
local Rx = include("../../rxlua/rx.lua");
local RxUtils = include("../../shared/rxutils.lua");

local function Create(parent)

	local panel = vgui.Create("DFrame", parent);

	panel:SetTitle("Save");
	panel:SetDeleteOnClose(false);

	panel.FileName = vgui.Create("DTextEntry", panel);
	panel.FileName:Bind(SMH.Data, "SaveFileName", "TextEntry");
	panel.FileName.Label = vgui.Create("DLabel", panel);
	panel.FileName.Label:SetText("Name");
	panel.FileName.Label:SizeToContents();

	panel.FileList = vgui.Create("DListView", panel);
	panel.FileList:SetMultiSelect(false);
	panel.FileList:AddColumn("Saved scenes");

	panel.Save = vgui.Create("DButton", panel);
	panel.Save:SetText("Save");

	panel.Delete = vgui.Create("DButton", panel);
	panel.Delete:SetText("Delete");

	local basePerformLayout = panel.PerformLayout;
	panel.PerformLayout = function(_, w, h)
	
		basePerformLayout(panel, w, h);

		panel:SetSize(250, 250);
		panel:SetPos(ScrW() / 2 - panel:GetWide() / 2, ScrH() / 2 - panel:GetTall() / 2);
	
		panel.FileName:SetPos(5, 45);
		panel.FileName:SetSize(panel:GetWide() - 5 - 5, 20);
		panel.FileName.Label:SetPos(5, 30);
	
		panel.FileList:SetPos(5, 67);
		panel.FileList:SetSize(panel:GetWide() - 5 - 5, 150);

		panel.Save:SetPos(panel:GetWide() - 60 - 5, 219);
		panel.Save:SetSize(60, 20);
	
		panel.Delete:SetPos(panel:GetWide() - 60 - 5 - 60 - 5, 219);
		panel.Delete:SetSize(60, 20);
	
	end

	local function addLines(item, lines)
		item:ClearSelection();
		item:Clear();
		for _, line in pairs(lines) do
			item:AddLine(line);
		end
	end
	
	local fileListStream = Rx.Subject.create();
	fileListStream:map(function(files) return panel.FileList, files end)
		:subscribe(addLines);

	local fileSelectStream = Rx.Subject.create();
	panel.FileList.OnRowSelected = function(self, rowID, row) fileSelectStream(row:GetValue(1)) end

	local _, fileStream = RxUtils.bindDPanel(panel.FileName, nil, "OnValueChange");

	local _, saveStream = RxUtils.bindDPanel(panel.Save, nil, "DoClick");
	local _, deleteStream = RxUtils.bindDPanel(panel.Delete, nil, "DoClick");

	fileSelectStream:subscribe(fileStream);

	return panel, {
		Input = {
			FileList = fileListStream,
		},
		Output = {
			File = fileStream,
			Save = saveStream,
			Delete = deleteStream,
		}
	};

end

return Create;