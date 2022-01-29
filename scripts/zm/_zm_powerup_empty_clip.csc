#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_empty_clip.gsh;

#namespace zm_powerup_empty_clip;

REGISTER_SYSTEM_EX( "zm_powerup_empty_clip", &__init__, &__main__, undefined )
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::include_zombie_powerup( EMPTY_CLIP_STRING );
	zm_powerups::add_zombie_powerup( EMPTY_CLIP_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------