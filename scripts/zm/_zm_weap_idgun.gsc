#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_idgun.gsh;

#namespace idgun;

REGISTER_SYSTEM_EX( "idgun", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	level.weaponNone = getWeapon( "none" );
	level.b_allow_idgun_pap = IDGUN_CAN_BE_PACK_A_PUNCHED;
	
	callback::on_connect( &on_connect_idgun );
	zm::register_player_damage_callback( &player_damage_idgun_cb );
}

function __main__()
{
	if ( !isDefined( level.idgun_weapons ) )
	{
		if ( !isDefined( level.idgun_weapons ) )
			level.idgun_weapons = [];
		else if ( !isArray( level.idgun_weapons ) )
			level.idgun_weapons = array( level.idgun_weapons );
		
		level.idgun_weapons[ level.idgun_weapons.size ] = getWeapon( "idgun" );
	}
	zm::register_vehicle_damage_callback( &vehicle_damage_idgun_cb );
	setup_idgun_weapons();
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function on_connect_idgun()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "projectile_impact", w_weapon, v_position, n_radius, attacker, v_normal );
		v_position = validate_idgun_vortex_origin( v_position + v_normal * 20 );
		if ( is_idgun_damage( w_weapon ) )
		{
			n_outer_radius = n_radius * 1.8;
			if ( is_upgraded_idgun( w_weapon) )
				thread zombie_vortex::start_timed_vortex( v_position, n_radius, 9, 10, n_outer_radius, self, w_weapon, 1, undefined, 0, 2 );
			else
				thread zombie_vortex::start_timed_vortex( v_position, n_radius, 4, 5, n_outer_radius, self, w_weapon, 1, undefined, 0, 1 );
			
			level notify( "idgun_impact", v_position, w_weapon, self );
		}
		WAIT_SERVER_FRAME;
	}
}

function vehicle_damage_idgun_cb( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, v_damage_origin, n_offset_time, b_damage_from_underneath, n_model_index, str_part_name, v_surface_normal )
{
	if ( isDefined( w_weapon ) )
	{
		if ( is_idgun_damage( w_weapon ) && !IS_TRUE( self.veh_idgun_allow_damage ) )
			n_damage = 0;
		
	}
	return n_damage;
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function setup_idgun_weapons()
{
	level.idgun_weapons = [];
	register_idgun( getWeapon( IDGUN_GENESIS_0_WEAPON ) );
	register_idgun( getWeapon( IDGUN_GENESIS_0_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_0_WEAPON ) );
	register_idgun( getWeapon( IDGUN_1_WEAPON ) );
	register_idgun( getWeapon( IDGUN_2_WEAPON ) );
	register_idgun( getWeapon( IDGUN_3_WEAPON ) );
	register_idgun( getWeapon( IDGUN_0_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_1_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_2_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_3_UPGRADED_WEAPON ) );
}

function register_idgun( w_weapon )
{
	if ( w_weapon != level.weaponNone )
	{
		if ( !isDefined( level.idgun_weapons ) )
			level.idgun_weapons = [];
		else if ( !isArray( level.idgun_weapons ) )
			level.idgun_weapons = array( level.idgun_weapons );
		
		level.idgun_weapons[ level.idgun_weapons.size ] = w_weapon;
	}
}

function is_idgun_damage( w_weapon )
{
	if ( isDefined( level.idgun_weapons ) )
	{
		if ( isInArray( level.idgun_weapons, w_weapon ) )
			return 1;
		
	}
	return 0;
}

function is_upgraded_idgun( w_weapon )
{
	if ( is_idgun_damage( w_weapon ) && zm_weapons::is_weapon_upgraded( w_weapon ) )
		return 1;
	
	return 0;
}

function validate_idgun_vortex_origin( v_vortex_origin )
{
	v_nearest_navmesh_point = getClosestPointOnNavMesh( v_vortex_origin, 36, 15 );
	if ( isDefined( v_nearest_navmesh_point ) )
	{
		f_distance = distance( v_vortex_origin, v_nearest_navmesh_point );
		if ( f_distance < 41 )
			v_vortex_origin = v_vortex_origin + vectorScale( ( 0, 0, 1 ), 36 );
		
	}
	return v_vortex_origin;
}

function player_damage_idgun_cb( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time )
{
	if ( is_idgun_damage( w_weapon ) )
		return 0;
	
	return -1;
}

// ============================== FUNCTIONALITY ==============================