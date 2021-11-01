_, N = ...
AceHandler = LibStub("AceAddon-3.0"):NewAddon("HMB", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0");
local InternalName = "HMB";

local defaults = {
    global = {
        enabled = true,
        characterData = {},
        soundData = {}
    }
}

local options = {
    type = "group",
    name = "Help My Brewski Options",
    handler = AceHandler,
    args = {
        general = {
            name = "General Options",
            type = "group",
            args = {
                toggle = {
                    name = "Sound Enabled",
                    desc = "Enables / disables the sound effects",
                    type = "toggle",
                    set = function(info, val) AceHandler.db.global.enabled = val end,
                    get = function(info) return AceHandler.db.global.enabled end
                },
                uwu = {
                    name = "Kawaii Enabled",
                    desc = "Enables / disables the uwuizer",
                    type = "toggle",
                    set = function(info, val) AceHandler.db.global.uwuEnabled = val end,
                    get = function(info) return AceHandler.db.global.uwuEnabled end
                }
            }
        },
        playerOptions = {
            name = "Player Options",
            type = "group",
            childGroups = "select",
            args = {}
        }
    }
}

function AceHandler:OnSpellSuccess(event, unit, guid, skillID)
    if(self.db.global.enabled) then --Skip if not enabled
        if(unit:find("player") or unit:find("raid") or unit:find("party")) then --Self or party/raid member
            local player = UnitName(unit)
            local skillStringID = tostring(skillID)
            local skill = nil

            if(self.db.global.characterData[player] ~= nil and self.db.global.characterData[player][skillStringID] ~= nil) then
                if(self.db.global.characterData[player][skillStringID].SkillName == nil) then
                    self.db.global.characterData[player][skillStringID].SkillName = GetSpellLink(skillID)
                end
                skill = self.db.global.characterData[player][skillStringID]
            elseif(self.db.global.characterData["ANY PARTY"][skillStringID] ~= nil) then
                if(self.db.global.characterData["ANY PARTY"][skillStringID].SkillName == nil) then
                    self.db.global.characterData["ANY PARTY"][skillStringID].SkillName = GetSpellLink(skillID)
                end
                skill = self.db.global.characterData["ANY PARTY"][skillStringID]
            end
            if(skill ~= nil) then
                N:DebugPrint("Detected '"..player.."' using skill "..skill.SkillName.."!");
                N:SoundHandler(skill.SoundID);
            else
                N:DebugPrint("SkillID: "..skillID.." | SkillName: "..GetSpellLink(skillID));
            end
        end
    end
end

function AceHandler:SendChatMessage(msg, system, language, channel, targetPlayer)
    if(self.db.global.uwuEnabled and system ~= "EMOTE") then
        msg = N:HandleChatMessage(msg)
    end
    self.hooks["SendChatMessage"](msg, system, language, channel, targetPlayer)
end

function AceHandler:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HMBDB", defaults);
    self:LoadCharacters();
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable(InternalName, options);
    diag = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(InternalName, "HMB Config");

    self:RegisterChatCommand(InternalName, "ChatHandler");
    function self:ChatHandler(input)
        InterfaceOptionsFrame_OpenToCategory(diag);
        InterfaceOptionsFrame_OpenToCategory(diag);
    end
    
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellSuccess");
    self:RawHook("SendChatMessage", true);

    N:DebugPrint(InternalName.." addon initialized!")
end

function AceHandler:RefreshAll()
    self:LoadCharacters();
end

function AceHandler:LoadCharacters()
    if(self.db.global.characterData["ANY PARTY"] == nil) then
        self.db.global.characterData["ANY PARTY"] = {}
    end

    options.args.playerOptions.args = {    
        addPlayer = {
            name = "Add Player",
            desc = "Type a name and click okay to add character to dropdown list.",
            type = "input",
            set = "AddCharacter"
        },
        removePlayer = {
            name = "Remove Player",
            desc = "Select a name from the dropdown to remove a character.",
            type = "select",
            values = "GetCharacters",
            set = "RemoveCharacter",
            confirm = true
        }
    };
    for character, data in pairs(self.db.global.characterData) do
        local fields = {
            name = character,
            type = "group",
            args = {
                addSpell = {
                    name = "Add Spell",
                    type = "input",
                    confirm = "AddSpellConfirm",
                    validate = "AddSpellValidate",
                    set = function(var, val) self.db.global.characterData[character][val] = {}; self:RefreshAll(); end
                }
            }
        }
        for key, info in pairs(data) do
            local spellName = GetSpellLink(key);
            fields.args[tostring(key)] = {
                name = spellName,
                type = "group",
                args = {
                    spellHeader = {
                        name = spellName,
                        type = "header",
                        order = 1
                    },
                    spellSound = {
                        name = "Spell Sound",
                        type = "select",
                        values = "GetSounds",
                        order = 2,
                        get = function(var) return info.SoundID end,
                        set = function(var, val) info.SoundID = val; self:RefreshAll(); end
                    },
                    spellRemove = {
                        name = "Remove Spell",
                        type = "execute",
                        order = 3,
                        func = function(var) self.db.global.characterData[character][tostring(key)] = nil; self:RefreshAll(); end
                    }
                }
            }
        end
        options.args.playerOptions.args[character] = fields;
    end
    N:DebugPrint('Loaded character data.');
end

function AceHandler:AddCharacter(info, name)
    if(name == "") then
        UIErrorsFrame:AddMessage("Must enter a name!", 1.0, 0.0, 0.0, 5.0);
    elseif(self.db.global.characterData[name]) then
        UIErrorsFrame:AddMessage("Character already added!", 1.0, 0.0, 0.0, 5.0);
    else
        self.db.global.characterData[name] = {};
        self:RefreshAll();
    end
end

function AceHandler:RemoveCharacter(info, name)
    if(name == "") then
        UIErrorsFrame:AddMessage("Must enter a name!", 1.0, 0.0, 0.0, 5.0);
    else
        self.db.global.characterData[name] = nil;
        self:RefreshAll();
    end
end

function AceHandler:GetCharacters()
    local characters = {}
    for name, data in pairs(self.db.global.characterData) do
        characters[name] = name;
    end
    return characters;
end

function AceHandler:GetSounds()
    local sounds = {}
    for k, v in pairs(N.sounds) do
        sounds[k] = k
    end
    return sounds
end

function AceHandler:AddSpellValidate(info, spell)
    if(GetSpellLink(spell) == nil) then  
        return "Spell not found";
    else
        return true;
    end
end

function AceHandler:AddSpellConfirm(info, spell)
    return "Add spell "..GetSpellLink(spell).."?";
end