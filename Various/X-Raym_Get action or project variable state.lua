-- Action exemple : Record: Set record mode to selected item auto-punch (ID: 40253)

retval, value = reaper.SNM_GetIntConfigVar( 'projrecmode', -666)
value = reaper.GetToggleCommandState( 40253 )
