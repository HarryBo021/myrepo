#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicles\_spider;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb_machine;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_ai_spiders.gsh;
#insert scripts\shared\aat_zm.gsh;

#precache("model", "p7_zm_isl_web_vending_doubletap2");
#precache("model", "p7_zm_isl_web_vending_revive");
#precache("model", "p7_zm_isl_web_vending_sleight");
#precache("model", "p7_zm_isl_web_vending_marathon");
#precache("model", "p7_zm_isl_web_vending_jugg");
#precache("model", "p7_zm_isl_web_vending_three_gun");
#precache("fx", "dlc2/island/fx_spider_death_explo_sm");
#precache("fx", "dlc2/island/fx_web_bgb_reweb");
#precache("fx", "dlc2/island/fx_web_perk_machine_reweb");
#precache("fx", "dlc2/island/fx_spider_spit_projectile_reweb");
#precache("fx", "dlc2/island/fx_web_impact_player_melee");
#precache("fx", "dlc2/island/fx_web_impact_spider_crawl");
	
#using_animtree( "generic" );
	
#namespace zm_ai_spiders;

REGISTER_SYSTEM_EX( "zm_ai_spiders", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "toplayer", "spider_round_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "toplayer", "spider_round_ring_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "toplayer", "spider_end_of_round_reset", VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", "set_fade_material", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "web_fade_material", VERSION_SHIP, 3, "float" );
	clientfield::register( "missile", "play_grenade_stuck_in_web_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "play_spider_web_tear_fx", VERSION_SHIP, getMinBitCountForNum( 4 ), "int" );
	clientfield::register( "scriptmover", "play_spider_web_tear_complete_fx", VERSION_SHIP, getMinBitCountForNum( 4 ), "int" );
	clientfield::register( "world", "force_stream_spiders", VERSION_SHIP, 1, "int" );
	
	zm_audio::musicState_Create( "spider_roundstart", 3, "island_spider_roundstart_1" );
	zm_audio::musicState_Create( "spider_roundend", 3, "island_spider_roundend_1" );
	
	level.spiders_enabled = 1;
	level.spider_rounds_enabled = 0;
	level.spider_round_count = 1;
	level.spider_web_chance = 30;
	level.spider_spawners = [];
	level.n_spider_melee_range = 200;
	level.n_spider_round_count = 1;
	level.aat[ ZM_AAT_TURNED_NAME ].immune_trigger[ "spider" ] = 1;
	level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_result_indirect[ "spider" ] = 1;
	level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_trigger[ "spider" ] = 1;
	level.melee_range_sav = getdvarstring( "ai_meleeRange" );
	level.melee_width_sav = getdvarstring( "ai_meleeWidth" );
	level.melee_height_sav = getdvarstring( "ai_meleeHeight" );
	
	level flag::init( "spider_round" );
	level flag::init( "spider_clips" );
	level flag::init( "spider_round_in_progress" );
	
	level._effect[ "spider_gib" ] = "dlc2/island/fx_spider_death_explo_sm";
	level._effect[ "spider_web_bgb_reweb" ] = "dlc2/island/fx_web_bgb_reweb";
	level._effect[ "spider_web_perk_machine_reweb" ] = "dlc2/island/fx_web_perk_machine_reweb";
	level._effect[ "spider_web_doorbuy_reweb" ] = "dlc2/island/fx_web_perk_machine_reweb";
	level._effect[ "spider_web_spit_reweb" ] = "dlc2/island/fx_spider_spit_projectile_reweb";
	level._effect[ "spider_web_melee_hit" ] = "dlc2/island/fx_web_impact_player_melee";
	level._effect[ "spider_web_spider_enter" ] = "dlc2/island/fx_web_impact_spider_crawl";
	level._effect[ "spider_web_spider_leave" ] = "dlc2/island/fx_web_impact_spider_crawl";
	
	scene::add_scene_func( "scene_zm_dlc2_spider_web_engage", &spider_scene_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_spider_burrow_out_of_ground", &spider_scene_delete, "done" );
	visionset_mgr::register_info( "visionset", "zm_isl_parasite_spider_visionset", VERSION_SHIP, 33, 16, 0, &visionset_mgr::ramp_in_out_thread, 0 );
	
	spider_spawner_init();
	
	level thread spider_clip_monitor();
	level thread spiders_init_webs();
	
	callback::on_spawned( &spider_webs_grenade_watcher );
	callback::on_spawned( &spider_webs_grenade_launcher_watcher );
	callback::on_spawned( &spider_webs_missile_watcher );
	callback::on_spawned( &spider_last_stand_cleanup );
	callback::on_spawned( &spider_score_round_cap_reset );
	callback::on_connect( &spider_player_on_connect );
}

function spiders_init_webs()
{
	level flag::wait_till( "start_zombie_round_logic" );
	level thread spider_web_doors_and_bgbs_init();
	level thread spider_web_perks_init();
}

function __main__()
{
}

function spider_player_on_connect()
{
	self.b_web_tear_done = 0;
	self.b_web_tear_perk_done = 0;
	self.b_web_tear_with_launcher_done = 0;
	self.b_web_tear_with_grenade_done = 0;
	self.b_web_tear_with_raygun_done = 0;
	self.b_web_tear_with_mirg_done = 0;
}

function spider_last_stand_cleanup()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "bled_out" );
		if ( level flag::get( "spider_round_in_progress" ) )
		{
			self waittill( "spawned_player" );
			level flag::wait_till_clear( "spider_round_in_progress" );
			util::wait_network_frame();
			self clientfield::increment_to_player( "spider_end_of_round_reset", 1 );
		}
	}
}

function spider_scene_delete( a_ents )
{
	if ( self.model === "tag_origin" )
		self zm_utility::self_delete();
	
}

function spider_clip_monitor()
{
	clips_on = 0;
	level.spider_clips = getEntArray( "spider_clips", "targetname" );
	while ( 1 )
	{
		for ( i = 0; i < level.spider_clips.size; i++ )
			level.spider_clips[ i ] connectpaths();
		
		level flag::wait_till( "spider_clips" );
		if ( IS_TRUE( level.no_spider_clip ) )
			return;
		
		for ( i = 0; i < level.spider_clips.size; i++ )
		{
			level.spider_clips[ i ] disconnectPaths();
			util::wait_network_frame();
		}
		b_spider_is_alive = 1;
		while ( b_spider_is_alive || level flag::get( "spider_round" ) )
		{
			b_spider_is_alive = 0;
			a_spiders = getVehicleArray( "zombie_spider", "targetname" );
			for ( i = 0; i < a_spiders.size; i++ )
			{
				if ( isAlive( a_spiders[ i ] ) )
					b_spider_is_alive = 1;
				
			}
			wait 1;
		}
		level flag::clear( "spider_clips" );
		wait 1;
	}
}

function enable_spider_rounds()
{
	level.spider_rounds_enabled = 1;
	if ( !isDefined( level.spider_round_track_override ) )
		level.spider_round_track_override = &spider_round_tracker;
	
	level thread [ [ level.spider_round_track_override ] ]();
}

function spider_spawner_init()
{
	level.spider_spawners = getEntArray( "zombie_spider_spawner", "script_noteworthy" );
	later_spiders = getEntArray( "later_round_spider_spawners", "script_noteworthy" );
	level.a_spider_spawners = arraycombine( level.spider_spawners, later_spiders, 1, 0 );
	
	if ( level.spider_spawners.size == 0 )
		return;
	
	for ( i = 0; i < level.spider_spawners.size; i++ )
	{
		if ( zm_spawner::is_spawner_targeted_by_blocker( level.spider_spawners[ i ] ) )
		{
			level.spider_spawners[ i ].is_enabled = 0;
			continue;
		}
		level.spider_spawners[ i ].is_enabled = 1;
		level.spider_spawners[ i ].script_forcespawn = 1;
	}
	
	array::thread_all( level.spider_spawners, &spawner::add_spawn_function, &spider_init );
}

function spider_init()
{
	self.targetname = "zombie_spider";
	self.b_is_spider = 1;
	spider_health_increase();
	self.maxhealth = level.n_spider_health;
	self.health = self.maxhealth;
	self.no_gib = 1;
	self.no_eye_glow = 1;
	self.custom_player_shellshock = &spider_custom_player_shellshock;
	self.team = level.zombie_team;
	self.missinglegs = 0;
	self.thundergun_knockdown_func = &spider_thundergun_knockdown;
	self.lightning_chain_immune = 1;
	self.heroweapon_kill_power = 1;
	self thread zombie_utility::round_spawn_failsafe();
	self thread spider_set_damage_type();
	self thread spider_death();
	self playsound( "zmb_spider_spawn" );
	self thread spider_stalk_audio();
}

function spider_set_damage_type()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage", n_amount, e_attacker, v_direction, v_hit_location, str_mod );
		if ( isPlayer( e_attacker ) )
		{
			e_attacker.use_weapon_type = str_mod;
			self thread zm_powerups::check_for_instakill( e_attacker, str_mod, v_hit_location );
		}
	}
}

function spider_thundergun_knockdown( e_player, gib )
{
	self endon( "death" );
	n_damage = int( self.maxhealth * .5 );
	self doDamage( n_damage, self.origin, e_player );
}

function spider_stalk_audio()
{
	self endon( "death" );
	wait randomFloatRange( 3, 6 );
	while ( 1 )
	{
		self playSoundOnTag( "zmb_spider_vocals_ambient", "tag_eye" );
		wait randomFloatRange( 2, 6 );
	}
}

function spider_death()
{
	self waittill( "death", e_attacker );
	if ( get_current_spider_count() == 0 && level.zombie_total == 0 )
	{
		if ( !isDefined( level.zm_ai_round_over ) || [ [ level.zm_ai_round_over ] ]() )
		{
			level.last_ai_origin = self.origin;
			level notify( "last_ai_down", self );
		}
	}
	if ( isPlayer( e_attacker ) )
	{
		if ( !IS_TRUE( self.deathpoints_already_given ) )
			e_attacker zm_score::player_add_points( "death_spider" );
		
		if ( isDefined( level.hero_power_update ) )
			[ [ level.hero_power_update ] ]( e_attacker, self );
		
		e_attacker notify( "player_killed_spider" );
		e_attacker zm_stats::increment_client_stat( "zspiders_killed" );
		e_attacker zm_stats::increment_player_stat( "zspiders_killed" );
	}
	if ( isDefined( e_attacker ) && isAi( e_attacker ) )
	{
		e_attacker notify( "killed", self );
	}
	if ( isDefined( self ) )
	{
		self stopLoopSound();
		self thread spider_do_death_fx( self.origin );
	}
}

function spider_do_death_fx( v_pos )
{
	self thread fx::play( "spider_gib", v_pos );
}

function spider_round_tracker()
{
	level.n_next_spider_round = level.round_number + randomIntRange( SPIDERS_START_ROUND_MIN, SPIDERS_START_ROUND_MAX );
	
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	
	while ( 1 )
	{
		level waittill( "between_round_over" );
		
		if ( level.round_number == level.n_next_spider_round )
		{
			level.sndmusicspecialround = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			spider_round_start();
			level.round_spawn_func = &spider_round_spawning;
			level.round_wait_func = &spider_round_wait_func;
			level.n_next_spider_round = level.round_number + randomIntRange( SPIDERS_NEXT_ROUND_MIN, SPIDERS_NEXT_ROUND_MAX );
		}
		else if ( level flag::get( "spider_round" ) )
		{
			spider_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.n_spider_round_count = level.n_spider_round_count + 1;
		}
	}
}

function spider_round_fx()
{
	foreach ( player in level.players )
	{
		player clientfield::increment_to_player( "spider_round_fx" );
		player clientfield::increment_to_player( "spider_round_ring_fx" );
	}
	visionset_mgr::activate( "visionset", "zm_isl_parasite_spider_visionset", undefined, 1.5, &spider_round_waittill_end, 2 );
}

function spider_round_waittill_end()
{
	level flag::wait_till_clear( "spider_round_in_progress" );
}

function spider_round_spawning()
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	
	for ( i = 0; i < level.players.size; i++ )
		level.players[ i ].hunted_by = 0;
	
	if ( level.intermission )
		return;
	
	level flag::set( "spider_round_in_progress" );
	level thread spider_round_aftermath();
	array::thread_all( level.players, &play_spider_round );
	
	wait 1;
	level notify( "enable_spider_round_webs" );
	spider_round_fx();
	wait 4;
	n_spider_total = get_spiders_round_total();
	
	level.zombie_total = n_spider_total;
	while ( 1 )
	{
		while ( level.zombie_total > 0 )
		{
			if ( IS_TRUE( level.bzm_worldpaused ) )
			{
				util::wait_network_frame();
				continue;
			}
			spawn_spiders();
			util::wait_network_frame();
		}
		util::wait_network_frame();
	}
}

function get_spiders_round_total()
{
	if ( level.n_spider_round_count < 3 )
		n_wave_count = level.players.size * SPIDERS_PER_ROUND_PER_PLAYER;
	else
		n_wave_count = level.players.size * SPIDERS_PER_ROUND_PER_PLAYER;
	
	return n_wave_count;
}

function spawn_spiders()
{
	while ( !can_we_spawn_spiders() )
		wait .1;
	
	s_spawn_loc = undefined;
	e_favorite_enemy = get_favorite_enemy();
	if ( !isDefined( e_favorite_enemy ) )
	{
		wait randomFloatRange( .3333333, .6666667 );
		return;
	}
	if ( isDefined( level.spider_spawn_func ) )
		s_spawn_loc = [ [ level.spider_spawn_func ] ]( e_favorite_enemy );
	else
		s_spawn_loc = spider_spawn_logic( e_favorite_enemy );
	
	if ( !isDefined( s_spawn_loc ) )
	{
		wait randomFloatRange( .3333333, .6666667 );
		return;
	}
	
	ai = zombie_utility::spawn_zombie( level.spider_spawners[ 0 ] );
	
	if ( isDefined( ai ) )
	{
		s_spawn_loc thread spider_spawn_fx( ai, s_spawn_loc );
		level.zombie_total--;
		level thread zm_spawner::zombie_death_event( ai );
		if ( isDefined( level.ptr_spider_post_spawn ) )
			ai thread [ [ level.ptr_spider_post_spawn ] ]();
		
		waiting_for_next_spider_spawn();
	}
}

function can_we_spawn_spiders()
{
	n_spider_alive = get_current_spider_count();
	b_spider_count_at_max = n_spider_alive >= SPIDERS_MAX_AT_ONE_TIME;
	n_spider_count_per_player_at_max = n_spider_alive >= ( level.players.size * SPIDERS_MAX_AT_ONE_TIME_PER_PLAYER );
	if ( b_spider_count_at_max || n_spider_count_per_player_at_max || !level flag::get( "spawn_zombies" ) )
		return 0;
	
	return 1;
}

function get_current_spider_count()
{
	spiders = getEntArray( "zombie_spider", "targetname" );
	n_alive_spiders = spiders.size;
	foreach ( ai_spider in spiders )
	{
		if ( !isAlive( ai_spider ) )
			n_alive_spiders--;
		
	}
	return n_alive_spiders;
}

function spider_round_wait_func()
{
	level endon( "restart_round" );
	
	if ( level flag::get( "spider_round" ) )
	{
		level flag::wait_till( "spider_round_in_progress" );
		level flag::wait_till_clear( "spider_round_in_progress" );
	}
	level.sndmusicspecialround = 0;
}

function spider_round_start()
{
	level flag::set( "spider_round" );
	level flag::set( "special_round" );
	level clientfield::set( "force_stream_spiders", 1 );
	
	if ( !isDefined( level.b_spider_round_nomusic ) )
		level.b_spider_round_nomusic = 0;
	
	level.b_spider_round_nomusic = 1;
	level notify( "spider_round_starting" );
	level thread zm_audio::sndmusicsystem_playstate( "spider_roundstart" );
	
	if ( isDefined( level.n_spider_melee_range ) )
		setDvar( "ai_meleeRange", level.n_spider_melee_range );
	else
		setDvar( "ai_meleeRange", 100 );
	
}

function spider_round_stop()
{
	level flag::clear( "spider_round" );
	level flag::clear( "special_round" );
	level clientfield::set( "force_stream_spiders", 0 );
	
	if ( !isDefined( level.b_spider_round_nomusic ) )
		level.b_spider_round_nomusic = 0;
	
	level.b_spider_round_nomusic = 0;
	level notify( "spider_round_ending" );
	setDvar( "ai_meleeRange", level.melee_range_sav );
	setDvar( "ai_meleeWidth", level.melee_width_sav );
	setDvar( "ai_meleeHeight", level.melee_height_sav );
}

function waiting_for_next_spider_spawn()
{
	switch ( level.players.size )
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
	wait n_default_wait;
}

function spider_health_increase()
{
	if ( isDefined( level.n_spider_health_override ) )
		level.n_spider_health = level.n_spider_health_override;
	else
	{
		switch ( level.n_spider_round_count )
		{
			case 1:
			{
				level.n_spider_health = SPIDERS_FIRST_SPIDER_ROUND_HEALTH;
				break;
			}
			case 2:
			{
				level.n_spider_health = SPIDERS_SECOND_SPIDER_ROUND_HEALTH;
				break;
			}
			case 3:
			{
				level.n_spider_health = SPIDERS_THIRD_SPIDER_ROUND_HEALTH;
				break;
			}
			default:
			{
				level.n_spider_health = SPIDERS_LATER_SPIDER_ROUND_HEALTH;
				break;
			}
		}
		level.n_spider_health = int( level.n_spider_health * .5 );
	}
}

function spider_spawn_logic( e_favorite_enemy )
{
	switch ( level.players.size )
	{
		case 1:
		{
			n_spawn_dist_min = 2500;
			n_spawn_dist_max = 490000;
			break;
		}
		case 2:
		{
			n_spawn_dist_min = 2500;
			n_spawn_dist_max = 810000;
			break;
		}
		case 3:
		{
			n_spawn_dist_min = 2500;
			n_spawn_dist_max = 1000000;
			break;
		}
		case 4:
		{
			n_spawn_dist_min = 2500;
			n_spawn_dist_max = 1000000;
			break;
		}
		default:
		{
			n_spawn_dist_min = 2500;
			n_spawn_dist_max = 490000;
			break;
		}
	}
	if ( isDefined( level.zm_loc_types[ "spider_location" ] ) )
		a_spider_locs = array::randomize( level.zm_loc_types[ "spider_location" ] );
	else
		return;
	
	for ( i = 0; i < a_spider_locs.size; i++ )
	{
		if ( isDefined( level.s_last_spider_spawn_loc ) && level.s_last_spider_spawn_loc == a_spider_locs[ i ] )
			continue;
		
		n_dist_squared = distanceSquared( a_spider_locs[ i ].origin, e_favorite_enemy.origin );
		n_height_diff = abs( a_spider_locs[ i ].origin[ 2 ] - e_favorite_enemy.origin[ 2 ] );
		if ( n_dist_squared > n_spawn_dist_min && n_dist_squared < n_spawn_dist_max && n_height_diff < 128 )
		{
			s_spawn_loc = spider_get_safe_spawn_pos( a_spider_locs[ i ] );
			level.s_last_spider_spawn_loc = s_spawn_loc;
			return s_spawn_loc;
		}
	}
	s_spawn_loc = spider_get_safe_spawn_pos( arrayGetClosest( e_favorite_enemy.origin, a_spider_locs ) );
	level.s_last_spider_spawn_loc = s_spawn_loc;
	return s_spawn_loc;
}

function spider_get_safe_spawn_pos( s_spawn_loc )
{
	s_struct = s_spawn_loc;
	s_struct.origin = s_spawn_loc.origin + vectorScale( ( 0, 0, 1 ), 16 );
	return s_struct;
}

function play_spider_round()
{
	self playLocalSound( "zmb_raps_round_start" );
}

function spider_round_aftermath()
{
	level waittill( "last_ai_down", e_enemy_ai );
	level thread zm_audio::sndmusicsystem_playstate( "spider_roundend" );
	if ( isDefined( level.zm_override_ai_aftermath_powerup_drop ) )
		[ [ level.zm_override_ai_aftermath_powerup_drop ] ]( e_enemy_ai, level.last_ai_origin );
	else
	{
		v_power_up_origin = level.last_ai_origin;
		if ( !isPointOnNavMesh( v_power_up_origin, e_enemy_ai ) )
		{
			v_power_up_origin = getClosestPointOnNavMesh( v_power_up_origin, 100 );
			if ( !isDefined( v_power_up_origin ) )
			{
				e_player = zm_utility::get_closest_player( level.last_ai_origin );
				v_power_up_origin = e_player.origin;
			}
		}
		trace = groundTrace( v_power_up_origin + vectorScale( ( 0, 0, 1 ), 15 ), v_power_up_origin + ( vectorScale( ( 0, 0, -1 ), 1000 ) ), 0, undefined );
		v_power_up_origin = trace[ "position" ];
		if ( isDefined( v_power_up_origin ) )
			level thread zm_powerups::specific_powerup_drop( "full_ammo", v_power_up_origin );
		
	}
	wait 2;
	level.sndmusicspecialround = 0;
	if ( isDefined( level.zm_override_spider_round_end ) )
	{
		[ [ level.zm_override_spider_round_end ] ]();
	}
	else
	{
		wait 6;
		level flag::clear( "spider_round_in_progress" );
		foreach ( player in level.players )
			player clientfield::increment_to_player( "spider_end_of_round_reset", 1 );
		
	}
}

function get_favorite_enemy()
{
	a_spider_targets = level.players;
	e_least_hunted = a_spider_targets[ 0 ];
	for ( i = 0; i < a_spider_targets.size; i++ )
	{
		if ( !isDefined( a_spider_targets[ i ].hunted_by ) )
			a_spider_targets[ i ].hunted_by = 0;
		
		if ( !zm_utility::is_player_valid( a_spider_targets[ i ] ) )
			continue;
		
		if ( !zm_utility::is_player_valid( e_least_hunted ) )
			e_least_hunted = a_spider_targets[ i ];
		
		if ( a_spider_targets[ i ].hunted_by < e_least_hunted.hunted_by )
			e_least_hunted = a_spider_targets[ i ];
		
	}
	e_least_hunted.hunted_by = e_least_hunted.hunted_by + 1;
	return e_least_hunted;
}

function special_spider_spawn( n_to_spawn, s_spawn_point )
{
	a_spiders = getVehicleArray( "zombie_spider", "targetname" );
	
	if ( isDefined( a_spiders ) && a_spiders.size >= 9 )
		return 0;
	
	if ( !isDefined( n_to_spawn ) )
		n_to_spawn = 1;
	
	n_spider_count = 0;
	while ( n_spider_count < n_to_spawn )
	{
		e_favorite_enemy = get_favorite_enemy();
		if ( isDefined( level.spider_spawn_func ) )
		{
			if ( !isDefined( s_spawn_point ) )
			{
				s_spawn_point = [ [ level.spider_spawn_func ] ]( level.spider_spawners, e_favorite_enemy );
			}
			ai = zombie_utility::spawn_zombie( level.spider_spawners[ 0 ] );
			if ( isDefined( ai ) )
			{
				s_spawn_point thread spider_spawn_fx( ai, s_spawn_point );
				level.zombie_total--;
				n_spider_count++;
				level flag::set( "spider_clips" );
			}
		}
		else if ( !isDefined( s_spawn_point ) )
			s_spawn_point = spider_spawn_logic( e_favorite_enemy );
		
		ai = zombie_utility::spawn_zombie( level.spider_spawners[ 0 ] );
		if ( isDefined( ai ) )
		{
			s_spawn_point thread spider_spawn_fx( ai, s_spawn_point );
			level.zombie_total--;
			n_spider_count++;
			level flag::set( "spider_clips" );
		}
		waiting_for_next_spider_spawn();
	}
	if ( isDefined( ai ) )
		return ai;
	
	return undefined;
}

function spider_spawn_fx( ai_spider, ent = self, b_force_burrow = 0 )
{
	ai_spider endon( "death" );
	ai_spider ai::set_ignoreall( 1 );
	
	if ( !isDefined( ent.target ) || b_force_burrow )
	{
		ai_spider ghost();
		ai_spider util::delay( .2, "death", &show );
		ai_spider util::delay_notify( .2, "visible", "death" );
		ai_spider.origin = ent.origin;
		ai_spider.angles = ent.angles;
		ai_spider vehicle_ai::set_state( "scripted" );
		if ( isAlive( ai_spider ) )
		{
			a_ground_trace = groundTrace( ai_spider.origin + vectorScale( ( 0, 0, 1 ), 100 ), ai_spider.origin - vectorScale( ( 0, 0, 1 ), 1000 ), 0, ai_spider, 1 );
			if ( isDefined( a_ground_trace[ "position" ] ) )
				e_scene_model = util::spawn_model( "tag_origin", a_ground_trace[ "position" ], ai_spider.angles );
			else
				e_scene_model = util::spawn_model( "tag_origin", ai_spider.origin, ai_spider.angles );
			
			e_scene_model scene::play( "scene_zm_dlc2_spider_burrow_out_of_ground", ai_spider );
			state = "combat";
			if ( randomFloat( 1 ) > .6 )
				state = "meleeCombat";
			
			ai_spider vehicle_ai::set_state( state );
			ai_spider setVisibleToAll();
			ai_spider ai::set_ignoreme( 0 );
		}
	}
	else
	{
		ai_spider.disablearrivals = 1;
		ai_spider.disableexits = 1;
		ai_spider vehicle_ai::set_state( "scripted" );
		ai_spider notify( "visible" );
		a_spawn_scenebundles = struct::get_array( ent.target, "targetname" );
		s_spawn_scenebundle = array::random( a_spawn_scenebundles );
		if ( isDefined( s_spawn_scenebundle ) && isAlive( ai_spider ) )
		{
			s_spawn_scenebundle.script_play_multiple = 1;
			level scene::play( ent.target, ai_spider );
		}
		else
		{
			a_vehicle_nodes = getVehicleNodeArray( ent.target, "targetname" );
			s_vehicle_node = array::random( a_vehicle_nodes );
			ai_spider ghost();
			ai_spider.spider_anchor = spawner::simple_spawn_single( "spider_mover_spawner" );
			ai_spider.origin = ai_spider.spider_anchor.origin;
			ai_spider.angles = ai_spider.spider_anchor.angles;
			ai_spider linkTo( ai_spider.spider_anchor );
			s_end = struct::get( s_vehicle_node.target, "targetname" );
			ai_spider.spider_anchor vehicle::get_on_path( s_vehicle_node );
			ai_spider show();
			if ( isDefined( s_vehicle_node.script_int ) )
				ai_spider.spider_anchor setSpeed( s_vehicle_node.script_int );
			else
				ai_spider.spider_anchor setSpeed( 20 );
			
			ai_spider.spider_anchor vehicle::go_path();
			ai_spider notify( "spider_on_path" );
			ai_spider unlink();
			ai_spider.spider_anchor delete();
		}
		earthquake( .1, .5, ai_spider.origin, 256 );
		state = "combat";
		if ( randomFloat( 1 ) > .6 )
			state = "meleeCombat";
		
		ai_spider vehicle_ai::set_state( state );
		ai_spider.completed_emerging_into_playable_area = 1;
	}
	ai_spider ai::set_ignoreall( 0 );
}

function spider_custom_player_shellshock( damage, attacker, direction_vec, point, mod )
{
	if ( mod == "MOD_EXPLOSIVE" )
		self thread spider_shellshock_player();
	
}

function spider_shellshock_player()
{
	self endon( "death" );
	if ( !isDefined( self.n_spider_shellshock_count ) )
		self.n_spider_shellshock_count = 0;
	
	self.n_spider_shellshock_count++;
	if ( self.n_spider_shellshock_count >= 4 )
		self shellShock( "pain", 1 );
	
	self util::waittill_any_timeout( 10, "death" );
	self.n_spider_shellshock_count--;
}

function spider_web_doors_and_bgbs_init()
{
	a_door_webs = getEntArray( "spider_web_visual", "script_string" );
	array::run_all( a_door_webs, &notsolid );
	array::run_all( a_door_webs, &hide );
	level.a_spider_webs = [];
	level.revive_trigger_should_ignore_sight_checks = &spider_web_should_ignore_sight_checks;
	a_bgb_webs = getEntArray( "bgb_web_trigger", "targetname" );
	foreach ( trigger in a_bgb_webs )
	{
		trigger thread spider_web_bgb_init_and_think();
		if ( !isDefined( level.a_spider_webs ) )
			level.a_spider_webs = [];
		else if ( !isArray( level.a_spider_webs ) )
			level.a_spider_webs = array( level.a_spider_webs );
		
		level.a_spider_webs[ level.a_spider_webs.size ] = trigger;
	}
	
	a_zombie_door_triggers = getEntArray( "zombie_door", "targetname" );
	foreach ( trigger in a_zombie_door_triggers )
	{
		a_target_ents = getEntArray( trigger.target, "targetname" );
		a_door_web_triggers = [];
		foreach ( e_piece in a_target_ents )
		{
			if ( e_piece.script_string === "spider_web_trigger" )
			{
				if ( !isDefined( a_door_web_triggers ) )
					a_door_web_triggers = [];
				else if ( !isArray( a_door_web_triggers ) )
					a_door_web_triggers = array( a_door_web_triggers );
				
				a_door_web_triggers[ a_door_web_triggers.size ] = e_piece;
			}
		}
		foreach ( e_door_web_trigger in a_door_web_triggers )
		{
			e_door_web_trigger.e_web_trigger = trigger;
			e_door_web_trigger.script_flag = trigger.script_flag;
			e_door_web_trigger spider_web_door_init();
			if ( !IS_TRUE( e_door_web_trigger.b_active ) )
			{
				e_door_web_trigger.b_active = 1;
				if ( !isDefined( level.a_spider_webs ) )
					level.a_spider_webs = [];
				else if ( !isArray( level.a_spider_webs ) )
					level.a_spider_webs = array( level.a_spider_webs );
				
				level.a_spider_webs[ level.a_spider_webs.size ] = e_door_web_trigger;
				e_door_web_trigger thread spider_web_door_watcher();
			}
		}
	}
}

function spider_web_door_init()
{
	a_target_ents = getEntArray( self.target, "targetname" );
	self.s_spider_web_fx = struct::get( self.target, "targetname" );
	foreach ( e_target_ent in a_target_ents )
	{
		if ( e_target_ent.script_string === "spider_web_visual" )
		{
			self.e_destructible = e_target_ent;
			self.e_web_model = e_target_ent;
			self.e_web_model clientfield::set( "web_fade_material", 0 );
		}
	}
}

function spider_web_create_webtear_trigger()
{
	s_unitrigger = spawnStruct();
	s_unitrigger.origin = self.origin;
	if ( self.targetname == "bgb_web_trigger" || self.targetname == "doorbuy_web_trigger" )
	{
		s_trigger_struct = struct::get_array( self.target, "targetname" );
		if ( isDefined( s_trigger_struct[ 0 ] ) )
			s_unitrigger.angles = s_trigger_struct[ 0 ].angles;
		else
			s_unitrigger.angles = self.angles;
		
	}
	else
		s_unitrigger.angles = self.angles;
	
	s_unitrigger.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger.cursor_hint = "HINT_NOICON";
	s_unitrigger.require_look_at = 0;
	s_unitrigger.e_web_trigger = self;
	if ( isDefined( self.script_width ) )
		s_unitrigger.script_width = self.script_width;
	else
		s_unitrigger.script_width = 128;
	
	if ( isDefined( self.script_length ) )
		s_unitrigger.script_length = self.script_length;
	else
		s_unitrigger.script_length = 130;
	
	if ( isDefined( self.script_height ) )
		s_unitrigger.script_height = self.script_height;
	else
		s_unitrigger.script_height = 100;
	
	if ( isDefined( self.script_vector ) )
	{
		s_unitrigger.script_length = self.script_vector[ 0 ];
		s_unitrigger.script_width = self.script_vector[ 1 ];
		s_unitrigger.script_height = self.script_vector[ 2 ];
	}
	s_unitrigger.prompt_and_visibility_func = &spider_web_prompt_and_visiblity_func;
	zm_unitrigger::register_static_unitrigger( s_unitrigger, &spider_web_unitrigger_think );
	self.s_unitrigger = s_unitrigger;
}

function spider_web_bgb_init_and_think()
{
	self endon( "death" );
	self spider_web_door_init();
	self.e_bgb_machine = undefined;
	
	foreach ( e_bgb_machine in level.bgb_machines )
	{
		if ( e_bgb_machine isTouching( self ) )
		{
			self.e_bgb_machine = e_bgb_machine;
			self.e_web_model.origin = self.e_bgb_machine.origin;
			self.e_web_model.angles = self.e_bgb_machine.angles;
		}
	}
	while ( 1 )
	{
		if ( can_be_webbed( self.origin ) )
		{
			self set_webbed_state( 1 );
			if ( isDefined( self.e_bgb_machine ) )
			{
				self notify( "end_old_bgb_webs" );
				self thread spider_web_bgb_webtear_think();
			}
			self waittill( "web_torn" );
			self set_webbed_state( 0 );
		}
		level waittill( "enable_spider_round_webs" );
	}
}

function spider_web_bgb_webtear_think()
{
	self endon( "death" );
	self endon( "end_old_bgb_webs" );
	self.e_bgb_machine thread fx::play( "spider_web_bgb_reweb", self.e_bgb_machine.origin, self.e_bgb_machine.angles );
	if ( self.e_bgb_machine bgb_machine::get_bgb_machine_state() === "initial" || self.e_bgb_machine bgb_machine::is_bgb_machine_active() )
	{
		self.e_bgb_machine thread zm_unitrigger::unregister_unitrigger( self.e_bgb_machine.unitrigger_stub );
		self waittill( "web_torn" );
		self.e_bgb_machine thread zm_unitrigger::register_static_unitrigger( self.e_bgb_machine.unitrigger_stub, &bgb_machine::bgb_machine_unitrigger_think );
	}
	while ( 1 )
	{
		self.e_bgb_machine waittill( "zbarrier_state_change" );
		if ( IS_TRUE( self.b_web_on ) )
		{
			if ( self.e_bgb_machine bgb_machine::get_bgb_machine_state() === "initial" || self.e_bgb_machine bgb_machine::is_bgb_machine_active() )
			{
				self.e_bgb_machine thread zm_unitrigger::unregister_unitrigger( self.e_bgb_machine.unitrigger_stub );
				self waittill( "web_torn" );
				self.e_bgb_machine thread zm_unitrigger::register_static_unitrigger( self.e_bgb_machine.unitrigger_stub, &bgb_machine::bgb_machine_unitrigger_think );
			}
		}
	}
}

function spider_web_door_watcher()
{
	self endon( "death" );
	while ( !IS_TRUE( self.e_web_trigger._door_open ) )
		wait .5;
	
	while ( 1 )
	{
		self trigger::wait_till();
		if ( IS_TRUE( self.who.b_is_spider ) )
		{
			e_spider = self.who;
			n_web_chance = randomInt( 100 );
			if ( n_web_chance < level.spider_web_chance )
			{
				self.n_ai_stuck_to_web = 0;
				self thread spider_webtear_door_think();
				if ( isAlive( e_spider ) && IS_TRUE( e_spider.b_is_spider ) )
					e_spider spider_web_door_engage( self );
				
				self spider_webs_cleanup_trapped_ai();
				level util::waittill_any_ents( level, "end_of_round", level, "between_round_over", level, "start_of_round", self, "death", level, "enable_all_webs" );
			}
			else
				wait 3;
			
		}
	}
}

function spider_web_door_engage( e_dest )
{
	self endon( "death" );
	e_scene_model = util::spawn_model( "tag_origin", self.origin, self.angles );
	e_scene_model thread scene::play( "scene_zm_dlc2_spider_web_engage", self );
	self waittill( "web" );
	self spit_projectile( e_dest );
}

function spit_projectile( e_dest )
{
	v_origin = self gettagorigin( "head_1" );
	v_angles = self gettagangles( "head_1" );
	e_spit_fx_model = util::spawn_model( "tag_origin", v_origin, v_angles );
	e_spit_fx_model thread fx::play( "spider_web_spit_reweb", v_origin, v_angles, "movedone", 1 );
	e_spit_fx_model moveto( e_dest.origin, .5 );
	e_spit_fx_model waittill( "movedone" );
	e_spit_fx_model delete();
}

function set_webbed_state( b_on = 1, n_transition_fade = .5 )
{
	if ( b_on )
	{
		if ( isDefined( self.s_spider_web_fx ) )
			self.e_web_model thread fx::play( "spider_web_doorbuy_reweb", self.s_spider_web_fx.origin, self.s_spider_web_fx.angles );
		
		self spider_web_create_webtear_trigger();
		self.e_web_model show();
		self.e_web_model solid();
		self.e_web_model clientfield::set( "web_fade_material", n_transition_fade );
		self.b_web_on = 1;
		self thread spider_web_door_watch_for_grenade_stuck();
	}
	else
	{
		self.b_web_on = 0;
		self.n_ai_stuck_to_web = 0;
		self.e_web_model clientfield::set( "web_fade_material", 0 );
		self.e_web_model notsolid();
		self.e_web_model hide();
		zm_unitrigger::unregister_unitrigger( self.s_unitrigger );
	}
}

function spider_webs_cleanup_trapped_ai()
{
	self endon( "death" );
	if ( isDefined( self.script_noteworthy ) )
	{
		a_zones = [];
		a_zones = strTok( self.script_noteworthy, " " );
	}
	else
		return;
	
	self set_webbed_state( 1 );
	a_zones_to_check = [];
	foreach ( str_zone in a_zones )
	{
		e_zone = level.zones[ str_zone ];
		
		if ( !is_in_valid_zone( str_zone ) )
		{
			e_zone.is_spawning_allowed = 0;
			e_zone thread add_zombie_to_respawn_queue();
			if ( !isDefined( a_zones_to_check ) )
				a_zones_to_check = [];
			else if ( !isArray( a_zones_to_check ) )
				a_zones_to_check = array( a_zones_to_check );
			
			a_zones_to_check[ a_zones_to_check.size ] = e_zone;
			a_zombies = zombie_utility::get_zombie_array();
			foreach ( ai_zombie in a_zombies )
			{
				if ( ai_zombie zm_zonemgr::entity_in_zone( str_zone ) )
					ai_zombie.b_immune_to_web_stick = 1;
				
			}
		}
	}
	self waittill( "web_torn" );
	foreach ( e_zone in a_zones_to_check )
	{
		e_zone.is_spawning_allowed = 1;
		e_zone notify( "web_torn" );
	}
	self set_webbed_state( 0 );
}

function add_zombie_to_respawn_queue()
{
	self endon( "web_torn" );
	str_zone = self.volumes[ 0 ].targetname;
	while ( !( isDefined( is_in_valid_zone( str_zone ) ) && is_in_valid_zone( str_zone ) ) )
		wait 1;
	
	self.is_spawning_allowed = 1;
}

function is_in_valid_zone( str_zone )
{
	e_zone = level.zones[ str_zone ];
	for ( i = 0; i < e_zone.volumes.size; i++ )
	{
		foreach ( player in level.players )
		{
			if ( zm_utility::is_player_valid( player, 0, 0 ) && player isTouching( e_zone.volumes[ i ] ) )
				return 1;
			
		}
	}
	return 0;
}

function spider_webtear_door_think()
{
	self endon( "web_torn" );
	self thread spider_ai_web_door_think();
	while ( true )
	{
		self waittill( "trigger", e_who );
		if ( !IS_TRUE( e_who.b_is_spider ) && !IS_TRUE( e_who.b_stuck_to_web ) && isAi( e_who ) )
			self.n_ai_stuck_to_web++;
		else if ( IS_TRUE( e_who.b_is_spider ) && !IS_TRUE( e_who.b_spider_is_traversing_web ) )
			e_who thread spider_burrow_through_web( self );
		
	}
}

function spider_ai_web_door_think()
{
	self endon( "web_torn" );
	e_door_web_trigger = spawn( "trigger_radius", self.origin, 1, 50, 50 );
	e_door_web_trigger endon( "death" );
	self thread spider_web_delete_on_tear( e_door_web_trigger );
	self.b_is_checking_for_stuck_zombie = 0;
	while ( 1 )
	{
		e_door_web_trigger waittill( "trigger", e_who );
		if ( e_who.archetype === "thrasher" )
		{
			self thread do_webtear_effects( 1 );
			self notify( "web_torn" );
		}
		else if ( e_who.archetype === "zombie" && !IS_TRUE( e_who.b_stuck_to_web ) )
		{
			e_who thread zombie_stick_to_web( self );
			if ( !self.b_is_checking_for_stuck_zombie )
			{
				self.b_is_checking_for_stuck_zombie = 1;
				self thread tear_if_zombie_stuck_after_a_minute( e_door_web_trigger );
				self thread spider_web_wobble( 4, .125 );
			}
		}
	}
}

function tear_if_zombie_stuck_after_a_minute( e_door_web_trigger )
{
	self endon( "web_torn" );
	wait 60;
	foreach ( ai_zombie in getAiTeamArray( level.zombie_team ) )
	{
		if ( ai_zombie isTouching( e_door_web_trigger ) )
		{
			self.b_is_checking_for_stuck_zombie = 0;
			self thread do_webtear_effects( 1 );
			self notify( "web_torn" );
		}
	}
	self.b_is_checking_for_stuck_zombie = 0;
}

function zombie_stick_to_web( e_door_web_trigger )
{
	self endon( "death" );
	self.b_stuck_to_web = 1;
	if ( e_door_web_trigger.n_ai_stuck_to_web > 5 )
		self.b_immune_to_web_stick = 1;
	else
		self thread set_immune_to_web_for_time();
	
	self asmSetAnimationRate( 0.1 );
	self ai::set_ignoreall( 1 );
	e_door_web_trigger waittill( "web_torn" );
	self asmSetAnimationRate( 1 );
	self ai::set_ignoreall( 0 );
	self notify( "zombie_freed_from_web" );
	self.b_stuck_to_web = 0;
	self.b_immune_to_web_stick = 0;
}

function spider_web_delete_on_tear( e_door_web_trigger )
{
	self waittill( "web_torn" );
	if ( isDefined( e_door_web_trigger ) )
		e_door_web_trigger delete();
	
}

function spider_burrow_through_web( e_door_web_trigger )
{
	self endon( "death" );
	e_door_web_trigger endon( "death" );
	self.b_spider_is_traversing_web = 1;
	self fx::play( "spider_web_spider_enter", self.origin, self.angles, "stop_spider_web_enter", 0, "tag_body" );
	e_door_web_trigger thread spider_web_wobble( 1 );
	while ( 1 )
	{
		WAIT_SERVER_FRAME
		if ( self isTouching( e_door_web_trigger ) && IS_TRUE( e_door_web_trigger.b_web_on ) )
			continue;
		else
		{
			self.b_spider_is_traversing_web = 0;
			self notify( "stop_spider_web_enter" );
			self fx::play( "spider_web_spider_leave", self.origin, self.angles, 2, 0, "tag_body" );
			break;
		}
	}
}

function spider_web_wobble( n_interations = 4, n_move_speed = .25 )
{
	self endon( "death" );
	if ( !isDefined( self.e_web_model ) )
		return;
	
	if ( !IS_TRUE( self.b_spiderweb_is_wobbling ) )
	{
		self.b_spiderweb_is_wobbling = 1;
		v_original_pos = self.e_web_model.origin;
		for ( i = 0; i < n_interations; i++ )
		{
			v_wobble_pos = ( randomFloatRange( 0, 2 ), randomFloatRange( 0, 2 ), 0 );
			self.e_web_model moveto( v_original_pos + v_wobble_pos, n_move_speed );
			self.e_web_model waittill( "movedone" );
			self.e_web_model moveto( v_original_pos, n_move_speed );
			self.e_web_model waittill( "movedone" );
		}
		self.b_spiderweb_is_wobbling = 0;
	}
}

function set_widows_cocoon_fx()
{
	self waittill( "death" );
	if ( isDefined( self ) )
	{
		if ( self clientfield::get( "widows_wine_wrapping" ) )
			self clientfield::set( "widows_wine_wrapping", 0 );
		
	}
}

function set_immune_to_web_for_time( n_delay_timer = 5 )
{
	self endon( "death" );
	self endon( "zombie_freed_from_web" );
	self.b_immune_to_web_stick = 0;
	wait n_delay_timer;
	self.b_immune_to_web_stick = 1;
}

function spider_web_prompt_and_visiblity_func( player )
{
	if ( !player zm_utility::is_player_looking_at( self.origin, .4, 0 ) || !player zm_magicbox::can_buy_weapon() )
	{
		self setHintString( "" );
		return 0;
	}
	self setHintString( "Hold ^3&&1^7 to tear off Webs" );
	return 1;
}

function spider_web_should_ignore_sight_checks()
{
	if ( !isDefined( level.a_spider_webs ) )
		return 0;
	
	b_ignore_sight = 0;
	foreach ( e_door_web_trigger in level.a_spider_webs )
	{
		if ( !IS_TRUE( e_door_web_trigger.b_web_on ) )
			continue;
		
		foreach ( player in level.players )
		{
			if ( player == self )
				continue;
			
			if ( isDefined( player.revivetrigger ) && self isTouching( player.revivetrigger ) && self util::is_player_looking_at( player.revivetrigger.origin, .6, 0 ) && distance2dSquared( self.origin, e_door_web_trigger.origin ) < 14400 )
			{
				b_ignore_sight = 1;
				break;
			}
		}
		if ( b_ignore_sight )
			break;
		
	}
	return b_ignore_sight;
}

function spider_web_unitrigger_think()
{
	e_web_trigger = self.stub.e_web_trigger;
	e_web_trigger endon( "web_torn" );
	while ( 1 )
	{
		self waittill( "trigger", e_who );
		e_who.e_using_web_trigger = self.stub.e_web_trigger;
		
		if ( e_who zm_laststand::is_reviving_any() )
			continue;
		
		if ( e_who.is_drinking > 0 )
			continue;
		
		if ( !e_who zm_magicbox::can_buy_weapon() )
			continue;
		
		if ( !zm_utility::is_player_valid( e_who ) )
			continue;
		
		else
			e_who notify( "tearing_web" );
		
		if ( isDefined( self.related_parent ) )
			self.related_parent notify( "trigger_activated", e_who );
		
		if ( !isDefined( e_who.usebar ) )
		{
			if ( isDefined( level.ptr_do_web_tear_cb ) )
				self thread [ [ level.ptr_do_web_tear_cb ] ]( e_who );
			else
				self thread complete_webtear();
			
			e_web_trigger thread do_webtear_effects();
			str_notify = self util::waittill_any_ex( "webtear_succeed", "webtear_failed", "kill_trigger", e_web_trigger, "web_torn" );
			if ( str_notify == "webtear_succeed" )
			{
				e_who.b_web_tear_done = 1;
				e_who player_award_webtear_points();
				e_web_trigger thread do_webtear_effects( 1 );
				e_web_trigger notify( "web_torn" );
				break;
			}
			else
				e_web_trigger thread do_webtear_effects( 1 );
			
		}
	}
}

function complete_webtear()
{
	wait .25;
	self notify( "webtear_succeed" );
}

function spider_webs_grenade_watcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "grenade_fire", e_grenade, weapon );
		e_grenade thread spider_webs_grenade_impact_think( weapon, self );
	}
}

function spider_webs_grenade_launcher_watcher()
{
	self endon( "death" );
	while ( true )
	{
		self waittill( "grenade_launcher_fire", e_grenade, weapon );
		e_grenade thread spider_webs_grenade_impact_think( weapon, self );
	}
}

function spider_webs_missile_watcher()
{
	self endon( "death" );
	while ( true )
	{
		self waittill( "missile_fire", e_projectile, weapon );
		e_projectile thread spider_webs_missile_impact_think( weapon, self );
	}
}

function spider_webs_grenade_impact_think( weapon, player )
{
	self endon( "death" );
	if ( !isDefined( level.a_spider_webs ) )
		return;
	
	if ( weapon === getWeapon( "sticky_grenade_widows_wine" ) )
	{
		self waittill( "stationary" );
		e_grenade = self.origin;
		v_normal = ( 0, 0, 0 );
	}
	else
	{
		self waittill( "grenade_bounce", e_grenade, v_normal, hitent, str_surface );
	}
	
	foreach ( trigger in level.a_spider_webs )
	{
		if ( !IS_TRUE( trigger.b_web_on ) )
			continue;
		
		if ( self isTouching( trigger ) || trigger.e_web_model === hitent && distance2dSquared( trigger.origin, e_grenade ) < 2500 )
		{
			self thread spider_web_stick_grenade( trigger, weapon, e_grenade, v_normal, player );
			return;
		}
	}
	self thread grenade_stick_to_webs_think( player );
}

function grenade_stick_to_webs_think( player )
{
	v_impact_org = self.origin;
	self waittill( "death" );
	foreach ( trigger in level.a_spider_webs )
	{
		if ( !IS_TRUE( trigger.b_web_on ) || IS_TRUE( trigger.b_grenade_stuck ) )
			continue;
		
		if ( distance2dSquared( trigger.origin, v_impact_org ) < 2500 )
		{
			player.b_web_tear_with_grenade_done = 1;
			trigger thread do_webtear_effects( 1, v_impact_org, undefined, 1 );
			trigger notify( "web_torn" );
			player player_award_webtear_points( 1, 1 );
			return;
		}
	}
}

function spider_web_door_watch_for_grenade_stuck()
{
	self endon( "death" );
	self endon( "web_torn" );
	while ( true )
	{
		self.e_web_model waittill( "grenade_stuck", e_grenade );
	}
}

function spider_webs_missile_impact_think( weapon, player )
{
	if ( !isDefined( level.a_spider_webs ) || weapon == getWeapon( "skull_gun" ) )
		return;
	
	self waittill( "death" );
	if ( isDefined( self ) && isDefined( self.origin ) )
		v_imapact_origin = self.origin;
	else
		return;
	
	foreach ( trigger in level.a_spider_webs )
	{
		if ( !IS_TRUE( trigger.b_web_on ) || IS_TRUE( trigger.b_grenade_stuck ) )
			continue;
		
		if ( distance2dSquared( trigger.origin, v_imapact_origin ) < 10000 )
		{
			if ( weapon == getWeapon( "launcher_standard" ) || weapon == getWeapon( "launcher_standard_upgraded" ) )
				player.b_web_tear_with_launcher_done = 1;
			else if ( weapon == getWeapon( "ray_gun" ) || weapon == getWeapon( "ray_gun_upgraded" ) )
				player.b_web_tear_with_raygun_done = 1;
			
			trigger thread do_webtear_effects( 1, v_imapact_origin, undefined, 1 );
			trigger notify( "web_torn" );
			player player_award_webtear_points( 1, 1 );
			return;
		}
	}
}

function spider_web_stick_grenade( trigger, weapon, e_grenade, v_normal, player )
{
	trigger endon( "death" );
	trigger endon( "web_torn" );
	player endon( "death" );
	
	if ( weapon == getWeapon( "frag_grenade" ) )
		e_sticky_grenade = player magicGrenadeManualPlayer( e_grenade - v_normal, ( 0, 0, 0 ), getWeapon( "frag_grenade_web" ), weapon.fusetime / 1000 );
	else if ( weapon == getWeapon( "bouncingbetty" ) )
		e_sticky_grenade = player magicGrenadeManualPlayer( e_grenade - _normal, ( 0, 0, 0 ), getWeapon( "bouncingbetty_web" ), weapon.fusetime / 1000 );
	else if ( weapon == getWeapon( "sticky_grenade_widows_wine" ) )
		e_sticky_grenade = self;
	else
		return;
	
	e_sticky_grenade.angles = self.angles;
	if ( e_sticky_grenade != self )
		self delete();
	
	trigger thread delete_grenade_on_tear( e_sticky_grenade );
	e_sticky_grenade clientfield::set( "play_grenade_stuck_in_web_fx", 1 );
	e_sticky_grenade waittill( "death" );
	if ( !IS_TRUE( trigger.b_grenade_stuck ) )
	{
		player.b_web_tear_with_grenade_done = 1;
		trigger thread do_webtear_effects( 1, e_grenade - v_normal, undefined, 1 );
		player player_award_webtear_points( 1, 1 );
		trigger notify( "web_torn" );
	}
}

function delete_grenade_on_tear( e_sticky_grenade )
{
	e_sticky_grenade endon( "death" );
	self waittill( "web_torn" );
	e_sticky_grenade delete();
}

function do_webtear_effects( b_destroyed = 0, v_origin, v_angles, b_is_explosive = 0 )
{
	if ( !isDefined( self.s_spider_web_fx ) )
		return;
	
	if ( isDefined( v_origin ) )
		v_fx_org = v_origin;
	else
		v_fx_org = self.s_spider_web_fx.origin;
	
	if ( isDefined( v_angles ) )
		v_fx_ang = v_angles;
	else
		v_fx_ang = self.s_spider_web_fx.angles;
	
	if ( !isDefined( self.e_webtear_fx_model ) && !b_destroyed )
	{
		self.e_webtear_fx_model = util::spawn_model( "tag_origin", v_fx_org, v_fx_ang );
		self.e_webtear_fx_model set_webtear_fx( 1, self.s_spider_web_fx.script_string );
	}
	else if ( !isDefined( self.e_webtear_fx_model ) && b_destroyed )
	{
		self.e_webtear_fx_model = util::spawn_model( "tag_origin", v_fx_org, v_fx_ang );
		if ( b_is_explosive )
			self.e_webtear_fx_model set_webtear_fx( 1, "spider_web_particle_explosive", 1 );
		else
			self.e_webtear_fx_model set_webtear_fx( 1, self.s_spider_web_fx.script_string, 1 );
		
		util::wait_network_frame();
		if ( isDefined( self.e_webtear_fx_model ) )
			self.e_webtear_fx_model delete();
		
	}
	else
	{
		self.e_webtear_fx_model set_webtear_fx( 0 );
		if ( b_destroyed )
			self.e_webtear_fx_model set_webtear_fx( 1, self.s_spider_web_fx.script_string, 1 );
		
		util::wait_network_frame();
		if ( isDefined( self.e_webtear_fx_model ) )
			self.e_webtear_fx_model delete();
		
	}
}

function set_webtear_fx( b_stop_fx = 1, str_type, b_completed = 0 )
{
	if ( !b_stop_fx )
	{
		self clientfield::set( "play_spider_web_tear_fx", 0 );
		return;
	}
	switch ( str_type )
	{
		case "spider_web_particle_bgb":
		{
			if ( !b_completed )
				self clientfield::set( "play_spider_web_tear_fx", 1 );
			else
				self clientfield::set( "play_spider_web_tear_complete_fx", 1 );
			
			break;
		}
		case "spider_web_particle_perk_machine":
		{
			if ( !b_completed )
				self clientfield::set( "play_spider_web_tear_fx", 2 );
			else
				self clientfield::set( "play_spider_web_tear_complete_fx", 2 );
			
			break;
		}
		case "spider_web_particle_doorbuy":
		{
			if ( !b_completed )
				self clientfield::set( "play_spider_web_tear_fx", 3 );
			else
				self clientfield::set( "play_spider_web_tear_complete_fx", 3 );
			
			break;
		}
		case "spider_web_particle_explosive":
		{
			self clientfield::set( "play_spider_web_tear_complete_fx", 4 );
			break;
		}
		default:
		{
			if ( !b_completed )
				self clientfield::set( "play_spider_web_tear_fx", 2 );
			else
				self clientfield::set( "play_spider_web_tear_complete_fx", 2 );
			
			break;
		}
	}
}

function spider_score_round_cap_reset()
{
	self endon( "death" );
	self.spider_score_this_round = 0;
	while ( 1 )
	{
		level waittill( "end_of_round" );
		self.spider_score_this_round = 0;
	}
}

function player_award_webtear_points( n_multiplier = 1, b_grenade = 0 )
{
	self endon( "death" );
	if ( self.spider_score_this_round < 100 )
	{
		n_webtear_points = ( 10 * n_multiplier ) * zm_score::get_points_multiplier( self );
		self zm_score::add_to_player_score( n_webtear_points );
		self.spider_score_this_round = self.spider_score_this_round + n_webtear_points;
	}
	
	self notify( "spider_web_destroyed" );
	
	if ( b_grenade )
		self notify( "spider_web_grenade_destroyed" );
	
	if ( self.b_web_tear_done && self.b_web_tear_perk_done && self.b_web_tear_with_launcher_done && self.b_web_tear_with_grenade_done && self.b_web_tear_with_raygun_done && self.b_web_tear_with_mirg_done )
		self notify( "spider_web_destroyed_no_knife" );
	
}

function can_be_webbed( v_web_origin )
{
	if ( level.round_number === 1 )
		return 1;
	
	if ( zm_utility::check_point_in_enabled_zone( v_web_origin, 1 ) )
	{
		foreach ( player in level.players )
		{
			if ( distanceSquared( player.origin, v_web_origin ) < 640000 )
				return 0;
			
			if ( player util::is_player_looking_at( v_web_origin, 0.5, 0 ) && distanceSquared( player.origin, v_web_origin ) < 1440000 )
				return 0;
			
		}
		return 1;
	}
	return 0;
}

function spider_web_perks_init()
{
	level.a_perk_triggers = getEntArray( "zombie_vending", "targetname" );
	spider_web_perks_setup();
	level.ptr_do_web_tear_cb = &do_spider_web_tear;
	set_spider_web_perk_models();
}

function set_spider_web_perk_models()
{
	foreach ( e_perk_web in level.a_perk_webs )
	{
		t_perk = arrayGetClosest( e_perk_web.origin, level.a_perk_triggers );
		
		switch ( t_perk.script_noteworthy )
		{
			case "specialty_doubletap2":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_doubletap2");
				break;
			}
			case "specialty_quickrevive":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_revive");
				break;
			}
			case "specialty_fastreload":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_sleight");
				break;
			}
			case "specialty_staminup":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_marathon");
				break;
			}
			case "specialty_armorvest":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_jugg");
				break;
			}
			case "specialty_additionalprimaryweapon":
			{
				e_perk_web.e_destructible setModel("p7_zm_isl_web_vending_three_gun");
				break;
			}
			default:
				break;
			
		}
		e_perk_web.e_destructible.origin = t_perk.machine.origin;
		e_perk_web.e_destructible.angles = t_perk.machine.angles;
	}
}

function spider_web_perks_setup()
{
	level.a_perk_webs = [];
	a_structs = struct::get_array( "web_perk_structs", "script_noteworthy" );
	for ( i = 0; i < a_structs.size; i++ )
	{
		level.a_perk_webs[ i ] = a_structs[ i ];
		level.a_perk_webs[ i ].t_webbing_extra_damage = getEnt( level.a_perk_webs[ i ].target, "targetname" );
		level.a_perk_webs[ i ].e_destructible = getEnt( level.a_perk_webs[ i ].t_webbing_extra_damage.target, "targetname" );
		
		level.a_perk_webs[ i ].e_destructible.v_destructible_origin = level.a_perk_webs[ i ].e_destructible.origin;
		level.a_perk_webs[ i ].e_destructible.v_destructible_angles = level.a_perk_webs[ i ].e_destructible.angles;
		level.a_perk_webs[ i ].e_destructible.v_off_pos = level.a_perk_webs[ i ].e_destructible.v_destructible_origin - vectorScale( ( 0, 0, 1 ), 256 );
		
		level.a_perk_webs[ i ].e_destructible setCanDamage( 1 );
		level.a_perk_webs[ i ].e_destructible clientfield::set( "web_fade_material", .5 );
		
		if ( isDefined( level.a_perk_webs[ i ].t_webbing_extra_damage ) )
		{
			t_webbing_extra_damage = level.a_perk_webs[ i ].t_webbing_extra_damage;
			t_webbing_extra_damage.e_destructible = level.a_perk_webs[ i ].e_destructible;
			t_webbing_extra_damage.s_spider_web_fx = struct::get( t_webbing_extra_damage.target, "targetname" );
			t_webbing_extra_damage.b_web_on = 1;
			t_webbing_extra_damage.n_perk_web_index = i;
			t_webbing_extra_damage thread spider_web_perks_think();
		}
		level.a_perk_webs[ i ] set_perk_active_state( 0 );
		level.a_perk_webs[ i ] spider_web_create_webtear_perk_trigger();
		level.a_perk_webs[ i ].n_perk_web_index = i;
		level.a_perk_webs[ i ].e_destructible.n_perk_web_index = i;
		level.a_perk_webs[ i ].s_unitrigger.n_perk_web_index = i;
	}
}

function spider_web_perks_think()
{
	self endon( "death" );
	while ( !isDefined( level.a_spider_webs ) )
		wait 1;
	
	array::add( level.a_spider_webs, self );
	while ( 1 )
	{
		self waittill( "web_torn" );
		if ( self.b_web_on )
			level.a_perk_webs[ self.n_perk_web_index ] thread spider_web_perks_on_spider_rounds();
		
	}
}

function spider_web_create_webtear_perk_trigger()
{
	if ( !isDefined( self.s_unitrigger ) )
		s_unitrigger = spawnStruct();
	else
		s_unitrigger = self.s_unitrigger;
	
	s_unitrigger.origin = self.origin;
	s_unitrigger.angles = self.angles;
	s_unitrigger.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger.cursor_hint = "HINT_NOICON";
	s_unitrigger.require_look_at = 0;
	s_unitrigger.e_web_trigger = self.t_webbing_extra_damage;
	s_unitrigger.related_parent = self;
	s_unitrigger.script_width = 130;
	s_unitrigger.script_length = 130;
	s_unitrigger.script_height = 100;
	s_unitrigger.prompt_and_visibility_func = &spider_web_prompt_and_visiblity_func;
	self.s_unitrigger = s_unitrigger;
	self.s_unitrigger.n_perk_web_index = self.n_perk_web_index;
	self.b_occupied = 0;
	self.b_destroyed = 0;
	self.n_hits = 0;
	zm_unitrigger::register_static_unitrigger( self.s_unitrigger, &spider_web_unitrigger_think );
}

function set_perk_active_state( b_enable )
{
	a_perk_triggers = getEntArray( "zombie_vending", "targetname" );
	t_perk = arrayGetClosest( self.origin, a_perk_triggers );
	t_perk triggerEnable( b_enable );
}

function spider_web_perks_on_spider_rounds( e_player )
{
	self deactivate_perk_spider_web( e_player );
	level waittill( "enable_spider_round_webs" );
	do
	{
		b_do_web_perks = can_be_webbed( self.origin );
		wait 2;
	}
	while ( !IS_TRUE( b_do_web_perks ) );
	self activate_perk_spider_web();
}

function activate_perk_spider_web()
{
	if ( isDefined( self.t_webbing_extra_damage.s_spider_web_fx ) )
	{
		v_fx_org = self.t_webbing_extra_damage.s_spider_web_fx.origin;
		v_fx_ang = self.t_webbing_extra_damage.s_spider_web_fx.angles;
		self.t_webbing_extra_damage thread fx::play( "spider_web_perk_machine_reweb", v_fx_org, v_fx_org );
	}
	self.e_destructible show();
	self.e_destructible solid();
	self.t_webbing_extra_damage.b_web_on = 1;
	zm_unitrigger::register_static_unitrigger( self.s_unitrigger, &spider_web_unitrigger_think );
	self set_perk_active_state( 0 );
}

function deactivate_perk_spider_web( e_player )
{
	zm_unitrigger::unregister_unitrigger( self.s_unitrigger );
	self.e_destructible notSolid();
	self.e_destructible hide();
	self.t_webbing_extra_damage notify( "web_torn" );
	self.t_webbing_extra_damage.b_web_on = 0;
	if ( zm_utility::is_player_valid( e_player ) )
		e_player player_award_webtear_points();
	
	self set_perk_active_state( 1 );
}

function do_spider_web_tear( e_who )
{
	self thread do_spider_web_tear_fx( e_who );
	self thread do_spider_web_tear_animation( e_who );
}

function do_spider_web_tear_fx( player )
{
	self endon( "kill_trigger" );
	self endon( "webtear_succeed" );
	self endon( "webtear_failed" );
	self endon( "webtear_over" );
	while ( 1 )
	{
		playFx( level._effect[ "building_dust" ], player getPlayerCameraPos(), player.angles );
		wait .5;
	}
}

function do_spider_web_tear_animation( player, webtear_time = 2 )
{
	e_web_trigger = self.stub.e_web_trigger;
	wait .01;
	if ( !isDefined( self ) )
	{
		if ( isDefined( e_web_trigger.e_webtear_fx_model ) )
			e_web_trigger.e_webtear_fx_model set_webtear_fx( 0 );
		
		return;
	}
	w_bowie_knife = getWeapon( "bowie_knife" );
	w_widows_wine_bowie_knife = getWeapon( "bowie_knife_widows_wine" );
	b_has_bowie_knife = player hasWeapon( w_bowie_knife ) || player hasWeapon( w_widows_wine_bowie_knife );
	if ( b_has_bowie_knife )
		webtear_time = webtear_time / 2;
	
	webtear_time = int( webtear_time * 1000 );
	self.webtear_time = webtear_time;
	self.webtear_length = self.webtear_time;
	self.webtear_start_time = getTime();
	webtear_length = self.webtear_length;
	webtear_start_time = self.webtear_start_time;
	webtear_end_time = self.webtear_start_time + self.webtear_length;
	if ( webtear_length > 0 )
	{
		player zm_utility::disable_player_move_states( 1 );
		player zm_utility::increment_is_drinking();
		w_prev_weapon = player getCurrentWeapon();
		w_zombie_spider_web_tear = getWeapon( "zombie_spider_web_tear" );
		player giveWeapon( w_zombie_spider_web_tear );
		util::wait_network_frame();
		player switchToWeapon( w_zombie_spider_web_tear );
		player thread spider_webtear_use_bar_think( webtear_start_time, webtear_length );
		while ( isDefined( self ) && player player_is_webtear_valid( self ) && getTime() < webtear_end_time )
			WAIT_SERVER_FRAME;
		
		player notify( "webtear_over" );
		if ( isDefined( w_prev_weapon ) )
			player switchToWeapon( w_prev_weapon );
		
		if ( isDefined( w_zombie_spider_web_tear ) )
			player takeWeapon( w_zombie_spider_web_tear );
		
		if ( IS_DRINKING( player.is_drinking ) )
			player zm_utility::decrement_is_drinking();
		
		player zm_utility::enable_player_move_states();
	}
	if ( isDefined( player.usebartext ) )
		player.usebartext hud::destroyelem();
	
	if ( isDefined( player.usebar ) )
		player.usebar hud::destroyelem();
	
	if ( isDefined( self ) && player player_is_webtear_valid( self ) && ( self.webtear_time <= 0 || getTime() >= webtear_end_time ) )
	{
		self notify( "webtear_succeed" );
		if ( b_has_bowie_knife )
			player.b_web_tear_perk_done = 1;
		
		return;
	}
	
	if ( isDefined( self ) )
		self notify( "webtear_failed" );
	else if ( isDefined( e_web_trigger.e_webtear_fx_model ) )
		e_web_trigger.e_webtear_fx_model set_webtear_fx( 0 );
	
}

function player_is_webtear_valid( s_unitrigger )
{
	if ( self laststand::player_is_in_laststand() || self zm_laststand::is_reviving_any() )
		return 0;
	
	if ( !self useButtonPressed() )
		return 0;
	
	if ( !self zm_utility::is_player_looking_at( self.e_using_web_trigger.e_destructible.origin, .4, 0 ) )
		return 0;
	
	if ( isDefined( s_unitrigger.stub.origin ) && isDefined( s_unitrigger.stub.radius ) )
	{
		if ( distance( self.origin, s_unitrigger.stub.origin ) > s_unitrigger.stub.radius )
			return 0;
		
	}
	return 1;
}

function spider_webtear_use_bar_think( start_time, craft_time )
{
	if ( isDefined( self.usebartext ) )
		self.usebartext hud::destroyelem();
	
	if ( isDefined( self.usebar ) )
		self.usebar hud::destroyelem();
	
	self.usebar = self hud::createprimaryprogressbar();
	self.usebartext = self hud::createprimaryprogressbartext();
	self.usebartext setText( "Slashing..." );
	if ( isDefined( self ) && isDefined( start_time ) && isDefined( craft_time ) )
		self spider_webtear_use_bar_update( start_time, craft_time );
	
	if ( isDefined( self.usebartext ) )
		self.usebartext hud::destroyelem();
	
	if ( isDefined( self.usebar ) )
		self.usebar hud::destroyelem();
	
}

function spider_webtear_use_bar_update( n_start_time, n_length )
{
	self endon( "entering_last_stand" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "webtear_over" );
	while ( isDefined( self ) && ( getTime() - n_start_time ) < n_length )
	{
		n_progress = ( getTime() - n_start_time ) / n_length;
		if ( n_progress < 0 )
			n_progress = 0;
		
		if ( n_progress > 1 )
			n_progress = 1;
		
		self.usebar hud::updatebar( n_progress );
		WAIT_SERVER_FRAME;
	}
}