function dig(array, ...)
  for i = 1, select('#', ...) do
    if type(array) ~= 'table' then return false end
    array = array[select(i, ...)]
    if array == nil then return false end
  end
  return true
end

t = { animal = { tetrapod = { dog = true } } }
print (dig( t, "animal", "tetrapod", "dog" ))

-- More flexible Better version than
function CheckTableKey(var, k, l)
  if not var[k] then return false end
  if not var[k][l] then return false end
  return true
end
