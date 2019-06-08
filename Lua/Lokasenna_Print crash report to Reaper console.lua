--[[
    Adapted from cfillion's "Print traceback in REAPER console on Lua error" template.
    
    This version includes the original error message, adds filenames for scripts using
    several modules, and formats the output message to be a little more readable:
    
    Error: Lokasenna_Print crash report to Reaper console.lua:8: attempt to perform arithmetic on a string value

    Stack traceback:
        Lokasenna_Print crash report to Reaper console.lua:20: in function 'crash'
        Lokasenna_Print crash report to Reaper console.lua:8: in function 'main'
            [C]: in function 'xpcall'
        Lokasenna_Print crash report to Reaper console.lua:45: in main chunk
    
    
    xpcall can be used in the defer loop of a graphical script by wrapping it inside
    your main function:
    
    function main()
        
        xpcall( function()
        
        -- do your own stuff here
        
        reaper.defer(main)
        
        end, crash)
        
    end
    
]]--


function main()
  foo('bar' / nil)
end


crash = function (errObject)

  local byLine = "([^\r\n]*)\r?\n?"
  local trimPath = "[\\/]([^\\/]-:%d+:.+)$"
  local err = errObject   and string.match(errObject, trimPath)
                          or  "Couldn't get error message."

  local trace = debug.traceback()
  local stack = {}
  for line in string.gmatch(trace, byLine) do
    local str = string.match(line, trimPath) or line
    stack[#stack + 1] = str
  end

  local name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)$")

  local ret = reaper.ShowMessageBox(
      name.." has crashed!\n\n"..
      "Would you like to have a crash report printed "..
      "to the Reaper console?",
      "Oops",
      4
    )

  if ret == 6 then
    reaper.ShowConsoleMsg(
      "Error: "..err.."\n\n"..
      "Stack traceback:\n\t"..table.concat(stack, "\n\t", 2).."\n\n"..
      "Reaper:       \t"..reaper.GetAppVersion().."\n"..
      "Platform:     \t"..reaper.GetOS()
    )
  end
end

xpcall(main, crash)
