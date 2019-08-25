local function create()

    local clicker = vgui.Create("EditablePanel")

    clicker:SetWorldClicker(true)
    clicker.m_bStretchToFit = true

    clicker:SetPos(0, 0)
    clicker:SetSize(ScrW(), ScrH())

    clicker:MakePopup()
    clicker:SetVisible(false)

    return clicker

end

return create