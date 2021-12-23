#using scripts\shared\ai_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\ai\archetype_thrasher;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_thrasher.gsh;

#namespace zm_ai_thrasher;

#using_animtree( "generic" );

function autoexec main()
{
	clientfield::register( "actor", THRASHER_MOUTH_CF, VERSION_SHIP, 8, "int", &ThrasherClientUtils::thrasher_mouth_cf, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

#namespace ThrasherClientUtils;

function thrasher_get_state( entity, player, state )
{
	entityNumber = player getEntityNumber();
	n_mouth_state = state;
	n_mouth_state &= ( 3 << ( 2 * entityNumber ) );
	return n_mouth_state >> ( 2 * entityNumber );
}

function private thrasher_mouth_cf( localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump )
{
	entity = self;
	localPlayer = getLocalPlayer( localClientNum );
	localPlayerClientNum = localPlayer getLocalClientNumber();
	oldState = thrasher_get_state( entity, localPlayer, oldValue );
	State = thrasher_get_state( entity, localPlayer, newValue );
	
	if( oldState == State && localClientNum === localPlayerClientNum )
		return;
	
	if ( localClientNum !== localPlayerClientNum )
	{
		entity thread thrasher_delete_stomach( localClientNum, entity, localPlayer );
		return;
	}
	if ( IS_TRUE( entity.b_thasher_no_stomach ) )
		return;
	
	if ( !isDefined( entity.e_thrasher_stomach ) && State != 0 )
	{
		entity thread thrasher_create_stomach( localClientNum, entity, localPlayer );
		entity thread thrasher_update_stomach( localClientNum, entity, localPlayer );
	}
	switch ( State )
	{
		case 0:
		{
			entity thread thrasher_delete_stomach( localClientNum, entity, localPlayer );
			break;
		}
		case 1:
		{
			entity thread thrasher_stomach_idle( localClientNum, entity, localPlayer );
			break;
		}
		case 2:
		{
			entity thread thrasher_stomach_open( localClientNum, entity, localPlayer );
			break;
		}
		case 3:
		{
			entity thread thrasher_stomach_close( localClientNum, entity, localPlayer );
			break;
		}
	}
}

function private thrasher_stomach_idle( localClientNum, thrasher, player )
{
	if( isdefined( thrasher ) && isDefined( thrasher.e_thrasher_stomach ) )
	{
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_close_anim", .2 );
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_open_anim", .2 );
		thrasher.e_thrasher_stomach setAnimRestart( "p7_fxanim_zm_island_thrasher_stomach_idle_anim" );
	}
}

function private thrasher_stomach_close( localClientNum, thrasher, player )
{
	if ( isDefined( thrasher ) && isDefined( thrasher.e_thrasher_stomach ) )
	{
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_idle_anim", .2 );
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_open_anim", .2 );
		thrasher.e_thrasher_stomach setAnimRestart( "p7_fxanim_zm_island_thrasher_stomach_close_anim" );
		player thread LUI::screen_fade( 1.5, 0.3, 0 );
		player thread postfx::playPostfxBundle( "pstfx_thrasher_stomach" );
	}
}

function private thrasher_stomach_open( localClientNum, thrasher, player )
{
	if ( isDefined( thrasher ) && isDefined( thrasher.e_thrasher_stomach ) )
	{
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_idle_anim", .2 );
		thrasher.e_thrasher_stomach clearAnim( "p7_fxanim_zm_island_thrasher_stomach_close_anim", .2 );
		thrasher.e_thrasher_stomach setAnimRestart( "p7_fxanim_zm_island_thrasher_stomach_open_anim" );
		player thread LUI::screen_fade_in( 2 );
		player thread postfx::playPostfxBundle( "pstfx_thrasher_stomach" );
		animtime = getAnimLength( "p7_fxanim_zm_island_thrasher_stomach_open_anim" );
		wait animtime;
		thrasher_stomach_idle( localClientNum, thrasher, player );
	}
}

function private thrasher_create_stomach( localClientNum, thrasher, player )
{
	thrasher endon( "entityshutdown" );
	player endon( "entityshutdown" );
	player endon( "thrasher_player_freed" );
	thrasher endon( "thrasher_player_freed" );
	eyePosition = player getTagOrigin( "tag_eye" );
	eyeOffset = ( 0, 0, abs( abs( eyePosition[ 2 ] - player.origin[ 2 ] ) - 40 ) - 10 );
	thrasher.e_thrasher_stomach = spawn( localClientNum, thrasher.origin, "script_model" );
	thrasher.e_thrasher_stomach setModel( "p7_fxanim_zm_island_thrasher_stomach_mod" );
	thrasher.e_thrasher_stomach useAnimTree( #animtree );
	offsetScale = 5;
	forwardOffset = anglesToForward( thrasher.e_thrasher_stomach.angles ) * offsetScale;
	thrasher.e_thrasher_stomach.origin = getCamPosByLocalClientNum( player.localClientNum ) - forwardOffset;
	lastPosition = thrasher.e_thrasher_stomach.origin;
	tempOrigin = ( 0, 0, 0 );
	interpolate = .01;
	max_distance_to_camera = 2;
	max_distance_to_new_origin = .1;
	max_distance_to_camera_sq = max_distance_to_camera * max_distance_to_camera;
	max_distance_to_new_origin_sq = max_distance_to_new_origin * max_distance_to_new_origin;
	while ( 1 )
	{
		forwardOffset = anglesToForward( thrasher.e_thrasher_stomach.angles ) * offsetScale;
		desiredPosition = thrasher getTagOrigin( "tag_camera_thrasher" ) + eyeOffset - forwardOffset;
		v_camera_with_offset = getCamPosByLocalClientNum( player.localClientNum ) - forwardOffset;
		v_new_origin = desiredPosition - v_camera_with_offset;
		if ( lengthSquared( v_new_origin ) > max_distance_to_camera_sq )
			v_new_origin = vectorNormalize( v_new_origin ) * max_distance_to_camera;
		
		desiredPosition = v_camera_with_offset + v_new_origin;
		v_comp_origin = v_new_origin - tempOrigin;
		if ( lengthSquared( v_comp_origin ) > max_distance_to_new_origin_sq )
			v_new_origin = tempOrigin + vectorNormalize( v_comp_origin ) * max_distance_to_new_origin;
		
		thrasher.e_thrasher_stomach.origin = v_camera_with_offset + v_new_origin;
		tempOrigin = v_new_origin;
		wait interpolate;
	}
}

function private thrasher_update_stomach( localClientNum, thrasher, player )
{
	thrasher endon( "entityshutdown" );
	player endon( "entityshutdown" );
	player endon( "thrasher_player_freed" );
	thrasher endon( "thrasher_player_freed" );
	interpolate = .016;
	v_clamped_angles = angleClamp180( getCamAnglesByLocalClientNum( player.localClientNum )[ 1 ]);
	thrasher.e_thrasher_stomach.angles = ( 0, v_clamped_angles, 0 );
	maxYawDelta = .01;
	lastTime = player getClientTime() / 1000;
	wait interpolate;
	while ( isDefined( thrasher.e_thrasher_stomach ) )
	{
		currentTime = player getClientTime() / 1000;
		n_real_time = currentTime - lastTime;
		v_forward = thrasher.e_thrasher_stomach.angles[ 1 ];
		newYaw = getCamAnglesByLocalClientNum( player.localClientNum )[ 1 ];
		while ( n_real_time > interpolate )
		{
			v_forward = angleClamp180( angleLerp( v_forward, newYaw, .15 ) );
			n_real_time = n_real_time - interpolate;
		}
		thrasher.e_thrasher_stomach.angles = ( 0, v_forward, 0 );
		lastTime = currentTime - n_real_time;
		wait interpolate;
	}
}

function private thrasher_delete_stomach( localClientNum, thrasher, player )
{
	if ( isDefined( thrasher ) )
	{
		thrasher notify( "thrasher_player_freed" );
		thrasher.b_thasher_no_stomach = 1;
	}
	if ( isDefined( player ) )
		player notify( "thrasher_player_freed" );
	
	if ( isDefined( player ) )
		player thread LUI::screen_fade_in( 2 );
	
	if ( isDefined( thrasher ) && isDefined( thrasher.e_thrasher_stomach ) )
	{
		thrasher.e_thrasher_stomach delete();
		thrasher.e_thrasher_stomach = undefined;
	}
}