
if SERVER then
	util.AddNetworkString("SMHSave");
	util.AddNetworkString("SMHDelete");
end

-- Frames are stored in a database structure
-- All objects in this table should be frames, which contain the following fields:
-- ID - the frame's unique identifier
-- Player - the player that owns this frame
-- Entity - the entity that owns this frame
-- Position - The position of the frame in the timeline
-- Data - The data retrieved from SMH modifiers
SMH.Frames = {};

local FRAME = {};
FRAME.__index = FRAME;

if SERVER then

	util.AddNetworkString("SMHPositionEntities");
	net.Receive("SMHPositionEntities", function(len, pl)

		local t = net.ReadTable();

		for _, ent in pairs(t.Entities) do
			SMH.PositionEntity(pl, ent, t.Position);
		end

	end);
	
	function SMH.RecordToFrame(frame)

		frame.Data = {};
		for name, mod in pairs(SMH.Modifiers) do
			frame.Data[name] = mod:Save(frame.Entity);
		end

	end

	-- If the position has no frame, gets the frame before the position and the frame after the position.
	-- otherwise returns only the frame at the position.
	function SMH.GetPositionFrames(frames, framepos)

		local closestPrevFramePos = 9999999;
		local closestPrevFrame = nil;
		local closestNextFramePos = 9999999;
		local closestNextFrame = nil;

		for _, frame in pairs(frames) do

			local diff = frame.Position - framepos;
			if diff < 0 and math.abs(diff) < closestPrevFramePos then
				closestPrevFramePos = math.abs(diff);
				closestPrevFrame = frame;
			elseif diff > 0 and math.abs(diff) < closestNextFramePos then
				closestNextFramePos = math.abs(diff);
				closestNextFrame = frame;
			else
				return frame, nil;
			end

		end

		if not closestPrevFrame and closestNextFrame then
			return closestNextFrame, nil;
		elseif closestPrevFrame and not closestNextFrame then
			return closestPrevFrame, nil;
		end

		return closestPrevFrame, closestNextFrame;

	end

	function SMH.PositionEntity(player, entity, framepos)

		local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
		if not frames or #frames == 0 then
			return;
		end

		local frame1, frame2 = SMH.GetPositionFrames(frames, framepos);

		if not frame2 then
			for name, mod in pairs(SMH.Modifiers) do
				mod:Load(entity, frame1.Data[name]);
			end
			return;
		end

		local perc = (framepos - frame1.Position) / (frame2.Position - frame1.Position);
		for name, mod in pairs(SMH.Modifiers) do
			mod:LoadBetween(entity, frame1.Data[name], frame2.Data[name], perc);
		end

	end

end

function FRAME.New(player, entity, position)

	local f = setmetatable({}, FRAME);

	f.ID = math.random(1, 99999999);

	f.Player = player;
	f.Entity = entity;
	f.Position = position;
	f.Data = nil;

	return f;

end

-- Sends the frame table to the other side (server on client, client on server).
function FRAME:Save()

	net.Start("SMHSave");

	net.WriteTable(self);

	if SERVER then
		net.Send(self.Player);
	else
		net.SendToServer();
	end

end

-- Send a message to the other side that this frame is to be deleted
function FRAME:Delete()

	net.Start("SMHDelete");

	net.WriteString(self.ID);

	if SERVER then
		net.Send(self.Player);
	else
		net.SendToServer();
	end

end

net.Receive("SMHSave", function(len, pl)

	local frame = setmetatable(net.ReadTable(), FRAME);

	if SERVER and (not IsValid(frame.Player) or frame.Player ~= pl) then
		ErrorNoHalt("SMHSave - players do not match!");
		return;
	end
	if not IsValid(frame.Entity) then
		ErrorNoHalt("SMHSave - Entity is not valid!");
		return;
	end

	local f = table.First(SMH.Frames, function(item) return item.ID == frame.ID; end);

	if not f then

		if SERVER then
			SMH.RecordToFrame(frame);
			frame:Save();
		end

		table.insert(SMH.Frames, frame);

	else

		table.RemoveByValue(SMH.Frames, f);
		table.insert(SMH.Frames, frame);

	end

end);

net.Receive("SMHDelete", function(len, pl)

	local frameID = net.ReadString();
	local frame = table.First(SMH.Frames, function(item) return item.ID == frameID; end);

	-- Security check
	if SERVER and frame.Player ~= pl then
		ErrorNoHalt("SMHDelete - players do not match!");
		return;
	end

	table.RemoveByValue(SMH.Frames, frame);

end);

hook.Add("EntityRemoved", "SMHFramesEntityRemoved", function(ent)

	local frames = table.Where(SMH.Frames, function(item) return item.Entity == ent; end);
	for _, frame in pairs(frames) do
		table.RemoveByValue(SMH.Frames, frame);
	end

end);

SMH.Frame = FRAME;