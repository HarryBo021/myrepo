#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\zm\_zm_perk_vulture_aid.gsh;

#precache( "client_fx", VULTUREAID_MACHINE_LIGHT_FX );
#precache( "client_fx", VULTUREAID_GREEN_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_BLUE_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_RED_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_YELLOW_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_GREEN_MIST_FX );

#namespace zm_perk_vulture_aid;

REGISTER_SYSTEM_EX( "zm_perk_vulture_aid", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		enable_vulture_aid_perk_for_level();
	
}

function __main__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		vulture_aid_main();
	
}

function enable_vulture_aid_perk_for_level()
{
	zm_perks::register_perk_clientfields( VULTUREAID_PERK, &vulture_aid_client_field_func, &vulture_aid_callback_func );
	zm_perks::register_perk_effects( VULTUREAID_PERK, VULTUREAID_PERK );
	zm_perks::register_perk_init_thread( VULTUREAID_PERK, &vulture_aid_init );
}

function vulture_aid_init()
{
	level._effect[ VULTUREAID_PERK ] = VULTUREAID_MACHINE_LIGHT_FX;
}

function vulture_aid_client_field_func() 
{
	clientfield::register( "clientuimodel", VULTUREAID_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function vulture_aid_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function vulture_aid_main()
{	
	clientfield::register( "toplayer", VULTUREAID_STINK_CF, VERSION_SHIP, 1, "int", &vulture_aid_stink, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", VULTUREAID_DISEASE_METER_CF, VERSION_SHIP, 5, "float", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", VULTUREAID_PERK_TOPLAYER_CF, VERSION_SHIP, 1, "int", &vulture_callback_toplayer, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	clientfield::register( "scriptmover", VULTUREAID_KEYLINE_WAYPOINTS_CF, VERSION_SHIP, 1, "int", &vulture_aid_keyline_watcher, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", VULTUREAID_KEYLINE_WAYPOINTS_CF, VERSION_SHIP, 1, "int", &vulture_aid_keyline_watcher_zbarrier, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	clientfield::register( "scriptmover", VULTUREAID_ENABLE_KEYLINE_CF, VERSION_SHIP, 1, "int", &vulture_aid_enable_keyline, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_POWERUP_CF, VERSION_SHIP, getMinBitCountForNum( 4 ), "int", &vulture_aid_register_powerup, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_STINK_CF, VERSION_SHIP, 1, "int", &vulture_aid_register_stink, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function vulture_aid_stink( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_val == 1 )
		self thread vulture_aid_activate_stink( n_local_client_num );
	else
		self thread vulture_aid_deactivate_stink( n_local_client_num );
	
}

function vulture_aid_activate_stink( n_local_client_num )
{
	if ( !isDefined( self.sndstinkent ) )
	{
		self.sndstinkent = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
		self.sndstinkent playLoopSound( "zmb_perks_vulture_stink_loop", .5 );
	}
	playSound( n_local_client_num, "zmb_perks_vulture_stink_start" );
}

function vulture_aid_deactivate_stink( n_local_client_num )
{
	playSound( n_local_client_num, "zmb_perks_vulture_stink_stop" );
	if ( isDefined( self.sndstinkent ) )
	{
		self.sndstinkent stopLoopSound( n_local_client_num, .5 );
		self.sndstinkent delete();
		self.sndstinkent = undefined;
	}
}

function vulture_callback_toplayer( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_val )
		getLocalPlayers()[ n_local_client_num ] notify( "vulture_aid_active_1" );
	else
		getLocalPlayers()[ n_local_client_num ] notify( "vulture_aid_active_0" );
}

function vulture_perk_disease_meter( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	ui_model = createUIModel( getUIModelForController( n_local_client_num ), VULTUREAID_DISEASE_METER_CF );
	setUIModelValue( ui_model, n_new_val );
}

function vulture_aid_enable_keyline( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) && getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK ) )
	{
		self duplicate_render::set_dr_flag( "keyline_active", 1 );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
	else
	{
		self duplicate_render::set_dr_flag( "keyline_active", 0 );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
}

function vulture_aid_register_stink( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self vulture_aid_stink_callback( n_local_client_num, getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK ) );
	self thread vulture_aid_stink_watcher( n_local_client_num );
}

function vulture_aid_stink_watcher( n_local_client_num )
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		str_notify_recieved = getLocalPlayers()[ n_local_client_num ] util::waittill_any_return( "vulture_aid_active_0", "vulture_aid_active_1" );
		b_val = ( ( isDefined( str_notify_recieved ) && str_notify_recieved == "vulture_aid_active_1" ) ? 1 : 0 );
		
		if ( !isDefined( self ) )
			break;
		
		self vulture_aid_stink_callback( n_local_client_num, b_val );
	}
}

function vulture_aid_stink_callback( n_local_client_num, b_turn_on )
{
	if ( IS_TRUE( b_turn_on ) && isDefined( self ) )
	{
		if ( !isDefined( self.fx_vulture_aid_stink ) )
			self.fx_vulture_aid_stink = playFXOnTag( n_local_client_num, VULTUREAID_GREEN_MIST_FX, self, "tag_origin" );
		
	}
	else
	{
		if ( isDefined( self.fx_vulture_aid_stink ) )
		{
			stopFx( n_local_client_num, self.fx_vulture_aid_stink );
			self.fx_vulture_aid_stink = undefined;
		}
	}
}

function vulture_aid_register_powerup( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_val == 2 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_BLUE_POWERUP_GLOW;
	else if ( n_new_val == 3 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_RED_POWERUP_GLOW;
	else if ( n_new_val == 4 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_YELLOW_POWERUP_GLOW;
	else
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_GREEN_POWERUP_GLOW;
	
	self vutlure_aid_powerup_fx_callback( n_local_client_num, getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK ) );
	self thread vulture_aid_powerup_watcher( n_local_client_num );
}

function vulture_aid_powerup_watcher( n_local_client_num )
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		str_notify_recieved = getLocalPlayers()[ n_local_client_num ] util::waittill_any_return( "vulture_aid_active_0", "vulture_aid_active_1" );
		b_val = ( ( isDefined( str_notify_recieved ) && str_notify_recieved == "vulture_aid_active_1" ) ? 1 : 0 );
		
		if ( !isDefined( self ) )
			break;
		
		self vutlure_aid_powerup_fx_callback( n_local_client_num, b_val );
	}
}

function vutlure_aid_powerup_fx_callback( n_local_client_num, b_turn_on )
{
	if ( IS_TRUE( b_turn_on ) && isDefined( self ) )
	{
		if ( !isDefined( self.fx_vulture_aid_powerup ) )
		{
			self.fx_vulture_aid_powerup = playFXOnTag( n_local_client_num, self.str_vulture_aid_waypoint_fx_name, self, "tag_origin" );
			self duplicate_render::set_dr_flag( "keyline_active", 1 );
			self duplicate_render::update_dr_filters( n_local_client_num );
		}
	}
	else
	{
		if ( isDefined( self.fx_vulture_aid_powerup ) )
		{
			stopFx( n_local_client_num, self.fx_vulture_aid_powerup );
			self.fx_vulture_aid_powerup = undefined;
			self duplicate_render::set_dr_flag( "keyline_active", 0 );
			self duplicate_render::update_dr_filters( n_local_client_num );
		}
	}
}

function vulture_aid_keyline_watcher( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self thread vulture_aid_keyline_watcher_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump );
	else
	{
		self notify( "vulture_aid_keyline_watcher_cb" );
		self duplicate_render::set_dr_flag( "keyline_active", 0 );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
}

function vulture_aid_keyline_watcher_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self notify( "vulture_aid_keyline_watcher_cb" );
	self endon( "vulture_aid_keyline_watcher_cb" );
	
	if ( !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
		return;
	
	e_player = getLocalPlayers()[ n_local_client_num ];
	while ( isDefined( self ) )
	{
		while ( !e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) || !isAlive( e_player ) )
			WAIT_CLIENT_FRAME;
		
		self duplicate_render::set_dr_flag( "keyline_active", 1 );
		self duplicate_render::update_dr_filters( n_local_client_num );
		
		while ( isAlive( e_player ) && e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) )
			WAIT_CLIENT_FRAME;
		
		self duplicate_render::set_dr_flag( "keyline_active", 0 );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
}

function vulture_aid_keyline_watcher_zbarrier( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self thread vulture_aid_keyline_watcher_zbarrier_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump );
	else
	{
		self notify( "vulture_aid_keyline_watcher_zbarrier_cb" );
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::set_dr_flag( "keyline_active", 0 );
			e_model duplicate_render::update_dr_filters( n_local_client_num );
		}
	}
}

function vulture_aid_keyline_watcher_zbarrier_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self notify( "vulture_aid_keyline_watcher_zbarrier_cb" );
	self endon( "vulture_aid_keyline_watcher_zbarrier_cb" );
	
	if ( !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
		return;
	
	e_player = getLocalPlayers()[ n_local_client_num ];
	while ( isDefined( self ) )
	{
		while ( !e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) || !isAlive( e_player ) )
			WAIT_CLIENT_FRAME;
		
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::set_dr_flag( "keyline_active", 1 );
			e_model duplicate_render::update_dr_filters( n_local_client_num );
		}
		
		while ( isAlive( e_player ) && e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) )
			WAIT_CLIENT_FRAME;
		
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::set_dr_flag( "keyline_active", 0 );
			e_model duplicate_render::update_dr_filters( n_local_client_num );
		}
	}
}