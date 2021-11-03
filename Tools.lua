_, N = ...
local DEBUG = false;


function N:DebugPrint(message)
    if(DEBUG == true) then
        print("[DEBUG]"..message);
    end
end