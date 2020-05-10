
local PANEL = {}

function PANEL:_initialize(surfaceDrawer, framePanel, color, pointy)
    self._surfaceDrawer = surfaceDrawer
    self._framePanel = framePanel

    self:SetSize(8, 15)
    self.color = color
    self.outlineColor = {0, 0, 0, 255}
    self.verticalPosition = 0;
    self.pointy = pointy
    self._frame = 0
end

function PANEL:Paint(width, height)
    if self._framePanel == nil then
        return
    end
    if self._frame < self._framePanel.scrollOffset or self._frame > (self._framePanel.scrollOffset + self._framePanel.zoom) then
        return
    end

    if self.pointy then
        self._surfaceDrawer:setDrawColor(unpack(self.color))
        self._surfaceDrawer:noTexture()
        self._surfaceDrawer:drawRect(1, 1, width - 1, height - (height * 0.25))
        self._surfaceDrawer:drawPoly({
            { x = 1, y = height - (height * 0.25) },
            { x = width - 1, y = height - (height * 0.25) },
            { x = width / 2, y = height - 1 },
        })

        self._surfaceDrawer:setDrawColor(unpack(self.outlineColor))
        self._surfaceDrawer:drawLine(0, 0, width, 0)
        self._surfaceDrawer:drawLine(width, 0, width, height - (height * 0.25))
        self._surfaceDrawer:drawLine(width, height - (height * 0.25), w / 2, height)
        self._surfaceDrawer:drawLine(width / 2, height, 0, height - (height * 0.25))
        self._surfaceDrawer:drawLine(0, height - (height * 0.25), 0, 0)
    else
        self._surfaceDrawer:setDrawColor(self.color)
        self._surfaceDrawer:drawRect(1, 1, width - 1, height - 1)

        self._surfaceDrawer:setDrawColor(unpack(self.outlineColor))
        self._surfaceDrawer:drawLine(0, 0, width, 0)
        self._surfaceDrawer:drawLine(width, 0, width, height)
        self._surfaceDrawer:drawLine(width, height, 0, height)
        self._surfaceDrawer:drawLine(0, height, 0, 0)
    end
end

return PANEL