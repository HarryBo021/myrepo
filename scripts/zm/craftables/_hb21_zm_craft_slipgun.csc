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
#using scripts\zm\_zm_weapons;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_slipgun.gsh;
#insert scripts\zm\_zm_utility.gsh;
	
#namespace hb21_zm_craft_slipgun;

REGISTER_SYSTEM( "zm_craft_slipgun", &__init__, undefined )

// RIOT SHIELD	
function __init__()
{
	zm_craftables::include_zombie_craftable( SLIPGUN_NAME );
	zm_craftables::add_zombie_craftable( SLIPGUN_NAME );
	
	clientfield::register( "clientuimodel", CLIENTFIELD_SLIPGUN_CRAFTED, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", CLIENTFIELD_SLIPGUN_PARTS, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_COOKER, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_EXTINGUISHER, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_FOOT, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_THROTTLE, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	// clientfield::register( "toplayer", ZMUI_SLIPGUN_PART_PICKUP, VERSION_SHIP, 	1, "int", &zm_utility::zm_ui_infotext, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// clientfield::register( "toplayer", ZMUI_SLIPGUN_CRAFTED, 	VERSION_SHIP, 	1, "int", &zm_utility::zm_ui_infotext, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}
