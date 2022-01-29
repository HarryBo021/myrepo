#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\zm\_util;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_tomahawk.gsh;

#precache( "fx", TOMAHAWK_CHARGE_FX );
#precache( "fx", TOMAHAWK_CHARGE_FX_UG );
#precache( "fx", TOMAHAWK_TRAIL_FX );
#precache( "fx", TOMAHAWK_TRAIL_FX_UG );
#precache( "fx", TOMAHAWK_CHARGED_TRAIL_FX );
#precache( "fx", TOMAHAWK_IMPACT_FX );
#precache( "fx", TOMAHAWK_IMPACT_UG_FX );

#namespace hb21_zm_weap_tomahawk; 

REGISTER_SYSTEM( "hb21_zm_weap_tomahawk", &__init__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{	
	level.a_tomahawk_weapons = [];

	clientfield::register( "clientuimodel", "tomahawk_in_use", 					VERSION_SHIP, 2, "int" );
	// clientfield::register( "toplayer", "upgraded_tomahawk_in_use", 	VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", 	"play_tomahawk_hit_sound", 	VERSION_SHIP, 1, "int" );
	
	callback::on_spawned( &tomahawk_on_player_spawned );
	
	level thread tomahawk_pickup();
	
	zm_powerups::set_weapon_ignore_max_ammo( getWeapon( TOMAHAWK_WEAPON ) );
	zm_powerups::set_weapon_ignore_max_ammo( getWeapon( TOMAHAWK_UPGRADED_WEAPON ) );
	
	level.a_tomahawk_pickup_funcs = [];
	
	zm_utility::register_tactical_grenade_for_level( TOMAHAWK_WEAPON );
	zm_utility::register_tactical_grenade_for_level( TOMAHAWK_UPGRADED_WEAPON );
	
	register_tomahawk_weapon_for_level( TOMAHAWK_WEAPON, &tomahawk_obtained, &tomahawk_lost );
	register_tomahawk_weapon_for_level( TOMAHAWK_UPGRADED_WEAPON, &tomahawk_obtained, &tomahawk_lost );
}

function register_tomahawk_weapon_for_level( ut_weapon, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined )
{	
	w_weapon = ( !isWeapon( ut_weapon ) ? getWeapon( ut_weapon ) : ut_weapon );
	
	w_weapon.ptr_weapon_obtained_cb 			= ptr_weapon_obtained_cb;
	w_weapon.ptr_weapon_lost_cb 					= ptr_weapon_lost_cb;
	
	ARRAY_ADD( level.a_tomahawk_weapons, w_weapon );
}

function tomahawk_obtained( w_weapon )
{
	self clientfield::set_player_uimodel( "tomahawk_in_use", ( w_weapon.name == TOMAHAWK_UPGRADED_WEAPON ? 2 : 1 ) );
}

function tomahawk_lost( w_weapon )
{
	self clientfield::set_player_uimodel( "tomahawk_in_use", 0 );
}

function tomahawk_on_player_spawned()
{
	self thread tomahawk_watch_for_throw();
	self thread tomahawk_watch_for_charge();
}

function tomahawk_watch_for_throw()
{
	self endon( "death_or_disconnect" );
	self notify( "tomahawk_watch_for_throw" );
	self endon( "tomahawk_watch_for_throw" );
	
	while ( isDefined( self ) )
	{
		self waittill( "grenade_fire", e_grenade, w_weapon, n_cooktime );
		
		if ( !isSubStr( w_weapon.name, "tomahawk" ) )
			continue;
		
		e_grenade.low_level_instant_kill_charge = 1;
		
		self notify( "throwing_tomahawk" );
		
		if ( isDefined( self.n_tomahawk_cooking_time ) )
			e_grenade.n_cookedtime = e_grenade.birthtime - self.n_tomahawk_cooking_time;
		else
			e_grenade.n_cookedtime = 0;
		
		self thread tomahawk_watch_for_time_out( e_grenade );
		self thread tomahawk_thrown( e_grenade );
	}
}

function tomahawk_watch_for_charge()
{
	self endon( "death_or_disconnect" );
	self notify( "tomahawk_watch_for_charge" );
	self endon( "tomahawk_watch_for_charge" );
	
	while ( isDefined( self ) )
	{
		self waittill( "grenade_pullback", w_weapon );
		
		if ( !isSubStr( w_weapon.name, "tomahawk" ) )
			continue;
		
		self thread tomahawk_watch_for_grenade_cancel();
		self thread tomahawk_play_charge_fx();
		
		self.n_tomahawk_cooking_time = getTime();
		
		self util::waittill_either( "grenade_fire", "grenade_throw_cancelled" );
		
		WAIT_SERVER_FRAME;
		
		self.n_tomahawk_cooking_time = undefined;
	}
}

function tomahawk_watch_for_grenade_cancel()
{
	self endon( "death_or_disconnect" );
	self endon( "grenade_fire" );
	
	waitTillFrameEnd;
	while ( self isThrowingGrenade() )
		WAIT_SERVER_FRAME;
	
	self notify( "grenade_throw_cancelled" );
}

function tomahawk_play_charge_fx()
{
	self endon( "death_or_disconnect" );
	self endon( "grenade_fire" );
	
	waitTillFrameEnd;
	n_time_to_pulse = 1000;
	while ( isDefined( self ) )
	{
		n_time = getTime() - self.n_tomahawk_cooking_time;
		w_current_tomahawk_weapon = self zm_utility::get_player_tactical_grenade();
		if ( n_time >= n_time_to_pulse )
		{
			if ( w_current_tomahawk_weapon.name == TOMAHAWK_UPGRADED_WEAPON )
				playFxOnTag( TOMAHAWK_CHARGE_FX_UG, self, "tag_origin" );
			else
				playFxOnTag( TOMAHAWK_CHARGE_FX, self, "tag_origin" );
			
			n_time_to_pulse += 1000;
			self playRumbleOnEntity( "reload_small" );
		}
		if ( n_time_to_pulse > 2400 && w_current_tomahawk_weapon.name != TOMAHAWK_UPGRADED_WEAPON )
			return;
		else
		{
			if ( n_time_to_pulse >= 3400 )
				return;
			else
				WAIT_SERVER_FRAME;
			
		}
	}
}

function tomahawk_get_charge_power( e_player )
{
	e_player endon( "disconnect" );
	
	w_current_tomahawk_weapon = e_player zm_utility::get_player_tactical_grenade();
	
	if ( self.n_cookedtime > 1000 && self.n_cookedtime < 2000 )
	{
		if ( w_current_tomahawk_weapon.name == TOMAHAWK_UPGRADED_WEAPON )
			return 4.5;
		
		return 1.5;
	}
	else
	{
		if ( self.n_cookedtime > 2000 && self.n_cookedtime < 3000 )
		{
			if ( w_current_tomahawk_weapon.name == TOMAHAWK_UPGRADED_WEAPON )
				return 6;
			
			return 2;
		}
		else
		{
			if ( self.n_cookedtime >= 3000 && w_current_tomahawk_weapon.name != TOMAHAWK_UPGRADED_WEAPON )
				return 2;
			else
				if ( self.n_cookedtime >= 3000 )
					return 3;
				
			
		}
	}
	return 1;
}

function tomahawk_thrown( e_grenade )
{
	self endon( "disconnect" );
	e_grenade endon( "in_hellhole" );
	
	playFxOnTag( TOMAHAWK_CHARGED_TRAIL_FX, e_grenade, "tag_origin" );
	self clientfield::set_player_uimodel( "tomahawk_in_use", 0 );
	
	e_grenade util::waittill_either( "death", "time_out" );
	
	v_grenade_origin = e_grenade.origin;
	
	a_zombies = getAiSpeciesArray( "axis", "all" );
	
	n_grenade_charge_power = e_grenade tomahawk_get_charge_power( self );
	
	a_zombies = util::get_array_of_closest( v_grenade_origin, a_zombies, undefined, undefined, TOMAHAWK_RANGE );
	a_powerups = util::get_array_of_closest( v_grenade_origin, level.active_powerups, undefined, undefined, TOMAHAWK_RANGE );
	
	if ( isDefined( level.a_tomahawk_pickup_funcs ) )
	{
		foreach( ptr_tomahawk_func in level.a_tomahawk_pickup_funcs )
		{
			if ( [ [ ptr_tomahawk_func ] ]( e_grenade, n_grenade_charge_power ) )
				return;
			
		}
	}
	if ( isDefined( a_powerups ) && a_powerups.size > 0 )
	{
		e_tomahawk = tomahawk_spawn( v_grenade_origin, n_grenade_charge_power );
		e_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		foreach ( e_powerup in a_powerups )
		{
			e_powerup.origin = v_grenade_origin;
			e_powerup linkTo( e_tomahawk );
			e_tomahawk.a_has_powerup = a_powerups;
		}
		self thread tomahawk_return_player( e_tomahawk, 0 );
		return;
	}
	if ( !isDefined( a_zombies ) )
	{
		e_tomahawk = tomahawk_spawn( v_grenade_origin, n_grenade_charge_power );
		e_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		self thread tomahawk_return_player( e_tomahawk, 0 );
		return;
	}
	else
	{
		foreach ( ai_zombie in a_zombies )
			ai_zombie.b_hit_by_tomahawk = 0;
		
	}
	if ( isDefined( a_zombies[ 0 ] ) && isAlive( a_zombies[ 0 ] ) )
	{
		v_zombiepos = a_zombies[ 0 ].origin;
		if ( distanceSquared( v_grenade_origin, v_zombiepos ) <= TOMAHAWK_DISTANCE_SQ_CHECK )
		{
			a_zombies[ 0 ] clientfield::set( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = tomahawk_calculate_damage( a_zombies[ 0 ], n_grenade_charge_power, e_grenade );
			a_zombies[ 0 ] doDamage( n_tomahawk_damage, v_grenade_origin, self, e_grenade, "none", "MOD_GRENADE", 0, getWeapon( TOMAHAWK_WEAPON ) );
			a_zombies[ 0 ].b_hit_by_tomahawk = 1;
			self zm_score::add_to_player_score( 10 );
			self thread tomahawk_ricochet_attack( v_grenade_origin, n_grenade_charge_power );
		}
		else
		{
			e_tomahawk = tomahawk_spawn( v_grenade_origin, n_grenade_charge_power );
			e_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
			self thread tomahawk_return_player( e_tomahawk, 0 );
		}
	}
	else
	{
		e_tomahawk = tomahawk_spawn( v_grenade_origin, n_grenade_charge_power );
		e_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		if ( isDefined( e_grenade ) )
			e_grenade delete();
		
		self thread tomahawk_return_player( e_tomahawk, 0 );
	}
}

function tomahawk_watch_for_time_out( e_grenade )
{
	self endon( "death_or_disconnect" );
	e_grenade endon( "death" );
	wait .5;
	e_grenade notify( "time_out" );
}

function tomahawk_ricochet_attack( v_grenade_origin, n_tomahawk_charge_power )
{
	self endon( "death_or_disconnect" );
	a_zombies = getAiSpeciesArray( "axis", "all" );
	a_zombies = util::get_array_of_closest( v_grenade_origin, a_zombies, undefined, undefined, TOMAHAWK_RANGE );
	a_zombies = array::reverse( a_zombies );
	if ( !isDefined( a_zombies ) )
	{
		e_tomahawk = tomahawk_spawn( v_grenade_origin, n_tomahawk_charge_power );
		e_tomahawk.n_grenade_charge_power = n_tomahawk_charge_power;
		self thread tomahawk_return_player( e_tomahawk, 0 );
		return;
	}
	e_tomahawk = tomahawk_spawn( v_grenade_origin, n_tomahawk_charge_power );
	e_tomahawk.n_grenade_charge_power = n_tomahawk_charge_power;
	self thread tomahawk_attack_zombies( e_tomahawk, a_zombies );
}

function tomahawk_attack_zombies( e_tomahawk, a_zombies )
{
	self endon( "disconnect" );
	if ( !isDefined( a_zombies ) )
	{
		self thread tomahawk_return_player( e_tomahawk, 0 );
		return;
	}
	if ( a_zombies.size <= 4 )
		n_attack_limit = a_zombies.size;
	else
		n_attack_limit = 4;
	
	i = 0;
	while ( i < n_attack_limit )
	{
		if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
		{
			tag = "j_head";
			if ( IS_TRUE( a_zombies[ i ].isdog ) )
				tag = "j_spine1";
			
			if ( isDefined( a_zombies[ i ].b_hit_by_tomahawk ) && !a_zombies[ i ].b_hit_by_tomahawk )
			{
				v_target = a_zombies[ i ] getTagOrigin( tag );
				e_tomahawk moveTo( v_target, .3 );
				e_tomahawk waittill( "movedone" );
				if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
				{
					if ( self.current_tactical_grenade.name == TOMAHAWK_UPGRADED_WEAPON )
						playFxOnTag( TOMAHAWK_IMPACT_UG_FX, a_zombies[ i ], tag );
					else
						playFxOnTag( TOMAHAWK_IMPACT_FX, a_zombies[ i ], tag );
					
					a_zombies[ i ] clientfield::set( "play_tomahawk_hit_sound", 1 );
					n_tomahawk_damage = tomahawk_calculate_damage( a_zombies[ i ], e_tomahawk.n_grenade_charge_power, e_tomahawk );
					a_zombies[ i ] doDamage( n_tomahawk_damage, e_tomahawk.origin, self, e_tomahawk, "none", "MOD_GRENADE", 0, getWeapon( TOMAHAWK_WEAPON ) );
					a_zombies[ i ].b_hit_by_tomahawk = 1;
					self zm_score::add_to_player_score( 10 );
				}
			}
		}
		wait .2;
		i++;
	}
	self thread tomahawk_return_player( e_tomahawk, n_attack_limit );
}

function tomahawk_return_player( e_tomahawk, n_zombies_hit )
{
	self endon( "disconnect" );
	self playLoopSound( "wpn_tomahawk_incoming" );
	n_dist = distance2dSquared( e_tomahawk.origin, self.origin );
	if ( !isDefined( n_zombies_hit ) )
		n_zombies_hit = 5;
	
	while ( n_dist > 4096 )
	{
		e_tomahawk moveTo( self getEye(), .25 );
		if ( n_zombies_hit < 5 )
		{
			self tomahawk_check_for_zombie( e_tomahawk );
			n_zombies_hit++;
		}
		wait .1;
		n_dist = distance2dSquared( e_tomahawk.origin, self getEye() );
	}
	if ( isDefined( e_tomahawk.a_has_powerup ) )
	{
		foreach( e_powerup in e_tomahawk.a_has_powerup )
		{
			if ( isDefined( e_powerup ) )
				e_powerup.origin = self.origin;
			
		}
	}
	e_tomahawk delete();
	self playSoundToPlayer( "wpn_tomahawk_catch_plr", self );
	self playSound( "wpn_tomahawk_catch_npc" );
	
	self clientfield::set_player_uimodel( "tomahawk_in_use", 3 );
	wait TOMAHAWK_RECHARGE_TIME;
	
	self playSoundToPlayer( "wpn_tomahawk_cooldown", self );
	self giveMaxAmmo( self.current_tactical_grenade );
	
	if ( self zm_utility::get_player_tactical_grenade().name == TOMAHAWK_UPGRADED_WEAPON )
		self clientfield::set_player_uimodel( "tomahawk_in_use", 2 );
	else if ( self zm_utility::get_player_tactical_grenade().name == TOMAHAWK_WEAPON )
		self clientfield::set_player_uimodel( "tomahawk_in_use", 1 );
	
}

function tomahawk_check_for_zombie( e_grenade )
{
	self endon( "disconnect" );
	e_grenade endon( "death" );
	
	a_zombies = getAiSpeciesArray( "axis", "all" );
	a_zombies = util::get_array_of_closest( e_grenade.origin, a_zombies, undefined, undefined, TOMAHAWK_RANGE );
	
	if ( isDefined( a_zombies[ 0 ] ) && distance2dSquared( e_grenade.origin, a_zombies[ 0 ].origin ) <= TOMAHAWK_DISTANCE_RETURN_CHECK )
	{
		if ( isDefined( a_zombies[ 0 ].b_hit_by_tomahawk ) && !a_zombies[ 0 ].b_hit_by_tomahawk )
			self tomahawk_hit_zombie( a_zombies[ 0 ], e_grenade );
		
	}
}

function tomahawk_hit_zombie( e_zombie, e_grenade )
{
	self endon( "disconnect" );
	if ( isDefined( e_zombie ) && isAlive( e_zombie ) )
	{
		str_tag = ( IS_TRUE( e_zombie.isdog ) ? "j_spine1" : "j_head" );
		
		v_target = e_zombie getTagOrigin( str_tag );
		e_grenade moveTo( v_target, .3 );
		e_grenade waittill( "movedone" );
		
		current_tactical_grenade = self zm_utility::get_player_tactical_grenade();
		
		if ( isDefined( e_zombie ) && isAlive( e_zombie ) )
		{
			if ( current_tactical_grenade.name == TOMAHAWK_UPGRADED_WEAPON )
				playFxOnTag( TOMAHAWK_IMPACT_UG_FX, e_zombie, str_tag );
			else
				playFxOnTag( TOMAHAWK_IMPACT_FX, e_zombie, str_tag );
			
			e_zombie clientfield::set( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = tomahawk_calculate_damage( e_zombie, e_grenade.n_grenade_charge_power, e_grenade );
			e_zombie doDamage( n_tomahawk_damage, e_grenade.origin, self, e_grenade, "none", "MOD_GRENADE", 0, getWeapon( TOMAHAWK_WEAPON ) );
			e_zombie.b_hit_by_tomahawk = 1;
			self zm_score::add_to_player_score( 10 );
		}
	}
}

function tomahawk_spawn( v_grenade_origin, n_charged )
{
	e_tomahawk = spawn( "script_model", v_grenade_origin );
	if ( self.current_tactical_grenade.name == TOMAHAWK_UPGRADED_WEAPON )
	{
		e_tomahawk setModel( getWeaponWorldModel( getWeapon( TOMAHAWK_UPGRADED_WEAPON ) ) );
		playFxOnTag( TOMAHAWK_TRAIL_FX_UG, e_tomahawk, "tag_origin" );
	}
	else
	{
		e_tomahawk setModel( getWeaponWorldModel( getWeapon( TOMAHAWK_WEAPON ) ) );
		playFxOnTag( TOMAHAWK_TRAIL_FX, e_tomahawk, "tag_origin" );
	}
	
	e_tomahawk thread tomahawk_spin();
	e_tomahawk playLoopSound( "wpn_tomahawk_spin" );
	
	if ( isDefined( n_charged ) && n_charged > 1 )
		playFxOnTag( TOMAHAWK_CHARGED_TRAIL_FX, e_tomahawk, "tag_origin" );
	
	e_tomahawk.low_level_instant_kill_charge = 1;
	return e_tomahawk;
}

function tomahawk_spin()
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self rotatePitch( 90, .2 );
		wait .15;
	}
}

function tomahawk_calculate_damage( e_target_zombie, n_tomahawk_power, e_tomahawk )
{
	if ( n_tomahawk_power > 2 )
		return e_target_zombie.health + 1;
	else
	{
		if ( level.round_number >= 10 && level.round_number < 13 && e_tomahawk.low_level_instant_kill_charge <= 3 )
		{
			e_tomahawk.low_level_instant_kill_charge += 1;
			return e_target_zombie.health + 1;
		}
		else
		{
			if ( level.round_number >= 13 && level.round_number < 15 && e_tomahawk.low_level_instant_kill_charge <= 2 )
			{
				e_tomahawk.low_level_instant_kill_charge += 1;
				return e_target_zombie.health + 1;
			}
			else
				return 1000 * n_tomahawk_power;
			
		}
	}
}

function tomahawk_pickup()
{
	s_pos_tomahawk = struct::get( "tomahawk_pickup_pos", "targetname" );
	if ( isDefined( s_pos_tomahawk ) )
	{
		e_tomahawk = spawn( "script_model", s_pos_tomahawk.origin );
		e_tomahawk setModel( getWeaponWorldModel( getWeapon( TOMAHAWK_WEAPON ) ) );
		e_tomahawk thread tomahawk_pickup_spin();
		e_tomahawk playLoopSound( "amb_tomahawk_swirl" );
		
		e_trigger = spawn( "trigger_radius_use", s_pos_tomahawk.origin, 0, 100, 150 );
		e_trigger useTriggerRequireLookAt();
		e_trigger triggerIgnoreTeam();
		e_trigger setHintString( "Press and hold ^3&&1^7 for Hell's Retriever" );
		e_trigger setCursorHint( "HINT_NOICON" );
		
		e_trigger thread tomahawk_pickup_trigger( TOMAHAWK_WEAPON );
	}
	
	s_pos_tomahawk = struct::get( "tomahawk_upgraded_pickup_pos", "targetname" );
	if ( isDefined( s_pos_tomahawk ) )
	{
		e_tomahawk = spawn( "script_model", s_pos_tomahawk.origin );
		e_tomahawk setModel( getWeaponWorldModel( getWeapon( TOMAHAWK_UPGRADED_WEAPON ) ) );
		e_tomahawk thread tomahawk_pickup_spin();
		e_tomahawk playLoopSound( "amb_tomahawk_swirl" );
		
		e_trigger = spawn( "trigger_radius_use", s_pos_tomahawk.origin, 0, 100, 150 );
		e_trigger useTriggerRequireLookAt();
		e_trigger triggerIgnoreTeam();
		e_trigger setHintString( "Press and hold ^3&&1^7 for Hell's Redeemer" );
		e_trigger setCursorHint( "HINT_NOICON" );
		
		e_trigger thread tomahawk_pickup_trigger( TOMAHAWK_UPGRADED_WEAPON );
	}
}

function tomahawk_pickup_trigger( str_tomahawk )
{
	w_tomahawk = getWeapon( str_tomahawk );
	w_tomahawk_flourish = getWeapon( str_tomahawk + "_flourish" );
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player hasWeapon( w_tomahawk ) )
			continue;
		
		e_player zm_weapons::weapon_give( w_tomahawk, 0, 0, 1, 0 );
		
		// if ( str_tomahawk == TOMAHAWK_UPGRADED_WEAPON )
		// 	e_player clientfield::set_player_uimodel( "tomahawk_in_use", 2 );
		// else
		// 	e_player clientfield::set_player_uimodel( "tomahawk_in_use", 1 );
		
		e_player giveWeapon( w_tomahawk_flourish );
		e_player switchToWeapon( w_tomahawk_flourish );
		
		e_player zm_utility::disable_player_move_states( 1 );
		e_player util::waittill_any( "death_or_disconnect", "player_downed", "weapon_change_complete" );
		e_player zm_utility::enable_player_move_states();
		
		e_player takeWeapon( w_tomahawk_flourish );
		
		e_player thread tomahawk_tutorial_hint( w_tomahawk );
	}
}

function tomahawk_pickup_spin()
{
	self endon( "death" );
	
	while ( isDefined( self ) )
	{
		self rotateYaw( 90, 1 );
		wait .15;
	}
}

function tomahawk_tutorial_hint( w_weapon )
{
	self endon( "disconnect" );
	
	h_client_hint = newClientHudElem( self );
	h_client_hint.alignx = "center";
	h_client_hint.aligny = "middle";
	h_client_hint.horzalign = "center";
	h_client_hint.vertalign = "bottom";
	h_client_hint.y = -120;
	h_client_hint.foreground = 1;
	h_client_hint.font = "default";
	h_client_hint.fontscale = 1.5;
	h_client_hint.alpha = 1;
	h_client_hint.color = ( 1, 1, 1 );
	h_client_hint setText( "Press [{+smoke}] to Throw the " + w_weapon.displayname );
	
	self util::waittill_any_timeout( 5, "throwing_tomahawk", "death" );
	
	h_client_hint destroy();
}