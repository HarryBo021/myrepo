#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_elemental_bow;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_ambient_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_impact_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_impact_ug_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_funnel_loop_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_funnel_end_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_orb_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_storm_bolt_zap_zmb" );
#precache( "client_fx", "zombie/fx_tesla_shock_eyes_zmb" );
#precache( "client_fx", "zombie/fx_tesla_shock_zmb" );
#precache( "client_fx", "zombie/fx_bmode_shock_os_zod_zmb" );

#namespace _zm_weap_elemental_bow_storm;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_storm", &__init__, undefined, undefined )

function __init__()
{
	clientfield::register( "toplayer", "elemental_bow_storm" + "_ambient_bow_fx", VERSION_SHIP, 1, "int", &elemental_bow_storm_ambient_bow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_storm" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_storm_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_storm4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_storm4_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "elem_storm_fx", VERSION_SHIP, 1, "int", &elem_storm_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "elem_storm_whirlwind_rumble", VERSION_SHIP, 1, "int", &elem_storm_whirlwind_rumble, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "elem_storm_bolt_fx", VERSION_SHIP, 1, "int", &elem_storm_bolt_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "elem_storm_zap_ambient", VERSION_SHIP, 1, "int", &elem_storm_zap_ambient, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "elem_storm_shock_fx", VERSION_SHIP, 2, "int", &elem_storm_shock_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ "elem_storm_ambient_bow" ] = "dlc1/zmb_weapon/fx_bow_storm_ambient_1p_zmb";
	level._effect[ "elem_storm_arrow_impact" ] = "dlc1/zmb_weapon/fx_bow_storm_impact_zmb";
	level._effect[ "elem_storm_arrow_charged_impact" ] = "dlc1/zmb_weapon/fx_bow_storm_impact_ug_zmb";
	level._effect[ "elem_storm_whirlwind_loop" ] = "dlc1/zmb_weapon/fx_bow_storm_funnel_loop_zmb";
	level._effect[ "elem_storm_whirlwind_end" ] = "dlc1/zmb_weapon/fx_bow_storm_funnel_end_zmb";
	level._effect[ "elem_storm_zap_ambient" ] = "dlc1/zmb_weapon/fx_bow_storm_orb_zmb";
	level._effect[ "elem_storm_zap_bolt" ] = "dlc1/zmb_weapon/fx_bow_storm_bolt_zap_zmb";
	level._effect[ "elem_storm_shock_eyes" ] = "zombie/fx_tesla_shock_eyes_zmb";
	level._effect[ "elem_storm_shock" ] = "zombie/fx_tesla_shock_zmb";
	level._effect[ "elem_storm_shock_nonfatal" ] = "zombie/fx_bmode_shock_os_zod_zmb";
}

function elemental_bow_storm_ambient_bow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self zm_weap_elemental_bow::elemental_bow_ambient_bow_fx_start( localclientnum, newval, "elem_storm_ambient_bow" );
}

function elemental_bow_storm_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "elem_storm_arrow_impact" ], self.origin );
	
}

function elemental_bow_storm4_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "elem_storm_arrow_charged_impact" ], self.origin );
	
}

function elem_storm_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	if ( newval )
		self.fx_elem_storm_whirlwind_loop = playFxOnTag( localclientnum, level._effect[ "elem_storm_whirlwind_loop" ], self, "tag_origin" );
	else if ( isDefined( self.fx_elem_storm_whirlwind_loop ) )
	{
		deleteFx( localclientnum, self.fx_elem_storm_whirlwind_loop, 0 );
		self.fx_elem_storm_whirlwind_loop = undefined;
	}
	wait .4;
	playFx( localclientnum, level._effect[ "elem_storm_whirlwind_end" ], self.origin );
}

function elem_storm_whirlwind_rumble( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self thread storm_rumble_think( localclientnum );
	else
		self notify( "stom_rumble_over" );
	
}

function storm_rumble_think( localclientnum )
{
	level endon( "demo_jump" );
	self endon( "stom_rumble_over" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self playRumbleOnEntity( localclientnum, "zod_idgun_vortex_interior" );
		wait .075;
	}
}

function elem_storm_bolt_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
	{
		if ( isDefined( self.fx_elem_storm_zap_bolt ) )
		{
			deleteFx( localclientnum, self.fx_elem_storm_zap_bolt, 0 );
			self.fx_elem_storm_zap_bolt = undefined;
		}
		v_forward = anglesToForward( self.angles );
		v_up = anglesToUp( self.angles );
		self.fx_elem_storm_zap_bolt = playFxOnTag( localclientnum, level._effect[ "elem_storm_zap_bolt" ], self, "tag_origin" );
	}
}

function elem_storm_zap_ambient( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self.fx_elem_storm_zap_ambient = playFxOnTag( localclientnum, level._effect[ "elem_storm_zap_ambient" ], self, "tag_origin" );
	else
	{
		deleteFx( localclientnum, self.fx_elem_storm_zap_ambient, 0 );
		self.fx_elem_storm_zap_ambient = undefined;
	}
}

function elem_storm_shock_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	tag = ( self isAi() ? "j_spineupper" : "tag_origin" );
	switch( newval )
	{
		case 0:
		{
			if ( isDefined( self.fx_elem_storm_shock_eyes ) )
				deleteFx( localclientnum, self.fx_elem_storm_shock_eyes, 1 );
			if ( isDefined( self.fx_elem_storm_shock ) )
				deleteFx( localclientnum, self.fx_elem_storm_shock, 1 );
			if ( isDefined( self.fx_elem_storm_shock_nonfatal ) )
				deleteFx( localclientnum, self.fx_elem_storm_shock_nonfatal, 1 );
			
			self.fx_elem_storm_shock_eyes = undefined;
			self.fx_elem_storm_shock = undefined;
			self.var_bb955880 = undefined;
			break;
		}
		case 1:
		{
			if ( !isDefined( self.fx_elem_storm_shock ) )
				self.fx_elem_storm_shock = playFxOnTag( localclientnum, level._effect[ "elem_storm_shock" ], self, tag );
			
			break;
		}
		case 2:
		{
			if ( !isDefined( self.fx_elem_storm_shock_eyes ) )
				self.var_111812ed = playFxOnTag( localclientnum, level._effect[ "elem_storm_shock_eyes" ], self, "J_Eyeball_LE" );
			if ( !isDefined( self.fx_elem_storm_shock ) )
				self.fx_elem_storm_shock = playFxOnTag( localclientnum, level._effect[ "elem_storm_shock" ], self, tag );
			if ( !isDefined( self.fx_elem_storm_shock_nonfatal ) )
				self.fx_elem_storm_shock_nonfatal = playFxOnTag( localclientnum, level._effect[ "elem_storm_shock_nonfatal" ], self, tag );
			
			break;
		}
	}
}
