local function GetModelName(entity)
    local mdl = string.Split(entity:GetModel(), "/");
    mdl = mdl[#mdl];

    return mdl
end

local function SetUniqueName(name, usedModelNames)
    local namebase = name
    local num = 1

    if usedModelNames[name] then
        local startPos = string.find(namebase, "%d*$")
        namebase = string.sub(namebase, 1, startPos - 1)
    end
    while usedModelNames[name] do
        name = namebase .. num
        num = num + 1
    end
    usedModelNames[name] = true
    return name
end

local function ProcessKeyframes(keyframes, entityMappedKeyframes, properties, player)
    for _, keyframe in pairs(keyframes) do
        local entity = keyframe.Entity
        if not IsValid(entity) then
            continue
        end

        if entity ~= player then
            if not entityMappedKeyframes[entity] then
                local mdl = GetModelName(entity)

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
end

local SaveDir = "smh/"
local SettingsDir = "smhsettings/"
local PlayerPath = {}

local MGR = {}

function MGR.ListFiles(player)
    local path = SaveDir .. (PlayerPath[player] or "")
    local files, _ = file.Find(path .. "*.txt", "DATA")
    local _, dirs = file.Find(path .. "*", "DATA")

    local saves = {}
    for _, file in pairs(files) do
        table.insert(saves, file:sub(1, -5))
    end

    return dirs, saves, path
end

function MGR.ListSettings()
    local files, dirs = file.Find(SettingsDir .. "*.txt", "DATA")

    local settings = {}
    for _, setting in pairs(files) do
        table.insert(settings, setting:sub(1, -5))
    end

    return settings
end

function MGR.Load(path, player)
    path = SaveDir .. (PlayerPath[player] or "") .. path .. ".txt"
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

function MGR.ListModels(path, player)
    local serializedKeyframes = MGR.Load(path, player)
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

function MGR.GetModelName(path, modelName, player)
    local serializedKeyframes = MGR.Load(path, player)

    for _, sEntity in pairs(serializedKeyframes.Entities) do
        if sEntity.Properties then
            if sEntity.Properties.Name == modelName then
                local model, class
                model = sEntity.Properties.Model

                if not sEntity.Properties.Class then
                    class = "Error: No class found"
                else
                    class = sEntity.Properties.Class
                end
                return model, class
            end
        else
            if sEntity.Model == modelName then
                return sEntity.Model, "Error: No class found"
            end
        end
    end
    return "Error: No model found", "Error: No class found"
end

function MGR.LoadForEntity(path, modelName, player)
    local serializedKeyframes = MGR.Load(path, player)
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

    ProcessKeyframes(keyframes, entityMappedKeyframes, properties, player)

    local serializedKeyframes = {
        Map = game.GetMap(),
        Entities = {},
    }

    for _, skf in pairs(entityMappedKeyframes) do
        table.insert(serializedKeyframes.Entities, skf)
    end

    return serializedKeyframes
end

function MGR.CheckIfExists(path, player)
    if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
        file.CreateDir(SaveDir)
    end

    path = SaveDir .. (PlayerPath[player] or "") ..  path .. ".txt"
    if file.Exists(path, "DATA") and not file.IsDir(path, "DATA") then return true end

    return false
end

function MGR.GetUnusedNames(path, properties, player)
    if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
        file.CreateDir(SaveDir)
    end

    local serializedKeyframes = MGR.Load(path, player)
    local entityNames = {}

    for _, data in ipairs(serializedKeyframes.Entities) do
        if data.Properties then
            entityNames[data.Properties.Name] = true
        else
            entityNames[data.Model] = true
        end
    end

    for entity, data in pairs(properties) do
        entityNames[data.Name] = nil
    end

    return entityNames
end

function MGR.SerializeAndAppend(path, keyframes, properties, player, saveNames, gameNames)
    if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
        file.CreateDir(SaveDir)
    end

    local oldSerializedKeyframes = MGR.Load(path, player)
    local usedModelNames, entityMappedKeyframes = {}, {}
    local serializedKeyframes = {
        Map = game.GetMap(),
        Entities = {},
    }

    for _, data in ipairs(oldSerializedKeyframes.Entities) do
        if data.Properties then
            if saveNames[data.Properties.Name] then
                table.insert(serializedKeyframes.Entities, data)
            end
        else
            if saveNames[data.Model] then
                table.insert(serializedKeyframes.Entities, data)
            end
        end
    end

    for name, _ in pairs(saveNames) do
        usedModelNames[name] = true
    end

    ProcessKeyframes(keyframes, entityMappedKeyframes, properties, player)

    for _, skf in pairs(entityMappedKeyframes) do
        if gameNames[skf.Properties.Name] then
            skf.Properties.Name = SetUniqueName(skf.Properties.Name, usedModelNames)
            table.insert(serializedKeyframes.Entities, skf)
        end
    end

    return serializedKeyframes
end

function MGR.Save(path, serializedKeyframes, player)
    if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
        file.CreateDir(SaveDir)
    end

    path = SaveDir .. (PlayerPath[player] or "") .. path .. ".txt"
    local json = util.TableToJSON(serializedKeyframes)
    file.Write(path, json)
end

function MGR.AddFolder(path, player)
    local fullpath = SaveDir .. (PlayerPath[player] or "") .. path

    if file.Exists(fullpath, "DATA") and file.IsDir(fullpath, "DATA") then return nil end

    file.CreateDir(fullpath)
    return path
end

function MGR.CopyIfExists(pathFrom, pathTo, player)
    pathFrom = SaveDir .. (PlayerPath[player] or "") .. pathFrom .. ".txt"
    pathTo = SaveDir .. (PlayerPath[player] or "") .. pathTo .. ".txt"

    if file.Exists(pathFrom, "DATA") then
        file.Write(pathTo, file.Read(pathFrom));
    end
end

function MGR.Delete(path, player)
    path = SaveDir .. (PlayerPath[player] or "") .. path .. ".txt"
    if file.Exists(path, "DATA") then
        file.Delete(path)
    end
end

function MGR.DeleteFolder(path, player)
    path = SaveDir .. (PlayerPath[player] or "") .. path
    if file.Exists(path, "DATA") and file.IsDir(path, "DATA") then
        file.Delete(path)
    end

    if file.Exists(path, "DATA") and file.IsDir(path, "DATA") then return false end
    return true
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

function MGR.GetPath(player)
    if not PlayerPath[player] then
        PlayerPath[player] = ""
    end

    return PlayerPath[player]
end

function MGR.GoBackPath(player)
    if not PlayerPath[player] or PlayerPath[player] == "" then
        return
    end

    local kablooey = string.Explode("/", PlayerPath[player])

    if #kablooey > 2 then
        PlayerPath[player] = table.concat(kablooey, "/", 1, #kablooey - 2) .. "/"
    else
        PlayerPath[player] = ""
    end
end

function MGR.SetPath(path, player)
    PlayerPath[player] = path
end

SMH.Saves = MGR
