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

// BO2 WEAPON STUFF

// GSTRIKE
// #using scripts\zm\_zm_weap_beacon;

// ACIDGAT
#using scripts\zm\craftables\_hb21_zm_craft_blundersplat;
#using scripts\zm\_hb21_zm_weap_blundersplat;
#using scripts\zm\_hb21_zm_weap_magmagat;

// SLIQUIFIER
// #using scripts\zm\_hb21_zm_weap_slipgun;
// #using scripts\zm\craftables\_hb21_zm_craft_slipgun;

// GALVAKNUCKLES
// #using scripts\zm\_hb21_zm_weap_galvaknuckles;

// TOMAHAWK
// #using scripts\zm\_hb21_zm_weap_tomahawk;

// STAFFS
// #using scripts\zm\craftables\_zm_craft_staff;
// #using scripts\zm\_zm_weap_staff_revive;
// #using scripts\zm\_zm_weap_staff_fire;
// #using scripts\zm\_zm_weap_staff_air;
// #using scripts\zm\_zm_weap_staff_lightning;
// #using scripts\zm\_zm_weap_staff_water;

// ONE INCH PUNCH
// #using scripts\zm\_zm_weap_one_inch_punch;

// LSAT AMMO COUNTER
// #using scripts\zm\_zm_weap_ammo_counter;

// TOMAHAWK
#using scripts\zm\_hb21_zm_weap_tomahawk;

#namespace zm_t8_weapons;

REGISTER_SYSTEM_EX( "zm_t8_weapons", &__init__, &__main__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t8_weapons.csv", 1 );
}

function __main__()
{
}