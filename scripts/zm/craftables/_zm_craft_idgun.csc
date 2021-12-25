#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_idgun.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_zm_craft_idgun.gsh;
	
#namespace zm_craft_idgun;

REGISTER_SYSTEM_EX( "zm_craft_idgun", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_IDGUN_PARTS, 										VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_IDGUN_CRAFTED, 									VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_IDGUN_ADD_TO_BOX, 								VERSION_SHIP, 1, "int", &add_idgun_to_box, 									!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_IDGUN_REMOVE_FROM_BOX, 					VERSION_SHIP, 1, "int", &remove_idgun_from_box, 						!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_HEART,			VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_SKELETON, 		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_XENOMATTER,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	zm_craftables::include_zombie_craftable( IDGUN_NAME );
	zm_craftables::add_zombie_craftable( IDGUN_NAME );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function add_idgun_to_box( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	w_weapon = getWeapon( IDGUN_GENESIS_0_WEAPON );
	addZombieBoxWeapon( w_weapon, w_weapon.worldmodel, w_weapon.isdualwield );
}

function remove_idgun_from_box( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	w_weapon = getWeapon( IDGUN_GENESIS_0_WEAPON );
	removeZombieBoxWeapon( w_weapon );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================