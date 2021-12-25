#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_quad;
#using scripts\shared\array_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\zm\_zm_ai_quad.gsh;

#namespace zm_ai_quad; 

#precache( "fx", "dlc5/zmhd/fx_zombie_quad_gas_nova6" );
#precache( "fx", "dlc5/zmhd/fx_zombie_quad_trail" );
#precache( "fx", "dlc5/zmhd/fx_quad_teleport_in" );
#precache( "fx", "dlc5/zmhd/fx_quad_teleport_out" );
#precache( "fx", "dlc5/moon/fx_zombie_phasing" );

REGISTER_SYSTEM_EX( "zm_ai_quad", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # BEHAVIOR SET UP
	BT_REGISTER_ACTION( 								"traversewallcrawlaction", 						&traversewallcrawlaction, 								&traversewallcrawlactionupdate, 	undefined																	 );
	BT_REGISTER_API( 										"shouldwalltraverse", 								&shouldwalltraverse																																												 );
	BT_REGISTER_API( 										"shouldwallcrawl", 									&shouldwallcrawl																																													 );
	BT_REGISTER_API( 										"traversewallintro", 									&traversewallintro																																													 );
	BT_REGISTER_API( 										"traversewalljumpoff", 								&traversewalljumpoff																																											 );
	BT_REGISTER_API( 										"quadcollisionservice", 								&quadcollisionservice																																												 );
	BT_REGISTER_API( 										"quaddeathaction", 									&quaddeathaction																																													 );
	BT_REGISTER_API( 										"quadphasingservice", 								&quadphasingservice																																												 );
	BT_REGISTER_API( 										"shouldphase", 										&shouldphase																																														 );
	BT_REGISTER_API( 										"phaseactionstart", 									&phaseactionstart																																													 );
	BT_REGISTER_API( 										"phaseactionterminate", 							&phaseactionterminate																																											 );
	BT_REGISTER_API( 										"moonquadkilledbymicrowavegundw", 		&killedbymicrowavegundw																																										 );
	BT_REGISTER_API( 										"moonquadkilledbymicrowavegun", 			&killedbymicrowavegun																																											 );
	ASM_REGISTER_MOCOMP( 							"quad_wall_traversal", 								&quad_wall_traversal_mocomp_start, 				undefined, 									undefined																	 );
	ASM_REGISTER_MOCOMP( 							"quad_wall_jump_off", 							&quad_wall_jump_off_mocomp_start, 			undefined, 									&quad_wall_jump_off_mocomp_terminate				 );
	ASM_REGISTER_MOCOMP( 							"quad_move_strict_traversal", 				&quad_move_strict_traversal_mocomp_start, 	undefined, 									&quad_move_strict_traversal_mocomp_terminate	 );
	ASM_REGISTER_MOCOMP( 							"quad_phase", 											&mocompquadphase, 										undefined, 									undefined																	 );
	ASM_REGISTER_NOTETRACK_HANDLER( 		"quad_melee", 										&quadnotetrackmeleefire																																										 );
	ASM_REGISTER_NOTETRACK_HANDLER( 		"phase_start", 											&quadphasestart																																													 );
	ASM_REGISTER_NOTETRACK_HANDLER( 		"phase_end", 											&quadphaseend																																													 );
	// # BEHAVIOR SET UP
	
	// # REGISTER IMMUNITY FOR AI FROM AATS
	level thread AAT::register_immunity( 			"zm_aat_dead_wire", 		"zombie_quad", 	1, 	1, 	1 );
	level thread AAT::register_immunity( 			"zm_aat_turned", 			"zombie_quad", 	1, 	1, 	1 );
	// # REGISTER IMMUNITY FOR AI FROM AATS
	
	// # VARIABLES AND SETTINGS
	level.quad_explode 													= QUAD_ZOMBIE_EXPLODE_GAS_DEATH;
	level.quad_phase 														= QUAD_ZOMBIE_CAN_PHASE_TELEPORT;
	// # VARIABLES AND SETTINGS
	
	// # REGISTER FX
	level._effect[ "quad_explo_gas" ] 							= "dlc5/zmhd/fx_zombie_quad_gas_nova6";
	level._effect[ "quad_trail" ] 										= "dlc5/zmhd/fx_zombie_quad_trail";
	level._effect[ "quad_phasing" ] 								= "dlc5/moon/fx_zombie_phasing";
	level._effect[ "quad_phasing_in" ] 							= "dlc5/zmhd/fx_quad_teleport_in";
	level._effect[ "quad_phasing_out" ] 						= "dlc5/zmhd/fx_quad_teleport_out";
	// # REGISTER FX
	
	// THREAD LOGIC
	level thread activate_quad_spawners_power_check();
	// THREAD LOGIC
}

function __main__()
{
	if ( !isDefined( level.quad_visionset_priority ) )
		level.quad_visionset_priority = 50;
	
	visionset_mgr::register_info( "overlay", "zm_ai_quad_blur", 1, level.quad_visionset_priority, 1, 1 );
}

// ============================== INITIALIZE ==============================

// ============================== BEHAVIOR ==============================

function quaddeathaction( e_entity )
{
	if ( isDefined( e_entity.fx_quad_trail ) )
	{
		e_entity.fx_quad_trail unlink();
		e_entity.fx_quad_trail delete();
	}
	if ( IS_TRUE( e_entity.can_explode ) && !IS_TRUE( e_entity.guts_explosion ) )
		e_entity thread quad_gas_explo_death();
	
	e_entity startRagdoll();
}

function traversewallcrawlaction( e_entity, str_asm_state_name )
{
	animationStateNetworkUtility::requestState( e_entity, str_asm_state_name );
	return BHTN_RUNNING;
}

function traversewallcrawlactionupdate( e_entity, str_asm_state_name )
{
	if ( !shouldwallcrawl( e_entity ) )
		return BHTN_SUCCESS;
	
	return BHTN_RUNNING;
}

function shouldwalltraverse( e_entity )
{
	if ( isDefined( e_entity.traverseStartNode ) )
	{
		if ( isSubStr( e_entity.traverseStartNode.animscript, "zm_wall_crawl_drop" ) )
			return 1;
		
	}
	return 0;
}

function shouldwallcrawl( e_entity )
{
	if ( isDefined( e_entity.quad_crawl_cooldown_time ) )
	{
		if ( getTime() >= e_entity.quad_crawl_cooldown_time )
			return 0;
		
	}
	return 1;
}

function traversewallintro( e_entity )
{
	e_entity allowPitchAngle( 0 );
	e_entity.clampToNavMesh = 0;
	if ( isDefined( e_entity.traverseStartNode ) )
	{
		e_entity.crawlTraverseStartNode = e_entity.traverseStartNode;
		e_entity.crawlTraverseEndNode = e_entity.traverseEndNode;
		if ( e_entity.traverseStartNode.animscript == "zm_wall_crawl_drop" )
			blackboard::setBlackBoardAttribute( e_entity, "_quad_wall_crawl", "quad_wall_crawl_theater" );
		else
			blackboard::setBlackBoardAttribute( e_entity, "_quad_wall_crawl", "quad_wall_crawl_start" );
		
	}
}

function traversewalljumpoff( e_entity )
{
	e_entity.quad_crawl_cooldown_time = undefined;
}

function quadcollisionservice( e_entity )
{
	if ( isDefined( e_entity.dontPushTime ) )
	{
		if ( getTime() < e_entity.dontPushTime )
			return 1;
		
	}
	a_zombies = getAITeamArray( level.zombie_team );
	foreach ( e_zombie in a_zombies )
	{
		if ( e_zombie == e_entity )
			continue;
		
		if ( IS_TRUE( e_zombie.missingLegs ) || IS_TRUE( e_zombie.knockdown ) )
			continue;
		
		dist_sq = distanceSquared( e_entity.origin, e_zombie.origin );
		if ( dist_sq < 14400 )
		{
			e_entity pushActors( 0 );
			e_entity.dontPushTime = getTime() + 3000;
			e_zombie thread quad_collision_service_wrapper();
			return 1;
		}
	}
	e_entity pushActors( 1 );
	return 0;
}

function quad_collision_service_wrapper()
{
	self endon( "death" );
	self setAvoidanceMask( "avoid all" );
	wait 3;
	self setAvoidanceMask( "avoid none" );
}

function quadphasingservice( e_entity )
{
	if ( IS_TRUE( e_entity.is_phasing ) )
		return 0;
	
	if ( !IS_TRUE( e_entity.b_phase_quad ) )
		return 0;
	
	e_entity.can_phase = 0;
	if ( e_entity.phase_counter == 0 )
	{
		if ( math::cointoss() )
			e_entity.phase_dir = "quad_phase_right";
		else
			e_entity.phase_dir = "quad_phase_left";
		
	}
	else if ( e_entity.phase_counter == -1 )
		e_entity.phase_dir = "quad_phase_right";
	else
		e_entity.phase_dir = "quad_phase_left";
	
	if ( e_entity.phase_dir == "quad_phase_left" )
	{
		if ( isPlayer( e_entity.enemy ) && e_entity.enemy isLookingAt( e_entity ) )
		{
			if ( e_entity mayMoveFromPointToPoint( e_entity.origin, zombie_utility::getAnimEndPos( level.quad_phase_anims[ "phase_left_long" ] ) ) )
				e_entity.can_phase = 1;
			
		}
	}
	else if ( isPlayer( e_entity.enemy ) && e_entity.enemy isLookingAt( e_entity ) )
	{
		if ( e_entity mayMoveFromPointToPoint( e_entity.origin, zombie_utility::getAnimEndPos( level.quad_phase_anims[ "phase_right_long" ] ) ) )
			e_entity.can_phase = 1;
		
	}
	if ( !IS_TRUE( e_entity.can_phase ) )
	{
		if ( e_entity mayMoveFromPointToPoint( e_entity.origin, zombie_utility::getAnimEndPos( level.quad_phase_anims[ "phase_forward" ] ) ) )
		{
			e_entity.can_phase = 1;
			e_entity.phase_dir = "quad_phase_forward";
		}
	}
	if ( IS_TRUE( e_entity.can_phase ) )
	{
		blackboard::setBlackBoardAttribute( e_entity, "_quad_phase_direction", e_entity.phase_dir );
		if ( math::cointoss() )
			blackboard::setBlackBoardAttribute( e_entity, "_quad_phase_distance", "quad_phase_short" );
		else
			blackboard::setBlackBoardAttribute( e_entity, "_quad_phase_distance", "quad_phase_long" );
		
		return 1;
	}
	return 0;
}

function shouldphase( e_entity )
{
	if ( !IS_TRUE( e_entity.can_phase ) )
		return 0;
	if ( IS_TRUE( e_entity.is_phasing ) )
		return 0;
	if ( getTime() - e_entity.last_phase_time < 2000 )
		return 0;
	if ( !isDefined( e_entity.enemy ) )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.enemy.origin );
	n_min_dist_sq = 4096;
	n_max_dist_sq = 1000000;
	if ( e_entity.phase_dir == "quad_phase_forward" )
	{
		n_min_dist_sq = 14400;
		n_max_dist_sq = 5760000;
	}
	if ( n_dist_sq < n_min_dist_sq )
		return 0;
	if ( n_dist_sq > n_max_dist_sq )
		return 0;
	
	if ( !isDefined( e_entity.pathGoalPos ) || distanceSquared( e_entity.origin, e_entity.pathGoalPos ) < n_min_dist_sq )
		return 0;
	
	if ( abs( e_entity getMotionAngle() ) > 15 )
		return 0;
	
	n_yaw = zombie_utility::getYawToOrigin( e_entity.enemy.origin );
	if ( abs( n_yaw ) > 45 )
		return 0;
	
	return 1;
}

function phaseactionstart( e_entity )
{
	e_entity.is_phasing = 1;
	if ( e_entity.phase_dir == "quad_phase_left" )
		e_entity.phase_counter--;
	else if ( e_entity.phase_dir == "quad_phase_right" )
		e_entity.phase_counter++;
	
}

function phaseactionterminate( e_entity )
{
	e_entity.last_phase_time = getTime();
	e_entity.is_phasing = 0;
}

function killedbymicrowavegundw( e_entity )
{
	return IS_TRUE( e_entity.microwavegun_dw_death );
}

function killedbymicrowavegun( e_entity )
{
	return IS_TRUE( e_entity.microwavegun_death );
}

function quad_wall_traversal_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	n_anim_dist = abs( getMoveDelta( str_mocomp_anim, 0, 1 )[ 2 ] );
	e_entity.ground_pos = bulletTrace( e_entity.crawlTraverseEndNode.origin, e_entity.crawlTraverseEndNode.origin + vectorScale( ( 0, 0, -1 ), 100000 ), 0, e_entity )[ "position" ];
	n_phys_dist = abs( e_entity.origin[ 2 ] - e_entity.ground_pos[ 2 ] - 60 );
	n_cycles = n_phys_dist / n_anim_dist;
	n_time = n_cycles * getAnimLength( str_mocomp_anim );
	e_entity.quad_crawl_cooldown_time = getTime() + n_time * 1000;
}

function quad_wall_jump_off_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity animMode( "noclip", 0 );
}

function quad_wall_jump_off_mocomp_terminate( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity allowPitchAngle( 1 );
	e_entity.clampToNavMesh = 1;
}

function quad_move_strict_traversal_mocomp_start( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity.blockingPain = 1;
	e_entity.useGoalAnimWeight = 1;
	e_entity animMode( "noclip", 0 );
	e_entity forceTeleport( e_entity.traverseStartNode.origin, e_entity.traverseStartNode.angles, 0 );
	e_entity orientMode( "face angle", e_entity.traverseStartNode.angles[ 1 ] );
}

function quad_move_strict_traversal_mocomp_terminate( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity finishTraversal();
	e_entity.useGoalAnimWeight = 0;
	e_entity.blockingPain = 0;
}

function mocompquadphase( e_entity, str_mocomp_anim, f_mocomp_anim_blend_out_time, n_mocomp_anim_flag, f_mocomp_duration )
{
	e_entity animMode( "gravity", 0 );
}

function quadnotetrackmeleefire( e_entity )
{
	e_entity melee();
}

function quadphasestart( e_entity )
{
	e_entity thread quad_pre_teleport();
	e_entity playSound( "zmb_quad_phase_out" );
	e_entity thread moon_quad_phase_fx( "quad_phasing_out" );
	e_entity ghost();
}

function quadphaseend( e_entity )
{
	e_entity thread quad_post_teleport();
	e_entity playSound( "zmb_quad_phase_in" );
	e_entity thread moon_quad_phase_fx( "quad_phasing_in" );
	e_entity show();
}

// ============================== BEHAVIOR ==============================

// ============================== SPAWN LOGIC ==============================

function activate_quad_spawners_power_check()
{
	while ( !flag::exists( "initial_blackscreen_passed" ) )
		WAIT_SERVER_FRAME;
	
	if ( !flag::get( "initial_blackscreen_passed" ) )
		level flag::wait_till( "initial_blackscreen_passed" );
	
	if ( IS_TRUE( QUAD_ZOMBIE_ONLY_IF_POWER_ACTIVE ) && level flag::exists( "power_on" ) && !IS_TRUE( level flag::get( "power_on" ) ) )
		level flag::wait_till( "power_on" );
	
	activate_quad_spawners();
}
	
function activate_quad_spawners()
{
	level.quad_spawners = getEntArray( "quad_zombie_spawner", "script_noteworthy" );
	array::thread_all( level.quad_spawners, &spawner::add_spawn_function, &quad_prespawn );
	zm::register_custom_ai_spawn_check( "quads", &quad_spawn_check, &get_quad_spawners );
}

function quad_spawn_check()
{
	return isDefined( level.zm_loc_types[ "quad_location" ] ) && level.zm_loc_types[ "quad_location" ].size > 0;
}

function get_quad_spawners()
{
	return level.quad_spawners;
}

function quad_prespawn()
{
	self.custom_location 							= &quad_location;
	
	self zm_spawner::zombie_spawn_init( 1 );
	
	self.animName 									= "quad_zombie";
	self.no_gib 											= 1;
	self.no_eye_glow 								= 1;
	self.no_widows_wine 							= 1;
	self.canBeTargetedByTurnedZombies 	= 1;
	self.zombie_can_sidestep 					= 0;
	self.maxhealth 										= int( self.maxhealth * .75 );
	self.health 											= self.maxhealth;
	self.freezegun_damage 						= 0;
	self.meleeDamage 								= 45;
	self.death_explo_radius_zomb 				= 96;
	self.death_explo_radius_plr 					= 96;
	self.death_explo_damage_zomb 			= 1.05;
	self.death_gas_radius 							= 125;
	self.death_gas_time 							= 7;
	self.b_phase_quad	 							= level.quad_phase;
	self.can_explode 									= 0;
	self.exploded 										= 0;
	self.zombie_can_sidestep 					= 1;
	self.zombie_can_forwardstep 				= 1;
	self.goalRadius 										= 16;
	self.maxsightdistsqrd 							= 16384;
	
	if ( IS_TRUE( level.quad_explode ) )
	{
		self.deathFunction 							= &quad_post_death;
		self.actor_killed_override 					= &quad_killed_override;
	}
	self.thundergun_knockdown_func 		= &quad_thundergun_knockdown;
	
	self allowPitchAngle( 1 );
	self setPhysParams( 15, 0, 24 );
	self quad_phase_setup();
	self thread quad_trail();
	
	self playSound( "zmb_quad_spawn" );
	
	if ( isDefined( level.quad_prespawn ) )
		self thread [ [ level.quad_prespawn ] ]();
	
}

function quad_phase_setup()
{
	self.can_phase = 0;
	self.last_phase_time = getTime();
	self.phase_counter = 0;
	if ( !isDefined( level.quad_phase_anims ) )
	{
		level.quad_phase_anims = [];
		level.quad_phase_anims[ "phase_forward" ] 		= self animMappingSearch( iString( "anim_zombie_phase_f_long_b" ) );
		level.quad_phase_anims[ "phase_left_long" ] 		= self animMappingSearch( iString( "anim_zombie_phase_l_long_b" ) );
		level.quad_phase_anims[ "phase_left_short" ] 	= self animMappingSearch( iString( "anim_zombie_phase_l_short_b" ) );
		level.quad_phase_anims[ "phase_right_long" ] 	= self animMappingSearch( iString( "anim_zombie_phase_r_long_b" ) );
		level.quad_phase_anims[ "phase_right_short" ] 	= self animMappingSearch( iString( "anim_zombie_phase_r_short_a" ) );
	}
}

// ============================== SPAWN LOGIC ==============================

// ============================== EVENT OVERRIDES ==============================

function quad_thundergun_knockdown( e_player, b_gib )
{
	self endon( "death" );
	damage = int( self.maxhealth * .5 );
	self doDamage( damage, e_player.origin, e_player );
}

function quad_killed_override( e_inflictor, e_attacker, n_damage, str_means_of_death, w_weapon, v_dir, str_hit_loc, f_offset_time )
{
	if ( str_means_of_death == "MOD_PISTOL_BULLET" || str_means_of_death == "MOD_RIFLE_BULLET" )
		self.can_explode = 1;
	else
	{
		self.can_explode = 0;
		if ( isDefined( self.fx_quad_trail ) )
		{
			self.fx_quad_trail unlink();
			self.fx_quad_trail delete();
		}
	}
	if ( isDefined( level._override_quad_explosion ) )
		[ [ level._override_quad_explosion ] ]( self );
	
}

function quad_post_death( e_inflictor, e_attacker, n_damage, str_means_of_death, w_weapon, v_dir, str_hit_loc, f_offset_time )
{
	self zm_spawner::zombie_death_animscript();
	return 0;
}

// ============================== EVENT OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function quad_location()
{
	self endon( "death" );
	
	if ( !isDefined( level.zm_loc_types[ "quad_location" ] ) || level.zm_loc_types[ "quad_location" ].size <= 0 )
	{
		self doDamage( self.health + 666, self.origin );
		return;
	}
	
	s_spot = array::random( level.zm_loc_types[ "quad_location" ] );
	if ( isDefined( s_spot.target ) )
		self.target = s_spot.target;
	if ( isDefined( s_spot.zone_name ) )
		self.zone_name = s_spot.zone_name;
	
	self.e_anchor = spawn( "script_origin", self.origin );
	self.e_anchor.angles = self.angles;
	self linkTo( self.e_anchor );
	if ( !isDefined( s_spot.angles ) )
		s_spot.angles = ( 0, 0, 0 );
	
	self ghost();
	self.e_anchor moveTo( s_spot.origin, .05 );
	self.e_anchor waittill( "movedone" );
	v_target_org = zombie_utility::get_desired_origin();
	
	if ( isDefined( v_target_org ) )
	{
		v_anim_ang = vectorToAngles( v_target_org - self.origin );
		self.e_anchor rotateTo( ( 0, v_anim_ang[ 1 ], 0 ), .05 );
		self.e_anchor waittill( "rotatedone" );
	}
	
	if ( isDefined( level.zombie_spawn_fx ) )
		playFX( level.zombie_spawn_fx, s_spot.origin );
	
	self unLink();
	if ( isDefined( self.e_anchor ) )
		self.e_anchor delete();
	
	self show();
	playFXOnTag( level._effect[ "quad_phasing_out" ], self, "j_spine4" );
	self notify( "risen", s_spot.script_string );
}

function quad_vox()
{
	self endon( "death" );
	wait 5;
	n_quad_wait = 5;
	while ( 1 )
	{
		a_players = getPlayers();
		for ( i = 0; i < a_players.size; i++ )
		{
			if ( distanceSquared( self.origin, a_players[ i ].origin ) > 1440000 )
			{
				self playSound( "zmb_quad_amb" );
				n_quad_wait = 7;
				continue;
			}
			if ( distanceSquared( self.origin, a_players[ i ].origin ) > 40000 )
			{
				self playSound( "zmb_quad_vox" );
				n_quad_wait = 5;
				continue;
			}
			if ( distanceSquared( self.origin, a_players[ i ].origin ) < 22500 )
				wait .05;
			
		}
		wait randomFloatRange( 1, n_quad_wait );
	}
}

function quad_gas_explo_death()
{
	a_death_vars = [];
	a_death_vars[ "explo_radius_zomb" ] 		= self.death_explo_radius_zomb;
	a_death_vars[ "explo_radius_plr" ] 				= self.death_explo_radius_plr;
	a_death_vars[ "explo_damage_zomb" ] 	= self.death_explo_damage_zomb;
	a_death_vars[ "gas_radius" ] 						= self.death_gas_radius;
	a_death_vars[ "gas_time" ] 						= self.death_gas_time;
	
	self thread quad_death_explo( self.origin, a_death_vars );
	level thread quad_gas_area_of_effect( self.origin, a_death_vars );
}

function quad_death_explo( v_origin, a_death_vars )
{
	playSoundAtPosition( "zmb_quad_explo", v_origin );
	
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( distance( v_origin, a_players[ i ].origin) <= a_death_vars[ "explo_radius_plr" ] )
		{
			b_is_immune = 0;
			if ( isDefined( level.quad_gas_immune_func ) )
				b_is_immune = a_players[ i ] thread [ [ level.quad_gas_immune_func ] ]();
			
			if ( !IS_TRUE( b_is_immune ) )
				a_players[ i ] shellShock( "explosion", 2.5 );
			
		}
	}
	self.exploded = 1;
	self radiusDamage( v_origin, a_death_vars[ "explo_radius_zomb" ], level.zombie_health, level.zombie_health, self, "MOD_EXPLOSIVE" );
}

function quad_damage_func( e_player )
{
	if ( IS_TRUE( self.exploded ) )
		return 0;
	
	return self.meleeDamage;
}

function quad_gas_area_of_effect( v_origin, a_death_vars )
{
	e_effect_area = spawn( "trigger_radius", v_origin, 0, a_death_vars[ "gas_radius" ], 100 );
	playFX( level._effect[ "quad_explo_gas" ], v_origin );
	for ( n_gas_time = 0; n_gas_time <= a_death_vars[ "gas_time" ]; n_gas_time++ )
	{
		a_players = getPlayers();
		for ( i = 0; i < a_players.size; i++ )
		{
			b_is_immune = 0;
			if ( isDefined( level.quad_gas_immune_func ) )
				b_is_immune = a_players[ i ] thread [ [ level.quad_gas_immune_func ] ]();
			
			if ( a_players[ i ] isTouching( e_effect_area ) && !IS_TRUE( b_is_immune ) )
			{
				visionset_mgr::activate( "overlay", "zm_ai_quad_blur", a_players[ i ] );
				continue;
			}
			visionset_mgr::deactivate( "overlay", "zm_ai_quad_blur", a_players[ i ] );
		}
		wait 1;
	}
	a_players = getPlayers();
	for( i = 0; i < a_players.size; i++ )
		visionset_mgr::deactivate( "overlay", "zm_ai_quad_blur", a_players[ i ] );
	
	e_effect_area delete();
}

function quad_trail()
{
	self endon( "death" );
	self.fx_quad_trail = spawn( "script_model", self getTagOrigin( "tag_origin" ) );
	self.fx_quad_trail.angles = self getTagAngles( "tag_origin" );
	self.fx_quad_trail setModel( "tag_origin" );
	self.fx_quad_trail linkTo( self, "tag_origin" );
	zm_net::network_safe_play_fx_on_tag( "quad_fx", 2, level._effect[ "quad_trail" ], self.fx_quad_trail, "tag_origin" );
}

function quad_pre_teleport()
{
	if ( isDefined( self.fx_quad_trail ) )
	{
		self.fx_quad_trail unlink();
		self.fx_quad_trail delete();
		wait .1;
	}
}

function quad_post_teleport()
{
	if ( isDefined( self.fx_quad_trail ) )
	{
		self.fx_quad_trail unlink();
		self.fx_quad_trail delete();
	}
	if ( self.health > 0 )
	{
		self.fx_quad_trail = spawn( "script_model", self getTagOrigin( "tag_origin" ) );
		self.fx_quad_trail.angles = self getTagAngles( "tag_origin" );
		self.fx_quad_trail setModel( "tag_origin" );
		self.fx_quad_trail linkTo( self, "tag_origin" );
		zm_net::network_safe_play_fx_on_tag( "quad_fx", 2, level._effect[ "quad_trail" ], self.fx_quad_trail, "tag_origin" );
	}
}

function moon_quad_phase_fx( str_fx )
{
	self endon( "death" );
	if ( isDefined( level._effect[ str_fx ] ) )
		playFXOnTag( level._effect[ str_fx ], self, "j_spine4" );
	
}

function moon_quad_gas_immune()
{
	self endon( "disconnect" );
	self endon( "death" );
}

// ============================== FUNCTIONALITY ==============================