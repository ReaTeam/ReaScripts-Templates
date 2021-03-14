local function HannWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  size = size-1
  for i = 0, size do
    t[i+1] = .5*(1-cos(2*pi*i/size))
  end
  return t
end


local function HammingWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  size = size-1
  for i = 0, size do
    t[i+1] = .54-.46*cos(2*pi*i/size)
  end
  return t
end


local function BlackmanWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  size = size-1
  for i = 0, size do
    t[i+1] = .42-.5*cos(2*pi*i/size)+.08*cos(4*pi*i/size)
  end
  return t
end


local function BlackmanHarrisWindow( size )
  local pi = math.pi
  local cos = math.cos
  local t = {}
  size = size-1
  for i = 0, size do
    t[i+1] = .35875-.48829*cos(2*pi*i/size)+.14128*cos(4*pi*i/size)-.01168*cos(6*pi*i/size)
  end
  return t
end
