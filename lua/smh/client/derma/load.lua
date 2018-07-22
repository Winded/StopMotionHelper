
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Create(parent)

	local panel = vgui.Create("DFrame", parent);

	panel:SetTitle("Load");
	panel:SetDeleteOnClose(false);

	panel.FileList = vgui.Create("DListView", panel);
	panel.FileList:AddColumn("Saved scenes");
	panel.FileList:SetMultiSelect(false);

	panel.EntityList = vgui.Create("DListView", panel);
	panel.EntityList:AddColumn("Entities");
	panel.EntityList:SetMultiSelect(false);

	panel.Load = vgui.Create("DButton", panel);
	panel.Load:SetText("Load");

	local basePerformLayout = panel.PerformLayout;
	panel.PerformLayout = function(panel, w, h)

		basePerformLayout(panel, w, h);

		panel:SetSize(250, 210);
		panel:SetPos(ScrW() / 2 - panel:GetWide() / 2, ScrH() / 2 - panel:GetTall() / 2);
	
		panel.FileList:SetPos(5, 30);
		panel.FileList:SetSize(panel:GetWide() / 2 - 5 - 5, 150);
	
		panel.EntityList:SetPos(panel:GetWide() / 2 + 5, 30);
		panel.EntityList:SetSize(panel:GetWide() / 2 - 5 - 5, 150);
	
		panel.Load:SetPos(panel:GetWide() - 60 - 5, 182);
		panel.Load:SetSize(60, 20);

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
	
	local entitiesStream = Rx.Subject.create();
	entitiesStream:map(function(entities) return panel.EntityList, entities end)
		:subscribe(addLines);

	local fileSelectStream = Rx.Subject.create();
	panel.FileList.OnRowSelected = function(self, rowID, row) fileSelectStream(row:GetValue(1)) end

	local entitySelectStream = Rx.Subject.create();
	panel.EntityList.OnRowSelected = function(self, rowID, row) entitySelectStream(row:GetValue(1)) end

	local _, loadStream = RxUtils.bindDPanel(panel.Load, nil, "DoClick");

	return panel, {
		Input = {
			FileList = fileListStream,
			Entities = entitiesStream,
		},
		Output = {
			File = fileSelectStream,
			Entity = entitySelectStream,
			Load = loadStream,
		}
	};

end

return Create;