#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\raz; 
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_raz.gsh;

#namespace zm_ai_raz;

REGISTER_SYSTEM_EX( "zm_ai_raz", &__init__, &__main__, undefined )

function __init__()
{
	zm::register_player_damage_callback( &raz_player_damage_callback );
	level.b_raz_enabled = 1;
	level.b_raz_rounds_enabled = 0;
	level.n_raz_round_count = 1;
	level.razround_nomusic = 0;
	level.raz_spawners = [];
	level.n_raz_health = RAZ_BASE_HEALTH;
	zm_score::register_score_event( "death_raz", &raz_death_score_event );
	level flag::init( "raz_round" );
	level flag::init( "raz_round_in_progress" );
	level thread AAT::register_immunity( "zm_aat_blast_furnace", "raz", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_dead_wire", "raz", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_fire_works", "raz", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_thunder_wall", "raz", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_turned", "raz", 1, 1, 1 );
	raz_spawner_init();
	level thread raz_increase_health_every_round();
	
	level.b_raz_debug 																= RAZ_ZOMBIE_DEBUG;
	level.n_raz_debug_spawn_delay 											= RAZ_ZOMBIE_DEBUG_SPAWN_DELAY;
}

function __main__()
{
	level thread raz_zombie_debug_spawn_logic();
}

function raz_zombie_debug_spawn_logic()
{
	level flag::wait_till( "initial_blackscreen_passed" );
	while ( 1 )
	{
		if ( IS_TRUE( level.b_raz_debug ) )
		{
			special_raz_spawn();
			wait level.n_raz_debug_spawn_delay;
			continue;
		}
		WAIT_SERVER_FRAME;
	}
}

function raz_death_score_event( str_event, str_mod, str_hit_location, str_zombie_team, w_damage_weapon )
{
	if ( str_event === "death_raz" )
	{
		n_points = zm_score::get_zombie_death_player_points();
		n_points_multiplier = self zm_score::player_add_points_kill_bonus( str_mod, str_hit_location, w_damage_weapon );
		n_points = ( n_points + n_points_multiplier ) * 2;
		if ( str_mod == "MOD_GRENADE" || str_mod == "MOD_GRENADE_SPLASH" )
		{
			self zm_stats::increment_client_stat( "grenade_kills" );
			self zm_stats::increment_player_stat( "grenade_kills" );
		}
		scoreevents::processScoreEvent( "kill_raz", self, undefined, w_damage_weapon );
		return n_points;
	}
	return 0;
}

function enable_raz_rounds()
{
	level.b_raz_rounds_enabled = 1;
	if ( !isDefined( level.raz_round_track_override ) )
		level.raz_round_track_override = &raz_round_tracker;
	
	level thread [ [ level.raz_round_track_override ] ]();
}

function raz_spawner_init()
{
	level.raz_spawners = getEntArray( "zombie_raz_spawner", "script_noteworthy" );
	if ( level.raz_spawners.size == 0 )
		return;
	
	foreach( e_raz_spawner in level.raz_spawners )
	{
		e_raz_spawner.is_enabled = 1;
		e_raz_spawner.script_forcespawn = 1;
		e_raz_spawner spawner::add_spawn_function( &raz_init );
	}
}

function raz_increase_health_every_round()
{
	while ( 1 )
	{
		level waittill( "between_round_over" );
		raz_health_increase();
	}
}

function raz_round_tracker()
{
	level.n_raz_round_count = 1;
	level.n_next_raz_round = level.round_number + randomIntRange( RAZ_MIN_START_ROUND, RAZ_MAX_START_ROUND );
	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( isDefined( level.b_delay_raz_round ) && level.round_number == level.b_delay_raz_round )
		{
			level.n_next_raz_round = level.n_next_raz_round + 1;
			continue;
		}
		if ( level.round_number == level.n_next_raz_round )
		{
			level.n_next_raz_round = level.n_next_raz_round + randomIntRange( RAZ_MIN_NEXT_ROUND, RAZ_MAX_NEXT_ROUND );
			level thread raz_round_spawning();
			level flag::set( "raz_round" );
			level waittill( "end_of_round" );
			level flag::clear( "raz_round" );
			level.n_raz_round_count++;
		}
	}
}

function raz_round_spawning()
{
	level endon( "end_of_round" );
	a_zombies = [];
	while ( 1 )
	{
		a_zombies = zombie_utility::get_zombie_array();
		if ( a_zombies.size >= 4 )
			break;
		
		wait .5;
	}
	switch ( level.players.size )
	{
		case 1:
		{
			n_razs_to_spawn = RAZ_PER_ROUND_1P;
			break;
		}
		case 2:
		{
			n_razs_to_spawn = RAZ_PER_ROUND_2P;
			break;
		}
		case 3:
		{
			n_razs_to_spawn = RAZ_PER_ROUND_3P;
			break;
		}
		case 4:
		{
			n_razs_to_spawn = RAZ_PER_ROUND_4P;
			break;
		}
		default:
		{
			n_razs_to_spawn = RAZ_PER_ROUND_1P;
			break;
		}
	}
	for ( i = 0; i < n_razs_to_spawn; i++ )
	{
		spawn_raz();
		waiting_for_next_raz_spawn();
	}
}

/*
function raz_round_tracker()
{
	level.n_raz_round_count = 1;
	level.n_next_raz_round = randomIntRange( RAZ_MIN_NEXT_ROUND, RAZ_MAX_NEXT_ROUND );
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( level.round_number == level.n_next_raz_round )
		{
			level.sndMusicSpecialRound = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			raz_round_start();
			level.round_spawn_func = &raz_round_spawning;
			level.round_wait_func = &raz_round_wait_func;
			
			if ( isDefined( level.zm_custom_get_next_raz_round ) )
				level.n_next_raz_round = [ [ level.zm_custom_get_next_raz_round ] ]();
			else
				level.n_next_raz_round = level.n_next_raz_round + randomIntRange( RAZ_MIN_NEXT_ROUND, RAZ_MAX_NEXT_ROUND );
			
		}
		else if ( level flag::get( "raz_round" ) )
		{
			raz_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.n_raz_round_count++;
		}
	}
}

function raz_round_start()
{
	level flag::set( "raz_round" );
	level flag::set( "special_round" );
	level.razround_nomusic = 1;
	level notify( "raz_round_starting" );
	level thread zm_audio::sndMusicSystem_PlayState( "raz_start" );
}

function raz_round_stop()
{
	level flag::clear( "raz_round" );
	level flag::clear( "special_round" );
	level.razround_nomusic = 0;
	level notify( "raz_round_ending" );
}

function raz_round_spawning()
{
	level endon( "intermission" );
	level endon( "raz_round" );
	level.raz_targets = getPlayers();
	for ( i = 0; i < level.raz_targets.size; i++ )
		level.raz_targets[ i ].hunted_by = 0;
	
	level endon( "restart_round" );
	if ( level.intermission )
		return;
	
	array::thread_all( level.players, &play_raz_round );
	n_wave_count = get_raz_per_round_count();
	raz_health_increase();
	level.zombie_total = int( n_wave_count );
	wait 1;
	wait 6;
	n_raz_alive = 0;
	level flag::set( "raz_round_in_progress" );
	level endon( "last_ai_down" );
	level thread raz_round_aftermath();
	while ( 1 )
	{
		while ( level.zombie_total > 0 )
		{
			if ( IS_TRUE( level.bzm_worldPaused ) )
			{
				util::wait_network_frame();
				continue;
			}
			spawn_raz();
			util::wait_network_frame();
		}
		util::wait_network_frame();
	}
}
*/
function spawn_raz_zombie( spawner, s_spot )
{
	e_ai_raz = zombie_utility::spawn_zombie( level.raz_spawners[ 0 ], "raz", s_spot );
	if ( isDefined( e_ai_raz ) )
	{
		e_ai_raz.check_point_in_enabled_zone = &zm_utility::check_point_in_playable_area;
		e_ai_raz thread zombie_utility::round_spawn_failsafe();
		e_ai_raz thread raz_player_vo( s_spot );
	}
	return e_ai_raz;
}

function raz_player_vo( s_spot )
{
	if ( isDefined( level.raz_spawn_player_vo ) )
		self thread [ [ level.raz_spawn_player_vo ] ]( s_spot );
	
	if ( isDefined( level.raz_arm_detach_player_vo ) )
		self thread [ [ level.raz_arm_detach_player_vo ] ]();
	
}

function spawn_raz()
{
	while ( !can_spawn_raz() )
		wait .1;
	
	s_spawn_loc = undefined;
	e_favorite_enemy = get_favorite_enemy();
	if ( !isdefined( e_favorite_enemy ) )
	{
		wait randomFloatRange( .3333333, .6666667 );
		return;
	}
	if ( isDefined( level.raz_spawn_func ) )
		s_spawn_loc = [ [ level.raz_spawn_func ] ]( e_favorite_enemy );
	else
	{
		if ( level.zm_loc_types[ "raz_location" ].size == 0 )
			iPrintLnBold( "NO RAZ SPAWNER POINTS" );
		else
			s_spawn_loc = array::random( level.zm_loc_types[ "raz_location" ] );
	
	}
	if ( !isDefined( s_spawn_loc ) )
	{
		wait randomFloatRange( .3333333, .6666667 );
		return;
	}
	ai = spawn_raz_zombie( level.raz_spawners[ 0 ] );
	if ( isDefined( ai ) )
	{
		ai thread raz_player_vo( s_spawn_loc );
		ai forceTeleport( s_spawn_loc.origin, s_spawn_loc.angles );
		
		if ( isDefined( s_spawn_loc.script_string ) )
		{
			ai.script_string = s_spawn_loc.script_string;
			ai.find_flesh_struct_string = ai.script_string;
		}
		
		ai.sword_kill_power = 4;
        ai.heroweapon_kill_power = 4;
		
		if ( isDefined( e_favorite_enemy ) )
		{
			ai.favoriteenemy = e_favorite_enemy;
			ai.favoriteenemy.hunted_by++;
		}
		level.zombie_total--;
		waiting_for_next_raz_spawn();
	}
}
/*
function get_raz_per_round_count()
{
	switch ( level.players.size )
	{
		case 1:
		{
			n_wave_count = RAZ_WAVE_1_AMOUNT;
			break;
		}
		case 2:
		{
			n_wave_count = RAZ_WAVE_2_AMOUNT;
			break;
		}
		case 3:
		{
			n_wave_count = RAZ_WAVE_3_AMOUNT;
			break;
		}
		case 4:
		default:
		{
			n_wave_count = RAZ_WAVE_MAX_AMOUNT;
			break;
		}
	}
	return n_wave_count;
}

function raz_round_wait_func()
{
	level endon( "restart_round" );
	if ( level flag::get( "raz_round" ) )
	{
		level flag::wait_till( "raz_round_in_progress" );
		level flag::wait_till_clear( "raz_round_in_progress" );
	}
	level.sndMusicSpecialRound = 0;
}
*/
function get_current_raz_count()
{
	a_raz = getEntArray( "zombie_raz", "targetname" );
	n_raz_alive = a_raz.size;
	foreach ( e_raz in a_raz )
	{
		if ( !isAlive( e_raz ) )
			n_raz_alive--;
		
	}
	return n_raz_alive;
}

function get_max_allowed_alive_raz()
{
	switch ( level.players.size )
	{
		case 1:
		{
			return RAZ_MAX_RAZ_1PLAYER;
			break;
		}
		case 2:
		{
			return RAZ_MAX_RAZ_2PLAYER;
			break;
		}
		case 3:
		{
			return RAZ_MAX_RAZ_3PLAYER;
			break;
		}
		case 4:
		{
			return RAZ_MAX_RAZ_4PLAYER;
			break;
		}
	}
}

function can_spawn_raz()
{
	n_raz_alive = get_current_raz_count();
	n_max = get_max_allowed_alive_raz();
	if ( n_raz_alive >= n_max || !level flag::get( "spawn_zombies" ) )
		return 0;
	
	return 1;
}

function waiting_for_next_raz_spawn()
{
	switch ( level.players.size )
	{
		case 1:
		{
			n_default_wait = RAZ_SPAWN_DELAY_1PLAYER;
			break;
		}
		case 2:
		{
			n_default_wait = RAZ_SPAWN_DELAY_2PLAYER;
			break;
		}
		case 3:
		{
			n_default_wait = RAZ_SPAWN_DELAY_3PLAYER;
			break;
		}
		default:
		{
			n_default_wait = RAZ_SPAWN_DELAY_4PLAYER;
			break;
		}
	}
	wait n_default_wait;
}
/*
function raz_round_aftermath()
{
	level waittill( "last_ai_down", e_enemy_ai );
	level thread zm_audio::sndMusicSystem_PlayState( "raz_over" );
	if ( isDefined( level.zm_override_ai_aftermath_powerup_drop ) )
		[ [ level.zm_override_ai_aftermath_powerup_drop ] ]( e_enemy_ai, level.v_last_ai_origin );
	else
	{
		v_powerup_spawn_origin = level.v_last_ai_origin;
		a_trace = groundTrace( v_powerup_spawn_origin, v_powerup_spawn_origin + vectorScale( ( 0, 0, -1 ), 1000 ), 0, undefined );
		v_powerup_spawn_origin = a_trace[ "position" ];
		if ( isDefined( v_powerup_spawn_origin ) )
			level thread zm_powerups::specific_powerup_drop( "full_ammo", v_powerup_spawn_origin );
		
	}
	wait 2;
	level.sndMusicSpecialRound = 0;
	wait 6;
	level flag::clear( "raz_round_in_progress" );
}
*/
function get_favorite_enemy()
{
	raz_targets = getPlayers();
	e_least_hunted = undefined;
	foreach( e_target in raz_targets )
	{
		if ( !isDefined( e_target.hunted_by ) )
			e_target.hunted_by = 0;
		
		if ( !zm_utility::is_player_valid( e_target ) )
			continue;
		
		if ( isDefined( level.fn_custom_raz_favorite_enemy ) && ![ [ level.fn_custom_raz_favorite_enemy ] ]( e_target ) )
			continue;
		
		if ( !isDefined( e_least_hunted ) )
		{
			e_least_hunted = e_target;
			continue;
		}
		if ( e_target.hunted_by < e_least_hunted.hunted_by )
			e_least_hunted = e_target;
		
	}
	return e_least_hunted;
}

function raz_health_increase()
{
	level.n_raz_health = RAZ_BASE_HEALTH + level.round_number * RAZ_HEALTH_MULTIPLIER;
	if ( level.n_raz_health < RAZ_BASE_HEALTH )
		level.n_raz_health = RAZ_BASE_HEALTH;
	else if ( level.n_raz_health > RAZ_MAX_BASE_HEALTH )
		level.n_raz_health = RAZ_MAX_BASE_HEALTH;
	
	level.n_raz_health = int( level.n_raz_health * ( 1 + ( RAZ_BASE_HEALTH_MULTIPLIER * ( level.players.size - 1 ) ) ) );
	level.razGunHealth = level.n_raz_health * RAZ_GUN_HEALTH_PERCENT;
	level.razHelmetHealth = level.n_raz_health * RAZ_HELMET_HEALTH_PERCENT;
	level.razLeftShoulderArmorHealth = level.n_raz_health * RAZ_SHOULDER_ARMOR_HEALTH_PERCENT;
	level.razChestArmorHealth = level.n_raz_health * RAZ_CHEST_ARMOR_HEALTH_PERCENT;
	level.razThighArmorHealth = level.n_raz_health * RAZ_THIGH_ARMOR_HEALTH_PERCENT;
}
/*
function play_raz_round()
{
	self playLocalSound( "zmb_raz_round_start" );
	variation_count = 5;
	wait 4.5;
	a_players = getPlayers();
	n_index = randomIntRange( 0, a_players.size );
	a_players[ n_index ] zm_audio::create_and_play_dialog( "general", "raz_spawn" );
}
*/
function raz_init()
{
	self.targetname = "zombie_raz";
	self.script_noteworthy = undefined;
	self.animName = "zombie_raz";
	self.no_damage_points = 1;
	self.allowdeath = 1;
	self.allowPain = 1;
	self.force_gib = 1;
	self.is_zombie = 1;
	self.gibbed = 0;
	self.head_gibbed = 0;
	self.default_goalheight = 40;
	self.ignore_inert = 1;
	self.lightning_chain_immune = 1;
	self.holdFire = 1;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoreSuppression = 1;
	self.suppressionThreshold = 1;
	self.noDodgeMove = 1;
	self.dontShootWhileMoving = 1;
	self.pathenemylookahead = 0;
	self.chatInitialized = 0;
	self.missingLegs = 0;
	self.team = level.zombie_team;
	self.sword_kill_power = 4;
	self.instakill_func = &raz_instakill_override;
	self thread zombie_utility::zombie_eye_glow();
	if ( isDefined( level.func_custom_raz_cleanup_check ) )
		self.func_custom_cleanup_check = level.func_custom_raz_cleanup_check;
	
	self.maxhealth = level.n_raz_health;
	if ( isDefined( level.a_zombie_respawn_health[ self.archetype ] ) && level.a_zombie_respawn_health[ self.archetype ].size > 0 )
	{
		self.health = level.a_zombie_respawn_health[ self.archetype ][ 0 ];
		arrayRemoveValue(level.a_zombie_respawn_health[ self.archetype ], level.a_zombie_respawn_health[ self.archetype ][ 0 ] );
	}
	else
		self.health = self.maxhealth;
	
	self thread raz_death();
	level thread zm_spawner::zombie_death_event( self );
	self thread zm_spawner::enemy_death_detection();
	self zm_spawner::zombie_history( "zombie_raz_spawn_init -> Spawned = " + self.origin );
	if ( isDefined( level.achievement_monitor_func ) )
		self thread [ [ level.achievement_monitor_func ] ]();
	
}

function raz_death()
{
	self waittill( "death", e_attacker );
	self thread zombie_utility::zombie_eye_glow_stop();
	if( get_current_raz_count() == 0 && level.zombie_total == 0 )
	{
		if ( !isDefined( level.zm_ai_round_over ) || [ [ level.zm_ai_round_over ] ]() )
		{
			level.v_last_ai_origin = self.origin;
			level notify( "last_ai_down", self );
		}
	}
	if ( isPlayer( e_attacker ) )
	{
		if ( !IS_TRUE( self.deathpoints_already_given ) )
			e_attacker zm_score::player_add_points( "death_raz", self.damageMod, self.damagelocation );
		
		if ( isDefined( level.hero_power_update ) )
			[ [ level.hero_power_update ] ]( e_attacker, self );
		
		e_attacker zm_audio::create_and_play_dialog( "kill", "raz" );
		e_attacker zm_stats::increment_client_stat( "zraz_killed" );
		e_attacker zm_stats::increment_player_stat( "zraz_killed" );
	}
	if ( isDefined( e_attacker ) && isAi( e_attacker ) )
		e_attacker notify( "killed", self );
	
	if ( isDefined( self ) )
		self stopLoopSound();
	
}

function zombie_setup_attack_properties_raz()
{
	self zm_spawner::zombie_history( "zombie_setup_attack_properties()" );
	self.ignoreall = 0;
	self.meleeAttackDist = 64;
	self.disableArrivals = 1;
	self.disableExits = 1;
}

function stop_raz_sound_on_death()
{
	self waittill( "death" );
	self stopSounds();
}

function special_raz_spawn( n_to_spawn = 1, ptr_post_spawn = undefined, b_ignore_max_raz_count = 0, s_spawn_point = undefined )
{
	n_spawned = 0;
	while ( n_spawned < n_to_spawn )
	{
		if ( !b_ignore_max_raz_count && !can_spawn_raz() )
			return n_spawned;
		
		e_favorite_enemy = get_favorite_enemy();
		
		if ( isDefined( s_spawn_point ) )
			s_spawn_loc = s_spawn_point;
		else if ( isDefined( level.func_custom_get_raz_spawn_point ) )
			s_spawn_loc = [ [ level.func_custom_get_raz_spawn_point ] ]( level.raz_spawners, e_favorite_enemy );
		else if ( level.zm_loc_types[ "raz_location" ].size > 0 )
			s_spawn_loc = array::random( level.zm_loc_types[ "raz_location" ] );
		
		if ( !isDefined( s_spawn_loc ) )
			return 0;
		
		e_ai = spawn_raz_zombie( level.raz_spawners[ 0 ] );
		if ( isDefined( e_ai ) )
		{
			e_ai forceTeleport( s_spawn_loc.origin, s_spawn_loc.angles );
			e_ai.script_string = s_spawn_loc.script_string;
			e_ai.find_flesh_struct_string = e_ai.script_string;
			if ( isDefined( e_favorite_enemy ) )
			{
				e_ai.favoriteenemy = e_favorite_enemy;
				e_ai.favoriteenemy.hunted_by++;
			}
			n_spawned++;
			if ( isDefined( ptr_post_spawn ) )
				e_ai thread [ [ ptr_post_spawn ] ]();
			
			playSoundAtPosition( "zmb_raz_spawn", s_spawn_loc.origin );
		}
		waiting_for_next_raz_spawn();
	}
	return 1;
}


function raz_player_damage_callback( e_inflictor, e_attacker, n_damage, n_flags, str_mod, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time )
{
	e_player = self;
	if ( isDefined( e_attacker ) && e_attacker.archetype === "raz" && str_mod === "MOD_PROJECTILE_SPLASH" && isDefined( w_weapon ) && isSubStr( "raz_melee", w_weapon.name ) )
	{
		n_dist_sq = distanceSquared( e_attacker.origin, e_player.origin );
		n_max_range_sq = 16384;
		n_percent = 1 - n_dist_sq / n_max_range_sq;
		n_base_damage = 35;
		n_damage = n_base_damage * n_percent;
		n_damage = int( n_damage );
		n_damage = n_damage + 15;
		return n_damage;
	}
	return -1;
}

function raz_instakill_override( e_player, str_mod, str_hit_location )
{
	if ( str_hit_location == "right_arm_lower" || str_hit_location == "right_hand" )
		return 1;
	else if ( str_hit_location == "right_arm_upper" && self.razHasGunAttached == 1 )
	{
		self.razGunHealth = 1;
		self doDamage( 1, e_player.origin, e_player, e_player, "right_arm_upper" );
		return 1;
	}
	else if ( IS_TRUE( self.last_damage_hit_armor ) )
		return 1;
	else
		return 0;
	
}