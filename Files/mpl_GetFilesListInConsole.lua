path =  [[C:\Users]]



str = ''
for i = 0, 20 do
  test = reaper.EnumerateFiles( path, i )
  if not test then break end
  str = str..'\n'..test
end

reaper.ShowConsoleMsg('')
reaper.ShowConsoleMsg(str)
