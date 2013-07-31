
if !game.SinglePlayer() then return end

-- Even though SMH (and the other tools) are meant for singleplayer,
-- you should know that serverside and clientside differences still matter.
-- Why? Its just the way source engine works. And it makes things more simple than more complicated.

if !SMH then
	SMH = {}
end

SMH.Ents = {}

SMH.CurFrame = 1

SMH.ThreadUpdate = false

-- Initializing all convars, although all of them aren't needed right away
CreateConVar("smh_picsadd",9,{FCVAR_REPLICATED})
CreateConVar("smh_cycletick",0.2,{FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("smh_moverounded",0,{FCVAR_REPLICATED})
CreateConVar("smh_startslow",0.0,{FCVAR_REPLICATED})
CreateConVar("smh_endslow",0.0,{FCVAR_REPLICATED})
CreateConVar("smh_freezeall",0,{FCVAR_REPLICATED})
CreateConVar("smh_saveonadd",0,{FCVAR_REPLICATED})
CreateConVar("smh_localized",0,{FCVAR_REPLICATED})
CreateConVar("smh_ghost_enable",1,{FCVAR_REPLICATED})

CreateConVar("smh_wf_r",0.0,{FCVAR_REPLICATED})
CreateConVar("smh_wf_g",1.0,{FCVAR_REPLICATED})
CreateConVar("smh_wf_b",0.0,{FCVAR_REPLICATED})
CreateConVar("smh_wf_enable",1,{FCVAR_REPLICATED})

-- Fix bone manipulations.
hook.Add("PlayerSpawnedRagdoll","smhRagdollFix",
function(pl,mdl,rag)
	for i=0,rag:GetBoneCount()-1 do
		rag:ManipulateBonePosition(i,Vector(0,0,0));
		rag:ManipulateBoneAngles(i,Angle(0,0,0));
		rag:ManipulateBoneScale(i,Vector(1,1,1));
	end
end)
hook.Add("PlayerSpawnedRagdoll","smhRagdollFix",
function(pl,mdl,prop)
	for i=0,prop:GetBoneCount()-1 do
		prop:ManipulateBonePosition(i,Vector(0,0,0));
		prop:ManipulateBoneAngles(i,Angle(0,0,0));
		prop:ManipulateBoneScale(i,Vector(1,1,1));
	end
end)

-- SMH entity functions
local ENT = FindMetaTable("Entity")
local FingersAll = 5 * 3 * 2

-- This is for easier phys bone parent receiving, so you dont have to do many steps always
function ENT:GetPhysBoneParent(bone)
	local b = self:TranslatePhysBoneToBone(bone)
	local parent = self:GetBoneParent(b)
	return self:TranslateBoneToPhysBoneNew(parent)
end

-- These are used to manage the entity's ghost
function ENT:smhAddGhost()
	if self.smhGhost then
		self.smhGhost:Remove()
		self.smhGhost = nil
	end
	local e = NULL
	if self:GetClass() == "prop_ragdoll" then
		e = ents.Create("prop_ragdoll")
	else
		e = ents.Create("prop_physics")
	end
	e:SetModel(self:GetModel())
	e:SetNotSolid(true)
	e:SetColor(Color(255,255,255,0))
	e:SetPos(Vector(0,0,0))
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	e:Spawn()
	e:DrawShadow(false)
	e:SetNotSolid(true)
	for i=0,self:GetPhysicsObjectCount()-1 do
		e:GetPhysicsObjectNum(i):EnableMotion(false)
		e:GetPhysicsObjectNum(i):Wake()
	end
	self.smhGhost = e
end
function ENT:smhRemoveGhost()
	if self.smhGhost then
		self.smhGhost:Remove()
		self.smhGhost = nil
	end
end
function ENT:smhEnableGhost()
	if self.smhGhost then
		self.smhGhost:SetColor(Color(255,255,255,150))
	end
end
function ENT:smhDisableGhost()
	if self.smhGhost then
		self.smhGhost:SetColor(Color(255,255,255,0))
		self.smhGhost:DrawShadow(false);
	end
end
function ENT:smhSetGhostFrame(f)
--	if !GetConVar("smh_ghost_enable"):GetBool() then
--		self:smhDisableGhost()
--		return
--	end
--	if !IsValid(self.smhGhost) then return end
--	local FT = self.smhFrames[f-1]
--	if !FT then
--		self:smhDisableGhost()
--		return
--	end
--	if table.Count(FT) <= 0 then
--		self:smhDisableGhost()
--		return
--	end
--	for i=0,self:GetPhysicsObjectCount()-1 do
--		local bone = self.smhGhost:GetPhysicsObjectNum(i)
--		local b = self.smhGhost:TranslatePhysBoneToBone(i)
--		bone:SetPos(FT["bone"..i].Pos)
--		bone:SetAngles(FT["bone"..i].Ang)
--		self.smhGhost:SetNWInt("InflateSize"..b,FT["bone"..i].Inf)
--		bone:EnableMotion(false)
--		bone:Wake()
--	end
--	for i=0,self.smhGhost:GetBoneCount()-1 do
--		if self.smhGhost:TranslateBoneToPhysBoneNew(i) == -1 then
--			local T = FT["mbone"..i];
--			self.smhGhost:ManipulateBonePosition(i,T.Vector);
--			self.smhGhost:ManipulateBoneAngles(i,T.Angle);
--			self.smhGhost:ManipulateBoneScale(i,T.Scale);
--		end
--	end
--	self.smhGhost:SetFlexScale(FT["flexscale"])
--	for i=0,self:GetFlexNum()-1 do
--		self.smhGhost:SetFlexWeight(i,FT["flex"..i])
--	end
--	self.smhGhost:SetEyeTarget(FT["eyes"])
--	for k,v in pairs(FT["posep"]) do
--		self.smhGhost:SetPoseParameter(k,v)
--		self.smhGhost:GetPhysicsObject():Wake()
--	end
--	for i=1,32 do
--		self.smhGhost:SetBodygroup(i,self:GetBodygroup(i))
--	end
--	self.smhGhost:SetSkin(self:GetSkin())
end

-- Adding a frame for the entity
function ENT:smhAddFrame(f)
	table.insert(self.smhFrames,f+1,{})
	if GetConVar("smh_saveonadd"):GetInt() != 0 then
		self:smhRecFrame(f+1)
	end
end

-- Removing frame
function ENT:smhRemFrame(f)
	table.remove(self.smhFrames,f)
end

-- Recording
function ENT:smhRecFrame(frame)

	-- NEW CODE
	local FT = {};

	for name, mod in pairs(SMH.Modifiers) do
		FT[name] = mod:Save(self);
	end

	self.smhFrames[frame] = FT;

	return;

--	local FT = {}
--	//Bones (position,angle and inflate size)
--	for i=0,self:GetPhysicsObjectCount()-1 do
--		local Ref = self:GetPhysicsObjectNum(i)
--		local b = self:TranslatePhysBoneToBone(i)
--		local T = {};
--		T.Pos = Ref:GetPos()
--		T.Ang = Ref:GetAngles()
--		if i != 0 then
--			local mb = self:GetPhysicsObjectNum(self:GetPhysBoneParent(i))
--			if mb then
--				local pos,ang = WorldToLocal(Ref:GetPos(),Ref:GetAngles(),mb:GetPos(),mb:GetAngles())
--				T.OffPos = pos
--				T.OffAng = ang
--			end
--		end
--		T.Freezed = !Ref:IsMoveable()
--		T.Inf = self:GetManipulateBoneScale(b);
--		FT["bone"..i] = T;
--	end
--	//Bone manipulations. For non-physical bones.
--	for i=0,self:GetBoneCount()-1 do
--		if self:TranslateBoneToPhysBoneNew(i) == -1 then
--			local T = {};
--			T.Vector = self:GetManipulateBonePosition(i);
--			T.Angle = self:GetManipulateBoneAngles(i);
--			T.Scale = self:GetManipulateBoneScale(i);
--			FT["mbone"..i] = T;
--		end
--	end
--	//Flex scale and flexes
--	FT["flexscale"] = self:GetFlexScale()
--	for i=0,self:GetFlexNum()-1 do
--		FT["flex"..i] = self:GetFlexWeight(i)
--	end
--	//Eyes
--	FT["eyes"] = self:GetEyeTarget()
--	//Color
--	FT["color"] = self:GetColor()
--	//Pose parameters
--	FT["posep"] = {}
--	for k,v in pairs(self:GetPoseParams()) do
--		FT["posep"][v] = self:GetPoseParameter(v)
--	end
--	FT["posep"]["aim_pitch"] = self:GetPoseParameter("aim_pitch")
--	FT["posep"]["aim_yaw"] = self:GetPoseParameter("aim_yaw")
--	//E. A. S. Attachments
--	if self.easWelds then
--		for k,v in pairs(self.easWelds) do
--			FT["eas"..k] = {}
--			FT["eas"..k].Pos = v:GetNWVector("EAS_Pos")
--			FT["eas"..k].Ang = v:GetNWAngle("EAS_Ang")
--			FT["eas"..k].Color = v:GetColor()
--			FT["eas"..k].Scale = v:GetNWVector("EAS_Scale",Vector(1,1,1))
--		end
--	end
--	self.smhFrames[f] = FT
end

-- Clearing
function ENT:smhClearFrame(f)
	table.Empty(self.smhFrames[f])
end

-- Clearing all. This is used by the selector when pressing Reload
function ENT:smhClearFrames()
	table.Empty(self.smhFrames)
end

function ENT:smhMoveFrameUp(f)
	local FT = table.Copy(self.smhFrames[f])
	table.remove(self.smhFrames,f)
	table.insert(self.smhFrames,f-1,FT)
end
function ENT:smhMoveFrameDown(f)
	local FT = self.smhFrames[f]
	table.remove(self.smhFrames,f)
	table.insert(self.smhFrames,f+1,FT)
end

-- Setting to a certain frame
function ENT:smhSetFrame(frame)

	if not self.smhFrames[frame] then return; end
	local FT = self.smhFrames[frame];

	for name, mod in pairs(SMH.Modifiers) do
		if FT[name] then
			mod:Load(self, FT[name]);
		end
	end

	return;

--	//If the frame doesnt exist or its size is 0 entries (Empty frame), we return from the function
--	if !self.smhFrames[f] then return end
--	local FT = self.smhFrames[f]
--	if table.Count(FT) <= 0 then return end
--	//Phys bone indexing starts from 0, so the actual final phys bone is physobject count - 1
--	for i=0,self:GetPhysicsObjectCount()-1 do
--		local T = FT["bone"..i];
--		local Ref = self:GetPhysicsObjectNum(i)
--		local b = self:TranslatePhysBoneToBone(i)
--		local parent = self:GetPhysicsObjectNum(self:GetPhysBoneParent(i))
--		Ref:EnableMotion(true)
--		Ref:Sleep()
--		Ref:SetPos(T.Pos)
--		Ref:SetAngles(T.Ang)
--		self:ManipulateBoneScale(b,T.Inf);
--	end
--	for i=0,self:GetPhysicsObjectCount()-1 do
--		if FT["bone"..i].Freezed or GetConVar("smh_freezeall"):GetInt() == 1 then
--			self:GetPhysicsObjectNum(i):EnableMotion(false)
--		end
--		self:GetPhysicsObjectNum(i):Wake()
--	end
--	for i=0,self:GetBoneCount()-1 do
--		if self:TranslateBoneToPhysBoneNew(i) == -1 then
--			local T = FT["mbone"..i];
--			self:ManipulateBonePosition(i,T.Vector);
--			self:ManipulateBoneAngles(i,T.Angle);
--			self:ManipulateBoneScale(i,T.Scale);
--		end
--	end
--	self:SetFlexScale(FT["flexscale"])
--	for i=0,self:GetFlexNum()-1 do
--		self:SetFlexWeight(i,FT["flex"..i])
--	end
--	self:SetEyeTarget(FT["eyes"])
--	self:SetColor(FT["color"])
--	for k,v in pairs(FT["posep"]) do
--		self:SetPoseParameter(k,v)
--		self:GetPhysicsObject():Wake()
--	end
--	if self.easWelds then
--		for k,v in pairs(self.easWelds) do
--			if FT["eas"..k] then
--				v:SetNWVector("EAS_Pos",FT["eas"..k].Pos)
--				v:SetNWAngle("EAS_Ang",FT["eas"..k].Ang)
--				v:SetColor(FT["eas"..k].Color)
--				v:SetNWVector("EAS_Scale",FT["eas"..k].Scale)
--			end
--		end
--	end
end

-- Setting a picture between frame and next frame
function ENT:smhSetPic(f,p/*,middle*/,ss,es)

	if not self.smhFrames[f] then return; end
	local FT = self.smhFrames[f];
	local FT2 = {};
	if not self.smhFrames[f + 1] then
		FT2 = FT;
	else
		FT2 = self.smhFrames[f + 1];
	end

	for name, mod in pairs(SMH.Modifiers) do

		if FT[name] and FT2[name] then
			mod:LoadBetween(self, FT[name], FT2[name], p);
		end

	end

	return;

--	if !self.smhFrames[f] then return end
--	local FT = self.smhFrames[f]
--	if table.Count(FT) <= 0 then return end
--	local FT2 = {}
--	if !self.smhFrames[f+1] or table.Count(self.smhFrames[f+1]) <= 0 then
--		FT2 = FT
--	else
--		FT2 = self.smhFrames[f+1]
--	end
--	p = math.EaseInOut(p,ss,es)
--	for k,v in pairs(FT["posep"]) do
--		if FT2["posep"][k] then
--			local val = Lerp(p,v,FT2["posep"][k])
--			self:SetPoseParameter(k,val)
--			self:GetPhysicsObject():Wake()
--		end
--	end
--	if self:GetClass() == "prop_physics" then
--		local obj = self:GetPhysicsObject()
--		local pos = LerpVector(p,FT["bone0"].Pos,FT2["bone0"].Pos)
--		local ang = LerpAngle(p,FT["bone0"].Ang,FT2["bone0"].Ang)
--		obj:EnableMotion(true)
--		obj:Wake()
--		obj:SetPos(pos)
--		obj:SetAngles(ang)
--		obj:EnableMotion(false)
--		obj:Wake()
--		return
--	end
--	//Using EAS the weld clipping bug is gone. Finally!
--	for b=0,self:GetBoneCount()-1 do
--		local i = self:TranslateBoneToPhysBoneNew(b)
--		if i > -1 then
--			local parent = self:GetBoneParent(b)
--			local Ref = self:GetPhysicsObjectNum(i)
--			local pos,ang,inf
--			local mb = self:GetPhysicsObjectNum(self:GetPhysBoneParent(i))
--			if mb and i != 0 and GetConVar("smh_localized"):GetBool() then
--				pos = LerpVector(p,FT["bone"..i].OffPos,FT2["bone"..i].OffPos)
--				ang = LerpAngle(p,FT["bone"..i].OffAng,FT2["bone"..i].OffAng)
--				local _pos,_ang = LocalToWorld(pos,ang,mb:GetPos(),mb:GetAngles())
--				pos = _pos
--				ang = _ang
--			else
--				pos = LerpVector(p,FT["bone"..i].Pos,FT2["bone"..i].Pos)
--				ang = LerpAngle(p,FT["bone"..i].Ang,FT2["bone"..i].Ang)
--			end
--			inf = LerpVector(p,FT["bone"..i].Inf,FT2["bone"..i].Inf)
--			Ref:EnableMotion(true)
--			Ref:Sleep()
--			Ref:SetPos(pos)
--			Ref:SetAngles(ang)
--			self:ManipulateBoneScale(b,inf);
--		end
--	end
--	for i=0,self:GetPhysicsObjectCount()-1 do
--		self:GetPhysicsObjectNum(i):EnableMotion(false)
--		self:GetPhysicsObjectNum(i):Wake()
--	end
--	for i=0,self:GetBoneCount()-1 do
--		if self:TranslateBoneToPhysBoneNew(i) == -1 then
--			local T = FT["mbone"..i];
--			local T2 = FT2["mbone"..i];
--			local Vector = LerpVector(p,T.Vector,T2.Vector);
--			local Angle = LerpAngle(p,T.Angle,T2.Angle);
--			local Scale = LerpVector(p,T.Scale,T2.Scale);
--			self:ManipulateBonePosition(i,Vector);
--			self:ManipulateBoneAngles(i,Angle);
--			self:ManipulateBoneScale(i,Scale);
--		end
--	end
--	local scale = Lerp(p,FT["flexscale"],FT2["flexscale"])
--	self:SetFlexScale(scale)
--	for i=0,self:GetFlexNum()-1 do
--		local flex = Lerp(p,FT["flex"..i],FT2["flex"..i])
--		self:SetFlexWeight(i,flex)
--	end
--	local eyes = LerpVector(p,FT["eyes"],FT2["eyes"])
--	self:SetEyeTarget(eyes)
--	local r = Lerp(p,FT["color"].r,FT2["color"].r)
--	local g = Lerp(p,FT["color"].g,FT2["color"].g)
--	local b = Lerp(p,FT["color"].b,FT2["color"].b)
--	local a = Lerp(p,FT["color"].a,FT2["color"].a)
--	self:SetColor(Color(r,g,b,a))
--	if self.easWelds then
--		for k,v in pairs(self.easWelds) do
--			if FT["eas"..k] and FT2["eas"..k] then
--				local pos = LerpVector(p,FT["eas"..k].Pos,FT2["eas"..k].Pos)
--				local ang = LerpAngle(p,FT["eas"..k].Ang,FT2["eas"..k].Ang)
--				local colr = Lerp(p,FT["eas"..k].Color.r,FT2["eas"..k].Color.r)
--				local colg = Lerp(p,FT["eas"..k].Color.g,FT2["eas"..k].Color.g)
--				local colb = Lerp(p,FT["eas"..k].Color.b,FT2["eas"..k].Color.b)
--				local cola = Lerp(p,FT["eas"..k].Color.a,FT2["eas"..k].Color.a)
--				local scale = LerpVector(p,FT["eas"..k].Scale,FT2["eas"..k].Scale)
--				v:SetNWVector("EAS_Pos",pos)
--				v:SetNWAngle("EAS_Ang",ang)
--				v:SetColor(Color(colr,colg,colb,cola))
--				v:SetNWVector("EAS_Scale",scale)
--			end
--		end
--	end
end

local function smhRemoveEntHook(self)
	if self.smhGhost then
		self.smhGhost:Remove()
		self.smhGhost = nil
	end
	if table.HasValue(SMH.Ents,self) then
		for k,v in pairs(SMH.Ents) do
			if v == self then
				table.remove(SMH.Ents,k)
				SMH.clDeselectEnt(v)
				break
			end
		end
	end
end
hook.Add("EntityRemoved","smhRemoveEntHook",smhRemoveEntHook)

-- Saving entity frame data, AKA writing a file with GLON encoded string from entity's frame table
function ENT:smhSave(fn)
	file.Write("smh_saves/"..fn..".txt",glon.encode(self.smhFrames))
end

-- Loading encoded frame data file
function ENT:smhLoad(fn)
	local File = file.Read("smh_saves/"..fn..".txt")
	if !File then return end
	local Frames = glon.decode(File)
	if !self.smhFrames then
		self.smhFrames = {}
	end
	self.smhFrames = Frames
end