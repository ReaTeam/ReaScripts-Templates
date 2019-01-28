local e = 2.718281828459
local function ln(x)
  return math.log(x,e)
end
local function sinh_inv(x)
  return ln(x + math.sqrt(x^2 + 1) )
end
function QToOct(Q)
  return (2/ln(2))*sinh_inv(1/(2*Q))
end

-- a = QToOct(1.4)
-- = 1.009759163821 octaves
