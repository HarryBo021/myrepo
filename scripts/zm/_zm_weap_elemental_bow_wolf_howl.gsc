#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_elemental_bow;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace _zm_weap_elemental_bow_wolf_howl;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_wolf_howl", &__init__, &__main__, undefined )

function __init__()
{
	level.w_bow_wolf_howl = getWeapon( "elemental_bow_wolf_howl" );
	level.w_bow_wolf_howl_upgraded = getWeapon( "elemental_bow_wolf_howl4" );
	clientfield::register( "toplayer", "elemental_bow_wolf_howl" + "_ambient_bow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_wolf_howl" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "elemental_bow_wolf_howl4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "wolf_howl_muzzle_flash", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "wolf_howl_arrow_charged_trail", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "wolf_howl_arrow_charged_spiral", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "wolf_howl_slow_snow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "zombie_hit_by_wolf_howl_charge", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "wolf_howl_zombie_explode_fx", VERSION_SHIP, 1, "counter" );
	callback::on_connect( &on_connect_bow_wolf_howl );
	zm_spawner::register_zombie_damage_callback( &bow_wolf_howl_damage_callback );
}

function __main__()
{
}

function on_connect_bow_wolf_howl()
{
	self endon( "disconnect" );
	self thread zm_weap_elemental_bow::bow_base_wield_watcher( "elemental_bow_wolf_howl" );
	self thread zm_weap_elemental_bow::bow_base_fired_watcher( "elemental_bow_wolf_howl", "elemental_bow_wolf_howl4", &bow_wolf_howl_fired );
	self thread zm_weap_elemental_bow::bow_base_impact_watcher( "elemental_bow_wolf_howl", "elemental_bow_wolf_howl4", &bow_wolf_howl_impact_explosion );
	while ( 1 )
	{
		self waittill( "weapon_change", newweapon );
		if ( newweapon.name === "elemental_bow_wolf_howl" )
			break;
		
	}
	bow_wolf_howl_setup_models();
}

function bow_wolf_howl_fired( projectile, weapon )
{
	if ( weapon.name == "elemental_bow_wolf_howl4" )
	{
		v_target_pos = ( projectile.origin + ( 0, 0, 0 ) ) + ( anglesToForward( projectile.angles ) * 64 );
		projectile thread bow_wolf_howl_arrow_remove();
		self thread bow_wolf_howl_charge_fired( v_target_pos );
	}
}

function bow_wolf_howl_impact_explosion( weapon, position, radius, attacker, normal )
{
	if ( weapon.name != "elemental_bow_wolf_howl4" )
		attacker clientfield::set( "elemental_bow_wolf_howl" + "_arrow_impact_fx", 1 );
	
}

function bow_wolf_howl_arrow_remove()
{
	self endon( "death" );
	util::wait_network_frame();
	self delete();
}

function bow_wolf_howl_charge_fired( v_target_pos )
{
	v_player_angles = anglesToForward( self getPlayerAngles() );
	v_up = anglesToUp( self getPlayerAngles() );
	n_dist_to_eye = length( v_target_pos - self getEye() );
	a_trace = bulletTrace( self getEye(), v_target_pos, 0, self );
	if ( a_trace[ "fraction" ] < 1 )
	{
		a_wolf_impact_models = self bow_wolf_howl_get_model_positions( a_trace[ "position" ], v_player_angles, v_up, 1 );
		util::wait_network_frame();
		if ( isDefined( a_wolf_impact_models ) )
			bow_wolf_howl_launch_at_models( a_trace[ "position" ], a_wolf_impact_models );
		
	}
	else
		bow_wolf_howl_launch( self, v_target_pos, v_player_angles, v_up, 1 );
	
}

function bow_wolf_howl_launch( e_player, v_target_pos, v_player_angles, v_up, b_in_fov, a_wolf_impact_models = undefined )
{
	if ( !zm_utility::is_player_valid( e_player ) )
		return;
	
	if ( b_in_fov )
	{
		a_wolf_impact_models = e_player bow_wolf_howl_get_model_positions( v_target_pos, v_player_angles, v_up, b_in_fov );
		if ( isDefined( a_wolf_impact_models ) )
			bow_wolf_howl_set_model_visiblity( a_wolf_impact_models, 1 );
		
	}
	if ( isDefined( a_wolf_impact_models ) )
	{
		e_wolf_howl_charge_base = a_wolf_impact_models[ 0 ];
		e_wolf_howl_charge_viz_wolf01 = a_wolf_impact_models[ 1 ];
		e_wolf_howl_charge_viz_wolf02 = a_wolf_impact_models[ 2 ];
		e_wolf_howl_charge_base.v_start_pos = v_target_pos;
		n_percent = 2560 - e_wolf_howl_charge_base.n_charge_power;
		v_target_pos = ( b_in_fov ? v_target_pos - ( 0, 0, 0 ) : v_target_pos - ( ( 0, 0, 0 ) * 2 ) );
		a_trace = bulletTrace( v_target_pos, v_target_pos + ( v_player_angles * n_percent ), 0, e_player );
		n_charge_percent = a_trace[ "fraction" ] * n_percent;
		if ( n_charge_percent > 32 )
		{
			e_wolf_howl_charge_base.n_charge_power = e_wolf_howl_charge_base.n_charge_power + n_charge_percent;
			v_target_pos = a_trace[ "position" ] - ( v_player_angles * 32 );
			n_in_fov_perc = n_charge_percent / 1920;
			str_return = "none";
			if ( n_in_fov_perc > 0 )
			{
				e_wolf_howl_charge_base moveTo( v_target_pos, n_in_fov_perc, n_in_fov_perc * .3, 0 );
				level thread bow_wolf_howl_whirlwind_think( e_player, a_wolf_impact_models, v_player_angles );
				level thread bow_wolf_howl_charge_base_trail( a_wolf_impact_models );
				if ( b_in_fov )
					level thread wolf_howl_arrow_charged_spiral_activate( e_player, a_wolf_impact_models );
				
				str_return = e_wolf_howl_charge_base util::waittill_any_return( "movedone", "mechz_impact" );
			}
			if ( str_return != "mechz_impact" && b_in_fov )
			{
				v_target_pos = e_wolf_howl_charge_base.origin;
				v_surface_normal = getNavmeshFaceNormal( e_wolf_howl_charge_base.origin, 2560 );
				if ( isDefined( v_surface_normal ) )
				{
					v_up = v_surface_normal;
					v_player_angles = vectorCross( v_up, anglestoright( e_wolf_howl_charge_viz_wolf01.angles ) );
					level thread bow_wolf_howl_launch( e_player, v_target_pos, v_player_angles, v_up, 0, a_wolf_impact_models );
					return;
				}
			}
		}
		bow_wolf_howl_launch_at_models( e_wolf_howl_charge_base.origin, a_wolf_impact_models );
	}
}

function bow_wolf_howl_setup_models()
{
	if ( !isDefined( self.a_wolf_howl_charge_base ) )
	{
		for ( i = 0; i < 2; i++ )
		{
			self.a_wolf_howl_charge_base[ i ] = zm_net::network_safe_spawn( "wolf_howl_charge_base", 2, "script_model", ( 100, 300, -200 ) );
			self.a_wolf_howl_charge_base[ i ] setModel( "tag_origin" );
			self.a_wolf_howl_charge_base[ i ].in_use = 0;
		}
		for ( i = 0; i < 2; i++ )
		{
			self.a_wolf_howl_charge_viz_wolf01[ i ] = zm_net::network_safe_spawn( "wolf_howl_charge_viz_wolf01", 2, "script_model", ( 100, 300, -200 ) );
			self.a_wolf_howl_charge_viz_wolf01[ i ] setModel( "tag_origin" );
		}
		for ( i = 0; i < 2; i++ )
		{
			self.a_wolf_howl_charge_viz_wolf02[ i ] = zm_net::network_safe_spawn( "wolf_howl_charge_viz_wolf02", 2, "script_model", ( 100, 300, -200 ) );
			self.a_wolf_howl_charge_viz_wolf02[ i ] setModel( "tag_origin" );
		}
	}
}

function bow_wolf_howl_get_model_positions( v_target_pos, v_player_angles, v_up, b_in_fov )
{
	v_player_angles_vec = vectorToAngles( v_player_angles );
	n_z_offset = v_up * -24;
	v_spawn_pos = v_target_pos;
	n_model_index = undefined;
	if ( !isDefined( self.a_wolf_howl_charge_base ) )
		bow_wolf_howl_setup_models();
	
	if ( b_in_fov )
	{
		foreach ( n_index, e_wolf_howl_charge_base in self.a_wolf_howl_charge_base )
		{
			if ( !e_wolf_howl_charge_base.in_use )
			{
				e_wolf_howl_charge_base.in_use = 1;
				e_wolf_howl_charge_base.n_charge_power = 0;
				n_model_index = n_index;
				break;
			}
		}
	}
	if ( isDefined( n_model_index ) )
	{
		self.a_wolf_howl_charge_base[ n_model_index ].origin = v_spawn_pos;
		self.a_wolf_howl_charge_base[ n_model_index ].angles = ( v_player_angles_vec[ 0 ], v_player_angles_vec[ 1 ], 0 );
		if ( b_in_fov )
		{
			self.a_wolf_howl_charge_viz_wolf01[ n_model_index ].origin = v_spawn_pos + n_z_offset;
			self.a_wolf_howl_charge_viz_wolf01[ n_model_index ].angles = v_player_angles_vec;
			self.a_wolf_howl_charge_viz_wolf02[ n_model_index ].origin = v_spawn_pos - n_z_offset;
			self.a_wolf_howl_charge_viz_wolf02[ n_model_index ].angles = v_player_angles_vec;
		}
		return array( self.a_wolf_howl_charge_base[ n_model_index ], self.a_wolf_howl_charge_viz_wolf01[ n_model_index ], self.a_wolf_howl_charge_viz_wolf02[ n_model_index ] );
	}
	return undefined;
}

function bow_wolf_howl_whirlwind_think( e_player, a_wolf_impact_models, v_player_angles )
{
	e_wolf_howl_charge_base = a_wolf_impact_models[ 0 ];
	e_wolf_howl_charge_base endon( "movedone" );
	e_wolf_howl_charge_base endon( "mechz_impact" );
	n_dist_sq_max = 409600;
	v_player_angles_vec = vectorToAngles( v_player_angles );
	n_offset = ( 1920 * .1 ) * 2;
	n_incriment_multi = 32;
	while ( 1 )
	{
		a_zombies = getAiTeamArray( level.zombie_team );
		a_filtered_zombies = array::get_all_closest( e_wolf_howl_charge_base.origin, a_zombies, undefined, undefined, n_offset );
		a_filtered_zombies = array::filter( a_filtered_zombies, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
		a_filtered_zombies = array::filter( a_filtered_zombies, 0, &bow_wolf_howl_validate_zombie );
		if ( a_filtered_zombies.size )
		{
			v_wolf_howl_charge_base_origin = e_wolf_howl_charge_base.origin;
			v_wolf_howl_charge_base_origin_off = v_wolf_howl_charge_base_origin + ( v_player_angles * n_offset );
			n_distance_from_start_to_end = distance( e_wolf_howl_charge_base.origin, e_wolf_howl_charge_base.v_start_pos );
			if ( n_distance_from_start_to_end < 256 )
			{
				n_incriment = n_distance_from_start_to_end / 256;
				n_max_distance = 64 - ( n_incriment_multi * n_incriment );
			}
			else
				n_max_distance = 32;
			
			foreach ( ai_enemy in a_filtered_zombies )
			{
				v_enemy_origin = ai_enemy getCentroid();
				v_safe_org = pointOnSegmentNearestToPoint( v_wolf_howl_charge_base_origin, v_wolf_howl_charge_base_origin_off, v_enemy_origin );
				v_angles_to_enemy = v_safe_org - v_enemy_origin;
				if ( abs( v_angles_to_enemy[ 2 ] ) > 72 )
					continue;
				
				v_angles_to_enemy = ( v_angles_to_enemy[ 0 ], v_angles_to_enemy[ 1 ], 0 );
				n_length = length( v_angles_to_enemy );
				if ( n_length > n_max_distance )
					continue;
				
				ai_enemy.b_bow_wolf_howl_marked = 1;
				if ( ai_enemy.archetype === "mechz" )
				{
					if ( n_length < 24 )
						level thread bow_wolf_howl_hit_mechz( e_player, ai_enemy, e_wolf_howl_charge_base );
					else
						ai_enemy.b_bow_wolf_howl_marked = 0;
					
					continue;
				}
				if ( zm_utility::is_player_valid( e_player ) && ( level.round_number < 26 || ( level.round_number >= 26 && distanceSquared( e_player.origin, ai_enemy.origin ) < n_dist_sq_max ) ) )
				{
					ai_enemy.b_is_bow_hit = 1;
					n_dist_percent = 75 * ( n_length / n_max_distance );
					v_angles_to_charge_vec = vectorToAngles( ai_enemy.origin - e_wolf_howl_charge_base.origin );
					v_calc = ( ( v_angles_to_charge_vec[ 1 ] - v_player_angles_vec[ 1 ] ) > 0 ? 1 : -1 );
					n_dist_percent = n_dist_percent * v_calc;
					v_launch = vectorNormalize( anglesToForward( ( 0, v_player_angles_vec[ 1 ] + n_dist_percent, 0 ) ) );
					level thread bow_wolf_howl_launch_zombie( e_player, ai_enemy, v_launch );
					continue;
				}
				ai_enemy thread bow_wolf_howl_hit_zombie( v_safe_org );
			}
		}
		wait .1;
	}
}

function bow_wolf_howl_validate_zombie( ai_enemy )
{
	return !IS_TRUE( ai_enemy.b_bow_wolf_howl_marked );
}

function bow_wolf_howl_launch_zombie( e_player, ai_enemy, v_launch )
{
	if ( ai_enemy.archetype === "zombie" )
	{
		n_z_launch_min = 45;
		n_z_launch_max = 90;
		ai_enemy startRagdoll();
		ai_enemy launchRagdoll( ( 90 * v_launch ) + ( 0, 0, randomFloatRange( n_z_launch_min, n_z_launch_max ) ) );
		ai_enemy thread bow_wolf_howl_explode_zombie_delayed();
		wait .1;
		ai_enemy clientfield::set( "zombie_hit_by_wolf_howl_charge", 1 );
	}
	ai_enemy doDamage( ai_enemy.health, ai_enemy.origin, e_player, e_player, undefined, "MOD_UNKNOWN", 0, level.w_bow_wolf_howl_upgraded );
	ai_enemy.b_bow_wolf_howl_marked = 0;
	ai_enemy.b_is_bow_hit = 0;
}

function bow_wolf_howl_explode_zombie_delayed()
{
	self endon( "actor_corpse" );
	self thread bow_wolf_howl_explode_corpse();
	wait .7 + randomFloat( .5 );
	self notify( "bow_wolf_howl_exploded" );
	self thread do_zombie_explode();
}

function bow_wolf_howl_explode_corpse()
{
	self endon( "bow_wolf_howl_exploded" );
	self waittill( "actor_corpse", e_corpse );
	e_corpse thread do_zombie_explode();
}

function do_zombie_explode()
{
	self zombie_utility::zombie_eye_glow_stop();
	self clientfield::increment( "wolf_howl_zombie_explode_fx" );
	self ghost();
	self util::delay( .25, undefined, &zm_utility::self_delete );
}

function bow_wolf_howl_hit_zombie( ai_zombie )
{
	self endon( "death" );
	if ( IS_TRUE( self.isdog ) )
		n_damage = level.zombie_health;
	else if ( self.archetype === "zombie" )
		n_damage = level.zombie_health * .5;
	else
		n_damage = 0;
	
	if ( n_damage > 0 )
	{
		self thread zm_weap_elemental_bow::bow_base_do_knockdown( ai_zombie );
		self doDamage( n_damage, self.origin, self, self, undefined, "MOD_UNKNOWN", 0, level.w_bow_wolf_howl_upgraded );
		wait 2.5;
		self.b_bow_wolf_howl_marked = 0;
	}
}

function bow_wolf_howl_hit_mechz( e_player, ai_mechz, e_wolf_howl_charge_base )
{
	wait .1;
	if ( isDefined( ai_mechz ) && isalive( ai_mechz ) )
	{
		n_mexhz_max_health = level.mechz_health;
		
		n_damage = ( n_mexhz_max_health * .4 ) / .2;
		ai_mechz doDamage( n_damage, ai_mechz getCentroid(), e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_wolf_howl_upgraded );
		v_hit_origin = ai_mechz getCentroid() - ( anglesToForward( e_wolf_howl_charge_base.angles ) * 96 );
		e_wolf_howl_charge_base.origin = v_hit_origin;
		WAIT_SERVER_FRAME;
		e_wolf_howl_charge_base notify( "mechz_impact" );
		ai_mechz.b_bow_wolf_howl_marked = 0;
	}
}

function bow_wolf_howl_launch_at_models( v_hit_pos, a_wolf_impact_models )
{
	e_wolf_howl_charge_base = a_wolf_impact_models[ 0 ];
	e_wolf_howl_charge_viz_wolf01 = a_wolf_impact_models[ 1 ];
	e_wolf_howl_charge_viz_wolf02 = a_wolf_impact_models[ 2 ];
	e_wolf_howl_charge_base clientfield::set( "elemental_bow_wolf_howl4" + "_arrow_impact_fx", 1 );
	e_wolf_howl_charge_base notify( "elemental_bow_wolf_howl4_fired" );
	a_zombies = getAiTeamArray( level.zombie_team );
	a_filtered_zombies = array::get_all_closest( v_hit_pos, a_zombies, undefined, undefined, 256 );
	a_filtered_zombies = array::filter( a_filtered_zombies, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
	a_filtered_zombies = array::filter( a_filtered_zombies, 0, &bow_wolf_howl_validate_zombie );
	foreach ( ai_enemy in a_filtered_zombies )
		ai_enemy thread bow_wolf_howl_hit_zombie( v_hit_pos );
	
	e_wolf_howl_charge_base clientfield::set( "wolf_howl_arrow_charged_trail", 0 );
	e_wolf_howl_charge_viz_wolf01 clientfield::set( "wolf_howl_arrow_charged_spiral", 0 );
	e_wolf_howl_charge_viz_wolf02 clientfield::set( "wolf_howl_arrow_charged_spiral", 0 );
	bow_wolf_howl_set_model_visiblity( a_wolf_impact_models, 0 );
	e_wolf_howl_charge_base.in_use = 0;
	util::wait_network_frame();
	e_wolf_howl_charge_base clientfield::set( "elemental_bow_wolf_howl4" + "_arrow_impact_fx", 0 );
}

function bow_wolf_howl_set_model_visiblity( a_wolf_impact_models, b_show )
{
	if ( b_show )
		array::run_all( a_wolf_impact_models, &show );
	else
		array::run_all( a_wolf_impact_models, &ghost );
	
}

function bow_wolf_howl_charge_base_trail( a_wolf_impact_models )
{
	e_wolf_howl_charge_base = a_wolf_impact_models[ 0 ];
	e_wolf_howl_charge_viz_wolf01 = a_wolf_impact_models[ 1 ];
	e_wolf_howl_charge_viz_wolf02 = a_wolf_impact_models[ 2 ];
	e_wolf_howl_charge_base endon( "movedone" );
	e_wolf_howl_charge_base endon( "mechz_impact" );
	e_wolf_howl_charge_base thread bow_wolf_howl_charge_viz_trail( e_wolf_howl_charge_viz_wolf01, 1 );
	e_wolf_howl_charge_base thread bow_wolf_howl_charge_viz_trail( e_wolf_howl_charge_viz_wolf02, -1 );
	while ( 1 )
	{
		e_wolf_howl_charge_base rotateRoll( 360, .6 );
		wait .6;
	}
}

function bow_wolf_howl_charge_viz_trail( e_wolf_howl_charge_viz_wolf, n_multi )
{
	self endon( "movedone" );
	self endon( "mechz_impact" );
	while ( 1 )
	{
		v_up = anglesToUp( self.angles );
		v_offset = ( v_up * 24 ) * n_multi;
		e_wolf_howl_charge_viz_wolf.origin = self.origin + v_offset;
		WAIT_SERVER_FRAME;
	}
}

function wolf_howl_arrow_charged_spiral_activate( e_player, a_wolf_impact_models )
{
	e_wolf_howl_charge_base = a_wolf_impact_models[ 0 ];
	e_wolf_howl_charge_viz_wolf01 = a_wolf_impact_models[ 1 ];
	e_wolf_howl_charge_viz_wolf02 = a_wolf_impact_models[ 2 ];
	e_wolf_howl_charge_base endon( "elemental_bow_wolf_howl4_fired" );
	if ( zm_utility::is_player_valid( e_player ) )
		e_player clientfield::set_to_player( "wolf_howl_muzzle_flash", 1 );
	
	e_wolf_howl_charge_base clientfield::set( "wolf_howl_arrow_charged_trail", 1 );
	e_wolf_howl_charge_viz_wolf01 clientfield::set( "wolf_howl_arrow_charged_spiral", 1 );
	e_wolf_howl_charge_viz_wolf02 clientfield::set( "wolf_howl_arrow_charged_spiral", 1 );
}

function bow_wolf_howl_damage_callback( mod, hit_location, hit_origin, e_player, amount, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel )
{
	if ( isalive( self ) && !IS_TRUE( self.isdog ) && isSubStr( weapon.name, "elemental_bow_wolf_howl" ) && mod !== "MOD_MELEE" )
	{
		if ( weapon.name != "elemental_bow_wolf_howl4" )
		{
			self notify( "bow_wolf_howl_zombie_upgraded_hit" );
			self thread bow_wolf_howl_zombie_upgraded_hit( e_player, amount, hit_origin, weapon );
		}
		return 1;
	}
	return 0;
}

function bow_wolf_howl_zombie_upgraded_hit( e_player, n_damage, v_hit_origin, weapon )
{
	self endon( "death" );
	self endon( "bow_wolf_howl_zombie_upgraded_hit" );
	self clientfield::set( "wolf_howl_slow_snow_fx", 1 );
	if ( isDefined( level.zombie_vars[ e_player.team ][ "zombie_insta_kill" ] ) && level.zombie_vars[ e_player.team ][ "zombie_insta_kill" ] )
	{
		if ( self.archetype === "mechz" )
			self doDamage( n_damage, v_hit_origin, e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_wolf_howl );
		else
			self doDamage( self.health, self.origin, e_player, e_player, undefined, "MOD_UNKNOWN", 0, level.w_bow_wolf_howl );
		
	}
	else
	{
		self thread bow_wolf_howl_slow_reset_on_death();
		if ( distance2dSquared( v_hit_origin, self.origin ) < 9216 )
			self zm_weap_elemental_bow::bow_base_do_knockdown( v_hit_origin );
		
		n_timer = 0;
		n_amount_in_scope = 1;
		if ( !isDefined( self.n_bow_wolf_howl_slowed_rate ) )
			self.n_bow_wolf_howl_slowed_rate = 1;
		
		while ( n_amount_in_scope > .7 )
		{
			n_amount_in_scope = n_amount_in_scope - ( ( n_amount_in_scope - .7 ) * .2 );
			if ( n_amount_in_scope < .71 )
				n_amount_in_scope = .7;
			
			self.n_bow_wolf_howl_slowed_rate = ( n_amount_in_scope < self.n_bow_wolf_howl_slowed_rate ? n_amount_in_scope : self.n_bow_wolf_howl_slowed_rate );
			self asmSetAnimationRate( self.n_bow_wolf_howl_slowed_rate );
			n_timer = n_timer + .1;
			wait .1;
		}
		self asmSetAnimationRate( .7 );
		wait 4;
		n_timer = 0;
		self.n_bow_wolf_howl_slowed_rate = .73;
		while ( self.n_bow_wolf_howl_slowed_rate < 1 )
		{
			self.n_bow_wolf_howl_slowed_rate = self.n_bow_wolf_howl_slowed_rate + ( ( self.n_bow_wolf_howl_slowed_rate - .7 ) * .05 );
			if ( self.n_bow_wolf_howl_slowed_rate > 1 )
				self.n_bow_wolf_howl_slowed_rate = 1;
			
			self asmSetAnimationRate( self.n_bow_wolf_howl_slowed_rate );
			n_timer = n_timer + .1;
			wait .1;
		}
		self clientfield::set( "wolf_howl_slow_snow_fx", 0 );
		self.n_bow_wolf_howl_slowed_rate = 1;
		self asmSetAnimationRate( 1 );
	}
}

function bow_wolf_howl_slow_reset_on_death()
{
	self waittill( "death" );
	if ( isDefined( self ) )
		self asmSetAnimationRate( 1 );
	
}
