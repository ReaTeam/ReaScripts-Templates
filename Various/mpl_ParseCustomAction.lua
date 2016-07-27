function ParseCustomAction(CA_string)
  if not CA_string then return end
  local t = {}
  for action in CA_string:gmatch('[^%s]+') do t[#t+1] = action end
  if #t == 0 then return end
  for i = 1, #t do reaper.Main_OnCommand(reaper.NamedCommandLookup( t[i] ), 0) end
end


-- TEST:
 
  custom_action_string = 
[[
40034 41173 _BR_SAVE_CURSOR_POS_SLOT_1 _SWS_PROJEND _FNG_MOVE_TO_EDIT 
_SWS_SAFETIMESEL 41824 _BR_RESTORE_CURSOR_POS_SLOT_1 _FNG_MOVE_TO_EDIT
]]

ParseCustomAction(custom_action_string)
