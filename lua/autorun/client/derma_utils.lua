
local PANEL = FindMetaTable("Panel");

function PANEL:SetRelativePos(otherPanel, x, y)
	local posX, posY = otherPanel:GetPos();
	self:SetPos(posX + x, posY + y);
end

-- For number wangs
function PANEL:GetNumberStep()
	return self.Step or 1;
end
function PANEL:SetNumberStep(step)
	self.Step = step;
	self.Up.DoClick = function() self:SetValue(self:GetValue() + self.Step); end
	self.Down.DoClick = function() self:SetValue(self:GetValue() - self.Step); end
end