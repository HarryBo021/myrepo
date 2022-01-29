#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_hb21_zm_weap_staff_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_revive.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_fire.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_air.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_lightning.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_water.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_staff.gsh;

#namespace hb21_zm_craft_staff;

REGISTER_SYSTEM_EX( "hb21_zm_craft_staff", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	level.zombie_craftable_persistent_weapon = &check_crafted_staff_persistence;
	
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", CLIENTFIELD_STAFF_PARTS, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "staff_element_glow_fx", VERSION_SHIP, 4, "int" );
	// # CLIENTFIELD REGISTRATION
	
	// # FIRE STAFF REGISTRATION
	s_fire_staff_crystal 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_FIRESTAFF, "crystal", 	32, 64, 25, undefined, &on_pickup_crystal, 		&on_drop_crystal, 		undefined, undefined, undefined, undefined, 1, 							!STAFF_CRYSTAL_ONE_PER_PLAYER );
	s_fire_staff_tip 														= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_FIRESTAFF, "tip", 		48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_TIP, 									CRAFTABLE_IS_SHARED 				 );
	s_fire_staff_stem 													= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_FIRESTAFF, "stem", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_STEM, 								CRAFTABLE_IS_SHARED 				 );
	s_fire_staff_revive 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_FIRESTAFF, "revive", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_REVIVE, 								CRAFTABLE_IS_SHARED 				 );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_FIRESTAFF_VISIBLE, 							VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_FIRESTAFF_HOLDER, 							VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_FIRESTAFF_QUEST_STATE, 					VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_CRYSTAL,				VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_TIP,						VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_STEM, 					VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_FIRESTAFF_REVIVE, 					VERSION_SHIP, 1, "int" );
	
	s_fire_staff 															= spawnStruct();
	s_fire_staff.name 													= CRAFTABLE_FIRESTAFF;
	s_fire_staff.weaponname 										= FIRESTAFF_WEAPON;
	s_fire_staff.triggerthink 											= &staff_craftable;
	s_fire_staff.custom_craftablestub_update_prompt 	= &staff_update_prompt;
	s_fire_staff zm_craftables::add_craftable_piece( s_fire_staff_crystal );
	s_fire_staff zm_craftables::add_craftable_piece( s_fire_staff_tip );
	s_fire_staff zm_craftables::add_craftable_piece( s_fire_staff_stem );
	s_fire_staff zm_craftables::add_craftable_piece( s_fire_staff_revive );
	
	zm_craftables::include_zombie_craftable( s_fire_staff );
	zm_craftables::add_zombie_craftable( CRAFTABLE_FIRESTAFF, CRAFT_ITEM_STRING + makeLocalizedString( getWeapon( FIRESTAFF_WEAPON ).displayname ), "Hold ^3[{+activate}]^7 to insert the Elemental Crystal", BOUGHT_ITEM_STRING + makeLocalizedString( getWeapon( FIRESTAFF_WEAPON ).displayname ), &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	hb21_zm_weap_staff_utility::staff_upgrade_plynth_spawn( CRAFTABLE_FIRESTAFF, FIRESTAFF_WEAPON, FIRESTAFF_UPGRADED_WEAPON, FIRESTAFF_MODEL, FIRESTAFF_UPGRADED_MODEL );
	// # FIRE STAFF REGISTRATION
	
	// # ICE STAFF REGISTRATION
	s_water_staff_crystal 											= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_WATERSTAFF, "crystal", 	32, 64, 25, undefined, &on_pickup_crystal, 		&on_drop_crystal, 		undefined, undefined, undefined, undefined, 1, 					!STAFF_CRYSTAL_ONE_PER_PLAYER );
	s_water_staff_tip 													= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_WATERSTAFF, "tip", 		48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_TIP, 							CRAFTABLE_IS_SHARED				 );
	s_water_staff_stem 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_WATERSTAFF, "stem", 		48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_STEM, 						CRAFTABLE_IS_SHARED 				 );
	s_water_staff_revive  											= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_WATERSTAFF, "revive", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_REVIVE, 						CRAFTABLE_IS_SHARED 				 );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_WATERSTAFF_VISIBLE, 						VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_WATERSTAFF_HOLDER, 						VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_WATERSTAFF_QUEST_STATE, 				VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_CRYSTAL,			VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_TIP,					VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_STEM, 				VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_WATERSTAFF_REVIVE, 				VERSION_SHIP, 1, "int" );
	
	s_water_staff 														= spawnStruct();
	s_water_staff.name 												= CRAFTABLE_WATERSTAFF;
	s_water_staff.weaponname 									= WATERSTAFF_WEAPON;
	s_water_staff.triggerthink 										= &staff_craftable;
	s_water_staff.custom_craftablestub_update_prompt 	= &staff_update_prompt;
	s_water_staff zm_craftables::add_craftable_piece( s_water_staff_crystal );
	s_water_staff zm_craftables::add_craftable_piece( s_water_staff_tip );
	s_water_staff zm_craftables::add_craftable_piece( s_water_staff_stem );
	s_water_staff zm_craftables::add_craftable_piece( s_water_staff_revive );
	
	zm_craftables::include_zombie_craftable( s_water_staff );
	zm_craftables::add_zombie_craftable( CRAFTABLE_WATERSTAFF, CRAFT_ITEM_STRING + makeLocalizedString( getWeapon( WATERSTAFF_WEAPON ).displayname ), "Hold ^3[{+activate}]^7 to insert the Elemental Crystal", BOUGHT_ITEM_STRING + makeLocalizedString( getWeapon( WATERSTAFF_WEAPON ).displayname ), &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	hb21_zm_weap_staff_utility::staff_upgrade_plynth_spawn( CRAFTABLE_WATERSTAFF, WATERSTAFF_WEAPON, WATERSTAFF_UPGRADED_WEAPON, WATERSTAFF_MODEL, WATERSTAFF_UPGRADED_MODEL );
	// # ICE STAFF REGISTRATION
	
	// # WIND STAFF REGISTRATION
	s_wind_staff_crystal 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_AIRSTAFF, 	"crystal", 	32, 64, 25, undefined, &on_pickup_crystal, 		&on_drop_crystal, 		undefined, undefined, undefined, undefined, 2, 								!STAFF_CRYSTAL_ONE_PER_PLAYER );
	s_wind_staff_tip 													= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_AIRSTAFF, 	"tip", 		48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_TIP, 										CRAFTABLE_IS_SHARED 	 			 );
	s_wind_staff_stem 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_AIRSTAFF, 	"stem", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_STEM, 										CRAFTABLE_IS_SHARED 				 );
	s_wind_staff_revive 												= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_AIRSTAFF, 	"revive", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_REVIVE, 									CRAFTABLE_IS_SHARED 				 );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_AIRSTAFF_VISIBLE, 							VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_AIRSTAFF_HOLDER, 							VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_AIRSTAFF_QUEST_STATE, 					VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_CRYSTAL,				VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_TIP,							VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_STEM, 						VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_AIRSTAFF_REVIVE, 					VERSION_SHIP, 1, "int" );
	
	s_wind_staff 															= spawnStruct();
	s_wind_staff.name 												= CRAFTABLE_AIRSTAFF;
	s_wind_staff.weaponname 										= AIRSTAFF_WEAPON;
	s_wind_staff.triggerthink 										= &staff_craftable;
	s_wind_staff.custom_craftablestub_update_prompt 	= &staff_update_prompt;
	s_wind_staff zm_craftables::add_craftable_piece( s_wind_staff_crystal );
	s_wind_staff zm_craftables::add_craftable_piece( s_wind_staff_tip );
	s_wind_staff zm_craftables::add_craftable_piece( s_wind_staff_stem );
	s_wind_staff zm_craftables::add_craftable_piece( s_wind_staff_revive );
	
	zm_craftables::include_zombie_craftable( s_wind_staff );
	zm_craftables::add_zombie_craftable( CRAFTABLE_AIRSTAFF, CRAFT_ITEM_STRING + makeLocalizedString( getWeapon( AIRSTAFF_WEAPON ).displayname ), "Hold ^3[{+activate}]^7 to insert the Elemental Crystal", BOUGHT_ITEM_STRING + makeLocalizedString( getWeapon( AIRSTAFF_WEAPON ).displayname ), &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	hb21_zm_weap_staff_utility::staff_upgrade_plynth_spawn( CRAFTABLE_AIRSTAFF, AIRSTAFF_WEAPON, AIRSTAFF_UPGRADED_WEAPON, AIRSTAFF_MODEL, AIRSTAFF_UPGRADED_MODEL );
	// # AIR WIND REGISTRATION
	
	// # LIGHTNING STAFF REGISTRATION
	s_bolt_staff_crystal 												= zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_LIGHTNINGSTAFF, 	"crystal", 	32, 64, 25, undefined, &on_pickup_crystal, 		&on_drop_crystal, 		undefined, undefined, undefined, undefined, 3, 	!STAFF_CRYSTAL_ONE_PER_PLAYER );
	s_bolt_staff_tip 														= zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_LIGHTNINGSTAFF, 	"tip", 		48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_TIP, 				CRAFTABLE_IS_SHARED 				 );
	s_bolt_staff_stem  													= zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_LIGHTNINGSTAFF, 	"stem", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_STEM, 			CRAFTABLE_IS_SHARED 				 );
	s_bolt_staff_revive  												= zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_LIGHTNINGSTAFF, 	"revive", 	48, 15, 25, undefined, &on_pickup_common, 	&on_drop_common, 	undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_REVIVE, 		CRAFTABLE_IS_SHARED 				 );
	
	clientfield::register( "clientuimodel", 	CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_VISIBLE, 				VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_HOLDER, 				VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_LIGHTNINGSTAFF_QUEST_STATE, 		VERSION_SHIP, 5, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_CRYSTAL,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_TIP,				VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_STEM, 			VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_LIGHTNINGSTAFF_REVIVE, 		VERSION_SHIP, 1, "int" );
	
	s_bolt_staff 															= spawnStruct();
	s_bolt_staff.name 													= CRAFTABLE_LIGHTNINGSTAFF;
	s_bolt_staff.weaponname 										= LIGHTNINGSTAFF_WEAPON;
	s_bolt_staff.triggerthink 											= &staff_craftable;
	s_bolt_staff.custom_craftablestub_update_prompt 	= &staff_update_prompt;
	s_bolt_staff zm_craftables::add_craftable_piece( s_bolt_staff_crystal );
	s_bolt_staff zm_craftables::add_craftable_piece( s_bolt_staff_tip );
	s_bolt_staff zm_craftables::add_craftable_piece( s_bolt_staff_stem );
	s_bolt_staff zm_craftables::add_craftable_piece( s_bolt_staff_revive );
	
	zm_craftables::include_zombie_craftable( s_bolt_staff );
	zm_craftables::add_zombie_craftable( CRAFTABLE_LIGHTNINGSTAFF, CRAFT_ITEM_STRING + makeLocalizedString( getWeapon( LIGHTNINGSTAFF_WEAPON ).displayname ), "Hold ^3[{+activate}]^7 to insert the Elemental Crystal", BOUGHT_ITEM_STRING + makeLocalizedString( getWeapon( LIGHTNINGSTAFF_WEAPON ).displayname ), &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	hb21_zm_weap_staff_utility::staff_upgrade_plynth_spawn( CRAFTABLE_LIGHTNINGSTAFF, LIGHTNINGSTAFF_WEAPON, LIGHTNINGSTAFF_UPGRADED_WEAPON, LIGHTNINGSTAFF_MODEL, LIGHTNINGSTAFF_UPGRADED_MODEL );
	// # LIGHTNING STAFF REGISTRATION
}

function __main__()
{
	level thread hide_staff_models();
	level thread staff_piece_add_glow_fx();
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function check_crafted_staff_persistence( e_player )
{
	w_weapon = self.stub.weaponname;
	if ( [ [ level.ptr_is_staff_weapon ] ]( w_weapon ) )
	{
		s_charger = struct::get( self.stub.equipname + "_charger", "script_noteworthy" );
		if ( !isDefined( s_charger.e_staff_placed ) || s_charger.e_staff_placed != self.stub )
		{
			self.hint_string = "";
			return 1;
		}
		e_player hb21_zm_weap_staff_utility::take_all_staff_weapons();
		e_player zm_weapons::weapon_give( w_weapon, 0, 0, 1, 1 );
		if ( isDefined( level.zombie_craftablestubs[ self.stub.equipname ].str_taken ) )
			self.hint_string = level.zombie_craftablestubs[ self.stub.equipname ].str_taken;
		else
			self.hint_string = "";
		
		staff_model = getEnt( self.stub.equipname + "_model", "targetname" );
		staff_model ghost();
		s_charger.e_staff_placed = undefined;
		return 1;
	}
	return 0;
}

function staff_update_prompt( e_player, b_set_hint_string_now, b_trigger )
{
	s_charger = struct::get( self.craftablespawn.craftable_name + "_charger", "script_noteworthy" );
	if ( IS_TRUE( self.crafted ) )
	{
		if ( ( !isDefined( s_charger.e_staff_placed ) || s_charger.e_staff_placed != self ) )
		{
			self.hint_string = "";
			return 0;
		}
		else
			return 1;
		
	}
	self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
	if ( !staff_all_parts_are_shared( self.craftablespawn.craftable_name ) )
	{
		if ( isDefined( e_player ) )
		{
			if ( !isDefined( e_player.current_craftable_pieces ) || e_player.current_craftable_pieces.size < 1 )
				return 0;
			if ( !self.craftablespawn zm_craftables::craftable_has_piece( e_player.current_craftable_pieces[ 0 ] ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				return 0;
			}
		}
	}
	if ( e_player staff_all_parts_collected( self.craftablespawn.craftable_name ) )
	{
		self.hint_string = level.zombie_craftableStubs[ self.craftablespawn.craftable_name ].str_to_craft;
		return 1;
	}
	else
		return 0;
	
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function on_drop_crystal_return_to_spawn( e_player_owner )
{
	s_piece = self.piecestub;
	s_piece.piecespawn.canmove = 1;
	zm_unitrigger::reregister_unitrigger_as_dynamic( s_piece.piecespawn.unitrigger );
	s_original_pos = struct::get( self.craftablename + "_" + self.piecename );
	s_piece.piecespawn.model.origin = s_original_pos.origin;
	s_piece.piecespawn.model.angles = s_original_pos.angles;
}

function on_drop_crystal( e_player_owner )
{
	self.piecestub thread attach_staff_piece_add_glow_fx( self.craftablename );
	if ( IS_TRUE( STAFF_CRYSTAL_RETURN_TO_SPAWN_ON_DROPPED ) )
		self on_drop_crystal_return_to_spawn( e_player_owner );
	
	level clientfield::set( self.craftablename + ".holder", 0 );
	level clientfield::set( self.craftablename + ".piece_zm_gem", 0 );
	level clientfield::set( self.craftablename + ".quest_state", 0 );
	
	on_drop_common( e_player_owner );
}

function on_pickup_crystal( e_player_owner )
{
	level clientfield::set( self.craftablename + ".holder", e_player_owner.characterindex + 1 );
	level clientfield::set( self.craftablename + ".piece_zm_gem", 1 );
	level clientfield::set( self.craftablename + ".quest_state", 2 );

	e_player_owner playSound( "evt_crystal" );

	on_pickup_common( e_player_owner );
}

function on_pickup_common( e_player_owner )
{
	e_player_owner playSound( "zmb_craftable_pickup" );	
	
	iPrintLnBold( "zminventory." + self.craftablename + ".visible" );
	
	foreach( e_player in level.players )
		e_player thread staff_player_show_craftable_parts_ui( undefined, "zminventory." + self.craftablename + ".visible", 0 );

	self.piece_owner = e_player_owner;
}

function on_drop_common( e_player_owner )
{
	self.piece_owner = undefined;
}

function staff_craftable()
{
	zm_craftables::craftable_trigger_think( self.name + "_craftable_trigger", self.name, self.weaponname, TAKE_ITEM_STRING + makeLocalizedString( getWeapon( self.weaponname ).displayname ), DELETE_TRIGGER, PERSISTENT );
}

function on_fully_crafted()
{
	s_charger = struct::get( self.equipname + "_charger", "script_noteworthy" );
	e_staff_model = getEnt( self.equipname + "_model", "targetname");
	if ( !IS_TRUE( e_staff_model.b_crafted ) )
	{
		level clientfield::set( self.equipname + ".holder", 0 );
		
		e_staff_model show();
		e_staff_model.b_crafted = 1;
		s_charger.e_staff_placed = self;
		self thread hb21_zm_weap_staff_utility::staff_pedestal_watch_for_loss();
		
		foreach ( e_player in level.players )
			e_player thread staff_player_show_craftable_parts_ui( undefined, "zminventory." + self.equipname + ".visible", 1 );
		
	}
	if ( !isDefined( s_charger ) || !IS_TRUE( s_charger.b_upgraded ) )
		level clientfield::set( self.equipname + ".quest_state", 3 );
	
	return 1;
}

function staff_all_parts_are_shared( str_craftable_name )
{
	foreach( s_piece in level.zombie_craftablestubs[ str_craftable_name ].a_piecestubs )
		if ( !s_piece.is_shared )
			return 0;
			
	return 1;
}

function staff_all_parts_collected( str_craftable_name )
{
	foreach( s_piece in level.zombie_craftablestubs[ str_craftable_name ].a_piecestubs )
		if ( !self staff_is_holding_part( str_craftable_name, s_piece.piecename, 0 ) )
			return 0;
			
	return 1;
}

function staff_is_holding_part( str_craftable_name, str_piece_name, n_slot = 0 )
{
	if ( isDefined( self.current_craftable_pieces ) && isDefined( self.current_craftable_pieces[ n_slot ] ) )
	{
		if ( self.current_craftable_pieces[ n_slot ].craftablename == str_craftable_name && self.current_craftable_pieces[ n_slot ].piecename == str_piece_name )
			return 1;
		
	}
	if ( isDefined( level.a_uts_craftables ) )
	{
		foreach ( s_craftable_stub in level.a_uts_craftables )
		{
			if ( isDefined( s_craftable_stub.craftablestub ) && s_craftable_stub.craftablestub.name == str_craftable_name )
			{
				foreach ( s_piece in s_craftable_stub.craftablespawn.a_pieceSpawns )
				{
					if ( s_piece.piecename == str_piece_name )
					{
						if ( IS_TRUE( s_piece.in_shared_inventory ) )
							return 1;
						
					}
				}
			}
		}
	}
	return 0;
}

function hide_staff_models()
{
	a_staffs = getEntArray( "craftable_staff_model", "script_noteworthy" );
	foreach ( e_stave in a_staffs )
		e_stave ghost();
	
}

function staff_piece_add_glow_fx()
{
	level flagsys::wait_till( "load_main_complete" );
	level flag::wait_till( "start_zombie_round_logic" );
	foreach ( s_craftable in level.zombie_include_craftables )
	{
		if ( !isSubStr( s_craftable.name, "craft_staff" ) )
			continue;
		
		foreach ( s_piece in s_craftable.a_piecestubs )
			s_piece thread attach_staff_piece_add_glow_fx( s_craftable.name );
		
	}
}

function attach_staff_piece_add_glow_fx( str_craftable_name )
{
	self craftable_waittill_spawned();
	
	n_elem = 0;
	if ( isSubStr( str_craftable_name, "fire" ) )
		n_elem = 1;
	else if ( isSubStr( str_craftable_name, "air" ) )
		n_elem = 2;
	else if ( isSubStr( str_craftable_name, "bolt" ) )
		n_elem = 3;
	else if ( isSubStr( str_craftable_name, "water" ) )
		n_elem = 4;
		
	self.piecespawn.model clientfield::set( "staff_element_glow_fx", n_elem );
}

function craftable_waittill_spawned()
{
	while ( !isDefined( self.piecespawn ) )
		util::wait_network_frame();
	
}

function staff_player_show_craftable_parts_ui( str_crafted_clientuimodel, str_widget_clientuimodel, b_is_crafted )
{
	self notify( "staff_player_show_craftable_parts_ui" );
	self endon( "staff_player_show_craftable_parts_ui" );
	
	if( b_is_crafted )
	{
		if( isdefined( str_crafted_clientuimodel ) )
		{
			self thread clientfield::set_player_uimodel( str_crafted_clientuimodel, 1 );
		}
		n_show_ui_duration = ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION;
	}
	else
	{
		n_show_ui_duration = ZM_CRAFTABLES_NOT_ENOUGH_PIECES_UI_DURATION;
	}	
	
	self thread staff_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, ZM_CRAFTABLES_NOT_ENOUGH_PIECES_UI_DURATION );	
}

function staff_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, n_show_ui_duration )
{
	self endon( "disconnect" );
	self notify( str_widget_clientuimodel + "_staff_player_show_craftable_parts_ui" );
	self endon( str_widget_clientuimodel + "_staff_player_show_craftable_parts_ui" );
	
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 1 );
	wait n_show_ui_duration;
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 0 );
}
// ============================== FUNCTIONALITY ==============================