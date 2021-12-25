#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_gravityspikes.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_zm_craft_gravityspikes.gsh;
	
#namespace zm_craft_gravityspikes;

REGISTER_SYSTEM_EX( "zm_craft_gravityspikes", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_GRAVITYSPIKE_PARTS, 								VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_GRAVITYSPIKE_CRAFTED, 							VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_BODY,		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_GUARDS, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_HANDLE,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	zm_craftables::include_zombie_craftable( GRAVITYSPIKE_NAME );
	zm_craftables::add_zombie_craftable( GRAVITYSPIKE_NAME );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================