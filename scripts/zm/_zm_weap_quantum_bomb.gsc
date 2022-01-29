#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_powerup_lose_points;
#using scripts\zm\_zm_powerup_empty_clip;
#using scripts\zm\_zm_powerup_lose_perk;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_quantum_bomb.gsh;

#precache( "fx", QUANTUM_BOMB_ZOMBIE_FLING_RESULT_FX );
#precache( "fx", QUANTUM_BOMB_AREA_EFFECT_FX );
#precache( "fx", QUANTUM_BOMB_PLAYER_EFFECT_FX );
#precache( "fx", QUANTUM_BOMB_PLAYER_POSITION_EFFECT_FX );
#precache( "fx", QUANTUM_BOMB_MYSTERY_EFFECT_FX );

#namespace zm_weap_quantum_bomb;

REGISTER_SYSTEM_EX( "zm_weap_quantum_bomb", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # VARIABLES AND SETTINGS
	level.using_zombie_powerups = 1;
	level.w_quantum_bomb = getWeapon( QUANTUM_BOMB_WEAPON );
	zm_utility::register_tactical_grenade_for_level( QUANTUM_BOMB_WEAPON );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER FX
	level._effect[ "zombie_fling_result" ] = QUANTUM_BOMB_ZOMBIE_FLING_RESULT_FX;
	level._effect[ "quantum_bomb_area_effect" ] = QUANTUM_BOMB_AREA_EFFECT_FX;
	level._effect[ "quantum_bomb_player_effect" ] = QUANTUM_BOMB_PLAYER_EFFECT_FX;
	level._effect[ "quantum_bomb_player_position_effect" ] = QUANTUM_BOMB_PLAYER_POSITION_EFFECT_FX;
	level._effect[ "quantum_bomb_mystery_effect" ] = QUANTUM_BOMB_MYSTERY_EFFECT_FX;
	// # REGISTER FX
	
	// # REGISTER CALLBACKS
	level._zombiemode_powerup_zombie_grab = &_zombiemode_powerup_zombie_grab;
	level.quantum_bomb_register_result_func = &quantum_bomb_register_result;
	level.quantum_bomb_deregister_result_func = &quantum_bomb_deregister_result;
	level.quantum_bomb_in_playable_area_validation_func = &quantum_bomb_in_playable_area_validation;
	level.quantum_bomb_play_area_effect_func = &quantum_bomb_play_area_effect;
	level.quantum_bomb_play_player_effect_func = &quantum_bomb_play_player_effect;
	level.quantum_bomb_play_player_effect_at_position_func = &quantum_bomb_play_player_effect_at_position;
	level.quantum_bomb_play_mystery_effect_func = &quantum_bomb_play_mystery_effect;
	callback::on_spawned( &quantum_bomb_on_spawned );
	// # REGISTER CALLBACKS
	
	// # REGISTER QED RESULTS	
	quantum_bomb_register_result( "random_lethal_grenade", &quantum_bomb_lethal_grenade_result, QUANTUM_BOMB_RANDOM_LETHAL_GRENADE_CHANCE );
	quantum_bomb_register_result( "random_weapon_starburst", &quantum_bomb_random_weapon_starburst_result, QUANTUM_BOMB_RANDOM_WEAPON_STARBURST_CHANCE );
	quantum_bomb_register_result( "pack_or_unpack_current_weapon", &quantum_bomb_pack_or_unpack_current_weapon_result, QUANTUM_BOMB_PACK_OR_UNPACK_CURRENT_WEAPON_CHANCE, &quantum_bomb_pack_or_unpack_current_weapon_validation );
	quantum_bomb_register_result( "auto_revive", &quantum_bomb_auto_revive_result, QUANTUM_BOMB_AUTO_REVIVE_CHANCE, &quantum_bomb_auto_revive_validation );
	quantum_bomb_register_result( "player_teleport", &quantum_bomb_player_teleport_result, QUANTUM_BOMB_PLAYER_TELEPORT_CHANCE );
	quantum_bomb_register_result( "zombie_speed_buff", &quantum_bomb_zombie_speed_buff_result, QUANTUM_BOMB_ZOMBIE_SPEED_BUFF_CHANCE );
	quantum_bomb_register_result( "zombie_add_to_total", &quantum_bomb_zombie_add_to_total_result, QUANTUM_BOMB_ZOMBIE_ADD_TO_TOTAL_CHANCE, &quantum_bomb_zombie_add_to_total_validation );
	quantum_bomb_register_result( "zombie_fling", &quantum_bomb_zombie_fling_result );
	quantum_bomb_register_result( "random_powerup", &quantum_bomb_random_powerup_result, QUANTUM_BOMB_RANDOM_POWERUP_CHANCE );
	quantum_bomb_register_result( "random_zombie_grab_powerup", &quantum_bomb_random_zombie_grab_powerup_result, QUANTUM_BOMB_RANDOM_ZOMBIE_POWERUP_CHANCE );
	// quantum_bomb_register_result( "random_weapon_powerup", &quantum_bomb_random_weapon_powerup_result, QUANTUM_BOMB_RANDOM_WEAPON_POWERUP_CHANCE );
	quantum_bomb_register_result( "random_bonus_or_lose_points_powerup", &quantum_bomb_random_bonus_or_lose_points_powerup_result, QUANTUM_BOMB_POINTS_POWERUP_CHANCE );
	// # REGISTER QED RESULTS	
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function _zombiemode_powerup_zombie_grab( e_grabber )
{
	level thread [[ level._zombiemode_powerup_grab ]]( self, e_grabber );
}

function quantum_bomb_on_spawned()
{
	self thread player_handle_quantum_bomb();
}

function quantum_bomb_register_result( str_name, ptr_result_func, n_chance = 100, ptr_validation_func )
{
	if ( !isDefined( level.quantum_bomb_results ) )
		level.quantum_bomb_results = [];
	
	if ( isDefined( level.quantum_bomb_results[ str_name ] ) )
		return;
	
	s_result = spawnStruct();
	s_result.str_name = str_name;
	s_result.ptr_result_func = ptr_result_func;
	s_result.n_chance = math::clamp( n_chance, 1, 100 );
	
	if ( !isDefined( ptr_validation_func ) )
		s_result.ptr_validation_func = &quantum_bomb_default_validation;
	else
		s_result.ptr_validation_func = ptr_validation_func;
	
	level.quantum_bomb_results[ str_name ] = s_result;
}

function quantum_bomb_deregister_result( str_name )
{
	if ( !isDefined( level.quantum_bomb_results ) )
		level.quantum_bomb_results = [];
	
	if ( !isDefined( level.quantum_bomb_results[ str_name ] ) )
		return;
	
	level.quantum_bomb_results[ str_name ] = undefined;
}

function quantum_bomb_in_playable_area_validation( v_position )
{
	return quantum_bomb_get_cached_in_playable_area( v_position );
}

function quantum_bomb_play_area_effect( v_position )
{
	playFX( level._effect[ "quantum_bomb_area_effect" ], v_position );
}

function quantum_bomb_play_player_effect()
{
	playFXOnTag( level._effect[ "quantum_bomb_player_effect" ], self, "tag_origin" );
}

function quantum_bomb_play_player_effect_at_position( v_position )
{
	playFX( level._effect[ "quantum_bomb_player_position_effect" ], v_position );
}

function quantum_bomb_play_mystery_effect( v_position )
{
	playFX( level._effect[ "quantum_bomb_mystery_effect" ], v_position );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function quantum_bomb_clear_cached_data()
{
	level.quantum_bomb_cached_in_playable_area = undefined;
	level.quantum_bomb_cached_closest_zombies = undefined;
}

function quantum_bomb_select_result( v_position )
{
	quantum_bomb_clear_cached_data();
	
	a_eligible_results = [];
	n_chance = randomInt( 100 );
	a_keys = getArrayKeys( level.quantum_bomb_results );
	for ( i = 0; i < a_keys.size; i++ )
	{
		s_result = level.quantum_bomb_results[ a_keys[ i ] ];
		if ( s_result.n_chance > n_chance && self [ [ s_result.ptr_validation_func ] ]( v_position ) )
			a_eligible_results[ a_eligible_results.size ] = s_result.str_name;
		
	}
	return level.quantum_bomb_results[ a_eligible_results[ randomInt( a_eligible_results.size ) ] ];
}

function player_handle_quantum_bomb()
{
	self notify( "starting_quantum_bomb" );
	self endon( "disconnect" );
	self endon( "starting_quantum_bomb" );
	level endon( "end_game" );
	while ( 1 )
	{
		self waittill( "grenade_fire", e_grenade, w_weapon );
		if ( w_weapon != level.w_quantum_bomb )
			continue;
		
		if ( isDefined( e_grenade ) )
		{
			if ( self laststand::player_is_in_laststand() )
			{
				e_grenade delete();
				continue;
			}
			e_grenade waittill( "explode", v_position );
			playSoundAtPosition( QUANTUM_BOMB_EXP_SND, v_position );
			s_result = self quantum_bomb_select_result( v_position );
			self thread [ [ s_result.ptr_result_func ] ]( v_position );
		}
		WAIT_SERVER_FRAME;
	}
}

function quantum_bomb_exists()
{
	return isDefined( level.zombie_weapons[ QUANTUM_BOMB_WEAPON ] );
}

function quantum_bomb_default_validation( v_position )
{
	return 1;
}

function quantum_bomb_get_cached_closest_zombies( v_position )
{
	if ( !isDefined( level.quantum_bomb_cached_closest_zombies ) )
		level.quantum_bomb_cached_closest_zombies = util::get_array_of_closest( v_position, zombie_utility::get_round_enemy_array() );
	
	return level.quantum_bomb_cached_closest_zombies;
}

function quantum_bomb_get_cached_in_playable_area( v_position )
{
	if ( !isDefined( level.quantum_bomb_cached_in_playable_area ) )
		level.quantum_bomb_cached_in_playable_area = zm_utility::check_point_in_playable_area( v_position );
	
	return level.quantum_bomb_cached_in_playable_area;
}

function quantum_bomb_lethal_grenade_result( v_position )
{
	self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
	a_keys = getArrayKeys( level.zombie_lethal_grenade_list );
	self magicGrenadeType( level.zombie_lethal_grenade_list[ a_keys[ randomInt( a_keys.size ) ] ], v_position, ( 0, 0, 0 ), .35 );
}

function quantum_bomb_invalid_weapon( w_weapon )
{
	if ( w_weapon == level.weaponNone )
		return 1;
	
	if ( w_weapon.type == "projectile" )
	{
		if ( w_weapon.weapClass == "pistol" || w_weapon.weapClass == "pistol spread" )
			return 0;
		
		return 1;
	}
	return 0;
}

function quantum_bomb_random_weapon_starburst_result( v_position )
{
	self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
	a_weapons_list = [];
	a_zombie_weapons = getArrayKeys( level.zombie_weapons );
	foreach ( w_weapon in a_zombie_weapons )
	{
		if ( !w_weapon.isMeleeWeapon && !w_weapon.isgrenadeweapon && !w_weapon.isLauncher && !quantum_bomb_invalid_weapon( w_weapon ) )
			array::add( a_weapons_list, w_weapon, 0 );
		
	}
	w_weapon = array::random( a_weapons_list );
	w_upg_weapon = zm_weapons::get_upgrade_weapon( w_weapon );
	if ( !quantum_bomb_invalid_weapon( w_upg_weapon ) )
		w_weapon = w_upg_weapon;
	
	quantum_bomb_play_player_effect_at_position( v_position );
	v_base_pos = v_position + vectorScale( ( 0, 0, 1 ), 40 );
	v_start_yaw = vectorToAngles( v_base_pos - self.origin );
	v_start_yaw = ( 0, v_start_yaw[ 1 ], 0 );
	e_weapon_model = zm_utility::spawn_weapon_model( w_weapon, undefined, v_position, v_start_yaw );
	e_weapon_model moveTo( v_base_pos, 1, .25, .25 );
	e_weapon_model waittill( "movedone" );
	for ( i = 0; i < 36; i++ )
	{
		v_yaw = v_start_yaw + ( randomIntRange( -3, 3 ), i * 10, 0 );
		e_weapon_model.angles = v_yaw;
		v_flash_pos = e_weapon_model getTagOrigin( "tag_flash" );
		v_target_pos = v_flash_pos + vectorScale( anglesToForward( v_yaw ), 40 );
		magicBullet( w_weapon, v_flash_pos, v_target_pos, undefined );
		util::wait_network_frame();
	}
	e_weapon_model delete();
}

function quantum_bomb_pack_or_unpack_current_weapon_validation( v_position )
{
	if ( !quantum_bomb_get_cached_in_playable_area( v_position ) )
		return 0;
	
	a_pack_triggers = getEntArray( "specialty_weapupgrade", "script_noteworthy" );
	n_range_squared = 32400;
	for ( i = 0; i < a_pack_triggers.size; i++ )
	{
		if ( distanceSquared( a_pack_triggers[ i ].origin, v_position ) < n_range_squared )
			return 1;
		
	}
	return !randomInt( 5 );
}

function quantum_bomb_pack_or_unpack_current_weapon_result( v_position )
{
	quantum_bomb_play_mystery_effect( v_position );
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( e_player.sessionstate == "spectator" || e_player laststand::player_is_in_laststand() )
			continue;
		
		w_weapon = e_player getCurrentWeapon();
		if ( !w_weapon.isPrimary || !isDefined( level.zombie_weapons[ w_weapon ] ) )
			continue;
		
		if ( zm_weapons::is_weapon_upgraded( w_weapon ) )
		{
			if ( randomInt( 5 ) )
				continue;
			
			a_ziw_keys = getArrayKeys( level.zombie_weapons );
			for ( n_weapon_index = 0; n_weapon_index < level.zombie_weapons.size; n_weapon_index++ )
			{
				if ( isDefined( level.zombie_weapons[ a_ziw_keys[ n_weapon_index ] ].upgrade_name ) && level.zombie_weapons[ a_ziw_keys[ n_weapon_index ] ].upgrade_name == w_weapon )
				{
					if ( e_player == self )
						self thread zm_audio::create_and_play_dialog( "kill", "quant_bad" );
					
					e_player thread zm_weapons::weapon_give( a_ziw_keys[ n_weapon_index ] );
					e_player quantum_bomb_play_player_effect();
					break;
				}
			}
			continue;
		}
		if ( zm_weapons::can_upgrade_weapon( w_weapon ) )
		{
			if ( !randomInt( 4 ) )
				continue;
			
			n_weapon_limit = 2;
			if ( e_player hasPerk( "specialty_additionalprimaryweapon" ) )
				n_weapon_limit = 3;
			
			a_primaries = e_player getWeaponsListPrimaries();
			if ( isDefined( a_primaries ) && a_primaries.size < n_weapon_limit )
				e_player takeWeapon( w_weapon );
			
			if ( e_player == self )
				e_player thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
			
			e_player thread zm_weapons::weapon_give( level.zombie_weapons[ w_weapon ].upgrade );
			e_player quantum_bomb_play_player_effect();
		}
	}
}

function quantum_bomb_auto_revive_validation( v_position )
{
	if ( level flag::get( "solo_game" ) )
		return 0;
	
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( e_player laststand::player_is_in_laststand() )
			return 1;
		
	}
	return 0;
}

function quantum_bomb_auto_revive_result( v_position )
{
	quantum_bomb_play_mystery_effect( v_position );
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( e_player laststand::player_is_in_laststand() && randomInt( 3 ) )
		{
			e_player zm_laststand::auto_revive( self );
			e_player quantum_bomb_play_player_effect();
		}
	}
}

function quantum_bomb_player_teleport_result( v_position )
{
	quantum_bomb_play_mystery_effect( v_position );
	a_players = getPlayers();
	a_players_to_teleport = [];
	for ( i = 0; i < a_players.size; i++ )
	{
		e_player = a_players[ i ];
		if ( e_player.sessionstate == "spectator" || e_player laststand::player_is_in_laststand() )
			continue;
		
		if ( isDefined( level.quantum_bomb_prevent_player_getting_teleported ) && e_player [ [ level.quantum_bomb_prevent_player_getting_teleported ] ]( v_position ) )
			continue;
		
		a_players_to_teleport[ a_players_to_teleport.size ] = e_player;
	}
	a_players_to_teleport = array::randomize( a_players_to_teleport );
	for ( i = 0; i < a_players_to_teleport.size; i++ )
	{
		e_player = a_players_to_teleport[ i ];
		if ( i && randomInt( 5 ) )
			continue;
		
		level thread quantum_bomb_teleport_player( e_player );
	}
}

function quantum_bomb_teleport_player( e_player )
{
	a_black_hole_teleport_structs = struct::get_array( "struct_black_hole_teleport", "targetname" );
	s_chosen_spot = undefined;
	if ( isDefined( level._special_blackhole_bomb_structs ) )
		a_black_hole_teleport_structs = [ [ level._special_blackhole_bomb_structs ] ]();
	
	str_player_current_zone = e_player zm_utility::get_current_zone();
	if ( !isDefined( a_black_hole_teleport_structs ) || a_black_hole_teleport_structs.size == 0 || !isDefined( str_player_current_zone ) )
		return;
	
	a_black_hole_teleport_structs = array::randomize( a_black_hole_teleport_structs );
	if ( isDefined( level._override_blackhole_destination_logic ) )
	{
		s_chosen_spot = [ [ level._override_blackhole_destination_logic ] ]( a_black_hole_teleport_structs, e_player );
		break;
	}
	for ( i = 0; i < a_black_hole_teleport_structs.size; i++ )
	{
		if ( zm_utility::check_point_in_enabled_zone( a_black_hole_teleport_structs[ i ].origin ) && str_player_current_zone != a_black_hole_teleport_structs[ i ].script_string )
		{
			s_chosen_spot = a_black_hole_teleport_structs[ i ];
			break;
		}
	}
	if ( isDefined( s_chosen_spot ) )
		e_player thread quantum_bomb_teleport( s_chosen_spot );
	
}

function quantum_bomb_teleport( s_dest )
{
	self endon( "death" );
	if ( !isDefined( s_dest ) )
		return;
	
	v_prone_offset = vectorScale( ( 0, 0, 1 ), 49 );
	v_crouch_offset = vectorScale( ( 0, 0, 1 ), 20 );
	v_stand_offset = ( 0, 0, 0 );
	v_destination = undefined;
	if ( self getStance() == "prone" )
		v_destination = s_dest.origin + v_prone_offset;
	else if ( self getStance() == "crouch" )
		v_destination = s_dest.origin + v_crouch_offset;
	else
		v_destination = s_dest.origin + v_stand_offset;
	
	if ( isDefined( level._black_hole_teleport_override ) )
		level [ [ level._black_hole_teleport_override ] ]( self );
	
	quantum_bomb_play_player_effect_at_position( self.origin );
	self freezeControls( 1 );
	self disableOffhandWeapons();
	self disableWeapons();
	self playSoundToPlayer( QUANTUM_BOMB_TELEPORT_SND, self );
	self dontInterpolate();
	self setOrigin( v_destination );
	self setPlayerAngles( s_dest.angles );
	self enableOffhandWeapons();
	self enableWeapons();
	self freezeControls( 0 );
	self quantum_bomb_play_player_effect();
	self thread quantum_bomb_slightly_delayed_player_response();
}

function quantum_bomb_slightly_delayed_player_response()
{
	wait 1;
	self zm_audio::create_and_play_dialog( "general", "teleport_gersh" );
}

function quantum_bomb_zombie_speed_buff_result( v_position )
{
	quantum_bomb_play_mystery_effect( v_position );
	self thread zm_audio::create_and_play_dialog( "kill", "quant_bad" );
	a_zombies = quantum_bomb_get_cached_closest_zombies( v_position );
	for ( i = 0; i < a_zombies.size; i++ )
	{
		e_zombie = a_zombies[ i ];
		if ( isDefined( e_zombie.fastSprintFunc ) )
			str_fast_sprint = e_zombie [ [ e_zombie.fastSprintFunc ] ]();
		else if ( IS_TRUE( e_zombie.in_low_gravity ) )
		{
			if ( IS_TRUE( e_zombie.missingLegs ) )
				str_fast_sprint = "crawl_low_g_super_sprint";
			else
				str_fast_sprint = "low_g_super_sprint";
			
		}
		else if ( IS_TRUE( e_zombie.missingLegs ) )
			str_fast_sprint = "crawl_super_sprint";
		
		if ( IS_TRUE( e_zombie.isdog ) )
			continue;
		
		e_zombie zombie_utility::set_zombie_run_cycle( "super_sprint" );
	}
}

function quantum_bomb_zombie_fling_result( v_position )
{
	playFX( level._effect[ "zombie_fling_result" ], v_position );
	self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
	n_range = 300;
	n_range_squared = SQR( n_range );
	a_zombies = quantum_bomb_get_cached_closest_zombies( v_position );
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

function quantum_bomb_fling_zombie( e_player, v_fling_vec )
{
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	self doDamage( self.health + 666, e_player.origin, e_player, e_player, 0, "MOD_UNKNOWN", 0, level.w_quantum_bomb );
	if ( self.health <= 0 )
	{
		self startRagdoll();
		self launchRagdoll( v_fling_vec );
	}
}

function quantum_bomb_zombie_add_to_total_validation( v_position )
{
	if ( level.zombie_total )
		return 0;
	
	a_zombies = quantum_bomb_get_cached_closest_zombies( v_position );
	return a_zombies.size < level.zombie_ai_limit;
}

function quantum_bomb_zombie_add_to_total_result( v_position )
{
	quantum_bomb_play_mystery_effect( v_position );
	self thread zm_audio::create_and_play_dialog( "kill", "quant_bad" );
	level.zombie_total = level.zombie_total + level.zombie_ai_limit;
}

function quantum_bomb_random_powerup_result( v_position )
{
	if ( !isDefined( level.zombie_include_powerups ) || !level.zombie_include_powerups.size )
		return;
	
	a_keys = getArrayKeys( level.zombie_include_powerups );
	while ( a_keys.size )
	{
		n_index = randomInt( a_keys.size );
		if ( !level.zombie_powerups[ a_keys[ n_index ] ].zombie_grabbable )
		{
			b_skip = 0;
			switch ( a_keys[ n_index ] )
			{
				case "bonus_points_player":
				case "bonus_points_team":
				case "random_weapon":
				{
					b_skip = 1;
					break;
				}
				case "fire_sale":
				case "full_ammo":
				case "insta_kill":
				case "minigun":
				{
					if ( randomInt( 4 ) )
						b_skip = 1;
					
					break;
				}
				case "bonfire_sale":
				case "free_perk":
				case "tesla":
				{
					if ( randomInt( 20 ) )
						b_skip = 1;
					
					break;
				}
				default:
				{
				}
			}
			if ( b_skip )
			{
				arrayRemoveValue( a_keys, a_keys[ n_index ] );
				continue;
			}
			self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
			[ [ level.quantum_bomb_play_player_effect_at_position_func ] ]( v_position );
			level zm_powerups::specific_powerup_drop( a_keys[ n_index ], v_position );
			return;
		}
		else
			arrayRemoveValue( a_keys, a_keys[ n_index ] );
		
	}
}

function quantum_bomb_random_zombie_grab_powerup_result( v_position )
{
	if ( !isDefined( level.zombie_include_powerups ) || !level.zombie_include_powerups.size )
		return;
	
	a_keys = getArrayKeys( level.zombie_include_powerups );
	
	while ( a_keys.size )
	{
		n_index = randomInt( a_keys.size );
		if ( level.zombie_powerups[ a_keys[ n_index ] ].zombie_grabbable )
		{
			self thread zm_audio::create_and_play_dialog( "kill", "quant_bad" );
			[ [ level.quantum_bomb_play_player_effect_at_position_func ] ]( v_position );
			level zm_powerups::specific_powerup_drop( a_keys[ n_index ], v_position );
			return;
		}
		else
			arrayRemoveValue( a_keys, a_keys[ n_index ] );
		
	}
}

function quantum_bomb_random_weapon_powerup_result( v_position )
{
	self thread zm_audio::create_and_play_dialog( "kill", "quant_good" );
	[ [ level.quantum_bomb_play_player_effect_at_position_func ] ]( v_position );
	level zm_powerups::specific_powerup_drop( "random_weapon", v_position );
}

function quantum_bomb_random_bonus_or_lose_points_powerup_result( v_position )
{
	n_rand = randomInt( 10 );
	str_powerup = "bonus_points_team";
	switch ( n_rand )
	{
		case 0:
		case 1:
		{
			str_powerup = "lose_points_team";
			if ( isDefined( level.zombie_include_powerups[ str_powerup ] ) )
			{
				self thread zm_audio::create_and_play_dialog( "kill", "quant_bad" );
				break;
			}
		}
		case 2:
		case 3:
		case 4:
		{
			str_powerup = "bonus_points_player";
			if ( isDefined( level.zombie_include_powerups[ str_powerup ] ) )
				break;
			
		}
		default:
		{
			str_powerup = "bonus_points_team";
			break;
		}
	}
	[ [ level.quantum_bomb_play_player_effect_at_position_func ] ]( v_position );
	level zm_powerups::specific_powerup_drop( str_powerup, v_position );
}

// ============================== FUNCTIONALITY ==============================