#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craft_shield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;

#namespace zm_craft_shield;

REGISTER_SYSTEM_EX( "zm_craft_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_ROCKETSHIELD_PARTS, 							VERSION_SHIP, 1, "int", undefined, 													!CF_HOST_ONLY, 	CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_ROCKETSHIELD_CRAFTED, 						VERSION_SHIP, 1, "int", undefined, 													!CF_HOST_ONLY, 	CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 		!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR, 	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 		!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 		!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer",			ZMUI_SHIELD_PART_PICKUP, 										VERSION_SHIP, 1, "int", &zm_utility::zm_ui_infotext, 							!CF_HOST_ONLY, 	CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer", 			ZMUI_SHIELD_CRAFTED, 												VERSION_SHIP, 1, "int", &zm_utility::zm_ui_infotext, 							!CF_HOST_ONLY, 	CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	zm_craftables::include_zombie_craftable( CRAFTABLE_SHIELD );
	zm_craftables::add_zombie_craftable( CRAFTABLE_SHIELD );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================