-- Lua: Value to Boolean function
-- Return false unless tonumber(val) > 0, "true" or "y"
function toboolean( val )
  if tonumber(val) and tonumber(val) > 0 then val = "1" end
  local t = { ["true"] = true, ["y"] = true, ["1"] = true }
  return t[val] or false
end

