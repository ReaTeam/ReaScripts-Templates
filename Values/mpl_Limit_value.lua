  function F_limit(val,min,max)
    if val == nil or min == nil or max == nil then return end
    local val_out = val
    if val < min then val_out = min end
    if val > max then val_out = max end
    return val_out
  end 
  
  val = F_limit(150,0,100)