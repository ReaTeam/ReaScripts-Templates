-- https://forum.cockos.com/showpost.php?p=2528121&postcount=27
local function Break( msg )
  local line = "Breakpoint at line " .. debug.getinfo(2).currentline
  local ln = "\n" .. string.rep("=", #line) .. "\n"
  local trace = debug.traceback(ln .. line)
  trace = trace:gsub("(stack traceback:\n).*\n", "%1")
  reaper.ShowConsoleMsg(trace .. ln .. "\n" )
  reaper.MB(tostring(msg) .. "\n\nContinue?", line, 0 )
end
