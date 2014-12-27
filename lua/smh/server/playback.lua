
util.AddNetworkString("SMHPlayback");

local CurrentPlaybacks = {};

hook.Add("Think", "SMHPlaybackTick", function()
	for _, pb in pairs(CurrentPlaybacks) do
		
		local oldPos = math.floor(pb.Position);
		pb.Position = pb.Position + FrameTime() * pb.PlaybackRate;
		local newPos = math.floor(pb.Position);

		if newPos > pb.PlaybackLength then
			pb.Position = 0;
			newPos = 0;
		end

		if newPos ~= oldPos then
			for _, ent in pairs(pb.Entities) do
				SMH.PositionEntity(pb.Player, ent, newPos);
			end
		end

	end
end);

function SMH.StartPlayback(player)

	local pb = table.First(CurrentPlaybacks, function(item) return item.Player == pl; end);
	if pb then
		table.RemoveByValue(CurrentPlaybacks, pb);
	end

	pb = {};
	pb.Player = player;
	pb.Entities = SMH.GetEntities(player);
	pb.Position = player.SMHData.Position;
	pb.PlaybackRate = player.SMHData.PlaybackRate;
	pb.PlaybackLength = player.SMHData.PlaybackLength;

	table.insert(CurrentPlaybacks, pb);

end

function SMH.StopPlayback(player)
	local pb = table.First(CurrentPlaybacks, function(item) return item.Player == player; end);
	if pb then
		table.RemoveByValue(CurrentPlaybacks, pb);
	end
end