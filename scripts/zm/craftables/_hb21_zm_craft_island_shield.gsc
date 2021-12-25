#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_powerup_shield_charge;

#using scripts\shared\ai\zombie_utility;

#insert scripts\zm\_hb21_zm_weap_island_shield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_island_shield.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace hb21_zm_craft_island_shield;

REGISTER_SYSTEM_EX( "hb21_zm_craft_island_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", CLIENTFIELD_ISLANDSHIELD_PARTS, VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", CLIENTFIELD_ISLANDSHIELD_CRAFTED, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_DOLLY,	VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_DOOR,	VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_CLAMP, VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	s_dolly = zm_craftables::generate_zombie_craftable_piece( ISLANDSHIELD_NAME, "dolly", 32, 64, 0, undefined, &island_shield_on_pickup_common, &island_shield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_DOLLY, CRAFTABLE_IS_SHARED, "build_zs" );
	s_door  = zm_craftables::generate_zombie_craftable_piece( ISLANDSHIELD_NAME, "door", 48, 15, 25, undefined, &island_shield_on_pickup_common, &island_shield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_DOOR, CRAFTABLE_IS_SHARED, "build_zs" );
	s_clamp  = zm_craftables::generate_zombie_craftable_piece( ISLANDSHIELD_NAME, "clamp", 48, 15, 25, undefined, &island_shield_on_pickup_common, &island_shield_on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_ISLANDSHIELD_CLAMP, CRAFTABLE_IS_SHARED, "build_zs" );
	
	s_shield = spawnStruct();
	s_shield.name = ISLANDSHIELD_NAME;
	s_shield.weaponname = ISLANDSHIELD_WEAPON;
	s_shield zm_craftables::add_craftable_piece( s_dolly );
	s_shield zm_craftables::add_craftable_piece( s_door );
	s_shield zm_craftables::add_craftable_piece( s_clamp );
	s_shield.onbuyweapon = &island_shield_on_buy_weapon;
	s_shield.triggerthink = &island_shield_craftable;
	
	zm_craftables::include_zombie_craftable( s_shield );
	zm_craftables::add_zombie_craftable( ISLANDSHIELD_NAME, &"ZOMBIE_CRAFT_RIOT", "ERROR", &"ZOMBIE_BOUGHT_RIOT", &island_shield_on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::make_zombie_craftable_open( ISLANDSHIELD_NAME, ISLANDSHIELD_MODEL, ( 0, -90, 0 ), ( 0, 0, 26 ) );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function island_shield_craftable()
{
	zm_craftables::craftable_trigger_think( ISLANDSHIELD_NAME + "_craftable_trigger", ISLANDSHIELD_NAME, ISLANDSHIELD_WEAPON, &"ZOMBIE_GRAB_RIOTSHIELD", DELETE_TRIGGER, PERSISTENT );
}

function island_shield_on_pickup_common( e_player )
{
	e_player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_island_shield_piece_pickup_vo_override ) )
		e_player thread [ [ level.craft_origind_shield_piece_pickup_vo_override ] ]();
	
	foreach ( e_player_index in level.players )
	{
		e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_ISLANDSHIELD_CRAFTED, CLIENTFIELD_ISLANDSHIELD_PARTS, 0 );
		e_player_index thread island_shield_show_infotext_for_duration( ZMUI_SHIELD_PART_PICKUP, ZM_CRAFTABLES_NOT_ENOUGH_PIECES_UI_DURATION );
	}

	self island_shield_pickup_from_mover();
	self.piece_owner = e_player;
}

function island_shield_on_drop_common( e_player )
{
	self island_shield_drop_on_mover( e_player );
	self.piece_owner = undefined;
}

function island_shield_on_fully_crafted()
{
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_ISLANDSHIELD_CRAFTED, CLIENTFIELD_ISLANDSHIELD_PARTS, 1 );
			e_player thread island_shield_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	return 1;
}

function island_shield_on_buy_weapon( player )
{
	if ( isDefined( player.player_shield_reset_health ) )
		player [[ player.player_shield_reset_health ]]();
	
	if ( isDefined( player.player_shield_reset_location ) )
		player [[ player.player_shield_reset_location ]]();
		
	player playSound( "zmb_craftable_buy_shield" );
	level notify( "shield_built", player );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function island_shield_show_infotext_for_duration( str_infotext, n_duration )
{
	self clientfield::set_to_player( str_infotext, 1 );
	wait n_duration;
	self clientfield::set_to_player( str_infotext, 0 );
}

function island_shield_pickup_from_mover()
{	
	if ( isDefined( level.craft_island_shield_pickup_override ) )
		[ [ level.craft_island_shield_pickup_override ] ]();
		
}

function island_shield_drop_on_mover( e_player )
{
	if ( isDefined( level.craft_shield_drop_override ) )
		[ [ level.craft_island_shield_drop_override ] ]();
	
}

// ============================== FUNCTIONALITY ==============================