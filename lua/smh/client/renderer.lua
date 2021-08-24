local UseScreenshot = false
local TimerName = "SMHRender"
local Rendering = false

local MGR = {}

function MGR.IsRendering()
    return IsRendering
end

function MGR.Stop()
	if timer.Exists(TimerName) then
		timer.Remove(TimerName)
	end

	LocalPlayer():EmitSound("buttons/button1.wav");

    IsRendering = false
end

local function RenderTick()
	local newPos = SMH.State.Frame + 1
	if newPos > SMH.State.PlaybackLength then
		MGR.Stop()
		return
	end

	local command = "jpeg"
	if UseScreenshot then
		command = "screenshot"
	end

	timer.Simple(0.2, function()
		RunConsoleCommand(command)

		timer.Simple(0.4, function()
			SMH.Controller.SetFrame(newPos)
		end)
	end)

end

function MGR.Start(useScreenshot)
    UseScreenshot = useScreenshot

    SMH.Controller.SetFrame(0)

	LocalPlayer():EmitSound("buttons/blip1.wav")

	timer.Create(TimerName, 1, 0, RenderTick)
    IsRendering = true
end

SMH.Renderer = MGR
