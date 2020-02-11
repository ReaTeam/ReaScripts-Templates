-- Use mpl take chunks function there:
-- https://github.com/ReaTeam/ReaScripts-Templates/blob/master/Items%20Properties/mpl_GetSetTakeChunks.lua

local retval, ItemStateChunk = reaper.GetItemStateChunk( item, '', false )        
local take_id = reaper.GetMediaItemInfo_Value( item, "I_CURTAKE" )

local item_body, tk_chunks = ExtractTakeChunks(item)
ItemFXStateChunk = tk_chunks[take_id+1]:match("<TAKEFX(.+)>$") or "" -- get current take FX chain

-- Get FX chain content from file
file = io.open(fx_chain_path, "r")
FXStateChunk = file:read("*a"):sub(0,-4)
FXStateChunk = FXStateChunk:gsub("REQUIRED_CHANNELS %d+\n", "") -- this field is only for tracks so we delete it
FXStateChunk = "  " .. FXStateChunk:gsub("\n", "\n  ") -- add indentation
file:close()

FXStateChunk = "<TAKEFX" .. ItemFXStateChunk .. FXStateChunk .. "\n>"

-- Add FX chain file content to the existing Take Fx chain
tk_chunks[take_id+1] = tk_chunks[take_id+1] .. "\n" .. FXStateChunk

ApplyTakeChunks(item,item_body, tk_chunks)
