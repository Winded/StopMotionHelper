SMH.Properties = {
    Players = {}
}

local usednames = {}

local function GetModelName(entity)
    local mdl = string.Split(entity:GetModel(), "/")
    mdl = mdl[#mdl]

    return mdl
end

local function SetUniqueName(player, entity, name)
    if SMH.Properties.Players[player].Entities[entity] then
        usednames[SMH.Properties.Players[player].Entities[entity].Name] = nil -- so we won't consider our own name when sorting
    end

    for kentity, value in pairs(SMH.Properties.Players[player].Entities) do
        if kentity ~= entity and name == value.Name then -- if there's another entity with our name
            usednames[value.Name] = true
            break
        end
    end

    while usednames[name] do
        name = name .. "I"
    end
    usednames[name] = true
    return name
end

local function FindEntity(player) -- I use this to find entity that doesn't have recorded frames
    local sorting = {}

    for entity, _ in pairs(SMH.Properties.Players[player].Entities) do
        if sorting[entity] then continue end

        for k, value in pairs(SMH.KeyframeData.Players[player].Keyframes) do
            if value.Entity == entity then
                sorting[entity] = true
                break 
            end
        end
    end

    for entity, _ in pairs(SMH.Properties.Players[player].Entities) do
        if not sorting[entity] then return entity end
    end

    return nil
end

hook.Add("EntityRemoved", "SMHPropertiesEntityRemoved", function(entity)

    for _, player in pairs(player.GetAll()) do
        if SMH.Properties.Players[player] and SMH.Properties.Players[player].Entities then
            if SMH.Properties.Players[player].Entities[entity] then
                usednames[SMH.Properties.Players[player].Entities[entity].Name] = nil
                SMH.Properties.Players[player].Entities[entity] = nil
            end
        end
    end

end)

local MGR = {}

function MGR.GetAllEntityProperties(player, selectedentity)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities or not IsValid(selectedentity) then return {} end

    local info = {}

    for entity, value in pairs(SMH.Properties.Players[player].Entities) do
        if selectedentity == entity then
            info = {
                Name = value.Name,
                Timelines = value.Timelines,
                TimelineMods = table.Copy(value.TimelineMods),
            }
            break
        end
    end

    return info
end

function MGR.GetAllProperties(player)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities then return {} end

    local info = {}

    for entity, value in pairs(SMH.Properties.Players[player].Entities) do
        info[entity] = {
            Name = value.Name,
            Timelines = value.Timelines,
            TimelineMods = table.Copy(value.TimelineMods),
        }
    end

    return info
end

function MGR.GetAllEntitiesNames(player)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities then return {} end

    local info = {}

    for entity, value in pairs(SMH.Properties.Players[player].Entities) do
        info[entity] = {
            Name = value.Name,
        }
    end

    return info
end

function MGR.CheckEntity(player, entity)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities or not SMH.Properties.Players[player].Entities[entity] then return true end
    return false
end

function MGR.RemoveEntity(player)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities or not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities then return end
    local entity = FindEntity(player)
    if entity then
        usednames[SMH.Properties.Players[player].Entities[entity].Name] = nil
        SMH.Properties.Players[player].Entities[entity] = nil
    end
end

function MGR.AddEntity(player, entity)
    if not SMH.Properties.Players[player] then
        SMH.Properties.Players[player] = { Entities = {} }
    end

    if not SMH.Properties.Players[player].Entities[entity] then
        if player ~= entity then
            local template = SMH.Saves.GetPreferences(player)
            local timelines
            local timelinemods = {}
            if not template then
                timelines = 1

                timelinemods[1] = { KeyColor = Color(0, 200, 0) }

                for name, mod in pairs(SMH.Modifiers) do
                    table.insert(timelinemods[1], name)
                end
            else
                timelines = template.Timelines

                timelinemods = table.Copy(template.TimelineMods)
            end
            SMH.Properties.Players[player].Entities[entity] = {
                Name = SetUniqueName(player, entity, GetModelName(entity)),
                Timelines = timelines,
                TimelineMods = timelinemods
            }
        else
            local timelinemods = {}

            timelinemods[1] = { KeyColor = Color(0, 200, 0) }

            SMH.Properties.Players[player].Entities[entity] = {
                Name = SetUniqueName(player, entity, "world"),
                Timelines = 1,
                TimelineMods = timelinemods,
            }
        end
    end
    usednames[SMH.Properties.Players[player].Entities[entity].Name] = true
end

function MGR.SetName(player, entity, newname)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return end
    if not newname then return end

    newname = SetUniqueName(player, entity, newname)
    SMH.Properties.Players[player].Entities[entity].Name = newname

    return newname
end

function MGR.SetTimelines(player, entity, add)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return end

    local timelines = SMH.Properties.Players[player].Entities[entity].Timelines
    local count
    if add then
        count = timelines + 1
    else
        count = timelines - 1
    end

    if count > 10 or count < 1 then return end  -- just in case

    if add then
        SMH.Properties.Players[player].Entities[entity].TimelineMods[count] = { KeyColor = Color(0, 200, 0) }
    else
        SMH.Properties.Players[player].Entities[entity].TimelineMods[timelines] = nil
    end

    SMH.Properties.Players[player].Entities[entity].Timelines = count
end

function MGR.UpdateModifier(player, entity, itimeline, name, state)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return end

    if state then 
        table.insert(SMH.Properties.Players[player].Entities[entity].TimelineMods[itimeline], name)
        for i = 1, SMH.Properties.Players[player].Entities[entity].Timelines do
            if i == itimeline then continue end
            table.RemoveByValue(SMH.Properties.Players[player].Entities[entity].TimelineMods[i], name)
        end
    else
        table.RemoveByValue(SMH.Properties.Players[player].Entities[entity].TimelineMods[itimeline], name)
    end

    return name
end

function MGR.UpdateKeyframeColor(player, entity, color, timeline)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return end

    SMH.Properties.Players[player].Entities[entity].TimelineMods[timeline].KeyColor = color
end

function MGR.GetTimelines(player, entity)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return 1 end
    return SMH.Properties.Players[player].Entities[entity].Timelines
end

function MGR.SetProperties(player, entity, properties)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities[entity] then return end

    local newname = SetUniqueName(player, entity, properties.Name)
    SMH.Properties.Players[player].Entities[entity].Name = newname
    SMH.Properties.Players[player].Entities[entity].Timelines = properties.Timelines
    SMH.Properties.Players[player].Entities[entity].TimelineMods = properties.TimelineMods
    if properties.Old then
        SMH.Properties.Players[player].Entities[entity].Old = true
    end
end

SMH.PropertiesManager = MGR
