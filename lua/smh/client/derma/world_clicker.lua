
local PANEL = {};

function PANEL:Init()

	self:SetWorldClicker(true);
	self:SetDrawBackground(false);
	self.m_bStretchToFit = true;

	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());

end

function PANEL:OnMousePressed(mousecode)

	if mousecode ~= MOUSE_RIGHT then
		return;
	end

	local playerTrace = util.GetPlayerTrace(LocalPlayer());
	local tr = util.TraceLine(playerTrace);
	if IsValid(tr.Entity) then
		self:OnSelect(tr.Entity);
	end

end

function PANEL:OnSelect(entity) end

vgui.Register("SMHWorldClicker", PANEL, "DPanel");

local BIND = setmetatable({}, BiValues.ValueBind);
function BIND:Init()
	self.Settings.Callback = self.Settings.Callback or "OnSelect";
	BiValues.ValueBind.Init(self);
end
function BIND:SetValue(value)
	-- do nothing
end
BiValues.RegisterBindType("WorldClicker", BIND);