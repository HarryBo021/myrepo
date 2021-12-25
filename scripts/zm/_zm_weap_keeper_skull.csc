#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace keeper_skull;

#precache( "client_fx", "zombie/fx_tesla_shock_eyes_zmb" );
#precache( "client_fx", "zombie/fx_glow_eye_white" );
#precache( "client_fx", "dlc2/island/fx_zombie_torso_explo" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_start_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_loop_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_end_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_start_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_loop_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_end_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_start_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_loop_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_end_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_start_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_loop_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_beam_side_end_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_start_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_loop_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_end_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_start_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_loop_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_end_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_start_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_loop_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_end_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_start_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_loop_3p_island" );
#precache( "client_fx", "dlc2/zmb_weapon/fx_wpn_skull_torch_side_end_3p_island" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_arm_left_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_arm_rgt_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_leg_left_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_leg_rgt_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_hip_left_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_hip_rgt_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_torso_loop" );
#precache( "client_fx", "dlc2/island/fx_fire_thrash_waist_loop" );

REGISTER_SYSTEM_EX( "keeper_skull", &__init__, undefined, undefined )

function __init__()
{
	clientfield::register("actor", "zombie_explode", 9000, 1, "int", &function_615adc5e, 0, 0);
	clientfield::register("actor", "death_ray_shock_eye_fx", 9000, 1, "int", &function_4513798e, 0, 0);
	clientfield::register("actor", "entranced", 9000, 1, "int", &function_384d8884, 0, 0);
	clientfield::register("actor", "thrasher_skull_fire", 9000, 1, "int", &function_5543770f, 0, 0);
	clientfield::register("toplayer", "skull_beam_fx", 9000, 2, "int", &function_4fb98616, 0, 0);
	clientfield::register("toplayer", "skull_torch_fx", 9000, 2, "int", &function_2802db6f, 0, 0);
	clientfield::register("allplayers", "skull_beam_3p_fx", 9000, 2, "int", &function_3f47ba02, 0, 0);
	clientfield::register("allplayers", "skull_torch_3p_fx", 9000, 2, "int", &function_cea6821, 0, 0);
	clientfield::register("allplayers", "skull_emissive", 9000, 1, "int", &function_c92fcc97, 0, 0);
	level._effect["death_ray_shock_eyes"] = "zombie/fx_tesla_shock_eyes_zmb";
	level._effect["glow_eye_white"] = "zombie/fx_glow_eye_white";
	level._effect["zombie_explode"] = "dlc2/island/fx_zombie_torso_explo";
	level._effect["beam_start"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_start_island";
	level._effect["beam_loop"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_loop_island";
	level._effect["beam_end"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_end_island";
	level._effect["beam_start_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_start_3p_island";
	level._effect["beam_loop_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_loop_3p_island";
	level._effect["beam_end_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_end_3p_island";
	level._effect["beam_side_start"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_start_island";
	level._effect["beam_side_loop"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_loop_island";
	level._effect["beam_side_end"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_end_island";
	level._effect["beam_side_start_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_start_3p_island";
	level._effect["beam_side_loop_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_loop_3p_island";
	level._effect["beam_side_end_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_beam_side_end_3p_island";
	level._effect["torch_start"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_start_island";
	level._effect["torch_loop"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_loop_island";
	level._effect["torch_end"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_end_island";
	level._effect["torch_side_start"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_start_island";
	level._effect["torch_side_loop"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_loop_island";
	level._effect["torch_side_end"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_end_island";
	level._effect["torch_start_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_start_3p_island";
	level._effect["torch_loop_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_loop_3p_island";
	level._effect["torch_end_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_end_3p_island";
	level._effect["torch_side_start_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_start_3p_island";
	level._effect["torch_side_loop_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_loop_3p_island";
	level._effect["torch_side_end_3p"] = "dlc2/zmb_weapon/fx_wpn_skull_torch_side_end_3p_island";
	level._effect["fx_fire_thrash_arm_left_loop"] = "dlc2/island/fx_fire_thrash_arm_left_loop";
	level._effect["fx_fire_thrash_arm_rgt_loop"] = "dlc2/island/fx_fire_thrash_arm_rgt_loop";
	level._effect["fx_fire_thrash_leg_left_loop"] = "dlc2/island/fx_fire_thrash_leg_left_loop";
	level._effect["fx_fire_thrash_leg_rgt_loop"] = "dlc2/island/fx_fire_thrash_leg_rgt_loop";
	level._effect["fx_fire_thrash_hip_left_loop"] = "dlc2/island/fx_fire_thrash_hip_left_loop";
	level._effect["fx_fire_thrash_hip_rgt_loop"] = "dlc2/island/fx_fire_thrash_hip_rgt_loop";
	level._effect["fx_fire_thrash_torso_loop"] = "dlc2/island/fx_fire_thrash_torso_loop";
	level._effect["fx_fire_thrash_waist_loop"] = "dlc2/island/fx_fire_thrash_waist_loop";
}

/*
	Name: function_2802db6f
	Namespace: keeper_skull
	Checksum: 0xA44C072A
	Offset: 0x1220
	Size: 0x345
	Parameters: 7
	Flags: None
*/
function function_2802db6f(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(IsSpectating(localClientNum))
	{
		return;
	}
	if(newVal == 1)
	{
		if(isdefined(self GetTagOrigin("tag_fx_mouth")))
		{
			PlayViewmodelFX(localClientNum, level._effect["torch_start"], "tag_fx_mouth");
		}
		if(isdefined(self GetTagOrigin("tag_fx_left")))
		{
			PlayViewmodelFX(localClientNum, level._effect["torch_side_start"], "tag_fx_left");
		}
		if(isdefined(self GetTagOrigin("tag_fx_right")))
		{
			PlayViewmodelFX(localClientNum, level._effect["torch_side_start"], "tag_fx_right");
		}
	}
	else if(newVal == 2)
	{
		if(isdefined(self GetTagOrigin("tag_fx_mouth")))
		{
			self.var_159d6213 = PlayViewmodelFX(localClientNum, level._effect["torch_loop"], "tag_fx_mouth");
		}
		if(isdefined(self GetTagOrigin("tag_fx_left")))
		{
			self.var_4030b4a0 = PlayViewmodelFX(localClientNum, level._effect["torch_side_loop"], "tag_fx_left");
		}
		if(isdefined(self GetTagOrigin("tag_fx_right")))
		{
			self.var_f04b5791 = PlayViewmodelFX(localClientNum, level._effect["torch_side_loop"], "tag_fx_right");
		}
	}
	else if(isdefined(self.var_159d6213))
	{
		stopfx(localClientNum, self.var_159d6213);
		self.var_159d6213 = undefined;
	}
	if(isdefined(self.var_4030b4a0))
	{
		stopfx(localClientNum, self.var_4030b4a0);
		self.var_4030b4a0 = undefined;
	}
	if(isdefined(self.var_f04b5791))
	{
		stopfx(localClientNum, self.var_f04b5791);
		self.var_f04b5791 = undefined;
	}
}

/*
	Name: function_4fb98616
	Namespace: keeper_skull
	Checksum: 0xB99AC059
	Offset: 0x1570
	Size: 0x2F5
	Parameters: 7
	Flags: None
*/
function function_4fb98616(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(IsSpectating(localClientNum))
	{
		return;
	}
	if(newVal == 1)
	{
		PlayViewmodelFX(localClientNum, level._effect["beam_start"], "tag_flash");
		if(isdefined(self GetTagOrigin("tag_fx_right")))
		{
			PlayViewmodelFX(localClientNum, level._effect["beam_side_start"], "tag_fx_right");
		}
		if(isdefined(self GetTagOrigin("tag_fx_left")))
		{
			PlayViewmodelFX(localClientNum, level._effect["beam_side_start"], "tag_fx_left");
		}
	}
	else if(newVal == 2)
	{
		self.var_1bcaa674 = PlayViewmodelFX(localClientNum, level._effect["beam_loop"], "tag_flash");
		if(isdefined(self GetTagOrigin("tag_fx_left")))
		{
			self.var_17822f77 = PlayViewmodelFX(localClientNum, level._effect["beam_side_loop"], "tag_fx_left");
		}
		if(isdefined(self GetTagOrigin("tag_fx_right")))
		{
			self.var_76b0d9e8 = PlayViewmodelFX(localClientNum, level._effect["beam_side_loop"], "tag_fx_right");
		}
	}
	else if(isdefined(self.var_1bcaa674))
	{
		stopfx(localClientNum, self.var_1bcaa674);
		self.var_1bcaa674 = undefined;
	}
	if(isdefined(self.var_17822f77))
	{
		stopfx(localClientNum, self.var_17822f77);
		self.var_17822f77 = undefined;
	}
	if(isdefined(self.var_76b0d9e8))
	{
		stopfx(localClientNum, self.var_76b0d9e8);
		self.var_76b0d9e8 = undefined;
	}
}

/*
	Name: function_615adc5e
	Namespace: keeper_skull
	Checksum: 0x4EF8C552
	Offset: 0x1870
	Size: 0x313
	Parameters: 7
	Flags: None
*/
function function_615adc5e(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(isdefined(self.gibdef))
	{
		gibBundle = struct::get_script_bundle("gibcharacterdef", self.gibdef);
		var_e02aa733 = self.gibdef + "_nofx";
		if(!isdefined(struct::get_script_bundle("gibcharacterdef", var_e02aa733)))
		{
			var_8083daae = spawnstruct();
			var_8083daae.gibs = [];
			var_8083daae.name = gibBundle.name;
			foreach(gib in gibBundle.gibs)
			{
				var_8083daae.gibs[gib] = spawnstruct();
				var_8083daae.gibs[gib].gibmodel = gibBundle.gibs[gib].gibmodel;
				var_8083daae.gibs[gib].gibtag = gibBundle.gibs[gib].gibtag;
				var_8083daae.gibs[gib].gibdynentfx = gibBundle.gibs[gib].gibdynentfx;
				var_8083daae.gibs[gib].gibsound = gibBundle.gibs[gib].gibsound;
			}
			level.scriptbundles["gibcharacterdef"][var_e02aa733] = var_8083daae;
		}
		self.gib_data = spawnstruct();
		self.gib_data.gibdef = var_e02aa733;
	}
	PlayFXOnTag(localClientNum, level._effect["zombie_explode"], self, "j_spine4");
}

/*
	Name: function_4513798e
	Namespace: keeper_skull
	Checksum: 0xA300BF3B
	Offset: 0x1B90
	Size: 0xC5
	Parameters: 7
	Flags: None
*/
function function_4513798e(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 1)
	{
		if(!isdefined(self.var_5f35d5e4))
		{
			self.var_5f35d5e4 = PlayFXOnTag(localClientNum, level._effect["death_ray_shock_eyes"], self, "J_Eyeball_LE");
		}
	}
	else
	{
		deletefx(localClientNum, self.var_5f35d5e4, 1);
		self.var_5f35d5e4 = undefined;
	}
}

/*
	Name: function_384d8884
	Namespace: keeper_skull
	Checksum: 0xBB2B7933
	Offset: 0x1C60
	Size: 0xC5
	Parameters: 7
	Flags: None
*/
function function_384d8884(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 1)
	{
		if(!isdefined(self.var_60a62a48))
		{
			self.var_60a62a48 = PlayFXOnTag(localClientNum, level._effect["glow_eye_white"], self, "J_Eyeball_LE");
		}
	}
	else
	{
		deletefx(localClientNum, self.var_60a62a48, 1);
		self.var_60a62a48 = undefined;
	}
}

/*
	Name: function_5543770f
	Namespace: keeper_skull
	Checksum: 0xFC56D6E1
	Offset: 0x1D30
	Size: 0x93
	Parameters: 7
	Flags: None
*/
function function_5543770f(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 0)
	{
		self thread function_c16de463(0, localClientNum);
	}
	else if(newVal == 1)
	{
		self thread function_c16de463(1, localClientNum);
	}
}

/*
	Name: function_c16de463
	Namespace: keeper_skull
	Checksum: 0x704D11CF
	Offset: 0x1DD0
	Size: 0x591
	Parameters: 2
	Flags: None
*/
function function_c16de463(var_1607039a, localClientNum)
{
	if(var_1607039a)
	{
		if(!isdefined(self.var_9cd89d5f))
		{
			self.var_9cd89d5f = [];
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_arm_left_loop"], self, "j_shoulder_le");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_arm_rgt_loop"], self, "j_shoulder_ri");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_leg_left_loop"], self, "j_knee_le");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_leg_rgt_loop"], self, "j_knee_ri");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_hip_left_loop"], self, "j_hip_le");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_hip_rgt_loop"], self, "j_hip_ri");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_torso_loop"], self, "j_spineupper");
			if(!isdefined(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = [];
			}
			else if(!IsArray(self.var_9cd89d5f))
			{
				self.var_9cd89d5f = Array(self.var_9cd89d5f);
			}
			self.var_9cd89d5f[self.var_9cd89d5f.size] = PlayFXOnTag(localClientNum, level._effect["fx_fire_thrash_waist_loop"], self, "j_spinelower");
		}
	}
	else
	{
		foreach(var_41865f6c in self.var_9cd89d5f)
		{
			stopfx(localClientNum, var_41865f6c);
		}
		self.var_9cd89d5f = undefined;
	}
}

/*
	Name: function_c92fcc97
	Namespace: keeper_skull
	Checksum: 0xA63DDE97
	Offset: 0x2370
	Size: 0xA3
	Parameters: 7
	Flags: None
*/
function function_c92fcc97(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal)
	{
		self MapShaderConstant(localClientNum, 0, "scriptVector2", 1, 1, 1, 0);
	}
	else
	{
		self MapShaderConstant(localClientNum, 0, "scriptVector2", 0, 0, 0, 0);
	}
}

/*
	Name: function_cea6821
	Namespace: keeper_skull
	Checksum: 0x3A41785
	Offset: 0x2420
	Size: 0x15D
	Parameters: 7
	Flags: None
*/
function function_cea6821(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(IsSpectating(localClientNum))
	{
		return;
	}
	player = GetLocalPlayer(localClientNum);
	if(newVal == 1)
	{
		if(player != self)
		{
			PlayFXOnTag(localClientNum, level._effect["torch_start_3p"], self, "tag_flash");
		}
	}
	else if(newVal == 2)
	{
		if(player != self)
		{
			self.var_23a3e944 = PlayFXOnTag(localClientNum, level._effect["torch_loop_3p"], self, "tag_flash");
		}
	}
	else if(player != self)
	{
		if(isdefined(self.var_23a3e944))
		{
			stopfx(localClientNum, self.var_23a3e944);
			self.var_23a3e944 = undefined;
		}
	}
}

/*
	Name: function_3f47ba02
	Namespace: keeper_skull
	Checksum: 0xDCBFB49A
	Offset: 0x2588
	Size: 0x15D
	Parameters: 7
	Flags: None
*/
function function_3f47ba02(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(IsSpectating(localClientNum))
	{
		return;
	}
	player = GetLocalPlayer(localClientNum);
	if(newVal == 1)
	{
		if(player != self)
		{
			PlayFXOnTag(localClientNum, level._effect["beam_start_3p"], self, "tag_flash");
		}
	}
	else if(newVal == 2)
	{
		if(player != self)
		{
			self.var_5f48ba4b = PlayFXOnTag(localClientNum, level._effect["beam_loop_3p"], self, "tag_flash");
		}
	}
	else if(player != self)
	{
		if(isdefined(self.var_5f48ba4b))
		{
			stopfx(localClientNum, self.var_5f48ba4b);
			self.var_5f48ba4b = undefined;
		}
	}
}

