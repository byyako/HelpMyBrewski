_, N = ...
local DEBUG = true;


function N:DebugPrint(message)
    if(DEBUG == true) then
        print("[DEBUG]"..message);
    end
end