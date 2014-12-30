
SMH.Rendering = false;
SMH.RenderTimerName = "SMHRender";

local function RenderTick()

	local newPos = SMH.Data.Position + 1;
	if newPos > SMH.Data.PlaybackLength then
		SMH.StopRender();
		return;
	end

	SMH.Data.Position = newPos;

	timer.Create(SMH.RenderTimerName .. "Sub", 0.4, 1, function()
		RunConsoleCommand("jpeg");
	end);

end

function SMH.StartRender()

	SMH.Data.Position = 0;

	LocalPlayer():EmitSound("buttons/blip1.wav");

	timer.Create(SMH.RenderTimerName, 1, 0, RenderTick);

	SMH.Rendering = true;

end

function SMH.StopRender()

	if timer.Exists(SMH.RenderTimerName) then
		timer.Remove(SMH.RenderTimerName);
	end

	LocalPlayer():EmitSound("buttons/button1.wav");

	SMH.Rendering = false;

end