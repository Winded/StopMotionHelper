return function(parent)

	local panel = vgui.Create("DFrame", parent);

	panel:SetTitle("SMH Settings");
	panel:SetDeleteOnClose(false);

	panel.FreezeAll = vgui.Create("DCheckBoxLabel", panel);
	panel.FreezeAll:SetText("Freeze all");
	panel.FreezeAll:SizeToContents();

	panel.LocalizePhysBones = vgui.Create("DCheckBoxLabel", panel);
	panel.LocalizePhysBones:SetText("Localize phys bones");
	panel.LocalizePhysBones:SizeToContents();

	panel.IgnorePhysBones = vgui.Create("DCheckBoxLabel", panel);
	panel.IgnorePhysBones:SetText("Don't animate phys bones");
	panel.IgnorePhysBones:SizeToContents();

	panel.GhostPrevFrame = vgui.Create("DCheckBoxLabel", panel);
	panel.GhostPrevFrame:SetText("Ghost previous frame");
	panel.GhostPrevFrame:SizeToContents();

	panel.GhostNextFrame = vgui.Create("DCheckBoxLabel", panel);
	panel.GhostNextFrame:SetText("Ghost next frame");
	panel.GhostNextFrame:SizeToContents();

	panel.GhostAllEntities = vgui.Create("DCheckBoxLabel", panel);
	panel.GhostAllEntities:SetText("Ghost all entities");
	panel.GhostAllEntities:SizeToContents();

	panel.GhostTransparency = vgui.Create("Slider", panel);
	panel.GhostTransparency:SetMinMax(0, 1);
	panel.GhostTransparency:SetDecimals(2);
	panel.GhostTransparencyLabel = vgui.Create("DLabel", panel);
	panel.GhostTransparencyLabel:SetText("Ghost transparency");
	panel.GhostTransparencyLabel:SizeToContents();

	panel.HelpButton = vgui.Create("DButton", panel);
	panel.HelpButton:SetText("Help");

	panel:SetSize(160, 225);

	local basePerformLayout = panel.PerformLayout;
	panel.PerformLayout = function()

		basePerformLayout(panel);

		panel.FreezeAll:SetPos(5, 25);
	
		panel.LocalizePhysBones:SetPos(5, 45);
	
		panel.IgnorePhysBones:SetPos(5, 65);
	
		panel.GhostPrevFrame:SetPos(5, 85);
		panel.GhostNextFrame:SetPos(5, 105);
		panel.GhostAllEntities:SetPos(5, 125);
	
		local gt = panel.GhostTransparency;
		local label = panel.GhostTransparencyLabel;
		label:SizeToContents();
		local LW, LH = label:GetSize();
		gt:SetPos(5, 145 + LH - 5);
		gt:SetSize(panel:GetWide() - 5 - 5, 25);
		label:SetPos(10, 145);
	
		panel.HelpButton:SetPos(5, 190);
		panel.HelpButton:SetSize(150, 20);

	end
	
	return panel

end