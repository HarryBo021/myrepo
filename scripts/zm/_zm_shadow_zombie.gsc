#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_elemental_zombies;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_shadow_zombie;

#precache( "fx", "dlc4/genesis/fx_zombie_shadow_trap_exp" );

REGISTER_SYSTEM( "zm_shadow_zombie", &__init__, undefined )

function __init__()
{
	register_clientfields();
	if ( !isdefined( level._effect[ "cursetrap_explosion" ] ) )
		level._effect[ "cursetrap_explosion" ] = "dlc4/genesis/fx_zombie_shadow_trap_exp";
	
}

function private register_clientfields()
{
	clientfield::register( "actor", "shadow_zombie_clientfield_aura_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "shadow_zombie_clientfield_death_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "shadow_zombie_clientfield_damaged_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", "shadow_zombie_cursetrap_fx", VERSION_SHIP, 1, "int" );
}

function make_shadow_zombie()
{
	e_ai_zombie = self;
	n_shadow_zombie_count = zm_elemental_zombie::get_elemental_zombie_count( "shadow" );
	if ( !isDefined( level.n_max_shadow_zombies ) || n_shadow_zombie_count < level.n_max_shadow_zombies )
	{
		if(!isdefined(e_ai_zombie.is_elemental_zombie) || e_ai_zombie.is_elemental_zombie == 0)
		{
			e_ai_zombie.is_elemental_zombie = 1;
			e_ai_zombie.elemental_type = "shadow";
			e_ai_zombie clientfield::set("shadow_zombie_clientfield_aura_fx", 1);
			e_ai_zombie.health = int( e_ai_zombie.health * 1 );
			e_ai_zombie thread shadow_zombie_death();
			e_ai_zombie thread shadow_zombie_damage();
		}
	}
}

function shadow_zombie_damage()
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage" );
		if ( randomInt( 100 ) < 50 )
			self clientfield::increment( "shadow_zombie_clientfield_damaged_fx" );
		
		wait .05;
	}
}

function shadow_zombie_death()
{
	e_ai_zombie = self;
	e_ai_zombie waittill( "death" );
	if ( !isDefined( e_ai_zombie ) || e_ai_zombie.nuked === 1 )
		return;
	
	v_origin = e_ai_zombie.origin;
	v_origin = v_origin + vectorScale( ( 0, 0, 1 ), 2 );
	level thread shadow_zombie_death_aoe( v_origin, undefined );
	e_ai_zombie clientfield::set( "shadow_zombie_clientfield_death_fx", 1 );
	e_ai_zombie zombie_utility::gib_random_parts();
	wait .05;
	e_ai_zombie hide();
	e_ai_zombie notSolid();
}

function shadow_zombie_death_aoe( v_origin, n_duration = randomFloatRange( 5, 10 ) )
{
	e_shadow_trap = util::spawn_model( "tag_origin", v_origin, vectorScale( ( -1, 0, 0 ), 90 ) );
	e_shadow_trap.targetname = "shadow_curse_trap";
	e_shadow_trap clientfield::set( "shadow_zombie_cursetrap_fx", 1 );
	e_shadow_trap thread shadow_zombie_death_aoe_delete_trigger_after_time( n_duration );
	e_shadow_trap thread shadow_zombie_death_aoe_damage();
	return e_shadow_trap;
}

function private shadow_zombie_death_aoe_delete_trigger_after_time( n_duration )
{
	wait n_duration;
	if ( isDefined( self ) )
	{
		if ( isDefined( self.trigger ) )
			self.trigger delete();
		
		self delete();
	}
}

function private shadow_zombie_death_aoe_damage()
{
	self.trigger = spawn( "trigger_radius", self.origin, 2, 40, 50 );
	
	while ( isDefined( self ) )
	{
		self.trigger waittill( "trigger", e_guy );
		if ( isDefined( self ))
		{
			playFX( level._effect[ "cursetrap_explosion" ], self.origin );
			e_guy playSound( "zmb_zod_cursed_landmine_explode" );
			e_guy doDamage( int( e_guy.health / 2 ), e_guy.origin, self, self );

			if ( isDefined( self.trigger ) )
				self.trigger delete();
			
			self delete();
		}
	}
}