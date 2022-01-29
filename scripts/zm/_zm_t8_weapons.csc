#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

// BO2 WEAPON STUFF

// TOMAHAWK
// #using scripts\zm\_hb21_zm_weap_tomahawk;

// ACIDGAT
#using scripts\zm\craftables\_hb21_zm_craft_blundersplat;
#using scripts\zm\_hb21_zm_weap_blundersplat;
#using scripts\zm\_hb21_zm_weap_magmagat;

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


// GSTRIKE
// #using scripts\zm\_zm_weap_beacon;

// SLIQUIFIER
// #using scripts\zm\_hb21_zm_weap_slipgun;
// #using scripts\zm\craftables\_hb21_zm_craft_slipgun;

// TOMAHAWK
#using scripts\zm\_hb21_zm_weap_tomahawk;

#namespace zm_t8_weapons;

REGISTER_SYSTEM_EX( "zm_t8_weapons", &__init__, &__main__, undefined )

function __init__()
{
	luiLoad( "ui.uieditor.widgets.hud.zm_ammowidgetfactory_mod.zmammo_equipcontainerfactory" );
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t8_weapons.csv", 1 );
}

function __main__()
{
}