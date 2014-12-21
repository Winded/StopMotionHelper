
--[[
	Frames are stored on the server in a database structure.
	SMH.Data.ActiveFrames, will be what the client will see, so it can construct the menu accordingly
	
	All objects in this table should be frames, which contain the following fields:
	ID - the frame's unique identifier
	Player - the player that owns this frame
	Entity - the entity that owns this frame
	Position - The position of the frame in the timeline
	EntityData - The data retrieved from SMH modifiers

	ActiveFrame objects should only contain the frame's ID and Position, as the client won't need anything else.
]]--

SMH.Frames = {};

local FRAME = {};
FRAME.__index = FRAME;

function FRAME.Get(id)
	return table.First(SMH.Frames, function(item) return item.ID == id; end);
end

function FRAME.GetByPosition(player, entity, position)
	return table.First(SMH.Frames, function(item) return item.Player == player and item.Entity == entity and item.Position == position; end);
end

function FRAME.New(player, entity, position, copyOf)

	local f = setmetatable({}, FRAME);

	f.ID = math.random(1, 99999999);

	f.Player = player;
	f.Entity = entity;
	f.Position = position;

	f.EntityData = nil;

	table.insert(SMH.Frames, f);
	return f;

end

-- Create a copy of the given frame
function FRAME.Copy(frame)
	local newFrame = FRAME.New(frame.Player, frame.Entity, frame.Position, frame.ID);
	newFrame.EntityData = table.Copy(frame.EntityData);
	return newFrame;
end

function FRAME:Record()
	self.EntityData = {};
	for name, mod in pairs(SMH.Modifiers) do
		self.EntityData[name] = mod:Save(self.Entity);
	end
end

function FRAME:Remove()
	table.RemoveByValue(SMH.Frames, self);
end

hook.Add("EntityRemoved", "SMHFramesEntityRemoved", function(ent)

	for _, player in pairs(player.GetAll()) do
		if player.SMHData and player.SMHData.Entity == ent then
			player.SMHData.Entity = nil;
			player.SMHData.ActiveFrames = {};
		end
	end

	local frames = table.Where(SMH.Frames, function(item) return item.Entity == ent; end);
	for _, frame in pairs(frames) do
		table.RemoveByValue(SMH.Frames, frame);
	end

end);

SMH.Frame = FRAME;