#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicles\_glaive;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#namespace zm_weap_glaive;

#precache( "client_fx", "zombie/fx_sword_trail_1p_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_trail_1p_lvl2_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_slash_right_1p_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_slash_left_1p_zod_zmb" );
#precache( "client_fx", "zombie/fx_keeper_death_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_slam_elec_1p_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_slam_elec_3p_zod_zmb" );
#precache( "client_fx", "zombie/fx_sword_lvl2_throw_1p_zod_zmb" );

/*
	Name: __init__sytem__
	Namespace: zm_weap_glaive
	Checksum: 0xB0BF3911
	Offset: 0x3D8
	Size: 0x33
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_weap_glaive", &__init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: zm_weap_glaive
	Checksum: 0xD86598C6
	Offset: 0x418
	Size: 0x2AD
	Parameters: 0
	Flags: None
*/
function __init__()
{
	clientfield::register("allplayers", "slam_fx", 1, 1, "counter", &function_69a90263, 0, 0);
	clientfield::register("toplayer", "throw_fx", 1, 1, "counter", &function_6b6e650c, 0, 0);
	clientfield::register("toplayer", "swipe_fx", 1, 1, "counter", &function_b881d4aa, 0, 0);
	clientfield::register("toplayer", "swipe_lv2_fx", 1, 1, "counter", &function_647dc27d, 0, 0);
	clientfield::register("actor", "zombie_slice_r", 1, 2, "counter", &function_bbeb4c2c, 1, 0);
	clientfield::register("actor", "zombie_slice_l", 1, 2, "counter", &function_38924d95, 1, 0);
	level._effect["sword_swipe_1p"] = "zombie/fx_sword_trail_1p_zod_zmb";
	level._effect["sword_swipe_lv2_1p"] = "zombie/fx_sword_trail_1p_lvl2_zod_zmb";
	level._effect["sword_bloodswipe_r_1p"] = "zombie/fx_sword_slash_right_1p_zod_zmb";
	level._effect["sword_bloodswipe_l_1p"] = "zombie/fx_sword_slash_left_1p_zod_zmb";
	level._effect["sword_bloodswipe_r_level2_1p"] = "zombie/fx_keeper_death_zod_zmb";
	level._effect["sword_bloodswipe_l_level2_1p"] = "zombie/fx_keeper_death_zod_zmb";
	level._effect["groundhit_1p"] = "zombie/fx_sword_slam_elec_1p_zod_zmb";
	level._effect["groundhit_3p"] = "zombie/fx_sword_slam_elec_3p_zod_zmb";
	level._effect["sword_lvl2_throw"] = "zombie/fx_sword_lvl2_throw_1p_zod_zmb";
}

/*
	Name: function_b881d4aa
	Namespace: zm_weap_glaive
	Checksum: 0x14C14BCE
	Offset: 0x6D0
	Size: 0xEB
	Parameters: 7
	Flags: None
*/
function function_b881d4aa(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	owner = self GetOwner(localClientNum);
	if(isdefined(owner) && owner == GetLocalPlayer(localClientNum))
	{
		var_a0bb60fa = PlayViewmodelFX(localClientNum, level._effect["sword_swipe_1p"], "tag_flash");
		wait(3);
		deletefx(localClientNum, var_a0bb60fa, 1);
	}
}

/*
	Name: function_647dc27d
	Namespace: zm_weap_glaive
	Checksum: 0x84B7450A
	Offset: 0x7C8
	Size: 0xEB
	Parameters: 7
	Flags: None
*/
function function_647dc27d(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	owner = self GetOwner(localClientNum);
	if(isdefined(owner) && owner == GetLocalPlayer(localClientNum))
	{
		var_f2f7c3ad = PlayViewmodelFX(localClientNum, level._effect["sword_swipe_lv2_1p"], "tag_flash");
		wait(3);
		deletefx(localClientNum, var_f2f7c3ad, 1);
	}
}

/*
	Name: function_bbeb4c2c
	Namespace: zm_weap_glaive
	Checksum: 0xE4CC7B1C
	Offset: 0x8C0
	Size: 0x103
	Parameters: 7
	Flags: None
*/
function function_bbeb4c2c(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(util::is_mature() && !util::is_gib_restricted_build())
	{
		if(newVal == 1)
		{
			PlayFXOnTag(localClientNum, level._effect["sword_bloodswipe_r_1p"], self, "j_spine4");
		}
		else if(newVal == 2)
		{
			PlayFXOnTag(localClientNum, level._effect["sword_bloodswipe_r_level2_1p"], self, "j_spineupper");
		}
	}
	self playsound(0, "zmb_sword_zombie_explode");
}

/*
	Name: function_38924d95
	Namespace: zm_weap_glaive
	Checksum: 0x69290AD2
	Offset: 0x9D0
	Size: 0x103
	Parameters: 7
	Flags: None
*/
function function_38924d95(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(util::is_mature() && !util::is_gib_restricted_build())
	{
		if(newVal == 1)
		{
			PlayFXOnTag(localClientNum, level._effect["sword_bloodswipe_l_1p"], self, "j_spine4");
		}
		else if(newVal == 2)
		{
			PlayFXOnTag(localClientNum, level._effect["sword_bloodswipe_l_level2_1p"], self, "j_spineupper");
		}
	}
	self playsound(0, "zmb_sword_zombie_explode");
}

/*
	Name: function_69a90263
	Namespace: zm_weap_glaive
	Checksum: 0x639F2132
	Offset: 0xAE0
	Size: 0x5B
	Parameters: 7
	Flags: None
*/
function function_69a90263(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	thread do_gravity_spike_fx(localClientNum, self, self.origin);
}

/*
	Name: function_6b6e650c
	Namespace: zm_weap_glaive
	Checksum: 0x3A70CC4D
	Offset: 0xB48
	Size: 0xEB
	Parameters: 7
	Flags: None
*/
function function_6b6e650c(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	owner = self GetOwner(localClientNum);
	if(isdefined(owner) && owner == GetLocalPlayer(localClientNum))
	{
		var_b7fb3c1b = PlayFXOnCamera(localClientNum, level._effect["sword_lvl2_throw"], (0, 0, 0), (0, 1, 0), (0, 0, 1));
		wait(3);
		deletefx(localClientNum, var_b7fb3c1b, 1);
	}
}

/*
	Name: do_gravity_spike_fx
	Namespace: zm_weap_glaive
	Checksum: 0x1E70591A
	Offset: 0xC40
	Size: 0x19B
	Parameters: 3
	Flags: None
*/
function do_gravity_spike_fx(localClientNum, owner, position)
{
	var_f31c9d4c = 0;
	if(self isPlayer() && self isLocalPlayer() && !IsDemoPlaying())
	{
		if(!isdefined(self getlocalclientnumber()) || localClientNum == self getlocalclientnumber())
		{
			var_f31c9d4c = 1;
		}
	}
	if(var_f31c9d4c)
	{
		FX = level._effect["groundhit_1p"];
		fwd = AnglesToForward(owner.angles);
		playFX(localClientNum, FX, position + fwd * 100, fwd);
	}
	else
	{
		FX = level._effect["groundhit_3p"];
		fwd = AnglesToForward(owner.angles);
		playFX(localClientNum, FX, position, fwd);
	}
}

/*
	Name: getIdealLocationForFX
	Namespace: zm_weap_glaive
	Checksum: 0x5E85FB25
	Offset: 0xDE8
	Size: 0xB5
	Parameters: 5
	Flags: None
*/
function getIdealLocationForFX(startPos, fxIndex, fxCount, defaultDistance, rotation)
{
	currentAngle = 360 / fxCount * fxIndex;
	cosCurrent = cos(currentAngle + rotation);
	sinCurrent = sin(currentAngle + rotation);
	return startPos + (defaultDistance * cosCurrent, defaultDistance * sinCurrent, 0);
}

/*
	Name: randomizeLocation
	Namespace: zm_weap_glaive
	Checksum: 0x75A51745
	Offset: 0xEA8
	Size: 0xE1
	Parameters: 3
	Flags: None
*/
function randomizeLocation(startPos, max_x_offset, max_y_offset)
{
	half_x = Int(max_x_offset / 2);
	half_y = Int(max_y_offset / 2);
	rand_x = randomIntRange(half_x * -1, half_x);
	rand_y = randomIntRange(half_y * -1, half_y);
	return startPos + (rand_x, rand_y, 0);
}

/*
	Name: ground_trace
	Namespace: zm_weap_glaive
	Checksum: 0x4FD5A9D4
	Offset: 0xF98
	Size: 0x71
	Parameters: 2
	Flags: None
*/
function ground_trace(startPos, owner)
{
	trace_height = 50;
	trace_depth = 100;
	return bullettrace(startPos + (0, 0, trace_height), startPos - (0, 0, trace_depth), 0, owner);
}

