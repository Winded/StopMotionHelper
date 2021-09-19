local PANEL = {}
local EntsTable = {}
local Fallback = "none"
local selectedEntity = nil

local function GetModelName(entity)
	local mdl = string.Split(entity:GetModel(), "/");
	mdl = mdl[#mdl];
	return mdl
end

local function FindEntity(entity)
	if EntsTable then
		for kentity, value in pairs(EntsTable) do
			if kentity == entity then
				return value
			end
		end
	end
	
	return nil
end

function PANEL:Init()

	self:SetTitle("Properties")
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	
	self:SetSize(250, 210)
	self:SetMinWidth(250)
	self:SetMinHeight(210)
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)
	
	self.EntityNameEnter = vgui.Create("DTextEntry", self)
	self.EntityNameEnter:SetSize(240, 20)
	self.EntityNameEnter:SetEditable(false)
	self.EntityNameEnter:SetText("none")
	self.EntityNameEnter.OnLoseFocus = function(sel)
		if sel:GetValue() == "" then
			sel:SetText(Fallback)
		end
		
		self:ApplyName(selectedEntity, sel:GetValue())
	end
		self.EntityNameEnter.Label = vgui.Create("DLabel", self)
		self.EntityNameEnter.Label:SetText("Selected entity's name:")
		self.EntityNameEnter.Label:SizeToContents()
	
end

function PANEL:PerformLayout(width, height)
	
	self.BaseClass.PerformLayout(self, width, height)
	
	self.EntityNameEnter:Center()
		self.EntityNameEnter.Label:SetRelativePos(self.EntityNameEnter, 0, -5 - self.EntityNameEnter.Label:GetTall())
	
end

function PANEL:UpdateSelectedEnt(ent)
	selectedEntity = ent
end

function PANEL:SetName(name)
	self.EntityNameEnter:SetText(name)
end

function PANEL:SetEntities(entities)
	EntsTable = table.Copy(entities)
	
	if !IsValid(selectedEntity) then
		self.EntityNameEnter:SetText("none")
		self.EntityNameEnter:SetEditable(false)
	else
		local entityinfo = FindEntity(selectedEntity)
		
		if !entityinfo then
			Fallback = GetModelName(selectedEntity)
			self.EntityNameEnter:SetText(Fallback)
			self.EntityNameEnter:SetEditable(false)
		else
			Fallback = entityinfo.Name
			self.EntityNameEnter:SetText(entityinfo.Name)
			self.EntityNameEnter:SetEditable(true)
		end
	end
end

function PANEL:ApplyName(ent, name) end

vgui.Register("SMHProperties", PANEL, "DFrame")
