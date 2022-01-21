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
    self._ids = {}
    self._mods = {}
    self._selected = false
    self._maxoffset = 0
    self._minoffset = 0

end

function PANEL:Paint(width, height)
    local parent = self:GetParent()
    if self._frame < parent.ScrollOffset or self._frame > (parent.ScrollOffset + parent.Zoom - 1) then
        return
    end

    local outlineColor = ((self._selected or self._dragging) and self.OutlineColorDragged) or self.OutlineColor

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
    local x = startX + (offsetFrame / (parent.Zoom - 1)) * frameAreaWidth

    self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2)
    self._frame = frame
end

function PANEL:RefreshFrame()
    self:SetFrame(self._frame)
end

function PANEL:IsDragging()
    return self._dragging
end

function PANEL:SetSelected(selected)
    self._selected = selected
end

function PANEL:GetSelected()
    return self._selected
end

function PANEL:GetIDs()
    return self._ids
end

function PANEL:GetMods()
    return self._mods
end

function PANEL:RemoveID(id)
    self._mods[self._ids[id]] = nil
    self._ids[id] = nil
end

function PANEL:AddID(id, mod)
    self._ids[id] = mod
    self._mods[mod] = id
end

function PANEL:OnMousePressed(mousecode)
    if mousecode ~= MOUSE_LEFT then
        self:MouseCapture(false)
        self._dragging = false
        self:OnCustomMousePressed(mousecode)
        return
    end

    self:MouseCapture(true)
    self._dragging = true

    SMH.UI.SetOffsets(self)
end

function PANEL:SetParentPointer(ppointer)
    self.parent = ppointer
end

function PANEL:ClearParentPointer()
    self.parent = nil
end

function PANEL:GetParentKeyframe()
    return self.parent
end

function PANEL:SetOffsets(minimum, maximum)
    self._minoffset = minimum
    self._maxoffset = maximum
end

function PANEL:SetParentPointer(ppointer)
    self.parent = ppointer
end

function PANEL:ClearParentPointer()
    self.parent = nil
end

function PANEL:GetParentKeyframe()
    return self.parent
end

function PANEL:OnMouseReleased(mousecode)
    if not self._dragging then
        return
    end

    self:SetOffsets(0, 0)

    self:MouseCapture(false)
    self._dragging = false
    SMH.UI.ClearFrames(self)
    self:OnPointerReleased(self._frame)

    if mousecode == MOUSE_LEFT and not self.PointyBottom then
        if input.IsKeyDown(KEY_LSHIFT) then
            SMH.UI.ShiftSelect(self)
        elseif input.IsKeyDown(KEY_LCONTROL) then
            SMH.UI.ToggleSelect(self)
        else
            SMH.UI.ClearAllSelected()
        end
    end
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

    local targetPos = math.Round(parent.ScrollOffset + (targetX / width) * (parent.Zoom - 1))
    targetPos = targetPos < 0 - self._minoffset and 0 - self._minoffset or (targetPos >= parent.TotalFrames - self._maxoffset and parent.TotalFrames - 1 - self._maxoffset or targetPos)

    if targetPos ~= self._frame then
        SMH.UI.MoveChildren(self, targetPos)
        self:SetFrame(targetPos)
        self:OnFrameChanged(targetPos)
        SMH.UI.MoveChildren(self, targetPos)
    end
end

function PANEL:OnFrameChanged(newFrame) end
function PANEL:OnPointerReleased(frame) end
function PANEL:OnCustomMousePressed(mousecode) end

vgui.Register("SMHFramePointer", PANEL, "DPanel")
