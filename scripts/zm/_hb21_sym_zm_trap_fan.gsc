#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\gib;
#insert scripts\shared\ai\systems\gib.gsh;
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
#insert scripts\zm\_hb21_sym_zm_trap_fan.gsh;

#using_animtree( "generic" );

#namespace hb21_sym_zm_trap_fan;

REGISTER_SYSTEM( "hb21_sym_zm_trap_fan", &__init__, undefined )

function __init__()
{
	clientfield::register( "scriptmover", FAN_TRAP_CLIENTFIELD,	VERSION_SHIP, 1, "int" );
	
	zm_traps::register_trap_basic_info( FAN_TRAP_SCRIPT_NOTEWORTHY, &fan_trap_activate, undefined );
}

function fan_trap_activate()
{	
	self._trap_duration = FAN_TRAP_DURATION;
	self._trap_cooldown_time = FAN_TRAP_COOLDOWN;

	self notify( "trap_activate" );
	level notify( "trap_activate", self );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] thread fan_trap_activate_movers();
	
	self thread fan_trap_damage_loop();
	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] thread fan_trap_deactivate_movers();
			  	
	wait 1;
	
	self notify( "trap_done" );
}

function fan_trap_damage_loop()
{	
	self endon( "trap_done" );

	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_ent );
		
		if ( IS_TRUE( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_fan_trap ) )
			continue;
		
		if ( isPlayer( e_ent ) )
		{
			if ( e_ent isOnSlide() )
				continue;

			playSoundAtPosition( "wpn_thundergun_proj_impact", e_ent.origin );
			e_ent doDamage( e_ent.health, e_ent.origin );
		}
		else
			e_ent thread fan_trap_kill_zombie( self );
		
	}
}

function fan_trap_kill_zombie( e_trap )
{
	if ( isDefined( self.ptr_fan_trap_reaction_func ) )
	{
		self [ [ self.ptr_fan_trap_reaction_func ] ]( e_trap );
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
	self doDamage( self.health + 666, self.origin, e_trap );

	if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
		e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
	
}

function fan_trap_activate_movers()
{
	self playSound( "evt_fan_trap_start" );
	self useAnimTree( #animtree );
	self animScripted( "p8_fxanim_zom_al_trap_fan_start_anim", self.origin , self.angles, "p8_fxanim_zom_al_trap_fan_start_anim" );
	wait getAnimLength( "p8_fxanim_zom_al_trap_fan_start_anim" );
	self playLoopSound( "evt_fan_trap_loop" );
	self clientfield::set( FAN_TRAP_CLIENTFIELD, 1 );
	self animScripted( "p8_fxanim_zom_al_trap_fan_idle_anim", self.origin , self.angles, "p8_fxanim_zom_al_trap_fan_idle_anim" );
}

function fan_trap_deactivate_movers()
{
	self stopLoopSound( 1 );
	self clientfield::set( FAN_TRAP_CLIENTFIELD, 0 );
	self animScripted( "p8_fxanim_zom_al_trap_fan_end_anim", self.origin , self.angles, "p8_fxanim_zom_al_trap_fan_end_anim" );
	self playsound( "evt_fan_trap_stop" );
}