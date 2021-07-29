--[[
	TODO move control key logic elsewhere

	local leftMousePressStream = mousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local leftMouseReleaseStream = mouseReleaseStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local rightMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) end);
	local middleMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);
	local middleMouseReleaseStream = mouseReleaseStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);
]]

local PANEL = {}

function PANEL:Init()
	
	self:SetSize(8, 15)
	self.Color = Color(0, 200, 0)
	self.OutlineColor = Color(0, 0, 0)
	self.OutlineColorDragged = Color(255, 255, 255)
	self.VerticalPosition = 0
	self.PointyBottom = false

	self._frame = 0
	self._dragging = false

end

function PANEL:Paint(width, height)
	local parent = self:GetParent()
	if self._frame < parent.ScrollOffset or self._frame > (parent.ScrollOffset + parent.Zoom) then
		return
	end

	local outlineColor = (self._dragging and self.OutlineColorDragged) or self.OutlineColor

	if self.PointyBottom then

		surface.SetDrawColor(self.Color:Unpack())
		draw.NoTexture()
		surface.DrawRect(1, 1, width - 1, height - (height * 0.25))
		surface.DrawPoly({
			{ x = 1, y = height - (height * 0.25) },
			{ x = width - 1, y = height - (height * 0.25) },
			{ x = width / 2, y = height - 1 },
		})

		surface.SetDrawColor(outlineColor:Unpack())
		surface.DrawLine(0, 0, width, 0)
		surface.DrawLine(width, 0, width, height - (height * 0.25))
		surface.DrawLine(width, height - (height * 0.25), width / 2, height)
		surface.DrawLine(width / 2, height, 0, height - (height * 0.25))
		surface.DrawLine(0, height - (height * 0.25), 0, 0)

	else
		
		surface.SetDrawColor(self.Color:Unpack())
		surface.DrawRect(1, 1, width - 1, height - 1)

		surface.SetDrawColor(outlineColor:Unpack())
		surface.DrawLine(0, 0, width, 0)
		surface.DrawLine(width, 0, width, height)
		surface.DrawLine(width, height, 0, height)
		surface.DrawLine(0, height, 0, 0)

	end
end

function PANEL:GetFrame()
	return self._frame
end

function PANEL:SetFrame(frame)
	local parent = self:GetParent()

	local startX, endX = unpack(parent.FrameArea)
	local height = self.VerticalPosition

	local frameAreaWidth = endX - startX
	local offsetFrame = frame - parent.ScrollOffset
	local x = startX + (offsetFrame / parent.Zoom) * frameAreaWidth

	self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2)
	self._frame = frame
end

function PANEL:RefreshFrame()
	self:SetFrame(self._frame)
end

function PANEL:OnMousePressed(mousecode)
	if mousecode ~= MOUSE_LEFT then
		self:OnCustomMousePressed(mousecode)
		return
	end

	self:MouseCapture(true)
	self._dragging = true
end

function PANEL:OnMouseReleased(mousecode)
	if mousecode ~= MOUSE_LEFT then
		return
	end

	self:MouseCapture(false)
	self._dragging = false
	self:OnPointerReleased(self._frame)
end

function PANEL:OnCursorMoved()
	if not self._dragging then
		return
	end

	local parent = self:GetParent()

	local cursorX, cursorY = parent:CursorPos()
	local startX, endX = unpack(parent.FrameArea)
	
	local targetX = cursorX - startX
	local width = endX - startX

	local targetPos = math.Round(parent.ScrollOffset + (targetX / width) * parent.Zoom)
	targetPos = targetPos < 0 and 0 or (targetPos >= parent.TotalFrames and parent.TotalFrames - 1 or targetPos)

	if targetPos ~= self._frame then
		self:SetFrame(targetPos)
		self:OnFrameChanged(targetPos)
	end
end

function PANEL:OnFrameChanged(newFrame) end
function PANEL:OnPointerReleased(frame) end
function PANEL:OnCustomMousePressed(mousecode) end

vgui.Register("SMHFramePointer", PANEL, "DPanel")
