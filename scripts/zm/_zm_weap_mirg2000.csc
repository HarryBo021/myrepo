#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_mirg2000.gsh;

#namespace mirg2000;

#precache( "client_fx", MIRG2000_CHARGED_SHOT_1_FX );
#precache( "client_fx", MIRG2000_CHARGED_SHOT_2_FX );
#precache( "client_fx", MIRG2000_CHARGED_SHOT_1_UP_FX );
#precache( "client_fx", MIRG2000_CHARGED_SHOT_2_UP_FX );
#precache( "client_fx", MIRG2000_ENEMY_IMPACT_FX );
#precache( "client_fx", MIRG2000_ENEMY_IMPACT_UP_FX );
#precache( "client_fx", MIRG2000_GLOW_FX );
#precache( "client_fx", MIRG2000_GLOW_UP_FX );
#precache( "client_fx", MIRG2000_SPIDER_DEATH_FX_FX );
#precache( "client_fx", MIRG2000_SPIDER_DEATH_FX_UP_FX );

REGISTER_SYSTEM_EX( "mirg2000", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", 						MIRG2000_PLANT_KILLER_CF, 						VERSION_SHIP, getMinBitCountForNum( 4 ),	"int", &mirg2000_plant_killer_cb, 				!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", 							MIRG2000_SPIDER_DEATH_FX_CF, 				VERSION_SHIP, 2, 										"int", &mirg2000_spider_death_fx, 				!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", 								MIRG2000_ENEMY_IMPACT_FX_CF, 				VERSION_SHIP, 2, 										"int", &mirg2000_enemy_impact_fx, 			!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", 							MIRG2000_ENEMY_IMPACT_FX_CF, 				VERSION_SHIP, 2, 										"int", &mirg2000_enemy_impact_fx, 			!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers", 						MIRG2000_FIRE_BUTTON_HELD_SOUND_CF, 	VERSION_SHIP, 1, 										"int", &mirg2000_fire_button_held_sound, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", 							MIRG2000_CHARGE_GLOW_CF, 						VERSION_SHIP, 2, 										"int", &mirg2000_charge_glow, 					!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER FX
	level._effect[ "mirg2000_charged_shot_1" ] 		= MIRG2000_CHARGED_SHOT_1_FX;
	level._effect[ "mirg2000_charged_shot_2" ] 		= MIRG2000_CHARGED_SHOT_2_FX;
	level._effect[ "mirg2000_charged_shot_1_up" ] 	= MIRG2000_CHARGED_SHOT_1_UP_FX;
	level._effect[ "mirg2000_charged_shot_2_up" ] 	= MIRG2000_CHARGED_SHOT_2_UP_FX;
	level._effect[ "mirg2000_spider_death_fx" ] 		= MIRG2000_SPIDER_DEATH_FX_FX;
	level._effect[ "mirg2000_spider_death_fx_up" ] 	= MIRG2000_SPIDER_DEATH_FX_UP_FX;
	level._effect[ "mirg2000_enemy_impact" ] 			= MIRG2000_ENEMY_IMPACT_FX;
	level._effect[ "mirg2000_enemy_impact_up" ] 		= MIRG2000_ENEMY_IMPACT_UP_FX;
	level._effect[ "mirg2000_glow" ] 							= MIRG2000_GLOW_FX;
	level._effect[ "mirg2000_glow_up" ] 					= MIRG2000_GLOW_UP_FX;
	// # REGISTER FX
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function mirg2000_plant_killer_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	switch ( n_new_value )
	{
		case 0:
		{
			if ( isDefined( self.fx_mirg2000_aoe ) )
			{
				stopFx( n_local_client_num, self.fx_mirg2000_aoe );
				self.fx_mirg2000_aoe = undefined;
			}
			break;
		}
		case 1:
		{
			self.fx_mirg2000_aoe = playFXOnTag( n_local_client_num, level._effect[ "mirg2000_charged_shot_1" ], self, "tag_origin" );
			break;
		}
		case 2:
		{
			self.fx_mirg2000_aoe = playFXOnTag( n_local_client_num, level._effect[ "mirg2000_charged_shot_2" ], self, "tag_origin" );
			break;
		}
		case 3:
		{
			self.fx_mirg2000_aoe = playFXOnTag( n_local_client_num, level._effect[ "mirg2000_charged_shot_1_up" ], self, "tag_origin" );
			break;
		}
		case 4:
		{
			self.fx_mirg2000_aoe = playFXOnTag( n_local_client_num, level._effect[ "mirg2000_charged_shot_2_up" ], self, "tag_origin" );
			break;
		}
		default:
		{
			if ( isDefined( self.fx_mirg2000_aoe ) )
			{
				stopfx(n_local_client_num, self.fx_mirg2000_aoe);
				self.fx_mirg2000_aoe = undefined;
			}
			break;
		}
	}
}

function mirg2000_enemy_impact_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value == 2 )
		playFXOnTag( n_local_client_num, level._effect[ "mirg2000_enemy_impact_up" ], self, "j_spineupper" );
	else if ( n_new_value == 1 )
		playFXOnTag( n_local_client_num, level._effect[ "mirg2000_enemy_impact" ], self, "j_spineupper" );
	
}

function mirg2000_spider_death_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value == 2 )
		playFXOnTag( n_local_client_num, level._effect[ "mirg2000_spider_death_fx_up" ], self, "tag_origin" );
	else if ( n_new_value == 1 )
		playFXOnTag( n_local_client_num, level._effect[ "mirg2000_spider_death_fx" ], self, "tag_origin" );
	
}

function mirg2000_fire_button_held_sound( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_value == 1 )
	{
		if ( !isDefined( self.fx_mirg2000_loop_sound ) )
			self.fx_mirg2000_loop_sound = self playLoopSound( "wpn_mirg2k_hold_lp", 1.25 );
		
	}
	else if ( n_new_value == 0 )
	{
		if ( isDefined( self.fx_mirg2000_loop_sound ) )
		{
			self StopLoopSound( self.fx_mirg2000_loop_sound, .1 );
			self.fx_mirg2000_loop_sound = undefined;
		}
	}
}

function mirg2000_charge_glow( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	w_current = getCurrentWeapon( n_local_client_num );
	str_weapon_name = w_current.name;
	self mapShaderConstant( n_local_client_num, 0, "scriptVector2", 0, 1, n_new_value, 0 );
	if ( n_new_value != 3 && ( str_weapon_name == MIRG2000_UPGRADED_WEAPON || str_weapon_name == MIRG2000_WEAPON ) )
	{
		if ( str_weapon_name == MIRG2000_UPGRADED_WEAPON )
		{
			if ( !isDefined( self.fx_mirg2000_glow ) )
				self.fx_mirg2000_glow = playViewmodelFX(n_local_client_num, level._effect[ "mirg2000_glow_up" ], "tag_liquid" );
			
		}
		else if ( !isDefined( self.fx_mirg2000_glow ) )
			self.fx_mirg2000_glow = playViewmodelFX( n_local_client_num, level._effect[ "mirg2000_glow" ], "tag_liquid" );
		
	}
	else if ( isdefined( self.fx_mirg2000_glow ) )
	{
		stopFx( n_local_client_num, self.fx_mirg2000_glow );
		self.fx_mirg2000_glow = undefined;
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================