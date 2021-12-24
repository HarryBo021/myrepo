CoD.PerkListItemFactory = InheritFrom( LUI.UIElement )
CoD.PerkListItemFactory.IconSize = 36
CoD.PerkListItemFactory.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.PerkListItemFactory )
	self.id = "PerkListItemFactory"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 36 )
	self:setTopBottom( true, false, 0, 36 )
	self:linkToElementModel(self, "perkid", true, function (ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue == "vultureaid" then
			CoD.PerkListItemFactory.AddGlowIcon(menu, self)
		 	CoD.PerkListItemFactory.AddVultureMeter(menu, self)
		end
		if ModelValue == "dead_shot" then
			CoD.PerkListItemFactory.AddDeadShotGlowIcon(menu, self)
		end
		if ModelValue == "additional_primary_weapon" then
			CoD.PerkListItemFactory.AddMuleKickGlowIcon(menu, self)
		end
		if ModelValue == "elemental_pop" then
			CoD.PerkListItemFactory.AddElementalPopGlowIcon(menu, self)
		end
	end)
	
	local GlowOblueOver = LUI.UIImage.new()
	GlowOblueOver:setLeftRight( true, false, -7.51, 43.51 )
	GlowOblueOver:setTopBottom( true, false, -36.85, 69.85 )
	GlowOblueOver:setRGB( 0, 0.61, 1 )
	GlowOblueOver:setZRot( 90 )
	GlowOblueOver:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowOblueOver:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowOblueOver )
	self.GlowOblueOver = GlowOblueOver
	
	local GlowBlueOver0 = LUI.UIImage.new()
	GlowBlueOver0:setLeftRight( true, false, 11.49, 24.51 )
	GlowBlueOver0:setTopBottom( true, false, -36.85, 69.85 )
	GlowBlueOver0:setRGB( 0, 0.98, 1 )
	GlowBlueOver0:setAlpha( 0.62 )
	GlowBlueOver0:setZRot( 90 )
	GlowBlueOver0:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowBlueOver0:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowBlueOver0 )
	self.GlowBlueOver0 = GlowBlueOver0
	
	local PerkImage = LUI.UIImage.new()
	PerkImage:setLeftRight( true, false, 0, 36 )
	PerkImage:setTopBottom( false, true, -36, 0 )
	PerkImage:linkToElementModel( self, "image", true, function ( modelRef )
		local image = Engine.GetModelValue( modelRef )
		if image then
			PerkImage:setImage( RegisterImage( image ) )
		end
	end )
	self:addElement( PerkImage )
	self.PerkImage = PerkImage
	
	local GlowOrangeOver1 = LUI.UIImage.new()
	GlowOrangeOver1:setLeftRight( true, false, -7.51, 43.51 )
	GlowOrangeOver1:setTopBottom( true, false, -36.85, 69.85 )
	GlowOrangeOver1:setRGB( 1, 0.31, 0 )
	GlowOrangeOver1:setAlpha( 0.53 )
	GlowOrangeOver1:setZRot( 90 )
	GlowOrangeOver1:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowOrangeOver1:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowOrangeOver1 )
	self.GlowOrangeOver1 = GlowOrangeOver1
	
	local Lightning = LUI.UIImage.new()
	Lightning:setLeftRight( true, false, -57.5, 93.5 )
	Lightning:setTopBottom( true, false, -81, 63 )
	Lightning:setAlpha( 0 )
	Lightning:setImage( RegisterImage( "uie_t7_zm_derriese_hud_notification_anim" ) )
	Lightning:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_flipbook" ) )
	Lightning:setShaderVector( 0, 28, 0, 0, 0 )
	Lightning:setShaderVector( 1, 30, 0, 0, 0 )
	self:addElement( Lightning )
	self.Lightning = Lightning
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 5 )
				GlowOblueOver:completeAnimation()
				self.GlowOblueOver:setAlpha( 0 )
				self.clipFinished( GlowOblueOver, {} )
				GlowBlueOver0:completeAnimation()
				self.GlowBlueOver0:setAlpha( 0 )
				self.clipFinished( GlowBlueOver0, {} )
				PerkImage:completeAnimation()
				self.PerkImage:setAlpha( 0 )
				self.clipFinished( PerkImage, {} )
				GlowOrangeOver1:completeAnimation()
				self.GlowOrangeOver1:setAlpha( 0 )
				self.clipFinished( GlowOrangeOver1, {} )
				Lightning:completeAnimation()
				self.Lightning:setAlpha( 0 )
				self.clipFinished( Lightning, {} )
			end
		},
		Enabled = {
			DefaultClip = function ()
				self:setupElementClipCounter( 5 )
				GlowOblueOver:completeAnimation()
				self.GlowOblueOver:setAlpha( 0 )
				self.clipFinished( GlowOblueOver, {} )
				GlowBlueOver0:completeAnimation()
				self.GlowBlueOver0:setAlpha( 0 )
				self.clipFinished( GlowBlueOver0, {} )
				PerkImage:completeAnimation()
				self.PerkImage:setAlpha( 1 )
				self.clipFinished( PerkImage, {} )
				GlowOrangeOver1:completeAnimation()
				self.GlowOrangeOver1:setAlpha( 0 )
				self.clipFinished( GlowOrangeOver1, {} )
				Lightning:completeAnimation()
				self.Lightning:setAlpha( 0 )
				self.clipFinished( Lightning, {} )
			end,
			Intro = function ()
				self:setupElementClipCounter( 5 )
				local f5_local0 = function ( f6_arg0, f6_arg1 )
					local f6_local0 = function ( f7_arg0, f7_arg1 )
						local f7_local0 = function ( f8_arg0, f8_arg1 )
							local f8_local0 = function ( f9_arg0, f9_arg1 )
								if not f9_arg1.interrupted then
									f9_arg0:beginAnimation( "keyframe", 810, false, false, CoD.TweenType.Linear )
								end
								f9_arg0:setAlpha( 0 )
								if f9_arg1.interrupted then
									self.clipFinished( f9_arg0, f9_arg1 )
								else
									f9_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
								end
							end
							
							if f8_arg1.interrupted then
								f8_local0( f8_arg0, f8_arg1 )
								return 
							else
								f8_arg0:beginAnimation( "keyframe", 30, false, false, CoD.TweenType.Linear )
								f8_arg0:setAlpha( 1 )
								f8_arg0:registerEventHandler( "transition_complete_keyframe", f8_local0 )
							end
						end
						
						if f7_arg1.interrupted then
							f7_local0( f7_arg0, f7_arg1 )
							return 
						else
							f7_arg0:beginAnimation( "keyframe", 30, false, false, CoD.TweenType.Linear )
							f7_arg0:setAlpha( 0.34 )
							f7_arg0:registerEventHandler( "transition_complete_keyframe", f7_local0 )
						end
					end
					
					if f6_arg1.interrupted then
						f6_local0( f6_arg0, f6_arg1 )
						return 
					else
						f6_arg0:beginAnimation( "keyframe", 129, false, false, CoD.TweenType.Linear )
						f6_arg0:setAlpha( 1 )
						f6_arg0:registerEventHandler( "transition_complete_keyframe", f6_local0 )
					end
				end
				
				GlowOblueOver:completeAnimation()
				self.GlowOblueOver:setAlpha( 0 )
				f5_local0( GlowOblueOver, {} )
				local f5_local1 = function ( f10_arg0, f10_arg1 )
					local f10_local0 = function ( f11_arg0, f11_arg1 )
						if not f11_arg1.interrupted then
							f11_arg0:beginAnimation( "keyframe", 699, false, false, CoD.TweenType.Linear )
						end
						f11_arg0:setLeftRight( true, false, 11.49, 24.51 )
						f11_arg0:setTopBottom( true, false, -36.85, 69.85 )
						f11_arg0:setRGB( 1, 0.48, 0 )
						f11_arg0:setAlpha( 0 )
						if f11_arg1.interrupted then
							self.clipFinished( f11_arg0, f11_arg1 )
						else
							f11_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f10_arg1.interrupted then
						f10_local0( f10_arg0, f10_arg1 )
						return 
					else
						f10_arg0:beginAnimation( "keyframe", 129, false, false, CoD.TweenType.Linear )
						f10_arg0:setAlpha( 0.54 )
						f10_arg0:registerEventHandler( "transition_complete_keyframe", f10_local0 )
					end
				end
				
				GlowBlueOver0:completeAnimation()
				self.GlowBlueOver0:setLeftRight( true, false, 11.49, 24.51 )
				self.GlowBlueOver0:setTopBottom( true, false, -36.85, 69.85 )
				self.GlowBlueOver0:setRGB( 1, 0.48, 0 )
				self.GlowBlueOver0:setAlpha( 0 )
				f5_local1( GlowBlueOver0, {} )
				local f5_local2 = function ( f12_arg0, f12_arg1 )
					if not f12_arg1.interrupted then
						f12_arg0:beginAnimation( "keyframe", 129, false, false, CoD.TweenType.Linear )
					end
					f12_arg0:setAlpha( 1 )
					if f12_arg1.interrupted then
						self.clipFinished( f12_arg0, f12_arg1 )
					else
						f12_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				PerkImage:completeAnimation()
				self.PerkImage:setAlpha( 0 )
				f5_local2( PerkImage, {} )
				local f5_local3 = function ( f13_arg0, f13_arg1 )
					local f13_local0 = function ( f14_arg0, f14_arg1 )
						local f14_local0 = function ( f15_arg0, f15_arg1 )
							local f15_local0 = function ( f16_arg0, f16_arg1 )
								if not f16_arg1.interrupted then
									f16_arg0:beginAnimation( "keyframe", 639, false, false, CoD.TweenType.Linear )
								end
								f16_arg0:setAlpha( 0 )
								if f16_arg1.interrupted then
									self.clipFinished( f16_arg0, f16_arg1 )
								else
									f16_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
								end
							end
							
							if f15_arg1.interrupted then
								f15_local0( f15_arg0, f15_arg1 )
								return 
							else
								f15_arg0:beginAnimation( "keyframe", 30, false, false, CoD.TweenType.Linear )
								f15_arg0:setAlpha( 0.22 )
								f15_arg0:registerEventHandler( "transition_complete_keyframe", f15_local0 )
							end
						end
						
						if f14_arg1.interrupted then
							f14_local0( f14_arg0, f14_arg1 )
							return 
						else
							f14_arg0:beginAnimation( "keyframe", 30, false, false, CoD.TweenType.Linear )
							f14_arg0:setAlpha( 0 )
							f14_arg0:registerEventHandler( "transition_complete_keyframe", f14_local0 )
						end
					end
					
					if f13_arg1.interrupted then
						f13_local0( f13_arg0, f13_arg1 )
						return 
					else
						f13_arg0:beginAnimation( "keyframe", 129, false, false, CoD.TweenType.Linear )
						f13_arg0:setAlpha( 0.24 )
						f13_arg0:registerEventHandler( "transition_complete_keyframe", f13_local0 )
					end
				end
				
				GlowOrangeOver1:completeAnimation()
				self.GlowOrangeOver1:setAlpha( 0 )
				f5_local3( GlowOrangeOver1, {} )
				local f5_local4 = function ( f17_arg0, f17_arg1 )
					local f17_local0 = function ( f18_arg0, f18_arg1 )
						if not f18_arg1.interrupted then
							f18_arg0:beginAnimation( "keyframe", 870, false, false, CoD.TweenType.Linear )
						end
						f18_arg0:setAlpha( 0 )
						if f18_arg1.interrupted then
							self.clipFinished( f18_arg0, f18_arg1 )
						else
							f18_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f17_arg1.interrupted then
						f17_local0( f17_arg0, f17_arg1 )
						return 
					else
						f17_arg0:beginAnimation( "keyframe", 129, false, false, CoD.TweenType.Linear )
						f17_arg0:setAlpha( 1 )
						f17_arg0:registerEventHandler( "transition_complete_keyframe", f17_local0 )
					end
				end
				
				Lightning:completeAnimation()
				self.Lightning:setAlpha( 0 )
				f5_local4( Lightning, {} )
			end
		},
		Paused = {
			DefaultClip = function ()
				self:setupElementClipCounter( 5 )
				GlowOblueOver:completeAnimation()
				self.GlowOblueOver:setAlpha( 0 )
				self.clipFinished( GlowOblueOver, {} )
				GlowBlueOver0:completeAnimation()
				self.GlowBlueOver0:setAlpha( 0 )
				self.clipFinished( GlowBlueOver0, {} )
				PerkImage:completeAnimation()
				self.PerkImage:setAlpha( .2 )
				self.clipFinished( PerkImage, {} )
				GlowOrangeOver1:completeAnimation()
				self.GlowOrangeOver1:setAlpha( 0 )
				self.clipFinished( GlowOrangeOver1, {} )
				Lightning:completeAnimation()
				self.Lightning:setAlpha( 0 )
				self.clipFinished( Lightning, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Enabled",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualTo( element, controller, "status", 1 )
			end
		},
		{
			stateName = "Paused",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualTo( element, controller, "status", 2 )
			end
		}
	} )
	self:linkToElementModel( self, "status", true, function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "status"
		} )
	end )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller )
		if IsSelfModelValueTrue( element, controller, "newPerk" ) then
			PlayClip( self, "Intro", controller )
			SetSelfModelValue( self, element, controller, "newPerk", false )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.PerkImage:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.PerkListItemFactory.AddVultureMeter = function ( HudRef, currentPerk )
	if not currentPerk.meterContainer then
        local meterContainer = LUI.UIElement.new()
        meterContainer:setLeftRight( true, false, 0, 36 )
        meterContainer:setTopBottom( false, true, -180 + 36 * 2 + 5, -36 + 5 )
        meterContainer:setAlpha( 0 )
        meterContainer:setPriority( -10 )
        currentPerk:addElement( meterContainer )
        currentPerk.meterContainer = meterContainer
        
        local meterBlackImage = LUI.UIImage.new()
        meterBlackImage:setLeftRight( true, true, -36 / 2, 36 / 2 )
        meterBlackImage:setTopBottom( true, true, 0, 0 )
        meterBlackImage:setImage( RegisterImage( "i_zm_hud_stink_ani_black" ) )
        meterBlackImage:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_flipbook" ) )
        meterBlackImage:setShaderVector(0, 0, 30, 0, 0)
        meterBlackImage:setShaderVector(1, 16, 0, 0, 0)
        meterContainer:addElement( meterBlackImage )
		
        local meterGreenImage = LUI.UIImage.new()
        meterGreenImage:setLeftRight( true, true, -36 / 2, 36 / 2 )
        meterGreenImage:setTopBottom( true, true, 0, 0 )
        meterGreenImage:setImage( RegisterImage( "i_zm_hud_stink_ani_green" ) )
        meterGreenImage:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_flipbook_add" ) )
        meterGreenImage:setShaderVector(0, 0, 30, 0, 0)
        meterGreenImage:setShaderVector(1, 16, 0, 0, 0)
        meterContainer:addElement( meterGreenImage )

        local function UpdateVultureDiseaseMeter(ModelRef)
            local value = Engine.GetModelValue(ModelRef)
            if currentPerk.meterContainer then
                currentPerk.meterContainer:setAlpha( value )
            end
            if currentPerk.perkGlowIcon then
                currentPerk.perkGlowIcon:setAlpha( value )
            end
        end
        currentPerk:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "vulture_perk_disease_meter"), UpdateVultureDiseaseMeter)
    end
end

CoD.PerkListItemFactory.AddGlowIcon = function (f8_arg0, SenderRef)
	if not SenderRef.perkGlowIcon then
		local f8_local0 = LUI.UIImage.new()
		f8_local0:setLeftRight(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setTopBottom(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setAlpha(0)
		f8_local0:setPriority(-10)
		f8_local0:setImage(RegisterImage( "i_specialty_vulture_zombies_glow" ))
		SenderRef:addElement(f8_local0)
		SenderRef.perkGlowIcon = f8_local0
	end
end

CoD.PerkListItemFactory.AddMuleKickGlowIcon = function (f8_arg0, SenderRef)
	if not SenderRef.perkGlowIcon then
		local f8_local0 = LUI.UIImage.new()
		f8_local0:setLeftRight(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setTopBottom(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setAlpha(0)
		f8_local0:setPriority(-10)
		f8_local0:setImage(RegisterImage( "i_specialty_vulture_zombies_glow" ))
		SenderRef:addElement(f8_local0)
		SenderRef.perkGlowIcon = f8_local0
		
		local UpdateMuleKickGlow = function (ModelRef)
			local f10_local0 = Engine.GetModelValue(ModelRef)
			if SenderRef.perkGlowIcon then
				SenderRef.perkGlowIcon:setAlpha(f10_local0)
			end
		end
		SenderRef:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "additional_primary_weapon_ui_glow"), UpdateMuleKickGlow)
	end
end

CoD.PerkListItemFactory.AddDeadShotGlowIcon = function (f8_arg0, SenderRef)
	if not SenderRef.perkGlowIcon then
		local f8_local0 = LUI.UIImage.new()
		f8_local0:setLeftRight(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setTopBottom(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setAlpha(0)
		f8_local0:setPriority(-10)
		f8_local0:setImage(RegisterImage( "i_specialty_vulture_zombies_glow" ))
		SenderRef:addElement(f8_local0)
		SenderRef.perkGlowIcon = f8_local0
		
		local UpdateDeadShotGlow = function (ModelRef)
			local f10_local0 = Engine.GetModelValue(ModelRef)
			if SenderRef.perkGlowIcon then
				SenderRef.perkGlowIcon:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
				SenderRef.perkGlowIcon:setAlpha(f10_local0)
			end
		end
		SenderRef:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "dead_shot_ui_glow"), UpdateDeadShotGlow)
	end
end

CoD.PerkListItemFactory.AddElementalPopGlowIcon = function (f8_arg0, SenderRef)
	if not SenderRef.perkGlowIcon then
		local f8_local0 = LUI.UIImage.new()
		f8_local0:setLeftRight(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setTopBottom(true, true, -CoD.PerkListItemFactory.IconSize / 2, CoD.PerkListItemFactory.IconSize / 2)
		f8_local0:setAlpha(0)
		f8_local0:setPriority(-10)
		f8_local0:setImage(RegisterImage( "i_specialty_vulture_zombies_glow" ))
		SenderRef:addElement(f8_local0)
		SenderRef.perkGlowIcon = f8_local0
		
		local UpdateDeadShotGlow = function (ModelRef)
			local f10_local0 = Engine.GetModelValue(ModelRef)
			if SenderRef.perkGlowIcon then
				SenderRef.perkGlowIcon:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
				SenderRef.perkGlowIcon:setAlpha(f10_local0)
			end
		end
		SenderRef:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "elemental_pop_ui_glow"), UpdateDeadShotGlow)
	end
end