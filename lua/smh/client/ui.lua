local WorldClicker = nil
local SaveMenu = nil
local LoadMenu = nil
local PropertiesMenu = nil

local FrameToKeyframe = {}
local KeyframePointers = {}
local KeyframeEasingData = {}
local KeyframeIDs = {}
local SelectedPointers = {}
local OffsetPointers = {}
local LocalIDs = 0

local LastSelectedKeyframe = nil
local KeyColor = Color(0, 200, 0)

local ClickerEntity = nil

local function DeleteEmptyKeyframe(pointer)
    for id, kpointer in pairs(KeyframePointers) do
        if pointer == kpointer then
            if KeyframePointers[id] == LastSelectedKeyframe then LastSelectedKeyframe = nil end
            SelectedPointers[id] = nil
            WorldClicker.MainMenu.FramePanel:DeleteFramePointer(kpointer)
            KeyframePointers[id] = nil
            KeyframeEasingData[id] = nil

            for frame, kid in pairs(FrameToKeyframe) do
                if kid == id then
                    FrameToKeyframe[frame] = nil
                    break
                end
            end
        end
    end
end

local function CreateCopyPointer(keyframeId)
    OffsetPointers = {}
    local KeysToDelete = {}
    local originFrame = KeyframePointers[keyframeId]:GetFrame()

    local counter = 1

    for id, kpointer in pairs(KeyframePointers) do
        if id == keyframeId then continue end
        if SelectedPointers[id] then
            local difference = kpointer:GetFrame() - originFrame

            kpointer:SetSelected(false)
            SelectedPointers[id] = nil

            local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
            KeyColor,
            WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
            false
            )

            table.insert(OffsetPointers, pointer)
            pointer:SetFrame(originFrame + difference)
            pointer:SetSelected(true)

            pointer.OnPointerReleased = function(_, frame)
                WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
                if frame < 0 then return end

                for id, _ in pairs(kpointer:GetIDs()) do
                    SMH.Controller.CopyKeyframe(id, frame)
                end

                for id, pointer in pairs(KeyframePointers) do
                    if id == LocalIDs + counter then continue end
                    if pointer:GetFrame() == frame then
                        for mod, id in pairs(pointer:GetMods()) do
                            if not kpointer:GetMods()[mod] then
                                SMH.Controller.CopyKeyframe(id, frame)
                            end
                        end

                        for id, _ in pairs(pointer:GetIDs()) do
                            table.insert(KeysToDelete, id)
                        end
                    end
                end
            end
            counter = counter + 1
        end
    end

    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        KeyColor,
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )

    pointer:SetFrame(originFrame)
    local minimum, maximum = 0, 0
    for _, kpointer in ipairs(OffsetPointers) do
        kpointer:SetParentPointer(pointer)
        local difference = kpointer:GetFrame() - pointer:GetFrame()
        if minimum > difference then
            minimum = difference
        elseif maximum < difference then
            maximum = difference
        end
    end

    pointer:OnMousePressed(MOUSE_LEFT)
    pointer:SetOffsets(minimum, maximum)

    pointer.OnPointerReleased = function(_, frame)
        for _, kpointer in ipairs(OffsetPointers) do
            kpointer:OnPointerReleased(kpointer:GetFrame())
        end
        OffsetPointers = {}
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
        if frame < 0 then return end

        for id, mod in pairs(KeyframePointers[keyframeId]:GetIDs()) do
            SMH.Controller.CopyKeyframe(id, frame)
        end

        for id, pointer in pairs(KeyframePointers) do
            if id == LocalIDs + counter then continue end
            if pointer:GetFrame() == frame then
                for mod, id in pairs(pointer:GetMods()) do
                    if not KeyframePointers[keyframeId]:GetMods()[mod] then
                        SMH.Controller.CopyKeyframe(id, frame)
                    end
                end

                for id, _ in pairs(pointer:GetIDs()) do
                    table.insert(KeysToDelete, id)
                end
            end
        end
        for _, id in ipairs(KeysToDelete) do
            SMH.Controller.DeleteKeyframe(id)
        end
    end
end

local function NewKeyframePointer(keyframeId)

    local pointer = WorldClicker.MainMenu.FramePanel:CreateFramePointer(
        KeyColor,
        WorldClicker.MainMenu.FramePanel:GetTall() / 4 * 2.2,
        false
    )

    pointer.OnPointerReleased = function(_, frame)
        if frame < 0 then
            for id, _ in pairs(pointer:GetIDs()) do
                SMH.Controller.DeleteKeyframe(id)
            end
            return
        end

        for id, _ in pairs(pointer:GetIDs()) do
            SMH.Controller.UpdateKeyframe(id, { Frame = frame })
        end

        for id, kpointer in pairs(KeyframePointers) do
            if id == keyframeId then continue end

            if kpointer:GetFrame() == frame then
                for mod, id in pairs(kpointer:GetMods()) do
                    if not pointer:GetMods()[mod] then
                        pointer:AddID(id, mod)
                        KeyframeIDs[id] = KeyframeIDs[keyframeId]
                        kpointer:RemoveID(id)
                        if not next(kpointer:GetIDs()) then
                            DeleteEmptyKeyframe(kpointer)
                        end
                    end
                end

                for id, _ in pairs(kpointer:GetIDs()) do
                    SMH.Controller.DeleteKeyframe(id)
                end
            end
        end
    end

    pointer.OnCustomMousePressed = function(_, mousecode)
        local frame = pointer:GetFrame()

        if SelectedPointers[keyframeId] then
            pointer:SetSelected(false)
            if pointer == LastSelectedKeyframe then LastSelectedKeyframe = nil end
            SelectedPointers[keyframeId] = nil
        end

        if mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) then
            for id, kpointer in pairs(KeyframePointers) do
                if SelectedPointers[id] then
                    if kpointer == LastSelectedKeyframe then LastSelectedKeyframe = nil end
                    for id, _ in pairs(kpointer:GetIDs()) do
                        SMH.Controller.DeleteKeyframe(id)
                    end
                end
            end
            for id, _ in pairs(pointer:GetIDs()) do
                SMH.Controller.DeleteKeyframe(id)
            end
        elseif mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) then
            CreateCopyPointer(keyframeId)
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
                for id, mod in pairs(pointer:GetIDs()) do
                    SMH.Controller.UpdateKeyframe(id, newKeyframeData)
                end
                break
            end
        end
    end
    WorldClicker.MainMenu.OnRequestOpenPropertiesMenu = function()
        local frame = SMH.State.Frame

        PropertiesMenu:SetVisible(true)
        SMH.Controller.GetServerEntities()

        if FrameToKeyframe[frame] ~= nil and PropertiesMenu:GetUsingWorld() then
            SMH.Controller.RequestWorldData(frame)
        else
            PropertiesMenu:HideWorldSettings()
        end
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
    WorldClicker.Settings.OnRequestOpenPhysRecorder = function()
        WorldClicker.PhysRecorder:SetVisible(true)
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
        SMH.Controller.SpawnReset()
        WorldClicker.SpawnMenu:SetSaveFile(path)
    end
    LoadMenu.OnLoadRequested = function(_, path, modelName, loadFromClient)
        SMH.Controller.Load(path, modelName, loadFromClient)
    end
    LoadMenu.OnModelInfoRequested = function(_, path, modelName, loadFromClient)
        SMH.Controller.GetModelInfo(path, modelName, loadFromClient)
    end
    LoadMenu.OpenSpawnMenu = function()
        LoadMenu:Close()
        WorldClicker.SpawnMenu:SetVisible(true)
        SMH.Controller.SetSpawnGhost(true)
    end

    WorldClicker.SpawnMenu.OnClose = function()
        SMH.Controller.SetSpawnGhost(false)
    end
    WorldClicker.SpawnMenu.OnOriginRequested = function(_, path, model, loadFromClient)
        SMH.Controller.SetSpawnOrigin(path, model, loadFromClient)
    end
    WorldClicker.SpawnMenu.OnModelRequested = function(_, path, model, loadFromClient)
        SMH.Controller.SetPreviewEntity(path, model, loadFromClient)
    end
    WorldClicker.SpawnMenu.OnSpawnRequested = function(_, path, model, loadFromClient)
        SMH.Controller.SpawnEntity(path, model, loadFromClient)
    end
    WorldClicker.SpawnMenu.SetOffsetMode = function(_, set)
        SMH.Controller.SetSpawnOffsetMode(set)
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

    PropertiesMenu.SelectWorld = function()
        SMH.Controller.SelectEntity(LocalPlayer())
        LoadMenu:UpdateSelectedEnt(LocalPlayer())
        PropertiesMenu:UpdateSelectedEnt(LocalPlayer())
        ClickerEntity = LocalPlayer()
    end

    PropertiesMenu.SetData = function(_, str, key)
        SMH.Controller.UpdateWorld(str, key)
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
    WorldClicker.Settings:SetPos(ScrW() - 250, ScrH() - 90 - 290)
    WorldClicker.Settings:SetVisible(false)

    WorldClicker.PhysRecorder = vgui.Create("SMHPhysRecord", WorldClicker)
    WorldClicker.PhysRecorder:SetPos(ScrW() - 250 - 250, ScrH() - 90 - 150)
    WorldClicker.PhysRecorder:SetVisible(false)

    SaveMenu = vgui.Create("SMHSave")
    SaveMenu:MakePopup()
    SaveMenu:SetVisible(false)

    LoadMenu = vgui.Create("SMHLoad")
    LoadMenu:MakePopup()
    LoadMenu:SetVisible(false)

    WorldClicker.SpawnMenu = vgui.Create("SMHSpawn", WorldClicker)
    WorldClicker.SpawnMenu:SetPos(0, ScrH() - 405 - 90)
    WorldClicker.SpawnMenu:SetVisible(false)

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

    if not PropertiesMenu:GetUsingWorld() then
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
    SelectedPointers = {}
    KeyframeIDs = {}
    LastSelectedKeyframe = nil

    if not PropertiesMenu:GetUsingWorld() then
        for _, keyframe in pairs(keyframes) do
            if Modifiers[keyframe.Modifier] then
                if not FrameToKeyframe[keyframe.Frame] then
                    KeyframePointers[LocalIDs] = NewKeyframePointer(LocalIDs)
                    KeyframePointers[LocalIDs]:SetFrame(keyframe.Frame)
                    KeyframePointers[LocalIDs]:AddID(keyframe.ID, keyframe.Modifier)
                    FrameToKeyframe[keyframe.Frame] = LocalIDs
                    KeyframeEasingData[LocalIDs] = {
                        EaseIn = keyframe.EaseIn,
                        EaseOut = keyframe.EaseOut,
                    }
                    KeyframeIDs[keyframe.ID] = LocalIDs
                    LocalIDs = LocalIDs + 1
                else
                    local pointer = KeyframePointers[FrameToKeyframe[keyframe.Frame]]
                    pointer:AddID(keyframe.ID, keyframe.Modifier)
                    KeyframeIDs[keyframe.ID] = FrameToKeyframe[keyframe.Frame]
                end
            end
        end
    else
        for _, keyframe in pairs(keyframes) do
            if not FrameToKeyframe[keyframe.Frame] then
                KeyframePointers[LocalIDs] = NewKeyframePointer(LocalIDs)
                KeyframePointers[LocalIDs]:SetFrame(keyframe.Frame)
                KeyframePointers[LocalIDs]:AddID(keyframe.ID, keyframe.Modifier)
                FrameToKeyframe[keyframe.Frame] = LocalIDs
                KeyframeEasingData[LocalIDs] = {
                    EaseIn = keyframe.EaseIn,
                    EaseOut = keyframe.EaseOut,
                }
                KeyframeIDs[keyframe.ID] = LocalIDs
                LocalIDs = LocalIDs + 1
            else
                local pointer = KeyframePointers[FrameToKeyframe[keyframe.Frame]]
                pointer:AddID(keyframe.ID, keyframe.Modifier)
                KeyframeIDs[keyframe.ID] = FrameToKeyframe[keyframe.Frame]
            end
        end
    end
end

function MGR.UpdateKeyframe(keyframe)
    if not KeyframeIDs[keyframe.ID] then
        if not FrameToKeyframe[keyframe.Frame] then
            KeyframePointers[LocalIDs] = NewKeyframePointer(LocalIDs)
            KeyframePointers[LocalIDs]:AddID(keyframe.ID, keyframe.Modifier)
            KeyframeIDs[keyframe.ID] = LocalIDs
            LocalIDs = LocalIDs + 1
        else
            local pointer = KeyframePointers[FrameToKeyframe[keyframe.Frame]]
            pointer:AddID(keyframe.ID, keyframe.Modifier)
            KeyframeIDs[keyframe.ID] = FrameToKeyframe[keyframe.Frame]
        end
        -- TODO should this logic exist? Where should it be?
        -- if FrameToKeyframe[keyframe.Frame] and KeyframePointers[FrameToKeyframe[keyframe.Frame]] then
        --     local pointer = KeyframePointers[FrameToKeyframe[keyframe.Frame]]
        --     KeyframePointers[FrameToKeyframe[keyframe.Frame]] = nil
        --     WorldClicker.MainMenu.FramePanel:DeleteFramePointer(pointer)
        -- end
    end

    KeyframeEasingData[KeyframeIDs[keyframe.ID]] = {
        EaseIn = keyframe.EaseIn,
        EaseOut = keyframe.EaseOut,
    }

    KeyframePointers[KeyframeIDs[keyframe.ID]]:SetFrame(keyframe.Frame)

    for frame, kid in pairs(FrameToKeyframe) do
        if kid == KeyframeIDs[keyframe.ID] then
            FrameToKeyframe[frame] = nil
            break
        end
    end
    FrameToKeyframe[keyframe.Frame] = KeyframeIDs[keyframe.ID]
    if keyframe.Frame == SMH.State.Frame then
        WorldClicker.MainMenu:ShowEasingControls(keyframe.EaseIn, keyframe.EaseOut)
    end
end

function MGR.DeleteKeyframe(keyframeId)
    if not KeyframeIDs[keyframeId] then return end

    KeyframePointers[KeyframeIDs[keyframeId]]:RemoveID(keyframeId)

    if not next(KeyframePointers[KeyframeIDs[keyframeId]]:GetIDs()) then
        if KeyframePointers[KeyframeIDs[keyframeId]] == LastSelectedKeyframe then LastSelectedKeyframe = nil end
        SelectedPointers[KeyframeIDs[keyframeId]] = nil
        WorldClicker.MainMenu.FramePanel:DeleteFramePointer(KeyframePointers[KeyframeIDs[keyframeId]])
        KeyframePointers[KeyframeIDs[keyframeId]] = nil
        KeyframeEasingData[KeyframeIDs[keyframeId]] = nil

        for frame, kid in pairs(FrameToKeyframe) do
            if kid == KeyframeIDs[keyframeId] then
                if frame == SMH.State.Frame then
                    WorldClicker.MainMenu:HideEasingControls()
                end
                FrameToKeyframe[frame] = nil
                break
            end
        end
    end

    KeyframeIDs[keyframeId] = nil
end

function MGR.SetOffsets(pointer)
    local minimum, maximum = 0, 0
    for id, kpointer in pairs(KeyframePointers) do
        if SelectedPointers[id] then
            local difference = kpointer:GetFrame() - pointer:GetFrame()
            if minimum > difference then
                minimum = difference
            elseif maximum < difference then
                maximum = difference
            end
        end
    end
    pointer:SetOffsets(minimum, maximum)
end

function MGR.MoveChildren(pointer, frame)
    if next(OffsetPointers) then
        for _, kpointer in ipairs(OffsetPointers) do
            local difference = kpointer:GetFrame() - pointer:GetFrame()
            kpointer:SetFrame(frame + difference)
        end
    else
        for id, kpointer in pairs(KeyframePointers) do
            if kpointer:GetParentKeyframe() == pointer then
                kpointer:SetFrame(frame)
            end
            if kpointer == pointer then continue end
            if SelectedPointers[id] then
                local difference = kpointer:GetFrame() - pointer:GetFrame()
                kpointer:SetFrame(frame + difference)
            end
        end
    end
end

function MGR.ClearFrames(pointer)
    for id, kpointer in pairs(KeyframePointers) do
        if kpointer:GetParentKeyframe() == pointer then
            kpointer:OnPointerReleased(kpointer:GetFrame())
            kpointer:ClearParentPointer()
        end
        if kpointer == pointer then continue end
        if SelectedPointers[id] then
            kpointer:OnPointerReleased(kpointer:GetFrame())
        end
    end
end

function MGR.ClearAllSelected()
    for id, pointer in pairs(KeyframePointers) do
        if SelectedPointers[id] then
            pointer:SetSelected(false)
        end
    end
    LastSelectedKeyframe = nil
    SelectedPointers = {}
end

function MGR.ShiftSelect(pointer)
    if not LastSelectedKeyframe then 
        MGR.ToggleSelect(pointer) 
        return
    end

    local minimum, maximum = 0, 0
    if pointer:GetFrame() > LastSelectedKeyframe:GetFrame() then
        minimum, maximum = LastSelectedKeyframe:GetFrame(), pointer:GetFrame()
    else
        minimum, maximum = pointer:GetFrame(), LastSelectedKeyframe:GetFrame()
    end

    for id, kpointer in pairs(KeyframePointers) do
        if kpointer:GetFrame() >= minimum and kpointer:GetFrame() <= maximum then
            SelectedPointers[id] = true
            kpointer:SetSelected(true)
        end
    end

    LastSelectedKeyframe = pointer
end

function MGR.ToggleSelect(pointer)
    local selected = not pointer:GetSelected()
    local frame = pointer:GetFrame()
    for id, kpointer in pairs(KeyframePointers) do
        if kpointer ~= pointer then continue end
        if selected then
            LastSelectedKeyframe = kpointer
            for id, kpointer in pairs(KeyframePointers) do
                if kpointer:GetFrame() == frame then
                    SelectedPointers[id] = true
                    kpointer:SetSelected(selected)
                end
            end
        else
            if kpointer == LastSelectedKeyframe then LastSelectedKeyframe = nil end
            for id, kpointer in pairs(KeyframePointers) do
                if kpointer:GetFrame() == frame then
                    SelectedPointers[id] = nil
                    kpointer:SetSelected(selected)
                end
            end
        end
        break
    end
    for id, kpointer in pairs(KeyframePointers) do
        if kpointer == pointer then continue end
        if kpointer == LastSelectedKeyframe then LastSelectedKeyframe = nil end
    end
end

function MGR.SetServerSaves(saves)
    LoadMenu:SetSaves(saves)
    SaveMenu:SetSaves(saves)
end

function MGR.SetModelList(models, map)
    LoadMenu:SetEntities(models, map)
    WorldClicker.SpawnMenu:SetEntities(models)
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

function MGR.SetUsingWorld(set)
    PropertiesMenu:SetUsingWorld(set)
    if set then
        WorldClicker.MainMenu:HideEasingControls()
    else
        PropertiesMenu:HideWorldSettings()
    end
end

function MGR.SetWorldData(console, push, release)
    PropertiesMenu:ShowWorldSettings(console, push, release)
end

SMH.UI = MGR
