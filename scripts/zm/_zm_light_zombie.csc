#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_elemental_zombies;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_light_zombie;

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_wrap_torso" );
#precache( "client_fx", "explosions/fx_exp_grenade_flshbng" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_wolf_impact_zmb" );

REGISTER_SYSTEM( "zm_light_zombie", &__init__, undefined )

function __init__()
{
	init_fx();
	register_clientfields();
}

function init_fx()
{
	level._effect[ "light_zombie_fx" ] = "dlc1/zmb_weapon/fx_bow_wolf_wrap_torso";
	level._effect[ "light_zombie_suicide" ] = "explosions/fx_exp_grenade_flshbng";
	level._effect[ "light_zombie_damage_fx" ] = "dlc1/zmb_weapon/fx_bow_wolf_impact_zmb";
}

function register_clientfields()
{
	clientfield::register( "actor", "light_zombie_clientfield_aura_fx", VERSION_SHIP, 1, "int", &light_zombie_clientfield_aura_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "light_zombie_clientfield_death_fx", VERSION_SHIP, 1, "int", &light_zombie_clientfield_death_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "light_zombie_clientfield_damaged_fx", VERSION_SHIP, 1, "counter", &light_zombie_clientfield_damaged_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function light_zombie_clientfield_death_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_old_value !== n_new_value && n_new_value === 1 )
		fx = playFXOnTag( n_local_client_num, level._effect[ "light_zombie_suicide" ], self, "j_spineupper" );
	
}

function light_zombie_clientfield_damaged_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( self ) )
		return;
	
	if ( n_new_value )
	{
		if ( isDefined( level._effect[ "light_zombie_damage_fx" ] ) )
		{
			playSound( n_local_client_num, "gdt_electro_bounce", self.origin );
			a_locs = array( "j_wrist_le", "j_wrist_ri" );
			fx = playFXOnTag( n_local_client_num, level._effect[ "light_zombie_damage_fx" ], self, array::random( a_locs ) );
			setFXIgnorePause( n_local_client_num, fx, 1 );
		}
	}
}

function light_zombie_clientfield_aura_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( n_new_value ) )
		return;
	
	if ( n_new_value == 1 )
	{
		fx = playFXOnTag( n_local_client_num, level._effect[ "light_zombie_fx" ], self, "j_spineupper" );
		setFXIgnorePause( n_local_client_num, fx, 1 );
	}
}

