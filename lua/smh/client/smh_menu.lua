
local PANEL = {};

function PANEL:Init()

	self:SetTitle("Stop Motion Helper");
	self:SetSize(ScrW(), 70);
	self:SetPos(0, ScrH() - self:GetTall());
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	self:SetDeleteOnClose(false);
	self:ShowCloseButton(false);

	self.FramePanel = vgui.Create("SMHFramePanel", self);
	self.FramePanel:SetPos(5, 25);
	self.FramePanel:SetSize(self:GetWide() - 5, 40);

	self.Pointer = vgui.Create("SMHPointer", self.FramePanel);
	self.Pointer:SetPosition(0);
	self.Pointer.OnValueChanged = function(value) SMH.Menu:SetPosition(math.Round(value)); end

	self.RecordButton = vgui.Create("DButton", self);
	self.RecordButton:SetPos(self:GetWide() - 25, 2);
	self.RecordButton:SetSize(20, 20);
	self.RecordButton:SetText("R");
	self.RecordButton:SetTooltip("Record frame");
	self.RecordButton.DoClick = function(self) SMH.Menu:RecordFrame(); end

	self.PositionLabel = vgui.Create("DLabel", self);
	self.PositionLabel:SetPos(150, 2);
	self.PositionLabel:SetText("Position: 0 / 100");
	self.PositionLabel:SizeToContents();

	self.PlaybackRateControl = vgui.Create("DNumberWang", self);
	self.PlaybackRateControl:SetPos(300, 2);
	self.PlaybackRateControl:SetSize(50, 20);
	self.PlaybackRateControl:SetMinMax(1, 999);
	self.PlaybackRateControl:SetDecimals(0);
	self.PlaybackRateControl:SetValue(SMH.PlaybackRate);
	self.PlaybackRateControl.OnValueChanged = function(self)
		local value = self:GetValue();
		if value and value > 0 then
			SMH.Menu:SetPlaybackRate(value);
		end
	end

	self.PlaybackLengthControl = vgui.Create("DNumberWang", self);
	self.PlaybackLengthControl:SetPos(360, 2);
	self.PlaybackLengthControl:SetSize(50, 20);
	self.PlaybackLengthControl:SetMinMax(1, 999);
	self.PlaybackLengthControl:SetDecimals(0);
	self.PlaybackLengthControl:SetValue(SMH.PlaybackLength);
	self.PlaybackLengthControl.OnValueChanged = function(self)
		local value = self:GetValue();
		if value and value > 0 then
			SMH.Menu:SetPlaybackLength(value);
		end
	end

	self.CurrentPosition = 0;
	self.FrameItems = {};

end

function PANEL:Focused()
	return self.PlaybackRateControl:HasFocus() or self.PlaybackLengthControl:HasFocus();
end

function PANEL:SetPlaybackRate(rate)
	SMH.PlaybackRate = rate;
end

function PANEL:SetPlaybackLength(length)

	self.PositionLabel:SetText("Position: " .. self.CurrentPosition .. " / " .. length);
	self.PositionLabel:SizeToContents();
	SMH.PlaybackLength = length;

	if self.Pointer.Position > length then
		self.Pointer:SetPosition(0);
	else
		self.Pointer:SetPosition(self.Pointer.Position);
	end

	for _, item in pairs(self.FrameItems) do
		item:SetPosition(item.Position);
	end

end

function PANEL:RecordFrame()

	if not IsValid(SMH.Entity) then
		return;
	end

	local pos = self.CurrentPosition;
	local frame = table.First(SMH.Frames, function(item) return item.Entity == SMH.Entity and item.Position == pos; end);

	if not frame then
		frame = SMH.Frame.New(LocalPlayer(), SMH.Entity, pos);
		table.insert(SMH.Frames, frame);
		self:CreateFrameItem(frame);
	end

	frame:Save();

end

function PANEL:DeleteFrame(frame)

	local frameItem = table.First(self.FrameItems, function(item) return item.Frame == frame; end);
	if frameItem then
		frameItem:Remove();
		table.RemoveByValue(self.FrameItems, frameItem);
	end

	frame:Delete();
	table.RemoveByValue(SMH.Frames, frame);

end

function PANEL:CreateFrameItem(frame)

	local item = vgui.Create("SMHFrameItem", self.FramePanel);
	item:SetFrame(frame);
	table.insert(self.FrameItems, item);
	return item;

end

function PANEL:SetPosition(position)

	if position == self.CurrentPosition then
		return;
	end
	self.CurrentPosition = position;

	self.PositionLabel:SetText("Position: " .. position .. " / " .. SMH.PlaybackLength);
	self.PositionLabel:SizeToContents();

	local t = {};
	t.Position = position;
	t.Entities = SMH.TouchedEntities;

	net.Start("SMHPositionEntities");
	net.WriteTable(t);
	net.SendToServer();

end

function PANEL:RebuildFrameItems()

	for _, item in pairs(self.FrameItems) do
		item:Remove();
	end
	table.Empty(self.FrameItems);

	if not IsValid(SMH.Entity) then
		return;
	end

	local frames = table.Where(SMH.Frames, function(item) return item.Entity == SMH.Entity; end);
	for _, frame in pairs(frames) do
		local item = vgui.Create("SMHFrameItem", self.FramePanel);
		item:SetFrame(frame);
		table.insert(self.FrameItems, item);
	end

end

vgui.Register("SMHMenu", PANEL, "DFrame");