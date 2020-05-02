retval, files_csv = reaper.GetSetProjectInfo_String(0, "RENDER_TARGETS", '', false)
files = {}
for file in files_csv:gmatch("[^;]*") do
  table.insert(files, file)
end
