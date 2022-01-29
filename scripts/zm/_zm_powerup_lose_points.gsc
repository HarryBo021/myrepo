#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_lose_points.gsh;

#precache( "string", "ZOMBIE_POWERUP_LOSE_POINTS" );

#namespace zm_powerup_lose_points;

REGISTER_SYSTEM_EX( "zm_powerup_lose_points", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( LOSE_POINTS_STRING, &grab_lose_points );
	zm_powerups::add_zombie_powerup( LOSE_POINTS_STRING, LOSE_POINTS_MODEL, &"ZOMBIE_POWERUP_LOSE_POINTS", &zm_powerups::func_should_never_drop, !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_statless_powerup( LOSE_POINTS_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function grab_lose_points( e_powerup, e_zombie )
{	
	level thread lose_points_team_powerup( e_powerup, e_zombie );
}

function lose_points_team_powerup( e_powerup, e_zombie )
{
	n_points = int( randomIntRange( 1, 25 ) * 100 );
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( !a_players[ i ] laststand::player_is_in_laststand() && !( a_players[ i ].sessionstate == "spectator" ) )
		{
			if ( 0 > a_players[ i ].score - n_points )
			{
				a_players[ i ] zm_score::minus_to_player_score( a_players[ i ].score );
				continue;
			}
			a_players[ i ] zm_score::minus_to_player_score( n_points );
		}
	}
}
