local OverwriteWarningActive = false
local AppendWindowActive = false
local DeletePromptActive = false
local FolderSelected = false

local PANEL = {}

function PANEL:Init()

    self:SetTitle("Save")
    self:SetDeleteOnClose(false)
    self:SetSizable(true)

    self:SetSize(250, 250)
    self:SetMinWidth(250)
    self:SetMinHeight(250)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

    self.FileName = vgui.Create("DTextEntry", self)
    self.FileName.Label = vgui.Create("DLabel", self)
    self.FileName.Label:SetText("Name")
    self.FileName.Label:SizeToContents()

    self.FileList = vgui.Create("DListView", self)
    self.FileList:SetMultiSelect(false)
    self.FileList:AddColumn("Saved scenes")
    self.FileList.OnRowSelected = function(_, rowID, row)
        if not IsValid(row) or row:GetValue(1) == ".." then
            return
        elseif row.IsFolder then
            self.FileName:SetValue(string.sub(row:GetValue(1), 2))
            FolderSelected = true
            return
        end
        self.FileName:SetValue(row:GetValue(1))
        FolderSelected = false
    end
    self.FileList.DoDoubleClick = function(_, rowID, row)
        if not IsValid(row) then 
            return
        end
        local path = row:GetValue(1)
        if not (row.IsFolder or path == "..") then return end
        if row.IsFolder then path = string.sub(path, 2) end

        self:DoFolderPath(path)
    end

    self.PathLabel = vgui.Create("DLabel", self)
    self.PathLabel:SetMouseInputEnabled(true)
    self.PathLabel:SetText("smh/")
    self.PathLabel:SetTooltip("smh/")

    self.Save = vgui.Create("DButton", self)
    self.Save:SetText("Save")
    self.Save.DoClick = function()
        self:DoSave()
    end

    self.MakeFolder = vgui.Create("DButton", self)
    self.MakeFolder:SetText("Add Folder")
    self.MakeFolder.DoClick = function()
        self:DoFolder()
    end

    self.Pack = vgui.Create("DButton", self)
    self.Pack:SetText("Pack")
    self.Pack.DoClick = function()
        self:OnPackRequested()
    end

    self.Delete = vgui.Create("DButton", self)
    self.Delete:SetText("Delete")
    self.Delete.DoClick = function()
        self:DoDelete()
    end

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    local xOffset, yOffset = (self:GetWide()*0.2 - 50), (self:GetTall()*0.1 - 25)

    self.FileName:SetPos(5, 45)
    self.FileName:SetSize(self:GetWide() - 75 - xOffset, 20)
    self.FileName.Label:SetPos(5, 30)

    self.FileList:SetPos(5, 67)
    self.FileList:SetSize(self:GetWide() - 75 - xOffset, 153 + (self:GetTall() - 250))

    self.PathLabel:SetPos(5, 220 + (self:GetTall() - 250))
    self.PathLabel:SetSize(self:GetWide() - 15 - 60, 20)

    self.Save:SetPos(self:GetWide() - 65 - xOffset, 67)
    self.Save:SetSize(60 + xOffset, 20 + yOffset)

    self.MakeFolder:SetPos(self:GetWide() - 65 - xOffset, 97 + 2*yOffset)
    self.MakeFolder:SetSize(60 + xOffset, 20 + yOffset)

    self.Pack:SetPos(self:GetWide() - 65 - xOffset, 127 + 4*yOffset)
    self.Pack:SetSize(60 + xOffset, 20 + yOffset)

    self.Delete:SetPos(self:GetWide() - 65 - xOffset, 207 + 6*yOffset)
    self.Delete:SetSize(60 + xOffset, 20 + yOffset)

end

function PANEL:SetSaves(folders, saves, path)
    self.FileList:UpdateLines(folders, true)
    self.FileList:UpdateLines(saves)
    self.PathLabel:SetText(path)
    self.PathLabel:SetTooltip(path)

    local kablooey = string.Explode("/", path)
    if #kablooey > 2 then
        local line = self.FileList:AddLine("..")
        self.FileList:SortByColumn(1)
    end
end

function PANEL:AddSave(path)
    self.FileList:AddLine(path)
end

function PANEL:AddFolder(path)
    local line = self.FileList:AddLine(path)
    line.IsFolder = true
end

function PANEL:RemoveSave(path, isFolder)
    if isFolder then path = "\\" .. path end

    for idx, line in pairs(self.FileList:GetLines()) do
        if line:GetValue(1) == path then
            self.FileList:RemoveLine(idx)
            break
        end
    end
end

function PANEL:DoSave()
    local path = self.FileName:GetValue()
    if not path or path == "" then
        return
    end

    FolderSelected = false
    -- TODO clientside support for loading and saving
    self:OnSaveRequested(path, false)
end

function PANEL:DoFolder()
    local path = self.FileName:GetValue()
    if not path or path == "" then
        return
    end

    FolderSelected = true
    -- TODO clientside support for loading and saving
    self:OnFolderRequested(path, false)
end

function PANEL:DoFolderPath(path)
    if not path or path == "" then
        return
    end

    self:OnGoToFolderRequested(path)
end

function PANEL:DoDelete()
    if DeletePromptActive then return end

    local path = self.FileName:GetValue()
    if not path or path == "" then
        return
    end

    DeletePromptActive = true

    local promptpanel = vgui.Create("DFrame")
    promptpanel:SetTitle("Confirm delete")
    promptpanel:SetPos((ScrW() / 2) - 250/2, (ScrH() / 2) - 200/2)
    promptpanel:SetSize(250, 200)
    promptpanel:MakePopup()
    promptpanel:DoModal()
    promptpanel:SetBackgroundBlur(true)

    local text = 'Are you sure you want to delete "' .. path .. '"?'
    if FolderSelected then
        text = text .. "\n\nCaution: you can't delete folders that still have files in them"
    end

    promptpanel.Label = vgui.Create("DLabel", promptpanel)
    promptpanel.Label:SetPos(25, 30)
    promptpanel.Label:SetSize(200, 20)
    promptpanel.Label:SetText(text)
    promptpanel.Label:SetWrap(true)
    promptpanel.Label:SetAutoStretchVertical(true)

    promptpanel.Delete = vgui.Create("DButton", promptpanel)
    promptpanel.Delete:SetPos(45, 175)
    promptpanel.Delete:SetSize(60, 20)
    promptpanel.Delete:SetText("Delete")

    promptpanel.Delete.DoClick = function()
        self:OnDeleteRequested(path, FolderSelected)
        FolderSelected = false
        promptpanel:Close()
    end

    promptpanel.Cancel = vgui.Create("DButton", promptpanel)
    promptpanel.Cancel:SetPos(145, 175)
    promptpanel.Cancel:SetSize(60, 20)
    promptpanel.Cancel:SetText("Cancel")

    promptpanel.Cancel.DoClick = function()
        promptpanel:Close()
    end

    promptpanel.OnClose = function()
        promptpanel:SetBackgroundBlur(false)
        DeletePromptActive = false
    end
end

function PANEL:SaveExists(names)
    if OverwriteWarningActive then return end

    local path = self.FileName:GetValue()
    local namelist
    if not path or path == "" then
        return
    end

    OverwriteWarningActive = true

    local overwritepanel = vgui.Create("DFrame")
    overwritepanel:SetTitle("Overwrite save?")
    overwritepanel:SetPos((ScrW() / 2) - 250/2, (ScrH() / 2) - 250/2)
    overwritepanel:SetSize(250, 250)
    overwritepanel:MakePopup()
    overwritepanel:DoModal()
    overwritepanel:SetBackgroundBlur(true)

    overwritepanel.ScrollPanel = vgui.Create("DScrollPanel", overwritepanel)
    overwritepanel.ScrollPanel:SetPos(25, 30)
    overwritepanel.ScrollPanel:SetSize(220, 190)

    if next(names) ~= nil then
        namelist = {"Following animations from the save will be lost:\n"}
        for _, name in ipairs(names) do
            table.insert(namelist, "- " .. name .. "\n")
        end
        namelist = table.concat(namelist)
    else
        namelist = "All animations from the save will be overridden"
    end

    overwritepanel.ScrollPanel.Text = vgui.Create("DLabel")
    overwritepanel.ScrollPanel.Text:SetSize(200, 20)
    overwritepanel.ScrollPanel.Text:SetText('Save "' .. path .. '" already exists. Do you want to replace it?\n\n' .. namelist .. "\n\nUse Append mode to merge animations from the game session into the save.")
    overwritepanel.ScrollPanel.Text:SetWrap(true)
    overwritepanel.ScrollPanel.Text:SetAutoStretchVertical(true)

    overwritepanel.ScrollPanel:AddItem(overwritepanel.ScrollPanel.Text)

    overwritepanel.AppendButton = vgui.Create("DButton", overwritepanel)
    overwritepanel.AppendButton:SetPos(25, 225)
    overwritepanel.AppendButton:SetSize(60, 20)
    overwritepanel.AppendButton:SetText("Append")

    overwritepanel.AppendButton.DoClick = function()
        self:OnAppendRequested(path)
        overwritepanel:Close()
    end

    overwritepanel.WriteButton = vgui.Create("DButton", overwritepanel)
    overwritepanel.WriteButton:SetPos(95, 225)
    overwritepanel.WriteButton:SetSize(60, 20)
    overwritepanel.WriteButton:SetText("Overwrite")

    overwritepanel.WriteButton.DoClick = function()
        self:OnOverwriteSave(path)
        overwritepanel:Close()
    end

    overwritepanel.CloseButton = vgui.Create("DButton", overwritepanel)
    overwritepanel.CloseButton:SetPos(165, 225)
    overwritepanel.CloseButton:SetSize(60, 20)
    overwritepanel.CloseButton:SetText("Cancel")

    overwritepanel.CloseButton.DoClick = function()
        overwritepanel:Close()
    end

    overwritepanel.OnClose = function()
        overwritepanel:SetBackgroundBlur(false)
        OverwriteWarningActive = false
    end
end

function PANEL:AppendWindow(savenames, gamenames)
    if AppendWindowActive then return end

    local path = self.FileName:GetValue()
    if not path or path == "" then
        return
    end

    AppendWindowActive = true

    local appendpanel = vgui.Create("DFrame")
    appendpanel:SetTitle("Append")
    appendpanel:SetPos((ScrW() / 2) - 300/2, (ScrH() / 2) - 350/2)
    appendpanel:SetSize(300, 350)
    appendpanel:MakePopup()
    appendpanel:DoModal()
    appendpanel:SetBackgroundBlur(true)

    appendpanel.ScrollPanel = vgui.Create("DScrollPanel", appendpanel)
    appendpanel.ScrollPanel:SetPos(25, 30)
    appendpanel.ScrollPanel:SetSize(270, 290)

    appendpanel.ScrollPanel.NameLeft = vgui.Create("DLabel", appendpanel.ScrollPanel)
    appendpanel.ScrollPanel.NameLeft:SetSize(100, 20)
    appendpanel.ScrollPanel.NameLeft:SetPos(0, 5)
    appendpanel.ScrollPanel.NameLeft:SetText("To be saved:")

    appendpanel.ScrollPanel.NameRight = vgui.Create("DLabel", appendpanel.ScrollPanel)
    appendpanel.ScrollPanel.NameRight:SetSize(100, 20)
    appendpanel.ScrollPanel.NameRight:SetPos(130, 5)
    appendpanel.ScrollPanel.NameRight:SetText("In Save:")


    local savestuff, gamestuff = {}, {}
    appendpanel.ScrollPanel.SaveNames = {}
    appendpanel.ScrollPanel.GameNames = {}

    for id, name in ipairs(savenames) do
        appendpanel.ScrollPanel.SaveNames[id] = vgui.Create("DCheckBox", appendpanel.ScrollPanel)
        appendpanel.ScrollPanel.SaveNames[id]:SetSize(15, 15)
        appendpanel.ScrollPanel.SaveNames[id]:SetPos(130, 30 + (id - 1)*20)
        appendpanel.ScrollPanel.SaveNames[id].Label = vgui.Create("DLabel", appendpanel.ScrollPanel)
        appendpanel.ScrollPanel.SaveNames[id].Label:SetSize(80, 15)
        appendpanel.ScrollPanel.SaveNames[id].Label:SetPos(130 + 20, 30 + (id - 1)*20)
        appendpanel.ScrollPanel.SaveNames[id].Label:SetMouseInputEnabled(true)
        appendpanel.ScrollPanel.SaveNames[id].Label:SetText(name)
        appendpanel.ScrollPanel.SaveNames[id].Label:SetTooltip(name)

        appendpanel.ScrollPanel.SaveNames[id].Label.DoClick = function()
            appendpanel.ScrollPanel.SaveNames[id]:Toggle()
        end

        appendpanel.ScrollPanel.SaveNames[id].OnChange = function(_, val)
            savestuff[name] = val
        end

        appendpanel.ScrollPanel.SaveNames[id]:SetValue(true)
    end

    for id, name in ipairs(gamenames) do
        appendpanel.ScrollPanel.GameNames[id] = vgui.Create("DCheckBox", appendpanel.ScrollPanel)
        appendpanel.ScrollPanel.GameNames[id]:SetSize(15, 15)
        appendpanel.ScrollPanel.GameNames[id]:SetPos(0, 30 + (id - 1)*20)
        appendpanel.ScrollPanel.GameNames[id].Label = vgui.Create("DLabel", appendpanel.ScrollPanel)
        appendpanel.ScrollPanel.GameNames[id].Label:SetSize(80, 15)
        appendpanel.ScrollPanel.GameNames[id].Label:SetPos(20, 30 + (id - 1)*20)
        appendpanel.ScrollPanel.GameNames[id].Label:SetMouseInputEnabled(true)
        appendpanel.ScrollPanel.GameNames[id].Label:SetText(name)
        appendpanel.ScrollPanel.GameNames[id].Label:SetTooltip(name)

        appendpanel.ScrollPanel.GameNames[id].Label.DoClick = function()
            appendpanel.ScrollPanel.GameNames[id]:Toggle()
        end

        appendpanel.ScrollPanel.GameNames[id].OnChange = function(_, val)
            gamestuff[name] = val
        end

        appendpanel.ScrollPanel.GameNames[id]:SetValue(true)
    end


    appendpanel.ConfirmButton = vgui.Create("DButton", appendpanel)
    appendpanel.ConfirmButton:SetPos(75, 325)
    appendpanel.ConfirmButton:SetSize(60, 20)
    appendpanel.ConfirmButton:SetText("Confirm")

    appendpanel.ConfirmButton.DoClick = function()
        local save, game = {}, {}

        for name, value in pairs(savestuff) do
            if value then
                table.insert(save, name)
            end
        end
        for name, value in pairs(gamestuff) do
            if value then
                table.insert(game, name)
            end
        end
        self:OnAppend(path, save, game)
        appendpanel:Close()
    end

    appendpanel.CloseButton = vgui.Create("DButton", appendpanel)
    appendpanel.CloseButton:SetPos(165, 325)
    appendpanel.CloseButton:SetSize(60, 20)
    appendpanel.CloseButton:SetText("Cancel")

    appendpanel.CloseButton.DoClick = function()
        appendpanel:Close()
    end

    appendpanel.OnClose = function()
        appendpanel:SetBackgroundBlur(false)
        AppendWindowActive = false
    end
end

function PANEL:OnSaveRequested(path, saveToClient) end
function PANEL:OnFolderRequested(path, saveToClient) end
function PANEL:OnGoToFolderRequested(path, toClient) end
function PANEL:OnOverwriteSave(path) end
function PANEL:OnAppendRequested(path) end
function PANEL:OnAppend(path, savenames, gamenames) end
function PANEL:OnPackRequested() end
function PANEL:OnDeleteRequested(path, isFolder, deleteFromClient) end

vgui.Register("SMHSave", PANEL, "DFrame")
