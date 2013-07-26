
TOOL.Name = "SMH Save/Load"
TOOL.Category = "Stop Motion Helper"
TOOL.Command = nil
TOOL.ConfigName = ""

local SelectedEnt = NULL

function TOOL:LeftClick(tr)
	if tr.Entity == NULL or !tr.Entity:IsValid() then return false end
	SelectedEnt = tr.Entity
	return true
end

if SERVER then

local function load_data(pl,cmd,args)
	if SelectedEnt != NULL and SelectedEnt:IsValid() then
		SelectedEnt:smhLoad(args[1])
	end
end
concommand.Add("smh_saveload_load",load_data)

local function save_data(pl,cmd,args)
	if SelectedEnt != NULL and SelectedEnt:IsValid() then
		SelectedEnt:smhSave(args[1])
	end
end
concommand.Add("smh_saveload_save",save_data)

else

language.Add("Tool.smh_saveload.name","SMH Save/Load")
language.Add("Tool.smh_saveload.desc","Lets you save and load entity frame data.")
language.Add("Tool.smh_saveload.0","Left Click to select an entity to save/load data to/from.")

local TFilename
local BLoad
local BSave
function TOOL.BuildCPanel(CPanel)
	TFilename = vgui.Create("DTextEntry",CPanel)
	CPanel:AddItem(TFilename)
	
	BLoad = vgui.Create("DButton",CPanel)
	BLoad:SetText("Load")
	BLoad.DoClick = function()
		if string.len(TFilename:GetValue()) > 0 then
			RunConsoleCommand("smh_saveload_load",TFilename:GetValue())
		end
	end
	CPanel:AddItem(BLoad)
	
	BSave = vgui.Create("DButton",CPanel)
	BSave:SetText("Save")
	BSave.DoClick = function()
		if string.len(TFilename:GetValue()) > 0 then
			RunConsoleCommand("smh_saveload_save",TFilename:GetValue())
		end
	end
	CPanel:AddItem(BSave)
end

end