local WorldClicker = nil
local SaveMenu = nil
local LoadMenu = nil

local FrameToKeyframe = {}
local KeyframePointers = {}
local KeyframeEasingData = {}

local function CreateCopyPointer(keyframeId)
    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        Color(0, 200, 0),
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )
    pointer:OnMousePressed(MOUSE_LEFT)
    pointer.OnPointerReleased = function(_, frame)
        SMH.Controller.CopyKeyframe(keyframeId, frame)
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
    end
end

local function NewKeyframePointer(keyframeId)
    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        Color(0, 200, 0),
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )

    pointer.OnPointerReleased = function(_, frame)
        SMH.Controller.UpdateKeyframe(keyframeId, { Frame = frame })
    end
    pointer.OnCustomMousePressed = function(_, mousecode)
        if mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) then
            SMH.Controller.DeleteKeyframe(keyframeId)
        elseif mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) then
            CreateCopyPointer(keyframeId)
        end
    end

    return pointer
end

local function AddCallbacks()

    WorldClicker.OnEntitySelected = function(_, entity)
        SMH.Controller.SelectEntity(entity)
    end

    WorldClicker.MainMenu.OnRequestStateUpdate = function(_, newState)
        SMH.Controller.UpdateState(newState)
    end
    WorldClicker.MainMenu.OnRequestKeyframeUpdate = function(_, newKeyframeData)
        if FrameToKeyframe[SMH.State.Frame] then
            SMH.Controller.UpdateKeyframe(FrameToKeyframe[SMH.State.Frame], newKeyframeData)
        end
    end
    WorldClicker.MainMenu.OnRequestRecord = function()
        SMH.Controller.Record()
    end
    WorldClicker.MainMenu.OnRequestOpenSaveMenu = function()
        SaveMenu:SetVisible(true)
    end
    WorldClicker.MainMenu.OnRequestOpenLoadMenu = function()
        LoadMenu:SetVisible(true)
    end
    WorldClicker.MainMenu.OnRequestOpenSettings = function()
        WorldClicker.Settings:SetVisible(true)
    end

    WorldClicker.MainMenu.FramePanel.OnFramePressed = function(_, frame)
        SMH.Controller.SetFrame(frame)
    end

    WorldClicker.MainMenu.FramePointer.OnFrameChanged = function(_, newFrame)
        SMH.Controller.SetFrame(newFrame)
    end

    WorldClicker.Settings.OnSettingsUpdated = function(_, newSettings)
        SMH.Controller.UpdateSettings(newSettings)
    end

    SaveMenu.OnSaveRequested = function(_, path, saveToClient)
        SMH.Controller.Save(path, saveToClient)
    end
    SaveMenu.OnDeleteRequested = function(_, path)
        SMH.Controller.DeleteSave(path)
    end

    LoadMenu.OnLoadRequested = function(_, path, modelName, loadFromClient)
        SMH.Controller.Load(path, modelName, loadFromClient)
    end

end

hook.Add("InitPostEntity", "SMHMenuSetup", function()

    WorldClicker = vgui.Create("SMHWorldClicker")

    WorldClicker.MainMenu = vgui.Create("SMHMenu", WorldClicker)

    WorldClicker.Settings = vgui.Create("SMHSettings", WorldClicker)
	WorldClicker.Settings:SetPos(ScrW() - 165, ScrH() - 275)
	WorldClicker.Settings:SetVisible(false)

    SaveMenu = vgui.Create("SMHSave")
	SaveMenu:MakePopup()
	SaveMenu:SetVisible(false)

    LoadMenu = vgui.Create("SMHLoad")
	LoadMenu:MakePopup()
	LoadMenu:SetVisible(false)

    AddCallbacks()
	
	WorldClicker.MainMenu:UpdateState(SMH.State)
    
end)

local MGR = {}

function MGR.IsOpen()
    return WorldClicker:IsVisible()
end

function MGR.Open()
    WorldClicker:SetVisible(true)
end

function MGR.Close()
    WorldClicker:SetVisible(false)
end

function MGR.SetFrame(frame)
    if not WorldClicker.MainMenu.FramePointer:IsDragging() then
        WorldClicker.MainMenu.FramePointer:SetFrame(frame)
    end
	WorldClicker.MainMenu:UpdatePositionLabel(frame, SMH.State.PlaybackLength)
end

function MGR.SetKeyframes(keyframes)
    for _, pointer in pairs(KeyframePointers) do
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
    end
    KeyframePointers = {}
    FrameToKeyframe = {}

    for _, keyframe in pairs(keyframes) do
        KeyframePointers[keyframe.ID] = NewKeyframePointer(keyframe.ID)
        KeyframePointers[keyframe.ID]:SetFrame(keyframe.Frame)
        FrameToKeyframe[keyframe.Frame] = keyframe.ID
        KeyframeEasingData[keyframe.ID] = {
            EaseIn = keyframe.EaseIn,
            EaseOut = keyframe.EaseOut,
        }
    end
end

function MGR.UpdateKeyframe(keyframe)
    KeyframeEasingData[keyframe.ID] = {
        EaseIn = keyframe.EaseIn,
        EaseOut = keyframe.EaseOut,
    }

    if not KeyframePointers[keyframe.ID] then
        KeyframePointers[keyframe.ID] = NewKeyframePointer(keyframe.ID)

        -- TODO should this logic exist? Where should it be?
        -- if FrameToKeyframe[keyframe.Frame] and KeyframePointers[FrameToKeyframe[keyframe.Frame]] then
        --     local pointer = KeyframePointers[FrameToKeyframe[keyframe.Frame]]
        --     KeyframePointers[FrameToKeyframe[keyframe.Frame]] = nil
        --     WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
        -- end
        
    end

    KeyframePointers[keyframe.ID]:SetFrame(keyframe.Frame)

    for frame, kid in pairs(FrameToKeyframe) do
        if kid == keyframe.ID then
            FrameToKeyframe[frame] = nil
            break
        end
    end
    FrameToKeyframe[keyframe.Frame] = keyframe.ID
end

function MGR.DeleteKeyframe(keyframeId)
    if not KeyframePointers[keyframeId] then
        return
    end

    WorldClicker.MainMenu.FramePanel:DeleteFramePointer(KeyframePointers[keyframeId])
    KeyframePointers[keyframeId] = nil
    KeyframeEasingData[keyframeId] = nil

    for frame, kid in pairs(FrameToKeyframe) do
        if kid == keyframeId then
            FrameToKeyframe[frame] = nil
            break
        end
    end
end

function MGR.SetServerSaves(saves)
    LoadMenu:SetSaves(saves)
    SaveMenu:SetSaves(saves)
end

function MGR.SetModelList(models)
    LoadMenu:SetEntities(models)
end

function MGR.AddSaveFile(path)
    SaveMenu:AddSave(path)
end

SMH.UI = MGR
