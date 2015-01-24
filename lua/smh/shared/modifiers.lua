
local MODBASE = {};
MODBASE.__index = MODBASE;
MODBASE.Name = "Unnamed";

function MODBASE:Save(player, entity) end
function MODBASE:Load(player, entity, data) end
function MODBASE:LoadGhost(player, entity, ghost, data) end
function MODBASE:LoadBetween(player, entity, data1, data2, percentage) end

function SMH.LoadModifiers()

	SMH.Modifiers = {};

	local path = "smh/modifiers/";
	local files, dirs = file.Find(path .. "*.lua", "LUA");

	for _, f in pairs(files) do

		_G["MOD"] = setmetatable({}, MODBASE);

		include(path .. f);

		SMH.Modifiers[f:sub(1, -5)] = _G["MOD"];

		_G["MOD"] = nil;

	end

end

SMH.LoadModifiers();