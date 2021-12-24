require("ui.uieditor.widgets.MPHudWidgets.Waypoint")

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

CoD.VultureAidWaypointContainer = InheritFrom(LUI.UIElement)
CoD.VultureAidWaypointContainer.new = function (HudRef, InstanceRef, waypointContainer, Event)
	
	local objectiveModel = Engine.GetModel(Engine.GetModelForController(waypointContainer), ("objective" .. Event.objId))
	
	local Widget = LUI.UIElement.new()
	
	if PreLoadFunc then
		PreLoadFunc(Widget, InstanceRef)
	end
	
	Widget:setUseStencil(false)
	Widget:setClass(CoD.VultureAidWaypointContainer)
	Widget.id = "VultureAidWaypointContainer"
	Widget.soundSet = "default"
	Widget:setLeftRight(true, false, 0, 1280)
	Widget:setTopBottom(true, false, 0, 720)
	Widget.anyChildUsesUpdawaypointContainer = true
	
	local Waypoint = CoD.Waypoint.new(HudRef, InstanceRef)
	Waypoint:setLeftRight(true, true, 600, -600)
	Waypoint:setTopBottom(true, true, 315, -315)
	Widget:addElement(Waypoint)
	Widget.Waypoint = Waypoint
	
	local VultureIconGlow = LUI.UIImage.new()
	VultureIconGlow:setLeftRight(false, false, -100, 100)
	VultureIconGlow:setTopBottom(false, false, -100, 100)
	VultureIconGlow:setImage(RegisterImage("i_hud_ks_lit_glow"))
	VultureIconGlow:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	VultureIconGlow:setAlpha(0.7)
	VultureIconGlow:setRGB(1, 1, 1)
	Widget.VultureIconGlow = VultureIconGlow
	Waypoint:addElement(VultureIconGlow)

	local VultureIcon = LUI.UIImage.new()
	VultureIcon:setLeftRight(false, false, -30, 30)
	VultureIcon:setTopBottom(false, false, -30, 30)
	VultureIcon:setImage(RegisterImage("blacktransparent"))
	VultureIcon:setAlpha(1)
	VultureIcon:setRGB(1, 1, 1)
	Widget.VultureIcon = VultureIcon
	Waypoint:addElement(VultureIcon)	
	
	Engine.CreateModel(objectiveModel, "priority")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "priority"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue == nil then
			ModelValue = 0
		end
		waypointContainer:setPriority( ModelValue )
	end)
	
	Engine.CreateModel(objectiveModel, "vulture_icon")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "vulture_icon"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue ~= nil then
			VultureIcon:setImage(RegisterImage(ModelValue))
		end
	end)
	
	Engine.CreateModel(objectiveModel, "vulture_icon_colour")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "vulture_icon_colour"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue ~= nil then
			local splitstring = mysplit (ModelValue, ",")
			VultureIcon:setRGB(splitstring[1], splitstring[2], splitstring[3])
			VultureIconGlow:setRGB(splitstring[1], splitstring[2], splitstring[3])
		end
	end)
	
	Widget.clipsPerState = 
	{
		DefaultState = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(1)
				Waypoint:completeAnimation()
				Widget.Waypoint:setAlpha(0)
				Widget.clipFinished(Waypoint, {})
			end
		}, 
		Done = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(1)
				Waypoint:completeAnimation()
				Widget.Waypoint:setAlpha(1)
				local f7_local0 = function (f9_arg0, f9_arg1)
					if not f9_arg1.interrupted then
						f9_arg0:beginAnimation("keyframe", 1000, false, false, CoD.TweenType.Linear)
					end
					f9_arg0:setAlpha(0)
					if f9_arg1.interrupted then
						Widget.clipFinished(f9_arg0, f9_arg1)
					else
						f9_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
					end
				end

				f7_local0(Waypoint, {})
			end
		}
	}
	
	LUI.OverrideFunction_CallOriginalSecond(Widget, "close", function (Sender)
		Sender.VultureIconGlow:close()
		Sender.VultureIcon:close()
		Sender.Waypoint:close()
	end)
	
	if f0_local3 then
		f0_local3(Widget, InstanceRef, HudRef)
	end
	
	return Widget
end

