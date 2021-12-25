#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_castle_rocketshield.gsh;
#insert scripts\zm\craftables\_zm_craft_shield.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;

#precache( "string", "ZOMBIE_CRAFT_RIOT" );
#precache( "string", "ZOMBIE_GRAB_RIOTSHIELD" );
#precache( "triggerstring", "ZOMBIE_CRAFT_RIOT" );
#precache( "triggerstring", "ZOMBIE_GRAB_RIOTSHIELD" );
#precache( "triggerstring", "ZOMBIE_BOUGHT_RIOT" );
#precache( "string", "ZOMBIE_EQUIP_RIOTSHIELD_HOWTO" );

#namespace zm_craft_shield;

REGISTER_SYSTEM_EX( "zm_craft_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_ROCKETSHIELD_PARTS, 							VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_ROCKETSHIELD_CRAFTED, 						VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY,	VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP, 	VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 			ZMUI_SHIELD_PART_PICKUP, 										VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 			ZMUI_SHIELD_CRAFTED, 												VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	s_dolly 		= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_SHIELD, "dolly", 		32, 64, GROUND_LEVEL, undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY, 	CRAFTABLE_IS_SHARED, "build_zs" );
	s_door  	= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_SHIELD, "door", 		48, 15, 25, 					undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR, 	CRAFTABLE_IS_SHARED, "build_zs" );
	s_clamp  	= zm_craftables::generate_zombie_craftable_piece( CRAFTABLE_SHIELD, "clamp", 	48, 15, 25, 					undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP, 	CRAFTABLE_IS_SHARED, "build_zs" );
	
	s_shield = spawnStruct();
	s_shield.name = CRAFTABLE_SHIELD;
	s_shield.weaponname = ROCKETSHIELD_CASTLE_WEAPON;
	s_shield.onbuyweapon = &on_buy_weapon_riotshield;
	s_shield.triggerthink = &riotshield_craftable;
	s_shield zm_craftables::add_craftable_piece( s_dolly );
	s_shield zm_craftables::add_craftable_piece( s_door );
	s_shield zm_craftables::add_craftable_piece( s_clamp );
	
	zm_craftables::include_zombie_craftable( s_shield );
	zm_craftables::add_zombie_craftable( CRAFTABLE_SHIELD, &"ZOMBIE_CRAFT_RIOT", "ERROR", &"ZOMBIE_BOUGHT_RIOT", &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::add_zombie_craftable_vox_category( CRAFTABLE_SHIELD, "build_zs" );
	zm_craftables::make_zombie_craftable_open( CRAFTABLE_SHIELD, ROCKETSHIELD_CASTLE_MODEL, ( 0, -90, 0 ), ( 0, 0, RIOTSHIELD_OFFSET ) );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function riotshield_craftable()
{
	zm_craftables::craftable_trigger_think( CRAFTABLE_SHIELD + "_craftable_trigger", CRAFTABLE_SHIELD, ROCKETSHIELD_CASTLE_WEAPON, &"ZOMBIE_GRAB_RIOTSHIELD", DELETE_TRIGGER, PERSISTENT );
}

function on_pickup_common( e_player )
{
	e_player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_shield_piece_pickup_vo_override ) )
		e_player thread [ [ level.craft_shield_piece_pickup_vo_override ] ]();
	
	foreach( e_player_index in level.players )
	{
		e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_ROCKETSHIELD_CRAFTED, CLIENTFIELD_ROCKETSHIELD_PARTS, 0 );
		e_player_index thread show_infotext_for_duration( ZMUI_SHIELD_PART_PICKUP, ZM_CRAFTABLES_NOT_ENOUGH_PIECES_UI_DURATION );
	}

	self pickup_from_mover();
	self.piece_owner = e_player;
}

function on_drop_common( e_player )
{
	self drop_on_mover( e_player );
	self.piece_owner = undefined;
}

function on_fully_crafted()
{
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_ROCKETSHIELD_CRAFTED, CLIENTFIELD_ROCKETSHIELD_PARTS, 1 );
			e_player thread show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	return 1;
}

function on_buy_weapon_riotshield( e_player )
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

function show_infotext_for_duration( str_infotext, n_duration )
{
	self clientfield::set_to_player( str_infotext, 1 );
	wait n_duration;
	self clientfield::set_to_player( str_infotext, 0 );
}

function pickup_from_mover()
{	
	if ( isDefined( level.craft_shield_pickup_override ) )
		[ [ level.craft_shield_pickup_override ] ]();
	
}

function drop_on_mover( e_player )
{
	if ( isDefined( level.craft_shield_drop_override ) )
		[ [ level.craft_shield_drop_override ] ]();
	
}

// ============================== FUNCTIONALITY ==============================