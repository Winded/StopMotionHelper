
local PANEL = {};

function PANEL:Init()

	self:SetSize(8, 15);
	self.Color = Color(0, 200, 0);
	self.Dragging = false;
	self.Position = 0;
	self.VerticalPosition = 0;
	self.SetPositionOnRelease = false;

end

function PANEL:ShouldDraw()
	return self.Position <= self:GetParent().Length;
end

function PANEL:SetPosition(pos)

	local framePanel = self:GetParent();
	local startX, endX = framePanel:GetFrameArea();
	local height = self.VerticalPosition;

	local x = startX + (endX - startX) / framePanel.Length * pos;

	self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2);

	self.Position = pos;

end

function PANEL:RefreshPosition()
	self:SetPosition(self.Position);
end

function PANEL:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT then

		self.Dragging = true;
		self:MouseCapture(true);

	elseif mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) then
		self:OnRightClick();
	elseif mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) then
		self:OnMiddleClick();
	end
end

function PANEL:OnMouseReleased(mousecode)

	if not self.Dragging then
		return;
	end

	self.Dragging = false;
	self:MouseCapture(false);

	if self.SetPositionOnRelease then
		self:OnPositionChanged(self.Position);
	end

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
	local frameWidth = width / framePanel.Length;

	local targetPos = 0;
	for i = 0, framePanel.Length do
		local x = frameWidth * i;
		local diff = math.abs(x - targetX);
		if diff <= frameWidth / 2 then
			targetPos = i;
			break;
		elseif i == framePanel.Length and targetX > x then
			targetPos = framePanel.Length;
		end
	end

	if self.Position ~= targetPos then
		self:SetPosition(targetPos);
		if not self.SetPositionOnRelease then
			self:OnPositionChanged(targetPos);
		end
	end

end

function PANEL:Paint(w, h)
	if self:ShouldDraw() then

		surface.SetDrawColor(self.Color);
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
end

function PANEL:OnPositionChanged(value) end
function PANEL:OnMiddleClick() end
function PANEL:OnRightClick() end

vgui.Register("SMHPointer", PANEL, "DPanel");

local BIND = setmetatable({}, BiValues.ValueBind);
function BIND:Init()
	self.Settings.Callback = self.Settings.Callback or "OnPositionChanged";
	self.Settings.ValueFunction = self.Settings.ValueFunction or "SetPosition";
	BiValues.ValueBind.Init(self);
end
BiValues.RegisterBindType("PointerPosition", BIND);