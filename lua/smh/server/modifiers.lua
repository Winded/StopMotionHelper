
function SMH.LoadModifiers()

	SMH.Modifiers = {};

	local path = "smh/server/modifiers/";
	local files, dirs = file.Find(path .. "*.lua", "LUA");

	for _, f in pairs(files) do

		_G["MOD"] = {};

		include(path .. f);

		SMH.Modifiers[f:sub(1, -5)] = _G["MOD"];

		_G["MOD"] = nil;

	end

end

SMH.LoadModifiers();