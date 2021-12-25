#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_weap_utility; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_utility", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register("clientuimodel", "hudItems.dpadLeftAmmo", 21000, 5, "int", undefined, 0, 0);
	clientfield::register( "allplayers", "rs_ammo",	VERSION_SHIP, 1, "int", &set_rocketshield_ammo, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function __main__()
{
}

function set_rocketshield_ammo( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if( newVal == 1 )
	{
		self MapShaderConstant( localClientNum, 0, "scriptVector2", 0, 1, 0, 0 );
	}
	else
	{
		self MapShaderConstant( localClientNum, 0, "scriptVector2", 0, 0, 0, 0 );
	}
}