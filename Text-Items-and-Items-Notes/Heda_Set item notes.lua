-- Work with REAPER native but far less efficient than SWS dedicated function.
-- reaper.ULT_SetMediaItemNote(item,newnote)
	
function rtrim(s)
	local n = #s
	while n > 0 and s:find("^|", n) do n = n - 1 end
	return s:sub(1, n)
end

function string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end

function HedaSetNotes(item,newnote)
	-- X-Raym: prevent multiple lines note break and trim any trailing last empty line
	newnote = newnote:gsub("\n", "\n|")
	last_char = string.sub(newnote, -1)
	if last_char == "|" then
		newnote = rtrim(newnote)
	end
	
	--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
	retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
	--dbug("\nChunk=" .. s .. "\n")
	has_notes = s:find("<NOTES")  -- has notes?
	if has_notes then
		-- there are notes already
		chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
		newchunk = chunk .. newnote .. chunk2
		--dbug(newchunk .. "\n")
		
	else
		--there are still no notes
		chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
		newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
		--dbug(newchunk .. "\n")
	end
	reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
end
