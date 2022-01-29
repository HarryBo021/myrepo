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

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_rune_ambient_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_rune_impact_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_rune_impact_ug_fire_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_rune_impact_aoe_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_rune_fire_torso_zmb" );

#namespace _zm_weap_elemental_bow_storm;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_rune_prison", &__init__, undefined, undefined )

function __init__()
{
	clientfield::register( "toplayer", "elemental_bow_rune_prison" + "_ambient_bow_fx", VERSION_SHIP, 1, "int", &elemental_bow_rune_prison_ambient_bow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_rune_prison" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_rune_prison_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow_rune_prison4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_rune_prison4_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "runeprison_rock_fx", VERSION_SHIP, 1, "int", &runeprison_rock_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "runeprison_explode_fx", VERSION_SHIP, 1, "int", &runeprison_explode_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "runeprison_lava_geyser_fx", VERSION_SHIP, 1, "int", &runeprison_lava_geyser_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "runeprison_lava_geyser_dot_fx", VERSION_SHIP, 1, "int", &runeprison_lava_geyser_dot_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "runeprison_zombie_charring", VERSION_SHIP, 1, "int", &runeprison_zombie_charring, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "runeprison_zombie_death_skull", VERSION_SHIP, 1, "int", &runeprison_zombie_death_skull, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ "rune_ambient_bow" ] = "dlc1/zmb_weapon/fx_bow_rune_ambient_1p_zmb";
	level._effect[ "rune_arrow_impact" ] = "dlc1/zmb_weapon/fx_bow_rune_impact_zmb";
	level._effect[ "rune_fire_pillar" ] = "dlc1/zmb_weapon/fx_bow_rune_impact_ug_fire_zmb";
	level._effect[ "rune_lava_geyser" ] = "dlc1/zmb_weapon/fx_bow_rune_impact_aoe_zmb";
	level._effect[ "rune_lava_geyser_dot" ] = "dlc1/zmb_weapon/fx_bow_rune_fire_torso_zmb";
}

function elemental_bow_rune_prison_ambient_bow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self zm_weap_elemental_bow::elemental_bow_ambient_bow_fx_start( localclientnum, newval, "rune_ambient_bow" );
}

function elemental_bow_rune_prison_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "rune_arrow_impact" ], self.origin );
	
}

function elemental_bow_rune_prison4_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "rune_arrow_impact" ], self.origin );
	
}

function runeprison_rock_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	switch( newval )
	{
		case 0:
		{
			self scene_play( "p7_fxanim_zm_bow_rune_prison_01_bundle" );
			if ( !isDefined( self ) )
				return;
			
			self thread scene_play( "p7_fxanim_zm_bow_rune_prison_01_dissolve_bundle", self.e_bow_rune_prison_scene );
			self.e_bow_rune_prison_scene thread function_79854312( localclientnum );
			break;
		}
		case 1:
		{
			self thread scene::init( "p7_fxanim_zm_bow_rune_prison_01_bundle" );
			self.e_bow_rune_prison_scene = util::spawn_model( localclientnum, "p7_fxanim_zm_bow_rune_prison_dissolve_mod", self.origin, self.angles );
			break;
		}
	}
}

function scene_play( scene, str_scene )
{
	self notify( "scene_play" );
	self endon( "scene_play" );
	self scene::stop();
	self _scene_play( scene, str_scene );
	if ( isDefined( self ) )
		self scene::stop();
	
}

function _scene_play( scene, str_scene )
{
	level endon( "demo_jump" );
	self scene::play( scene, str_scene );
}

function function_79854312( localclientnum )
{
	self endon( "entityshutdown" );
	n_start_time = getTime();
	n_end_time = n_start_time + 1633;
	b_is_updating = 1;
	while ( b_is_updating )
	{
		n_time = getTime();
		if ( n_time >= n_end_time )
		{
			n_shader_value = mapfloat( n_start_time, n_end_time, 1, 0, n_end_time );
			b_is_updating = 0;
		}
		else
			n_shader_value = mapfloat( n_start_time, n_end_time, 1, 0, n_time );
		
		self mapShaderConstant( localclientnum, 0, "scriptVector0", n_shader_value, 0, 0 );
		WAIT_CLIENT_FRAME;
	}
}

function runeprison_explode_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "rune_fire_pillar" ], self.origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
	
}

function runeprison_lava_geyser_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
	{
		playFx( localclientnum, level._effect[ "rune_lava_geyser" ], self.origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
		self playSound( 0, "wpn_rune_prison_lava_lump", self.origin );
	}
}

function runeprison_lava_geyser_dot_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		self.fx_rune_lava_geyser_dot = playFxontag( localclientnum, level._effect[ "rune_lava_geyser_dot" ], self, "j_spine4" );
	else
		deleteFx( localclientnum, self.fx_rune_lava_geyser_dot, 0 );
	
}

function runeprison_zombie_charring( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self endon( "entityshutdown" );
	if ( newval )
	{
		n_cur_time = getTime();
		n_start_time = n_cur_time;
		n_end_time = n_cur_time + 1200;
		while ( n_cur_time < n_end_time )
		{
			n_shader_value = ( n_cur_time - n_start_time ) / 1200;
			self mapShaderConstant( localclientnum, 0, "scriptVector0", n_shader_value, n_shader_value, 0 );
			WAIT_CLIENT_FRAME;
			n_cur_time = getTime();
		}
	}
}

function runeprison_zombie_death_skull( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
	{
		v_head_pos = self getTagOrigin( "j_head" );
		v_head_ang = self getTagAngles( "j_head" );
		createDynentAndLaunch( localclientnum, "rune_prison_death_skull", v_head_pos, v_head_ang, self.origin, ( randomFloatRange( -.15, .15 ), randomFloatRange( -.15, .15 ), .1 ) );
	}
}
