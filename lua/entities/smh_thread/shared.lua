
ENT.Type = "anim";
ENT.Base = "base_entity";

function ENT:SharedInitialize()

	self:SetNetFuncs({
		"AddFrame",
		"RemoveFrame",
		"RecordFrame",
		"ClearFrame",
		"MoveFrame",
	});

end

function ENT:SetNetFuncs(list)

	nf = {};

	for k, name in pairs(list) do

		nf[name] = function(...)
			self:SendNetFunc(name, {...})
		end

	end

	self.netfuncs = nf;

end

function ENT:SendNetFunc(name, args)

	net.Start("smh_thread_netfunc");

	net.WriteEntity(self);

	net.WriteString(name);

	for i, v in pairs(args) do

		net.WriteInt(i, 8);

		net.WriteType(v);

	end

	if SERVER then

		net.Send(self.player);

	else

		net.SendToServer();

	end

end