-- Display a message in the console for debugging
function Msg(value)
  reaper.ShowConsoleMsg(tostring(value) .. "\n")
end

Msg("Lua Global Function")
for k,v in pairs( _G ) do
   reaper.ShowConsoleMsg( k .. " = " .. tostring(v) .. "\n")
end

Msg("\nREAPER Functions")
for k, v in pairs(reaper) do
  reaper.ShowConsoleMsg( k .. " = " .. tostring(v) .. "\n")
end
