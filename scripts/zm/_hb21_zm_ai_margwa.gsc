#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_zonemgr;
// #using scripts\zm\_hb21_zm_utility;
#using scripts\shared\_burnplayer;
#using scripts\zm\gametypes\_zm_gametype;
#using scripts\shared\aat_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\aat_zm.gsh;
#insert scripts\zm\_hb21_zm_ai_margwa.gsh;

#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\blackboard;

#using scripts\shared\ai\margwa;
#using scripts\zm\_zm_ai_margwa;
#using scripts\zm\_zm_ai_margwa_elemental;

#namespace hb21_zm_ai_margwa; 

REGISTER_SYSTEM( "hb21_zm_ai_margwa", &__init__, undefined )

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None 
*/
function __init__()
{
	// # SPAWN SET UP
	
	// # SPAWN SET UP
	
	// # BEHAVIOR SET UP
	
	// # BEHAVIOR SET UP
	
	// # CLIENTFIELD REGISTRATION
	
	// # CLIENTFIELD REGISTRATION

	// # REGISTER IMMUNITY FOR AI FROM AATS
	
	// # REGISTER IMMUNITY FOR AI FROM AATS
	
	// # VARIABLES AND SETTINGS
	level.b_margwa_debug 																= MARGWA_ZOMBIE_DEBUG;
	level.n_margwa_debug_spawn_delay 											= MARGWA_ZOMBIE_DEBUG_SPAWN_DELAY;
	level.b_margwa_zombies_enabled												= 1;
	level.n_margwa_max																	= MARGWA_ZOMBIE_MAX_ALLOWED_START;
	level.n_next_margwa_spawn_round											= MARGWA_ZOMBIE_ROUND_REQUIREMENT + randomIntRange( 0, MARGWA_ZOMBIE_MAXIMUM_ROUND_WAIT + 1 );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER AI CALLBACKS
	
	// # REGISTER AI CALLBACKS
	
	// # REGISTER PLAYER CALLBACKS
	
	// # REGISTER PLAYER CALLBACKS
	
	// THREAD LOGIC
	level thread margwa_zombie_spawn_logic();
	level thread margwa_zombie_debug_spawn_logic();
	// THREAD LOGIC
}

// ============================== INITIALIZE ==============================

// ============================== BEHAVIOR ==============================



// ============================== BEHAVIOR ==============================

// ============================== SPAWN LOGIC ==============================

function delay_if_blackscreen_pending()
{
	while ( !flag::exists( "initial_blackscreen_passed" ) )
		WAIT_SERVER_FRAME;
	
	if ( !flag::get( "initial_blackscreen_passed" ) )
		level flag::wait_till( "initial_blackscreen_passed" );
	
}

function custom_spawn_location_selection( a_spots )
{
	if ( isDefined( level.zombie_respawns ) && level.zombie_respawns > 0 )
	{
		if( !isDefined( level.n_player_spawn_selection_index ) )
			level.n_player_spawn_selection_index = 0;

		a_players = getPlayers();
		level.n_player_spawn_selection_index++;
		if ( level.n_player_spawn_selection_index >= a_players.size )
			level.n_player_spawn_selection_index = 0;
		
		e_player = a_players[ level.n_player_spawn_selection_index ];

		arraySortClosest( a_spots, e_player.origin );

		a_candidates = [];

		v_player_dir = anglesToForward( e_player.angles );
		
		for ( i = 0; i < a_spots.size; i++ )
		{
			v_dir = a_spots[ i ].origin - e_player.origin;
			dp = vectorDot( v_player_dir, v_dir );
			if ( dp >= 0.0 )
			{
				a_candidates[ a_candidates.size ] = a_spots[ i ];
				if ( a_candidates.size > 10 )
					break;
				
			}
		}

		if ( a_candidates.size )
			s_spot = array::random( a_candidates );
		else
			s_spot = array::random(a_spots);
		
	}
	else
		s_spot = array::random( a_spots );
	
	return s_spot;
}

/* 
MARGWA ZOMBIE DEBUG SPAWN LOGIC
Description : This function controls the logic for spawning the Mechz Zombie when the debug is on
Notes : if level.b_margwa_debug is set to true, the Mechz Zombie will spawn on repeat, at intervals of whatever level.n_margwa_debug_spawn_delay is set to
Notes : This could be used to activate / deactivate constant spawning Mechz Zombies for boss battles or something
*/

function margwa_zombie_debug_spawn_logic()
{
	while ( 1 )
	{
		if ( IS_TRUE( level.b_margwa_debug ) )
		{
			margwa_zombie_debug_print( "#LOG 001 : SPAWN MARGWA" );
			margwa_zombie_spawn();
			wait level.n_margwa_debug_spawn_delay;
			continue;
		}
		WAIT_SERVER_FRAME;
	}
}

/* 
MARGWA ZOMBIE SPAWN LOGIC
Description : This function controls the logic for spawning the Mechz Zombie when appropriate
Notes : None
*/
function margwa_zombie_spawn_logic()
{
	delay_if_blackscreen_pending();
	
	while ( 1 )
	{
		level waittill( "between_round_over" );
		
		if ( level.round_number > level.n_next_margwa_spawn_round )
			level.n_next_margwa_spawn_round = level.round_number;
		
		if ( isDefined( level.next_dog_round ) && level.next_dog_round == level.n_next_margwa_spawn_round )
			level.n_next_margwa_spawn_round++;
		
		if ( level.round_number < level.n_next_margwa_spawn_round )
			continue;
		
		level margwa_zombie_spawner_logic();
		
		level.n_margwa_max += MARGWA_ZOMBIE_MAX_ALLOWED_INCRIMENT;
		
		if ( level.n_margwa_max > MARGWA_ZOMBIE_MAX_ALLOWED_CAP )
			level.n_margwa_max = MARGWA_ZOMBIE_MAX_ALLOWED_CAP;
		
	}
}

/* 
MARGWA ZOMBIE SPAWNER LOGIC
Description : This function is called by MARGWA ZOMBIE SPAWN LOGIC, and handles the Mechz Zombie's spawning within that round
Notes : If the max amount of Mechz Zombies allowed spawned at once time is met, the thread will pause, if the overall per round cap of Mechz Zombies has been met, the thread will terminate
*/
function margwa_zombie_spawner_logic()
{
	level notify( "margwa_zombie_spawner_logic" );
	level endon( "margwa_zombie_spawner_logic" );
	level endon( "end_of_round" );
	
	while ( !isDefined( level.zombie_total ) || level.zombie_total < 1 )
		WAIT_SERVER_FRAME;
	
	n_round_total = level.zombie_total;
	
	n_increment = int( n_round_total / ( level.n_margwa_max + 1 ) );
	
	n_next_spawn = int( n_round_total - n_increment );
		
	level.n_margwa_zombie_spawned_this_round = 0;
	while ( level.n_margwa_zombie_spawned_this_round < level.n_margwa_max )
	{
		while ( IS_TRUE( level.intermission ) )
			WAIT_SERVER_FRAME;
		
		while ( !IS_TRUE( level.b_margwa_zombies_enabled ) )
			WAIT_SERVER_FRAME;
		
		a_margwas = getAIArchetypeArray( "margwa" );
		
		if ( level.zombie_total > n_next_spawn || ( isDefined( a_margwas ) && a_margwas.size >= MARGWA_ZOMBIE_MAX_AT_ONCE_CAP ) )
		{
			WAIT_SERVER_FRAME;
			continue;
		}
		
		ai_margwa = margwa_zombie_spawn();

		if ( !isDefined( ai_margwa ) )
		{
			WAIT_SERVER_FRAME;
			continue;
		}

		if ( level.n_margwa_zombie_spawned_this_round == 0 )
			level.n_next_margwa_spawn_round = level.round_number + randomIntRange( MARGWA_ZOMBIE_MINIMUM_ROUND_WAIT, MARGWA_ZOMBIE_MAXIMUM_ROUND_WAIT + 1 );
		
		level.n_margwa_zombie_spawned_this_round++;

		n_next_spawn -= n_increment;
	}
	
	// return true;
}

/* 
MARGWA ZOMBIE GET SPAWN POINT
Description : This function returns a valid spawn point struct
Notes : If no struct is found, this will fallback and use the player respawn logic and player spawn points instead, as at least one of those will always exist
*/
function margwa_zombie_get_spawn_point()
{
	if ( !isDefined( level.zm_loc_types ) || !isArray( level.zm_loc_types ) )
		return undefined;
	
	if ( !isDefined( level.zm_loc_types[ "margwa_location" ] ) )
		return undefined;
	
	a_structs = level.zm_loc_types[ "margwa_location" ];
	// a_structs = struct::get_array( 		"margwa_location", 					"script_noteworthy"		 );
	
	// if ( !isDefined( a_structs ) || a_structs.size < 1 )
	// 	a_structs = level.zm_loc_types[ "zombie_location" ];
	
	s_struct = custom_spawn_location_selection( a_structs );
	return s_struct;
}

/* 
MARGWA ZOMBIE SPAWN
Description : This function will spawn a Mechz Zombie at the struct that was passed to it
Notes : None
*/
function margwa_zombie_spawn( s_struct )
{
	if ( !isDefined( s_struct ) )
		s_struct = margwa_zombie_get_spawn_point();
	
	if ( !isDefined( s_struct ) )
	{
		margwa_zombie_debug_print( "#ERROR 002 : NO VALID SPAWN POINTS FOUND" );
		return undefined;
	}
	
	n_rand = randomInt( 3 );
	if ( n_rand == 0 )
		ai_margwa = zm_ai_margwa_elemental::spawn_fire_margwa( undefined, s_struct );
	else if ( n_rand == 1 )
		ai_margwa = zm_ai_margwa_elemental::spawn_shadow_margwa( undefined, s_struct );
	else
		ai_margwa = zm_ai_margwa::spawn_margwa( s_struct );
	
	if ( isDefined( ai_margwa ) )
	{
		// ai_margwa.no_damage_points 									= 1;
		// ai_margwa.maxhealth 									= 1000000;
		// ai_margwa.health 									= 1000000;
	}
	
	// ai_margwa waittill( "death" );
	
	return ai_margwa;
}

// ============================== SPAWN LOGIC ==============================

// ============================== CALLBACKS ==============================



// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================



// ============================== FUNCTIONALITY ==============================

// ============================== EVENT OVERRIDES ==============================



// ============================== EVENT OVERRIDES ==============================

// ============================== DEVELOPER ==============================

/* 
MARGWA ZOMBIE DEBUG PRINT
Description : This function handles printing some information for debugging purposes
Notes : None
*/
function margwa_zombie_debug_print( text )
{
	if ( !IS_TRUE( MARGWA_ZOMBIE_DEVELOPER_DEBUG_PRINTS ) )
		return;
	
	iPrintLnBold( "^1#MARGWA ZOMBIE DEBUG : " + text );
}

// ============================== DEVELOPER ==============================
