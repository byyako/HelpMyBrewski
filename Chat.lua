_, N = ...

local emotes = {
    "nuzzwes.",
    "nuzzwes and sniffs you.",
    "whispews softwy.",
    "bwushes.",
    "yiffs in response."
}

local faces = {
    " rawr x3 ",
    " :3 ",
    " ^^ ",
    " >w< ",
    " n_n ",
    " ^^;; ",
    " σωσ ",
    " òωó ",
    "  ♥w ♥ ",
    " ☆w☆ ",
    " ︠uw ︠u "
}

function N:HandleChatMessage(msg)
    msg = msg:lower()
    msg = msg:gsub("[lr]",
        function(w)
            if(math.random() >= 0.7) then
                return "w";
            else
                return w;
            end
        end);

    local identity = msg:match("%[.-%]"); --Store identity if exists
    msg = msg:gsub("%[.-%]", ""); --Remove identity so prefix won't be weird

    msg = msg:gsub("[%.%?!]", function(w) if(math.random() >= 0.8) then return faces[math.random(#faces)] else return w end end);

    if(identity ~= nil) then
        msg = identity..msg;
    end

    if (math.random() >= 0.5) then --add prefix roughly 50% of the time
        SendChatMessage(emotes[math.random(#emotes)], "EMOTE")
    end

    return msg:sub(1, 255) --Ensure we don't go over the message limit with cringe
end