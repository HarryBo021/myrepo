#using scripts\codescripts\struct;
#using scripts\shared\ai\archetype_robot;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_hb21_zm_behavior;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_astro.gsh;

#precache( "fx", "dlc5/moon/fx_moon_qbomb_explo_distort" );

#namespace zm_ai_astro;

REGISTER_SYSTEM_EX( "zm_ai_astro", &__init__, &__main__, undefined )

function __init__()
{
	level.astro_names_count = tableLookUpRowCount( "gamedata/tables/zm/zm_astro_names.csv" );
	if ( isDefined( level.astro_names_count ) && level.astro_names_count > 0 )
		clientfield::register( "actor", "astro_name_index", VERSION_SHIP, getMinBitCountForNum( level.astro_names_count + 1 ), "int" );
	
	spawner::add_archetype_spawn_function( "astronaut", &set_astro_name );
	
	initastrobehaviorsandasm();
	spawner::add_archetype_spawn_function( "astronaut", &archetypeastroblackboardinit );
	spawner::add_archetype_spawn_function( "astronaut", &astrospawnsetup );
	animationstatenetwork::registernotetrackhandlerfunction( "headbutt_start", &astro_headbutt_start );
	animationstatenetwork::registernotetrackhandlerfunction( "astro_melee", &astro_astro_melee );
	init_astro_zombie_fx();
	if ( !isDefined( level.astro_zombie_enter_level ) )
		level.astro_zombie_enter_level = &astro_zombie_default_enter_level;
	
	level.astro_zombie_enter_level = &moon_astro_enter_level;
	level.ai_astro_explode = &moon_push_zombies_when_astro_explodes;
	
	level.num_astro_zombies = 0;
	level.astro_zombie_spawners = getEntArray( "astronaut_zombie", "targetname" );
	level.max_astro_zombies = MAX_ASTRO_ZOMBIES;
	level.astro_zombie_health_mult = ASTRO_ZOMBIE_HEALTH_MULT;
	level.min_astro_round_wait = MIN_ASTRO_ROUND_WAIT;
	level.max_astro_round_wait = MAX_ASTRO_ROUND_WAIT;
	level.astro_round_start = ASTRO_ROUND_START;
	level.next_astro_round = level.astro_round_start + ( randomIntRange( 0, level.max_astro_round_wait + 1 ) );
	level.zombies_left_before_astro_spawn = 1;
	level.zombie_left_before_spawn = 0;
	level.astro_explode_radius = ASTRO_EXPLODE_RADIUS;
	level.astro_explode_blast_radius = ASTRO_EXPLODE_BLAST_RADIUS;
	level.astro_explode_pulse_min = ASTRO_EXPLODE_PULSE_MIN;
	level.astro_explode_pulse_max = ASTRO_EXPLODE_PULSE_MAX;
	level.astro_headbutt_delay = ASTRO_HEADBUTT_DELAY;
	level.astro_headbutt_radius_sqr = ASTRO_HEADBUTT_RADIUS_SQR;
	level.zombie_total_update = 0;
	zm_spawner::register_zombie_damage_callback( &astro_damage_callback );
}

function __main__()
{
	hb21_zm_behavior::set_zombie_aat_override();
	level thread astro_zombie_spawning();
}

function astro_zombie_spawning()
{
	level waittill( "start_of_round" );
	while ( 1 )
	{
		if ( can_spawn_astro() )
		{
			spawner_list = get_astro_spawners();
			location_list = get_astro_locations();
			spawner = array::random( spawner_list );
			location = array::random( location_list );
			ai = zombie_utility::spawn_zombie( spawner, spawner.targetname, location );
			// ai forceTeleport( location.origin );
			// ai.angles = location.angles;
			// if ( isDefined( ai ) )
				// ai.spawn_point_override = location;
			
		}
		wait 3;
	}
}

function moon_push_zombies_when_astro_explodes( position )
{
	level.quantum_bomb_cached_closest_zombies = undefined;
	self thread quantum_bomb_zombie_fling_result( position );
}

function quantum_bomb_zombie_fling_result( v_position )
{
	playFX( level._effect[ "zombie_fling_result" ], v_position );
	self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
	n_range = 300;
	n_range_squared = SQR( n_range );
	a_zombies = util::get_array_of_closest( v_position, zombie_utility::get_round_enemy_array() );
	for ( i = 0; i < a_zombies.size; i++ )
	{
		e_zombie = a_zombies[ i ];
		if ( !isDefined( e_zombie ) || !isAlive( e_zombie ) )
			continue;
		
		v_test_origin = e_zombie.origin + vectorScale( ( 0, 0, 1 ), 40 );
		n_test_origin_squared = distanceSquared( v_position, v_test_origin );
		if ( n_test_origin_squared > n_range_squared )
			break;
		
		n_dist_mult = ( n_range_squared - n_test_origin_squared ) / n_range_squared;
		v_fling_vec = vectorNormalize( v_test_origin - v_position );
		v_fling_vec = ( v_fling_vec[ 0 ], v_fling_vec[ 1 ], abs( v_fling_vec[ 2 ] ) );
		v_fling_vec = vectorScale( v_fling_vec, 100 + 100 * n_dist_mult );
		e_zombie quantum_bomb_fling_zombie( self, v_fling_vec );
		if ( i && !i % 10 )
		{
			util::wait_network_frame();
			util::wait_network_frame();
			util::wait_network_frame();
		}
	}
}

function quantum_bomb_get_cached_closest_zombies( v_position )
{
	if ( !isDefined( level.quantum_bomb_cached_closest_zombies ) )
		level.quantum_bomb_cached_closest_zombies = util::get_array_of_closest( v_position, zombie_utility::get_round_enemy_array() );
	
	return level.quantum_bomb_cached_closest_zombies;
}

function quantum_bomb_fling_zombie( e_player, v_fling_vec )
{
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	self doDamage( self.health + 666, e_player.origin, e_player, e_player, 0, "MOD_UNKNOWN", 0, undefined );
	if ( self.health <= 0 )
	{
		self startRagdoll();
		self launchRagdoll( v_fling_vec );
	}
}

function moon_astro_enter_level()
{
	self endon( "death" );
	util::wait_network_frame();
	self hide();
	self.entered_level = 1;
	self.no_widows_wine = 1;
	astro_struct = array::random( get_astro_locations() );
	if ( isDefined( astro_struct ) )
	{
		self forceTeleport( astro_struct.origin, astro_struct.angles );
		util::wait_network_frame();
	}
	playFX( level._effect[ "astro_spawn" ], self.origin );
	self playSound( "zmb_hellhound_bolt" );
	self playSound( "zmb_hellhound_spawn" );
	playRumbleOnPosition( "explosion_generic", self.origin );
	self playLoopSound( "zmb_zombie_astronaut_loop", 1 );
	self thread play_line_if_player_can_see();
	self zombie_set_fake_playername();
	util::wait_network_frame();
	self show();
}

function player_can_see_me( player )
{
	v_player_angles = player getPlayerAngles();
	v_player_forward = anglesToForward( v_player_angles );
	v_player_to_self = self.origin - player getOrigin();
	v_player_to_self = vectorNormalize( v_player_to_self );
	n_dot = vectorDot( v_player_forward, v_player_to_self );
	if ( n_dot < .766 )
		return 0;
	
	return 1;
}

function zombie_set_fake_playername()
{
	self setZombieName( "SpaceZom" );
}

function play_line_if_player_can_see()
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( distanceSquared( self.origin, players[ i ].origin ) <= 640000 )
		{
			cansee = self player_can_see_me( players[ i ] );
			if ( cansee )
			{
				players[ i ] thread zm_audio::create_and_play_dialog( "general", "astro_spawn" );
				return;
			}
		}
	}
}

function set_astro_name()
{
	do
	{
		astro_name_index = randomInt( level.astro_names_count );
		astro_name_index = astro_name_index + 1;
	}
	while ( level.current_astro_name_index === astro_name_index );
	level.current_astro_name_index = astro_name_index;
	
	self clientfield::set( "astro_name_index", astro_name_index );
	foreach ( array_key, player in level.players )
	{
		if ( zombie_utility::is_player_valid( player ) )
		{
			owner = player;
			break;
		}
	}
	if ( !isDefined( owner ) )
		owner = level.players[ 0 ];
	
	self setEntityOwner( owner );
	self setClone();
}

function archetypeastroblackboardinit()
{
	blackboard::createblackboardforentity( self );
	self aiutility::registerutilityblackboardattributes();
	ai::createinterfaceforentity(self);
	blackboard::registerblackboardattribute( self, "_locomotion_speed", "locomotion_speed_walk", &zombiebehavior::bb_getlocomotionspeedtype );
	self.___archetypeonanimscriptedcallback = &archetypeastroonanimscriptedcallback;
}

function private archetypeastroonanimscriptedcallback( entity )
{
	entity.__blackboard = undefined;
	entity archetypeastroblackboardinit();
}

function private initastrobehaviorsandasm()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi( "astrotargetservice", &astrotargetservice );
	behaviortreenetworkutility::registerbehaviortreeaction( "moonastroproceduraltraversal", &astrotraversestart, &robotsoldierbehavior::robotproceduraltraversalupdate, &astrotraverseend );
}

function astrospawnsetup()
{
	self astro_prespawn();
	self thread astro_zombie_spawn( self );
}

function astrotargetservice( entity )
{
	if ( IS_TRUE( entity.ignoreall ) )
		return 0;
	
	player = zombie_utility::get_closest_valid_player( self.origin, self.ignore_player );
	entity.favoriteenemy = player;
	if ( !isDefined( player ) || player isNoTarget() )
	{
		if ( isDefined( entity.ignore_player ) )
		{
			if ( isDefined( level._should_skip_ignore_player_logic ) && [ [ level._should_skip_ignore_player_logic ] ]() )
				return;
			
			entity.ignore_player = [];
		}
		if ( isDefined( level.no_target_override ) )
			[ [ level.no_target_override ] ]( entity );
		else
			entity setGoal( entity.origin );
		
		return 0;
	}
	if ( isDefined( level.enemy_location_override_func ) )
	{
		enemy_ground_pos = [ [ level.enemy_location_override_func ] ]( entity, player );
		if ( isDefined( enemy_ground_pos ) )
		{
			entity setGoal( enemy_ground_pos );
			return 1;
		}
	}
	targetpos = getClosestPointOnNavMesh( player.origin, 15, 15 );
	if(isdefined(targetpos))
	{
		entity setGoal( targetpos );
		return 1;
	}
	if ( isDefined( player.last_valid_position ) )
	{
		entity setGoal( player.last_valid_position );
		return 1;
	}
	entity setGoal( entity.origin );
	return 0;
}

function can_spawn_astro()
{
	if ( !isDefined( level.zm_loc_types[ "astro_location" ] ) || level.zm_loc_types[ "astro_location" ].size <= 0 )
		return 0;
	
	if ( !( level.round_number >= level.next_astro_round && level.num_astro_zombies < level.max_astro_zombies ) )
		return 0;
	
	if ( !IS_TRUE( level.zombie_total_update ) )
		return 0;
	
	if ( level.zombie_total > level.zombies_left_before_astro_spawn )
		return 0;
	
	return 1;
}

function get_astro_spawners()
{
	return level.astro_zombie_spawners;
}

function get_astro_locations()
{
	return level.zm_loc_types[ "astro_location" ];
}

function astro_prespawn()
{
	self.animname = "astro_zombie";
	self.ignoreall = 1;
	self.allowdeath = 1;
	self.is_zombie = 1;
	self.has_legs = 1;
	self allowedstances("stand");
	self.gibbed = 0;
	self.head_gibbed = 0;
	self.disablearrivals = 1;
	self.disableexits = 1;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.nododgemove = 1;
	self.dontshootwhilemoving = 1;
	self.pathenemylookahead = 0;
	self.badplaceawareness = 0;
	self.chatinitialized = 0;
	self thread zm_spawner::zombie_damage_failsafe();
	self thread zombie_utility::delayed_zombie_eye_glow();
	self.flame_damage_time = 0;
	self.meleedamage = 50;
	self.no_powerups = 1;
	self.no_gib = 1;
	self.ignorelocationaldamage = 1;
	self.actor_damage_func = &astro_actor_damage;
	self.nuke_damage_func = &astro_nuke_damage;
	self.custom_damage_func = &astro_custom_damage;
	self.microwavegun_sizzle_func = &astro_microwavegun_sizzle;
	self.ignore_cleanup_mgr = 1;
	self.ignore_distance_tracking = 1;
	self.ignore_enemy_count = 1;
	self.ignore_gravity = 1;
	self.ignore_devgui_death = 1;
	self.ignore_nml_delete = 1;
	self.ignore_round_spawn_failsafe = 1;
	self.ignore_poi_targetname = [];
	self.ignore_poi_targetname[ self.ignore_poi_targetname.size ] = "zm_bhb";
	self.zombie_move_speed = "walk";
	self zombie_utility::set_zombie_run_cycle();
	self.zombie_think_done = 1;
	self thread zm_spawner::play_ambient_zombie_vocals();
	self thread zm_audio::zmbaivox_notifyconvert();
	self notify( "zombie_init_done" );
}

function init_astro_zombie_fx()
{
	level._effect[ "astro_spawn" ] = "dlc5/moon/fx_moon_qbomb_explo_distort";
	level._effect[ "astro_explosion" ] = "dlc5/moon/fx_moon_qbomb_explo_distort";
	level._effect["zombie_fling_result"] = "dlc5/moon/fx_moon_qbomb_explo_distort";
}

function astro_zombie_spawn( astro_zombie )
{
	self.script_moveoverride = 1;
	if ( !isDefined( level.num_astro_zombies ) )
		level.num_astro_zombies = 0;
	
	level.num_astro_zombies++;
	astro_zombie.has_legs = 1;
	self.count = 100;
	playSoundAtPosition( "evt_astro_spawn", self.origin );
	astro_zombie.deathfunction = &astro_zombie_die;
	astro_zombie.animname = "astro_zombie";
	astro_zombie.loopsound = "evt_astro_gasmask_loop";
	astro_zombie thread astro_zombie_think();
	_debug_astro_print( "astro spawned in " + level.round_number );
	return astro_zombie;
}

function astro_zombie_think()
{
	self endon( "death" );
	self.entered_level = 0;
	self.ignoreall = 0;
	self.maxhealth = ( level.zombie_health * getPlayers().size ) * level.astro_zombie_health_mult;
	self.health = self.maxhealth;
	self.maxsightdistsqrd = 9216;
	self.zombie_move_speed = "walk";
	self thread [ [ level.astro_zombie_enter_level ] ]();
	if ( isDefined( level.astro_zombie_custom_think ) )
		self thread [[level.astro_zombie_custom_think]]();
	
	self thread astro_zombie_headbutt_think();
	self playLoopSound( self.loopsound );
}

function astro_zombie_headbutt_think()
{
	self endon( "death" );
	self.is_headbutt = 0;
	self.next_headbutt_time = getTime() + level.astro_headbutt_delay;
	while ( 1 )
	{
		if ( !isDefined( self.enemy ) )
		{
			wait .05;
			continue;
		}
		if ( !self.is_headbutt && getTime() > self.next_headbutt_time )
		{
			origin = self getEye();
			test_origin = self.enemy getEye();
			dist_sqr = distanceSquared( origin, test_origin );
			if ( dist_sqr > level.astro_headbutt_radius_sqr )
			{
				wait .05;
				continue;
			}
			yaw = zombie_utility::getYawToOrigin( self.enemy.origin );
			if ( abs( yaw ) > 45 )
			{
				wait .05;
				continue;
			}
			if ( !bulletTracePassed( origin, test_origin, 0, undefined ) )
			{
				wait .05;
				continue;
			}
			self.is_headbutt = 1;
			self thread astro_turn_player();
			headbutt_anim = self animMappingSearch( istring( "anim_astro_headbutt" ) );
			time = getAnimLength( headbutt_anim );
			self.player_to_headbutt thread astro_restore_move_speed( time );
			self animScripted( "headbutt_anim", self.origin, self.angles, "ai_zm_dlc5_zombie_astro_headbutt" );
			wait time;
			self.next_headbutt_time = getTime() + level.astro_headbutt_delay;
			self.is_headbutt = 0;
		}
		wait .05;
	}
}

function astro_restore_move_speed( time )
{
	self endon( "disconnect" );
	wait time;
	self allowJump( 1 );
	self allowProne( 1 );
	self allowCrouch( 1 );
	self setMoveSpeedScale( 1 );
}

function astrotraversestart( entity, asmstatename )
{
	robotsoldierbehavior::robotcalcproceduraltraversal( entity, asmstatename );
	robotsoldierbehavior::robottraversestart( entity, asmstatename );
	return 5;
}

function astrotraverseend( entity, asmstatename )
{
	robotsoldierbehavior::robotprocedurallandingupdate( entity, asmstatename );
	robotsoldierbehavior::robottraverseend( entity );
	return 4;
}

function astro_turn_player()
{
	self endon( "death ");
	self.player_to_headbutt = self.enemy;
	player = self.player_to_headbutt;
	up = player.origin + vectorScale( ( 0, 0, 1 ), 10 );
	facing_astro = vectorToAngles( self.origin - up );
	player thread astro_watch_controls( self );
	if ( self.health > 0 )
		player freezeControls(1);
	
	lerp_time = .2;
	enemy_to_player = vectorNormalize( player.origin - self.origin );
	link_org = self.origin + ( 40 * enemy_to_player );
	player lerp_player_view_to_position( link_org, facing_astro, lerp_time, 1 );
	wait lerp_time;
	player freezeControls( 0 );
	player allowJump( 0 );
	player allowStand( 1 );
	player allowProne( 0 );
	player allowCrouch( 0 );
	player setMoveSpeedScale( .1 );
	player notify( "released" );
	dist = distance( self.origin, player.origin );
	_debug_astro_print( "grab dist = " + dist );
}

function lerp_player_view_to_position( origin, angles, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo )
{
	if ( isPlayer( self ) )
		self endon( "disconnect" );
	
	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = self.origin;
	linker.angles = self getPlayerAngles();
	if ( isDefined( hit_geo ) )
		self playerLinkTo( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo );
	else if ( isDefined( right_arc ) )
		self playerLinkTo( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc );
	else if ( isDefined( fraction ) )
		self playerLinkTo( linker, "", fraction );
	else
		self playerLinkTo( linker );
	
	linker moveTo( origin, lerptime, lerptime * .25 );
	linker rotateTo( angles, lerptime, lerptime * .25 );
	linker waittill( "movedone" );
	linker delete();
}

function astro_watch_controls( astro )
{
	self endon( "released" );
	self endon( "disconnect" );
	animlen = astro getAnimLengthFromAsd( "zm_headbutt", 0 );
	time = .5 + animlen;
	astro util::waittill_notify_or_timeout( "death", time );
	self freezeControls( 0 );
}

function astro_astro_melee( entity )
{
	if ( !isDefined( entity.player_to_headbutt ) || !zombie_utility::is_player_valid( entity.player_to_headbutt ) )
		return;
	
	entity thread astro_zombie_attack();
	entity thread astro_zombie_teleport_enemy();
}

function astro_headbutt_start( entity )
{
	_release_dist = 59;
	player = entity.player_to_headbutt;
	if ( !isDefined( player ) || !isAlive( player ) )
		return;
	
	dist = distance( player.origin, entity.origin );
	_debug_astro_print( "distance before headbutt = " + dist );
	if ( dist < _release_dist )
		return;
	
	player allowJump( 1 );
	player allowProne( 1 );
	player allowCrouch( 1 );
	player setMoveSpeedScale( 1 );
	self animScripted( "headbutt_anim", entity.origin, entity.angles, "ai_zm_dlc5_zombie_astro_headbutt_release" );
}

function astro_zombie_attack()
{
	self endon( "death" );
	if ( !isDefined( self.player_to_headbutt ) )
		return;
	
	player = self.player_to_headbutt;
	perk_list = [];
	vending_triggers = getEntArray( "zombie_vending", "targetname" );
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( player hasPerk( perk ) )
			perk_list[ perk_list.size ] = perk;
		
	}
	take_perk = 0;
	if ( perk_list.size > 0 && !isDefined( player._retain_perks ) )
	{
		take_perk = 1;
		perk_list = array::randomize( perk_list );
		perk = perk_list[ 0 ];
		perk_str = perk + "_stop";
		player notify( perk_str );
		if ( level flag::get( "solo_game" ) && perk == "specialty_quickrevive" )
			player.lives--;
		
		player thread astro_headbutt_damage( self, self.origin );
	}
	if ( !take_perk )
	{
		damage = player.health - 1;
		player doDamage( damage, self.origin, self );
	}
}

function astro_headbutt_damage( astro, org )
{
	self endon( "disconnect" );
	self waittill( "perk_lost" );
	damage = self.health - 1;
	if ( isDefined( astro ) )
		self doDamage( damage, astro.origin, astro );
	else
		self doDamage( damage, org );
	
}

function astro_zombie_teleport_enemy()
{
	self endon( "death" );
	player = self.player_to_headbutt;
	a_structs = get_astro_locations();
	chosen_spot = undefined;
	a_structs = arraySort( a_structs, self.origin, 0 );
	foreach ( s_struct in a_structs )
	{
		if ( zm_utility::check_point_in_enabled_zone( s_struct.origin, 1, level.active_zones ) )
		{
			chosen_spot = s_struct;
			break;
		}
	}
	if ( isDefined( chosen_spot ) )
		player thread astro_zombie_teleport( chosen_spot );
	
}

function astro_zombie_teleport( struct_dest )
{
	self endon( "death" );
	if ( !isDefined( struct_dest ) )
		return;
	
	prone_offset = vectorScale( ( 0, 0, 1 ), 49 );
	crouch_offset = vectorScale( ( 0, 0, 1 ), 20 );
	stand_offset = ( 0, 0, 0 );
	destination = undefined;
	if ( self getStance() == "prone" )
		destination = struct_dest.origin + prone_offset;
	else if ( self getStance() == "crouch" )
		destination = struct_dest.origin + crouch_offset;
	else
		destination = struct_dest.origin + stand_offset;
	
	if ( isDefined( level._black_hole_teleport_override ) )
		level [ [ level._black_hole_teleport_override ] ]( self );
	
	self freezeControls(1);
	self disableOffhandWeapons();
	self disableWeapons();
	self dontInterpolate();
	self setOrigin(destination);
	self setPlayerAngles( struct_dest.angles );
	self enableOffhandWeapons();
	self enableWeapons();
	self freezeControls( 0 );
	earthquake( .8, .75, self.origin, 1000, self );
	self playSoundToPlayer( "zmb_gersh_teleporter_go_2d", self );
}

function astro_zombie_die( einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime )
{
	playFxOnTag( level._effect[ "astro_explosion" ], self, "j_spinelower" );
	self stopLoopSound( 1 );
	self playSound( "evt_astro_zombie_explo" );
	self thread astro_delay_delete();
	self thread astro_player_pulse();
	level.num_astro_zombies--;
	level.next_astro_round = level.round_number + ( randomIntRange( level.min_astro_round_wait, level.max_astro_round_wait + 1 ) );
	level.zombie_total_update = 0;
	_debug_astro_print( "astro killed in " + level.round_number );
	return self zm_spawner::zombie_death_animscript();
}

function astro_delay_delete()
{
	self endon( "death" );
	self setPlayerCollision( 0 );
	self thread zombie_utility::zombie_eye_glow_stop();
	wait .05;
	self ghost();
	wait .05;
	self delete();
}

function astro_player_pulse()
{
	eye_org = self getEye();
	foot_org = self.origin + vectorScale( ( 0, 0, 1 ), 8 );
	mid_org = ( foot_org[ 0 ], foot_org[ 1 ], ( foot_org[ 2 ] + eye_org[ 2 ]) / 2 );
	astro_org = self.origin;
	if ( isDefined( self.player_to_headbutt ) )
	{
		self.player_to_headbutt allowjump( 1 );
		self.player_to_headbutt allowprone( 1 );
		self.player_to_headbutt allowcrouch( 1 );
		self.player_to_headbutt unlink();
		wait .05;
		wait .05;
	}
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		if ( !zombie_utility::is_player_valid( player ) )
			continue;
		
		test_org = player getEye();
		explode_radius = level.astro_explode_radius;
		if ( distanceSquared( eye_org, test_org ) > ( explode_radius * explode_radius ) )
			continue;
		
		test_org_foot = player.origin + vectorScale( ( 0, 0, 1 ), 8 );
		test_org_mid = ( test_org_foot[ 0 ], test_org_foot[ 1 ], ( test_org_foot[ 2 ] + test_org[ 2 ] ) / 2 );
		if ( !bulletTracePassed( eye_org, test_org, 0, undefined ) )
		{
			if ( !bulletTracePassed( mid_org, test_org_mid, 0, undefined ) )
			{
				if ( !bulletTracePassed( foot_org, test_org_foot, 0, undefined ) )
					continue;
				
			}
		}
		dist = distance( eye_org, test_org );
		scale = 1 - ( dist / explode_radius );
		if ( scale < 0 )
			scale = 0;
		
		bonus = ( level.astro_explode_pulse_max - level.astro_explode_pulse_min ) * scale;
		pulse = level.astro_explode_pulse_min + bonus;
		dir = ( player.origin[ 0 ] - astro_org[ 0 ], player.origin[ 1 ] - astro_org[ 1 ], 0 );
		dir = vectorNormalize( dir );
		dir = dir + ( 0, 0, 1 );
		dir = dir * pulse;
		player setOrigin( player.origin + ( 0, 0, 1 ) );
		player_velocity = dir;
		player setVelocity( player_velocity );
		if ( isDefined( level.ai_astro_explode ) )
			player thread [ [ level.ai_astro_explode ] ]( mid_org );
		
	}
}

function astro_actor_damage( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	self endon( "death" );
	switch ( weapon.name )
	{
		case "microwavegundw_upgraded_zm":
		case "microwavegundw_zm":
		{
			damage = 0;
			break;
		}
	}
	return damage;
}

function astro_nuke_damage()
{
	self endon( "death" );
}

function astro_custom_damage( player )
{
	damage = self.meleedamage;
	if ( self.is_headbutt )
		damage = player.health - 1;
	
	_debug_astro_print( "astro damage = " + damage );
	return damage;
}

function astro_microwavegun_sizzle( player )
{
	_debug_astro_print( "astro sizzle" );
}

function astro_zombie_default_enter_level()
{
	playFx( level._effect[ "astro_spawn" ], self.origin );
	playSoundAtPosition( "zmb_bolt", self.origin );
	players = getPlayers();
	players[ randomIntRange( 0, players.size ) ] thread zm_audio::create_and_play_dialog( "general", "astro_spawn" );
	self.entered_level = 1;
}

function astro_damage_callback( mod, hit_location, hit_origin, player, amount, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel )
{
	if ( isDefined( self.animname ) && self.animname == "astro_zombie" )
		return 1;
	
	return 0;
}

function _debug_astro_health_watch()
{
	self endon( "death" );
	while ( 1 )
	{
		/#
			iPrintLn( "" + self.health );
		#/
		wait 1;
	}
}

function _debug_astro_print( str )
{
	/#
		if ( IS_TRUE( level.debug_astro ) )
			iPrintLn( str );
		
	#/
}