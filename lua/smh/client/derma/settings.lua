local PANEL = {}

function PANEL:Init()

    local function CreateSettingChanger(name)
        return function(_self, value)
            if self._changingSettings then
                return
            end

            local updatedSettings = {
                [name] = value
            }
            self:OnSettingsUpdated(updatedSettings)
        end
    end

    local function CreateCheckBox(name, label)
        local cb = vgui.Create("DCheckBoxLabel", self)
        cb:SetText(label)
        cb:SizeToContents()
        cb.OnChange = CreateSettingChanger(name)
        return cb
    end

    local function CreateSlider(name, label, min, max, decimals)
        local slider = vgui.Create("DNumSlider", self)
        slider:SetMinMax(min, max)
        slider:SetDecimals(decimals)
        slider:SetText(label)
        slider.OnValueChanged = CreateSettingChanger(name)
        return slider
    end

    self:SetTitle("SMH Settings")
    self:SetDeleteOnClose(false)

    self.FreezeAll = CreateCheckBox("FreezeAll", "Freeze all")
    self.LocalizePhysBones = CreateCheckBox("LocalizePhysBones", "Localize phys bones")
    self.IgnorePhysBones = CreateCheckBox("IgnorePhysBones", "Don't animate phys bones")
    self.GhostPrevFrame = CreateCheckBox("GhostPrevFrame", "Ghost previous frame")
    self.GhostNextFrame = CreateCheckBox("GhostNextFrame", "Ghost next frame")
    self.GhostAllEntities = CreateCheckBox("GhostAllEntities", "Ghost all entities")
    self.TweenDisable = CreateCheckBox("TweenDisable", "Disable tweening")
    self.GhostTransparency = CreateSlider("GhostTransparency", "Ghost transparency", 0, 1, 2)

    self.HelpButton = vgui.Create("DButton", self)
    self.HelpButton:SetText("Help")
    self.HelpButton.DoClick = function()
        self:OnRequestOpenHelp()
    end

    self:SetSize(250, 225)

    self._changingSettings = false

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.FreezeAll:SetPos(5, 25)

    self.LocalizePhysBones:SetPos(5, 45)

    self.IgnorePhysBones:SetPos(5, 65)

    self.GhostPrevFrame:SetPos(5, 85)
    self.GhostNextFrame:SetPos(5, 105)
    self.GhostAllEntities:SetPos(5, 125)

    self.TweenDisable:SetPos(5, 145)

    self.GhostTransparency:SetPos(5, 165)
    self.GhostTransparency:SetSize(self:GetWide() - 5 - 5, 25)

    self.HelpButton:SetPos(5, 200)
    self.HelpButton:SetSize(self:GetWide() - 5 - 5, 20)

end

function PANEL:ApplySettings(settings)
    self._changingSettings = true

    local checkBoxes = {
        "FreezeAll",
        "LocalizePhysBones",
        "IgnorePhysBones",
        "GhostPrevFrame",
        "GhostNextFrame",
        "GhostAllEntities",
        "TweenDisable",
    }

    for _, key in pairs(checkBoxes) do
        if settings[key] ~= nil then
            self[key]:SetChecked(settings[key])
        end
    end

    if settings.GhostTransparency ~= nil then
        self.GhostTransparency:SetValue(settings.GhostTransparency)
    end

    self._changingSettings = false
end

function PANEL:OnSettingsUpdated(settings) end
function PANEL:OnRequestOpenHelp() end

vgui.Register("SMHSettings", PANEL, "DFrame")
