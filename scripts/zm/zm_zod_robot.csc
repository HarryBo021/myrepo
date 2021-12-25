#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\archetype_zod_companion;
#using scripts\zm\craftables\_hb21_zm_craft_fuse;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_zod_robot;

#precache( "client_fx", "zombie/fx_fuse_master_switch_on_zod_zmb" );

REGISTER_SYSTEM_EX( "zm_zod_robot", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

/*
	Name: __init__
	Namespace: zm_zod_robot
	Checksum: 0xE94728A4
	Offset: 0x300
	Size: 0xBB
	Parameters: 0
	Flags: None
*/
function __init__()
{
	// # SPAWN SET UP
	ai::add_archetype_spawn_function( "zod_companion", &zod_robot_spawn );
	// # SPAWN SET UP
	
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", "robot_switch", 1, 1, "int", &zod_robot_switch, 0, 0 );
	clientfield::register( "world", "robot_lights", 1, 2, "int", &zod_robot_lights, 0, 0 );
	// # CLIENTFIELD REGISTRATION	
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== FUNCTIONALITY ==============================

function private zod_robot_spawn( n_local_client_num )
{
	self setDrawName( "Civil Protector" ); // self setDrawName( &"ZM_ZOD_ROBOT_NAME" );
}

function zod_robot_switch( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	playFX( n_local_client_num, "zombie/fx_fuse_master_switch_on_zod_zmb", self.origin );
}

function zod_robot_lights( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	switch ( n_new_val )
	{
		case 1:
		{
			exploder::exploder( "lgt_robot_callbox_green" );
			exploder::stop_exploder( "lgt_robot_callbox_red" );
			exploder::stop_exploder( "lgt_robot_callbox_yellow" );
			break;
		}
		case 2:
		{
			exploder::stop_exploder( "lgt_robot_callbox_green" );
			exploder::exploder( "lgt_robot_callbox_red" );
			exploder::stop_exploder( "lgt_robot_callbox_yellow" );
			break;
		}
		case 3:
		{
			exploder::stop_exploder( "lgt_robot_callbox_green" );
			exploder::stop_exploder( "lgt_robot_callbox_red" );
			exploder::exploder( "lgt_robot_callbox_yellow" );
			break;
		}
		default:
		{
			exploder::stop_exploder( "lgt_robot_callbox_green" );
			exploder::stop_exploder( "lgt_robot_callbox_red" );
			exploder::stop_exploder( "lgt_robot_callbox_yellow" );
			break;
		}
	}
}

// ============================== FUNCTIONALITY ==============================