#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_staff.gsh;
	
#namespace hb21_zm_craft_staff;

#precache( "client_fx", FIRESTAFF_PIECE_GLOW_FX );
#precache( "client_fx", WATERSTAFF_PIECE_GLOW_FX );
#precache( "client_fx", AIRSTAFF_PIECE_GLOW_FX );
#precache( "client_fx", LIGHTNINGSTAFF_PIECE_GLOW_FX );

REGISTER_SYSTEM_EX( "hb21_zm_craft_staff", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", "staff_element_glow_fx", VERSION_SHIP, 4, "int", &staff_element_glow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER FX
	level._effect[ "air_glow" ] = AIRSTAFF_PIECE_GLOW_FX;
	level._effect[ "elec_glow" ] = LIGHTNINGSTAFF_PIECE_GLOW_FX;
	level._effect[ "fire_glow" ] = FIRESTAFF_PIECE_GLOW_FX;
	level._effect[ "ice_glow" ] = WATERSTAFF_PIECE_GLOW_FX;
	// # REGISTER FX
	
	// # FIRE STAFF REGISTRATION
	zm_craftables::include_zombie_craftable( CRAFTABLE_FIRESTAFF );
	zm_craftables::add_zombie_craftable( CRAFTABLE_FIRESTAFF );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_FIRESTAFF_VISIBLE, 							VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_FIRESTAFF_HOLDER, 							VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_FIRESTAFF_QUEST_STATE, 					VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_CRYSTAL,				VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_TIP, 						VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_STEM,						VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_REVIVE,					VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # FIRE STAFF REGISTRATION
	
	// # ICE STAFF REGISTRATION
	zm_craftables::include_zombie_craftable( CRAFTABLE_WATERSTAFF );
	zm_craftables::add_zombie_craftable( CRAFTABLE_WATERSTAFF );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_WATERSTAFF_VISIBLE, 						VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_WATERSTAFF_HOLDER, 						VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_WATERSTAFF_QUEST_STATE, 				VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_CRYSTAL,			VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_TIP, 					VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_STEM,					VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_REVIVE,				VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # ICE STAFF REGISTRATION
	
	// # WIND STAFF REGISTRATION
	zm_craftables::include_zombie_craftable( CRAFTABLE_AIRSTAFF );
	zm_craftables::add_zombie_craftable( CRAFTABLE_AIRSTAFF );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_AIRSTAFF_VISIBLE, 							VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_AIRSTAFF_HOLDER, 							VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_AIRSTAFF_QUEST_STATE, 					VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_CRYSTAL,				VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_TIP, 						VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_STEM,						VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_REVIVE,					VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # WIND STAFF REGISTRATION
	
	// # LIGHTNING STAFF REGISTRATION
	zm_craftables::include_zombie_craftable( CRAFTABLE_LIGHTNINGSTAFF );
	zm_craftables::add_zombie_craftable( CRAFTABLE_LIGHTNINGSTAFF );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_VISIBLE, 				VERSION_SHIP, 1, "int", undefined, 												!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_HOLDER, 				VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_QUEST_STATE, 		VERSION_SHIP, 5, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_CRYSTAL,		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_TIP, 				VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_STEM,			VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_REVIVE,		VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, 	!CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # LIGHTNING STAFF REGISTRATION
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function staff_element_glow_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value == 0 )
	{
		if ( isDefined( self.fx_element_glow ) )
		{
			stopFx( n_local_client_num, self.fx_element_glow );
			self.fx_element_glow = undefined;
		}
	}
	else
	{
		str_fx = "";
		switch ( n_new_value )
		{
			case 1:
				str_fx = "fire_glow";
				break;
			case 2:
				str_fx = "air_glow";
				break;
			case 3:
				str_fx = "elec_glow";
				break;
			case 4:
				str_fx = "ice_glow";
				break;
				
		}
		self.fx_element_glow = playFXOnTag( n_local_client_num, level._effect[ str_fx ], self, "tag_origin" );
		setFxIgnorePause( n_local_client_num, self.fx_element_glow, 1 );
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================