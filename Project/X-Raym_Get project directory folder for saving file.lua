suffix = " - Items List.html"

-- Get Path from file name
function GetPath(str,sep)
    return str:match("(.*"..sep..")")
end


-- Check if project has been saved
function IsProjectSaved()
	-- OS BASED SEPARATOR
	if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
		separator = "\\"
	else
		separator = "/"
	end

	retval, project_path_name = reaper.EnumProjects(-1, "")
	if project_path_name ~= "" then
		
		dir = GetPath(project_path_name, separator)
    
		-- Get file name for the output file
		name = string.sub(project_path_name, string.len(dir) + 1)
		name = string.sub(name, 1, -5)

		name = name:gsub(dir, "")

		file = dir .. name .. suffix

		project_saved = true
		
		return project_saved
	
	else
		display = reaper.ShowMessageBox("You need to save the project to execute this script.", "HTML Export", 1)

		if display == 1 then

			reaper.Main_OnCommand(40022, 0) -- SAVE AS PROJECT

			return IsProjectSaved()
			
		end
	end
end