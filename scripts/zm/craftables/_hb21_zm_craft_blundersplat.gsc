/*#===================================================================###
###                                                                   ###
###                                                                   ###
###        Harry Bo21s Black Ops 3 Acidgat Upgrade Station v1.0.0	  ###
###                                                                   ###
###                                                                   ###
###===================================================================#*/
/*=======================================================================

								CREDITS

=========================================================================
Lilrifa
Easyskanka
ProRevenge
DTZxPorter
Zeroy
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MZSlayer
AndyWhelen
HitmanVere
ProGamerzFTW
Scobalula
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
=======================================================================*/
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_hb21_zm_weap_blundersplat;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_blundersplat.gsh;
#insert scripts\zm\_hb21_zm_weap_blundersplat.gsh;

#namespace zm_craft_blundersplat;

REGISTER_SYSTEM_EX( "zm_craft_blundersplat", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	clientfield::register( "clientuimodel", CLIENTFIELD_BLUNDERSPLAT_CRAFTED, VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", CLIENTFIELD_BLUNDERSPLAT_PARTS, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_0, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_1, VERSION_SHIP, 1, "int" );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_2, VERSION_SHIP, 1, "int" );
}

function __main__()
{
	part_0 = zm_craftables::generate_zombie_craftable_piece( 	BLUNDERSPLAT_NAME, "part_0", 32, 64, 0, 		undefined, &on_pickup_common, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_0, CRAFTABLE_IS_SHARED, "build_zs" );
	part_1 = zm_craftables::generate_zombie_craftable_piece( 	BLUNDERSPLAT_NAME, "part_1", 48, 15, 25, 	undefined, &on_pickup_common, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_1, CRAFTABLE_IS_SHARED, "build_zs" );
	part_2 = zm_craftables::generate_zombie_craftable_piece( 	BLUNDERSPLAT_NAME, "part_2", 48, 15, 25, 	undefined, &on_pickup_common, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_2, CRAFTABLE_IS_SHARED, "build_zs" );
	
	craftable_object 									= spawnStruct();
	craftable_object.name 							= BLUNDERSPLAT_NAME;
	craftable_object.weaponname 				= BLUNDERSPLAT_WEAPON;
	craftable_object.equipname 					= BLUNDERSPLAT_WEAPON;
	craftable_object zm_craftables::add_craftable_piece( part_0 );
	craftable_object zm_craftables::add_craftable_piece( part_1 );
	craftable_object zm_craftables::add_craftable_piece( part_2 );
	craftable_object.onBuyWeapon 			= &on_buy_weapon_craftable;
	craftable_object.triggerThink 				= &template_craftable;
	
	zm_craftables::include_zombie_craftable( craftable_object );
	
	zm_craftables::add_zombie_craftable( BLUNDERSPLAT_NAME, CRAFT_READY_STRING, "ERROR", CRAFT_GRABED_STRING, &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::add_zombie_craftable_vox_category( BLUNDERSPLAT_NAME, "build_zs" );
	zm_craftables::make_zombie_craftable_open( BLUNDERSPLAT_NAME, BLUNDERSPLAT_MODEL, ( 0, -90, 0 ), ( 0, 0, -3 ) ); // COMMENT THIS OUT IF YOU WANT TO ONLY BUILD IT AT ITS DEDICATED TRIGGER - OTHERWISE PLACE THAT TRIGGER UNDER THE MAP
}

function template_craftable()
{
	zm_craftables::craftable_trigger_think( BLUNDERSPLAT_NAME + "_craftable_trigger", BLUNDERSPLAT_NAME, BLUNDERSPLAT_WEAPON, CRAFT_GRAB_STRING, DELETE_TRIGGER, ONE_TIME_CRAFT );
}

function on_pickup_common( player )
{
	player playSound( "zmb_craftable_pickup" );	
	
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread acidkit_player_show_craftable_parts_ui( CLIENTFIELD_BLUNDERSPLAT_CRAFTED, CLIENTFIELD_BLUNDERSPLAT_PARTS, 0 );
			e_player thread acidkit_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	self pickup_from_mover();
	self.piece_owner = player;
}

function acidkit_player_show_craftable_parts_ui( str_crafted_clientuimodel, str_widget_clientuimodel, b_is_crafted )
{
	self notify( "acidkit_player_show_craftable_parts_ui" );
	self endon( "acidkit_player_show_craftable_parts_ui" );
	
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
	
	self thread acidkit_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, n_show_ui_duration );
}

function acidkit_player_hide_craftable_parts_ui_after_duration( str_widget_clientuimodel, n_show_ui_duration )
{
	self endon( "disconnect" );
	self endon( "acidkit_player_show_craftable_parts_ui" );
	
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 1 );
	wait n_show_ui_duration;
	self thread clientfield::set_player_uimodel( str_widget_clientuimodel, 0 );
}

function acidkit_show_infotext_for_duration( str_infotext, n_duration )
{
	self clientfield::set_to_player( str_infotext, 1 );
	wait n_duration;
	self clientfield::set_to_player( str_infotext, 0 );
}

function pickup_from_mover()
{	
	if ( isDefined( level.craft_blundersplat_pickup_override ) )
		[ [ level.craft_blundersplat_pickup_override ] ]();
}

function on_fully_crafted()
{
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player thread acidkit_player_show_craftable_parts_ui( CLIENTFIELD_BLUNDERSPLAT_CRAFTED, CLIENTFIELD_BLUNDERSPLAT_PARTS, 1 );
			e_player thread acidkit_show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	table_model = getEnt( self.target, "targetname" );
	level thread hb21_zm_weap_blundersplat::blundersplat_upgrade_machine( self, self.model );
	return 1;
}

function on_buy_weapon_craftable( player )
{
	player playSound( "zmb_craftable_buy_shield" );
}

