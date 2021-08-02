local MODBASE = {}
MODBASE.__index = MODBASE
MODBASE.Name = "Unnamed"

function MODBASE:Save(entity) end
function MODBASE:Load(entity, data, settings) end
function MODBASE:LoadGhost(entity, ghost, data, settings) end
function MODBASE:LoadBetween(entity, data1, data2, percentage, settings) end

SMH.Modifiers = {}

local path = "smh/modifiers/"
local files, dirs = file.Find(path .. "*.lua", "LUA")

for _, f in pairs(files) do

	_G["MOD"] = setmetatable({}, MODBASE)

	include(path .. f)

	SMH.Modifiers[f:sub(1, -5)] = _G["MOD"]

	_G["MOD"] = nil

end