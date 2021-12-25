#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_napalm.gsh;

#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_forearm" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_torso" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_ground2" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_exp" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_end2" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_spawn7" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_heat" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_torso_end" );
#precache( "fx", "dlc5/temple/fx_ztem_napalm_zombie_forearm_end" );
#precache( "fx", "dlc5/temple/fx_ztem_zombie_torso_steam_runner" );

#namespace zm_ai_napalm;

REGISTER_SYSTEM_EX( "zm_ai_napalm", &__init__, &__main__, undefined )

function __init__()
{
	init_clientfields();
	registerbehaviorscriptfunctions();
}

function __main__()
{
	init_napalm_fx();
	level.napalmzombiesenabled = 1;
	level.napalmzombieminroundwait = NAPALM_ZOMBIE_MINIMUM_ROUND_WAIT;
	level.napalmzombiemaxroundwait = NAPALM_ZOMBIE_MAXIMUM_ROUND_WAIT;
	level.napalmzombieroundrequirement = NAPALM_ZOMBIE_ROUND_REQUIREMENT;
	level.nextnapalmspawnround = level.napalmzombieroundrequirement + ( randomIntRange( 0, level.napalmzombiemaxroundwait + 1 ) );
	level.napalmzombiedamageradius = NAPALM_ZOMBIE_DAMAGE_RADIUS;
	level.napalmexploderadius = NAPALM_ZOMBIE_EXPLODE_RADIUS;
	level.napalmexplodekillradiusjugs = NAPALM_ZOMBIE_KILL_RADIUS_JUGG;
	level.napalmexplodekillradius = NAPALM_ZOMBIE_KILL_RADIUS;
	level.napalmexplodedamageradius = NAPALM_ZOMBIE_EXPLODE_DAMAGE_RADIUS;
	level.napalmexplodedamageradiuswet = NAPALM_ZOMBIE_EXPLODE_DAMAGE_RADIUS_WET;
	level.napalmexplodedamagemin = NAPALM_ZOMBIE_EXPLODE_DAMAGE_MIN;
	level.napalmhealthmultiplier = NAPALM_ZOMBIE_HEALTH_MULTIPLIER;
	level.napalmlasrroundspawn = 0;
	level.napalmzombies = [];
	level.napalm_zombie_spawners = getEntArray( "napalm_zombie_spawner", "script_noteworthy" );
	level flag::init( "zombie_napalm_force_spawn" );
	array::thread_all( level.napalm_zombie_spawners, &spawner::add_spawn_function, &napalm_zombie_spawn );
	array::thread_all( level.napalm_zombie_spawners, &spawner::add_spawn_function, &zombie_utility::round_spawn_failsafe );
	_napalm_initsounds();
	zm_spawner::register_zombie_damage_callback( &_napalm_damage_callback );
	level thread napalm_zombie_spawning();
	level.zombie_total_set_func = &napalm_zombie_spawning_delay_setup;
}

function napalm_zombie_spawning_delay_setup()
{
	level.zombiesLeftBeforeNapalmSpawn = randomIntRange( int( level.zombie_total * .25 ), int( level.zombie_total * .75 ) );
	level.zombiesLeftBeforeSonicSpawn = randomIntRange( int( level.zombie_total * .25 ), int( level.zombie_total * .75 ) );
}

function registerbehaviorscriptfunctions()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi( "napalmExplodeInitialize", &napalmexplodeinitialize );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "napalmExplodeTerminate", &napalmexplodeterminate );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "napalmCanExplode", &napalmcanexplode );
}

function get_napalm_spawners()
{
	return level.napalm_zombie_spawners;
}

function get_napalm_locations()
{
	return level.zm_loc_types[ "napalm_location" ];
}

function can_spawn_napalm_zombie()
{
	forcespawn = level flag::get( "zombie_napalm_force_spawn" );
	if ( !isDefined( level.napalmzombiesenabled ) || level.napalmzombiesenabled == 0 || level.napalm_zombie_spawners.size == 0 || level.zm_loc_types[ "napalm_location" ].size == 0 )
		return 0;
	
	if ( isDefined( level.napalmzombiecount ) && level.napalmzombiecount > 0 )
		return 0;
	
	if ( level.napalmlasrroundspawn >= level.round_number )
		return 0;
	
	if ( forcespawn )
		return 1;
	
	if ( level.nextnapalmspawnround > level.round_number )
		return 0;
	
	if ( level.zombie_total == 0 )
		return 0;
	
	return level.zombie_total < level.zombiesleftbeforenapalmspawn;
}

function napalm_zombie_spawning()
{
	level waittill( "start_of_round" );
	while ( 1 )
	{
		if ( can_spawn_napalm_zombie() )
		{
			spawner_list = get_napalm_spawners();
			location_list = get_napalm_locations();
			spawner = array::random( spawner_list );
			location = array::random( location_list );
			ai = zombie_utility::spawn_zombie( spawner, spawner.targetname, location );
			if ( isDefined( ai ) )
				ai.spawn_point_override = location;
			
		}
		wait 3;
	}
}

function napalm_zombie_do_spawn_rise()
{
	self endon( "death" );
	spot = self.spawn_point_override;
	self.spawn_point = spot;
	if ( isDefined( spot.target ) )
		self.target = spot.target;
	
	if ( isDefined( spot.zone_name ) )
		self.zone_name = spot.zone_name;
	
	if ( isDefined( spot.script_parameters ) )
		self.script_parameters = spot.script_parameters;
	
	self thread zm_spawner::do_zombie_rise( spot );
	playFx( level._effect[ "napalm_spawn" ], spot.origin, anglesToUp( spot.angles ), anglesToUp( spot.angles ) );
	thread napalm_zombie_do_player_vo();
}

function napalm_zombie_do_player_vo()
{
	wait 2;
	players = getPlayers();
	players[ randomIntRange( 0, players.size ) ] thread zm_audio::create_and_play_dialog( "general", "napalm_spawn" );
}

function _napalm_initsounds()
{
	level.zmb_vox[ "napalm_zombie" ] = [];
	level.zmb_vox[ "napalm_zombie" ][ "ambient" ] = "napalm_ambient";
	level.zmb_vox[ "napalm_zombie" ][ "sprint" ] = "napalm_ambient";
	level.zmb_vox[ "napalm_zombie" ][ "attack" ] = "napalm_attack";
	level.zmb_vox[ "napalm_zombie" ][ "teardown" ] = "napalm_attack";
	level.zmb_vox[ "napalm_zombie" ][ "taunt" ] = "napalm_ambient";
	level.zmb_vox[ "napalm_zombie" ][ "behind" ] = "napalm_ambient";
	level.zmb_vox[ "napalm_zombie" ][ "death" ] = "napalm_explode";
	level.zmb_vox[ "napalm_zombie" ][ "crawler" ] = "napalm_ambient";
}

function _entity_in_zone( zone )
{
	for ( i = 0; i < zone.volumes.size; i++ )
	{
		if ( self isTouching( zone.volumes[ i ] ) )
			return 1;
		
	}
	return 0;
}

function init_napalm_fx()
{
	level._effect[ "napalm_fire_forearm" ] = "dlc5/temple/fx_ztem_napalm_zombie_forearm";
	level._effect[ "napalm_fire_torso" ] = "dlc5/temple/fx_ztem_napalm_zombie_torso";
	level._effect[ "napalm_fire_ground" ] = "dlc5/temple/fx_ztem_napalm_zombie_ground2";
	level._effect[ "napalm_explosion" ] = "dlc5/temple/fx_ztem_napalm_zombie_exp";
	level._effect[ "napalm_fire_trigger" ] = "dlc5/temple/fx_ztem_napalm_zombie_end2";
	level._effect[ "napalm_spawn" ] = "dlc5/temple/fx_ztem_napalm_zombie_spawn7";
	level._effect[ "napalm_distortion" ] = "dlc5/temple/fx_ztem_napalm_zombie_heat";
	level._effect[ "napalm_fire_forearm_end" ] = "dlc5/temple/fx_ztem_napalm_zombie_torso_end";
	level._effect[ "napalm_fire_torso_end" ] = "dlc5/temple/fx_ztem_napalm_zombie_forearm_end";
	level._effect[ "napalm_steam" ] = "dlc5/temple/fx_ztem_zombie_torso_steam_runner";
	level._effect[ "napalm_feet_steam" ] = "dlc5/temple/fx_ztem_zombie_torso_steam_runner";
}

function napalm_zombie_spawn( animname_set )
{
	self.custom_location = &napalm_zombie_do_spawn_rise;
	zm_spawner::zombie_spawn_init( animname_set );
	
	level.napalmlasrroundspawn = level.round_number;
	self.animname = "napalm_zombie";
	self thread napalm_zombie_client_flag();
	self.napalm_zombie_glowing = 0;
	self.maxhealth = self.maxhealth * ( getPlayers().size * level.napalmhealthmultiplier );
	self.health = self.maxhealth;
	self.no_gib = 1;
	self.rising = 1;
	self.no_damage_points = 1;
	self.explosive_volume = 0;
	self.ignore_enemy_count = 1;
	self.deathfunction = &napalm_zombie_death;
	self.actor_full_damage_func = &_napalm_zombie_damage;
	self.nuke_damage_func = &_napalm_nuke_damage;
	self.instakill_func = undefined;
	self._zombie_shrink_callback = &_napalm_shrink;
	self._zombie_unshrink_callback = &_napalm_unshrink;
	self.water_trigger_func = &napalm_enter_water_trigger;
	self.custom_damage_func = &napalm_custom_damage;
	self.monkey_bolt_taunts = &napalm_monkey_bolt_taunts;
	self.canexplodetime = getTime() + NAPALM_ZOMBIE_TIME_BEFORE_EXPLODE_POSSIBLE;
	self thread _zombie_watchstopeffects();
	self thread napalm_watch_for_sliding();
	self thread napalm_zombie_count_watch();
	self.zombie_move_speed = "walk";
	self.zombie_arms_position = "up";
	self.variant_type = randomInt( 3 );
	self playSound( "evt_napalm_zombie_spawn" );
}

function napalm_zombie_client_flag()
{
	self clientfield::set("isnapalm", 1);
	self waittill("death");
	self clientfield::set("isnapalm", 0);
	napalm_clear_radius_fx_all_players();
}

function _napalm_nuke_damage()
{
}

function _napalm_instakill_func()
{
}

function napalm_custom_damage( player )
{
	damage = self.meleedamage;
	if ( isDefined( self.overridedeathdamage ) )
		damage = int( self.overridedeathdamage );
	
	return damage;
}

function _zombie_runexplosionwindupeffects()
{
	fx = [];
	fx[ "j_elbow_le" ] = "napalm_fire_forearm_end";
	fx[ "j_elbow_ri" ] = "napalm_fire_forearm_end";
	fx[ "j_clavicle_ri" ] = "napalm_fire_forearm_end";
	fx[ "j_clavicle_le" ] = "napalm_fire_forearm_end";
	fx[ "j_spinelower" ] = "napalm_fire_torso_end";
	offsets[ "j_spinelower" ] = vectorscale( ( 0, 1, 0 ), 10 );
	watch = [];
	keys = getArrayKeys( fx );
	for ( i = 0; i < keys.size; i++ )
	{
		jointname = keys[ i ];
		fxname = fx[ jointname ];
		offset = offsets[ jointname ];
		effectent = self _zombie_setupfxonjoint( jointname, fxname, offset );
		watch[ i ] = effectent;
	}
	self waittill( "stop_fx" );
	if ( !isDefined( self ) )
		return;
	
	for ( i = 0; i < watch.size; i++ )
		watch[ i ] delete();
	
}

function _zombie_watchstopeffects()
{
	self waittill( "death" );
	self notify( "stop_fx" );
	if ( level flag::get( "world_is_paused" ) )
		self setignorepauseworld( 1 );
	
}

function private napalmcanexplode( entity )
{
	if ( entity.animname !== "napalm_zombie" )
		return 0;
	
	if ( level.napalmexploderadius <= 0 )
		return 0;
	
	napalmexploderadiussqr = level.napalmexploderadius * level.napalmexploderadius;
	napalmplayerwarningradius = level.napalmexplodedamageradius;
	napalmplayerwarningradiussqr = napalmplayerwarningradius * napalmplayerwarningradius;
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		if ( !zombie_utility::is_player_valid( player ) )
			continue;
		
		if ( distance2dsquared( player.origin, entity.origin ) < napalmplayerwarningradiussqr )
		{
			if ( !isDefined( player.napalmradiuswarningtime ) || player.napalmradiuswarningtime <= ( getTime() - .1 ) )
			{
				player clientfield::set_to_player( "napalm_pstfx_burn", 1 );
				player playLoopSound( "chr_burning_loop", 1 );
				player.napalmradiuswarningtime = getTime() + NAPALM_ZOMBIE_WARNING_RADIUS_TIME;
			}
		}
		else if ( isDefined( player.napalmradiuswarningtime ) && player.napalmradiuswarningtime > getTime() )
		{
			player exit_napalm_radius();
			continue;
		}
		if ( !isDefined( entity.favoriteenemy ) || !isPlayer( entity.favoriteenemy ) )
			continue;
		
		if ( IS_TRUE( entity.in_the_ground ) )
			continue;
		
		if ( entity.canexplodetime > getTime() )
			continue;
		
		if ( ( abs( player.origin[ 2 ] - entity.origin[ 2 ] ) ) > 50 )
			continue;
		
		if ( distance2dSquared( player.origin, entity.origin ) > napalmexploderadiussqr )
			continue;
		
		return 1;
	}
	return 0;
}

function private napalmexplodeinitialize( entity, asmstatename )
{
	if ( level flag::get( "world_is_paused" ) )
		entity setIgnorePauseWorld( 1 );
	
	entity clientfield::set( "napalmexplode", 1 );
	entity playsound( "evt_napalm_zombie_charge" );
}

function private napalmexplodeterminate( entity, asmstatename )
{
	napalm_clear_radius_fx_all_players();
	entity.killed_self = 1;
	entity doDamage( entity.health + 666, entity.origin );
}

function napalm_zombie_death( einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime )
{
	zombies_axis = array::get_all_closest( self.origin, getAiSpeciesArray( "axis", "all" ), undefined, undefined, level.napalmzombiedamageradius );
	dogs = array::get_all_closest( self.origin, getAiSpeciesArray("allies", "zombie_dog"), undefined, undefined, level.napalmzombiedamageradius );
	zombies = arraycombine( zombies_axis, dogs, 0, 0 );
	if ( isDefined( level._effect[ "napalm_explosion" ] ) )
		playFxOnTag( level._effect[ "napalm_explosion" ], self, "j_spinelower" );
	
	self playSound( "evt_napalm_zombie_explo" );
	if ( isDefined( self.attacker ) && isPlayer( self.attacker ) )
		self.attacker thread zm_audio::create_and_play_dialog( "kill", "napalm" );
	
	level notify( "napalm_death", self.explosive_volume );
	self thread napalm_delay_delete();
	if ( !self napalm_standing_in_water( 1 ) )
		level thread napalm_fire_trigger( self, 80, 20, 0 );
	
	self thread _napalm_damage_zombies( zombies );
	napalm_clear_radius_fx_all_players();
	self _napalm_damage_players();
	if ( isDefined( self.attacker ) && isPlayer( self.attacker ) && !IS_TRUE( self.killed_self ) && !IS_TRUE( self.shrinked ) )
	{
		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[ i ];
			if ( zombie_utility::is_player_valid( player ) )
				player zm_score::player_add_points( "thundergun_fling", 300, ( 0, 0, 0 ), 0 );
			
		}
	}
	return self zm_spawner::zombie_death_animscript();
}

function napalm_delay_delete()
{
	self endon( "death" );
	self setPlayerCollision( 0 );
	self thread zombie_utility::zombie_eye_glow_stop();
	util::wait_network_frame();
	self hide();
}

function _napalm_damage_zombies( zombies )
{
	eyeorigin = self getEye();
	if ( !isDefined( zombies ) )
		return;
	
	damageorigin = self.origin;
	standinginwater = self napalm_standing_in_water();
	for ( i = 0; i < zombies.size; i++ )
	{
		if ( !isDefined( zombies[ i ] ) )
			continue;
		
		if ( zm_utility::is_magic_bullet_shield_enabled( zombies[ i ] ) )
			continue;
		
		test_origin = zombies[ i ] getEye();
		if ( !bulletTracePassed( eyeorigin, test_origin, 0, undefined ) )
			continue;
		
		if ( zombies[ i ].animname == "napalm_zombie" )
			continue;
		
		if ( !standinginwater )
			zombies[ i ] thread zombie_death::flame_death_fx();
		
		refs = [];
		refs[ refs.size ] = "guts";
		refs[ refs.size ] = "right_arm";
		refs[ refs.size ] = "left_arm";
		refs[ refs.size ] = "right_leg";
		refs[ refs.size ] = "left_leg";
		refs[ refs.size ] = "no_legs";
		refs[ refs.size ] = "head";
		if ( refs.size )
			zombies[ i ].a.gib_ref = array::random( refs );
		
		zombies[ i ] doDamage( zombies[ i ].health + 666, damageorigin );
		util::wait_network_frame();
	}
}

function _napalm_damage_players()
{
	eyeorigin = self getEye();
	footorigin = self.origin + vectorScale( ( 0, 0, 1 ), 8 );
	midorigin = ( footorigin[ 0 ], footorigin[ 1 ], ( footorigin[ 2 ] + eyeorigin[ 2 ] ) / 2 );
	players_damaged_by_explosion = 0;
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( !zombie_utility::is_player_valid( players[ i ] ) )
			continue;
		
		test_origin = players[ i ] getEye();
		damageradius = level.napalmexplodedamageradius;
		if ( IS_TRUE( self.wet ) )
			damageradius = level.napalmexplodedamageradiuswet;
		
		if ( distanceSquared( eyeorigin, test_origin ) > ( damageradius * damageradius ) )
			continue;
		
		test_origin_foot = players[ i ].origin + vectorScale( ( 0, 0, 1 ), 8 );
		test_origin_mid = ( test_origin_foot[ 0 ], test_origin_foot[ 1 ], ( test_origin_foot[ 2 ] + test_origin[ 2 ] ) / 2 );
		if ( !bulletTracePassed( eyeorigin, test_origin, 0, undefined ) )
		{
			if ( !bulletTracePassed( midorigin, test_origin_mid, 0, undefined ) )
			{
				if ( !bulletTracePassed( footorigin, test_origin_foot, 0, undefined ) )
					continue;
				
			}
		}
		players_damaged_by_explosion = 1;
		if ( isDefined( level._effect[ "player_fire_death_napalm" ] ) )
			playFxOnTag( level._effect[ "player_fire_death_napalm" ], players[ i ], "j_spinelower" );
		
		dist = distance( eyeorigin, test_origin );
		killplayerdamage = 100;
		killjusgsplayerdamage = 250;
		shellshockmintime = 1.5;
		shellshockmaxtime = 3;
		damage = level.napalmexplodedamagemin;
		shellshocktime = shellshockmaxtime;
		if ( dist < level.napalmexplodekillradiusjugs )
			damage = killjusgsplayerdamage;
		else if ( dist < level.napalmexplodekillradius )
			damage = killplayerdamage;
		else
		{
			scale = ( level.napalmexplodedamageradius - dist ) / ( level.napalmexplodedamageradius - level.napalmexplodekillradius );
			shellshocktime = ( scale * ( shellshockmaxtime - shellshockmintime ) ) + shellshockmintime;
			damage = ( scale * ( killplayerdamage - level.napalmexplodedamagemin ) ) + level.napalmexplodedamagemin;
		}
		if ( IS_TRUE( self.shrinked ) )
		{
			damage = damage * .25;
			shellshocktime = shellshocktime * .25;
		}
		if ( IS_TRUE( self.wet ) )
		{
			damage = damage * .25;
			shellshocktime = shellshocktime * .25;
		}
		self.overridedeathdamage = damage;
		players[ i ] doDamage( damage, self.origin, self );
		players[ i ] shellShock( "explosion", shellshocktime );
		players[ i ] thread zm_audio::create_and_play_dialog( "kill", "napalm" );
	}
	if ( !players_damaged_by_explosion )
		level notify( "zomb_disposal_achieved" );
	
}

function napalm_fire_trigger( ai, radius, time, spawnfire )
{
	aiisnapalm = ai.animname == "napalm_zombie";
	if ( !aiisnapalm )
		radius = radius / 2;
	
	spawnflags = 1;
	trigger = spawn( "trigger_radius", ai.origin, spawnflags, radius, 70 );
	sound_ent = undefined;
	if ( !isDefined( trigger ) )
		return;
	
	if ( aiisnapalm )
	{
		if ( spawnfire )
			trigger.napalm_fire_damage = 10;
		else
			trigger.napalm_fire_damage = 40;
		
		trigger.napalm_fire_damage_type = "burned";
		if ( !spawnfire && isDefined( level._effect[ "napalm_fire_trigger" ] ) )
		{
			sound_ent = spawn( "script_origin", ai.origin );
			sound_ent playLoopSound( "evt_napalm_fire", 1 );
			playFx( level._effect[ "napalm_fire_trigger" ], ai.origin );
		}
	}
	else
	{
		trigger.napalm_fire_damage = 10;
		trigger.napalm_fire_damage_type = "triggerhurt";
		if ( spawnfire )
			ai thread zombie_death::flame_death_fx();
		
	}
	trigger thread triggerdamage();
	wait time;
	trigger notify( "end_fire_effect" );
	trigger delete();
	if ( isDefined( sound_ent ) )
	{
		sound_ent stopLoopSound( 1 );
		wait 1;
		sound_ent delete();
	}
}

function triggerdamage()
{
	self endon( "end_fire_effect" );
	while ( 1 )
	{
		self waittill( "trigger", guy );
		if ( isPlayer(guy ) )
		{
			if ( zombie_utility::is_player_valid( guy ) )
			{
				debounce = 500;
				if ( !isDefined( guy.last_napalm_fire_damage ) )
					guy.last_napalm_fire_damage = -1 * debounce;
				
				if ( ( guy.last_napalm_fire_damage + debounce ) < getTime() )
				{
					guy doDamage( self.napalm_fire_damage, guy.origin, undefined, undefined, self.napalm_fire_damage_type );
					guy.last_napalm_fire_damage = getTime();
				}
			}
		}
		else if ( guy.animname != "napalm_zombie" )
			guy thread kill_with_fire( self.napalm_fire_damage_type );
		
	}
}

function kill_with_fire( damagetype )
{
	self endon( "death" );
	if ( isDefined( self.marked_for_death ) )
		return;
	
	self.marked_for_death = 1;
	if ( self.animname == "monkey_zombie" )
	{
	}
	else if ( !isDefined( level.burning_zombies ) )
		level.burning_zombies = [];
	
	if ( level.burning_zombies.size < 6 )
	{
		level.burning_zombies[ level.burning_zombies.size ] = self;
		self thread zombie_flame_watch();
		self playsound( "evt_zombie_ignite" );
		self thread zombie_death::flame_death_fx();
		wait randomFloat( 1.25 );
	}
	self doDamage( self.health + 666, self.origin, undefined, undefined, damagetype );
}

function zombie_flame_watch()
{
	if ( isDefined( level.mutators ) && level.mutators[ "mutator_noTraps" ] )
		return;
	
	self waittill( "death" );
	if ( isDefined( self ) )
	{
		self stopLoopSound();
		arrayRemoveValue( level.burning_zombies, self );
	}
	else
		array::remove_undefined( level.burning_zombies );
	
}

function array_remove( array, object )
{
	if ( !isDefined( array ) && !isDefined( object ) )
		return;
	
	new_array = [];
	foreach ( temp, item in array )
	{
		if ( item != object )
		{
			if (!isdefined( new_array ) )
				new_array = [];
			else if ( !isArray( new_array ) )
				new_array = array( new_array );
			
			new_array[ new_array.size ] = item;
		}
	}
	return new_array;
}

function _zombie_setupfxonjoint( jointname, fxname, offset )
{
	origin = self getTagOrigin( jointname );
	effectent = spawn( "script_model", origin );
	effectent setModel( "tag_origin" );
	effectent.angles = self getTagAngles( jointname );
	if ( !isDefined( offset ) )
		offset = ( 0, 0, 0 );
	
	effectent linkTo( self, jointname, offset );
	playFxOnTag( level._effect[ fxname ], effectent, "tag_origin" );
	return effectent;
}

function _napalm_shrink()
{
}

function _napalm_unshrink()
{
}

function _napalm_damage_callback( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel )
{
	if ( self.classname == "actor_spawner_zm_temple_napalm" )
		return 1;
	
	return 0;
}

function _napalm_zombie_damage( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, modelindex, psoffsettime )
{
	if ( level.zombie_vars[ "zombie_insta_kill" ] )
		damage = damage * 2;
	
	if ( IS_TRUE( self.wet ) )
		damage = damage * 5;
	else if ( self napalm_standing_in_water() )
		damage = damage * 2;
	
	switch( weapon )
	{
		case "spikemore_zm":
		{
			damage = 0;
			break;
		}
	}
	return damage;
}

function napalm_zombie_count_watch()
{
	if ( !isDefined( level.napalmzombiecount ) )
		level.napalmzombiecount = 0;
	
	level.napalmzombiecount++;
	level.napalmzombies[ level.napalmzombies.size ] = self;
	self waittill( "death" );
	level.napalmzombiecount--;
	arrayRemoveValue( level.napalmzombies, self, 0 );
	if ( IS_TRUE( self.shrinked ) )
		level.nextnapalmspawnround = level.round_number + 1;
	else
		level.nextnapalmspawnround = level.round_number + ( randomIntRange( level.napalmzombieminroundwait, level.napalmzombiemaxroundwait + 1 ) );
	
}

function napalm_clear_radius_fx_all_players()
{
	players = getPlayers();
	for ( j = 0; j < players.size; j++ )
	{
		player_to_clear = players[ j ];
		if ( !isDefined( player_to_clear ) )
			continue;
		
		player_to_clear exit_napalm_radius();
	}
}

function exit_napalm_radius()
{
	self clientfield::set_to_player( "napalm_pstfx_burn", 0 );
	self stopLoopound( 2 );
	self.napalmradiuswarningtime = getTime();
}

function init_clientfields()
{
	clientfield::register( "actor", "napalmwet", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "napalmexplode", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "isnapalm", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "napalm_pstfx_burn", VERSION_SHIP, 1, "int" );
}

function napalm_enter_water_trigger( trigger )
{
	self endon( "death" );
	self thread napalm_add_wet_time( 4 );
}

function napalm_add_wet_time( time )
{
	self endon( "death" );
	wettime = time * 1000;
	self.wet_time = getTime() + wettime;
	if ( IS_TRUE( self.wet ) )
		return;
	
	self.wet = 1;
	self thread napalm_start_wet_fx();
	while (self.wet_time > getTime() )
		wait .1;
	
	self thread napalm_end_wet_fx();
	self.wet = 0;
}

function napalm_watch_for_sliding()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( IS_TRUE( self.sliding ) )
			self thread napalm_add_wet_time( 4 );
		
		wait 1;
	}
}

function napalm_start_wet_fx()
{
	self clientfield::set( "napalmwet", 1 );
}

function napalm_end_wet_fx()
{
	self clientfield::set( "napalmwet", 0 );
}

function napalm_standing_in_water(forcecheck)
{
	dotrace = !isDefined( self.standing_in_water_debounce );
	dotrace = dotrace || self.standing_in_water_debounce < getTime();
	dotrace = dotrace || IS_TRUE( forcecheck );
	if ( dotrace )
	{
		self.standing_in_water_debounce = getTime() + 500;
		waterheight = getWaterHeight( self.origin );
		self.standing_in_water = waterheight > self.origin[ 2 ];
	}
	return self.standing_in_water;
}

function napalm_monkey_bolt_taunts( monkey_bolt )
{
	return 1;
}
