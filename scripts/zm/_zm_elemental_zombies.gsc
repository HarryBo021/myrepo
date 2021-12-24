#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\animation_shared;
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
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_elemental_zombie;

REGISTER_SYSTEM( "zm_elemental_zombie", &__init__, undefined )

function __init__()
{
	register_clientfields();
}

function private register_clientfields()
{
	clientfield::register( "actor", "sparky_zombie_spark_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "sparky_zombie_death_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "napalm_zombie_death_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "sparky_damaged_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", "napalm_damaged_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", "napalm_sfx", VERSION_SHIP, 1, "int" );
}

function make_sparky_zombie()
{
	e_ai_zombie = self;
	if ( !isAlive( e_ai_zombie ) )
		return;
	
	n_sparky_zombie_count = get_elemental_zombie_count( "sparky" );
	if ( !isDefined( level.n_max_sparky_zombies ) || n_sparky_zombie_count < level.n_max_sparky_zombies )
	{
		if ( !isDefined( e_ai_zombie.is_elemental_zombie ) || e_ai_zombie.is_elemental_zombie == 0 )
		{
			e_ai_zombie.is_elemental_zombie = 1;
			e_ai_zombie.elemental_zombie_type = "sparky";
			e_ai_zombie clientfield::set( "sparky_zombie_spark_fx", 1 );
			e_ai_zombie.health = int( e_ai_zombie.health * 1.5 );
			e_ai_zombie thread sparky_zombie_death();
			e_ai_zombie thread sparky_zombie_damage();
			if ( e_ai_zombie.isCrawler === 1 )
				a_anims = array( "ai_zm_dlc1_zombie_crawl_turn_sparky_a", "ai_zm_dlc1_zombie_crawl_turn_sparky_b", "ai_zm_dlc1_zombie_crawl_turn_sparky_c", "ai_zm_dlc1_zombie_crawl_turn_sparky_d", "ai_zm_dlc1_zombie_crawl_turn_sparky_e" );
			else
				a_anims = array( "ai_zm_dlc1_zombie_turn_sparky_a", "ai_zm_dlc1_zombie_turn_sparky_b", "ai_zm_dlc1_zombie_turn_sparky_c", "ai_zm_dlc1_zombie_turn_sparky_d", "ai_zm_dlc1_zombie_turn_sparky_e" );
			
			if ( isDefined( e_ai_zombie ) && !isDefined( e_ai_zombie.traverseStartNode ) )
				e_ai_zombie animation::play( array::random( a_anims ), e_ai_zombie, undefined, 1, .2, .2 );
			
		}
	}
}

function make_napalm_zombie()
{
	if ( isDefined( self ) )
	{
		e_ai_zombie = self;
		n_napalm_zombie_count = get_elemental_zombie_count( "napalm" );
		if ( !isDefined( level.n_max_napalm_zombies ) || n_napalm_zombie_count < level.n_max_napalm_zombies )
		{
			if ( !isDefined( e_ai_zombie.is_elemental_zombie ) || e_ai_zombie.is_elemental_zombie == 0 )
			{
				e_ai_zombie.is_elemental_zombie = 1;
				e_ai_zombie.elemental_zombie_type = "napalm";
				e_ai_zombie clientfield::set( "arch_actor_fire_fx", 1 );
				e_ai_zombie clientfield::set( "napalm_sfx", 1 );
				e_ai_zombie.health = int( e_ai_zombie.health * .75 );
				e_ai_zombie thread napalm_zombie_death();
				e_ai_zombie thread napalm_zombie_damage();
				e_ai_zombie zombie_utility::set_zombie_run_cycle( "sprint" );
			}
		}
	}
}

function sparky_zombie_damage()
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage" );
		if ( randomInt( 100 ) < 50 )
			self clientfield::increment( "sparky_damaged_fx" );
		
		wait .05;
	}
}

function napalm_zombie_damage()
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage" );
		if ( randomInt( 100 ) < 50 )
			self clientfield::increment( "napalm_damaged_fx" );
		
		wait .05;
	}
}

function sparky_zombie_death()
{
	e_ai_zombie = self;
	e_ai_zombie waittill( "death" );
	if ( !isDefined( e_ai_zombie ) || e_ai_zombie.nuked === 1 )
		return;
	
	e_ai_zombie clientfield::set( "sparky_zombie_death_fx", 1 );
	e_ai_zombie zombie_utility::gib_random_parts();
	gibServerUtils::annihilate( e_ai_zombie );
	radiusDamage( e_ai_zombie.origin + vectorScale( ( 0, 0, 1 ), 35 ), 128, 70, 30, self, "MOD_EXPLOSIVE" );
}

function napalm_zombie_death()
{
	e_ai_zombie = self;
	e_ai_zombie waittill( "death" );
	if ( !isDefined( e_ai_zombie ) || e_ai_zombie.nuked === 1 )
		return;
	
	e_ai_zombie clientfield::set( "napalm_zombie_death_fx", 1 );
	e_ai_zombie zombie_utility::gib_random_parts();
	gibServerUtils::annihilate( e_ai_zombie );
	e_ai_zombie.custom_player_shellshock = &napalm_player_shellshock;
	
	radiusDamage( e_ai_zombie.origin + vectorScale( ( 0, 0, 1 ), 35 ), 128, 70, 30, self, "MOD_EXPLOSIVE" );
}

function napalm_player_shellshock( n_damage, e_attacker, v_direction, v_point, str_mod )
{
	if ( getDvarString( "blurpain" ) == "on" )
		self shellshock( "pain_zm", .5 );
	
}

function get_non_elemental_zombies_in_range( pos, range )
{
	var_7843fa64 = get_non_elemental_zombies();
	a_zombies = array::get_all_closest( pos, var_7843fa64, undefined, undefined, range );
	return a_zombies;
}

function get_non_elemental_zombies()
{
	a_zombies = getAIArchetypeArray( "zombie" );
	a_filtered_zombies = array::filter( a_zombies, 0, &is_not_elemental_zombie );
	return a_filtered_zombies;
}

function get_elemental_type_zombies( str_type )
{
	a_zombies = getAIArchetypeArray( "zombie" );
	a_filtered_zombies = array::filter( a_zombies, 0, &is_elemental_type_zombie, str_type );
	return a_filtered_zombies;
}

function get_elemental_zombie_count( str_type )
{
	a_zombies = get_elemental_type_zombies( str_type );
	return a_zombies.size;
}

function is_elemental_type_zombie( e_ai_zombie, str_type )
{
	return e_ai_zombie.elemental_type === str_type;
}

function is_not_elemental_zombie( e_ai_zombie )
{
	return e_ai_zombie.is_elemental_zombie !== 1;
}