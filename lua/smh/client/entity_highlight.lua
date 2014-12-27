

-- Most taken from lua/includes/modules/halo.lua
local matColor	= Material( "model_color" )
local mat_Copy	= Material( "pp/copy" )
local mat_Add	= Material( "pp/add" )
local mat_Sub	= Material( "pp/sub" )
local rt_Stencil	= render.GetBloomTex0()
local rt_Store		= render.GetScreenEffectTexture( 0 )
function SMH.RenderHalo()

	local entity = SMH.Data.Entity;
	local highlight = SMH.WorldClicker:IsVisible();
	if not IsValid(entity) or not highlight then
		return;
	end

	local OldRT = render.GetRenderTarget()
	
	-- Copy what's currently on the screen to another texture
	render.CopyRenderTargetToTexture( rt_Store )
	
	-- Clear the colour and the stencils, not the depth
	render.Clear( 0, 0, 0, 255, false, true )
		
	
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
			
		render.PushFlashlightMode( true )
		entity:DrawModel()
		render.PopFlashlightMode()
			
	cam.End3D()	
	
	-- FILL COLOUR
	-- Write to the colour buffer
	cam.Start3D( EyePos(), EyeAngles() );

		render.MaterialOverride( matColor )	;
		cam.IgnoreZ( false );
		
		render.SetStencilEnable( true );
		render.SetStencilWriteMask( 0 );
		render.SetStencilReferenceValue( 0 );
		render.SetStencilTestMask( 1 );
		render.SetStencilFailOperation( STENCILOPERATION_KEEP );
		render.SetStencilPassOperation( STENCILOPERATION_KEEP );
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL );
		
		render.SetColorModulation(0, 1, 0);
		render.SetBlend(1);

		entity:DrawModel();
			
		render.MaterialOverride(nil);
		render.SetStencilEnable(false);

	cam.End3D()
	
	-- BLUR IT
	render.CopyRenderTargetToTexture( rt_Stencil )
	render.OverrideDepthEnable( false, false )
	render.SetStencilEnable( false );
	render.BlurRenderTarget( rt_Stencil, 2, 2, 1 )
	
	-- Put our scene back
	render.SetRenderTarget( OldRT );
	render.SetColorModulation( 1, 1, 1 );
	render.SetStencilEnable( false );
	render.OverrideDepthEnable( true, false );
	render.SetBlend( 1 );
	mat_Copy:SetTexture( "$basetexture", rt_Store );
	render.SetMaterial( mat_Copy );
	render.DrawScreenQuad();
		
	
	-- DRAW IT TO THE SCEEN

	render.SetStencilEnable( true );
	render.SetStencilWriteMask( 0 );
	render.SetStencilReferenceValue( 0 );
	render.SetStencilTestMask( 1 );
	render.SetStencilFailOperation( STENCILOPERATION_KEEP );
	render.SetStencilPassOperation( STENCILOPERATION_KEEP );
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL );
		
	mat_Add:SetTexture( "$basetexture", rt_Stencil );
	render.SetMaterial( mat_Add );
	
	for i=0, 2 do
		render.DrawScreenQuad();
	end
	
	-- PUT EVERYTHING BACK HOW WE FOUND IT

	render.SetStencilWriteMask( 0 );
	render.SetStencilReferenceValue( 0 );
	render.SetStencilTestMask( 0 );
	render.SetStencilEnable( false );
	render.OverrideDepthEnable( false );
	render.SetBlend( 1 );

	cam.IgnoreZ( false );

end
hook.Add("PostDrawEffects","smhRenderHalo",SMH.RenderHalo);