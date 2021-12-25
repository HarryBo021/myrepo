#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\vehicles\_spider;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\weapons\grapple.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#using scripts\shared\ai\zombie_utility;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_spiders.gsh;

#precache( "fx", "dlc2/island/fx_spider_death_explo_sm" );
#precache( "fx", "dlc2/island/fx_web_bgb_reweb" );
#precache( "fx", "dlc2/island/fx_web_perk_machine_reweb" );
#precache( "fx", "dlc2/island/fx_spider_spit_projectile_reweb" );
#precache( "fx", "dlc2/island/fx_web_impact_player_melee" );
#precache( "fx", "dlc2/island/fx_web_impact_spider_crawl" );
	
#using_animtree( "generic" );
	
#namespace zm_ai_spiders;

REGISTER_SYSTEM_EX( "zm_ai_spiders", &__init__, &__main__, undefined )

function __init__()
{
	zm_audio::musicState_Create("spider_roundstart", 3, "island_spider_roundstart_1");
	zm_audio::musicState_Create("spider_roundend", 3, "island_spider_roundend_1");
	clientfield::register("world", "force_stream_spiders", 9001, 1, "int");
	level thread web_init();
	
	level.spider_melee_range = 200;
	level.n_spider_multi = 1;
	level flag::init("spider_round");
	init_effects();
	init();
	callback::on_spawned(&spider_watch_grenade_fire);
	callback::on_spawned(&spider_watch_grenade_launcher_fire);
	callback::on_spawned(&spider_watch_missile_fire);
	callback::on_spawned(&function_83a70ec3);
	callback::on_spawned(&function_d717ef02);
	callback::on_connect(&function_3a14f1bc);
}

function __main__()
{
	register_clientfields();
}

function register_clientfields()
{
	clientfield::register("toplayer", "spider_round_fx", 9000, 1, "counter");
	clientfield::register("toplayer", "spider_round_ring_fx", 9000, 1, "counter");
	clientfield::register("toplayer", "spider_end_of_round_reset", 9000, 1, "counter");
	clientfield::register("scriptmover", "set_fade_material", 9000, 1, "int");
	clientfield::register("scriptmover", "web_fade_material", 9000, 3, "float");
	clientfield::register("missile", "play_grenade_stuck_in_web_fx", 9000, 1, "int");
	clientfield::register("scriptmover", "play_spider_web_tear_fx", 9000, GetMinBitCountForNum(4), "int");
	clientfield::register("scriptmover", "play_spider_web_tear_complete_fx", 9000, GetMinBitCountForNum(4), "int");
}

function function_3a14f1bc()
{
	self.var_7f3c8431 = 0;
	self.var_f795ee17 = 0;
	self.var_86009342 = 0;
	self.var_3b4423fd = 0;
	self.var_ee8976c8 = 0;
	self.var_5c159c87 = 0;
}

function function_83a70ec3()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("bled_out");
		if(level flag::get("spider_round_in_progress"))
		{
			self waittill("spawned_player");
			level flag::wait_till_clear("spider_round_in_progress");
			util::wait_network_frame();
			self clientfield::increment_to_player("spider_end_of_round_reset", 1);
		}
	}
}

function init()
{
	level.spider_enabled = 1;
	level.spider_rounds_enabled = 0;
	level.spider_round_count = 1;
	// level.var_42034f6a = 30;
	level.spider_spawners = [];
	level flag::init("spider_clips");
	level flag::init("spider_round_in_progress");
	level.AAT["zm_aat_turned"].immune_trigger["spider"] = 1;
	level.AAT["zm_aat_thunder_wall"].immune_result_indirect["spider"] = 1;
	level.AAT["zm_aat_dead_wire"].immune_trigger["spider"] = 1;
	level.melee_range_sav = GetDvarString("ai_meleeRange");
	level.melee_width_sav = GetDvarString("ai_meleeWidth");
	level.melee_height_sav = GetDvarString("ai_meleeHeight");
	spider_spawner_init();
	level thread spider_clips_logic();
	scene::add_scene_func("scene_zm_dlc2_spider_web_engage", &function_1c624caf, "done");
	scene::add_scene_func("scene_zm_dlc2_spider_burrow_out_of_ground", &function_1c624caf, "done");
	visionset_mgr::register_info("visionset", "zm_isl_parasite_spider_visionset", 9000, 33, 16, 0, &visionset_mgr::ramp_in_out_thread, 0);
}

function function_1c624caf(a_ents)
{
	if(self.model === "tag_origin")
	{
		self zm_utility::self_delete();
	}
}

function init_effects()
{
	level._effect["spider_gib"] 										= "dlc2/island/fx_spider_death_explo_sm";
	level._effect["spider_web_bgb_reweb"] 					= "dlc2/island/fx_web_bgb_reweb";
	level._effect["spider_web_perk_machine_reweb"] 	= "dlc2/island/fx_web_perk_machine_reweb";
	level._effect["spider_web_doorbuy_reweb"] 			= "dlc2/island/fx_web_perk_machine_reweb";
	level._effect["spider_web_spit_reweb"] 					= "dlc2/island/fx_spider_spit_projectile_reweb";
	level._effect["spider_web_melee_hit"] 					= "dlc2/island/fx_web_impact_player_melee";
	level._effect["spider_web_spider_enter"] 				= "dlc2/island/fx_web_impact_spider_crawl";
	level._effect["spider_web_spider_leave"] 				= "dlc2/island/fx_web_impact_spider_crawl";
}

function spider_clips_logic()
{
	clips_on = 0;
	level.a_spider_clips = GetEntArray("spider_clips", "targetname");
	while(1)
	{
		for(i = 0; i < level.a_spider_clips.size; i++)
		{
			level.a_spider_clips[i] connectpaths();
		}
		level flag::wait_till("spider_clips");
		if(isdefined(level.spider_clips_disabled) && level.spider_clips_disabled == 1)
		{
			return;
		}
		for(i = 0; i < level.a_spider_clips.size; i++)
		{
			level.a_spider_clips[i] disconnectpaths();
			util::wait_network_frame();
		}
		b_spider_alive = 1;
		while(b_spider_alive || level flag::get("spider_round"))
		{
			b_spider_alive = 0;
			a_spiders = GetVehicleArray("zombie_spider", "targetname");
			for(i = 0; i < a_spiders.size; i++)
			{
				if(isalive(a_spiders[i]))
				{
					b_spider_alive = 1;
				}
			}
			wait(1);
		}
		level flag::clear("spider_clips");
		wait(1);
	}
}

function enable_spider_rounds()
{
	level.spider_rounds_enabled = 1;
	if(!isdefined(level.spider_round_track_override))
	{
		level.spider_round_track_override = &spider_round_tracker;
	}
	level thread [[level.spider_round_track_override]]();
}

function spider_spawner_init()
{
	level.spider_spawners = GetEntArray("zombie_spider_spawner", "script_noteworthy");
	later_spider = GetEntArray("later_round_spider_spawners", "script_noteworthy");
	level.spider_spawners = ArrayCombine(level.spider_spawners, later_spider, 1, 0);
	if(level.spider_spawners.size == 0)
	{
		return;
	}
	for(i = 0; i < level.spider_spawners.size; i++)
	{
		if(zm_spawner::is_spawner_targeted_by_blocker(level.spider_spawners[i]))
		{
			level.spider_spawners[i].is_enabled = 0;
			continue;
		}
		level.spider_spawners[i].is_enabled = 1;
		level.spider_spawners[i].script_forcespawn = 1;
	}
	/#
		Assert(level.spider_spawners.size > 0);
	#/
	Array::thread_all(level.spider_spawners, &spawner::add_spawn_function, &spider_init);
}

function spider_init()
{
	self.targetname = "zombie_spider";
	self.b_is_spider = 1;
	spider_set_max_health();
	self.maxhealth = level.n_spider_max_health;
	self.health = self.maxhealth;
	self.no_gib = 1;
	self.no_eye_glow = 1;
	self.custom_player_shellshock = &spider_custom_shellshock;
	self.team = level.zombie_team;
	self.missingLegs = 0;
	self.thundergun_knockdown_func = &spider_thundergun_knockdown;
	self.lightning_chain_immune = 1;
	self.heroweapon_kill_power = 1;
	self thread zombie_utility::round_spawn_failsafe();
	self thread spider_set_damage_weapon();
	self thread spider_death_event();
	self playsound("zmb_spider_spawn");
	self thread spider_play_ambient_voals();
}

function spider_set_damage_weapon()
{
	self endon("death");
	while(1)
	{
		self waittill("damage", n_amount, e_attacker, v_direction, v_hit_location, str_mod);
		if(isPlayer(e_attacker))
		{
			e_attacker.use_weapon_type = str_mod;
			self thread zm_powerups::check_for_instakill(e_attacker, str_mod, v_hit_location);
		}
	}
}

function spider_thundergun_knockdown(e_player, gib)
{
	self endon("death");
	n_damage = Int(self.maxhealth * 0.5);
	self DoDamage(n_damage, self.origin, e_player);
}

function function_a3f4adb()
{
}

function spider_play_ambient_voals()
{
	self endon("death");
	wait(RandomFloatRange(3, 6));
	while(1)
	{
		self PlaySoundOnTag("zmb_spider_vocals_ambient", "tag_eye");
		wait(RandomFloatRange(2, 6));
	}
}

function spider_death_event()
{
	self waittill("death", e_attacker);
	if(get_current_spider_count() == 0 && level.zombie_total == 0)
	{
		if(!isdefined(level.zm_ai_round_over) || [[level.zm_ai_round_over]]())
		{
			level.last_ai_origin = self.origin;
			level notify("last_ai_down", self);
		}
	}
	if(isPlayer(e_attacker))
	{
		if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
		{
			e_attacker zm_score::player_add_points("death_spider");
		}
		if(isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]](e_attacker, self);
		}
		e_attacker notify("spider_killed");
		e_attacker zm_stats::increment_client_stat("zspiders_killed");
		e_attacker zm_stats::increment_player_stat("zspiders_killed");
	}
	if(isdefined(e_attacker) && isai(e_attacker))
	{
		e_attacker notify("killed", self);
	}
	if(isdefined(self))
	{
		self StopLoopSound();
		self thread spider_play_gib_fx(self.origin);
	}
}

function spider_play_gib_fx(v_pos)
{
	self thread FX::Play("spider_gib", v_pos);
}

function spider_round_tracker()
{
	level.next_spider_round = level.round_number + randomIntRange(4, 7);
	
	// level.var_5ccd3661 = level.next_spider_round;
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while(1)
	{
		level waittill("between_round_over");
		/#
			if(GetDvarInt("force_spider") > 0)
			{
				level.next_spider_round = level.round_number;
			}
		#/
		if(level.round_number == level.next_spider_round)
		{
			level.sndMusicSpecialRound = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			spider_round_start();
			level.round_spawn_func = &spider_round_spawning;
			level.round_wait_func = &spider_round_wait_func;
			level.next_spider_round = level.round_number + randomIntRange(4, 6);
			/#
				GetPlayers()[0] iprintln("Next spider round: " + level.next_spider_round);
			#/
		}
		else if(level flag::get("spider_round"))
		{
			spider_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.n_spider_multi = level.n_spider_multi + 1;
		}
	}
}

function spider_round_fx()
{
	foreach(player in level.players)
	{
		player clientfield::increment_to_player("spider_round_fx");
		player clientfield::increment_to_player("spider_round_ring_fx");
	}
	visionset_mgr::activate("visionset", "zm_isl_parasite_spider_visionset", undefined, 1.5, &spider_wait_till_round_over, 2);
}

function spider_wait_till_round_over()
{
	level flag::wait_till_clear("spider_round_in_progress");
}

function spider_round_spawning()
{
	level endon("intermission");
	level endon("end_of_round");
	level endon("restart_round");
	for(i = 0; i < level.players.size; i++)
	{
		level.players[i].hunted_by = 0;
	}
	/*
	/#
		level endon("kill_round");
		if(GetDvarInt("Dev Block strings are not supported") == 2 || GetDvarInt("Dev Block strings are not supported") >= 4)
		{
			return;
		}
	#/
	*/
	if(level.intermission)
	{
		return;
	}
	level flag::set("spider_round_in_progress");
	level thread spider_round_aftermath();
	Array::thread_all(level.players, &spider_play_sound_start_sound);
	wait(1);
	level notify("hash_9c49b4a8"); // spider_round_start
	spider_round_fx();
	wait(4);
	spider_get_max = spider_get_max();
	/*
	/#
		if(GetDvarString("Dev Block strings are not supported") != "Dev Block strings are not supported")
		{
			spider_get_max = GetDvarInt("Dev Block strings are not supported");
		}
	#/
	*/
	level.zombie_total = spider_get_max;
	while(1)
	{
		while(level.zombie_total > 0)
		{
			if(isdefined(level.bzm_worldPaused) && level.bzm_worldPaused)
			{
				util::wait_network_frame();
				continue;
			}
			spawn_spider();
			util::wait_network_frame();
		}
		util::wait_network_frame();
	}
}

function spider_get_max()
{
	if(level.n_spider_multi < 3)
	{
		n_wave_count = level.players.size * 6;
	}
	else
	{
		n_wave_count = level.players.size * 8;
	}
	return n_wave_count;
}

function spawn_spider()
{
	while(!spider_should_spawn())
	{
		wait(0.1);
	}
	s_spawn_loc = undefined;
	e_favorite_enemy = get_favorite_enemy();
	if(!isdefined(e_favorite_enemy))
	{
		wait(RandomFloatRange(0.3333333, 0.6666667));
		return;
	}
	if(isdefined(level.ptr_custom_spider_get_spawn_point))
	{
		s_spawn_loc = [[level.ptr_custom_spider_get_spawn_point]](e_favorite_enemy);
	}
	else
	{
		s_spawn_loc = spider_get_spawn_point(e_favorite_enemy);
	}
	if(!isdefined(s_spawn_loc))
	{
		wait(RandomFloatRange(0.3333333, 0.6666667));
		return;
	}
	if(level flag::exists("spiders_from_mars_round") && level flag::get("spiders_from_mars_round") && isdefined(level.spider_mars_spawners))
	{
		ai = zombie_utility::spawn_zombie(level.spider_mars_spawners[0]);
	}
	else
	{
		ai = zombie_utility::spawn_zombie(level.spider_spawners[0]);
	}
	if(isdefined(ai))
	{
		s_spawn_loc thread spider_spawn_animation(ai, s_spawn_loc);
		level.zombie_total--;
		level thread zm_spawner::zombie_death_event(ai);
		if(isdefined(level.ptr_spider_custom_init))
		{
			ai thread [[level.ptr_spider_custom_init]]();
		}
		spider_spawn_delay();
	}
}

function spider_should_spawn()
{
	a_current_spider_amount = get_current_spider_count();
	b_spider_count_at_max = a_current_spider_amount >= 13;
	b_spider_count_per_player_at_max = a_current_spider_amount >= level.players.size * 4;
	if(b_spider_count_at_max || b_spider_count_per_player_at_max || !level flag::get("spawn_zombies"))
	{
		return 0;
	}
	return 1;
}

function get_current_spider_count()
{
	a_spiders = GetEntArray("zombie_spider", "targetname");
	a_current_spider_amount = a_spiders.size;
	foreach(ai_spider in a_spiders)
	{
		if(!isalive(ai_spider))
		{
			a_current_spider_amount--;
		}
	}
	return a_current_spider_amount;
}

function spider_round_wait_func()
{
	level endon("restart_round");
	/*
	/#
		level endon("kill_round");
	#/
	*/
	if(level flag::get("spider_round"))
	{
		level flag::wait_till("spider_round_in_progress");
		level flag::wait_till_clear("spider_round_in_progress");
	}
	level.sndMusicSpecialRound = 0;
}

function spider_round_start()
{
	level flag::set("spider_round");
	level flag::set("special_round");
	level clientfield::set("force_stream_spiders", 1);
	if(!isdefined(level.spiderround_nomusic))
	{
		level.spiderround_nomusic = 0;
	}
	level.spiderround_nomusic = 1;
	level notify("spider_round_starting");
	level thread zm_audio::sndMusicSystem_PlayState("spider_roundstart");
	if(isdefined(level.spider_melee_range))
	{
		SetDvar("ai_meleeRange", level.spider_melee_range);
	}
	else
	{
		SetDvar("ai_meleeRange", 100);
	}
}

function spider_round_stop()
{
	level flag::clear("spider_round");
	level flag::clear("special_round");
	level clientfield::set("force_stream_spiders", 0);
	if(!isdefined(level.spiderround_nomusic))
	{
		level.spiderround_nomusic = 0;
	}
	level.spiderround_nomusic = 0;
	level notify("spider_round_ending");
	SetDvar("ai_meleeRange", level.melee_range_sav);
	SetDvar("ai_meleeWidth", level.melee_width_sav);
	SetDvar("ai_meleeHeight", level.melee_height_sav);
}

function spider_spawn_delay()
{
	switch(level.players.size)
	{
		case 1:
		{
			n_default_wait = 2.25;
			break;
		}
		case 2:
		{
			n_default_wait = 2;
			break;
		}
		case 3:
		{
			n_default_wait = 1.75;
			break;
		}
		default:
		{
			n_default_wait = 1.5;
			break;
		}
	}
	wait(n_default_wait);
}

function spider_set_max_health()
{
	if(isdefined(level.n_spider_max_health_override))
	{
		level.n_spider_max_health = level.n_spider_max_health_override;
	}
	else
	{
		switch(level.n_spider_multi)
		{
			case 1:
			{
				level.n_spider_max_health = 400;
				break;
			}
			case 2:
			{
				level.n_spider_max_health = 900;
				break;
			}
			case 3:
			{
				level.n_spider_max_health = 1300;
				break;
			}
			default:
			{
				level.n_spider_max_health = 1600;
				break;
			}
		}
		level.n_spider_max_health = Int(level.n_spider_max_health * 0.5);
		if(level flag::exists("spiders_from_mars_round") && level flag::get("spiders_from_mars_round"))
		{
			level.n_spider_max_health = level.n_spider_max_health * 2;
		}
	}
}

function spider_get_spawn_point(e_favorite_enemy)
{
	switch(level.players.size)
	{
		case 1:
		{
			spawn_dist_min = 2500;
			spawn_dist_max = 490000;
			break;
		}
		case 2:
		{
			spawn_dist_min = 2500;
			spawn_dist_max = 810000;
			break;
		}
		case 3:
		{
			spawn_dist_min = 2500;
			spawn_dist_max = 1000000;
			break;
		}
		case 4:
		{
			spawn_dist_min = 2500;
			spawn_dist_max = 1000000;
			break;
		}
		default:
		{
			spawn_dist_min = 2500;
			spawn_dist_max = 490000;
			break;
		}
	}
	if(isdefined(level.zm_loc_types["spider_location"]))
	{
		a_spider_spawn_locations = Array::randomize(level.zm_loc_types["spider_location"]);
	}
	else
	{
		ASSERTMSG("Dev Block strings are not supported");
		return;
	}
	/#
	#/
	for(i = 0; i < a_spider_spawn_locations.size; i++)
	{
		if(isdefined(level.old_spider_spawn) && level.old_spider_spawn == a_spider_spawn_locations[i])
		{
			continue;
		}
		n_dist_squared = DistanceSquared(a_spider_spawn_locations[i].origin, e_favorite_enemy.origin);
		n_height_diff = Abs(a_spider_spawn_locations[i].origin[2] - e_favorite_enemy.origin[2]);
		if(n_dist_squared > spawn_dist_min && n_dist_squared < spawn_dist_max && n_height_diff < 128)
		{
			s_spawn_loc = spider_spawn_adjust(a_spider_spawn_locations[i]);
			level.old_spider_spawn = s_spawn_loc;
			return s_spawn_loc;
		}
	}
	s_spawn_loc = spider_spawn_adjust(ArrayGetClosest(e_favorite_enemy.origin, a_spider_spawn_locations));
	level.old_spider_spawn = s_spawn_loc;
	return s_spawn_loc;
}

function spider_spawn_adjust(s_spawn_loc)
{
	/*
	/#
		Assert(isdefined(s_spawn_loc), "Dev Block strings are not supported");
	#/
	*/
	s_new_spawn_loc = s_spawn_loc;
	s_new_spawn_loc.origin = s_spawn_loc.origin + VectorScale((0, 0, 1), 16);
	return s_new_spawn_loc;
}

function spider_play_sound_start_sound()
{
	self playlocalsound("zmb_raps_round_start");
}

function spider_round_aftermath()
{
	level waittill("last_ai_down", e_enemy_ai);
	level thread zm_audio::sndMusicSystem_PlayState("spider_roundend");
	if(isdefined(level.zm_override_ai_aftermath_powerup_drop))
	{
		[[level.zm_override_ai_aftermath_powerup_drop]](e_enemy_ai, level.last_ai_origin);
	}
	else
	{
		v_origin = level.last_ai_origin;
		if(!IsPointOnNavMesh(v_origin, e_enemy_ai))
		{
			v_origin = GetClosestPointOnNavMesh(v_origin, 100);
			if(!isdefined(v_origin))
			{
				e_player = zm_utility::get_closest_player(level.last_ai_origin);
				v_origin = e_player.origin;
			}
		}
		trace = GroundTrace(v_origin + VectorScale((0, 0, 1), 15), v_origin + VectorScale((0, 0, -1), 1000), 0, undefined);
		v_origin = trace["position"];
		if(isdefined(v_origin))
		{
			level thread zm_powerups::specific_powerup_drop("full_ammo", v_origin);
		}
	}
	wait(2);
	level.sndMusicSpecialRound = 0;
	if(isdefined(level.spider_custom_round_end))
	{
		[[level.spider_custom_round_end]]();
		break;
	}
	wait(6);
	level flag::clear("spider_round_in_progress");
	foreach(player in level.players)
	{
		player clientfield::increment_to_player("spider_end_of_round_reset", 1);
	}
}

function get_favorite_enemy()
{
	a_players = level.players;
	e_least_hunted = a_players[0];
	for(i = 0; i < a_players.size; i++)
	{
		if(!isdefined(a_players[i].hunted_by))
		{
			a_players[i].hunted_by = 0;
		}
		if(!zm_utility::is_player_valid(a_players[i]))
		{
			continue;
		}
		if(!zm_utility::is_player_valid(e_least_hunted))
		{
			e_least_hunted = a_players[i];
		}
		if(a_players[i].hunted_by < e_least_hunted.hunted_by)
		{
			e_least_hunted = a_players[i];
		}
	}
	e_least_hunted.hunted_by = e_least_hunted.hunted_by + 1;
	return e_least_hunted;
}

function special_spider_spawn(n_to_spawn, s_spawn_point)
{
	a_spiders = GetVehicleArray("zombie_spider", "targetname");
	if(isdefined(a_spiders) && a_spiders.size >= 9)
	{
		return 0;
	}
	if(!isdefined(n_to_spawn))
	{
		n_to_spawn = 1;
	}
	n_count = 0;
	while(n_count < n_to_spawn)
	{
		e_favorite_enemy = get_favorite_enemy();
		if(isdefined(level.spider_spawn_func))
		{
			if(!isdefined(s_spawn_point))
			{
				s_spawn_point = [[level.spider_spawn_func]](level.spider_spawners, e_favorite_enemy);
			}
			ai = zombie_utility::spawn_zombie(level.spider_spawners[0]);
			if(isdefined(ai))
			{
				s_spawn_point thread spider_spawn_animation(ai, s_spawn_point);
				level.zombie_total--;
				n_count++;
				level flag::set("spider_clips");
			}
		}
		else if(!isdefined(s_spawn_point))
		{
			s_spawn_point = spider_get_spawn_point(e_favorite_enemy);
		}
		ai = zombie_utility::spawn_zombie(level.spider_spawners[0]);
		if(isdefined(ai))
		{
			s_spawn_point thread spider_spawn_animation(ai, s_spawn_point);
			level.zombie_total--;
			n_count++;
			level flag::set("spider_clips");
		}
		spider_spawn_delay();
	}
	if(isdefined(ai))
	{
		return ai;
	}
	else
	{
		return undefined;
	}
}

function spider_spawn_animation(ai_spider, ent, s_scriptbundle)
{
	if(!isdefined(s_scriptbundle))
	{
		s_scriptbundle = 0;
	}
	if(!isdefined(ent))
	{
		ent = self;
	}
	ai_spider endon("death");
	ai_spider ai::set_ignoreall(1);
	if(!isdefined(ent.target) || s_scriptbundle)
	{
		ai_spider ghost();
		ai_spider util::delay(0.2, "death", &show);
		ai_spider util::delay_notify(0.2, "visible", "death");
		ai_spider.origin = ent.origin;
		ai_spider.angles = ent.angles;
		ai_spider vehicle_ai::set_state("scripted");
		if(isalive(ai_spider))
		{
			a_ground_trace = GroundTrace(ai_spider.origin + VectorScale((0, 0, 1), 100), ai_spider.origin - VectorScale((0, 0, 1), 1000), 0, ai_spider, 1);
			if(isdefined(a_ground_trace["position"]))
			{
				e_model = util::spawn_model("tag_origin", a_ground_trace["position"], ai_spider.angles);
			}
			else
			{
				e_model = util::spawn_model("tag_origin", ai_spider.origin, ai_spider.angles);
			}
			e_model scene::Play("scene_zm_dlc2_spider_burrow_out_of_ground", ai_spider);
			State = "combat";
			if(RandomFloat(1) > 0.6)
			{
				State = "meleeCombat";
			}
			ai_spider vehicle_ai::set_state(State);
			ai_spider SetVisibleToAll();
			ai_spider ai::set_ignoreme(0);
		}
	}
	else
	{
		ai_spider.disableArrivals = 1;
		ai_spider.disableExits = 1;
		ai_spider vehicle_ai::set_state("scripted");
		ai_spider notify("visible");
		a_scriptbundles = struct::get_array(ent.target, "targetname");
		s_scriptbundle = Array::random(a_scriptbundles);
		if(isdefined(s_scriptbundle) && isalive(ai_spider))
		{
			s_scriptbundle.script_play_multiple = 1;
			level scene::Play(ent.target, ai_spider);
		}
		else
		{
			a_vehicle_nodes = getvehiclenodearray(ent.target, "targetname");
			s_vehicle_node = Array::random(a_vehicle_nodes);
			ai_spider ghost();
			ai_spider.e_vehicle_linker = spawner::simple_spawn_single("spider_mover_spawner");
			ai_spider.origin = ai_spider.e_vehicle_linker.origin;
			ai_spider.angles = ai_spider.e_vehicle_linker.angles;
			ai_spider LinkTo(ai_spider.e_vehicle_linker);
			s_end = struct::get(s_vehicle_node.target, "targetname");
			ai_spider.e_vehicle_linker vehicle::get_on_path(s_vehicle_node);
			ai_spider show();
			if(isdefined(s_vehicle_node.script_int))
			{
				ai_spider.e_vehicle_linker SetSpeed(s_vehicle_node.script_int);
			}
			else
			{
				ai_spider.e_vehicle_linker SetSpeed(20);
			}
			ai_spider.e_vehicle_linker vehicle::go_path();
			ai_spider notify("hash_a81735f9");
			ai_spider Unlink();
			ai_spider.e_vehicle_linker delete();
		}
		Earthquake(0.1, 0.5, ai_spider.origin, 256);
		State = "combat";
		if(RandomFloat(1) > 0.6)
		{
			State = "meleeCombat";
		}
		ai_spider vehicle_ai::set_state(State);
		ai_spider.completed_emerging_into_playable_area = 1;
	}
	ai_spider ai::set_ignoreall(0);
}

function spider_custom_shellshock(damage, attacker, direction_vec, point, mod)
{
	if(mod == "MOD_EXPLOSIVE")
	{
		self thread spider_shellshock();
	}
}

function spider_shellshock()
{
	self endon("death");
	if(!isdefined(self.n_shellshock_count))
	{
		self.n_shellshock_count = 0;
	}
	self.n_shellshock_count++;
	if(self.n_shellshock_count >= 4)
	{
		self shellshock("pain", 1);
	}
	self util::waittill_any_timeout(10, "death");
	self.n_shellshock_count--;
}

function web_init()
{
	/*
	a_spider_web_visuals = GetEntArray("spider_web_visual", "script_string");
	Array::run_all(a_spider_web_visuals, &notsolid);
	Array::run_all(a_spider_web_visuals, &Hide);
	level.a_spider_web_triggers = [];
	level.revive_trigger_should_ignore_sight_checks = &function_7495ed75;
	a_bgb_web_triggers = GetEntArray("bgb_web_trigger", "targetname");
	foreach(trigger in a_bgb_web_triggers)
	{
		trigger thread setup_bgb_web();
		if(!isdefined(level.a_spider_web_triggers))
		{
			level.a_spider_web_triggers = [];
		}
		else if(!IsArray(level.a_spider_web_triggers))
		{
			level.a_spider_web_triggers = Array(level.a_spider_web_triggers);
		}
		level.a_spider_web_triggers[level.a_spider_web_triggers.size] = trigger;
	}
	a_zombie_doors = GetEntArray("zombie_door", "targetname");
	foreach(trigger in a_zombie_doors)
	{
		a_zombie_door_triggers = GetEntArray(trigger.target, "targetname");
		a_spider_web_door_triggers = [];
		foreach(e_piece in a_zombie_door_triggers)
		{
			if(e_piece.script_string === "spider_web_trigger")
			{
				if(!isdefined(a_spider_web_door_triggers))
				{
					a_spider_web_door_triggers = [];
				}
				else if(!IsArray(a_spider_web_door_triggers))
				{
					a_spider_web_door_triggers = Array(a_spider_web_door_triggers);
				}
				a_spider_web_door_triggers[a_spider_web_door_triggers.size] = e_piece;
			}
		}
		foreach(e_spider_web_door_trigger in a_spider_web_door_triggers)
		{
			e_spider_web_door_trigger.e_door_trigger = trigger;
			e_spider_web_door_trigger.script_flag = trigger.script_flag;
			e_spider_web_door_trigger set_up_web_visual();
			if(!(isdefined(e_spider_web_door_trigger.b_active) && e_spider_web_door_trigger.b_active))
			{
				e_spider_web_door_trigger.b_active = 1;
				if(!isdefined(level.a_spider_web_triggers))
				{
					level.a_spider_web_triggers = [];
				}
				else if(!IsArray(level.a_spider_web_triggers))
				{
					level.a_spider_web_triggers = Array(level.a_spider_web_triggers);
				}
				level.a_spider_web_triggers[level.a_spider_web_triggers.size] = e_spider_web_door_trigger;
				e_spider_web_door_trigger thread function_a96551fe();
			}
		}
	}
	*/
}

function set_up_web_visual()
{
	/*
	a_target_ents = GetEntArray(self.target, "targetname");
	self.s_web_struct = struct::get(self.target, "targetname");
	foreach(e_entity in a_target_ents)
	{
		if(e_entity.script_string === "spider_web_visual")
		{
			self.e_destructible = e_entity;
			self.e_web = e_entity;
			self.e_web clientfield::set("web_fade_material", 0);
		}
	}
	*/
}

function setup_web_trigger()
{
	/*
	s_unitrigger = spawnstruct();
	s_unitrigger.origin = self.origin;
	if(self.targetname == "bgb_web_trigger" || self.targetname == "doorbuy_web_trigger")
	{
		var_81aba619 = struct::get_array(self.target, "targetname");
		if(isdefined(var_81aba619[0]))
		{
			s_unitrigger.angles = var_81aba619[0].angles;
		}
		else
		{
			s_unitrigger.angles = self.angles;
		}
	}
	else
	{
		s_unitrigger.angles = self.angles;
	}
	s_unitrigger.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger.cursor_hint = "HINT_NOICON";
	s_unitrigger.require_look_at = 0;
	s_unitrigger.var_a6a648f0 = self;
	if(isdefined(self.script_width))
	{
		s_unitrigger.script_width = self.script_width;
	}
	else
	{
		s_unitrigger.script_width = 128;
	}
	if(isdefined(self.script_length))
	{
		s_unitrigger.script_length = self.script_length;
	}
	else
	{
		s_unitrigger.script_length = 130;
	}
	if(isdefined(self.script_height))
	{
		s_unitrigger.script_height = self.script_height;
	}
	else
	{
		s_unitrigger.script_height = 100;
	}
	if(isdefined(self.script_vector))
	{
		s_unitrigger.script_length = self.script_vector[0];
		s_unitrigger.script_width = self.script_vector[1];
		s_unitrigger.script_height = self.script_vector[2];
	}
	s_unitrigger.prompt_and_visibility_func = &function_e433eb78;
	zm_unitrigger::register_static_unitrigger(s_unitrigger, &function_c915f7a9);
	self.s_unitrigger = s_unitrigger;
	*/
}

function setup_bgb_web()
{
	/*
	self endon("death");
	self set_up_web_visual();
	self.web_bgb_zbarrier = undefined;
	foreach(web_bgb_zbarrier in level.bgb_machines)
	{
		if(web_bgb_zbarrier istouching(self))
		{
			self.web_bgb_zbarrier = web_bgb_zbarrier;
			self.e_web.origin = self.web_bgb_zbarrier.origin;
			self.e_web.angles = self.web_bgb_zbarrier.angles;
		}
	}
	while(1)
	{
		if(function_f67965ad(self.origin))
		{
			self spider_web_state(1);
			if(isdefined(self.web_bgb_zbarrier))
			{
				self notify("hash_16b3008");
				self thread activate_bgb_web();
			}
			self waittill("hash_bbf62f57");
			self spider_web_state(0);
		}
		level waittill("hash_9c49b4a8");
	}
	*/
}

function activate_bgb_web()
{
	/*
	self endon("death");
	self endon("hash_16b3008");
	self.web_bgb_zbarrier thread FX::Play("spider_web_bgb_reweb", self.web_bgb_zbarrier.origin, self.web_bgb_zbarrier.angles);
	if(self.web_bgb_zbarrier bgb_machine::function_8ae729a7() === "initial" || self.web_bgb_zbarrier bgb_machine::function_b56ef180())
	{
		self.web_bgb_zbarrier thread zm_unitrigger::unregister_unitrigger(self.web_bgb_zbarrier.unitrigger_stub);
		self waittill("hash_bbf62f57");
		self.web_bgb_zbarrier thread zm_unitrigger::register_static_unitrigger(self.web_bgb_zbarrier.unitrigger_stub, &bgb_machine::function_ededc488);
	}
	while(1)
	{
		self.web_bgb_zbarrier waittill("zbarrier_state_change");
		if(isdefined(self.b_web_active) && self.b_web_active)
		{
			if(self.web_bgb_zbarrier bgb_machine::function_8ae729a7() === "initial" || self.web_bgb_zbarrier bgb_machine::function_b56ef180())
			{
				self.web_bgb_zbarrier thread zm_unitrigger::unregister_unitrigger(self.web_bgb_zbarrier.unitrigger_stub);
				self waittill("hash_bbf62f57");
				self.web_bgb_zbarrier thread zm_unitrigger::register_static_unitrigger(self.web_bgb_zbarrier.unitrigger_stub, &bgb_machine::function_ededc488);
			}
		}
	}
	*/
}

function function_a96551fe()
{
	/*
	self endon("death");
	while(!(isdefined(self.var_b8a7fb78._door_open) && self.var_b8a7fb78._door_open))
	{
		wait(0.5);
	}
	while(1)
	{
		self trigger::wait_till();
		if(isdefined(self.who.b_is_spider) && self.who.b_is_spider || (isdefined(level.var_f618f3e1) && level.var_f618f3e1))
		{
			var_59bd3c5a = self.who;
			var_94aebe65 = RandomInt(100);
			if(var_94aebe65 < level.var_42034f6a)
			{
				self.var_cb6fa5c5 = 0;
				self thread function_e96bd0d2();
				if(isalive(var_59bd3c5a) && (isdefined(var_59bd3c5a.b_is_spider) && var_59bd3c5a.b_is_spider))
				{
					var_59bd3c5a function_d8cfc139(self);
				}
				self function_c83dc712();
				level util::waittill_any_ents(level, "end_of_round", level, "between_round_over", level, "start_of_round", self, "death", level, "enable_all_webs");
			}
			else
			{
				wait(3);
			}
		}
	}
	*/
}

function function_d8cfc139(e_dest)
{
	/*
	self endon("death");
	var_366514d8 = util::spawn_model("tag_origin", self.origin, self.angles);
	var_366514d8 thread scene::Play("scene_zm_dlc2_spider_web_engage", self);
	self waittill("web");
	self function_f2724f43(e_dest);
	*/
}

function function_f2724f43(e_dest)
{
	/*
	v_origin = self GetTagOrigin("head_1");
	v_angles = self GetTagAngles("head_1");
	var_e9ad0294 = util::spawn_model("tag_origin", v_origin, v_angles);
	var_e9ad0294 thread FX::Play("spider_web_spit_reweb", v_origin, v_angles, "movedone", 1);
	var_e9ad0294 moveto(e_dest.origin, 0.5);
	var_e9ad0294 waittill("movedone");
	var_e9ad0294 delete();
	*/
}

function spider_web_state(b_on, var_32ee3d8b)
{
	/*
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	if(!isdefined(var_32ee3d8b))
	{
		var_32ee3d8b = 0.5;
	}
	if(b_on)
	{
		if(isdefined(self.s_web_struct))
		{
			self.e_web thread FX::Play("spider_web_doorbuy_reweb", self.s_web_struct.origin, self.s_web_struct.angles);
		}
		self setup_web_trigger();
		self.e_web show();
		self.e_web solid();
		self.e_web clientfield::set("web_fade_material", var_32ee3d8b);
		self.b_web_active = 1;
		self thread function_1a393131();
	}
	else
	{
		self.b_web_active = 0;
		self.var_cb6fa5c5 = 0;
		self.e_web clientfield::set("web_fade_material", 0);
		self.e_web notsolid();
		self.e_web Hide();
		zm_unitrigger::unregister_unitrigger(self.s_unitrigger);
	}
	*/
}

function function_c83dc712()
{
	/*
	self endon("death");
	if(isdefined(self.script_noteworthy))
	{
		var_6adf046 = [];
		var_6adf046 = StrTok(self.script_noteworthy, " ");
	}
	else
	{
		return;
	}
	self spider_web_state(1);
	var_9df462ad = [];
	foreach(str_zone in var_6adf046)
	{
		e_zone = level.zones[str_zone];
		/#
			Assert(isdefined(e_zone), "Dev Block strings are not supported" + str_zone + "Dev Block strings are not supported");
		#/
		if(!function_7be01d65(str_zone))
		{
			e_zone.is_spawning_allowed = 0;
			e_zone thread function_cb33362d();
			if(!isdefined(var_9df462ad))
			{
				var_9df462ad = [];
			}
			else if(!IsArray(var_9df462ad))
			{
				var_9df462ad = Array(var_9df462ad);
			}
			var_9df462ad[var_9df462ad.size] = e_zone;
			var_d1cba433 = zombie_utility::get_zombie_array();
			foreach(ai_zombie in var_d1cba433)
			{
				if(ai_zombie zm_zonemgr::entity_in_zone(str_zone))
				{
					ai_zombie.var_b1b7c1b7 = 1;
				}
			}
		}
	}
	self waittill("hash_bbf62f57");
	foreach(e_zone in var_9df462ad)
	{
		e_zone.is_spawning_allowed = 1;
		e_zone notify("hash_bbf62f57");
	}
	self spider_web_state(0);
	*/
}

function function_7be01d65(str_zone)
{
	/*
	e_zone = level.zones[str_zone];
	for(i = 0; i < e_zone.Volumes.size; i++)
	{
		foreach(player in level.players)
		{
			if(zm_utility::is_player_valid(player, 0, 0) && player istouching(e_zone.Volumes[i]))
			{
				return 1;
			}
		}
	}
	return 0;
	*/
}

function function_cb33362d()
{
	/*
	self endon("hash_bbf62f57");
	str_zone = self.Volumes[0].targetname;
	while(!(isdefined(function_7be01d65(str_zone)) && function_7be01d65(str_zone)))
	{
		wait(1);
	}
	self.is_spawning_allowed = 1;
	*/
}

function function_e96bd0d2()
{
	/*
	self endon("hash_bbf62f57");
	self thread function_e85225c8();
	while(1)
	{
		self waittill("trigger", e_who);
		if(!isdefined(e_who.b_is_spider) && e_who.b_is_spider && (!isdefined(e_who.var_93100ec2) && e_who.var_93100ec2) && isai(e_who))
		{
			self.var_cb6fa5c5++;
		}
		else if(isdefined(e_who.b_is_spider) && e_who.b_is_spider && (!isdefined(e_who.var_a56241ac) && e_who.var_a56241ac))
		{
			e_who thread function_9b4a5d94(self);
		}
	}
	*/
}

function function_e85225c8()
{
	/*
	self endon("hash_bbf62f57");
	e_spider_web_door_trigger = spawn("trigger_radius", self.origin, 1, 50, 50);
	e_spider_web_door_trigger endon("death");
	self thread function_d1835ae4(e_spider_web_door_trigger);
	self.var_82b5ff7a = 0;
	while(1)
	{
		e_spider_web_door_trigger waittill("trigger", e_who);
		if(e_who.archetype === "thrasher")
		{
			self thread function_6b1cc9fb(1);
			self notify("hash_bbf62f57");
		}
		else if(e_who.archetype === "zombie" && (!isdefined(e_who.var_93100ec2) && e_who.var_93100ec2))
		{
			e_who thread function_82900a05(self);
			if(!self.var_82b5ff7a)
			{
				self thread function_d672fbd9(e_spider_web_door_trigger);
				self thread function_6c15e157(4, 0.125);
			}
		}
	}
	*/
}

function function_d672fbd9(e_spider_web_door_trigger)
{
	/*
	self endon("hash_bbf62f57");
	wait(60);
	foreach(ai_zombie in GetAITeamArray(level.zombie_team))
	{
		if(ai_zombie istouching(e_spider_web_door_trigger))
		{
			self.var_82b5ff7a = 0;
			self thread function_6b1cc9fb(1);
			self notify("hash_bbf62f57");
		}
	}
	self.var_82b5ff7a = 0;
	*/
}

function function_82900a05(e_spider_web_door_trigger)
{
	/*
	self endon("death");
	self.var_93100ec2 = 1;
	if(e_spider_web_door_trigger.var_cb6fa5c5 > 5)
	{
		self.var_b1b7c1b7 = 1;
	}
	else
	{
		self thread function_e0f04a8a();
	}
	self ASMSetAnimationRate(0.1);
	self ai::set_ignoreall(1);
	e_spider_web_door_trigger waittill("hash_bbf62f57");
	self ASMSetAnimationRate(1);
	self ai::set_ignoreall(0);
	self notify("hash_af52d2f8");
	self.var_93100ec2 = 0;
	self.var_b1b7c1b7 = 0;
	*/
}

function function_d1835ae4(e_spider_web_door_trigger)
{
	/*
	self waittill("hash_bbf62f57");
	if(isdefined(e_spider_web_door_trigger))
	{
		e_spider_web_door_trigger delete();
	}
	*/
}

function function_9b4a5d94(e_spider_web_door_trigger)
{
	/*
	self endon("death");
	e_spider_web_door_trigger endon("death");
	self.var_a56241ac = 1;
	self FX::Play("spider_web_spider_enter", self.origin, self.angles, "stop_spider_web_enter", 0, "tag_body");
	e_spider_web_door_trigger thread function_6c15e157(1);
	while(1)
	{
		wait(0.05);
		if(self istouching(e_spider_web_door_trigger) && (isdefined(e_spider_web_door_trigger.b_web_active) && e_spider_web_door_trigger.b_web_active))
		{
			continue;
		}
		else
		{
			self.var_a56241ac = 0;
			self notify("hash_ef3d1943");
			self FX::Play("spider_web_spider_leave", self.origin, self.angles, 2, 0, "tag_body");
			break;
		}
	}
	*/
}

function function_6c15e157(var_f0566a69, var_d1bb0869)
{
	/*
	if(!isdefined(var_f0566a69))
	{
		var_f0566a69 = 4;
	}
	if(!isdefined(var_d1bb0869))
	{
		var_d1bb0869 = 0.25;
	}
	self endon("death");
	if(!isdefined(self.e_web))
	{
		return;
	}
	if(!(isdefined(self.var_c8acfaf8) && self.var_c8acfaf8))
	{
		self.var_c8acfaf8 = 1;
		var_12295a2 = self.e_web.origin;
		for(i = 0; i < var_f0566a69; i++)
		{
			var_45634a22 = (RandomFloatRange(0, 2), RandomFloatRange(0, 2), 0);
			self.e_web moveto(var_12295a2 + var_45634a22, var_d1bb0869);
			self.e_web waittill("movedone");
			self.e_web moveto(var_12295a2, var_d1bb0869);
			self.e_web waittill("movedone");
		}
		self.var_c8acfaf8 = 0;
	}
	*/
}

function function_17a41767(var_a6a648f0)
{
	/*
	self endon("death");
	self.var_93100ec2 = 1;
	if(isdefined(self.var_61f7b3a0) && self.var_61f7b3a0)
	{
		var_ab201dd8 = util::spawn_model("tag_origin", self.origin, self.angles);
		var_ab201dd8 thread scene::Play("scene_zm_dlc2_thrasher_attack_swing_swipe", self);
		self waittill("hash_507023cf");
		var_a6a648f0 thread function_6b1cc9fb(1);
		var_a6a648f0 notify("hash_bbf62f57");
		self.var_93100ec2 = 0;
		return;
	}
	if(var_a6a648f0.var_cb6fa5c5 > 2)
	{
		self.var_b1b7c1b7 = 1;
	}
	else
	{
		self thread function_e0f04a8a();
	}
	self ASMSetAnimationRate(0.1);
	self ai::set_ignoreall(1);
	self clientfield::set("widows_wine_wrapping", 1);
	self thread function_81936417();
	var_a6a648f0 thread function_6c15e157(4, 0.125);
	var_a6a648f0 waittill("hash_bbf62f57");
	self ASMSetAnimationRate(1);
	self ai::set_ignoreall(0);
	self clientfield::set("widows_wine_wrapping", 0);
	self notify("hash_af52d2f8");
	self.var_93100ec2 = 0;
	self.var_b1b7c1b7 = 0;
	*/
}

function function_81936417()
{
	/*
	self waittill("death");
	if(isdefined(self))
	{
		if(self clientfield::get("widows_wine_wrapping"))
		{
			self clientfield::set("widows_wine_wrapping", 0);
		}
	}
	*/
}

function function_e0f04a8a(var_4639e1cf)
{
	/*
	if(!isdefined(var_4639e1cf))
	{
		var_4639e1cf = 5;
	}
	self endon("death");
	self endon("hash_af52d2f8");
	self.var_b1b7c1b7 = 0;
	wait(var_4639e1cf);
	self.var_b1b7c1b7 = 1;
	*/
}

function function_e433eb78(player)
{
	/*
	if(!player zm_utility::is_player_looking_at(self.origin, 0.4, 0) || !player zm_magicbox::can_buy_weapon())
	{
		self setHintString("");
		return 0;
	}
	self setHintString(&"ZM_ISLAND_TEAR_WEB");
	return 1;
	*/
}

function function_7495ed75()
{
	/*
	if(!isdefined(level.var_d3b40681))
	{
		return 0;
	}
	var_a15343e5 = 0;
	foreach(e_spider_web_door_trigger in level.var_d3b40681)
	{
		if(!(isdefined(e_spider_web_door_trigger.b_web_active) && e_spider_web_door_trigger.b_web_active))
		{
			continue;
		}
		foreach(player in level.players)
		{
			if(player == self)
			{
				continue;
			}
			if(isdefined(player.reviveTrigger) && self istouching(player.reviveTrigger) && self util::is_player_looking_at(player.reviveTrigger.origin, 0.6, 0) && Distance2DSquared(self.origin, e_spider_web_door_trigger.origin) < 14400)
			{
				var_a15343e5 = 1;
				break;
			}
		}
		if(var_a15343e5)
		{
			break;
		}
	}
	return var_a15343e5;
	*/
}

function function_c915f7a9()
{
	/*
	var_a6a648f0 = self.stub.var_a6a648f0;
	var_a6a648f0 endon("hash_bbf62f57");
	while(1)
	{
		self waittill("trigger", e_who);
		e_who.var_77f9de0d = self.stub.var_a6a648f0;
		if(e_who zm_laststand::is_reviving_any())
		{
			continue;
		}
		if(e_who.IS_DRINKING > 0)
		{
			continue;
		}
		if(!e_who zm_magicbox::can_buy_weapon())
		{
			continue;
		}
		if(!zm_utility::is_player_valid(e_who))
		{
			continue;
		}
		else
		{
			e_who notify("hash_8c63654c");
		}
		if(isdefined(self.related_parent))
		{
			self.related_parent notify("trigger_activated", e_who);
		}
		if(!isdefined(e_who.useBar))
		{
			if(isdefined(level.var_922007f3))
			{
				self thread [[level.var_922007f3]](e_who);
			}
			else
			{
				self thread function_8cf6fed9();
			}
			var_a6a648f0 thread function_6b1cc9fb();
			var_a7579b72 = self util::waittill_any_ex("webtear_succeed", "webtear_failed", "kill_trigger", var_a6a648f0, "web_torn");
			if(var_a7579b72 == "webtear_succeed")
			{
				e_who.var_7f3c8431 = 1;
				e_who function_20915a1a();
				var_a6a648f0 thread function_6b1cc9fb(1);
				var_a6a648f0 notify("hash_bbf62f57");
				break;
			}
			else
			{
				var_a6a648f0 thread function_6b1cc9fb(1);
			}
		}
	}
	*/
}

function function_8cf6fed9()
{
	/*
	wait(0.25);
	self notify("hash_cca6ad64");
	*/
}

function spider_watch_grenade_fire()
{
	/*
	self endon("death");
	while(1)
	{
		self waittill("grenade_fire", e_grenade, weapon);
		e_grenade thread function_a5ee3628(weapon, self);
	}
	*/
}

function spider_watch_grenade_launcher_fire()
{
	/*
	self endon("death");
	while(1)
	{
		self waittill("grenade_launcher_fire", e_grenade, weapon);
		e_grenade thread function_a5ee3628(weapon, self);
	}
	*/
}

function spider_watch_missile_fire()
{
	/*
	self endon("death");
	while(1)
	{
		self waittill("missile_fire", e_projectile, weapon);
		e_projectile thread function_5165d3f2(weapon, self);
	}
	*/
}

function function_a5ee3628(weapon, player)
{
	/*
	self endon("death");
	if(!isdefined(level.var_d3b40681))
	{
		return;
	}
	if(weapon === GetWeapon("sticky_grenade_widows_wine"))
	{
		self waittill("stationary");
		var_9f172edf = self.origin;
		v_normal = (0, 0, 0);
	}
	else
	{
		self waittill("grenade_bounce", var_9f172edf, v_normal, hitEnt, str_surface);
	}
	foreach(trigger in level.var_d3b40681)
	{
		if(!(isdefined(trigger.b_web_active) && trigger.b_web_active))
		{
			continue;
		}
		if(self istouching(trigger) || trigger.e_web === hitEnt && Distance2DSquared(trigger.origin, var_9f172edf) < 2500)
		{
			self thread function_96ebe65e(trigger, weapon, var_9f172edf, v_normal, player);
			return;
		}
	}
	self thread function_8f6a18e4(player);
	*/
}

function function_8f6a18e4(player)
{
	/*
	var_68b0e214 = self.origin;
	self waittill("death");
	foreach(trigger in level.var_d3b40681)
	{
		if(!isdefined(trigger.b_web_active) && trigger.b_web_active || (isdefined(trigger.var_e084d7bd) && trigger.var_e084d7bd))
		{
			continue;
		}
		if(Distance2DSquared(trigger.origin, var_68b0e214) < 2500)
		{
			player.var_3b4423fd = 1;
			trigger thread function_6b1cc9fb(1, var_68b0e214, undefined, 1);
			trigger notify("hash_bbf62f57");
			player function_20915a1a(1, 1);
			return;
		}
	}
	*/
}

function function_1a393131()
{
	/*
	self endon("death");
	self endon("hash_bbf62f57");
	while(1)
	{
		self.e_web waittill("grenade_stuck", e_grenade);
	}
	*/
}

function function_5165d3f2(weapon, player)
{
	/*
	if(!isdefined(level.var_d3b40681) || weapon == GetWeapon("skull_gun"))
	{
		return;
	}
	self waittill("death");
	if(isdefined(self) && isdefined(self.origin))
	{
		var_318d5542 = self.origin;
	}
	else
	{
		return;
	}
	foreach(trigger in level.var_d3b40681)
	{
		if(!isdefined(trigger.b_web_active) && trigger.b_web_active || (isdefined(trigger.var_e084d7bd) && trigger.var_e084d7bd))
		{
			continue;
		}
		if(Distance2DSquared(trigger.origin, var_318d5542) < 10000)
		{
			if(weapon == GetWeapon("launcher_standard") || weapon == GetWeapon("launcher_standard_upgraded"))
			{
				player.var_86009342 = 1;
			}
			else if(weapon == GetWeapon("ray_gun") || weapon == GetWeapon("ray_gun_upgraded"))
			{
				player.var_ee8976c8 = 1;
			}
			trigger thread function_6b1cc9fb(1, var_318d5542, undefined, 1);
			trigger notify("hash_bbf62f57");
			player function_20915a1a(1, 1);
			return;
		}
	}
	*/
}

function function_96ebe65e(trigger, weapon, var_9f172edf, v_normal, player)
{
	/*
	trigger endon("death");
	trigger endon("hash_bbf62f57");
	player endon("death");
	if(weapon == GetWeapon("frag_grenade"))
	{
		var_a8dac2c5 = player function_5f90b785(var_9f172edf - v_normal, (0, 0, 0), GetWeapon("frag_grenade_web"), weapon.fusetime / 1000);
	}
	else if(weapon == GetWeapon("bouncingbetty"))
	{
		var_a8dac2c5 = player function_5f90b785(var_9f172edf - v_normal, (0, 0, 0), GetWeapon("bouncingbetty_web"), weapon.fusetime / 1000);
	}
	else if(weapon == GetWeapon("sticky_grenade_widows_wine"))
	{
		var_a8dac2c5 = self;
	}
	else
	{
		return;
	}
	var_a8dac2c5.angles = self.angles;
	if(var_a8dac2c5 != self)
	{
		self delete();
	}
	trigger thread function_52f52ae0(var_a8dac2c5);
	var_a8dac2c5 clientfield::set("play_grenade_stuck_in_web_fx", 1);
	var_a8dac2c5 waittill("death");
	if(!(isdefined(trigger.var_e084d7bd) && trigger.var_e084d7bd))
	{
		player.var_3b4423fd = 1;
		trigger thread function_6b1cc9fb(1, var_9f172edf - v_normal, undefined, 1);
		player function_20915a1a(1, 1);
		trigger notify("hash_bbf62f57");
	}
	*/
}

function function_52f52ae0(var_a8dac2c5)
{
	/*
	var_a8dac2c5 endon("death");
	self waittill("hash_bbf62f57");
	var_a8dac2c5 delete();
	*/
}

function function_eca55d4c()
{
	/*
	self endon("death");
	self endon("hash_bbf62f57");
	self.e_destructible SetCanDamage(1);
	self.b_destroyed = 0;
	var_50f39d2b = level.players[0];
	while(!self.b_destroyed)
	{
		self.e_destructible waittill("damage", n_damage, e_attacker, var_a3382de1, v_point, str_means_of_death, var_c4fe462, var_e64d69f9, var_c04aef90, w_weapon);
		if(zm_utility::is_player_valid(e_attacker) && str_means_of_death == "MOD_MELEE")
		{
			if(w_weapon === GetWeapon("bowie_knife"))
			{
				self.b_destroyed = 1;
				var_50f39d2b = e_attacker;
				var_50f39d2b.var_f795ee17 = 1;
			}
		}
		else
		{
			self.health = 10000;
			wait(0.05);
		}
	}
	var_50f39d2b function_20915a1a();
	self thread function_6b1cc9fb(1);
	if(isdefined(self.var_ae94a833))
	{
		self thread [[self.var_ae94a833]]();
	}
	else
	{
		self notify("hash_bbf62f57");
	}
	*/
}

function function_6b1cc9fb(b_destroyed, v_origin, v_angles, var_ef07eb9d)
{
	/*
	if(!isdefined(b_destroyed))
	{
		b_destroyed = 0;
	}
	if(!isdefined(var_ef07eb9d))
	{
		var_ef07eb9d = 0;
	}
	if(!isdefined(self.s_web_struct))
	{
		return;
	}
	if(isdefined(v_origin))
	{
		var_fde3dbd8 = v_origin;
	}
	else
	{
		var_fde3dbd8 = self.s_web_struct.origin;
	}
	if(isdefined(v_angles))
	{
		var_e1a86b86 = v_angles;
	}
	else
	{
		var_e1a86b86 = self.s_web_struct.angles;
	}
	if(!isdefined(self.var_160abeb7) && !b_destroyed)
	{
		self.var_160abeb7 = util::spawn_model("tag_origin", var_fde3dbd8, var_e1a86b86);
		self.var_160abeb7 function_9b41e249(1, self.s_web_struct.script_string);
	}
	else if(!isdefined(self.var_160abeb7) && b_destroyed)
	{
		self.var_160abeb7 = util::spawn_model("tag_origin", var_fde3dbd8, var_e1a86b86);
		if(var_ef07eb9d)
		{
			self.var_160abeb7 function_9b41e249(1, "spider_web_particle_explosive", 1);
		}
		else
		{
			self.var_160abeb7 function_9b41e249(1, self.s_web_struct.script_string, 1);
		}
		util::wait_network_frame();
		if(isdefined(self.var_160abeb7))
		{
			self.var_160abeb7 delete();
		}
	}
	else
	{
		self.var_160abeb7 function_9b41e249(0);
		if(b_destroyed)
		{
			self.var_160abeb7 function_9b41e249(1, self.s_web_struct.script_string, 1);
		}
		util::wait_network_frame();
		if(isdefined(self.var_160abeb7))
		{
			self.var_160abeb7 delete();
		}
	}
	*/
}

function function_9b41e249(var_eddcecaa, str_type, var_a807fb73)
{
	/*
	if(!isdefined(var_eddcecaa))
	{
		var_eddcecaa = 1;
	}
	if(!isdefined(var_a807fb73))
	{
		var_a807fb73 = 0;
	}
	if(!var_eddcecaa)
	{
		self clientfield::set("play_spider_web_tear_fx", 0);
		return;
	}
	switch(str_type)
	{
		case "spider_web_particle_bgb":
		{
			if(!var_a807fb73)
			{
				self clientfield::set("play_spider_web_tear_fx", 1);
			}
			else
			{
				self clientfield::set("play_spider_web_tear_complete_fx", 1);
			}
			break;
		}
		case "spider_web_particle_perk_machine":
		{
			if(!var_a807fb73)
			{
				self clientfield::set("play_spider_web_tear_fx", 2);
			}
			else
			{
				self clientfield::set("play_spider_web_tear_complete_fx", 2);
			}
			break;
		}
		case "spider_web_particle_doorbuy":
		{
			if(!var_a807fb73)
			{
				self clientfield::set("play_spider_web_tear_fx", 3);
			}
			else
			{
				self clientfield::set("play_spider_web_tear_complete_fx", 3);
			}
			break;
		}
		case "spider_web_particle_explosive":
		{
			self clientfield::set("play_spider_web_tear_complete_fx", 4);
			break;
		}
		default:
		{
			if(!var_a807fb73)
			{
				self clientfield::set("play_spider_web_tear_fx", 2);
			}
			else
			{
				self clientfield::set("play_spider_web_tear_complete_fx", 2);
			}
			break;
		}
	}
	*/
}

function function_d717ef02()
{
	/*
	self endon("death");
	self.var_255c77dc = 0;
	while(1)
	{
		level waittill("end_of_round");
		self.var_255c77dc = 0;
	}
	*/
}

function function_20915a1a(n_multiplier, var_2b5697d)
{
	/*
	if(!isdefined(n_multiplier))
	{
		n_multiplier = 1;
	}
	if(!isdefined(var_2b5697d))
	{
		var_2b5697d = 0;
	}
	self endon("death");
	if(self.var_255c77dc < 100)
	{
		var_86b6ca3c = 10 * n_multiplier * zm_score::get_points_multiplier(self);
		self zm_score::add_to_player_score(var_86b6ca3c);
		self.var_255c77dc = self.var_255c77dc + var_86b6ca3c;
	}
	self notify("hash_52472986");
	if(var_2b5697d)
	{
		self notify("hash_7ae66b0a");
	}
	if(self.var_7f3c8431 && self.var_f795ee17 && self.var_86009342 && self.var_3b4423fd && self.var_ee8976c8 && self.var_5c159c87)
	{
		self notify("hash_1327d1d5");
	}
	*/
}

function function_f67965ad(var_4e7dce73)
{
	/*
	if(level.round_number === 1)
	{
		return 1;
	}
	if(zm_utility::check_point_in_enabled_zone(var_4e7dce73, 1))
	{
		foreach(player in level.players)
		{
			if(DistanceSquared(player.origin, var_4e7dce73) < 640000)
			{
				return 0;
			}
			if(player util::is_player_looking_at(var_4e7dce73, 0.5, 0) && DistanceSquared(player.origin, var_4e7dce73) < 1440000)
			{
				return 0;
			}
		}
		return 1;
	}
	else
	{
		return 0;
	}
	*/
}

function function_3fd0c070()
{
	/*
	/#
		level flagsys::wait_till("Dev Block strings are not supported");
		zm_devgui::function_4acecab5(&function_8457e10f);
	#/
	*/
}

function function_8457e10f(cmd)
{
	/*
	/#
		switch(cmd)
		{
			case "Dev Block strings are not supported":
			{
				var_19764360 = get_favorite_enemy();
				s_spawn_point = function_570247b9(var_19764360);
				ai = zombie_utility::spawn_zombie(level.var_c38a4fee[0]);
				if(isdefined(ai) && isdefined(s_spawn_point))
				{
					s_spawn_point thread spider_spawn_animation(ai, s_spawn_point);
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				var_19764360 = get_favorite_enemy();
				s_spawn_point = function_570247b9(var_19764360);
				ai = zombie_utility::spawn_zombie(level.var_c38a4fee[0]);
				if(isdefined(ai) && isdefined(s_spawn_point))
				{
					s_spawn_point thread spider_spawn_animation(ai, s_spawn_point, 1);
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				a_enemies = GetAITeamArray(level.zombie_team);
				if(a_enemies.size > 0)
				{
					foreach(e_enemy in a_enemies)
					{
						if(isdefined(e_enemy.b_is_spider) && e_enemy.b_is_spider)
						{
							e_enemy kill();
						}
					}
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				level.var_3013498 = level.round_number + 1;
				zm_devgui::zombie_devgui_goto_round(level.var_3013498);
				break;
			}
			case "Dev Block strings are not supported":
			{
				level.var_42034f6a = 100;
				break;
			}
			case "Dev Block strings are not supported":
			{
				level.var_f618f3e1 = 1;
				level.var_42034f6a = 100;
				level notify("hash_9996f546");
				util::wait_network_frame();
				foreach(trigger in level.var_d3b40681)
				{
					if(!(isdefined(trigger.b_web_active) && trigger.b_web_active))
					{
						trigger notify("trigger", level.players[0], trigger);
					}
				}
				break;
			}
		}
	#/
	*/
}