
local function Record()
	SMH.Menu:RecordFrame();
end

local function NextPosition()
	local pointer = SMH.Menu.Pointer;
	local pos = pointer.Position + 1;
	if pos > SMH.PlaybackLength then
		pos = 0;
	end
	pointer:SetPosition(pos);
end

local function PrevPosition()
	local pointer = SMH.Menu.Pointer;
	local pos = pointer.Position - 1;
	if pos < 0 then
		pos = SMH.PlaybackLength;
	end
	pointer:SetPosition(pos);
end

local function Play()

	local data = {};
	data.Play = true;
	data.Entities = SMH.TouchedEntities;
	data.StartPosition = SMH.Menu.CurrentPosition;
	data.PlaybackRate = SMH.PlaybackRate;
	data.PlaybackLength = SMH.PlaybackLength;

	net.Start("SMHPlayback");
	net.WriteTable(data);
	net.SendToServer();

end

local function Stop()

	local data = {};
	data.Play = false;

	net.Start("SMHPlayback");
	net.WriteTable(data);
	net.SendToServer();

end

concommand.Add("smh_record", Record);
concommand.Add("smh_next", NextPosition);
concommand.Add("smh_previous", PrevPosition);
concommand.Add("+smh_playback", Play);
concommand.Add("-smh_playback", Stop);