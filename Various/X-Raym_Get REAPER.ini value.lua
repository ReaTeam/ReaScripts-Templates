inipath = reaper.get_ini_file()
retval, value = reaper.BR_Win32_GetPrivateProfileString("reaper", "workrender", "", inipath)

-- reaper.BR_Win32_WritePrivateProfileString( sectionName, keyName, value, inipath )
