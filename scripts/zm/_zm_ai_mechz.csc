#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_elemental_zombies;
#using scripts\shared\ai\mechz;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\mechz.gsh;

#namespace zm_ai_mechz;

#precache( "client_fx", "dlc5/tomb/fx_tomb_mech_wpn_claw" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_mech_wpn_source" );
#precache( "client_fx", "explosions/fx_exp_dest_barrel_concussion_sm_optim" );
#precache( "client_fx", "fire/fx_embers_burst_optim" );

REGISTER_SYSTEM_EX( "zm_ai_mechz", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", 			"mechz_claw", 												VERSION_SHIP, 	1, 	"int", 	&mechz_claw_cb, 				!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "actor", 					"mechz_wpn_source", 									VERSION_SHIP, 	1, 	"int", 	&mechz_wpn_source_cb, 	!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "toplayer", 				"mechz_grab", 												VERSION_SHIP, 	1, 	"int", 	&mechz_grab_cb, 				!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "actor", 					"tomb_mech_eye", 											VERSION_SHIP, 	1, 	"int", 	&tomb_mech_eye_cb, 		!CF_HOST_ONLY, 	!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER FX
	level._effect[ "mechz_claw" ] 					= "dlc5/tomb/fx_tomb_mech_wpn_claw";
	level._effect[ "mechz_wpn_source" ] 		= "dlc5/tomb/fx_tomb_mech_wpn_source";
	// # REGISTER FX
	
	// # REGISTER AI CALLBACKS
	level.mechz_detach_claw_override 			= &mechz_detach_claw_override;
	level.mechz_detach_faceplate_override 	= &mechz_detach_faceplate_override;
	// # REGISTER AI CALLBACKS
}

function __main__()
{
	visionset_mgr::register_overlay_info_style_burn( "mechz_player_burn", 5000, 15, 1.5 );
}

// ============================== INITIALIZE ==============================

// ============================== EVENT OVERRIDES ==============================

function private mechz_detach_claw_override( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	createDynEntAndLaunch( n_local_client_num, ( n_new_value == 2 ? "c_t7_zm_dlchd_origins_mech_claw" : MECHZ_MODEL_CLAW ), self getTagOrigin( "tag_claw" ), self getTagAngles( "tag_claw" ), self.origin, self getVelocity() );
	playFXOnTag( n_local_client_num, level._effect[ "fx_mech_dmg_armor" ], self, "tag_grappling_source_fx" );
	self playSound( 0, "zmb_ai_mechz_destruction" );
	playFXOnTag( n_local_client_num, level._effect[ "fx_mech_dmg_sparks" ], self, "tag_grappling_source_fx" );
}

function mechz_detach_faceplate_override( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	createDynEntAndLaunch( n_local_client_num, ( n_new_value == 2 ? "c_t7_zm_dlchd_origins_mech_faceplate" : MECHZ_MODEL_FACEPLATE ), self getTagOrigin( MECHZ_TAG_FACEPLATE ), self getTagAngles( MECHZ_TAG_FACEPLATE ), self.origin, self getVelocity() );
	playFXonTag( n_local_client_num, level._effect[ MECHZ_FACEPLATE_OFF_FX ], self, MECHZ_TAG_FACEPLATE );
	self setSoundEntContext( "movement", "loud" );
	self playSound( 0, "zmb_ai_mechz_faceplate" );		
}

// ============================== EVENT OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function tomb_mech_eye_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	waitTillFrameEnd;
	self mapShaderConstant( n_local_client_num, 0, "scriptVector2", 0, n_new_value, 3, 0 );
}

function private mechz_claw_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value )
		playFXOnTag( n_local_client_num, level._effect[ "mechz_claw" ], self, "tag_origin" );
	
}

function private mechz_wpn_source_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value )
		self.fx_mechz_claw = playFXOnTag( n_local_client_num, level._effect[ "mechz_wpn_source" ], self, "j_elbow_le" );
	else if ( isDefined( self.fx_mechz_claw ) )
	{
		stopFx( n_local_client_num, self.fx_mechz_claw );
		self.fx_mechz_claw = undefined;
	}
}

function private mechz_grab_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value )
		self hideViewLegs();
	else
		self showviewLegs();
	
}

// ============================== FUNCTIONALITY ==============================