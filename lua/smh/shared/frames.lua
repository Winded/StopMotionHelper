
if SERVER then
	util.AddNetworkString("SMHSave");
	util.AddNetworkString("SMHRecord");
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

	-- If the position has no frame, gets the frame before the position and the frame after the position.
	-- otherwise returns only the frame at the position.
	function SMH.GetPositionFrames(frames, framepos)

		local closestPrevFramePos = 9999999;
		local closestPrevFrame = nil;
		local closestNextFramePos = 9999999;
		local closestNextFrame = nil;

		for _, frame in pairs(frames) do

			local diff = frame.Position - framepos;
			local aDiff = math.abs(diff);
			if diff < 0 and aDiff < closestPrevFramePos then
				closestPrevFramePos = aDiff;
				closestPrevFrame = frame;
			elseif diff > 0 and aDiff < closestNextFramePos then
				closestNextFramePos = math.abs(diff);
				closestNextFrame = frame;
			elseif diff == 0 then
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
-- Argument copyOf should be set to another frame if the server should copy the data from that frame.
function FRAME:Save(copyOf)

	net.Start("SMHSave");

	-- Don't send data; its only recorded and kept on server, no need to transfer
	local data = self.Data;
	net.WriteTable(self);
	self.Data = data;

	if SERVER then
		net.Send(self.Player);
		return;
	end

	if copyOf then
		net.WriteInt(copyOf.ID, 32);
	else
		net.WriteInt(0, 32);
	end
	net.SendToServer();

end

-- If on server, record current entity state to the frame.
-- If on client, send a request for server to record the frame.
function FRAME:Record()
	if SERVER then

		self.Data = {};
		for name, mod in pairs(SMH.Modifiers) do
			self.Data[name] = mod:Save(self.Entity);
		end

	else

		net.Start("SMHRecord");
		net.WriteInt(self.ID, 32);
		net.SendToServer();

	end
end

-- Send a message to the other side that this frame is to be deleted
function FRAME:Delete()

	net.Start("SMHDelete");

	net.WriteInt(self.ID, 32);

	if SERVER then
		net.Send(self.Player);
	else
		net.SendToServer();
	end

end

-- Update frame with given data
function FRAME:Update(data)
	if self.ID ~= data.ID then
		error("SMH frame update - ID mismatch");
		return;
	end
	self.Entity = data.Entity;
	self.Player = data.Player;
	self.Position = data.Position;
end

net.Receive("SMHSave", function(len, pl)

	local frame = setmetatable(net.ReadTable(), FRAME);
	local copyOf = net.ReadInt(32);

	if SERVER and (not IsValid(frame.Player) or frame.Player ~= pl) then
		ErrorNoHalt("SMHSave - players do not match!");
		return;
	end
	if not IsValid(frame.Entity) then
		ErrorNoHalt("SMHSave - Entity is not valid!");
		return;
	end

	local f = table.First(SMH.Frames, function(item) return item.ID == frame.ID; end);
	if f then
		f:Update(frame);
		frame = f;
	else
		table.insert(SMH.Frames, frame);
		if SERVER and copyOf == 0 then
			frame:Record();
		end
	end

	if copyOf ~= 0 then
		local copyFrame = table.First(SMH.Frames, function(item) return item.ID == copyOf; end);
		if not copyFrame then
			ErrorNoHalt("SMHSave - Invalid copyOf ID!");
			return;
		end
		frame.Data = table.Copy(copyFrame.Data);
	end

end);

net.Receive("SMHRecord", function(len, pl)

	if not SERVER then
		return;
	end

	local frameID = net.ReadInt(32);
	local frame = table.First(SMH.Frames, function(item) return item.ID == frameID; end);
	if not frame then
		ErrorNoHalt("SMHRecord - Invalid frame ID");
		return;
	end

	-- Security check
	if frame.Player ~= pl then
		ErrorNoHalt("SMHRecord - players do not match!");
		return;
	end

	frame:Record();

end);

net.Receive("SMHDelete", function(len, pl)

	local frameID = net.ReadInt(32);
	local frame = table.First(SMH.Frames, function(item) return item.ID == frameID; end);
	if not frame then
		ErrorNoHalt("SMHDelete - Invalid frame ID");
		return;
	end

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