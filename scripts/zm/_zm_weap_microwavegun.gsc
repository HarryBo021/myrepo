#using scripts\codescripts\struct;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\zm\_zm_weap_microwavegun.gsh;

#namespace zm_weap_microwavegun;

#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_DW_FX );
#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_EYES_DW_FX );
#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_LH_FX );
#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_EYES_LH_FX );
#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_UG_FX );
#precache( "fx", MICROWAVEGUN_ZAP_SHOCK_EYES_UG_FX );

REGISTER_SYSTEM_EX( "zm_weap_microwavegun", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "actor", 					MICROWAVEGUN_HIT_RESPONSE_CF, 			VERSION_SHIP, 	1, 	"int" );
	clientfield::register( "actor", 					MICROWAVEGUN_EXPAND_RESPONSE_CF, 		VERSION_SHIP, 	1, 	"int" );
	clientfield::register( "clientuimodel", 		MICROWAVEGUN_DPAD_ICON_CF, 				VERSION_SHIP, 	1, 	"int" );
	// # CLIENTFIELD REGISTRATION
	
	// # VARIABLES AND SETTINGS
	zombie_utility::set_zombie_var( "microwavegun_cylinder_radius", MICROWAVEGUN_CYLINDER_RADIUS );
	zombie_utility::set_zombie_var( "microwavegun_sizzle_range", MICROWAVEGUN_SIZZLE_RANGE );
	level._microwaveable_objects = [];
	// # VARIABLES AND SETTINGS
	
	// # REGISTER MICROWAVE WEAPONS
	level.a_zapgun_weapons = [];
	level.a_wavegun_weapons = [];
	register_microwavegun_weapon_for_level( getWeapon( MICROWAVEGUN_WEAPON ), &microwavegun_weapon_fired_cb, undefined, undefined, undefined, undefined, undefined, &microwavegun_weapon_pullout_cb, &microwavegun_weapon_putaway_cb, undefined, undefined );
	register_microwavegun_weapon_for_level( getWeapon( MICROWAVEGUN_UPGRADED_WEAPON ), &microwavegun_weapon_fired_cb, undefined, undefined, undefined, undefined, undefined, &microwavegun_weapon_pullout_cb, &microwavegun_weapon_putaway_cb, undefined, undefined );
	register_zapgun_weapon_for_level( getWeapon( ZAPGUN_WEAPON ), undefined, undefined, undefined, undefined, undefined, undefined, &zapgun_weapon_pullout_cb, &zapgun_weapon_putaway_cb, undefined, undefined );
	register_zapgun_weapon_for_level( getWeapon( ZAPGUN_LH_WEAPON ), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined );
	register_zapgun_weapon_for_level( getWeapon( ZAPGUN_UPGRADED_WEAPON ), undefined, undefined, undefined, undefined, undefined, undefined, &zapgun_weapon_pullout_cb, &zapgun_weapon_putaway_cb, undefined, undefined );
	register_zapgun_weapon_for_level( getWeapon( ZAPGUN_LH_UPGRADED_WEAPON ), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined );
	// # REGISTER MICROWAVE WEAPONS
	
	// # REGISTER FX
	level._effect[ "microwavegun_zap_shock_dw" ] 				= MICROWAVEGUN_ZAP_SHOCK_DW_FX;
	level._effect[ "microwavegun_zap_shock_eyes_dw" ] 		= MICROWAVEGUN_ZAP_SHOCK_EYES_DW_FX;
	level._effect[ "microwavegun_zap_shock_lh" ] 					= MICROWAVEGUN_ZAP_SHOCK_LH_FX;
	level._effect[ "microwavegun_zap_shock_eyes_lh" ] 		= MICROWAVEGUN_ZAP_SHOCK_EYES_LH_FX;
	level._effect[ "microwavegun_zap_shock_ug" ] 				= MICROWAVEGUN_ZAP_SHOCK_UG_FX;
	level._effect[ "microwavegun_zap_shock_eyes_ug" ] 		= MICROWAVEGUN_ZAP_SHOCK_EYES_UG_FX;
	// # REGISTER FX
	
	// # REGISTER CALLBACKS
	zm_spawner::register_zombie_damage_callback( 				&microwavegun_zombie_damage_response	 );
	zm_spawner::register_zombie_death_animscript_callback( 	&microwavegun_zombie_death_response		 );
	callback::on_spawned( &microwavegun_sound_thread );
	// # REGISTER CALLBACKS
	
	// # BEHAVIOR	
	ASM_REGISTER_NOTETRACK_HANDLER( "expand", &microwavegun_handle_death_notetracks_expand );
	ASM_REGISTER_NOTETRACK_HANDLER( "explode", &microwavegun_handle_death_notetracks_explode );
	// # BEHAVIOR	
}

function register_zapgun_weapon_for_level( ut_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined, ptr_weapon_first_raise_cb = undefined, ptr_weapon_charge_cb = undefined )
{	
	w_weapon = ( !isWeapon( ut_weapon ) ? getWeapon( ut_weapon ) : ut_weapon );
	
	w_weapon.ptr_weapon_fired_cb					= ptr_weapon_fired_cb;
	w_weapon.ptr_weapon_missile_fired_cb		= ptr_weapon_missile_fired_cb;
	w_weapon.ptr_weapon_grenade_fired_cb	= ptr_weapon_grenade_fired_cb;
	w_weapon.ptr_weapon_obtained_cb 			= ptr_weapon_obtained_cb;
	w_weapon.ptr_weapon_lost_cb 					= ptr_weapon_lost_cb;
	w_weapon.ptr_weapon_reloaded_cb 			= ptr_weapon_reloaded_cb;
	w_weapon.ptr_weapon_pullout_cb 				= ptr_weapon_pullout_cb;
	w_weapon.ptr_weapon_putaway_cb 			= ptr_weapon_putaway_cb;
	w_weapon.ptr_weapon_first_raise_cb 			= ptr_weapon_first_raise_cb;
	w_weapon.ptr_weapon_charge_cb 				= ptr_weapon_charge_cb;
	
	ARRAY_ADD( level.a_zapgun_weapons, w_weapon );
}

function register_microwavegun_weapon_for_level( ut_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined, ptr_weapon_first_raise_cb = undefined, ptr_weapon_charge_cb = undefined )
{	
	w_weapon = ( !isWeapon( ut_weapon ) ? getWeapon( ut_weapon ) : ut_weapon );
	
	w_weapon.ptr_weapon_fired_cb					= ptr_weapon_fired_cb;
	w_weapon.ptr_weapon_missile_fired_cb		= ptr_weapon_missile_fired_cb;
	w_weapon.ptr_weapon_grenade_fired_cb	= ptr_weapon_grenade_fired_cb;
	w_weapon.ptr_weapon_obtained_cb 			= ptr_weapon_obtained_cb;
	w_weapon.ptr_weapon_lost_cb 					= ptr_weapon_lost_cb;
	w_weapon.ptr_weapon_reloaded_cb 			= ptr_weapon_reloaded_cb;
	w_weapon.ptr_weapon_pullout_cb 				= ptr_weapon_pullout_cb;
	w_weapon.ptr_weapon_putaway_cb 			= ptr_weapon_putaway_cb;
	w_weapon.ptr_weapon_first_raise_cb 			= ptr_weapon_first_raise_cb;
	w_weapon.ptr_weapon_charge_cb 				= ptr_weapon_charge_cb;
	
	ARRAY_ADD( level.a_wavegun_weapons, w_weapon );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function microwavegun_weapon_fired_cb( w_weapon )
{
	self thread microwavegun_fired();
}

function microwavegun_weapon_pullout_cb( w_previous_weapon, w_new_weapon )
{
	self setActionSlot( 3, "altMode" );
	self clientfield::set_player_uimodel( MICROWAVEGUN_DPAD_ICON_CF, 1 );
	self.dpad_left_ammo_weapon = w_new_weapon;
}

function microwavegun_weapon_putaway_cb( w_previous_weapon, w_new_weapon )
{
	self setActionSlot( 3, "" );
	self clientfield::set_player_uimodel( MICROWAVEGUN_DPAD_ICON_CF, 0 );
	self.dpad_left_ammo_weapon = undefined;
}

function zapgun_weapon_pullout_cb( w_previous_weapon, w_new_weapon )
{
	self setActionSlot( 3, "altMode" );
	self clientfield::set_player_uimodel( MICROWAVEGUN_DPAD_ICON_CF, 1 );
	self.dpad_left_ammo_weapon = w_new_weapon.altWeapon;
}

function zapgun_weapon_putaway_cb( w_previous_weapon, w_new_weapon )
{
	self setActionSlot( 3, "" );
	self clientfield::set_player_uimodel( MICROWAVEGUN_DPAD_ICON_CF, 0 );
	self.dpad_left_ammo_weapon = undefined;
}

function microwavegun_zombie_damage_response( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( self is_microwavegun_dw_damage() )
	{
		self thread microwavegun_dw_zombie_hit_response_internal( str_means_of_death, w_weapon, e_attacker );
		return 1;
	}
	return 0;
}

function microwavegun_dw_zombie_hit_response_internal( str_means_of_death, w_weapon, e_attacker )
{
	e_attacker endon( "disconnect" );
	if ( !isDefined(self) || !isAlive( self ) )
		return;
	if ( IS_TRUE( self.isdog ) )
		self.a.nodeath = undefined;
	if ( IS_TRUE( self.is_traversing ) )
		self.deathAnim = undefined;
	
	self.skipAutoRagdoll = 1;
	self.microwavegun_dw_death = 1;
	self thread microwavegun_zap_death_fx( w_weapon );
	if ( isDefined( self.microwavegun_zap_damage_func ) )
	{
		self [ [ self.microwavegun_zap_damage_func ] ]( e_attacker );
		return;
	}
	else
		self doDamage( self.health + 666, self.origin, e_attacker );
	
	e_attacker zm_score::player_add_points( "death", "", "" );
	if ( randomIntRange( 0, 101 ) >= 75 )
		e_attacker thread zm_audio::create_and_play_dialog( "kill", "micro_dual" );
	
}

function microwavegun_zombie_death_response()
{
	if ( self enemy_killed_by_dw_microwavegun() )
	{
		if ( isDefined( self.attacker ) && isDefined( level.hero_power_update ) )
			level thread [ [ level.hero_power_update ] ]( self.attacker, self );
		
		return 1;
	}
	else if ( self enemy_killed_by_microwavegun() )
	{
		if ( isDefined( self.attacker ) && isDefined( level.hero_power_update ) )
			level thread [ [ level.hero_power_update ] ]( self.attacker, self );
		
		return 1;
	}
	return 0;
}

function microwavegun_sound_thread()
{
	self notify( "microwavegun_sound_thread" );
	self endon( "microwavegun_sound_thread" );
	self endon( "disconnect" );
	for ( ; ; )
	{
		result = self util::waittill_any_return( "grenade_fire", "death", "player_downed", "weapon_change", "grenade_pullback" );
		if ( !isDefined( result ) )
			continue;
		
		if ( isDefined( level.ptr_is_wavegun_weapon ) )
			b_microwavegun = [ [ level.ptr_is_wavegun_weapon ] ]( self getCurrentWeapon() );
		else
			b_microwavegun = ( ( self getCurrentWeapon() == getWeapon( MICROWAVEGUN_WEAPON ) || self getCurrentWeapon() == getWeapon( MICROWAVEGUN_UPGRADED_WEAPON ) ) ? 1 : 0 );
		
		if ( result == "weapon_change" || result == "grenade_fire" && b_microwavegun )
		{
			self playLoopSound( "tesla_idle", .25 );
			continue;
		}
		self notify( "weap_away" );
		self stopLoopSound( .25 );
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function microwavegun_fired()
{
	if ( !isDefined( level.microwavegun_sizzle_enemies ) )
	{
		level.microwavegun_sizzle_enemies = [];
		level.microwavegun_sizzle_vecs = [];
	}
	self microwavegun_get_enemies_in_range();
	level.microwavegun_network_choke_count = 0;
	for ( i = 0; i < level.microwavegun_sizzle_enemies.size; i++ )
	{
		microwavegun_network_choke();
		level.microwavegun_sizzle_enemies[ i ] thread microwavegun_sizzle_zombie( self, i );
	}
	level.microwavegun_sizzle_enemies = [];
	level.microwavegun_sizzle_vecs = [];
}

function microwavegun_network_choke()
{
	level.microwavegun_network_choke_count++;
	if ( !level.microwavegun_network_choke_count % 10 )
	{
		util::wait_network_frame();
		util::wait_network_frame();
		util::wait_network_frame();
	}
}

function microwavegun_get_enemies_in_range()
{
	v_view_pos = self getWeaponMuzzlePoint();
	a_microwave_list = [];
	
	a_zombies = util::get_array_of_closest( v_view_pos, zombie_utility::get_round_enemy_array(), undefined, undefined, level.zombie_vars[ "microwavegun_sizzle_range" ] );
	a_objects = util::get_array_of_closest( v_view_pos, level._microwaveable_objects, undefined, undefined, level.zombie_vars[ "microwavegun_sizzle_range" ] * 10 );
	
	a_microwave_list = arrayCombine( a_zombies, a_objects, 0, 0 );
	a_microwave_list = util::get_array_of_closest( v_view_pos, a_microwave_list );
	
	if ( !isDefined( a_microwave_list ) )
		return;
	
	for ( i = 0; i < a_microwave_list.size; i++ )
	{
		if ( !isDefined( a_microwave_list[ i ] ) || ( isAi( a_microwave_list[ i ] ) && !isAlive( a_microwave_list[ i ] ) ) )
			continue;
		
		if ( isAi( a_microwave_list[ i ] ) )
		{
			n_range = level.zombie_vars[ "microwavegun_sizzle_range" ];
			n_cylinder_radius = level.zombie_vars[ "microwavegun_cylinder_radius" ];
			n_sizzle_range_squared = n_range * n_range;
			n_cylinder_radius_squared = n_cylinder_radius * n_cylinder_radius;
			v_forward_view_angles = self getWeaponForwardDir();
			v_end_pos = v_view_pos + vectorScale( v_forward_view_angles, n_range );
		}
		else
		{
			n_range = level.zombie_vars[ "microwavegun_sizzle_range" ] * 10;
			n_cylinder_radius = level.zombie_vars[ "microwavegun_cylinder_radius" ] * 10;
			n_sizzle_range_squared = n_range * n_range;
			n_cylinder_radius_squared = n_cylinder_radius * n_cylinder_radius;
			v_forward_view_angles = self getWeaponForwardDir();
			v_end_pos = v_view_pos + vectorScale( v_forward_view_angles, n_range );
		}
		
		v_test_origin = a_microwave_list[ i ] getCentroid();
		n_test_range_squared = distanceSquared( v_view_pos, v_test_origin );
		if ( n_test_range_squared > n_sizzle_range_squared )
			return;
		
		v_normal = vectorNormalize( v_test_origin - v_view_pos );
		n_dot = vectorDot( v_forward_view_angles, v_normal );
		if ( 0 > n_dot )
			continue;
		
		v_radial_origin = pointOnSegmentNearestToPoint( v_view_pos, v_end_pos, v_test_origin );
		if ( distanceSquared( v_test_origin, v_radial_origin ) > n_cylinder_radius_squared )
			continue;
		
		if ( 0 == a_microwave_list[ i ] damageConeTrace( v_view_pos, self ) )
			continue;
		
		if ( isAi( a_microwave_list[ i ] ) )
		{
			level.microwavegun_sizzle_enemies[ level.microwavegun_sizzle_enemies.size ] = a_microwave_list[ i ];
			n_dist_mult = n_sizzle_range_squared - n_test_range_squared / n_sizzle_range_squared;
			v_sizzle_vec = vectorNormalize( v_test_origin - v_view_pos );
			if ( 5000 < n_test_range_squared )
				v_sizzle_vec = v_sizzle_vec + vectorNormalize( v_test_origin - v_radial_origin );
			
			v_sizzle_vec = ( v_sizzle_vec[ 0 ], v_sizzle_vec[ 1 ], abs( v_sizzle_vec[ 2 ] ) );
			v_sizzle_vec = vectorScale( v_sizzle_vec, 100 + 100 * n_dist_mult );
			level.microwavegun_sizzle_vecs[ level.microwavegun_sizzle_vecs.size ] = v_sizzle_vec;
			continue;
		}
		a_microwave_list[ i ] notify( "microwaved", self );
	}
}

function microwavegun_sizzle_zombie( e_player, index )
{
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( isDefined( self.microwavegun_sizzle_func ) )
	{
		self [ [ self.microwavegun_sizzle_func ] ]( e_player );
		return;
	}
	self.no_gib = 1;
	self.gibbed = 1;
	self.skipAutoRagdoll = 1;
	self.microwavegun_death = 1;
	self doDamage( self.health + 666, e_player.origin, e_player );
	if ( self.health <= 0 )
	{
		n_points = MICROWAVEGUN_LOW_POINTS;
		if ( !index )
			n_points = zm_score::get_zombie_death_player_points();
		else if ( 1 == index )
			n_points = MICROWAVEGUN_HIGH_POINTS;
		
		e_player zm_score::player_add_points( "thundergun_fling", n_points );
		b_instant_explode = 0;
		if ( IS_TRUE( self.isdog ) )
		{
			self.a.nodeath = undefined;
			b_instant_explode = 1;
		}
		if ( IS_TRUE( self.is_traversing ) || IS_TRUE( self.in_the_ceiling ) )
		{
			self.deathAnim = undefined;
			b_instant_explode = 1;
		}
		if ( b_instant_explode )
		{
			if ( isDefined( self.animName ) && self.animName != "astro_zombie" )
				self thread setup_microwavegun_vox( e_player );
			
			self clientfield::set( MICROWAVEGUN_EXPAND_RESPONSE_CF, 1 );
			self thread microwavegun_sizzle_death_ending();
		}
		else if ( isDefined( self.animName ) && self.animName != "astro_zombie" )
			self thread setup_microwavegun_vox( e_player, 6 );
		
		self clientfield::set( MICROWAVEGUN_HIT_RESPONSE_CF, 1 );
		self.nodeathragdoll = 1;
	}
}

function microwavegun_handle_death_notetracks_expand( e_behavior_tree_entity )
{
	e_behavior_tree_entity clientfield::set( MICROWAVEGUN_EXPAND_RESPONSE_CF, 1 );
}

function microwavegun_handle_death_notetracks_explode( e_behavior_tree_entity )
{
	e_behavior_tree_entity clientfield::set( MICROWAVEGUN_EXPAND_RESPONSE_CF, 0 );
	e_behavior_tree_entity thread microwavegun_sizzle_death_ending();
}

function microwavegun_sizzle_death_ending()
{
	if ( !isDefined( self ) )
		return;
	
	self ghost();
	wait .1;
	self zm_utility::self_delete();
}

function microwavegun_zap_get_shock_fx( w_weapon )
{
	if ( w_weapon == getWeapon( ZAPGUN_WEAPON ) )
		return level._effect[ "microwavegun_zap_shock_dw" ];
	else if ( w_weapon == getWeapon( ZAPGUN_LH_WEAPON ) )
		return level._effect[ "microwavegun_zap_shock_lh" ];
	else
		return level._effect[ "microwavegun_zap_shock_ug" ];
	
}

function microwavegun_zap_get_shock_eyes_fx( w_weapon )
{
	if ( w_weapon == getWeapon( ZAPGUN_WEAPON ) )
		return level._effect[ "microwavegun_zap_shock_eyes_dw" ];
	else if ( w_weapon == getWeapon( ZAPGUN_LH_WEAPON ) )
		return level._effect[ "microwavegun_zap_shock_eyes_lh" ];
	else
		return level._effect[ "microwavegun_zap_shock_eyes_ug" ];
	
}

function microwavegun_zap_head_gib( w_weapon )
{
	self endon( "death" );
	zm_net::network_safe_play_fx_on_tag( "microwavegun_zap_death_fx", 2, microwavegun_zap_get_shock_eyes_fx( w_weapon ), self, "j_eyeball_le" );
}

function microwavegun_zap_death_fx( w_weapon )
{
	str_tag = "j_spineupper";
	if ( IS_TRUE( self.isdog ) )
		str_tag = "j_spine1";
	
	zm_net::network_safe_play_fx_on_tag( "microwavegun_zap_death_fx", 2, microwavegun_zap_get_shock_fx( w_weapon ), self, str_tag );
	self playSound( "wpn_imp_tesla" );
	if ( IS_TRUE( self.head_gibbed ) )
		return;
	
	if ( isDefined( self.microwavegun_zap_head_gib_func ) )
		self thread [ [ self.microwavegun_zap_head_gib_func ] ]( w_weapon );
	else if ( "quad_zombie" != self.animName )
		self thread microwavegun_zap_head_gib( w_weapon );
	
}

function is_microwavegun_dw_damage()
{
	if ( isDefined( level.ptr_is_zapgun_weapon ) )
		return [ [ level.ptr_is_zapgun_weapon ] ]( self.damageweapon );
	
	return 0;
}

function enemy_killed_by_dw_microwavegun()
{
	return IS_TRUE( self.microwavegun_dw_death );
}

function is_microwavegun_damage()
{
	if ( isDefined( level.ptr_is_wavegun_weapon ) )
		return [ [ level.ptr_is_wavegun_weapon ] ]( getWeapon( self.damageweapon ) );
	
	return 0;
}

function enemy_killed_by_microwavegun()
{
	return IS_TRUE( self.microwavegun_death );
}

function setup_microwavegun_vox( e_player, n_wait_time = .05 )
{
	level notify( "force_end_microwave_vox" );
	level endon( "force_end_microwave_vox" );
	
	wait n_wait_time;
	if ( 50 > randomIntRange( 1, 100 ) && isDefined( e_player ) )
		e_player thread zm_audio::create_and_play_dialog( "kill", "micro_single" );
	
}

function add_microwaveable_object( e_ent )
{
	array::add( level._microwaveable_objects, e_ent, 0 );
}

function remove_microwaveable_object( e_ent )
{
	arrayRemoveValue( level._microwaveable_objects, e_ent );
}

// ============================== FUNCTIONALITY ==============================