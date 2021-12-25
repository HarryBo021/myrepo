#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_glow" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_exp" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_trail" );

#namespace hb21_zm_weap_beacon; 

REGISTER_SYSTEM( "hb21_zm_weap_beacon", &__init__, undefined )

function __init__()
{
	level._effect[ "beacon_glow" ] = "dlc5/tomb/fx_tomb_beacon_glow";
	level._effect["beacon_shell_explosion"] = "dlc5/tomb/fx_tomb_beacon_exp";
	level._effect["beacon_shell_trail"] = "dlc5/tomb/fx_tomb_beacon_trail";
	
	clientfield::register( "scriptmover", "play_beacon_fx", 21000, 1, "int", &play_beacon_glow, 0, 0 );
	clientfield::register( "scriptmover", "play_artillery_barrage", 21000, 2, "int", &play_artillery_barrage, 0, 0 );
}

function play_beacon_glow( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasDemoJump )
{
	self endon( "weapon_beacon_destroyed" );
	while ( isdefined( self ) )
	{
		playSound( 0, "evt_beacon_beep", self.origin );
		PlayFXOnTag(localClientNum, level._effect[ "beacon_glow"], self, "origin_animate_jnt" );
		wait 1.5;
	}
}

function build_weap_beacon_landing_offsets()
{
	a_offsets = [];
	a_offsets[ 0 ] = (0, 0, 0);
	a_offsets[1] = VectorScale((-1, 1, 0), 72);
	a_offsets[2] = VectorScale((1, 1, 0), 72);
	a_offsets[3] = VectorScale((1, -1, 0), 72);
	a_offsets[4] = VectorScale((-1, -1, 0), 72);
	return (a_offsets);
}

function build_weap_beacon_start_offsets()
{
	a_offsets = [];
	a_offsets[0] = VectorScale((0, 0, 1), 8500);
	a_offsets[1] = (-6500, 6500, 8500);
	a_offsets[2] = (6500, 6500, 8500);
	a_offsets[3] = (6500, -6500, 8500);
	a_offsets[4] = (-6500, -6500, 8500);
	return a_offsets;
}

/*
	Name: function_1e3322d1
	Namespace: _zm_weap_beacon
	Checksum: 0x58BCE7C3
	Offset: 0x808
	Size: 0x2B9
	Parameters: 7
	Flags: None
*/
function play_artillery_barrage(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasDemoJump)
{
	if(newVal == 0)
	{
		return;
	}
	if(newVal == 1)
	{
		if(!isdefined(self.a_v_land_offsets))
		{
			self.a_v_land_offsets = [];
		}
		if(!isdefined(self.a_v_land_offsets[localClientNum]))
		{
			self.a_v_land_offsets[localClientNum] = self build_weap_beacon_landing_offsets();
		}
		if(!isdefined(self.a_v_start_offsets))
		{
			self.a_v_start_offsets = [];
		}
		if(!isdefined(self.a_v_start_offsets[localClientNum]))
		{
			self.a_v_start_offsets[localClientNum] = self build_weap_beacon_start_offsets();
		}
	}
	/*
	if(newVal == 2)
	{
		if(!isdefined(self.a_v_land_offsets))
		{
			self.a_v_land_offsets = [];
		}
		if(!isdefined(self.a_v_land_offsets[localClientNum]))
		{
			self.a_v_land_offsets[localClientNum] = self build_weap_beacon_landing_offsets_ee();
		}
		if(!isdefined(self.a_v_start_offsets))
		{
			self.a_v_start_offsets = [];
		}
		if(!isdefined(self.a_v_start_offsets[localClientNum]))
		{
			self.a_v_start_offsets[localClientNum] = self build_weap_beacon_start_offsets_ee();
		}
	}
	*/
	if(!isdefined(self.num_rockets_fired))
	{
		self.num_rockets_fired = [];
	}
	if(!isdefined(self.num_rockets_fired[localClientNum]))
	{
		self.num_rockets_fired[localClientNum] = 0;
	}
	n_index = self.num_rockets_fired[localClientNum];
	v_start = self.origin + self.a_v_start_offsets[localClientNum][n_index];
	shell = spawn(localClientNum, v_start, "script_model");
	shell.angles = VectorScale((-1, 0, 0), 90);
	shell SetModel("tag_origin");
	shell thread shell_logic(self, n_index, v_start, localClientNum);
	self.num_rockets_fired[localClientNum]++;
}

function shell_logic(model, index, v_start, localClientNum)
{
	v_land = model.origin + model.a_v_land_offsets[localClientNum][index];
	v_start_trace = v_start - VectorScale((0, 0, 1), 5000);
	trace = bullettrace(v_start_trace, v_land, 0, undefined);
	v_land = trace["position"];
	self moveto(v_land, 3);
	PlayFXOnTag(localClientNum, level._effect["beacon_shell_trail"], self, "tag_origin");
	self playsound(0, "zmb_homingbeacon_missile_boom");
	self thread sndplayincoming(v_land);
	self waittill("movedone");
	if(index == 1)
	{
		model notify("weapon_beacon_destroyed");
	}
	playFX(localClientNum, level._effect["beacon_shell_explosion"], self.origin);
	playsound(0, "wpn_rocket_explode", self.origin);
	self delete();
}

function sndplayincoming(origin)
{
	wait(2);
	playsound(0, "zmb_homingbeacon_missile_incoming", origin);
}