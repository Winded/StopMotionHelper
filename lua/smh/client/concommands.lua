
local Rx = SMH.Include("rxlua/rx.lua")
local RxUtils = SMH.Include("shared/rxutils.lua")

local function Setup()

    -- TODO move to SMH.Settings
    local data = SMH.Data
    data:_BindToConVar("FreezeAll", CreateClientConVar("smh_freezeall", "0"), {ValueType = "boolean"})
    data:_BindToConVar("LocalizePhysBones", CreateClientConVar("smh_localizephysbones", "0"), {ValueType = "boolean"})
    data:_BindToConVar("IgnorePhysBones", CreateClientConVar("smh_ignorephysbones", "0"), {ValueType = "boolean"})
    data:_BindToConVar("GhostPrevFrame", CreateClientConVar("smh_ghostprevframe", "0"), {ValueType = "boolean"})
    data:_BindToConVar("GhostNextFrame", CreateClientConVar("smh_ghostnextframe", "0"), {ValueType = "boolean"})
    data:_BindToConVar("GhostAllEntities", CreateClientConVar("smh_ghostallentities", "0"), {ValueType = "boolean"})
    data:_BindToConVar("GhostTransparency", CreateClientConVar("smh_ghosttransparency", "0.5"), {ValueType = "number"})

end

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
    local pos = SMH.State.Frame + 1
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

-- TODO move to SMH.Settings
-- concommand.Add("smh_onionskin", function()
--     SMH.Data.OnionSkin = not SMH.Data.OnionSkin
-- end)

concommand.Add("smh_quicksave", function()
    SMH.Controller.QuickSave()
end)

concommand.Add("smh_makejpeg", function()
    SMH.Controller.ToggleRendering(false)
end)

concommand.Add("smh_makescreenshot", function()
    SMH.Controller.ToggleRendering(true)
end)
