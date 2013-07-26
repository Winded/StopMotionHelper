
include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetNotSolid(true)
	self:SetPos(Vector(0,0,0))
	self:SetAngles(Angle(0,0,0))
	self:DrawShadow(false);
end

function ENT:SetPlayer(ply)
	self:SetNWEntity("Player",ply)
end

function ENT:ValidateModel(ent)
	if self:GetModel() != ent:GetModel() then
		self:SetModel(ent:GetModel())
	end
	if self:GetColor() != Color(255,255,255,200) then
		self:SetColor(255,255,255,200)
	end
	if self:GetSkin() != ent:GetSkin() then
		self:SetSkin(ent:GetSkin())
	end
	for i=1,32 do
		self:SetBodygroup(i,ent:GetBodygroup(i))
	end
	
	self.BoneOrigins = {};
	local pp, pa = self:GetPos(), self:GetAngles();
	for i=0, self:GetBoneCount()-1 do
		local p,a = self:GetBonePosition(i);
		local pos,ang = WorldToLocal(p, a, pp, pa);
		self.BoneOrigins[i] = {pos = pos, ang = ang};
	end
end

function ENT:GetBoneOrigin(bone)
	local lp, la = self.BoneOrigins[bone].pos, self.BoneOrigins[bone].ang;
	local p, a = self:GetPos(),self:GetAngles();
	local pos, ang = LocalToWorld(lp, la, p, a);
	return pos, ang;
end

function ENT:SetBone(bone, pos, ang)
	if bone >= self:GetBoneCount() then return end
	local op, oa = self:GetBoneOrigin(bone);
	local lp, la = WorldToLocal(pos, ang, op, oa);
	self:ManipulateBonePosition(bone, lp);
	self:ManipulateBoneAngles(bone, la);
end

function ENT:Think()
end