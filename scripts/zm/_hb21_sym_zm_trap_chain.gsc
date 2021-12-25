#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_chain.gsh;

#using_animtree( "generic" );

#namespace hb21_sym_zm_trap_chain;

REGISTER_SYSTEM_EX( "hb21_sym_zm_trap_chain", &__init__, &__main__, undefined )

function __init__()
{
	DEFAULT( level._zombiemode_trap_use_funcs, [] );
	
	zm_traps::register_trap_basic_info( CHAIN_TRAP_SCRIPT_NOTEWORTHY, &trap_activate_chain, undefined );
	level._zombiemode_trap_use_funcs[ CHAIN_TRAP_SCRIPT_NOTEWORTHY ] = &trap_activate_trigger_chain;
}

function __main__()
{
	a_traps = getEntArray( "zombie_trap", "targetname" );
	if ( !isDefined( a_traps ) || !isArray( a_traps ) || a_traps.size < 1 )
		return;
	
	for ( i = 0; i < a_traps.size; i++ )
	{
		if ( isDefined( a_traps[ i ].script_noteworthy ) && a_traps[ i ].script_noteworthy == "chain" )
		{
			a_targets = getEntArray( a_traps[ i ].target, "targetname" );
			for ( t = 0; t < a_targets.size; t++ )
			{
				if ( isDefined( a_targets[ t ].script_noteworthy ) && a_targets[ t ].script_noteworthy == "switch" )
				{
					a_targets[ t ] useAnimTree( #animtree );
					a_targets[ t ] animScripted( "p7_fxanim_zm_zod_chain_trap_heart_low_anim", a_targets[ t ].origin, a_targets[ t ].angles, "p7_fxanim_zm_zod_chain_trap_heart_low_anim" );
					a_targets[ t ] playLoopSound( "evt_chain_trap_heartbeat" );
				}
				else if ( isDefined( a_targets[ t ].script_noteworthy ) && a_targets[ t ].script_noteworthy == "mover" )
				{
					a_targets[ t ] useAnimTree( #animtree );
					a_targets[ t ] animScripted( "p7_fxanim_zm_zod_chain_trap_end_idle_anim", a_targets[ t ].origin, a_targets[ t ].angles, "p7_fxanim_zm_zod_chain_trap_end_idle_anim" );
					a_targets[ t ] playLoopSound( "evt_chaintrap_idle" );
				}
			}
		}
	}
}

function trap_activate_trigger_chain( e_trap )
{
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );

		if ( e_player zm_utility::in_revive_trigger() || IS_DRINKING( e_player.is_drinking ) )
			continue;

		if ( zm_utility::is_player_valid( e_player ) && !e_trap._trap_in_use )
		{
			if ( e_player zm_score::can_player_purchase( e_trap.zombie_cost ) )
				e_player zm_score::minus_to_player_score( e_trap.zombie_cost ); 
			else
			{
				playSoundAtPosition( "zmb_trap_deny", e_trap.origin );
				e_player zm_audio::create_and_play_dialog( "general", "outofmoney" );
				continue;
			}

			e_trap.activated_by_player = e_player;
			e_trap._trap_in_use = 1;
			e_trap zm_traps::trap_set_string( &"ZOMBIE_TRAP_ACTIVE" );

			zm_utility::play_sound_at_pos( "purchase", e_player.origin );
			
			if ( !IS_TRUE( level.b_trap_start_custom_vo ) )
				e_player zm_audio::create_and_play_dialog( "trap", "start" );

			if ( e_trap._trap_switches.size )
			{
				e_trap thread trap_move_switches_chain();
				e_trap waittill( "switch_activated" );
			}

			e_trap triggerEnable( 1 );

			e_trap thread [ [ e_trap._trap_activate_func ] ]();
			
			e_trap waittill( "trap_done" );

			e_trap triggerEnable( 0 );

			e_trap._trap_cooling_down = 1;
			
			e_trap zm_traps::trap_set_string( &"ZOMBIE_TRAP_COOLDOWN" );
			wait( e_trap._trap_cooldown_time );
			
			e_trap._trap_cooling_down = 0;

			playSoundAtPosition( "zmb_trap_ready", e_trap.origin );
			
			if ( isDefined( level.sndTrapFunc ) )
				level thread [ [ level.sndTrapFunc ] ]( e_trap, 0 );
			
			e_trap notify( "available" );

			e_trap._trap_in_use = 0;
			e_trap zm_traps::trap_set_string( &"ZOMBIE_BUTTON_BUY_TRAP", e_trap.zombie_cost );
		}
	}
}

function trap_move_switches_chain()
{
	self thread trap_activate_hearts_chain();
	
	wait getAnimLength( "p7_fxanim_zm_zod_chain_trap_heart_pull_anim" ) / 2;
	
	self notify( "switch_activated" );

	self waittill( "trap_done" );
	
	self thread trap_cooldown_hearts_chain();
	
	self waittill( "available" );
	
	self thread trap_deactivate_hearts_chain();
}

function trap_activate_chain()
{	
	self._trap_duration = CHAIN_TRAP_DURATION;
	self._trap_cooldown_time = CHAIN_TRAP_COOLDOWN;

	self notify( "trap_activate" );
	level notify( "trap_activate", self );
	
	playSoundAtPosition( "evt_chaintrap_start", self.origin );
	
	self thread trap_turn_on_chain();
	
	e_model_sound = util::spawn_model( "tag_origin", self.origin, self.angles );
	e_model_sound playLoopSound( "evt_chaintrap_loop", 1 );  

	self thread trap_damage_chain();
	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration - 3 );
	
	self thread trap_turn_off_chain();
	
	e_model_sound stopLoopSound( 3 );
	self util::waittill_notify_or_timeout( "trap_deactivate", 3 );
	e_model_sound delete();
	
	playSoundAtPosition( "evt_chaintrap_stop", self.origin );
	
	self notify( "trap_done" );
}

function trap_damage_chain()
{	
	self endon( "trap_done" );

	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_ent );
		
		if ( IS_TRUE( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_chain_trap ) )
			continue;
		
		if ( isPlayer( e_ent ) )
		{
			if ( e_ent isOnSlide() )
				continue;
			
			playSoundAtPosition( "wpn_thundergun_proj_impact", e_ent.origin );
			e_ent doDamage( e_ent.health, e_ent.origin );
		}
		else
			e_ent thread zombie_trap_death_chain( self );

	}
}

function zombie_trap_death_chain( e_trap )
{
	if ( isDefined( self.ptr_chain_trap_reaction_func ) )
	{
		self [ [ self.ptr_chain_trap_reaction_func ] ]( e_trap );
		return;
	}
	else if ( isDefined( self.trap_reaction_func ) )
	{
		self [ [ self.trap_reaction_func ] ]( e_trap );
		return;
	}
	
	if ( self.archetype === "mechz" || self.archetype === "margwa" )
		return;
	
	playSoundAtPosition( "wpn_thundergun_proj_impact", self.origin );
	
	self.marked_for_death = 1;
	
	level notify( "trap_kill", self, e_trap );
	
	str_tag = ( IS_TRUE( self.isdog ) ? "j_spine1" : "j_spineupper" );
	playFx( level._effect[ "zombie_guts_explosion" ], self getTagOrigin( str_tag ) );
	self zombie_utility::gib_random_parts();
	self ghost();
	self doDamage( self.health, self.origin, e_trap );

	if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
		e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
	
}

function trap_activate_hearts_chain()
{
	for ( i = 0; i < self._trap_switches.size; i++ )
		self._trap_switches[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_heart_pull_anim", self._trap_switches[ i ].origin , self._trap_switches[ i ].angles, "p7_fxanim_zm_zod_chain_trap_heart_pull_anim" );
		self._trap_switches[ i ] stopLoopSound();
	
	wait getAnimLength( "p7_fxanim_zm_zod_chain_trap_heart_pull_anim" );
	
	for ( i = 0; i < self._trap_switches.size; i++ )
		self._trap_switches[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_heart_fast_anim", self._trap_switches[ i ].origin , self._trap_switches[ i ].angles, "p7_fxanim_zm_zod_chain_trap_heart_fast_anim" );
}

function trap_cooldown_hearts_chain()
{
	for ( i = 0; i < self._trap_switches.size; i++ )
		self._trap_switches[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_heart_med_anim", self._trap_switches[ i ].origin , self._trap_switches[ i ].angles, "p7_fxanim_zm_zod_chain_trap_heart_med_anim" );

}

function trap_deactivate_hearts_chain()
{
	for ( i = 0; i < self._trap_switches.size; i++ )
		self._trap_switches[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_heart_low_anim", self._trap_switches[ i ].origin , self._trap_switches[ i ].angles, "p7_fxanim_zm_zod_chain_trap_heart_low_anim" );
		self._trap_switches[ i ] playLoopSound( "evt_chain_trap_heartbeat" );
}

function trap_turn_on_chain()
{
	x_start = ( isDefined( self.script_string ) ? "p7_fxanim_zm_zod_chain_trap_" + self.script_string + "_start_anim" : "p7_fxanim_zm_zod_chain_trap_start_anim" );
	x_on = ( isDefined( self.script_string ) ? "p7_fxanim_zm_zod_chain_trap_" + self.script_string + "_on_anim" : "p7_fxanim_zm_zod_chain_trap_on_anim" );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( x_start, self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, x_start );
	
	wait getAnimLength( x_start );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( x_on, self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, x_on );
}

function trap_turn_off_chain()
{
	x_end = ( isDefined( self.script_string ) ? "p7_fxanim_zm_zod_chain_trap_" + self.script_string + "_end_anim" : "p7_fxanim_zm_zod_chain_trap_end_anim" );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_symbol_on_anim", self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, "p7_fxanim_zm_zod_chain_trap_symbol_on_anim" );
	
	wait getAnimLength( "p7_fxanim_zm_zod_chain_trap_symbol_on_anim" );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( x_end, self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, x_end );
	
	wait getAnimLength( x_end );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_symbol_off_anim", self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, "p7_fxanim_zm_zod_chain_trap_symbol_off_anim" );
	
	self waittill( "available" );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] animScripted( "p7_fxanim_zm_zod_chain_trap_end_idle_anim", self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, "p7_fxanim_zm_zod_chain_trap_end_idle_anim" );
	
}