
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

local function Load(container, key)

	local player = container._Player;
	local entity = container.Entity;
	local index = container.LoadDataIndex;

	if not IsValid(entity) or table.Count(index) == 0 then
		return;
	end

	local loadFrames = {};
	for _, idx in pairs(index) do
		local frame = container["LoadDataFrame_" .. idx];
		table.insert(loadFrames, frame);
	end

	local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
	for _, frame in pairs(frames) do
		frame:Remove();
	end

	for _, sFrame in pairs(loadFrames) do
		local frame = SMH.Frame.New(player, entity, sFrame.Position, sFrame.EaseIn, sFrame.EaseOut);
		frame.EntityData = table.Copy(sFrame.EntityData);
	end

	RefreshActiveFrames(container);
	container.LoadFileName = "";

end

local function Save(container, key)

	local player = container._Player;

	local data = {};
	data.Map = game.GetMap();
	data.Entities = {};

	-- We don't store all frames into one table in the container because they can be huge, which causes problems with net sync

	local i = 1;
	local ents = SMH.GetEntities(player);
	for _, entity in pairs(ents) do
		
		local eData = {};
		local mdl = string.Split(entity:GetModel(), "/");
		eData.Model = mdl[#mdl];
		eData.FrameIndex = {};

		local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
		for _, frame in pairs(frames) do
			local fData = {};
			fData.Position = frame.Position;
			fData.EaseIn = frame.EaseIn;
			fData.EaseOut = frame.EaseOut;
			fData.EntityData = frame.EntityData;
			container["SaveDataFrame_" .. i] = fData;
			table.insert(eData.FrameIndex, i);
			i = i + 1;
		end

		table.insert(data.Entities, eData);

	end

	container.SaveData = data;

end

local function ToggleOnionSkin(container, key, value)

	local player = container._Player;
	local enabled = value;

	if not enabled then
		container.OnionSkinData = {};
		return;
	end

	local data = {};

	local ents = SMH.GetEntities(player);
	for _, entity in pairs(ents) do
		
		-- TODO

	end

	container.OnionSkinData = data;

end

local function RefreshGhosts(container, key)
	local player = container._Player;
	SMH.RefreshGhosts(player);
end

function SMH.SetupData(player)

	local defaults = table.Copy(SMH.DefaultData);

	defaults.Record = RecordFrame;

	defaults.Play = function(container, key)
		SMH.StartPlayback(container._Player);
	end
	defaults.Stop = function(container, key)
		SMH.StopPlayback(container._Player);
	end

	defaults.Load = Load;
	defaults.Save = Save;

	local data = BiValues.New(player, "SMHData", {UseSync = true, AutoApply = true}, defaults);
		
	data:_Listen("Entity", function(container, key, value)
		RefreshActiveFrames(container);
	end);
	data:_Listen("Position", PositionChanged);
	data:_Listen("EditedFrame", FrameEdited);
	data:_Listen("CopiedFrame", FrameCopied);

	data:_Listen("OnionSkin", ToggleOnionSkin);

	-- Changes in any of these trigger ghost refresh
	data:_Listen("Entity", RefreshGhosts);
	data:_Listen("Position", RefreshGhosts);
	data:_Listen("Rendering", RefreshGhosts);
	data:_Listen("GhostPrevFrame", RefreshGhosts);
	data:_Listen("GhostNextFrame", RefreshGhosts);
	data:_Listen("GhostAllEntities", RefreshGhosts);
	data:_Listen("GhostTransparency", RefreshGhosts);

	player.SMHData = data;

end