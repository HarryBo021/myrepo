#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perk_widows_wine;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_spiders.gsh;

#precache( "client_fx", "dlc2\island\fx_spider_round_tell" );
#precache( "client_fx", "dlc2\island\fx_web_grenade_tell" );
#precache( "client_fx", "dlc2\island\fx_web_bgb_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_bgb_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_perk_machine_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_perk_machine_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_barrier_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_barrier_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_impact_rocket" );
#precache( "client_fx", "dlc2\island\fx_spider_round_tell" );

#namespace zm_ai_spiders;

REGISTER_SYSTEM_EX( "zm_ai_spiders", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "toplayer", "spider_round_fx", VERSION_SHIP, 1, "counter", &spider_round_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "spider_round_ring_fx", VERSION_SHIP, 1, "counter", &spider_round_ring_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "spider_end_of_round_reset", VERSION_SHIP, 1, "counter", &spider_end_of_round_reset, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "set_fade_material", VERSION_SHIP, 1, "int", &set_fade_material, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "web_fade_material", VERSION_SHIP, 3, "float", &web_fade_material, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "play_grenade_stuck_in_web_fx", VERSION_SHIP, 1, "int", &play_grenade_stuck_in_web_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "play_spider_web_tear_fx", VERSION_SHIP, getMinBitCountForNum( 4 ), "int", &play_spider_web_tear_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "play_spider_web_tear_complete_fx", VERSION_SHIP, getMinBitCountForNum( 4 ), "int", &play_spider_web_tear_complete_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "force_stream_spiders", VERSION_SHIP, 1, "int", &force_stream_spiders, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "spider_round" ] = "dlc2/island/fx_spider_round_tell";
	level._effect[ "spider_web_grenade_stuck" ] = "dlc2/island/fx_web_grenade_tell";
	level._effect[ "spider_web_bgb_tear" ] = "dlc2/island/fx_web_bgb_tearing";
	level._effect[ "spider_web_bgb_tear_complete" ] = "dlc2/island/fx_web_bgb_reveal";
	level._effect[ "spider_web_perk_machine_tear" ] = "dlc2/island/fx_web_perk_machine_tearing";
	level._effect[ "spider_web_perk_machine_tear_complete" ] = "dlc2/island/fx_web_perk_machine_reveal";
	level._effect[ "spider_web_doorbuy_tear" ] = "dlc2/island/fx_web_barrier_tearing";
	level._effect[ "spider_web_doorbuy_tear_complete" ] = "dlc2/island/fx_web_barrier_reveal";
	level._effect[ "spider_web_tear_explosive" ] = "dlc2/island/fx_web_impact_rocket";
	
	vehicle::add_vehicletype_callback( "spider", &spider_init );
	visionset_mgr::register_visionset_info( "zm_isl_parasite_spider_visionset", VERSION_SHIP, 16, undefined, "zm_isl_parasite_spider" );
}

function __main__()
{
}

function force_stream_spiders( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if ( newVal )
		forceStreamXModel( "c_zom_dlc2_spider" );
	else
		stopForceStreamingXModel( "c_zom_dlc2_spider" );
	
}

function spider_init( localclientnum )
{
	self.str_tag_tesla_death_fx = "j_spineupper";
	self.str_tag_tesla_shock_eyes_fx = "j_spineupper";
}

function spider_round_fx( n_local_client, n_val_old, n_val_new, b_ent_new, b_initial_snap, str_field, b_demo_jump )
{
	self endon( "disconnect" );
	setWorldFogActiveBank( n_local_client, 8 );
	if ( isSpectating( n_local_client ) )
		return;
	
	self.fx_spider_camera_fx = playFxOnCamera( n_local_client, level._effect[ "spider_round" ] );
	playSound( 0, "zmb_spider_round_webup", ( 0, 0, 0 ) );
	WAIT_CLIENT_FRAME;
	self thread postfx::playpostfxbundle( "pstfx_parasite_spider" );
	wait 3.5;
	deleteFx( n_local_client, self.fx_spider_camera_fx );
}

function spider_end_of_round_reset( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval == 1 )
		setWorldFogActiveBank( localclientnum, 1 );
	
}

function spider_round_ring_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "disconnect" );
	if ( isSpectating( localclientnum ) )
		return;
	
	self thread postfx::playpostfxbundle( "pstfx_ring_loop" );
	wait 1.5;
	self postfx::exitpostfxbundle();
}

function web_fade_transition( localclientnum, str_vector, n_offset, b_on, n_alpha = 1, b_instant = 0, b_sqr = 0 )
{
	self endon( "entityshutdown" );
	if ( self.b_on === b_on )
		return;
	
	self.b_on = b_on;
	if ( b_instant )
	{
		if ( b_on )
			self transition_shader( localclientnum, n_alpha, str_vector );
		else
			self transition_shader( localclientnum, 0, str_vector );
		
		return;
	}
	if ( b_on )
	{
		n_current_alpha = 0;
		i = 0;
		while ( n_current_alpha <= n_alpha )
		{
			self transition_shader( localclientnum, n_current_alpha, str_vector );
			if ( b_sqr )
				n_current_alpha = sqrt( i );
			else
				n_current_alpha = i;
			
			wait .01;
			i = i + n_offset;
		}
		self.n_web_alpha = n_alpha;
		self transition_shader( localclientnum, n_alpha, str_vector );
	}
	else if ( isDefined( self.n_web_alpha ) )
		n_web_alpha = self.n_web_alpha;
	else
		n_web_alpha = 1;
	
	n_current_alpha = n_web_alpha;
	i = n_web_alpha;
	while ( n_current_alpha >= 0 )
	{
		self transition_shader( localclientnum, n_current_alpha, str_vector );
		if ( b_sqr )
			n_current_alpha = sqrt( i );
		else
			n_current_alpha = i;
		
		wait .01;
		i = i - n_offset;
	}
	self transition_shader( localclientnum, 0, str_vector );
}

function transition_shader( localclientnum, n_value, str_vector )
{
	self mapShaderConstant( localclientnum, 0, "scriptVector" + str_vector, n_value, n_value, 0, 0 );
}

function set_fade_material( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self mapShaderConstant( localclientnum, 0, "scriptVector0", newval, 0, 0, 0 );
}

function web_fade_material( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	b_web_on = 0;
	if ( newval <= 0 )
	{
		b_web_on = 0;
		n_web_alpha = newval;
	}
	else
	{
		b_web_on = 1;
		n_web_alpha = newval;
	}
	self thread web_fade_transition( localclientnum, 0, .025, b_web_on, n_web_alpha );
}

function play_grenade_stuck_in_web_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( isDefined( self ) )
		playFxOnTag( localclientnum, level._effect[ "spider_web_grenade_stuck" ], self, "tag_origin" );
	
}

function play_spider_web_tear_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	switch ( newval )
	{
		case 0:
		{
			if ( isDefined( self ) && isDefined( self.fx_web_tear ) )
			{
				stopfx( localclientnum, self.fx_web_tear );
				self.fx_web_tear = undefined;
			}
			if ( isDefined( self ) && isDefined( self.snd_web_tear ) )
			{
				self stopLoopSound( self.snd_web_tear, .5 );
				self playSound( 0, "zmb_spider_web_tear_stop" );
				self.snd_web_tear = undefined;
			}
			return;
		}
		case 1:
		{
			str_effect = "spider_web_bgb_tear";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear";
			break;
		}
		default:
		{
			return;
		}
	}
	if ( !isDefined( self.snd_web_tear ) )
	{
		self.snd_web_tear = self playloopsound( "zmb_spider_web_tear_loop", 1 );
		self playSound( 0, "zmb_spider_web_tear_start" );
	}
	if ( !isDefined( self.fx_web_tear ) )
		self.fx_web_tear = playFx( localclientnum, level._effect[ str_effect ], self.origin, anglestoforward( self.angles ), anglestoup( self.angles ) );
	
}

function play_spider_web_tear_complete_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	switch ( newval )
	{
		case 1:
		{
			str_effect = "spider_web_bgb_tear_complete";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear_complete";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear_complete";
			break;
		}
		case 4:
		{
			str_effect = "spider_web_tear_explosive";
			break;
		}
		default:
		{
			return;
		}
	}
	playFx( localclientnum, level._effect[ str_effect ], self.origin, anglestoforward( self.angles ), anglestoup( self.angles ) );
}