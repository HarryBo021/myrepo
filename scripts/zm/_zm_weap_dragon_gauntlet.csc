#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicles\_dragon_whelp;
#using scripts\zm\_callbacks;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_orange_glow1" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_orange_glow2" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_whelp_eye_glow_sm" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_whelp_mouth_drips_sm" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow1" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow2" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger2" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger3" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube" );
#precache( "client_fx", "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube2" );

#namespace zm_weap_dragon_gauntlet;

REGISTER_SYSTEM_EX( "zm_weap_dragon_gauntlet", &__init__, undefined, undefined )

/*
	Name: __init__
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x14B25167
	Offset: 0x538
	Size: 0x23
	Parameters: 0
	Flags: None
*/
function __init__()
{
	callback::on_localplayer_spawned(&player_on_spawned);
}

/*
	Name: player_on_spawned
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x79CC3A39
	Offset: 0x568
	Size: 0x23
	Parameters: 1
	Flags: None
*/
function player_on_spawned(localClientNum)
{
	self thread watch_weapon_changes(localClientNum);
}

/*
	Name: watch_weapon_changes
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0xCEB2EBF0
	Offset: 0x598
	Size: 0x18D
	Parameters: 1
	Flags: None
*/
function watch_weapon_changes(localClientNum)
{
	self endon("disconnect");
	self endon("entityshutdown");
	self.dragon_gauntlet = GetWeapon("dragon_gauntlet_flamethrower");
	self.dragon_gauntlet_flamethrower = GetWeapon("dragon_gauntlet");
	while(isdefined(self))
	{
		self waittill("weapon_change", weapon);
		if(weapon === self.dragon_gauntlet)
		{
			self thread function_7645efdb(localClientNum);
			self thread function_6c7c9327(localClientNum);
			self notify("hash_7c243ce8");
		}
		if(weapon === self.dragon_gauntlet_flamethrower)
		{
			self thread function_99aba1a5(localClientNum);
			self thread function_a8ac2d1d(localClientNum);
			self thread function_3011ccf6(localClientNum);
		}
		if(weapon !== self.dragon_gauntlet && weapon !== self.dragon_gauntlet_flamethrower)
		{
			self function_99aba1a5(localClientNum);
			self function_7645efdb(localClientNum);
			self notify("hash_7c243ce8");
		}
	}
}

/*
	Name: function_6c7c9327
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x7052A51B
	Offset: 0x730
	Size: 0x16D
	Parameters: 1
	Flags: None
*/
function function_6c7c9327(localClientNum)
{
	self endon("disconnect");
	self util::waittill_any_timeout(0.5, "weapon_change_complete", "disconnect");
	if(GetCurrentWeapon(localClientNum) === GetWeapon("dragon_gauntlet_flamethrower"))
	{
		if(!isdefined(self.var_11d5152b))
		{
			self.var_11d5152b = [];
		}
		self.var_11d5152b[self.var_11d5152b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_orange_glow1", "tag_fx_7");
		self.var_11d5152b[self.var_11d5152b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_orange_glow2", "tag_fx_6");
		self.var_11d5152b[self.var_11d5152b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_whelp_eye_glow_sm", "tag_eye_left_fx");
		self.var_11d5152b[self.var_11d5152b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_whelp_mouth_drips_sm", "tag_throat_fx");
	}
}

/*
	Name: function_a8ac2d1d
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x14C08406
	Offset: 0x8A8
	Size: 0x2BD
	Parameters: 1
	Flags: None
*/
function function_a8ac2d1d(localClientNum)
{
	self endon("disconnect");
	self util::waittill_any_timeout(0.5, "weapon_change_complete", "disconnect");
	if(GetCurrentWeapon(localClientNum) === GetWeapon("dragon_gauntlet"))
	{
		if(!isdefined(self.var_a7abd31))
		{
			self.var_a7abd31 = [];
		}
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow1", "tag_fx_7");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow2", "tag_fx_6");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger2", "tag_fx_1");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger", "tag_fx_2");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger", "tag_fx_3");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger", "tag_fx_4");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube", "tag_gauntlet_tube_01");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube", "tag_gauntlet_tube_02");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube", "tag_gauntlet_tube_03");
		self.var_a7abd31[self.var_a7abd31.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube", "tag_gauntlet_tube_04");
	}
}

/*
	Name: function_99aba1a5
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x1485465F
	Offset: 0xB70
	Size: 0xB1
	Parameters: 1
	Flags: None
*/
function function_99aba1a5(localClientNum)
{
	if(isdefined(self.var_11d5152b) && self.var_11d5152b.size > 0)
	{
		foreach(FX in self.var_11d5152b)
		{
			stopfx(localClientNum, FX);
		}
	}
}

/*
	Name: function_7645efdb
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0x6CBD7E65
	Offset: 0xC30
	Size: 0xB1
	Parameters: 1
	Flags: None
*/
function function_7645efdb(localClientNum)
{
	if(isdefined(self.var_a7abd31) && self.var_a7abd31.size > 0)
	{
		foreach(FX in self.var_a7abd31)
		{
			stopfx(localClientNum, FX);
		}
	}
}

/*
	Name: function_3011ccf6
	Namespace: zm_weap_dragon_gauntlet
	Checksum: 0xBB81351A
	Offset: 0xCF0
	Size: 0x31D
	Parameters: 1
	Flags: None
*/
function function_3011ccf6(localClientNum)
{
	self endon("disconnect");
	self endon("death");
	self endon("bled_out");
	self endon("hash_7c243ce8");
	self notify("hash_8d98e9db");
	self endon("hash_8d98e9db");
	while(isdefined(self))
	{
		self waittill("notetrack", note);
		// if(note === "dragon_gauntlet_115_punch_fx_start")
		if(note === "dlc3/stalingrad/fx_dragon_gauntlet_melee")
		{
			if(!isdefined(self.var_4d73e75b))
			{
				self.var_4d73e75b = [];
			}
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger3", "tag_fx_1");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger3", "tag_fx_2");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger3", "tag_fx_3");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_glow_finger3", "tag_fx_4");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube2", "tag_gauntlet_tube_01");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube2", "tag_gauntlet_tube_02");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube2", "tag_gauntlet_tube_03");
			self.var_4d73e75b[self.var_4d73e75b.size] = PlayViewmodelFX(localClientNum, "dlc3/stalingrad/fx_dragon_gauntlet_glove_blue_tube2", "tag_gauntlet_tube_04");
		}
		// if(note === "dragon_gauntlet_115_punch_fx_stop")
		if(note === "dlc3/stalingrad/fx_dragon_gauntlet_melee_impact")
		{
			if(isdefined(self.var_4d73e75b) && self.var_4d73e75b.size > 0)
			{
				foreach(FX in self.var_4d73e75b)
				{
					stopfx(localClientNum, FX);
				}
			}
		}
	}
}

