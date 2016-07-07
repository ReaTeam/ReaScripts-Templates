function SanitizeDB( val, min, max, default )

	-- TYPE
	if not type( val ) == "number" then return default end

	-- RELATIVE
	if val > 0 then val = - val end

	-- ROUNDING
	val = math.floor( val + 0.5 )

	-- LIMITS
	if val < min then val = min end
	if val > max then val = max end

	return val

end

val = SanitizeDB( 150, 0, 100, 72 )
