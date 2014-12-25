
local function RefreshEaseOptions(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		container.ShowEaseOptions = false;
		return;
	end

	container.EaseIn = frame.EaseIn;
	container.EaseOut = frame.EaseOut;
	container.ShowEaseOptions = true;

end

local function EaseInChanged(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		return;
	end

	if value ~= frame.EaseIn then
		frame.NewEaseIn = value;
		container.EditedFrame = frame;
	end

end

local function EaseOutChanged(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		return;
	end

	if value ~= frame.EaseOut then
		frame.NewEaseOut = value;
		container.EditedFrame = frame;
	end

end

local function ShowSettingsMenu(container, key)
	if not container.ShowSettings then
		container.ShowSettings = true;
	end
end

local function ShowHelpMenu(container, key)
	if not container.ShowHelp then
		container.ShowHelp = true;
	end
end

local function ShowSaveMenu(container, key)
	if not container.ShowSave then
		container.ShowSave = true;
	end
end

function SMH.SetupData()

	local defaults = table.Copy(SMH.DefaultData);
	defaults.ShowSettingsMenu = ShowSettingsMenu;
	defaults.ShowHelpMenu = ShowHelpMenu;
	defaults.ShowSaveMenu = ShowSaveMenu;

	local data = BiValues.New(LocalPlayer(), "SMHData", {UseSync = true, AutoApply = true}, defaults);

	data:_Listen("Position", RefreshEaseOptions);
	data:_Listen("ActiveFrames", RefreshEaseOptions);
	data:_Listen("EaseIn", EaseInChanged);
	data:_Listen("EaseOut", EaseOutChanged);

	SMH.Data = data;

end