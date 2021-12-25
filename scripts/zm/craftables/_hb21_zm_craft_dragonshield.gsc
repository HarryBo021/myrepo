#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_dragonshield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_dragonshield.gsh;

#precache( "string", "ZOMBIE_DRAGON_SHIELD_CRAFT" );
#precache( "string", "ZOMBIE_DRAGON_SHIELD_TAKEN" );
#precache( "triggerstring", "ZOMBIE_DRAGON_SHIELD_CRAFT" );
#precache( "triggerstring", "ZOMBIE_DRAGON_SHIELD_TAKEN" );

#namespace hb21_zm_craft_dragonshield;

REGISTER_SYSTEM_EX( "hb21_zm_craft_dragonshield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_DRAGONSHIELD_CRAFTED, 								VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_DRAGONSHIELD_PARTS, 									VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_PELVIS,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_HEAD,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_WINDOW, 	VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	s_dragonshield_pelvis 				= zm_craftables::generate_zombie_craftable_piece( DRAGONSHIELD_NAME, "pelvis", 	32, 64, 0, 		undefined, &dragonshield_on_pickup_common, &dragonshield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_PELVIS, CRAFTABLE_IS_SHARED, 		"build_zs" );
	s_dragonshield_head  				= zm_craftables::generate_zombie_craftable_piece( DRAGONSHIELD_NAME, "head", 		48, 15, 25, 	undefined, &dragonshield_on_pickup_common, &dragonshield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_HEAD, CRAFTABLE_IS_SHARED, 		"build_zs" );
	s_dragonshield_window  			= zm_craftables::generate_zombie_craftable_piece( DRAGONSHIELD_NAME, "window", 	48, 15, 25, 	undefined, &dragonshield_on_pickup_common, &dragonshield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_WINDOW, CRAFTABLE_IS_SHARED, 	"build_zs" );
	
	s_dragonshield 							= spawnStruct();
	s_dragonshield.name 				= DRAGONSHIELD_NAME;
	s_dragonshield.weaponname 		= DRAGONSHIELD_WEAPON;
	s_dragonshield.onbuyweapon 		= &dragonshield_on_buy_weapon;
	s_dragonshield.triggerthink 		= &dragonshield_craftable;
	s_dragonshield zm_craftables::add_craftable_piece( s_dragonshield_pelvis );
	s_dragonshield zm_craftables::add_craftable_piece( s_dragonshield_head );
	s_dragonshield zm_craftables::add_craftable_piece( s_dragonshield_window );
	
	zm_craftables::include_zombie_craftable( s_dragonshield );
	zm_craftables::add_zombie_craftable( DRAGONSHIELD_NAME, &"ZOMBIE_DRAGON_SHIELD_CRAFT", "ERROR", &"ZOMBIE_DRAGON_SHIELD_TAKEN", &dragonshield_on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::make_zombie_craftable_open( DRAGONSHIELD_NAME, DRAGONSHIELD_MODEL, ( 0, -90, 0 ), ( 0, 0, 26 ) );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function dragonshield_craftable()
{
	zm_craftables::craftable_trigger_think( DRAGONSHIELD_NAME + "_craftable_trigger", DRAGONSHIELD_NAME, DRAGONSHIELD_WEAPON, "Hold ^3&&1^7 to equip Guard of Fafnir", DELETE_TRIGGER, PERSISTENT );
}

function dragonshield_on_pickup_common( e_player )
{
	e_player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_dragon_shield_piece_pickup_vo_override ) )
		e_player thread [ [ level.craft_dragon_shield_piece_pickup_vo_override ] ]();
	
	foreach ( e_player_index in level.players )
	{
		e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_DRAGONSHIELD_CRAFTED, CLIENTFIELD_DRAGONSHIELD_PARTS, 0 );
		e_player_index thread dragonshield_show_infotext_for_duration( ZMUI_SHIELD_PART_PICKUP, ZM_CRAFTABLES_NOT_ENOUGH_PIECES_UI_DURATION );
	}
	
	self dragonshield_pickup_from_mover();
	self.piece_owner = e_player;
}

function dragonshield_on_drop_common( e_player )
{
	self dragonshield_drop_on_mover( e_player );
	self.piece_owner = undefined;
}

function dragonshield_on_fully_crafted()
{
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_DRAGONSHIELD_CRAFTED, CLIENTFIELD_DRAGONSHIELD_PARTS, 1 );
			e_player thread dragonshield_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	return 1;
}

function dragonshield_on_buy_weapon( e_player )
{
	if ( isDefined( e_player.player_shield_reset_health ) )
		e_player [ [ e_player.player_shield_reset_health ] ]();
	
	if ( isDefined( e_player.player_shield_reset_location ) )
		e_player [ [ e_player.player_shield_reset_location ] ]();
		
	e_player playSound( "zmb_craftable_buy_shield" );
	level notify( "shield_built", e_player );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function dragonshield_show_infotext_for_duration( str_infotext, n_duration )
{
	self clientfield::set_to_player( str_infotext, 1 );
	wait n_duration;
	self clientfield::set_to_player( str_infotext, 0 );
}

function dragonshield_drop_on_mover( e_player )
{
	if ( isDefined( level.craft_shield_drop_override ) )
		[ [ level.craft_dragon_shield_drop_override ] ]();
	
}

function dragonshield_pickup_from_mover()
{	
	if ( isDefined( level.craft_shield_pickup_override ) )
		[ [ level.craft_dragon_shield_pickup_override ] ]();
		
}

// ============================== FUNCTIONALITY ==============================