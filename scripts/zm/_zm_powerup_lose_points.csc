#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_lose_points.gsh;

#namespace zm_powerup_lose_points;

REGISTER_SYSTEM_EX( "zm_powerup_lose_points", &__init__, &__main__, undefined )
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::include_zombie_powerup( LOSE_POINTS_STRING );
	zm_powerups::add_zombie_powerup( LOSE_POINTS_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------