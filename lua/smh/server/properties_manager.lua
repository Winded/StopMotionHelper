SMH.Properties = {
	Players = {}
}

local usednames = {}

local function GetModelName(entity, usedModelNames)
	local mdl = string.Split(entity:GetModel(), "/")
	mdl = mdl[#mdl]
--	while usedModelNames[mdl] do
--		mdl = mdl .. "I"
--	end
--	usedModelNames[mdl] = true
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
		if !sorting[entity] then return entity end
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

function MGR.GetAllEntityProperties(player)
    if not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities then return nil end
	
	local info = {}
	
	for entity, value in pairs(SMH.Properties.Players[player].Entities) do
		info[entity] = {
			Name = value.Name
		}
		table.insert(info, entinfo)
	end
	
	return info
end

function MGR.UpdateEntity(player, entity)
	if not entity then
		if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities or not SMH.Properties.Players[player] or not SMH.Properties.Players[player].Entities then return end
		entity = FindEntity(player)
		if entity then
			usednames[SMH.Properties.Players[player].Entities[entity].Name] = nil
			SMH.Properties.Players[player].Entities[entity] = nil
		end
	else
		if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
			if SMH.Properties.Players[player] and SMH.Properties.Players[player].Entities[entity] then
				SMH.Properties.Players[player].Entities[entity] = nil
			end
			return
		end

		if not SMH.Properties.Players[player] then
			SMH.Properties.Players[player] = { Entities = {} }
		end
		
		if not SMH.Properties.Players[player].Entities[entity] then
			SMH.Properties.Players[player].Entities[entity] = {
				Name = SetUniqueName(player, entity, GetModelName(entity))
			}
		end
		usednames[SMH.Properties.Players[player].Entities[entity].Name] = true
	end
end

function MGR.AddEntity(player, entity)
	if not SMH.Properties.Players[player] then
		SMH.Properties.Players[player] = { Entities = {} }
	end
		
	if not SMH.Properties.Players[player].Entities[entity] then
		SMH.Properties.Players[player].Entities[entity] = {
			Name = SetUniqueName(player, entity, GetModelName(entity))
		}
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

SMH.PropertiesManager = MGR
