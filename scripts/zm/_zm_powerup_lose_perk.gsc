#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_lose_perk.gsh;

#precache( "string", "ZOMBIE_POWERUP_LOSE_PERK" );

#namespace zm_powerup_lose_perk;

REGISTER_SYSTEM_EX( "zm_powerup_lose_perk", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( LOSE_PERK_STRING, &grab_lose_perk );
	zm_powerups::add_zombie_powerup( LOSE_PERK_STRING, LOSE_PERK_MODEL, &"ZOMBIE_POWERUP_LOSE_PERK", &zm_powerups::func_should_never_drop, !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_statless_powerup( LOSE_PERK_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function grab_lose_perk( e_powerup, e_zombie )
{	
	level thread lose_perk_powerup( e_powerup, e_zombie );
}

function lose_perk_powerup( e_powerup, e_zombie )
{
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( !e_player laststand::player_is_in_laststand() && !( e_player.sessionstate == "spectator" ) )
			e_player zm_perks::lose_random_perk();
		
	}
}
