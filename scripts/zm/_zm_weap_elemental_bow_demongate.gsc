#using scripts\codescripts\struct;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_elemental_bow;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "model", "c_zom_chomper" );

#namespace _zm_weap_elemental_bow_demongate;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_demongate", &__init__, &__main__, undefined )

function __init__()
{
	level.w_bow_demongate = getweapon( "elemental_bow_demongate" );
	level.w_bow_demongate_charged = getweapon( "elemental_bow_demongate4" );
	level.a_demongate_chompers = [];
	clientfield::register( "toplayer", "elemental_bow_demongate" + "_ambient_bow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_demongate" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_demongate4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "demongate_portal_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "demongate_portal_rumble", 1, 1, "int" );
	clientfield::register( "scriptmover", "demongate_wander_locomotion_anim", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "demongate_attack_locomotion_anim", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "demongate_chomper_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "demongate_chomper_bite_fx", VERSION_SHIP, 1, "counter" );
}

function __main__()
{
	callback::on_connect( &on_connect_bow_demongate );
}

function on_connect_bow_demongate()
{
	self thread zm_weap_elemental_bow::bow_base_wield_watcher( "elemental_bow_demongate" );
	self thread zm_weap_elemental_bow::bow_base_fired_watcher( "elemental_bow_demongate", "elemental_bow_demongate4" );
	self thread zm_weap_elemental_bow::bow_base_impact_watcher( "elemental_bow_demongate", "elemental_bow_demongate4", &bow_demongate_impact_explosion );
}


function bow_demongate_impact_explosion( weapon, position, radius, attacker, normal )
{
	if ( weapon.name == "elemental_bow_demongate4" )
		self thread bow_demongate_open_portal( weapon, position, attacker, normal );
	else
	{
		attacker clientfield::set( "elemental_bow_demongate" + "_arrow_impact_fx", 1 );
		self thread bow_demongate_fire_chomper( position, attacker );
	}
}

function bow_demongate_get_impact_pos( v_pos, v_norm )
{
	if ( abs( v_norm[ 2 ] ) < .2 )
	{
		v_pos = v_pos + ( v_norm * 16 );
		a_trace = bullettrace( v_pos, v_pos + vectorScale( ( 0, 0, 1 ), 64 ), 0, undefined );
		if ( a_trace[ "fraction" ] < 1 )
			v_pos = a_trace[ "position" ] - vectorScale( ( 0, 0, 1 ), 64 );
		
		a_trace = bullettrace( v_pos, v_pos - vectorScale( ( 0, 0, 1 ), 64 ), 0, undefined );
		if ( a_trace[ "fraction" ] < 1 )
			v_pos = a_trace[ "position" ] + vectorScale( ( 0, 0, 1 ), 64 );
		
	}
	else
	{
		n_z_offset = v_norm[ 2 ] * 64;
		v_pos = v_pos + ( 0, 0, n_z_offset );
	}
	return v_pos;
}

function bow_demongate_open_portal( weapon, position, attacker, normal )
{
	position = bow_demongate_get_impact_pos( position, normal );
	v_portal_angles = vectorToAngles( normal );
	v_portal_angles = v_portal_angles + vectorScale( ( 0, 1, 0 ), 90 );
	v_portal_angles = v_portal_angles * ( 0, 1, 0 );
	e_portal = util::spawn_model( "tag_origin", position, v_portal_angles );
	e_portal clientfield::set( "demongate_portal_fx", 1 );
	e_portal.b_portal_open = 1;
	
	radiusDamage( position, 96, level.zombie_health, level.zombie_health, self, "MOD_UNKNOWN", level.w_bow_demongate_charged );
	wait .25;
	
	e_portal thread bow_demongate_portal_shake_players();
	
	if ( getDvarInt( "splitscreen_playerCount" ) > 2 )
		n_round_group_health_remaining = 4 * level.zombie_health;
	else
		n_round_group_health_remaining = 2 * level.zombie_health;
	
	if ( level.a_demongate_chompers.size > 12 )
		n_chompers_to_spawn = 2;
	else
	{
		n_chompers_to_spawn = int( ( ( zombie_utility::get_current_zombie_count() + level.zombie_total ) * level.zombie_health ) / n_round_group_health_remaining );
		
		if ( getDvarInt( "splitscreen_playerCount" ) > 2 )
			n_chompers_to_spawn = math::clamp( n_chompers_to_spawn, 4, 4 );
		else
			n_chompers_to_spawn = math::clamp( n_chompers_to_spawn, 4, 6 );
		
	}
	
	n_spawn_delay = 0;
	for ( i = 0; i < n_chompers_to_spawn; i++ )
	{
		e_chomper = bow_demongate_spawn_chomper( position, v_portal_angles - vectorScale( ( 0, 1, 0 ), 90 ) );
		e_chomper thread bow_demongate_chomper_move_forward( self, position );
		n_wait_time = .1;
		n_spawn_delay = n_spawn_delay + n_wait_time;
		wait n_wait_time;
	}
	if ( n_spawn_delay < 2 )
		wait 2 - n_spawn_delay;
	
	wait 2.5;
	e_portal clientfield::set( "demongate_portal_fx", 0 );
	wait 2;
	e_portal notify( "demongate_portal_closed" );
	e_portal.b_portal_open = 0;
	wait 1.6;
	e_portal delete();
}

function bow_demongate_portal_shake_players()
{
	self endon( "demongate_portal_closed" );
	while ( 1 )
	{
		foreach ( e_player in level.activeplayers )
		{
			if ( isDefined( e_player ) && !IS_TRUE( e_player.b_bow_portal_rumbling ) )
			{
				if ( distanceSquared( e_player.origin, self.origin ) < 9216 )
					e_player thread bow_demongate_portal_shake_player( self );
				
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function bow_demongate_portal_shake_player( e_portal )
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self.b_bow_portal_rumbling = 1;
	self clientfield::set_to_player( "demongate_portal_rumble", 1 );
	while ( distanceSquared( self.origin, e_portal.origin ) < 9216 && IS_TRUE( e_portal.b_portal_open ) )
		WAIT_SERVER_FRAME;
	
	self.b_bow_portal_rumbling = 0;
	self clientfield::set_to_player( "demongate_portal_rumble", 0 );
}

function bow_demongate_fire_chomper( position, attacker )
{
	v_angles = anglesToForward( attacker.angles ) * -1;
	e_chomper = bow_demongate_spawn_chomper( position, v_angles );
	wait( 0.1 );
	e_chomper thread bow_demongate_chomper_start_attack( self );
}

function bow_demongate_spawn_chomper( position, v_angles )
{
	e_chomper = util::spawn_model( "c_zom_chomper", position, v_angles );
	e_chomper clientfield::set( "demongate_chomper_fx", 1 );
	e_chomper flag::init( "chomper_attacking" );
	e_chomper flag::init( "demongate_chomper_despawning" );
	if ( getDvarInt( "splitscreen_playerCount" ) > 2 )
		n_round_group_health_remaining = 4 * level.zombie_health;
	else
		n_round_group_health_remaining = 2 * level.zombie_health;
	
	e_chomper.n_chomper_round_group_health_remaining = n_round_group_health_remaining;
	e_chomper.b_look_for_target = 1;
	e_chomper thread demongate_chomper_failsafe();
	n_free_chomp_count = 0;
	n_chomp_total = level.a_demongate_chompers.size - 12;
	if ( n_chomp_total > 0 )
	{
		foreach ( e_chomper_b in level.a_demongate_chompers )
		{
			if ( !e_chomper_b flag::get( "chomper_attacking" ) && !IS_TRUE( e_chomper_b.b_chomper_stalking ) )
			{
				e_chomper_b.n_timer = 3;
				n_free_chomp_count++;
				if ( n_free_chomp_count > n_chomp_total )
					break;
				
			}
		}
	}
	if ( !isDefined( level.a_demongate_chompers ) )
		level.a_demongate_chompers = [];
	else if ( !isArray( level.a_demongate_chompers ) )
		level.a_demongate_chompers = array( level.a_demongate_chompers );
	
	level.a_demongate_chompers[ level.a_demongate_chompers.size ] = e_chomper;
	return e_chomper;
}

function bow_demongate_chomper_despawn()
{
	self flag::set( "demongate_chomper_despawning" );
	if ( !IS_TRUE( self.b_chomper_despawning ) )
	{
		self.b_chomper_despawning = 1;
		if ( !isDefined( level.n_chomper_last_despawn_time ) )
			level.n_chomper_last_despawn_time = getTime();
		else if ( level.n_chomper_last_despawn_time == getTime() )
			wait( randomFloatRange( 0.1, 0.2 ) );
		
		level.n_chomper_last_despawn_time = getTime();
		self moveTo( self.origin + vectorScale( ( 0, 0, 1 ), 96 ), 1.4 );
		self rotatePitch( -90, .4 );
		wait 1.4;
		self moveTo( self.origin, .1 );
		self clientfield::set( "demongate_chomper_fx", 0 );
		wait 3;
		self notify( "demongate_chomper_despawned" );
		level.a_demongate_chompers = array::exclude( level.a_demongate_chompers, self );
		self delete();
	}
}

function demongate_chomper_failsafe()
{
	self endon( "demongate_chomper_despawning" );
	self.n_timer = 0;
	while ( self.n_timer < 3 )
	{
		if ( !self flag::get( "chomper_attacking" ) && !IS_TRUE( self.b_chomper_stalking ) )
			self.n_timer = self.n_timer + .05;
		
		WAIT_SERVER_FRAME;
	}
	while ( self flag::get( "chomper_attacking" ) )
		wait .1;
	
	self thread bow_demongate_chomper_despawn();
}

function bow_demongate_chomper_move_forward( e_player, portal_origin )
{
	self.b_chomper_stalking = 1;
	self.origin = self.origin + ( 0, 0, randomIntRange( int( -51.2 ), int( 51.2 ) ) );
	self.angles = ( self.angles[ 0 ] + ( randomIntRange( -30, 30 ) ), self.angles[ 1 ] + ( randomIntRange( -45, 45 ) ), self.angles[ 2 ] );
	v_target_org = self.origin + ( anglesToForward( self.angles ) * 96 );
	self.angles = ( 0, self.angles[ 1 ], 0 );
	self moveTo( v_target_org, .4 );
	wait .4;
	self.b_chomper_stalking = 0;
	self bow_demongate_chomper_start_attack( e_player );
}

function bow_demongate_chomper_start_attack( e_player )
{
	self bow_demongate_chomper_acquire_new_target( e_player );
	if ( isDefined( self.target_enemy ) )
		self bow_demongate_chomper_think( e_player );
	else
		self thread bow_demongate_chomper_search( e_player );
	
}

function bow_demongate_chomper_search( e_player )
{
	self endon( "demongate_chomper_despawning" );
	self endon( "death" );
	if ( !isDefined( self ) )
		return;
	if ( self flag::get( "demongate_chomper_despawning" ) )
		return;
	
	self flag::clear( "chomper_attacking" );
	self clientfield::set( "demongate_wander_locomotion_anim", 1 );
	n_target_x = randomFloatRange( 5, 15 );
	n_target_y = randomFloatRange( 15, 45 );
	n_target_z = randomFloatRange( 15, 45 );
	n_target_x = ( randomInt( 100 ) < 50 ? n_target_x : n_target_x * -1 );
	n_target_y = ( randomInt( 100 ) < 50 ? n_target_y : n_target_y * -1 );
	n_target_z = ( randomInt( 100 ) < 50 ? n_target_z : n_target_z * -1 );
	if ( zm_utility::is_player_valid( e_player ) )
	{
		v_target_angles = e_player.angles;
		v_target_pos = e_player getEye();
	}
	else
	{
		v_target_angles = self.angles;
		v_target_pos = self.origin;
	}
	v_pos = ( v_target_angles[ 0 ] + n_target_x, v_target_angles[ 1 ] + n_target_y, v_target_angles[ 2 ] + n_target_z );
	v_norm = vectorNormalize( anglesToForward( v_pos ) );
	a_trace = physicsTraceEx( v_target_pos, v_target_pos + ( v_norm * 512 ), vectorScale( ( -1, -1, -1 ), 16 ), vectorScale( ( 1, 1, 1 ), 16 ) );
	v_target_org = a_trace[ "position" ] + ( v_norm * -32 );
	n_dist = distance( self.origin, v_target_org );
	n_time = n_dist / 48;
	v_rotate = v_target_org - self.origin;
	v_rotate = ( 0, v_rotate[ 1 ], 0 );
	
	if ( !isDefined( level.n_chomper_last_despawn_time ) )
		level.n_chomper_last_despawn_time = getTime();
	else if ( level.n_chomper_last_despawn_time == getTime() )
		wait( randomFloatRange( .1, .2 ) );
	
	level.n_chomper_last_despawn_time = getTime();
	self moveTo( v_target_org, n_time );
	self rotateTo( vectorToAngles( v_rotate ), n_time * .5 );
	self thread bow_demongate_chomper_find_flesh( e_player );
	self util::waittill_any_timeout( n_time * 2, "movedone", "demongate_chomper_found_target", "demongate_chomper_despawning", "death" );
	if ( isDefined( self.target_enemy ) )
	{
		self clientfield::set( "demongate_wander_locomotion_anim", 0 );
		self bow_demongate_chomper_think( e_player );
	}
	else
		self thread bow_demongate_chomper_search( e_player );
	
}

function bow_demongate_chomper_find_flesh( e_player )
{
	self endon( "demongate_chomper_despawning" );
	self endon( "demongate_chomper_found_target" );
	self endon( "movedone" );
	self endon( "death" );
	while ( !isDefined( self.target_enemy ) )
	{
		wait .2;
		self thread bow_demongate_chomper_acquire_new_target( e_player );
	}
}

function bow_demongate_chomper_think( e_player )
{
	n_target_enemy_health = self.target_enemy.health;
	self bow_demongate_chomper_move_to_player();
	if ( zm_weap_elemental_bow::is_bow_impact_valid( self.target_enemy ) )
	{
		n_variant = randomIntRange( 1, 7 );
		b_is_crawler = self.target_enemy.missinglegs;
		self.target_enemy.b_is_bow_hit = 1;
		self.b_look_for_target = 0;
		self.n_chomper_round_group_health_remaining = self.n_chomper_round_group_health_remaining - n_target_enemy_health;
		self thread bow_demongate_chomper_eat_zombie( n_variant, b_is_crawler );
		self thread bow_demongate_chomper_do_bite_fx();
		self thread bow_demongate_chomper_attack_target( e_player );
		if ( IS_TRUE( self.target_enemy.isdog ) || isVehicle( self.target_enemy ) )
			n_wait_time = .8;
		
		else if ( self.target_enemy.archetype === "mechz" )
		{
			n_wait_time = 2.6;
			self.n_chomper_round_group_health_remaining = 0;
		}
		else
		{
			n_wait_time = randomFloatRange( 2, 3 );
			self.target_enemy setPlayerCollision( 0 );
		}
		self.target_enemy util::waittill_notify_or_timeout( "death", n_wait_time );
		self notify( "chomper_reached_target" );
		self bow_demongate_chomper_eat_zombie_scene( n_variant, b_is_crawler );
		if ( self.n_chomper_round_group_health_remaining < 1 )
		{
			self thread bow_demongate_chomper_despawn();
			return;
		}
	}
	else if ( isDefined( self.target_enemy ) )
		self.target_enemy.b_hunted_by_chomper = 0;
	
	self flag::clear( "chomper_attacking" );
	self thread bow_demongate_chomper_start_attack( e_player );
}

function bow_demongate_chomper_do_bite_fx()
{
	self endon( "death" );
	self endon( "chomper_reached_target" );
	if ( self.target_enemy.archetype === "mechz" )
	{
		while ( 1 )
		{
			self clientfield::increment( "demongate_chomper_bite_fx", 1 );
			wait( 1 );
		}
	}
	else
	{
		while ( 1 )
		{
			self waittill( "chomper_bite" );
			self clientfield::increment( "demongate_chomper_bite_fx", 1 );
		}
	}
}

function bow_demongate_chomper_eat_zombie( n_variant, b_is_crawler )
{
	self.target_enemy endon( "death" );
	if ( IS_TRUE( self.target_enemy.isdog ) )
		self.target_enemy ai::set_ignoreall( 1 );
	else if ( self.target_enemy.archetype === "mechz" )
		self thread bow_demongate_chomper_eat_mechz();
	else if ( isVehicle( self.target_enemy ) )
		self.target_enemy.ignoreall = 1;
	else if ( IS_TRUE( b_is_crawler ) )
		self.target_enemy scene::play( "ai_zm_dlc1_zombie_demongate_chomper_attack_crawler", array( self.target_enemy, self ) );
	else
	{
		self.target_enemy scene::init( "ai_zm_dlc1_zombie_demongate_chomper_attack_0" + n_variant, array( self.target_enemy, self ) );
		self.target_enemy scene::play( "ai_zm_dlc1_zombie_demongate_chomper_attack_0" + n_variant, array( self.target_enemy, self ) );
	}
}

function bow_demongate_chomper_eat_mechz()
{
	e_mechz = self.target_enemy;
	self endon( "death" );
	self endon( "chomper_reached_target" );
	e_mechz endon( "death" );
	while ( 1 )
	{
		n_target_distance = isDefined( e_mechz.has_faceplate ) && ( e_mechz.has_faceplate ? 6 : 1 );
		n_target_pos = anglesToForward( self.target_enemy.angles ) * n_target_distance;
		self.origin = self.target_enemy getTagOrigin( "j_faceplate" ) + n_target_pos;
		self.angles = vectorToAngles( n_target_pos * -1 );
		WAIT_SERVER_FRAME;
	}
}

function bow_demongate_chomper_eat_zombie_scene( n_variant, b_is_crawler )
{
	if ( isDefined( self.target_enemy ) && self.target_enemy.archetype === "mechz" )
	{
		self.target_enemy thread bow_demongate_chomper_eat_mechz_scene();
		return;
	}
	if ( isDefined( self.target_enemy ) && !IS_TRUE( self.target_enemy.isdog ) )
	{
		if ( IS_TRUE( b_is_crawler ) )
			self.target_enemy thread scene::stop( "ai_zm_dlc1_zombie_demongate_chomper_attack_crawler" );
		else
			self.target_enemy thread scene::stop( "ai_zm_dlc1_zombie_demongate_chomper_attack_0" + n_variant );
		
	}
	if ( IS_TRUE( b_is_crawler ) )
		self thread scene::stop( "ai_zm_dlc1_zombie_demongate_chomper_attack_crawler" );
	else
		self thread scene::stop( "ai_zm_dlc1_zombie_demongate_chomper_attack_0" + n_variant );
	
}

function bow_demongate_chomper_eat_mechz_scene()
{
	self endon( "death" );
	self.b_mechz_hit_by_chomper = 1;
	wait 16;
	self.b_mechz_hit_by_chomper = 0;
}

function bow_demongate_chomper_move_to_player()
{
	self flag::set( "chomper_attacking" );
	v_eye_pos = self.target_enemy getEye();
	n_dist = distance( self.origin, v_eye_pos );
	n_loop_count = 1;
	n_coin = ( math::cointoss() ? 1 : -1 );
	self clientfield::set( "demongate_attack_locomotion_anim", 1 );
	while ( n_dist > 32 && isDefined( self.target_enemy ) && isalive( self.target_enemy ) )
	{
		v_eye_pos = self.target_enemy getEye();
		n_time = n_dist / 640;
		n_incriment = 1 / n_loop_count;
		n_scale = vectorScale( ( 0, 0, 1 ), 160 ) * n_incriment;
		v_offset = ( anglesToRight( vectorToAngles( v_eye_pos - self.origin ) ) ) * 256;
		v_offset = v_offset * n_incriment;
		v_offset = v_offset * n_coin;
		v_target_pos = ( v_eye_pos + v_offset ) + n_scale;
		v_rotate = v_target_pos - self.origin;
		v_rotate = ( 0, v_rotate[ 1 ], 0 );
		
		if ( !isDefined( level.n_chomper_last_despawn_time ) )
			level.n_chomper_last_despawn_time = getTime();
		else if ( level.n_chomper_last_despawn_time == getTime() )
			wait randomFloatRange( .1, .2 );
		
		level.n_chomper_last_despawn_time = getTime();
		self moveTo( v_target_pos, n_time );
		self rotateTo( vectorToAngles( v_rotate ), n_time * .5 );
		n_time = n_time * .3;
		n_time = ( n_time < .1 ? .1 : n_time );
		wait n_time;
		n_loop_count++;
		n_dist = distance( self.origin, v_eye_pos );
	}
	self clientfield::set( "demongate_attack_locomotion_anim", 0 );
	if ( isDefined( self.target_enemy ) && isalive( self.target_enemy ) )
		self.origin = v_eye_pos;
	
}

function bow_demongate_chomper_attack_target( e_player )
{
	e_target = self.target_enemy;
	e_target endon( "death" );
	if ( e_target.archetype === "mechz" )
	{
		self thread bow_demongate_chomper_attack_mechz_target( e_player );
		return;
	}
	n_damage = e_target.health;
	self waittill( "chomper_reached_target" );
	e_target setPlayerCollision( 1 );
	e_target.b_hunted_by_chomper = 0;
	e_target.b_is_bow_hit = 0;
	if ( zm_utility::is_player_valid( e_player ) )
		e_chomper_target = e_player;
	else
		e_chomper_target = undefined;
	
	e_target doDamage( n_damage, e_target.origin, e_chomper_target, e_chomper_target, undefined, "MOD_UNKNOWN", 0, level.w_bow_demongate );
	gibserverutils::gibhead( e_target );
}

function bow_demongate_chomper_attack_mechz_target( e_player )
{
	e_target = self.target_enemy;
	e_target endon( "death" );
	
	n_max_mechz_health = level.mechz_health;
	
	n_damage = ( n_max_mechz_health * .2 ) / .2;
	if ( zm_utility::is_player_valid( e_player ) )
		e_chomper_target = e_player;
	else
		e_chomper_target = undefined;
	
	e_target doDamage( n_damage, e_target.origin, e_chomper_target, e_chomper_target, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_demongate );
	self waittill( "chomper_reached_target" );
	e_target.b_hunted_by_chomper  = 0;
	e_target.b_is_bow_hit = 0;
}

function bow_demongate_chomper_acquire_new_target( e_player )
{
	if ( self flag::get( "demongate_chomper_despawning" ) )
		return;
	
	self.target_enemy = undefined;
	v_target_org = self.origin;
	n_target_radius = 1024;
	if ( IS_TRUE( self.b_look_for_target ) )
	{
		if ( zm_utility::is_player_valid( e_player ) )
			v_target_org = e_player.origin;
		
		n_target_radius = 1024;
	}
	a_ai_enemies = getAiTeamArray( level.zombie_team );
	a_valid_enemies = arraySortClosest( a_ai_enemies, v_target_org, a_ai_enemies.size, 0, n_target_radius );
	a_valid_enemies = array::filter( a_valid_enemies, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
	a_valid_enemies = array::filter( a_valid_enemies, 0, &bow_demongate_chomper_validate_target, self );
	if ( a_valid_enemies.size )
	{
		e_favorite_enemy = a_valid_enemies[ 0 ];
		e_favorite_enemy.b_hunted_by_chomper = 1;
		self.target_enemy = e_favorite_enemy;
		self notify( "demongate_chomper_found_target" );
	}
}

function bow_demongate_chomper_validate_target( e_favorite_enemy, e_chomper )
{
	return !( IS_TRUE( e_favorite_enemy.b_hunted_by_chomper ) && ( ( isDefined( e_favorite_enemy.completed_emerging_into_playable_area ) && e_favorite_enemy.completed_emerging_into_playable_area ) || !isDefined( e_favorite_enemy.completed_emerging_into_playable_area ) ) && ( e_favorite_enemy.archetype === "zombie" && IS_TRUE( e_favorite_enemy.completed_emerging_into_playable_area ) ) || ( e_favorite_enemy.archetype !== "zombie" ) && bulletTracePassed( e_favorite_enemy getEye(), e_chomper.origin, 0, e_chomper ) );
}