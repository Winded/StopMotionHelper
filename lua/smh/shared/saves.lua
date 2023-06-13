local function GetModelName(entity, usedModelNames)
    local mdl = string.Split(entity:GetModel(), "/");
    mdl = mdl[#mdl];

    return mdl
end

local SaveDir = "smh/"
local SettingsDir = "smhsettings/"

local MGR = {}

function MGR.ListFiles()
    local files, dirs = file.Find(SaveDir .. "*.txt", "DATA")

    local saves = {}
    for _, file in pairs(files) do
        table.insert(saves, file:sub(1, -5))
    end

    return saves
end

function MGR.ListSettings()
    local files, dirs = file.Find(SettingsDir .. "*.txt", "DATA")

    local settings = {}
    for _, setting in pairs(files) do
        table.insert(settings, setting:sub(1, -5))
    end

    return settings
end

function MGR.Load(path)
    path = SaveDir .. path .. ".txt"
    if not file.Exists(path, "DATA") then
        error("SMH file does not exist: " .. path)
    end

    local json = file.Read(path)
    local serializedKeyframes = util.JSONToTable(json)
    if not serializedKeyframes then
        error("SMH file load failure")
    end

    return serializedKeyframes
end

function MGR.ListModels(path)
    local serializedKeyframes = MGR.Load(path)
    local models = {}
    local map = serializedKeyframes.Map
    local listname = " "
    for _, sEntity in pairs(serializedKeyframes.Entities) do
        if not sEntity.Properties then -- in case if we load an old save without properties entities
            listname = sEntity.Model
        else
            listname = sEntity.Properties.Name
        end
        table.insert(models, listname)
    end
    return models, map
end

function MGR.GetModelName(path, modelName)
    local serializedKeyframes = MGR.Load(path)

    for _, sEntity in pairs(serializedKeyframes.Entities) do
        if sEntity.Properties then
            if sEntity.Properties.Name == modelName then
                return sEntity.Model
            end
        else
            if sEntity.Model == modelName then
                return sEntity.Model
            end
        end
    end
    return "Error: No model found"
end

function MGR.LoadForEntity(path, modelName)
    local serializedKeyframes = MGR.Load(path)
    for _, sEntity in pairs(serializedKeyframes.Entities) do
        if not sEntity.Properties then
            if sEntity.Model == modelName then

                sEntity.Properties = {
                    Name = sEntity.Model,
                }

                return sEntity.Frames, sEntity.Properties
            end
        else
            if sEntity.Properties.Name == modelName then
                return sEntity.Frames, sEntity.Properties, sEntity.Properties.IsWorld
            end
        end
    end
    return nil
end

function MGR.Serialize(keyframes, properties, player)
    local entityMappedKeyframes = {}
    local usedModelNames = {}

    for _, keyframe in pairs(keyframes) do
        local entity = keyframe.Entity
        if not IsValid(entity) then
            continue
        end

        if entity ~= player then
            if not entityMappedKeyframes[entity] then
                local mdl = GetModelName(entity, usedModelNames)

                entityMappedKeyframes[entity] = {
                    Model = mdl,
                    Properties = {
                        Name = properties[entity].Name,
                        Class = properties[entity].Class,
                        Model = properties[entity].Model,
                    },
                    Frames = {},
                }
            end
        else
            if not entityMappedKeyframes[entity] then
                local mdl = "world"

                entityMappedKeyframes[entity] = {
                    Model = mdl,
                    Properties = {
                        Name = properties[entity].Name,
                        IsWorld = true,
                    },
                    Frames = {},
                }
            end
        end
        table.insert(entityMappedKeyframes[entity].Frames, {
            Position = keyframe.Frame,
            EaseIn = table.Copy(keyframe.EaseIn),
            EaseOut = table.Copy(keyframe.EaseOut),
            EntityData = table.Copy(keyframe.Modifiers),
        })
    end

    local serializedKeyframes = {
        Map = game.GetMap(),
        Entities = {},
    }

    for _, skf in pairs(entityMappedKeyframes) do
        table.insert(serializedKeyframes.Entities, skf)
    end

    return serializedKeyframes
end

function MGR.Save(path, serializedKeyframes)
    if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
        file.CreateDir(SaveDir)
    end

    path = SaveDir .. path .. ".txt"
    local json = util.TableToJSON(serializedKeyframes, true)
    file.Write(path, json)
end

function MGR.CopyIfExists(pathFrom, pathTo)
    pathFrom = SaveDir .. pathFrom .. ".txt"
    pathTo = SaveDir .. pathTo .. ".txt"

    if file.Exists(pathFrom, "DATA") then
        file.Write(pathTo, file.Read(pathFrom));
    end
end

function MGR.Delete(path)
    path = SaveDir .. path .. ".txt"
    if file.Exists(path, "DATA") then
        file.Delete(path)
    end
end

function MGR.SaveProperties(timeline, name)
    if next(timeline) == nil then return end

    if not file.Exists(SettingsDir, "DATA") or not file.IsDir(SettingsDir, "DATA") then
        file.CreateDir(SettingsDir)
    end

    local template = {
        Timelines = timeline.Timelines,
        TimelineMods = table.Copy(timeline.TimelineMods),
    }

    path = SettingsDir .. name .. ".txt"
    local json = util.TableToJSON(template)
    file.Write(path, json)
end

function MGR.GetPreferences(name)
    path = SettingsDir .. name .. ".txt"
    if not file.Exists(path, "DATA") then return nil end

    local json = file.Read(path)
    local template = util.JSONToTable(json)
    if not template then
        error("SMH settings file load failure")
    end

    for i = 1, template.Timelines do
        local color = template.TimelineMods[i].KeyColor
        template.TimelineMods[i].KeyColor = Color(color.r, color.g, color.b)
    end
    return template
end

SMH.Saves = MGR
