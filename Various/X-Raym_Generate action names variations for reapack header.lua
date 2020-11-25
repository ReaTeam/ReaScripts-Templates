-- https://github.com/cfillion/reapack-index/wiki/Examples#multiple-slots

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val) .. "\n")
end

prefix = " *   [main] . > X-Raym_"
suffix = ".lua"
name = " selected tracks VCA follow to group "

reaper.ClearConsole()

for i = 1, 32 do
  Msg(prefix .. "Set" .. name .. i .. suffix)
end

for i = 1, 32 do
  Msg(prefix .. "Unset" .. name .. i .. suffix)
end

for i = 1, 32 do
  Msg(prefix .. "Toggle" .. name .. i..suffix)
end
