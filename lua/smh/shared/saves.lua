local function GetModelName(entity, usedModelNames)
    local mdl = string.Split(entity:GetModel(), "/");
    mdl = mdl[#mdl];
    while usedModelNames[mdl] do
        mdl = mdl .. "I"
    end
    usedModelNames[mdl] = true
    return mdl
end

local SaveDir = "smh/"

local MGR = {}

function MGR.ListFiles()
	local files, dirs = file.Find(SaveDir .. "*.txt", "DATA");

	local saves = {}
	for _, file in pairs(files) do
		table.insert(saves, file:sub(1, -5))
	end

    return saves
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
    for _, sEntity in pairs(serializedKeyframes.Entities) do
        table.insert(models, sEntity.Model)
    end
    return models
end

function MGR.LoadForEntity(path, modelName)
    local serializedKeyframes = MGR.Load(path)
    for _, sEntity in pairs(serializedKeyframes.Entities) do
        if sEntity.Model == modelName then
            return sEntity.Frames
        end
    end

    return nil
end

function MGR.Serialize(keyframes)
    local entityMappedKeyframes = {}
    local usedModelNames = {}

    for _, keyframe in pairs(keyframes) do
        local entity = keyframe.Entity
        if not IsValid(entity) then
            continue
        end

        if not entityMappedKeyframes[entity] then
            local mdl = GetModelName(entity, usedModelNames)

            entityMappedKeyframes[entity] = {
                Model = mdl,
                Frames = {},
            }
        end

        table.insert(entityMappedKeyframes[entity].Frames, {
            Position = keyframe.Frame,
            EaseIn = keyframe.EaseIn,
            EaseOut = keyframe.EaseOut,
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
	local json = util.TableToJSON(serializedKeyframes)
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

SMH.Saves = MGR
