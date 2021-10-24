local WorldClicker = nil
local SaveMenu = nil
local LoadMenu = nil
local PropertiesMenu = nil

local FrameToKeyframe = {}
local KeyframePointers = {}
local KeyframeEasingData = {}
local ClickerEntity = nil

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
		
		for id, pointer in pairs(KeyframePointers) do
			if id == keyframeId + 1 then continue end
			if pointer:GetFrame() == frame then
				SMH.Controller.DeleteKeyframe(id)
			end
		end
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
		
		for id, pointer in pairs(KeyframePointers) do
			if id == keyframeId then continue end
			if pointer:GetFrame() == frame then
				SMH.Controller.DeleteKeyframe(id)
			end
		end
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
		LoadMenu:UpdateSelectedEnt(entity)
		PropertiesMenu:UpdateSelectedEnt(entity)
		ClickerEntity = entity
    end

    WorldClicker.MainMenu.OnRequestStateUpdate = function(_, newState)
        SMH.Controller.UpdateState(newState)
    end
    WorldClicker.MainMenu.OnRequestKeyframeUpdate = function(_, newKeyframeData)
        if FrameToKeyframe[SMH.State.Frame] then
            SMH.Controller.UpdateKeyframe(FrameToKeyframe[SMH.State.Frame], newKeyframeData)
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
	WorldClicker.Settings:SetPos(ScrW() - 250, ScrH() - 75 - 225)
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

function MGR.UpdateState(newState)
    WorldClicker.MainMenu:UpdatePositionLabel(newState.Frame, newState.PlaybackLength)
    WorldClicker.MainMenu.FramePanel:UpdateFrameCount(newState.PlaybackLength)
end

SMH.UI = MGR
