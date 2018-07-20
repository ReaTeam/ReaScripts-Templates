--[[    Provides a set of iterator functions for working with tracks, items, and takes

Usage is similar to 'pairs' or 'file:lines' :

    for item in ProjectItems() do

        ...

    end

]]--

-- Returns an iterator, using the table returned by set_func
-- set_func MUST return a contiguous indexed table (i.e. 1,2,3,4,5...)
local function get_iterator(set_func)

    if not set_func then return end

    local iter = function(set)

        local t = set_func(set)
        if not t then return end
        
        local i = 0
        return
            function()
                i = i + 1
                return t[i]
            end

    end

    return iter
end


-- Expects a MediaItem
-- Returns a MediaTake
local Takes = get_iterator( function(item)

    if not item then return nil end
    local takes = {}
    for i = 1, reaper.GetMediaItemNumTakes(item) do
        takes[i] = reaper.GetMediaItemTake(item, i - 1)
    end

    return takes
end)

-- Expects a project number (0 if not given)
-- Returns a MediaItem
local ProjectItems = get_iterator( function(proj)

    if not proj then proj = 0 end

    local items = {}
    for i = 1, reaper.CountMediaItems(proj) do
        items[i] = reaper.GetMediaItem(0, i - 1)
    end

    return items

end)

-- Expects a MediaTrack
-- Returns a MediaItem
local TrackItems = get_iterator( function(track)

    if not track then return nil end

    local items = {}
    for i = 1, reaper.CountTrackMediaItems(track) do
        items[i] = reaper.GetTrackMediaItem(track, i - 1)
    end

    return items
end)

-- Expects a project number (0 if not given)
-- Returns a MediaItem
local SelectedItems = get_iterator( function(proj)

    if not proj then proj = 0 end

    local items = {}
    for i = 1, reaper.CountSelectedMediaItems() do
        items[i] = reaper.GetSelectedMediaItem(proj, i - 1)
    end

    return items

end)

-- Expects a project number(0 if not given)
-- Returns a MediaTrack
local Tracks = get_iterator( function(proj)

    if not proj then proj = 0 end

    local tracks = {}
    for i = 1, reaper.CountTracks(proj) do
        tracks[i] = reaper.GetTrack(proj, i - 1)
    end

    return tracks

end)

-- Expects a project number(0 if not given)
-- Returns a MediaTrack
local SelectedTracks = get_iterator( function(proj)

    if not proj then proj = 0 end

    local tracks = {}
    for i = 1, reaper.CountSelectedTracks(proj) do
        tracks[i] = reaper.GetSelectedTrack(proj, i - 1)
    end

    return tracks

end)




------------------------------------
-------- Example usage -------------
------------------------------------


local function Msg(str)
   reaper.ShowConsoleMsg(tostring(str) .. "\n")
end

local function loop_through_all()

    for track in Tracks() do

        local idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
        local ret, name = reaper.GetTrackName(track, "")
        Msg("track " .. math.floor(idx) .. ": " .. name)

        for item in TrackItems() do

            local idx = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
            Msg("\titem " .. math.floor(idx))

            for take in Takes(item) do

                local idx = reaper.GetMediaItemTakeInfo_Value(take, "IP_TAKENUMBER")
                Msg("\t\ttake " .. math.floor(idx))

            end

        end

    end

end

loop_through_all()