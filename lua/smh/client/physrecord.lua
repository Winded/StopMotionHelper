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

local function NextFrame()
    local pos = SMH.State.Frame + 1
    if pos >= SMH.State.PlaybackLength then
        pos = 0
    end
    SMH.Controller.SetFramePhys(pos)
end

local MGR = {}

MGR.FrameCount, MGR.RecordInterval, MGR.StartDelay = 100, 0, 3

function MGR.RecordToggle()

    if not Active then
        Active = true
        local wait = MGR.StartDelay
        Waiting = wait

        timer.Create(SMHRecorderID, 1 , wait + 1, function()
            Waiting = Waiting - 1 
        end)

        timer.Simple(wait, function()
            Waiting = 0
            local fps = SMH.State.PlaybackRate
            local i = MGR.RecordInterval
            timer.Remove(SMHRecorderID)
            local counter = -1
            SMH.Controller.Record()

            timer.Create(SMHRecorderID, 1 / fps , MGR.FrameCount, function()
                counter = counter + 1

                if i == 0 or (counter / i) == math.Round(counter / i)  then 
                    SMH.Controller.Record()
                end

                if counter >= MGR.FrameCount - 1 or SMH.State.Frame + 1 > SMH.State.PlaybackLength - 1  then

                    SMH.Controller.Record()
                    Active = false
                    Waiting = 0
                    timer.Remove(SMHRecorderID)
                    LocalPlayer():ChatPrint( "SMH Physics Recorder stopped.")

                else
                    NextFrame()
                end
            end)

        end)
    else
        Active = false
        Waiting = 0
        timer.Remove(SMHRecorderID)
        LocalPlayer():ChatPrint( "SMH Physics Recorder stopped.")
    end

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
