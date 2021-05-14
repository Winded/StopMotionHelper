
-- Get all entities that have frames, as well as the currently selected entity
function SMH.GetEntities(player)

	local entities = {};

	for _, frame in pairs(SMH.Frames) do
		if frame.Player == player and not table.HasValue(entities, frame.Entity) then
			table.insert(entities, frame.Entity);
		end
	end

	if not table.HasValue(entities, player.SMHData.Entity) then
		table.insert(entities, player.SMHData.Entity);
	end

	return entities;

end

-- If the position has no frame (or is ignored), gets the frame before the position, the frame after the position and the difference percentage
-- otherwise returns only the frame at the position.
function SMH.GetPositionFrames(frames, framepos, ignoreCurrentFrame)

	local closestPrevFramePos = 9999999;
	local closestPrevFrame = nil;
	local closestNextFramePos = 9999999;
	local closestNextFrame = nil;

	for _, frame in pairs(frames) do

		if frame.Position == nil then
			frame.Position = -1;
		end

		local diff = frame.Position - framepos;
		local aDiff = math.abs(diff);
		if diff < 0 and aDiff < closestPrevFramePos then
			closestPrevFramePos = aDiff;
			closestPrevFrame = frame;
		elseif diff > 0 and aDiff < closestNextFramePos then
			closestNextFramePos = math.abs(diff);
			closestNextFrame = frame;
		elseif diff == 0 and not ignoreCurrentFrame then
			return frame, nil;
		end

	end

	if not closestPrevFrame and not closestNextFrame then
		return nil, nil;
	elseif not closestPrevFrame and closestNextFrame then
		return closestNextFrame, nil;
	elseif closestPrevFrame and not closestNextFrame then
		return closestPrevFrame, nil;
	end

	local perc = (framepos - closestPrevFrame.Position) / (closestNextFrame.Position - closestPrevFrame.Position);
	perc = math.EaseInOut(perc, closestPrevFrame.EaseOut, closestNextFrame.EaseIn);
	return closestPrevFrame, closestNextFrame, perc;

end

function SMH.PositionEntity(player, entity, framepos)

	local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
	if not frames or #frames == 0 then
		return;
	end

	local frame1, frame2, perc = SMH.GetPositionFrames(frames, framepos);

	if not frame2 then
		for name, mod in pairs(SMH.Modifiers) do
			local data1 = frame1.EntityData[name];
			if data1 ~= nil then
				mod:Load(player, entity, frame1.EntityData[name]);
			end
		end
		return;
	end

	for name, mod in pairs(SMH.Modifiers) do
		local data1, data2 = frame1.EntityData[name], frame2.EntityData[name];
		if data1 ~= nil and data2 ~= nil then
			mod:LoadBetween(player, entity, data1, data2, perc);
		end
	end

end

function SMH.PositionEntities(player, framepos)
	local entities = SMH.GetEntities(player);
	for _, entity in pairs(entities) do
		SMH.PositionEntity(player, entity, framepos);
	end
end