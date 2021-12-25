#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\throttle_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicles\_glaive;
// #using scripts\zm\_zm_ai_raps;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_lightning_chain;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_tesla;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_glaive;

#precache( "fx", "impacts/fx_flesh_hit_knife_lg_zmb" );

/*
	Name: __init__sytem__
	Namespace: namespace_2318f091
	Checksum: 0xC756E12B
	Offset: 0x700
	Size: 0x33
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_weap_glaive", &__init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: namespace_2318f091
	Checksum: 0x6E9D7651
	Offset: 0x740
	Size: 0x423
	Parameters: 0
	Flags: None
*/
function __init__()
{
	clientfield::register("allplayers", "slam_fx", 1, 1, "counter");
	clientfield::register("toplayer", "throw_fx", 1, 1, "counter");
	clientfield::register("toplayer", "swipe_fx", 1, 1, "counter");
	clientfield::register("toplayer", "swipe_lv2_fx", 1, 1, "counter");
	clientfield::register("actor", "zombie_slice_r", 1, 2, "counter");
	clientfield::register("actor", "zombie_slice_l", 1, 2, "counter");
	level._effect["glaive_blood_spurt"] = "impacts/fx_flesh_hit_knife_lg_zmb";
	level.var_8e4d3487 = 240;
	level.var_f1ed42ce = level.var_8e4d3487 * level.var_8e4d3487;
	level.var_906ed1e7 = 100;
	level.var_db3c626e = level.var_906ed1e7 * level.var_906ed1e7;
	level.glaive_chop_cone_range = 120;
	level.glaive_chop_cone_range_sq = level.glaive_chop_cone_range * level.glaive_chop_cone_range;
	level.var_3e0110d = 160;
	level.var_42894cb8 = level.var_3e0110d * level.var_3e0110d;
	callback::on_connect(&function_5d561ab0);
	for(i = 0; i < 4; i++)
	{
		zombie_utility::add_zombie_gib_weapon_callback("glaive_apothicon" + "_" + i, &function_906dfe04, &function_9e3debe7);
		zombie_utility::add_zombie_gib_weapon_callback("glaive_keeper" + "_" + i, &function_906dfe04, &function_9e3debe7);
		zm_hero_weapon::register_hero_weapon("glaive_apothicon" + "_" + i);
		zm_hero_weapon::register_hero_weapon("glaive_keeper" + "_" + i);
		zm_hero_weapon::register_hero_recharge_event(GetWeapon("glaive_apothicon" + "_" + i), &function_4a948f8a);
		zm_hero_weapon::register_hero_recharge_event(GetWeapon("glaive_keeper" + "_" + i), &function_4a948f8a);
	}
	level.var_44a72fa6 = Array("left_arm_upper", "left_arm_lower", "left_hand", "right_arm_upper", "right_arm_lower", "right_hand");
	level thread function_e97f78f0();
	// function_9b385ca5();
	level.var_b31b9421 = new Throttle();
	[[ level.var_b31b9421 ]]->Initialize(6,0.1);
}

/*
	Name: function_c3226e09
	Namespace: namespace_2318f091
	Checksum: 0x5C4CC332
	Offset: 0xB70
	Size: 0x8B
	Parameters: 1
	Flags: None
*/
function function_c3226e09(var_a38bb577)
{
	var_e4be281f = undefined;
	if(var_a38bb577 == 1)
	{
		var_e4be281f = "glaive_apothicon";
	}
	else
	{
		var_e4be281f = "glaive_keeper";
	}
	var_e4be281f = var_e4be281f + "_" + self.characterindex;
	var_d2af076 = GetWeapon(var_e4be281f);
	return var_d2af076;
}

/*
	Name: function_3f820ba7
	Namespace: namespace_2318f091
	Checksum: 0xFD497DEF
	Offset: 0xC08
	Size: 0xD7
	Parameters: 1
	Flags: None
*/
function function_3f820ba7(var_9fd9c680)
{
	self endon("hash_b29853d8");
	while(isdefined(self))
	{
		self waittill("weapon_change", var_7146ec21, var_46a99b76);
		if(var_7146ec21 != level.weaponNone && var_7146ec21 != var_9fd9c680)
		{
			self.usingsword = 0;
			if(self.autokill_glaive_active)
			{
				self EnableOffhandWeapons();
				self thread function_762ff0b6(var_9fd9c680);
				self waittill("hash_8a993396");
			}
			// self function_24587ddb();
			self notify("hash_b29853d8");
			return;
		}
	}
}

/*
	Name: function_762ff0b6
	Namespace: namespace_2318f091
	Checksum: 0x56BD8EDF
	Offset: 0xCE8
	Size: 0xD7
	Parameters: 1
	Flags: None
*/
function function_762ff0b6(var_46a99b76)
{
	self endon("hash_8a993396");
	var_fbfaeadb = GetTime();
	while(isdefined(self) && IS_TRUE(self.autokill_glaive_active))
	{
		rate = 1.667;
		if(isdefined(var_46a99b76.gadget_power_usage_rate))
		{
			rate = var_46a99b76.gadget_power_usage_rate;
		}
		self.sword_power = self.sword_power - 0.0005 * rate;
		self GadgetPowerSet(0, self.sword_power * 100);
		wait(0.05);
	}
}

/*
	Name: function_50cf29d
	Namespace: namespace_2318f091
	Checksum: 0x2844E7FF
	Offset: 0xDC8
	Size: 0x2B
	Parameters: 1
	Flags: None
*/
function function_50cf29d(evt)
{
	self PlayRumbleOnEntity("lightninggun_charge");
}

/*
	Name: function_5c998ffc
	Namespace: namespace_2318f091
	Checksum: 0x9894F53A
	Offset: 0xE00
	Size: 0x42B
	Parameters: 4
	Flags: None
*/
function function_5c998ffc(var_52baa43a, var_c93fc6c, var_7146ec21, var_46a99b76)
{
	if(self.var_86a785ad && !IS_TRUE( self.usingsword ) )
	{
		if(IsSubStr(var_7146ec21.name, "glaive_keeper")) // if(var_7146ec21 == var_c93fc6c)
		{
			self.current_sword = var_c93fc6c;
			self.var_2ef815cf = 0;
			self disableOffhandWeapons();
			self notify("hash_f0078f48");
			self thread function_3f820ba7(var_7146ec21);
			if(!IS_TRUE(self.usingsword))
			{
				self GadgetPowerSet(0, 100);
				// self clientfield::set_player_uimodel("zmhud.swordEnergy", 1);
				// self clientfield::set_player_uimodel("zmhud.swordState", 2);
				self.sword_power = 1;
			}
			self notify("hash_b74ad0fb");
			self thread function_50cf29d("lv2start");
			self.usingsword = 1;
			self.autokill_glaive_active = 0;
			slot = self GadgetGetSlot(var_c93fc6c);
			self thread function_a15f6f64(slot);
			self thread function_d0a73497(var_7146ec21, 1);
			self thread function_1fb44d05(var_c93fc6c);
			self waittill("hash_b29853d8");
			self EnableOffhandWeapons();
			self allowMeleePowerLeft(1);
			self.usingsword = 0;
			// self function_24587ddb();
		}
		else if(IsSubStr(var_7146ec21.name,"glaive_apothicon")) // else if(var_7146ec21 == var_52baa43a)
		{
			self.current_sword = var_52baa43a;
			self.var_2ef815cf = 1;
			self disableOffhandWeapons();
			self notify("hash_f0078f48");
			self thread function_3f820ba7(var_7146ec21);
			if(!(isdefined(self.usingsword) && self.usingsword))
			{
				self GadgetPowerSet(0, 100);
				// self clientfield::set_player_uimodel("zmhud.swordEnergy", 1);
				// self clientfield::set_player_uimodel("zmhud.swordState", 6);
				self.sword_power = 1;
			}
			self notify("hash_b74ad0fb");
			self thread function_50cf29d("lv1start");
			self.usingsword = 1;
			self.autokill_glaive_active = 0;
			slot = self GadgetGetSlot(var_52baa43a);
			self thread function_a15f6f64(slot);
			self thread function_d0a73497(var_52baa43a, 0);
			self thread function_1de29b67(var_52baa43a);
			self waittill("hash_b29853d8");
			self EnableOffhandWeapons();
			self allowMeleePowerLeft(1);
			self.usingsword = 0;
			// self function_24587ddb();
		}
	}
}

/*
	Name: function_5d561ab0
	Namespace: namespace_2318f091
	Checksum: 0xD89FBDF
	Offset: 0x1238
	Size: 0xC7
	Parameters: 0
	Flags: Private
*/
function private function_5d561ab0()
{
	self endon("disconnect");
	var_52baa43a = self function_c3226e09(1);
	var_c93fc6c = self function_c3226e09(2);
	self.var_86a785ad = 1;
	self.usingsword = 0;
	while(1)
	{
		self waittill("weapon_change", var_7146ec21, var_46a99b76);
		self function_5c998ffc(var_52baa43a, var_c93fc6c, var_7146ec21, var_46a99b76);
	}
}

/*
	Name: function_906dfe04
	Namespace: namespace_2318f091
	Checksum: 0xBFBC337B
	Offset: 0x1308
	Size: 0x43
	Parameters: 1
	Flags: Private
*/
function private function_906dfe04(damage_percent)
{
	self.var_5f40519e = "none";
	if(damage_percent > 99.8)
	{
		self.var_5f40519e = "neck";
		return 1;
	}
	return 0;
}

/*
	Name: function_9e3debe7
	Namespace: namespace_2318f091
	Checksum: 0x437463AF
	Offset: 0x1358
	Size: 0x7B
	Parameters: 1
	Flags: Private
*/
function private function_9e3debe7(damage_location)
{
	if(self.var_5f40519e === "neck")
	{
		return 1;
	}
	if(!isdefined(damage_location))
	{
		return 0;
	}
	if(damage_location == "head")
	{
		return 1;
	}
	if(damage_location == "helmet")
	{
		return 1;
	}
	if(damage_location == "neck")
	{
		return 1;
	}
	return 0;
}

/*
	Name: function_1de29b67
	Namespace: namespace_2318f091
	Checksum: 0x584DF384
	Offset: 0x13E0
	Size: 0x97
	Parameters: 1
	Flags: Private
*/
function private function_1de29b67(var_52baa43a)
{
	self endon("hash_b29853d8");
	self endon("disconnect");
	self endon("bled_out");
	while(1)
	{
		self waittill("weapon_melee_power_left", weapon);
		if(IsSubStr(weapon.name,"glaive_apothicon"))
		{
			self clientfield::increment("slam_fx");
			self thread function_da195a32(var_52baa43a);
		}
	}
}

/*
	Name: function_da195a32
	Namespace: namespace_2318f091
	Checksum: 0x725BDACF
	Offset: 0x1480
	Size: 0x2C1
	Parameters: 1
	Flags: Private
*/
function private function_da195a32(var_52baa43a)
{
	view_pos = self GetWeaponMuzzlePoint();
	forward_view_angles = self GetWeaponForwardDir();
	zombie_list = GetAITeamArray(level.zombie_team);
	foreach(ai in zombie_list)
	{
		if(!isdefined(ai) || !isalive(ai))
		{
			continue;
		}
		test_origin = ai GetCentroid();
		dist_sq = DistanceSquared(view_pos, test_origin);
		if(dist_sq < level.var_f1ed42ce)
		{
			if(isdefined(ai.var_a3b60c68))
			{
				self thread [[ai.var_a3b60c68]](ai, var_52baa43a);
			}
			else
			{
				self thread function_20654ca0(ai, var_52baa43a);
			}
			continue;
		}
		if(dist_sq > level.var_db3c626e)
		{
			continue;
		}
		normal = VectorNormalize(test_origin - view_pos);
		dot = VectorDot(forward_view_angles, normal);
		if(0.707 > dot)
		{
			continue;
		}
		if(0 == ai damageConeTrace(view_pos, self))
		{
			continue;
		}
		if(isdefined(ai.var_a3b60c68))
		{
			self thread [[ai.var_a3b60c68]](ai, var_52baa43a);
			continue;
		}
		self thread function_20654ca0(ai, var_52baa43a);
	}
}

/*
	Name: function_20654ca0
	Namespace: namespace_2318f091
	Checksum: 0xC02AAF17
	Offset: 0x1750
	Size: 0xE3
	Parameters: 2
	Flags: None
*/
function function_20654ca0(ai, var_52baa43a)
{
	self endon("disconnect");
	if(!isdefined(ai) || !isalive(ai))
	{
		return;
	}
	if(!isdefined(self.tesla_enemies_hit))
	{
		self.tesla_enemies_hit = 1;
	}
	ai notify("bhtn_action_notify", "electrocute");
	function_72ca5a88();
	ai.tesla_death = 0;
	ai thread function_fe8a580e(ai.origin, ai.origin, self);
	ai thread tesla_death(self);
}

/*
	Name: function_72ca5a88
	Namespace: namespace_2318f091
	Checksum: 0x22B7069F
	Offset: 0x1840
	Size: 0x5F
	Parameters: 0
	Flags: None
*/
function function_72ca5a88()
{
	level.var_ba84a05b = lightning_chain::create_lightning_chain_params(1);
	level.var_ba84a05b.head_gib_chance = 100;
	level.var_ba84a05b.network_death_choke = 4;
	level.var_ba84a05b.should_kill_enemies = 0;
}

/*
	Name: tesla_death
	Namespace: namespace_2318f091
	Checksum: 0x3B880FCF
	Offset: 0x18A8
	Size: 0x7B
	Parameters: 1
	Flags: None
*/
function tesla_death(player)
{
	self endon("death");
	self thread function_862aadab(1);
	wait(2);
	player thread zm_audio::create_and_play_dialog("kill", "sword_slam");
	self DoDamage(self.health + 1, self.origin);
}

/*
	Name: function_fe8a580e
	Namespace: namespace_2318f091
	Checksum: 0xA990EBBD
	Offset: 0x1930
	Size: 0x63
	Parameters: 3
	Flags: None
*/
function function_fe8a580e(HIT_LOCATION, hit_origin, player)
{
	player endon("disconnect");
	if(IS_TRUE(self.zombie_tesla_hit))
	{
		return;
	}
	self lightning_chain::arc_damage_ent(player, 1, level.var_ba84a05b);
}

/*
	Name: chop_actor
	Namespace: namespace_2318f091
	Checksum: 0x755B2ED3
	Offset: 0x19A0
	Size: 0x1B3
	Parameters: 4
	Flags: None
*/
function chop_actor(ai, upgraded, leftswing, weapon)
{
	if(!isdefined(weapon))
	{
		weapon = level.weaponNone;
	}
	self endon("disconnect");
	if(!isdefined(ai) || !isalive(ai))
	{
		return;
	}
	if(IS_TRUE(upgraded))
	{
		if(9317 >= ai.health)
		{
			ai.ignoreMelee = 1;
		}
		[[ level.var_b31b9421 ]]->WaitInQueue(ai);
		ai DoDamage(9317, self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	}
	else if(3594 >= ai.health)
	{
		ai.ignoreMelee = 1;
	}
	[[ level.var_b31b9421 ]]->WaitInQueue(ai);
	ai DoDamage(3594, self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	ai function_996725b9(leftswing, upgraded);
	util::wait_network_frame();
}

/*
	Name: function_862aadab
	Namespace: namespace_2318f091
	Checksum: 0x38E1D52D
	Offset: 0x1B60
	Size: 0x12B
	Parameters: 1
	Flags: None
*/
function function_862aadab(random_gibs)
{
	if(isdefined(self) && IsActor(self))
	{
		if(!random_gibs || RandomInt(100) < 50)
		{
			GibServerUtils::GibHead(self);
		}
		if(!random_gibs || RandomInt(100) < 50)
		{
			GibServerUtils::GibLeftArm(self);
		}
		if(!random_gibs || RandomInt(100) < 50)
		{
			GibServerUtils::GibRightArm(self);
		}
		if(!random_gibs || RandomInt(100) < 50)
		{
			GibServerUtils::GibLegs(self);
		}
	}
}

/*
	Name: function_996725b9
	Namespace: namespace_2318f091
	Checksum: 0xF706AECF
	Offset: 0x1C98
	Size: 0xEB
	Parameters: 2
	Flags: Private
*/
function private function_996725b9(var_d98455ab, var_26ba0d4c)
{
	if(self.archetype == "zombie")
	{
		if(var_d98455ab)
		{
			if(IS_TRUE(var_26ba0d4c))
			{
				self clientfield::increment("zombie_slice_l", 2);
			}
			else
			{
				self clientfield::increment("zombie_slice_l", 1);
			}
		}
		else if(IS_TRUE(var_26ba0d4c))
		{
			self clientfield::increment("zombie_slice_r", 2);
		}
		else
		{
			self clientfield::increment("zombie_slice_r", 1);
		}
	}
}

/*
	Name: chop_zombies
	Namespace: namespace_2318f091
	Checksum: 0x8E742C1C
	Offset: 0x1D90
	Size: 0x309
	Parameters: 4
	Flags: None
*/
function chop_zombies(first_time, var_10ee11e, leftswing, weapon)
{
	if(!isdefined(weapon))
	{
		weapon = level.weaponNone;
	}
	view_pos = self GetWeaponMuzzlePoint();
	forward_view_angles = self GetWeaponForwardDir();
	zombie_list = GetAITeamArray(level.zombie_team);
	foreach(ai in zombie_list)
	{
		if(!isdefined(ai) || !isalive(ai))
		{
			continue;
		}
		if(first_time)
		{
			ai.chopped = 0;
		}
		else if(IS_TRUE(ai.chopped))
		{
			continue;
		}
		test_origin = ai GetCentroid();
		dist_sq = DistanceSquared(view_pos, test_origin);
		dist_to_check = level.glaive_chop_cone_range_sq;
		if(var_10ee11e)
		{
			dist_to_check = level.var_42894cb8;
		}
		if(dist_sq > dist_to_check)
		{
			continue;
		}
		normal = VectorNormalize(test_origin - view_pos);
		dot = VectorDot(forward_view_angles, normal);
		if(dot <= 0)
		{
			continue;
		}
		if(0 == ai damageConeTrace(view_pos, self))
		{
			continue;
		}
		ai.chopped = 1;
		if(isdefined(ai.chop_actor_cb))
		{
			self thread [[ai.chop_actor_cb]](ai, self, weapon);
			continue;
		}
		self thread chop_actor(ai, var_10ee11e, leftswing, weapon);
	}
}

/*
	Name: function_4a6a1b77
	Namespace: namespace_2318f091
	Checksum: 0x5B4299FB
	Offset: 0x20A8
	Size: 0xD3
	Parameters: 2
	Flags: None
*/
function function_4a6a1b77(player, var_10ee11e)
{
	if(var_10ee11e)
	{
		player clientfield::increment_to_player("swipe_lv2_fx");
	}
	else
	{
		player clientfield::increment_to_player("swipe_fx");
	}
	player thread chop_zombies(1, var_10ee11e, 1, self);
	wait(0.3);
	player thread chop_zombies(0, var_10ee11e, 1, self);
	wait(0.5);
	player thread chop_zombies(0, var_10ee11e, 0, self);
}

/*
	Name: function_d0a73497
	Namespace: namespace_2318f091
	Checksum: 0x245A67A7
	Offset: 0x2188
	Size: 0x87
	Parameters: 2
	Flags: Private
*/
function private function_d0a73497(weapon, var_10ee11e)
{
	self endon("hash_b29853d8");
	self endon("disconnect");
	self endon("bled_out");
	while(1)
	{
		self util::waittill_any("weapon_melee_power", "weapon_melee");
		weapon thread function_4a6a1b77(self, var_10ee11e);
	}
}

/*
	Name: function_1fb44d05
	Namespace: namespace_2318f091
	Checksum: 0x224C3688
	Offset: 0x2218
	Size: 0x87
	Parameters: 1
	Flags: Private
*/
function private function_1fb44d05(var_c93fc6c)
{
	self endon("hash_b29853d8");
	self endon("disconnect");
	self endon("bled_out");
	while(1)
	{
		self waittill("weapon_melee_power_left", weapon);
		if(IsSubStr(weapon.name,"glaive_keeper") && self.autokill_glaive_active == 0)
		{
			self thread function_946ce935(var_c93fc6c);
		}
	}
}

/*
	Name: function_86ee93a8
	Namespace: namespace_2318f091
	Checksum: 0x8DC10D32
	Offset: 0x22A8
	Size: 0x6B
	Parameters: 0
	Flags: None
*/
function function_86ee93a8()
{
	if(IS_TRUE(self.var_8f6c69b8))
	{
		return;
	}
	self.var_8f6c69b8 = 1;
	self notify("hide_equipment_hint_text");
	util::wait_network_frame();
	zm_equipment::show_hint_text("Hold ^3[{+speed_throw}]^7 to recall the Archon Sword", 3.2);
}

/*
	Name: function_729af361
	Namespace: namespace_2318f091
	Checksum: 0xAB305DD9
	Offset: 0x2320
	Size: 0xE3
	Parameters: 1
	Flags: Private
*/
function private function_729af361(var_1c7a4c9a)
{
	self endon("disconnect");
	self endon("hash_b29853d8");
	self endon("weapon_change");
	var_1c7a4c9a endon("returned_to_owner");
	var_1c7a4c9a endon("disconnect");
	self thread function_86ee93a8();
	self.var_c0d25105._glaive_must_return_to_owner = 0;
	while(isdefined(self) && self throwbuttonpressed())
	{
		wait(0.05);
	}
	while(isdefined(self))
	{
		if(self throwbuttonpressed())
		{
			self.var_c0d25105._glaive_must_return_to_owner = 1;
			return;
		}
		wait(0.05);
	}
}

/*
	Name: function_946ce935
	Namespace: namespace_2318f091
	Checksum: 0x777D00D4
	Offset: 0x2410
	Size: 0x2D3
	Parameters: 1
	Flags: Private
*/
function private function_946ce935(var_c93fc6c)
{
	var_37d6ca9f = GetSpawnerArray("glaive_spawner", "script_noteworthy");
	var_8e77ef3f = var_37d6ca9f[0];
	var_8e77ef3f.count = 1;
	var_1c7a4c9a = var_8e77ef3f SpawnFromSpawner("player_glaive_" + self.characterindex, 1);
	self.var_c0d25105 = var_1c7a4c9a;
	if(isdefined(var_1c7a4c9a))
	{
		var_1c7a4c9a vehicle::lights_on();
		self clientfield::increment_to_player("throw_fx");
		var_1c7a4c9a.origin = self.origin + 80 * AnglesToForward(self.angles) + VectorScale((0, 0, 1), 50);
		var_1c7a4c9a.angles = self getPlayerAngles();
		var_1c7a4c9a.owner = self;
		var_1c7a4c9a.weapon = var_c93fc6c;
		var_1c7a4c9a._glaive_settings_lifetime = math::clamp(self.sword_power * 100, 10, 60);
		self.autokill_glaive_active = 1;
		self allowMeleePowerLeft(0);
		self thread function_50cf29d("lv2launch");
		self thread function_729af361(var_1c7a4c9a);
		var_1c7a4c9a util::waittill_any("returned_to_owner", "disconnect");
		self thread function_50cf29d("lv2recover");
		self allowMeleePowerLeft(1);
		self.autokill_glaive_active = 0;
		self notify("hash_8a993396");
		self.var_c0d25105 = undefined;
		if(isdefined(self))
		{
			util::wait_network_frame();
			self playsound("wpn_sword2_return");
		}
		var_1c7a4c9a delete();
	}
}

/*
	Name: function_e97f78f0
	Namespace: namespace_2318f091
	Checksum: 0x67BDACB7
	Offset: 0x26F0
	Size: 0x2C7
	Parameters: 0
	Flags: None
*/
function function_e97f78f0()
{
	while(1)
	{
		foreach(player in GetPlayers())
		{
			if(isdefined(player.sword_power) && !IS_TRUE(player.var_86a785ad))
			{
				player.sword_power = player GadgetPowerGet(0) / 100;
				// player clientfield::set_player_uimodel("zmhud.swordEnergy", player.sword_power);
				if(player.sword_power >= 1)
				{
					player.var_86a785ad = 1;
					if(isdefined(player.current_sword) && !IS_TRUE(player.usingsword) && !IS_TRUE(player.autokill_glaive_active))
					{
						player GiveWeapon(player.current_sword);
						player.var_86a785ad = 1;
						player GadgetPowerSet(0, 100);
						// player clientfield::set_player_uimodel("zmhud.swordEnergy", 1);
						if(IS_TRUE(player.var_2ef815cf))
						{
							// player clientfield::set_player_uimodel("zmhud.swordState", 6);
						}
						else
						{
							// player clientfield::set_player_uimodel("zmhud.swordState", 2);
						}
						player.sword_power = 1;
						player zm_equipment::show_hint_text("Press ^3[{+ability}]^7 to Wield Sword.", 2);
					}
				}
			}
		}
		wait(0.05);
	}
}

/*
	Name: function_24587ddb
	Namespace: namespace_2318f091
	Checksum: 0x332E9F18
	Offset: 0x29C0
	Size: 0x1B3
	Parameters: 0
	Flags: None
*/
/*
function function_24587ddb()
{
	if(IS_TRUE(self.usingsword))
	{
		return;
	}
	var_52baa43a = self function_c3226e09(1);
	var_c93fc6c = self function_c3226e09(2);
	/#
		if(IS_TRUE(self.swordpreserve))
		{
			self.var_86a785ad = 1;
			return;
		}
	#/
	self.var_86a785ad = 0;
	if(self HasWeapon(var_c93fc6c))
	{
		iPrintLnBold( "^1TESTING" );
		// self clientfield::set_player_uimodel("zmhud.swordState", 1);
		if(0)
		{
			// self clientfield::set_player_uimodel("zmhud.swordEnergy", 0);
			self GadgetPowerSet(0, 0);
			self.sword_power = 0;
		}
	}
	else if(self HasWeapon(var_52baa43a))
	{
		iPrintLnBold( "^1TESTING" );
		// self clientfield::set_player_uimodel("zmhud.swordState", 5);
		if(0)
		{
			// self clientfield::set_player_uimodel("zmhud.swordEnergy", 0);
			self GadgetPowerSet(0, 0);
			self.sword_power = 0;
		}
	}
}
*/

/*
	Name: function_a15f6f64
	Namespace: namespace_2318f091
	Checksum: 0x249BE0D
	Offset: 0x2B80
	Size: 0x2C1
	Parameters: 1
	Flags: None
*/
function function_a15f6f64(slot)
{
	self endon("disconnect");
	self endon("hash_b29853d8");
	// while(isdefined(self) && (isdefined(self.usingsword) && self.usingsword || (isdefined(self.autokill_glaive_active) && self.autokill_glaive_active)) && self.sword_power > 0)
	while(isdefined(self) && (IS_TRUE(self.usingsword) || IS_TRUE(self.autokill_glaive_active) && self.sword_power > 0))
	{
		if(IS_TRUE(self.teleporting))
		{
			wait(0.05);
			continue;
		}
		self.sword_power = self GadgetPowerGet(slot) / 100;
		// self clientfield::set_player_uimodel("zmhud.swordEnergy", self.sword_power);
		if(IS_TRUE(self.var_2ef815cf))
		{
			// self clientfield::set_player_uimodel("zmhud.swordState", 7);
		}
		else
		{
			// self clientfield::set_player_uimodel("zmhud.swordState", 3);
		}
		/#
			if(IS_TRUE(self.swordpreserve))
			{
				self.sword_power = 1;
				// self clientfield::set_player_uimodel("Dev Block strings are not supported", 1);
				if(IS_TRUE(self.var_2ef815cf))
				{
					// self clientfield::set_player_uimodel("Dev Block strings are not supported", 6);
				}
				else
				{
					// self clientfield::set_player_uimodel("Dev Block strings are not supported", 2);
				}
				self GadgetPowerSet(0, 100);
			}
		#/
		wait(0.05);
	}
	self thread function_50cf29d("oopower");
	self.usingsword = 0;
	self.autokill_glaive_active = 0;
	self notify("hash_8a993396");
	if(isdefined(self.var_c0d25105))
	{
		self.var_c0d25105._glaive_must_return_to_owner = 1;
	}
	while(self IsSlamming())
	{
		wait(0.05);
	}
	// self function_24587ddb();
	self notify("hash_b29853d8");
}

/*
	Name: function_4a948f8a
	Namespace: namespace_2318f091
	Checksum: 0x443C20E2
	Offset: 0x2E50
	Size: 0x1D3
	Parameters: 2
	Flags: None
*/
function function_4a948f8a(player, enemy)
{
	if(player laststand::player_is_in_laststand())
	{
		return;
	}
	if(isdefined(player) && !IS_TRUE(player.usingsword) && !IS_TRUE(player.autokill_glaive_active) && isdefined(player.current_sword))
	{
		if(isdefined(enemy.sword_kill_power))
		{
			perkFactor = 1;
			if(player hasPerk("specialty_overcharge"))
			{
				perkFactor = GetDvarFloat("gadgetPowerOverchargePerkScoreFactor");
			}
			temp = player.sword_power + perkFactor * enemy.sword_kill_power / 100;
			player.sword_power = math::clamp(temp, 0, 1);
			// player clientfield::set_player_uimodel("zmhud.swordEnergy", player.sword_power);
			player GadgetPowerSet(0, 100 * player.sword_power);
			player clientfield::increment_uimodel("zmhud.swordChargeUpdate");
		}
	}
}

/*
	Name: function_7855de72
	Namespace: namespace_2318f091
	Checksum: 0x62106619
	Offset: 0x3030
	Size: 0x23
	Parameters: 1
	Flags: None
*/
function function_7855de72(player)
{
	/#
		// player ability_player::function_10f3334();
	#/
}

