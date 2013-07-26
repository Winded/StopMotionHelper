
//Well, this got short...

TOOL.Name = "SMH Selector"
TOOL.Category = "Stop Motion Helper"
TOOL.Command = nil
TOOL.ConfigName = ""


function TOOL:LeftClick(tr)
	return SMH.svSelectEnt(tr.Entity)
end

function TOOL:RightClick(tr)
	return SMH.svDeselectEnt(tr.Entity)
end

function TOOL:Reload(tr)
	if tr.Entity == NULL or !tr.Entity:IsValid() then return false end
	if !tr.Entity.smhFrames then return true end
	tr.Entity:smhClearFrames()
	return true
end

if CLIENT then

language.Add("Tool.smh_selector.name", "SMH Selector")
language.Add("Tool.smh_selector.desc", "Select entities for Stop Motion Helper.")
language.Add("Tool.smh_selector.0", "Left Click to select an object, Right Click to deselect, Reload to clear entity frames.")

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header",{Name = "#Tool_smh_selector_name",Description = "#Tool_smh_selector_desc"})
	local TEntText = vgui.Create("DLabel",CPanel)
	TEntText:SetText("Entities selected: 99")
	TEntText:SizeToContents()
	CPanel:AddItem(TEntText)
	LocalPlayer().smhTEntText = TEntText;
end
function TOOL:Think()
	local entcount = #SMH.Ents
	local str = "Entities Selected: "..tostring(entcount)
	LocalPlayer().smhTEntText:SetText(str)
end

end
