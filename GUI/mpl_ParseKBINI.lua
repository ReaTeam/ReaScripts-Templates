  function MPL_ParseKBINI()
    local kbini = reaper.GetResourcePath()..'/reaper-kb.ini'
    local f = io.open(kbini, 'r')
    local cont = f:read('a')
    if not f then return else  f:close() end
    t = {}
    for line in cont:gmatch('[^\r\n]+') do
      if line:match('KEY%s') then
        local flags, key, action, page = line:match('KEY%s(%d+)%s(%d+)%s([%d%a%_]+)%s(%d+)')
        if tonumber(key) ~= 0 then
          t[tonumber(key)] = { action = tonumber(action) or action,
                      page = tonumber(page),
                      flags =tonumber(flags)}
        end
      end
    end
    return t
  end
  
  t = MPL_ParseKBINI()
