local ctx = reaper.ImGui_CreateContext('My script')
local function loop()
  reaper.ImGui_Text(ctx, 'Hello world!')
  reaper.defer(loop)
end
reaper.defer(loop)
