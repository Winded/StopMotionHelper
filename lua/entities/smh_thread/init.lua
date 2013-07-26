
AddCSLuaFile("cl_init.lua");

ENT.Type = "anim"

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetColor(Color(255,255,255,0));
	self:DrawShadow(false);
end

function ENT:Think()
	if SMH.ThreadUpdate then
		if self.Ents != SMH.Ents
		or (self.Ents and SMH.Ents and #self.Ents != #SMH.Ents)then
			self:UpdateEnts();
		end
		if self.frames != SMH.frames
		or (self.frames and SMH.frames and #self.frames != #SMH.frames) then
			self:UpdateFrames();
		end
	end
end

function ENT:UpdateEnts()
	if SMH.ThreadUpdate then
		self.Ents = SMH.Ents
		
		if self.Ents then
			self:SetNetworkedInt("EntCount", #self.Ents);
			for i,v in ipairs(self.Ents) do
				self:SetNetworkedEntity("Ent"..i, v);
			end
		end
	end
end

function ENT:UpdateFrames()
	if SMH.ThreadUpdate then
		self.frames = SMH.frames

		if self.frames then
			self:SetNetworkedInt("FrameCount", #self.frames);
			for i,v in ipairs(self.frames) do
				self:SetNetworkedInt("Frame_"..i.."_Pics", v.Pics);
				self:SetNetworkedFloat("Frame_"..i.."_StartSlow", v.StartSlow);
				self:SetNetworkedFloat("Frame_"..i.."_EndSlow", v.EndSlow);
			end
		end
	end
end

function ENT:GetEnts()
	local RT = {};
	
	local count = self:GetNetworkedInt("EntCount", 0);
	
	for i=1, count do
		local v = self:GetNetworkedEntity("Ent"..i, NULL);
		
		if IsValid(v) then
			table.insert(RT,v);
		end
	end
	
	return RT;
end

function ENT:GetFrames()
	local RT = {};
	
	local count = self:GetNetworkedInt("FrameCount", 0);
	
	for i=1, count do
		local pics = self:GetNetworkedInt("Frame_"..i.."_Pics", 1);
		local ss = self:GetNetworkedInt("Frame_"..i.."_StartSlow", 0);
		local es = self:GetNetworkedInt("Frame_"..i.."_EndSlow", 0);
		
		table.insert(RT,{Pics = pics, StartSlow = ss, EndSlow = es});
	end
	
	return RT;
end