
local PANEL = {};

function PANEL:Init()

    self:SetBackgroundColor(Color(64, 64, 64, 64));

end

vgui.Register("SMHFramePanel", PANEL, "DPanel");