--[[
 * ReaScript Name: Parent Script Name - ReaImGui
 * About: To use this, just duplicate it in a folder next to a GFX script, and rename the script just like target one but with _ReaImGui suffix. Also change name its metadata Name value if you plan to share it via Reapack.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > ReaTeam > ReaScripts-Templates
 * Repository URI: https://github.com/ReaTeam/ReaScripts-Templates
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

-- USER CONFIG AREA -------------------------------------------------
GFX2IMGUI_NO_LOG = false
GFX2IMGUI_UNUSED_FONTS_CACHE_SIZE = 16
GFX2IMGUI_PROFILE = false -- true needs profiler.lua in Scripts folder. See https://github.com/ReaTeam/ReaScripts-Templates/blob/master/Profiler/profiler.lua

------------------------------------------ END OF USER CONFIG AREA --

-- NOTE: Nothing to modify below. Just read instructions in the About header field.

-- ReaImGui Check
if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

-- GFX2ImGui Check
local gfx2imgui_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/gfx2imgui.lua'
local os_sep = package.config:sub(1,1)
gfx2imgui_path = gfx2imgui_path:gsub( "/", os_sep )
if reaper.file_exists( gfx2imgui_path ) then
  gfx = dofile( gfx2imgui_path )
else
  gfx2imgui_url = "https://github.com/cfillion/reaimgui/blob/gfx2imgui/examples/gfx2imgui.lua"
  reaper.MB("Missing dependency: gfx2imgui.lua\n" .. gfx2imgui_path .. "\n\nDownload it via:\n" .. gfx2imgui_url, "Error", 0)
  reaper.ShowConsoleMsg( gfx2imgui_url .. "\n")
  return
end

-- Parent Script Check
local script_path = debug.getinfo(1,'S').source:match("@?(.*)")
local parent_script_path = script_path:gsub( "_ReaImGui", "" ) -- 1. Name of the parent script, based on this script file name

if reaper.file_exists( parent_script_path ) then
  dofile( parent_script_path )
else
  reaper.MB("Missing parent script.\n" .. parent_script_path, "Error", 0)
  return
end
