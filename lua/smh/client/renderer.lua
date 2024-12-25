local RenderCmd = ""
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

    LocalPlayer():ConCommand(RenderCmd)

    if newPos >= SMH.State.PlaybackLength then
        MGR.Stop()
        return
    end

    timer.Simple(0.001, function()
        SMH.Controller.SetFrame(newPos)

        timer.Simple(0.001, function()
            RenderTick()
        end)
    end)

end

function MGR.Start(renderCmd, StartFrame)
    if not isstring(renderCmd) then error(string.format("Tried to start a render with a non-string renderCmd: %s: %q", type(renderCmd), tostring(renderCmd))) end
    RenderCmd = renderCmd

    IsRendering = true
    SMH.Controller.SetRendering(IsRendering)

    SMH.Controller.SetFrame(StartFrame)

    LocalPlayer():EmitSound("buttons/blip1.wav")

    timer.Simple(1, RenderTick)
end

SMH.Renderer = MGR
