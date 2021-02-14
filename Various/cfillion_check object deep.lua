-- check if var[a][b][c]... exists.
function dig(obj, ...)
  for i = 1, select('#', ...) do
    local sub = obj[select(i, ...)]
    if sub == nil then return end
    obj = sub
  end

  return obj
end
