#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_beacon.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", BEACON_MODEL );

#precache( "xanim", BEACON_DEPLOY );
#precache( "xanim", BEACON_SPIN );

#precache( "fx", BEACON_GLOW_FX );
#precache( "fx", BEACON_ARTILLERY_TRAIL_FX );
#precache( "fx", BEACON_ARTILLERY_EXPLODE_FX );

#using_animtree( BEACON_ANIMTREE );

#namespace hb21_zm_weap_beacon; 

REGISTER_SYSTEM( "hb21_zm_weap_beacon", &__init__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{	
	clientfield::register( "scriptmover", "play_beacon_fx", 21000, 1, "int" );
	clientfield::register( "scriptmover", "play_artillery_barrage", 21000, 2, "int" );
	
	level.beacons = [];
	zm_utility::register_tactical_grenade_for_level( BEACON_WEAPONFILE );
	callback::on_spawned( &on_player_spawned );
}

function on_player_spawned()
{
	self thread player_handle_beacon();
}

function player_handle_beacon()
{
	self notify( "starting_beacon_watch" );
	self endon( "disconnect" );
	self endon( "starting_beacon_watch" );
	
	attract_dist_diff = level.beacon_attract_dist_diff;
	if ( !isDefined( attract_dist_diff ) )
		attract_dist_diff = 45;
	
	num_attractors = level.num_beacon_attractors;
	if ( !isDefined( num_attractors ) )
		num_attractors = 96;
	
	max_attract_dist = level.beacon_attract_dist;
	if ( !isDefined( max_attract_dist ) )
		max_attract_dist = 1536;
	
	while ( 1 )
	{
		grenade = get_thrown_beacon();
		self thread player_throw_beacon( grenade, num_attractors, max_attract_dist, attract_dist_diff );
		wait .05;
	}
}

function clone_player_angles(owner)
{
	self endon("death");
	owner endon("bled_out");
	while(isdefined(self))
	{
		self.angles = owner.angles;
		wait(0.05);
	}
}

function show_briefly(showtime)
{
	self endon("show_owner");
	if(isdefined(self.show_for_time))
	{
		self.show_for_time = showtime;
		return;
	}
	self.show_for_time = showtime;
	self SetVisibleToAll();
	while(self.show_for_time > 0)
	{
		self.show_for_time = self.show_for_time - 0.05;
		wait(0.05);
	}
	self SetVisibleToAllExceptTeam(level.zombie_team);
	self.show_for_time = undefined;
}

function show_owner_on_attack(owner)
{
	owner endon("hide_owner");
	owner endon("show_owner");
	self endon("explode");
	self endon("death");
	self endon("grenade_dud");
	owner.show_for_time = undefined;
	for(;;)
	{
		owner waittill("weapon_fired");
		owner thread show_briefly(0.5);
	}
}

function hide_owner(owner)
{
	self notify("hide_owner");
	owner notify("hide_owner");
	owner endon("hide_owner");
	owner setPerk("specialty_immunemms");
	owner.no_burning_sfx = 1;
	owner notify("stop_flame_sounds");
	owner SetVisibleToAllExceptTeam(level.zombie_team);
	owner.hide_owner = 1;
	if(isdefined(level._effect["human_disappears"]))
	{
		playFX(level._effect["human_disappears"], owner.origin);
	}
	self thread show_owner_on_attack(owner);
	evt = self util::waittill_any_return("explode", "death", "grenade_dud", "hide_owner");
	/#
		println("Dev Block strings are not supported" + evt);
	#/
	owner notify("show_owner");
	owner unsetPerk("specialty_immunemms");
	if(isdefined(level._effect["human_disappears"]))
	{
		playFX(level._effect["human_disappears"], owner.origin);
	}
	owner.no_burning_sfx = undefined;
	owner SetVisibleToAll();
	owner.hide_owner = undefined;
	owner show();
}


function player_throw_beacon( grenade, num_attractors, max_attract_dist, attract_dist_diff )
{
	self endon( "disconnect" );
	self endon( "starting_beacon_watch" );
	if ( isDefined( grenade ) )
	{
		grenade endon( "death" );
		if ( self laststand::player_is_in_laststand() )
		{
			if ( isDefined( grenade.damagearea ) )
				grenade.damagearea delete();
			
			grenade delete();
			return;
		}
		var_65f5946c = vectorScale( ( 0, 0, 1 ), 8 );
		grenade ghost();
		model = spawn("script_model", grenade.origin + var_65f5946c);
		model endon( "weapon_beacon_timeout" );
		model setModel( BEACON_MODEL );
		model useAnimTree( #animtree );
		model linkTo( grenade );
		model.angles = grenade.angles;
		model.owner = self;
		clone = undefined;
		if ( IS_TRUE( level.beacon_dual_view ) )
		{
			model setVisibleToAllExceptTeam( level.zombie_team );
			clone = zm_clone::spawn_player_clone( self, vectorScale( ( 0, 0, -1 ), 999 ), level.beacon_clone_weapon, undefined );
			model.simulacrum = clone;
			clone zm_clone::clone_animate("idle");
			clone thread clone_player_angles(self);
			clone notsolid();
			clone ghost();
		}
		grenade thread watch_for_dud( model );
		info = spawnstruct();
		info.sound_attractors = [];
		grenade waittill( "stationary" );
		if ( isDefined( level.grenade_planted ) )
		{
			self thread [ [ level.grenade_planted ] ]( grenade, model );
		}
		if ( isDefined( grenade ) )
		{
			if ( isDefined( model ) )
			{
				if ( !IS_TRUE( grenade.backlinked ) )
				{
					model unlink();
					model.origin = grenade.origin + var_65f5946c;
					model.angles = grenade.angles;
				}
			}
			if ( isDefined( clone ) )
			{
				clone forceTeleport( grenade.origin, grenade.angles );
				clone thread hide_owner( self );
				grenade thread proximity_detonate( self );
				clone show();
				clone setInvisibleToAll();
				clone setVisibleToTeam( level.zombie_team );
			}
			grenade resetMissileDetonationTime();
			model clientfield::set( "play_beacon_fx", 1 );
			valid_poi = zm_utility::check_point_in_enabled_zone( grenade.origin, undefined, undefined );
			if ( isDefined( level.check_valid_poi ) )
				valid_poi = grenade [ [ level.check_valid_poi ] ]( valid_poi );
			
			if ( valid_poi )
			{
				grenade zm_utility::create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
				grenade.attract_to_origin = 1;
				grenade thread zm_utility::create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
				grenade thread zm_utility::wait_for_attractor_positions_complete();
				grenade thread do_beacon_sound( model, info );
				model thread wait_and_explode( grenade );
				model thread weapon_beacon_anims();
				model.time_thrown = getTime();
				while ( IS_TRUE( level.weapon_beacon_busy ) )
				{
					wait .1;
					continue;
				}
				// if(level flag::get("three_robot_round") && level flag::get("fire_link_enabled"))
				// {
				// 	model thread start_artillery_launch_ee(grenade);
				// }
				// else
				// {
					model thread start_artillery_launch_normal( grenade );
				// }
				level.beacons[ level.beacons.size ] = grenade;
			}
			else
			{
				grenade.script_noteworthy = undefined;
				level thread grenade_stolen_by_sam(grenade, model, clone);
			}
		}
		else
		{
			grenade.script_noteworthy = undefined;
			level thread grenade_stolen_by_sam(grenade, model, clone);
		}
		/*
		grenade waittill_not_moving();
		if ( isDefined( level.grenade_planted ) )
			self thread [[ level.grenade_planted ]]( grenade, model );
		
		if ( isDefined( grenade ) )
		{
			if ( isDefined( model ) )
			{
				if ( isDefined( grenade.backlinked ) && !grenade.backlinked )
				{
					model unlink();
					model.origin = grenade.origin;
					model.angles = grenade.angles;
				}
				model unlink();
				
				
				model.animname = "beacon";
				model.origin = grenade.origin;
				model.angles = ( 0, 0, 0 );
				model thread weapon_beacon_anims();
			}
			grenade resetMissileDetonationTime();
			valid_poi = zm_utility::is_point_inside_enabled_zone( grenade.origin );
			if ( isDefined( level.check_valid_poi ) )
				valid_poi = grenade[[ level.check_valid_poi ]]( valid_poi );
			
			if ( valid_poi )
			{
				grenade zm_utility::create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
				grenade.attract_to_origin = 1;
				grenade thread zm_utility::create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
				grenade thread zm_utility::wait_for_attractor_positions_complete();
				model thread wait_and_explode( grenade );
				model.time_thrown = getTime();
				model clientfield::set( "play_beacon_fx", 1 );
				// playFxOnTag( BEACON_GLOW_FX, model, "tag_fx" );
				playSoundAtPosition( "wpn_beacon_alarm", grenade.origin );
				grenade.e_model = model;
				grenade playLoopSound( "wpn_beacon_beep" );
				model thread start_artillery_launch_normal( grenade );
				level.beacons[ level.beacons.size ] = grenade;
			}
			else
			{
				grenade.script_noteworthy = undefined;
				level thread grenade_stolen_by_sam( grenade, model );
			}
			return;
		}
		else
		{
			grenade.script_noteworthy = undefined;
			level thread grenade_stolen_by_sam( grenade, model );
		}
		*/
	}
}

function play_delayed_explode_vox()
{
	wait(6.5);
}

/*
	Name: do_beacon_sound
	Namespace: _zm_weap_beacon
	Checksum: 0x185EBF16
	Offset: 0x1C10
	Size: 0x233
	Parameters: 2
	Flags: None
*/
function do_beacon_sound(model, info)
{
	self.monk_scream_vox = 0;
	if(isdefined(level.grenade_safe_to_bounce))
	{
		if(![[level.grenade_safe_to_bounce]](self.owner, level.var_25ef5fab))
		{
			self.monk_scream_vox = 1;
		}
	}
	if(!self.monk_scream_vox && !(isdefined(level.music_override) && level.music_override))
	{
		if(isdefined(level.beacon_dual_view) && level.beacon_dual_view)
		{
			self playsoundtoteam("null", "allies");
		}
		else
		{
			self playsound("null");
		}
	}
	if(!self.monk_scream_vox)
	{
		self thread play_delayed_explode_vox();
	}
	self waittill("robot_artillery_barrage", position);
	level notify("grenade_exploded", position, 100, 5000, 450);
	beacon_index = -1;
	for(i = 0; i < level.beacons.size; i++)
	{
		if(!isdefined(level.beacons[i]))
		{
			beacon_index = i;
			break;
		}
	}
	if(beacon_index >= 0)
	{
		ArrayRemoveIndex(level.beacons, beacon_index);
	}
	for(i = 0; i < info.sound_attractors.size; i++)
	{
		if(isdefined(info.sound_attractors[i]))
		{
			info.sound_attractors[i] notify("beacon_blown_up");
		}
	}
	self delete();
}

function proximity_detonate(owner)
{
	wait(1.5);
	if(!isdefined(self))
	{
		return;
	}
	detonateRadius = 96;
	explosionRadius = detonateRadius * 2;
	damagearea = spawn("trigger_radius", self.origin + (0, 0, 0 - detonateRadius), 4, detonateRadius, detonateRadius * 1.5);
	damagearea SetExcludeTeamForTrigger(owner.team);
	damagearea EnableLinkTo();
	damagearea LinkTo(self);
	self.damagearea = damagearea;
	while(isdefined(self))
	{
		damagearea waittill("trigger", ent);
		if(isdefined(owner) && ent == owner)
		{
			continue;
		}
		if(isdefined(ent.team) && ent.team == owner.team)
		{
			continue;
		}
		self playsound("wpn_claymore_alert");
		dist = Distance(self.origin, ent.origin);
		RadiusDamage(self.origin + VectorScale((0, 0, 1), 12), explosionRadius, 1, 1, owner, "MOD_GRENADE_SPLASH", level.var_25ef5fab);
		if(isdefined(owner))
		{
			self detonate(owner);
		}
		else
		{
			self detonate(undefined);
		}
		break;
	}
	if(isdefined(damagearea))
	{
		damagearea delete();
	}
}

function get_thrown_beacon()
{
	self endon( "disconnect" );
	self endon( "starting_beacon_watch" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapon );
		if ( weapon.name == BEACON_WEAPONFILE )
		{
			grenade.use_grenade_special_long_bookmark = 1;
			grenade.grenade_multiattack_bookmark_count = 1;
			return grenade;
		}
		wait .05;
	}
}

function weapon_beacon_anims()
{
	self animScripted( BEACON_DEPLOY, self.origin , self.angles, BEACON_DEPLOY );
	wait getAnimLength( BEACON_DEPLOY );
	self animScripted( BEACON_SPIN, self.origin , self.angles, BEACON_SPIN );
}

function wait_and_explode(grenade)
{
	self endon("beacon_missile_launch");
	grenade waittill("explode", position);
	self notify("weapon_beacon_timeout");
	if(isdefined(grenade))
	{
		grenade notify("robot_artillery_barrage", self.origin);
	}
}

function start_artillery_launch_normal( grenade )
{
	self endon( "weapon_beacon_timeout" );
	// sp_giant_robot = undefined;
	// if ( !isDefined( sp_giant_robot ) )
	// {
	// 	i = 0;
	// 	while ( i < 3 )
	// 	{
	// 		if ( isDefined( level.a_giant_robots[ i ].is_walking ) && level.a_giant_robots[ i ].is_walking )
	// 		{
	// 			if ( isDefined( level.a_giant_robots[ i ].weap_beacon_firing ) && !level.a_giant_robots[ i ].weap_beacon_firing )
	// 			{
					// sp_giant_robot = level.a_giant_robots[ i ];
					// self thread artillery_fx_logic( sp_giant_robot, grenade );
					self thread artillery_fx_logic( undefined, grenade );
					self notify( "beacon_missile_launch" );
					level.weapon_beacon_busy = 1;
					grenade.fuse_reset = 1;
					grenade.fuse_time = 100;
					grenade resetMissileDetonationTime( 100 );
	// 				break;
	// 			}
	// 		}
	// 		else
	// 			i++;
	// 		
	// 	}
	// 	wait .1;
	// }
}

function artillery_fx_logic( sp_giant_robot, grenade )
{
	// sp_giant_robot.weap_beacon_firing = 1;
	// level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 1 );
	// self thread homing_beacon_vo();
	wait .5;
	// if ( isDefined( sp_giant_robot ) )
	// {
	// 	level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 0 );
		wait 3;
		self thread artillery_barrage_logic( grenade );
		wait 1;
	// 	sp_giant_robot.weap_beacon_firing = 0;
	// }
}

function artillery_barrage_logic( grenade, b_ee )
{
	if ( !isDefined( b_ee ) )
		b_ee = 0;
	
	if ( isDefined( b_ee ) && b_ee )
	{
		// a_v_land_offsets = self build_weap_beacon_landing_offsets_ee();
		// a_v_start_offsets = self build_weap_beacon_start_offsets_ee();
		// n_num_missiles = 15;
		// n_clientfield = 2;
	}
	else
	{
		a_v_land_offsets = self build_weap_beacon_landing_offsets();
		a_v_start_offsets = self build_weap_beacon_start_offsets();
		n_num_missiles = 5;
		n_clientfield = 1;
	}
	self.a_v_land_spots = [];
	self.a_v_start_spots = [];
	i = 0;
	while ( i < n_num_missiles )
	{
		self.a_v_start_spots[ i ] = self.origin + a_v_start_offsets[ i ];
		self.a_v_land_spots[ i ] = self.origin + a_v_land_offsets[ i ];
		v_start_trace = self.a_v_start_spots[ i ] - vectorScale( ( 0, 0, 1 ), 5000 );
		trace = bullettrace( v_start_trace, self.a_v_land_spots[ i ], 0, undefined );
		self.a_v_land_spots[ i ] = trace[ "position" ];
		wait .05;
		i++;
	}
	i = 0;
	while ( i < n_num_missiles )
	{
		self clientfield::set( "play_artillery_barrage", n_clientfield );
		self thread wait_and_do_weapon_beacon_damage( i );
		util::wait_network_frame();
		self clientfield::set( "play_artillery_barrage", 0 );
		
		if ( i == 0 )
		{
			wait 1;
			i++;
			continue;
		}
		else
			wait .25;
		
		i++;
	}
	level thread allow_beacons_to_be_targeted_by_giant_robot();
	wait 6;
	grenade notify( "robot_artillery_barrage", self.origin );
}

function allow_beacons_to_be_targeted_by_giant_robot()
{
	wait(3);
	level.weapon_beacon_busy = 0;
}

function delay_delete()
{
	self endon( "death" );
	wait 1;
	self delete();
}

function wait_and_do_weapon_beacon_damage( index )
{
	model = spawn( "script_model", self.a_v_start_spots[ index ] );
	model setModel( "tag_origin" );
	model moveTo( self.a_v_land_spots[ index ], 3 );
	// playFxOnTag( BEACON_ARTILLERY_TRAIL_FX, model, "tag_origin" );
		
	wait 3;
	
	model thread delay_delete();
	
	// playFx( BEACON_ARTILLERY_EXPLODE_FX, self.a_v_land_spots[ index ] );
	// playSoundAtPosition( "wpn_beacon_explode", self.a_v_land_spots[ index ] );
	
	v_damage_origin = self.a_v_land_spots[ index ];
	level.n_weap_beacon_zombie_thrown_count = 0;
	a_zombies_to_kill = [];
	a_zombies = getAiSpeciesArray( "axis", "all" );
	_a969 = a_zombies;
	_k969 = getFirstArrayKey( _a969 );
	while ( isDefined( _k969 ) )
	{
		zombie = _a969[ _k969 ];
		n_distance = distance( zombie.origin, v_damage_origin );
		if ( n_distance <= 200 )
		{
			n_damage = math::linear_map( n_distance, 200, 0, 7000, 8000 );
			if ( n_damage >= zombie.health )
			{
				a_zombies_to_kill[ a_zombies_to_kill.size ] = zombie;
				break;
			}
			else
			{
				zombie doDamage( n_damage, zombie.origin, self.owner, undefined, 0, "MOD_GRENADE_SPLASH", 0, getWeapon( BEACON_WEAPONFILE ) );
			}
		}
		_k969 = getNextArrayKey( _a969, _k969 );
	}
	if ( index == 0 )
	{
		RadiusDamage( self.origin + ( 0, 0, 12 ), 192, 20, 20, self.owner, "MOD_GRENADE_SPLASH", getWeapon( BEACON_WEAPONFILE ) );
		// radiusDamage( self.origin + vectorScale( ( 0, 0, 1 ), 12 ), 10, 1, 1, self.owner, "MOD_GRENADE_SPLASH", getWeapon( BEACON_WEAPONFILE ) );
		self ghost();
		self stopAnimScripted( 0 );
	}
	level thread weap_beacon_zombie_death( self, a_zombies_to_kill );
	self thread weap_beacon_rumble();
}

function weap_beacon_zombie_death( model, a_zombies_to_kill )
{
	n_interval = 0;
	i = 0;
	while ( i < a_zombies_to_kill.size )
	{
		zombie = a_zombies_to_kill[ i ];
		if ( !isDefined( zombie ) || !isalive( zombie ) )
		{
			i++;
			continue;
		}
		else
		{
			zombie doDamage( zombie.health, zombie.origin, model.owner, model.owner, 0, "MOD_GRENADE_SPLASH", 0, getWeapon( BEACON_WEAPONFILE ) );
			n_interval++;
			zombie thread weapon_beacon_launch_ragdoll();
			if ( n_interval >= 4 )
			{
				util::wait_network_frame();
				n_interval = 0;
			}
		}
		i++;
	}
}

function weapon_beacon_launch_ragdoll()
{
	if ( isDefined( self.is_mechz ) && self.is_mechz )
	{
		return;
	}
	if ( isDefined( self.is_giant_robot ) && self.is_giant_robot )
	{
		return;
	}
	if ( level.n_weap_beacon_zombie_thrown_count >= 5 )
	{
		return;
	}
	level.n_weap_beacon_zombie_thrown_count++;
	if ( isDefined( level.ragdoll_limit_check ) && !( [[ level.ragdoll_limit_check ]]() ) )
	{
		level thread weap_beacon_gib( self );
		return;
	}
	self startragdoll();
	n_x = randomintrange( 50, 150 );
	n_y = randomintrange( 50, 150 );
	if ( math::cointoss() )
		n_x *= -1;
	
	if ( math::cointoss() )
		n_y *= -1;
	
	v_launch = ( n_x, n_y, randomIntRange( 75, 250 ) );
	self launchragdoll( v_launch );
}

function weap_beacon_gib( ai_zombie )
{
	a_gib_ref = [];
	a_gib_ref[ 0 ] = level._zombie_gib_piece_index_all;
	ai_zombie gib( "normal", a_gib_ref );
}

function weap_beacon_rumble()
{
	a_players = getplayers();
	_a1087 = a_players;
	_k1087 = getFirstArrayKey( _a1087 );
	while ( isDefined( _k1087 ) )
	{
		player = _a1087[ _k1087 ];
		if ( isAlive( player ) && isDefined( player ) )
		{
			if ( distance2dSquared( player.origin, self.origin ) < 250000 )
				player shellShock( "explosion", 2.5 );
			
		}
		_k1087 = getNextArrayKey( _a1087, _k1087 );
	}
}

function build_weap_beacon_landing_offsets()
{
	a_offsets = [];
	a_offsets[ 0 ] = ( 0, 0, 1 );
	a_offsets[1] = VectorScale((-1, 1, 0), 72);
	a_offsets[2] = VectorScale((1, 1, 0), 72);
	a_offsets[3] = VectorScale((1, -1, 0), 72);
	a_offsets[4] = VectorScale((-1, -1, 0), 72);
	return a_offsets;
}

function build_weap_beacon_start_offsets()
{
	a_offsets = [];
	a_offsets[ 0 ] = vectorScale( ( 0, 0, 1 ), 8500 );
	a_offsets[ 1 ] = ( -6500, 6500, 8500 );
	a_offsets[ 2 ] = ( 6500, 6500, 8500 );
	a_offsets[ 3 ] = ( 6500, -6500, 8500 );
	a_offsets[ 4 ] = ( -6500, -6500, 8500 );
	return a_offsets;
}

function waittill_not_moving()
{
	self endon( "death" );
	
	prev_origin = self.origin;
	while( isDefined( self ) )
	{
		wait .05;
		if ( prev_origin == self.origin )
			break;
		
		prev_origin = self.origin;
	}
}

function beacon_cleanup( parent )
{
	while ( isDefined( self ) )
	{
		if ( !isDefined( parent ) )
		{
			if ( isDefined( self ) && isDefined( self.dud ) && self.dud )
				wait 6;
			
			if ( isDefined( self.simulacrum ) )
				self.simulacrum delete();
			
			self delete();
			return;
		}
		wait .05;
	}
}

function watch_for_dud( model, actor )
{
	self endon( "death" );
	self waittill( "grenade_dud" );
	model.dud = 1;
	self.monk_scream_vox = 1;
	wait 3;
	if ( isDefined( model ) )
		model delete();
	
	if ( isDefined( actor ) )
		actor delete();
	
	if ( isDefined( self.damagearea ) )
		self.damagearea delete();
	
	if ( isDefined( self.e_model ) )
		self.e_model delete();
	if ( isDefined( self ) )
		self delete();
	
}

function grenade_stolen_by_sam( ent_grenade, ent_model, ent_actor )
{
	if ( !isDefined( ent_model ) )
		return;
	
	direction = ent_model.origin;
	direction = ( direction[ 1 ], direction[ 0 ], 0 );
	if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
	{
		direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	}
	else
	{
		if ( direction[ 0 ] < 0 )
			direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
		
	}
	players = getPlayers();
	i = 0;
	while ( i < players.size )
	{
		if ( isAlive( players[ i ] ) )
			players[ i ] playLocalSound( level.zmb_laugh_alias );
		
		i++;
	}
	playfxontag( level._effect[ "grenade_samantha_steal" ], ent_model, "tag_origin" );
	ent_model moveZ( 60, 1, 0.25, 0.25 );
	ent_model vibrate( direction, 1.5, 2.5, 1 );
	ent_model waittill( "movedone" );
	if ( isDefined( self.damagearea ) )
		self.damagearea delete();
	
	ent_model delete();
	if ( isDefined( ent_actor ) )
		ent_actor delete();
	
	if ( isDefined( ent_grenade ) )
	{
		if ( isDefined( ent_grenade.damagearea ) )
			ent_grenade.damagearea delete();
		
		if ( isDefined( ent_grenade.e_model ) )
			ent_grenade.e_model delete();
		if ( isDefined( ent_grenade ) )
			ent_grenade delete();
		
	}
}
