-- Idea from https://wiki.netio-products.com/index.php?title=Function_toboolean()
function toboolean( val )
	local out = nil
	if val == "false" then out = false end
	if val == "true" then out = true end
	if val == 0 then out = false end
	if val == 1 then out = true end
	if val == "" then out = false end
	if type(val) == "table" then out = false end
	return out
end
