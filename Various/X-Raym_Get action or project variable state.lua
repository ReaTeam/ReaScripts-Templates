-- Action exemple : Record: Set record mode to selected item auto-punch (ID: 40253)

-- Project Value style (need SWS)
retval, value = reaper.SNM_GetIntConfigVar( 'projrecmode', -666)

-- Action state on/off style
value = reaper.GetToggleCommandState( 40253 )
