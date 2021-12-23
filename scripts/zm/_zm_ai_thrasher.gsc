#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\archetype_thrasher;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_ai_thrasher;

// #precache( "model", "p7_fxanim_zm_island_thrasher_stomach_mod" );

REGISTER_SYSTEM_EX( "zm_ai_thrasher", &__init__, &__main__, undefined )

function __init__()
{
	level flag::init( "thrasher_round" );
	
	callback::on_spawned( &on_player_spawned );
	level.can_revive = &ThrasherServerUtils::thrasherCanBeRevived;
	// level.var_11b06c2f = &ptr_player_consumed_can_phoenix_up_revive; -- something to do with the Phoenix Up gobble gum
	level.thrashers_enabled = 1;
	level.thrasher_rounds_enabled = 0;
	level.n_thrasher_round_count = 1;
	level.a_thrashers = [];
	level.b_thrasher_transforming = 1;
	level.n_last_thrasher_transform_round = 1;
	level.n_thrashers_spawned_this_round = 0;
	level.aat[ "zm_aat_blast_furnace" ].immune_result_direct[ "thrasher" ] = 1;
	level.aat[ "zm_aat_blast_furnace" ].immune_result_indirect[ "thrasher" ] = 1;
	level.aat[ "zm_aat_turned" ].immune_trigger[ "thrasher" ] = 1;
	level.aat[ "zm_aat_fire_works" ].immune_trigger[ "thrasher" ] = 1;
	level.aat[ "zm_aat_thunder_wall" ].immune_result_direct[ "thrasher" ] = 1;
	level.aat[ "zm_aat_thunder_wall" ].immune_result_indirect[ "thrasher" ] = 1;
	level.thrasher_spawners = [];
	level.thrasher_spawners = getEntArray( "zombie_thrasher_spawner", "script_noteworthy" );
	
	if ( level.thrasher_spawners.size == 0 )
		return;
	
	array::thread_all( level.thrasher_spawners, &spawner::add_spawn_function, &thrasher_prespawn );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_transform_thrasher", &thrasher_safe_self_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_transform_zombie", &thrasher_safe_self_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_transform_zombie_friendly", &thrasher_safe_self_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_teleport_out", &thrasher_safe_self_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_teleport_in_v1", &thrasher_safe_self_delete, "done" );
	scene::add_scene_func( "scene_zm_dlc2_thrasher_attack_swing_swipe", &thrasher_safe_self_delete, "done" );
	level thread thrasher_reset_count_on_round_change();
}

function __main__()
{
	register_clientfields();
}

function register_clientfields()
{
	clientfield::register( "actor", "thrasher_mouth_cf", 9000, 8, "int" );
}

function on_player_spawned()
{
	self thread thrasher_update_last_stand_start_time();
}

function thrasher_update_last_stand_start_time()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "entering_last_stand" );
		self.lastStandStartTime = getTime();
	}
}

function thrasher_reset_count_on_round_change()
{
	level endon( "end_game" );
	while ( 1 )
	{
		level waittill( "end_of_round" );
		level.n_thrashers_spawned_this_round = 0;
	}
}

function thrasher_transform_cooldown( n_cooldown = 30 )
{
	level notify( "thrasher_transform_cooldown" );
	level endon( "thrasher_transform_cooldown" );
	level.b_thrasher_transforming = 0;
	wait n_cooldown;
	level.b_thrasher_transforming = 1;
}

function enable_thrasher_rounds()
{
	level.thrasher_rounds_enabled = 1;
	if ( !isDefined( level.thrasher_round_track_override ) )
		level.thrasher_round_track_override = &thrasher_round_tracker;
	
	level thread [ [ level.thrasher_round_track_override ] ]();
}

function thrasher_round_tracker()
{
	level.n_thrasher_round_count = 1;
	level.n_thrashers_spawned_by_spores = 0;
	level.n_next_thrasher_round = level.round_number + randomIntRange( 4, 7 );
	while ( 1 )
	{
		level waittill( "between_round_over" );
		level.n_thrashers_spawned_by_spores = 0;
		if ( isDefined( level.b_delay_thrasher_round ) && level.round_number == level.b_delay_thrasher_round )
		{
			level.n_next_thrasher_round = level.n_next_thrasher_round + 1;
			continue;
		}
		if ( level.round_number == level.n_next_thrasher_round )
		{
			level.n_next_thrasher_round = level.round_number + 3;
			level thread thrasher_round_spawning();
			level flag::set( "thrasher_round" );
			level waittill( "end_of_round" );
			level flag::clear( "thrasher_round" );
			level.n_thrasher_round_count++;
		}
	}
}

function thrasher_round_spawning()
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
			n_thrashers_to_spawn = 2;
			break;
		}
		case 2:
		{
			n_thrashers_to_spawn = 2;
			break;
		}
		case 3:
		{
			n_thrashers_to_spawn = 3;
			break;
		}
		case 4:
		{
			n_thrashers_to_spawn = 4;
			break;
		}
		default:
		{
			n_thrashers_to_spawn = 2;
			break;
		}
	}
	for ( i = 0; i < n_thrashers_to_spawn; i++ )
	{
		spawn_thrasher();
		wait 30;
	}
}

function ptr_player_consumed_can_phoenix_up_revive( e_revivee, b_ignore_sight_checks = 0, b_ignore_touch_checks = 0 )
{
	if ( IS_TRUE( e_revivee.thrasherConsumed ) )
	{
		if ( !isDefined( e_revivee.reviveTrigger ) )
			return 0;
		
		return 1;
	}
	return self zm_laststand::can_revive( e_revivee, b_ignore_sight_checks, b_ignore_touch_checks);
}

function thrasher_can_spawn( v_origin )
{
	if ( isDefined( v_origin ) )
	{
		if ( !zm_utility::check_point_in_playable_area( v_origin ) )
			return 0;
		
	}
	if ( level.n_thrashers_spawned_this_round >= 2 && level.players.size == 1 && level.round_number < 20 )
		return 0;
	
	if ( level.round_number < 4 )
		return 0;
	
	switch ( level.players.size )
	{
		case 1:
		{
			if ( level.a_thrashers.size < 2 )
				return 1;
			
			break;
		}
		case 2:
		{
			if ( level.a_thrashers.size < 2 )
				return 1;
			
			break;
		}
		case 3:
		{
			if ( level.a_thrashers.size < 3 )
				return 1;
			
			break;
		}
		case 4:
		{
			if ( level.a_thrashers.size < 4 )
				return 1;
			
			break;
		}
		default:
		{
			break;
		}
	}
	return 0;
}
/*
function function_68ee76ee(var_d1cba433, var_48cf4a3d)
{
	if(!isdefined(var_48cf4a3d))
	{
		var_48cf4a3d = 1;
	}
	level endon("end_of_round");
	/#
		Assert(var_d1cba433.size >= var_48cf4a3d, "Dev Block strings are not supported");
	#/
	for(i = 0; i < var_48cf4a3d; i++)
	{
		var_a4ef4373 = undefined;
		while(!isdefined(var_a4ef4373))
		{
			foreach(ai in var_d1cba433)
			{
				if(thrasher_can_infect_zombie(ai))
				{
					var_a4ef4373 = ai;
					break;
				}
			}
			wait(0.5);
		}
		if(isalive(var_a4ef4373))
		{
			if(thrasher_can_spawn())
			{
				ai_thrasher = thrasher_transform_zombie(var_a4ef4373);
				ArrayRemoveValue(var_d1cba433, var_a4ef4373);
			}
		}
	}
}
*/
function thrasher_transform_zombie( e_infected_zombie, b_use_spawn_valid_checks = 1, b_delay_if_thrasher_transforming = 1, b_is_friendly = 0 )
{
	level endon( "end_of_round" );
	str_scene = "scene_zm_dlc2_thrasher_transform_zombie";
	if ( b_is_friendly )
		str_scene = "scene_zm_dlc2_thrasher_transform_zombie_friendly";
	
	while ( !IS_TRUE( e_infected_zombie.zombie_init_done ) )
		wait .05;
	
	if( IS_TRUE(e_infected_zombie.b_is_thrasher) )
	{
		return;
	}
	if ( b_delay_if_thrasher_transforming )
	{
		if ( !level.b_thrasher_transforming )
			return;
		
	}
	if ( !thrasher_can_spawn( e_infected_zombie.origin ) && b_use_spawn_valid_checks )
		return;
	
	if ( isAlive( e_infected_zombie ) )
	{
		// e_infected_zombie.var_34d00e7 = 1;
		if ( b_is_friendly == 0 )
			level notify( "hash_49c2b21f", e_infected_zombie );
		else
			level notify( "hash_de7b8073", e_infected_zombie );
		
		e_align = util::spawn_model( "tag_origin", e_infected_zombie.origin, e_infected_zombie.angles );
		e_align thread scene::play( str_scene, e_infected_zombie );
		e_infected_zombie util::waittill_notify_or_timeout( "spawn_thrasher", 4 );
	}
	if ( isAlive( e_infected_zombie ) )
	{
		if ( !thrasher_can_spawn( e_infected_zombie.origin ) && b_use_spawn_valid_checks )
			return;
		
		ai_thrasher = zombie_utility::spawn_zombie( level.thrasher_spawners[ 0 ], "thrasher" );
		if ( !isDefined( ai_thrasher ) )
			return;
		
		v_origin = e_infected_zombie.origin;
		v_angles = e_infected_zombie.angles;
		ai_thrasher forceTeleport( v_origin, v_angles, 1, 1 );
		if ( b_is_friendly )
			ai_thrasher ai::set_behavior_attribute( "move_mode", "friendly" );
		
		a_ai_zombies = getAIArchetypeArray( "zombie", "axis" );
		foreach ( ai_zombie in a_ai_zombies )
		{
			if ( isAlive( ai_zombie ) && ai_zombie != e_infected_zombie )
			{
				n_max_distance_sq = 60 * 60;
				if ( distanceSquared( ai_zombie.origin, ai_thrasher.origin ) <= n_max_distance_sq )
					ThrasherServerUtils::thrasherKnockdownZombie( ai_thrasher, ai_zombie );
				
			}
		}
		e_scene_model = util::spawn_model( "tag_origin", ai_thrasher.origin, ai_thrasher.angles );
		e_scene_model thread scene::play( "scene_zm_dlc2_thrasher_transform_thrasher", ai_thrasher );
		level.n_last_thrasher_transform_round = level.round_number;
		level thread thrasher_transform_cooldown();
		return ai_thrasher;
	}
}

function thrasher_safe_self_delete(a_ents, e_align)
{
	self zm_utility::self_delete();
}

function thrasher_pustule_pop_callback( v_origin, w_weapon, e_attacker )
{
	if ( isdefined( level.ptr_thrasher_pustule_pop_callback ) )
	{
		self thread [ [ level.ptr_thrasher_pustule_pop_callback ] ]( v_origin, w_weapon, e_attacker );
		break;
	}
	n_infected_zombies_count = 0;
	n_burst_time = getTime();
	n_infect_distance_sq = 60 * 60;
	n_offset = 36;
	while ( n_burst_time + 5000 > getTime() )
	{
		if ( level.n_thrashers_spawned_by_spores < 2 )
		{
			zombies = getAIArchetypeArray( "zombie", "axis" );
			foreach ( zombie in zombies )
			{
				if ( isDefined( zombie ) && isAlive( zombie ) )
				{
					v_infect_origin = ( zombie.origin[ 0 ], zombie.origin[ 1 ], zombie.origin[ 2 ] + n_offset );
					if ( distanceSquared( v_infect_origin, v_origin ) <= n_infect_distance_sq )
					{
						if ( .2 >= randomFloat( 1 ) && thrasher_can_infect_zombie( zombie ) )
						{
							level.n_thrashers_spawned_by_spores++;
							n_infected_zombies_count++;
							thrasher_transform_zombie( zombie );
						}
					}
					if ( n_infected_zombies_count >= 2 )
						return;
					
				}
			}
		}
		wait .5;
	}
}

function spawn_thrasher( b_check_thrasher_spawn_valid = 1 )
{
	if ( !thrasher_can_spawn() && b_check_thrasher_spawn_valid )
		return;
	
	s_loc = thrasher_get_spawn_point();
	ai_thrasher = zombie_utility::spawn_zombie( level.thrasher_spawners[ 0 ], "thrasher", s_loc );
	if ( isDefined( ai_thrasher ) && isDefined( s_loc ) )
	{
		ai_thrasher forceTeleport( s_loc.origin, s_loc.angles );
		playSoundAtPosition( "zmb_vocals_thrash_spawn", ai_thrasher.origin );
		if ( !ai_thrasher zm_utility::in_playable_area() )
		{
			player = array::random( level.players );
			if ( zm_utility::is_player_valid( player, 0, 1 ) )
				ai_thrasher thread thrasher_do_spawn( player.origin );
			
		}
		return ai_thrasher;
	}
}

function thrasher_do_spawn( v_pos )
{
	self endon( "death" );
	e_scene_model = util::spawn_model( "tag_origin", self.origin, self.angles );
	e_scene_model thread scene::play( "scene_zm_dlc2_thrasher_teleport_out", self );
	self util::waittill_notify_or_timeout( "thrasher_teleport_out_done", 4 );
	v_dest_pos = util::positionQuery_PointArray( v_pos, 128, 750, 32, 64, self );
	if ( isDefined( self.thrasher_teleport_dest_func ) )
		v_dest_pos = self [ [ self.thrasher_teleport_dest_func ]]( v_dest_pos );
	
	v_final_pos = arraygetfarthest( v_pos, v_dest_pos );
	if ( isDefined( v_final_pos ) )
	{
		v_dir = v_pos - v_final_pos;
		v_dir = vectorNormalize( v_dir );
		v_angles = vectorToAngles( v_dir );
		e_scene_model_final = util::spawn_model( "tag_origin", v_final_pos, v_angles );
		e_scene_model scene::stop( "scene_zm_dlc2_thrasher_teleport_out" );
		e_scene_model_final thread scene::play( "scene_zm_dlc2_thrasher_teleport_in_v1", self );
	}
	else
	{
		e_scene_model_final = util::spawn_model( "tag_origin", v_pos, ( 0, 0, 0 ) );
		e_scene_model scene::stop( "scene_zm_dlc2_thrasher_teleport_out" );
		e_scene_model_final thread scene::play( "scene_zm_dlc2_thrasher_teleport_in_v1", self );
	}
}

function thrasher_get_spawn_point()
{
	a_thrasher_spawn_points = level.zm_loc_types[ "thrasher_location" ];
	for( i = 0; i < a_thrasher_spawn_points.size; i++ )
	{
		if( isDefined( level.e_last_spawn_used ) && level.e_last_spawn_used == a_thrasher_spawn_points[ i ] )
			continue;
		
		s_spawn_loc = a_thrasher_spawn_points[ i ];
		level.e_last_spawn_used = s_spawn_loc;
		return s_spawn_loc;
	}
	s_spawn_loc = a_thrasher_spawn_points[ 0 ];
	level.e_last_spawn_used = s_spawn_loc;
	return s_spawn_loc;
}

function thrasher_prespawn()
{
	self.b_is_thrasher = 1;
	zombiehealth = level.zombie_health;
	if ( !isDefined( zombiehealth ) )
		zombiehealth = level.zombie_vars[ "zombie_health_start" ];
	
	if ( level.round_number <= 50 )
		self.maxhealth = zombiehealth * 10;
	else if ( level.round_number <= 70 )
	{
		n_round = level.round_number;
		n_health_multiplier = 10 - n_round - 50 * .35;
		self.maxhealth = int( zombiehealth * n_health_multiplier );
	}
	else
		self.maxhealth = zombiehealth * 3;
	
	if ( !isDefined( self.maxhealth ) || self.maxhealth <= 0 || self.maxhealth > 2147483647 || self.maxhealth != self.maxhealth )
		self.maxhealth = zombiehealth;
	
	self.health = self.maxhealth;
	self.thrasherRageLevel = level.round_number;
	self.thrasherClosestValidPlayer = &zm_utility::get_closest_valid_player;
	self.thrasherConsumeZombieCallback = &thrasher_consume_zombie;
	self.thrasherCanConsumeCallback = &thrasher_can_consume_callback;
	self.thrasherPustulePopCallback = &thrasher_pustule_pop_callback;
	self.thrasherMoveModeFriendlyCallback = &thrasher_move_mode_friendly_callback;
	self.nuke_damage_func = &thrasher_nuke_damage_func;
	self.thrasherMeleeHitCallback = &thrasher_melee_hit_callback;
	self.thrasherTeleportCallback = &thrasher_teleport_callback;
	self.thrasherShouldTeleportCallback = &thrasher_should_teleport_callback;
	self.thrasherCanConsumePlayerCallback = &thrasher_can_consume_player_callback;
	self.thrasherConsumedCallback = &thrasher_consumed_callback;
	self.thrasherReleaseConsumedCallback = &thrasher_release_consumed_callback;
	self.thrasherStartTraverseCallback = &thrasher_start_traverse_callback;
	self.thrasherTerminateTraverseCallback = &thrasher_terminate_traverse_callback;
	self.thrasherAttackableObjectCallback = &zm_behavior::zombieAttackableObjectService;
	self.riotshield_knockdown_func = &thrasher_riotshield_fling_func;
	self.riotshield_fling_func = &thrasher_riotshield_fling_func;
	self.tesla_damage_func = &thrasher_tesla_damage_func;
	self.thrasher_teleport_dest_func = &thrasher_teleport_dest_func;
	self zombie_utility::zombie_eye_glow_stop();
	self thread zm::update_zone_name();
	foreach ( e_spore in self.thrasherSpores )
	{
		e_spore.health = zombiehealth * 2;
		if ( !isDefined( e_spore.health ) || e_spore.health <= 0 || e_spore.health > 2147483647 || e_spore.health != e_spore.health )
			e_spore.health = zombiehealth;
		
		e_spore.maxhealth = e_spore.health;
	}
	self.no_gib = 1;
	self.head_gibbed = 1;
	self.missingLegs = 0;
	self.b_ignore_cleanup = 1;
	self thread thrasher_death();
	self thread thrasher_vocals();
	
	if ( !isDefined( level.a_thrashers ) )
		level.a_thrashers = [];
	else if ( !isArray( level.a_thrashers ) )
		level.a_thrashers = array( level.a_thrashers );
	
	level.a_thrashers[ level.a_thrashers.size ] = self;
	level.n_thrashers_spawned_this_round++;
	level thread zm_spawner::zombie_death_event( self );
}

function thrasher_tesla_damage_func( v_origin, e_player )
{
	return;
}

function thrasher_can_infect_zombie( zombie )
{
	if ( isDefined( zombie ) && isAlive( zombie ) && zombie isOnGround() && zombie.archetype == "zombie" && !zombie isPlayingAnimScripted() && zm_utility::check_point_in_playable_area( zombie.origin ) && thrasher_should_teleport_callback( zombie.origin ) )
		return 1;
	
	return 0;
}

function thrasher_teleport_dest_func( a_dest_pos )
{
	a_valid_pos = [];
	foreach ( v_point in a_dest_pos )
	{
		if ( zm_utility::check_point_in_enabled_zone( v_point, 1 ) && thrasher_should_teleport_callback( v_point ) )
		{
			if ( !isDefined( a_valid_pos ) )
				a_valid_pos = [];
			else if ( !isArray( a_valid_pos ) )
				a_valid_pos = array( a_valid_pos );
			
			a_valid_pos[ a_valid_pos.size ] = v_point;
		}
	}
	return a_valid_pos;
}

function thrasher_nuke_damage_func()
{
	if ( !zm_utility::is_magic_bullet_shield_enabled( self ) )
	{
		self doDamage( self.health / 2, self.origin );
		ThrasherServerUtils::thrasherGoBerserk( self );
	}
}

function thrasher_riotshield_fling_func( player, gib )
{
	if ( !zm_utility::is_magic_bullet_shield_enabled( self ) )
	{
		self doDamage( 10, player.origin, player, player, "head", "MOD_IMPACT" );
		self doDamage( 3000, player.origin, player, player );
	}
}

function thrasher_can_eat_zombie( entity )
{
	a_zombies = zombie_utility::get_zombie_array();
	a_zombies_in_range = arraySortClosest(a_zombies, entity.origin, 5, 50, 96);
	foreach( zombie in a_zombies_in_range )
	{
		if ( !isDefined( zombie ) || IS_TRUE( zombie.knockdown ) || IS_TRUE( zombie.missingLegs ) || IS_TRUE( zombie.thrasherConsumed ) || zombie isRagdoll())
			continue;
		
		if ( abs( zombie.origin[ 2 ] - entity.origin[ 2 ] ) > 18 )
			continue;
		
		forward = AnglesToForward(entity.angles);
		forward = (forward[0], forward[1], 0);
		forward = VectorNormalize(forward);
		direction = zombie.origin - entity.origin;
		direction = (direction[0], direction[1], 0);
		direction = vectorNormalize(direction);
		if ( isAlive( zombie ) && zombie.archetype == "zombie" && zombie !== entity && !zombie isPlayingAnimScripted() && vectorDot( forward, direction ) >= .9063 && zm_utility::check_point_in_playable_area( zombie.origin ) )
			return zombie;
		
	}
}

function thrasher_can_consume_callback( entity )
{
	if ( IS_TRUE( entity.thrasherConsumedPlayer ) )
		return 0;
	
	return isDefined( thrasher_can_eat_zombie( entity ) );
}

function thrasher_eat_zombie_scene( entity, zombie )
{
	zombie.allowdeath = 0;
	zombie.b_ignore_cleanup = 1;
	zombie.thrasherConsumed = 1;
	zombieForward = anglesToForward( zombie.angles );
	entityForward = anglesToForward( entity.angles );
	if ( vectorDot( zombieForward, entityForward ) > 0 )
		entity thread scene::play( "scene_zm_dlc2_thrasher_eat_f_zombie", array( entity, zombie ) );
	else
		entity thread scene::play( "scene_zm_dlc2_thrasher_eat_b_zombie", array( entity, zombie ) );
	
	zombie util::waittill_notify_or_timeout( "hide_zombie", 5 );
	if ( isDefined( zombie ) )
	{
		zombie.allowdeath = 1;
		zombie hide();
		zombie kill();
		entity ThrasherServerUtils::thrasherRestorePustule( entity );
	}
}

function thrasher_consume_zombie( entity )
{
	e_zombie = thrasher_can_eat_zombie( entity );
	if ( isDefined( e_zombie ) )
	{
		entity thread thrasher_eat_zombie_scene( entity, e_zombie );
		return 1;
	}
	return 0;
}

function thrasher_set_mouth_state( e_entity, e_player, str_state )
{
	if ( isDefined( e_entity ) && isDefined( e_player ) )
	{
		entityNumber = e_player getEntityNumber();
		n_mouth_state = e_entity clientfield::get( "thrasher_mouth_cf" );
		 
		n_mouth_state &= ~( 3 << ( 2 * entityNumber ) );
		n_mouth_state |= ( str_state << ( 2 * entityNumber ) );
		
		e_entity clientfield::set( "thrasher_mouth_cf", n_mouth_state );
	}
}

function thrasher_start_traverse_callback( entity )
{
	thrasher_set_mouth_state( entity, entity.thrasherPlayer, 3 );
}

function thrasher_terminate_traverse_callback( entity )
{
	thrasher_set_mouth_state( entity, entity.thrasherPlayer, 2 );
}

function thrasher_consumed_callback( entity, player )
{
	thrasher_set_mouth_state( entity, player, 2 );
}

function thrasher_release_consumed_callback( entity, player )
{
	thrasher_set_mouth_state( entity, player, 0 );
}

function thrasher_can_consume_player_callback( entity )
{
	if ( !zm_utility::check_point_in_playable_area( entity.origin ) )
		return 0;
	
	return 1;
}

function thrasher_melee_hit_callback( hitEntity )
{
	entity = self;
	if ( isDefined( hitEntity ) && isActor( hitEntity ) && entity.team == "allies" )
	{
		hitEntity clientfield::increment( "zm_nuked" );
		hitEntity kill();
	}
}

function thrasher_teleport_callback( entity )
{
	entity endon( "death" );
	if ( isDefined( entity ) && isAlive( entity ) )
	{
		entity.bgbIgnoreFearInHeadlights = 1;
		thrasher_set_mouth_state( entity, entity.thrasherPlayer, 3 );
		if ( isDefined( entity.thrasherPlayer ) )
			entity.thrasherPlayer thread LUI::screen_fade_out( 1.5 );
		
		e_scene_model = util::spawn_model( "tag_origin", entity.origin, entity.angles );
		e_scene_model thread scene::play( "scene_zm_dlc2_thrasher_teleport_out", entity );
		entity util::waittill_notify_or_timeout( "hide_ai", 4 );
		entity hide();
	}
	if ( isDefined( entity ) && isAlive( entity ) )
	{
		ThrasherServerUtils::thrasherTeleport( entity );
		e_scene_model = util::spawn_model( "tag_origin", entity.origin, entity.angles );
		e_scene_model thread scene::play( "scene_zm_dlc2_thrasher_teleport_in_v1", entity );
		entity util::waittill_notify_or_timeout( "show_ai", 4 );
		entity show();
		entity util::waittill_notify_or_timeout( "show_player", 4 );
		thrasher_set_mouth_state( entity, entity.thrasherPlayer, 2 );
		if ( isDefined( entity.thrasherPlayer ) )
			entity.thrasherPlayer thread LUI::screen_fade_in( 2 );
		
		entity.bgbIgnoreFearInHeadlights = 0;
	}
}

function thrasher_move_mode_friendly_callback()
{
	zm_behavior::findZombieEnemy();
	if ( !isDefined( self.favoriteenemy ) && isDefined( self.owner ) )
	{
		if ( isDefined( self.owner ) )
		{
			queryResult = positionQuery_Source_Navigation( self.owner.origin, 128, 256, 128, 20 );
			if ( isDefined( queryResult ) && queryResult.data.size > 0 )
				self setGoal( queryResult.data[ 0 ].origin );
			
		}
	}
}

function thrasher_death()
{
	self waittill( "death", e_attacker );
	arrayRemoveValue( level.a_thrashers, self );
	if ( isPlayer( e_attacker ) )
	{
		if ( !IS_TRUE( self.deathpoints_already_given ) )
			e_attacker zm_score::player_add_points( "death_thrasher", self.damageMod, self.damagelocation, 1 );
		
		if ( isDefined( level.hero_power_update ) )
			[ [ level.hero_power_update ] ]( e_attacker, self );
		
		if ( randomIntRange( 0, 100 ) >= 80 )
			e_attacker zm_audio::create_and_play_dialog( "kill", "thrashers" );
		
		e_attacker zm_stats::increment_client_stat( "zthrashers_killed" );
		e_attacker zm_stats::increment_player_stat( "zthrashers_killed" );
	}
	if ( isDefined( e_attacker ) && isAi( e_attacker ) )
		e_attacker notify( "killed", self );
	
}

function thrasher_vocals()
{
	self endon( "death" );
	self playLoopSound( "zmb_thrasher_lp_close", 2 );
	wait randomIntRange( 2, 5 );
	while ( 1 )
	{
		self playSoundOnTag( "zmb_vocals_thrash_ambient", "j_head" );
		// level notify( "hash_9b1446c2", self );
		wait randomIntRange( 3, 9 );
	}
}

function thrasher_should_teleport_callback( origin )
{
	a_volumes = getEntArray( "no_teleport_area", "script_noteworthy" );
	if ( !isDefined( a_volumes ) || a_volumes.size < 1 )
		return 1;
	
	if ( !isDefined(level.check_model ) )
		level.check_model = spawn( "script_model", origin );
	else
		level.check_model.origin = origin;
	
	for ( i = 0; i < a_volumes.size; i++ )
	{
		if ( level.check_model istouching( a_volumes[ i ] ) )
			return 0;
		
	}
	return 1;
}