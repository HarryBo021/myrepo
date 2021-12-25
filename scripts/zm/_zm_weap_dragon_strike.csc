#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_dragon_strike.gsh;

#namespace dragon_strike;

#precache( "client_fx", DRAGON_STRIKE_PORTAL_FX );
#precache( "client_fx", DRAGON_STRIKE_BEACON_FX );
#precache( "client_fx", DRAGON_STRIKE_ZOMBIE_FIRE_FX );
#precache( "client_fx", DRAGON_STRIKE_MOUTH_FX );
#precache( "client_fx", DRAGON_STRIKE_TONGUE_FX );

REGISTER_SYSTEM_EX( "zm_weap_dragon_strike", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", DRAGON_STRIKE_SPAWN_FX_CF, VERSION_SHIP, 1, "int", &dragon_strike_spawn_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_ON_CF, VERSION_SHIP, 1, "int", &dragon_strike_marker_on, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_FX_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_FX_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_upgraded_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_INVALID_FX_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_invalid_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_INVALID_FX_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_upgraded_invalid_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_FLARE_FX_CF, VERSION_SHIP, 1, "int", &dragon_strike_flare_fx, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_FX_FADEOUT_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_fx_fadeout, 0, 0 );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_FX_FADEOUT_CF, VERSION_SHIP, 1, "counter", &dragon_strike_marker_upgraded_fx_fadeout, 0, 0 );
	clientfield::register( "actor", DRAGON_STRIKE_ZOMBIE_FIRE_CF, VERSION_SHIP, 2, "int", &dragon_strike_zombie_fire, 0, 0 );
	clientfield::register( "vehicle", DRAGON_STRIKE_ZOMBIE_FIRE_CF, VERSION_SHIP, 2, "int", &dragon_strike_zombie_fire, 0, 0 );
	clientfield::register( "clientuimodel", DRAGON_STRIKE_INVALID_USE_CF, VERSION_SHIP, 1, "counter", undefined, 0, 0 );
	clientfield::register( "clientuimodel", DRAGON_STRIKE_HUD_ICON_CF, VERSION_SHIP, 1, "int", undefined, 0, 0 );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER FX
	level._effect[ "dragon_strike_portal" ] = DRAGON_STRIKE_PORTAL_FX;
	level._effect[ "dragon_strike_beacon" ] = DRAGON_STRIKE_BEACON_FX;
	level._effect[ "dragon_strike_zombie_fire" ] = DRAGON_STRIKE_ZOMBIE_FIRE_FX;
	level._effect[ "dragon_strike_mouth" ] = DRAGON_STRIKE_MOUTH_FX;
	level._effect[ "dragon_strike_tongue" ] = DRAGON_STRIKE_TONGUE_FX;
	// # REGISTER FX
}

// ============================== INITIALIZE ==============================

// ============================== FUNCTIONALITY ==============================

function dragon_strike_spawn_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value )
	{
		playFXOnTag( n_local_client_num, level._effect[ "dragon_strike_portal" ], self, "tag_neck_fx" );
		playFXOnTag( n_local_client_num, level._effect[ "dragon_strike_mouth" ], self, "tag_throat_fx" );
		playFXOnTag( n_local_client_num, level._effect[ "dragon_strike_tongue" ], self, "tag_mouth_floor_fx" );
	}
}

function dragon_strike_marker_on( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value )
	{
		self dragonstrike_enable( 1 );
		self thread dragon_strike_marker_update( n_local_client_num );
	}
	else
	{
		self notify( "stop_dragon_strike_marker" );
		self dragonstrike_enable( 0 );
	}
}

function dragon_strike_marker_update( n_local_client_num )
{
	self endon( "stop_dragon_strike_marker" );
	self endon( "entityshutdown" );
	while ( isDefined( self ) )
	{
		self dragonstrike_setposition( self.origin );
		WAIT_CLIENT_FRAME;
	}
}

function dragon_strike_marker_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self dragonstrike_setcolorradiusspinpulse( .25, 3, .25, 128, .5, 0 );
}

function dragon_strike_marker_upgraded_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self dragonstrike_setcolorradiusspinpulse( .15, 3, .15, 128, 0.75, 0 );
}

function dragon_strike_marker_invalid_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self dragonstrike_setcolorradiusspinpulse( 4, .5, 0.25, 128, .5, 0 );
}

function dragon_strike_marker_upgraded_invalid_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self dragonstrike_setcolorradiusspinpulse( 4, .5, .25, 128, .75, 0 );
}

function dragon_strike_flare_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value )
		self.fx_flare = playFX( n_local_client_num, level._effect[ "dragon_strike_beacon" ], self.origin );
	else if ( isDefined( self.fx_flare ) )
	{
		deleteFx( n_local_client_num, self.fx_flare, 1 );
		self.fx_flare = undefined;
	}
}

function dragon_strike_marker_fx_fadeout( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self thread dragon_strike_marker_color( .25, 3, .25, .5 );
}

function dragon_strike_marker_upgraded_fx_fadeout( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self thread dragon_strike_marker_color( .15, 3, .15,  .75 );
}

function dragon_strike_marker_color( n_r, n_g, n_b, n_a )
{
	n_r_frac = n_r / 16;
	n_g_frac = n_g / 16;
	n_b_frac = n_b / 16;
	for ( i = 0; i < 16; i++ )
	{
		n_r = n_r - n_r_frac;
		n_g = n_g - n_g_frac;
		n_b = n_b - n_b_frac;
		self dragonstrike_setcolorradiusspinpulse( n_r, n_g, n_b, 128, n_a, 0 );
		WAIT_CLIENT_FRAME;
	}
}

function dragon_strike_zombie_fire( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value == 2 )
		self zombie_death::flame_death_fx( n_local_client_num );
	else
	{
		str_tag = "j_spinelower";
		v_tag = self getTagOrigin( str_tag );
		if ( !isDefined( v_tag ) )
			str_tag = "tag_origin";
		
		self.b_dragon_strike_on_fire = 1;
		if ( isDefined( self ) )
		{
			self.fx_dragon_strike_fire = playFXOnTag( n_local_client_num, level._effect[ "dragon_strike_zombie_fire" ], self, str_tag );
			self thread dragon_strike_zombie_fire_end( n_local_client_num );
		}
	}
}

function dragon_strike_zombie_fire_end( n_local_client_num )
{
	self endon( "entityshutdown" );
	wait 12;
	if ( isDefined( self ) && isAlive( self ) )
	{
		stopFx(n_local_client_num, self.fx_dragon_strike_fire);
		self.b_dragon_strike_on_fire = 0;
	}
}

// ============================== FUNCTIONALITY ==============================