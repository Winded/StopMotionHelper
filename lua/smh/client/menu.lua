
include("derma/frame_panel.lua");
include("derma/frame_pointer.lua");
include("derma/smh_menu.lua");

local Rx = include("../rxlua/rx.lua");
local RxUtils = include("../shared/rxutils.lua");

local WorldClickerSetup = include("derma/world_clicker.lua");
local SMHMenuSetup = include("derma/smh_menu.lua");

local CreateSettingsMenu = include("derma/settings.lua");
local CreateLoadMenu = include("derma/load.lua");
local CreateSaveMenu = include("derma/save.lua");

local function Setup()

	local clicker, clickerStreams = WorldClickerSetup();

	local smhMenuStreams = SMHMenuSetup(clicker);

	local settingsMenu, settingsMenuStreams = CreateSettingsMenu(clicker);
	settingsMenu:SetPos(ScrW() - 165, ScrH() - 270);
	settingsMenu:SetVisible(false);
	smhMenuStreams.Output.Settings:subscribe(function() settingsMenu:SetVisible(true) end);

	local saveMenu, saveMenuStreams = CreateSaveMenu();
	saveMenu:MakePopup();
	saveMenu:SetVisible(false);
	smhMenuStreams.Output.Save:subscribe(function() saveMenu:SetVisible(true) end);

	local loadMenu, loadMenuStreams = CreateLoadMenu();
	loadMenu:MakePopup();
	loadMenu:SetVisible(false);
	smhMenuStreams.Output.Load:subscribe(function() loadMenu:SetVisible(true) end);

	local selectorStream = clickerStreams.Output.Selector
		:map(function(trace) return trace.Entity; end)
		:filter(function(entity) return IsValid(entity) end);

	return {
		Input = {
			Position = smhMenuStreams.Input.Position,
			Visibility = clickerStreams.Input.Visibility,
			ActiveFrames = smhMenuStreams.Input.ActiveFrames,
			TimelineLength = smhMenuStreams.Input.TimelineLength,
			PlaybackRate = smhMenuStreams.Input.PlaybackRate,
			ShowEaseOptions = smhMenuStreams.Input.ShowEaseOptions,
			EaseIn = smhMenuStreams.Input.EaseIn,
			EaseOut = smhMenuStreams.Input.EaseOut,
		},
		Output = {
			Position = smhMenuStreams.Output.Position,
			FramePosition = smhMenuStreams.Output.FramePosition,
			FrameClone = smhMenuStreams.Output.FrameClone,
			FrameRemove = smhMenuStreams.Output.FrameRemove,
			Record = smhMenuStreams.Output.Record,
			Visibility = clickerStreams.Input.Visibility,
			Selector = selectorStream,
			TimelineLength = smhMenuStreams.Output.TimelineLength,
			PlaybackRate = smhMenuStreams.Output.PlaybackRate,
			EaseIn = smhMenuStreams.Output.EaseIn,
			EaseOut = smhMenuStreams.Output.EaseOut,
			Save = smhMenuStreams.Output.Save,
			Load = smhMenuStreams.Output.Load,
		},

		Settings = settingsMenuStreams,
		Load = loadMenuStreams,
		Save = saveMenuStreams,
	};

end

return Setup;