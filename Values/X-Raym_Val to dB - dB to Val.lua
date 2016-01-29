-- Mod from SPK77
-- http://forum.cockos.com/showpost.php?p=1608719&postcount=6

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

-- test
some_dB_val = dBFromValue(2) -- should be ~6.02 dB
some_dB_val_to_val = ValFromdB(some_dB_val) -- should be "2"