local PANEL = {}

function PANEL:Init()

    self:SetWorldClicker(true)
    self.m_bStretchToFit = true

    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())

    self:MakePopup()
    self:SetVisible(false)

end

vgui.Register("SMHWorldClicker", PANEL, "EditablePanel")