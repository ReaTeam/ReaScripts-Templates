--[[
 Get/Set Text in Video Processor-functions

  Meo Mespotine - 29.06.2018 mespotine.de ultraschall.fm/danke

 licensed under an MIT-license

 These functions allow you to change the displayed text in items with video-processor as TakeFX.

 Only works for TakeFX in MediaItems! As I use StateChunks to change texts, TrackFX would be too slow to do that.
 Changes/gets the text of the first(!) video processor in the FX Chain of the MediaItem
 Only supports Reaper's built-in "Title text overlay"-preset!
 You can use safely newlines, these will be added properly.

 Limitation: if you want to change text in the video-processor-window while rendering, you need to work with a defer-background-script,
              that checks, whether the playcursor reached your desired position, on which you want to change the text.
              That should work, but may result in stuttering video, at text-change, so don't do it, unless you need to.

 Usecase: Use a MediaItem, that's streched along the whole project.
          Give it a video-processor as TakeFX
          Apply these functions to this MediaItem.
          That way, you can change the text whenever you want.
          Keep in mind: this MediaItem must be the "highest order", means, it must be above all other video/picture items
                        otherwise, other items may "overwrite" the text
          Changing texts may cause hickups and stuttering in video-rendering, because of the change.
--]]
          
function SetTextInVideoProcessor(item, text)
--[[ 
    sets the videotext in a given item in it's first(!) Video Processor in the FXChain.
        the Video Processor must be set to the built-in "Title text overlay"-preset!
        multiline-texts are allowed
  
   The function's parameters are: 
     MediaItem item - a MediaItem object as returned by reaper.GetMediaItem
     string text - the text, that you want to set. Write \n to include a newline.
  
   The function returns retval, errormessage
     boolean retval - true, in case of success; false, in case of an error
     string errormessage - in case of an error, this message gives you a hint, what went wrong.
                                  can be: "No valid MediaItem", 
                                          "No Video Processor found in this item", 
                                          "Only default preset "Title text overlay" supported. Please select accordingly.",
                                          "Done"
   Meo Mespotine - mespotine.de
   licensed under an MIT-license
--]]

  if reaper.ValidatePtr2(0, item, "MediaItem*")==false then return false, "No valid MediaItem" end
  if type(text)~="string" then return false, "Must be a string" end
  local _bool, StateChunk=reaper.GetItemStateChunk(item, "", false)
  if StateChunk:match("VIDEO_EFFECT")==nil then return false, "No Video Processor found in this item" end
  local part1, code, part2=StateChunk:match("(.-)(<CODE.-\n>)(\nCODEPARM.*)")
  
  if code:match("// Title text overlay")==nil then return false, "Only default preset \"Title text overlay\" supported. Please select accordingly." 
  else 
    local c1,test,c3=code:match("(.-text=\")(.-)(\".*)") 
    text=string.gsub(text, "\n", "\\n")
    code=c1..text..c3
  end
  StateChunk=part1..code..part2
  return reaper.SetItemStateChunk(item, StateChunk, false), "Done"
end

function GetTextInVideoProcessor(item)
--[[
    gets the videotext in a given item in it's first(!) Video Processor in the FXChain.
        the Video Processor must be set to the built-in "Title text overlay"-preset!
        multiline-texts are allowed

   The function's parameter is:
     MediaItem item - a MediaItem object as returned by reaper.GetMediaItem
   
   The function returns retval, errormessage, textinvideoitem
       boolean retval - true, in case of success; false, in case of an error
       string errormessage - in case of an error, this message gives you a hint, what went wrong.
                                  can be: "No valid MediaItem", 
                                          "No Video Processor found in this item", 
                                          "Only default preset "Title text overlay" supported. Please select accordingly.",
                                          "Done"
       string textinvideoitem - the text, that is currently set in videoitem
     
  Meo Mespotine - mespotine.de
--]]
  
  
  if reaper.ValidatePtr2(0, item, "MediaItem*")==false then return false, "No valid MediaItem" end
  local _bool, StateChunk=reaper.GetItemStateChunk(item, "", false)
  if StateChunk:match("VIDEO_EFFECT")==nil then return false, "No Video Processor found in this item" end
  local part1, code, part2=StateChunk:match("(.-)(<CODE.-\n>)(\nCODEPARM.*)")
  
  if code:match("// Title text overlay")==nil then return false, "Only default preset \"Title text overlay\" supported. Please select accordingly." 
  else 
    local c1,test,c3=code:match("(.-text=\")(.-)(\".*)") 
    test=string.gsub(test, "\\n", "\n")
    return true, "Done", test
  end
end

-- get the first MediaItem in the project, that should contain Video Processor as TakeFX
--      it must have the "Title text overlay"-preset set!
MediaItem=reaper.GetMediaItem(0,0)

-- Set a text into the first(!) videoprocessor in the TakeFX-Chain of MediaItem
SuccessfulOrNot, MsgInCaseOfError=SetTextInVideoProcessor(MediaItem, "Text line one\nText line Two\nanother(third) line, etc")

-- Get a text of the first(!) videoprocessor in the TakeFX-Chain of MediaItem
SuccessfulOrNot, Errormessage, VideoProcessorText=GetTextInVideoProcessor(MediaItem)
