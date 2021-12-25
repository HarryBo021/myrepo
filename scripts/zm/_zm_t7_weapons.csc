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

// BO3 WEAPON STUFF

// ZNS SHIELD
#using scripts\zm\craftables\_hb21_zm_craft_island_shield;
#using scripts\zm\_hb21_zm_weap_island_shield;

// ORIGINS SHIELD
#using scripts\zm\craftables\_hb21_zm_craft_origins_shield;
#using scripts\zm\_hb21_zm_weap_origins_shield;

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

// RAGNAROK DG-4
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\craftables\_zm_craft_gravityspikes;

#namespace zm_t7_weapons;

REGISTER_SYSTEM_EX( "zm_t7_weapons", &__init__, &__main__, undefined )

function __init__()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t7_weapons.csv", 1 );
}

function __main__()
{
}