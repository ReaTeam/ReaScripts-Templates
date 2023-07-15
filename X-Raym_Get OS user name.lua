  OS = reaper.GetOS()

  if OS == "Win64" or OS == "Win32" then
    username = os.getenv('USERNAME')
  else
    username = os.getenv('USER')
  end
