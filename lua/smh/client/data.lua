
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

function SMH.SetupData()

	local defaults = {};
	defaults.Entity = nil;
	defaults.Position = 0;
	defaults.PlaybackRate = 30;
	defaults.PlaybackLength = 100;
	defaults.ActiveFrames = {};
	defaults.EditedFrame = nil;

	defaults.EaseIn = 0;
	defaults.EaseOut = 0;
	defaults.ShowEaseOptions = false;

	local data = BiValues.New(LocalPlayer(), "SMHData", {UseSync = true, AutoApply = true}, defaults);

	data:_Listen("Position", RefreshEaseOptions);
	data:_Listen("ActiveFrames", RefreshEaseOptions);
	data:_Listen("EaseIn", EaseInChanged);
	data:_Listen("EaseOut", EaseOutChanged);

	SMH.Data = data;

end