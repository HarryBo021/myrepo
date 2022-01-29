#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\throttle_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_weap_elemental_bow;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow", &__init__, &__main__, undefined )

function __init__()
{
	level.w_bow_base = getWeapon( "elemental_bow" );
	
	level.n_bow_mechz_damage_min = 1750;
	level.n_bow_mechz_damage_max = 3500;
	level.n_bow_mechz_damage_middle = level.n_bow_mechz_damage_max - level.n_bow_mechz_damage_min;
	level.w_bow_base_charged = getWeapon( "elemental_bow4" );
	clientfield::register( "toplayer", "elemental_bow" + "_ambient_bow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	callback::on_connect( &on_connect_bow_base );
	setdvar( "bg_chargeShotUseOneAmmoForMultipleBullets", 0 );
	setdvar( "bg_zm_dlc1_chargeShotMultipleBulletsForFullCharge", 2 );
	object = new throttle();
	[ [ object ] ]->__constructor();
	level.ai_bow_throttle = object;
	[ [ level.ai_bow_throttle ] ]->initialize( 6, .1 );
	
	thread peds();
}

function peds()
{
	a_array = getEntArray( "elemental_bow_pickup", "targetname" );
	if ( !isDefined( a_array ) || !isArray( a_array ) || a_array.size < 1 )
		return;
	
	foreach ( e_trig in a_array )
		e_trig thread pickup( getWeapon( e_trig.script_string ) );
		
}

function pickup( w_weapon )
{
	self setHintString( "Press and hold ^3&&1^7 to take " + w_weapon.displayname );
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player laststand::player_is_in_laststand() || IS_TRUE( e_player.intermission ) )
			continue;
		
		if ( e_player zm_utility::in_revive_trigger() )
			return 0;

		if ( IS_DRINKING( e_player.is_drinking ) )
			return 0;

		if ( !zm_utility::is_player_valid( e_player ) )
			return 0;
	
		e_player thread bow_pickup( w_weapon );
	}
}

function bow_pickup( w_weapon )
{
	self zm_weapons::weapon_give( w_weapon, undefined, undefined, undefined, true );
}

function __main__()
{
}

function on_connect_bow_base()
{
	self thread bow_base_wield_watcher( "elemental_bow" );
	self thread bow_base_fired_watcher( "elemental_bow", "elemental_bow4" );
	self thread bow_base_impact_watcher( "elemental_bow", "elemental_bow4", &bow_base_impact_explosion );
}

function bow_base_impact_explosion( weapon, v_position, radius, attacker, normal )
{
	str_bow = bow_base_get_bow_weapon( weapon.name );
	if ( weapon.name == "elemental_bow4" )
	{
		attacker clientfield::set( str_bow + "_arrow_impact_fx", 1 );
		a_zombies = array::get_all_closest( v_position, getAiTeamArray( level.zombie_team ), undefined, undefined, 128 );
		a_zombies = array::filter( a_zombies, 0, &is_bow_explosion_impact_valid, v_position );
		array::thread_all( a_zombies, &bow_launch_zombie, self, v_position );
	}
	else
		attacker clientfield::set( str_bow + "_arrow_impact_fx", 1 );
	
}

function is_bow_explosion_impact_valid( ai_enemy, impact_org )
{
	return isAlive( ai_enemy ) && !IS_TRUE( ai_enemy.b_is_bow_hit ) && bulletTracePassed( ai_enemy getCentroid(), impact_org + vectorScale( ( 0, 0, 1 ), 48 ), 0, undefined );
}

function bow_launch_zombie( e_player, impact_org )
{
	self endon( "death" );
	if ( self.archetype === "mechz" )
		return;
	
	self.b_is_bow_hit = 1;
	n_damage = 2233;
	if ( self.health > 2233 )
		self thread bow_base_do_knockdown( impact_org );
	else
	{
		self startRagdoll();
		n_dist = distance2d( self.origin, impact_org );
		n_launch_speed = ( 128 - n_dist ) / 128;
		v_norm = vectorNormalize( self getCentroid() - impact_org );
		if (v_norm[ 2 ] < .8 )
			v_norm = ( v_norm[ 0 ], v_norm[ 1 ], .8 );
		
		self launchRagdoll( ( v_norm * 96 ) * n_launch_speed );
		wait .1;
		self zm_spawner::zombie_explodes_intopieces( 0 );
	}
	if ( isDefined( self ) )
	{
		[ [ level.ai_bow_throttle ] ] -> waitInQueue( self );
		if ( isDefined( self ) )
		{
			self doDamage( n_damage, self.origin, e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_base_charged );
			self.b_is_bow_hit = 0;
		}
	}
}

function bow_base_wield_watcher( str_bow )
{
	self endon( "death" );
	w_bow = getWeapon( str_bow );
	while ( 1 )
	{
		self waittill( "weapon_change", wpn_new, wpn_old );
		if ( wpn_new === w_bow )
		{
			if ( !IS_TRUE( self.b_used_bow ) )
			{
				if (isDefined( self.hintelem ) )
				{
					self.hintelem setText( "" );
					self.hintelem destroy();
				}
				if (self isSplitScreen() )
					self thread zm_equipment::show_hint_text( "Press ^3[{+attack}]^7 to shoot\nHold ^3[{+attack}]^7 to shoot a charged shot\nCharged shots use extra arrows", 8, 1, 150 );
				else
					self thread zm_equipment::show_hint_text( "Press ^3[{+attack}]^7 to shoot\nHold ^3[{+attack}]^7 to shoot a charged shot\nCharged shots use extra arrows", 8 );
				
				self.b_used_bow = 1;
			}
			if ( isDefined( level.ptr_first_wield_bow ) )
				self thread [ [ level.ptr_first_wield_bow ] ]();
			
			self util::waittill_any_timeout( 1, "weapon_change_complete", "death" );
			self clientfield::set_to_player( str_bow + "_ambient_bow_fx", 1 );
		}
		else if ( wpn_old === w_bow )
		{
			self clientfield::set_to_player( str_bow + "_ambient_bow_fx", 0 );
			self stopRumble( "bow_draw_loop" );
		}
	}
}

function bow_base_fired_watcher( w_bow, w_bow_charged, ptr_bow_fired = undefined )
{
	self endon( "death" );
	if ( !isDefined( ptr_bow_fired ) )
		return;
	
	while ( 1 )
	{
		self waittill( "missile_fire", projectile, weapon );
		if ( isSubStr( weapon.name, w_bow ) )
			self thread [ [ ptr_bow_fired ] ]( projectile, weapon );
		
	}
}

function is_bow_damage( str_weapon_name )
{
	if ( !isDefined( str_weapon_name ) )
		return 0;
	
	if ( str_weapon_name == "elemental_bow" || str_weapon_name == "elemental_bow2" || str_weapon_name == "elemental_bow3" || str_weapon_name == "elemental_bow4" || str_weapon_name == "elemental_bow_demongate" || str_weapon_name == "elemental_bow_demongate2" || str_weapon_name == "elemental_bow_demongate3" || str_weapon_name == "elemental_bow_demongate4" || str_weapon_name == "elemental_bow_rune_prison" || str_weapon_name == "elemental_bow_rune_prison_ricochet" || str_weapon_name == "elemental_bow_rune_prison2" || str_weapon_name == "elemental_bow_rune_prison3" || str_weapon_name == "elemental_bow_rune_prison4" || str_weapon_name == "elemental_bow_rune_prison4_ricochet" || str_weapon_name == "elemental_bow_storm" || str_weapon_name == "elemental_bow_storm_ricochet" || str_weapon_name == "elemental_bow_storm2" || str_weapon_name == "elemental_bow_storm3" || str_weapon_name == "elemental_bow_storm4" || str_weapon_name == "elemental_bow_storm4_ricochet" || str_weapon_name == "elemental_bow_wolf_howl" || str_weapon_name == "elemental_bow_wolf_howl2" || str_weapon_name == "elemental_bow_wolf_howl3" || str_weapon_name == "elemental_bow_wolf_howl4" )
		return 1;
	
	return 0;
}

function is_bow_damage_charged( str_weapon_name )
{
	if ( !isDefined( str_weapon_name ) )
		return 0;
	
	if ( str_weapon_name == "elemental_bow4" || str_weapon_name == "elemental_bow_demongate4" || str_weapon_name == "elemental_bow_rune_prison4" || str_weapon_name == "elemental_bow_rune_prison4_ricochet" || str_weapon_name == "elemental_bow_storm4" || str_weapon_name == "elemental_bow_storm4_ricochet" || str_weapon_name == "elemental_bow_wolf_howl4" )
		return 1;
	
	return 0;
}

function is_bow_damage_type( str_weapon_name, str_bow_type )
{
	if ( !isDefined( str_weapon_name ) )
		return 0;
	
	switch ( str_bow_type )
	{
		case "elemental_bow":
		{
			if ( str_weapon_name == "elemental_bow" || str_weapon_name == "elemental_bow2" || str_weapon_name == "elemental_bow3" || str_weapon_name == "elemental_bow4" )
				return 1;
			
			break;
		}
		case "elemental_bow_demongate":
		{
			if ( str_weapon_name == "elemental_bow_demongate" || str_weapon_name == "elemental_bow_demongate2" || str_weapon_name == "elemental_bow_demongate3" || str_weapon_name == "elemental_bow_demongate4" )
				return 1;
			
			break;
		}
		case "elemental_bow_rune_prison":
		{
			if ( str_weapon_name == "elemental_bow_rune_prison" || str_weapon_name == "elemental_bow_rune_prison_ricochet" || str_weapon_name == "elemental_bow_rune_prison2" || str_weapon_name == "elemental_bow_rune_prison3" || str_weapon_name == "elemental_bow_rune_prison4" || str_weapon_name == "elemental_bow_rune_prison4_ricochet" )
				return 1;
			
			break;
		}
		case "elemental_bow_storm":
		{
			if ( str_weapon_name == "elemental_bow_storm" || str_weapon_name == "elemental_bow_storm_ricochet" || str_weapon_name == "elemental_bow_storm2" || str_weapon_name == "elemental_bow_storm3" || str_weapon_name == "elemental_bow_storm4" || str_weapon_name == "elemental_bow_storm4_ricochet" )
				return 1;
			
			break;
		}
		case "elemental_bow_wolf_howl":
		{
			if ( str_weapon_name == "elemental_bow_wolf_howl" || str_weapon_name == "elemental_bow_wolf_howl2" || str_weapon_name == "elemental_bow_wolf_howl3" || str_weapon_name == "elemental_bow_wolf_howl4" )
				return 1;
			
			break;
		}
		default:
		{
			/#
				assert( 0, "" );
			#/
			break;
		}
	}
	return 0;
}

function is_bow_weapon( str_weapon_name )
{
	if ( !isDefined( str_weapon_name ) )
		return 0;
	
	if ( str_weapon_name == "elemental_bow_demongate" || str_weapon_name == "elemental_bow_demongate2" || str_weapon_name == "elemental_bow_demongate3" || str_weapon_name == "elemental_bow_demongate4" || str_weapon_name == "elemental_bow_rune_prison" || str_weapon_name == "elemental_bow_rune_prison_ricochet" || str_weapon_name == "elemental_bow_rune_prison2" || str_weapon_name == "elemental_bow_rune_prison3" || str_weapon_name == "elemental_bow_rune_prison4" || str_weapon_name == "elemental_bow_rune_prison4_ricochet" || str_weapon_name == "elemental_bow_storm" || str_weapon_name == "elemental_bow_storm_ricochet" || str_weapon_name == "elemental_bow_storm2" || str_weapon_name == "elemental_bow_storm3" || str_weapon_name == "elemental_bow_storm4" || str_weapon_name == "elemental_bow_storm4_ricochet" || str_weapon_name == "elemental_bow_wolf_howl" || str_weapon_name == "elemental_bow_wolf_howl2" || str_weapon_name == "elemental_bow_wolf_howl3" || str_weapon_name == "elemental_bow_wolf_howl4" )
		return 1;
	
	return 0;
}

function bow_base_impact_watcher( w_bow, w_bow_charged, ptr_post_bow_impact = undefined )
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "projectile_impact", weapon, v_position, radius, e_projectile, normal );
		w_player_bow = bow_base_get_bow_weapon( weapon.name );
		if ( w_player_bow == w_bow || w_player_bow == w_bow_charged )
		{
			if ( w_player_bow != "elemental_bow" && w_player_bow != "elemental_bow_wolf_howl4" && isDefined( e_projectile.birthtime ) )
			{
				if ( ( getTime() - e_projectile.birthtime ) <= 150 )
					radiusDamage( v_position, 32, level.zombie_health, level.zombie_health, self, "MOD_UNKNOWN", weapon );
				
			}
			self thread bow_base_hit_mechz( w_player_bow, v_position );
			if ( isDefined( ptr_post_bow_impact ) )
				self thread [ [ ptr_post_bow_impact ] ]( weapon, v_position, radius, e_projectile, normal );
			
			self thread bow_base_do_impact_damage( weapon, v_position );
		}
	}
}

function bow_base_hit_mechz( w_player_bow, v_position )
{
	if ( w_player_bow === "elemental_bow_wolf_howl4" )
		return;
	
	array::thread_all( getAiArchetypeArray( "mechz" ), &bow_base_damage_mechz, self, w_player_bow, v_position );
}

function bow_base_damage_mechz( e_player, w_player_bow, v_position )
{
	b_in_bow_range = 0;
	n_bow_damage_multi = 0;
	b_is_charged_bow = 0;
	if ( !isSubStr( w_player_bow, "4" ) )
	{
		b_is_charged_bow = 1;
		n_distance_sq_max = 9216;
		n_bow_damage = 96;
		n_bow_damage_charge_multi = .25;
	}
	else if ( w_player_bow == "elemental_bow4" )
	{
		b_is_charged_bow = 1;
		n_distance_sq_max = 20736;
		n_bow_damage = 144;
		n_bow_damage_charge_multi = .1;
	}
	n_distance_sq_origin = distanceSquared( v_position, self.origin );
	n_distance_sq_neck = distanceSquared( v_position, self getTagOrigin( "j_neck" ) );
	if (n_distance_sq_origin < 1600 || n_distance_sq_neck < 2304 )
	{
		b_in_bow_range = 1;
		n_bow_damage_multi = 1;
	}
	else if ( b_is_charged_bow && ( n_distance_sq_origin < n_distance_sq_max || n_distance_sq_neck < n_distance_sq_max ) )
	{
		b_in_bow_range = 1;
		n_bow_damage_multi = 1 - n_bow_damage_charge_multi;
		n_bow_damage_multi = n_bow_damage_multi * ( ( sqrt( ( n_distance_sq_origin < n_distance_sq_neck ? n_distance_sq_origin : n_distance_sq_neck ) ) ) / n_bow_damage );
		n_bow_damage_multi = 1 - n_bow_damage_multi;
	}
	if ( b_in_bow_range )
	{
		n_bow_damage_final = level.mechz_health;
		if ( isDefined( level.ptr_bow_damage_final_override ) )
			n_bow_damage_final = math::clamp( n_bow_damage_final, 0, level.ptr_bow_damage_final_override );
		
		if ( w_player_bow == "elemental_bow" )
			n_mechz_health_percent = get_bow_mechz_damage( .15, .03 );
		else if ( w_player_bow == "elemental_bow4" )
			n_mechz_health_percent = get_bow_mechz_damage( .25, .12 );
		else if ( !isSubStr( w_player_bow, "4" ) )
			n_mechz_health_percent = .1;
		else
			n_mechz_health_percent = .35;
		
		n_mechz_final_damage = ( n_bow_damage_final * n_mechz_health_percent ) / .2;
		n_mechz_final_damage = n_mechz_final_damage * n_bow_damage_multi;
		self doDamage( n_mechz_final_damage, self.origin, e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_base );
	}
}

function get_bow_mechz_damage( n_mechz_health_min, n_mechz_health_max )
{
	if ( level.mechz_health < level.n_bow_mechz_damage_min )
		n_mechz_health_percent = n_mechz_health_min;
	else if ( level.mechz_health > level.n_bow_mechz_damage_max )
		n_mechz_health_percent = n_mechz_health_max;
	else
	{
		calc_mechz_health = level.mechz_health - level.n_bow_mechz_damage_min;
		n_health_remainder_percent = calc_mechz_health / level.n_bow_mechz_damage_middle;
		n_mechz_health_percent = n_mechz_health_min - ( ( n_mechz_health_min - n_mechz_health_max ) * n_health_remainder_percent );
	}
	return n_mechz_health_percent;
}

function bow_base_do_impact_damage( weapon, v_position )
{
	util::wait_network_frame();
	radiusDamage( v_position, 24, 1, 1, self, undefined, weapon );
}

function is_bow_impact_valid( ai_enemy )
{
	b_callback_result = 1;
	if ( isDefined( level.ptr_bow_impact_valid_override ) )
		b_callback_result = [ [ level.ptr_bow_impact_valid_override ] ]( ai_enemy );
	
	return isDefined( ai_enemy ) && isAlive( ai_enemy ) && !ai_enemy isRagdoll() && !IS_TRUE( ai_enemy.b_is_bow_hit ) && !IS_TRUE( ai_enemy.var_d3c478a0 ) && b_callback_result;
}

function bow_base_do_knockdown( bow_impact_origin )
{
	self endon( "death" );
	if ( !IS_TRUE( self.knockdown ) && !IS_TRUE( self.missinglegs ) )
	{
		self.knockdown = 1;
		self setPlayerCollision( 0 );
		impact_angles = bow_impact_origin - self.origin;
		impact_angles_norm = vectorNormalize( ( impact_angles[ 0 ], impact_angles[ 1 ], 0 ) );
		v_zombie_forward = vectorNormalize( ( anglesToForward( self.angles )[ 0 ], anglesToForward( self.angles )[ 1 ], 0 ) );
		v_zombie_right = vectorNormalize( ( anglesToRight( self.angles )[ 0 ], anglesToRight( self.angles )[ 1 ], 0 ) );
		v_dot = vectorDot( impact_angles_norm, v_zombie_forward );
		if ( v_dot >= .5 )
		{
			self.knockdown_direction = "front";
			self.getup_direction = "getup_back";
		}
		else if ( v_dot < .5 && v_dot > -.5 )
		{
			v_dot = vectorDot( impact_angles_norm, v_zombie_right );
			if ( v_dot > 0 )
			{
				self.knockdown_direction = "right";
				if ( math::cointoss() )
					self.getup_direction = "getup_back";
				else
					self.getup_direction = "getup_belly";
				
			}
			else
			{
				self.knockdown_direction = "left";
				self.getup_direction = "getup_belly";
			}
		}
		else
		{
			self.knockdown_direction = "back";
			self.getup_direction = "getup_belly";
		}
		wait 2.5;
		self setPlayerCollision( 1 );
		self.knockdown = 0;
	}
}

function bow_get_impact_pos_on_navmesh( v_hit_origin, str_weapon_name, e_impact_ent, n_impact_multi, ptr_bow_impact_bullet_override = undefined )
{
	v_ent_angles = anglesToForward( e_impact_ent.angles );
	if ( v_ent_angles[ 2 ] != -1 )
	{
		v_ent_angles_norm = vectorNormalize( v_ent_angles * -1 );
		v_bow_hit_org = v_hit_origin + ( v_ent_angles_norm * n_impact_multi );
	}
	else
		v_bow_hit_org = v_hit_origin + ( 0, 0, 1 );
	
	a_trace = bulletTrace( v_bow_hit_org, v_bow_hit_org - vectorScale( ( 0, 0, 1 ), 1000 ), 0, undefined );
	n_impact_multi = v_bow_hit_org[ 2 ] - a_trace[ "position" ][ 2 ];
	str_bow = bow_base_get_bow_weapon( str_weapon_name );
	if ( !isPointOnNavmesh( a_trace[ "position" ] ) )
	{
		e_impact_ent clientfield::set( str_bow + "_arrow_impact_fx", 1 );
		return undefined;
	}
	if ( n_impact_multi > 72 )
	{
		if ( isDefined( ptr_bow_impact_bullet_override ) )
			self thread [ [ ptr_bow_impact_bullet_override ] ]( str_weapon_name, v_bow_hit_org, a_trace[ "position" ] );
		else
			self thread bow_fake_fire_impact( str_weapon_name, v_bow_hit_org, a_trace[ "position" ] );
		
		return undefined;
	}
	e_impact_ent clientfield::set( str_bow + "_arrow_impact_fx", 1 );
	return a_trace[ "position" ];
}

function bow_fake_fire_impact( str_weapon_name, v_source, v_destination )
{
	wait .1;
	magicBullet( getWeapon( str_weapon_name ), v_source, v_destination, self );
}

function bow_base_get_bow_weapon( str_weapon_name )
{
	w_player_bow = str_weapon_name;
	if ( isSubStr( w_player_bow, "ricochet" ) )
	{
		w_bow_parent = strtok2( w_player_bow, "_ricochet" );
		w_player_bow = w_bow_parent[ 0 ];
	}
	if ( isSubStr( w_player_bow, "2" ) )
		w_player_bow = strtok( w_player_bow, "2" )[ 0 ];
	
	if ( isSubStr( w_player_bow, "3" ) )
		w_player_bow = strtok( w_player_bow, "3" )[ 0 ];
	
	return w_player_bow;
}
