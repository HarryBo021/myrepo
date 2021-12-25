#using scripts\shared\ai\archetype_cover_utility;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\ai_blackboard;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\ai_squads;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\destructible_character;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\systems\shared;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\gameskill_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\archetype_zod_companion_interface;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;


#namespace archetype_zod_companion;

function autoexec main()
{
	clientfield::register( "allplayers", "being_robot_revived", 1, 1, "int" );
	spawner::add_archetype_spawn_function( "zod_companion", &zodcompanionbehavior::archetypezodcompanionblackboardinit );
	spawner::add_archetype_spawn_function( "zod_companion", &zodcompanionserverutils::zodcompanionsoldierspawnsetup );
	zodcompanioninterface::registerzodcompanioninterfaceattributes();
	zodcompanionbehavior::RegisterBehaviorScriptFunctions();
}

#namespace zodcompanionbehavior;

/*
	Name: RegisterBehaviorScriptFunctions
	Namespace: zodcompanionbehavior
	Checksum: 0x436CEF15
	Offset: 0xAB8
	Size: 0x2AB
	Parameters: 0
	Flags: None
*/
function RegisterBehaviorScriptFunctions()
{
	BT_REGISTER_API( "zodCompanionTacticalWalkActionStart", &zodcompaniontacticalwalkactionstart );
	BT_REGISTER_API( "zodCompanionAbleToShoot", &zodcompanionabletoshoot );
	BT_REGISTER_API( "zodCompanionShouldTacticalWalk", &zodcompanionshouldtacticalwalk );
	BT_REGISTER_API( "zodCompanionMovement", &zodcompanionmovement );
	BT_REGISTER_API( "zodCompanionDelayMovement", &zodcompaniondelaymovement );
	BT_REGISTER_API( "zodCompanionSetDesiredStanceToStand", &zodcompanionsetdesiredstancetostand );
	BT_REGISTER_API( "zodCompanionFinishedSprintTransition", &zodcompanionfinishedsprinttransition );
	BT_REGISTER_API( "zodCompanionSprintTransitioning", &zodcompanionsprinttransitioning );
	BT_REGISTER_API( "zodCompanionKeepsCurrentMovementMode", &zodcompanionkeepscurrentmovementmode );
	BT_REGISTER_API( "zodCompanionCanJuke", &zodcompanioncanjuke );
	BT_REGISTER_API( "zodCompanionCanPreemptiveJuke", &zodcompanioncanpreemptivejuke );
	BT_REGISTER_API( "zodCompanionJukeInitialize", &zodcompanionjukeinitialize );
	BT_REGISTER_API( "zodCompanionPreemptiveJukeTerminate", &zodcompanionpreemptivejuketerminate );
	BT_REGISTER_API( "zodCompanionTargetService", &zodcompaniontargetservice );
	BT_REGISTER_API( "zodCompanionTryReacquireService", &zodcompaniontryreacquireservice );
	BT_REGISTER_API( "manage_companion_movement", &manage_companion_movement );
	BT_REGISTER_API( "zodCompanionCollisionService", &zodcompanioncollisionservice );
}

/*
	Name: mocompIgnorePainFaceEnemyInit
	Namespace: zodcompanionbehavior
	Checksum: 0x555DE963
	Offset: 0xD70
	Size: 0x7B
	Parameters: 5
	Flags: Private
*/
function private mocompIgnorePainFaceEnemyInit( entity, mocompAnim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration )
{
	entity.blockingPain = 1;
	entity OrientMode( "face enemy" );
	entity animMode( "pos deltas" );
}

/*
	Name: mocompIgnorePainFaceEnemyTerminate
	Namespace: zodcompanionbehavior
	Checksum: 0x483B0F5B
	Offset: 0xDF8
	Size: 0x3B
	Parameters: 5
	Flags: Private
*/
function private mocompIgnorePainFaceEnemyTerminate( entity, mocompAnim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration )
{
	entity.blockingPain = 0;
}

/*
	Name: archetypezodcompanionblackboardinit
	Namespace: zodcompanionbehavior
	Checksum: 0x2BECAACE
	Offset: 0xE40
	Size: 0x1A3
	Parameters: 0
	Flags: Private
*/
function private archetypezodcompanionblackboardinit()
{
	entity = self;
	entity.pushable = 1;
	blackboard::CreateBlackBoardForEntity( entity );
	ai::CreateInterfaceForEntity( entity );
	entity AiUtility::RegisterUtilityBlackboardAttributes();
	blackboard::RegisterBlackBoardAttribute( self, "_locomotion_speed", "locomotion_speed_sprint", undefined );
	blackboard::RegisterBlackBoardAttribute( self, "_move_mode", "normal", undefined );
	blackboard::RegisterBlackBoardAttribute( self, "_gibbed_limbs", undefined, &archetypezodcompaniongib );
}

/*
	Name: archetypezodcompaniongib
	Namespace: zodcompanionbehavior
	Checksum: 0x592AF342
	Offset: 0xFF0
	Size: 0xA5
	Parameters: 0
	Flags: Private
*/
function private archetypezodcompaniongib()
{
	entity = self;
	rightArmGibbed = GibServerUtils::IsGibbed( entity, 16 );
	leftArmGibbed = GibServerUtils::IsGibbed( entity, 32 );
	if ( rightArmGibbed && leftArmGibbed )
		return "both_arms";
	else if ( rightArmGibbed )
		return "right_arm";
	else if ( leftArmGibbed )
		return "left_arm";
	
	return "none";
}

/*
	Name: zodcompaniondelaymovement
	Namespace: zodcompanionbehavior
	Checksum: 0x81C474F3
	Offset: 0x10A0
	Size: 0x43
	Parameters: 1
	Flags: Private
*/
function private zodcompaniondelaymovement( entity )
{
	entity PathMode( "move delayed", 0, RandomFloatRange( 1, 2 ) );
}

/*
	Name: zodcompanionmovement
	Namespace: zodcompanionbehavior
	Checksum: 0x97FFAD11
	Offset: 0x10F0
	Size: 0x5B
	Parameters: 1
	Flags: Private
*/
function private zodcompanionmovement( entity )
{
	if ( blackboard::GetBlackBoardAttribute( entity, "_stance" ) != "stand" )
		blackboard::SetBlackBoardAttribute( entity, "_desired_stance", "stand" );
	
}

/*
	Name: zodcompanioncanjuke
	Namespace: zodcompanionbehavior
	Checksum: 0x4D3CA24A
	Offset: 0x1158
	Size: 0x155
	Parameters: 1
	Flags: None
*/
function zodcompanioncanjuke( entity )
{
	if ( !IS_TRUE( entity.steppedOutOfCover) && AiUtility::canJuke( entity ) )
	{
		jukeEvents = blackboard::GetBlackboardEvents( "robot_juke" );
		tooCloseJukeDistanceSqr = 57600;
		foreach ( event in jukeEvents )
		{
			if ( event.data.entity != entity && Distance2DSquared( entity.origin, event.data.origin ) <= tooCloseJukeDistanceSqr )
				return 0;
			
		}
		return 1;
	}
	return 0;
}

/*
	Name: zodcompanioncanpreemptivejuke
	Namespace: zodcompanionbehavior
	Checksum: 0x18865039
	Offset: 0x12B8
	Size: 0x31D
	Parameters: 1
	Flags: None
*/
function zodcompanioncanpreemptivejuke( entity )
{
	if ( !isdefined( entity.enemy ) || !isPlayer( entity.enemy ) )
		return 0;
	
	if ( blackboard::GetBlackBoardAttribute( entity, "_stance" ) == "crouch" )
		return 0;
	
	if ( !entity.shouldPreemptiveJuke )
		return 0;
	
	if ( isdefined( entity.nextPreemptiveJuke ) && entity.nextPreemptiveJuke > GetTime() )
		return 0;
	
	if ( entity.enemy PlayerAds() < entity.nextPreemptiveJukeAds )
		return 0;
	
	if ( DistanceSquared( entity.origin, entity.enemy.origin ) < 360000 )
	{
		angleDifference = AbsAngleClamp180( entity.angles[ 1 ] - entity.enemy.angles[ 1 ] );
		/#
			Record3DText( angleDifference, entity.origin + VectorScale( ( 0, 0, 1 ), 5 ), ( 0, 1, 0 ), "Dev Block strings are not supported" );
		#/
		if ( angleDifference > 135 )
		{
			enemyAngles = entity.enemy GetGunAngles();
			toEnemy = entity.enemy.origin - entity.origin;
			forward = AnglesToForward( enemyAngles );
			dotProduct = Abs( VectorDot( VectorNormalize( toEnemy ), forward ) );
			/#
				Record3DText( ACos( dotProduct ), entity.origin + VectorScale( ( 0, 0, 1 ), 10 ), ( 0, 1, 0 ), "Dev Block strings are not supported" );
			#/
			if ( dotProduct > 0.9848 )
			{
				return zodcompanioncanjuke( entity );
			}
		}
	}
	return 0;
}

/*
	Name: _IsValidPlayer
	Namespace: zodcompanionbehavior
	Checksum: 0xE9BBCB3D
	Offset: 0x15E0
	Size: 0xAD
	Parameters: 1
	Flags: Private
*/
function private _IsValidPlayer( player )
{
	if ( !isdefined( player ) || !isalive( player ) || !isPlayer( player ) || player.sessionstate == "spectator" || player.sessionstate == "intermission" || player laststand::player_is_in_laststand() || player.ignoreme )
		return 0;
	
	return 1;
}

/*
	Name: _FindClosest
	Namespace: zodcompanionbehavior
	Checksum: 0x84D9CF2A
	Offset: 0x1698
	Size: 0x141
	Parameters: 2
	Flags: Private
*/
function private _FindClosest( entity, entities )
{
	closest = spawnstruct();
	if ( entities.size > 0 )
	{
		closest.entity = entities[ 0 ];
		closest.DistanceSquared = DistanceSquared( entity.origin, closest.entity.origin );
		for ( index = 1; index < entities.size; index++ )
		{
			DistanceSquared = DistanceSquared( entity.origin, entities[ index ].origin );
			if ( DistanceSquared < closest.DistanceSquared )
			{
				closest.DistanceSquared = DistanceSquared;
				closest.entity = entities[ index ];
			}
		}
	}
	return closest;
}

/*
	Name: zodcompaniontargetservice
	Namespace: zodcompanionbehavior
	Checksum: 0x12B9842D
	Offset: 0x17E8
	Size: 0x433
	Parameters: 1
	Flags: Private
*/
function private zodcompaniontargetservice( entity )
{
	if ( zodcompanionabletoshoot( entity ) )
		return 0;
	
	if ( IS_TRUE( entity.ignoreall ) )
		return 0;
	
	aiEnemies = [];
	playerEnemies = [];
	ai = GetAIArray();
	players = GetPlayers();
	positionOnNavMesh = GetClosestPointOnNavMesh( entity.origin, 200 );
	if ( !isdefined( positionOnNavMesh ) )
		return;
	
	foreach ( value in ai )
	{
		if ( value.team != entity.team && IsActor( value ) && !isdefined( entity.favoriteenemy ) )
		{
			enemyPositionOnNavMesh = GetClosestPointOnNavMesh( value.origin, 200 );
			if ( isdefined( enemyPositionOnNavMesh ) && entity FindPath( positionOnNavMesh, enemyPositionOnNavMesh, 1, 0 ) )
				aiEnemies[ aiEnemies.size ] = value;
			
		}
	}
	foreach ( value in players )
	{
		if ( _IsValidPlayer( value ) )
		{
			enemyPositionOnNavMesh = GetClosestPointOnNavMesh( value.origin, 200 );
			if ( isdefined( enemyPositionOnNavMesh ) && entity FindPath( positionOnNavMesh, enemyPositionOnNavMesh, 1, 0 ) )
				playerEnemies[ playerEnemies.size ] = value;
			
		}
	}
	closestPlayer = _FindClosest( entity, playerEnemies );
	closestAI = _FindClosest( entity, aiEnemies );
	if ( !isdefined( closestPlayer.entity ) && !isdefined( closestAI.entity ) )
		return;
	else if ( !isdefined( closestAI.entity ) )
		entity.favoriteenemy = closestPlayer.entity;
	else if ( !isdefined( closestPlayer.entity ) )
		entity.favoriteenemy = closestAI.entity;
	else if ( closestAI.DistanceSquared < closestPlayer.DistanceSquared )
		entity.favoriteenemy = closestAI.entity;
	else
		entity.favoriteenemy = closestPlayer.entity;
	
}

/*
	Name: zodcompaniontacticalwalkactionstart
	Namespace: zodcompanionbehavior
	Checksum: 0xFD51892B
	Offset: 0x1C28
	Size: 0x2B
	Parameters: 1
	Flags: Private
*/
function private zodcompaniontacticalwalkactionstart( entity )
{
	entity OrientMode( "face enemy" );
}

/*
	Name: zodcompanionabletoshoot
	Namespace: zodcompanionbehavior
	Checksum: 0xEBFC955B
	Offset: 0x1C60
	Size: 0x53
	Parameters: 1
	Flags: Private
*/
function private zodcompanionabletoshoot( entity )
{
	return entity.weapon.name != level.weaponNone.name && !GibServerUtils::IsGibbed( entity, 16 );
}

/*
	Name: zodcompanionshouldtacticalwalk
	Namespace: zodcompanionbehavior
	Checksum: 0xE4B8C005
	Offset: 0x1CC0
	Size: 0x2D
	Parameters: 1
	Flags: Private
*/
function private zodcompanionshouldtacticalwalk( entity )
{
	if ( !entity HasPath() )
		return 0;
	
	return 1;
}

/*
	Name: zodcompanionjukeinitialize
	Namespace: zodcompanionbehavior
	Checksum: 0xFC2FB338
	Offset: 0x1CF8
	Size: 0xAB
	Parameters: 1
	Flags: Private
*/
function private zodcompanionjukeinitialize( entity )
{
	AiUtility::chooseJukeDirection( entity );
	entity clearPath();
	jukeInfo = spawnstruct();
	jukeInfo.origin = entity.origin;
	jukeInfo.entity = entity;
	blackboard::AddBlackboardEvent( "robot_juke", jukeInfo, 2000 );
}

/*
	Name: zodcompanionpreemptivejuketerminate
	Namespace: zodcompanionbehavior
	Checksum: 0xCE04FBD1
	Offset: 0x1DB0
	Size: 0x67
	Parameters: 1
	Flags: Private
*/
function private zodcompanionpreemptivejuketerminate( entity )
{
	entity.nextPreemptiveJuke = GetTime() + randomIntRange( 4000, 6000 );
	entity.nextPreemptiveJukeAds = RandomFloatRange( 0.5, 0.95 );
}

/*
	Name: zodcompaniontryreacquireservice
	Namespace: zodcompanionbehavior
	Checksum: 0x913AD5F5
	Offset: 0x1E20
	Size: 0x2F1
	Parameters: 1
	Flags: Private
*/
function private zodcompaniontryreacquireservice( entity )
{
	if ( !isdefined( entity.reacquire_state ) )
		entity.reacquire_state = 0;
	
	if ( !isdefined( entity.enemy ) )
	{
		entity.reacquire_state = 0;
		return 0;
	}
	if ( entity HasPath() )
		return 0;
	
	if ( !zodcompanionabletoshoot( entity ) )
		return 0;
	
	if ( entity cansee( entity.enemy ) && entity CanShootEnemy() )
	{
		entity.reacquire_state = 0;
		return 0;
	}
	dirToEnemy = VectorNormalize( entity.enemy.origin - entity.origin );
	forward = AnglesToForward( entity.angles );
	if ( VectorDot( dirToEnemy, forward) < 0.5 )
	{
		entity.reacquire_state = 0;
		return 0;
	}
	switch ( entity.reacquire_state )
	{
		case 0:
		case 1:
		case 2:
		{
			step_size = 32 + entity.reacquire_state * 32;
			reacquirePos = entity ReacquireStep( step_size );
			break;
		}
		case 4:
		{
			if ( !entity cansee( entity.enemy ) || !entity CanShootEnemy() )
				entity FlagEnemyUnattackable();
			
			break;
		}
		default:
		{
			if ( entity.reacquire_state > 15 )
			{
				entity.reacquire_state = 0;
				return 0;
			}
			break;
		}
	}
	if ( IsVec( reacquirePos ) )
	{
		entity UsePosition( reacquirePos );
		return 1;
	}
	entity.reacquire_state++;
	return 0;
}

/*
	Name: manage_companion_movement
	Namespace: zodcompanionbehavior
	Checksum: 0x34C7F7BF
	Offset: 0x2120
	Size: 0x7A3
	Parameters: 1
	Flags: Private
*/
function private manage_companion_movement( entity )
{
	self endon( "death" );
	if ( IS_TRUE( level.b_robot_leader ) )
		self.leader = level.b_robot_leader;
	
	if ( !isdefined( entity.n_revive_cooldown ) )
		entity.n_revive_cooldown = 0;
	
	if ( entity.bulletsInClip < entity.weapon.clipSize )
		entity.bulletsInClip = entity.weapon.clipSize;
	
	if ( entity.b_robot_reviving === 1 )
		return;
	
	if ( entity.b_robot_finished === 1 )
		return;
	
	if ( entity.b_chasing_teleporting_player === 1 || entity.teleporting === 1 )
		return;
	
	if ( entity.leader.teleporting === 1 )
	{
		entity thread zodrobotchaseteleportingplayer( entity.leader.teleport_location );
		return;
	}
	if ( entity.var_c0e8df41 === 1 )
		return;
	
	if ( entity.leader.var_122a2dda === 1 )
		entity thread function_3463b8c2( entity.leader.var_fa1ecd39 );
	
	foreach ( player in level.players )
	{
		if ( player laststand::player_is_in_laststand() && entity.b_robot_reviving === 0 && player.reviveTrigger.beingRevived !== 1 )
		{
			time = GetTime();
			if ( DistanceSquared( entity.origin, player.origin ) <= 1024 * 1024 && time >= entity.n_revive_cooldown )
			{
				entity.b_robot_reviving = 1;
				entity function_944023af( player );
				return;
			}
		}
	}
	if ( !isdefined( entity.var_a0c5deb2 ) )
		entity.var_a0c5deb2 = GetTime();
	
	if ( GetTime() >= entity.var_a0c5deb2 && isdefined(level.active_powerups) && level.active_powerups.size > 0 )
	{
		if ( !isdefined( entity.var_34a9f1ad ) )
			entity.var_34a9f1ad = 0;
		
		foreach ( powerup in level.active_powerups )
		{
			if ( IsInArray( entity.var_fb400bf7, powerup.powerup_name ) )
			{
				dist = DistanceSquared( entity.origin, powerup.origin );
				if ( dist <= 147456 && RandomInt( 100 ) < 50 + 10 * entity.var_34a9f1ad )
				{
					entity SetGoal( powerup.origin, 1 );
					entity.var_a0c5deb2 = GetTime() + randomIntRange( 2500, 3500 );
					entity.var_9f6855ba = GetTime() + randomIntRange( 2500, 3500 );
					entity.var_34a9f1ad = 0;
					return;
				}
				entity.var_34a9f1ad = entity.var_34a9f1ad + 1;
			}
		}
		entity.var_a0c5deb2 = GetTime() + randomIntRange( 333, 666 );
	}
	var_cadf2501 = 256 * 256;
	if ( isdefined( entity.leader ) )
		entity.v_robot_land_position = entity.leader.origin;
	
	if ( isdefined( entity.pathGoalPos ) )
		var_fa42b6b2 = entity.pathGoalPos;
	else
		var_fa42b6b2 = entity.origin;
	
	if ( isdefined( entity.enemy ) && entity.enemy.archetype == "parasite" )
	{
		var_ad7631ce = Abs(entity.origin[ 2 ] - entity.enemy.origin[ 2 ] );
		var_3b804002 = 1.5 * var_ad7631ce * 1.5 * var_ad7631ce;
		if ( DistanceSquared( var_fa42b6b2, entity.enemy.origin ) < var_3b804002 )
			entity function_d03a1b48();
		
	}
	if ( DistanceSquared( var_fa42b6b2, entity.v_robot_land_position ) > var_cadf2501 || DistanceSquared( var_fa42b6b2, entity.v_robot_land_position) < 4096 )
		entity function_d03a1b48();
	
	if ( GetTime() >= entity.var_9f6855ba )
		entity function_d03a1b48();
	
}

/*
	Name: zodcompanioncollisionservice
	Namespace: zodcompanionbehavior
	Checksum: 0xF33E182
	Offset: 0x28D0
	Size: 0x1D5
	Parameters: 1
	Flags: Private
*/
function private zodcompanioncollisionservice( entity )
{
	if ( isdefined( entity.dontPushTime ) )
	{
		if ( GetTime() < entity.dontPushTime )
			return 1;
		
	}
	var_5558b624 = 0;
	zombies = GetAITeamArray( level.zombie_team );
	foreach ( zombie in zombies )
	{
		if ( zombie == entity )
			continue;
		
		dist_sq = DistanceSquared( entity.origin, zombie.origin );
		if ( dist_sq < 14400 )
		{
			if ( IS_TRUE( zombie.cant_move ) )
			{
				zombie thread function_d04291cf();
				var_5558b624 = 1;
			}
		}
	}
	if ( var_5558b624 )
	{
		entity PushActors( 0 );
		entity.dontPushTime = GetTime() + 2000;
		return 1;
	}
	entity PushActors( 1 );
	return 0;
}

/*
	Name: function_d04291cf
	Namespace: zodcompanionbehavior
	Checksum: 0xF5317EE6
	Offset: 0x2AB0
	Size: 0x43
	Parameters: 0
	Flags: Private
*/
function private function_d04291cf()
{
	self endon( "death" );
	self PushActors( 0 );
	wait 2;
	self PushActors( 1 );
}

/*
	Name: function_f62bd05c
	Namespace: zodcompanionbehavior
	Checksum: 0x80851C4
	Offset: 0x2B00
	Size: 0x13D
	Parameters: 2
	Flags: Private
*/
function private function_f62bd05c( target_entity, max_distance )
{
	entity = self;
	var_c96da0a0 = target_entity.origin;
	if ( DistanceSquared( entity.origin, var_c96da0a0 ) > max_distance * max_distance )
		return 0;
	
	path = entity CalcApproximatePathToPosition( var_c96da0a0 );
	segmentLength = 0;
	for ( index = 1; index < path.size; index++ )
	{
		currentSegLength = Distance( path[ index - 1 ], path[ index ] );
		if ( currentSegLength + segmentLength > max_distance )
			return 0;
		
		segmentLength = segmentLength + currentSegLength;
	}
	return 1;
}

function private zodrobotchaseteleportingplayer( v_teleport_location )
{
	self.b_chasing_teleporting_player = 1;
	self SetGoal( v_teleport_location, 1 );
	self waittill( "goal" );
	wait 1;
	self.b_chasing_teleporting_player = 0;
}

/*
	Name: function_3463b8c2
	Namespace: zodcompanionbehavior
	Checksum: 0x9B0A229
	Offset: 0x2CA0
	Size: 0xAF
	Parameters: 1
	Flags: Private
*/
function private function_3463b8c2( var_ee6ad78e )
{
	self.var_c0e8df41 = 1;
	var_c9277d64 = GetNodeArray( "flinger_traversal", "script_noteworthy" );
	var_292fba5b = ArrayGetClosest( var_ee6ad78e, var_c9277d64 );
	self SetGoal( var_292fba5b.origin, 1 );
	self waittill( "goal" );
	wait 1;
	self.var_c0e8df41 = 0;
}

/*
	Name: function_d03a1b48
	Namespace: zodcompanionbehavior
	Checksum: 0x55FF1AE9
	Offset: 0x2D58
	Size: 0x1CB
	Parameters: 0
	Flags: Private
*/
function private function_d03a1b48()
{
	queryResult = PositionQuery_Source_Navigation( self.v_robot_land_position, 96, 256, 256, 20, self );
	if ( queryResult.data.size )
	{
		if ( isdefined( self.enemy ) && self.enemy.archetype == "parasite" )
			Array::filter( queryResult.data, 0, &function_ab299a53, self.enemy );
		
	}
	if ( queryResult.data.size )
	{
		point = queryResult.data[ RandomInt( queryResult.data.size ) ];
		pathSuccess = self FindPath( self.origin, point.origin, 1, 0 );
		if ( pathSuccess )
			self.var_cd632390 = point.origin;
		else
		{
			self.var_9f6855ba = GetTime() + randomIntRange( 500, 1500 );
			return;
		}
	}
	self SetGoal( self.var_cd632390, 1 );
	self.var_9f6855ba = GetTime() + randomIntRange( 20000, 30000 );
}

/*
	Name: function_ab299a53
	Namespace: zodcompanionbehavior
	Checksum: 0x9511E5C1
	Offset: 0x2F30
	Size: 0xB7
	Parameters: 1
	Flags: Private
*/
function private function_ab299a53( parasite )
{
	point = self;
	var_ad7631ce = Abs( point.origin[ 2 ] - parasite.origin[ 2 ] );
	var_3b804002 = 1.5 * var_ad7631ce * 1.5 * var_ad7631ce;
	return DistanceSquared( point.origin, parasite.origin ) > var_3b804002;
}

/*
	Name: zodcompanionsetdesiredstancetostand
	Namespace: zodcompanionbehavior
	Checksum: 0xAF0D314
	Offset: 0x2FF0
	Size: 0x6B
	Parameters: 1
	Flags: Private
*/
function private zodcompanionsetdesiredstancetostand( behaviorTreeEntity )
{
	currentStance = blackboard::GetBlackBoardAttribute( behaviorTreeEntity, "_stance" );
	if ( currentStance == "crouch" )
		blackboard::SetBlackBoardAttribute( behaviorTreeEntity, "_desired_stance", "stand" );
	
}

/*
	Name: function_944023af
	Namespace: zodcompanionbehavior
	Checksum: 0x22D4E3C4
	Offset: 0x3068
	Size: 0x3E3
	Parameters: 1
	Flags: None
*/
function function_944023af( player )
{
	self endon( "hash_ca20fd7a" );
	self endon( "end_game" );
	if ( !IS_TRUE( self.b_robot_reviving ) )
		self.b_robot_reviving = 1;
	
	player.var_b8bcd543 = 0;
	self thread function_ed3b1086( player );
	self.ignoreall = 1;
	queryResult = PositionQuery_Source_Navigation( player.origin, 64, 96, 48, 18, self );
	if ( queryResult.data.size )
	{
		point = queryResult.data[ RandomInt( queryResult.data.size ) ];
		self.var_cd632390 = point.origin;
	}
	self SetGoal( self.var_cd632390, 1 );
	self waittill( "goal" );
	level.b_robot_reviving = 1;
	player.reviveTrigger.beingRevived = 1;
	player.var_b8bcd543 = 1;
	vector = VectorNormalize( player.origin - self.origin );
	angles = VectorToAngles( vector );
	self teleport( self.origin, angles );
	self thread animation::Play( "ai_robot_base_stn_exposed_revive", self, angles, 1.5 );
	wait .67;
	player clientfield::set( "being_robot_revived", 1 );
	self waittill( "heal_end" ); // hash_ae2cb5a9
	if ( level.players.size == 1 && level flag::get( "solo_game" ) )
		self.n_revive_cooldown = GetTime() + 10000;
	else
		self.n_revive_cooldown = GetTime() + 5000;
	
	player notify( "stop_revive_trigger" );
	if ( isPlayer( player ) )
		player AllowJump( 1 );
	
	player.laststand = undefined;
	player thread zm_laststand::revive_success( self, 0 );
	level.b_robot_reviving = 0;
	players = GetPlayers();
	if ( players.size == 1 && level flag::get( "solo_game" ) && IS_TRUE( player.waiting_to_revive ) )
	{
		level.solo_game_free_player_quickrevive = 1;
		player thread zm_perks::give_perk( "specialty_quickrevive", 0 );
	}
	self function_c50a8914( player );
}

/*
	Name: function_ed3b1086
	Namespace: zodcompanionbehavior
	Checksum: 0xDE5AFC7A
	Offset: 0x3458
	Size: 0xD7
	Parameters: 1
	Flags: None
*/
function function_ed3b1086( player )
{
	self endon( "hash_ca20fd7a" );
	while ( 1 )
	{
		if ( isdefined( player.reviveTrigger ) && player.reviveTrigger.beingRevived === 1 && player.var_b8bcd543 !== 1 )
			self function_c50a8914( player );
		
		if ( !player laststand::player_is_in_laststand() )
			self function_c50a8914( player );
		
		wait .05;
	}
}

/*
	Name: function_c50a8914
	Namespace: zodcompanionbehavior
	Checksum: 0xEE5C154B
	Offset: 0x3538
	Size: 0x81
	Parameters: 1
	Flags: None
*/
function function_c50a8914( player )
{
	self.ignoreall = 0;
	self.b_robot_reviving = 0;
	if ( isdefined( player ) )
	{
		if ( player.var_b8bcd543 == 1 )
			player.var_b8bcd543 = 0;
		
		player clientfield::set( "being_robot_revived", 0 );
	}
	self notify( "hash_ca20fd7a" );
}

/*
	Name: zodcompanionfinishedsprinttransition
	Namespace: zodcompanionbehavior
	Checksum: 0x9EB06BE3
	Offset: 0x35C8
	Size: 0xDB
	Parameters: 1
	Flags: Private
*/
function private zodcompanionfinishedsprinttransition( behaviorTreeEntity )
{
	behaviorTreeEntity.var_d718eb6c = 0;
	if ( blackboard::GetBlackBoardAttribute( behaviorTreeEntity, "_locomotion_speed" ) == "locomotion_speed_walk" )
	{
		behaviorTreeEntity ai::set_behavior_attribute( "sprint", 1 );
		blackboard::SetBlackBoardAttribute( behaviorTreeEntity, "_locomotion_speed", "locomotion_speed_sprint" );
	}
	else
	{
		behaviorTreeEntity ai::set_behavior_attribute( "sprint", 0 );
		blackboard::SetBlackBoardAttribute( behaviorTreeEntity, "_locomotion_speed", "locomotion_speed_walk" );
	}
}

/*
	Name: zodcompanionkeepscurrentmovementmode
	Namespace: zodcompanionbehavior
	Checksum: 0x587D468E
	Offset: 0x36B0
	Size: 0xDF
	Parameters: 1
	Flags: Private
*/
function private zodcompanionkeepscurrentmovementmode( behaviorTreeEntity )
{
	var_ef42515b = 262144;
	var_1be8672c = 147456;
	dist = DistanceSquared( behaviorTreeEntity.origin, behaviorTreeEntity.v_robot_land_position );
	if ( dist > var_ef42515b && blackboard::GetBlackBoardAttribute( behaviorTreeEntity, "_locomotion_speed" ) == "locomotion_speed_walk" )
		return 0;
	
	if ( dist < var_1be8672c && blackboard::GetBlackBoardAttribute( behaviorTreeEntity, "_locomotion_speed" ) == "locomotion_speed_sprint" )
		return 0;
	
	return 1;
}

/*
	Name: zodcompanionsprinttransitioning
	Namespace: zodcompanionbehavior
	Checksum: 0x5188172F
	Offset: 0x3798
	Size: 0x2B
	Parameters: 1
	Flags: Private
*/
function private zodcompanionsprinttransitioning( behaviorTreeEntity )
{
	if ( behaviorTreeEntity.var_d718eb6c === 1 )
		return 1;
	
	return 0;
}

#namespace zodcompanionserverutils;

/*
	Name: _tryGibbingHead
	Namespace: zodcompanionserverutils
	Checksum: 0x22882D2E
	Offset: 0x37D0
	Size: 0x133
	Parameters: 4
	Flags: Private
*/
function private _tryGibbingHead( entity, damage, hitLoc, isExplosive )
{
	if ( isExplosive && RandomFloatRange( 0, 1 ) <= 0.5 )
		GibServerUtils::GibHead( entity );
	else if ( IsInArray( Array( "head", "neck", "helmet" ), hitLoc ) && RandomFloatRange( 0, 1 ) <= 1 )
		GibServerUtils::GibHead( entity );
	else if ( entity.health - damage <= 0 && RandomFloatRange(0, 1) <= 0.25 )
		GibServerUtils::GibHead( entity );
	
}

/*
	Name: _tryGibbingLimb
	Namespace: zodcompanionserverutils
	Checksum: 0xD648E8BF
	Offset: 0x3910
	Size: 0x27B
	Parameters: 4
	Flags: Private
*/
function private _tryGibbingLimb( entity, damage, hitLoc, isExplosive )
{
	if ( GibServerUtils::IsGibbed( entity, 32 ) || GibServerUtils::IsGibbed( entity, 16 ) )
		return;
	
	if ( isExplosive && RandomFloatRange( 0, 1 ) <= 0.25 )
	{
		if ( entity.health - damage <= 0 && entity.allowdeath && math::cointoss() )
			GibServerUtils::GibRightArm( entity );
		else
			GibServerUtils::GibLeftArm( entity );
		
	}
	else if ( IsInArray( Array( "left_hand", "left_arm_lower", "left_arm_upper" ), hitLoc ) )
		GibServerUtils::GibLeftArm( entity );
	else if ( entity.health - damage <= 0 && entity.allowdeath && IsInArray( Array( "right_hand", "right_arm_lower", "right_arm_upper" ), hitLoc ) )
		GibServerUtils::GibRightArm( entity );
	else if ( entity.health - damage <= 0 && entity.allowdeath && RandomFloatRange( 0, 1 ) <= 0.25 )
	{
		if ( math::cointoss() )
			GibServerUtils::GibLeftArm( entity );
		else
			GibServerUtils::GibRightArm( entity );
		
	}
}

/*
	Name: _tryGibbingLegs
	Namespace: zodcompanionserverutils
	Checksum: 0xF06301E
	Offset: 0x3B98
	Size: 0x37B
	Parameters: 5
	Flags: Private
*/
function private _tryGibbingLegs( entity, damage, hitLoc, isExplosive, attacker )
{
	if ( !isdefined( attacker ) )
		attacker = entity;
	
	canGibLegs = entity.health - damage <= 0 && entity.allowdeath;
	canGibLegs = canGibLegs || ( entity.health - damage / entity.maxhealth <= 0.25 && DistanceSquared( entity.origin, attacker.origin ) <= 360000 && entity.allowdeath );
	if ( entity.health - damage <= 0 && entity.allowdeath && isExplosive && RandomFloatRange( 0, 1 ) <= 0.5 )
	{
		GibServerUtils::GibLegs( entity );
		entity StartRagdoll();
	}
	else if ( canGibLegs && IsInArray( Array( "left_leg_upper", "left_leg_lower", "left_foot" ), hitLoc ) && RandomFloatRange( 0, 1 ) <= 1 )
	{
		if ( entity.health - damage > 0 )
			entity.becomeCrawler = 1;
		
		GibServerUtils::GibLeftLeg( entity );
	}
	else if ( canGibLegs && IsInArray( Array( "right_leg_upper", "right_leg_lower", "right_foot" ), hitLoc ) && RandomFloatRange( 0, 1 ) <= 1 )
	{
		if ( entity.health - damage > 0 )
			entity.becomeCrawler = 1;
		
		GibServerUtils::GibRightLeg( entity );
	}
	else if ( entity.health - damage <= 0 && entity.allowdeath && RandomFloatRange( 0, 1 ) <= 0.25 )
	{
		if ( math::cointoss() )
			GibServerUtils::GibLeftLeg( entity );
		else
			GibServerUtils::GibRightLeg( entity );
		
	}
}

/*
	Name: function_a05a46f
	Namespace: zodcompanionserverutils
	Checksum: 0xB8358657
	Offset: 0x3F20
	Size: 0x18F
	Parameters: 12
	Flags: Private
*/
function private function_a05a46f( inflictor, attacker, damage, flags, meansOfDeath, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex )
{
	entity = self;
	if ( entity.health - damage / entity.maxhealth > 0.75 )
		return damage;
	
	GibServerUtils::ToggleSpawnGibs( entity, 1 );
	isExplosive = IsInArray( Array( "MOD_GRENADE", "MOD_GRENADE_SPLASH", "MOD_PROJECTILE", "MOD_PROJECTIVLE_SPLASH", "MOD_EXPLOSIVE" ), meansOfDeath );
	_tryGibbingHead( entity, damage, hitLoc, isExplosive );
	_tryGibbingLimb( entity, damage, hitLoc, isExplosive );
	_tryGibbingLegs( entity, damage, hitLoc, isExplosive, attacker );
	return damage;
}

/*
	Name: function_b4b7c6c2
	Namespace: zodcompanionserverutils
	Checksum: 0x75DCA24C
	Offset: 0x40B8
	Size: 0x22F
	Parameters: 12
	Flags: Private
*/
function private function_b4b7c6c2( inflictor, attacker, damage, flags, meansOfDeath, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex )
{
	entity = self;
	if ( entity.health - damage <= 0 )
	{
		DestructServerUtils::ToggleSpawnGibs( entity, 1 );
		pieceCount = DestructServerUtils::GetPieceCount( entity );
		possiblePieces = [];
		for ( index = 1; index <= pieceCount; index++ )
		{
			if ( !DestructServerUtils::IsDestructed( entity, index ) && RandomFloatRange( 0, 1 ) <= 0.2 )
				possiblePieces[ possiblePieces.size ] = index;
			
		}
		gibbedPieces = 0;
		for ( index = 0; index < possiblePieces.size && possiblePieces.size > 1 && gibbedPieces < 2; index++ )
		{
			randomPiece = randomIntRange( 0, possiblePieces.size - 1 );
			if ( !DestructServerUtils::IsDestructed( entity, possiblePieces[ randomPiece ] ) )
			{
				DestructServerUtils::DestructPiece( entity, possiblePieces[ randomPiece ] );
				gibbedPieces++;
			}
		}
	}
	return damage;
}

/*
	Name: function_d3676ae9
	Namespace: zodcompanionserverutils
	Checksum: 0xFD7B7316
	Offset: 0x42F0
	Size: 0xCB
	Parameters: 12
	Flags: Private
*/
function private function_d3676ae9( inflictor, attacker, damage, flags, meansOfDeath, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex )
{
	entity = self;
	if ( hitLoc == "helmet" || hitLoc == "head" || hitLoc == "neck" )
		damage = Int( damage * 0.5 );
	
	return damage;
}

/*
	Name: findClosestNavMeshPositionToEnemy
	Namespace: zodcompanionserverutils
	Checksum: 0xB8EF9671
	Offset: 0x43C8
	Size: 0x83
	Parameters: 1
	Flags: Private
*/
function private findClosestNavMeshPositionToEnemy( enemy )
{
	enemyPositionOnNavMesh = undefined;
	for ( toleranceLevel = 1; toleranceLevel <= 4; toleranceLevel++ )
	{
		enemyPositionOnNavMesh = GetClosestPointOnNavMesh( enemy.origin, 200 * toleranceLevel );
		if ( isdefined( enemyPositionOnNavMesh ) )
			break;
		
	}
	return enemyPositionOnNavMesh;
}

/*
	Name: zodcompanionsoldierspawnsetup
	Namespace: zodcompanionserverutils
	Checksum: 0xDC58D726
	Offset: 0x4458
	Size: 0x253
	Parameters: 0
	Flags: Private
*/
function private zodcompanionsoldierspawnsetup()
{
	entity = self;
	entity.combatmode = "cover";
	entity.fullHealth = entity.health;
	entity.controlLevel = 0;
	entity.steppedOutOfCover = 0;
	entity.startingWeapon = entity.weapon;
	entity.jukeDistance = 90;
	entity.jukeMaxDistance = 600;
	entity.entityRadius = 15;
	entity.var_9f44813a = entity.accuracy;
	entity.highlyawareradius = 256;
	entity.treatAllCoversAsGeneric = 1;
	entity.onlyCrouchArrivals = 1;
	entity.nextPreemptiveJukeAds = RandomFloatRange( 0.5, 0.95 );
	entity.shouldPreemptiveJuke = math::cointoss();
	entity.b_robot_reviving = 0;
	AiUtility::AddAIOverrideDamageCallback( entity, &DestructServerUtils::handleDamage );
	AiUtility::AddAIOverrideDamageCallback( entity, &function_d3676ae9 );
	AiUtility::AddAIOverrideDamageCallback( entity, &function_a05a46f );
	entity.v_robot_land_position = entity.origin;
	entity.var_9f6855ba = GetTime();
	entity.allow_zombie_to_target_ai = 1;
	entity.ignoreme = 1;
	entity thread namespace_8f15b1fe::function_cbe73e3d();
	entity thread namespace_8f15b1fe::function_18d76447();
}

#namespace namespace_8f15b1fe;

/*
	Name: function_18d76447
	Namespace: namespace_8f15b1fe
	Checksum: 0xABE66E86
	Offset: 0x46B8
	Size: 0x67
	Parameters: 0
	Flags: None
*/
function function_18d76447()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( !self.b_robot_reviving )
		{
			if ( !isdefined( self.leader ) || !self.leader.var_ff30d5ce )
				self function_5104a2a9();
			
		}
		wait .5;
	}
}

/*
	Name: function_cbe73e3d
	Namespace: namespace_8f15b1fe
	Checksum: 0x61D92885
	Offset: 0x4728
	Size: 0x99
	Parameters: 0
	Flags: None
*/
function function_cbe73e3d()
{
	self.var_fb400bf7 = [];
	self.var_fb400bf7[ 0 ] = "double_points";
	self.var_fb400bf7[ 1 ] = "fire_sale";
	self.var_fb400bf7[ 2 ] = "insta_kill";
	self.var_fb400bf7[ 3 ] = "nuke";
	self.var_fb400bf7[ 4 ] = "full_ammo";
	self.var_fb400bf7[ 5 ] = "insta_kill_ug";
}

/*
	Name: function_5104a2a9
	Namespace: namespace_8f15b1fe
	Checksum: 0x957CFC4B
	Offset: 0x47D0
	Size: 0x165
	Parameters: 0
	Flags: None
*/
function function_5104a2a9()
{
	if ( isdefined( level.b_robot_leader ) && level.b_robot_leader.var_ff30d5ce )
	{
		self.leader = level.b_robot_leader;
		break;
	}
	var_ed56d2f6 = function_801ff0ab( self );
	var_d503f306 = undefined;
	closest_distance = 1000000;
	if ( var_ed56d2f6.size == 0 )
	{
		self.leader = undefined;
		break;
	}
	foreach ( var_f76ee5cf in var_ed56d2f6 )
	{
		dist = PathDistance( self.origin, var_f76ee5cf.origin );
		if ( isdefined( dist ) && dist < closest_distance )
		{
			closest_distance = dist;
			self.leader = var_f76ee5cf;
		}
	}
}

/*
	Name: function_801ff0ab
	Namespace: namespace_8f15b1fe
	Checksum: 0x148DC9BA
	Offset: 0x4940
	Size: 0x121
	Parameters: 1
	Flags: None
*/
function function_801ff0ab( companion )
{
	var_ed56d2f6 = [];
	foreach ( player in level.players )
	{
		if ( !isdefined( player.var_ff30d5ce ) )
			player.var_ff30d5ce = 1;
		
		if ( isdefined( player.var_ff30d5ce ) && player.var_ff30d5ce && companion FindPath( companion.origin, player.origin ) )
			var_ed56d2f6[ var_ed56d2f6.size ] = player;
		
	}
	return var_ed56d2f6;
}

