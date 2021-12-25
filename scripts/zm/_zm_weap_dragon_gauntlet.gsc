#using scripts\shared\abilities\_ability_player;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\throttle_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicles\_dragon_whelp;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "model", 	"wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_world" );
#precache( "model", 	"wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_upg_world" );
#precache( "fx", 	"dlc3/stalingrad/fx_fire_generic_zmb_green" );
#precache( "fx", 	"dlc3/stalingrad/fx_fire_torso_zmb_green" );

#namespace zm_weap_dragon_gauntlet;

REGISTER_SYSTEM_EX( "zm_weap_dragon_gauntlet", &__init__, undefined, undefined )

function __init__()
{
	level.w_dragon_gauntlet_flamethrower = GetWeapon("dragon_gauntlet_flamethrower");
	level.w_dragon_gauntlet = GetWeapon("dragon_gauntlet");
	zm_hero_weapon::register_hero_recharge_event(level.w_dragon_gauntlet_flamethrower, &dragon_gauntlet_power_override);
	zm_hero_weapon::register_hero_recharge_event(level.w_dragon_gauntlet, &dragon_gauntlet_power_override);
	callback::on_connect(&on_connect_func_for_dragon_gauntlet);
	callback::on_player_killed(&on_player_killed_func_for_dragon_gauntlet);
	zm_hero_weapon::register_hero_weapon("dragon_gauntlet_flamethrower");
	zm_hero_weapon::register_hero_weapon_wield_unwield_callbacks("dragon_gauntlet_flamethrower", &wield_dragon_gauntlet, &unwield_dragon_gauntlet);
	zm_hero_weapon::register_hero_weapon_power_callbacks("dragon_gauntlet_flamethrower", &dragon_gauntlet_power_full, &dragon_gauntlet_power_expired);
	zm_hero_weapon::register_hero_weapon("dragon_gauntlet");
	zm_hero_weapon::register_hero_weapon_wield_unwield_callbacks("dragon_gauntlet", &wield_dragon_gauntlet_melee, &unwield_dragon_gauntlet_melee);
	zm_hero_weapon::register_hero_weapon_power_callbacks("dragon_gauntlet", &dragon_gauntlet_power_full, &dragon_gauntlet_power_expired);
	zm::register_actor_damage_callback(&on_actor_damage_func_for_dragon_gauntlet);
	// function_9b385ca5();
	level.var_af9cd4ca = new Throttle();
	[[ level.var_af9cd4ca ]]->Initialize(6,0.1);
}

function private on_connect_func_for_dragon_gauntlet()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("death");
	self endon("dragon_gauntlet_expired");
	self update_dragon_gauntlet_state(0);
	self.w_dragon_gauntlet_flamethrower = level.w_dragon_gauntlet_flamethrower;
	self.w_dragon_gauntlet = level.w_dragon_gauntlet;
	self.var_d15b9a33 = "spawner_bo3_dragon_whelp";
	self.var_956fba75 = 0;
	self.var_5307dedb = 0;
	if(IS_TRUE(self.var_cc844f4c))
	{
		self.var_cc844f4c = 0;
	}
	if(isdefined(self.var_4bd1ce6b))
	{
		self function_22d7caeb();
	}
	do
	{
		// self waittill("new_dragon_gauntlet_weapon", weapon);
		self waittill("weapon_change", weapon);
	}
	while(weapon != self.w_dragon_gauntlet_flamethrower);
	if(isdefined(self.var_85466cc5) && isdefined(self.var_85466cc5["dragon_gauntlet_flamethrower"]))
	{
		self SetWeaponAmmoClip(level.w_dragon_gauntlet_flamethrower, self.var_85466cc5["dragon_gauntlet_flamethrower"]);
		self.var_85466cc5 = undefined;
	}
	else
	{
		self SetWeaponAmmoClip(self.w_dragon_gauntlet_flamethrower, self.w_dragon_gauntlet_flamethrower.clipSize);
	}
	if(isdefined(self.saved_dragon_gauntlet_power))
	{
		self GadgetPowerSet(0, self.saved_dragon_gauntlet_power);
		self.saved_dragon_gauntlet_power = undefined;
	}
	else
	{
		self GadgetPowerSet(0, 100);
	}
	self thread weapon_change_watcher();
}

function reset_after_bleeding_out()
{
	self endon("disconnect");
	self waittill("spawned_player");
	self on_player_killed_func_for_dragon_gauntlet();
	self thread on_connect_func_for_dragon_gauntlet();
}

function on_player_killed_func_for_dragon_gauntlet()
{
	player = self;
	if(IS_TRUE(player.var_cc844f4c))
	{
		player thread function_22d7caeb();
	}
}

function give_dragon_gauntlet()
{
	player = self;
	player zm_weapons::weapon_give(self.w_dragon_gauntlet_flamethrower, 0, 1);
	player thread zm_equipment::show_hint_text(&"DLC3_WEAP_DRAGON_GAUNTLET_USE_HINT", 3);
	player.dragon_gauntlet_power = 100;
	player.hero_power = 100;
	player GadgetPowerSet(0, 100);
	player zm_hero_weapon::set_hero_weapon_state(self.w_dragon_gauntlet_flamethrower, 2);
	player SetWeaponAmmoClip(self.w_dragon_gauntlet_flamethrower, self.w_dragon_gauntlet_flamethrower.clipSize);
	player.b_has_dragon_gauntlet = 1;
}

function update_dragon_gauntlet_state(n_dragon_gauntlet_state)
{
	self.n_dragon_gauntlet_state = n_dragon_gauntlet_state;
}

function wield_dragon_gauntlet(w_dragon_gauntlet_weapon)
{
	if(IS_TRUE(self.var_cc844f4c))
	{
		self function_22d7caeb();
	}
	if(!IS_TRUE(self.var_d0827e15))
	{
		self.var_d0827e15 = 1;
		self zm_audio::create_and_play_dialog("whelp", "aquire");
	}
	self zm_hero_weapon::default_wield(w_dragon_gauntlet_weapon);
	self update_dragon_gauntlet_state(3);
	self SetWeaponAmmoClip(w_dragon_gauntlet_weapon, w_dragon_gauntlet_weapon.clipSize);
	self.dragon_gauntlet_power = self GadgetPowerGet(0);
	self.hero_power = self GadgetPowerGet(0);
	self disableOffhandWeapons();
	if(isdefined(self.dragon_gauntlet_power))
	{
		self GadgetPowerSet(0, self.dragon_gauntlet_power);
	}
	self.hero_power = self GadgetPowerGet(0);
	self notify("stop_draining_hero_weapon");
	if(!isdefined(self.var_956fba75) || self.var_956fba75 < 3)
	{
		self thread zm_equipment::show_hint_text(&"DLC3_WEAP_DRAGON_GAUNTLET_FLAMETHROWER_HINT", 3);
		self.var_956fba75 = self.var_956fba75 + 1;
	}
	self thread zm_hero_weapon::continue_draining_hero_weapon(self.w_dragon_gauntlet_flamethrower);
	self.var_4c8e9f40 = GetTime() + 1000;
	self thread function_c0093887();
	self thread function_22a08c51(w_dragon_gauntlet_weapon);
}

function unwield_dragon_gauntlet(w_dragon_gauntlet_weapon)
{
	self notify("dragon_gauntlet_unwield");
	self.dragon_gauntlet_power = self GadgetPowerGet(0);
	self.hero_power = self GadgetPowerGet(0);
	self zm_hero_weapon::default_unwield(w_dragon_gauntlet_weapon);
	self update_dragon_gauntlet_state(1);
	self notify("stop_draining_hero_weapon");
	self EnableOffhandWeapons();
	if(zm_weapons::has_weapon_or_attachments(w_dragon_gauntlet_weapon))
	{
		self SetWeaponAmmoClip(w_dragon_gauntlet_weapon, 0);
	}
}

function wield_dragon_gauntlet_melee(w_dragon_gauntlet_melee_weapon)
{
	self zm_hero_weapon::default_wield(w_dragon_gauntlet_melee_weapon);
	self update_dragon_gauntlet_state(3);
	self SetWeaponAmmoClip(w_dragon_gauntlet_melee_weapon, w_dragon_gauntlet_melee_weapon.clipSize);
	self.dragon_gauntlet_power = self GadgetPowerGet(0);
	self.hero_power = self GadgetPowerGet(0);
	self disableOffhandWeapons();
	if(isdefined(self.dragon_gauntlet_power))
	{
		self GadgetPowerSet(0, self.dragon_gauntlet_power);
	}
	if(!isdefined(self.var_5307dedb) || self.var_5307dedb < 3)
	{
		self thread zm_equipment::show_hint_text(&"DLC3_WEAP_DRAGON_GAUNTLET_MELEE_HINT", 3);
		self.var_5307dedb = self.var_5307dedb + 1;
	}
	self.hero_power = self GadgetPowerGet(0);
	self notify("stop_draining_hero_weapon");
	self thread zm_hero_weapon::continue_draining_hero_weapon(self.w_dragon_gauntlet);
	self thread function_d7a4275d();
	self thread function_62d6a233();
	self thread function_8e2014a0();
	self thread function_22a08c51(w_dragon_gauntlet_melee_weapon);
}

function unwield_dragon_gauntlet_melee(w_dragon_gauntlet_melee_weapon)
{
	self notify("hash_20599947");
	self.dragon_gauntlet_power = self GadgetPowerGet(0);
	self.hero_power = self GadgetPowerGet(0);
	self zm_hero_weapon::default_unwield(w_dragon_gauntlet_melee_weapon);
	self update_dragon_gauntlet_state(1);
	self EnableOffhandWeapons();
	if(zm_weapons::has_weapon_or_attachments(w_dragon_gauntlet_melee_weapon))
	{
		self SetWeaponAmmoClip(w_dragon_gauntlet_melee_weapon, 0);
	}
	self notify("stop_draining_hero_weapon");
	if(self zm_weapons::has_weapon_or_attachments(w_dragon_gauntlet_melee_weapon))
	{
		self SetWeaponAmmoClip(w_dragon_gauntlet_melee_weapon, 0);
	}
	if(IS_TRUE(self.var_cc844f4c))
	{
		self thread zm_hero_weapon::continue_draining_hero_weapon(self.w_dragon_gauntlet);
		self thread zm_hero_weapon::continue_draining_hero_weapon(self.w_dragon_gauntlet_flamethrower);
	}
}

function weapon_change_watcher()
{
	self endon("disconnect");
	self.var_f2a52896 = undefined;
	while(1)
	{
		self waittill("weapon_change", w_current, w_previous);
		if(w_current === level.w_dragon_gauntlet_flamethrower)
		{
			if(self.var_f2a52896 === "wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_upg_world")
			{
				self Detach(self.var_f2a52896, "J_Elbow_RI");
			}
			self.var_f2a52896 = "wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_world";
			self Attach(self.var_f2a52896, "J_Elbow_RI");
		}
		else if(w_current === level.w_dragon_gauntlet)
		{
			if(self.var_f2a52896 === "wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_world")
			{
				self Detach(self.var_f2a52896, "J_Elbow_RI");
			}
			self.var_f2a52896 = "wpn_t7_zmb_dlc3_gauntlet_dragon_elbow_upg_world";
			self Attach(self.var_f2a52896, "J_Elbow_RI");
		}
		else if(isdefined(self.var_f2a52896))
		{
			self Detach(self.var_f2a52896, "J_Elbow_RI");
			self.var_f2a52896 = undefined;
		}
		if(isdefined(w_previous) && w_previous.name !== "none" && zm_utility::is_hero_weapon(w_current) && !zm_utility::is_hero_weapon(w_previous))
		{
			self.var_a1ee595 = w_previous;
		}
	}
}

function function_22a08c51(weapon)
{
	self endon("death");
	self endon("bled_out");
	self endon("disconnect");
	self endon("dragon_gauntlet_expired");
	self endon("stop_draining_hero_weapon");
	self endon("hash_9b74f71e");
	self notify("hash_22a08c51");
	self endon("hash_22a08c51");
	while(1)
	{
		if(!self laststand::player_is_in_laststand())
		{
			if(IS_TRUE(self.var_9e2dd97) && self.hero_power < 98)
			{
				self.hero_power = 98;
				self GadgetPowerSet(0, 98);
				self.hero_power = 98;
				self.dragon_gauntlet_power = 98;
			}
			self SetWeaponAmmoClip(weapon, weapon.clipSize);
		}
		wait(1);
	}
}

function function_c0093887()
{
	self endon("disconnect");
	self endon("dragon_gauntlet_expired");
	self endon("hash_89dc36f4");
	self notify("hash_309d2dbf");
	self endon("hash_309d2dbf");
	while(self AdsButtonPressed())
	{
		wait(0.05);
	}
	while(!IS_TRUE(self.var_cc844f4c))
	{
		time = GetTime();
		if(isdefined(self.var_4c8e9f40) && time < self.var_4c8e9f40)
		{
			wait(0.05);
			continue;
		}
		if(self GadgetPowerGet(0) <= 3)
		{
			wait(0.05);
			break;
		}
		if(self AdsButtonPressed() && self GetCurrentWeapon() === self.w_dragon_gauntlet_flamethrower && !IS_TRUE(self.var_a0a9409e) && (!isdefined(level.var_163a43e4) || !is_in_array(self, level.var_163a43e4)))
		{
			self DisableWeaponCycling();
			self function_f5802b55();
			self.dragon_gauntlet_power = self GadgetPowerGet(0);
			self SwitchToWeapon(self.w_dragon_gauntlet);
			while(self GetCurrentWeapon() !== self.w_dragon_gauntlet)
			{
				wait(0.05);
			}
			self EnableWeaponCycling();
			level notify("hash_fbd59317", self);
			self notify("hash_89dc36f4");
		}
		wait(0.05);
	}
}

function is_in_array(item, Array)
{
	if(isdefined(Array))
	{
		foreach(index in Array)
		{
			if(index == item)
			{
				return 1;
			}
		}
	}
	return 0;
}

function function_d7a4275d()
{
	self endon("disconnect");
	self endon("death");
	self endon("bled_out");
	self endon("dragon_gauntlet_expired");
	self endon("hash_3307435");
	while(self AdsButtonPressed())
	{
		if(IS_TRUE(self.var_a0a9409e) || (isdefined(level.var_163a43e4) && is_in_array(self, level.var_163a43e4)))
		{
			continue;
		}
		wait(0.05);
	}
	while(1)
	{
		time = GetTime();
		if(isdefined(self.var_d4b932e6) && time < self.var_d4b932e6)
		{
			wait(0.05);
			continue;
		}
		if(self GadgetPowerGet(0) <= 3)
		{
			wait(0.05);
			continue;
		}
		if(IS_TRUE(self.var_9d9ac25d))
		{
			wait(0.05);
			continue;
		}
		if(self AdsButtonPressed() && self GetCurrentWeapon() === self.w_dragon_gauntlet || IS_TRUE(self.var_a0a9409e) || (isdefined(level.var_163a43e4) && is_in_array(self, level.var_163a43e4)) || !isalive(self.var_4bd1ce6b))
		{
			self DisableWeaponCycling();
			self function_22d7caeb();
			self.dragon_gauntlet_power = self GadgetPowerGet(0);
			self SwitchToWeapon(self.w_dragon_gauntlet_flamethrower);
			while(self GetCurrentWeapon() !== self.w_dragon_gauntlet_flamethrower)
			{
				wait(0.05);
			}
			self EnableWeaponCycling();
			self notify("hash_3307435");
		}
		wait(0.05);
	}
}

function function_62d6a233()
{
	self endon("disconnect");
	self endon("death");
	self endon("bled_out");
	self endon("dragon_gauntlet_expired");
	self endon("dragon_gauntlet_unwield");
	self endon("hash_20599947");
	self endon("hash_3307435");
	self notify("hash_cf68b84e");
	self endon("hash_cf68b84e");
	while(1)
	{
		self util::waittill_any("weapon_melee", "weapon_melee_power");
		var_ebcc1e01 = self GetTagOrigin("tag_weapon_right");
		PhysicsExplosionCylinder(var_ebcc1e01, 96, 48, 1.5);
		self thread function_345e492a(var_ebcc1e01, 128);
		wait(0.05);
	}
}

function function_8e2014a0()
{
	self endon("disconnect");
	self endon("death");
	self endon("bled_out");
	self endon("dragon_gauntlet_expired");
	self endon("dragon_gauntlet_unwield");
	self endon("hash_20599947");
	self endon("hash_3307435");
	self notify("hash_e3575e9f");
	self endon("hash_e3575e9f");
	for(;;)
	{
		self waittill("weapon_melee_juke", weapon);
		if(weapon === self.w_dragon_gauntlet)
		{
			self playsound("zmb_rocketshield_start");
			self function_e7fe168a(weapon);
			self playsound("zmb_rocketshield_end");
			self notify("hash_206bebc2");
		}
	}
}

function function_e7fe168a(weapon)
{
	self endon("disconnect");
	self endon("death");
	self endon("bled_out");
	self endon("dragon_gauntlet_expired");
	self endon("dragon_gauntlet_unwield");
	self endon("hash_20599947");
	self endon("hash_3307435");
	self endon("weapon_melee");
	self endon("weapon_melee_power");
	self endon("weapon_melee_charge");
	self notify("hash_c0a47e94");
	self endon("hash_c0a47e94");
	start_time = GetTime();
	while(start_time + 1000 > GetTime())
	{
		self PlayRumbleOnEntity("zod_shield_juke");
		FORWARD = AnglesToForward(self getPlayerAngles());
		velocity = self GetVelocity();
		predicted_pos = self.origin + velocity * 0.1;
		self thread function_345e492a(predicted_pos, 96);
		wait(0.1);
	}
}

function function_345e492a(var_ebcc1e01, radius)
{
	player = self;
	a_enemies_in_range = Array::get_all_closest(var_ebcc1e01, GetAITeamArray(level.zombie_team), undefined, undefined, radius);
	if(!isdefined(a_enemies_in_range) || a_enemies_in_range.size <= 0)
	{
		return;
	}
	foreach(enemy in a_enemies_in_range)
	{
		if(!isdefined(enemy) || IS_TRUE(enemy.var_96906507))
		{
			continue;
		}
		range_sq = DistanceSquared(enemy.origin, var_ebcc1e01);
		radius_sq = radius * radius;
		enemy.var_96906507 = 1;
		if(range_sq > radius_sq)
		{
			continue;
		}
		[[ level.var_af9cd4ca ]]->WaitInQueue(enemy);
		if(isdefined(enemy) && isalive(enemy))
		{
			enemy DoDamage(enemy.health + 6000, var_ebcc1e01, player, undefined, undefined, "MOD_MELEE", 0, level.w_dragon_gauntlet);
			if(isVehicle(enemy))
			{
				continue;
			}
			if(enemy.health <= 0)
			{
				n_random_x = RandomFloatRange(-3, 3);
				n_random_y = RandomFloatRange(-3, 3);
				player thread zm_audio::create_and_play_dialog("whelp", "punch");
				enemy StartRagdoll(1);
				enemy LaunchRagdoll(100 * VectorNormalize(enemy.origin - self.origin + (n_random_x, n_random_y, 100)), "torso_lower");
			}
		}
	}
}

function dragon_gauntlet_power_override(e_player, ai_enemy)
{
	if(e_player laststand::player_is_in_laststand())
	{
		return;
	}
	if(ai_enemy.damageWeapon === level.w_dragon_gauntlet_flamethrower || ai_enemy.damageWeapon === level.w_dragon_gauntlet)
	{
		return;
	}
	if(IS_TRUE(e_player.var_cc844f4c))
	{
		return;
	}
	if(e_player.n_dragon_gauntlet_state === 0)
	{
		return;
	}
	if(isdefined(e_player.disable_hero_power_charging) && e_player.disable_hero_power_charging)
	{
		return;
	}
	e_player.dragon_gauntlet_power = e_player GadgetPowerGet(0);
	if(isdefined(e_player) && isdefined(e_player.dragon_gauntlet_power))
	{
		if(isdefined(ai_enemy.heroweapon_kill_power))
		{
			n_perk_factor = 1;
			if(e_player hasPerk("specialty_overcharge"))
			{
				n_perk_factor = GetDvarFloat("gadgetPowerOverchargePerkScoreFactor");
			}
			if(isdefined(ai_enemy.damageWeapon))
			{
				weapon = ai_enemy.damageWeapon;
				if(IsSubStr(weapon.name, "elemental_bow_demongate") || IsSubStr(weapon.name, "elemental_bow_run_prison") || IsSubStr(weapon.name, "elemental_bow_storm") || IsSubStr(weapon.name, "elemental_bow_wolf_howl"))
				{
					n_perk_factor = 0.25;
				}
			}
			e_player.dragon_gauntlet_power = e_player.dragon_gauntlet_power + n_perk_factor * ai_enemy.heroweapon_kill_power;
			e_player.dragon_gauntlet_power = math::clamp(e_player.dragon_gauntlet_power, 0, 100);
			if(e_player.dragon_gauntlet_power >= e_player.hero_power_prev)
			{
				e_player GadgetPowerSet(0, e_player.dragon_gauntlet_power);
				e_player clientfield::set_player_uimodel("zmhud.swordEnergy", e_player.dragon_gauntlet_power / 100);
				e_player clientfield::increment_uimodel("zmhud.swordChargeUpdate");
			}
		}
	}
}

function dragon_gauntlet_power_expired(weapon)
{
	self zm_hero_weapon::default_power_empty(weapon);
	self notify("stop_draining_hero_weapon");
	self notify("dragon_gauntlet_expired");
	self.dragon_gauntlet_power = 0;
	self.hero_power = 0;
	if(IS_TRUE(self.var_cc844f4c))
	{
		self function_22d7caeb();
	}
	current_weapon = self GetCurrentWeapon();
	if(self HasWeapon(weapon) && current_weapon === weapon)
	{
		self SetWeaponAmmoClip(weapon, 0);
	}
	if(current_weapon === self.w_dragon_gauntlet_flamethrower || current_weapon === self.w_dragon_gauntlet)
	{
		if(isdefined(self.var_a1ee595) && !IsSubStr(self.var_a1ee595.name, "minigun"))
		{
			self SwitchToWeapon(self.var_a1ee595);
		}
		else
		{
			self zm_weapons::switch_back_primary_weapon();
		}
	}
}

function dragon_gauntlet_power_full(weapon)
{
	self thread zm_equipment::show_hint_text(&"DLC3_WEAP_DRAGON_GAUNTLET_USE_HINT", 3);
	self zm_hero_weapon::set_hero_weapon_state(weapon, 2);
	self update_dragon_gauntlet_state(2);
	self SetWeaponAmmoClip(weapon, weapon.clipSize);
	if(!(isdefined(self.b_has_dragon_gauntlet) && self.b_has_dragon_gauntlet))
	{
		self thread zm_audio::create_and_play_dialog("whelp", "ready");
	}
	self.b_has_dragon_gauntlet = 0;
}

function function_f5802b55()
{
	if(IS_TRUE(self.var_cc844f4c) || isdefined(self.var_4bd1ce6b))
	{
		return;
	}
	self.var_cc844f4c = 1;
	spawn_pos = self GetTagOrigin("tag_dragon_world");
	spawn_angles = self GetTagAngles("tag_dragon_world");
	var_42c06d64 = SpawnVehicle(self.var_d15b9a33, spawn_pos, spawn_angles);
	if(isdefined(var_42c06d64))
	{
		self.var_4bd1ce6b = var_42c06d64;
		var_42c06d64 ai::set_ignoreme(1);
		var_42c06d64 SetIgnorePauseWorld(1);
		var_42c06d64.owner = self;
		self thread zm_audio::create_and_play_dialog("whelp", "command");
		var_42c06d64 thread function_44ecb9cb();
		var_42c06d64 thread function_b80d5548();
		self thread function_1692b405();
	}
	self.var_d4b932e6 = GetTime() + 1000;
}

function function_44ecb9cb()
{
	self endon("death");
	self ghost();
	wait(0.15);
	self show();
}

function function_1692b405()
{
	self notify("hash_22d7caeb");
	self endon("hash_22d7caeb");
	self waittill("entering_last_stand");
	self thread function_22d7caeb();
}

function function_22d7caeb()
{
	self notify("hash_22d7caeb");
	self.var_cc844f4c = 0;
	if(isdefined(self.var_4bd1ce6b))
	{
		var_42c06d64 = self.var_4bd1ce6b;
		var_42c06d64 notify("hash_22d7caeb");
		var_42c06d64.dragon_recall_death = 1;
		var_42c06d64.var_a0e2dfff = 1;
		var_42c06d64 kill();
	}
}

function function_b80d5548()
{
	while(isdefined(self))
	{
		if(!isdefined(self.owner) || self.owner laststand::player_is_in_laststand())
		{
			self.dragon_recall_death = 1;
			self.var_a0e2dfff = 1;
			self kill();
		}
		wait(0.25);
	}
}

function on_actor_damage_func_for_dragon_gauntlet(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime, boneIndex, surfaceType)
{
	if(isdefined(attacker) && isPlayer(attacker))
	{
		if(isdefined(weapon) && weapon === level.w_dragon_gauntlet_flamethrower)
		{
			if(meansOfDeath === "MOD_BURNED")
			{
				self.weapon_specific_fire_death_torso_fx = "dlc3/stalingrad/fx_fire_torso_zmb_green";
				self.weapon_specific_fire_death_sm_fx = "dlc3/stalingrad/fx_fire_generic_zmb_green";
				if(self.archetype === "zombie" || (isdefined(level.zombie_vars[attacker.team]) && (isdefined(level.zombie_vars[attacker.team]["zombie_insta_kill"]) && level.zombie_vars[attacker.team]["zombie_insta_kill"])))
				{
					damage = self.health + 6000;
					attacker thread zm_audio::create_and_play_dialog("whelp", "flamethrower_kill");
					return damage;
				}
			}
			if(meansOfDeath === "MOD_MELEE" && !IS_TRUE(self.var_96906507))
			{
				damage = self.health + 6000;
				self.deathFunction = &function_cb6fb97;
				return damage;
			}
		}
		if(isdefined(weapon) && weapon === level.w_dragon_gauntlet)
		{
			if(meansOfDeath === "MOD_MELEE" && (!IS_TRUE(self.var_96906507)))
			{
				damage = self.health + 6000;
				self.deathFunction = &function_d775fe77;
				return damage;
			}
		}
	}
	return -1;
}

function function_d775fe77(eInflictor, attacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime)
{
	n_random_x = RandomFloatRange(-3, 3);
	n_random_y = RandomFloatRange(-3, 3);
	self StartRagdoll(1);
	self LaunchRagdoll(100 * VectorNormalize(self.origin - attacker.origin + (n_random_x, n_random_y, 100)), "torso_lower");
}

function function_cb6fb97(eInflictor, attacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime)
{
	GibServerUtils::GibHead(self);
	n_random_x = RandomFloatRange(-3, 3);
	n_random_y = RandomFloatRange(-3, 3);
	self StartRagdoll(1);
	self LaunchRagdoll(100 * VectorNormalize(self.origin - attacker.origin + (n_random_x, n_random_y, 100)), "torso_lower");
}