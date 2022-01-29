#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
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
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\shared\ai\zombie_utility;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_slipgun.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace hb21_zm_craft_slipgun;

REGISTER_SYSTEM_EX( "zm_craft_slipgun", &__init__, &__main__, undefined )

// SLIQUIFIER

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	clientfield::register( "clientuimodel", CLIENTFIELD_SLIPGUN_CRAFTED, VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", CLIENTFIELD_SLIPGUN_PARTS, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_COOKER,	VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_EXTINGUISHER, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_FOOT, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_THROTTLE, VERSION_SHIP, 1, "int" );
}

function __main__()
{
	slipgun_cooker 			= zm_craftables::generate_zombie_craftable_piece( SLIPGUN_NAME, "cooker", 32, 64, 0, undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_COOKER, CRAFTABLE_IS_SHARED, "build_zs" );
	slipgun_extinguisher  	= zm_craftables::generate_zombie_craftable_piece( SLIPGUN_NAME, "extinguisher", 48, 15, 0, undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_EXTINGUISHER, CRAFTABLE_IS_SHARED, "build_zs" );
	slipgun_foot  				= zm_craftables::generate_zombie_craftable_piece( SLIPGUN_NAME, "foot", 48, 15, 0, undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_FOOT, CRAFTABLE_IS_SHARED, "build_zs" );
	slipgun_throttle  		= zm_craftables::generate_zombie_craftable_piece( SLIPGUN_NAME, "throttle", 48, 15, 0, undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_SLIPGUN_THROTTLE, CRAFTABLE_IS_SHARED, "build_zs" );
	
	slipgun 																= spawnStruct();
	slipgun.name 															= SLIPGUN_NAME;
	slipgun.weaponname 														= SLIPGUN_WEAPON;
	slipgun zm_craftables::add_craftable_piece( slipgun_cooker ); // , "tag_cooker" );
	slipgun zm_craftables::add_craftable_piece( slipgun_extinguisher ); // , "tag_co2" );
	slipgun zm_craftables::add_craftable_piece( slipgun_foot ); // , "tag_foot" );
	slipgun zm_craftables::add_craftable_piece( slipgun_throttle ); // , "tag_throttle" );
	slipgun.onBuyWeapon 													= &on_buy_weapon_slipgun;
	slipgun.triggerThink 													= &slipgun_craftable;
	
	zm_craftables::include_zombie_craftable( slipgun );
	
	zm_craftables::add_zombie_craftable( 				SLIPGUN_NAME, CRAFT_READY_STRING, 	"ERROR", 		CRAFT_GRABED_STRING, 		&on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::add_zombie_craftable_vox_category( 	SLIPGUN_NAME, "build_zs" );
	zm_craftables::make_zombie_craftable_open( 			SLIPGUN_NAME, SLIPGUN_MODEL, 		( 0, 0, 0 ), 	( 0, 0, SLIPGUN_OFFSET ) );
}

function slipgun_craftable()
{
	zm_craftables::craftable_trigger_think( SLIPGUN_NAME + "_craftable_trigger", SLIPGUN_NAME, SLIPGUN_WEAPON, CRAFT_GRAB_STRING, DELETE_TRIGGER, ONE_USE_AND_FLY );
}

function on_pickup_common( player )
{
	player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_slipgun_piece_pickup_vo_override ) )
		player thread [[level.craft_slipgun_piece_pickup_vo_override]]();
	
	foreach ( e_player in level.players )
	{
		e_player thread slipgun_player_show_craftable_parts_ui( CLIENTFIELD_SLIPGUN_CRAFTED, CLIENTFIELD_SLIPGUN_PARTS, 0 );
		e_player thread slipgun_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
	}

	self pickup_from_mover();
	self.piece_owner = player;
}

function on_drop_common( player )
{
	self drop_on_mover( player );
	self.piece_owner = undefined;
}

function pickup_from_mover()
{	
	if ( isDefined( level.craft_slipgun_pickup_override ) )
		[ [ level.craft_slipgun_pickup_override ] ]();
	
}

function on_fully_crafted()
{
	players = level.players;
	foreach( e_player in players )
	{
		if( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread slipgun_player_show_craftable_parts_ui( CLIENTFIELD_SLIPGUN_CRAFTED, CLIENTFIELD_SLIPGUN_PARTS, 1 );
			e_player thread slipgun_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	// table_model = getEnt( self.target, "targetname" );
	
	// level thread acid_gat_kit_logic( self, self.model );
	
	return 1;
}

function slipgun_player_show_craftable_parts_ui( str_crafted_clientuimodel, str_widget_clientuimodel, b_is_crafted )
{
	self notify( "slipgun_player_show_craftable_parts_ui" );
	self endon( "slipgun_player_show_craftable_parts_ui" );
	
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
	
	self thread slipgun_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, n_show_ui_duration );
}

function slipgun_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, n_show_ui_duration )
{
	self endon( "disconnect" );
	self endon( "slipgun_player_show_craftable_parts_ui" );
	
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 1 );
	wait n_show_ui_duration;
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 0 );
}

function slipgun_show_infotext_for_duration( str_infotext, n_duration )
{
	self clientfield::set_to_player( str_infotext, 1 );
	wait n_duration;
	self clientfield::set_to_player( str_infotext, 0 );
}

function drop_on_mover( player )
{
	if( isDefined( level.craft_slipgun_drop_override ) )
		[[level.craft_slipgun_drop_override]]();
	
}

function on_buy_weapon_slipgun( player )
{
	// player playSound( "zmb_craftable_buy_shield" );
	level notify( "sliquifier_built", player );
}

