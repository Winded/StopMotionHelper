
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Setup()

	local menuVisibilityStream = Rx.Subject.create();
	RxUtils.fromConcommand("+smh_menu"):map(function() return true; end):subscribe(menuVisibilityStream);
	RxUtils.fromConcommand("-smh_menu"):map(function() return false; end):subscribe(menuVisibilityStream);

	concommand.Add("smh_record", function()
		SMH.Data:_Call("Record");
	end);

	concommand.Add("smh_next", function()
		local pos = SMH.Data.Position + 1;
		if pos > SMH.Data.PlaybackLength then
			pos = 0;
		end
		SMH.Data.Position = pos;
	end);

	concommand.Add("smh_previous", function()
		local pos = SMH.Data.Position - 1;
		if pos < 0 then
			pos = SMH.Data.PlaybackLength;
		end
		SMH.Data.Position = pos;
	end);

	concommand.Add("+smh_playback", function()
		SMH.Data:_Call("Play");
	end);

	concommand.Add("-smh_playback", function()
		SMH.Data:_Call("Stop");
	end);

	concommand.Add("smh_onionskin", function()
		SMH.Data.OnionSkin = not SMH.Data.OnionSkin;
	end);

	concommand.Add("smh_quicksave", function()
		SMH.Data:_Call("QuickSave");
	end);

	concommand.Add("smh_makejpeg", function()
		SMH.Data.UseScreenshot = false;
		SMH.Data.Rendering = not SMH.Data.Rendering;
	end);

	concommand.Add("smh_makescreenshot", function()
		SMH.Data.UseScreenshot = true;
		SMH.Data.Rendering = not SMH.Data.Rendering;
	end);

	local data = SMH.Data;
	data:_BindToConVar("FreezeAll", CreateClientConVar("smh_freezeall", "0"), {ValueType = "boolean"});
	data:_BindToConVar("LocalizePhysBones", CreateClientConVar("smh_localizephysbones", "0"), {ValueType = "boolean"});
	data:_BindToConVar("IgnorePhysBones", CreateClientConVar("smh_ignorephysbones", "0"), {ValueType = "boolean"});
	data:_BindToConVar("GhostPrevFrame", CreateClientConVar("smh_ghostprevframe", "0"), {ValueType = "boolean"});
	data:_BindToConVar("GhostNextFrame", CreateClientConVar("smh_ghostnextframe", "0"), {ValueType = "boolean"});
	data:_BindToConVar("GhostAllEntities", CreateClientConVar("smh_ghostallentities", "0"), {ValueType = "boolean"});
	data:_BindToConVar("GhostTransparency", CreateClientConVar("smh_ghosttransparency", "0.5"), {ValueType = "number"});

	return {
		Output = {
			MenuVisibility = menuVisibilityStream,
		}
	};

end

return Setup;