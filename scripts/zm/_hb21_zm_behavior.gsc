#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_attackables;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\shared\ai\utility.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;

#insert scripts\zm\_zm_behavior.gsh;

#namespace hb21_zm_behavior;

REGISTER_SYSTEM( "hb21_zm_behavior", &__init__, undefined )

function __init__()
{
	// ------- ZOMBIE SOE EXPLOSIVE DEATHS -----------//
	BT_REGISTER_API( "explosivekillinvalid",                 	 	&explosive_kill_invalid );
	
	// ------- ZOMBIE IDGUN -----------//
	BT_REGISTER_API( "waskilledbyidgun", 									&was_killed_by_idgun );
	
	// ------- ZOMBIE GERSH DEVICE -----------//
	BT_REGISTER_ACTION( "hb21zombieblackholebombpullaction", &zombie_black_hole_bomb_pull_start, &zombie_black_hole_bomb_pull_update, &zombie_black_hole_bomb_pull_end );
	BT_REGISTER_API( "waskilledbyblackholebomb", 						&was_killed_by_black_hole_bomb );
	
	// ------- ZOMBIE STAFFS -----------//
	BT_REGISTER_API( "waskilledbywaterstaff", 							&is_staff_water_damage );
	BT_REGISTER_API( "waskilledbylightningstaff", 							&is_staff_lightning_damage );
	BT_REGISTER_API( "wasstunnedbylightningstaff", 					&was_stunned_by_lightning_staff );
	BT_REGISTER_API( "zombiestunlightningactionend", 				&zombie_stun_lightning_action_end );
	BT_REGISTER_API( "zombieshouldwhirlwind", 							&zombie_should_whirlwind );
	BT_REGISTER_API( "wasstunnedbyfirestaff", 							&was_stunned_by_fire_staff );
	BT_REGISTER_API( "zombiestunfireactionend", 						&zombie_stun_fire_action_end );
	BT_REGISTER_API( "waskilledbyfirestaff", 								&is_staff_fire_damage );
	
	// ------- ZOMBIE WAVEGUN -----------//
	BT_REGISTER_API( "moonzombiekilledbymicrowavegun", 		&is_microwavegun_damage );
	BT_REGISTER_API( "moonzombiekilledbymicrowavegundw",		&is_zapgun_damage );
	
	// ------- ZOMBIE INERT -----------//
	BT_REGISTER_API( "zombieshouldinertidle", 							&zombie_should_inert_idle );
	BT_REGISTER_API( "zombieshouldinertwakeup", 						&zombie_should_inert_wakeup );
	BT_REGISTER_API( "zombieshouldinertterminate", 					&zombie_inert_terminate );
	
	// ------- ZOMBIE SLIQUIFIER -----------//
	BT_REGISTER_API( "zombieshouldslip", 									&zombie_should_slip );
	BT_REGISTER_API( "zombieslippedactionstart", 						&zombie_slipped_action_start );
	BT_REGISTER_API( "zombieslippedactionupdate", 				&zombie_slipped_action_update );
	BT_REGISTER_API( "zombieslippedactionterminate", 				&zombie_slipped_action_terminate );

	// ------- ZOMBIE ACID -----------//
	BT_REGISTER_API( "wasstunnedbyacid", 									&was_stunned_by_acid );
	BT_REGISTER_API( "zombiestunacidactionend", 						&zombie_stun_acid_action_end );

	// ------- ZOMBIE NAPALM -----------//
	// BT_REGISTER_API( "napalmcanexplode",                  			&napalm_can_explode );
	// BT_REGISTER_API( "napalmexplodeinitialize",                  	&napalm_explode_initialize );
	// BT_REGISTER_API( "napalmexplodeterminate",                  	&napalm_explode_terminate );

	// ------- ZOMBIE SONIC -----------//
	// BT_REGISTER_API( "soniccanattack",                  				&sonic_can_attack );
	// BT_REGISTER_API( "sonicattackinitialize",                  			&sonic_can_attack_initialize );
	// BT_REGISTER_API( "sonicattackterminate",                  		&sonic_can_attack_terminate );

	
	
	
}

function zombie_black_hole_bomb_pull_start( e_behavior_tree_entity, str_asm_state_name )
{
	if ( isDefined( level.black_hole_bomb_ai_fx ) )
		e_behavior_tree_entity thread [ [ level.black_hole_bomb_ai_fx ] ]( e_behavior_tree_entity, 1 );
	
	e_behavior_tree_entity.pullTime = getTime();
	e_behavior_tree_entity.pullOrigin = e_behavior_tree_entity.origin;
	
	animationStateNetworkUtility::requestState( e_behavior_tree_entity, str_asm_state_name );
	
	zombie_update_black_hole_bomb_pull_state( e_behavior_tree_entity );
	
	if ( isDefined( e_behavior_tree_entity.damageOrigin ) )
	{
		e_behavior_tree_entity.n_zombie_custom_goal_radius = 8;
		e_behavior_tree_entity.v_zombie_custom_goal_pos = e_behavior_tree_entity.damageOrigin;
	}
	
	return BHTN_RUNNING;
}

function zombie_update_black_hole_bomb_pull_state( e_behavior_tree_entity )
{
	n_dist_to_bomb = distanceSquared( e_behavior_tree_entity.origin, e_behavior_tree_entity.damageOrigin );
	
	if ( n_dist_to_bomb < 16384 )
		e_behavior_tree_entity._black_hole_bomb_collapse_death = 1;
	else if ( n_dist_to_bomb < 1048576 )
		blackboard::setBlackBoardAttribute( e_behavior_tree_entity, BLACKHOLEBOMB_PULL_STATE, BLACKHOLEBOMB_PULL_FAST );
	else if ( n_dist_to_bomb < 4227136 )
		blackboard::setBlackBoardAttribute( e_behavior_tree_entity, BLACKHOLEBOMB_PULL_STATE, BLACKHOLEBOMB_PULL_SLOW );
	
}
	
function zombie_black_hole_bomb_pull_update( e_behavior_tree_entity, str_asm_state_name )
{
	if ( !isDefined( e_behavior_tree_entity.interdimensional_gun_kill ) )
		return BHTN_SUCCESS;
	
	zombie_update_black_hole_bomb_pull_state( e_behavior_tree_entity );
	
	if ( IS_TRUE( e_behavior_tree_entity._black_hole_bomb_collapse_death ) )
	{
		e_behavior_tree_entity.skipAutoRagdoll = 1;
		e_behavior_tree_entity doDamage( e_behavior_tree_entity.health + 666, e_behavior_tree_entity.origin + ( 0, 0, 50 ), e_behavior_tree_entity.interdimensional_gun_attacker, undefined, undefined, "MOD_CRUSH", 0, e_behavior_tree_entity.interdimensional_gun_weapon );
		return BHTN_SUCCESS;
	}
	
	if ( isDefined( e_behavior_tree_entity.damageOrigin ) )
		e_behavior_tree_entity.v_zombie_custom_goal_pos = e_behavior_tree_entity.damageOrigin;
	
	// if ( !IS_TRUE( e_behavior_tree_entity.missingLegs ) && ( GetTime() - e_behavior_tree_entity.pullTime > ZM_MOVE_TIME ) )
	if ( getTime() - e_behavior_tree_entity.pullTime > ZM_MOVE_TIME )
	{
		n_dist_sq = distance2DSquared( e_behavior_tree_entity.origin, e_behavior_tree_entity.pullOrigin );
		if ( n_dist_sq < ZM_MOVE_DIST_SQ )
		{
			e_behavior_tree_entity setAvoidanceMask( "avoid all" );
			e_behavior_tree_entity.cant_move = 1;

			if ( isDefined( e_behavior_tree_entity.cant_move_cb ) )
				e_behavior_tree_entity [ [ e_behavior_tree_entity.cant_move_cb ] ]();
			
		}
		else
		{
			e_behavior_tree_entity setAvoidanceMask( "avoid none" );
			e_behavior_tree_entity.cant_move = 0;
		}

		e_behavior_tree_entity.pullTime = getTime();
		e_behavior_tree_entity.pullOrigin = e_behavior_tree_entity.origin;
	}
	
	return BHTN_RUNNING;
}

function zombie_black_hole_bomb_pull_end( e_behavior_tree_entity, str_asm_state_name )
{
	if ( isDefined( level.black_hole_bomb_ai_fx ) )
		e_behavior_tree_entity thread [ [ level.black_hole_bomb_ai_fx ] ]( e_behavior_tree_entity, 0 );
	
	e_behavior_tree_entity.v_zombie_custom_goal_pos = undefined;
	e_behavior_tree_entity.n_zombie_custom_goal_radius = undefined;
	
	e_behavior_tree_entity.pullTime = undefined;
	e_behavior_tree_entity.pullOrigin = undefined;
	
	return BHTN_SUCCESS;
}

function private explosive_kill_invalid( e_behavior_tree_entity )
{
	if ( isDefined( level.ptr_is_explode_death_anim_excluded ) )
		return [ [ level.ptr_is_explode_death_anim_excluded ] ]( e_behavior_tree_entity.damageweapon );
			   
	return 0;    
}

function private was_killed_by_idgun( e_behavior_tree_entity )
{
	if ( !isDefined( e_behavior_tree_entity.killby_interdimensional_gun_hole ) && IS_TRUE( e_behavior_tree_entity.interdimensional_gun_kill ) && isDefined( e_behavior_tree_entity.interdimensional_gun_weapon ) && isWeapon( e_behavior_tree_entity.interdimensional_gun_weapon ) && isInArray( level.idgun_weapons, e_behavior_tree_entity.interdimensional_gun_weapon ) && isAlive( e_behavior_tree_entity ) )
	{
		return 1;
	}
	return 0;
}

function private was_killed_by_black_hole_bomb( e_behavior_tree_entity )
{
	if ( IS_TRUE( e_behavior_tree_entity.interdimensional_gun_kill ) && isDefined( e_behavior_tree_entity.interdimensional_gun_weapon ) && isWeapon( e_behavior_tree_entity.interdimensional_gun_weapon ) && e_behavior_tree_entity.interdimensional_gun_weapon.name == "t7_black_hole_bomb" && isAlive( e_behavior_tree_entity ) )
	{
		return 1;
	}
	return 0;
}

function private is_staff_water_damage( e_behavior_tree_entity )
{
	if ( !isDefined( level.ptr_is_staff_weapon ) || e_behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.ptr_is_staff_weapon ] ]( e_behavior_tree_entity.damageweapon, level.a_staff_water_weaponfiles );
}

function private is_staff_lightning_damage( e_behavior_tree_entity )
{
	if ( !isDefined( level.ptr_is_staff_weapon ) || e_behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.ptr_is_staff_weapon ] ]( e_behavior_tree_entity.damageweapon, level.a_staff_lightning_weaponfiles );
}

function private was_stunned_by_lightning_staff( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_staff_lightning_stunned );
}

function private zombie_stun_lightning_action_end( e_behavior_tree_entity )
{
	if ( isDefined( e_behavior_tree_entity.b_staff_lightning_stunned ) && e_behavior_tree_entity.b_staff_lightning_stunned > 1 )
	{
		e_behavior_tree_entity.b_staff_lightning_stunned--;
		if ( isDefined( level.ptr_staff_lightning_zombie_shockd_fx_cb ) )
			e_behavior_tree_entity [ [ level.ptr_staff_lightning_zombie_shockd_fx_cb ] ]( 1 );
		
		return BHTN_RUNNING;
	}
	e_behavior_tree_entity.b_staff_lightning_stunned = undefined;
	if ( isAlive( e_behavior_tree_entity ) && isDefined( level.ptr_staff_lightning_zombie_shockd_fx_cb ) )
		e_behavior_tree_entity [ [ level.ptr_staff_lightning_zombie_shockd_fx_cb ] ]( 0 );
	
	return BHTN_SUCCESS;
}

function private zombie_should_whirlwind( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_staff_air_whirlwind_attract );
}

function private was_stunned_by_fire_staff( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_staff_fire_stunned );
}

function private zombie_stun_fire_action_end( e_behavior_tree_entity )
{
	e_behavior_tree_entity.b_staff_fire_stunned = undefined;
	return BHTN_SUCCESS;
}

function private is_staff_fire_damage( e_behavior_tree_entity )
{
	if ( !isDefined( level.ptr_is_staff_weapon ) || e_behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.ptr_is_staff_weapon ] ]( e_behavior_tree_entity.damageweapon, level.a_staff_fire_weaponfiles );
}

function private is_microwavegun_damage( e_behavior_tree_entity )
{
	if ( isDefined( level.ptr_is_wavegun_weapon ) )
		return [ [ level.ptr_is_wavegun_weapon ] ]( e_behavior_tree_entity.damageweapon );
	
	return 0;
}

function private is_zapgun_damage( e_behavior_tree_entity )
{
	if ( isDefined( level.ptr_is_zapgun_weapon ) )
		return [ [ level.ptr_is_zapgun_weapon ] ]( e_behavior_tree_entity.damageweapon );
	
	return 0;
}

function private zombie_should_inert_idle( e_behavior_tree_entity )
{
	return ( IS_TRUE( e_behavior_tree_entity.emp_inert ) );
}

function private zombie_should_inert_wakeup( e_behavior_tree_entity )
{
	return ( IS_TRUE( e_behavior_tree_entity.wake_up ) );
}

function private zombie_inert_terminate( e_behavior_tree_entity )
{
	e_behavior_tree_entity.wake_up = undefined;
	e_behavior_tree_entity.v_zombie_custom_goal_pos = undefined;
}

function zombie_should_slip( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_sliding_on_goo );
}

function private zombie_slipped_action_start( e_behavior_tree_entity, str_asm_state_name )
{
	animationStateNetworkUtility::requestState( e_behavior_tree_entity, str_asm_state_name );
	
	if ( !isDefined( e_behavior_tree_entity.slip_move_anim_end_time ) )
	{
		slip_action_result = e_behavior_tree_entity ASTSearch(  iString( str_asm_state_name ) );
		slip_action_animation = animationStateNetworkUtility::searchAnimationMap( e_behavior_tree_entity, slip_action_result[ ASM_ALIAS_ATTRIBUTE ] );
		
		e_behavior_tree_entity.slip_move_anim_end_time = getTime() + getAnimLength( slip_action_animation );
	}
	
	e_behavior_tree_entity.oldblockingPain = ( isDefined( e_behavior_tree_entity.blockingPain ) ? e_behavior_tree_entity.blockingPain : 0 );
	e_behavior_tree_entity.blockingPain = 1;
	return BHTN_RUNNING;
}

function zombie_slipped_action_update( e_behavior_tree_entity )
{
	if ( isDefined( e_behavior_tree_entity.slip_move_anim_end_time ) && ( getTime() >= e_behavior_tree_entity.slip_move_anim_end_time ) )
	{
		e_behavior_tree_entity.slip_move_anim_end_time = undefined;
		return BHTN_SUCCESS;
	}
	return BHTN_RUNNING;
}

function private zombie_slipped_action_terminate( e_behavior_tree_entity )
{
	e_behavior_tree_entity.b_sliding_on_goo = undefined;
	e_behavior_tree_entity.blockingPain = ( isDefined( e_behavior_tree_entity.oldblockingPain ) ? e_behavior_tree_entity.oldblockingPain : 0 );
	e_behavior_tree_entity.oldblockingPain = undefined;
	return BHTN_SUCCESS;	
}

function private was_stunned_by_acid( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_acid_stunned );
}

function private zombie_stun_acid_action_end( e_behavior_tree_entity )
{
	e_behavior_tree_entity.b_acid_stunned = undefined;
	return BHTN_SUCCESS;
}

function private napalm_can_explode( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_napalm_explode );
}

function private napalm_explode_initialize( e_behavior_tree_entity )
{
	return BHTN_RUNNING;
}

function private napalm_explode_terminate( e_behavior_tree_entity )
{
	return BHTN_SUCCESS;
}

function private sonic_can_attack( e_behavior_tree_entity )
{
	return IS_TRUE( e_behavior_tree_entity.b_sonic_attack );
}

function private sonic_can_attack_initialize( e_behavior_tree_entity )
{
	return BHTN_RUNNING;
}

function private sonic_can_attack_terminate( e_behavior_tree_entity )
{
	return BHTN_SUCCESS;
}
