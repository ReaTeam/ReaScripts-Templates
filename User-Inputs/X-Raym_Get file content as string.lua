-- https://stackoverflow.com/questions/10386672/reading-whole-files-in-lua
function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

retval, filename = reaper.GetUserFileNameForRead("", "Open", "" )
 
content = readAll(filenameNeed4096)
