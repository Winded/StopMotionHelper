
include("shared.lua")

function ENT:Initialize()
	self.m_bRagdollSetup = true
	self.LastUpdate = 0
end

function ENT:Think()
	-- self:DrawTranslucent()
	-- if CurTime() >= self.LastUpdate + 0.1 then
		-- self:InvalidateBoneCache()
		-- self.LastUpdate = CurTime()
	-- end
end

function ENT:Draw()
	-- local pos = self:GetNWVector("Bone0Pos",Vector(0,0,0))
	-- local ang = self:GetNWAngle("Bone0Ang",Angle(0,0,0))
	-- self:SetRenderOrigin(pos)
	-- self:SetRenderAngles(ang)
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

-- function ENT:DoRagdollBone(physbone,bone)
	-- local pos = self:GetNWVector("Bone"..bone.."Pos",Vector(0,0,0))
	-- local ang = self:GetNWAngle("Bone"..bone.."Ang",Angle(0,0,0))
	-- self:SetBonePosition(bone,pos,ang)
-- end