#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_spawner;

#using scripts\shared\ai\zombie_utility;

// BO3 WEAPON STUFF

// ORIGINS SHIELD
#using scripts\zm\craftables\_hb21_zm_craft_origins_shield;
#using scripts\zm\_hb21_zm_weap_origins_shield;

// ZNS SHIELD
#using scripts\zm\craftables\_hb21_zm_craft_island_shield;
#using scripts\zm\_hb21_zm_weap_island_shield;

// STAFFS
#using scripts\zm\craftables\_hb21_zm_craft_staff;
#using scripts\zm\_hb21_zm_weap_staff_revive;
#using scripts\zm\_hb21_zm_weap_staff_fire;
#using scripts\zm\_hb21_zm_weap_staff_air;
#using scripts\zm\_hb21_zm_weap_staff_lightning;
#using scripts\zm\_hb21_zm_weap_staff_water;

// ONE INCH PUNCH
#using scripts\zm\_hb21_zm_weap_one_inch_punch;

// GSTRIKE
#using scripts\zm\_hb21_zm_weap_beacon;

// IDGUN
#using scripts\zm\craftables\_zm_craft_idgun;
#using scripts\zm\_zm_weap_idgun;

// GERSH DEVICE
#using scripts\zm\_zm_weap_black_hole_bomb;

// QED
#using scripts\zm\_zm_weap_quantum_bomb;

// WAVE GUN
#using scripts\zm\_zm_weap_microwavegun;

// DRAGON SHIELD
#using scripts\zm\_hb21_zm_weap_dragonshield;
#using scripts\zm\craftables\_hb21_zm_craft_dragonshield;

// ROCKET SHIELD CASTLE
#using scripts\zm\craftables\_zm_craft_shield;
#using scripts\zm\_zm_weap_castle_rocketshield;

// DRAGON STRIKE
#using scripts\zm\_zm_weap_dragon_strike;

// KT-4
#using scripts\zm\_zm_weap_mirg2000;
#using scripts\zm\craftables\_hb21_zm_craft_mirg2000;

// SOUL CHESTS
#using scripts\zm\_hb21_zm_soul_chests;

// SICKLE
#using scripts\zm\_hb21_zm_weap_sickle;

// RAGNAROK DG-4
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\craftables\_zm_craft_gravityspikes;

#namespace zm_t7_weapons;

REGISTER_SYSTEM_EX( "zm_t7_weapons", &__init__, &__main__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{
	
	// level.zombie_death_animscript_override = &zombie_death_animscript_override;
	level.ptr_is_wavegun_weapon = &is_wavegun_weapon;
	level.ptr_is_zapgun_weapon = &is_zapgun_weapon;
	level.ptr_is_explode_death_anim_excluded = &ptr_is_explode_death_anim_excluded;
	
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t7_weapons.csv", 1 );
}

function is_wavegun_weapon( w_weapon )
{
	if ( isDefined( level.a_wavegun_weapons ) && isArray( level.a_wavegun_weapons ) && isInArray( level.a_wavegun_weapons, w_weapon ) )
		return 1;
		
	return 0;	
}

function is_zapgun_weapon( w_weapon )
{
	if ( isDefined( level.a_zapgun_weapons ) && isArray( level.a_zapgun_weapons ) && isInArray( level.a_zapgun_weapons, w_weapon ) )
		return 1;
	
	return 0;	
}

function ptr_is_explode_death_anim_excluded( w_weapon )
{
	if ( isDefined( level.a_explode_death_excluded_weapons ) && isArray( level.a_explode_death_excluded_weapons ) && isInArray( level.a_explode_death_excluded_weapons, w_weapon ) )
		return 1;
	
	return 0;	
}

function zombie_death_animscript_override()
{
	if ( "t6_shotgun_rottweil72_upgraded" == self.damageweapon.name || "t7_shotgun_rottweil72_upgraded" == self.damageweapon.name )
		self thread zm_spawner::dragons_breath_flame_death_fx();

}

function __main__()
{
}