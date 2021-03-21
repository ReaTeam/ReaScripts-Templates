-- Windoing functions for FFT

-- https://en.wikipedia.org/wiki/Window_function
-- https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/46092/versions/3/previews/coswin.m/index.html?access_key=

local function HannWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    t[i+1] = .5*(1-cos(2*pi*i/size))
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end


local function HammingWindow( size, exact )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local a0 = exact and .5383553946707251 or .54
  local a1 = exact and .4616446053292749 or .46
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    t[i+1] = a0-a1*cos(2*pi*i/size)
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end


local function BlackmanWindow( size, exact )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local a0 = exact and .42659071367154 or .42
  local a1 = exact and .49656061908856 or .5
  local a2 = exact and .076848667239897 or .08
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    local x = 2*pi*i/size
    t[i+1] = a0-a1*cos(x)+a2*cos(2*x)
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end


local function BlackmanHarrisWindow( size, exact )
  -- 4-term
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local a0 = exact and .358750287312166 or .35875
  local a1 = exact and .488290107472600 or .48829
  local a2 = exact and .141279712970519 or .14128
  local a3 = exact and .011679892244715 or .01168
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    local x = 2*pi*i/size
    t[i+1] = a0-a1*cos(x)+a2*cos(2*x)-a3*cos(3*x)
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end


local function FiveTermCosineWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local a0 = 3.232153788877343e-001
  local a1 = 4.714921439576260e-001
  local a2 = 1.755341299601972e-001
  local a3 = 2.849699010614994e-002
  local a4 = 1.261357088292677e-003
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    local x = 2*pi*i/size
    t[i+1] = a0-a1*cos(x)+a2*cos(2*x)-a3*cos(3*x)+a4*cos(4*x)
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end


local function SevenTermCosineWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  local a0 = 2.712203605850388e-001
  local a1 = 4.334446123274422e-001
  local a2 = 2.180041228929303e-001
  local a3 = 6.578534329560609e-002
  local a4 = 1.076186730534183e-002
  local a5 = 7.700127105808265e-004
  local a6 = 1.368088305992921e-005
  local adj = size % 2 == 0 and 1 or 0
  local mid = math.ceil( size/2 )
  size = size-1
  for i = 0, mid-1 do
    local x = 2*pi*i/size
    t[i+1] = a0-a1*cos(x)+a2*cos(2*x)-a3*cos(3*x)+a4*cos(4*x)-a5*cos(5*x)+a6*cos(6*x)          
  end
  for i = 0, mid do
    t[mid+i+adj] = t[mid-i]
  end
  return t
end
