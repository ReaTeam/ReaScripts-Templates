	-- GET LOOP
	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	-- IF LOOP ?
	if start_time ~= end_time then time_selection = true end
