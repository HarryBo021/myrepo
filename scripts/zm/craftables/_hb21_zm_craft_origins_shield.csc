#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_powerup_shield_charge;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_hb21_zm_weap_origins_shield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_origins_shield.gsh;
#insert scripts\zm\_zm_utility.gsh;
	
#namespace hb21_zm_craft_origins_shield;

REGISTER_SYSTEM_EX( "hb21_zm_craft_origins_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", CLIENTFIELD_ORIGINSSHIELD_PARTS, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", CLIENTFIELD_ORIGINSSHIELD_CRAFTED, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ORIGINSSHIELD_DOLLY,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ORIGINSSHIELD_DOOR, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ORIGINSSHIELD_CLAMP,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	zm_craftables::include_zombie_craftable( ORIGINSSHIELD_NAME );
	zm_craftables::add_zombie_craftable( ORIGINSSHIELD_NAME );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================