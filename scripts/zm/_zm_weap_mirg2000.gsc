#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_mirg2000.gsh;

#namespace mirg2000;

REGISTER_SYSTEM_EX( "mirg2000", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", 			MIRG2000_PLANT_KILLER_CF, 							VERSION_SHIP, getMinBitCountForNum( 4 ), 	"int" );
	clientfield::register( "vehicle", 				MIRG2000_SPIDER_DEATH_FX_CF, 					VERSION_SHIP, 2, 										"int" );
	clientfield::register( "actor", 					MIRG2000_ENEMY_IMPACT_FX_CF, 					VERSION_SHIP, 2, 										"int" );
	clientfield::register( "vehicle", 				MIRG2000_ENEMY_IMPACT_FX_CF, 					VERSION_SHIP, 2, 										"int" );
	clientfield::register( "allplayers", 			MIRG2000_FIRE_BUTTON_HELD_SOUND_CF, 		VERSION_SHIP, 1, 										"int" );
	clientfield::register( "toplayer", 				MIRG2000_CHARGE_GLOW_CF, 							VERSION_SHIP, 2, 										"int" );
	// # CLIENTFIELD REGISTRATION
	
	// # VARIABLES AND SETTINGS
	level.n_mirg2000_bundle_index 				= 0;
	level.n_mirg2000_crawler_bundle_index 	= 0;
	level.w_mirg2000 									= getWeapon( MIRG2000_WEAPON );
	level.w_mirg2000_1 								= getWeapon( MIRG2000_1_WEAPON );
	level.w_mirg2000_2 								= getWeapon( MIRG2000_2_WEAPON );
	level.w_mirg2000_up 							= getWeapon( MIRG2000_UPGRADED_WEAPON );
	level.w_mirg2000_up_1 							= getWeapon( MIRG2000_UPGRADED_1_WEAPON );
	level.w_mirg2000_up_2 							= getWeapon( MIRG2000_UPGRADED_2_WEAPON );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_connect( &mirg2000_on_connect );
	// # REGISTER CALLBACKS
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function mirg2000_on_connect()
{
	self thread mirg2000_watch_for_fire();
	self thread mirg2000_charge_sounds_and_effects();
	self thread mirg2000_watch_weapon_change();
	self thread mirg2000_charge_fire_sounds();
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function is_wonder_weapon( w_weapon, str_type = "any" )
{
	if ( !isDefined( w_weapon ) )
		return 0;
	
	switch ( str_type )
	{
		case "any":
		{
			if ( w_weapon == level.w_mirg2000 || w_weapon == level.w_mirg2000_1 || w_weapon == level.w_mirg2000_2 || w_weapon == level.w_mirg2000_up || w_weapon == level.w_mirg2000_up_1 || w_weapon == level.w_mirg2000_up_2 )
				return 1;
			
			break;
		}
		case "default":
		{
			if ( w_weapon == level.w_mirg2000 || w_weapon == level.w_mirg2000_1 || w_weapon == level.w_mirg2000_2 )
				return 1;
			
			break;
		}
		case "default_charged_shot":
		{
			if ( w_weapon == level.w_mirg2000_1 || w_weapon == level.w_mirg2000_2 )
				return 1;
			
			break;
		}
		case "upgraded":
		{
			if ( w_weapon == level.w_mirg2000_up || w_weapon == level.w_mirg2000_up_1 || w_weapon == level.w_mirg2000_up_2 )
				return 1;
			
			break;
		}
		case "upgraded_charged_shot":
		{
			if ( w_weapon == level.w_mirg2000_up_1 || w_weapon == level.w_mirg2000_up_2 )
				return 1;
			
			break;
		}
		default:
		{
			if ( w_weapon == level.w_mirg2000 || w_weapon == level.w_mirg2000_1 || w_weapon == level.w_mirg2000_2 || w_weapon == level.w_mirg2000_up || w_weapon == level.w_mirg2000_up_1 || w_weapon == level.w_mirg2000_up_2 )
				return 1;
			
			break;
		}
	}
	return 0;
}

function mirg2000_get_range( b_use_charge_level = 0 )
{
	if ( self hasWeapon( level.w_mirg2000_up ) )
	{
		if ( b_use_charge_level )
		{
			if ( self.chargeShotLevel > 2 )
				n_range_sq = MIRG2000_CHARGE_2_RANGE;
			else
				n_range_sq = MIRG2000_CHARGE_1_RANGE;
			
		}
		else
			n_range_sq = MIRG2000_CHARGE_1_RANGE;
		
	}
	else if ( b_use_charge_level )
	{
		if ( self.chargeShotLevel > 2 )
			n_range_sq = MIRG2000_CHARGE_2_RANGE;
		else
			n_range_sq = MIRG2000_CHARGE_1_RANGE;
		
	}
	else
		n_range_sq = MIRG2000_CHARGE_1_RANGE;
	
	return n_range_sq;
}

function mirg2000_distance_check( v_start, v_end, n_range_sq, n_height = 72 )
{
	n_height_diff = abs( v_end[ 2 ] - v_start[ 2 ] );
	if ( distance2DSquared( v_start, v_end ) <= n_range_sq && n_height_diff <= n_height )
		return 1;
	else
		return 0;
	
}

function mirg2000_do_damage( e_player, v_pos )
{
	self DoDamage( ( e_player hasWeapon( level.w_mirg2000_up ) ? MIRG2000_UPGRADED_DAMAGE : MIRG2000_DAMAGE ), v_pos, e_player, e_player );
	self clientfield::set( MIRG2000_ENEMY_IMPACT_FX_CF, ( e_player hasWeapon( level.w_mirg2000_up ) ? 2 : 1 ) );
}

function is_mirg2000_damage( str_mod, w_weapon )
{
	return is_wonder_weapon( w_weapon ) && ( str_mod == "MOD_GRENADE" || str_mod == "MOD_GRENADE_SPLASH" );
}

function mirg2000_watch_weapon_change()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		str_notify = self util::waittill_any_return( "weapon_fired", "weapon_melee", "weapon_change", "reload", "reload_start", "disconnect" );
		w_current = self getCurrentWeapon();
		if ( is_wonder_weapon( w_current ) )
		{
			n_ammo_clip = self getWeaponAmmoClip( w_current );
			if ( n_ammo_clip == 0 || str_notify == "reload_start" )
				self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 3 );
			else
				self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 2 );
			
		}
		else if ( str_notify == "weapon_change" && !is_wonder_weapon( w_current ) )
			self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 3 );
		
	}
}

function mirg2000_charge_sounds_and_effects()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		w_current = self getCurrentWeapon();
		if ( is_wonder_weapon( w_current ) && self.chargeShotLevel > 1 )
		{
			b_expo_ammo = getDvarInt( "bg_chargeShotExponentialAmmoPerChargeLevel", 0 );
			if ( !b_expo_ammo )
			{
				n_ammoclip = self getWeaponAmmoClip( w_current );
				if ( self.chargeShotLevel > n_ammoclip )
					n_current_chargelevel = n_ammoclip;
				else
				{
					n_current_chargelevel = self.chargeShotLevel;
					self playSound( MIRG2000_CHARGE_SND + n_current_chargelevel );
				}
			}
			else
			{
				n_current_chargelevel = self.chargeShotLevel;
				self playSound( MIRG2000_CHARGE_SND + n_current_chargelevel );
			}
			switch ( n_current_chargelevel )
			{
				case 1:
				{
					self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 2 );
					break;
				}
				case 2:
				{
					self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 1 );
					self notify( "mirg2000_charge" );
					break;
				}
				case 3:
				{
					self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 0 );
					self notify( "mirg2000_charge" );
					break;
				}
				default:
				{
					self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 3 );
					break;
				}
			}
			while ( self.chargeShotLevel == n_current_chargelevel )
				wait .1;
			
			if ( self.chargeShotLevel == 0 && !self isReloading() )
				self clientfield::set_to_player( MIRG2000_CHARGE_GLOW_CF, 2 );
			
		}
		wait .1;
	}
}

function mirg2000_charge_fire_sounds()
{
	self endon( "disconnect" );
	self.b_mirg2000_charging = 0;
	while ( 1 )
	{
		if ( self util::attack_button_held() )
		{
			w_weapon = self getCurrentWeapon();
			if ( is_wonder_weapon( w_weapon ) && !self.b_mirg2000_charging )
			{
				self.b_mirg2000_charging = 1;
				self clientfield::set( MIRG2000_FIRE_BUTTON_HELD_SOUND_CF, 1 );
			}
		}
		else if ( !self util::attack_button_held() && self.b_mirg2000_charging )
		{
			self.b_mirg2000_charging = 0;
			self clientfield::set( MIRG2000_FIRE_BUTTON_HELD_SOUND_CF, 0 );
		}
		wait .05;
	}
}

function mirg2000_watch_for_fire()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_launcher_fire", e_grenade, w_weapon );
		if ( !is_wonder_weapon( w_weapon ) )
			continue;
		if ( !isDefined( e_grenade ) )
			continue;
		if ( !isDefined( self.chargeshotlevel ) )
			continue;
		
		n_clip = self getWeaponAmmoClip( self getCurrentWeapon() );
		n_chargeshotlevel = self mirg2000_set_ammo_get_charge_level( n_clip + 1 );
		e_grenade thread watch_mirg2000_fired( self, n_chargeshotlevel );
	}
}

function mirg2000_set_ammo_get_charge_level( n_clip )
{
	if ( getDvarInt( "bg_chargeShotExponentialAmmoPerChargeLevel", 0 ) != 0 )
		return self.chargeshotlevel;
	
	if ( n_clip >= self.chargeshotlevel )
	{
		n_ammo = n_clip - self.chargeshotlevel;
		self setWeaponAmmoClip( self getCurrentWeapon(), n_ammo );
		n_charge_level = self.chargeshotlevel;
	}
	else if ( n_clip > 1 && self.chargeshotlevel > n_clip )
	{
		self setWeaponAmmoClip( self getCurrentWeapon(), 0 );
		n_charge_level = n_clip;
	}
	else
		n_charge_level = n_clip;
	
	return n_charge_level;
}

function watch_mirg2000_fired( e_player, n_chargeshotlevel )
{
	self waittill( "death" );
	v_position = self.origin;
	v_angles = self.angles;
	if ( !isDefined( v_position ) || !isDefined( v_angles ) )
		return;
	
	switch ( n_chargeshotlevel )
	{
		case 1:
		{
			e_player thread mirg2000_explode( v_position );
			break;
		}
		case 2:
		{
			e_player thread mirg2000_aoe_effect( v_position, n_chargeshotlevel );
			break;
		}
		case 3:
		{
			e_player thread mirg2000_aoe_effect( v_position, n_chargeshotlevel );
			break;
		}
		default:
		{
			e_player thread mirg2000_explode( v_position );
			break;
		}
	}
}

function mirg2000_aoe_effect( v_position, n_chargeshotlevel )
{
	self endon( "disconnect" );
	v_pos = getClosestPointOnNavMesh( v_position, 80 );
	if ( isDefined( v_pos ) )
	{
		e_model = util::spawn_model( "tag_origin", v_pos );
		e_model endon( "death" );
		if ( self hasWeapon( level.w_mirg2000_up ) )
			n_clientfield = n_chargeshotlevel + 1;
		else
			n_clientfield = n_chargeshotlevel - 1;
		
		e_model clientfield::set( MIRG2000_PLANT_KILLER_CF, n_clientfield );
		e_model thread mirg2000_aoe_countdown( self );
		self thread mirg2000_aoe_effect_ai_loop( v_pos, e_model );
		e_model waittill( "mirg2000_aoe_over" );
		e_model clientfield::set( MIRG2000_PLANT_KILLER_CF, 0 );
		wait .1;
		e_model delete();
	}
}

function mirg2000_aoe_countdown( e_player )
{
	self endon( "death" );
	e_player endon( "disconnect" );
	w_weapon = e_player getCurrentWeapon();
	if ( is_wonder_weapon( w_weapon, "upgraded" ) )
		n_timeout = e_player.chargeShotLevel * MIRG2000_UPGRADED_AOE_DURATION_PER_CHARGE;
	else
		n_timeout = e_player.chargeShotLevel * MIRG2000_AOE_DURATION_PER_CHARGE;
	
	wait n_timeout;
	self notify( "mirg2000_aoe_over" );
}

function mirg2000_aoe_effect_ai_loop( v_pos, e_model )
{
	self endon( "disconnect" );
	e_model endon( "mirg2000_aoe_over" );
	n_kills = 0;
	n_range_sq = self mirg2000_get_range( 1 );
	w_weapon = self getCurrentWeapon();
	if( is_wonder_weapon( w_weapon, "upgraded" ) )
		e_model.n_kills = MIRG2000_UPGRADED_AOE_MAX_KILLS;
	
	e_model.n_kills = MIRG2000_AOE_MAX_KILLS;
	while ( 1 )
	{
		a_ai_zombies = getAITeamArray( level.zombie_team );
		foreach ( ai_zombie in a_ai_zombies )
		{
			if ( isAlive( ai_zombie ) && !isDefined( ai_zombie.b_mirg2000_trap_death ) && !IS_TRUE( ai_zombie.thrasherConsumed ) )
			{
				if ( !IS_TRUE( ai_zombie.b_skull_trapped ) && mirg2000_distance_check( ai_zombie.origin, v_pos, n_range_sq ) )
				{
					self thread mirg2000_aoe_hit_ai( ai_zombie, v_pos );
					n_kills++;
					if ( n_kills >= e_model.n_kills )
						e_model notify( "mirg2000_aoe_over" );
					
					if ( !IS_TRUE( ai_zombie.b_is_thrasher ) && !IS_TRUE( ai_zombie.b_is_spider ) )
						wait .5;
					
				}
			}
		}
		wait .25;
	}
}

function mirg2000_aoe_hit_ai( e_ai_zombie, v_pos )
{
	self endon( "disconnect" );
	e_ai_zombie endon( "death" );
	if ( self hasWeapon( level.w_mirg2000_up ) )
		e_grenade = magicBullet( level.w_mirg2000_up, v_pos, e_ai_zombie getCentroid() );
	else
		e_grenade = magicBullet( level.w_mirg2000, v_pos, e_ai_zombie getCentroid() );
	
	if ( isDefined( e_grenade ) )
	{
		e_grenade thread watch_mirg2000_fired( self, 1 );
		wait .5;
		self thread mirg2000_spread_damage( e_ai_zombie );
	}
}

function mirg2000_explode( v_position )
{
	self endon( "disconnect" );
	a_ai_zombies = getAITeamArray( level.zombie_team );
	if ( !a_ai_zombies.size )
		return;
	
	n_range_sq = self mirg2000_get_range();
	n_mirg_spread_count = 0;
	ai_closest_zombie = arrayGetClosest( v_position, a_ai_zombies );
	if ( mirg2000_distance_check( ai_closest_zombie.origin, v_position, n_range_sq ) && !IS_TRUE( ai_closest_zombie.b_mirg2000_trap_death ) )
	{
		self thread mirg2000_spread_damage( ai_closest_zombie );
		arrayRemoveValue( a_ai_zombies, ai_closest_zombie );
		n_mirg_spread_count++;
	}
	foreach ( e_ai_zombie in a_ai_zombies )
	{
		if ( isAlive( e_ai_zombie ) && !isDefined( e_ai_zombie.b_mirg2000_trap_death ) )
		{
			if ( mirg2000_distance_check( e_ai_zombie.origin, v_position, n_range_sq ) && n_mirg_spread_count < 1 )
			{
				self thread mirg2000_spread_damage( e_ai_zombie );
				if ( !IS_TRUE( e_ai_zombie.b_is_thrasher) )
					n_mirg_spread_count++;
				
				if ( !IS_TRUE( e_ai_zombie.b_is_thrasher ) && !IS_TRUE( e_ai_zombie.b_is_spider ) )
					wait 1;
				
			}
		}
	}
}

function mirg2000_spread_damage( e_ai_zombie )
{
	self endon( "disconnect" );
	e_ai_zombie endon( "death" );
	if ( IS_TRUE( e_ai_zombie.b_is_thrasher ) )
	{
		if ( !IS_TRUE( e_ai_zombie.b_spore_stunned ) )
		{
			foreach ( e_spore in e_ai_zombie.thrasherSpores )
			{
				if ( e_spore.health > 0 )
				{
					e_target_spore = e_spore;
					break;
				}
			}
			if ( isDefined( e_ai_zombie.maxhealth ) && isDefined( e_target_spore ) )
			{
				switch ( self.chargeshotlevel )
				{
					case 1:
					{
						e_ai_zombie doDamage( e_target_spore.maxhealth / 2, e_ai_zombie getTagOrigin( e_target_spore.tag ), self );
						e_ai_zombie thread mirg2000_destroy_thrasher_spore( 1.5 );
						break;
					}
					case 2:
					{
						e_ai_zombie doDamage( e_target_spore.maxhealth / 2, e_ai_zombie getTagOrigin( e_target_spore.tag ), self );
						e_ai_zombie thread mirg2000_destroy_thrasher_spore( .75 );
						break;
					}
					case 3:
					{
						e_ai_zombie doDamage( e_target_spore.maxhealth / 2, e_ai_zombie getTagOrigin( e_target_spore.tag ), self );
						e_ai_zombie thread mirg2000_destroy_thrasher_spore( .5 );
						break;
					}
					default:
					{
						e_ai_zombie doDamage( e_target_spore.maxhealth / 2, e_ai_zombie getTagOrigin( e_target_spore.tag ), self );
						e_ai_zombie thread mirg2000_destroy_thrasher_spore( 1.5 );
						return;
					}
				}
			}
		}
		return;
	}
	if ( e_ai_zombie.b_mirg2000_trap_death !== 1 && !IS_TRUE( e_ai_zombie.b_skull_trapped ) && !IS_TRUE( e_ai_zombie.b_thrasher_spawning ) && !IS_TRUE( e_ai_zombie.thrasherConsumed ) )
	{
		e_ai_zombie ai::set_ignoreall( 1 );
		e_ai_zombie.b_mirg2000_trap_death = 1;
		e_ai_zombie notify( "mirg2000_killed" );
		if ( !IS_TRUE( e_ai_zombie.b_is_spider ) )
		{
			if ( zm_utility::is_player_valid( self ) )
				self notify( "mirg2000_kill" );
			
			e_ai_zombie.ignore_game_over_death = 1;
			e_ai_zombie mirg2000_trap_zombie( ( IS_TRUE( e_ai_zombie.missinglegs ) ? 1 : 0 ) );
			
			self thread mirg2000_chain_ai( e_ai_zombie );
		}
		if ( IS_TRUE( e_ai_zombie.b_is_spider ) )
			e_ai_zombie clientfield::set( MIRG2000_SPIDER_DEATH_FX_CF, ( self hasWeapon( level.w_mirg2000_up ) ? 2 : 1 ) );
			else
		
		if( !IS_TRUE( e_ai_zombie.b_is_spider ) )
			level thread zm_spawner::zombie_death_points( e_ai_zombie.origin, "MOD_EXPLOSIVE", "head", self, e_ai_zombie );
		
		e_ai_zombie thread zombie_utility::zombie_gut_explosion();
		e_ai_zombie doDamage( e_ai_zombie.health, e_ai_zombie.origin, self );
	}
}

function mirg2000_chain_ai( e_ai_zombie_initial )
{
	a_ai_zombies = getAITeamArray( level.zombie_team );
	v_start_origin = e_ai_zombie_initial getCentroid();
	n_range_sq = self mirg2000_get_range();
	arrayRemoveValue( a_ai_zombies, e_ai_zombie_initial );
	foreach ( e_ai_zombie in a_ai_zombies )
	{
		if ( isAlive( e_ai_zombie ) && !IS_TRUE( e_ai_zombie.b_mirg2000_trap_death ) && mirg2000_distance_check( e_ai_zombie.origin, v_start_origin, n_range_sq ) )
		{
			e_ai_zombie mirg2000_do_damage( self, v_start_origin );
			util::wait_network_frame();
		}
	}
}

function mirg2000_trap_zombie( b_is_crawler )
{
	self endon( "death" );
	
	self.marked_for_death = 1;
	if ( b_is_crawler )
	{
		level.n_mirg2000_crawler_bundle_index++;
		if ( level.n_mirg2000_crawler_bundle_index > 2 )
			level.n_mirg2000_crawler_bundle_index = 1;
		
		if ( isAlive( self ) && !self isRagdoll() )
			self scene::play( "p7_fxanim_zm_island_mirg_trap_crawl_" + level.n_mirg2000_crawler_bundle_index + "_bundle", self );
		
	}
	else
	{
		level.n_mirg2000_bundle_index++;
		if ( level.n_mirg2000_bundle_index > 5 )
			level.n_mirg2000_bundle_index = 1;
		
		if ( isAlive( self ) && !self isRagdoll() )
			self scene::play( "p7_fxanim_zm_island_mirg_trap_" + level.n_mirg2000_bundle_index + "_bundle", self );
		
	}
}

function mirg2000_destroy_thrasher_spore( n_stun_time = 1 )
{
	self endon( "death" );
	self.b_spore_stunned = 1;
	wait n_stun_time;
	self.b_spore_stunned = 0;
}

// ============================== FUNCTIONALITY ==============================