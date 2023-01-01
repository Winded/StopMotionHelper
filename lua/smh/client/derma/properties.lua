local PANEL = {}
local EntsTable = {}
local PropertyTable = {}
local ModifierList = {}
local Fallback = "none"
local selectedEntity = nil
local UsingWorld = false
local IsSaving = false

local function GetModelName(entity)
    local mdl = string.Split(entity:GetModel(), "/");
    mdl = mdl[#mdl];
    return mdl
end

local function FindEntityInfo(entity)
    if EntsTable then
        for kentity, value in pairs(EntsTable) do
            if kentity == entity then
                return value
            end
        end
    end

    return nil
end

local function FindEntity(name)
    if EntsTable then
        for kentity, value in pairs(EntsTable) do
            if value.Name == name then
                return kentity
            end
        end
    end

    return nil
end

local function UpdateName(name)
    if not IsValid(selectedEntity) then return end
    if EntsTable then
        EntsTable[selectedEntity].Name = name
    end
end

function PANEL:Init()

    self:SetTitle("Properties")
    self:SetDeleteOnClose(false)
    self:SetSizable(true)

    self:SetSize(704, 420)
    self:SetMinWidth(704)
    self:SetMinHeight(420)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

    self.EntitiesPanel = vgui.Create("DPanel", self)
    self.EntitiesPanel:SetBackgroundColor(Color(155, 155, 155, 255))

    self.EntityNameEnter = vgui.Create("DTextEntry", self.EntitiesPanel)
    self.EntityNameEnter:SetSize(236, 20)
    self.EntityNameEnter:SetEditable(false)
    self.EntityNameEnter:SetText("none")
    self.EntityNameEnter.OnLoseFocus = function(sel)
        if sel:GetValue() == "" then
            sel:SetText(Fallback)
        end

        self:ApplyName(selectedEntity, sel:GetValue())
    end
        self.EntityNameEnter.Label = vgui.Create("DLabel", self.EntitiesPanel)
        self.EntityNameEnter.Label:SetText("Selected entity's name:")
        self.EntityNameEnter.Label:SizeToContents()

    self.EntityList = vgui.Create("DListView", self.EntitiesPanel)
    self.EntityList:AddColumn("Recorded Entities")
    self.EntityList:SetMultiSelect(false)
    self.EntityList.OnRowSelected = function(_, rowIndex, row)
        local _, selectedName = self.EntityList:GetSelectedLine()
        if not IsValid(selectedName) then return end
        local selectedEntity = FindEntity(selectedName:GetValue(1))
        if not IsValid(selectedEntity) then return end
        self:SelectEntity(selectedEntity)
    end

    self.TimelinesPanel = vgui.Create("DPanel", self)
    self.TimelinesPanel:SetBackgroundColor(Color(155, 155, 155, 255))

    self.SettingPicker = vgui.Create("DComboBox", self.TimelinesPanel)
    self.SettingPicker.OnSelect = function(_, index, value)
        RunConsoleCommand("smh_currentpreset", value)
        local settings = SMH.Saves.GetPreferences(value)
        if not settings and not value == "default" then return end
        self:SetSettings(settings, value)
    end

    self.AddSettingPresetButton = vgui.Create("DButton", self.TimelinesPanel)
    self.AddSettingPresetButton:SetText("+")
    self.AddSettingPresetButton.DoClick = function()
        self:MakeSettingSavePanel()
    end

    self.SelectedEntityLabel = vgui.Create("DLabel", self.TimelinesPanel)
    self.SelectedEntityLabel:SetText("Selected model: " .. "none")

    self.AddTimeButton = vgui.Create("DButton", self.TimelinesPanel)
    self.AddTimeButton:SetText("Add Timeline")
    self.AddTimeButton.DoClick = function()
        if UsingWorld then return end
        self:ButtonTimeline(true)
    end

    self.RemoveTimeButton = vgui.Create("DButton", self.TimelinesPanel)
    self.RemoveTimeButton:SetText("Remove Timeline")
    self.RemoveTimeButton.DoClick = function()
        if UsingWorld then return end
        self:ButtonTimeline(false)
    end

    self.TimelinesCList = vgui.Create("DCategoryList", self.TimelinesPanel)

    self.ColorPanel = vgui.Create("DPanel", self)
    self.ColorPanel:SetBackgroundColor(Color(155, 155, 155, 255))

    self.ColorLabel = vgui.Create("DLabel", self.ColorPanel)
    self.ColorLabel:SetText("Keyframe Color for timeline: " .. "none")
 
    self.ColorPicker = vgui.Create("DColorMixer", self.ColorPanel)
    self.ColorPicker:SetPalette(false)
    self.ColorPicker:SetAlphaBar(false)
    self.ColorPicker:SetWangs(true)
    self.ColorPicker.Timeline = -1
    self.ColorPicker.ValueChanged = function(_, col)
        col = Color(col.r, col.g, col.b)
        self.ColorPreview:SetBackgroundColor(col)
        if next(PropertyTable) == nil or self.ColorPicker.Timeline == -1 then return end
        self:OnUpdateKeyframeColorRequested(col, self.ColorPicker.Timeline)
        if self.ColorPicker.Timeline == SMH.State.Timeline then SMH.UI.PaintKeyframes(col) end
    end

    self.ColorPreview = vgui.Create("DPanel", self.ColorPanel)
    self.ColorPreview:SetBackgroundColor(self.ColorPicker:GetColor())

    self.SelectWorldButton = vgui.Create("DButton", self.ColorPanel)
    self.SelectWorldButton:SetText("Select World")
    self.SelectWorldButton.DoClick = function()
        self:SelectWorld()
    end

    self.WorldParent = vgui.Create("Panel", self.ColorPanel)

    self.ConsoleEnter = vgui.Create("DTextEntry", self.WorldParent)
    self.ConsoleEnter.OnLoseFocus = function(sel)
        self:SetData(sel:GetValue(), "Console")
    end
        self.ConsoleEnter.Label = vgui.Create("DLabel", self.WorldParent)
        self.ConsoleEnter.Label:SetText("Console command:")
        self.ConsoleEnter.Label:SizeToContents()

    self.ButtonPressEnter = vgui.Create("DTextEntry", self.WorldParent)
    self.ButtonPressEnter.OnLoseFocus = function(sel)
        self:SetData(sel:GetValue(), "Push")
    end
        self.ButtonPressEnter.Label = vgui.Create("DLabel", self.WorldParent)
        self.ButtonPressEnter.Label:SetText("Keys to press:")
        self.ButtonPressEnter.Label:SizeToContents()

    self.ButtonReleaseEnter = vgui.Create("DTextEntry", self.WorldParent)
    self.ButtonReleaseEnter.OnLoseFocus = function(sel)
        self:SetData(sel:GetValue(), "Release")
    end
        self.ButtonReleaseEnter.Label = vgui.Create("DLabel", self.WorldParent)
        self.ButtonReleaseEnter.Label:SetText("Keys to release:")
        self.ButtonReleaseEnter.Label:SizeToContents()

    self.WorldParent:SetVisible(false)

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.EntitiesPanel:SetPos(4, 30)
    self.EntitiesPanel:SetSize(240, self:GetTall() - 4 - 30)

    self.EntityNameEnter:SetPos(2, 25)
        self.EntityNameEnter.Label:SetRelativePos(self.EntityNameEnter, 2, -5 - self.EntityNameEnter.Label:GetTall())

    self.EntityList:SetPos(5, 60)
    self.EntityList:SetSize(230, self.EntitiesPanel:GetTall() - 60 - 5)

    self.TimelinesPanel:SetPos(248, 30)
    self.TimelinesPanel:SetSize(self:GetWide() - 456, self:GetTall() - 4 - 30)

    self.SelectedEntityLabel:SetPos(4, 5)
    self.SelectedEntityLabel:SetSize(self.TimelinesPanel:GetWide() - 8, 15)

    self.SettingPicker:SetPos(4, 25)
    self.SettingPicker:SetSize(self.TimelinesPanel:GetWide() - 10 - 25, 20)

    self.AddSettingPresetButton:SetPos(self.TimelinesPanel:GetWide() - 8 - 20, 25)
    self.AddSettingPresetButton:SetSize(20, 20)

    self.TimelinesCList:SetPos(5, 70)
    self.TimelinesCList:SetSize(self.TimelinesPanel:GetWide() - 10, self.TimelinesPanel:GetTall() - 70 - 5)

    self.AddTimeButton:SetPos(5, 50)
    self.AddTimeButton:SetSize(self.TimelinesCList:GetWide() / 2 - 2, 20)

    self.RemoveTimeButton:SetPos(5 + self.TimelinesCList:GetWide() / 2 + 2, 50)
    self.RemoveTimeButton:SetSize(self.TimelinesCList:GetWide() / 2 - 2, 20)

    self.ColorPanel:SetPos(248 + self:GetWide() - 456 + 4, 30)
    self.ColorPanel:SetSize(200, self:GetTall() - 4 - 30)

    self.ColorLabel:SetPos(4, 5)
    self.ColorLabel:SetSize(self.ColorPanel:GetWide() - 8, 15)

    self.ColorPicker:SetPos(5, 35)
    self.ColorPicker:SetSize(190, 130)

    self.ColorPreview:SetPos(5, 165 + 5)
    self.ColorPreview:SetSize(105, 15)

    self.SelectWorldButton:SetPos(5, 185 + 10)
    self.SelectWorldButton:SetSize(self.ColorPanel:GetWide() - 10, 20)

    self.WorldParent:SetPos(0, 225)
    self.WorldParent:SetSize(self.ColorPanel:GetWide(), self.ColorPanel:GetTall() - 225)

    self.ConsoleEnter:SetPos(5, 15)
    self.ConsoleEnter:SetSize(self.WorldParent:GetWide() - 10, 20)
        self.ConsoleEnter.Label:SetRelativePos(self.ConsoleEnter, 2, -5 - self.ConsoleEnter.Label:GetTall())

    self.ButtonPressEnter:SetPos(5, 55)
    self.ButtonPressEnter:SetSize(self.WorldParent:GetWide() - 10, 20)
        self.ButtonPressEnter.Label:SetRelativePos(self.ButtonPressEnter, 2, -5 - self.ButtonPressEnter.Label:GetTall())

    self.ButtonReleaseEnter:SetPos(5, 95)
    self.ButtonReleaseEnter:SetSize(self.WorldParent:GetWide() - 10, 20)
        self.ButtonReleaseEnter.Label:SetRelativePos(self.ButtonReleaseEnter, 2, -5 - self.ButtonReleaseEnter.Label:GetTall())

end

function PANEL:MakeSettingSavePanel()
    if IsSaving then return end

    IsSaving = true

    local savepanel = vgui.Create("DFrame")
    savepanel:SetTitle("Save Timeline Preset")
    savepanel:SetPos((ScrW() / 2) - 100, (ScrH() / 2) - 50)
    savepanel:SetSize(200, 100)
    savepanel:MakePopup()
    savepanel:SetBackgroundBlur(true)

    savepanel.TextEnter = vgui.Create("DTextEntry", savepanel)
    savepanel.TextEnter:SetPos(50, 45)
    savepanel.TextEnter:SetSize(100, 20)

    savepanel.SaveButton = vgui.Create("DButton", savepanel)
    savepanel.SaveButton:SetPos(75, 75)
    savepanel.SaveButton:SetSize(50, 20)
    savepanel.SaveButton:SetText("Save")

    savepanel.SaveButton.DoClick = function()
        local text = savepanel.TextEnter:GetValue()
        if text == "" or text == "default" then return end
        self:SaveSettingsPreset(text)
        savepanel:Close()
    end

    savepanel.OnClose = function()
        savepanel:SetBackgroundBlur(false)
        IsSaving = false
    end
end

function PANEL:UpdateSelectedEnt(ent)
    local modelname = ent == LocalPlayer() and "world" or IsValid(ent) and ent:GetModel() or "none"
    self.SelectedEntityLabel:SetText("Selected model: " .. modelname)

    selectedEntity = ent
    self:SetEntities(EntsTable)
end

function PANEL:SetName(name)
    self.EntityNameEnter:SetText(name)
    UpdateName(name)
    self:SetEntities(EntsTable)
end

function PANEL:UpdateTimelineInfo(timelineinfo)
    PropertyTable = table.Copy(timelineinfo)
    self:BuildTimelineinfo()
end

function PANEL:UpdateModifiersInfo(timelineinfo, changed)
    PropertyTable = table.Copy(timelineinfo)

    for i = 1, PropertyTable.Timelines do
        local set = false
        for _, name in ipairs(PropertyTable.TimelineMods[i]) do
            if changed == name then
                self.TimelinesUI[i].Contents.Checker[name]:SetChecked(true)
                set = true
            end
        end
        if not set then
            self.TimelinesUI[i].Contents.Checker[changed]:SetChecked(false)
        end
    end
end

function PANEL:BuildTimelineinfo()
    self.TimelinesCList:Clear()
    self.TimelinesUI = {}

    self.ColorLabel:SetText("Keyframe Color for timeline: " .. "none")
    self.ColorPicker.Timeline = -1
    if next(PropertyTable) == nil then return end

    for i = 1, PropertyTable.Timelines do
        self.TimelinesUI[i] = self.TimelinesCList:Add("Timeline " .. i)
        self.TimelinesUI[i]:SetTall(200)
        self.TimelinesUI[i].Contents = vgui.Create("DPanel")
        self.TimelinesUI[i].OnToggle = function(_, expanded)
            if expanded then 
                self.ColorLabel:SetText("Keyframe Color for timeline: " .. i)
                self.ColorPicker.Timeline = i
                self.ColorPicker:SetColor(PropertyTable.TimelineMods[i].KeyColor)
            end
        end
        self.TimelinesUI[i].Contents.Checker = {}
        for mod, name in pairs(ModifierList) do
            self.TimelinesUI[i].Contents.Checker[mod] = vgui.Create("DCheckBoxLabel", self.TimelinesUI[i].Contents)
            self.TimelinesUI[i].Contents.Checker[mod]:SetText(name)
            self.TimelinesUI[i].Contents.Checker[mod]:SetTextColor(Color(25, 25, 25))
            self.TimelinesUI[i].Contents.Checker[mod].OnChange = function(_, check)
                if UsingWorld then return end
                self:OnUpdateModifierRequested(i, mod, check)
            end
            self.TimelinesUI[i].Contents.Checker[mod]:DockMargin(0, 0, 0, 2)
            self.TimelinesUI[i].Contents.Checker[mod]:Dock(TOP)
        end

        for _, mod in ipairs(PropertyTable.TimelineMods[i]) do
            self.TimelinesUI[i].Contents.Checker[mod]:SetChecked(true)
        end

        self.TimelinesUI[i]:SetContents(self.TimelinesUI[i].Contents)
        self.TimelinesUI[i]:SetExpanded(false)
    end
end

function PANEL:GetCurrentModifiers()
    if not PropertyTable or not PropertyTable.TimelineMods then return {} end
    return PropertyTable.TimelineMods[SMH.State.Timeline]
end

function PANEL:UpdateTimelineSettings()
    self.SettingPicker:Clear()
    self.SettingPicker:AddChoice("default")

    for _, setting in ipairs(SMH.Saves.ListSettings()) do
        self.SettingPicker:AddChoice(setting)
    end

    if ConVarExists("smh_currentpreset") then
        self.SettingPicker:SetValue(GetConVar("smh_currentpreset"):GetString())
    else
        self.SettingPicker:SetValue("default")
    end
end

function PANEL:SetEntities(entities)
    local entlist = {}
    EntsTable = table.Copy(entities)

    if not IsValid(selectedEntity) then
        self.EntityNameEnter:SetText("none")
        self.EntityNameEnter:SetEditable(false)
    else
        local entityinfo = FindEntityInfo(selectedEntity)

        if not entityinfo then
            Fallback = GetModelName(selectedEntity)
            self.EntityNameEnter:SetText(Fallback)
            self.EntityNameEnter:SetEditable(false)
        else
            Fallback = entityinfo.Name
            self.EntityNameEnter:SetText(entityinfo.Name)
            self.EntityNameEnter:SetEditable(true)
        end
    end

    for entity, value in pairs(EntsTable) do
        table.insert(entlist, value.Name)
    end

    self.EntityList:UpdateLines(entlist)
end

function PANEL:InitModifiers(list)
    ModifierList = table.Copy(list)
end

function PANEL:GetModifiers()
    return ModifierList
end

function PANEL:SetUsingWorld(set)
    UsingWorld = set
end

function PANEL:GetUsingWorld()
    return UsingWorld
end

function PANEL:UpdateColor(timelineinfo)
    PropertyTable = table.Copy(timelineinfo)
end

function PANEL:ButtonTimeline(add)
    if next(PropertyTable) == nil then return end

    if add and PropertyTable.Timelines < 10 then
        self:OnAddTimelineRequested()

    elseif add then return

    elseif PropertyTable.Timelines > 1 then
        self:OnRemoveTimelineRequested()
    end
end

function PANEL:ShowWorldSettings(console, push, release)
    self.ConsoleEnter:SetValue(console)
    self.ButtonPressEnter:SetValue(push)
    self.ButtonReleaseEnter:SetValue(release)
    self.WorldParent:SetVisible(true)
end

function PANEL:HideWorldSettings()
    self.WorldParent:SetVisible(false)
end

function PANEL:InitTimelineSettings()
    local value

    if ConVarExists("smh_currentpreset") then
        value = GetConVar("smh_currentpreset"):GetString()
    else
        value = "default"
    end

    local settings = SMH.Saves.GetPreferences(value)
    if not settings then value = "default" end
    self:SetSettings(settings, value)
end

function PANEL:ApplyName(ent, name) end
function PANEL:SelectEntity(entity) end
function PANEL:SelectWorld() end
function PANEL:OnAddTimelineRequested() end
function PANEL:OnRemoveTimelineRequested() end
function PANEL:OnUpdateModifierRequested(i, mod, check) end
function PANEL:OnUpdateKeyframeColorRequested(color, timeline) end
function PANEL:SetData(str, key) end
function PANEL:SetSettings(settings, presetname) end
function PANEL:SaveSettingsPreset(name) end

vgui.Register("SMHProperties", PANEL, "DFrame")
