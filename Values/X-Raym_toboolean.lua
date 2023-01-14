-- Lua: Value to Boolean function
-- Return false unless tonumber(val) > 0, "true" or "y"
function toboolean( val )
  local nval = tonumber(val)
  if nval then return nval > 0 end
  local t = { [true] = true, ["true"] = true, ["y"] = true, ["1"] = true }
  return t[val] or false
end
