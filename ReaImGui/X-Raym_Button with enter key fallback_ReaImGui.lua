function IsLastItemFocusedAndKeyPressed( val )
  if val == "enter" then val = 13 end
  return reaper.ImGui_IsItemFocused( ctx ) and reaper.ImGui_IsKeyPressed( ctx, val )
end

-- Draw a button and returned true if pressed or if focus and enter key is pressed
function ButtonEnter( ctx, label, w, h )
  return reaper.ImGui_Button( ctx, label, w, h ) or IsLastItemFocusedAndKeyPressed( "enter" )
end

if ButtonEnter( ctx, label, w, h ) then
  -- KEY ENTER PRESSED
end
