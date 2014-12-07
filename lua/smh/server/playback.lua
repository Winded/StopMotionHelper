
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

net.Receive("SMHPlayback", function(len, pl)

	local data = net.ReadTable();
	local pb = table.First(CurrentPlaybacks, function(item) return item.Player == pl; end);

	if data.Play then
		
		if not pb then
			pb = {};
			pb.Player = pl;
		end

		pb.Entities = data.Entities;
		pb.Position = data.StartPosition;
		pb.PlaybackRate = data.PlaybackRate;
		pb.PlaybackLength = data.PlaybackLength;

		table.insert(CurrentPlaybacks, pb);

	else
		if pb then
			table.RemoveByValue(CurrentPlaybacks, pb);
		end
	end

end);