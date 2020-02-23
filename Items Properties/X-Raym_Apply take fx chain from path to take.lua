-- Use mpl take chunks function there:
-- https://github.com/ReaTeam/ReaScripts-Templates/blob/master/Items%20Properties/mpl_GetSetTakeChunks.lua

local retval, ItemStateChunk = reaper.GetItemStateChunk( item, '', false )        
local take_id = reaper.GetMediaItemInfo_Value( item, "I_CURTAKE" )

local item_body, tk_chunks = ExtractTakeChunks(item)

takeFXStateChunk = tk_chunks[take_id+1]:match("<TAKEFX(.+)>") or ""

file = io.open(fx_chain_path, "r")
FXStateChunk = file:read("*a"):sub(0,-4)
override_take_chan = tonumber(FXStateChunk:match("REQUIRED_CHANNELS (%d+)")) -- this would be only needed for track
FXStateChunk = FXStateChunk:gsub("REQUIRED_CHANNELS %d+\n", "")
FXStateChunk = "  " .. FXStateChunk:gsub("\n", "\n  ") -- add indentation
file:close()

current_take_chan = tonumber(tk_chunks[take_id+1]:match("TAKEFX_NCH (%d+)"))
if current_take_chan and not override_take_chan then override_take_chan = current_take_chan end
if current_take_chan and override_take_chan and current_take_chan > override_take_chan then override_take_chan = current_take_chan end

if not override_take_chan then
  FXStateChunk = "<TAKEFX" .. takeFXStateChunk .. FXStateChunk .. "\n>"
else
  FXStateChunk = "<TAKEFX" .. takeFXStateChunk .. FXStateChunk .. "\n>\nTAKEFX_NCH " .. override_take_chan
end

tk_chunks[take_id+1] = tk_chunks[take_id+1] .. "\n" .. FXStateChunk
ApplyTakeChunks(item,item_body, tk_chunks)
