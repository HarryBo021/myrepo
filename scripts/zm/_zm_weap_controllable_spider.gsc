#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\player_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;
#using scripts\zm\_util;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_placeable_mine;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace controllable_spider;

REGISTER_SYSTEM_EX( "controllable_spider", &__init__, undefined, undefined )

function __init__()
{
	register_clientfields();
	zm_placeable_mine::add_mine_type("controllable_spider", &"");
	callback::on_spawned(&controllable_spider_on_player_spawned);
	level.w_controllable_spider = GetWeapon("controllable_spider");
	level flag::init("controllable_spider_equipped");
	/*
	/#
		function_be10e0f1();
	#/
	*/
}

function register_clientfields()
{
	clientfield::register("scriptmover", "player_cocooned_fx", 9000, 1, "int");
	clientfield::register("allplayers", "player_cocooned_fx", 9000, 1, "int");
	// clientfield::register("clientuimodel", "hudItems.showDpadRight_Spider", 9000, 1, "int");
}

/*
function function_468b927()
{
	if(!self HasWeapon(level.w_controllable_spider))
	{
		self thread zm_placeable_mine::setup_for_player(level.w_controllable_spider, "hudItems.showDpadRight_Spider");
		self giveMaxAmmo(level.w_controllable_spider);
		level thread function_160ff11f();
	}
}

function function_160ff11f()
{
	if(!level flag::get("controllable_spider_equipped"))
	{
		level flag::set("controllable_spider_equipped");
		level.zone_occupied_func = &function_84313596;
		level.closest_player_targets_override = &closest_player_targets_override;
		level.get_closest_valid_player_override = &closest_player_targets_override;
	}
}
*/

// function_b2a01f79
function controllable_spider_on_player_spawned()
{
	self endon("disconnect");
	var_97cffdb4 = "zone_bunker_interior_elevator";
	var_be85f81a = "zone_bunker_prison_entrance";
	while(1)
	{
		self waittill("weapon_change", w_current, w_previous);
		if(w_current === level.w_controllable_spider)
		{
			if(!IsPointOnNavMesh(self.origin) || (isdefined(self.var_b0329be9) && self.var_b0329be9) || !self IsOnGround())
			{
				self SwitchToWeaponImmediate(w_previous);
				wait(0.05);
			}
			else if(var_97cffdb4 === self zm_utility::get_current_zone() || (var_be85f81a === self zm_utility::get_current_zone() && level flag::get("elevator_in_use")))
			{
				self SwitchToWeaponImmediate(w_previous);
				wait(0.05);
			}
			else
			{
				n_ammo = self getammocount(level.w_controllable_spider);
				if(n_ammo <= 0)
				{
					continue;
				}
				n_ammo--;
				self SetWeaponAmmoClip(level.w_controllable_spider, n_ammo);
				self thread control_spider_start(w_previous);
				self waittill("hash_6181e737");
			}
		}
	}
}

// function_40296c9b
function control_spider_start(w_previous)
{
	self notify("hash_a1fe358c");
	e_cocoon = util::spawn_model("p7_zm_isl_cocoon_standing", self.origin, self.angles);
	e_cocoon clientfield::set("player_cocooned_fx", 1);
	self.e_cocoon = e_cocoon;
	e_spawner = GetEnt("friendly_spider_spawner", "targetname");
	ai = zombie_utility::spawn_zombie(e_spawner);
	ai.origin = self.origin;
	ai.angles = self.angles;
	ai.am_i_valid = 1;
	ai thread player::last_valid_position();
	ai thread function_5ce6002e(self, w_previous);
	ai thread function_4e8bb77d();
	ai thread function_cb196021();
	ai usevehicle(self, 0);
	self FreezeControls(1);
	self LUI::screen_fade_out(0.25);
	self.player_spider = ai;
	self.old_origin = self.origin;
	self.old_angles = self.angles;
	self LUI::screen_fade_in(0.25);
	self Hide();
	self notsolid();
	self SetPlayerCollision(0);
	self EnableInvulnerability();
	self FreezeControls(0);
	self thread function_a21f0b74();
	self thread zm_equipment::show_hint_text(&"ZM_ISLAND_SPIDER_SELF_DESTRUCT", 4);
	self.dontspeak = 1;
	self clientfield::set_to_player("isspeaking", 1);
}

// function_5ce6002e
function function_5ce6002e(e_player, w_previous)
{
	e_player endon("disconnect");
	self waittill("death");
	e_cocoon = e_player.e_cocoon;
	e_player FreezeControls(1);
	e_player.ignoreme = 1;
	wait(1);
	e_player LUI::screen_fade_out(0.25);
	self notify("stop_last_valid_position");
	self notify("exit_vehicle");
	e_player clientfield::set("player_cocooned_fx", 1);
	e_cocoon Hide();
	e_player LUI::screen_fade_in(0.25);
	e_player thread function_5a1c08d0();
	v_nav_origin = GetClosestPointOnNavMesh(e_player.old_origin, 1000, 15);
	e_player.player_spider = undefined;
	e_player FreezeControls(0);
	e_player Unlink();
	e_player show();
	e_player solid();
	e_player SetPlayerCollision(1);
	e_player DisableInvulnerability();
	e_player SetOrigin(v_nav_origin);
	e_player.angles = e_player.old_angles;
	e_player SwitchToWeaponImmediate(w_previous);
	e_player.ignoreme = 0;
	while(1)
	{
		e_player waittill("weapon_change", w_current);
		if(w_current == w_previous)
		{
			break;
		}
	}
	e_player waittill("weapon_change_complete");
	e_player notify("hash_6181e737");
	e_player.dontspeak = 0;
	e_player clientfield::set_to_player("isspeaking", 0);
}

function function_5a1c08d0()
{
	e_cocoon = self.e_cocoon;
	wait(1);
	e_cocoon delete();
}

function function_4e8bb77d()
{
	self endon("death");
	wait(60);
	self DoDamage(self.health + 1000, self.origin);
}

function function_cb196021()
{
	self endon("death");
	if(level.round_number <= 30)
	{
		self.health = 200 * level.round_number;
	}
	else
	{
		self.health = 6000;
	}
}

function function_a21f0b74()
{
	self.player_spider endon("death");
	self endon("disconnect");
	while(1)
	{
		if(self util::use_button_held())
		{
			self.player_spider SetTeam("axis");
			self.player_spider.takedamage = 1;
			self.player_spider.owner = undefined;
			self.player_spider DoDamage(self.player_spider.health + 1000, self.player_spider.origin);
			return;
		}
		wait(0.05);
	}
}

function function_e889b7()
{
	self endon("disconnect");
	level waittill("between_round_over");
	n_ammo = self getammocount(level.w_controllable_spider);
	if(n_ammo <= 0)
	{
		n_ammo++;
		self SetWeaponAmmoClip(level.w_controllable_spider, n_ammo);
	}
}

function function_84313596(zone_name)
{
	if(!zm_zonemgr::zone_is_enabled(zone_name))
	{
		return 0;
	}
	zone = level.zones[zone_name];
	for(i = 0; i < zone.Volumes.size; i++)
	{
		players = GetPlayers();
		for(j = 0; j < players.size; j++)
		{
			if(isdefined(players[j].player_spider))
			{
				if(players[j].player_spider istouching(zone.Volumes[i]) && !players[j].player_spider.sessionstate === "spectator")
				{
					return 1;
				}
				continue;
			}
			if(players[j] istouching(zone.Volumes[i]) && !players[j].sessionstate == "spectator")
			{
				return 1;
			}
		}
	}
	return 0;
}

function closest_player_targets_override()
{
	a_targets = GetPlayers();
	for(i = 0; i < a_targets.size; i++)
	{
		if(isdefined(a_targets[i].player_spider))
		{
			a_targets[i] = a_targets[i].player_spider;
		}
	}
	return a_targets;
}

/*
function function_be10e0f1()
{
	/#
		zm_devgui::function_4acecab5(&function_11949f35);
		AddDebugCommand("Dev Block strings are not supported");
	#/
}
*/