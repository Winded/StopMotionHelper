local PANEL = {}

function PANEL:Init()

	self:SetBackgroundColor(Color(64, 64, 64, 64))

	self.Playhead = vgui.Create("SMHFramePointer", self)
	self.Playhead.Color = Color(255, 255, 255)
	self.Playhead.FramePanel = self

	self.ScrollBar = vgui.Create("DPanel", self)
	self.ScrollBar.Paint = function(self, w, h) derma.SkinHook("Paint", "ScrollBarGrip", self, w, h) end

	self.ScrollBtnLeft = vgui.Create("DButton", self)
	self.ScrollBtnLeft:SetText("")
	self.ScrollBtnLeft.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonLeft", self, w, h) end

	self.ScrollBtnRight = vgui.Create("DButton", self)
	self.ScrollBtnRight:SetText("")
	self.ScrollBtnRight.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonRight", self, w, h) end

	self.TimelineLength = 100
	self.ScrollOffset = 0
	self.Zoom = 100
	self.FrameArea = {0, 1}
	self.ScrollBarAreaPosition = {0, 0}
	self.ScrollBarAreaSize = {0, 0}

end

function PANEL:PerformLayout(width, height)
	
	local scrollPadding = 18
	local scrollHeight = 12

	local scrollPosY = height - scrollHeight

	self.ScrollBarAreaPosition = { scrollPadding, scrollPosY }
	self.ScrollBarAreaSize = { width - scrollPadding * 2, scrollHeight }

	scrollBtnLeft:SetPos(scrollPadding - 12, scrollPosY)
	scrollBtnLeft:SetSize(12, scrollHeight)

	scrollBtnRight:SetPos(scrollPadding + self.ScrollBarAreaSize[1], scrollPosY)
	scrollBtnRight:SetSize(12, scrollHeight)

end

function PANEL:Paint()
	local width, height = self:GetWide(), self:GetTall()
	local startX, endX = unpack(self.FrameArea)

	local frameWidth = (endX - startX) / self.Zoom

	surface.SetDrawColor(255, 255, 255, 255)

	for i = 0, self.Zoom do
		if self.ScrollOffset + i < self.TimelineLength then
			local x = startX + frameWidth * i
			surface.DrawLine(x, 6, x, height - 6)
		end
	end
end

vgui.Register("SMHFramePanel", PANEL, "DPanel")
