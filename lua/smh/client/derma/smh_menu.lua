local PANEL = {}

function PANEL:Init()

    self:SetTitle("Stop Motion Helper")
    self:SetSize(ScrW(), 75)
    self:SetPos(0, ScrH() - self:GetTall())
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetDeleteOnClose(false)
    self:ShowCloseButton(false)

    self._sendKeyframeChanges = true

    self.FramePanel = vgui.Create("SMHFramePanel", self)

    self.FramePointer = self.FramePanel:CreateFramePointer(Color(255, 255, 255), self.FramePanel:GetTall() / 4, true)
    
    self.PositionLabel = vgui.Create("DLabel", self)

    self.PlaybackRateControl = vgui.Create("DNumberWang", self)
    self.PlaybackRateControl:SetMinMax(1, 216000)
    self.PlaybackRateControl:SetDecimals(0)
    self.PlaybackRateControl.OnValueChanged = function(_, value)
        self:OnRequestStateUpdate({ PlaybackRate = tonumber(value) })
    end
    self.PlaybackRateControl.Label = vgui.Create("DLabel", self)
    self.PlaybackRateControl.Label:SetText("Framerate")
    self.PlaybackRateControl.Label:SizeToContents()
    
    self.PlaybackLengthControl = vgui.Create("DNumberWang", self)
    self.PlaybackLengthControl:SetMinMax(1, 999)
    self.PlaybackLengthControl:SetDecimals(0)
    self.PlaybackLengthControl.OnValueChanged = function(_, value)
        self:OnRequestStateUpdate({ PlaybackLength = tonumber(value) })
    end
    self.PlaybackLengthControl.Label = vgui.Create("DLabel", self)
    self.PlaybackLengthControl.Label:SetText("Frame count")
    self.PlaybackLengthControl.Label:SizeToContents()
    
    self.Easing = vgui.Create("Panel", self)
    
    self.EaseInControl = vgui.Create("DNumberWang", self.Easing)
    self.EaseInControl:SetNumberStep(0.1)
    self.EaseInControl:SetMinMax(0, 1)
    self.EaseInControl:SetDecimals(1)
    self.EaseInControl.OnValueChanged = function(_, value)
        if self._sendKeyframeChanges then
            self:OnRequestKeyframeUpdate({ EaseIn = tonumber(value) })
        end
    end
    self.EaseInControl.Label = vgui.Create("DLabel", self.Easing)
    self.EaseInControl.Label:SetText("Ease in")
    self.EaseInControl.Label:SizeToContents()
    
    self.EaseOutControl = vgui.Create("DNumberWang", self.Easing)
    self.EaseOutControl:SetNumberStep(0.1)
    self.EaseOutControl:SetMinMax(0, 1)
    self.EaseOutControl:SetDecimals(1)
    self.EaseOutControl.OnValueChanged = function(_, value)
        if self._sendKeyframeChanges then
            self:OnRequestKeyframeUpdate({ EaseOut = tonumber(value) })
        end
    end
    self.EaseOutControl.Label = vgui.Create("DLabel", self.Easing)
    self.EaseOutControl.Label:SetText("Ease out")
    self.EaseOutControl.Label:SizeToContents()
    
    self.RecordButton = vgui.Create("DButton", self)
    self.RecordButton:SetText("Record")
    self.RecordButton.DoClick = function() self:OnRequestRecord() end
    
    self.SaveButton = vgui.Create("DButton", self)
    self.SaveButton:SetText("Save")
    self.SaveButton.DoClick = function() self:OnRequestOpenSaveMenu() end
    
    self.LoadButton = vgui.Create("DButton", self)
    self.LoadButton:SetText("Load")
    self.LoadButton.DoClick = function() self:OnRequestOpenLoadMenu() end
    
    self.SettingsButton = vgui.Create("DButton", self)
    self.SettingsButton:SetText("Settings")
    self.SettingsButton.DoClick = function() self:OnRequestOpenSettings() end
    
    self.Easing:SetVisible(false)

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self:SetTitle("Stop Motion Helper")

    self.FramePanel:SetPos(5, 25)
    self.FramePanel:SetSize(width - 5 * 2, 45)

    self.FramePointer.VerticalPosition = self.FramePanel:GetTall() / 4

    self.PositionLabel:SetPos(150, 5)

    self.PlaybackRateControl:SetPos(340, 2)
    self.PlaybackRateControl:SetSize(50, 20)
    local sizeX, sizeY = self.PlaybackRateControl.Label:GetSize()
    self.PlaybackRateControl.Label:SetRelativePos(self.PlaybackRateControl, -(sizeX) - 5, 3)

    self.PlaybackLengthControl:SetPos(460, 2)
    self.PlaybackLengthControl:SetSize(50, 20)
    sizeX, sizeY = self.PlaybackLengthControl.Label:GetSize()
    self.PlaybackLengthControl.Label:SetRelativePos(self.PlaybackLengthControl, -(sizeX) - 5, 3)

    self.Easing:SetPos(540, 0)
    self.Easing:SetSize(250, 30)

    self.EaseInControl:SetPos(60, 2)
    self.EaseInControl:SetSize(50, 20)
    sizeX, sizeY = self.EaseInControl.Label:GetSize()
    self.EaseInControl.Label:SetRelativePos(self.EaseInControl, -(sizeX) - 5, 3)

    self.EaseOutControl:SetPos(160, 2)
    self.EaseOutControl:SetSize(50, 20)
    sizeX, sizeY = self.EaseOutControl.Label:GetSize()
    self.EaseOutControl.Label:SetRelativePos(self.EaseOutControl, -(sizeX) - 5, 3)

    self.RecordButton:SetPos(width - 60 * 4 - 5 * 4, 2)
    self.RecordButton:SetSize(60, 20)

    self.SaveButton:SetPos(width - 60 * 3 - 5 * 3, 2)
    self.SaveButton:SetSize(60, 20)

    self.LoadButton:SetPos(width - 60 * 2 - 5 * 2, 2)
    self.LoadButton:SetSize(60, 20)

    self.SettingsButton:SetPos(width - 60 * 1 - 5 * 1, 2)
    self.SettingsButton:SetSize(60, 20)

end

function PANEL:SetInitialState(state)
    self.PlaybackRateControl:SetValue(state.PlaybackRate)
    self.PlaybackLengthControl:SetValue(state.PlaybackLength)
    self:UpdatePositionLabel(state.Frame, state.PlaybackLength)
end

function PANEL:UpdatePositionLabel(frame, totalFrames)
    self.PositionLabel:SetText("Position: " .. frame .. " / " .. totalFrames)
    self.PositionLabel:SizeToContents()
end

function PANEL:ShowEasingControls(easeIn, easeOut)
    self._sendKeyframeChanges = false
    self.EaseInControl:SetValue(easeIn)
    self.EaseOutControl:SetValue(easeOut)
    self.Easing:SetVisible(true)
    self._sendKeyframeChanges = true
end

function PANEL:HideEasingControls()
    self.Easing:SetVisible(false)
end

function PANEL:OnRequestStateUpdate(newState) end
function PANEL:OnRequestKeyframeUpdate(newKeyframeData) end
function PANEL:OnRequestRecord() end
function PANEL:OnRequestOpenSaveMenu() end
function PANEL:OnRequestOpenLoadMenu() end
function PANEL:OnRequestOpenSettings() end

vgui.Register("SMHMenu", PANEL, "DFrame")
