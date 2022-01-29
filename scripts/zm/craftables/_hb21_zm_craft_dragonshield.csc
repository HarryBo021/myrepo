#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_dragonshield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_dragonshield.gsh;
	
#namespace hb21_zm_craft_dragonshield;

REGISTER_SYSTEM_EX( "hb21_zm_craft_dragonshield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_DRAGONSHIELD_CRAFTED, 								VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_DRAGONSHIELD_PARTS, 									VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_PELVIS,		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_HEAD, 		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_WINDOW,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	zm_craftables::include_zombie_craftable( DRAGONSHIELD_NAME );
	zm_craftables::add_zombie_craftable( DRAGONSHIELD_NAME );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================