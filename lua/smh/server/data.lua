
SMH.SaveDir = "smh/";

local function RefreshActiveFrames(container)

	local player = container:_GetPlayer();
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

	local player = container:_GetPlayer();
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
	SMH.PositionEntities(container:_GetPlayer(), value);
end

local function FrameEdited(container, key, editedFrame)

	local player = container:_GetPlayer();
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

	local player = container:_GetPlayer();
	local entity = container.Entity;

	if not copiedFrame or not IsValid(entity) or not copiedFrame.Position then
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

local function RefreshSaveList(container)

	if not container.ShowLoad and not container.ShowSave then
		return;
	end

	local files, dirs = file.Find(SMH.SaveDir .. "*.txt", "DATA");

	local saves = {};
	for _, file in pairs(files) do
		table.insert(saves, file:sub(1, -5));
	end

	container.SaveFiles = saves;

end

local function LoadFileChanged(container, key, value)

	if not value or value == "" then
		container.LoadFileEntities = {};
		return;
	end

	local path = SMH.SaveDir .. value .. ".txt";
	if not file.Exists(path, "DATA") then
		container.LoadFileEntities = {};
		return;
	end

	local json = file.Read(path);
	local data = util.JSONToTable(json);
	if not data then
		container.LoadFileEntities = {};
		return;
	end

	local ents = {};
	for _, ent in pairs(data.Entities) do
		table.insert(ents, ent.Model);
	end

	container.LoadFileEntities = ents;

end

local function Load(container, key)

	local player = container:_GetPlayer();
	local entity = container.Entity;
	local loadFile = container.LoadFileName;
	local loadEntName = container.LoadFileEntity;

	if not IsValid(entity) or not loadFile or loadFile == "" or not loadEntName or loadEntName == "" then
		return;
	end

	local path = SMH.SaveDir .. loadFile .. ".txt";
	if not file.Exists(path, "DATA") then
		return;
	end
	local json = file.Read(path);
	local data = util.JSONToTable(json);
	if not data then
		return;
	end

	local loadEnt = table.First(data.Entities, function(item) return item.Model == loadEntName; end);
	if not loadEnt then
		return;
	end

	local existingFrames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
	for _, frame in pairs(existingFrames) do
		frame:Remove();
	end

	for _, dFrame in pairs(loadEnt.Frames) do
		local frame = SMH.Frame.New(player, entity, dFrame.Position, dFrame.EaseIn, dFrame.EaseOut);
		frame.EntityData = dFrame.EntityData;
	end

	RefreshActiveFrames(container);

end

local function Save(container, key)

	local fileName = container.SaveFileName;

	if not fileName or fileName == "" then
		return;
	end

	local player = container:_GetPlayer();

	local data = {};
	data.Map = game.GetMap();
	data.Entities = {};

	-- We don't store all frames into one table in the container because they can be huge, which causes problems with net sync

	local ents = SMH.GetEntities(player);
	for _, entity in pairs(ents) do
		
		local eData = {};

		local mdl = string.Split(entity:GetModel(), "/");
		mdl = mdl[#mdl];
		while true do
			local existing = table.First(data.Entities, function(item) return item.Model == mdl; end);
			if not existing then
				break;
			end
			mdl = mdl .. "I";
		end
		eData.Model = mdl;

		eData.Frames = {};
		local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
		for _, frame in pairs(frames) do
			local fData = {};
			fData.Position = frame.Position;
			fData.EaseIn = frame.EaseIn;
			fData.EaseOut = frame.EaseOut;
			fData.EntityData = frame.EntityData;
			table.insert(eData.Frames, fData);
		end

		table.insert(data.Entities, eData);

	end

	if not file.Exists(SMH.SaveDir, "DATA") or not file.IsDir(SMH.SaveDir, "DATA") then
		file.CreateDir(SMH.SaveDir);
	end

	local path = SMH.SaveDir .. fileName .. ".txt";
	local json = util.TableToJSON(data);
	file.Write(path, json);

	container.SaveFileName = "";
	RefreshSaveList(container);

end

local function QuickSave(container, key)

	local nick = container:_GetPlayer():Nick();
	local qs1 = SMH.SaveDir .. "/quicksave.txt";
	local qs2 = SMH.SaveDir .. "/quicksave_backup.txt";
	if not game.SinglePlayer() then
		qs1 = SMH.SaveDir .. "/quicksave_" .. nick .. ".txt";
		qs2 = SMH.SaveDir .. "/quicksave_" .. nick .. "_backup.txt";
	end

	if file.Exists(qs1, "DATA") then
		file.Write(qs2, file.Read(qs1));
	end

	if game.SinglePlayer() then
		container.SaveFileName = "quicksave";
	else
		container.SaveFileName = "quicksave_" .. nick;
	end
	Save(container);

end

local function DeleteSave(container, key)

	local fileName = container.SaveFileName;

	if not fileName or fileName == "" then
		return;
	end

	local path = SMH.SaveDir .. fileName .. ".txt";
	file.Delete(path);

	RefreshSaveList(container);

end

local function RefreshGhosts(container, key)
	local player = container:_GetPlayer();
	SMH.RefreshGhosts(player);
end

function SMH.SetupData(player)

	local defaults = table.Copy(SMH.DefaultData);

	defaults.Record = RecordFrame;

	defaults.Play = function(container, key)
		SMH.StartPlayback(container:_GetPlayer());
	end
	defaults.Stop = function(container, key)
		SMH.StopPlayback(container:_GetPlayer());
	end

	defaults.Load = Load;
	defaults.Save = Save;
	defaults.QuickSave = QuickSave;
	defaults.DeleteSave = DeleteSave;

	local data = SMH.BiValues.New(player, "SMHData", {IsPrivate = true, UseSync = true, AutoApply = true}, defaults);
		
	data:_Listen("Entity", function(container, key, value)
		RefreshActiveFrames(container);
	end);
	data:_Listen("Position", PositionChanged);
	data:_Listen("EditedFrame", FrameEdited);
	data:_Listen("CopiedFrame", FrameCopied);

	data:_Listen("ShowLoad", RefreshSaveList);
	data:_Listen("ShowSave", RefreshSaveList);
	data:_Listen("LoadFileName", LoadFileChanged);

	-- Changes in any of these trigger ghost refresh
	data:_Listen("Entity", RefreshGhosts);
	data:_Listen("Position", RefreshGhosts);
	data:_Listen("Rendering", RefreshGhosts);
	data:_Listen("GhostPrevFrame", RefreshGhosts);
	data:_Listen("GhostNextFrame", RefreshGhosts);
	data:_Listen("GhostAllEntities", RefreshGhosts);
	data:_Listen("GhostTransparency", RefreshGhosts);
	data:_Listen("OnionSkin", RefreshGhosts);

	player.SMHData = data;

end