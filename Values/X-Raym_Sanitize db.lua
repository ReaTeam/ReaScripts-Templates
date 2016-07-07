function SanitizeDB( val, min_val, max_val, default )

	-- TYPE
	if not type( val ) == "number" then return default end

	-- RELATIVE
	if val > 0 then val = - val end

	-- ROUNDING
	val = math.floor( val + 0.5 )

	-- LIMITS
	if val < min_val then val = min_val end
	if val > max_val then val = max_val end

	return val

end

val = -30

min_val = -144
max_val = 0
default_val = -50

val = SanitizeDB( val, min_val, max_val, default_val )
