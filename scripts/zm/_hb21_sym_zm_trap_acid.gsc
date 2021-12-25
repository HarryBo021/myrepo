#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_playerhealth;
#using scripts\zm\_zm_utility;
#using scripts\shared\scene_shared;
#using scripts\shared\vehicles\_auto_turret;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_acid.gsh;

#namespace hb21_sym_zm_trap_acid;

REGISTER_SYSTEM( "hb21_sym_zm_trap_acid", &__init__, undefined )

function __init__()
{
	clientfield::register( "actor", 	ACID_TRAP_DISSOLVE_CLIENTFIELD,	VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", 	ACID_TRAP_DISSOLVE_CLIENTFIELD,	VERSION_SHIP, 1, "int" );
	
	a_traps = struct::get_array( "trap_acid", "targetname" );
	foreach ( e_trap in a_traps )
		clientfield::register( "world", e_trap.script_noteworthy, VERSION_SHIP, 1, "int" );			
	
	zm_traps::register_trap_basic_info( ACID_TRAP_SCRIPT_NOTEWORTHY, &acid_trap_activated, undefined );
}

function acid_trap_activated()
{	
	self._trap_duration = ACID_TRAP_DURATION;
	self._trap_cooldown_time = ACID_TRAP_COOLDOWN;
	
	self notify( "trap_activate" );
	level notify( "trap_activate", self );
	
	e_model_sound  = util::spawn_model( "tag_origin", self.origin, self.angles );
	e_model_sound playLoopSound( "evt_acid_trap_loop", 3 );	
	
	level clientfield::set( self.target, 1 );
	
	self thread acid_trap_damage_loop();

	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration - 3 );
		
	level clientfield::set( self.target, 0 );
	e_model_sound stopLoopSound( 3 );
	
	self util::waittill_notify_or_timeout( "trap_deactivate", 3 );
	
	e_model_sound delete();
	
	self notify( "trap_done" );
}

function acid_trap_damage_loop()
{	
	self endon( "trap_done" );

	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_ent );
		
		if ( IS_TRUE( e_ent.b_acid_trap_damaged ) || IS_TRUE( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_acid_trap ) )
			continue;
		
		if ( isPlayer( e_ent ) )
			e_ent thread acid_trap_damage_and_cooldown( ACID_TRAP_DAMAGE_PERCENT, self );
		else
			e_ent thread acid_trap_damage_zombie( self );	
		
	}
}

function acid_trap_damage_zombie( e_trap )
{
	n_damage = int( ( self.maxHealth / 100 ) * ACID_TRAP_DAMAGE_PERCENT ); 
	
	if ( self.health <= n_damage )
		self acid_trap_kill_zombie( e_trap );
	else
		self thread acid_trap_damage_and_cooldown( n_damage, e_trap );
	
}

function acid_trap_kill_zombie( e_trap )
{
	if ( isDefined( self.ptr_acid_trap_reaction_func ) )
	{
		self [ [ self.ptr_acid_trap_reaction_func ] ]( e_trap );
		return;
	}
	else if ( isDefined( self.trap_reaction_func ) )
	{
		self [ [ self.trap_reaction_func ] ]( e_trap );
		return;
	}
	
	if ( self.archetype === "mechz" || self.archetype === "margwa" )
		return;
	
	playSoundAtPosition( "zmb_acid_death", self.origin );
	
	self.marked_for_death = 1;
	
	level notify( "trap_kill", self, e_trap );
	
	self clientfield::set( ACID_TRAP_DISSOLVE_CLIENTFIELD, 1 );
	self clientfield::set( "zombie_has_eyes", 0 );
	
	self acid_trap_stun_zombie();
	
	if ( isDefined( self ) && isAlive( self ) )
		self doDamage( self.health + 666, self.origin, e_trap );
	
	self ghost();
	
	if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
		e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
			
}

function acid_trap_stun_zombie()
{
	self endon( "death" );
	
	if ( isDefined( self.archetype ) && self.archetype == "zombie" )
	{
		x_stun_anim = ACID_TRAP_STUN_ANIM[ randomInt( 5 ) ];	
		self animScripted( x_stun_anim, self.origin, self.angles, x_stun_anim );
		wait 1;
	}
	else
		wait ACID_TRAP_DELAY_DAMAGE;
	
}

function acid_trap_damage_and_cooldown( n_damage, e_trap )
{
	self notify( "acid_trap_damage_and_cooldown" );
	self endon( "acid_trap_damage_and_cooldown" );
	self endon( "death_or_disconnect" );
	
	if ( isPlayer( self ) )
		self zm_playerhealth::player_health_visionset();
	
	self doDamage( n_damage, self.origin, e_trap );
	
	self.b_acid_trap_damaged = 1;
	wait ACID_TRAP_DELAY_DAMAGE;
	self.b_acid_trap_damaged = undefined;
}
