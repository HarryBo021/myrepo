#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\name_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
// #using scripts\zm\zm_zod_train;
// #using scripts\zm\zm_zod_vo;
#using scripts\zm\archetype_zod_companion;
#using scripts\zm\craftables\_hb21_zm_craft_fuse;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_zod_robot;

#precache( "fx", "zombie/fx_robot_helper_jump_landing_zod_zmb" );
#precache( "fx", "zombie/fx_robot_helper_trail_sky_zod_zmb" );
#precache( "fx", "zombie/fx_robot_helper_ground_tell_zod_zmb" );

REGISTER_SYSTEM_EX( "zm_zod_robot", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", "robot_switch", 1, 1, "int" );
	clientfield::register( "world", "robot_lights", 1, 2, "int" );
	// # CLIENTFIELD REGISTRATION
	
	// # FLAGS
	level flag::init( "ee_complete" );
	level flag::init( "police_box_ready" );
	level flag::init( "police_box_in_use" );
	level flag::init( "police_box_hide" );
	// # FLAGS
	
	// # VARIABLES AND SETTINGS
	level.n_civil_protector_cost = 2000;
	level.zombie_robot_spawners = getEntArray( "zombie_robot_spawner", "script_noteworthy" );
	level.zombie_robot_gold_spawners = getEntArray( "zombie_robot_gold_spawner", "script_noteworthy" );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER FX
	level._effect[ "robot_landing" ] = "zombie/fx_robot_helper_jump_landing_zod_zmb";
	level._effect[ "robot_sky_trail" ] = "zombie/fx_robot_helper_trail_sky_zod_zmb";
	level._effect[ "robot_ground_spawn" ] = "zombie/fx_robot_helper_ground_tell_zod_zmb";
	// # REGISTER FX	
	
	// # REGISTER CALLBACKS / OVERRIDES
	zombie_utility::add_zombie_gib_weapon_callback("ar_standard_companion", &zod_robot_gib_validate, &zod_robot_gib_head_validate);
	level.check_end_solo_game_override = &check_end_solo_game_override;
	level._game_module_game_end_check = &_game_module_game_end_check;
	// # REGISTER CALLBACKS / OVERRIDES
	
	// THREAD LOGIC
	array::thread_all( struct::get_array( "robot_activate_trig", "script_noteworthy"), &zod_robot_register_callbox_unitrigger, &zod_robot_callbox_visibility_func, &zod_robot_callbox_logic_func );
	level thread zod_robot_callbox_wait_for_crafted();
	level thread zod_robot_callbox_lights();
	level thread zod_robot_callbox_set_numbers();
	level thread zod_robot_upgrade();
	// THREAD LOGIC
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS / OVERRIDES ==============================

function check_end_solo_game_override()
{
	if ( isDefined( level.ai_robot ) )
		return 1;
	
	return 0;
}

function _game_module_game_end_check()
{
	if ( IS_TRUE( level.b_robot_reviving ) )
		return 0;
	
	return 1;
}

// ============================== CALLBACKS / OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function zod_robot_register_callbox_unitrigger( ptr_visibility_func, ptr_logic_func )
{
	self.unitrigger_stub = spawnStruct();
	self.unitrigger_stub.origin = self.origin;
	self.unitrigger_stub.angles = self.angles;
	self.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	self.unitrigger_stub.cursor_hint = "HINT_NOICON";
	self.unitrigger_stub.script_width = 110;
	self.unitrigger_stub.script_height = 90;
	self.unitrigger_stub.script_length = 110;
	self.unitrigger_stub.require_look_at = 0;
	self.unitrigger_stub.s_callbox = self;
	self.unitrigger_stub.prompt_and_visibility_func = ptr_visibility_func;
	zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ptr_logic_func );
}

function zod_robot_callbox_lights()
{
	level endon( "_zombie_game_over" );
	level flag::wait_till( "police_box_ready" );
	while ( 1 )
	{
		level clientfield::set( "robot_lights", 1 );
		level waittill( "police_box_activated" );
		level clientfield::set( "robot_lights", 2 );
		level waittill( "robot_landed" );
		level clientfield::set( "robot_lights", 3 );
		while ( isDefined( level.ai_robot ) )
			wait .05;
		
	}
}

function zod_robot_callbox_wait_for_crafted()
{
	level waittill( "police_box_fully_crafted" );
	level flag::set( "police_box_ready" );
	e_police_box = getEnt( "police_box", "targetname" );
	if ( isDefined( e_police_box ) )
		e_police_box playsound( "zmb_bm_interaction_machine_start" );
	
	e_police_box clientfield::set( "robot_switch", 1 );
}

function zod_robot_callbox_visibility_func( e_player )
{
	b_is_invis = IS_TRUE( e_player.beastmode ) || level flag::get( "police_box_hide" );
	self setInvisibleToPlayer( e_player, b_is_invis );
	if ( !level flag::get( "police_box_ready" ) )
		self setHintString( "Civil Protector Offline" ); // self setHintString( &"ZM_ZOD_ROBOT_NEEDS_POWER" );
	else if ( isDefined( level.ai_robot ) )
		self setHintString( "Civil Protector is On Call" );
	else if ( e_player.score < level.n_civil_protector_cost )
		self setHintString( "Hold ^3[{+activate}]^7 to Contribute to the Civil Protection Fund." ); // self setHintString( &"ZM_ZOD_ROBOT_PAY_TOWARDS" );
	else
		self setHintString( "Hold ^3[{+activate}]^7 to Summon the Civil Protector." ); // self setHintString( &"ZM_ZOD_ROBOT_SUMMON" );
	
	return !b_is_invis;
}

function zod_robot_callbox_logic_func()
{
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player zm_utility::in_revive_trigger() )
			continue;
		if ( isDefined( e_player.is_drinking ) && e_player.is_drinking > 0 )
			continue;
		if ( !zm_utility::is_player_valid( e_player ) )
			continue;
		if ( isDefined( level.ai_robot ) )
			continue;
		if ( level flag::get( "police_box_ready" ) !== 1 )
			continue;
		if ( level flag::get( "police_box_in_use" ) )
			continue;
		
		if ( !e_player zm_score::can_player_purchase( level.n_civil_protector_cost ) )
		{
			level.n_civil_protector_cost = level.n_civil_protector_cost - e_player.score;
			e_player zm_score::minus_to_player_score( e_player.score );
			self.stub zm_unitrigger::run_visibility_function_for_all_triggers();
			level thread zod_robot_callbox_set_numbers();
		}
		else
		{
			level flag::set( "police_box_in_use" );
			self setHintString( "" );
			e_player zm_score::minus_to_player_score( level.n_civil_protector_cost );
			if ( !e_player bgb::is_enabled( "zm_bgb_shopping_free" ) )
			{
				level.n_civil_protector_cost = 0;
				level thread zod_robot_callbox_set_numbers();
			}
			level thread zod_robot_summon( e_player, self.stub, 3 );
			e_player notify( "called_robot" );
			level notify( "police_box_activated" );
			level thread zod_robot_play_vox( self, "activated" );
			self playSound( "evt_police_box_siren" );
			wait 1.5;
			e_player zm_audio::create_and_play_dialog( "robot", "activate" );
		}
	}
}

function zod_robot_summon( e_player, e_trig_stub, n_spawn_delay )
{
	s_robot_spawn_point = struct::get(e_trig_stub.s_callbox.target, "targetname");

	v_trace = bullettrace(s_robot_spawn_point.origin, s_robot_spawn_point.origin, 0, s_robot_spawn_point);
	v_ground_position = v_trace[ "position" ];
	s_spawn_position = v_ground_position + vectorScale( ( 0, 0, 1 ), 650 );
	level thread zod_robot_spawn_fx( v_ground_position );
	if ( isDefined( n_spawn_delay ) )
		wait n_spawn_delay;
	
	if ( level flag::get( "ee_complete" ) )
		e_spawner = level.zombie_robot_gold_spawners[ 0 ];
	else
		e_spawner = level.zombie_robot_spawners[ 0 ];
	
	level.ai_robot = e_spawner spawnFromSpawner( "companion_spawner", 1 );
	level.ai_robot.maxhealth = level.ai_robot.health;
	level.ai_robot.allow_zombie_to_target_ai = 0;
	level.ai_robot.on_train = 0;
	level.ai_robot.can_gib_zombies = 1;
	level.ai_robot setCanDamage( 0 );
	e_trig_stub zm_unitrigger::run_visibility_function_for_all_triggers();
	level.ai_robot.b_robot_finished = 0;
	level.ai_robot playLoopSound( "fly_civil_protector_loop" );
	level.b_robot_leader = e_player;
	foreach ( e_player in level.players )
		e_player setPerk( "specialty_pistoldeath" );
	
	if ( isDefined( level.ai_robot ) )
	{
		level.ai_robot forceTeleport( s_spawn_position );
		level.ai_robot thread zod_robot_do_landing( v_ground_position, e_player );
		level.ai_robot scene::play( "cin_zod_robot_companion_entrance" );
		level notify( "robot_landed" );
		level.ai_robot.v_robot_land_position = v_ground_position;
	}
	level thread zod_robot_play_vox( level.ai_robot, "active", 2 );
	level.ai_robot thread zod_robot_kill_vox();
	level.ai_robot thread zod_robot_active_vox();
	level flag::clear( "police_box_in_use" );
	zod_robot_timer();
	level.ai_robot.b_robot_finished = 1;
	while ( level.ai_robot.b_robot_reviving == 1 )
		wait .05;
	
	foreach ( e_player in level.players )
	{
		e_player unsetPerk( "specialty_pistoldeath" );
	}
	level.ai_robot setCanDamage( 1 );
	level.ai_robot scene::play( "cin_zod_robot_companion_exit_death" );
	level.ai_robot = undefined;
	players = getPlayers();
	if ( players.size != 1 || !level flag::get( "solo_game" ) || !IS_TRUE( players[ 0 ].waiting_to_revive ) )
		level zm::checkForAllDead();
	
	level.n_civil_protector_cost = 2000;
	e_trig_stub zm_unitrigger::run_visibility_function_for_all_triggers();
	level thread zod_robot_callbox_set_numbers();
}

function zod_robot_timer()
{
	level endon( "robot_deactivate" );
	wait 120;
}

function zod_robot_do_landing( v_land_position, e_player )
{
	level.ai_robot thread zod_robot_flyin_fx();
	wait .5;
	earthquake( .55, 1.2, v_land_position, 1200 );
	playFX( level._effect[ "robot_landing" ], v_land_position );
	level thread zod_robot_do_landing_damage( v_land_position, undefined, 350 );
	
	for ( i = 0; i < 5; i++ )
	{
		foreach ( e_player in level.players )
			e_player playRumbleOnEntity( "damage_heavy" );
		
		wait .1;
	}
}

function zod_robot_flyin_fx()
{
	e_fx_model = spawn( "script_model", self.origin );
	e_fx_model setModel( "tag_origin" );
	playFXOnTag( level._effect[ "robot_sky_trail" ], e_fx_model, "tag_origin" );
	e_fx_model linkTo( self );
	level waittill( "robot_landed" );
	e_fx_model delete();
}

function zod_robot_spawn_fx( v_ground_position )
{
	e_fx_model = spawn( "script_model", v_ground_position );
	e_fx_model setModel( "tag_origin" );
	playFXOnTag( level._effect[ "robot_ground_spawn" ], e_fx_model, "tag_origin" );
	level waittill( "robot_landed" );
	e_fx_model delete();
}

function zod_robot_do_landing_damage( v_origin, e_attacker, n_radius )
{
	a_ai_zombies = array::get_all_closest( v_origin, getAITeamArray( "axis" ), undefined, undefined, n_radius );
	foreach ( ai_zombie in a_ai_zombies )
	{
		if ( isDefined( e_attacker ) )
			ai_zombie doDamage( ai_zombie.health + 10000, ai_zombie.origin, e_attacker );
		else
			ai_zombie doDamage( ai_zombie.health + 10000, ai_zombie.origin );
		
		n_distance_sqr = distanceSquared( ai_zombie.origin, v_origin );
		n_dist_mult = n_distance_sqr / SQR( n_radius );
		v_fling = ai_zombie.origin - v_origin;
		v_fling = v_fling + vectorScale( ( 0, 0, 1 ), 15 );
		v_fling = vectorNormalize( v_fling );
		n_size = 50 + 20 * n_dist_mult;
		v_fling = ( v_fling[ 0 ], v_fling[ 1 ], abs( v_fling[ 2 ] ) );
		v_fling = vectorScale( v_fling, n_size );
		ai_zombie startRagdoll();
		ai_zombie launchRagdoll( v_fling );
	}
}

function zod_robot_callbox_set_numbers()
{
	a_callbox_number_panels = getEntArray( "robot_readout_model", "targetname" );
	foreach ( e_callbox_number_panel in a_callbox_number_panels )
		e_callbox_number_panel zod_robot_set_number_joints();
	
}

function zod_robot_set_number_joints()
{
	a_bones = zod_robot_get_number_joints( level.n_civil_protector_cost );
	for ( i = 0; i < 4; i++ )
	{
		for ( j = 0; j < 10; j++ )
			self hidePart( "j_" + i + "_" + j );
		
		self showPart( "j_" + i + "_" + a_bones[ i ] );
	}
}

function zod_robot_get_number_joints( n_civil_protector_cost )
{
	a_bones = [];
	for ( i = 0; i < 4; i++ )
	{
		n_power = pow( 10, 3 - i );
		a_bones[ i ] = floor( n_civil_protector_cost / n_power );
		n_civil_protector_cost = n_civil_protector_cost - a_bones[ i ] * n_power;
	}
	return a_bones;
}

function private zod_robot_gib_head_validate( str_damage_location )
{
	if ( !isDefined( str_damage_location ) )
		return 0;
	
	switch ( str_damage_location )
	{
		case "head":
			return 1;
		case "helmet":
			return 1;
		case "neck":
			return 1;
		default:
			return 0;
		
	}
}

function private zod_robot_gib_validate( n_damage_percent )
{
	return 1;
}

function zod_robot_play_vox( e_entity, str_suffix, n_delay )
{
	e_entity endon("death");
	e_entity endon("disconnect");
	str_alias = "vox_crbt_robot_" + str_suffix;
	n_variants = zm_spawner::get_number_variants(str_alias);
	if ( n_variants <= 0 )
		return;
	
	n_variant = randomIntRange( 0, n_variants + 1 );
	
	if ( isDefined( n_delay ) )
		wait n_delay;
	
	if ( isDefined( e_entity ) && !IS_TRUE( e_entity.is_speaking ) )
	{
		e_entity.is_speaking = 1;
		e_entity PlaySoundWithNotify( str_alias + "_" + n_variant, "sndDone" );
		e_entity waittill( "sndDone" ); // entity waittill("hash_b6f7c8d2");
		e_entity.is_speaking = 0;
	}
}

function zod_robot_kill_vox()
{
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "killed" );
		if ( randomIntRange( 0, 101 ) <= 30 )
			level thread zod_robot_play_vox( level.ai_robot, "kills" );
		
	}
}

function zod_robot_active_vox()
{
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		wait randomIntRange( 15, 25 );
		level thread zod_robot_play_vox( level.ai_robot, "active" );
	}
}

function zod_robot_upgrade()
{
	e_trigger = getEnt( "cp_upgrade", "targetname" );
	if ( !isDefined( e_trigger ) )
		return;
	
	e_trigger triggerIgnoreTeam();
	e_trigger useTriggerRequireLookAt();
	e_trigger setCursorHint( "HINT_NOICON" );
	e_trigger setHintString( "Upgrade Civil Protector" );
	
	e_trigger waittill( "trigger" );
	
	level flag::set( "ee_complete" );
	
	e_trigger delete();
}

// ============================== FUNCTIONALITY ==============================