local WorldClicker = nil
local SaveMenu = nil
local LoadMenu = nil
local PropertiesMenu = nil

local FrameToKeyframe = {}
local KeyframePointers = {}
local KeyframeEasingData = {}
local LastID = 0
local ClickerEntity = nil
local KeyColor = Color(0, 200, 0)

local function CreateCopyPointer(keyframeId, mods)
    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        KeyColor,
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )
    pointer:OnMousePressed(MOUSE_LEFT)
    pointer.OnPointerReleased = function(_, frame)
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
        local counter = 1
        for mod, idm in pairs(mods) do
            SMH.Controller.CopyKeyframe(idm, frame)

            for id, pointer in pairs(KeyframePointers) do
                if id == LastID + counter then continue end
                if pointer:GetFrame() == frame and mod == pointer:GetMod() then
                    SMH.Controller.DeleteKeyframe(id)
                end
            end
            counter = counter + 1
        end
    end
end

local function NewKeyframePointer(keyframeId, modname)
    if keyframeId > LastID then LastID = keyframeId end

    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        KeyColor,
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )
    pointer:SetMod(modname)

    pointer.OnPointerReleased = function(_, frame)
        SMH.Controller.UpdateKeyframe(keyframeId, { Frame = frame })
        for id, pointer in pairs(KeyframePointers) do
            if id == keyframeId then continue end
            if pointer:GetFrame() == frame and pointer:GetMod() == modname then
                SMH.Controller.DeleteKeyframe(id)
            end
        end
    end
    pointer.OnCustomMousePressed = function(_, mousecode)
        local frame = pointer:GetFrame()
        if mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) then
            for id, kpointer in pairs(KeyframePointers) do
                if kpointer:GetFrame() == frame then
                    SMH.Controller.DeleteKeyframe(id)
                end
            end
        elseif mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) then
            local mods = {}
            for id, kpointer in pairs(KeyframePointers) do
                if kpointer:GetFrame() == frame then
                    mods[kpointer:GetMod()] = id
                end
            end
            CreateCopyPointer(keyframeId, mods)
        end
    end

    return pointer
end

local function AddCallbacks()

    WorldClicker.OnEntitySelected = function(_, entity)
        SMH.Controller.SelectEntity(entity)
        LoadMenu:UpdateSelectedEnt(entity)
        PropertiesMenu:UpdateSelectedEnt(entity)
        ClickerEntity = entity
    end

    WorldClicker.MainMenu.OnRequestStateUpdate = function(_, newState)
        SMH.Controller.UpdateState(newState)
    end
    WorldClicker.MainMenu.OnRequestKeyframeUpdate = function(_, newKeyframeData)
        for id, pointer in pairs(KeyframePointers) do
            if pointer:GetFrame() == SMH.State.Frame then
                SMH.Controller.UpdateKeyframe(id, newKeyframeData)
            end
        end
    end
    WorldClicker.MainMenu.OnRequestOpenPropertiesMenu = function()
        PropertiesMenu:SetVisible(true)
        SMH.Controller.GetServerEntities()
    end
    WorldClicker.MainMenu.OnRequestRecord = function()
        SMH.Controller.Record()
    end
    WorldClicker.MainMenu.OnRequestOpenSaveMenu = function()
        SaveMenu:SetVisible(true)
        SMH.Controller.GetServerSaves()
    end
    WorldClicker.MainMenu.OnRequestOpenLoadMenu = function()
        LoadMenu:SetVisible(true)
        SMH.Controller.GetServerSaves()
    end
    WorldClicker.MainMenu.OnRequestOpenSettings = function()
        WorldClicker.Settings:ApplySettings(SMH.Settings.GetAll())
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
        local ghoststuff = {
            GhostPrevFrame = true,
            GhostNextFrame = true,
            OnionSkin = true,
            GhostAllEntities = true,
            GhostTransparency = true,
        }
        for name, value in pairs(newSettings) do
            if ghoststuff[name] then
                SMH.Controller.UpdateGhostState()
                break
            end
        end
    end
    WorldClicker.Settings.OnRequestOpenHelp = function()
        SMH.Controller.OpenHelp()
    end

    SaveMenu.OnSaveRequested = function(_, path, saveToClient)
        SMH.Controller.Save(path, saveToClient)
    end
    SaveMenu.OnDeleteRequested = function(_, path, deleteFromClient)
        SMH.Controller.DeleteSave(path, deleteFromClient)
    end

    LoadMenu.OnModelListRequested = function(_, path, loadFromClient)
        SMH.Controller.GetModelList(path, loadFromClient)
    end
    LoadMenu.OnLoadRequested = function(_, path, modelName, loadFromClient)
        SMH.Controller.Load(path, modelName, loadFromClient)
    end
    LoadMenu.OnModelInfoRequested = function(_, path, modelName, loadFromClient)
        SMH.Controller.GetModelInfo(path, modelName, loadFromClient)
    end

    PropertiesMenu.ApplyName = function(_, ent, name)
        SMH.Controller.ApplyEntityName(ent, name)
    end

    PropertiesMenu.SelectEntity = function(_, ent)
        SMH.Controller.SelectEntity(ent)
        LoadMenu:UpdateSelectedEnt(ent)
        PropertiesMenu:UpdateSelectedEnt(ent)
        ClickerEntity = ent
    end

    PropertiesMenu.OnAddTimelineRequested = function()
        SMH.Controller.AddTimeline()
    end
    
    PropertiesMenu.OnRemoveTimelineRequested = function()
        SMH.Controller.RemoveTimeline()
    end

    PropertiesMenu.OnUpdateModifierRequested = function(_, i, mod, check)
        SMH.Controller.UpdateModifier(i, mod, check)
    end

    PropertiesMenu.OnUpdateKeyframeColorRequested = function(_, color, timeline)
        SMH.Controller.UpdateKeyframeColor(color, timeline)
    end

end

hook.Add("EntityRemoved", "SMHWorldClickerEntityRemoved", function(entity)

    if entity == ClickerEntity then
        WorldClicker:OnEntitySelected(nil)
    end

end)

hook.Add("InitPostEntity", "SMHMenuSetup", function()

    WorldClicker = vgui.Create("SMHWorldClicker")

    WorldClicker.MainMenu = vgui.Create("SMHMenu", WorldClicker)

    WorldClicker.Settings = vgui.Create("SMHSettings", WorldClicker)
    WorldClicker.Settings:SetPos(ScrW() - 250, ScrH() - 90 - 225)
    WorldClicker.Settings:SetVisible(false)

    SaveMenu = vgui.Create("SMHSave")
    SaveMenu:MakePopup()
    SaveMenu:SetVisible(false)

    LoadMenu = vgui.Create("SMHLoad")
    LoadMenu:MakePopup()
    LoadMenu:SetVisible(false)

    PropertiesMenu = vgui.Create("SMHProperties")
    PropertiesMenu:MakePopup()
    PropertiesMenu:SetVisible(false)

    AddCallbacks()

    SMH.Controller.RequestModifiers() -- needed to initialize properties menu

    WorldClicker.MainMenu:SetInitialState(SMH.State)

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

    if FrameToKeyframe[frame] ~= nil then
        local data = KeyframeEasingData[FrameToKeyframe[frame]]
        if data then
            WorldClicker.MainMenu:ShowEasingControls(data.EaseIn, data.EaseOut)
        else
            WorldClicker.MainMenu:ShowEasingControls(0, 0)
        end
    else
        WorldClicker.MainMenu:HideEasingControls()
    end
end

function MGR.SetKeyframes(keyframes)
    for _, pointer in pairs(KeyframePointers) do
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
    end

    local propertymods = PropertiesMenu:GetCurrentModifiers()

    if not propertymods.KeyColor then
        KeyColor = Color(0, 200, 0)
    else
        KeyColor = propertymods.KeyColor
    end

    local Modifiers = {}
    for _, name in ipairs(propertymods) do
        Modifiers[name] = true
    end
    KeyframePointers = {}
    FrameToKeyframe = {}

    for _, keyframe in pairs(keyframes) do
        if Modifiers[keyframe.Modifier] then
            KeyframePointers[keyframe.ID] = NewKeyframePointer(keyframe.ID, keyframe.Modifier)
            KeyframePointers[keyframe.ID]:SetFrame(keyframe.Frame)
            FrameToKeyframe[keyframe.Frame] = keyframe.ID
            KeyframeEasingData[keyframe.ID] = {
                EaseIn = keyframe.EaseIn,
                EaseOut = keyframe.EaseOut,
            }
        end
    end
end

function MGR.UpdateKeyframe(keyframe)
    KeyframeEasingData[keyframe.ID] = {
        EaseIn = keyframe.EaseIn,
        EaseOut = keyframe.EaseOut,
    }

    if not KeyframePointers[keyframe.ID] then
        KeyframePointers[keyframe.ID] = NewKeyframePointer(keyframe.ID, keyframe.Modifier)

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

function MGR.AssignFrames(pointer)
    local frame = pointer:GetFrame()
    local keyID
    for id, kpointer in pairs(KeyframePointers) do
        if pointer == kpointer then
            keyID = id
            break
        end
    end

    if not keyID then return end

    for id, kpointer in pairs(KeyframePointers) do
        if keyID == id then continue end
        if kpointer:GetFrame() == frame then
            kpointer:SetParentPointer(pointer)
        end
    end
end

function MGR.MoveChildren(pointer, frame)
    for id, kpointer in pairs(KeyframePointers) do
        if kpointer:GetParentKeyframe() == pointer then
            kpointer:SetFrame(frame)
        end
    end
end

function MGR.ClearFrames(pointer)
    for id, kpointer in pairs(KeyframePointers) do
        if kpointer:GetParentKeyframe() == pointer then
            kpointer:OnPointerReleased(kpointer:GetFrame())
            kpointer:ClearParentPointer()
        end
    end
end

function MGR.SetServerSaves(saves)
    LoadMenu:SetSaves(saves)
    SaveMenu:SetSaves(saves)
end

function MGR.SetModelList(models, map)
    LoadMenu:SetEntities(models, map)
end

function MGR.SetEntityList(entities)
    PropertiesMenu:SetEntities(entities)
end

function MGR.SetModelName(name)
    LoadMenu:SetModelName(name)
end

function MGR.UpdateName(name)
    PropertiesMenu:SetName(name)
end

function MGR.AddSaveFile(path)
    SaveMenu:AddSave(path)
end

function MGR.RemoveSaveFile(path)
    SaveMenu:RemoveSave(path)
end

function MGR.InitModifiers(list)
    PropertiesMenu:InitModifiers(list)
end

function MGR.SetTimeline(timeline)
    WorldClicker.MainMenu:UpdateTimelines(timeline)
    PropertiesMenu:UpdateTimelineInfo(timeline)
end

function MGR.UpdateState(newState)
    WorldClicker.MainMenu:UpdatePositionLabel(newState.Frame, newState.PlaybackLength)
    WorldClicker.MainMenu.FramePanel:UpdateFrameCount(newState.PlaybackLength)
end

function MGR.UpdateModifier(timelineinfo, changed)
    PropertiesMenu:UpdateModifiersInfo(timelineinfo, changed)
end

function MGR.UpdateKeyColor(timelineinfo)
    PropertiesMenu:UpdateColor(timelineinfo)
end

function MGR.PaintKeyframes(color)
    KeyColor = color

    for _, pointer in pairs(KeyframePointers) do
        pointer.Color = KeyColor
    end
end

function MGR.GetModifiers()
    return PropertiesMenu:GetModifiers()
end

SMH.UI = MGR
