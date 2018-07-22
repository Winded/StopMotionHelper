
local Rx = SMH.Include("rxlua/rx.lua");

local function Setup()

	local clicker = vgui.Create("EditablePanel");

	clicker:SetWorldClicker(true);
	clicker.m_bStretchToFit = true;

	clicker:SetPos(0, 0);
	clicker:SetSize(ScrW(), ScrH());

	clicker:MakePopup();
	clicker:SetVisible(false);

	local mousePressStream = Rx.Subject.create();
	clicker.OnMousePressed = function(self, mousecode) mousePressStream(mousecode) end
	
	local selectorStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_RIGHT end)
		:map(function(mousecode) return util.TraceLine(util.GetPlayerTrace(LocalPlayer())) end);

	local visibilityStream = Rx.Subject.create();
	visibilityStream:subscribe(function(value)
		if not value then
			RememberCursorPosition();
		end
		clicker:SetVisible(value);
		if value then
			RestoreCursorPosition();
		end
	end);

	return clicker, {
		Input = {
			Visibility = visibilityStream,
		},
		Output = {
			Selector = selectorStream,
		}
	};
end

return Setup;