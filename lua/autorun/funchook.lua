
/*
Function hooking system.
SMH.AddNetFunc and we can send functions between client and server with a snap of a finger!
*/

if !SMH then
	SMH = {}
end

if SERVER then

util.AddNetworkString("smhNetFunc");

end

//Net types
local TYPE_NONE 		= 0;
local TYPE_STRING 		= 1;
local TYPE_INT 			= 2;
local TYPE_BYTE 		= 3;
local TYPE_FLOAT 		= 4;
local TYPE_BOOL			= 5;
local TYPE_VECTOR 		= 6;
local TYPE_ANGLE 		= 7;
local TYPE_ENTITY 		= 8;

local function GetNetType(var)
	if type(var) == "string" then
		return TYPE_STRING;
	elseif type(var) == "number" then
		return TYPE_FLOAT;
	elseif type(var) == "Entity" or type(var) == "NPC" or type(var) == "Weapon" or type(var) == "Vehicle" or type(var) == "Player" then
		return TYPE_ENTITY;
	elseif type(var) == "Vector" then
		return TYPE_VECTOR;
	elseif type(var) == "Angle" then
		return TYPE_ANGLE;
	elseif type(var) == "boolean" then
		return TYPE_BOOL;
	else
		return TYPE_NONE;
	end
end
local function WriteNetType(var, type)
	if type == TYPE_STRING then
		net.WriteString(var);
	elseif type == TYPE_FLOAT then
		net.WriteFloat(var);
	elseif type == TYPE_ENTITY then
		net.WriteEntity(var);
	elseif type == TYPE_VECTOR then
		net.WriteVector(var);
	elseif type == TYPE_ANGLE then
		net.WriteAngle(var);
	elseif type == TYPE_BOOL then
		net.WriteBool(var);
	else
		error("Type is invalid.");
	end
end
local function ReadNetType(type)
	local val
	if type == TYPE_STRING then
		val = net.ReadString();
	elseif type == TYPE_FLOAT then
		val = net.ReadFloat();
	elseif type == TYPE_ENTITY then
		val = net.ReadEntity();
	elseif type == TYPE_VECTOR then
		val = net.ReadVector();
	elseif type == TYPE_ANGLE then
		val = net.ReadAngle();
	elseif type == TYPE_BOOL then
		val = net.ReadBool();
	end
	if val == nil then
		error("Read a nil value.");
	end
	return val;
end

function SMH.AddNetFunc(name)
	if type(name) != "string" then error("Name isn't a string!") end
	SMH[name] = function(...) 
		SMH.WriteNetFunc(name, {...});
	end
end

function SMH.ReadNetFunc(length)
	local func = net.ReadString();
	local argcount = net.ReadInt(8);
	
	local args = {};
	for i=1, argcount do
		local type = net.ReadInt(8);
		local val = ReadNetType(type);
		args[i] = val;
	end
	
	SMH[func](unpack(args));
end

function SMH.WriteNetFunc(name, args)
	if type(name) != "string" then ErrorNoHalt("Name isn't a string!"); return; end
	
	for k,v in pairs(args) do
		if v == nil or (type(v) == "Entity" and !IsValid(v)) then
			error(k.." is nil.");
		end
	end
	
	net.Start("smhNetFunc");
	net.WriteString(name);
	net.WriteInt(#args, 8);
	
	for i,v in ipairs(args) do
		local type = GetNetType(v);
		if type == TYPE_NONE then error(k.." is none!") end
		net.WriteInt(type, 8);
		WriteNetType(v, type);
	end
	
	if SERVER then
		net.Send(player.GetAll());
	else
		net.SendToServer();
	end
end

net.Receive("smhNetFunc", SMH.ReadNetFunc);