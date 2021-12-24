require("ui.uieditor.widgets.HUD.ZM_Perks.hb21perklistitemfactory")

local Perks_Table = 
{
		quick_revive 							= "i_t7_specialty_quickrevive",
		doubletap2 							= "i_t7_specialty_doubletap2",
		juggernaut 							= "i_t7_specialty_armorvest",
		sleight_of_hand 					= "i_t7_specialty_fastreload",
		dead_shot 							= "i_t7_specialty_deadshot",
		phdflopper 							= "i_t7_specialty_phdflopper",
		marathon 								= "i_t7_specialty_staminup",
		additional_primary_weapon 	= "i_t7_specialty_additionalprimaryweapon",
		tombstone 							= "i_t7_specialty_tombstone",
		whoswho 								= "i_t7_specialty_whoswho",
		electric_cherry 						= "i_t7_specialty_electriccherry",
        vultureaid 								= "i_t7_specialty_vultureaid",
		widows_wine 						= "i_t7_specialty_widowswine",
		elemental_pop 						= "i_t7_specialty_elemental_pop"
	}
	
local f0_local1 = function ( f1_arg0, f1_arg1 )
	if f1_arg0 ~= nil then
		for f1_local0 = 1, #f1_arg0, 1 do
			if f1_arg0[f1_local0].properties.key == f1_arg1 then
				return f1_local0
			end
		end
	end
	return nil
end

local f0_local2 = function ( f2_arg0, f2_arg1, f2_arg2 )
	if f2_arg0 ~= nil then
		for f2_local0 = 1, #f2_arg0, 1 do
			if f2_arg0[f2_local0].properties.key == f2_arg1 and f2_arg0[f2_local0].models.status ~= f2_arg2 then
				return f2_local0
			end
		end
	end
	return -1
end

local f0_local3 = function ( f3_arg0, f3_arg1 )
	if not f3_arg0.perksList then
		f3_arg0.perksList = {}
	end
	local f3_local0 = false
	local f3_local1 = Engine.GetModel( Engine.GetModelForController( f3_arg1 ), "hudItems.perks" )
	for f3_local6, f3_local7 in pairs( Perks_Table ) do
		local f3_local8 = Engine.GetModelValue( Engine.GetModel( f3_local1, f3_local6 ) )
		if f3_local8 ~= nil and f3_local8 > 0 then
			if not f0_local1( f3_arg0.perksList, f3_local6 ) then
				table.insert( f3_arg0.perksList, {
					models = {
						image = f3_local7,
						status = f3_local8,
						newPerk = false
					},
					properties = {
						key = f3_local6
					}
				} )
				f3_local0 = true
			end
			local f3_local5 = f0_local2( f3_arg0.perksList, f3_local6, f3_local8 )
			if f3_local5 > 0 then
				f3_arg0.perksList[f3_local5].models.status = f3_local8
				Engine.SetModelValue( Engine.GetModel( Engine.GetModel( Engine.GetModelForController( f3_arg1 ), "ZMPerksFactory" ), tostring( f3_local5 ) .. ".status" ), f3_local8 )
			end
		end
		local f3_local5 = f0_local1( f3_arg0.perksList, f3_local6 )
		if f3_local5 then
			table.remove( f3_arg0.perksList, f3_local5 )
			f3_local0 = true
		end
	end
	if f3_local0 then
		for f3_local2 = 1, #f3_arg0.perksList, 1 do
			f3_arg0.perksList[f3_local2].models.newPerk = f3_local2 == #f3_arg0.perksList
		end
	end
	if f3_local0 then
		return true
	end
	for f3_local2 = 1, #f3_arg0.perksList, 1 do
		Engine.SetModelValue( Engine.GetModel( f3_local1, f3_arg0.perksList[f3_local2].properties.key ), f3_arg0.perksList[f3_local2].models.status )
	end
	return false
end

DataSources.ZMPerksFactory = DataSourceHelpers.ListSetup( "ZMPerksFactory", function ( f4_arg0, f4_arg1 )
	f0_local3( f4_arg1, f4_arg0 )
	return f4_arg1.perksList
end, true )
local PreLoadFunc = function ( self, controller )
	local f5_local0 = Engine.CreateModel( Engine.GetModelForController( controller ), "hudItems.perks" )
	for f5_local4, f5_local5 in pairs( Perks_Table ) do
		self:subscribeToModel( Engine.CreateModel( f5_local0, f5_local4 ), function ( modelRef )
			if f0_local3( self.PerkList, controller ) then
				self.PerkList:updateDataSource()
			end
		end, false )
	end
end

CoD.ZMPerksContainerFactory = InheritFrom( LUI.UIElement )
CoD.ZMPerksContainerFactory.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.ZMPerksContainerFactory )
	self.id = "ZMPerksContainerFactory"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 151 )
	self:setTopBottom( true, false, 0, 36 )
	self.anyChildUsesUpdateState = true
	
	local PerkList = LUI.UIList.new( menu, controller, 2, 0, nil, false, false, 0, 0, false, false )
	PerkList:makeFocusable()
	PerkList:setLeftRight( true, false, 0, 378 )
	PerkList:setTopBottom( false, true, -36, 0 )
	PerkList:setWidgetType( CoD.PerkListItemFactory )
	PerkList:setHorizontalCount( 100 )
	PerkList:setDataSource( "ZMPerksFactory" )
	self:addElement( PerkList )
	self.PerkList = PerkList
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				PerkList:completeAnimation()
				self.PerkList:setAlpha( 1 )
				self.clipFinished( PerkList, {} )
			end
		},
		Hidden = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				PerkList:completeAnimation()
				self.PerkList:setAlpha( 0 )
				self.clipFinished( PerkList, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				local f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE )
				if not f10_local0 then
					f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN )
					if not f10_local0 then
						f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM )
						if not f10_local0 then
							f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_EMP_ACTIVE )
							if not f10_local0 then
								f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_GAME_ENDED )
								if not f10_local0 then
									if Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE ) then
										f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE )
										if not f10_local0 then
											f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC )
											if not f10_local0 then
												f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_VEHICLE )
												if not f10_local0 then
													f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED )
													if not f10_local0 then
														f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE )
														if not f10_local0 then
															f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_SCOPED )
															if not f10_local0 then
																f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN )
																if not f10_local0 then
																	f10_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE )
																end
															end
														end
													end
												end
											end
										end
									else
										f10_local0 = true
									end
								end
							end
						end
					end
				end
				return f10_local0
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE
		} )
	end )
	PerkList.id = "PerkList"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.PerkList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end



local f0_local1 = function (f1_arg0, f1_arg1)
	if f1_arg0 ~= nil then
		for f1_local0 = 1, #f1_arg0, 1 do
			if f1_arg0[f1_local0].properties.key == f1_arg1 then
				return f1_local0
			end
		end
	end
	return nil
end

local f0_local2 = function (f2_arg0, f2_arg1, f2_arg2)
	if f2_arg0 ~= nil then
		for f2_local0 = 1, #f2_arg0, 1 do
			if f2_arg0[f2_local0].properties.key == f2_arg1 and f2_arg0[f2_local0].models.status ~= f2_arg2 then
				return f2_local0
			end
		end
	end
	return -1
end

local f0_local3 = function (f3_arg0, InstanceRef)
	if not f3_arg0.perksList then
		f3_arg0.perksList = {}
	end
	local f3_local0 = false
	local f3_local1 = Engine.GetModel(Engine.GetModelForController(InstanceRef), "hudItems.perks")
	for f3_local6, f3_local7 in pairs(Perks_Table) do
		local f3_local8 = Engine.GetModelValue(Engine.GetModel(f3_local1, f3_local6))
		if f3_local8 ~= nil and 0 < f3_local8 then
			if not f0_local1(f3_arg0.perksList, f3_local6) then
				-- Engine.ComError( Enum.errorCode.ERROR_UI, "NEW PERK" )
				table.insert(f3_arg0.perksList, {models = {image = f3_local7, status = f3_local8, newPerk = false,perkid = f3_local6}, properties = {key = f3_local6}})
				f3_local0 = true
			elseif 0 < f0_local2(f3_arg0.perksList, f3_local6, f3_local8) then
				local f3_local5 = f0_local2(f3_arg0.perksList, f3_local6, f3_local8)
				f3_arg0.perksList[f3_local5].models.status = f3_local8
				Engine.SetModelValue(Engine.GetModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "ZMPerksFactory"), tostring(f3_local5) .. ".status"), f3_local8)
			end
		else
			local f3_local5 = f0_local1(f3_arg0.perksList, f3_local6)
			if f3_local5 then
				table.remove(f3_arg0.perksList, f3_local5)
				f3_local0 = true
			end
		end
	end
	if f3_local0 then
		for f3_local2 = 1, #f3_arg0.perksList, 1 do
			f3_arg0.perksList[f3_local2].models.newPerk = f3_local2 == #f3_arg0.perksList
		end
		
		if f3_local0 then
			return true
		end
		
	end
	
	for f3_local2 = 1, #f3_arg0.perksList, 1 do
		Engine.SetModelValue(Engine.GetModel(f3_local1, f3_arg0.perksList[f3_local2].properties.key), f3_arg0.perksList[f3_local2].models.status)
	end
	return false
end

DataSources.ZMPerksFactory = DataSourceHelpers.ListSetup("ZMPerksFactory", function (InstanceRef, f4_arg1)
	f0_local3(f4_arg1, f4_arg0)
	return f4_arg1.perksList
end, true)

local PerksModel = function (f5_arg0, f5_arg1)
	for f5_local3, f5_local4 in pairs(Perks_Table) do
		f5_arg0:subscribeToModel(Engine.CreateModel(Engine.CreateModel(Engine.GetModelForController(f5_arg1), "hudItems.perks"), f5_local3), function (ModelRef)
			if f0_local3(f5_arg0.PerkList, f5_arg1) then
				f5_arg0.PerkList:updateDataSource()
			end
		end, false)
	end
end

CoD.ZMPerksContainerFactory = InheritFrom(LUI.UIElement)
CoD.ZMPerksContainerFactory.new = function (HudRef, InstanceRef)

	local Widget = LUI.UIElement.new()

	if PerksModel then
		PerksModel(Widget, InstanceRef)
	end

	Widget:setUseStencil(false)
	Widget:setClass(CoD.ZMPerksContainerFactory)
	Widget.id = "ZMPerksContainerFactory"
	Widget.soundSet = "default"
	Widget:setLeftRight(true, false, 0, 151)
	Widget:setTopBottom(true, false, 0, 36)
	Widget.anyChildUsesUpdateState = true

	local PerkListFactory = LUI.UIList.new(HudRef, InstanceRef, 2, 0, nil, false, false, 0, 0, false, false)
	PerkListFactory:makeFocusable()
	PerkListFactory:setLeftRight(true, false, 0, 378)
	PerkListFactory:setTopBottom(false, true, -36, 0)
	PerkListFactory:setWidgetType(CoD.PerkListItemFactory)
	PerkListFactory:setHorizontalCount(30)
	PerkListFactory:setDataSource("ZMPerksFactory")
	Widget:addElement(PerkListFactory)
	Widget.PerkList = PerkListFactory
	
	Widget.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				Widget:setupElementClipCounter(1)
				PerkListFactory:completeAnimation()
				Widget.PerkList:setAlpha(1)
				Widget.clipFinished(PerkListFactory, {})
			end},

		Hidden = {
			DefaultClip = function ()
				Widget:setupElementClipCounter(1)
				PerkListFactory:completeAnimation()
				Widget.PerkList:setAlpha(0)
				Widget.clipFinished(PerkListFactory, {})
			end}
	}

	Widget:mergeStateConditions({{stateName = "Hidden", 
		condition = function (HudRef, ItemRef, UpdateTable)
			local f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE)
				if not f10_local0 then
					f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN)
					if not f10_local0 then
						f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM)
						if not f10_local0 then
							f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_EMP_ACTIVE)
							if not f10_local0 then
								f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_GAME_ENDED)
								if not f10_local0 then
									if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) then
										f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE)
										if not f10_local0 then
											f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC)
											if not f10_local0 then
												f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_VEHICLE)
												if not f10_local0 then
													f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED)
													if not f10_local0 then
														f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE)
														if not f10_local0 then
															f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_SCOPED)
															if not f10_local0 then
																f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN)
																if not f10_local0 then
																	f10_local0 = Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE)
																end
															end
														end
													end
												end
											end
										end
									else
										f10_local0 = true
									end
								end
							end
						end
					end
				end
		return f10_local0
	end}})

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN })
	end)

	Widget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE), function (ModelRef)
		HudRef:updateElementState(Widget, {
			name = "model_validation", 
			menu = HudRef, 
			modelValue = Engine.GetModelValue(ModelRef), 
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE })
	end)

	PerkListFactory.id = "PerkList"

	LUI.OverrideFunction_CallOriginalSecond(Widget, "close", function (Sender)
		Sender.PerkList:close()
	end)

	if PostLoadFunc then
		PostLoadFunc(Widget, InstanceRef, HudRef)
	end

	return Widget
end