
if !game.SinglePlayer() then return end

include("shared.lua");

local ShowEnts = false

SMH.AddNetFunc("svAddFrame")
SMH.AddNetFunc("svRemFrame")
SMH.AddNetFunc("svRecFrame")
SMH.AddNetFunc("svClearFrame")
SMH.AddNetFunc("svSetFrame")
SMH.AddNetFunc("svToggleSmooth")
SMH.AddNetFunc("svSetSS")
SMH.AddNetFunc("svSetES")
SMH.AddNetFunc("svSetFramePB")
SMH.AddNetFunc("svEnableGhosts")
SMH.AddNetFunc("svDisableGhosts")
SMH.AddNetFunc("svMoveFrameUp")
SMH.AddNetFunc("svMoveFrameDown")

SMH.PanelFrames = {}

local function UpdateFrames()
	for k,v in pairs(SMH.PanelFrames) do
		if v.FrameID == SMH.CurFrame then
			v:SetText("-")
		else
			v:SetText("")
		end
	end
end

function SMH.CreateKeyframe()
	local k = #SMH.PanelFrames + 1
	local b = vgui.Create("DButton")
	b:SetHeight(10)
	b:SetText("")
	b:SetToolTip(tostring(k))
	b.FrameID = k
	b.DoClick = function(self)
		SMH.CurFrame = self.FrameID
		SMH.SetFrame()
	end
	SMH.PanelFrames[k] = b
	SMH.PFrames:AddItem(SMH.PanelFrames[k])
end
function SMH.RemoveKeyframe()
	local k = #SMH.PanelFrames
	SMH.PanelFrames[k]:Remove()
	SMH.PFrames:RemoveItem(SMH.PanelFrames[k])
	table.remove(SMH.PanelFrames,k)
end
function SMH.GetKeyframeCount()
	return #SMH.PanelFrames
end

function SMH.AddFrame()
	SMH.svAddFrame(SMH.CurFrame)
end
function SMH.clAddFrame(f)
	--[[
	When a frame is added on clientside, it is added to the end of the panel list.
	Why? Because it doesn't matter in what order you put frames clientside,
	all frame setup is done serverside.
	--]]
	SMH.CreateKeyframe()
	SMH.svSetFrame(f+1)
end

function SMH.RemFrame()
	if GetGlobalInt("smhFrameCount") <= 1 then return end
	SMH.svRemFrame(SMH.CurFrame)
end
function SMH.clRemFrame(f)
	SMH.RemoveKeyframe()
	SMH.CurFrame = f-1
	SMH.SetFrame()
end

function SMH.RecFrame()
	SMH.svRecFrame(SMH.CurFrame)
end

function SMH.ClearFrame()
	SMH.svClearFrame(SMH.CurFrame)
end

function SMH.MoveFrameUp()
	SMH.svMoveFrameUp(SMH.CurFrame)
end
function SMH.MoveFrameDown()
	SMH.svMoveFrameDown(SMH.CurFrame)
end

function SMH.SetFrame()
	if SMH.CurFrame <= 0 then return end
	SMH.svSetFrame(SMH.CurFrame)
end
function SMH.clSetFrame(f,Pics/*,smooth*/,ss,es)
	SMH.CurFrame = f
	UpdateFrames()
	RunConsoleCommand("smh_picsadd",Pics)
	//RunConsoleCommand("smh_moverounded",tostring(smooth))
	RunConsoleCommand("smh_startslow",tostring(ss))
	RunConsoleCommand("smh_endslow",tostring(es))
end

function SMH.clSelectEnt(ent)
	if !IsValid(ent) then error("shit") end
	table.insert(SMH.Ents,ent)
end

function SMH.clDeselectEnt(ent)
	for k,v in pairs(SMH.Ents) do
		if v == ent then
			table.remove(SMH.Ents,k)
		end
	end
end

-- function SMH.clLoadAddEnt(ent,slot)
	-- table.insert(SMH.Ents,slot,ent)
-- end
-- function SMH.clLoad(Framecount)
	-- if #SMH.PanelFrames > 0 then
		-- for i=1,#SMH.PanelFrames do
			-- SMH.RemoveKeyframe()
		-- end
	-- end
	-- for i=1,Framecount do
		-- SMH.CreateKeyframe()
	-- end
-- end

net.Receive("smhClientLoad", function(len)
	local ecount = net.ReadInt(32);
	
	for i=1, ecount do
		local v = net.ReadEntity();
		table.insert(SMH.Ents, v);
	end
	
	local framecount = net.ReadInt(32);
	
	if #SMH.PanelFrames > 0 then
		for i=1,#SMH.PanelFrames do
			SMH.RemoveKeyframe()
		end
	end
	for i=1,framecount do
		SMH.CreateKeyframe()
	end
end)

-- function SMH.RenderScreenspaceEffects()
	-- if ShowEnts and GetConVar("smh_wf_enable"):GetInt() != 0 then
		-- cam.Start3D(LocalPlayer():EyePos(),LocalPlayer():EyeAngles())
		-- for k,e in pairs(SMH.Ents) do
			-- if e != NULL and e:IsValid() then
				-- local r,g,b,a = e:GetColor()
				-- local mat = e:GetMaterial()
				-- render.SuppressEngineLighting( true )
				-- local col =
				-- {
					-- r = GetConVar("smh_wf_r"):GetFloat(),
					-- g = GetConVar("smh_wf_g"):GetFloat(),
					-- b = GetConVar("smh_wf_b"):GetFloat()
				-- }
				-- render.SetColorModulation(col.r,col.g,col.b)
				-- e:SetMaterial("models/wireframe")
				-- e:SetModelScale(Vector(1.05,1.05,1.05))
				-- e:DrawModel()
				-- e:SetMaterial(mat)
				-- e:SetModelScale(Vector(1,1,1))
				-- render.SuppressEngineLighting( false )
				-- render.SetColorModulation(1,1,1)
			-- else
				-- table.remove(SMH.Ents,k)
			-- end
		-- end
		-- cam.End3D()
	-- end
-- end
-- hook.Add("RenderScreenspaceEffects","smhRenderScreenspaceEffects",SMH.RenderScreenspaceEffects)

SMH.ShowEnts = false;

-- Most taken from lua/includes/modules/halo.lua
local matColor	= Material( "model_color" )
local mat_Copy	= Material( "pp/copy" )
local mat_Add	= Material( "pp/add" )
local mat_Sub	= Material( "pp/sub" )
local rt_Stencil	= render.GetBloomTex0()
local rt_Store		= render.GetScreenEffectTexture( 0 )
function SMH.RenderHalo()
	if SMH.ShowEnts and GetConVar("smh_wf_enable"):GetInt() != 0 then

		local OldRT = render.GetRenderTarget()
		
		-- Copy what's currently on the screen to another texture
		render.CopyRenderTargetToTexture( rt_Store )
		
		-- Clear the colour and the stencils, not the depth
		-- if ( entry.Additive ) then			
			render.Clear( 0, 0, 0, 255, false, true )
		-- else
			-- render.Clear( 255, 255, 255, 255, false, true )
		-- end
			
		
		-- FILL STENCIL
		-- Write to the stencil..		
		cam.Start3D( EyePos(), EyeAngles() )
		
			-- cam.IgnoreZ( entry.IgnoreZ )
			cam.IgnoreZ( false )
			render.OverrideDepthEnable( true, false )									-- Don't write depth
			
			render.SetStencilEnable( true );
			render.SetStencilFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilPassOperation( STENCILOPERATION_REPLACE );
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS );
			render.SetStencilWriteMask( 1 );
			render.SetStencilReferenceValue( 1 );
			
			render.SetBlend( 0 ); -- don't render any colour
			
			for k, v in pairs( SMH.Ents ) do
			
				if ( !IsValid( v ) ) then continue end
				
				render.PushFlashlightMode( true )
					v:DrawModel()
				render.PopFlashlightMode()
			
			end
				
		cam.End3D()	
		
		-- FILL COLOUR
		-- Write to the colour buffer
		cam.Start3D( EyePos(), EyeAngles() )

			render.MaterialOverride( matColor )			
			cam.IgnoreZ( false )
			
			render.SetStencilEnable( true );
			render.SetStencilWriteMask( 0 );
			render.SetStencilReferenceValue( 0 );
			render.SetStencilTestMask( 1 );
			render.SetStencilFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilPassOperation( STENCILOPERATION_KEEP );
			render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL );
			
			for k, v in pairs( SMH.Ents ) do
				
				if ( !IsValid( v ) ) then continue end
				
				local r = GetConVar("smh_wf_r"):GetFloat();
				local g = GetConVar("smh_wf_g"):GetFloat();
				local b = GetConVar("smh_wf_b"):GetFloat();
				local a = 1;
				
				render.SetColorModulation( r, g, b )
				render.SetBlend( a );

				v:DrawModel()
				
			end
				
			render.MaterialOverride( nil )
			render.SetStencilEnable( false );

		cam.End3D()
		
		-- BLUR IT
			render.CopyRenderTargetToTexture( rt_Stencil )
			render.OverrideDepthEnable( false, false )
			render.SetStencilEnable( false );
			render.BlurRenderTarget( rt_Stencil, 2, 2, 1 )
		
		-- Put our scene back
			render.SetRenderTarget( OldRT )
			render.SetColorModulation( 1, 1, 1 )
			render.SetStencilEnable( false );
			render.OverrideDepthEnable( true, false )
			render.SetBlend( 1 );
			mat_Copy:SetTexture( "$basetexture", rt_Store )
			render.SetMaterial( mat_Copy )
			render.DrawScreenQuad()
			
		
		-- DRAW IT TO THE SCEEN

			render.SetStencilEnable( true );
			render.SetStencilWriteMask( 0 );
			render.SetStencilReferenceValue( 0 );
			render.SetStencilTestMask( 1 );
			render.SetStencilFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilPassOperation( STENCILOPERATION_KEEP );
			render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL );
				
			-- if ( entry.Additive ) then	
				mat_Add:SetTexture( "$basetexture", rt_Stencil )
				render.SetMaterial( mat_Add )
			-- else
				-- mat_Sub:SetTexture( "$basetexture", rt_Stencil )
				-- render.SetMaterial( mat_Sub )
			-- end
			
			for i=0, 2 do
				render.DrawScreenQuad()
			end
		
		-- PUT EVERYTHING BACK HOW WE FOUND IT

			render.SetStencilWriteMask( 0 );
			render.SetStencilReferenceValue( 0 );
			render.SetStencilTestMask( 0 );
			render.SetStencilEnable( false )
			render.OverrideDepthEnable( false )
			render.SetBlend( 1 )
			
			cam.IgnoreZ( false )

	end
end
hook.Add("PostDrawEffects","smhRenderHalo",SMH.RenderHalo);

include("client/menu.lua");

Msg("SMH client initialized.\n")
