local smh_startatone = CreateClientConVar("smh_startatone", 0, true, false, "Controls whether the timeline starts at 0 or 1.", 0, 1)
local smh_render_cmd = CreateClientConVar("smh_render_cmd", "poster 1", true, false, "For smh_render, this string will be ran in the console for each frame.")
CreateClientConVar("smh_currentpreset", "default", true, false)

concommand.Add("+smh_menu", function()
    SMH.Controller.OpenMenu()
end)

concommand.Add("-smh_menu", function()
    SMH.Controller.CloseMenu()
end)

concommand.Add("smh_record", function()
    SMH.Controller.Record()
end)

concommand.Add("smh_next", function()
    local pos = SMH.State.Frame + 1
    if pos >= SMH.State.PlaybackLength then
        pos = 0
    end
    SMH.Controller.SetFrame(pos)
end)

concommand.Add("smh_previous", function()
    local pos = SMH.State.Frame - 1
    if pos < 0 then
        pos = SMH.State.PlaybackLength - 1
    end
    SMH.Controller.SetFrame(pos)
end)

concommand.Add("+smh_playback", function()
    SMH.Controller.StartPlayback()
end)

concommand.Add("-smh_playback", function()
    SMH.Controller.StopPlayback()
end)

concommand.Add("smh_quicksave", function()
    SMH.Controller.QuickSave()
end)

local function StartRender(startFrame, renderCmd)
    if startFrame then
        startFrame = startFrame - smh_startatone:GetInt() -- Implicit string->number. Normalizes startFrame to 0-indexed if smh_startatone is set.
        if startFrame < 0 then startFrame = 0 end
    else
        startFrame = 0
    end

    if startFrame < SMH.State.PlaybackLength then
        SMH.Controller.ToggleRendering(renderCmd, startFrame)
    else
        print("Specified starting frame is outside of the current Frame Count!")
    end
end

concommand.Add("smh_makejpeg", function(pl, cmd, args)
    StartRender(args[1], "jpeg")
end)

concommand.Add("smh_makescreenshot", function(pl, cmd, args)
    StartRender(args[1], "screenshot")
end)

concommand.Add("smh_render", function(pl, cmd, args)
    StartRender(args[1], smh_render_cmd:GetString())
end)