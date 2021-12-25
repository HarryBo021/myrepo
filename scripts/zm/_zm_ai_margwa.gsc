#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\margwa;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
// #using scripts\zm\_zm_ai_wasp; // TEMPORARY
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
// #using scripts\zm\_zm_weap_idgun;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;

#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;

#namespace zm_ai_margwa;

#precache( "model", "c_zom_margwa_fb" );
#precache( "model", "c_zom_dlc4_margwa_fb" );

function autoexec init()
{
	init_margwa__behaviors_and_asm();
	level.margwa_spawners = getEntArray( "zombie_margwa_spawner", "script_noteworthy" );
	level.margwa_locations = struct::get_array( "margwa_location", "script_noteworthy" );
	level thread AAT::register_immunity( "zm_aat_blast_furnace", "margwa", 0, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_dead_wire", "margwa", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_fire_works", "margwa", 1, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_thunder_wall", "margwa", 0, 1, 1 );
	level thread AAT::register_immunity( "zm_aat_turned", "margwa", 1, 1, 1 );
	spawner::add_archetype_spawn_function( "margwa", &margwa_setup );
}

function private init_margwa__behaviors_and_asm()
{
	BT_REGISTER_API( "zmMargwaTargetService", &zm_margwa_target_service );
	BT_REGISTER_API( "zmMargwaTeleportService", &zm_margwa_teleport_service );
	BT_REGISTER_API( "zmMargwaZoneService", &zm_margwa_zone_service );
	BT_REGISTER_API( "zmMargwaPushService", &zm_margwa_push_service );
	BT_REGISTER_API( "zmMargwaOctobombService", &zm_margwa_octobomb_service );
	BT_REGISTER_API( "zmMargwaVortexService", &zm_margwa_vortex_service );
	BT_REGISTER_API( "zmMargwaShouldSmashAttack", &zm_margwa_should_smash_attack );
	BT_REGISTER_API( "zmMargwaShouldSwipeAttack", &zm_margwa_should_swipe_attack );
	BT_REGISTER_API( "zmMargwaShouldOctobombAttack", &zm_margwa_should_octobomb_attack );
	BT_REGISTER_API( "zmMargwaShouldMove", &zm_margwa_should_move );
	BT_REGISTER_ACTION( "zmMargwaSwipeAttackAction", &zm_margwa_swipe_attack_action, &zm_margwa_swipe_attack_action_update, undefined );
	BT_REGISTER_ACTION( "zmMargwaOctobombAttackAction", &zm_margwa_octobomb_attack_action, &zm_margwa_octobomb_attack_action_update, &zm_margwa_octobomb_attack_action_terminate );
	BT_REGISTER_API( "zmMargwaSmashAttackTerminate", &zm_margwa_smash_attack_terminate );
	BT_REGISTER_API( "zmMargwaSwipeAttackTerminate", &zm_margwa_swipe_attack_terminate );
	BT_REGISTER_API( "zmMargwaTeleportInTerminate", &zm_margwa_teleport_in_terminate );
}

function margwa_thundergun_fling_func( e_player, b_gib )
{
	self endon( "death" );
	self margwa_thundergun_knockdown_setup( e_player );
	if ( IS_TRUE( self.canStun ) )
		self.reactStun = 1;
	
}

function margwa_thundergun_knockdown_func( e_player, b_gib )
{
	self endon( "death" );
	self margwa_thundergun_knockdown_setup( e_player, 1 );
	if ( IS_TRUE( self.canStun ) )
		self.reactStun = 1;
	
}

function margwa_thundergun_knockdown_setup( e_player, b_knockdown = 0 )
{
	if ( isDefined( self ) )
	{
		foreach ( e_head in self.head )
		{
			if ( e_head MargwaServerUtils::margwaCanDamageHead() )
			{
				n_damage = e_head.health;
				if ( b_knockdown )
					n_damage = n_damage * .5;
				
				e_head.health = e_head.health - n_damage;
				if ( isDefined( self.var_5ffc5a7b ) )
					self [ [ self.var_5ffc5a7b ] ]( e_player );
				
				if ( e_head.health <= 0 )
				{
					if ( self MargwaServerUtils::margwaKillHead( e_head.model, e_player ) )
					{
						self.is_kill = 1;
						self kill( self.origin, e_player, e_player, level.weaponZMThunderGun );
					}
				}
				return;
			}
		}
	}
}

function private zm_margwa_target_service( e_entity )
{
	if ( IS_TRUE( e_entity.ignoreall ) )
		return 0;
	
	if ( IS_TRUE( e_entity.isTeleporting ) )
		return 0;
	
	if ( isDefined( e_entity.destroy_octobomb ) )
		return 0;
	
	e_entity zombie_utility::run_ignore_player_handler();
	e_player = zm_utility::get_closest_valid_player( e_entity.origin, e_entity.ignore_player );
	e_entity.favoriteenemy = e_player;
	if ( !isDefined( e_player ) || zm_behavior::zombieShouldMoveAwayCondition( e_entity ) )
	{
		str_zone = zm_utility::get_current_zone();
		if ( isDefined( str_zone ) )
		{
			a_wait_locations = level.zones[ str_zone ].a_loc_types[ "wait_location" ];
			if ( isDefined( a_wait_locations ) && a_wait_locations.size > 0 )
				return e_entity MargwaServerUtils::margwaSetGoal( a_wait_locations[ 0 ].origin, 64, 30 );
			
		}
		e_entity setGoal( e_entity.origin );
		return 0;
	}
	return e_entity MargwaServerUtils::margwaSetGoal( e_entity.favoriteenemy.origin, 64, 30 );
}

function private zm_margwa_teleport_service( e_entity )
{
	if ( !IS_TRUE( e_entity.needTeleportOut ) && !IS_TRUE( e_entity.isTeleporting ) && isDefined( e_entity.favoriteenemy ) )
	{
		b_can_teleport = 0;
		n_dist_sq = distanceSquared( self.favoriteenemy.origin, e_entity.origin );
		n_max_dist = 2250000;
		
		if ( n_dist_sq > n_max_dist )
		{
			if ( isDefined( e_entity.destroy_octobomb ) )
				b_can_teleport = 0;
			else
				b_can_teleport = 1;
			
		}
		else if ( isDefined( level.ptr_margwa_can_teleport_override ) )
		{
			if ( e_entity [ [ level.ptr_margwa_can_teleport_override ] ]() )
				b_can_teleport = 1;
			
		}
		if ( b_can_teleport )
		{
			if ( isDefined( self.favoriteenemy.zone_name ) )
			{
				a_wait_locations = level.zones[ self.favoriteenemy.zone_name ].a_loc_types[ "wait_location" ];
				if ( isDefined( a_wait_locations ) && a_wait_locations.size > 0 )
				{
					a_wait_locations = array::randomize( a_wait_locations );
					e_entity.needTeleportOut = 1;
					e_entity.teleportPos = a_wait_locations[ 0 ].origin;
					return 1;
				}
			}
		}
	}
	return 0;
}

function private zm_margwa_zone_service( e_entity )
{
	if ( IS_TRUE( e_entity.isTeleporting ) )
		return 0;
	
	if ( !isDefined( e_entity.zone_name ) )
		e_entity.zone_name = zm_utility::get_current_zone();
	else
	{
		e_entity.previous_zone_name = e_entity.zone_name;
		e_entity.zone_name = zm_utility::get_current_zone();
	}
	return 1;
}

function private zm_margwa_push_service( e_entity )
{
	if ( e_entity.zombie_move_speed == "walk" )
		return 0;
	
	a_zombies = zombie_utility::get_round_enemy_array();
	foreach ( e_zombie in a_zombies )
	{
		n_dist_sq = distanceSquared( e_entity.origin, e_zombie.origin );
		if ( n_dist_sq < 2304 )
		{
			e_zombie.pushed = 1;
			v_face_angles = self.origin - e_zombie.origin;
			v_norm_face_angles_no_z = vectorNormalize( ( v_face_angles[ 0 ], v_face_angles[ 1 ], 0 ) );
			v_zombie_right = anglesToRight( e_zombie.angles );
			v_zombie_right_2d = vectorNormalize( ( v_zombie_right[ 0 ], v_zombie_right[ 1 ], 0 ) );
			n_dot = vectorDot( v_norm_face_angles_no_z, v_zombie_right_2d );
			if ( n_dot > 0 )
			{
				e_zombie.push_direction = "left";
				continue;
			}
			e_zombie.push_direction = "right";
		}
	}
}

function private zm_margwa_octobomb_service( e_entity )
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
				n_dist_sq = distanceSquared( e_octobomb.origin, self.origin );
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

function private margwa_is_in_vortex( e_entity )
{
	if ( isDefined( self.react ) )
	{
		foreach ( react in self.react )
		{
			if ( react == e_entity )
				return 1;
			
		}
	}
	return 0;
}

function private margwa_add_to_vortex( e_entity )
{
	if ( !isDefined( self.react ) )
		self.react = [];
	
	self.react[ self.react.size ] = e_entity;
}

function zm_margwa_vortex_service( e_entity )
{
	if ( !IS_TRUE( e_entity.canStun ) )
		return 0;
	
	if ( isDefined( level.vortex_manager ) && isDefined( level.vortex_manager.a_active_vorticies ) )
	{
		foreach ( e_vortex in level.vortex_manager.a_active_vorticies )
		{
			if ( !e_vortex margwa_is_in_vortex( e_entity ) )
			{
				n_dist_sq = DistanceSquared( e_vortex.origin, self.origin );
				if ( n_dist_sq < 9216 )
				{
					e_entity.reactIDGun = 1;
					if ( isDefined( e_vortex.weapon ) && is_upgraded_idgun( e_vortex.weapon ) )
						blackboard::SetBlackBoardAttribute( e_entity, "_zombie_damageweapon_type", "packed" );
					
					e_vortex margwa_add_to_vortex( e_entity );
					return 1;
				}
			}
		}
	}
	return 0;
}

function is_idgun_damage( w_weapon )
{
	if ( isDefined( level.idgun_weapons ) )
	{
		if ( isInArray( level.idgun_weapons, w_weapon ) )
			return 1;
		
	}
	return 0;
}

function is_upgraded_idgun( w_weapon )
{
	if ( is_idgun_damage( w_weapon ) && zm_weapons::is_weapon_upgraded( w_weapon ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_smash_attack( e_entity )
{
	if ( isDefined( e_entity.destroy_octobomb ) )
		return 0;
	
	if ( !isDefined( e_entity.n_margwa_attack_type ) || e_entity.n_margwa_attack_type != 1 )
		return 0;
	
	return MargwaBehavior::margwaShouldSmashAttack( e_entity );
}

function private zm_margwa_should_swipe_attack( e_entity )
{
	if ( isDefined( e_entity.destroy_octobomb ) )
		return 0;
	
	if ( !isDefined( e_entity.n_margwa_attack_type ) || e_entity.n_margwa_attack_type != 2 )
		return 0;
	
	return MargwaBehavior::margwaShouldSwipeAttack( e_entity );
}

function private zm_margwa_should_octobomb_attack( e_entity )
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

function private zm_margwa_should_move( e_entity )
{
	if ( IS_TRUE( e_entity.needTeleportOut ) )
		return 0;
	
	if ( isDefined( e_entity.destroy_octobomb ) )
	{
		if ( zm_margwa_should_octobomb_attack( e_entity ) )
			return 0;
		
	}
	else if ( zm_margwa_should_swipe_attack( e_entity ) )
		return 0;
	
	if ( zm_margwa_should_smash_attack( e_entity ) )
		return 0;
	
	if ( e_entity hasPath() )
		return 1;
	
	return 0;
}

function private zm_margwa_octobomb_attack_action( e_entity, str_asm_state_name )
{
	animationStateNetworkUtility::requestState( e_entity, str_asm_state_name );
	if ( !isDefined( e_entity.n_margwa_next_octobomb_time ) )
		e_entity.n_margwa_next_octobomb_time = getTime() + randomIntRange( 3000, 4000 );
	
	return 5;
}

function private zm_margwa_octobomb_attack_action_update( e_entity, str_asm_state_name )
{
	if ( !isDefined( e_entity.destroy_octobomb ) )
		return 4;
	
	if ( isDefined( e_entity.n_margwa_next_octobomb_time ) && getTime() > e_entity.n_margwa_next_octobomb_time )
		return 4;
	
	return 5;
}

function private zm_margwa_octobomb_attack_action_terminate( e_entity, str_asm_state_name )
{
	if ( isDefined( e_entity.destroy_octobomb ) )
		e_entity.destroy_octobomb detonate();
	
	e_entity.n_margwa_next_octobomb_time = undefined;
	return 4;
}

function private zm_margwa_swipe_attack_action( e_entity, str_asm_state_name )
{
	AnimationStateNetworkUtility::RequestState( e_entity, str_asm_state_name );
	if ( !isDefined( e_entity.swipe_end_time ) )
	{
		a_swipe_action_ast = e_entity ASTSearch( istring( str_asm_state_name ) );
		str_swipe_sction_animation = AnimationStateNetworkUtility::SearchAnimationMap( e_entity, a_swipe_action_ast[ "animation" ] );
		n_swipe_action_time = getAnimLength( str_swipe_sction_animation ) * 1000;
		e_entity.swipe_end_time = getTime() + n_swipe_action_time;
	}
	MargwaBehavior::margwaSwipeAttackStart( e_entity );
	return 5;
}

function private zm_margwa_swipe_attack_action_update( e_entity, str_asm_state_name )
{
	if ( isDefined( e_entity.swipe_end_time ) && getTime() > e_entity.swipe_end_time )
		return 4;
	
	return 5;
}

function private zm_margwa_smash_attack_terminate( e_entity )
{
	e_entity.swipe_end_time = undefined;
	e_entity margwa_randomize_next_attack();
	MargwaBehavior::margwaSmashAttackTerminate( e_entity );
}

function private zm_margwa_swipe_attack_terminate( e_entity )
{
	e_entity.swipe_end_time = undefined;
	e_entity margwa_randomize_next_attack();
}

function private zm_margwa_teleport_in_terminate( e_entity )
{
	MargwaBehavior::margwaTeleportInTerminate( e_entity );
	e_entity.previous_zone_name = e_entity.zone_name;
	e_entity.zone_name = zm_utility::get_current_zone();
}

function private margwa_setup()
{
	self.destroyHeadCB = &margwa_destroy_head_cb;
	self.bodyfallCB = &margwa_body_fall_cb;
	self.chop_actor_cb = &margwa_chop_actor_cb;
	// self.var_a3b60c68 = &margwa_glaive_damage_cb; // REACTION TO SOE SWORD
	self.smashAttackCB = &margwa_smash_attack;
	self.lightning_chain_immune = 1;
	self.ignore_game_over_death = 1;
	self.should_turn = 1;
	self.jawAnimEnabled = 1;
	self.sword_kill_power = 5;
	self margwa_randomize_next_attack();
}

function private margwa_destroy_head_cb( str_model_hit, e_attacker )
{
	if ( isPlayer( e_attacker ) && !IS_TRUE( self.deathpoints_already_given )  )
		e_attacker zm_score::player_add_points( "bonus_points_powerup", 500 );
	
	v_spawn_pos = self.origin + anglesToRight( self.angles ) + vectorScale( ( 0, 0, 1 ), 128 );
	s_loc = spawnStruct();
	s_loc.origin = v_spawn_pos;
	s_loc.angles = self.angles;
	self margwa_head_explode_fx();
	str_spawner_override = undefined;
	if ( isDefined( level.e_margwa_wasp_spawner ) )
		str_spawner_override = level.e_margwa_wasp_spawner;
	
	// zm_ai_wasp::special_wasp_spawn( 1, s_loc, 32, 32, 1, 0, 0, str_spawner_override ); // TEMPORARY
	if ( isDefined( self.ptr_margwa_destroy_head_cb ) )
		self thread [ [ self.ptr_margwa_destroy_head_cb ] ]( str_model_hit, e_attacker );
	
	if ( isDefined( level.hero_power_update ) )
		[ [ level.hero_power_update ] ]( e_attacker, self );
	
	s_loc struct::delete();
}

function private margwa_body_fall_cb()
{
	v_power_up_origin = self.origin + vectorScale( anglesToForward( self.angles ), 32 ) + vectorScale( ( 0, 0, 1 ), 16 );
	if ( isDefined( v_power_up_origin ) && !IS_TRUE( self.no_powerups ) )
	{
		a_margwa_death_powerups = [];
		foreach ( e_powerup in level.zombie_powerup_array )
		{
			if ( e_powerup == "carpenter" )
				continue;
			
			if ( ![ [ level.zombie_powerups[ e_powerup ].func_should_drop_with_regular_powerups ] ]() )
				continue;
			
			a_margwa_death_powerups[ a_margwa_death_powerups.size ] = e_powerup;
		}
		str_margwa_death_powerup = array::random( a_margwa_death_powerups );
		level thread zm_powerups::specific_powerup_drop( str_margwa_death_powerup, v_power_up_origin );
	}
}

function private margwa_head_explode_fx()
{
	a_players = getPlayers();
	foreach ( e_player in a_players )
	{
		n_dist_sq = distanceSquared( self.origin, e_player.origin );
		if ( n_dist_sq < 16384 )
			e_player clientfield::increment_to_player( "margwa_head_explosion" );
		
	}
}

function spawn_margwa( s_location )
{
	if ( isDefined( level.margwa_spawners[ 0 ] ) )
	{
		level.margwa_spawners[ 0 ].script_forcespawn = 1;
		e_ai_margwa = zombie_utility::spawn_zombie( level.margwa_spawners[ 0 ], "margwa", s_location );
		e_ai_margwa disableAimAssist();
		e_ai_margwa.actor_damage_func = &MargwaServerUtils::margwaDamage;
		e_ai_margwa.canDamage = 0;
		e_ai_margwa.targetname = "margwa";
		e_ai_margwa.holdFire = 1;
		e_player = zm_utility::get_closest_player( s_location.origin );
		v_dir = e_player.origin - s_location.origin;
		v_dir = vectorNormalize( v_dir );
		v_angles = vectorToAngles( v_dir );
		e_ai_margwa forceTeleport( s_location.origin, v_angles );
		e_ai_margwa margwa_pre_spawn();
		
		e_ai_margwa.ignore_round_robbin_death = 1;
		e_ai_margwa thread margwa_post_spawn();
		return e_ai_margwa;
	}
	return undefined;
}

function private margwa_post_spawn()
{
	util::wait_network_frame();
	self clientfield::increment( "margwa_fx_spawn" );
	wait 3;
	self margwa_enable_movement();
	self.canDamage = 1;
	self.needSpawn = 1;
}

function private margwa_pre_spawn()
{
	self.isFrozen = 1;
	self ghost();
	self notSolid();
	self pathMode( "dont move" );
}

function private margwa_enable_movement()
{
	self.isFrozen = 0;
	self show();
	self solid();
	self pathMode( "move allowed" );
}

function private margwa_chop_actor_cb( e_entity, e_inflictor, w_weapon )
{
	if ( !IS_TRUE( e_entity.canDamage ) )
		return 0;
	
	a_alive_heads = [];
	if ( isDefined( e_entity.head ) )
	{
		foreach ( head in e_entity.head )
		{
			if ( head.health > 0 && head.canDamage )
				a_alive_heads[ a_alive_heads.size ] = head;
			
		}
	}
	else if ( a_alive_heads.size > 0 )
	{
		view_pos = self getWeaponMuzzlePoint();
		forward_view_angles = self getWeaponForwardDir();
		e_destroy_head = undefined;
		foreach ( e_head in a_alive_heads )
		{
			head_pos = e_entity getTagOrigin( e_head.tag );
			v_angles_to_head = vectorNormalize( head_pos - view_pos );
			if ( !isDefined( e_destroy_head ) )
			{
				e_destroy_head = e_head;
				n_first_dot = vectorDot( forward_view_angles, v_angles_to_head );
				continue;
			}
			n_dot = vectorDot( forward_view_angles, v_angles_to_head );
			if ( n_dot > n_first_dot )
			{
				n_first_dot = n_dot;
				e_destroy_head = e_head;
			}
		}
		if ( isDefined( e_destroy_head ) )
		{
			e_destroy_head.health = e_destroy_head.health - 1750;
			e_entity clientfield::increment( e_destroy_head.impactCF );
			if ( e_destroy_head.health <= 0 )
			{
				if ( e_entity MargwaServerUtils::margwaKillHead( e_destroy_head.model, self ) )
				{
					e_entity kill( self.origin, undefined, undefined, w_weapon );
					return 1;
				}
			}
		}
	}
	return 0;
}

function private margwa_glaive_damage_cb( e_entity, w_weapon )
{
	if ( IS_TRUE( e_entity.canStun ) )
		e_entity.reactStun = 1;
	
}

function private margwa_smash_attack()
{
	a_zombies = zombie_utility::get_round_enemy_array();
	foreach ( e_zombie in a_zombies )
	{
		v_smash_pos = self.origin + vectorScale( anglesToForward( self.angles ), 60 );
		n_dist_sq = distanceSquared( v_smash_pos, e_zombie.origin );
		if ( n_dist_sq < 20736 )
		{
			e_zombie.knockdown = 1;
			self margwa_knockdown_zombie( e_zombie );
		}
	}
}

function private margwa_randomize_next_attack()
{
	n_r = randomIntRange( 0, 100 );
	if ( n_r < 40 )
		self.n_margwa_attack_type = 2;
	else
		self.n_margwa_attack_type = 1;
	
}

function private margwa_knockdown_zombie( e_zombie )
{
	v_angles_to_margwa = self.origin - e_zombie.origin;
	v_angles_to_margwa_normal_no_z = vectorNormalize( ( v_angles_to_margwa[ 0 ], v_angles_to_margwa[ 1 ], 0 ) );
	v_zombie_forward = anglesToForward( e_zombie.angles );
	v_zombie_forward_2d = vectorNormalize( ( v_zombie_forward[ 0 ], v_zombie_forward[ 1 ], 0 ) );
	v_zombie_right = anglesToRight( e_zombie.angles );
	v_zombie_right_2d = vectorNormalize( ( v_zombie_right[ 0 ], v_zombie_right[ 1 ], 0 ) );
	n_dot = vectorDot( v_angles_to_margwa_normal_no_z, v_zombie_forward_2d );
	if ( n_dot >= .5 )
	{
		e_zombie.knockdown_direction = "front";
		e_zombie.getup_direction = "getup_back";
	}
	else if ( n_dot < .5 && n_dot > -.5 )
	{
		n_dot = vectorDot( v_angles_to_margwa_normal_no_z, v_zombie_right_2d );
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