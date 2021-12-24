#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\mechz;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_elemental_zombies;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_zm_zonemgr;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;

#insert scripts\zm\_zm_ai_mechz.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\mechz.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;

#namespace zm_ai_mechz;

#precache( "fx", "dlc1/castle/fx_mech_death" );
#precache( "xanim", "ai_zombie_mech_grapple_arm_closed_idle" );
#precache( "xanim", "ai_zombie_mech_grapple_arm_open_idle" );
#precache( "xmodel", "c_t7_zm_dlchd_origins_mech_claw" );
#precache( "xmodel", "p7_chemistry_kit_large_bottle" );

#using_animtree( "mechz_claw" );

REGISTER_SYSTEM_EX( "zm_ai_mechz", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # SPAWN SET UP
	spawner::add_archetype_spawn_function( 	"mechz", 	&mechz_setup	 );
	// # SPAWN SET UP
	
	// # BEHAVIOR SET UP
	// # SHARED
	BT_REGISTER_API( 									"zmMechzTargetService", 								&zm_mechz_target_service																																														 );
	// # GENESIS
	BT_REGISTER_API( 									"castleMechzTrapService", 								&genesis_mechz_trap_service																																													 );
	BT_REGISTER_API( 									"genesisVortexService", 									&genesis_mechz_vortex_service																																												 );
	BT_REGISTER_API( 									"genesisMechzOctobombService", 					&genesis_mechz_octobomb_service																																											 );
	BT_REGISTER_API( 									"castleMechzShouldMoveToTrap", 					&genesis_mechz_should_move_to_trap																																									 );
	BT_REGISTER_API( 									"castleMechzIsAtTrap", 									&genesis_mechz_is_at_trap																																														 );
	BT_REGISTER_API( 									"castleMechzShouldAttackTrap", 						&genesis_mechz_should_attack_trap																																										 );
	BT_REGISTER_API( 									"genesisMechzShouldOctobombAttack", 			&genesis_mechz_should_octobomb_attack																																								 );
	BT_REGISTER_API( 									"casteMechzTrapMoveTerminate", 					&genesis_mechz_trap_move_terminate																																									 );
	BT_REGISTER_API( 									"casteMechzTrapAttackTerminate", 					&genesis_mechz_trap_attack_terminate																																									 );
	BT_REGISTER_API( 									"genesisMechzDestoryOctobomb", 					&genesis_mechz_destroy_octobomb																																										 );
	// # TOMB
	BT_REGISTER_API( 									"tombMechzGetTankTagService", 					&mechzgettanktagservice																																															 );
	BT_REGISTER_API( 									"tombMechzGetJumpPosService", 					&mechzgetjumpposservice																																														 );
	BT_REGISTER_API( 									"tombMechzShouldJump", 								&mechzshouldjump																																																	 );
	BT_REGISTER_API( 									"tombMechzShouldShootFlameAtTank", 			&mechzshouldshootflameattank																																												 );
	BT_REGISTER_API( 									"tombMechzWasKnockedDownByTank", 			&mechzwasknockeddownbytank																																												 );
	BT_REGISTER_API( 									"tombMechzWasRobotStomped", 					&mechzwasrobotstomped																																														 );
	BT_REGISTER_API( 									"tombMechzShouldShowPain", 							&mechzshouldshowpain																																															 );
	BT_REGISTER_API( 									"tombMechzJumpUpActionStart", 					&mechzjumpupactionstart																																															 );
	BT_REGISTER_API( 									"tombMechzJumpUpActionTerminate", 				&mechzjumpupactionterminate																																													 );
	BT_REGISTER_ACTION( 							"tombMechzJumpHoverAction", 						undefined, 														&tombmechzjumphoveraction, 								undefined															 );
	BT_REGISTER_API( 									"tombMechzJumpDownActionStart", 				&mechzjumpdownactionstart																																													 );
	BT_REGISTER_API( 									"tombMechzJumpDownActionTerminate", 		&mechzjumpdownactionterminate																																												 );
	BT_REGISTER_API( 									"tombMechzRobotStompActionStart", 				&mechzrobotstompactionstart																																													 );
	BT_REGISTER_ACTION( 							"tombMechzRobotStompActionLoop", 				undefined, 														&mechzrobotstompactionupdate, 							undefined															 );
	BT_REGISTER_API( 									"tombMechzRobotStompActionEnd", 				&mechzrobotstompactionend																																													 );
	BT_REGISTER_ACTION( 							"tombMechzShootFlameAtTankAction", 			&mechzshootflameattankactionstart, 				&mechzBehavior::mechzShootFlameActionUpdate, 	&mechzshootflameattankactionend					 );
	BT_REGISTER_API( 									"tombMechzTankKnockdownActionStart", 		&mechztankknockdownactionstart																																											 );
	BT_REGISTER_ACTION( 							"tombMechzTankKnockdownActionLoop", 		undefined, 														&mechztankknockdownactionupdate, 						undefined															 );
	BT_REGISTER_API( 									"tombMechzTankKnockdownActionEnd", 			&mechztankknockdownactionend																																												 );
	BT_REGISTER_API( 									"zmMechzShouldShootClaw", 							&zm_mechz_should_shoot_claw																																												 );
	BT_REGISTER_ACTION( 							"zmMechzShootClawAction", 							&zm_mechz_shoot_claw_action_start, 			&zm_mechz_shoot_claw_action_update, 				&zm_mechz_shoot_claw_action_end				 );
	BT_REGISTER_API( 									"zmMechzShootClaw", 									&zm_mechz_shoot_claw																																															 );
	BT_REGISTER_API( 									"zmMechzUpdateClaw", 									&zm_mechz_update_claw																																														 );
	BT_REGISTER_API( 									"zmMechzStopClaw", 										&zm_mechz_stop_claw																																															 );
	
	ASM_REGISTER_MOCOMP( 						"mocomp_trap_attack@mechz", 						&trap_attack_mocomp_start, 							undefined, 																&trap_attack_mocomp_terminate						 );
	ASM_REGISTER_MOCOMP( 						"mocomp_teleport_traversal@mechz", 			&teleport_traversal_mocomp_start, 				undefined, 																undefined															 );
	ASM_REGISTER_MOCOMP( 						"mocomp_face_tank@mechz", 						&face_tank_mocomp_start, 							undefined, 																undefined															 );
	ASM_REGISTER_MOCOMP( 						"mocomp_jump_tank@mechz", 						&jump_tank_mocomp_start, 							undefined, 																undefined															 );
	ASM_REGISTER_MOCOMP( 						"mocomp_tomb_mechz_traversal@mechz", 	&tomb_mechz_traversal_mocomp_start, 		undefined, 																&tomb_mechz_traversal_mocomp_terminate	 );
	
	ASM_REGISTER_NOTETRACK_HANDLER( 	"muzzleflash", 													&mechznotetrackmuzzleflash																																													 );
	ASM_REGISTER_NOTETRACK_HANDLER( 	"start_ft", 														&mechznotetrackstartft																																															 );
	ASM_REGISTER_NOTETRACK_HANDLER( 	"stop_ft", 														&mechznotetrackstopft																																																 );
	// # BEHAVIOR SET UP
	
	// # CLIENTFIELD REGISTRATION
	clientfield::register( 									"scriptmover", 		"mechz_claw", 				VERSION_SHIP, 	1, 		"int"			 );
	clientfield::register( 									"actor", 				"mechz_wpn_source", 	VERSION_SHIP, 	1, 		"int"			 );
	clientfield::register( 									"toplayer", 			"mechz_grab", 				VERSION_SHIP, 	1, 		"int"			 );
	clientfield::register(									"actor", 				"tomb_mech_eye", 			VERSION_SHIP, 	1, 		"int"			 );
	// # CLIENTFIELD REGISTRATION

	// # REGISTER IMMUNITY FOR AI FROM AATS
	level thread AAT::register_immunity(		"zm_aat_blast_furnace", 		"mechz", 		0, 	1, 	1		 );
	level thread AAT::register_immunity(		"zm_aat_dead_wire", 			"mechz", 		1, 	1, 	1		 );
	level thread AAT::register_immunity(		"zm_aat_fire_works", 			"mechz", 		1, 	1, 	1		 );
	level thread AAT::register_immunity(		"zm_aat_thunder_wall", 		"mechz", 		0, 	1, 	1		 );
	level thread AAT::register_immunity(		"zm_aat_turned", 				"mechz", 		1, 	1, 	1		 );
	// # REGISTER IMMUNITY FOR AI FROM AATS
	
	// # VARIABLES AND SETTINGS
	level.mechz_max_thundergun_damage 							= MECHZ_MAX_THUNDERGUN_DAMAGE;
	level.mechz_points_for_killer 											= MECHZ_POINTS_FOR_KILLER;
	level.mechz_points_for_team 											= MECHZ_POINTS_FOR_TEAM;
	level.mechz_points_for_helmet 										= MECHZ_POINTS_FOR_HELMET;
	level.mechz_points_for_powerplant 									= MECHZ_POINTS_FOR_POWERPLANT;
	level.mechz_base_health 													= MECHZ_BASE_HEALTH;
	level.mechz_health 															= level.mechz_base_health;
	level.mechz_faceplate_base_health 									= MECHZ_FACEPLATE_BASE_HEALTH;
	level.mechz_faceplate_health 											= level.mechz_faceplate_base_health;
	level.mechz_powercap_cover_base_health 						= MECHZ_POWERCAP_COVER_BASE_HEALTH;
	level.mechz_powercap_cover_health 								= level.mechz_powercap_cover_base_health;
	level.mechz_powercap_base_health 								= MECHZ_POWERCAP_BASE_HEALTH;
	level.mechz_powercap_health 											= level.mechz_powercap_base_health;
	level.mechz_armor_base_health 										= MECHZ_ARMOR_BASE_HEALTH;
	level.mechz_armor_health 												= level.mechz_armor_base_health;
	level.mechz_health_increase 											= MECHZ_HEALTH_INCREASE;
	level.mechz_shotgun_damage_mod 								= MECHZ_SHOTGUN_DAMAGE_MOD;
	level.mechz_damage_percent 											= MECHZ_DAMAGE_PERCENT;
	level.mechz_helmet_health_percentage 							= MECHZ_HELMET_HEALTH_PERCENTAGE;
	level.mechz_explosive_dmg_to_cancel_claw_percentage 	= MECHZ_EXPLOSIVE_DMG_TO_CANCEL_CLAW_PERCENTAGE;
	level.mechz_powerplant_destroyed_health_percentage 	= MECHZ_POWERPLANT_DESTROYED_HEALTH_PERCENTAGE;
	level.mechz_powerplant_expose_health_percentage 		= MECHZ_POWERPLANT_EXPOSE_HEALTH_PERCENTAGE;
	level.mechz_custom_goalradius 										= MECHZ_CUSTOM_GOALRADIUS;
	level.mechz_tank_knockdown_time 								= MECHZ_TANK_KNOCKDOWN_TIME;
	level.mechz_robot_knockdown_time 								= MECHZ_ROBOT_KNOCKDOWN_TIME;
	level.mechz_claw_cooldown_time 									= MECHZ_CLAW_COOLDOWN_TIME;
	level.mechz_flamethrower_cooldown_time 						= MECHZ_FLAMETHROWER_COOLDOWN_TIME;
	level.mechz_jump_delay 													= MECHZ_JUMP_DELAY;
	
	level.num_mechz_spawned 												= 0;
	level.mechz_round_count 												= 0;
	level.mechz_min_round_fq 												= MECHZ_MIN_ROUND;
	level.mechz_max_round_fq 												= MECHZ_MAX_ROUND;
	level.mechz_min_round_fq_solo 										= MECHZ_MIN_ROUND_SOLO;
	level.mechz_max_round_fq_solo 										= MECHZ_MAX_ROUND_SOLO;
	level.mechz_zombie_per_round 										= MECHZ_ZOMBIE_PER_ROUND;
	level.mechz_left_to_spawn 												= 0;
	
	level.mechz_spawners 														= getEntArray( 				"zombie_mechz_spawner", 		"script_noteworthy"		 );
	level.mechz_locations 														= struct::get_array( 		"mechz_location", 					"script_noteworthy"		 );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER FX
	level._effect[ 		"mechz_death"		 ] 							= "dlc1/castle/fx_mech_death";
	// # REGISTER FX
	
	// # REGISTER AI CALLBACKS
	level.mechz_staff_damage_override 								= &mechz_staff_damage_override;
	level.mechz_flamethrower_ai_callback 								= &mechz_flamethrower_ai;
	level.mechz_left_arm_damage_callback 							= &zm_mechz_left_arm_damage;
	// # REGISTER AI CALLBACKS
	
	// # FLAGS
	level flag::init( 		"mechz_launching_claw"				 );
	level flag::init( 		"mechz_claw_move_complete"	 );
	// # FLAGS
	
	// # REGISTER PLAYER CALLBACKS
	zm::register_player_damage_callback( 							&mechz_player_damage							 );
	// # REGISTER PLAYER CALLBACKS
	
	// THREAD LOGIC
	mechz_setup_armor_pieces();
	level thread mechz_spawning_logic();
	// THREAD LOGIC
}

function __main__()
{
	if ( !isDefined( level.mechz_visionset_priority ) )
		level.mechz_visionset_priority = 80;
	
	visionset_mgr::register_info( "overlay", "mechz_player_burn", 5000, level.mechz_visionset_priority, 15, 1, &visionset_mgr::duration_lerp_thread_per_player, 0 );
	level.mechz_visionset_setup = 1;
}

// ============================== INITIALIZE ==============================

// ============================== BEHAVIOR ==============================

function zm_mechz_target_service( e_entity )
{
	if ( IS_TRUE( e_entity.ignoreall ) )
		return 0;
	if ( isDefined( e_entity.destroy_octobomb ) )
		return 0;
	
	e_player = zm_utility::get_closest_valid_player( e_entity.origin, e_entity.ignore_player );
	e_entity.favoriteenemy = e_player;
	if ( !isDefined( e_player ) || e_player isNoTarget() )
	{
		if ( isDefined( e_entity.ignore_player ) )
		{
			if ( isDefined( level._should_skip_ignore_player_logic ) && [ [ level._should_skip_ignore_player_logic ] ]() )
				return;
			
			e_entity.ignore_player = [];
		}
		if ( isDefined( level.no_target_override ) )
			[ [ level.no_target_override ] ]( e_entity );
		else
			e_entity setGoal( e_entity.origin );
		
		return 0;
	}
	else if ( isDefined( level.enemy_location_override_func ) )
	{
		enemy_ground_pos = [ [ level.enemy_location_override_func ] ]( e_entity, e_player );
		if ( isDefined( enemy_ground_pos ) )
		{
			e_entity setGoal( enemy_ground_pos );
			return 1;
		}
	}
	v_player_origin = e_player.origin;
	if ( isDefined( e_player.last_valid_position ) )
		v_player_origin = e_player.last_valid_position;
	
	v_target_origin = getClosestPointOnNavMesh( v_player_origin, 64, 30 );
	if ( isDefined( v_target_origin ) )
	{
		e_entity setGoal( v_target_origin );
		return 1;
	}
	e_entity setGoal( e_entity.origin );
	return 0;
}

function genesis_mechz_trap_service( e_entity )
{
	if ( IS_TRUE( e_entity.e_mechz_move_to_trap ) || IS_TRUE( e_entity.e_mechz_attack_trap ) )
		return 1;
	
	a_traps = array::get_all_closest( e_entity.origin, getEntArray( "zombie_trap", "targetname" ), undefined, undefined, 240 );
	if ( !isDefined( a_traps ) || !isArray( a_traps ) || a_traps.size <= 0 )
		return 0;
	
	for ( i = 0; i < a_traps.size; i++ )
	{
		if ( !IS_TRUE( a_traps[ i ]._trap_in_use ) || IS_TRUE( a_traps[ i ]._trap_cooling_down ) )
			continue;
		
		a_trap_triggers = array::get_all_closest( e_entity.origin, a_traps[ i ]._trap_use_trigs );
		for ( t = 0; t < a_trap_triggers.size; t++ )
		{
			if ( !e_entity canPath( e_entity.origin, a_trap_triggers[ t ].origin ) )
				continue;
			if ( !isDefined( e_entity.e_mechz_target_trap_trigger ) || isDefined( e_entity.e_mechz_target_trap_trigger ) && ( pathDistance( e_entity.origin, a_trap_triggers[ t ].origin ) <= pathDistance( e_entity.origin, e_entity.e_mechz_target_trap_trigger.origin ) ) )
			{
				e_entity.e_mechz_target_trap = a_traps[ i ];
				e_entity.e_mechz_target_trap_trigger = a_trap_triggers[ t ];
			}
		}
	}
	if ( !isDefined( e_entity.e_mechz_target_trap_trigger ) )
		return 0;
	
	e_entity.e_mechz_move_to_trap = 1;
	e_entity.ignoreall = 1;
	e_entity setGoal( e_entity.e_mechz_target_trap_trigger.origin );
	return 1;
}

function genesis_mechz_vortex_service( e_entity )
{
	return 0;
}

function genesis_mechz_octobomb_service( e_entity )
{
	if ( isDefined( e_entity.destroy_octobomb ) )
	{
		e_entity setGoal( e_entity.destroy_octobomb.origin );
		return 1;
	}
	if ( isDefined( level.octobombs ) )
	{
		foreach ( e_octobomb in level.octobombs )
		{
			if ( isDefined( e_octobomb ) )
			{
				n_dist_sq = distanceSquared( e_octobomb.origin, e_entity.origin );
				if ( n_dist_sq < 360000 )
				{
					e_entity.destroy_octobomb = e_octobomb;
					e_entity setGoal( e_octobomb.origin );
					return 1;
				}
			}
		}
	}
	return 0;
}

function genesis_mechz_should_move_to_trap( e_entity )
{
	if ( IS_TRUE( e_entity.e_mechz_move_to_trap ) )
		return 1;
	
	return 0;
}

function genesis_mechz_is_at_trap( e_entity )
{
	if ( e_entity isAtGoal() )
		return 1;
	
	return 0;
}

function genesis_mechz_should_attack_trap( e_entity )
{
	if ( IS_TRUE( e_entity.e_mechz_attack_trap ) )
		return 1;
	
	return 0;
}

function genesis_mechz_should_octobomb_attack( e_entity )
{
	if ( !isDefined( e_entity.destroy_octobomb ) )
		return 0;
	if ( distanceSquared( e_entity.origin, e_entity.destroy_octobomb.origin ) > 16384 )
		return 0;
	
	n_yaw = abs( zombie_utility::getYawToSpot( e_entity.destroy_octobomb.origin ) );
	if ( n_yaw > 45 )
		return 0;
	
	return 1;
}

function genesis_mechz_trap_move_terminate( e_entity )
{
	e_entity.e_mechz_move_to_trap = 0;
	e_entity.e_mechz_attack_trap = 1;
}

function genesis_mechz_trap_attack_terminate( e_entity )
{
	e_entity.e_mechz_target_trap notify ( "trap_deactivate" );
	e_entity.e_mechz_target_trap_trigger = undefined;
	e_entity.e_mechz_target_trap = undefined;
	e_entity.e_mechz_attack_trap = undefined;
	e_entity.ignoreall = 0;
	mechzBehavior::mechzTargetService( e_entity );
}

function genesis_mechz_destroy_octobomb( e_entity )
{
	if ( isDefined(e_entity.destroy_octobomb ) )
	{
		e_entity.destroy_octobomb detonate();
		e_entity.destroy_octobomb = undefined;
	}
	mechzBehavior::mechzStopFlame( e_entity );
}

function mechzgettanktagservice( e_entity )
{
	return 0;
}

function mechzgetjumpposservice( e_entity )
{
	return 0;
}

function mechzshouldjump( e_entity )
{
	if ( IS_TRUE( e_entity.force_jump ) )
		return 1;
	if ( !isDefined( e_entity.jump_pos ) )
		return 0;
	if ( distanceSquared( e_entity.origin, e_entity.jump_pos.origin ) > 100 )
		return 0;
	
	return 1;
}

function mechzshouldshootflameattank( e_entity )
{
	return 0;
}

function mechzwasknockeddownbytank( e_entity, str_asm_state_name )
{
	return 0;
}

function mechzwasrobotstomped( e_entity, str_asm_state_name )
{
	return IS_TRUE( e_entity.robot_stomped );
}

function mechzshouldshowpain( e_entity )
{
	if ( e_entity.partDestroyed === 1 )
		return 1;
	if ( e_entity.show_pain_from_explosive_dmg === 1 )
		return 1;
	
}

function mechzjumpupactionstart( e_entity, str_asm_state_name )
{
	e_entity setFreeCameraLockOnAllowed( 0 );
	e_entity thread mechz_jump_vo();
	e_entity pathMode( "dont move" );
}

function mechzjumpupactionterminate( e_entity, str_asm_state_name )
{
}

function tombmechzjumphoveraction( e_entity, str_asm_state_name )
{
	return BHTN_SUCCESS;
}

function mechzjumpdownactionstart( e_entity, str_asm_state_name )
{
}

function mechzjumpdownactionterminate( e_entity, str_asm_state_name )
{
	e_entity solid();
	e_entity setFreeCameraLockOnAllowed( 1 );
	e_entity.force_jump = undefined;
	e_entity pathMode( "move allowed" );
}

function mechzrobotstompactionstart( e_entity, str_asm_state_name )
{
}

function mechzrobotstompactionupdate( e_entity, str_asm_state_name )
{
	return BHTN_SUCCESS;
}

function mechzrobotstompactionend( e_entity, str_asm_state_name )
{
}

function mechzshootflameattankactionstart( e_entity, str_asm_state_name )
{
	e_entity.doing_tank_sweep = 1;
	return mechzBehavior::mechzShootFlameActionStart( e_entity, str_asm_state_name );
}

function mechzshootflameattankactionend( e_entity, str_asm_state_name )
{
	e_entity.doing_tank_sweep = undefined;
	return mechzBehavior::mechzShootFlameActionEnd( e_entity, str_asm_state_name );
}

function mechztankknockdownactionstart( e_entity, str_asm_state_name )
{
}

function mechztankknockdownactionupdate( e_entity, str_asm_state_name )
{
	return BHTN_SUCCESS;
}

function mechztankknockdownactionend( e_entity, str_asm_state_name )
{
}

function zm_mechz_should_shoot_claw( e_entity )
{
	if ( !e_entity zm_utility::in_playable_area() )
		return 0;
	if ( !isDefined( e_entity.m_claw_anchor ) )
		return 0;
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	if ( !IS_TRUE( e_entity.has_powercap ) )
		return 0;
	if ( isDefined( e_entity.last_claw_time ) && getTime() - e_entity.last_claw_time < level.mechz_claw_cooldown_time )
		return 0;
	if ( IS_TRUE( e_entity.berserk ) )
		return 0;
	if ( !e_entity mechzServerUtils::mechzCheckInArc() )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < 40000 || n_dist_sq > 1000000 )
		return 0;
	if ( !e_entity.favoriteenemy player_can_be_grabbed() )
		return 0;
	
	str_curr_zone = zm_zonemgr::get_zone_from_position( e_entity.origin + vectorScale( ( 0, 0, 1 ), 36 ) );
	if ( isDefined( str_curr_zone ) && "ug_bottom_zone" == str_curr_zone )
		return 0;
	
	n_clip_mask = 1 | 8;
	v_claw_origin = e_entity.origin + vectorScale( ( 0, 0, 1 ), 65 );
	s_trace = physicsTrace( v_claw_origin, e_entity.favoriteenemy.origin + vectorScale( ( 0, 0, 1 ), 30 ), ( -15, -15, -20 ), ( 15, 15, 40 ), e_entity, n_clip_mask );
	b_can_see = s_trace[ "fraction" ] == 1 || ( isDefined( s_trace[ "entity" ] ) && s_trace[ "entity" ] == e_entity.favoriteenemy );
	if ( !b_can_see )
		return 0;
	
}

function zm_mechz_shoot_claw_action_start( e_entity, str_asm_state_name )
{
	animationStateNetworkUtility::requestState( e_entity, str_asm_state_name );
	zm_mechz_shoot_claw( e_entity );
	return BHTN_RUNNING;
}

function zm_mechz_shoot_claw_action_update( e_entity, str_asm_state_name )
{
	if ( !IS_TRUE( e_entity.b_mech_claw_unlinked ) )
		return BHTN_SUCCESS;
	
	return BHTN_RUNNING;
}

function zm_mechz_shoot_claw_action_end( e_entity, str_asm_state_name )
{
	return BHTN_SUCCESS;
}

function zm_mechz_update_claw( e_entity )
{
}

function zm_mechz_stop_claw( e_entity )
{
}

function trap_attack_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity orientMode( "face angle", e_entity.e_mechz_target_trap_trigger.angles[ 1 ] );
	e_entity animMode( "normal" );
}

function trap_attack_mocomp_terminate( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity orientMode( "face default" );
}

function teleport_traversal_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
}

function face_tank_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
}

function jump_tank_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity animMode( "noclip", 0 );
}

function tomb_mechz_traversal_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity animMode( "noclip", 0 );
	if ( isDefined( e_entity.traverseStartNode ) )
		e_entity orientMode( "face angle", e_entity.traverseStartNode.angles[ 1 ] );
	
	e_entity setRepairPaths( 0 );
	e_entity forceTeleport( e_entity.traverseStartNode.origin, e_entity.traverseStartNode.angles, 0 );
}

function tomb_mechz_traversal_mocomp_terminate( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity setRepairPaths( 1 );
	if ( isDefined( e_entity.traverseEndNode ) )
		e_entity forceTeleport( e_entity.traverseEndNode.origin, e_entity.traverseEndNode.angles, 0 );
	else
	{
		s_query_result = positionQuery_Source_Navigation( e_entity.origin, 0, 64, 20, 4 );
		if ( s_query_result.data.size )
			e_entity forceTeleport( s_query_result.data[ 0 ].origin, e_entity.angles, 0 );
		
	}
	e_entity finishTraversal();
}

function mechznotetrackmuzzleflash( e_entity )
{
	self.b_mech_claw_unlinked = 1;
	self.last_claw_time = getTime();
	e_entity zm_claw_grapple();
	e_entity zm_mechz_claw_cleanup();
	self.last_claw_time = getTime();
}

function mechznotetrackstartft( e_entity )
{
	e_entity notify( "mechz_flamethrower" );
	e_entity clientfield::set( "mechz_ft", 1 );
	e_entity.isShootingFlame = 1;
	e_entity thread mechz_player_flame_damage();
}

function mechznotetrackstopft( e_entity )
{
	e_entity notify( "mechz_flamethrower" );
	e_entity clientfield::set( "mechz_ft", 0 );
	e_entity.isShootingFlame = 0;
	e_entity.nextFlameTime = getTime() + level.mechz_flamethrower_cooldown_time;
	e_entity.stopShootingFlameTime = undefined;
}

// ============================== BEHAVIOR ==============================

// ============================== SPAWN LOGIC ==============================

function mechz_setup()
{
	self.ignorevortices 											= 1;
	self.ignore_round_robbin_death 						= 1;
	self.non_attack_func_takes_attacker 				= 1;
	self.completed_emerging_into_playable_area 	= 1;
	self.goalRadius													= level.mechz_custom_goalradius;
	self.no_widows_wine 										= 1;
	self.no_damage_points 									= 1;
	self.b_ignore_cleanup 										= 1;
	self.is_mechz 													= 1;
	self.health 														= level.mechz_health;
	self.faceplate_health 										= level.mechz_faceplate_health;
	self.powercap_cover_health 							= level.mechz_powercap_cover_health;
	self.powercap_health 										= level.mechz_powercap_health;
	self.left_knee_armor_health 							= level.mechz_armor_health;
	self.right_knee_armor_health 							= level.mechz_armor_health;
	self.left_shoulder_armor_health 						= level.mechz_armor_health;
	self.right_shoulder_armor_health 						= level.mechz_armor_health;
	self.n_boss_health 											= self.health;
	self.heroweapon_kill_power 								= 10;
	self.team 															= level.zombie_team;
	self.faceplate_health 										= level.mechz_health * level.mechz_helmet_health_percentage;
	self.mechz_explosive_dmg_to_cancel_claw 		= level.mechz_health * level.mechz_explosive_dmg_to_cancel_claw_percentage;
	self.powercap_cover_health 							= level.mechz_health * level.mechz_powerplant_expose_health_percentage;
	self.powercap_health 										= level.mechz_health * level.mechz_powerplant_destroyed_health_percentage;
	self.instakill_func 												= &mechz_instakill_override;
	self.thundergun_fling_func 								= &mechz_thundergun_fling;
	self.thundergun_knockdown_func 					= &mechz_thundergun_knockdown;
	self.dragonshield_fling_func 								= &mechz_thundergun_fling;
	self.dragonshield_knockdown_func 					= &mechz_thundergun_knockdown;
	self.bgb_fear_in_headlights_traverse_cb 			= &bgb_fear_in_headlights_traverse_cb;
	self.actor_damage_func 									= &mechz_damage_override;
	self.damage_scoring_function 							= &mechz_damage_scoring;
	self.mechz_melee_knockdown_function 			= &mechz_melee_knockdown_function_override;
	
	self mechz_attach_claw();
	self mechz_setup_armor_states();
	
	self thread zm_spawner::enemy_death_detection();
	self thread mechz_death_event();
	level thread zm_spawner::zombie_death_event( self );
	
	self clientfield::set( "tomb_mech_eye", 1 );
}

function mechz_attach_claw()
{
	if ( self.classname != "actor_spawner_zm_tomb_mechz" )
		return;
	
	self.gun_attached = 0;
	
	self.m_claw_anchor = util::spawn_model( "tag_origin", self getTagOrigin( "tag_claw" ), self getTagAngles( "tag_claw" ) );
	self.m_claw_anchor notSolid();
	self.m_claw_anchor setCanDamage( 0 );
	self.m_claw_anchor.m_claw = util::spawn_model( "c_t7_zm_dlchd_origins_mech_claw", self getTagOrigin( "tag_claw" ), self getTagAngles( "tag_claw" ) );
	self.m_claw_anchor.m_claw notSolid();
	self.m_claw_anchor linkTo( self, "tag_claw" );
	self.m_claw_anchor.m_claw linkTo( self.m_claw_anchor, "tag_origin" );
	self.m_claw_anchor.m_claw useAnimTree( #animtree );
	
	self.m_claw_damage_trigger = util::spawn_model( "p7_chemistry_kit_large_bottle", self getTagOrigin( "tag_claw" ), combineAngles( vectorScale( ( -1, 0, 0 ), 90 ), self getTagAngles( "tag_claw" ) ) );
	self.m_claw_damage_trigger hide();
	self.m_claw_damage_trigger setCanDamage( 1 );
	self.m_claw_damage_trigger.health = 10000;
	self.m_claw_damage_trigger enableLinkTo();
	self.m_claw_damage_trigger linkTo( self, "tag_claw" );
	self thread zm_mechz_claw_damage_trigger_thread();
	self hidePart( "tag_claw" );
}

function mechz_spawning_logic()
{
	level thread enable_mechz_rounds();
	while ( 1 )
	{
		level waittill( "spawn_mechz" );
		while ( level.mechz_left_to_spawn )
		{
			s_loc = get_mechz_spawn_pos();
			if ( !isDefined( s_loc ) )
			{
				wait randomFloatRange( 3, 6 );
				continue;
			}
			ai = zm_ai_mechz::spawn_mechz( s_loc, 1 );
			waitTillFrameEnd;
			level.mechz_left_to_spawn--;
			if ( level.mechz_left_to_spawn == 0 )
				level thread response_to_air_raid_siren_vo();
			
			wait randomFloatRange( 3, 6 );
		}
	}
}

function enable_mechz_rounds()
{
	level.mechz_rounds_enabled = 1;
	level flag::init( "mechz_round" );
	level thread mechz_round_tracker();
}

function mechz_round_tracker()
{
	delay_if_blackscreen_pending();
	
	mech_start_round_num = MECHZ_FIRST_SPAWN_ROUND;
	if ( IS_TRUE( level.is_forever_solo_game ) )
		mech_start_round_num = MECHZ_FIRST_SPAWN_ROUND_SOLO;
	
	while ( level.round_number < mech_start_round_num )
		level waittill( "between_round_over" );
	
	level.next_mechz_round = level.round_number;
	while ( 1 )
	{
		if ( IS_TRUE( level.dog_rounds_allowed ) && isDefined( level.next_dog_round ) && level.next_mechz_round == level.next_dog_round )
		{
			level.next_mechz_round++;
			continue;
		}
		if ( level.next_mechz_round <= level.round_number )
		{
			a_zombies = getAISpeciesArray( level.zombie_team, "all" );
			foreach ( zombie in a_zombies )
			{
				if ( IS_TRUE( zombie.is_mechz ) && isAlive( zombie ) )
				{
					level.next_mechz_round++;
					break;
				}
			}
		}
		if ( level.mechz_left_to_spawn == 0 && level.next_mechz_round <= level.round_number )
		{
			mechz_health_increases();
			
			level.mechz_left_to_spawn = level.mechz_zombie_per_round;
			mechz_spawning = level.mechz_left_to_spawn;
			wait randomFloatRange( 10, 15 );
			level notify( "spawn_mechz" );
			if ( IS_TRUE( level.is_forever_solo_game ) )
				n_round_gap = randomIntRange( level.mechz_min_round_fq_solo, level.mechz_max_round_fq_solo );
			else
				n_round_gap = randomIntRange( level.mechz_min_round_fq, level.mechz_max_round_fq );
			
			level.next_mechz_round = level.round_number + n_round_gap;
			level.mechz_round_count++;
			level.num_mechz_spawned = level.num_mechz_spawned + mechz_spawning;
			
			level.mechz_zombie_per_round++;
			if ( level.mechz_zombie_per_round > MECHZ_ZOMBIE_MAX_PER_ROUND )
				level.mechz_zombie_per_round = MECHZ_ZOMBIE_MAX_PER_ROUND;
		}
		level waittill( "between_round_over" );
	}
}

function spawn_mechz( s_location, b_flyin )
{
	if ( !IS_TRUE( b_flyin ) )
		b_flyin = 0;
	
	if ( !isDefined( level.mechz_spawners ) || !isDefined( level.mechz_spawners[ 0 ] ) )
		return undefined;
	
	e_spawner = array::random( level.mechz_spawners );
	
	if ( isDefined( level.mechz_pre_spawn ) )
		[ [ level.mechz_pre_spawn ] ]();
	
	e_ai = zombie_utility::spawn_zombie( e_spawner, e_spawner.targetname, s_location );
	if ( !isDefined( e_ai ) )
		return undefined;
	
	s_query_result = positionQuery_Source_Navigation( s_location.origin, 0, 32, 20, 4 );
	if ( s_query_result.data.size )
		v_ground_position = array::random( s_query_result.data ).origin;
	if ( !isDefined( v_ground_position ) )
		v_ground_position = bulletTrace( s_location.origin, s_location.origin + vectorScale( ( 0, 0, -1 ), 256 ), 0, s_location )[ "position" ];
	
	if ( isDefined( level.mechz_post_spawn ) )
		e_ai thread [ [ level.mechz_post_spawn ] ]();
	
	e_ai forceTeleport( v_ground_position, zm_utility::flat_angle( vectorToAngles( vectorNormalize( zm_utility::get_closest_player( s_location.origin ).origin - s_location.origin ) ) ) );
	if ( IS_TRUE( b_flyin ) )
	{
		e_ai thread mechz_flyin_complete_logic();
		e_ai thread scene::play( "cin_zm_castle_mechz_entrance", e_ai );
		e_ai thread mechz_do_damage_on_landing( v_ground_position );
		e_ai thread mechz_flame_damage_on_landing( v_ground_position );
	}
	else 
	{
		e_ai.b_flyin_done = 1;
		if( isDefined( level.mechz_custom_spawn_func ) )
			e_ai thread [ [ level.mechz_custom_spawn_func ] ]( s_location );
	
	}
	e_ai thread mechz_ambient_vocals();
	
	return e_ai;
}

// ============================== SPAWN LOGIC ==============================

// ============================== CALLBACKS ==============================

function mechz_flamethrower_ai( e_mechz )
{
	e_flame_trigger = e_mechz.flameTrigger;
	a_zombies = array::filter( getAIArchetypeArray( "zombie" ), 0, &zm_elemental_zombie::is_not_elemental_zombie );
	foreach ( e_zombie in a_zombies )
	{
		if ( e_zombie isTouching( e_flame_trigger ) && e_zombie.b_is_keeper_zombie !== 1 )
			e_zombie zm_elemental_zombie::make_napalm_zombie();
		
	}
}

function zm_mechz_left_arm_damage()
{
	if ( self.classname != "actor_spawner_zm_tomb_mechz" )
		return;
	
	if ( isDefined( self.e_grabbed ) )
		self thread zm_mechz_claw_release( 1 );
	
}

function mechz_staff_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time, n_bone_index, n_model_index )
{
	return 0;
}

// ============================== CALLBACKS ==============================

// ============================== EVENT OVERRIDES ==============================

function mechz_death_event()
{
	self waittill( "death" );
	
	if ( isDefined( self.flameTrigger ) )
		self.flameTrigger delete();
	
	if ( isPlayer( self.attacker ) )
	{
		if ( !IS_TRUE( self.deathpoints_already_given ) )
		{
			a_players = level.players;
			for ( i = 0; i < a_players.size; i++ )
			{
				if ( zm_utility::is_player_valid( a_players[ i ] ) && !a_players[ i ] laststand::player_is_in_laststand() )
				{
					a_players[ i ] zm_score::add_to_player_score( level.mechz_points_for_team );
					if ( isDefined( self.attacker ) && a_players[ i ] == self.attacker )
						a_players[ i ] zm_score::add_to_player_score( level.mechz_points_for_killer );
					
				}
			}
			
		}
		if ( isDefined( level.hero_power_update ) )
			[ [ level.hero_power_update ] ]( self.attacker, self );
		
		level notify( "mechz_killed", self.origin );
		if ( level flag::get( "zombie_drop_powerups" ) && !IS_TRUE( self.no_powerups ) )
		{
			str_type = array::random( MECHZ_POWERUPS_ON_DEATH );
			zm_powerups::specific_powerup_drop( str_type, self.origin );
		}
	}
	
	self clientfield::set( "tomb_mech_eye", 0 );
	
	if ( IS_TRUE( self.has_faceplate ) )
	{
		self mechzServerUtils::hide_part( MECHZ_TAG_FACEPLATE );
		self clientfield::set( "mechz_faceplate_detached", ( self.classname == "actor_spawner_zm_tomb_mechz" ? 2 : 1 ) );
	}
	if ( IS_TRUE( self.powercap_covered ) )
	{
		self mechzServerUtils::hide_part( MECHZ_TAG_POWERSUPPLY );
		self clientfield::set( "mechz_powercap_detached", 1 );
	}
	if ( self.classname == "actor_spawner_zm_tomb_mechz" && isDefined( self.m_claw_anchor ) && isDefined( self.m_claw_anchor.m_claw ) )
	{
		self.m_claw_anchor unlink();
		self.m_claw_anchor.m_claw unlink();
		self.m_claw_anchor delete();
		self.m_claw_anchor.m_claw delete();
		self clientfield::set( "mechz_claw_detached", 2 );
		
	}
	else if ( IS_TRUE( self.gun_attached ) )
	{
		self mechzServerUtils::hide_part( MECHZ_TAG_CLAW );
		self clientfield::set( "mechz_claw_detached", 1 );
	}
	if ( isDefined( self.m_claw_damage_trigger ) )
	{
		self.m_claw_damage_trigger unlink();
		self.m_claw_damage_trigger delete();
	}
	self mechzServerUtils::mechz_turn_off_headlamp( 1 );
	
	self waittill( "overload_start" );
	
	playFxOnTag( level._effect[ "mechz_death" ], self, "tag_origin" );
		
	self waittill( "self_explode" );
	
	v_origin = self.origin;
			
	a_ai = getAISpeciesArray( level.zombie_team );
	a_ai_kill_zombies = arraySortClosest( a_ai, v_origin, 18, 0, 200 );
	foreach ( ai_enemy in a_ai_kill_zombies )
	{
		if ( isDefined( ai_enemy ) )
		{
			if ( ai_enemy.archetype === "mechz" )
				ai_enemy doDamage( level.mechz_health * .25, v_origin );
			else
				ai_enemy doDamage( ai_enemy.health + 100, v_origin );
			
		}
		wait .05;
	}
	self ghost();
}

function mechz_player_damage( e_inflictor, e_attacker, n_i_damage, n_id_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_ps_offset_time )
{
	if ( isDefined( e_attacker ) && e_attacker.archetype === "mechz" && str_means_of_death === "MOD_MELEE" )
		return 150;
	
	return -1;
}

function mechz_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time, n_bone_index )
{
	if ( isDefined( self.b_flyin_done ) && !IS_TRUE( self.b_flyin_done ) )
		return 0;
	
	n_num_tiers = level.mechz_armor_info.size + 1;
	n_old_health_tier = int( n_num_tiers * self.health / level.mechz_health );
	str_bone_name = getPartName( self.model, n_bone_index );
	if ( isDefined( e_attacker ) && isAlive( e_attacker ) && isPlayer( e_attacker ) && ( level.zombie_vars[ e_attacker.team ][ "zombie_insta_kill" ] || IS_TRUE( e_attacker.personal_instakill ) ) )
	{
		n_mechz_damage_percent = 1;
		n_mechz_headshot_modifier = 2;
	}
	else
	{
		n_mechz_damage_percent = level.mechz_damage_percent;
		n_mechz_headshot_modifier = 1;
	}
	if ( isDefined( w_weapon ) && w_weapon.weapClass == "spread" )
	{
		n_mechz_damage_percent = n_mechz_damage_percent * level.mechz_shotgun_damage_mod;
		n_mechz_headshot_modifier = n_mechz_headshot_modifier * level.mechz_shotgun_damage_mod;
	}
	
	if ( n_damage <= 10 )
		n_mechz_damage_percent = 1;
	
	if ( zm_utility::is_explosive_damage( str_means_of_death ) || isSubStr( w_weapon.name, "staff" ) )
	{
		if ( n_mechz_damage_percent < .5 )
			n_mechz_damage_percent = .5;
		if ( !IS_TRUE( self.has_faceplate ) && isSubStr( w_weapon.name, "staff" ) && n_mechz_damage_percent < 1 )
			n_mechz_damage_percent = 1;
		
		n_final_damage = n_damage * n_mechz_damage_percent;
		
		if ( !isDefined( self.explosive_dmg_taken ) )
			self.explosive_dmg_taken = 0;
		
		self.explosive_dmg_taken = self.explosive_dmg_taken + n_final_damage;
		self mechzServerUtils::mechz_track_faceplate_damage( n_final_damage );
		
		if ( isDefined( level.mechz_explosive_damage_reaction_callback ) )
			[ [ level.mechz_explosive_damage_reaction_callback ] ]();
		
		e_attacker mechzServerUtils::show_hit_marker();
	}
	else
	{
		n_final_damage = n_damage * n_mechz_damage_percent;
		if ( str_hit_loc === "torso_upper" )
		{
			if ( IS_TRUE( self.has_faceplate ) )
			{
				v_faceplate_pos = self getTagOrigin( "j_faceplate" );
				n_dist_sq = distanceSquared( v_faceplate_pos, v_point );
				if ( n_dist_sq <= 144 )
					self MechzServerUtils::mechz_track_faceplate_damage( n_final_damage );
				
				n_headlamp_dist_sq = distanceSquared( v_point, self getTagOrigin( "tag_headlamp_FX" ) );
				if ( n_headlamp_dist_sq <= 9 )
					self mechzServerUtils::mechz_turn_off_headlamp( 1 );
				
			}
			if ( str_bone_name == "tag_powersupply" || str_bone_name == "tag_powersupply_hit" )
			{
				if ( IS_TRUE( self.powercap_covered ) )
					self mechzServerUtils::mechz_track_powercap_cover_damage( n_final_damage );
				else if ( IS_TRUE( self.has_powercap ) )
					self mechzServerUtils::mechz_track_powercap_damage( n_final_damage );
				
			}
		}
		else if( isDefined( self.e_grabbed ) && ( str_hit_loc === "left_hand" || str_hit_loc === "left_arm_lower" || str_hit_loc === "left_arm_upper" ) )
		{
			if ( isDefined( self.e_grabbed ) )
				self.show_pain_from_explosive_dmg = 1;
			if ( isDefined( level.mechz_left_arm_damage_callback ) )
				self [ [ level.mechz_left_arm_damage_callback ] ]();
			
		}
		else if ( str_hit_loc == "head" )
			n_final_damage = n_damage * n_mechz_headshot_modifier;
		
		e_attacker mechzServerUtils::show_hit_marker();
	}
	if ( !isDefined( w_weapon ) || w_weapon.name == "none" )
		if ( !isPlayer( e_attacker ) )
			n_final_damage = 0;
		
	n_new_health_tier = int( n_num_tiers * ( self.health - n_final_damage ) / level.mechz_health );
	if ( n_old_health_tier > n_new_health_tier )
	{
		while ( n_old_health_tier > n_new_health_tier )
		{
			if ( n_old_health_tier < n_num_tiers )
				self mechz_launch_armor_piece();
			
			n_old_health_tier--;
		}
	}
	return n_final_damage;
}

function mechz_thundergun_fling( e_player, gib )
{
	self endon( "death" );
	self mechz_thundergun_damage( e_player );
	if ( !IS_TRUE( self.stun ) && self.stumble_stun_cooldown_time < getTime() )
		self.stun = 1;
	
}

function mechz_thundergun_knockdown( e_player, gib )
{
	self endon( "death" );
	self mechz_thundergun_damage( e_player );
	if ( !IS_TRUE( self.stun ) && self.stumble_stun_cooldown_time < getTime() )
		self.stun = 1;
	
}

function bgb_fear_in_headlights_traverse_cb()
{
	if ( isDefined( self.customTraverseEndNode ) && isDefined( self.customTraverseStartNode ) )
		return self.customTraverseEndNode.script_noteworthy === "custom_traversal" && self.customTraverseStartNode.script_noteworthy === "custom_traversal";
	
	return 0;
}

function mechz_instakill_override( e_player, str_mod, str_hit_location )
{
	return 1;
}

function mechz_damage_scoring( inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex )
{
	if ( isDefined( attacker ) && isPlayer( attacker ) )
	{
		if ( zm_spawner::player_using_hi_score_weapon( attacker ) )
			damage_type = "damage";
		else
			damage_type = "damage_light";
		
		if ( !IS_TRUE( self.no_damage_points ) )
			attacker zm_score::player_add_points( damage_type, mod, hitLoc, self.isdog, self.team, weapon );
		
	}
}

// ============================== EVENT OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function delay_if_blackscreen_pending()
{
	while ( !flag::exists( "initial_blackscreen_passed" ) )
		WAIT_SERVER_FRAME;
	
	if ( !flag::get( "initial_blackscreen_passed" ) )
		level flag::wait_till( "initial_blackscreen_passed" );
	
}

function mechz_setup_armor_pieces()
{
	level.mechz_armor_info 							= [];
	level.mechz_armor_info[ 0 ] 					= spawnStruct();
	level.mechz_armor_info[ 0 ].model 		= "c_zom_mech_armor_knee_left";
	level.mechz_armor_info[ 0 ].tag 			= "j_knee_attach_le";
	level.mechz_armor_info[ 0 ].clientfield 	= "mechz_lknee_armor_detached";
	level.mechz_armor_info[ 1 ] 					= spawnStruct();
	level.mechz_armor_info[ 1 ].model 		= "c_zom_mech_armor_knee_right";
	level.mechz_armor_info[ 1 ].tag 			= "j_knee_attach_ri";
	level.mechz_armor_info[ 1 ].clientfield 	= "mechz_rknee_armor_detached";
	level.mechz_armor_info[ 2 ] 					= spawnStruct();
	level.mechz_armor_info[ 2 ].model 		= "c_zom_mech_armor_shoulder_left";
	level.mechz_armor_info[ 2 ].tag 			= "j_shoulderarmor_le";
	level.mechz_armor_info[ 2 ].clientfield 	= "mechz_lshoulder_armor_detached";
	level.mechz_armor_info[ 3 ] 					= spawnStruct();
	level.mechz_armor_info[ 3 ].model 		= "c_zom_mech_armor_shoulder_right";
	level.mechz_armor_info[ 3 ].tag 			= "j_shoulderarmor_ri";
	level.mechz_armor_info[ 3 ].clientfield 	= "mechz_rshoulder_armor_detached";
}

function mechz_setup_armor_states()
{
	self.armor_states = [];
	foreach ( armor_info in level.mechz_armor_info )
	{
		armor_state = spawnStruct();
		armor_state.index = self.armor_states.size;
		armor_state.tag = armor_info.tag;
		armor_state.clientfield = armor_info.clientfield;
		if ( !isDefined( self.armor_states ) )
			self.armor_states = [];
		else if ( !isArray( self.armor_states) )
			self.armor_states = array( self.armor_states );
		
		self.armor_states[ self.armor_states.size ] = armor_state;
	}
	self.armor_states = array::randomize( self.armor_states );
}

function mechz_launch_armor_piece()
{
	if ( !isDefined( self.next_armor_piece ) )
		self.next_armor_piece = 0;
	if ( !isDefined( self.armor_states ) || self.next_armor_piece >= self.armor_states.size )
		return;
	
	self mechzServerUtils::hide_part( self.armor_states[ self.next_armor_piece ].tag );
	self clientfield::set( self.armor_states[ self.next_armor_piece ].clientfield, 1 );
	self.next_armor_piece++;
}

function zm_mechz_shoot_claw( e_entity )
{
	e_entity thread zm_mechz_kill_claw_watcher();
	level flag::set( "mechz_launching_claw" );
}

function player_can_be_grabbed()
{
	if ( self getStance() == "prone" )
		return 0;
	if ( !zm_utility::is_player_valid( self ) )
		return 0;
	
	return 1;
}

function zm_mechz_kill_claw_watcher()
{
	self endon( "claw_complete" );
	self util::waittill_either( "death", "kill_claw" );
	self zm_mechz_claw_cleanup();
}

function zm_claw_grapple()
{
	self endon( "death" );
	self endon( "kill_claw" );
	if ( !isDefined( self.favoriteenemy ) )
		return;
	
	self.m_claw_anchor.m_claw thread animation::play( "ai_zombie_mech_grapple_arm_open_idle", undefined, undefined, 1, 0 );
	self.m_claw_anchor unlink();
	self.m_claw_anchor.angles = vectorToAngles( self.origin - self.favoriteenemy.origin );
	self.m_claw_anchor.fx_ent = util::spawn_model( "tag_origin", self.m_claw_anchor.m_claw getTagOrigin( "tag_claw" ), self.m_claw_anchor.m_claw getTagAngles( "tag_claw" ) );
	self.m_claw_anchor.fx_ent setCanDamage( 0 );
	self.m_claw_anchor.fx_ent notSolid();
	self.m_claw_anchor.fx_ent linkTo( self.m_claw_anchor.m_claw, "tag_claw" );
	self.m_claw_anchor.fx_ent clientfield::set( "mechz_claw", 1 );
	self clientfield::set( "mechz_wpn_source", 1 );
	v_enemy_origin = self.favoriteenemy.origin + vectorScale( ( 0, 0, 1 ), 36 );
	n_dist = distance( self getTagOrigin( "tag_claw" ), v_enemy_origin );
	self playSound( "zmb_ai_mechz_claw_fire" );
	self.m_claw_anchor moveTo( v_enemy_origin, n_dist / 1200 );
	self.m_claw_anchor thread zm_check_for_claw_move_complete();
	self.m_claw_anchor playLoopSound( "zmb_ai_mechz_claw_loop_out", .1 );
	self.e_grabbed = undefined;
	do
	{
		a_players = getPlayers();
		foreach( e_player in a_players )
		{
			if ( !zm_utility::is_player_valid( e_player, 1, 1 ) || !e_player player_can_be_grabbed() )
				continue;
			
			if ( distanceSquared( e_player.origin + vectorScale( ( 0, 0, 1 ), 36 ), self.m_claw_anchor.origin ) < 2304 )
			{
				v_mechz_claw_start_origin = self.origin + vectorScale( ( 0, 0, 1 ), 65 );
				a_trace = physicsTrace( v_mechz_claw_start_origin, e_player.origin + vectorScale( ( 0, 0, 1 ), 30 ), ( -15, -15, -20 ), ( 15, 15, 40 ), self, 1 | 8 );
				if ( a_trace[ "fraction" ] == 1 || !isDefined( a_trace[ "entity" ] ) || a_trace[ "entity" ] != e_player )
					continue;
				
				// if ( a_trace[ "fraction" ] == 1 )
				// 	continue;
				// if ( a_trace[ "fraction" ] == 1 )
				// 	continue;
				
				if ( IS_TRUE( e_player.hasRiotShield ) && IS_TRUE( e_player.hasRiotShieldEquipped ) )
				{
					e_player riotshield::player_damage_shield( level.zombie_vars[ "riotshield_hit_points" ] - 1, 1 );
					wait 1;
					e_player riotshield::player_damage_shield( 1, 1 );
				}
				else
				{
					self.e_grabbed = e_player;
					self.e_grabbed clientfield::set_to_player( "mechz_grab", 1 );
					self.e_grabbed playerLinkToDelta( self.m_claw_anchor.m_claw, "tag_attach_player" );
					self.e_grabbed setPlayerAngles( vectorToAngles( self.origin - self.e_grabbed.origin ) );
					self.e_grabbed playSound( "zmb_ai_mechz_claw_grab" );
					self.e_grabbed setStance( "stand" );
					self.e_grabbed allowCrouch( 0 );
					self.e_grabbed allowProne( 0 );
					self.e_grabbed thread zm_mechz_grabbed_played_vo( self );
					if ( !level flag::get( "mechz_claw_move_complete" ) )
						self.m_claw_anchor moveTo( self.m_claw_anchor.origin, .05 );
					
				}
				break;
			}
		}
		wait .05;
	}
	while ( !level flag::get( "mechz_claw_move_complete" ) && !isDefined( self.e_grabbed ) );
	if ( !isDefined( self.e_grabbed ) )
	{
		foreach ( ai_zombie in zombie_utility::get_round_enemy_array() )
		{
			if ( !isAlive( ai_zombie ) || IS_TRUE( ai_zombie.is_giant_robot ) || IS_TRUE( ai_zombie.is_mechz ) )
				continue;
			
			if ( distanceSquared( ai_zombie.origin + vectorScale( ( 0, 0, 1 ), 36 ), self.m_claw_anchor.origin ) < 2304 )
			{
				self.e_grabbed = ai_zombie;
				self.e_grabbed linkTo( self.m_claw_anchor.m_claw, "tag_attach_player", ( 0, 0, 0 ) );
				self.e_grabbed.mechz_grabbed_by = self;
				break;
			}
		}
	}
	self.m_claw_anchor.m_claw stopAnimScripted( .2 );
	self.m_claw_anchor.m_claw thread animation::play( "ai_zombie_mech_grapple_arm_closed_idle", undefined, undefined, 1, .2 );
	wait .5;
	
	self zm_mechz_claw_explosive_watcher();
	self.m_claw_anchor moveTo( self getTagOrigin( "tag_claw" ), max( .05, ( isDefined( self.e_grabbed ) ? n_dist / 200 : n_dist / 1000 ) ) );
	self.m_claw_anchor playLoopSound( "zmb_ai_mechz_claw_loop_in", .1 );
	
	self.m_claw_anchor waittill( "movedone" );
	
	v_claw_angles = self getTagAngles( "tag_claw" );
	self.m_claw_anchor playSound( "zmb_ai_mechz_claw_back" );
	self.m_claw_anchor stopLoopSound( 1 );
	if ( zm_audio::sndIsNetworkSafe() )
		self playSound( "zmb_ai_mechz_vox_angry" );
	
	self.m_claw_anchor.origin = self getTagOrigin( "tag_claw" );
	self.m_claw_anchor.angles = self getTagAngles( "tag_claw" );
	self.m_claw_anchor linkTo( self, "tag_claw", ( 0, 0, 0 ) );
	self.m_claw_anchor.fx_ent delete();
	self.m_claw_anchor.fx_ent = undefined;
	self clientfield::set( "mechz_wpn_source", 0 );
	level flag::clear( "mechz_launching_claw" );
	if ( isDefined( self.e_grabbed ) )
	{
		if ( isPlayer( self.e_grabbed ) && zm_utility::is_player_valid( self.e_grabbed ) )
			self.e_grabbed thread mechz_unlink_on_laststand( self );
		else if ( isAi( self.e_grabbed ) )
			self.e_grabbed thread zm_mechz_zombie_flamethrower_gib( self );
		
		self thread mechz_check_for_claw_damaged( self.e_grabbed );
		self animScripted( "flamethrower_anim", self.origin, self.angles, "ai_zombie_mech_ft_burn_player" );
		self zombie_shared::doNoteTracks( "flamethrower_anim" );
	}
	level flag::clear( "mechz_claw_move_complete" );
}

function zm_mechz_claw_cleanup()
{
	self zm_mechz_claw_release();
	if ( isDefined( self.m_claw_anchor ) )
	{
		self.m_claw_anchor.m_claw stopAnimScripted( .2 );
		if ( isDefined( self.m_claw_anchor.fx_ent ) )
		{
			self.m_claw_anchor.fx_ent delete();
			self.m_claw_anchor.fx_ent = undefined;
		}
		if ( !IS_TRUE( self.has_powercap ) )
		{
			self zm_mechz_claw_detach();
			level flag::clear( "mechz_launching_claw" );
		}
		else if ( !self.m_claw_anchor isLinkedTo( self ) )
		{
			self.m_claw_anchor moveTo( self getTagOrigin( "tag_claw" ), max( .05, distance( self.m_claw_anchor.origin, self getTagOrigin( "tag_claw" ) ) / 1000 ) );
			self.m_claw_anchor playLoopSound( "zmb_ai_mechz_claw_loop_in", .1 );
			self.m_claw_anchor waittill( "movedone" );
			self.m_claw_anchor playSound( "zmb_ai_mechz_claw_back" );
			self.m_claw_anchor stopLoopSound( 1 );
			self.m_claw_anchor.origin = self getTagOrigin( "tag_claw" );
			self.m_claw_anchor.angles = self getTagAngles( "tag_claw" );
			self.m_claw_anchor.m_claw stopAnimScripted( .2 );
			self.m_claw_anchor linkTo( self, "tag_claw", ( 0, 0, 0 ) );
		}
	}
	self notify( "claw_complete" );
	self.b_mech_claw_unlinked = 0;
}

function zm_mechz_claw_release( b_open_claw )
{
	self.explosive_dmg_taken_on_grab_start = undefined;
	if ( isDefined( self.e_grabbed ) )
	{
		if ( isPlayer( self.e_grabbed ) )
		{
			self.e_grabbed clientfield::set_to_player( "mechz_grab", 0 );
			self.e_grabbed allowCrouch( 1 );
			self.e_grabbed allowProne( 1 );
		}
		if ( !isDefined( self.e_grabbed._fall_down_anchor ) )
		{
			self.e_grabbed unlink();
			self.e_grabbed setOrigin( playerPhysicsTrace( self.e_grabbed.origin + vectorScale( ( 0, 0, 1 ), 70 ), self.e_grabbed.origin + vectorScale( ( 0, 0, -1 ), 500 ) ) + vectorScale( ( 0, 0, 1 ), 24 ) );
		}
		self.e_grabbed = undefined;
		if ( IS_TRUE( b_open_claw ) )
			self.m_claw_anchor.m_claw thread animation::play( "ai_zombie_mech_grapple_arm_open_idle", undefined, undefined, 1, .2 );
		
		if ( self IsPlayingAnimScripted() )
		{
			self mechznotetrackstopft( self );
			self stopAnimScripted();
		}
	}
}

function zm_mechz_claw_detach()
{
	if ( isDefined( self.m_claw_anchor ) )
	{
		self.m_claw_anchor.m_claw thread animation::play( "ai_zombie_mech_grapple_arm_open_idle", undefined, undefined, 1, .2 );
		if ( isDefined( self.m_claw_anchor.fx_ent ) )
			self.m_claw_anchor.fx_ent delete();
		
		self.m_claw_anchor.m_claw unlink();
		self.m_claw_anchor unlink();
		self.m_claw_anchor.m_claw physicsLaunch( self.m_claw_anchor.m_claw.origin, ( 0, 0, -1 ) );
		self.m_claw_anchor thread zm_mechz_delayed_item_delete();
		self.m_claw_anchor.m_claw thread zm_mechz_delayed_item_delete();
		self.m_claw_anchor = undefined;
	}
	if ( isDefined( self.m_claw_damage_trigger ) )
	{
		self.m_claw_damage_trigger unlink();
		self.m_claw_damage_trigger delete();
		self.m_claw_damage_trigger = undefined;
	}
}

function zm_mechz_delayed_item_delete()
{
	wait 30;
	self delete();
}

function mechz_jump_vo()
{
	a_players = getPlayers();
	foreach ( e_player in a_players )
	{
		if ( distanceSquared( self.origin, e_player.origin ) < 1000000 )
		{
			if ( e_player zm_utility::is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), .5 ) )
			{
				if ( !IS_TRUE( e_player.dontspeak ) )
				{
					e_player util::delay( 3, undefined, &zm_audio::create_and_play_dialog, "general", "rspnd_mech_jump" );
					return;
				}
			}
		}
	}
}

function mechz_check_for_claw_damaged( e_player )
{
	e_player endon( "death" );
	e_player endon( "disconnect" );
	self endon( "death" );
	self endon( "claw_complete" );
	self endon( "kill_claw" );
	self thread mechz_claw_damaged_endon_watcher( e_player );
	e_player thread mechz_claw_damaged_player_endon_watcher( self );
	self.m_claw_anchor.m_claw setCanDamage( 1 );
	while ( isDefined( self.e_grabbed ) )
	{
		self.m_claw_anchor.m_claw waittill( "damage", n_amount, e_inflictor, v_direction, v_point, str_mod, str_tag_name, str_model_name, str_part_name, w_weapon, n_flags );
		if ( zm_utility::is_player_valid( e_inflictor ) )
		{
			self doDamage( 1, e_inflictor.origin, e_inflictor, e_inflictor, "left_hand", str_mod );
			self.m_claw_anchor.m_claw setCanDamage( 0 );
			self notify( "claw_damaged" );
			break;
		}
	}
}

function mechz_claw_damaged_endon_watcher( e_player )
{
	self endon( "claw_damaged" );
	e_player endon( "death" );
	e_player endon( "disconnect" );
	self util::waittill_any( "death", "claw_complete", "kill_claw" );
	if ( isDefined( self ) && isDefined( self.m_claw_anchor ) && isDefined( self.m_claw_anchor.m_claw ) )
		self.m_claw_anchor.m_claw setCanDamage( 0 );
	
}

function mechz_claw_damaged_player_endon_watcher( e_mechz )
{
	e_mechz endon( "claw_damaged" );
	e_mechz endon( "death" );
	e_mechz endon( "claw_complete" );
	e_mechz endon( "kill_claw" );
	self util::waittill_any( "death", "disconnect" );
	if ( isDefined( e_mechz ) && isDefined( e_mechz.m_claw_anchor ) && isDefined( e_mechz.m_claw_anchor.m_claw ) )
		e_mechz.m_claw_anchor.m_claw setCanDamage( 0 );
	
}

function mechz_unlink_on_laststand( e_mechz )
{
	self endon( "death" );
	self endon( "disconnect" );
	e_mechz endon( "death" );
	e_mechz endon( "claw_complete" );
	e_mechz endon( "kill_claw" );
	while ( 1 )
	{
		if ( isDefined( self ) && self laststand::player_is_in_laststand() )
		{
			e_mechz thread zm_mechz_claw_release();
			return;
		}
		wait .05;
	}
}

function zm_mechz_zombie_flamethrower_gib( e_mechz )
{
	e_mechz waittillmatch( "flamethrower_anim" );
	if ( isAlive( self ) )
	{
		self doDamage( self.health, self.origin, self );
		self zombie_utility::gib_random_parts();
		gibServerUtils::annihilate( self );
	}
}

function zm_check_for_claw_move_complete()
{
	self waittill( "movedone" );
	wait .05;
	level flag::set( "mechz_claw_move_complete" );
}

function zm_mechz_grabbed_played_vo( e_mechz )
{
	self endon( "disconnect" );
	self zm_audio::create_and_play_dialog( "general", "mech_grab" );
	while ( isDefined( self ) && IS_TRUE( self.isSpeaking ) )
		wait .1;
	
	wait 1;
	if ( isAlive( e_mechz ) && isDefined( e_mechz.e_grabbed ) )
		e_mechz thread play_shoot_arm_hint_vo();
	
}

function play_shoot_arm_hint_vo()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( !isDefined( self.e_grabbed ) )
			return;
		
		a_players = getPlayers();
		foreach ( e_player in a_players )
		{
			if ( e_player == self.e_grabbed )
				continue;
			
			if ( distanceSquared( self.origin, e_player.origin ) < 1000000 )
			{
				if ( e_player util::is_player_looking_at( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), .75 ) )
				{
					if ( !IS_TRUE( e_player.dontspeak ) )
					{
						e_player zm_audio::create_and_play_dialog( "general", "shoot_mech_arm" );
						return;
					}
				}
			}
		}
		wait .1;
	}
}

function zm_mechz_claw_explosive_watcher()
{
	if ( !isDefined( self.explosive_dmg_taken ) )
		self.explosive_dmg_taken = 0;
	
	self.explosive_dmg_taken_on_grab_start = self.explosive_dmg_taken;
}

function mechz_player_flame_damage()
{
	self endon( "death" );
	self endon( "mechz_flamethrower" );
	while ( 1 )
	{
		a_players = getPlayers();
		foreach ( e_player in a_players )
		{
			if ( !IS_TRUE( e_player.is_burning ) )
				if ( e_player isTouching( self.flameTrigger ) )
					e_player thread mechzBehavior::playerFlameDamage( self );
				
		}
		wait .05;
	}
}

function mechz_is_stunned()
{
	if ( !IS_TRUE( self.stun ) && self.stumble_stun_cooldown_time < getTime() )
		return 1;
	
	return 0;
}

function mechz_thundergun_damage( e_player )
{
	n_mechz_max_health = level.mechz_health;
	if ( isDefined( level.mechz_max_thundergun_damage ) )
		n_mechz_max_health = math::clamp( n_mechz_max_health, 0, level.mechz_max_thundergun_damage );
	
	n_damage = n_mechz_max_health * .25 / .2;
	self doDamage( n_damage, self getCentroid(), e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, getWeapon( "thundergun" ) );
}

function zm_mechz_claw_damage_trigger_thread()
{
	self endon( "death" );
	self.m_claw_damage_trigger endon( "death" );
	while ( 1 )
	{
		self.m_claw_damage_trigger waittill( "damage", amount, inflictor, direction, point, type, tagName, modelName, partName, weaponName, iDFlags );
		
		self.m_claw_damage_trigger.health = 10000;
		if ( self.m_claw_anchor isLinkedTo( self ) )
			continue;
		
		if ( zm_utility::is_player_valid( inflictor ) )
		{
			self doDamage( 1, inflictor.origin, inflictor, inflictor, "left_hand", type );
			self.m_claw_anchor.m_claw setCanDamage( 0 );
			self notify( "claw_damaged" );
		}
	}
}

function mechz_flyin_complete_logic()
{
	self endon( "death" );
	self.b_flyin_done = 0;
	self.bgbIgnoreFearInHeadlights = 1;
	self util::waittill_any( "mechz_flyin_done", "scene_done" );
	self.b_flyin_done = 1;
	self.bgbIgnoreFearInHeadlights = 0;
}

function mechz_do_damage_on_landing( v_mech_land_origin )
{
	self endon( "death" );
	n_kill_distance = 2304;
	n_scale_sq = 2250000;
	self waittill( "do_damage_on_landing" );
	a_zombies = getAIArchetypeArray( "zombie" );
	foreach( e_zombie in a_zombies )
	{
		n_distance_sq = distanceSquared( e_zombie.origin, v_mech_land_origin );
		if ( n_distance_sq <= n_kill_distance )
			e_zombie kill();
		
	}
	a_players = getPlayers();
	foreach ( e_player in a_players )
	{
		n_distance_sq = distanceSquared( e_player.origin, v_mech_land_origin );
		if ( n_distance_sq <= n_kill_distance )
			e_player doDamage( 100, v_mech_land_origin, self, self );
		
		n_scale = n_scale_sq - n_distance_sq / n_scale_sq;
		if ( n_scale <= 0 || n_scale >= 1 )
			return;
		
		n_earthquake_scale = n_scale * .15;
		earthquake( n_earthquake_scale, .1, v_mech_land_origin, 1500 );
		if ( n_scale >= .66 )
		{
			e_player playRumbleOnEntity( "shotgun_fire" );
			continue;
		}
		if ( n_scale >= .33 )
		{
			e_player playRumbleOnEntity( "damage_heavy" );
			continue;
		}
		e_player playRumbleOnEntity( "reload_small" );
	}	
}

function mechz_flame_damage_on_landing( v_mech_land_origin )
{
	self endon( "death" );
	self endon( "do_damage_on_landing" );
	self waittill( "start_damaging_players" );
	n_burn_range = 9216;
	while ( 1 )
	{
		a_players = getPlayers();
		foreach ( e_player in a_players )
		{
			n_distance_sq = distanceSquared( e_player.origin, v_mech_land_origin );
			if ( n_distance_sq <= n_burn_range )
			{
				if ( !IS_TRUE( e_player.is_burning ) && zombie_utility::is_player_valid( e_player, 0 ) )
					e_player mechz_set_player_burning( self );
				
			}
		}
		a_zombies = array::filter( getAIArchetypeArray( "zombie" ), 0, &zm_elemental_zombie::is_not_elemental_zombie );
		foreach ( e_zombie in a_zombies )
		{
			n_distance_sq = distanceSquared( e_zombie.origin, v_mech_land_origin );
			if ( n_distance_sq <= n_burn_range && self.b_is_keeper_zombie !== 1 )
			{
				self mechz_knockdown_zombie( e_zombie );
				e_zombie zm_elemental_zombie::make_napalm_zombie();
			}
		}
		wait .1;
	}
}

function get_mechz_spawn_pos()
{
	a_mechz_locations = array::randomize( level.mechz_locations );
	for ( i = 0; i < a_mechz_locations.size; i++ )
		if ( isDefined( a_mechz_locations[ i ].zone_name ) && level.zones[ a_mechz_locations[ i ].zone_name ].is_occupied )
			return a_mechz_locations[ i ];
		
	for ( i = 0; i < a_mechz_locations.size; i++ )
		if ( isDefined( a_mechz_locations[ i ].zone_name ) && level.zones[ a_mechz_locations[ i ].zone_name ].is_active )
			return a_mechz_locations[ i ];
		
	return undefined;
}

function mechz_set_player_burning( e_mechz )
{
	if ( !IS_TRUE( self.is_burning ) && zombie_utility::is_player_valid( self, 1 ) )
	{
		self.is_burning = 1;
		if ( !self hasPerk( "specialty_armorvest" ) )
			self burnplayer::setPlayerBurning( 1.5, .5, 30, e_mechz, undefined );
		else
			self burnplayer::setPlayerBurning( 1.5, .5, 20, e_mechz, undefined );
		
		wait 1.5;
		self.is_burning = 0;
	}
}

function mechz_knockdown_zombie( e_zombie )
{
	e_zombie.knockdown = 1;
	e_zombie.knockdown_type = "knockdown_shoved";
	v_zombie_to_mechz = self.origin - e_zombie.origin;
	v_zombie_to_mechz_2d = vectorNormalize( ( v_zombie_to_mechz[ 0 ], v_zombie_to_mechz[ 1 ], 0 ) );
	v_zombie_forward = anglesToForward( e_zombie.angles );
	v_zombie_forward_2d = vectorNormalize( ( v_zombie_forward[ 0 ], v_zombie_forward[ 1 ], 0 ) );
	v_zombie_right = anglesToRight( e_zombie.angles );
	v_zombie_right_2d = vectorNormalize( ( v_zombie_right[ 0 ], v_zombie_right[ 1 ], 0 ) );
	n_dot = vectorDot( v_zombie_to_mechz_2d, v_zombie_right_2d );
	if ( n_dot >= .5 )
	{
		e_zombie.knockdown_direction = "front";
		e_zombie.getup_direction = "getup_back";
	}
	else if ( n_dot < .5 && n_dot > -.5 )
	{
		n_dot = vectorDot( v_zombie_to_mechz_2d, v_zombie_right_2d );
		if ( n_dot > 0 )
		{
			e_zombie.knockdown_direction = "right";
			if ( math::cointoss() )
				e_zombie.getup_direction = "getup_back";
			else
				e_zombie.getup_direction = "getup_belly";
			
		}
		else
		{
			e_zombie.knockdown_direction = "left";
			e_zombie.getup_direction = "getup_belly";
		}
	}
	else
	{
		e_zombie.knockdown_direction = "back";
		e_zombie.getup_direction = "getup_belly";
	}
}

function mechz_melee_knockdown_function_override()
{
	a_zombies = getAIArchetypeArray( "zombie" );
	foreach ( e_zombie in a_zombies )
	{
		n_distance_sq = distanceSquared( self.origin, e_zombie.origin );
		if ( e_zombie mechz_knockdown_zombie_valid( self ) && n_distance_sq <= MECHZ_MAX_KNOCKDOWN_RANGE_SQ )
			self mechz_knockdown_zombie( e_zombie );
		
	}
}

function mechz_knockdown_zombie_valid( e_mechz )
{
	v_origin = self.origin;
	v_facing_vec = anglesToForward( e_mechz.angles );
	v_enemy_vec = v_origin - e_mechz.origin;
	v_enemy_yaw_vec = ( v_enemy_vec[ 0 ], v_enemy_vec[ 1 ], 0 );
	v_facing_yaw_vec = ( v_facing_vec[ 0 ], v_facing_vec[ 1 ], 0 );
	v_enemy_yaw_vec = vectorNormalize( v_enemy_yaw_vec );
	v_facing_yaw_vec = vectorNormalize( v_facing_yaw_vec );
	n_enemy_dot = vectorDot( v_facing_yaw_vec, v_enemy_yaw_vec );
	if ( n_enemy_dot < .7 )
		return 0;
	
	v_enemy_angles = vectorToAngles( v_enemy_vec );
	if ( abs( angleClamp180( v_enemy_angles[ 0 ] ) ) > 45 )
		return 0;
	
	return 1;
}

function mechz_health_increases()
{
	if ( !isDefined( level.mechz_last_spawn_round ) || level.round_number > level.mechz_last_spawn_round )
	{
		a_players = getPlayers();
		n_player_modifier = 1;
		if ( a_players.size > 1 )
			n_player_modifier = a_players.size * MECHZ_HEALTH_CO_OP_MULTI;
		
		level.mechz_health = int( n_player_modifier * ( level.mechz_base_health + ( level.mechz_health_increase * level.mechz_round_count ) ) );
		
		if ( level.mechz_health >= MECHZ_HEALTH_MAX_BASE * n_player_modifier )
			level.mechz_health = Int( MECHZ_HEALTH_MAX_BASE * n_player_modifier );
		
		level.mechz_last_spawn_round = level.round_number;
	}
}

function mechz_ambient_vocals()
{
	self endon( "death" );
	while( 1 )
	{
		wait( randomIntRange( 9, 14 ) );
		self playSound( "zmb_ai_mechz_vox_ambient" );
	}
}

function response_to_air_raid_siren_vo()
{
	wait 3;
	a_players = getPlayers();
	if ( a_players.size == 0 )
		return;
	
	a_players = array::randomize( a_players );
	foreach ( e_player in a_players )
	{
		if ( zombie_utility::is_player_valid( e_player ) )
		{
			if ( !IS_TRUE( e_player.dontspeak ) )
			{
				if ( !isDefined( level.air_raid_siren_count ) )
				{
					e_player zm_audio::create_and_play_dialog( "general", "siren_1st_time" );
					level.air_raid_siren_count = 1;
					while ( isDefined( e_player ) && IS_TRUE( e_player.isSpeaking ) )
						wait .1;
					
					level thread start_see_mech_zombie_vo();
					continue;
				}
				if ( level.mechz_zombie_per_round == 1 )
				{
					e_player zm_audio::create_and_play_dialog( "general", "siren_generic" );
					continue;
				}
				e_player zm_audio::create_and_play_dialog( "general", "multiple_mechs" );
			}
		}
	}
}

function start_see_mech_zombie_vo()
{
	wait 1;
	a_zombies = getAISpeciesArray( level.zombie_team, "all" );
	foreach ( e_zombie in a_zombies )
	{
		if ( IS_TRUE( e_zombie.is_mechz ) )
			e_ai_mechz = e_zombie;
		
	}
	a_players = getPlayers();
	if ( a_players.size == 0 )
		return;
	
	if ( isAlive( e_ai_mechz ) )
	{
		foreach( e_player in a_players )
			e_player thread player_looking_at_mechz_watcher( e_ai_mechz );
		
	}
}

function player_looking_at_mechz_watcher( e_ai_mechz )
{
	self endon( "disconnect" );
	e_ai_mechz endon( "death" );
	level endon( "first_mech_zombie_seen" );
	while ( 1 )
	{
		if ( distanceSquared( self.origin, e_ai_mechz.origin ) < 1000000 )
		{
			if ( self zm_utility::is_player_looking_at( e_ai_mechz.origin + vectorScale( ( 0, 0, 1 ), 60 ), .75) )
			{
				if ( !IS_TRUE( self.dontspeak ) )
				{
					self zm_audio::create_and_play_dialog( "general", "discover_mech" );
					level notify( "first_mech_zombie_seen" );
					break;
				}
			}
		}
		wait .1;
	}
}

// ============================== FUNCTIONALITY ==============================

// ============================== DEVELOPER ==============================

// ============================== DEVELOPER ==============================

// ============================== REMOVED FUNCTIONALITY ==============================

/*
	Name: genesis_mechz_vortex_service
	Namespace: namespace_8f77dbcb
	Checksum: 0x6C7E79B4
	Offset: 0xD78
	Size: 0x1C1
	Parameters: 1
	Flags: Private
*/
/*
function genesis_mechz_vortex_service( e_entity )
{
	if ( !e_entity mechz_is_stunned() )
		return 0;
	
	if ( isDefined( level.vortex_manager ) && isDefined( level.vortex_manager.a_active_vorticies ) )
	{
		foreach( vortex in level.vortex_manager.a_active_vorticies )
		{
			if ( !vortex function_604404( e_entity ) )
			{
				dist_sq = distanceSquared( vortex.origin, e_entity.origin );
				if ( dist_sq < 9216 )
				{
					e_entity.stun = 1;
					e_entity.vortex = vortex;
					if ( isDefined( vortex.weapon ) && idgun::function_9b7ac6a9( vortex.weapon ) )
						blackboard::setBlackBoardAttribute( e_entity, "_zombie_damageweapon_type", "packed" );
					
					vortex function_e92d3bb1( e_entity );
					return 1;
				}
			}
	 	}
	}
	return 0;
}
*/

/*
	Name: mechzgettanktagservice
	Namespace: zm_tomb_mech
	Checksum: 0xAD48F0A4
	Offset: 0x1728
	Size: 0x137
	Parameters: 1
	Flags: Private
*/
/*
function mechzgettanktagservice( e_entity )
{
	if ( level.vh_tank flag::get( "tank_moving" ) )
	{
		e_entity.var_afe67307 = undefined;
		return;
	}
	a_players_on_tank = zm_tomb_tank::get_players_on_tank();
	if ( isDefined( e_entity.var_afe67307 ) && a_players_on_tank.size > 0 )
		return;
	
	if ( !isDefined( e_entity.favoriteenemy ) )
	{
		e_entity.var_afe67307 = undefined;
		return;
	}
	if ( !e_entity.favoriteenemy zm_tomb_tank::entity_on_tank() )
	{
		e_entity.var_afe67307 = undefined;
		return;
	}
	str_tag = level.vh_tank zm_tomb_tank::get_closest_mechz_tag_on_tank( e_entity, e_entity.favoriteenemy.origin );
	if ( isDefined( str_tag ) )
		e_entity.var_afe67307 = level.vh_tank zm_tomb_tank::function_21d81b2c( str_tag );
	
}
*/

/*
	Name: mechzgetjumpposservice
	Namespace: zm_tomb_mech
	Checksum: 0x2BD5CDD5
	Offset: 0x1868
	Size: 0xC7
	Parameters: 1
	Flags: Private
*/
/*
function mechzgetjumpposservice( e_entity )
{
	if ( !level.vh_tank flag::get( "tank_moving" ) )
	{
		e_entity.jump_pos = undefined;
		return;
	}
	if ( !isDefined( e_entity.favoriteenemy ) )
	{
		e_entity.jump_pos = undefined;
		return;
	}
	if ( !e_entity.favoriteenemy zm_tomb_tank::entity_on_tank() )
	{
		e_entity.jump_pos = undefined;
		return;
	}
	if ( !isDefined( e_entity.jump_pos ) )
		e_entity.jump_pos = get_closest_mechz_spawn_pos( e_entity.origin );
	
}
*/

/*
	Name: mechzshouldshootflameattank
	Namespace: zm_tomb_mech
	Checksum: 0x5B4708A9
	Offset: 0x19C0
	Size: 0xF5
	Parameters: 1
	Flags: Private
*/
/*
function mechzshouldshootflameattank( e_entity )
{
	if ( e_entity.berserk === 1 )
		return 0;
	if ( !isDefined( e_entity.var_afe67307 ) )
		return 0;
	
	n_distance_2d = distance2DSquared( e_entity.origin, e_entity.var_afe67307 );
	if ( n_distance_2d > 100 )
		return 0;
	
	return 1;
}
*/

/*
	Name: mechzwasknockeddownbytank
	Namespace: zm_tomb_mech
	Checksum: 0x4173E10D
	Offset: 0x1AC0
	Size: 0x25
	Parameters: 2
	Flags: Private
*/
/*
function mechzwasknockeddownbytank( e_entity, str_asm_state_name )
{
	return IS_TRUE( e_entity.var_32854687 );
}
*/

/*
	Name: mechzjumpupactionterminate
	Namespace: zm_tomb_mech
	Checksum: 0xE17C84A7
	Offset: 0x1BE0
	Size: 0xDF
	Parameters: 2
	Flags: Private
*/
/*
function mechzjumpupactionterminate( e_entity, str_asm_state_name )
{
	e_entity ghost();
	e_entity.mechz_hidden = 1;
	if ( isDefined( e_entity.m_claw_anchor ) && isDefined( e_entity.m_claw_anchor.m_claw ) )
		e_entity.m_claw_anchor.m_claw ghost();
	if ( isDefined( e_entity.fx_field ) )
		e_entity.fx_field_old = e_entity.fx_field;
	
	e_entity thread zombie_utility::zombie_eye_glow_stop();
	e_entity.var_1ea3b675 = level.time + ( level.mechz_jump_delay * 1000 );
}
*/

/*
	Name: tombmechzjumphoveraction
	Namespace: zm_tomb_mech
	Checksum: 0x57D6A2F
	Offset: 0x1CC8
	Size: 0x5F
	Parameters: 2
	Flags: Private
*/
/*
function tombmechzjumphoveraction( e_entity, str_asm_state_name )
{
	if ( e_entity.var_1ea3b675 > level.time )
		return BHTN_RUNNING;
	
	if ( level.vh_tank flag::get( "tank_moving" ) )
		return BHTN_RUNNING;
	
	return BHTN_SUCCESS;
}
*/

/*
	Name: mechzjumpdownactionstart
	Namespace: zm_tomb_mech
	Checksum: 0xD616D41D
	Offset: 0x1D30
	Size: 0x133
	Parameters: 2
	Flags: Private
*/
/*
function mechzjumpdownactionstart( e_entity, str_asm_state_name )
{
	e_entity.var_1ea3b675 = undefined;
	var_be0ab0a1 = get_best_mechz_spawn_pos( 1 );
	if ( !isDefined( var_be0ab0a1.angles ) )
		var_be0ab0a1.angles = ( 0, 0, 0 );
	
	e_entity forceTeleport( var_be0ab0a1.origin, var_be0ab0a1.angles );
	e_entity.mechz_hidden = 0;
	e_entity show();
	if ( isDefined( e_entity.m_claw_anchor ) && isDefined( e_entity.m_claw_anchor.m_claw ) )
		e_entity.m_claw_anchor.m_claw show();
	
	e_entity.fx_field = e_entity.fx_field_old;
	e_entity.fx_field_old = undefined;
	e_entity thread zombie_utility::zombie_eye_glow();
}
*/

/*
	Name: mechzrobotstompactionstart
	Namespace: zm_tomb_mech
	Checksum: 0xCFC9A933
	Offset: 0x1EE8
	Size: 0x4F
	Parameters: 2
	Flags: Private
*/
/*
function mechzrobotstompactionstart( e_entity, str_asm_state_name )
{
	e_entity function_97cf5f();
	e_entity.var_5819fc = level.time + ( level.mechz_robot_knockdown_time * 1000 );
}
*/

/*
	Name: mechzrobotstompactionupdate
	Namespace: zm_tomb_mech
	Checksum: 0x93233663
	Offset: 0x1F40
	Size: 0x39
	Parameters: 2
	Flags: Private
*/
/*
function mechzrobotstompactionupdate( e_entity, str_asm_state_name )
{
	if ( e_entity.var_5819fc > level.time )
		return BHTN_RUNNING;
	
	return BHTN_SUCCESS;
}
*/

/*
	Name: mechzrobotstompactionend
	Namespace: zm_tomb_mech
	Checksum: 0x450309CA
	Offset: 0x1F88
	Size: 0x2D
	Parameters: 2
	Flags: Private
*/
/*
function mechzrobotstompactionend( e_entity, str_asm_state_name )
{
	e_entity.var_5819fc = undefined;
	e_entity.robot_stomped = undefined;
}
*/

/*
	Name: mechztankknockdownactionstart
	Namespace: zm_tomb_mech
	Checksum: 0x65500571
	Offset: 0x2058
	Size: 0x87
	Parameters: 2
	Flags: Private
*/
/*
function mechztankknockdownactionstart( e_entity, str_asm_state_name )
{
	e_entity function_97cf5f();
	e_entity show();
	e_entity pathMode( "move allowed" );
	e_entity.var_918f1b56 = level.time + ( level.mechz_tank_knockdown_time * 1000 );
}
*/

/*
	Name: mechztankknockdownactionupdate
	Namespace: zm_tomb_mech
	Checksum: 0x57FECECA
	Offset: 0x20E8
	Size: 0x39
	Parameters: 2
	Flags: Private
*/
/*
function mechztankknockdownactionupdate( e_entity, str_asm_state_name )
{
	if ( e_entity.var_918f1b56 > level.time )
		return BHTN_RUNNING;
	
	return BHTN_SUCCESS;
}
*/

/*
	Name: mechztankknockdownactionend
	Namespace: zm_tomb_mech
	Checksum: 0xCBFF2C0B
	Offset: 0x2130
	Size: 0xE1
	Parameters: 2
	Flags: Private
*/
/*
function mechztankknockdownactionend( e_entity, str_asm_state_name )
{
	if ( !level.vh_tank flag::get( "tank_moving" ) && e_entity isTouching( level.vh_tank ) )
	{
		e_entity notsolid();
		e_entity ghost();
		if ( isDefined( e_entity.var_b1d5a124 ) ) // HARRY_CHECK
			e_entity.m_claw_anchor ghost();
		
		e_entity.force_jump = 1;
	}
	e_entity.var_918f1b56 = undefined;
	e_entity.var_32854687 = undefined;
}
*/

/*
	Name: teleport_traversal_mocomp_start
	Namespace: namespace_8f77dbcb
	Checksum: 0x55D305A2
	Offset: 0x2050
	Size: 0xDB
	Parameters: 5
	Flags: None
*/
/*
function teleport_traversal_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity.is_teleporting = 1;
	e_entity orientMode( "face angle", e_entity.angles[ 1 ] );
	e_entity animMode( "normal" );
	if( isDefined( e_entity.traverseStartNode ) )
	{
		portal_trig = e_entity.traverseStartNode.portal_trig;
		portal_trig thread zm_genesis_portals::function_eb1242c8( e_entity );
	}
}
*/

/*
	Name: face_tank_mocomp_start
	Namespace: zm_tomb_mech
	Checksum: 0x2D6896FC
	Offset: 0x2220
	Size: 0x73
	Parameters: 5
	Flags: Private
*/
/*
function face_tank_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity orientMode( "face direction", vectorNormalize( level.vh_tank.origin - e_entity.origin ) );
}
*/

/*
	Name: mechz_staff_damage_override
	Namespace: zm_tomb_mech
	Checksum: 0x563F9FB
	Offset: 0x2A58
	Size: 0x115
	Parameters: 12
	Flags: None
*/
/*
function mechz_staff_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time, n_bone_index, n_model_index )
{
	if ( self zm_weap_staff_fire::is_staff_fire_damage( w_weapon ) && str_means_of_death != "MOD_MELEE" )
	{
		if ( str_means_of_death != "MOD_BURNED" && str_means_of_death != "MOD_GRENADE_SPLASH" )
			return zm_weap_staff_fire::get_impact_damage( w_weapon );
		
	}
	if ( self zm_weap_staff_air::is_staff_air_damage( w_weapon ) || self zm_weap_staff_water::is_staff_water_damage( w_weapon ) || self zm_weap_staff_lightning::is_staff_lightning_damage( w_weapon ) )
		return damage;
	
	return 0;
}
*/

/*
	Name: mechz_flamethrower_player
	Namespace: zm_tomb_mech
	Checksum: 0x36D05BD4
	Offset: 0x28B8
	Size: 0x191
	Parameters: 1
	Flags: None
*/
/*
function mechz_flamethrower_player( e_entity )
{
	b_do_tank_sweep_auto_damage = IS_TRUE( self.doing_tank_sweep ) && !level.vh_tank flag::get( "tank_moving" );
	a_players = getPlayers();
	foreach ( e_player in a_players )
	{
		if ( !IS_TRUE( e_player.is_burning ) )
		{
			if ( b_do_tank_sweep_auto_damage && e_player zm_tomb_tank::entity_on_tank() || e_player isTouching( e_entity.flameTrigger ) )
			{
				if ( isDefined( e_entity.mechzFlameDamage ) )
				{
					e_player thread [ [ e_entity.mechzFlameDamage ] ]();
					continue;
				}
				e_player thread mechzBehavior::playerFlameDamage( e_entity );
			}
		}
	}
}
*/

/*
	Name: mechz_lift_override
	Namespace: zm_ai_mechz
	Checksum: 0xDAA3C3AB
	Offset: 0x1D48
	Size: 0x2C7
	Parameters: 6
	Flags: None
*/
/*
function mechz_lift_override( e_player, v_attack_source, n_push_away, n_lift_height, v_lift_offset, n_lift_speed )
{
	self endon( "death" );
	if ( IS_TRUE( self.in_gravity_trap ) && e_player.gravityspikes_state === 3 )
	{
		if ( IS_TRUE( self.var_1f5fe943 ) )
			return;
		
		self.var_bcecff1d = 1;
		self.var_1f5fe943 = 1;
		self doDamage( 10, self.origin );
		self.var_ab0efcf6 = self.origin;
		self thread scene::play( "cin_zm_dlc1_mechz_dth_deathray_01", self );
		self clientfield::set( "sparky_beam_fx", 1 );
		self clientfield::set( "death_ray_shock_fx", 1 );
		self playSound( "zmb_talon_electrocute" );
		n_start_time = getTime();
		for ( n_total_time = 0; 10 > n_total_time && e_player.gravityspikes_state === 3; n_total_time++ ) // for ( n_total_time = 0; 10 > n_total_time && e_player.gravityspikes_state === 3;  = 0 )
			util::wait_network_frame();
		
		self scene::stop( "cin_zm_dlc1_mechz_dth_deathray_01" );
		self thread mechz_lift_death( self );
		self clientfield::set( "sparky_beam_fx", 0 );
		self clientfield::set( "death_ray_shock_fx", 0 );
		self.var_bcecff1d = undefined;
		while( e_player.gravityspikes_state === 3 )
			util::wait_network_frame();
		
		self.var_1f5fe943 = undefined;
		self.in_gravity_trap = undefined;
	}
	else
	{
		self doDamage( 10, self.origin );
		if ( !IS_TRUE( self.stun ) )
			self.stun = 1;
		
	}
}
*/

/*
	Name: mechz_lift_death
	Namespace: zm_ai_mechz
	Checksum: 0x6CFD4C09
	Offset: 0x2018
	Size: 0x1A3
	Parameters: 1
	Flags: None
*/
/*
function mechz_lift_death( mechz )
{
	mechz endon( "death" );
	if ( isDefined( mechz ) )
		mechz scene::play( "cin_zm_dlc1_mechz_dth_deathray_02", mechz );
	
	if ( isDefined( mechz ) && isAlive( mechz ) && isDefined( mechz.var_ab0efcf6 ) )
	{
		v_eye_pos = mechz getTagOrigin( "tag_eye" );
		trace = bullettrace( v_eye_pos, mechz.origin, 0, mechz );
		if ( trace[ "position" ] !== mechz.origin )
		{
			point = getClosestPointOnNavMesh( trace[ "position" ], 64, 30 );
			if ( !isDefined( point ) )
				point = mechz.var_ab0efcf6;
			
			mechz forceTeleport( point );
		}
	}
}
*/

/*
	Name: function_bed84b4
	Namespace: zm_ai_mechz_claw
	Checksum: 0xE32C1EFF
	Offset: 0x22B8
	Size: 0x91
	Parameters: 1
	Flags: Private
*/
/*
function function_bed84b4( mechz )
{
	self endon( "death" );
	self endon( "disconnect" );
	mechz endon( "death" );
	mechz endon( "claw_complete" );
	mechz endon( "kill_claw" );
	while ( 1 )
	{
		self waittill( "hash_10c37787" );
		if ( isdefined( self ) && self.bgb === "zm_bgb_anywhere_but_here" )
		{
			mechz thread zm_mechz_claw_release();
			return;
		}
	}
}
*/

/*
	Name: function_38d105a4
	Namespace: zm_ai_mechz_claw
	Checksum: 0xF69E84FF
	Offset: 0x2358
	Size: 0x79
	Parameters: 1
	Flags: Private
*/
/*
function function_38d105a4( mechz )
{
	self endon( "death" );
	self endon( "disconnect" );
	mechz endon( "death" );
	mechz endon( "claw_complete" );
	mechz endon( "kill_claw" );
	while ( 1 )
	{
		self waittill( "hash_e2be4752" );
		mechz thread zm_mechz_claw_release();
		return;
	}
}
*/

/*
	Name: function_97cf5f
	Namespace: zm_tomb_mech
	Checksum: 0xC447CB99
	Offset: 0x2540
	Size: 0xBB
	Parameters: 0
	Flags: Private
*/
/*
function function_97cf5f()
{
	v_trace_start = self.origin + vectorScale( ( 0, 0, 1 ), 100 );
	v_trace_end = self.origin - vectorScale( ( 0, 0, 1 ), 500 );
	v_trace = physicsTrace( self.origin, v_trace_end, ( -15, -15, -5 ), ( 15, 15, 5 ), self );
	self forceTeleport( v_trace[ "position" ], self.angles );
}
*/

/*
	Name: mechz_lift_death
	Namespace: zm_ai_mechz
	Checksum: 0x6CFD4C09
	Offset: 0x2018
	Size: 0x1A3
	Parameters: 1
	Flags: None
*/
/*
function mechz_lift_death( mechz )
{
	mechz endon( "death" );
	if ( isDefined( mechz ) )
		mechz scene::play( "cin_zm_dlc1_mechz_dth_deathray_02", mechz );
	
	if ( isDefined( mechz ) && isAlive( mechz ) && isDefined( mechz.var_ab0efcf6 ) )
	{
		v_eye_pos = mechz getTagOrigin( "tag_eye" );
		trace = bullettrace( v_eye_pos, mechz.origin, 0, mechz );
		if ( trace[ "position" ] !== mechz.origin )
		{
			point = getClosestPointOnNavMesh( trace[ "position" ], 64, 30 );
			if ( !isDefined( point ) )
				point = mechz.var_ab0efcf6;
			
			mechz forceTeleport( point );
		}
	}
}
*/

/*
function get_best_mechz_spawn_pos( b_ignore_used_positions )
{
	if ( !IS_TRUE( b_ignore_used_positions ) )
		b_ignore_used_positions = 0;
	
	n_best_distance = -1;
	s_best_pos = undefined;
	for ( i = 0; i < level.mechz_locations.size; i++ )
	{
		str_zone = zm_zonemgr::get_zone_from_position( level.mechz_locations[ i ].origin, 0 );
		if ( !isDefined( str_zone ) )
			break;
		if ( !b_ignore_used_positions && IS_TRUE( level.mechz_locations[ i ].has_been_used ) )
			break;
		if ( b_ignore_used_positions == 1 && IS_TRUE( level.mechz_locations[ i ].used_cooldown ) )
			break;
		
		for ( j = 0; j < level.players.size; j++ )
		{
			if ( zombie_utility::is_player_valid( level.players[ j ], 1, 1 ) )
			{
				dist = distanceSquared( level.mechz_locations[ i ].origin, level.players[ j ].origin );
				if ( dist < n_best_distance || n_best_distance < 0 )
				{
					n_best_distance = dist;
					s_best_pos = level.mechz_locations[ i ];
				}
			}
		}
	}
	if ( b_ignore_used_positions && isDefined( s_best_pos ) )
		s_best_pos thread jump_pos_used_cooldown();
	if ( isDefined( s_best_pos ) )
		s_best_pos.has_been_used = 1;
	else if ( level.mechz_locations.size > 0 )
	{
		a_mechz_locations = array::randomize( level.mechz_locations );
		foreach ( s_location in a_mechz_locations )
		{
			str_zone = zm_zonemgr::get_zone_from_position( s_location.origin, 0 );
			if ( isDefined( str_zone ) )
				return s_location;
			
		}
		return level.mechz_locations[ randomInt( level.mechz_locations.size ) ];
	}
	return s_best_pos;
}
*/

/*
function jump_pos_used_cooldown()
{
	self.used_cooldown = 1;
	wait 5;
	self.used_cooldown = 0;
}
*/

/*
function get_closest_mechz_spawn_pos( v_origin )
{
	n_best_distance = -1;
	s_best_pos = undefined;
	for ( i = 0; i < level.mechz_locations.size; i++ )
	{
		n_distance = distanceSquared( v_origin, level.mechz_locations[ i ].origin );
		if ( n_distance < n_best_distance || n_best_distance < 0 )
		{
			n_best_distance = n_distance;
			s_best_pos = level.mechz_locations[ i ];
		}
	}
	return s_best_pos;
}
*/

// ============================== REMOVED FUNCTIONALITY ==============================