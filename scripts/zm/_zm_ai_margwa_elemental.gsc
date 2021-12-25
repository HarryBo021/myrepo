#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\margwa;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_ai_margwa;
#using scripts\zm\_zm_elemental_zombies;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_light_zombie;
#using scripts\zm\_zm_shadow_zombie;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#insert scripts\zm\_zm_ai_margwa_elemental.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_ai_margwa_elemental;

function autoexec init()
{
	MargwaBehavior::AddDirectHitWeapon( "shotgun_energy" );
	MargwaBehavior::AddDirectHitWeapon( "shotgun_energy_upgraded" );
	MargwaBehavior::AddDirectHitWeapon( "pistol_energy" );
	MargwaBehavior::AddDirectHitWeapon( "pistol_energy_upgraded" );
	if ( !isDefined( level.a_margwa_head_model_overrides ) )
	{
		level.a_margwa_head_model_overrides = [];
		level.a_margwa_head_model_overrides[ "head_le" ] = MARGWA_ELEMENTAL_MODEL_HEAD_LEFT;
		level.a_margwa_head_model_overrides[ "head_mid" ] = MARGWA_ELEMENTAL_MODEL_HEAD_MID;
		level.a_margwa_head_model_overrides[ "head_ri" ] = MARGWA_ELEMENTAL_MODEL_HEAD_RIGHT;
		level.a_margwa_head_model_overrides[ "gore_le" ] = MARGWA_ELEMENTAL_MODEL_GORE_LEFT;
		level.a_margwa_head_model_overrides[ "gore_mid" ] = MARGWA_ELEMENTAL_MODEL_GORE_MID;
		level.a_margwa_head_model_overrides[ "gore_ri" ] = MARGWA_ELEMENTAL_MODEL_GORE_RIGHT;
		level.margwa_head_left_model_override = level.a_margwa_head_model_overrides[ "head_le" ];
		level.margwa_head_mid_model_override = level.a_margwa_head_model_overrides[ "head_mid" ];
		level.margwa_head_right_model_override = level.a_margwa_head_model_overrides[ "head_ri" ];
		level.margwa_gore_left_model_override = level.a_margwa_head_model_overrides[ "gore_le" ];
		level.margwa_gore_mid_model_override = level.a_margwa_head_model_overrides[ "gore_mid" ];
		level.margwa_gore_right_model_override = level.a_margwa_head_model_overrides[ "gore_ri" ];
	}
	
	init_margwa_elemental_behaviors_and_asm();
	spawner::add_archetype_spawn_function( "margwa", &elemental_margwa_spawn_setup );
	clientfield::register( "actor", MARGWA_ELEMENTAL_TYPE_CF, VERSION_SHIP, 3, "int" );
	clientfield::register( "actor", MARGWA_ELEMENTAL_DEFENSE_ACTOR_APPEAR_DISAPPEAR_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", MARGWA_ELEMENTAL_PLAY_MARGWA_FIRE_ATTACK_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, VERSION_SHIP, 3, "int" );
	clientfield::register( "actor", MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", MARGWA_ELEMENTAL_MARGWA_SHOCK_FX_CF, VERSION_SHIP, 1, "int" );
	a_zombie_wasp_elite_spawners = getEntArray( "zombie_wasp_elite_spawner", "script_noteworthy" );
	if ( isDefined( a_zombie_wasp_elite_spawners ) && a_zombie_wasp_elite_spawners.size > 0 )
		level.e_margwa_wasp_spawner = a_zombie_wasp_elite_spawners[ 0 ];
	
	zm::register_actor_damage_callback( &margwa_shadow_actor_damage_callback );
}

function private init_margwa_elemental_behaviors_and_asm()
{
	BT_REGISTER_API( "zmMargwaFireAttackService", &zm_margwa_fire_attack_service );
	BT_REGISTER_API( "zmMargwaFireDefendService", &zm_margwa_fire_defend_service );
	BT_REGISTER_API( "zmMargwaElectricGroundAttackService", &zm_margwa_electric_ground_attack_service );
	BT_REGISTER_API( "zmMargwaElectricShootAttackService", &zm_margwa_electric_shoot_attack_service );
	BT_REGISTER_API( "zmMargwaElectricDefendService", &zm_margwa_electric_defend_service );
	BT_REGISTER_API( "zmMargwaLightAttackService", &zm_margwa_light_attack_service );
	BT_REGISTER_API( "zmMargwaLightDefendService", &zm_margwa_light_defend_service );
	BT_REGISTER_API( "zmMargwaShadowAttackService", &zm_margwa_shadow_attack_service );
	BT_REGISTER_API( "zmMargwaShadowDefendService", &zm_margwa_shadow_defend_service );
	BT_REGISTER_API( "zmMargwaShouldFireAttack", &zm_margwa_should_fire_attack );
	BT_REGISTER_API( "zmMargwaShouldFireDefendOut", &zm_margwa_should_fire_defend_out );
	BT_REGISTER_API( "zmMargwaShouldFireDefendIn", &zm_margwa_should_fire_defend_in );
	BT_REGISTER_API( "zmMargwaShouldElectricGroundAttack", &zm_margwa_should_electric_ground_attack );
	BT_REGISTER_API( "zmMargwaShouldElectricShootAttack", &zm_margwa_should_electric_shoot_attack );
	BT_REGISTER_API( "zmMargwaShouldElectricDefendOut", &zm_margwa_should_electric_defend_out );
	BT_REGISTER_API( "zmMargwaShouldElectricDefendIn", &zm_margwa_should_electric_defend_in );
	BT_REGISTER_API( "zmMargwaShouldLightAttack", &zm_margwa_should_light_attack );
	BT_REGISTER_API( "zmMargwaShouldLightDefendOut", &zm_margwa_should_light_defend_out );
	BT_REGISTER_API( "zmMargwaShouldLightDefendIn", &zm_margwa_should_light_defend_in );
	BT_REGISTER_API( "zmMargwaShouldShadowAttack", &zm_margwa_should_shadow_attack );
	BT_REGISTER_API( "zmMargwaShouldShadowAttackLoop", &zm_margwa_should_shadow_attack_loop );
	BT_REGISTER_API( "zmMargwaShouldShadowAttackOut", &zm_margwa_should_shadow_attack_out );
	BT_REGISTER_API( "zmMargwaShouldShadowDefendOut", &zm_margwa_should_shadow_defend_out );
	BT_REGISTER_API( "zmMargwaShouldShadowDefendIn", &zm_margwa_should_shadow_defend_in );
	BT_REGISTER_API( "zmMargwaFireAttack", &zm_margwa_fire_attack );
	BT_REGISTER_API( "zmMargwaFireAttackTerminate", &zm_margwa_fire_attack_terminate );
	BT_REGISTER_API( "zmMargwaFireDefendOut", &zm_margwa_fire_defend_out );
	BT_REGISTER_API( "zmMargwaFireDefendOutTerminate", &zm_margwa_fire_defend_out_terminate );
	BT_REGISTER_API( "zmMargwaFireDefendIn", &zm_margwa_fire_defend_in );
	BT_REGISTER_API( "zmMargwaFireDefendInTerminate", &zm_margwa_fire_defend_in_terminate );
	BT_REGISTER_API( "zmMargwaElectricGroundAttack", &zm_margwa_electric_ground_attack );
	BT_REGISTER_API( "zmMargwaElectricShootAttack", &zm_margwa_electric_shoot_attack );
	BT_REGISTER_API( "zmMargwaElectricDefendOut", &zm_margwa_electric_defend_out );
	BT_REGISTER_API( "zmMargwaElectricDefendOutTerminate", &zm_margwa_electric_defend_out_terminate );
	BT_REGISTER_API( "zmMargwaElectricDefendIn", &zm_margwa_electric_defend_in );
	BT_REGISTER_API( "zmMargwaLightAttack", &zm_margwa_light_attack );
	BT_REGISTER_API( "zmMargwaLightDefendOut", &zm_margwa_light_defend_out );
	BT_REGISTER_API( "zmMargwaLightDefendOutTerminate", &zm_margwa_light_defend_out_terminate );
	BT_REGISTER_API( "zmMargwaLightDefendIn", &zm_margwa_light_defend_in );
	BT_REGISTER_API( "zmMargwaShadowAttack", &zm_margwa_shadow_attack );
	BT_REGISTER_API( "zmMargwaShadowAttackLoop", &zm_margwa_shadow_attack_loop );
	BT_REGISTER_API( "zmMargwaShadowAttackLoopTerminate", &zm_margwa_shadow_attack_loop_terminate );
	BT_REGISTER_API( "zmMargwaShadowAttackOutTerminate", &zm_margwa_shadow_attack_out_terminate );
	BT_REGISTER_API( "zmMargwaShadowDefendOut", &zm_margwa_shadow_defend_out );
	BT_REGISTER_API( "zmMargwaShadowDefendOutTerminate", &zm_margwa_shadow_defend_out_terminate );
	BT_REGISTER_API( "zmMargwaShadowDefendIn", &zm_margwa_shadow_defend_in );
	BT_REGISTER_API( "zmMargwaIsElectric", &zm_margwa_is_electric );
	BT_REGISTER_API( "zmMargwaIsFire", &zm_margwa_is_fire );
	BT_REGISTER_API( "zmMargwaIsLight", &zm_margwa_is_light );
	BT_REGISTER_API( "zmMargwaIsShadow", &zm_margwa_is_shadow );
	BT_REGISTER_API( "genesisMargwaVortexService", &genesis_margwa_vortex_service );
	BT_REGISTER_API( "genesisMargwaSpiderService", &genesis_margwa_spider_service );
	BT_REGISTER_API( "genesisMargwaReactStunTerminate", &genesis_margwa_react_stun_terminate );
	BT_REGISTER_API( "genesisMargwaReactIDGunTerminate", &genesis_margwa_react_idgun_terminate );
}

function spawn_elemental_margwa( e_spawner, str_targetname, str_element, s_location )
{
	if ( isDefined( e_spawner ) )
	{
		level.margwa_head_left_model_override = undefined;
		level.margwa_head_mid_model_override = undefined;
		level.margwa_head_right_model_override = undefined;
		level.margwa_gore_left_model_override = undefined;
		level.margwa_gore_mid_model_override = undefined;
		level.margwa_gore_right_model_override = undefined;
		switch ( str_element )
		{
			case "fire":
			{
				level.margwa_head_left_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_HEAD_LEFT;
				level.margwa_head_mid_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_HEAD_MID;
				level.margwa_head_right_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_HEAD_RIGHT;
				level.margwa_gore_left_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_GORE_LEFT;
				level.margwa_gore_mid_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_GORE_MID;
				level.margwa_gore_right_model_override = MARGWA_ELEMENTAL_FIRE_MODEL_GORE_RIGHT;
				break;
			}
			case "shadow":
			{
				level.margwa_head_left_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_HEAD_LEFT;
				level.margwa_head_mid_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_HEAD_MID;
				level.margwa_head_right_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_HEAD_RIGHT;
				level.margwa_gore_left_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_GORE_LEFT;
				level.margwa_gore_mid_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_GORE_MID;
				level.margwa_gore_right_model_override = MARGWA_ELEMENTAL_SHADOW_MODEL_GORE_RIGHT;
				break;
			}
		}
		e_spawner.script_forcespawn = 1;
		e_ai = zombie_utility::spawn_zombie( e_spawner, str_targetname, s_location );
		level.margwa_head_left_model_override = undefined;
		level.margwa_head_mid_model_override = undefined;
		level.margwa_head_right_model_override = undefined;
		level.margwa_gore_left_model_override = undefined;
		level.margwa_gore_mid_model_override = undefined;
		level.margwa_gore_right_model_override = undefined;
		if ( isDefined( level.a_margwa_head_model_overrides ) )
		{
			level.margwa_head_left_model_override = level.a_margwa_head_model_overrides[ "head_le" ];
			level.margwa_head_mid_model_override = level.a_margwa_head_model_overrides[ "head_mid" ];
			level.margwa_head_right_model_override = level.a_margwa_head_model_overrides[ "head_ri" ];
			level.margwa_gore_left_model_override = level.a_margwa_head_model_overrides[ "gore_le" ];
			level.margwa_gore_mid_model_override = level.a_margwa_head_model_overrides[ "gore_mid" ];
			level.margwa_gore_right_model_override = level.a_margwa_head_model_overrides[ "gore_ri" ];
		}
		e_ai disableAimAssist();
		e_ai.actor_damage_func = &MargwaServerUtils::margwaDamage;
		e_ai.canDamage = 0;
		e_ai.targetname = str_targetname;
		e_ai.holdFire = 1;
		e_ai margwa_set_element( str_element );
		switch ( str_element )
		{
			case "fire":
			{
				e_ai clientfield::set( MARGWA_ELEMENTAL_TYPE_CF, 1 );
				break;
			}
			case "electric":
			{
				e_ai clientfield::set( MARGWA_ELEMENTAL_TYPE_CF, 2 );
				break;
			}
			case "light":
			{
				e_ai clientfield::set( MARGWA_ELEMENTAL_TYPE_CF, 3 );
				break;
			}
			case "shadow":
			{
				e_ai clientfield::set( MARGWA_ELEMENTAL_TYPE_CF, 4 );
				break;
			}
		}
		e_ai.team = level.zombie_team;
		e_ai.canStun = 1;
		e_ai.thundergun_fling_func = &zm_ai_margwa::margwa_thundergun_fling_func;
		e_ai.thundergun_knockdown_func = &zm_ai_margwa::margwa_thundergun_knockdown_func;
		e_ai.dragonshield_fling_func = &zm_ai_margwa::margwa_thundergun_fling_func;
		e_ai.dragonshield_knockdown_func = &zm_ai_margwa::margwa_thundergun_knockdown_func;
		e_player = zm_utility::get_closest_player( s_location.origin );
		v_dir = e_player.origin - s_location.origin;
		v_dir = vectorNormalize( v_dir );
		v_angles = vectorToAngles( v_dir );
		e_ai forceTeleport( s_location.origin, v_angles );
		e_ai margwa_pre_spawn();
		e_ai thread margwa_elemental_death();
		e_ai.ignore_round_robbin_death = 1;
		e_ai thread margwa_post_spawn();
		level thread zm_spawner::zombie_death_event( e_ai );
		return e_ai;
	}
	return undefined;
}

function spawn_fire_margwa( e_spawner, s_location )
{
	if ( !isDefined( e_spawner ) )
	{
		a_zombie_margwa_fire_spawners = getSpawnerArray( "zombie_margwa_fire_spawner", "script_noteworthy" );
		if ( a_zombie_margwa_fire_spawners.size <= 0 )
			return;
		
		e_spawner = a_zombie_margwa_fire_spawners[ 0 ];
	}
	str_spawner_targetname = MARGWA_ELEMENTAL_FIRE_TARGETNAME;
	str_element = "fire";
	ai = spawn_elemental_margwa( e_spawner, str_spawner_targetname, str_element, s_location );
	return ai;
}

function spawn_shadow_margwa( e_spawner, s_location )
{
	if ( !isDefined( e_spawner ) )
	{
		a_zombie_margwa_shadow_spawners = getSpawnerArray( "zombie_margwa_shadow_spawner", "script_noteworthy" );
		if ( a_zombie_margwa_shadow_spawners.size <= 0 )
			return;
		
		e_spawner = a_zombie_margwa_shadow_spawners[ 0 ];
	}
	str_spawner_targetname = MARGWA_ELEMENTAL_SHADOW_TARGETNAME;
	str_element = "shadow";
	ai = spawn_elemental_margwa( e_spawner, str_spawner_targetname, str_element, s_location );
	return ai;
}

function spawn_light_margwa( e_spawner, s_location )
{
	if ( !isDefined( e_spawner ) )
	{
		a_zombie_margwa_light_spawners = getSpawnerArray( "zombie_margwa_light_spawner", "script_noteworthy" );
		if ( a_zombie_margwa_light_spawners.size <= 0 )
			return;
		
		e_spawner = a_zombie_margwa_light_spawners[ 0 ];
	}
	str_spawner_targetname = MARGWA_ELEMENTAL_LIGHT_TARGETNAME;
	str_element = "light";
	ai = spawn_elemental_margwa( e_spawner, str_spawner_targetname, str_element, s_location );
	return ai;
}

function spawn_electric_margwa( e_spawner, s_location )
{
	if ( !isDefined( e_spawner ) )
	{
		a_zombie_margwa_electricity_spawners = getSpawnerArray( "zombie_margwa_electricity_spawner", "script_noteworthy" );
		if ( a_zombie_margwa_electricity_spawners.size <= 0 )
			return;
		
		e_spawner = a_zombie_margwa_electricity_spawners[ 0 ];
	}
	str_spawner_targetname = MARGWA_ELEMENTAL_ELECTRIC_TARGETNAME;
	str_element = "electric";
	ai = spawn_elemental_margwa( e_spawner, str_spawner_targetname, str_element, s_location );
	return ai;
}

function private margwa_post_spawn()
{
	util::wait_network_frame();
	self clientfield::increment( "margwa_fx_spawn" );
	wait 3;
	self margwa_spawn_complete();
	self.candamage = 1;
	self.needspawn = 1;
}

function private margwa_pre_spawn()
{
	self.isfrozen = 1;
	self.dontShow = 1;
	self ghost();
	self notsolid();
	self pathMode( "dont move" );
}

function private margwa_spawn_complete()
{
	self.isFrozen = 0;
	self show();
	self solid();
	self pathMode( "move allowed" );
}

function private margwa_elemental_death()
{
	self waittill( "death" );
	foreach ( e_player in level.players )
	{
		if ( e_player.am_i_valid )
			scoreevents::processScoreEvent( "kill_margwa", e_player, undefined, undefined );
		
	}
	level notify( "margwa_killed" );
	if ( isDefined( zm_margwa_is_fire( self ) ) && zm_margwa_is_fire( self ) )
		margwa_fire_death( self.origin, 128 );
	
	if ( isDefined( zm_margwa_is_shadow( self ) ) && zm_margwa_is_shadow( self ) )
	{
		self clientfield::set( MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF, 0 );
		margwa_shadow_death( self.origin, 128 );
	}
	if ( isDefined( level.ptr_margwa_elemental_death_cb ) )
		[ [ level.ptr_margwa_elemental_death_cb ] ]();
	
}

function private margwa_fire_death( v_pos, n_range )
{
	a_zombies = zm_elemental_zombie::get_non_elemental_zombies_in_range( v_pos, n_range );
	foreach ( e_zombie in a_zombies )
	{
		e_zombie zm_elemental_zombie::make_napalm_zombie();
	}
}

function private margwa_shadow_death( v_pos, n_range )
{
	a_zombies = zm_elemental_zombie::get_non_elemental_zombies_in_range( v_pos, n_range );
	foreach( e_zombie in a_zombies )
	{
		e_zombie zm_shadow_zombie::make_shadow_zombie();
	}
}

function private margwa_set_element( str_element )
{
	self.str_element = str_element;
}

function zm_margwa_is_fire( e_entity )
{
	if ( isDefined( e_entity ) && isDefined( e_entity.str_element ) && e_entity.str_element == "fire" )
		return 1;
	
	return 0;
}

function zm_margwa_is_electric( e_entity )
{
	if ( isDefined( e_entity ) && isDefined( e_entity.str_element ) && e_entity.str_element == "electric" )
		return 1;
	
	return 0;
}

function zm_margwa_is_light( e_entity )
{
	if ( isDefined( e_entity ) && isDefined( e_entity.str_element ) && e_entity.str_element == "light" )
		return 1;
	
	return 0;
}

function zm_margwa_is_shadow( e_entity )
{
	if ( isDefined( e_entity ) && isDefined( e_entity.str_element ) && e_entity.str_element == "shadow" )
		return 1;
	
	return 0;
}

function private elemental_margwa_spawn_setup()
{
	self.zombie_lift_override = &margwa_lift_override;
	self margwa_fire_attack_setup();
	self margwa_fire_defend_setup();
	self margwa_electric_attack_setup();
	self margwa_electric_shoot_attack_setup();
	self margwa_electric_defend_setup();
	self margwa_light_attack_setup();
	self margwa_light_defend_setup();
	self margwa_shadow_attack_setup();
	self margwa_shadow_defend_setup();
	
	self.margwaPainTerminateCB = &margwa_pain_terminate_cb;
	self thread margwa_enable_stun();
	self.idgun_damage_cb = &margwa_idgun_damage_cb;
	self.n_margwa_next_stun_time = getTime();
	self.n_margwa_next_idgun_react_time = getTime();
	self.heroweapon_kill_power = 5;
}

function private margwa_fire_attack_setup()
{
	self.n_next_fire_attack_time = getTime() + MARGWA_ELEMENTAL_FIRE_ATTACK_SETUP_COOLDOWN;
}

function private margwa_fire_defend_setup()
{
	self.n_next_fire_defend_time = getTime() + MARGWA_ELEMENTAL_FIRE_DEFEND_SETUP_COOLDOWN;
}

function private margwa_electric_attack_setup()
{
	self.n_next_electric_attack_time = getTime() + MARGWA_ELEMENTAL_ELECTRIC_ATTACK_SETUP_COOLDOWN;
}

function private margwa_electric_shoot_attack_setup()
{
	self.n_next_electric_shoot_attack_time = getTime() + MARGWA_ELEMENTAL_ELECTRIC_SHOOT_ATTACK_SETUP_COOLDOWN;
}

function private margwa_electric_defend_setup()
{
	self.n_next_electric_defend_time = getTime() + MARGWA_ELEMENTAL_ELECTRIC_DEFEND_SETUP_COOLDOWN;
}

function private margwa_light_attack_setup()
{
	self.n_next_light_attack_time = getTime() + MARGWA_ELEMENTAL_LIGHT_ATTACK_SETUP_COOLDOWN;
}

function private margwa_light_defend_setup()
{
	self.n_next_light_defend_time = getTime() + MARGWA_ELEMENTAL_LIGHT_DEFEND_SETUP_COOLDOWN;
}

function private margwa_shadow_attack_setup()
{
	self.n_next_shadow_attack_time = getTime() + MARGWA_ELEMENTAL_SHADOW_ATTACK_SETUP_COOLDOWN;
}

function private margwa_shadow_defend_setup()
{
	self.n_next_shadow_defend_time = getTime() + MARGWA_ELEMENTAL_SHADOW_DEFEND_SETUP_COOLDOWN;
}

function private margwa_check_in_arc( v_right_offset )
{
	v_origin = self.origin;
	if ( isDefined( v_right_offset ) )
	{
		v_right_angle = anglesToRight( self.angles );
		v_origin = v_origin + v_right_angle * v_right_offset;
	}
	v_facing_vec = anglesToForward( self.angles );
	v_enemy_vec = self.favoriteenemy.origin - v_origin;
	v_enemy_yaw_vec = ( v_enemy_vec[ 0 ], v_enemy_vec[ 1 ], 0 );
	v_facing_yaw_vec = ( v_facing_vec[ 0 ], v_facing_vec[ 1 ], 0 );
	v_enemy_yaw_vec = vectorNormalize( v_enemy_yaw_vec );
	v_facing_yaw_vec = vectorNormalize( v_facing_yaw_vec );
	n_enemy_dot = vectorDot( v_facing_yaw_vec, v_enemy_yaw_vec );
	if ( n_enemy_dot < .5 )
		return 0;
	
	v_enemy_angles = vectorToAngles( v_enemy_vec );
	if ( abs( angleClamp180( v_enemy_angles[ 0 ] ) ) > MARGWA_ELEMENTAL_CHECK_IN_ARC )
		return 0;
	
	return 1;
}

function private zm_margwa_fire_attack_service( e_entity )
{
	if ( !zm_margwa_is_fire( e_entity ) )
		return 0;
	
	if ( IS_TRUE( e_entity.b_margwa_can_fire_attack ) )
	{
		e_entity.b_margwa_should_fire_attack = 1;
		return 1;
	}
	time = getTime();
	e_entity.b_margwa_should_fire_attack = 0;
	if ( time < e_entity.n_next_fire_attack_time )
		return 0;
	
	if ( IS_TRUE( e_entity.b_margwa_can_fire_defend_in ) )
		return 0;
	
	if ( IS_TRUE( e_entity.b_margwa_fire_attack_active ) )
		return 0;
	
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity margwa_check_in_arc() )
		return 0;
	
	if ( !e_entity canSee( e_entity.favoriteenemy ) )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_FIRE_ATTACK_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_FIRE_ATTACK_MAX_DISTANCE )
		return 0;
	
	e_entity.b_margwa_should_fire_attack = 1;
	return 1;
}

function private zm_margwa_fire_defend_service( e_entity )
{
	if ( !zm_margwa_is_fire( e_entity ) )
		return 0;
	
	if ( e_entity.headAttached > 2 )
		return 0;
	
	if ( isDefined( e_entity.favoriteenemy ) && IS_TRUE( e_entity.favoriteenemy.var_122a2dda ) ) // HARRY
		return 0;
	
	if ( getTime() > e_entity.n_next_fire_defend_time )
	{
		e_entity.b_margwa_can_fire_defend = 1;
		return 1;
	}
	return 0;
}

function private zm_margwa_electric_ground_attack_service( e_entity )
{
	e_entity.b_margwa_can_electric_attack = 0;
	if ( !zm_margwa_is_electric( e_entity ) )
		return 0;
	
	if ( getTime() > e_entity.n_next_electric_attack_time )
	{
		e_entity.b_margwa_can_electric_attack = 1;
		return 1;
	}
	
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity margwa_check_in_arc() )
		return 0;
	
	if ( !e_entity canSee( e_entity.favoriteenemy ) )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_ELECTRIC_ATTACK_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_ELECTRIC_ATTACK_MAX_DISTANCE )
		return 0;
	
	entity.b_margwa_can_electric_attack = 1;
	return 1;
}

function private zm_margwa_electric_shoot_attack_service( e_entity )
{
	if ( !zm_margwa_is_electric( e_entity ) )
		return 0;
	
	e_entity.b_margwa_can_electric_shoot_attack = 0;
	if ( getTime() > e_entity.n_next_electric_shoot_attack_time )
	{
		e_entity.b_margwa_can_electric_shoot_attack = 1;
		return 1;
	}
	
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity margwa_check_in_arc() )
		return 0;
	
	if ( !e_entity canSee( e_entity.favoriteenemy ) )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_ELECTRIC_SHOOT_ATTACK_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_ELECTRIC_SHOOT_ATTACK_MAX_DISTANCE )
		return 0;
	
	e_entity.b_margwa_can_electric_shoot_attack = 1;
	return 1;
}

function private zm_margwa_electric_defend_service( e_entity )
{
	e_entity.b_margwa_can_electric_defend = 0;
	if ( !zm_margwa_is_electric( e_entity ) )
		return 0;
	
	if ( getTime() < e_entity.n_next_electric_defend_time )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_ELECTRIC_DEFEND_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_ELECTRIC_DEFEND_MAX_DISTANCE )
		return 0;
	
	e_entity.b_margwa_can_electric_defend = 1;
	return 1;
}

function private zm_margwa_light_attack_service( e_entity )
{
	e_entity.b_margwa_can_light_attack = 0;
	if ( !zm_margwa_is_light( e_entity ) )
		return 0;
	
	e_entity.b_margwa_can_light_attack = 0;
	
	if ( getTime() > e_entity.n_next_light_attack_time )
	{
		e_entity.b_margwa_can_light_attack = 1;
		return 1;
	}
	
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity canSee( e_entity.favoriteenemy ) )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_LIGHT_ATTACK_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_LIGHT_ATTACK_MAX_DISTANCE )
		return 0;
	
	e_entity.b_margwa_can_light_attack = 1;
	return 1;
}

function private zm_margwa_light_defend_service( e_entity )
{
	if ( !zm_margwa_is_light( e_entity ) )
		return 0;
	
	if ( getTime() > e_entity.n_next_light_defend_time )
	{
		e_entity.b_margwa_can_light_defend = 1;
		return 1;
	}
	return 0;
}

function private zm_margwa_shadow_attack_service( e_entity )
{
	if ( !zm_margwa_is_shadow( e_entity ) )
		return 0;
	
	if ( IS_TRUE( e_entity.b_margwa_can_shadow_attack ) )
	{
		e_entity.b_margwa_should_shadow_attack = 1;
		return 1;
	}
	
	e_entity.b_margwa_should_shadow_attack = 0;
	
	if ( IS_TRUE( e_entity.b_margwa_shadow_over ) )
		return 0;
	
	if ( IS_TRUE( e_entity.isTeleporting ) )
		return 0;
	
	if ( getTime() < e_entity.n_next_shadow_attack_time )
		return 0;
	
	if ( !isDefined( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity canSee( e_entity.favoriteenemy ) )
		return 0;
	
	if ( !e_entity margwa_check_in_arc() )
		return 0;
	
	n_dist_sq = distanceSquared( e_entity.origin, e_entity.favoriteenemy.origin );
	if ( n_dist_sq < MARGWA_ELEMENTAL_SHADOW_ATTACK_MIN_DISTANCE || n_dist_sq > MARGWA_ELEMENTAL_SHADOW_ATTACK_MAX_DISTANCE )
		return 0;
	
	e_entity.b_margwa_should_shadow_attack = 1;
	return 1;
}

function private zm_margwa_shadow_defend_service( e_entity )
{
	if ( !zm_margwa_is_shadow( e_entity ) )
		return 0;
	
	if ( e_entity.headAttached > 2 )
		return 0;
	
	if ( isDefined( e_entity.favoriteenemy ) && IS_TRUE( e_entity.favoriteenemy.var_122a2dda ) )
		return 0;
	
	if ( IS_TRUE( e_entity.b_margwa_shadow_over ) )
		return 0;
	
	if ( getTime() > e_entity.n_next_shadow_defend_time )
	{
		e_entity.b_margwa_can_shadow_defend = 1;
		return 1;
	}
	return 0;
}

function private zm_margwa_should_fire_attack( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_should_fire_attack ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_fire_defend_out( e_entity )
{
	return 0;
}

function private zm_margwa_should_fire_defend_in( e_entity )
{
	return 0;
}

function private zm_margwa_should_electric_ground_attack( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_can_electric_attack ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_electric_shoot_attack( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_can_electric_shoot_attack ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_electric_defend_out( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_can_electric_defend ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_electric_defend_in( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_should_electric_defend_in ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_light_attack( e_entity )
{
	 if ( IS_TRUE( e_entity.b_margwa_can_light_attack ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_light_defend_out( e_entity )
{
	 if ( IS_TRUE( e_entity.b_margwa_can_light_defend ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_light_defend_in( e_entity )
{
	 if ( IS_TRUE( e_entity.b_margwa_should_light_defend_in ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_shadow_attack( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_should_shadow_attack ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_shadow_attack_loop( e_entity )
{
	if ( isDefined( e_entity.n_margwa_end_shadow_attack ) )
	{
		if ( getTime() > e_entity.n_margwa_end_shadow_attack )
			return 0;
		
	}
	return 1;
}

function private zm_margwa_should_shadow_attack_out( e_entity )
{
	if ( IS_TRUE( e_entity.b_margwa_should_shadow_attack_out ) )
		return 1;
	
	return 0;
}

function private zm_margwa_should_shadow_defend_out( e_entity )
{
	return 0;
}

function private zm_margwa_should_shadow_defend_in( e_entity )
{
	return 0;
}

function private zm_margwa_fire_attack( e_entity )
{
	e_entity endon( "death" );
	e_entity.b_margwa_can_fire_attack = 0;
	e_entity thread margwa_fire_attack();
}

function private margwa_fire_attack()
{
	self.b_margwa_fire_attack_active = 1;
	foreach ( e_head in self.head )
	{
		if ( !IS_TRUE( e_head.canDamage ) )
		{
			e_head.var_13ac78ab = 0;
			e_head.canDamage = 1;
			continue;
		}
		e_head.var_13ac78ab = 1;
	}
	self waittill( "start_margwa_fire_attack" );
	foreach ( e_head in self.head )
	{
		if ( !IS_TRUE( e_head.var_13ac78ab ) ) // HARRY
			e_head.canDamage = 0;
		
	}
	if ( isDefined( self.favoriteenemy ) )
	{
		v_angle_to_enemy = self.favoriteenemy.origin - self.origin;
		v_normal_to_enemy = vectorNormalize( v_angle_to_enemy );
		e_target_entity = self.favoriteenemy;
	}
	else
		v_normal_to_enemy = anglesToForward( self.angles );
	
	v_dir = v_normal_to_enemy;
	n_loops = int( MARGWA_ELEMENTAL_FIRE_ATTACK_NUM_LOOPS );
	v_position = self.origin;
	e_fire_projectile = spawn( "script_model", v_position );
	e_fire_projectile SetModel( "tag_origin" );
	level thread margwa_fire_death( v_position, 48 );
	v_torpedo_yaw_per_interval = 13.5;
	n_torpedo_max_yaw_cos = cos( v_torpedo_yaw_per_interval );
	for ( i = 0; i <= n_loops; i++ )
	{
		self margwa_fire_attack_setup();
		v_position = v_position + vectorScale( ( 0, 0, 1 ), 32 );
		if ( isDefined( e_target_entity ) )
		{
			v_torpedo_target_point = e_target_entity.origin;
			v_vector_to_target = v_torpedo_target_point - v_position;
			v_normal_vector = vectorNormalize( v_vector_to_target );
			v_flat_mapped_normal_vector = vectorNormalize( ( v_normal_vector[ 0 ], v_normal_vector[ 1 ], 0 ) );
			v_flat_mapped_old_normal_vector = VectorNormalize( ( v_dir[ 0 ], v_dir[ 1 ], 0 ) );
			n_dot = vectorDot( v_flat_mapped_normal_vector, v_flat_mapped_old_normal_vector );
			
			if ( n_dot >= 1 )
				n_dot = 1;
			else if ( n_dot <= -1 )
				n_dot = -1;
			
			if ( n_dot < n_torpedo_max_yaw_cos )
			{
				v_new_vector = v_normal_vector - v_dir;
				v_angle_between_vectors = aCos( n_dot );
				
				if ( !isDefined( v_angle_between_vectors ) )
					v_angle_between_vectors = 180;
				
				if ( v_angle_between_vectors == 0 )
					v_angle_between_vectors = .0001;
				
				v_max_angle_per_interval = 13.5;
				n_ratio = v_max_angle_per_interval / v_angle_between_vectors;
				if ( n_ratio > 1 )
					n_ratio = 1;
				
				v_new_vector = v_new_vector * n_ratio;
				v_new_vector = v_new_vector + v_dir;
				v_normal_vector = vectorNormalize( v_new_vector );
			}
			else
				v_normal_vector = v_dir;
			
		}
		if ( !isDefined( v_normal_vector ) )
			v_normal_vector = v_dir;
		
		v_offset = v_normal_vector * 48;
		v_dir = v_normal_vector;
		v_target_pos = v_position + v_offset;
		if ( bulletTracePassed( v_position, v_target_pos, 0, self ) )
		{
			a_trace = bulletTrace( v_target_pos, v_target_pos - vectorScale( ( 0, 0, 1 ), 64 ), 0, self );
			if ( !isDefined( a_trace[ "position" ] ) )
				continue;
			
			v_position = a_trace[ "position" ];
			e_fire_projectile moveTo( v_position, .15 );
			e_fire_projectile waittill( "movedone" );
			e_fire_projectile clientfield::increment( MARGWA_ELEMENTAL_PLAY_MARGWA_FIRE_ATTACK_CF );
			e_fire_projectile thread margwa_fire_death( v_position, 48 );
			self thread margwa_do_fire_damage( v_position, 48, 30, "MOD_BURNED" );
			if ( isDefined( e_target_entity ) && distanceSquared( e_target_entity.origin, v_position ) <= MARGWA_ELEMENTAL_FIRE_ATTACK_FAIL_DISTANCE )
				break;
			
			continue;
		}
		break;
	}
	self.b_margwa_fire_attack_active = 0;
}

function private zm_margwa_fire_attack_terminate( e_entity )
{
	e_entity margwa_fire_attack_setup();
}

function private zm_margwa_fire_defend_out( e_entity )
{
	e_entity margwa_fire_defend_setup();
	e_entity.isTeleporting = 1;
	e_entity.b_margwa_can_fire_defend = 0;
	e_entity.b_margwa_can_fire_defend_in = 1;
}

function private zm_margwa_fire_defend_out_terminate( e_entity )
{
	e_entity clientfield::set( MARGWA_ELEMENTAL_DEFENSE_ACTOR_APPEAR_DISAPPEAR_FX_CF, 1 );
	e_entity ghost();
	e_entity pathMode( "dont move" );
	e_entity thread zm_margwa_fire_defend_action();
}

function private zm_margwa_fire_defend_action()
{
	self.waiting = 1;
	v_defend_origin = vectorScale( ( 0, 0, 1 ), 64 );
	self margwa_defend_setup( v_defend_origin, 240, 480 );
	
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 1 );
	
	if ( isDefined(self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 1 );
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 1 );
	
	self forceTeleport( self.v_defend_start_origin );
	wait 1;
	self.waiting = 0;
	self.b_margwa_should_fire_defend_in = 1;
}

function private margwa_check_position_is_in_enabled_zone( v_point )
{
	return zm_utility::check_point_in_playable_area( v_point.origin ) && zm_utility::check_point_in_enabled_zone( v_point.origin );
}

function private zm_margwa_fire_defend_in( e_entity )
{
	e_entity show();
	e_entity pathMode( "move allowed" );
	e_entity.isTeleporting = 0;
	e_entity.b_margwa_should_fire_defend_in = 0;
	
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 clientfield::set(MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	if ( isDefined( self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	wait .05;
	
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 delete();
	
	if ( isDefined( self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 delete();
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 delete();
	
}

function private zm_margwa_fire_defend_in_terminate( e_entity )
{
	e_entity.b_margwa_can_fire_defend_in = 0;
}

function private zm_margwa_electric_ground_attack( e_entity )
{
	e_entity margwa_electric_attack_setup();
}

function private zm_margwa_electric_shoot_attack( e_entity )
{
	e_entity margwa_electric_shoot_attack_setup();
}

function private zm_margwa_electric_defend_out( e_entity )
{
	e_entity margwa_electric_defend_setup();
	e_entity.isTeleporting = 1;
	e_entity.b_margwa_can_electric_defend = 0;
}

function private zm_margwa_electric_defend_out_terminate( e_entity )
{
	if ( isDefined( e_entity.traveler ) )
	{
		e_entity.traveler.origin = e_entity getTagOrigin( "j_spine_1" );
		e_entity.traveler clientfield::set( "margwa_fx_travel", 1 );
	}
	e_entity ghost();
	e_entity pathMode( "dont move" );
	if ( isDefined( e_entity.traveler ) )
		e_entity linkTo( e_entity.traveler );
	
	e_entity thread zm_margwa_electric_defend_action();
}

function private zm_margwa_electric_defend_action()
{
	self.waiting = 1;
	v_goal_pos = self.enemy.origin;
	
	if ( isDefined( self.enemy.last_valid_position ) )
		v_goal_pos = self.enemy.last_valid_position;
	
	a_path = self calcApproximatePathToPosition( v_goal_pos, 0 );
	n_max_segment_length = randomIntRange( 96, 192 );
	n_segment_length = 0;
	a_teleport_points = [];
	n_teleport_point_index = 0;
	for ( index = 1; index < a_path.size; index++ )
	{
		n_new_distance = distance( a_path[ index - 1 ], a_path[ index ] );
		if ( n_segment_length + n_new_distance > n_max_segment_length )
		{
			n_new_segment_length = n_max_segment_length - n_segment_length;
			n_new_origin = a_path[ index - 1 ] + vectorNormalize( a_path[ index ] - a_path[ index - 1 ] ) * n_new_segment_length;
			a_query_result = positionQuery_Source_Navigation( n_new_origin, 64, 128, 36, 16, self, 16 );
			if ( a_query_result.data.size > 0 )
			{
				v_point = a_query_result.data[ randomInt( a_query_result.data.size ) ];
				a_teleport_points[ n_teleport_point_index ] = v_point.origin;
				n_teleport_point_index++;
				if ( n_teleport_point_index == 3 )
					break;
				
			}
		}
	}
	foreach ( v_point in a_teleport_points )
	{
		v_offset = v_point + vectorScale( ( 0, 0, 1 ), 60 );
		n_dist = distance( self.traveler.origin, v_offset );
		n_time = n_dist / 1200;
		if ( n_time < .1 )
			n_time = .1;
		
		if ( isDefined( self.traveler ) )
		{
			self.traveler moveTo( v_offset, n_time );
			self.traveler util::waittill_any_timeout( n_time, "movedone" );
		}
	}
	self.teleportPos = v_point;
	self.waiting = 0;
	self.b_margwa_should_electric_defend_in = 1;
}

function private zm_margwa_electric_defend_in( e_entity )
{
	e_entity unLink();
	if ( isDefined( e_entity.teleportPos ) )
		e_entity forceTeleport( e_entity.teleportPos );
	
	e_entity show();
	e_entity pathMode( "move allowed" );
	e_entity.isTeleporting = 0;
	e_entity.b_margwa_should_electric_defend_in = 0;
	e_entity.traveler clientfield::set( "margwa_fx_travel", 0 );
}

function private zm_margwa_light_attack( e_entity )
{
	e_entity margwa_light_attack_setup();
}

function private zm_margwa_light_defend_out( e_entity )
{
	e_entity margwa_light_defend_setup();
	e_entity.isTeleporting = 1;
	e_entity.b_margwa_can_light_defend = 0;
}

function private zm_margwa_light_defend_out_terminate( e_entity )
{
	e_entity ghost();
	e_entity pathMode( "dont move" );
	e_entity thread zm_margwa_light_defend_action();
}

function private zm_margwa_light_defend_action()
{
	self.waiting = 1;
	a_query_result = positionQuery_Source_Navigation( self.origin, 120, 360, 128, 32, self );
	a_point_list = array::randomize( a_query_result.data );
	self.v_defend_start_origin = a_point_list[ 0 ].origin;
	self forceTeleport( self.v_defend_start_origin );
	wait .5;
	self.waiting = 0;
	self.b_margwa_should_light_defend_in = 1;
}

function private zm_margwa_light_defend_in( e_entity )
{
	e_entity show();
	e_entity pathMode( "move allowed" );
	e_entity.isTeleporting = 0;
	e_entity.b_margwa_should_light_defend_in = 0;
}

function private zm_margwa_shadow_attack( e_entity )
{
	e_entity endon( "death" );
	n_loop_count = 0;
	e_entity.b_margwa_can_shadow_attack = 0;
	e_entity.b_margwa_shadow_over = 1;
	e_entity.n_margwa_end_shadow_attack = undefined;
	v_angles_vec = anglesToForward( e_entity.angles );
	v_target_pos = e_entity.origin + vectorScale( ( 0, 0, 1 ), 72 ) + v_angles_vec * 96;
	v_angles = e_entity.angles;
	e_entity waittill( "shdw_portal_open" );
	e_entity clientfield::set( MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF, 1 );
	wait .5;
	e_target = undefined;
	if ( isDefined( e_entity.favoriteenemy ) )
	{
		v_position = v_target_pos + v_angles_vec * 96;
		e_target = spawn( "script_model", v_position );
		e_target setModel( "tag_origin" );
		e_target.e_target = e_entity.favoriteenemy;
		e_target.owner = e_entity;
		e_target thread margwa_shadow_skull_link();
	}
	while ( n_loop_count < 4 )
	{
		e_entity margwa_shadow_skull_fire( v_target_pos, v_angles, e_target );
		n_loop_count = n_loop_count + 1;
		wait .25;
	}
	e_entity clientfield::set( MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF, 0 );
}

function private zm_margwa_shadow_attack_loop( e_entity )
{
	e_entity.n_margwa_end_shadow_attack = getTime() + MARGWA_ELEMENTAL_SHADOW_ATTACK_LENGTH;
}

function private zm_margwa_shadow_attack_loop_terminate( entity )
{
	entity.b_margwa_should_shadow_attack_out = 1;
}

function private zm_margwa_shadow_attack_out_terminate( entity )
{
	entity.b_margwa_shadow_over = 0;
	entity.b_margwa_should_shadow_attack_out = 0;
	entity.n_next_shadow_attack_time = getTime() + MARGWA_ELEMENTAL_SHADOW_ATTACK_COOLDOWN;
}

function private margwa_shadow_skull_link()
{
	self.owner util::waittill_any( "shadow_margwa_skull_launched", "death" );
	self.owner.a_margwa_shadow_skulls = array::remove_undefined( self.owner.a_margwa_shadow_skulls, 0 );
	margwa = self.owner;
	while ( isDefined( self ) && isDefined( self.e_target ) && isAlive( self.e_target ) && isDefined( self.owner ) && isDefined( self.owner.a_margwa_shadow_skulls ) && self.owner.a_margwa_shadow_skulls.size > 0 )
	{
		v_eye_position = self.e_target getTagOrigin( "tag_eye" );
		self.owner.a_margwa_shadow_skulls = array::remove_undefined( self.owner.a_margwa_shadow_skulls, 0 );
		if ( DistanceSquared( self.origin, v_eye_position ) <= 10000 )
		{
			if ( !IS_TRUE( self.b_margwa_shadow_skull_linked ))
			{
				self.origin = v_eye_position;
				self linkTo( self.e_target, "tag_eye" );
				self.b_margwa_shadow_skull_linked = 1;
			}
		}
		else
		{
			v_angles_to_target = v_eye_position - self.origin;
			v_angles_to_target_norm = vectorNormalize( v_angles_to_target );
			v_add_vector = v_angles_to_target_norm * 50;
			v_target_pos = self.origin + v_add_vector;
			v_offset = v_eye_position[ 2 ] - self.origin[ 2 ];
			a_trace = bulletTrace( v_target_pos + ( 0, 0, v_offset ), v_target_pos - ( 0, 0, v_offset ), 0, self.e_target );
			if ( isDefined( a_trace[ "position" ] ) )
				v_target_pos = a_trace[ "position" ] + ( 0, 0, v_offset );
			
			self moveTo( v_target_pos, .2 );
		}
		wait .2;
	}
	margwa margwa_shadow_attack_setup();
	if ( isDefined( self ) )
	{
		if ( IS_TRUE( self.b_margwa_shadow_skull_linked ) )
			self unLink();
		
		self delete();
	}
}

function private margwa_shadow_skull_fire( v_target_pos, v_angles, e_target )
{
	if ( !isDefined( e_target ) )
		e_target = undefined;
	
	e_entity = self;
	weapon = getWeapon( MARGWA_ELEMENTAL_SHADOW_ATTACK_WEAPON );
	if ( !isDefined( e_entity.a_margwa_shadow_skulls ) )
		e_entity.a_margwa_shadow_skulls = [];
	
	v_vector = anglesToForward( v_angles );
	v_vector = v_vector * 250;
	v_vector = v_vector + vectorScale( ( 0, 0, 1 ), 250 );
	n_x = randomInt( 100 ) - 50;
	n_y = randomInt( 100 ) - 50;
	n_z = randomInt( 50 ) - 25;
	v_velocity = v_vector + ( n_x, n_y, n_z );
	if ( !isDefined( e_target ) )
	{
		e_skull = e_entity magicMissile( weapon, v_target_pos, v_velocity );
		e_skull thread margwa_shadow_skull_damage_explode();
		e_entity.a_margwa_shadow_skulls[ e_entity.a_margwa_shadow_skulls.size ] = e_skull;
		e_entity notify( "shadow_margwa_skull_launched" );
	}
	else
	{
		e_skull = e_entity magicMissile( weapon, v_target_pos, v_velocity, e_target );
		e_skull thread margwa_shadow_skull_damage_explode();
		e_entity.a_margwa_shadow_skulls[ e_entity.a_margwa_shadow_skulls.size ] = e_skull;
		e_entity notify( "shadow_margwa_skull_launched" );
	}
}

function margwa_shadow_skull_damage_explode()
{
	self.takedamage = 1;
	n_current_damage = 0;
	n_max_damage = 100;
	if ( isDefined( level.n_margwa_shadow_max_health ) )
		n_max_damage = level.n_margwa_shadow_max_health;
	
	while ( isDefined( self ) )
	{
		self waittill( "damage", n_damage, e_attacker );
		if ( isPlayer( e_attacker ) )
		{
			n_current_damage = n_current_damage + n_damage;
			if ( n_current_damage >= n_max_damage )
				self detonate();
			
		}
	}
}

function private zm_margwa_shadow_defend_out( e_entity )
{
	e_entity margwa_shadow_defend_setup();
	e_entity.isTeleporting = 1;
	e_entity.b_margwa_can_shadow_defend = 0;
}

function private zm_margwa_shadow_defend_out_terminate( e_entity )
{
	e_entity ghost();
	e_entity PathMode( "dont move" );
	e_entity thread zm_margwa_defend_defend_action();
}

function private zm_margwa_defend_defend_action()
{
	self.waiting = 1;
	v_defend_origin = vectorScale( ( 0, 0, 1 ), 64 );
	self margwa_defend_setup( v_defend_origin, 240, 480 );
	
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 4 );
	
	if ( isDefined( self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 4 );
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 clientfield::set(MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 4);
	
	self forceTeleport( self.v_defend_start_origin );
	wait 1;
	self.waiting = 0;
	self.b_margwa_defending = 1;
}

function private zm_margwa_shadow_defend_in( e_entity )
{
	e_entity show();
	e_entity pathMode( "move allowed" );
	e_entity.isTeleporting = 0;
	e_entity.b_margwa_defending = 0;
	e_entity thread zm_margwa_shadow_defend_in_end();
}

function private zm_margwa_shadow_defend_in_end()
{
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	if ( isDefined( self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 clientfield::set( MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, 0 );
	
	WAIT_SERVER_FRAME;
	
	if ( isDefined( self.e_margwa_defender_1 ) )
		self.e_margwa_defender_1 delete();
	
	if ( isDefined( self.e_margwa_defender_2 ) )
		self.e_margwa_defender_2 delete();
	
	if ( isDefined( self.e_margwa_defender_3 ) )
		self.e_margwa_defender_3 delete();
	
}

function private margwa_do_fire_damage( v_position, n_range, n_damage, str_damage_mod )
{
	e_margwa = self;
	a_players = getPlayers();
	n_range_sq = n_range * n_range;
	foreach ( e_player in a_players )
	{
		if ( e_player laststand::player_is_in_laststand() )
			continue;
		
		n_dist_sq = distanceSquared( v_position, e_player.origin );
		if ( n_dist_sq <= n_range_sq )
			e_player doDamage( n_damage, v_position, e_margwa, undefined, undefined, str_damage_mod );
		
	}
}

function margwa_shadow_actor_damage_callback( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( isDefined( w_weapon ) && w_weapon == getWeapon( MARGWA_ELEMENTAL_SHADOW_ATTACK_WEAPON ) )
	{
		if ( isDefined( e_attacker ) && ( self == e_attacker || self.team == e_attacker.team ) )
		{
			if ( self.archetype === "zombie" && zm_elemental_zombie::is_not_elemental_zombie( self ) )
				self zm_shadow_zombie::make_shadow_zombie();
			
			return 0;
		}
	}
	return -1;
}

function margwa_defend_setup( v_defend_origin, n_min_search_radius, n_max_search_radius )
{
	v_defend_start_origin = self.origin;
	if ( isDefined( self.favoriteenemy ) )
		v_defend_start_origin = self.favoriteenemy.origin;
	
	a_query_result = positionQuery_Source_Navigation( v_defend_start_origin, n_min_search_radius, n_max_search_radius, 256, 96, self );
	a_point_list = array::randomize( a_query_result.data );
	a_point_list = array::filter( a_point_list, 0, &margwa_check_position_is_in_enabled_zone );
	if ( a_point_list.size > 0 )
	{
		self.v_defend_start_origin = a_point_list[ 0 ].origin;
		self.e_margwa_defender_1 = spawn( "script_model", self.v_defend_start_origin + v_defend_origin );
		self.e_margwa_defender_1 setModel( "tag_origin" );
		n_defender_count = 1;
		if ( isDefined( a_point_list[ 1 ] ) )
		{
			self.e_margwa_defender_2 = spawn( "script_model", a_point_list[ 1 ].origin + v_defend_origin );
			self.e_margwa_defender_2 setModel( "tag_origin" );
			n_defender_count = n_defender_count + 1;
			if ( isDefined( a_point_list[ 2 ] ) )
			{
				self.e_margwa_defender_3 = spawn( "script_model", a_point_list[ 2 ].origin + v_defend_origin );
				self.e_margwa_defender_3 setModel( "tag_origin" );
				n_defender_count = n_defender_count + 1;
			}
		}
	}
	else
	{
		self.v_defend_start_origin = self.origin;
		self.e_margwa_defender_1 = spawn( "script_model", self.v_defend_start_origin + v_defend_origin );
		self.e_margwa_defender_1 setModel( "tag_origin" );
		n_defender_count = 1;
	}
	n_defend_point = randomInt( n_defender_count );
	if ( n_defend_point === 1 )
		self.v_defend_start_origin = a_point_list[ 1 ].origin;
	
	if ( n_defend_point === 2 )
		self.v_defend_start_origin = a_point_list[ 2 ].origin;
	
}

function margwa_lift_override( e_player, v_attack_source, n_push_away, n_lift_height, v_lift_offset, n_lift_speed )
{
	self endon( "death" );
	if ( IS_TRUE( self.in_gravity_trap) && e_player.gravityspikes_state === 3 )
	{
		if ( IS_TRUE( self.b_margwa_in_gravity_trap ) )
			return;
		
		self.b_in_gravity_trap = 1;
		self.b_margwa_in_gravity_trap = 1;
		self doDamage( 10, self.origin );
		self.v_margwa_ground_position = self.origin;
		
		str_scene = MARGWA_ELEMENTAL_LIFT_SCENE;
		if ( self.str_element === "fire" )
			str_scene = MARGWA_ELEMENTAL_FIRE_LIFT_SCENE;
		
		if ( self.str_element === "shadow" )
			str_scene = MARGWA_ELEMENTAL_SHADOW_LIFT_SCENE;
		
		self thread scene::play( str_scene, self );
		self clientfield::set( "sparky_beam_fx", 1 );
		self clientfield::set( MARGWA_ELEMENTAL_MARGWA_SHOCK_FX_CF, 1 );
		self playSound( "zmb_talon_electrocute" );
		n_start_time = getTime();
		for ( n_total_time = 0; 10 > n_total_time && e_player.gravityspikes_state === 3; n_total_time = 0 )
			util::wait_network_frame();
		
		self scene::stop( str_scene );
		self thread margwa_in_gravity_trap( self );
		self clientfield::set( "sparky_beam_fx", 0 );
		self clientfield::set( MARGWA_ELEMENTAL_MARGWA_SHOCK_FX_CF, 0 );
		self.b_in_gravity_trap = undefined;
		while ( e_player.gravityspikes_state === 3 )
			util::wait_network_frame();
		
		self.b_margwa_in_gravity_trap = undefined;
		self.in_gravity_trap = undefined;
	}
	else if ( !IS_TRUE( self.reactStun ) )
		self.reactStun = 1;
	
	self.in_gravity_trap = undefined;
}

function margwa_in_gravity_trap( e_margwa )
{
	e_margwa endon( "death" );
	if ( isDefined( e_margwa ) )
	{
		self.v_margwa_ground_position = self.origin;
		
		str_scene = MARGWA_ELEMENTAL_GRAVITY_TRAP_SCENE;
		if ( self.str_element === "fire" )
			str_scene = MARGWA_ELEMENTAL_FIRE_GRAVITY_TRAP_SCENE;
		
		if ( self.str_element === "shadow" )
			str_scene = MARGWA_ELEMENTAL_SHADOW_GRAVITY_TRAP_SCENE;
		
		e_margwa scene::play( str_scene, e_margwa );
	}
	if ( isDefined( e_margwa ) && isAlive( e_margwa ) && isDefined( e_margwa.v_margwa_ground_position ) )
	{
		v_eye_pos = e_margwa getTagOrigin( "tag_eye" );
		
		a_trace = bulletTrace( v_eye_pos, e_margwa.origin, 0, e_margwa );
		if ( a_trace[ "position" ] !== e_margwa.origin )
		{
			v_point = getClosestPointOnNavMesh( a_trace[ "position" ], 64, 30 );
			if ( !isDefined( v_point ) )
				v_point = e_margwa.v_margwa_ground_position;
			
			e_margwa forceTeleport( v_point );
		}
	}
}

function private genesis_margwa_vortex_service( e_entity )
{
	if ( isDefined( e_entity.n_margwa_next_idgun_react_time ) && e_entity.n_margwa_next_idgun_react_time < getTime() )
		return zm_ai_margwa::zm_margwa_vortex_service( e_entity );
	
	return 0;
}

function private genesis_margwa_spider_service( e_entity )
{
	a_zombies = getAITeamArray( level.zombie_team );
	foreach ( e_zombie in a_zombies )
	{
		if ( e_zombie.archetype == "spider" )
		{
			n_dist_sq = distanceSquared( e_entity.origin, e_zombie.origin );
			if ( n_dist_sq < 2304 )
				e_zombie kill();
			
		}
	}
}

function private genesis_margwa_react_stun_terminate( e_entity )
{
	MargwaBehavior::margwaReactStunTerminate( e_entity );
	e_entity.n_margwa_next_stun_time = getTime() + MARGWA_ELEMENTAL_REACT_STUN_COOLDOWN;
}

function private genesis_margwa_react_idgun_terminate( e_entity )
{
	MargwaBehavior::margwaReactIDGunTerminate( e_entity );
	entity.n_margwa_next_idgun_react_time = getTime() + MARGWA_ELEMENTAL_REACT_IDGUN_COOLDOWN;
}

function private margwa_enable_stun()
{
	self endon( "death" );
	wait 1;
	self MargwaServerUtils::margwaEnableStun();
}

function private margwa_pain_terminate_cb()
{
	if ( math::cointoss() )
	{
		if ( zm_ai_margwa_elemental::zm_margwa_is_fire( self ) )
			self.b_margwa_can_fire_attack = 1;
		else if ( zm_ai_margwa_elemental::zm_margwa_is_shadow( self ) )
			self.b_margwa_can_shadow_attack = 1;
		
	}
}

function private margwa_idgun_damage_cb( e_inflictor, e_attacker )
{
	if ( isDefined( self ) )
	{
		foreach ( e_head in self.head )
		{
			if ( e_head.health > 0 )
			{
				n_damage = self.headHealthMax * .5;
				e_head.health = e_head.health - n_damage;
				if ( e_head.health <= 0 )
				{
					e_player = undefined;
					if ( isDefined( self.vortex ) )
						e_player = self.vortex.attacker;
					
					if ( self MargwaServerUtils::margwaKillHead( e_head.model, e_player ) )
						self kill();
					
				}
				return;
			}
		}
	}
}