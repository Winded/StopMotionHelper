-- Most taken from lua/includes/modules/halo.lua
-- https://github.com/Facepunch/garrysmod/blob/e47ac049d026f922867ee3adb2c4746fb1244300/garrysmod/lua/includes/modules/halo.lua#L38
-- local matColor    = Material( "model_color" )
local mat_Copy    = Material( "pp/copy" )
local mat_Add    = Material( "pp/add" )
-- local mat_Sub    = Material( "pp/sub" )
local rt_Stencil    = render.GetBloomTex0()
local rt_Store        = render.GetScreenEffectTexture( 0 )
local function RenderHalo(entities)

    local OldRT = render.GetRenderTarget()

    -- Copy what's currently on the screen to another texture
    render.CopyRenderTargetToTexture( rt_Store )

    -- Clear the colour and the stencils, not the depth
    render.Clear( 0, 0, 0, 255, false, true )


    -- FILL STENCIL
    -- Write to the stencil..
    cam.Start3D( EyePos(), EyeAngles() )

        render.SetStencilEnable( true )
            render.SuppressEngineLighting(true)
            cam.IgnoreZ( false )

            render.SetStencilWriteMask( 1 )
            render.SetStencilTestMask( 1 )
            render.SetStencilReferenceValue( 1 )
            
            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
            render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
            render.SetStencilFailOperation( STENCILOPERATION_KEEP )
            render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

                for entity, _ in pairs(entities) do
                    if IsValid(entity) then
                        entity:DrawModel()
                    end
                end

            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
            render.SetStencilPassOperation( STENCILOPERATION_KEEP )

            cam.Start2D()
                surface.SetDrawColor(0, 255, 0)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            cam.End2D()

            render.SuppressEngineLighting(false)
        render.SetStencilEnable(false)
    cam.End3D()

    -- BLUR IT
    render.CopyRenderTargetToTexture( rt_Stencil )
    render.BlurRenderTarget( rt_Stencil, 2, 2, 1 )

    -- Put our scene back
    render.SetRenderTarget( OldRT )
    mat_Copy:SetTexture( "$basetexture", rt_Store )
    mat_Copy:SetString( "$color", "1 1 1" )
    mat_Copy:SetString( "$alpha", "1" )
    render.SetMaterial( mat_Copy )
    render.DrawScreenQuad()

    -- DRAW IT TO THE SCEEN
    render.SetStencilEnable( true )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )

        mat_Add:SetTexture( "$basetexture", rt_Stencil )
        render.SetMaterial( mat_Add )

        for i=0, 2 do
            render.DrawScreenQuad()
        end

    render.SetStencilEnable( false )

    -- PUT EVERYTHING BACK HOW WE FOUND IT

    render.SetStencilWriteMask( 0 )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilTestMask( 0 )

end

hook.Add("PostDrawEffects", "smh_highlighter", function()
    if not next(SMH.State.Entity) or not SMH.Controller.ShouldHighlight() then
        return
    end

    RenderHalo(SMH.State.Entity)
end)
