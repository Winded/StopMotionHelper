local UseScreenshot = false
local TimerName = "SMHRender"
local IsRendering = false

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
	SMH.Controller.SetRendering(IsRendering)
end

local function RenderTick()
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

	timer.Simple(0.4, function()
		SMH.Controller.SetFrame(newPos)
	end)
	
end

function MGR.Start(useScreenshot)
    UseScreenshot = useScreenshot
	
	IsRendering = true
	SMH.Controller.SetRendering(IsRendering)
	
    SMH.Controller.SetFrame(0)
	
	LocalPlayer():EmitSound("buttons/blip1.wav")

	timer.Create(TimerName, 1, 0, RenderTick)
end

SMH.Renderer = MGR
