#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_elemental_bow;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_ambient_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_impact_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_impact_ug_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_wrap_torso"  );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_arrow_spiral_ug_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_arrow_trail_ug_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_arrow_trail_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_muz_flash_ug_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_torso_trail" );
#precache( "client_fx", "dlc1/castle/fx_tesla_trap_body_exp" );

#namespace _zm_weap_elemental_bow_wolf_howl;

REGISTER_SYSTEM_EX(  "_zm_weap_elemental_bow_wolf_howl", &__init__, undefined, undefined  )

function __init__(  )
{
	clientfield::register( "toplayer", "elemental_bow_wolf_howl" + "_ambient_bow_fx", VERSION_SHIP, 1, "int", &elemental_bow_wolf_howl_ambient_bow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_wolf_howl" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_wolf_howl_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "elemental_bow_wolf_howl4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_wolf_howl4_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "wolf_howl_muzzle_flash", VERSION_SHIP, 1, "int", &wolf_howl_muzzle_flash, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "wolf_howl_arrow_charged_trail", VERSION_SHIP, 1, "int", &wolf_howl_arrow_charged_trail, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "wolf_howl_arrow_charged_spiral", VERSION_SHIP, 1, "int", &wolf_howl_arrow_charged_spiral, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "wolf_howl_slow_snow_fx", VERSION_SHIP, 1, "int", &wolf_howl_slow_snow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "zombie_hit_by_wolf_howl_charge", VERSION_SHIP, 1, "int", &zombie_hit_by_wolf_howl_charge, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "zombie_explode_fx", VERSION_SHIP, 1, "counter", &wolf_howl_zombie_explode_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "zombie_explode_fx", -VERSION_SHIP, 1, "counter", &wolf_howl_zombie_explode_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "wolf_howl_zombie_explode_fx", VERSION_SHIP, 1, "counter", &wolf_howl_zombie_explode_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ "wolf_howl_ambient_bow" ] = "dlc1/zmb_weapon/fx_bow_wolf_ambient_1p_zmb";
	level._effect[ "wolf_howl_arrow_impact" ] = "dlc1/zmb_weapon/fx_bow_wolf_impact_zmb";
	level._effect[ "wolf_howl_arrow_charged_impact" ] = "dlc1/zmb_weapon/fx_bow_wolf_impact_ug_zmb";
	level._effect[ "wolf_howl_slow_torso" ] = "dlc1/zmb_weapon/fx_bow_wolf_wrap_torso";
	level._effect[ "wolf_howl_charge_spiral" ] = "dlc1/zmb_weapon/fx_bow_wolf_arrow_spiral_ug_zmb";
	level._effect[ "wolf_howl_charge_trail" ] = "dlc1/zmb_weapon/fx_bow_wolf_arrow_trail_ug_zmb";
	level._effect[ "wolf_howl_arrow_trail" ] = "dlc1/zmb_weapon/fx_bow_wolf_arrow_trail_zmb";
	level._effect[ "wolf_howl_muzzle_flash" ] = "dlc1/zmb_weapon/fx_bow_wolf_muz_flash_ug_1p_zmb";
	level._effect[ "zombie_trail_wolf_howl_hit" ] = "dlc1/zmb_weapon/fx_bow_wolf_torso_trail";
	level._effect[ "zombie_wolf_howl_hit_explode" ] = "dlc1/castle/fx_tesla_trap_body_exp";
	duplicate_render::set_dr_filter_framebuffer( "ghostly", 10, "ghostly_on", undefined, 0, "mc/mtl_c_zom_der_zombie_body1_ghost", 0 );
}

function elemental_bow_wolf_howl_ambient_bow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self zm_weap_elemental_bow::elemental_bow_ambient_bow_fx_start( localclientnum, newval, "wolf_howl_ambient_bow" );
}

function elemental_bow_wolf_howl_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "wolf_howl_arrow_impact" ], self.origin );
	
}

function elemental_bow_wolf_howl4_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "wolf_howl_arrow_charged_impact" ], self.origin );
	
}

function wolf_howl_muzzle_flash( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playViewModelFx( localclientnum, level._effect[ "wolf_howl_muzzle_flash" ], "tag_flash" );
	
}

function wolf_howl_arrow_charged_trail( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self.fx_wolf_howl_charge_trail = playFxOnTag( localclientnum, level._effect[ "wolf_howl_charge_trail" ], self, "tag_origin" );
	else
		deleteFx( localclientnum, self.fx_wolf_howl_charge_trail, 0 );
	
}

function wolf_howl_arrow_charged_spiral( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self.fx_wolf_howl_charge_spiral = playFxOnTag( localclientnum, level._effect[ "wolf_howl_charge_spiral" ], self, "tag_origin" );
	else
		deleteFx( localclientnum, self.fx_wolf_howl_charge_spiral, 0 );
	
}

function wolf_howl_slow_snow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
	{
		if ( !isDefined( self.fx_wolf_howl_slow_torso ) )
			self.fx_wolf_howl_slow_torso = playFxOnTag( localclientnum, level._effect[ "wolf_howl_slow_torso" ], self, "j_spineupper" );
		
	}
	else if ( isDefined( self.fx_wolf_howl_slow_torso ) )
	{
		deleteFx( localclientnum, self.fx_wolf_howl_slow_torso, 0 );
		self.fx_wolf_howl_slow_torso = undefined;
	}
}

function zombie_hit_by_wolf_howl_charge( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	if ( newval )
	{
		playFxOnTag( localclientnum, level._effect[ "zombie_trail_wolf_howl_hit" ], self, "j_spine4" );
		self duplicate_render::set_dr_flag( "ghostly_on", newval );
		self duplicate_render::update_dr_filters( localclientnum );
	}
}

function wolf_howl_zombie_explode_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	self util::waittill_dobj( localclientnum );
	playFxOnTag( localclientnum, level._effect[ "zombie_wolf_howl_hit_explode" ], self, "j_spine4" );
}
