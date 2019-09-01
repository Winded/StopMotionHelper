local PANEL = {}

function PANEL:Init()
	self:SetSize(8, 15)
	self.Color = Color(0, 200, 0)
	self.OutlineColor = Color(0, 0, 0)
	self.VerticalPosition = 0
	self.Pointy = false

	self.Position = 0
end

function PANEL:Paint(w, h)
	local panel = self.FramePanel
	if panel == nil or not (self.Position >= panel.ScrollOffset and self.Position <= (panel.ScrollOffset + panel.Zoom)) then
		return
	end

	if self.Pointy then
		surface.SetDrawColor(self.Color)
		draw.NoTexture()
		surface.DrawRect(1, 1, w - 1, h - (h * 0.25))
		surface.DrawPoly({
			{ x = 1, y = h - (h * 0.25) },
			{ x = w - 1, y = h - (h * 0.25) },
			{ x = w / 2, y = h - 1 },
		})

		surface.SetDrawColor(self.OutlineColor)
		surface.DrawLine(0, 0, w, 0)
		surface.DrawLine(w, 0, w, h - (h * 0.25))
		surface.DrawLine(w, h - (h * 0.25), w / 2, h)
		surface.DrawLine(w / 2, h, 0, h - (h * 0.25))
		surface.DrawLine(0, h - (h * 0.25), 0, 0)
	else
		surface.SetDrawColor(self.Color)
		surface.DrawRect(1, 1, w - 1, h - 1)

		surface.SetDrawColor(self.OutlineColor)
		surface.DrawLine(0, 0, w, 0)
		surface.DrawLine(w, 0, w, h)
		surface.DrawLine(w, h, 0, h)
		surface.DrawLine(0, h, 0, 0)
	end
end

vgui.Register("SMHFramePointer", PANEL, "DPanel")