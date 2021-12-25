#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\shared\ai\zombie_utility;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
// #insert scripts\zm\craftables\_hb21_zm_craft_blundersplat.gsh;
// #insert scripts\zm\_hb21_zm_weap_blundersplat.gsh;

#namespace zm_craft_fuse;

#precache( "model", "p7_zm_zod_fuse" );

REGISTER_SYSTEM_EX( "zm_craft_fuse", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	s_fuse_01 = zm_craftables::generate_zombie_craftable_piece( "police_box", "fuse_01", 32, 64, 0, undefined, &fuse_on_pick_up, undefined, &fuse_on_crafted, undefined, undefined, undefined, "police_box_fuse_01", 1, undefined, undefined, "Hold ^3[{+activate}]^7 to Pick Up the Fuse.", 4 ); // &"ZM_ZOD_POLICE_BOX_PICKUP_FUSE"
	s_fuse_02 = zm_craftables::generate_zombie_craftable_piece( "police_box", "fuse_02", 32, 64, 0, undefined, &fuse_on_pick_up, undefined, &fuse_on_crafted, undefined, undefined, undefined, "police_box_fuse_02", 1, undefined, undefined, "Hold ^3[{+activate}]^7 to Pick Up the Fuse.", 4 ); // &"ZM_ZOD_POLICE_BOX_PICKUP_FUSE"
	s_fuse_03 = zm_craftables::generate_zombie_craftable_piece( "police_box", "fuse_03", 32, 64, 0, undefined, &fuse_on_pick_up, undefined, &fuse_on_crafted, undefined, undefined, undefined, "police_box_fuse_03", 1, undefined, undefined, "Hold ^3[{+activate}]^7 to Pick Up the Fuse.", 4 ); // &"ZM_ZOD_POLICE_BOX_PICKUP_FUSE"
	s_craftable_object = spawnStruct();
	s_craftable_object.name = "police_box";
	s_craftable_object zm_craftables::add_craftable_piece( s_fuse_01, "j_fuse_01" );
	s_craftable_object zm_craftables::add_craftable_piece( s_fuse_02, "j_fuse_02" );
	s_craftable_object zm_craftables::add_craftable_piece( s_fuse_03, "j_fuse_03" );
	s_craftable_object.triggerThink = &fuse_trigger_think;
	s_craftable_object.no_challenge_stat = 1;
	level flag::init( "fuse_01_found" );
	level flag::init( "fuse_02_found" );
	level flag::init( "fuse_03_found" );
	level flag::init( "police_box_fuse_place" );
	zm_craftables::include_zombie_craftable( s_craftable_object );
	zm_craftables::add_zombie_craftable( "police_box", "Hold ^3[{+activate}]^7 to Place Fuse.", "Hold ^3[{+activate}]^7 to Place Fuse.", "Hold ^3[{+activate}]^7 to Power On Civil Protectors.", &fuse_on_fully_crafted ); // &"ZM_ZOD_POLICE_BOX_PLACE_FUSE", &"ZM_ZOD_POLICE_BOX_PLACE_FUSE", &"ZM_ZOD_POLICE_BOX_POWER_ON"
	zm_craftables::set_build_time( "police_box", 0 );
	
	RegisterClientField( "world", "police_box_fuse_01", 1, 1, "int", undefined, 0 );
	RegisterClientField( "world", "police_box_fuse_02", 1, 1, "int", undefined, 0 );
	RegisterClientField( "world", "police_box_fuse_03", 1, 1, "int", undefined, 0 );
	RegisterClientField( "scriptmover", "item_glow_fx", 1, 1, "int" );
	
	level thread fuse_set_glow();
}

function fuse_set_glow()
{
	wait .05;
	level flag::wait_till( "start_zombie_round_logic" );
	level flag::wait_till( "initial_blackscreen_passed" );
	
	a_fuses = array( "fuse_01", "fuse_02", "fuse_03" );
	foreach ( str_fuse in a_fuses )
	{
		e_fuse = level zm_craftables::get_craftable_piece_model( "police_box", str_fuse );
		e_fuse clientfield::set( "item_glow_fx", 1 );
	}
}

function fuse_on_fully_crafted( e_player )
{
	level notify( "police_box_fully_crafted" );
	foreach ( e_player in level.players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			// e_player thread zm_craftables::player_show_craftable_parts_ui("zmInventory.player_crafted_fusebox", "zmInventory.widget_fuses", 1);
			// e_player thread namespace_8e578893::show_infotext_for_duration("ZM_ZOD_UI_FUSE_CRAFTED", 3.5);
		}
	}
	return 1;
}

function fuse_trigger_think()
{
	zm_craftables::craftable_trigger_think( "police_box_usetrigger", "police_box", "police_box", "", 1, 0 );
}

function fuse_on_pick_up( player )
{
	level flag::set( self.pieceName + "_found" );
	self playSound( "zmb_zod_fuse_pickup" );
	foreach ( e_player in level.players )
	{
		// e_player thread zm_craftables::player_show_craftable_parts_ui("zmInventory.player_crafted_fusebox", "zmInventory.widget_fuses", 0);
		// e_player thread namespace_8e578893::show_infotext_for_duration("ZM_ZOD_UI_FUSE_PICKUP", 3.5);
	}
}

function fuse_on_crafted( e_player )
{
	e_police_box = getEnt( "police_box", "targetname" );
	if ( isDefined( e_police_box ) )
		e_police_box playSound( "zmb_zod_fuse_place" );
	
	foreach ( e_player in level.players )
	{
		// e_player thread zm_craftables::player_show_craftable_parts_ui("zmInventory.player_crafted_fusebox", "zmInventory.widget_fuses", 0);
		// e_player thread namespace_8e578893::show_infotext_for_duration("ZM_ZOD_UI_FUSE_PLACED", 3.5);
	}
}

function __main__()
{
}