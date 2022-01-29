#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_lose_perk.gsh;

#namespace zm_powerup_lose_perk;

REGISTER_SYSTEM_EX( "zm_powerup_lose_perk", &__init__, &__main__, undefined )
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::include_zombie_powerup( LOSE_PERK_STRING );
	zm_powerups::add_zombie_powerup( LOSE_PERK_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------