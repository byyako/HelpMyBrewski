_, N = ...
local LSM = LibStub("LibSharedMedia-3.0")

function N:UpdateSounds(event, mtype, key)
    if(mtype == "sound") then
        self.sounds = LSM:HashTable("sound")
    end
end

function N:SoundHandler(SoundID)
    if(N.sounds[SoundID] ~= nil) then
        PlaySoundFile(N.sounds[SoundID], "MASTER")
    end
end

LSM:Register("sound", "HMB: Owen Wow!", [[Interface\AddOns\HelpMyBrewski\Sounds\owen_wowson.mp3]])
LSM:Register("sound", "HMB: MJ Hoo!", [[Interface\AddOns\HelpMyBrewski\Sounds\michael_jackson.mp3]])
LSM:Register("sound", "HMB: MJ Baby!", [[Interface\AddOns\HelpMyBrewski\Sounds\mj_baby.mp3]])
LSM:Register("sound", "HMB: Da Baby", [[Interface\AddOns\HelpMyBrewski\Sounds\da_baby.mp3]])
LSM:Register("sound", "HMB: Nope", [[Interface\AddOns\HelpMyBrewski\Sounds\nope.mp3]])
LSM:Register("sound", "HMB: Discord", [[Interface\AddOns\HelpMyBrewski\Sounds\discord_sounds.mp3]])
LSM:Register("sound", "HMB: Shia Do it", [[Interface\AddOns\HelpMyBrewski\Sounds\do_it.mp3]])
LSM:Register("sound", "HMB: Sad", [[Interface\AddOns\HelpMyBrewski\Sounds\sad.mp3]])
LSM:Register("sound", "HMB: Surprise", [[Interface\AddOns\HelpMyBrewski\Sounds\surprise.mp3]])

LSM.RegisterCallback(N, "LibSharedMedia_Registered", "UpdateSounds")