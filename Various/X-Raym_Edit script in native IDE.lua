  script_path = script_path or debug.getinfo(1).source:match("@?(.+)")
  reaper_ini_path = reaper_ini_path or reaper.get_ini_file()
  reaper.BR_Win32_WritePrivateProfileString( "reaper", "lastscript", script_path, reaper_ini_path )
  reaper.Main_OnCommand( 41931, 0 ) -- ReaScript: Run/edit last ReaScript (EEL2, lua, or python)
