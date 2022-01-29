#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_bouncingbetty;
#using scripts\zm\_util;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace controllable_spider;

REGISTER_SYSTEM_EX( "controllable_spider", &__init__, undefined, undefined )

// player.var_e3645e32 = 

function __init__(localClientNum)
{
	clientfield::register("scriptmover", "player_cocooned_fx", 9000, 1, "int", &player_cocooned_fx, 0, 0);
	clientfield::register("allplayers", "player_cocooned_fx", 9000, 1, "int", &player_cocooned_fx, 0, 0);
}

function player_cocooned_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 1)
	{
		if(!isdefined(self.var_e3645e32))
		{
			self.var_e3645e32 = [];
		}
		self.var_e3645e32[localClientNum] = PlayFXOnTag(localClientNum, level._effect["cocooned_fx"], self, "tag_origin");
	}
}