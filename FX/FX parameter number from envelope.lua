TrackEnvelope = reaper.GetTrackEnvelope(reaper.GetTrack(0,0), 1)
_, strNeedBig = reaper.GetEnvelopeStateChunk(TrackEnvelope, '')
test = strNeedBig:match('PARMENV [%d]+'):gsub('PARMENV ','')
param_id = tonumber(test)

function Msg(value)
    reaper.ShowConsoleMsg(tostring(value).."\n")
end

Msg(strNeedBig)