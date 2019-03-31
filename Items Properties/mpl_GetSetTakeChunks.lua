function ExtractTakeChunks(item)
  local retval, chunk = reaper.GetItemStateChunk( item, '', false )
  local item_body = chunk:match('<ITEM(.-)NAME')
  local tk_chunk_section = chunk:match('(NAME.*)>')
  local tk_t = {}
  local tk = 0
  for line in tk_chunk_section:gmatch('[^\r\n]+') do
    if    (line:match('NAME ') and tk ==0)
      or  (line:match('TAKE') and not line:match('TAKE%a')) 
      or line:match('TAKE SEL')
      then tk=tk+1 
    end
    if not tk_t[tk] then tk_t[tk] = '' end
    tk_t[tk] = tk_t[tk]..'\n'..line
  end
  return item_body, tk_t
end
---------------------------------------
function ApplyTakeChunks(item,item_body, tk_chunks)
  local set_ch = '<ITEM'..item_body..table.concat(tk_chunks,'')..'\n>'
  set_ch = set_ch:gsub('\n+','\n')
  -- remove empty first take
    if set_ch:match('IID [%d]+\nTAKE') then 
      local IID = set_ch:match('IID (%d+)')
      set_ch = set_ch:gsub('IID [%d]+\nTAKE','IID '..IID) 
    end
  reaper.SetItemStateChunk( item, set_ch, false )
end
---------------------------------------
item = reaper.GetSelectedMediaItem(0,0)
item_body, tk_chunks = ExtractTakeChunks(item)
ApplyTakeChunks(item, item_body, tk_chunks)
