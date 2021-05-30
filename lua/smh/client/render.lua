SMH.Rendering = false;
SMH.UseScreenshot = false;
SMH.RenderTimerName = "SMHRender";

local function RenderTick()

	local newPos = SMH.Data.Position + 1;
	if newPos >= SMH.Data.PlaybackLength then
		SMH.StopRender();
		return;
	end

	local command = "jpeg";
	if SMH.UseScreenshot then
		command = "screenshot";
	end

	timer.Create(SMH.RenderTimerName .. "Sub", 0.4, 1, function()
		RunConsoleCommand(command);
	end);

	SMH.Data.Position = newPos;

end

function SMH.StartRender(useScreenshot)

	if useScreenshot == nil then
		useScreenshot = false;
	end

	SMH.Data.Position = -1;

	LocalPlayer():EmitSound("buttons/blip1.wav");

	timer.Create(SMH.RenderTimerName, 1, 0, RenderTick);

	SMH.UseScreenshot = useScreenshot;
	SMH.Rendering = true;

end

function SMH.StopRender()

	if timer.Exists(SMH.RenderTimerName) then
		timer.Remove(SMH.RenderTimerName);
	end

	LocalPlayer():EmitSound("buttons/button1.wav");

	SMH.Rendering = false;
	if SMH.Data.Rendering then
		SMH.Data.Rendering = false;
	end

end