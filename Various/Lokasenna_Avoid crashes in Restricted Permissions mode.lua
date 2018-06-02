--[[
    
    Reaper's "restricted permissions" mode keeps scripts from getting up to anything naughty
    by removing access to the computer outside Reaper. Specifically, the 'os' and 'io' libraries
    are blocked.
    
    However, as of this writing there's no way for a script to check for restricted permissions,
    and trying to use functions from those libraries results in a generic Lua error:
        
        Error: script.lua:199: attempt to index a nil value (global 'os')
        
    To an end-user, this looks like a script bug - there's no mention of it being related to
    permissions.
    
    The functions below will let your scripts sidestep that problem. Cheers.   
    
]]--


function error_restricted()

    reaper.MB(  "This script tried to access a function that isn't available in Reaper's 'restricted permissions' mode." ..
                "\n\nThe script was NOT necessarily doing something malicious - restricted scripts are unable " ..
                "to access a number of basic functions such as reading and writing files." ..
                "\n\nPlease let the script's author know, or consider running the script without restrictions if you feel comfortable.",
                "Script Error", 0)
    
    -- Probably return something specific to make your script exit 
    -- without crashing. Or not.
    
end

-- In 'restricted permissions' mode, 'os' and 'io' don't exist, which is easy to check for.
if not os then

    -- Create dummy libraries. When the script calls i.e. io.open, Lua looks at the dummy table
    -- and finds that io[open] is nil. Since io has an __index function, Lua will call that
    -- function to try and resolve the problem, triggering the error message above.
    os = setmetatable({}, { __index = error_restricted })
    io = setmetatable({}, { __index = error_restricted })    
    
end