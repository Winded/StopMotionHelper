
local PANEL = FindMetaTable("Panel")

function PANEL:SetRelativePos(otherPanel, x, y)
	local posX, posY = otherPanel:GetPos()
	self:SetPos(posX + x, posY + y)
end

-- For DListView
function PANEL:UpdateLines(lines)
--[[	self:ClearSelection()
	self:Clear()
	for _, line in pairs(lines) do
		self:AddLine(line)
	end]]
	local sorting = {}
	local existing = {}
	
	for k, line in pairs(lines) do -- turn lines stuff into a "sorting" table
		sorting[line] = true
	end
	
	for k, line in pairs(self:GetLines()) do -- first we remove lines that are missing from the sorting table
		if !sorting[line:GetValue(1)] then
			local _, selected = self:GetSelectedLine()
			if selected == line then self:ClearSelection() end -- clear selection if the removed line was selected
			self:RemoveLine(line:GetID())
			continue
		end
		existing[line:GetValue(1)] = true
	end
	
	for line, _ in pairs(sorting) do
		if existing[line] then continue end
		self:AddLine(line)
	end
	self:SortByColumn(1)
end

-- For number wangs
function PANEL:GetNumberStep()
	return self.Step or 1
end
function PANEL:SetNumberStep(step)
	self.Step = step
	self.Up.DoClick = function() self:SetValue(self:GetValue() + self.Step) end
	self.Down.DoClick = function() self:SetValue(self:GetValue() - self.Step) end
end
