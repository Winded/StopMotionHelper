
local PANEL = {};

function PANEL:Init()

	self:SetTitle("Stop Motion Helper");
	self:SetSize(ScrW(), 70);
	self:SetPos(0, ScrH() - self:GetTall());
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	self:SetDeleteOnClose(false);
	self:ShowCloseButton(false);

	self.LengthListener = SMH.Data:_Listen("PlaybackLength", function() self:LengthChanged(); end);
	self.FramesListener = SMH.Data:_Listen("ActiveFrames", function() self:RefreshFrames(); end);

	self.FrameItems = {};

	self.FramePanel = vgui.Create("SMHFramePanel", self);
	self.FramePanel:Bind(SMH.Data, "PlaybackLength", "FramePanel");

	self.Pointer = vgui.Create("SMHPointer", self.FramePanel);
	self.Pointer.Color = Color(255, 255, 255);
	self.Pointer.VerticalPosition = self.FramePanel:GetTall() / 4;
	self.Pointer:SetPosition(0);
	self.Pointer:Bind(SMH.Data, "Position", "PointerPosition");

	self.PositionLabel = vgui.Create("DLabel", self);
	self.PositionLabel:SetText("Position: 0 / 100");
	self.PositionLabel:SizeToContents();
	self.PositionLabel.Listen = function(container, key, value)
		self.PositionLabel:SetText("Position: " .. container.Position .. " / " .. container.PlaybackLength);
		self.PositionLabel:SizeToContents();
	end
	self.PositionLabel.PositionListener = SMH.Data:_Listen("Position", self.PositionLabel.Listen);
	self.PositionLabel.LengthListener = SMH.Data:_Listen("PlaybackLength", self.PositionLabel.Listen);

	self.PlaybackRateControl = vgui.Create("DNumberWang", self);
	self.PlaybackRateControl:SetMinMax(1, 999);
	self.PlaybackRateControl:SetDecimals(0);
	self.PlaybackRateControl:Bind(SMH.Data, "PlaybackRate", "Number");
	self.PlaybackRateControl.Label = vgui.Create("DLabel", self);
	self.PlaybackRateControl.Label:SetText("Framerate");
	self.PlaybackRateControl.Label:SizeToContents();

	self.PlaybackLengthControl = vgui.Create("DNumberWang", self);
	self.PlaybackLengthControl:SetMinMax(1, 999);
	self.PlaybackLengthControl:SetDecimals(0);
	self.PlaybackLengthControl:Bind(SMH.Data, "PlaybackLength", "Number");
	self.PlaybackLengthControl.Label = vgui.Create("DLabel", self);
	self.PlaybackLengthControl.Label:SetText("Frame count");
	self.PlaybackLengthControl.Label:SizeToContents();

	self.Easing = vgui.Create("Panel", self);

	self.EaseInControl = vgui.Create("DNumberWang", self.Easing);
	self.EaseInControl:SetNumberStep(0.1);
	self.EaseInControl:SetMinMax(0, 1);
	self.EaseInControl:SetDecimals(1);
	self.EaseInControl:Bind(SMH.Data, "EaseIn", "Number");
	self.EaseInControl.Label = vgui.Create("DLabel", self.Easing);
	self.EaseInControl.Label:SetText("Ease in");
	self.EaseInControl.Label:SizeToContents();

	self.EaseOutControl = vgui.Create("DNumberWang", self.Easing);
	self.EaseOutControl:SetNumberStep(0.1);
	self.EaseOutControl:SetMinMax(0, 1);
	self.EaseOutControl:SetDecimals(1);
	self.EaseOutControl:Bind(SMH.Data, "EaseOut", "Number");
	self.EaseOutControl.Label = vgui.Create("DLabel", self.Easing);
	self.EaseOutControl.Label:SetText("Ease out");
	self.EaseOutControl.Label:SizeToContents();

	self.Easing:Bind(SMH.Data, "ShowEaseOptions", "Visibility");

	self.RecordButton = vgui.Create("DButton", self);
	self.RecordButton:SetText("Record");
	self.RecordButton:Bind(SMH.Data, "Record", "Button");

	self.SaveButton = vgui.Create("DButton", self);
	self.SaveButton:SetText("Save");
	self.SaveButton:Bind(SMH.Data, "ShowSaveMenu", "Button");

	self.LoadButton = vgui.Create("DButton", self);
	self.LoadButton:SetText("Load");
	self.LoadButton:Bind(SMH.Data, "ShowLoadMenu", "Button");

	self.SettingsButton = vgui.Create("DButton", self);
	self.SettingsButton:SetText("Settings");
	self.SettingsButton:Bind(SMH.Data, "ShowSettingsMenu", "Button");

end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self:SetTitle("Stop Motion Helper");
	self:SetSize(ScrW(), 70);
	self:SetPos(0, ScrH() - self:GetTall());

	self.FramePanel:SetPos(5, 25);
	self.FramePanel:SetSize(self:GetWide() - 5, 40);

	self.Pointer.VerticalPosition = self.FramePanel:GetTall() / 4;
	self.Pointer:RefreshPosition();

	self.PositionLabel:SetPos(150, 5);

	self.PlaybackRateControl:SetPos(340, 2);
	self.PlaybackRateControl:SetSize(50, 20);
	local sizeX, sizeY = self.PlaybackRateControl.Label:GetSize();
	self.PlaybackRateControl.Label:SetRelativePos(self.PlaybackRateControl, -(sizeX) - 5, 3);

	self.PlaybackLengthControl:SetPos(460, 2);
	self.PlaybackLengthControl:SetSize(50, 20);
	sizeX, sizeY = self.PlaybackLengthControl.Label:GetSize();
	self.PlaybackLengthControl.Label:SetRelativePos(self.PlaybackLengthControl, -(sizeX) - 5, 3);

	self.Easing:SetPos(540, 0);
	self.Easing:SetSize(250, 30);

	self.EaseInControl:SetPos(60, 2);
	self.EaseInControl:SetSize(50, 20);
	sizeX, sizeY = self.EaseInControl.Label:GetSize();
	self.EaseInControl.Label:SetRelativePos(self.EaseInControl, -(sizeX) - 5, 3);

	self.EaseOutControl:SetPos(160, 2);
	self.EaseOutControl:SetSize(50, 20);
	sizeX, sizeY = self.EaseOutControl.Label:GetSize();
	self.EaseOutControl.Label:SetRelativePos(self.EaseOutControl, -(sizeX) - 5, 3);

	self.RecordButton:SetPos(self:GetWide() - 60 * 4 - 5 * 4, 2);
	self.RecordButton:SetSize(60, 20);

	self.SaveButton:SetPos(self:GetWide() - 60 * 3 - 5 * 3, 2);
	self.SaveButton:SetSize(60, 20);

	self.LoadButton:SetPos(self:GetWide() - 60 * 2 - 5 * 2, 2);
	self.LoadButton:SetSize(60, 20);

	self.SettingsButton:SetPos(self:GetWide() - 60 * 1 - 5 * 1, 2);
	self.SettingsButton:SetSize(60, 20);

end

function PANEL:Focused()
	return self.PlaybackRateControl:HasFocus() or self.PlaybackLengthControl:HasFocus();
end

function PANEL:LengthChanged()
	self.Pointer:RefreshPosition();
	for _, item in pairs(self.FrameItems) do
		item:RefreshPosition();
	end
end

function PANEL:CreateFrameItem(frame)

	local item = vgui.Create("SMHPointer", self.FramePanel);
	item.Frame = frame;
	item.Color = Color(0, 200, 0);
	item.SetPositionOnRelease = true;
	item.VerticalPosition = self.FramePanel:GetTall() / 4 * 3;
	item:SetPosition(frame.Position);

	item.OnPositionChanged = function(item, pos)
		item.Frame.NewPosition = pos;
		SMH.Data.EditedFrame = item.Frame;
	end

	item.OnMiddleClick = function(item)

		local newItem = vgui.Create("SMHPointer", self.FramePanel);
		newItem.Frame = item.Frame;
		newItem.Color = Color(0, 200, 0);
		newItem.SetPositionOnRelease = true;
		newItem.VerticalPosition = self.FramePanel:GetTall() / 4 * 3;
		newItem:SetPosition(frame.Position);

		newItem.OnPositionChanged = function(item, pos)
			SMH.Data.CopiedFrame = {
				ID = item.Frame.ID,
				Position = pos
			};
			item:Remove();
		end

		newItem.Dragging = true;
		newItem:MouseCapture(true);

	end

	item.OnRightClick = function(item)
		item.Frame.Remove = true;
		SMH.Data.EditedFrame = frame;
	end

	table.insert(self.FrameItems, item);
	return item;

end

function PANEL:RefreshFrames()

	for _, item in pairs(self.FrameItems) do
		item:Remove();
	end
	table.Empty(self.FrameItems);

	local frames = SMH.Data.ActiveFrames;
	for _, frame in pairs(frames) do
		self:CreateFrameItem(frame);
	end

end

vgui.Register("SMHMenu", PANEL, "DFrame");