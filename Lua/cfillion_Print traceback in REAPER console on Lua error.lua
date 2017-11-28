function main()
  foo('bar' / nil)
end

xpcall(main, function(errObject)
  reaper.ShowConsoleMsg(string.format('\n%s\n%s\n', errObject, debug.traceback()))
end)
