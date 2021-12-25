#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_gravityspikes.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_zm_craft_gravityspikes.gsh;

#namespace zm_craft_gravityspikes;

REGISTER_SYSTEM_EX( "zm_craft_gravityspikes", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_GRAVITYSPIKE_PARTS, 								VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_GRAVITYSPIKE_CRAFTED, 							VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_BODY,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_GUARDS,	VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_HANDLE, 	VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	s_heart 			= zm_craftables::generate_zombie_craftable_piece( GRAVITYSPIKE_NAME, "part_body", 	32, 64, 0, 	undefined, &on_pickup_common_gravityspike, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_BODY, 		CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	s_skeleton 		= zm_craftables::generate_zombie_craftable_piece( GRAVITYSPIKE_NAME, "part_guards",	32, 64, 0, 	undefined, &on_pickup_common_gravityspike, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_GUARDS, 	CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	s_xenomatter 	= zm_craftables::generate_zombie_craftable_piece( GRAVITYSPIKE_NAME, "part_handle", 	32, 64, 0, 	undefined, &on_pickup_common_gravityspike, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_GRAVITYSPIKE_HANDLE, 	CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	
	s_gravityspike 						= spawnStruct();
	s_gravityspike.name 				= GRAVITYSPIKE_NAME;
	s_gravityspike.weaponname 	= STR_GRAVITYSPIKES_NAME;
	s_gravityspike.triggerthink 		= &gravityspike_craftable;
	s_gravityspike zm_craftables::add_craftable_piece( s_heart );
	s_gravityspike zm_craftables::add_craftable_piece( s_skeleton );
	s_gravityspike zm_craftables::add_craftable_piece( s_xenomatter );
	
	zm_craftables::include_zombie_craftable( s_gravityspike );
	zm_craftables::add_zombie_craftable( GRAVITYSPIKE_NAME, "Hold ^3[{+activate}]^7 to craft the Ragnarok DG-4", "", "Hold ^3[{+activate}]^7 to pick up the Ragnarok DG-4", &on_fully_crafted_gravityspike, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::make_zombie_craftable_open( GRAVITYSPIKE_NAME, "", vectorScale( ( 0, -1, 0 ), 90 ), ( 0, 0, 0 ) );
	level.zombie_craftableStubs[ GRAVITYSPIKE_NAME ].v_origin_offset = vectorScale( ( 0, 0, 1 ), 10 );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function gravityspike_craftable()
{
	zm_craftables::craftable_trigger_think( GRAVITYSPIKE_NAME + "_craftable_trigger", GRAVITYSPIKE_NAME, STR_GRAVITYSPIKES_NAME, "", DELETE_TRIGGER, ONE_TIME_CRAFT );
}

function on_pickup_common_gravityspike( e_player )
{
	e_player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_gravityspike_piece_pickup_vo_override ) )
		e_player thread [ [ level.craft_gravityspike_piece_pickup_vo_override ] ]();
		
	foreach ( e_player_index in level.players )
		e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_GRAVITYSPIKE_CRAFTED, CLIENTFIELD_GRAVITYSPIKE_PARTS, 0 );
	
	self pickup_from_mover_gravityspike();
	self.piece_owner = e_player;
}


function on_fully_crafted_gravityspike( e_player )
{
	foreach ( e_player_index in level.players )
	{
		if ( zm_utility::is_player_valid( e_player_index ) )
			e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_GRAVITYSPIKE_CRAFTED, CLIENTFIELD_GRAVITYSPIKE_PARTS, 1 );
		
	}
	self spawn_pickup_trigger_gravityspike( self.origin, self.angles );
	return 1;
}

function gravityspike_prompt_and_visibility_func( e_player )
{
	if ( !isDefined( e_player.gravityspikes_state ) || e_player.gravityspikes_state == 0 )
	{
		self setHintString( "Hold ^3[{+activate}]^7 to pick up the Ragnarok DG-4" );
		return 1;
	}
	else
	{
		self setHintString( "You already have the Ragnarok DG-4" );
		return 0;
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function spawn_pickup_trigger_gravityspike( v_origin, v_angles )
{
	s_unitrigger_stub = spawnstruct();
	s_unitrigger_stub.origin = v_origin;
	s_unitrigger_stub.angles = v_angles;
	s_unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_unitrigger_stub.script_width = 128;
	s_unitrigger_stub.script_height = 128;
	s_unitrigger_stub.script_length = 128;
	s_unitrigger_stub.require_look_at = 1;
	s_align = struct::get( self.target, "targetname" );
	s_unitrigger_stub.e_gravityspike_model = util::spawn_model( "wpn_zmb_dlc1_talon_spikes_world", s_align.origin + vectorScale( ( 1, 0, 0 ), 5 ) + vectorScale( ( 0, 0, 1 ), 25 ), s_align.angles + vectorScale( ( 0, -1, 0 ), 90 ) );
	s_unitrigger_stub.prompt_and_visibility_func = &gravityspike_prompt_and_visibility_func;
	zm_unitrigger::register_static_unitrigger( s_unitrigger_stub, &gravityspike_trigger_logic );
}

function gravityspike_trigger_logic()
{
	self endon( "kill_trigger" );
	
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player zm_utility::in_revive_trigger() )
			continue;
	
		if ( IS_DRINKING( e_player.is_drinking ) )
			continue;

		if ( !zm_utility::is_player_valid( e_player ) )
			continue;
		
		level thread gravityspike_pickup( self.stub, e_player );
		break;
	}
}

function gravityspike_pickup( trig_stub, e_player )
{
	if ( !isDefined( e_player.gravityspikes_state ) || e_player.gravityspikes_state == 0 )
	{
		w_gravityspikes = getWeapon( "hero_gravityspikes_melee" );
		e_player zm_weapons::weapon_give( w_gravityspikes, 0, 1 );
		e_player thread zm_equipment::show_hint_text( "Press ^3[{+ability}]^7 to activate the Ragnarok DG-4", 3 );
		e_player gadgetPowerSet( e_player gadgetGetSlot( w_gravityspikes ), 100 );
		e_player zm_weap_gravityspikes::update_gravityspikes_state( 2 );
		e_player playRumbleOnEntity( "zm_castle_interact_rumble" );
	}
}

function pickup_from_mover_gravityspike()
{	
	if ( isDefined( level.craft_gravityspike_pickup_override ) )
		[ [ level.craft_gravityspike_pickup_override ] ]();
	
}

// ============================== FUNCTIONALITY ==============================