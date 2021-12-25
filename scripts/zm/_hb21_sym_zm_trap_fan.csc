#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_fan.gsh;

#namespace hb21_sym_zm_trap_fan;

#precache( "client_fx", FAN_TRAP_FX );

REGISTER_SYSTEM( "hb21_sym_zm_trap_fan", &__init__, undefined )
	
function __init__()
{	
	DEFAULT( level._effect, [] );
	level._effect[ FAN_TRAP_FX ] = FAN_TRAP_FX;
	
	clientfield::register( "scriptmover", FAN_TRAP_CLIENTFIELD, VERSION_SHIP, 1, "int", &fan_trap_effect, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function fan_trap_effect( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entity_shutdown" );
	
	if ( IS_TRUE( n_new_val ) )
	{
		if ( !isDefined( self.a_fan_trap ) )
		{
			self.a_fan_trap = [];
			self.a_fan_trap[ 0 ] = playFxOnTag( n_local_client_num, level._effect[ FAN_TRAP_FX ], self, "tag_fan_right" );
			self.a_fan_trap[ 1 ] = playFxOnTag( n_local_client_num, level._effect[ FAN_TRAP_FX ], self, "tag_fan_left" );
		}
	}
	else
	{
		if ( isDefined( self.a_fan_trap ) )
		{
			stopFx( n_local_client_num, self.a_fan_trap[ 0 ] );
			stopFx( n_local_client_num, self.a_fan_trap[ 1 ] );
			self.a_fan_trap = undefined;
		}
	}
}