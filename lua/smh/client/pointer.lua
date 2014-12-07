local PANEL = {};

function PANEL:Init()

	self.Position = 0;
	self.Dragging = false;

	self:SetSize(10, 15);

	self.OnValueChanged = function(value) return; end

end

function PANEL:SetPosition(pos)

	local framePanel = self:GetParent();
	local startX, endX = framePanel:GetFrameArea();
	local height = framePanel:GetTall() / 4;

	local x = startX + (endX - startX) / SMH.PlaybackLength * pos;

	self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2);

	self.Position = pos;
	self.OnValueChanged(pos);

end

function PANEL:OnMousePressed(mousecode)

	if mousecode ~= MOUSE_LEFT then
		return;
	end

	self.Dragging = true;
	self:MouseCapture(true);

end

function PANEL:OnMouseReleased(mousecode)

	if not self.Dragging then
		return;
	end

	self.Dragging = false;
	self:MouseCapture(false);

end

function PANEL:OnCursorMoved(cursorX, cursorY)

	if not self.Dragging then
		return;
	end

	local framePanel = self:GetParent();
	local startX, endX = framePanel:GetFrameArea();
	local posX, posY = self:GetPos();

	local targetX = (posX + self:GetWide() / 2) + cursorX - startX;
	local width = endX - startX;
	local frameWidth = width / SMH.PlaybackLength;

	local targetPos = 0;
	for i = 0, SMH.PlaybackLength do
		local x = frameWidth * i;
		local diff = math.abs(x - targetX);
		if diff <= frameWidth / 2 then
			targetPos = i;
			break;
		elseif i == SMH.PlaybackLength and targetX > x then
			targetPos = SMH.PlaybackLength;
		end
	end

	if self.Position ~= targetPos then
		self:SetPosition(targetPos);
	end

end

function PANEL:Paint(w, h)

	surface.SetDrawColor(240, 240, 240);
	surface.DrawRect(1, 1, w - 1, h - 1);

	if self.Dragging then
		surface.SetDrawColor(255, 255, 255);
	else
		surface.SetDrawColor(0, 0, 0);
	end
	surface.DrawLine(0, 0, w, 0);
	surface.DrawLine(w, 0, w, h);
	surface.DrawLine(w, h, 0, h);
	surface.DrawLine(0, h, 0, 0);

end

vgui.Register("SMHPointer", PANEL, "DPanel");