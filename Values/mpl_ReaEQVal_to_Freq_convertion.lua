  ----------------------------------------------------------------------------- 
  function ReaEQVal2F(x) 
    local curve = (math.exp(math.log(401)*x) - 1) * 0.0025
    local freq = (24000 - 20) * curve + 20
    return freq
  end
  ----------------------------------------------------------------------------- 
  function F2ReaEQVal(F) 
    local curve =  (F - 20) / (24000 - 20)
    local x = (math.log((curve +0.0025) / 0.0025,math.exp(1) ))/math.log(401)
    return x
  end
  -----------------------------------------------------------------------------   
  t = ReaEQVal2F(0.5)
  x = F2ReaEQVal(t)
