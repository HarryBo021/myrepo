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

#namespace zm_shadow_zombie;

#precache( "client_fx", "dlc4/genesis/fx_zombie_shadow_ambient_trail" );
#precache( "client_fx", "dlc4/genesis/fx_zombie_shadow_death" );
#precache( "client_fx", "dlc4/genesis/fx_zombie_shadow_damage" );
#precache( "client_fx", "dlc4/genesis/fx_zombie_shadow_trap_ambient" );

REGISTER_SYSTEM( "zm_shadow_zombie", &__init__, undefined )

function __init__()
{
	init_fx();
	register_clientfields();
}

function init_fx()
{
	level._effect[ "shadow_zombie_fx" ] = "dlc4/genesis/fx_zombie_shadow_ambient_trail";
	level._effect[ "shadow_zombie_suicide" ] = "dlc4/genesis/fx_zombie_shadow_death";
	level._effect[ "shadow_zombie_damage_fx" ] = "dlc4/genesis/fx_zombie_shadow_damage";
	if ( !isDefined( level._effect[ "mini_curse_circle" ] ) )
		level._effect[ "mini_curse_circle" ] = "dlc4/genesis/fx_zombie_shadow_trap_ambient";
	
}

function register_clientfields()
{
	clientfield::register( "actor", "shadow_zombie_clientfield_aura_fx", VERSION_SHIP, 1, "int", &shadow_zombie_clientfield_aura_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "shadow_zombie_clientfield_death_fx", VERSION_SHIP, 1, "int", &shadow_zombie_clientfield_death_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "shadow_zombie_clientfield_damaged_fx", VERSION_SHIP, 1, "counter", &shadow_zombie_clientfield_damaged_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "shadow_zombie_cursetrap_fx", VERSION_SHIP, 1, "int", &shadow_zombie_cursetrap_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function shadow_zombie_clientfield_death_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_old_value !== n_new_value && n_new_value === 1 )
		fx = playFXOnTag( n_local_client_num, level._effect[ "shadow_zombie_suicide" ], self, "j_spineupper" );
	
}

function shadow_zombie_clientfield_damaged_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( self ) )
		return;
	
	if ( n_new_value )
	{
		if ( isDefined( level._effect[ "shadow_zombie_damage_fx" ] ) )
		{
			playSound( n_local_client_num, "gdt_electro_bounce", self.origin );
			a_locs = array( "j_wrist_le", "j_wrist_ri" );
			fx = playFXOnTag( n_local_client_num, level._effect[ "shadow_zombie_damage_fx" ], self, array::random( a_locs ) );
			SetFXIgnorePause(n_local_client_num, FX, 1);
		}
	}
}

function shadow_zombie_clientfield_aura_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( n_new_value ) )
		return;
	
	if ( n_new_value == 1 )
	{
		fx = playFXOnTag( n_local_client_num, level._effect[ "shadow_zombie_fx" ], self, "j_spineupper" );
		fx2 = playFXOnTag( n_local_client_num, level._effect[ "shadow_zombie_fx" ], self, "j_head" );
		setFXIgnorePause( n_local_client_num, fx, 1 );
	}
}

function shadow_zombie_cursetrap_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( isDefined( self.snd_curse_sound ) )
	{
		self stopLoopSound( self.snd_curse_sound, .5 );
		self.snd_curse_sound = undefined;
		self playSound( 0, "zmb_zod_cursed_landmine_end" );
	}
	if ( n_new_value )
	{
		self.snd_curse_sound = self playLoopSound( "zmb_zod_cursed_landmine_lp", 1 );
		self playSound( 0, "zmb_zod_cursed_landmine_start" );
	}
	self shadow_zombie_cursetrap_effects( n_local_client_num, level._effect[ "mini_curse_circle" ], n_new_value, 1 );
}

function shadow_zombie_cursetrap_effects( n_local_client_num, fx_id = undefined, b_on = 1, n_new_value = 0, str_tag = "tag_origin" )
{
	if ( b_on )
	{
		if ( isDefined( self.fx_curse_trap ) )
			stopFx( n_local_client_num, self.fx_curse_trap );
		
		if ( n_new_value )
			self.fx_curse_trap = playFXOnTag( n_local_client_num, fx_id, self, str_tag );
		else if ( self.angles === ( 0, 0, 0 ) )
			self.fx_curse_trap = playFX( n_local_client_num, fx_id, self.origin );
		else
			self.fx_curse_trap = playFX( n_local_client_num, fx_id, self.origin, self.angles );
		
	}
	else if ( isDefined( self.fx_curse_trap ) )
	{
		stopFx( n_local_client_num, self.fx_curse_trap );
		self.fx_curse_trap = undefined;
	}
}

