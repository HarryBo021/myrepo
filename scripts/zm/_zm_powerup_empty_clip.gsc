#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_empty_clip.gsh;

#precache( "string", "ZOMBIE_POWERUP_EMPTY_CLIP" );

#namespace zm_powerup_empty_clip;

REGISTER_SYSTEM_EX( "zm_powerup_empty_clip", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( EMPTY_CLIP_STRING, &grab_empty_clip );
	zm_powerups::add_zombie_powerup( EMPTY_CLIP_STRING, EMPTY_CLIP_MODEL, &"ZOMBIE_POWERUP_EMPTY_CLIP", &zm_powerups::func_should_never_drop, !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_statless_powerup( EMPTY_CLIP_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function grab_empty_clip( e_powerup, e_zombie )
{	
	level thread empty_clip_powerup( e_powerup, e_zombie );
}

function empty_clip_powerup( e_powerup, e_zombie )
{
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( !e_player laststand::player_is_in_laststand() && !( e_player.sessionstate == "spectator" ) )
		{
			w_weapon = e_player getCurrentWeapon();
			e_player setWeaponAmmoClip( w_weapon, 0 );
		}
	}
}
