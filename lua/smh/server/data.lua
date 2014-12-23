
local function RefreshActiveFrames(container)

	local player = container._Player;
	local entity = container.Entity;

	table.Empty(container.ActiveFrames);

	if not IsValid(entity) then
		container:_MarkChanged("ActiveFrames");
		return;
	end

	local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
	for _, frame in pairs(frames) do
		local f = {
			ID = frame.ID,
			Position = frame.Position,
			EaseIn = frame.EaseIn,
			EaseOut = frame.EaseOut
		};
		table.insert(container.ActiveFrames, f);
	end

	container:_MarkChanged("ActiveFrames");

end

local function RecordFrame(container, key)

	local player = container._Player;
	local entity = container.Entity;
	local position = container.Position;

	if not IsValid(entity) then
		return;
	end

	local frame = table.First(SMH.Frames, function(item) return item.Player == player and item.Entity == entity and item.Position == position; end);
	if frame then
		frame:Record();
		return;
	end

	frame = SMH.Frame.New(player, entity, position);
	frame:Record();
	RefreshActiveFrames(container);

end

local function PositionChanged(container, key, value)
	SMH.PositionEntities(container._Player, value);
end

local function FrameEdited(container, key, editedFrame)

	local player = container._Player;
	local entity = container.Entity;

	if not editedFrame or not IsValid(entity) then
		return;
	end

	local frame = table.First(SMH.Frames, function(item) return item.Player == player and item.ID == editedFrame.ID; end);
	if not frame then
		error("Invalid frame!");
	end

	if editedFrame.NewPosition then

		local existingFrame = table.First(SMH.Frames, function(item) 
			return item.ID ~= editedFrame.ID and item.Player == player and item.Entity == entity and item.Position == editedFrame.NewPosition; 
		end);
		if existingFrame then
			existingFrame:Remove();
		end

		frame.Position = editedFrame.NewPosition;

	end

	if editedFrame.NewEaseIn then
		frame.EaseIn = editedFrame.NewEaseIn;
	end
	if editedFrame.NewEaseOut then
		frame.EaseOut = editedFrame.NewEaseOut;
	end

	if editedFrame.Remove then
		frame:Remove();
	end

	container[key] = nil;
	RefreshActiveFrames(container);

end

local function FrameCopied(container, key, copiedFrame)

	local player = container._Player;
	local entity = container.Entity;

	if not copiedFrame or not IsValid(entity) then
		return;
	end

	local id = copiedFrame.ID;
	local position = copiedFrame.Position;

	local frame = table.First(SMH.Frames, function(item) return item.Player == player and item.ID == id; end);
	if not frame then
		error("Invalid frame!");
	end

	local existingFrame = table.First(SMH.Frames, function(item) return item.Player == player and item.Entity == entity and item.Position == position; end);
	if existingFrame then
		existingFrame:Remove();
	end

	local newFrame = frame:Copy();
	frame.Position = position;

	RefreshActiveFrames(container);

end

function SMH.SetupData(player)

	local defaults = {};
	defaults.Entity = nil;
	defaults.Position = 0;
	defaults.PlaybackRate = 30;
	defaults.PlaybackLength = 100;
	defaults.ActiveFrames = {};
	defaults.EditedFrame = nil;

	defaults.EaseIn = 0;
	defaults.EaseOut = 0;
	defaults.ShowEaseOptions = false;

	defaults.Record = RecordFrame;

	defaults.Play = function(container, key)
		SMH.StartPlayback(container._Player);
	end
	defaults.Stop = function(container, key)
		SMH.StopPlayback(container._Player);
	end

	local data = BiValues.New(player, "SMHData", {UseSync = true, AutoApply = true}, defaults);
		
	data:_Listen("Entity", function(container, key, value)
		RefreshActiveFrames(container);
	end);
	data:_Listen("Position", PositionChanged);
	data:_Listen("EditedFrame", FrameEdited);
	data:_Listen("CopiedFrame", FrameCopied);

	player.SMHData = data;

end