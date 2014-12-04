
local PANEL = {};

function PANEL:Init()

	self:SetTitle("Stop Motion Helper");
	self:SetSize(ScrW(), 70);
	self:SetPos(0, ScrH() - self:GetTall());
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	self:SetDeleteOnClose(false);
	self:ShowCloseButton(false);

	self.PositionSlider = vgui.Create("Slider", self);
	self.PositionSlider:SetPos(10, 25);
	self.PositionSlider:SetSize(self:GetWide() - 10, 20);
	self.PositionSlider:SetMin(0);
	self.PositionSlider:SetMax(SMH.PlaybackLength);
	self.PositionSlider:SetDecimals(0);
	self.PositionSlider:SetValue(0);
	self.PositionSlider.OnValueChanged = function(self, value) SMH.Menu:SetPosition(math.Round(value)); end

	self.FramePanel = vgui.Create("SMHFramePanel", self);
	self.FramePanel:SetPos(10, 45);
	self.FramePanel:SetSize(self:GetWide() - 50, 20);

	self.RecordButton = vgui.Create("DButton", self);
	self.RecordButton:SetPos(self:GetWide() - 25, 2);
	self.RecordButton:SetSize(20, 20);
	self.RecordButton:SetText("R");
	self.RecordButton:SetTooltip("Record frame");
	self.RecordButton.DoClick = function(self) SMH.Menu:RecordFrame(); end

	self.CurrentPosition = 0;
	self.FrameItems = {};

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

function PANEL:CreateFrameItem(frame)

	-- TODO

end

function PANEL:SetPosition(position)

	if position == self.CurrentPosition then
		return;
	end
	self.CurrentPosition = position;

	local t = {};
	t.Position = position;
	t.Entities = SMH.TouchedEntities;

	net.Start("SMHPositionEntities");
	net.WriteTable(t);
	net.SendToServer();

end

function PANEL:RebuildFrameItems()

	-- TODO

end

vgui.Register("SMHMenu", PANEL, "DFrame");