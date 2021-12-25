#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_idgun.gsh;

#namespace idgun;

REGISTER_SYSTEM_EX( "idgun", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	level.weaponNone = getWeapon( "none" );
	setup_idgun_weapons();
	callback::on_spawned( &on_spawned_idgun );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function on_spawned_idgun( n_local_client_num )
{
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

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

function setup_idgun_weapons()
{
	level.idgun_weapons = [];
	register_idgun( getWeapon( IDGUN_0_WEAPON ) );
	register_idgun( getWeapon( IDGUN_1_WEAPON ) );
	register_idgun( getWeapon( IDGUN_2_WEAPON ) );
	register_idgun( getWeapon( IDGUN_3_WEAPON ) );
	register_idgun( getWeapon( IDGUN_0_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_1_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_2_UPGRADED_WEAPON ) );
	register_idgun( getWeapon( IDGUN_3_UPGRADED_WEAPON ) );
}

function is_upgraded_idgun( w_weapon )
{
	if ( w_weapon === getWeapon( IDGUN_0_UPGRADED_WEAPON ) || w_weapon === getWeapon( IDGUN_1_UPGRADED_WEAPON ) || w_weapon === getWeapon( IDGUN_2_UPGRADED_WEAPON ) || w_weapon === getWeapon( IDGUN_3_UPGRADED_WEAPON ) )
		return 1;
	
	return 0;
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

// ============================== FUNCTIONALITY ==============================