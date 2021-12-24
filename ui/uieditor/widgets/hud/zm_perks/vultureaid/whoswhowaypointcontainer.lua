-- require("ui.uieditor.widgets.MPHudWidgets.Waypoint")
require("ui.uieditor.widgets.HUD.ZM_Perks.waypoint2")
require("ui.uieditor.widgets.HUD.ZM_Revive.ZM_ReviveBleedoutRedEyeGlow")
require("ui.uieditor.widgets.HUD.core_AmmoWidget.AmmoWidget_AbilityGlow")

local function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local f0_local0 = function (f1_arg0, f1_arg1)
	if f1_arg1.objId then
		f1_arg0.objId = f1_arg1.objId
		local f1_local0 = f1_arg0.Waypoint
		f1_local0.objective = f1_arg0.objective
		f1_local0:setupWaypoint(f1_arg1)
		if f1_local0.waypoint_image_default == nil then
			f1_local0:setState("NoIcon")
		else
			f1_local0:setState("Default")
			f1_local0.WaypointCenter.waypointCenterImage:setImage(RegisterImage(f1_local0.waypoint_image_default))
		end
		local f1_local1 = f1_arg1.controller
		local f1_local2 = f1_arg0.objId
		if f1_local0.objective.minimapMaterial ~= nil then
			Engine.SetObjectiveIcon(f1_local1, f1_local2, CoD.GametypeBase.mapIconType, f1_local0.objective.minimapMaterial)
		else
			Engine.ClearObjectiveIcon(f1_local1, f1_local2, CoD.GametypeBase.mapIconType)
		end
		if f1_local0.waypoint_label_default == "" then
			f1_local0.WaypointText:setState("NoText")
		else
			f1_local0.WaypointText:setState("Default")
		end
		if f1_local0.objective.hide_arrow then
			f1_local0.WaypointArrowContainer:setState("Invisible")
		end
		f1_local0.WaypointText.text:setText(Engine.Localize(f1_local0.waypoint_label_default))
	end
end

local f0_local1 = function (f2_arg0, f2_arg1)
	f2_arg0.Waypoint:update(f2_arg1)
	if f2_arg1.objState ~= nil then
		if f2_arg1.objState == CoD.OBJECTIVESTATE_DONE then
			f2_arg0:setState("Done")
		else
			f2_arg0:setState("Default")
		end
		if f2_arg0.visible == true then
			f2_arg0:show()
		else
			f2_arg0:hide()
		end
	end
end

local f0_local2 = function (f3_arg0, f3_arg1)
	local f3_local0 = f3_arg1.controller
	local f3_local1 = f3_arg0.Waypoint
	local f3_local2 = Engine.GetObjectiveTeam(f3_local0, f3_arg0.objId)
	if f3_local2 == Enum.team_t.TEAM_FREE or f3_local2 == Enum.team_t.TEAM_NEUTRAL then
		return true
	else
		return f3_local1:isOwnedByMyTeam(f3_local0)
	end
end

local f0_local3 = function (f4_arg0)
	f4_arg0.update = f0_local1
	f4_arg0.shouldShow = f0_local2
	f4_arg0.setupWaypointContainer = f0_local0
end

CoD.WhosWhoWaypointContainer = InheritFrom(LUI.UIElement)
CoD.WhosWhoWaypointContainer.new = function (HudRef, InstanceRef, waypointContainer, Event)
	local Widget = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc(Widget, InstanceRef)
	end
	Widget:setUseStencil(false)
	Widget:setClass(CoD.WhosWhoWaypointContainer)
	Widget.id = "WhosWhoWaypointContainer"
	Widget.soundSet = "default"
	Widget:setLeftRight(true, false, 0, 1280)
	Widget:setTopBottom(true, false, 0, 720)
	Widget.anyChildUsesUpdawaypointContainerate = true
	
	local Waypoint = CoD.Waypoint.new(HudRef, InstanceRef)
	Waypoint:setLeftRight(true, true, 600, -600)
	Waypoint:setTopBottom(true, true, 315, -315)
	Widget:addElement(Waypoint)
	Widget.Waypoint = Waypoint
	
	local f1_local1 = LUI.UIImage.new()
	f1_local1:setLeftRight(false, false, -80, 80)
	f1_local1:setTopBottom(false, false, -126.5, 126.5)
	f1_local1:setRGB(1, 0.31, 0)
	f1_local1:setAlpha(0.4)
	f1_local1:setZRot(90)
	f1_local1:setImage(RegisterImage("uie_t7_core_hud_mapwidget_panelglow"))
	f1_local1:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Waypoint:addElement(f1_local1)
	Widget.GlowOrangeOver = f1_local1
	
	local f1_local2 = LUI.UIImage.new()
	f1_local2:setLeftRight(false, false, -70, 70)
	f1_local2:setTopBottom(false, false, -70, 70)
	f1_local2:setImage(RegisterImage("uie_t7_zm_hud_revive_glow"))
	Waypoint:addElement(f1_local2)
	Widget.glow = f1_local2
	
	local f1_local3 = LUI.UIImage.new()
	f1_local3:setLeftRight(false, false, -70, 70)
	f1_local3:setTopBottom(false, false, -70, 70)
	f1_local3:setRGB(1, 0.72, 0)
	f1_local3:setAlpha(0)
	f1_local3:setImage(RegisterImage("uie_t7_zm_hud_revive_ringblur"))
	f1_local3:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Waypoint:addElement(f1_local3)
	Widget.RingGlow = f1_local3
	
	local f1_local4 = LUI.UIImage.new()
	f1_local4:setLeftRight(false, false, -70, 70)
	f1_local4:setTopBottom(false, false, -70, 70)
	f1_local4:setRGB(1, 0.45, 0)
	f1_local4:setAlpha(0.1)
	f1_local4:setImage(RegisterImage("uie_t7_zm_hud_revive_ringmiddle"))
	f1_local4:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Waypoint:addElement(f1_local4)
	Widget.RingMiddle = f1_local4
	
	local f1_local5 = LUI.UIImage.new()
	f1_local5:setLeftRight(false, false, -70, 70)
	f1_local5:setTopBottom(false, false, -70, 70)
	f1_local5:setRGB(1, 0.92, 0)
	f1_local5:setImage(RegisterImage("uie_t7_zm_hud_revive_ringtop"))
	f1_local5:setMaterial(LUI.UIImage.GetCachedMaterial("uie_clock_add"))
	f1_local5:setShaderVector(1, 0.5, 0, 0, 0)
	f1_local5:setShaderVector(2, 0.5, 0, 0, 0)
	f1_local5:setShaderVector(3, 0.05, 0, 0, 0)
	-- f1_local5:linkToElementModel(Widget, "bleedOutPercent", true, function (ModelRef)
	-- 	local ModelValue = Engine.GetModelValue(ModelRef)
	-- 	if ModelValue then
	-- 		f1_local5:setShaderVector(0, CoD.GetVectorComponentFromString(ModelValue, 1), CoD.GetVectorComponentFromString(ModelValue, 2), CoD.GetVectorComponentFromString(ModelValue, 3), CoD.GetVectorComponentFromString(ModelValue, 4))
	--	end
	-- end)
	Waypoint:addElement(f1_local5)
	Widget.RingTopBleedOut = f1_local5
	
	local f1_local6 = LUI.UIImage.new()
	f1_local6:setLeftRight(false, false, -70, 70)
	f1_local6:setTopBottom(false, false, -70, 70)
	f1_local6:setRGB(0, 1, 0.01)
	f1_local6:setAlpha(0)
	f1_local6:setImage(RegisterImage("uie_t7_zm_hud_revive_ringtop"))
	f1_local6:setMaterial(LUI.UIImage.GetCachedMaterial("uie_clock_add"))
	f1_local6:setShaderVector(1, 0.5, 0, 0, 0)
	f1_local6:setShaderVector(2, 0.65, 0, 0, 0)
	f1_local6:setShaderVector(3, 0.34, 0, 0, 0)
	-- f1_local6:linkToElementModel(Widget, "clockPercent", true, function (ModelRef)
	-- 	local ModelValue = Engine.GetModelValue(ModelRef)
	-- 	if ModelValue then
	-- 		f1_local6:setShaderVector(0, CoD.GetVectorComponentFromString(ModelValue, 1), CoD.GetVectorComponentFromString(ModelValue, 2), CoD.GetVectorComponentFromString(ModelValue, 3), CoD.GetVectorComponentFromString(ModelValue, 4))
	-- 	end
	-- end)
	Waypoint:addElement(f1_local6)
	Widget.RingTopRevive = f1_local6
	
	local f1_local7 = LUI.UIImage.new()
	f1_local7:setLeftRight(false, false, -70, 70)
	f1_local7:setTopBottom(false, false, -70, 70)
	f1_local7:setImage(RegisterImage("uie_t7_zm_hud_revive_skull"))
	Waypoint:addElement(f1_local7)
	Widget.skull = f1_local7
	
	local f1_local8 = LUI.UIImage.new()
	f1_local8:setLeftRight(false, false, -67.86, 69)
	f1_local8:setTopBottom(false, false, -69, 67.86)
	f1_local8:setRGB(1, 0.64, 0)
	f1_local8:setAlpha(0)
	f1_local8:setScale(1.3)
	f1_local8:setImage(RegisterImage("uie_t7_core_hud_ammowidget_abilityswirl"))
	f1_local8:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Waypoint:addElement(f1_local8)
	Widget.AbilitySwirl = f1_local8
	
	local f1_local9 = CoD.ZM_ReviveBleedoutRedEyeGlow.new(HudRef, InstanceRef)
	f1_local9:setLeftRight(false, false, -23.91, -6.75)
	f1_local9:setTopBottom(false, false, 3.48, 21.64)
	Waypoint:addElement(f1_local9)
	Widget.ZMReviveBleedoutRedEyeGlow = f1_local9
	
	local f1_local10 = CoD.ZM_ReviveBleedoutRedEyeGlow.new(HudRef, InstanceRef)
	f1_local10:setLeftRight(false, false, 6.09, 23.25)
	f1_local10:setTopBottom(false, false, 3.48, 21.64)
	Waypoint:addElement(f1_local10)
	Widget.ZMReviveBleedoutRedEyeGlow0 = f1_local10
	
	local f1_local11 = CoD.AmmoWidget_AbilityGlow.new(HudRef, InstanceRef)
	f1_local11:setLeftRight(true, true, 4, -4)
	f1_local11:setTopBottom(true, true, 4, -4)
	f1_local11:setRGB(1, 0.49, 0)
	f1_local11:setAlpha(0)
	f1_local11:setZoom(13.47)
	f1_local11:setScale(0.7)
	Waypoint:addElement(f1_local11)
	Widget.Glow0 = f1_local11
	
	local objectiveModel = Engine.GetModel(Engine.GetModelForController(waypointContainer), ("objective" .. Event.objId))	
	
	Engine.CreateModel(objectiveModel, "test")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "test"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue == nil then
			ModelValue = 0
		end
		-- Waypoint:setEntityContainerStopUpdating(true)
		-- Waypoint:setupWaypointContainer(Event.objId, 0, 0, 0, 0)
		-- f1_arg0.zOffset = f1_arg0.objective.waypoint_z_offset
		-- Event.zOffset = 0
		-- waypointContainer:setPriority( ModelValue )
	end)
	
	Widget.clipsPerState = {DefaultState = {DefaultClip = function ()
		Widget:setupElementClipCounter(3)
		f1_local1:completeAnimation()
		Widget.playerName:setAlpha(0)
		Widget.clipFinished(f1_local1, {})
		f1_local2:completeAnimation()
		Widget.prompt:setAlpha(0)
		Widget.clipFinished(f1_local2, {})
		f1_local4:completeAnimation()
		Widget.ZMReviveClampedArrow:setAlpha(0)
		Widget.clipFinished(f1_local4, {})
	end}, Clamped = {DefaultClip = function ()
		Widget:setupElementClipCounter(3)
		f1_local1:completeAnimation()
		Widget.playerName:setAlpha(0)
		Widget.clipFinished(f1_local1, {})
		f1_local2:completeAnimation()
		Widget.prompt:setAlpha(0)
		Widget.clipFinished(f1_local2, {})
		f1_local4:completeAnimation()
		Widget.ZMReviveClampedArrow:setAlpha(1)
		Widget.clipFinished(f1_local4, {})
	end}, Visible_Reviving = {DefaultClip = function ()
		Widget:setupElementClipCounter(3)
		f1_local1:completeAnimation()
		Widget.playerName:setAlpha(0)
		Widget.clipFinished(f1_local1, {})
		f1_local2:completeAnimation()
		Widget.prompt:setAlpha(0)
		Widget.clipFinished(f1_local2, {})
		f1_local4:completeAnimation()
		Widget.ZMReviveClampedArrow:setAlpha(0)
		Widget.clipFinished(f1_local4, {})
	end}, Visible = {DefaultClip = function ()
		Widget:setupElementClipCounter(3)
		f1_local1:completeAnimation()
		Widget.playerName:setAlpha(1)
		Widget.clipFinished(f1_local1, {})
		f1_local2:completeAnimation()
		Widget.prompt:setAlpha(1)
		Widget.clipFinished(f1_local2, {})
		f1_local4:completeAnimation()
		Widget.ZMReviveClampedArrow:setAlpha(0)
		Widget.clipFinished(f1_local4, {})
	end}}
	
	Widget:mergeStateConditions(
	{
		{
			stateName = "Clamped", 
			condition = function (HudRef, ItemRef, UpdateTable)
				local f10_local0 = IsBleedOutVisible(ItemRef, InstanceRef)
				if f10_local0 then
					f10_local0 = IsSelfModelValueEnumBitSet(ItemRef, InstanceRef, "stateFlags", Enum.BleedOutStateFlags.BLEEDOUT_STATE_FLAG_CLAMPED)
				end
				return f10_local0
			end
		}, 
		{
			stateName = "Visible_Reviving", 
			condition = function (HudRef, ItemRef, UpdateTable)
				local f11_local0 = IsBleedOutVisible(ItemRef, InstanceRef)
				if f11_local0 then
					f11_local0 = IsSelfModelValueEnumBitSet(ItemRef, InstanceRef, "stateFlags", Enum.BleedOutStateFlags.BLEEDOUT_STATE_FLAG_BEING_REVIVED)
				end
				return f11_local0
			end
		}, 
		{
			stateName = "Visible", 
			condition = function (HudRef, ItemRef, UpdateTable)
				return IsBleedOutVisible(ItemRef, InstanceRef)
			end
		}
	})
	Widget:linkToElementModel(Widget, "bleedingOut", true, function (ModelRef)
		HudRef:updateElementState(Widget, {name = "model_validation", menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "bleedingOut"})
	end)
	Widget:linkToElementModel(Widget, "beingRevived", true, function (ModelRef)
		HudRef:updateElementState(Widget, {name = "model_validation", menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "beingRevived"})
	end)
	Widget:linkToElementModel(Widget, "stateFlags", true, function (ModelRef)
		HudRef:updateElementState(Widget, {name = "model_validation", menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "stateFlags"})
	end)
	
	LUI.OverrideFunction_CallOriginalSecond(Widget, "close", function (Sender)
		Sender.Waypoint:close()
	end)
	
	if f0_local3 then
		f0_local3(Widget, InstanceRef, HudRef)
	end
	
	return Widget
end

