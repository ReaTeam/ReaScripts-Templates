-- Note : This is just an exemple. It may not worked.

-- DEBUG FUNCTIONS
function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

reaper.ShowConsoleMsg("") -- Clean the console

-- GET THE TRACK
track = reaper.GetTrack(0, 0)

-- GET THE CHUNK
retval, xml = reaper.GetTrackStateChunk(track, "", false)
--Msg(xml)

-- PARSE SECTION
section = "SHOWINMIX"
answer1, answer2, answer3, answer4, answer5, answer6, answer7, answer8 = xml:match( section.." ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)\n" )

-- MODIFICATION
-- Don't forget to convert the result back to string.
answer4 = "1" -- 0 for hidden / 1 for visible

-- REPLACE THE LINE
csv = answer1
if answer2 ~= nil then csv = csv .. " " .. answer2 end
if answer3 ~= nil then csv = csv .. " " .. answer3 end
if answer4 ~= nil then csv = csv .. " " .. answer4 end
if answer5 ~= nil then csv = csv .. " " .. answer5 end
if answer6 ~= nil then csv = csv .. " " .. answer6 end
if answer7 ~= nil then csv = csv .. " " .. answer7 end
if answer8 ~= nil then csv = csv .. " " .. answer8 end

csv = csv .. "\n"

xml = string.gsub(xml, section .. ".+\n", section .. " " .. csv)
--Msg(xml)

-- SET THE CHUNK
retval = reaper.SetTrackStateChunk(track, xml, false)

reaper.TrackList_AdjustWindows(0)
reaper.UpdateArrange()
