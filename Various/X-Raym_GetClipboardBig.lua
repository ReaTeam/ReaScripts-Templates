reaper.ClearConsole()

local fs = reaper.SNM_CreateFastString('')

local clipboard = reaper.CF_GetClipboardBig(fs)

reaper.ShowConsoleMsg(string.len(clipboard))

reaper.SNM_DeleteFastString(fs)



local clipboard = reaper.CF_GetClipboard('')

reaper.ShowConsoleMsg("\n" .. string.len(clipboard))
