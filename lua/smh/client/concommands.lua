local smh_startatone = CreateClientConVar("smh_startatone", 0, true, false, nil, 0, 1)
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

concommand.Add("smh_delete", function()
	local frame = SMH.State.Frame
	local ids = SMH.UI.GetKeyframesOnFrame(frame)
	if not ids then return end

    SMH.Controller.DeleteKeyframe(ids)
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

concommand.Add("smh_makejpeg", function(pl, cmd, args)
    local startframe
    if args[1] then
        startframe = args[1] - smh_startatone:GetInt()
    else
        startframe = 0
    end
    if startframe < 0 then startframe = 0 end
    if startframe < SMH.State.PlaybackLength then
        SMH.Controller.ToggleRendering(false, startframe)
    else
        print("Specified starting frame is outside of the current Frame Count!")
    end
end)

concommand.Add("smh_makescreenshot", function(pl, cmd, args)
    local startframe
    if args[1] then
        startframe = args[1] - smh_startatone:GetInt()
    else
        startframe = 0
    end
    if startframe < 0 then startframe = 0 end
    if startframe < SMH.State.PlaybackLength then
        SMH.Controller.ToggleRendering(true, startframe)
    else
        print("Specified starting frame is outside of the current Frame Count!")
    end
end)