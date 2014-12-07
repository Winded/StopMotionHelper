
local PANEL = {};

function PANEL:Init()

	self:SetSize(8, 15);
	self.Frame = nil;
	self.Dragging = false;
	self.Position = 0;

end

function PANEL:ShouldDraw()
	return self.Frame and self.Frame.Position <= SMH.PlaybackLength;
end

function PANEL:SetFrame(frame)

	local framePanel = self:GetParent();
	local height = framePanel:GetTall() / 4 * 3;
	local startX, endX = framePanel:GetFrameArea();
	local x = startX + (endX - startX) / SMH.PlaybackLength * frame.Position;

	self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2);

	self.Frame = frame;
	self.Position = frame.Position;

end

function PANEL:SetPosition(pos)

	local framePanel = self:GetParent();
	local startX, endX = framePanel:GetFrameArea();
	local height = framePanel:GetTall() / 4 * 3;

	local x = startX + (endX - startX) / SMH.PlaybackLength * pos;

	self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2);

	self.Position = pos;

end

function PANEL:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT then

		self.Dragging = true;
		self:MouseCapture(true);

	elseif mousecode == MOUSE_RIGHT then

		SMH.Menu:DeleteFrame(self.Frame);

	elseif mousecode == MOUSE_MIDDLE and IsValid(SMH.Entity) then

		local player = LocalPlayer();
		local entity = SMH.Entity;
		local pos = self.Frame.Position;

		local frame = SMH.Frame.New(player, entity, pos);
		table.insert(SMH.Frames, frame);
		frame:Save(self.Frame);
		local item = SMH.Menu:CreateFrameItem(frame);

		item.Dragging = true;
		item:MouseCapture(true);

	end
end

function PANEL:OnMouseReleased(mousecode)

	if not self.Dragging then
		return;
	end

	self.Dragging = false;
	self:MouseCapture(false);

	local frame = self.Frame;
	frame.Position = self.Position;
	local exFrame = table.First(SMH.Frames, function(item) return item.Entity == SMH.Entity and item ~= frame and item.Position == frame.Position; end);
	if exFrame then
		SMH.Menu:DeleteFrame(exFrame);
	end

	frame:Save();

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
	if self:ShouldDraw() then

		surface.SetDrawColor(0, 200, 0);
		surface.DrawRect(1, 1, w - 1, h - 1);

		if self:IsSelected() then
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

vgui.Register("SMHFrameItem", PANEL, "DPanel");