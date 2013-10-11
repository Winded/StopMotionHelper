---
-- This objects holds SMH frames for an entity.
---

local FH = {};

---
-- Create a frame holder for the given entity.
-- This will throw an error if the entity already has a frame holder.
---
function FH.Create(entity)

	local fh =  setmetatable({}, FH);
	fh.entity = entity;
	fh:Initialize();

	entity.smh = fh;

end

function FH:Initialize()

	self.frames = {};

end

function FH:GetFrames()

	return self.frames;

end

function FH:GetFrame(at)

	return self.frames[at] or nil;

end

function FH:AddFrame(at)

	local f = {};
	f.recorded = false;
	f.data = {};

	table.insert(self.frames, at, f);

	if GetConVar("smh_save_on_add"):GetBool() then
		self.RecordFrame(at);
	end

end

function FH:RemoveFrame(at)

	table.remove(self.frames, at);

end

function FH:RecordFrame(at)

	local frame = self:GetFrame(at);
	if not frame then
		error("Frame " .. at .. " does not exist.");
		return;
	end

	frame.data = {};
	for name, mod in pairs(SMH.Modifiers) do
		frame.data[name] = mod:Save(self.entity);
	end

	frame.recorded = true;

end

function FH:ClearFrame(at)

	local frame = self:GetFrame(at);
	if not frame then
		error("Frame " .. at .. " does not exist.");
		return;
	end

	f.recorded = false;

end

function FH:MoveFrame(from, to)

	local frame = self:GetFrame(from);
	if not frame then
		error("Frame " .. from .. " does not exist.");
		return;
	end

	table.remove(self.frames, from);
	table.insert(self.frames, to, frame);

end

function FH:SetFrame(to)

	local frame = self:GetFrame(at);
	if not frame then
		error("Frame " .. to .. " does not exist.");
		return;
	end

	if not frame.recorded then return; end

	local data = frame.data;

	for name, mod in pairs(SMH.Modifiers) do
		if data[name] then
			mod:Load(self.entity, data[name]);
		end
	end

end

function FH:LerpFrame(from, percentage)

	local frame = self:GetFrame(from);
	if not frame then
		error("Frame " .. frame .. " does not exist.");
		return;
	end

	if not frame.recorded then return; end

	local frameto = self:GetFrame(from + 1);
	if not frameto or not frameto.recorded then
		frameto = frame
	end

	local data1 = frame.data;
	local data2 = frameto.data;

	for name, mod in pairs(SMH.Modifiers) do

		if data1[name] and data2[name] then
			mod:LoadBetween(self.entity, data1[name], data2[name], percentage);
		end

	end

end