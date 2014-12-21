
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

	self.FramePanel = vgui.Create("SMHFramePanel", self);
	self.FramePanel:SetPos(5, 25);
	self.FramePanel:SetSize(self:GetWide() - 5, 40);
	self.FramePanel:Bind(SMH.Data, "PlaybackLength", "FramePanel");

	self.Pointer = vgui.Create("SMHPointer", self.FramePanel);
	self.Pointer.Color = Color(255, 255, 255);
	self.Pointer.VerticalPosition = self.FramePanel:GetTall() / 4;
	self.Pointer:SetPosition(0);
	self.Pointer:Bind(SMH.Data, "Position", "PointerPosition");

	self.RecordButton = vgui.Create("DButton", self);
	self.RecordButton:SetPos(self:GetWide() - 25, 2);
	self.RecordButton:SetSize(20, 20);
	self.RecordButton:SetText("R");
	self.RecordButton:SetTooltip("Record frame");
	self.RecordButton:Bind(SMH.Data, "Record", "Button");

	self.PositionLabel = vgui.Create("DLabel", self);
	self.PositionLabel:SetPos(150, 5);
	self.PositionLabel:SetText("Position: 0 / 100");
	self.PositionLabel:SizeToContents();
	self.PositionLabel.Listen = function(container, key, value)
		self.PositionLabel:SetText("Position: " .. container.Position .. " / " .. container.PlaybackLength);
		self.PositionLabel:SizeToContents();
	end
	self.PositionLabel.PositionListener = SMH.Data:_Listen("Position", self.PositionLabel.Listen);
	self.PositionLabel.LengthListener = SMH.Data:_Listen("PlaybackLength", self.PositionLabel.Listen);

	local prLabel = vgui.Create("DLabel", self);
	prLabel:SetPos(283, 5);
	prLabel:SetText("Framerate");
	prLabel:SizeToContents();
	self.PlaybackRateControl = vgui.Create("DNumberWang", self);
	self.PlaybackRateControl:SetPos(340, 2);
	self.PlaybackRateControl:SetSize(50, 20);
	self.PlaybackRateControl:SetMinMax(1, 999);
	self.PlaybackRateControl:SetDecimals(0);
	self.PlaybackRateControl:Bind(SMH.Data, "PlaybackRate", "Number");

	local plLabel = vgui.Create("DLabel", self);
	plLabel:SetPos(395, 5);
	plLabel:SetText("Frame count");
	plLabel:SizeToContents();
	self.PlaybackLengthControl = vgui.Create("DNumberWang", self);
	self.PlaybackLengthControl:SetPos(460, 2);
	self.PlaybackLengthControl:SetSize(50, 20);
	self.PlaybackLengthControl:SetMinMax(1, 999);
	self.PlaybackLengthControl:SetDecimals(0);
	self.PlaybackLengthControl:Bind(SMH.Data, "PlaybackLength", "Number");

	self.FrameItems = {};

end

function PANEL:Focused()
	return self.PlaybackRateControl:HasFocus() or self.PlaybackLengthControl:HasFocus();
end

function PANEL:LengthChanged()
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