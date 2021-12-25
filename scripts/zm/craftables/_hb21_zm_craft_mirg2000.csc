#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_mirg2000.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_mirg2000.gsh;
	
#namespace hb21_zm_craft_mirg2000;

REGISTER_SYSTEM_EX( "hb21_zm_craft_mirg2000", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_KT4_PARTS, 			VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_I, 									VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_II, 									VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_III, 									VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register("world", CLIENTFIELD_CRAFTABLE_PIECE_KT4_ADD_TO_BOX, VERSION_SHIP, 4, "int", &function_fcdf674f, 0, 0);
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function function_fcdf674f(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal)
	{
		var_989d36e = GetWeapon("t7_hero_mirg2000");
		AddZombieBoxWeapon(var_989d36e, var_989d36e.worldmodel, var_989d36e.isDualWield);
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================