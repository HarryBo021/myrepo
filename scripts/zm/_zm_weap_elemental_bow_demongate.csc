#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_elemental_bow;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using_animtree( "generic" );

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_ambient_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_impact_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_impact_ug_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demonhead_trail_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demonhead_bite_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demonhead_despawn_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_portal_open_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_portal_loop_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_demongate_portal_close_zmb" );

#namespace _zm_weap_elemental_bow_demongate;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_demongate", &__init__, undefined, undefined )

function __init__()
{
	clientfield::register( "toplayer", "elemental_bow_demongate" + "_ambient_bow_fx", VERSION_SHIP, 1, "int", &elemental_bow_demongate_ambient_bow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_demongate" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_demongate_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_demongate4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_demongate4_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "demongate_portal_fx", VERSION_SHIP, 1, "int", &demongate_portal_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "demongate_portal_rumble", VERSION_SHIP, 1, "int", &demongate_portal_rumble, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "demongate_wander_locomotion_anim", VERSION_SHIP, 1, "int", &demongate_wander_locomotion_anim, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "demongate_attack_locomotion_anim", VERSION_SHIP, 1, "int", &demongate_attack_locomotion_anim, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "demongate_chomper_fx", VERSION_SHIP, 1, "int", &demongate_chomper_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "demongate_chomper_bite_fx", VERSION_SHIP, 1, "counter", &demongate_chomper_bite_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ "demongate_ambient_bow" ] = "dlc1/zmb_weapon/fx_bow_demongate_ambient_1p_zmb";
	level._effect[ "demongate_arrow_impact" ] = "dlc1/zmb_weapon/fx_bow_demongate_impact_zmb";
	level._effect[ "demongate_arrow_charged_impact" ] = "dlc1/zmb_weapon/fx_bow_demongate_impact_ug_zmb";
	level._effect[ "demongate_chomper_trail" ] = "dlc1/zmb_weapon/fx_bow_demonhead_trail_zmb";
	level._effect[ "demongate_chomper_bite" ] = "dlc1/zmb_weapon/fx_bow_demonhead_bite_zmb";
	level._effect[ "demongate_chomper_end" ] = "dlc1/zmb_weapon/fx_bow_demonhead_despawn_zmb";
	level._effect[ "demongate_portal_open" ] = "dlc1/zmb_weapon/fx_bow_demongate_portal_open_zmb";
	level._effect[ "demongate_portal_loop" ] = "dlc1/zmb_weapon/fx_bow_demongate_portal_loop_zmb";
	level._effect[ "demongate_portal_close" ] = "dlc1/zmb_weapon/fx_bow_demongate_portal_close_zmb";
}

function elemental_bow_demongate_ambient_bow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self zm_weap_elemental_bow::elemental_bow_ambient_bow_fx_start( localclientnum, newval, "demongate_ambient_bow" );
}

function elemental_bow_demongate_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "demongate_arrow_impact" ], self.origin );
	
}

function elemental_bow_demongate4_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "demongate_arrow_charged_impact" ], self.origin );
	
}

function demongate_portal_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
	{
		playFx( localclientnum, level._effect[ "demongate_portal_open" ], self.origin, anglesToForward( self.angles ) );
		self.snd_zmb_demongate_portal_lp = self playLoopSound( "zmb_demongate_portal_lp", 1 );
		wait .45;
		self.fx_zmb_demongate_portal_lp = playFx( localclientnum, level._effect[ "demongate_portal_loop" ], self.origin, anglesToForward( self.angles ) );
	}
	else
	{
		deleteFx( localclientnum, self.fx_zmb_demongate_portal_lp, 0 );
		playFx( localclientnum, level._effect[ "demongate_portal_close" ], self.origin, anglesToForward( self.angles ) );
		if ( isDefined( self.snd_zmb_demongate_portal_lp ) )
			self stopLoopSound( self.snd_zmb_demongate_portal_lp, 1 );
		
	}
}

function demongate_portal_rumble( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self thread demongate_portal_rumble_think( localclientnum );
	else
		self notify( "demongate_portal_rumble_over" );
	
}

function demongate_portal_rumble_think( localclientnum )
{
	level endon( "demo_jump" );
	self endon( "demongate_portal_rumble_over" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self playRumbleOnEntity( localclientnum, "zod_idgun_vortex_interior" );
		wait .075;
	}
}

function demongate_wander_locomotion_anim( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( !self hasAnimTree() )
		self useAnimTree( #animtree );
	
	if ( newval )
		self setAnim( "ai_zm_dlc1_chomper_a_demongate_swarm_locomotion_f_notrans" );
	
}

function demongate_attack_locomotion_anim( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( !self hasAnimTree() )
		self useAnimTree( #animtree );
	
	if ( newval )
		self setAnim( "ai_zm_dlc1_chomper_a_demongate_swarm_locomotion_f_notrans" );
	
}

function demongate_chomper_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	if ( newval )
	{
		if ( isDefined( self.fx_demongate_chomper_trail ) )
			deleteFx( localclientnum, self.fx_demongate_chomper_trail, 1 );
		
		self.fx_demongate_chomper_trail = playFxOnTag( localclientnum, level._effect[ "demongate_chomper_trail" ], self, "tag_fx" );
		return;
	}
	else if ( isDefined( self.fx_demongate_chomper_trail ) )
	{
		deleteFx( localclientnum, self.fx_demongate_chomper_trail, 0 );
		self.fx_demongate_chomper_trail = undefined;
	}
	self playSound( 0, "zmb_demongate_chomper_disappear" );
	playFxOnTag( localclientnum, level._effect[ "demongate_chomper_end" ], self, "tag_fx" );
	wait .4;
	self hide();
}

function demongate_chomper_bite_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	if ( isDefined( self.fx_demongate_chomper_bite ) )
		stopFx( localclientnum, self.fx_demongate_chomper_bite );
	
	self playSound( 0, "zmb_demongate_chomper_bite" );
	self.fx_demongate_chomper_bite = playFx( localclientnum, level._effect[ "demongate_chomper_bite" ], self.origin );
	wait .1;
	if ( isDefined( self.fx_demongate_chomper_bite ) )
		stopFx( localclientnum, self.fx_demongate_chomper_bite );
	
}
