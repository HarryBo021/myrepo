#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_mirg2000.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_mirg2000.gsh;

#namespace hb21_zm_craft_mirg2000;

REGISTER_SYSTEM_EX( "hb21_zm_craft_mirg2000", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_KT4_PARTS, 			VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_I, 									VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_II, 									VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 			CLIENTFIELD_CRAFTABLE_PIECE_KT4_III, 									VERSION_SHIP, 1, "int" );
	clientfield::register("world", CLIENTFIELD_CRAFTABLE_PIECE_KT4_ADD_TO_BOX, VERSION_SHIP, 4, "int");
	// # CLIENTFIELD REGISTRATION
	
	// # FLAG REGISTRATION
	level flag::init( "ww_obtained" );
	level flag::init( "ww1_found" );
	level flag::init( "ww2_found" );
	level flag::init( "ww3_found" );
	level flag::init( "wwup1_found" );
	level flag::init( "wwup2_found" );
	level flag::init( "wwup3_found" );
	level flag::init( "wwup_wait" );
	level flag::init( "wwup_ready" );
	level flag::init( "wwup1_placed" );
	level flag::init( "wwup2_placed" );
	level flag::init( "wwup3_placed" );
	// # FLAG REGISTRATION
	
	// # VARIABLES AND SETTINGS
	level.n_mirg2000_parts_held = 0;
	// # VARIABLES AND SETTINGS
}

function __main__()
{
	level.e_mirg2000_model = getEnt( "wonder_weapon_display", "targetname" );
	if ( isDefined( level.e_mirg2000_model ) )
		level.e_mirg2000_model hidePart( "tag_liquid" );
	
	level.e_mirg2000_upgraded_model = getEnt( "wonder_weapon_up_display", "targetname" );
	
	a_mirg2000_tables = struct::get_array( "mirg2000_craft_zm", "targetname" );
	if ( isDefined( a_mirg2000_tables ) )
		array::random( a_mirg2000_tables ) thread mirg2000_craftable_table_logic();
	
	a_mirg2000_part_plants = struct::get_array( "mirg2000_craft_zm_plant", "targetname" );
	if ( isDefined( a_mirg2000_part_plants ) )
		array::random( a_mirg2000_part_plants ) thread mirg2000_craftable_spawn_part( "ww2_found" );
		
	a_mirg2000_part_vials = struct::get_array( "mirg2000_craft_zm_vial", "targetname" );
	if ( isDefined( a_mirg2000_part_vials ) )
		array::random( a_mirg2000_part_vials ) thread mirg2000_craftable_spawn_part( "ww1_found" );
		
	a_mirg2000_part_extracts = struct::get_array( "mirg2000_craft_zm_extract", "targetname" );
	if ( isDefined( a_mirg2000_part_extracts ) )
		array::random( a_mirg2000_part_extracts ) thread mirg2000_craftable_spawn_part( "ww3_found" );
	
}

function mirg2000_craftable_spawn_part( str_notify )
{
	e_part_model = util::spawn_model( self.model, self.origin, self.angles );
	util::wait_network_frame();
	e_part_model.trigger = mirg2000_create_unitrigger( e_part_model.origin, 50, 1, &mirg2000_craftable_part_prompt_and_visibility_func );
	e_part_model thread mirg2000_craftable_part_logic( str_notify );
}

function private mirg2000_craftable_part_prompt_and_visibility_func( e_player )
{
	if ( level flag::get( "ww_obtained" ) )
		return "";
	
	return &"ZOMBIE_BUILD_PIECE_GRAB";
}

function mirg2000_craftable_part_logic( str_flag )
{
	self endon("death");
	while ( isDefined( self ) )
	{
		self.trigger waittill( "trigger", e_player );
		if ( zm_utility::is_player_valid( e_player ) )
		{
			e_player playSound( "zmb_craftable_pickup" );
			level.n_mirg2000_parts_held++;
			e_player notify( "mirg2000_part_collected" );
			zm_unitrigger::unregister_unitrigger( self.trigger );
			level flag::set( str_flag );
			self.trigger = undefined;
			level thread mirg2000_player_show_craftable_parts_ui( str_flag );
			self delete();
		}
	}
}

function mirg2000_player_show_craftable_parts_ui( str_flag )
{
	a_players = [];
	if ( self == level )
		a_players = level.players;
	else if ( isPlayer( self ) )
		a_players = array( self );
	else
		return;
	
	switch ( str_flag )
	{
		case "ww1_found":
		{
			foreach ( e_player in a_players )
			{
				e_player clientfield::set_to_player( CLIENTFIELD_CRAFTABLE_PIECE_KT4_I, 1 );
				e_player thread zm_craftables::player_show_craftable_parts_ui( "zmInventory.wonderweapon_part_wwi", CLIENTFIELD_KT4_PARTS, 0 );
			}
			break;
		}
		case "ww2_found":
		{
			foreach ( e_player in a_players )
			{
				e_player clientfield::set_to_player( CLIENTFIELD_CRAFTABLE_PIECE_KT4_II, 1 );
				e_player thread zm_craftables::player_show_craftable_parts_ui( "zmInventory.wonderweapon_part_wwii", CLIENTFIELD_KT4_PARTS, 0 );
			}
			break;
		}
		case "ww3_found":
		{
			foreach ( e_player in a_players )
			{
				e_player clientfield::set_to_player( CLIENTFIELD_CRAFTABLE_PIECE_KT4_III, 1 );
				e_player thread zm_craftables::player_show_craftable_parts_ui( "zmInventory.wonderweapon_part_wwiii", CLIENTFIELD_KT4_PARTS, 0 );
			}
			break;
		}
	}
}

function mirg2000_craftable_table_logic()
{
	self.trigger = mirg2000_create_unitrigger( self.origin, 50, 1, &mirg2000_craftable_station_prompt_and_visibility_func );
	e_mirg2000_station = getEnt( self.target, "targetname" );
	v_pos = e_mirg2000_station getTagOrigin( "mirg_cent_gun_tag_jnt" );
	v_ang = e_mirg2000_station getTagAngles( "mirg_cent_gun_tag_jnt" );
	e_mirg2000_station scene::init( "p7_fxanim_zm_island_mirg_centrifuge_table_gun_up_bundle", e_mirg2000_station );
	e_mirg2000_station_funnel = getEnt( "ww_station_funnel", "targetname" );
	e_mirg2000_station_funnel hidePart( "j_glow_green" );
	e_mirg2000_station_funnel hidePart( "j_glow_purple" );
	e_mirg2000_station_funnel hidePart( "j_glow_red" );
	level.e_mirg2000_model moveTo( v_pos, .05 );
	level.e_mirg2000_model waittill( "movedone" );
	level.e_mirg2000_model.angles = v_ang;
	level.e_mirg2000_model linkTo( e_mirg2000_station, "mirg_cent_gun_tag_jnt" );
	
	while ( isDefined( self ) )
	{
		self.trigger waittill( "trigger", e_player );
		if ( zm_utility::is_player_valid( e_player ) )
		{
			if ( level flag::get( "ww1_found" ) && !level flag::get( "wwup1_placed" ) )
			{
				level flag::set( "wwup1_placed" );
				e_mirg2000_station_funnel showPart( "j_glow_red" );
				level.n_mirg2000_parts_held--;
			}
			if ( level flag::get( "ww2_found" ) && !level flag::get( "wwup2_placed" ) )
			{
				level flag::set( "wwup2_placed" );
				e_mirg2000_station_funnel showPart( "j_glow_green" );
				level.n_mirg2000_parts_held--;
			}
			if ( level flag::get( "ww3_found" ) && !level flag::get( "wwup3_placed" ) )
			{
				level flag::set( "wwup3_placed" );
				e_mirg2000_station_funnel showPart( "j_glow_purple" );
				level.n_mirg2000_parts_held--;
			}
			if ( level flag::get( "ww1_found" ) && level flag::get( "ww2_found" ) && level flag::get( "ww3_found" ) )
			{
				zm_unitrigger::unregister_unitrigger( self.trigger );
				self.trigger = undefined;
				e_mirg2000_station scene::play( "p7_fxanim_zm_island_mirg_centrifuge_table_gun_up_bundle", e_mirg2000_station );
				e_mirg2000_station scene::play( "p7_fxanim_zm_island_mirg_centrifuge_table_turn_on_bundle", e_mirg2000_station );
				level.e_mirg2000_model showPart( "tag_liquid" );
				e_mirg2000_station scene::play( "p7_fxanim_zm_island_mirg_centrifuge_table_gun_down_bundle", e_mirg2000_station );
				self thread mirg2000_craftable_table_retrieve_weapon();
				break;
			}
			else if ( zm_utility::is_player_valid( e_player ) )
				e_player notify( "hash_f48612e4" );
			
		}
	}
}

function mirg2000_craftable_table_retrieve_weapon()
{
	self.trigger = mirg2000_create_unitrigger( self.origin, 50, 1, &mirg2000_craftable_station_retrieve_weapon_prompt_and_visibility_func );
	while ( isDefined( self ) )
	{
		self.trigger waittill( "trigger", e_player );
		if ( e_player zm_hero_weapon::is_hero_weapon_in_use() )
			continue;
		
		if ( e_player zm_utility::in_revive_trigger() )
			continue;
		
		if ( e_player.is_drinking > 0 )
			continue;
		
		if ( !zm_utility::is_player_valid( e_player ) )
			continue;
		
		if ( e_player bgb::is_enabled( "zm_bgb_disorderly_combat" ) )
			continue;
		
		zm_unitrigger::unregister_unitrigger( self.trigger );
		self.trigger = undefined;
		level thread mirg2000_craftable_give_to_player( e_player );
		break;
	}
}

function private mirg2000_craftable_station_retrieve_weapon_prompt_and_visibility_func( e_player )
{
	if ( e_player bgb::is_enabled( "zm_bgb_disorderly_combat" ) )
		return "";
	
	if ( !e_player zm_hero_weapon::is_hero_weapon_in_use() )
		return "Hold ^3[{+activate}]^7 for Kusanagi-no-Tsurugi";
	else
		return "";
	
}

function mirg2000_craftable_give_to_player( e_player )
{
	if ( e_player mirg2000_craftable_should_take_player_weapon() )
	{
		w_weapon = e_player getCurrentWeapon();
		e_player takeWeapon( w_weapon );
	}
	level.e_mirg2000_model unlink();
	level.e_mirg2000_model hide();
	e_player giveWeapon( level.w_mirg2000 );
	e_player giveMaxAmmo( level.w_mirg2000 );
	e_player switchToWeapon( level.w_mirg2000 );
	e_player notify( "mirg2000_obtained" );
	level clientfield::set( CLIENTFIELD_CRAFTABLE_PIECE_KT4_ADD_TO_BOX, 1 );
	e_player.b_has_mirg2000 = 1;
	level.zombie_weapons[ level.w_mirg2000 ].is_in_box = 1;
	e_player thread mirg2000_craftable_watch_for_loss();
	level flag::set( "ww_obtained" );
}

function mirg2000_craftable_should_take_player_weapon()
{
	a_weapons = self getWeaponsListPrimaries();
	if ( !self hasPerk( "specialty_additionalprimaryweapon" ) && a_weapons.size > 1 )
		return 1;
	else if ( self hasPerk( "specialty_additionalprimaryweapon" ) && a_weapons.size > 2 )
		return 1;
	else
		return 0;
	
}

function mirg2000_craftable_watch_for_loss()
{
	while ( isDefined( self ) )
	{
		self util::waittill_any("bled_out", "weapon_change", "disconnect");
		if ( mirg2000_craftable_players_with_weapon() == 0 )
		{
			level flag::set("players_lost_ww");
			return;
		}
	}
}

function private mirg2000_craftable_station_prompt_and_visibility_func( e_player )
{
	if ( level flag::get( "ww1_found" ) && level flag::get( "ww2_found" ) && level flag::get( "ww3_found" ) )
		return "Press ^3[{+activate}]^7 to create Formula";
	else if ( level.n_mirg2000_parts_held )
		return "Hold ^3[{+activate}]^7 to place Ingredient";
	else
		return &"ZOMBIE_BUILD_PIECE_MORE";
	
}

function mirg2000_create_unitrigger( v_origin, uk_radius, b_use_trigger = 0, ptr_func_per_player_msg )
{
	return mirg2000_create_unitrigger_internal( v_origin, undefined, uk_radius, b_use_trigger, ptr_func_per_player_msg );
}

function mirg2000_craftable_players_with_weapon()
{
	n_count = 0;
	foreach ( e_player in level.players )
	{
		if ( e_player hasWeapon( level.w_mirg2000 ) || e_player hasWeapon( level.w_mirg2000_up ) )
			n_count++;
		
	}
	return n_count;
}

function private mirg2000_create_unitrigger_internal( v_origin, v_angles = ( 0, 0, 0 ), uk_dimensions, b_use_trigger = 0, ptr_func_per_player_msg )
{
	s_trigger_stub = spawnStruct();
	s_trigger_stub.origin = v_origin;
	str_type = "unitrigger_radius";
	if ( isVec( uk_dimensions ) )
	{
		s_trigger_stub.script_length = uk_dimensions[ 0 ];
		s_trigger_stub.script_width = uk_dimensions[ 1 ];
		s_trigger_stub.script_height = uk_dimensions[ 2 ];
		str_type = "unitrigger_box";
		s_trigger_stub.angles = v_angles;
	}
	else
		s_trigger_stub.radius = uk_dimensions;
	
	if ( b_use_trigger )
	{
		s_trigger_stub.cursor_hint = "HINT_NOICON";
		s_trigger_stub.script_unitrigger_type = str_type + "_use";
	}
	else
		s_trigger_stub.script_unitrigger_type = str_type;
	
	if ( isDefined( ptr_func_per_player_msg ) )
	{
		s_trigger_stub.ptr_mirg2000_func_per_player_msg = ptr_func_per_player_msg;
		zm_unitrigger::unitrigger_force_per_player_triggers( s_trigger_stub, 1 );
	}
	s_trigger_stub.prompt_and_visibility_func = &mirg2000_prompt_and_visibility_func;
	zm_unitrigger::register_unitrigger( s_trigger_stub, &unitrigger_think );
	return s_trigger_stub;
}

function mirg2000_prompt_and_visibility_func( e_player )
{
	b_visible = 1;
	if ( IS_TRUE( e_player.beastmode ) )
		b_visible = 0;
	
	str_msg = &"";
	str_msg_param1 = undefined;
	if ( b_visible )
	{
		if ( isDefined( self.stub.ptr_mirg2000_func_per_player_msg ) )
			str_msg = self [ [ self.stub.ptr_mirg2000_func_per_player_msg ] ]( e_player );
		else
		{
			str_msg = self.stub.hint_string;
			str_msg_param1 = self.stub.hint_parm1;
		}
	}
	if ( isDefined( str_msg_param1 ) )
		self setHintString( str_msg, str_msg_param1 );
	else
		self setHintString( str_msg );
	
	return b_visible;
}

function private unitrigger_think()
{
	self endon( "kill_trigger" );
	self.stub thread mirg2000_run_visibility_function_for_all_triggers();
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		self.stub notify( "trigger", e_player );
	}
}

function mirg2000_run_visibility_function_for_all_triggers()
{
	self zm_unitrigger::run_visibility_function_for_all_triggers();
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================