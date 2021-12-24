#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_elemental_zombie;

#precache( "client_fx", "electric/fx_ability_elec_surge_short_robot_optim" );
#precache( "client_fx", "explosions/fx_ability_exp_ravage_core_optim" );
#precache( "client_fx", "fire/fx_embers_burst_optim" );
#precache( "client_fx", "explosions/fx_exp_dest_barrel_concussion_sm_optim" );
#precache( "client_fx", "light/fx_light_spark_chest_zombie_optim" );
#precache( "client_fx", "electric/fx_elec_sparks_burst_blue_optim" );

REGISTER_SYSTEM( "zm_elemental_zombie", &__init__, undefined )

function __init__()
{
	init_fx();
	register_clientfields();
}

function init_fx()
{
	level._effect[ "elemental_zombie_sparky" ] = "electric/fx_ability_elec_surge_short_robot_optim";
	level._effect[ "elemental_sparky_zombie_suicide" ] = "explosions/fx_ability_exp_ravage_core_optim";
	level._effect[ "elemental_zombie_fire_damage" ] = "fire/fx_embers_burst_optim";
	level._effect[ "elemental_napalm_zombie_suicide" ] = "explosions/fx_exp_dest_barrel_concussion_sm_optim";
	level._effect[ "elemental_zombie_spark_light" ] = "light/fx_light_spark_chest_zombie_optim";
	level._effect[ "elemental_electric_spark" ] = "electric/fx_elec_sparks_burst_blue_optim";
}

function register_clientfields()
{
	clientfield::register( "actor", "sparky_zombie_spark_fx", VERSION_SHIP, 1, "int", &sparky_zombie_spark_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "sparky_zombie_death_fx", VERSION_SHIP, 1, "int", &sparky_zombie_death_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "napalm_zombie_death_fx", VERSION_SHIP, 1, "int", &napalm_zombie_death_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "sparky_damaged_fx", VERSION_SHIP, 1, "counter", &sparky_damaged_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "napalm_damaged_fx", VERSION_SHIP, 1, "counter", &napalm_damaged_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "napalm_sfx", VERSION_SHIP, 1, "int", &napalm_sfx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function napalm_zombie_death_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( self ) )
		return;
	
	if ( n_old_value !== n_new_value && n_new_value === 1 )
	{
		fx = playFXOnTag( n_local_client_num, level._effect[ "elemental_napalm_zombie_suicide" ], self, "j_spineupper" );
		self playSound( 0, "zmb_elemental_zombie_explode_fire" );
	}
}

function napalm_damaged_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( self ) )
		return;
	
	if ( n_new_value )
	{
		if ( isDefined( level._effect[ "elemental_zombie_fire_damage" ] ) )
		{
			playSound( n_local_client_num, "gdt_electro_bounce", self.origin );
			a_locs = array( "j_wrist_le", "j_wrist_ri" );
			fx = playFXOnTag( n_local_client_num, level._effect[ "elemental_zombie_fire_damage" ], self, array::random( a_locs ) );
			setFXIgnorePause( n_local_client_num, fx, 1 );
		}
	}
}

function napalm_sfx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value == 1 )
	{
		if ( !isDefined( self.snd_napalm_sound ) )
			self.snd_napalm_sound = self playLoopSound( "zmb_elemental_zombie_loop_fire", .2 );
		
	}
	else
	{
		if ( isDefined( self.snd_napalm_sound ) )
		{
			self stopLoopSound( self.snd_napalm_sound, .5 );
			self.snd_napalm_sound = undefined;
		}
	}
}

function sparky_zombie_spark_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( n_new_value ) )
		return;
	
	if ( n_new_value == 1 )
	{
		if ( !isdefined( self.snd_sparky_sound ) )
			self.snd_sparky_sound = self playLoopSound( "zmb_electrozomb_lp", .2 );
		
		str_tag = "j_spineupper";
		if ( isDefined( self.str_sparky_tag ) )
			str_tag = self.str_sparky_tag;
		
		str_fx = level._effect[ "elemental_zombie_sparky" ];
		if ( isDefined( self.str_sparky_fx ) )
			str_fx = self.str_sparky_fx;
		
		fx = playFXOnTag( n_local_client_num, str_fx, self, str_tag );
		setFXIgnorePause( n_local_client_num, fx, 1 );
		var_4473cd0 = level._effect[ "elemental_zombie_spark_light" ];
		if ( isDefined( self.str_sparky_light_fx ) )
			var_4473cd0 = self.str_sparky_light_fx;
		
		fx = playFXOnTag( n_local_client_num, var_4473cd0, self, str_tag );
		setFXIgnorePause( n_local_client_num, fx, 1 );
	}
}

function sparky_zombie_death_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_old_value !== n_new_value && n_new_value === 1 )
	{
		fx = playFXOnTag( n_local_client_num, level._effect[ "elemental_sparky_zombie_suicide" ], self, "j_spineupper" );
		self playSound( 0, "zmb_elemental_zombie_explode_elec" );
	}
}

function sparky_damaged_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( n_new_value ) )
		return;
	
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined(self ) )
		return;
	
	if ( n_new_value >= 1 )
	{
		if ( !isDefined( self.snd_sparky_sound ) )
			self.snd_sparky_sound = self playLoopSound( "zmb_electrozomb_lp", .2 );
		
		fx = playFXOnTag( n_local_client_num, level._effect[ "elemental_electric_spark" ], self, "j_spineupper" );
		setFXIgnorePause( n_local_client_num, fx, 1 );
	}
}

