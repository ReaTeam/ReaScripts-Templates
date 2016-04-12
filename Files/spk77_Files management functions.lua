-- From http://forum.cockos.com/showthread.php?p=1546709#post1546709

-- File handling functions (Lua)
-- (example at the end)

-- Returns "currently executed script's path"
function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end


-- "User input dialog" for setting a new file name
function dialog(file_name, file_ext)
  return reaper.GetUserInputs("Set new filename", 1, "Set a new filename", file_name)
end


-- "Message box": user can select what to do if a file already exists
function msgbox(file_name, file_ext)
  return reaper.ShowMessageBox("Overwrite file ".. "'" .. file_name .. file_ext .. "'?" , "File exists", 3)
  -- ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
end


-- Creates a new empty file
function create_new_file(full_path)
  local file = io.open(full_path, "w")
  io.close(file)
end


-- Saves (or creates) a file to script folder
function save_file_to_script_folder(file_name, file_ext)
  local script_path = get_script_path()
  local file_path = script_path .. file_name .. file_ext
  
  -- File doesn't exist -> create new file
  if not reaper.file_exists(file_path) then  
    create_new_file(file_path)
    return
  end
  
  -- File exists -> show messagebox (user can select if the file will be overwritten)
  local file_exist = true
  while file_exist == true do
    msgbox_ret = msgbox(file_name, file_ext)
    
    -- "Cancel" pressed
    if msgbox_ret == 2 then
      reaper.ShowConsoleMsg("'cancel' pressed (no action)\n")
      break
      
    -- "No" pressed
    elseif msgbox_ret == 7 then
      reaper.ShowConsoleMsg("'no' pressed (user can select what to do next)\n")
      dialog_ok, file_name = dialog(file_name, file_ext) -- show dialog -> user can set a new file name
      if dialog_ok and file_name ~= "" and file_name ~= nil then
        -- create a new file
        file_path = script_path .. file_name .. file_ext
        file_exist = reaper.file_exists(file_path)
        if not file_exist then
          create_new_file(file_path)
          break
        end
      else
        reaper.ShowConsoleMsg("'User input dialog cancelled' (no action)\n")
        break
      end
      
    -- "Yes" pressed
    else
      reaper.ShowConsoleMsg("'yes' pressed (the file would be overwritten here)\n")
      -- add more code here
      break
    end
  end
end



---------------------------------------------------------------------
-- Test: try to run this script multiple times to see how it works --
---------------------------------------------------------------------

-- a file named "file1.txt" will be created to the script folder
file_name = "file1"
file_ext = ".txt" 

save_file_to_script_folder(file_name, file_ext)
