#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_util;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_net;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_slowgun.gsh;

#precache( "fx", "weapon/paralyzer/fx_paralyzer_hit_noharm" );
#precache( "fx", "weapon/paralyzer/fx_paralyzer_hit_noharm_view" );

#namespace zm_weap_slowgun; 

REGISTER_SYSTEM( "zm_weap_slowgun", &__init__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{		
	clientfield::register( "actor", "anim_rate", VERSION_SHIP, 5, "float" );
	clientfield::register( "allplayers", "anim_rate", VERSION_SHIP, 5, "float" );
	clientfield::register( "toplayer", "sndParalyzerLoop", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "slowgun_fx", VERSION_SHIP, 3, "int" );
	clientfield::register( "toplayer", "slowgun_fx", VERSION_SHIP, 1, "int" );
	
	level._effect[ "player_slowgun_sizzle_ug" ] = "weapon/paralyzer/fx_paralyzer_hit_noharm";
	level._effect[ "player_slowgun_sizzle_1st" ] = "weapon/paralyzer/fx_paralyzer_hit_noharm_view";
	
	level.sliquifier_distance_checks = 0;
	level.slowgun_damage = 40;
	level.slowgun_damage_ug = 60;
	level.slowgun_damage_mod = "MOD_PROJECTILE_SPLASH";
	
	zm_spawner::add_custom_zombie_spawn_logic( &slowgun_on_zombie_spawned );
	
	callback::on_connect( &slowgun_player_connect );
	
	zm_spawner::register_zombie_damage_callback( &slowgun_zombie_damage_response );
	zm_spawner::register_zombie_death_event_callback( &slowgun_zombie_death_response );
		
}

function slowgun_player_connect()
{
	self thread watch_slowgun_fired();
	self thread watch_reset_anim_rate();
	self thread sndwatchforweapswitch();
}

function sndwatchforweapswitch()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "weapon_change", weapon );
		if ( weapon.name == SLOWGUN_WEAPONFILE || weapon.name == SLOWGUN_UPGRADED_WEAPONFILE )
		{
			self clientfield::set_to_player( "sndParalyzerLoop", 1 );
			self waittill( "weapon_change" );
			self clientfield::set_to_player( "sndParalyzerLoop", 0 );
		}
	}
}

function watch_reset_anim_rate()
{
	self set_anim_rate( 1 );
	self clientfield::set_to_player( "slowgun_fx", 0 );
	while ( 1 )
	{
		self util::waittill_any( "spawned", "entering_last_stand", "player_revived", "player_suicide", "respawned" );
		self clientfield::set_to_player( "slowgun_fx", 0 );
		self set_anim_rate( 1 );
	}
}

function watch_slowgun_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	for ( ;; )
	{
		self waittill( "weapon_fired", str_weapon );
		if ( str_weapon.name == SLOWGUN_WEAPONFILE )
			self slowgun_fired( 0 );
		else if ( str_weapon.name == SLOWGUN_UPGRADED_WEAPONFILE )
			self slowgun_fired( 1 );
		
	}
}

function slowgun_fired( upgraded )
{
	origin = self getWeaponMuzzlePoint();
	forward = self getWeaponForwardDir();

	targets = self get_targets_in_range( upgraded, origin, forward );
	
	if ( targets.size )
	{
		foreach ( target in targets )
		{
			if ( isPlayer( target ) )
			{
				if ( zm_utility::is_player_valid( target ) && self != target )
					target thread player_paralyzed( self, upgraded );
				
			}
			if ( isDefined( target.paralyzer_hit_callback ) )
				target thread [[ target.paralyzer_hit_callback ]]( self, upgraded );
			
			target thread zombie_paralyzed( self, upgraded );
		}
	}
	dot = vectorDot( forward,  ( 0, 0, -1 ) );
	if ( dot > .8 )
		self thread player_paralyzed( self, upgraded );
	
}

function slowgun_get_enemies_in_range( upgraded, position, forward, possible_targets )
{
	inner_range = 12;
	outer_range = 660;
	cylinder_radius = 48;
	level.slowgun_enemies = [];
	view_pos = position;
	
	if ( !isDefined( possible_targets ) )
		return level.slowgun_enemies;
	
	slowgun_inner_range_squared = inner_range * inner_range;
	slowgun_outer_range_squared = outer_range * outer_range;
	cylinder_radius_squared = cylinder_radius * cylinder_radius;
	forward_view_angles = forward;
	end_pos = view_pos + vectorScale( forward_view_angles, outer_range );

	for ( i = 0; i < possible_targets.size; i++ )
	{
		if ( !isDefined( possible_targets[ i ] ) || !isAlive( possible_targets[ i ] ) )
			continue;
		
		test_origin = possible_targets[ i ] getCentroid();
		test_range_squared = distanceSquared( view_pos, test_origin );
		if ( test_range_squared > slowgun_outer_range_squared )
				continue;
			
		normal = vectorNormalize( test_origin - view_pos );
		dot = vectorDot( forward_view_angles, normal );
		if ( dot < 0 )
			continue;
		
		radial_origin = pointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );
		if ( distanceSquared( test_origin, radial_origin ) > cylinder_radius_squared )
			continue;
		
		if ( possible_targets[ i ] damageConeTrace( view_pos, self ) == 0 )
			continue;
		
		level.slowgun_enemies[ level.slowgun_enemies.size ] = possible_targets[ i ];
	}
	return level.slowgun_enemies;
}

function get_targets_in_range( upgraded, position, forward )
{
	if ( !isDefined( self.slowgun_targets ) || ( getTime() - self.slowgun_target_time ) > 150 )
	{
		targets = [];
		possible_targets = getAiSpeciesArray( level.zombie_team, "all" );
		possible_targets = arrayCombine( possible_targets, getPlayers(), 1, 0 );
		if ( isDefined( level.possible_slowgun_targets ) && level.possible_slowgun_targets.size > 0 )
			possible_targets = arrayCombine( possible_targets, level.possible_slowgun_targets, 1, 0 );
		
		targets = slowgun_get_enemies_in_range( 0, position, forward, possible_targets );
		self.slowgun_targets = targets;
		self.slowgun_target_time = getTime();
	}
	return self.slowgun_targets;
}

function slowgun_on_zombie_spawned()
{
	self set_anim_rate( 1 );
	self.paralyzer_hit_callback = &zombie_paralyzed;
	self.paralyzer_damaged_multiplier = 1;
	self.paralyzer_score_time_ms = getTime();
	self.paralyzer_slowtime = 0;
	self clientfield::set( "slowgun_fx", 0 );
}

function can_be_paralyzed( zombie )
{
	if ( IS_TRUE( zombie.is_ghost ) )
		return 0;
	
	if ( IS_TRUE( zombie.guts_explosion ) )
		return 0;
	
	if ( isDefined( zombie ) && zombie.health > 0 )
		return 1;
	
	return 0;
}

function set_anim_rate( rate )
{
	if ( isDefined( self ) )
	{
		self.slowgun_anim_rate = rate;
		if ( !IS_TRUE( level.ignore_slowgun_anim_rates ) && !IS_TRUE( self.ignore_slowgun_anim_rates ) )
		{
			self clientfield::set( "anim_rate", rate );
			qrate = self clientfield::get( "anim_rate" );
			
			if ( isPlayer( self ) )
				self setEntityAnimRate( qrate );
			else
				self asmSetAnimationRate( qrate );
			
			if ( isDefined( self.set_anim_rate ) )
				self [[ self.set_anim_rate ]]( rate );
			
		}
	}
}

function reset_anim()
{
	util::wait_network_frame();
	if ( !isDefined( self ) )
		return;
	
	if ( IS_TRUE( self.is_traversing ) )
	{
		animstate = self getAnimStateFromAsd();
		if ( !IS_TRUE( self.no_restart ) )
		{
			self.no_restart = 1;
			animstate += "_no_restart";
		}
		substate = self getAnimSubstateFromAsd();
		self setAnimStateFromAsd( animstate, substate );
	}
	else
	{
		self.needs_run_update = 1;
		self notify( "needs_run_update" );
	}
}

function zombie_change_rate( time, newrate )
{
	self set_anim_rate( newrate );
	
	if ( isDefined( self.reset_anim ) )
		self thread [[ self.reset_anim ]]();
	else
		self thread reset_anim();
	
	if ( time > 0 )
		wait time;
	
}

function zombie_slow_for_time( time, multiplier )
{
	if ( !isDefined( multiplier ) )
		multiplier = 2;
	
	paralyzer_time_per_frame = .1 * ( 1 + multiplier );
	if ( self.paralyzer_slowtime <= time )
		self.paralyzer_slowtime = time + paralyzer_time_per_frame;
	else
		self.paralyzer_slowtime += paralyzer_time_per_frame;
	
	if ( !isDefined( self.slowgun_anim_rate ) )
		self.slowgun_anim_rate = 1;
	
	if ( !isDefined( self.slowgun_desired_anim_rate ) )
		self.slowgun_desired_anim_rate = 1;
	
	if ( self.slowgun_desired_anim_rate > .3 )
		self.slowgun_desired_anim_rate -= .2;
	else
		self.slowgun_desired_anim_rate = .05;
	
	if ( IS_TRUE( self.slowing ) )
		return;
	
	self.slowing = 1;
	self.preserve_asd_substates = 1;
	self playLoopSound( "wpn_paralyzer_slowed_loop", .1 );
	while ( self.paralyzer_slowtime > 0 && isAlive( self ) )
	{
		if ( self.paralyzer_slowtime < .1 )
			self.slowgun_desired_anim_rate = 1;
		else if ( self.paralyzer_slowtime < ( 2 * .1 ) )
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, .8 );
		else if ( self.paralyzer_slowtime < ( 3 * .1 ) )
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, .6 );
		else if ( self.paralyzer_slowtime < ( 4 * .1 ) )
			self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, .4 );
		else
		{
			if ( self.paralyzer_slowtime < ( 5 * .1 ) )
				self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, .2 );
			
		}
		if ( self.slowgun_desired_anim_rate == self.slowgun_anim_rate )
		{
			self.paralyzer_slowtime -= .1;
			wait .1;
			continue;
		}
		else if ( self.slowgun_desired_anim_rate >= self.slowgun_anim_rate )
		{
			new_rate = self.slowgun_desired_anim_rate;
			if ( ( self.slowgun_desired_anim_rate - self.slowgun_anim_rate ) > .2 )
				new_rate = self.slowgun_anim_rate + .2;
			
			self.paralyzer_slowtime -= .1;
			zombie_change_rate( .1, new_rate );
			self.paralyzer_damaged_multiplier = 1;
			continue;
		}
		else
		{
			if ( self.slowgun_desired_anim_rate <= self.slowgun_anim_rate )
			{
				new_rate = self.slowgun_desired_anim_rate;
				if ( ( self.slowgun_anim_rate - self.slowgun_desired_anim_rate ) > .2 )
					new_rate = self.slowgun_anim_rate - .2;
				
				self.paralyzer_slowtime -= .25;
				zombie_change_rate( .25, new_rate );
			}
		}
	}
	if ( self.slowgun_anim_rate < 1 )
		self zombie_change_rate( 0, 1 );
	
	self.preserve_asd_substates = 0;
	self.slowing = 0;
	self.paralyzer_damaged_multiplier = 1;
	self clientfield::set( "slowgun_fx", 0 );
	self stopLoopSound( .1 );
}

function zombie_paralyzed( player, upgraded )
{
	if ( !can_be_paralyzed( self ) )
		return;
	
	insta = player zm_powerups::is_insta_kill_active();
	if ( upgraded )
		self clientfield::set( "slowgun_fx", 5 );
	else
		self clientfield::set( "slowgun_fx", 1 );
	
	if ( self.slowgun_anim_rate <= .1 || insta && self.slowgun_anim_rate <= .5 )
	{
		if ( upgraded )
			damage = level.slowgun_damage_ug;
		else
			damage = level.slowgun_damage;
		
		damage *= randomFloatRange( 0.667, 1.5 );
		damage *= self.paralyzer_damaged_multiplier;
		if ( insta )
			damage = self.health + 666;
		
		if ( isAlive( self ) )
			self doDamage( damage, player.origin, player, player, "none", level.slowgun_damage_mod, 0, getWeapon( SLOWGUN_WEAPONFILE ) );
		
		self.paralyzer_damaged_multiplier *= 1.15;
	}
	else
		self.paralyzer_damaged_multiplier = 1;
	
	self zombie_slow_for_time( .2 );
}

function get_extra_damage( amount, mod, slow )
{
	mult = 1 - slow;
	return amount * slow;
}

function slowgun_zombie_damage_response( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	if ( !isDefined( self.damageweapon ) )
		return 0;
	
	if ( !self is_slowgun_damage( str_mod, self.damageweapon ) )
	{
		if ( isDefined( self.slowgun_anim_rate ) && self.slowgun_anim_rate < 1 && str_mod != level.slowgun_damage_mod )
		{
			extra_damage = get_extra_damage( n_amount, str_mod, self.slowgun_anim_rate );
			
			if ( extra_damage > 0 )
			{
				if ( isAlive( self ) )
					self doDamage( extra_damage, v_hit_origin, e_player, e_player, str_hit_location, level.slowgun_damage_mod, 0, self.damageweapon );
				
				if ( !isAlive( self ) )
					return 1;
				
			}
		}
		return 0;
	}
	if ( ( getTime() - self.paralyzer_score_time_ms ) >= 500 )
	{
		self.paralyzer_score_time_ms = getTime();
		e_player zm_score::player_add_points( "damage", str_mod, str_hit_location, self.isdog, level.zombie_team );
	}
	if ( e_player zm_powerups::is_insta_kill_active() )
		n_amount = self.health + 666;
	
	if ( isAlive( self ) )
		self doDamage( n_amount, v_hit_origin, e_player, e_player, str_hit_location, str_mod, 0, self.damageweapon );
	
	return 1;
}

function explosion_choke()
{
	if ( !isDefined( level.slowgun_explosion_time ) )
		level.slowgun_explosion_time = 0;
	
	if ( level.slowgun_explosion_time != getTime() )
	{
		level.slowgun_explosion_count = 0;
		level.slowgun_explosion_time = getTime();
	}
	while ( level.slowgun_explosion_count > 4 )
	{
		wait .05;
		if ( level.slowgun_explosion_time != getTime() )
		{
			level.slowgun_explosion_count = 0;
			level.slowgun_explosion_time = getTime();
		}
	}
	level.slowgun_explosion_count++;
	return;
}

function explode_into_dust( player, upgraded )
{
	if ( isDefined( self.marked_for_insta_upgraded_death ) )
		return;
	
	explosion_choke();
	
	if ( upgraded )
		self clientfield::set( "slowgun_fx", 6 );
	else
		self clientfield::set( "slowgun_fx", 2 );
	
	self.guts_explosion = 1;
	self ghost();
}

function slowgun_zombie_death_response()
{
	if ( !isDefined( self.damageweapon ) )
		return 0;
	
	if ( !self is_slowgun_damage( self.damagemod, self.damageweapon ) )
		return 0;
	
	self stopLoopSound( .1 );
	
	level zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
	self thread explode_into_dust( self.attacker, self.damageweapon == SLOWGUN_UPGRADED_WEAPONFILE );
	return 1;
}

function is_slowgun_damage( mod, weapon )
{
	if ( isDefined( weapon.name ) && ( weapon.name == SLOWGUN_WEAPONFILE || weapon.name == SLOWGUN_UPGRADED_WEAPONFILE ) )
		return 1;
	
	return 0;
}

function get_ahead_ent()
{
	velocity = self getVelocity();
	if ( lengthSquared( velocity ) < 225 )
		return undefined;
	
	start = self getEyeApprox();
	end = start + ( velocity * .25 );
	mins = ( 0, 1, 0 );
	maxs = ( 0, 1, 0 );
	trace = physicsTrace( start, end, vectorScale( ( 0, 1, 0 ), 15 ), vectorScale( ( 0, 1, 0 ), 15 ), self );
	if ( isDefined( trace[ "entity" ] ) )
		return trace[ "entity" ];
	else if ( trace[ "fraction" ] < .99 || trace[ "surfacetype" ] != "none" )
		return level;
		
	return undefined;
}

function bump()
{
	self playRumbleOnEntity( "damage_heavy" );
	earthquake( .5, .15, self.origin, 1000, self );
}

function player_fly_rumble()
{
	self endon( "player_slow_stop_flying" );
	self endon( "disconnect" );
	self endon( "platform_collapse" );
	self.slowgun_flying = 1;
	last_ground = self getGroundEnt();
	last_ahead = undefined;
	while ( 1 )
	{
		ground = self getGroundEnt();
		if ( isDefined( ground ) != isDefined( last_ground ) || ground != last_ground )
		{
			if ( isDefined( ground ) )
				self bump();
			
		}
		if ( isDefined( ground ) && !self.slowgun_flying )
		{
			self thread dont_tread_on_z();
			return;
		}
		last_ground = ground;
		
		if ( isDefined( ground ) )
			last_ahead = undefined;
		else
		{
			ahead = self get_ahead_ent();
			if ( isDefined( ahead ) )
			{
				if ( isDefined( ahead ) != isDefined( last_ahead ) || ahead != last_ahead )
				{
					self playSoundToPlayer( "zmb_invis_barrier_hit", self );
					chance = zm_audio::get_response_chance( "invisible_collision" );
					if ( chance > randomintrange( 1, 100 ) )
						self thread zm_audio::create_and_play_dialog( "general", "invisible_collision" );
					
					self bump();
				}
			}
			last_ahead = ahead;
		}
		wait .15;
	}
}

function dont_tread_on_z()
{
	if ( !isDefined( level.ghost_head_damage ) )
		level.ghost_head_damage = 30;
	
	ground = self getGroundEnt();
	if ( isDefined( ground ) && isDefined( ground.team ) && ground.team == level.zombie_team )
	{
		first_ground = ground;
		while ( !isDefined( ground ) || isDefined( ground.team ) && ground.team == level.zombie_team )
		{
			if ( IS_TRUE( self.slowgun_flying ) )
				return;
			
			if ( isDefined( ground ) )
				self doDamage( level.ghost_head_damage, ground.origin, ground );
			else
				self doDamage( level.ghost_head_damage, first_ground.origin, first_ground );
			
			wait 0.25;
			ground = self getGroundEnt();
		}
	}
}

function player_slow_for_time( time )
{
	self notify( "player_slow_for_time" );
	self endon( "player_slow_for_time" );
	self endon( "disconnect" );
	
	if ( !IS_TRUE( self.slowgun_flying ) )
		self thread player_fly_rumble();
	
	self clientfield::set_to_player( "slowgun_fx", 1 );
	self set_anim_rate( .05 );
	wait time;
	self set_anim_rate( 1 );
	self clientfield::set_to_player( "slowgun_fx", 0 );
	self.slowgun_flying = 0;
}

function player_paralyzed( byplayer, upgraded )
{
	self notify( "player_paralyzed" );
	self endon( "player_paralyzed" );
	self endon( "death" );
	if ( isDefined( level.slowgun_allow_player_paralyze ) )
	{
		if ( !( self [[ level.slowgun_allow_player_paralyze ]]() ) )
			return;
		
	}
	if ( self != byplayer )
	{
		sizzle = "player_slowgun_sizzle";
		if ( upgraded )
			sizzle = "player_slowgun_sizzle_ug";
		
		if ( isDefined( level._effect[ sizzle ] ) )
			playFxOnTag( level._effect[ sizzle ], self, "j_spinelower" );
		
	}
	self thread player_slow_for_time( .25 );
}

function is_falling()
{
	velo = self getVelocity();
	if ( velo[ 2 ] < 0 )
		return 1;
	
	return 0;
}
/*
function player_slowgun_fly() 
{
	self endon( "disconnect" );
	self notify( "player_slowgun_fly" );
	self endon( "player_slowgun_fly" );
	
	n_max_climb_speed = 50;
	n_incriment_climb_speed = 10;
	n_max_climb_height = 255;
	while ( 1 )
	{
		wait .05;
		w_weapon = self getCurrentWeapon();
		if ( !isDefined( w_weapon ) )
			continue;
		
		v_current_velocity = self getVelocity();
		if ( !self laststand::player_is_in_laststand() && is_slowgun_damage( undefined, w_weapon ) && self isFiring() && !self isMeleeing() && !self isOnGround() ) 
		{
			v_angles = anglesToForward( self getPlayerAngles() );
			if ( v_angles[ 2 ] > -.8 )
				continue;
			
			self.b_paralyser_gravity_on = 1;
			self setPlayerGravity( 0 );
			
			if ( self is_falling() )
			{
				self setVelocity( ( self getVelocity()[ 0 ], self getVelocity()[ 1 ], self getVelocity()[ 2 ] + 10 ) );
				continue;
			}
			
			v_trace = physicsTraceEx( self.origin, self.origin - ( 0, 0, n_max_climb_height + 1 ), vectorScale( ( 0, 1, 0 ), 15 ), vectorScale( ( 0, 1, 0 ), 15 ), self );
			if ( ( !isDefined( v_trace ) || !isDefined( v_trace[ "position" ] ) ) || distance( v_trace[ "position" ], self.origin ) < n_max_climb_height )
			{
				if ( v_current_velocity[ 2 ] <= n_max_climb_speed )
					self setVelocity( ( v_current_velocity[ 0 ], v_current_velocity[ 1 ], v_current_velocity[ 2 ] + n_incriment_climb_speed ) );
				else if ( v_current_velocity[ 2 ] > n_max_climb_speed )
					self setVelocity( ( v_current_velocity[ 0 ], v_current_velocity[ 1 ], v_current_velocity[ 2 ] - n_incriment_climb_speed ) );
				else
					self setVelocity( ( v_current_velocity[ 0 ], v_current_velocity[ 1 ], v_current_velocity[ 2 ] ) );
			
			}
			else
				self setVelocity( ( v_current_velocity[ 0 ], v_current_velocity[ 1 ], 0 ) );
			
		}
		else
		{
			if ( IS_TRUE( self.b_paralyser_gravity_on ) )
			{
				self.b_paralyser_gravity_on = undefined;
				self clearPlayerGravity();
			}
		}
		
	}
}
*/