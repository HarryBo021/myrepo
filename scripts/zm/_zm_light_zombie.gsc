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

#namespace zm_light_zombie;

REGISTER_SYSTEM( "zm_light_zombie", &__init__, undefined )

function __init__()
{
	register_clientfields();
}

function private register_clientfields()
{
	clientfield::register( "actor", "light_zombie_clientfield_aura_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "light_zombie_clientfield_death_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "light_zombie_clientfield_damaged_fx", VERSION_SHIP, 1, "counter" );
}

function make_light_zombie()
{
	e_ai_zombie = self;
	n_light_zombie_count = zm_elemental_zombie::get_elemental_zombie_count( "light" );
	if ( !isDefined( level.n_max_light_zombies ) || n_light_zombie_count < level.n_max_light_zombies )
	{
		if ( !isDefined( e_ai_zombie.is_elemental_zombie ) || e_ai_zombie.is_elemental_zombie == 0 )
		{
			e_ai_zombie.is_elemental_zombie = 1;
			e_ai_zombie.elemental_type = "light";
			e_ai_zombie.health = int( e_ai_zombie.health * 1 );
			e_ai_zombie thread light_zombie_death();
			e_ai_zombie thread light_zombie_damage();
			e_ai_zombie thread light_zombie_aura_effects();
		}
	}
}

function light_zombie_aura_effects()
{
	self endon( "death" );
	wait 2;
	self clientfield::set( "light_zombie_clientfield_aura_fx", 1 );
}

function light_zombie_damage()
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage" );
		if ( randomInt( 100 ) < 50 )
			self clientfield::increment( "light_zombie_clientfield_damaged_fx" );
		
		wait .05;
	}
}

function light_zombie_death()
{
	e_ai_zombie = self;
	e_ai_zombie waittill( "death" );
	if ( !isDefined( e_ai_zombie ) || e_ai_zombie.nuked === 1 )
		return;
	
	v_origin = e_ai_zombie.origin;
	v_origin = v_origin + vectorScale( ( 0, 0, 1 ), 2 );
	e_ai_zombie clientfield::set( "light_zombie_clientfield_death_fx", 1 );
	e_ai_zombie zombie_utility::gib_random_parts();
	wait .05;
	str_mod = "MOD_EXPLOSIVE";
	radiusDamage( e_ai_zombie.origin + vectorScale( ( 0, 0, 1 ), 35 ), 128, 30, 10, self, str_mod );
	a_players = getPlayers();
	foreach ( e_player in a_players )
		e_player thread light_zombie_flash( e_ai_zombie.origin );
	
	e_ai_zombie hide();
	e_ai_zombie notSolid();
}

function light_zombie_flash( v_flash_origin )
{
	self endon( "death" );
	self endon( "disconnect" );
	e_player = self;
	dist_sq = distanceSquared( e_player.origin, v_flash_origin );
	max_dist_sq = 16384;
	min_dist_sq = 4096;
	mid_distance_sq = max_dist_sq - min_dist_sq;
	if ( dist_sq <= max_dist_sq && !IS_TRUE( e_player.b_light_zombie_flashed ) )
	{
		if ( dist_sq < min_dist_sq )
			flash_time = 1;
		else
		{
			n_calc = max_dist_sq - dist_sq / mid_distance_sq;
			n_decrement = n_calc * .5;
			n_flash_time = 1 - n_decrement;
		}
		if ( isDefined( n_flash_time ) )
		{
			n_flash_time = math::clamp( n_flash_time, .5, 1 );
			e_player thread light_player_shellshock_for_time( n_flash_time );
		}
	}
}

function light_player_shellshock_for_time( n_flash_time )
{
	self endon( "death" );
	self endon( "disconnect" );
	e_player = self;
	e_player.b_light_zombie_flashed = 1;
	e_player shellshock( "light_zombie_death", n_flash_time, 0 );
	wait 5;
	e_player.b_light_zombie_flashed = 0;
}