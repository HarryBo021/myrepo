#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_zm_trap_centrifuge.gsh;

#namespace hb21_zm_trap_centrifuge;

#precache( "client_fx", CENTRIFUGE_TRAP_LIGHT_FX );
#precache( "client_fx", CENTRIFUGE_TRAP_STEAM_FX );

REGISTER_SYSTEM( "hb21_zm_trap_centrifuge", &__init__, undefined )
	
function __init__()
{	
	DEFAULT( level._effect, [] );
	level._effect[ CENTRIFUGE_TRAP_LIGHT_FX ] = CENTRIFUGE_TRAP_LIGHT_FX;
	level._effect[ CENTRIFUGE_TRAP_STEAM_FX ] = CENTRIFUGE_TRAP_STEAM_FX;
	
	clientfield::register( "scriptmover", CENTRIFUGE_TRAP_CLIENTFIELD, 		VERSION_SHIP, 	1, "int", &centrifuge_trap_lights, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function centrifuge_trap_lights( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
	{
		if ( !isDefined( self.fx_centrifuge_lights ) )
		{
			self.fx_centrifuge_lights = [];
			self.fx_centrifuge_lights[ 0 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_LIGHT_FX ], self, "tag_light_fnt_top" );
			self.fx_centrifuge_lights[ 1 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_LIGHT_FX ], self, "tag_light_fnt_bttm" );
			self.fx_centrifuge_lights[ 2 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_LIGHT_FX ], self, "tag_light_bk_top" );
			self.fx_centrifuge_lights[ 3 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_LIGHT_FX ], self, "tag_light_bk_bttm" );
			self.fx_centrifuge_lights[ 3 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_STEAM_FX ], self, "tag_vent_top_btm" );
			self.fx_centrifuge_lights[ 3 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_STEAM_FX ], self, "tag_vent_bk_btm" );
			self.fx_centrifuge_lights[ 3 ] = playFXOnTag( n_local_client_num, level._effect[ CENTRIFUGE_TRAP_STEAM_FX ], self, "tag_vent_bk_top" );
		}
	}
	else
	{
		if ( isDefined( self.fx_centrifuge_lights ) )
		{
			for ( i = 0; i < self.fx_centrifuge_lights.size; i++ )
				stopFx( n_local_client_num, self.fx_centrifuge_lights[ i ] );
			
			self.fx_centrifuge_lights = undefined;
		}
	}
}