-- Use OSARA REAPER Extension for handling the API funciton
-- Use software like NVA to manage to text to speech

function speak(str)
 if reaper.osara_outputMessage then
    reaper.osara_outputMessage(str)
  end
end

cur_pos = reaper.GetCursorPosition()

pos = reaper.format_timestr_pos( cur_pos, '', 5 )

hour, minutes, seconds, frames = pos:match("(%d):(%d%d):(%d%d):(%d%d)")
 
speak( hour .. " heure " .. minutes .. " minutes " .. seconds .. " seconds " .. frames .. " frames ")
