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
// #using scripts\zm\_zm_ai_mechz;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_elemental_bow;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace _zm_weap_elemental_bow_storm;

function autoexec __init__sytem__()
{
	system::register( "_zm_weap_elemental_bow_storm", &__init__, &__main__, undefined );
}

function __init__()
{
	level.w_bow_storm = getweapon( "elemental_bow_storm" );
	level.w_bow_storm_upgraded = getweapon( "elemental_bow_storm4" );
	clientfield::register( "toplayer", "elemental_bow_storm" + "_ambient_bow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_storm" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_storm4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "elem_storm_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "elem_storm_whirlwind_rumble", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "elem_storm_bolt_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "elem_storm_zap_ambient", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "elem_storm_shock_fx", VERSION_SHIP, 2, "int" );
	callback::on_connect( &on_connect_bow_storm );
}

function __main__()
{
}

function on_connect_bow_storm()
{
	self thread zm_weap_elemental_bow::bow_base_wield_watcher( "elemental_bow_storm" );
	self thread zm_weap_elemental_bow::bow_base_fired_watcher( "elemental_bow_storm", "elemental_bow_storm4" );
	self thread zm_weap_elemental_bow::bow_base_impact_watcher( "elemental_bow_storm", "elemental_bow_storm4", &bow_storm_impact_explosion );
}

function bow_storm_impact_explosion( weapon, v_position, radius, attacker, normal )
{
	self.ptr_bow_storm_fake_fire_impact = &bow_storm_fake_fire_impact;
	if ( isSubStr( weapon.name, "elemental_bow_storm4" ) )
	{
		v_safe_org = self zm_weap_elemental_bow::bow_get_impact_pos_on_navmesh( v_position, weapon.name, attacker, 64, self.ptr_bow_storm_fake_fire_impact );
		v_position = ( isDefined( v_safe_org ) ? v_safe_org : v_position );
		self thread bow_storm_create_storm( v_position + vectorScale( ( 0, 0, 1 ), 48 ) );
	}
	else
	{
		v_safe_org = self zm_weap_elemental_bow::bow_get_impact_pos_on_navmesh( v_position, weapon.name, attacker, 32, self.ptr_bow_storm_fake_fire_impact );
		v_position = ( isDefined( v_safe_org ) ? v_safe_org : v_position );
		self thread bow_storm_bolt_fire( v_position + vectorScale( ( 0, 0, 1 ), 32 ), 3.6, attacker, 0 );
	}
}

function bow_storm_bolt_fire( v_hit_pos, n_storm_lifetime, e_storm, b_multi )
{
	zombie_utility::set_zombie_var( "tesla_head_gib_chance", 75 );
	n_bolt_count = ( b_multi ? 4 : 1 );
	if ( !( isDefined( b_multi ) && b_multi ) )
	{
		e_storm = util::spawn_model( "tag_origin", v_hit_pos );
		e_storm.b_in_use = 1;
		e_storm.b_storm_active = 1;
	}
	if ( !isDefined( e_storm.a_storm_bolt_locs ) )
	{
		e_storm.a_storm_bolt_locs = [];
		for ( i = 0; i < n_bolt_count; i++ )
		{
			e_storm.a_storm_bolt_locs[ i ] = util::spawn_model( "tag_origin", e_storm.origin );
			util::wait_network_frame();
		}
	}
	foreach ( e_storm_bolt_loc in e_storm.a_storm_bolt_locs )
		e_storm_bolt_loc.b_bolt_struck = 0;
	
	e_storm.n_lifetime = n_storm_lifetime;
	n_bolt_lifetime = n_storm_lifetime + 1;
	
	n_storm_range = 160;
	n_bolt_lifetime_multi = .6;
	if ( b_multi )
	{
		n_storm_range = 320;
		n_bolt_lifetime_multi = 0.233;
	}
	if ( !IS_TRUE( b_multi ) )
		e_storm clientfield::set( "elem_storm_zap_ambient", 1 );
	
	while ( e_storm.n_lifetime > 0 && IS_TRUE( e_storm.b_in_use ) )
	{
		if ( e_storm.n_lifetime < n_bolt_lifetime )
		{
			e_bolt_loc = undefined;
			e_bolt_loc = e_storm bow_storm_get_bolt_location();
			if ( isDefined( e_bolt_loc ) )
			{
				a_storm_targets = e_storm bow_storm_storm_get_targets( n_storm_range, self );
				foreach ( ai_enemy in a_storm_targets )
				{
					if ( bulletTracePassed( ai_enemy getCentroid(), e_storm.origin, 0, e_storm ) )
					{
						ai_enemy thread bow_storm_bolt_hit_zombie( self, e_storm, e_bolt_loc, b_multi );
						break;
					}
				}
			}
			n_bolt_lifetime = e_storm.n_lifetime - n_bolt_lifetime_multi;
		}
		WAIT_SERVER_FRAME;
		e_storm.n_lifetime = e_storm.n_lifetime - .05;
	}
	if ( !IS_TRUE( b_multi ) )
		e_storm clientfield::set( "elem_storm_zap_ambient", 0 );
	
	if ( IS_TRUE( e_storm.b_storm_active ) )
	{
		util::wait_network_frame();
		e_storm delete();
		array::run_all( e_storm.a_storm_bolt_locs, &delete );
		if ( isDefined( e_storm.e_bow_storm_bolt_loc ) )
			e_storm.e_bow_storm_bolt_loc delete();
		
	}
	else
	{
		foreach ( e_storm_bolt_loc in e_storm.a_storm_bolt_locs )
			e_storm_bolt_loc clientfield::set( "elem_storm_bolt_fx", 0 );
		
	}
}

function bow_storm_storm_get_targets( n_storm_range, e_player )
{
	a_ai_enemies = getAiTeamArray( level.zombie_team );
	a_storm_targets = array::get_all_closest( self.origin, a_ai_enemies, undefined, undefined, n_storm_range );
	if ( zm_utility::is_player_valid( e_player ) )
		a_storm_targets = array::get_all_closest( e_player.origin, a_storm_targets );
	
	a_storm_targets = array::filter( a_storm_targets, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
	a_storm_targets = array::filter( a_storm_targets, 0, &bow_storm_bolt_can_strike );
	return a_storm_targets;
}

function bow_storm_bolt_can_strike( ai_enemy )
{
	return !IS_TRUE( ai_enemy.b_hit_by_bolt );
}

function bow_storm_get_bolt_location()
{
	foreach ( e_storm_bolt_loc in self.a_storm_bolt_locs )
	{
		if ( isDefined( e_storm_bolt_loc ) && isDefined( e_storm_bolt_loc.b_bolt_struck ) && !e_storm_bolt_loc.b_bolt_struck )
			return e_storm_bolt_loc;
		
	}
	return undefined;
}

function bow_storm_bolt_hit_zombie( e_player, e_storm, e_storm_bolt_loc, b_multi )
{
	if ( b_multi )
		v_storm_origin = e_storm.origin + ( 0, 0, randomIntRange( 0, 96 ) );
	else
		v_storm_origin = e_storm.origin;
	
	self.b_hit_by_bolt = 1;
	e_storm_bolt_loc.b_bolt_struck = 1;
	b_bow_storm_bolt_hit = 0;
	e_storm_bolt_loc.origin = v_storm_origin;
	v_storm_bolt_origin = v_storm_origin;
	v_storm_cent = self getCentroid();
	v_storm_angles_norm = vectorNormalize( v_storm_cent - v_storm_bolt_origin );
	v_storm_angles = vectorToAngles( v_storm_angles_norm );
	v_storm_angles = ( v_storm_angles[ 0 ], v_storm_angles[ 1 ], randomInt( 360 ) );
	e_storm_bolt_loc.angles = v_storm_angles;
	e_storm_bolt_loc linkTo( e_storm );
	
	WAIT_SERVER_FRAME;
	
	e_storm_bolt_loc clientfield::set( "elem_storm_bolt_fx", 1 );
	wait .2;
	
	if ( isDefined( self ) && isAlive( self ) )
	{
		if ( self.archetype === "mechz" )
		{
			n_mechz_health_max = level.mechz_health;
			
			n_mechz_health_perc = ( b_multi ? .03 : .01 );
			n_damage = ( n_mechz_health_max * n_mechz_health_perc ) / .2;
			str_damage_mod = "MOD_PROJECTILE_SPLASH";
			n_bow_storm_damage = self.health / .2;
		}
		else
		{
			n_damage = 4782;
			str_damage_mod = "MOD_UNKNOWN";
			n_bow_storm_damage = self.health;
		}
		b_instakill_active = 0;
		if ( isDefined( e_player ) && ( isDefined( level.zombie_vars[ e_player.team ][ "zombie_insta_kill" ] ) && level.zombie_vars[ e_player.team ][ "zombie_insta_kill" ] ) && self.archetype !== "mechz" )
			b_instakill_active = 1;
		
		if ( n_bow_storm_damage > n_damage && !b_instakill_active )
		{
			self doDamage( n_damage, self.origin, e_player, e_player, undefined, str_damage_mod, 0, level.w_bow_storm );
			if ( b_multi )
			{
				b_bow_storm_bolt_hit = 1;
				if ( self.archetype === "mechz" )
					self thread bow_storm_hit_mechz( e_player, v_storm_origin, e_storm );
				else
					self thread bow_storm_hit_zombie( e_player, v_storm_origin, e_storm );
				
			}
			else
				self.b_hit_by_bolt = 0;
			
		}
		else
			self thread bow_storm_bolt_kill_zombie( e_player, b_multi );
		
	}
	if ( b_bow_storm_bolt_hit )
		wait 2.166;
	
	e_storm_bolt_loc clientfield::set( "elem_storm_bolt_fx", 0 );
	e_storm_bolt_loc.b_bolt_struck = 0;
	e_storm_bolt_loc unLink();
}

function bow_storm_bolt_kill_zombie( e_player, b_multi )
{
	self endon( "death" );
	n_damage = self.health;
	str_damage_mod = "MOD_UNKNOWN";
	if ( b_multi )
	{
		if ( self.archetype === "zombie" )
		{
			if ( zm_weap_elemental_bow::is_bow_impact_valid( self ) )
			{
				self setPlayerCollision( 0 );
				self.b_is_bow_hit = 1;
				self clientfield::set( "elem_storm_shock_fx", 2 );
				self scene::play( "cin_zm_dlc1_zombie_dth_deathray_0" + randomIntRange( 1, 5 ), self );
				self clientfield::set( "elem_storm_shock_fx", 0 );
				self.b_is_bow_hit = 0;
				if ( b_multi )
					self zm_spawner::zombie_explodes_intopieces( 0 );
				
			}
		}
		else if ( self.archetype === "mechz" )
		{
			n_damage = self.health / .2;
			str_damage_mod = "MOD_PROJECTILE_SPLASH";
		}
	}
	else if ( self.archetype === "zombie" )
		self bow_storm_stun_zombie( 1 );
	
	if ( zm_utility::is_player_valid( e_player ) && isDefined( e_player.zapped_zombies ) && self.archetype === "zombie" )
	{
		e_player.zapped_zombies++;
		e_player notify( "zombie_zapped" );
	}
	w_bow_storm = ( b_multi ? level.w_bow_storm_upgraded : level.w_bow_storm );
	self doDamage( n_damage, self.origin, e_player, e_player, undefined, str_damage_mod, 0, w_bow_storm );
	self.b_hit_by_bolt = 0;
	self setPlayerCollision( 1 );
}

function bow_storm_hit_zombie( e_player, var_126c274b, e_storm )
{
	self endon( "death" );
	n_bolt_lifetime = 2.166;
	if ( e_storm.n_lifetime < 2.166 )
		n_bolt_lifetime = e_storm.n_lifetime;
	
	if ( n_bolt_lifetime > .5 )
		self bow_storm_stun_zombie( n_bolt_lifetime );
	
	self bow_storm_bolt_kill_zombie( e_player, 1 );
}

function bow_storm_stun_zombie( n_time )
{
	self endon( "death" );
	n_counter = 0;
	self clientfield::set( "elem_storm_shock_fx", 1 );
	while ( n_counter < n_time )
	{
		self.zombie_tesla_hit = 1;
		wait .2;
		n_counter = n_counter + .2;
	}
	self.zombie_tesla_hit = 0;
	self notify( "bow_storm_stun_zombie_over" );
	self clientfield::set( "elem_storm_shock_fx", 0 );
}

function bow_storm_hit_mechz( e_player, var_126c274b, e_storm )
{
	self endon( "death" );
	if ( !IS_TRUE( self.b_bow_storm_hit ) && e_storm.n_lifetime > 2.5 )
	{
		self.b_is_bow_hit = 1;
		self.b_bow_storm_hit = 1;
		// self.var_ab0efcf6 = self.origin;
		self thread scene::play( "cin_zm_dlc1_mechz_dth_deathray_01", self );
		self thread bow_storm_mechz_lift( e_storm );
		self thread bow_storm_strike_mechz( e_player, e_storm );
		util::waittill_any_ents_two( self, "mechz_zap_lift_end", e_storm, "elem_storm_whirlwind_done" );
		wait .1;
		self scene::stop( "cin_zm_dlc1_mechz_dth_deathray_01" );
		// self thread zm_ai_mechz::function_bb84a54( self );
		self.b_hit_by_bolt = 0;
		self.b_is_bow_hit = 0;
		self.b_bow_storm_mechz_lifted = 1;
		wait 16;
		self.b_bow_storm_mechz_lifted = 0;
		self.b_bow_storm_hit = 0;
	}
	else
		self.b_hit_by_bolt = 0;
	
}

function bow_storm_mechz_lift( e_storm )
{
	self endon( "death" );
	e_storm endon( "death" );
	e_storm endon( "elem_storm_whirlwind_done" );
	n_dist_offs = distance( self.origin, e_storm.origin ) + 200;
	n_dist = ( n_dist_offs > 320 ? 320 : n_dist_offs );
	n_dist_sq = n_dist * n_dist;
	while ( 1 )
	{
		if ( distanceSquared( self.origin, e_storm.origin ) > n_dist_sq )
		{
			self notify( "mechz_zap_lift_end" );
			break;
		}
		wait .2;
	}
}

function bow_storm_strike_mechz( e_player, e_storm )
{
	self endon( "death" );
	self endon( "mechz_zap_lift_end" );
	e_storm endon( "elem_storm_whirlwind_done" );
	if ( !isDefined( e_storm.e_bow_storm_bolt_loc ) )
		e_storm.e_bow_storm_bolt_loc = util::spawn_model( "tag_origin", self.origin );
	
	while ( 1 )
	{
		wait( 1.4 );
		self thread bow_storm_bolt_hit_zombie( e_player, e_storm, e_storm.e_bow_storm_bolt_loc, 1 );
	}
}

function bow_storm_create_storm( v_hit_pos )
{
	if ( !isDefined( self.a_bow_storm_bolt_locs ) )
	{
		self.a_bow_storm_bolt_locs = [];
		for ( i = 0; i < 1; i++ )
		{
			self.a_bow_storm_bolt_locs[ i ] = util::spawn_model( "tag_origin", ( 0, 0, 0 ), vectorScale( ( -1, 0, 0 ), 90 ) );
			self.a_bow_storm_bolt_locs[ i ].b_in_use = 0;
			util::wait_network_frame();
		}
	}
	if ( zm_utility::is_player_valid( self ) )
	{
		e_bolt_loc = self bow_storm_get_bolt_loc();
		if ( isDefined( e_bolt_loc ) )
		{
			e_bolt_loc.b_in_use = 1;
			e_bolt_loc.script_int = gettime();
			e_bolt_loc.var_d8bee13b = 0;
			v_ground_pos = util::ground_position( v_hit_pos, 1000, vectorScale( ( 0, 0, 1 ), 16 )[ 2 ] );
			if ( ( v_hit_pos[ 2 ] - v_ground_pos[ 2 ] ) < 64 )
				e_bolt_loc.origin = v_ground_pos;
			else
				e_bolt_loc.origin = v_hit_pos;
			
			WAIT_SERVER_FRAME;
			e_bolt_loc clientfield::set( "elem_storm_fx", 1 );
			e_bolt_loc thread bow_storm_whirlwind_shake_players();
			e_bolt_loc thread bow_storm_whirlwind_move( self );
			e_bolt_loc thread bow_storm_bolt_fire_multi( self );
			str_return = e_bolt_loc util::waittill_any_timeout( 7.8, "elem_storm_whirlwind_force_off" );
			e_bolt_loc clientfield::set( "elem_storm_fx", 0 );
			e_bolt_loc notify( "elem_storm_whirlwind_done" );
			e_bolt_loc.b_in_use = 0;
		}
	}
}

function bow_storm_bolt_fire_multi( e_player )
{
	e_player bow_storm_bolt_fire( ( 0, 0, 0 ), 7.8, self, 1 );
}

function bow_storm_get_bolt_loc()
{
	for ( i = 0; i < self.a_bow_storm_bolt_locs.size; i++ )
	{
		if ( !IS_TRUE( self.a_bow_storm_bolt_locs[ i ].b_in_use ) )
			return self.a_bow_storm_bolt_locs[ i ];
		
	}
	a_bow_storm_bolt_locs = array::sort_by_script_int( self.a_bow_storm_bolt_locs, 1 );
	a_bow_storm_bolt_locs[ 0 ] notify( "elem_storm_whirlwind_force_off" );
	wait .1;
	return a_bow_storm_bolt_locs[ 0 ];
}

function bow_storm_whirlwind_move( e_player )
{
	self endon( "elem_storm_whirlwind_done" );
	while ( 1 )
	{
		v_ground_pos = util::ground_position( self.origin + ( 0, 0, 1 ), 1000, vectorScale( ( 0, 0, 1 ), 16 )[ 2 ] );
		n_z_diff = abs( self.origin[ 2 ] - v_ground_pos[ 2 ] );
		if ( n_z_diff > 0 )
		{
			n_time = n_z_diff / 256;
			self moveTo( v_ground_pos, n_time, n_time * 0.5 );
			wait( n_time );
		}
		v_away_from_source = undefined;
		n_incriment = 64;
		a_ai_enemies = self bow_storm_storm_get_targets( 768, e_player );
		if ( a_ai_enemies.size )
		{
			foreach ( ai_enemy in a_ai_enemies )
			{
				if ( bulletTracePassed( ai_enemy getCentroid(), self.origin + vectorScale( ( 0, 0, 1 ), 12 ), 0, self ) )
				{
					face_angles = vectorNormalize( ai_enemy.origin - self.origin );
					face_angles = ( face_angles[ 0 ], face_angles[ 1 ], 0 );
					v_away_from_source = face_angles * 128;
					break;
				}
			}
		}
		if ( !isDefined( v_away_from_source ) )
		{
			n_x_multi = randomIntRange( -1, 2 );
			if ( !n_x_multi )
				n_y_multi = ( randomInt( 100 ) < 50 ? 1 : -1 );
			else
				n_y_multi = randomIntRange( -1, 2 );
			
			v_away_from_source = ( 128 * n_x_multi, 128 * n_y_multi, 0 );
			n_incriment = randomFloatRange( 16, 48 );
			var_78870509 = self.origin + vectorScale( ( 0, 0, 1 ), 12 );
			a_trace = physicsTraceEx( var_78870509, var_78870509 + v_away_from_source, vectorScale( ( -1, -1, -1 ), 24 ), vectorScale( ( 1, 1, 1 ), 24 ), self );
			v_away_from_source = v_away_from_source * a_trace[ "fraction" ];
		}
		n_length = length( v_away_from_source );
		n_time = n_length / n_incriment;
		n_time = ( n_time < 1 ? 1 : n_time );
		v_on_navmesh = getClosestPointOnNavmesh( self.origin + v_away_from_source, 128, 64 );
		if ( !isDefined( v_on_navmesh ) )
			v_on_navmesh = self.origin + v_away_from_source;
		else
			v_on_navmesh = v_on_navmesh + vectorScale( ( 0, 0, 1 ), 16 );
		
		self moveTo( v_on_navmesh, n_time, n_time * 0.5 );
		wait n_time;
	}
}

function bow_storm_whirlwind_shake_players()
{
	self endon( "elem_storm_whirlwind_done" );
	while ( 1 )
	{
		foreach ( e_player in level.activeplayers )
		{
			if ( isDefined( e_player ) && !IS_TRUE( e_player.b_bow_storm_rumbling ) )
			{
				if ( distanceSquared( e_player.origin, self.origin ) < 16384 )
					e_player thread bow_storm_whirlwind_shake_player( self );
				
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function bow_storm_whirlwind_shake_player( e_bolt_loc )
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self.b_bow_storm_rumbling = 1;
	self clientfield::set_to_player( "elem_storm_whirlwind_rumble", 1 );
	while ( distanceSquared( self.origin, e_bolt_loc.origin ) < 16384 && IS_TRUE( e_bolt_loc.b_in_use ) )
		WAIT_SERVER_FRAME;
	
	self.b_bow_storm_rumbling = 0;
	self clientfield::set_to_player( "elem_storm_whirlwind_rumble", 0 );
}
/*
function function_88b53a11( var_80242169, v_hit_origin, var_3fee16b8 )
{
	var_bba6e664 = anglestoforward( var_3fee16b8.angles );
	var_3e878400 = vectorNormalize( var_bba6e664 * -1 );
	var_75181c09 = v_hit_origin + ( var_3e878400 * var_80242169 );
	return var_75181c09;
}
*/
function bow_storm_fake_fire_impact( str_weapon_name, v_source, v_destination )
{
	wait .1;
	str_weapon_name = ( str_weapon_name == "elemental_bow_storm4" ? "elemental_bow_storm4_ricochet" : "elemental_bow_storm_ricochet" );
	magicBullet( getweapon( str_weapon_name ), v_source, v_destination, self );
}
