-- Extracted from cfillion_Interactive ReaScript.lua
-- Works best on macOS. It's slower on Windows where a cmd.exe window is
-- briefly displayed, potentially messing with window focus in REAPER.

--[[ USAGE
copy("hello world");
local text = paste(); --> "hello world"
--]]

local function iswindows()
  return reaper.GetOS():find('Win') ~= nil
end

local function ismacos()
  return reaper.GetOS():find('OSX') ~= nil
end

local function copy(text)
  local tool

  if ismacos() then
    tool = 'pbcopy'
  elseif iswindows() then
    tool = 'clip'
  end

  local proc = assert(io.popen(tool, 'w'))
  proc:write(text)
  proc:close()
end

local function paste()
  local tool

  if ismacos() then
    tool = 'pbpaste'
  elseif iswindows() then
    tool = 'powershell -windowstyle hidden -Command Get-Clipboard'
  end

  local proc = assert(io.popen(tool, 'r'))
  local text = proc:read("*all")
  proc:close()
  
  return text
end
