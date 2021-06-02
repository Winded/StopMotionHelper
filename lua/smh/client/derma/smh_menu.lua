
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local CreateFramePanel = include("frame_panel.lua");
local CreateFramePointer = include("frame_pointer.lua");

local function Setup(parent)

	local menu = vgui.Create("DFrame", parent);

	menu:SetTitle("Stop Motion Helper");
	menu:SetSize(ScrW(), 75);
	menu:SetPos(0, ScrH() - menu:GetTall());
	menu:SetDraggable(false);
	menu:ShowCloseButton(false);
	menu:SetDeleteOnClose(false);
	menu:ShowCloseButton(false);

	local framePanel, framePanelStreams = CreateFramePanel(menu);

	local pointer, pointerStreams = CreateFramePointer(framePanel, true);
	pointer.Color = Color(255, 255, 255);
	pointer.VerticalPosition = framePanel:GetTall() / 4;
	
	local positionLabel = vgui.Create("DLabel", menu);
	menu.PositionLabel = positionLabel;

	menu.PlaybackRateControl = vgui.Create("DNumberWang", menu);
	menu.PlaybackRateControl:SetMinMax(1, 216000);
	menu.PlaybackRateControl:SetDecimals(0);
	menu.PlaybackRateControl.Label = vgui.Create("DLabel", menu);
	menu.PlaybackRateControl.Label:SetText("Framerate");
	menu.PlaybackRateControl.Label:SizeToContents();
	
	menu.PlaybackLengthControl = vgui.Create("DNumberWang", menu);
	menu.PlaybackLengthControl:SetMinMax(1, 999);
	menu.PlaybackLengthControl:SetDecimals(0);
	menu.PlaybackLengthControl.Label = vgui.Create("DLabel", menu);
	menu.PlaybackLengthControl.Label:SetText("Frame count");
	menu.PlaybackLengthControl.Label:SizeToContents();
	
	menu.Easing = vgui.Create("Panel", menu);
	
	menu.EaseInControl = vgui.Create("DNumberWang", menu.Easing);
	menu.EaseInControl:SetNumberStep(0.1);
	menu.EaseInControl:SetMinMax(0, 1);
	menu.EaseInControl:SetDecimals(1);
	menu.EaseInControl.Label = vgui.Create("DLabel", menu.Easing);
	menu.EaseInControl.Label:SetText("Ease in");
	menu.EaseInControl.Label:SizeToContents();
	
	menu.EaseOutControl = vgui.Create("DNumberWang", menu.Easing);
	menu.EaseOutControl:SetNumberStep(0.1);
	menu.EaseOutControl:SetMinMax(0, 1);
	menu.EaseOutControl:SetDecimals(1);
	menu.EaseOutControl.Label = vgui.Create("DLabel", menu.Easing);
	menu.EaseOutControl.Label:SetText("Ease out");
	menu.EaseOutControl.Label:SizeToContents();
	
	menu.RecordButton = vgui.Create("DButton", menu);
	menu.RecordButton:SetText("Record");
	
	menu.SaveButton = vgui.Create("DButton", menu);
	menu.SaveButton:SetText("Save");
	
	menu.LoadButton = vgui.Create("DButton", menu);
	menu.LoadButton:SetText("Load");
	
	menu.SettingsButton = vgui.Create("DButton", menu);
	menu.SettingsButton:SetText("Settings");

	local basePerformLayout = menu.PerformLayout;
	menu.PerformLayout = function(self, width, height)

		basePerformLayout(menu);

		menu:SetTitle("Stop Motion Helper");
	
		framePanel:SetPos(5, 25);
		framePanelStreams.Input.Size(width - 5 * 2, 45);
	
		pointer.VerticalPosition = framePanel:GetTall() / 4;
	
		menu.PositionLabel:SetPos(150, 5);
	
		menu.PlaybackRateControl:SetPos(340, 2);
		menu.PlaybackRateControl:SetSize(50, 20);
		local sizeX, sizeY = menu.PlaybackRateControl.Label:GetSize();
		menu.PlaybackRateControl.Label:SetRelativePos(menu.PlaybackRateControl, -(sizeX) - 5, 3);
	
		menu.PlaybackLengthControl:SetPos(460, 2);
		menu.PlaybackLengthControl:SetSize(50, 20);
		sizeX, sizeY = menu.PlaybackLengthControl.Label:GetSize();
		menu.PlaybackLengthControl.Label:SetRelativePos(menu.PlaybackLengthControl, -(sizeX) - 5, 3);
	
		menu.Easing:SetPos(540, 0);
		menu.Easing:SetSize(250, 30);
	
		menu.EaseInControl:SetPos(60, 2);
		menu.EaseInControl:SetSize(50, 20);
		sizeX, sizeY = menu.EaseInControl.Label:GetSize();
		menu.EaseInControl.Label:SetRelativePos(menu.EaseInControl, -(sizeX) - 5, 3);
	
		menu.EaseOutControl:SetPos(160, 2);
		menu.EaseOutControl:SetSize(50, 20);
		sizeX, sizeY = menu.EaseOutControl.Label:GetSize();
		menu.EaseOutControl.Label:SetRelativePos(menu.EaseOutControl, -(sizeX) - 5, 3);
	
		menu.RecordButton:SetPos(width - 60 * 4 - 5 * 4, 2);
		menu.RecordButton:SetSize(60, 20);
	
		menu.SaveButton:SetPos(width - 60 * 3 - 5 * 3, 2);
		menu.SaveButton:SetSize(60, 20);
	
		menu.LoadButton:SetPos(width - 60 * 2 - 5 * 2, 2);
		menu.LoadButton:SetSize(60, 20);
	
		menu.SettingsButton:SetPos(width - 60 * 1 - 5 * 1, 2);
		menu.SettingsButton:SetSize(60, 20);
	
	end

	local inputPositionStream = Rx.Subject.create();
	local outputPositionStream = Rx.Subject.create();
	local timelineLengthStream = Rx.BehaviorSubject.create(1);

	local outputFramePositionStream = Rx.Subject.create();
	local outputFrameCloneStream = Rx.Subject.create();
	local outputFrameRemoveStream = Rx.Subject.create();

	local uiFrames = {};

	local function createUiFrame(frame)

		local item, itemStreams = CreateFramePointer(framePanel, false);

		item:SetSize(8, 13);
		item.Color = Color(0, 200, 0);
		item.VerticalPosition = framePanel:GetTall() / 4 * 2.2;

		local itemPositionStream = Rx.BehaviorSubject.create(frame.Position);
		local outputPositionSub = itemStreams.Output.Position:subscribe(itemPositionStream);
		local releasePositionSub = itemStreams.Output.LeftMouseRelease:with(itemPositionStream)
			:map(function(mousecode, position) return frame, position end):subscribe(outputFramePositionStream);

		local middleMousePressSub = itemStreams.Output.MiddleMousePress:subscribe(function()
			
			local newItem, newItemStreams = CreateFramePointer(framePanel, false);
	
			newItem.Color = Color(0, 200, 0);
			newItem.VerticalPosition = framePanel:GetTall() / 4 * 2.2;

			local middleMouseReleaseStream = newItemStreams.Output.MiddleMouseRelease:first();

			middleMouseReleaseStream
				:with(newItemStreams.Output.Position)
				:map(function(mousecode, position) return frame.ID, position end)
				:subscribe(function(...) outputFrameCloneStream(...) end);
			
			middleMouseReleaseStream:subscribe(function(mousecode)
				newItem:Remove();
			end);
			
			newItemStreams.Input.FrameArea(framePanelStreams.Output.FrameArea:getValue());
			newItemStreams.Input.TimelineLength(timelineLengthStream:getValue());
			newItemStreams.Input.ScrollOffset(framePanelStreams.Output.ScrollOffset:getValue());
			newItemStreams.Input.Zoom(framePanelStreams.Output.Zoom:getValue());
			newItemStreams.Input.Position(frame.Position);
	
			newItemStreams.Input.StartDrag(newItemStreams.Output.MiddleMouseRelease);

		end);

		local rightClickSub = itemStreams.Output.RightMousePress
			:map(function(mousecode) return frame end):subscribe(outputFrameRemoveStream);

		local frameAreaSub = framePanelStreams.Output.FrameArea:subscribe(itemStreams.Input.FrameArea);
		local scrollOffsetSub = framePanelStreams.Output.ScrollOffset:subscribe(itemStreams.Input.ScrollOffset);
		local zoomSub = framePanelStreams.Output.Zoom:subscribe(itemStreams.Input.Zoom);
		local timelineLengthSub = timelineLengthStream:subscribe(itemStreams.Input.TimelineLength);

		itemStreams.Input.Position(frame.Position);

		local function unsubscribeStreams()
			outputPositionSub:unsubscribe();
			releasePositionSub:unsubscribe();
			middleMousePressSub:unsubscribe();
			rightClickSub:unsubscribe();
			frameAreaSub:unsubscribe();
			scrollOffsetSub:unsubscribe();
			zoomSub:unsubscribe();
			timelineLengthSub:unsubscribe();
		end
	
		return {
			Panel = item,
			UnsubscribeStreams = unsubscribeStreams
		};
	end

	local function refreshFrames(frames)
		for _, uiFrame in pairs(uiFrames) do
			uiFrame.UnsubscribeStreams();
			uiFrame.Panel:Remove();
		end
		table.Empty(uiFrames);
	
		for _, frame in pairs(frames) do
			table.insert(uiFrames, createUiFrame(frame));
		end
	end
	local activeFramesStream = Rx.Subject.create();
	activeFramesStream:subscribe(refreshFrames);

	menu.FrameItems = {};
	
	framePanelStreams.Output.ClickPosition:subscribe(outputPositionStream);
	timelineLengthStream:subscribe(framePanelStreams.Input.TimelineLength);

	pointerStreams.Output.Position:subscribe(outputPositionStream);
	inputPositionStream:subscribe(pointerStreams.Input.Position);
	timelineLengthStream:subscribe(pointerStreams.Input.TimelineLength);
	framePanelStreams.Output.ScrollOffset:subscribe(pointerStreams.Input.ScrollOffset);
	framePanelStreams.Output.Zoom:subscribe(pointerStreams.Input.Zoom);

	local combinedPositionStream = Rx.BehaviorSubject.create(0);
	inputPositionStream:merge(outputPositionStream):subscribe(combinedPositionStream);
	Rx.Observable.combineLatest(combinedPositionStream, timelineLengthStream)
		:map(function(position, timelineLength) return "Position: " .. (position + 1) .. " / " .. timelineLength end)
		:subscribe(function(text)
			positionLabel:SetText(text);
			positionLabel:SizeToContents();
		end);

	local inputPlaybackRateStream, outputPlaybackRateStream = RxUtils.bindDPanel(menu.PlaybackRateControl, "SetValue", "OnValueChanged");

	menu.PlaybackLengthControl.OnValueChanged = function(self, value) timelineLengthStream(tonumber(value)) end
	timelineLengthStream:filter(function(length) return menu.PlaybackLengthControl:GetValue() ~= length end)
		:subscribe(function(length) menu.PlaybackLengthControl:SetValue(length) end);

	framePanelStreams.Output.FrameArea:subscribe(pointerStreams.Input.FrameArea);

	local showEaseOptionsStream = Rx.BehaviorSubject.create(false);
	showEaseOptionsStream:subscribe(function(value) menu.Easing:SetVisible(value) end);

	local inputEaseInStream, outputEaseInStream = RxUtils.bindDPanel(menu.EaseInControl, "SetValue", "OnValueChanged");
	local inputEaseOutStream, outputEaseOutStream = RxUtils.bindDPanel(menu.EaseOutControl, "SetValue", "OnValueChanged");

	local _, recordStream = RxUtils.bindDPanel(menu.RecordButton, nil, "DoClick");
	local _, saveStream = RxUtils.bindDPanel(menu.SaveButton, nil, "DoClick");
	local _, loadStream = RxUtils.bindDPanel(menu.LoadButton, nil, "DoClick");
	local _, settingsStream = RxUtils.bindDPanel(menu.SettingsButton, nil, "DoClick");

	return {
		Input = {
			Position = inputPositionStream,
			ShowEaseOptions = showEaseOptionsStream,
			EaseIn = inputEaseInStream,
			EaseOut = inputEaseOutStream,
			ActiveFrames = activeFramesStream,
			PlaybackRate = inputPlaybackRateStream,
			TimelineLength = timelineLengthStream,
		},
		Output = {
			Position = outputPositionStream,
			FramePosition = outputFramePositionStream,
			FrameClone = outputFrameCloneStream,
			FrameRemove = outputFrameRemoveStream,
			PlaybackRate = outputPlaybackRateStream:map(function(value) return tonumber(value) end),
			TimelineLength = timelineLengthStream,
			EaseIn = outputEaseInStream:map(function(value) return tonumber(value) end),
			EaseOut = outputEaseOutStream:map(function(value) return tonumber(value) end),
			Record = recordStream,
			Save = saveStream,
			Load = loadStream,
			Settings = settingsStream,
		}
	};

end

return Setup;