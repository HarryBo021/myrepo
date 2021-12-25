
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\postfx_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_spiders.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#namespace zm_ai_spiders;

// spider round fx
#precache( "client_fx", "dlc2\island\fx_spider_round_tell" );
#precache( "client_fx", "dlc2\island\fx_web_grenade_tell" );
#precache( "client_fx", "dlc2\island\fx_web_bgb_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_bgb_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_perk_machine_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_perk_machine_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_barrier_tearing" );
#precache( "client_fx", "dlc2\island\fx_web_barrier_reveal" );
#precache( "client_fx", "dlc2\island\fx_web_impact_rocket" );

REGISTER_SYSTEM_EX( "zm_ai_spiders", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register("world", "force_stream_spiders", 9001, 1, "int", &force_stream_spiders, 0, 0);
	
	level._effect["spider_round"] 												= "dlc2/island/fx_spider_round_tell";
	level._effect["spider_web_grenade_stuck"] 							= "dlc2/island/fx_web_grenade_tell";
	level._effect["spider_web_bgb_tear"] 									= "dlc2/island/fx_web_bgb_tearing";
	level._effect["spider_web_bgb_tear_complete"] 					= "dlc2/island/fx_web_bgb_reveal";
	level._effect["spider_web_perk_machine_tear"] 					= "dlc2/island/fx_web_perk_machine_tearing";
	level._effect["spider_web_perk_machine_tear_complete"] 	= "dlc2/island/fx_web_perk_machine_reveal";
	level._effect["spider_web_doorbuy_tear"] 							= "dlc2/island/fx_web_barrier_tearing";
	level._effect["spider_web_doorbuy_tear_complete"] 			= "dlc2/island/fx_web_barrier_reveal";
	level._effect["spider_web_tear_explosive"] 							= "dlc2/island/fx_web_impact_rocket";
	register_clientfields();
	vehicle::add_vehicletype_callback("spider", &spider_vehicle_init);
	visionset_mgr::register_visionset_info("zm_isl_parasite_spider_visionset", 9000, 16, undefined, "zm_isl_parasite_spider");
}

function force_stream_spiders(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal)
	{
		ForceStreamXModel("c_zom_dlc2_spider");
	}
	else
	{
		StopForceStreamingXModel("c_zom_dlc2_spider");
	}
}

function __main__()
{
}

function register_clientfields()
{
	clientfield::register("toplayer", "spider_round_fx", 9000, 1, "counter", &spider_round_fx, 0, 0);
	clientfield::register("toplayer", "spider_round_ring_fx", 9000, 1, "counter", &spider_round_ring_fx, 0, 0);
	clientfield::register("toplayer", "spider_end_of_round_reset", 9000, 1, "counter", &spider_end_of_round_reset, 0, 0);
	clientfield::register("scriptmover", "set_fade_material", 9000, 1, "int", &set_fade_material, 0, 0);
	clientfield::register("scriptmover", "web_fade_material", 9000, 3, "float", &web_fade_material, 0, 0);
	clientfield::register("missile", "play_grenade_stuck_in_web_fx", 9000, 1, "int", &play_grenade_stuck_in_web_fx, 0, 0);
	clientfield::register("scriptmover", "play_spider_web_tear_fx", 9000, GetMinBitCountForNum(4), "int", &play_spider_web_tear_fx, 0, 0);
	clientfield::register("scriptmover", "play_spider_web_tear_complete_fx", 9000, GetMinBitCountForNum(4), "int", &play_spider_web_tear_complete_fx, 0, 0);
}

function spider_vehicle_init(localClientNum)
{
	self.str_tag_tesla_death_fx = "J_SpineUpper";
	self.str_tag_tesla_shock_eyes_fx = "J_SpineUpper";
}

function spider_round_fx(n_local_client, n_val_old, n_val_new, b_ent_new, b_initial_snap, str_field, b_demo_jump)
{
	self endon("disconnect");
	SetWorldFogActiveBank(n_local_client, 8);
	if(IsSpectating(n_local_client))
	{
		return;
	}
	self.fx_spider_round_camera = PlayFXOnCamera(n_local_client, level._effect["spider_round"]);
	playsound(0, "zmb_spider_round_webup", (0, 0, 0));
	wait(0.016);
	self thread postfx::playPostfxBundle("pstfx_parasite_spider");
	wait(3.5);
	deletefx(n_local_client, self.fx_spider_round_camera);
}

function spider_end_of_round_reset(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 1)
	{
		SetWorldFogActiveBank(localClientNum, 1);
	}
}

function spider_round_ring_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	self endon("disconnect");
	if(IsSpectating(localClientNum))
	{
		return;
	}
	self thread postfx::playPostfxBundle("pstfx_ring_loop");
	wait(1.5);
	self postfx::exitPostfxBundle();
}

function function_bea149a5(localClientNum, var_afc7cc94, var_b05b3457, b_on, n_alpha, var_abf03d83, var_c0ce8db2)
{
	if(!isdefined(n_alpha))
	{
		n_alpha = 1;
	}
	if(!isdefined(var_abf03d83))
	{
		var_abf03d83 = 0;
	}
	if(!isdefined(var_c0ce8db2))
	{
		var_c0ce8db2 = 0;
	}
	self endon("entityshutdown");
	if(self.b_on === b_on)
	{
		return;
	}
	else
	{
		self.b_on = b_on;
	}
	if(var_abf03d83)
	{
		if(b_on)
		{
			self transition_shader(localClientNum, n_alpha, var_afc7cc94);
		}
		else
		{
			self transition_shader(localClientNum, 0, var_afc7cc94);
		}
		return;
	}
	if(b_on)
	{
		var_24fbb6c6 = 0;
		i = 0;
		while(var_24fbb6c6 <= n_alpha)
		{
			self transition_shader(localClientNum, var_24fbb6c6, var_afc7cc94);
			if(var_c0ce8db2)
			{
				var_24fbb6c6 = sqrt(i);
			}
			else
			{
				var_24fbb6c6 = i;
			}
			wait(0.01);
			i = i + var_b05b3457;
		}
		self.var_bbfa5d7d = n_alpha;
		self transition_shader(localClientNum, n_alpha, var_afc7cc94);
	}
	else if(isdefined(self.var_bbfa5d7d))
	{
		var_bbfa5d7d = self.var_bbfa5d7d;
	}
	else
	{
		var_bbfa5d7d = 1;
	}
	var_24fbb6c6 = var_bbfa5d7d;
	i = var_bbfa5d7d;
	while(var_24fbb6c6 >= 0)
	{
		self transition_shader(localClientNum, var_24fbb6c6, var_afc7cc94);
		if(var_c0ce8db2)
		{
			var_24fbb6c6 = sqrt(i);
		}
		else
		{
			var_24fbb6c6 = i;
		}
		wait(0.01);
		i = i - var_b05b3457;
	}
	self transition_shader(localClientNum, 0, var_afc7cc94);
}

function transition_shader(localClientNum, n_value, var_afc7cc94)
{
	self MapShaderConstant(localClientNum, 0, "scriptVector" + var_afc7cc94, n_value, n_value, 0, 0);
}

function set_fade_material(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	self MapShaderConstant(localClientNum, 0, "scriptVector0", newVal, 0, 0, 0);
}

function web_fade_material(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	var_f2efc20a = 0;
	if(newVal <= 0)
	{
		var_f2efc20a = 0;
		var_32ee3d8b = newVal;
	}
	else
	{
		var_f2efc20a = 1;
		var_32ee3d8b = newVal;
	}
	self thread function_bea149a5(localClientNum, 0, 0.025, var_f2efc20a, var_32ee3d8b);
}

function play_grenade_stuck_in_web_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(isdefined(self))
	{
		PlayFXOnTag(localClientNum, level._effect["spider_web_grenade_stuck"], self, "tag_origin");
	}
}

function play_spider_web_tear_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	switch(newVal)
	{
		case 0:
		{
			if(isdefined(self) && isdefined(self.var_d5eda36c))
			{
				stopfx(localClientNum, self.var_d5eda36c);
				self.var_d5eda36c = undefined;
			}
			if(isdefined(self) && isdefined(self.var_cac11e11))
			{
				self StopLoopSound(self.var_cac11e11, 0.5);
				self playsound(0, "zmb_spider_web_tear_stop");
				self.var_cac11e11 = undefined;
			}
			return;
		}
		case 1:
		{
			str_effect = "spider_web_bgb_tear";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear";
			break;
		}
		default:
		{
			return;
		}
	}
	if(!isdefined(self.var_cac11e11))
	{
		self.var_cac11e11 = self PlayLoopSound("zmb_spider_web_tear_loop", 1);
		self playsound(0, "zmb_spider_web_tear_start");
	}
	if(!isdefined(self.var_d5eda36c))
	{
		self.var_d5eda36c = playFX(localClientNum, level._effect[str_effect], self.origin, AnglesToForward(self.angles), anglesToUp(self.angles));
	}
}

function play_spider_web_tear_complete_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	switch(newVal)
	{
		case 1:
		{
			str_effect = "spider_web_bgb_tear_complete";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear_complete";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear_complete";
			break;
		}
		case 4:
		{
			str_effect = "spider_web_tear_explosive";
			break;
		}
		default:
		{
			return;
		}
	}
	playFX(localClientNum, level._effect[str_effect], self.origin, AnglesToForward(self.angles), anglesToUp(self.angles));
}
