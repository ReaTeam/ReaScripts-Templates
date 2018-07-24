--[[    Iterator functions for working with takes, items, and tracks

    Usage is the same as pairs or io.lines:

        for idx, item in SelectedTracks() do
            ...
        end

]]--

--[[
    Expects:
        items   MediaItem
    Returns:
        idx     Take index, from 0
        take    MediaTake
]]--
local function ItemTakes(item, idx)

    if not item then return end
    if not idx then return Takes, item, -1 end

    idx = idx + 1
    local take = reaper.GetMediaItemTake(item, idx)
    
    if take then return idx, take end


end


--[[
    Expects:
        proj    Project. Defaults to 0.
    Returns:
        idx     Item index in project, from 0
        item    MediaItem
]]--
local function ProjectItems(proj, idx)

    if not idx then return ProjectItems, proj or 0, -1 end

    idx = idx + 1
    local item = reaper.GetMediaItem(proj, idx)

    if item then return idx, item end

end


--[[
    Expects:
        track    MediaTrack
    Returns:
        idx     Item index in track, from 0
        item    MediaItem
]]--
local function TrackItems(track, idx)

    if not track then return end
    if not idx then return TrackItems, track, -1 end

    idx = idx + 1
    local track = reaper.GetTrackMediaItem(track, idx)

    if track then return idx, track end

end


--[[
    Expects:
        proj    Project. Defaults to 0.
    Returns:
        idx     Item index in selection, from 0
        item    MediaItem
]]--
local function SelectedItems(proj, idx)

    if not proj then proj = 0 end
    if not idx then return SelectedItems, proj, -1 end

    idx = idx + 1
    local item = reaper.GetSelectedMediaItem(proj, idx)

    if item then return idx, item end

end


--[[
    Expects:
        proj    Project. Defaults to 0.
    Returns:
        idx     Track index in project, from 0
        track   MediaTrack
]]--
local function ProjectTracks(proj, idx)

    if not idx then return Tracks, proj or 0, -1 end

    idx = idx + 1
    local track = reaper.GetTrack(proj, idx)

    if track then return idx, track end

end


--[[
    Expects:
        proj    Project. Defaults to 0.
    Returns:
        idx     Item index in selection, from 0
        track   MediaTrack
]]--
local function SelectedTracks(proj, idx)

    if not idx then return SelectedTracks, proj or 0, -1 end

    idx = idx + 1
    local track = reaper.GetSelectedTrack(proj, idx)

    if track then return idx, track end

end





------------------------------------
-------- Example usage -------------
------------------------------------


-- Store all strings passed to xMsg in a table and print them when the script
-- exits. Windows lags really hard if you print a lot of messages individually.
local xMsgs = {}
local function xMsg(str)
    xMsgs[#xMsgs + 1] = tostring(str)
end
local function print_xMsgs()
    reaper.ShowConsoleMsg( table.concat(xMsgs, "\n") )
end
reaper.atexit(print_xMsgs)


local function iterator_example()

    for idx, track in ProjectTracks() do

        local ret, name = reaper.GetTrackName(track, "")
        xMsg("Track " .. math.floor(idx) .. ": " .. name)

        for idx, item in TrackItems(track) do

            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            xMsg("\tItem " .. math.floor(idx) .. " @ " .. string.format("%.4f", pos) .. "s")

            for idx, take in ItemTakes(item) do

                local active = reaper.GetActiveTake(item)
                xMsg("\t\tTake " .. math.floor(idx) .. (take == active and " (active)" or ""))

            end

        end

    end

end

iterator_example()