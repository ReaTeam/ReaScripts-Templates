function table.pack(...) -- For Lua < 5.2  https://www.lua.org/manual/5.2/manual.html#pdf-table.pack
      return { n = select("#", ...), ... }
end

function test()
    return "4", "3", "2", "1"
end

output = table.pack( test() )
-- alternative
output = { test() }

for i, v in ipairs (output) do
  print(v)
end
