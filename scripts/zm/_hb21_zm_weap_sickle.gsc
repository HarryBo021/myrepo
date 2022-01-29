#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

REGISTER_SYSTEM_EX( "hb21_zm_weap_sickle", &__init__, &__main__, undefined )

function private __init__()
{
}

function private __main__()
{
	level._allow_melee_weapon_switching = 1;
	zm_utility::register_melee_weapon_for_level( "t7_sickle" );
	zm_melee_weapon::init( "t7_sickle", "t7_sickle_flourish", undefined, undefined, 3000, "sickle_upgrade", "Hold ^3&&1^7 to buy Sickle [Cost:3000]", undefined, undefined );
	zm_melee_weapon::set_fallback_weapon( "t7_sickle", "knife" );
}