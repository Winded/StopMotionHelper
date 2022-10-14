local UseScreenshot = false
local IsRendering = false

local MGR = {}

function MGR.IsRendering()
    return IsRendering
end

function MGR.Stop()
    LocalPlayer():EmitSound("buttons/button1.wav")

    IsRendering = false
    SMH.Controller.SetRendering(IsRendering)
end

local function RenderTick()
    if not IsRendering then
        return
    end

    local newPos = SMH.State.Frame + 1

    local command = "jpeg"
    if UseScreenshot then
        command = "screenshot"
    end

    RunConsoleCommand(command)

    if newPos >= SMH.State.PlaybackLength then
        MGR.Stop()
        return
    end

    timer.Simple(0.01, function()
        SMH.Controller.SetFrame(newPos)

        timer.Simple(0.01, function()
            RenderTick()
        end)
    end)

end

function MGR.Start(useScreenshot, StartFrame)
    UseScreenshot = useScreenshot

    IsRendering = true
    SMH.Controller.SetRendering(IsRendering)

    SMH.Controller.SetFrame(StartFrame)

    LocalPlayer():EmitSound("buttons/blip1.wav")

    timer.Simple(1, RenderTick)
end

SMH.Renderer = MGR
