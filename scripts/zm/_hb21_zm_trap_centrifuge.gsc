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
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_zm_trap_centrifuge.gsh;

#namespace hb21_zm_trap_centrifuge;

REGISTER_SYSTEM( "hb21_zm_trap_centrifuge", &__init__, undefined )
	
function __init__()
{
	zm_traps::register_trap_basic_info( CENTRIFUGE_TRAP_SCRIPT_NOTEWORTHY, &centrifuge_trap_activate, undefined );
	
	clientfield::register( "scriptmover", CENTRIFUGE_TRAP_CLIENTFIELD, VERSION_SHIP, 	1, "int" );
}

function centrifuge_trap_activate()
{	
	self._trap_duration = CENTRIFUGE_TRAP_DURATION;
	self._trap_cooldown_time = CENTRIFUGE_TRAP_COOLDOWN;

	self enableLinkTo();
	self linkTo( self._trap_movers[ 0 ] );
	
	self thread centrifuge_trap_damage_loop();
	old_angles = self._trap_movers[ 0 ].angles;
	
	self._trap_movers[ 0 ] playSound( "zmb_cent_alarm" );
	self._trap_movers[ 0 ] playSound( "zmb_cent_start" );
	self._trap_movers[ 0 ] clientfield::set( "centrifuge_lights", 1 );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] RotateYaw( 360, 5.0, 4.5 );
	
	wait 5;
	step = 1.5;
	
	self._trap_movers[ 0 ] playLoopSound( "zmb_cent_lowend_loop", .6 );
	self._trap_movers[ 0 ] playLoopSound( "zmb_cent_mach_loop", .6 );
		
	for ( t = 0; t < self._trap_duration; t = t + step )
	{
		for ( i=0; i<self._trap_movers.size; i++ )
			self._trap_movers[ i ] RotateYaw( 360, step );
		
		wait step;
	}

	self._trap_movers[ 0 ] stopLoopSound( 2 );
	self._trap_movers[ 0 ] playSound( "zmb_cent_end" );
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] RotateYaw( 360, 5.0, 0.0, 4.5 );
	
	wait 5;
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ].angles = old_angles;

	self unLink();
	self._trap_movers[ 0 ] clientfield::set( "centrifuge_lights", 0 );
	
	self notify ( "trap_done" );	
}

function centrifuge_trap_damage_loop()
{	
	self endon( "trap_done" );

	while ( 1 )
	{
		self waittill( "trigger", e_ent );
		
		if ( !isDefined( e_ent ) || ( isDefined( e_ent.sessionstate ) && IS_TRUE( e_ent.sessionstate == "spectator" ) ) || IS_TRUE( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_centrifuge_trap ) )
			continue;
		
		if ( isPlayer( e_ent ) )
		{
			if ( e_ent getStance() == "stand" )
			{
				e_ent doDamage( 50, e_ent.origin );
				e_ent setStance( "crouch" );
			}
		}
		else
			e_ent thread centrifuge_trap_kill_zombie( self );

	}
}

function centrifuge_trap_kill_zombie( e_trap )
{
	if ( isDefined( self.ptr_centrifuge_trap_reaction_func ) )
	{
		self [ [ self.ptr_centrifuge_trap_reaction_func ] ]( e_trap );
		return;
	}
	else if ( isDefined( self.trap_reaction_func ) )
	{
		self [ [ self.trap_reaction_func ] ]( e_trap );
		return;
	}
	
	if ( self.archetype === "mechz" || self.archetype === "margwa" )
		return;
	
	playSoundAtPosition( "zmb_cent_zombie_gib", self.origin );

	self.marked_for_death = 1;

	v_ang = vectorToAngles( e_trap.origin - self.origin );
	
	v_direction_vec = vectorScale( anglesToRight( v_ang ), 200 );
	
	level notify( "trap_kill", self, e_trap );
	
	GibServerUtils::GibHead( self );
	
	self startRagdoll();
	self launchRagdoll( v_direction_vec );

	self doDamage( self.health, self.origin, e_trap );

	if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
		e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
	
}