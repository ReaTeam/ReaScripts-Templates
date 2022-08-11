local function GetExpectedXFadeLength()
  local xfadetime = tonumber(({reaper.get_config_var_string( "defsplitxfadelen" )})[2])
  if not xfadetime then
    error('Could not retrieve "defsplitxfadelen" from reaper.ini')
  end
  local hzoomlevel = reaper.GetHZoomLevel()
  if hzoomlevel >= 96000 then return 0
  elseif xfadetime > 50/hzoomlevel then return 50/hzoomlevel
  else return xfadetime
  end
end

xfadelen = GetExpectedXFadeLength()

-- https://www.askjf.com/index.php?q=6331s - Thanks Justin!
