#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_perk_utility;

REGISTER_SYSTEM( "zm_perk_utility", &__init__, undefined )

function __init__()
{		
	clientfield::register( "scriptmover", "remove_objective_id", VERSION_SHIP, getMinBitCountForNum( 1 ), "int", &remove_obj_id, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "set_objective_id", VERSION_SHIP, getMinBitCountForNum( 128 ), "int", &create_and_set_obj_id, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "remove_objective_id", VERSION_SHIP, getMinBitCountForNum( 1 ), "int", &remove_obj_id, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "set_objective_id", VERSION_SHIP, getMinBitCountForNum( 128 ), "int", &create_and_set_obj_id, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	callback::on_localplayer_spawned( &on_localplayer_spawned );
	
	level.a_priority_waypoints = [];
	level.a_priority_waypoints[ 0 ] = [];
	level.a_priority_waypoints[ 1 ] = [];
}

function is_stock_map()
{
	script = toLower( getDvarString( "mapname" ) );
	switch ( script )
	{
		case "zm_factory":
		case "zm_zod":
		case "zm_castle":
		case "zm_island":
		case "zm_stalingrad":
		case "zm_genesis":
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		case "zm_cosmodrome":
		case "zm_temple":
		case "zm_moon":
		case "zm_tomb":
			return 1;
		default:
			return 0;
			
	}
}

function on_localplayer_spawned( n_client_num )
{
	self thread arrange_priority_waypoints( n_client_num );
}

function arrange_priority_waypoints( n_client_num )
{
	self notify( "arrange_priority_waypoints" );
	self endon( "arrange_priority_waypoints" );
	self endon( "disconnect" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		reorder_priority_waypoints( n_client_num );
		WAIT_CLIENT_FRAME;
	}
}

function remove_obj_id( n_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_demo_jump )
{
	str_field_name = "objective" + self.n_obj_id;
	setUIModelValue( getUIModel( getUIModelForController( n_client_num ), str_field_name + ".priority" ), -100 );
	arrayRemoveValue( level.a_priority_waypoints[ n_client_num ], self );
}

function create_and_set_obj_id( n_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_demo_jump )
{
	self.n_obj_id = n_new_value;
	level.a_priority_waypoints[ n_client_num ][ level.a_priority_waypoints[ n_client_num ].size ] = self;
	str_field_name = "objective" + self.n_obj_id;
	setUIModelValue( createUIModel( getUIModelForController( n_client_num ), str_field_name + ".priority" ), -100 );
}

function reorder_priority_waypoints( n_client_num )
{
	a_priority_waypoints[ n_client_num ] = array::get_all_closest( getLocalPlayers()[ n_client_num ].origin, level.a_priority_waypoints[ n_client_num ] );
	if ( isDefined( level.a_priority_waypoints[ n_client_num ] ) && isArray( level.a_priority_waypoints[ n_client_num ] ) && level.a_priority_waypoints[ n_client_num ].size > 0 )
	{
		for ( i = 0; i < a_priority_waypoints[ n_client_num ].size; i++ )
		{
			str_field_name = "objective" + a_priority_waypoints[ n_client_num ][ i ].n_obj_id;
			setUIModelValue( getUIModel( getUIModelForController( n_client_num ), str_field_name + ".priority" ), -100 );
		}
		n_priority = -1;
		for ( i = 0; i < a_priority_waypoints[ n_client_num ].size; i++ )
		{
			if ( !isDefined( a_priority_waypoints[ n_client_num ][ i ].n_obj_id ) )
				continue;
			
			str_field_name = "objective" + a_priority_waypoints[ n_client_num ][ i ].n_obj_id;
			setUIModelValue( getUIModel( getUIModelForController( n_client_num ), str_field_name + ".priority" ), n_priority );
			n_priority -= 1;
		}
	}
}