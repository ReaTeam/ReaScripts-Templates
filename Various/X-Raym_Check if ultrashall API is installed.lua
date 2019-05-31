-- DEPENDENCY
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

if not ultraschall and not ultraschall.InsertMediaItem_MediaItem then
  reaper.MB("Please install Ultrashall API, available via Reapack. Check online doc of the script for more infos.", "Error", 0)
  return
end
