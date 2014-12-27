
SMH.Entity = nil;
SMH.TouchedEntities = {};

function SMH.SelectEntity(entity)
	SMH.Entity = entity;
	if not table.HasValue(SMH.TouchedEntities, entity) then
		table.insert(SMH.TouchedEntities, entity);
	end
	SMH.Menu:RebuildFrameItems();
end

hook.Add("EntityRemoved", "SMHSelectionEntityRemoved", function(ent)
	if SMH.Entity == ent then
		SMH.Entity = nil;
		SMH.Menu:RebuildFrameItems();
	end
	if table.HasValue(SMH.TouchedEntities, ent) then
		table.RemoveByValue(SMH.TouchedEntities, ent);
	end
end);