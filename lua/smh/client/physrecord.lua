local SMHRecorderID = "SMH_Recording_Timer"
local Active = false
local Waiting = 0

surface.CreateFont( "smh_font", {
    font = "Arial", 
    extended = false,
    size = 90,
    weight = 500,
    blursize = 0,
    scanlines = 4,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

local MGR = {}

MGR.FrameCount, MGR.RecordInterval, MGR.StartDelay = 100, 0, 3
MGR.SelectedEntities = {}

function MGR.RecordToggle()

    if not Active then
        SMH.Controller.SelectEntity(nil)
        Active = true
        local wait = MGR.StartDelay
        Waiting = wait

        timer.Create(SMHRecorderID, 1 , wait + 1, function()
            Waiting = Waiting - 1 
        end)

        timer.Create(SMHRecorderID .. 1, wait, 1, function()
            Waiting = 0
            SMH.Controller.StartPhysicsRecord(MGR.FrameCount, MGR.RecordInterval, MGR.SelectedEntities)
            timer.Remove(SMHRecorderID)
        end)
    else
        Active = false
        Waiting = 0
        SMH.Controller.StopPhysicsRecord()
        timer.Remove(SMHRecorderID)
        timer.Remove(SMHRecorderID .. 1)
        MGR.SelectedEntities = {}
    end

end

function MGR.Stop()
    Active = false
    Waiting = 0
    timer.Remove(SMHRecorderID)
    timer.Remove(SMHRecorderID .. 1)
    MGR.SelectedEntities = {}
end

function MGR.IsActive()
    return Active
end

SMH.PhysRecord = MGR

hook.Add( "HUDPaint", "smh_draw_waiting", function()
    if Waiting > 0 then 
        surface.SetFont( "smh_font" )
        surface.SetTextColor( 255, 0, 0 )
        surface.SetTextPos( 128, 128 )
        surface.DrawText( "Starting physics recording in: " .. Waiting )
    end
end)
