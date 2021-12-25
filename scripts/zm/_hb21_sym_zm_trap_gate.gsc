#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\gib;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_utility;
#using scripts\shared\vehicles\_auto_turret;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_gate.gsh;

#using_animtree( "generic" );

#namespace hb21_sym_zm_trap_gate;

REGISTER_SYSTEM( "hb21_sym_zm_trap_gate", &__init__, undefined )

function __init__()
{
	level._zombiemode_trap_use_funcs = [];
	level._zombiemode_trap_use_funcs[ GATE_TRAP_SCRIPT_NOTEWORTHY ] = &gate_trap_enabled;
	zm_traps::register_trap_basic_info( GATE_TRAP_SCRIPT_NOTEWORTHY, &gate_trap_activated, undefined );
}

function gate_trap_enabled( e_trap )
{
	for ( i = 0; i < e_trap._trap_movers.size; i++ )
	{
		if ( !IS_TRUE( e_trap._trap_movers[ i ].b_has_anim_tree ) )
		{
			e_trap._trap_movers[ i ] useAnimTree( #animtree );
			e_trap._trap_movers[ i ].b_has_anim_tree = 1;
			e_damage_trigger = getEnt( e_trap._trap_movers[ i ].target, "targetname" );
			e_damage_trigger enableLinkTo();
			e_damage_trigger linkTo( e_trap._trap_movers[ i ], "gate_jnt" );
		}
		e_trap._trap_movers[ i ] animScripted( "p7_fxanim_zm_castle_gate_door_rise_anim", e_trap._trap_movers[ i ].origin, e_trap._trap_movers[ i ].angles, "p7_fxanim_zm_castle_gate_door_rise_anim" );
	}
	self thread zm_traps::trap_use_think( e_trap );
}

function gate_trap_activated()
{	
	self._trap_duration = GATE_TRAP_DURATION;
	self._trap_cooldown_time = GATE_TRAP_COOLDOWN;

	self notify( "trap_activate" );
	level notify( "trap_activate", self );
	
	self.activated_by_player playRumbleOnEntity( "zm_castle_interact_rumble" );
	
	self thread gate_trap_activate_movers();
	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration );
	
	self notify( "trap_done" );
}

function gate_trap_activate_movers()
{
	for ( i = 0; i < self._trap_movers.size; i++ )
	{
		e_damage_trigger = getEnt( self._trap_movers[ i ].target, "targetname" );
		e_damage_trigger thread gate_trap_damage_loop( self );
		
		self._trap_movers[ i ].e_gate_chain = getEnt( e_damage_trigger.target, "targetname" );
		self._trap_movers[ i ].e_gate_chain useAnimTree( #animtree );
	}
	
	self gate_trap_loop_movers();
	
	for ( i = 0; i < self._trap_movers.size; i++ )
	{
		while ( self._trap_movers[ i ] isPlayingAnimScripted() )
			WAIT_SERVER_FRAME;
		
		e_damage_trigger = getEnt( self._trap_movers[ i ].target, "targetname" );
		e_damage_trigger unLink();
	}
	
}

function gate_trap_loop_movers()
{
	self endon( "trap_done" );
	
	while ( isDefined( self ) )
	{
		for ( i = 0; i < self._trap_movers.size; i++ )
		{
			self._trap_movers[ i ] animScripted( "p7_fxanim_zm_castle_gate_door_smash_anim", self._trap_movers[ i ].origin, self._trap_movers[ i ].angles, "p7_fxanim_zm_castle_gate_door_smash_anim" );
			self._trap_movers[ i ].e_gate_chain animScripted( "p7_fxanim_zm_castle_gate_base_smash_anim", self._trap_movers[ i ].e_gate_chain.origin, self._trap_movers[ i ].e_gate_chain.angles, "p7_fxanim_zm_castle_gate_base_smash_anim" );
			
			wait .25;
			playRumbleOnPosition( "zm_castle_gate_mash", self._trap_movers[ i ].origin );
			wait .5;
			
			if ( isDefined( GATE_TRAP_TIME_BETWEEN_SLAMS ) )
				wait GATE_TRAP_TIME_BETWEEN_SLAMS;
			
		}
	}
}

function gate_trap_damage_loop( e_trap )
{	
	e_trap endon( "trap_done" );
	
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_ent );
		
		if ( isDefined( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_gate_trap ) )
			continue;
		
		playSoundAtPosition( "wpn_thundergun_proj_impact", e_ent.origin );
		
		if ( isPlayer( e_ent ) )
			e_ent doDamage( e_ent.health + 666, e_ent.origin );
		else
			e_ent thread gate_trap_kill_zombie( e_trap );
			
	}
}

function gate_trap_kill_zombie( e_trap )
{
	if ( isDefined( self.ptr_gate_trap_reaction_func ) )
	{
		self [ [ self.ptr_gate_trap_reaction_func ] ]( e_trap );
		return;
	}
	else if ( isDefined( self.trap_reaction_func ) )
	{
		self [ [ self.trap_reaction_func ] ]( e_trap );
		return;
	}
	
	if ( self.archetype == "zombie" && !IS_TRUE( self.b_was_mashed ) )
		self thread gate_trap_kill_zombie_crushed( e_trap.activated_by_player, e_trap );
	else if ( self.archetype === "mechz" || self.archetype === "margwa" )
		e_trap notify( "trap_deactivate" );
	else
	{
		self.marked_for_death = 1;

		level notify( "trap_kill", self, e_trap );
	
		str_tag = ( IS_TRUE( self.isdog ) ? "j_spine1" : "j_spineupper" );
		playFx( level._effect[ "zombie_guts_explosion" ], self getTagOrigin( str_tag ) );
		self zombie_utility::gib_random_parts();
		self ghost();
		self doDamage( self.health + 666, self.origin, e_trap );
		if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
			e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
		
	}	
}

function gate_trap_kill_zombie_crushed( e_player, e_trap )
{
	n_chance = randomInt( 100 );
	if ( n_chance > 90 )
	{
		self.b_was_mashed = 1;
		self thread zombie_utility::makeZombieCrawler();
		wait 4;
		if ( isDefined( self ) )
			self.b_was_mashed = undefined;
		
	}
	else if ( n_chance > 50 )
	{
		self thread zombie_utility::zombie_gut_explosion();
		e_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
		self doDamage( self.health + 100, self.origin, e_trap, undefined, "none", "MOD_IMPACT" );
	}
	else
	{
		self thread zombie_utility::gib_random_parts();
		e_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
		self doDamage( self.health + 100, self.origin, e_trap, undefined, "none", "MOD_IMPACT" );
	}
	if ( IS_TRUE( GATE_TRAP_ZOMBIES_KILLED_RESPAWN ) )
		level.zombie_total++;

}
