/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           			Harry Bo21s Black Ops 3 Sliquifier						  ###
###                                                                   							  ###
###                                                                   							  ###
###========================================#*/
/*============================================

								CREDITS

=============================================
Raptroes
Hubashuba
WillJones1989
alexbgt
NoobForLunch
Symbo
TheIronicTruth
JAMAKINBACONMAN
Sethnorris
Yen466
Lilrifa
Easyskanka
Erthrock
Will Luffey
ProRevenge
DTZxPorter
Zeroy
JBird632
StevieWonder87
BluntStuffy
RedSpace200
Frost Iceforge
thezombieproject
Smasher248
JiffyNoodles
MadGaz
MZSlayer
AndyWhelen
Collie
ProGamerzFTW
Scobalula
Azsry
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
TheSkyeLord
===========================================*/
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\system_shared;
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
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_net;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_slipgun.gsh;

#precache( "fx", SLIPGUN_EXPLODE_FX );
#precache( "fx", SLIPGUN_SIZZLE_FX );

#namespace hb21_zm_weap_slipgun; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_slipgun", &__init__, &__main__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{		
	clientfield::register( "world", "add_sliquifier_to_box", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "slipgun_spot_active", VERSION_SHIP, 1, "int" );
	
	zombie_utility::set_zombie_var( 	"slipgun_reslip_max_spots", 		SLIPGUN_RESLIP_MAX_SPOTS );
	zombie_utility::set_zombie_var( 	"slipgun_reslip_rate", 					SLIPGUN_RESLIP_RATE );
	zombie_utility::set_zombie_var( 	"slipgun_max_kill_chain_depth", 	SLIPGUN_MAX_KILL_CHAIN_DEPTH );
	zombie_utility::set_zombie_var( 	"slipgun_max_kill_round", 			SLIPGUN_MAX_KILL_ROUND );
	zombie_utility::set_zombie_var( 	"slipgun_chain_radius", 				SLIPGUN_CHAIN_RADIUS );
	zombie_utility::set_zombie_var( 	"slipgun_chain_wait_min", 			SLIPGUN_CHAIN_WAIT_MIN );
	zombie_utility::set_zombie_var( 	"slipgun_chain_wait_max", 			SLIPGUN_CHAIN_WAIT_MAX );
	
	level.n_slippery_spot_count 			= 0;
	level.n_sliquifier_distance_checks 	= 0;
	
	callback::on_spawned( 																	&slipgun_on_player_spawned );
	
	zm_spawner::register_zombie_damage_callback( 							&slipgun_zombie_damage_response );
	zm_spawner::register_zombie_death_event_callback( 					&slipgun_zombie_death_response );
}

function __main__()
{
	level.n_slipgun_damage 				= slipgun_set_max_damage( level.zombie_vars[ "slipgun_max_kill_round" ] );
	level.n_slipgun_damage_mod 		= "MOD_PROJECTILE_SPLASH";
}

function slipgun_set_max_damage( n_round_number )
{
	n_zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
	while ( i <= n_round_number )
	{
		if ( i >= 10 )
		{
			n_old_health = n_zombie_health;
			n_zombie_health += int( n_zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
			if ( n_zombie_health < n_old_health )
				return n_old_health;
			
		}
		else
			n_zombie_health = int( n_zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
		
		i++;
	}
	return n_zombie_health;
}

function slipgun_on_player_spawned()
{
	self thread slipgun_wait_for_fired();
}

function slipgun_wait_for_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "slipgun_wait_for_fired" );
	self endon( "slipgun_wait_for_fired" );
	
	for ( ;; )
	{
		self waittill( "grenade_fire", e_grenade, w_weapon );

		switch( w_weapon.name )
		{
			case SLIPGUN_WEAPONFILE:
				e_grenade thread slipgun_grenade_logic( self, 0 );
				break;
			continue;
			case SLIPGUN_UPGRADED_WEAPONFILE:
				e_grenade thread slipgun_grenade_logic( self, 1 );
				break;
			continue;
		}
	}
}

function slipgun_grenade_logic( e_player, b_upgraded )
{
	v_start_pos = e_player getWeaponMuzzlePoint();
	
	self util::waittill_any( "grenade_bounce", "stationary", "death", "explode" );
	
	n_duration = ( IS_TRUE( b_upgraded ) ? 36 : 24 );
	
	if ( !isDefined( self ) )
		v_origin = v_start_pos;
	else
		v_origin = self.origin;
	
	thread slipgun_add_slippery_spot( self.origin, n_duration, v_start_pos );
}

function slipgun_add_slippery_spot( v_origin, n_duration, v_start_pos )
{
	wait .5;
	
	if ( !isDefined( v_origin ) && !isDefined( v_start_pos ) )
		return;
	
	playSoundAtPosition( "wpn_slipgun_splash", v_origin );
	
	ground = playerPhysicsTrace( v_origin + ( 0, 0, 80 ), v_origin - ( 0, 0, 1000 ) );
	
	level.n_slippery_spot_count++;
	
	thread slipgun_pool_of_goo( ground, n_duration );
	if ( !isDefined( level.a_slippery_spots ) )
		level.a_slippery_spots = [];
	
	level.a_slippery_spots[ level.a_slippery_spots.size ] = v_origin;
	n_radius = 60;
	n_height = 48;

	n_lifetime = n_duration;
	n_radius_sq = n_radius * n_radius;
	while ( n_lifetime > 0 )
	{
		n_old_lifetime = n_lifetime;
		
		_a612 = getPlayers();
		_k612 = getFirstArrayKey( _a612 );
		while ( isDefined( _k612 ) )
		{
			e_player = _a612[ _k612 ];
			if ( distance2dsquared( e_player.origin, ground ) < n_radius_sq && e_player slipgun_player_can_slip() )
			{
				should_be_slick = abs( e_player.origin[ 2 ] - ground[ 2 ] ) < n_height;
				if ( should_be_slick )
					e_player slipgun_player_set_slipping( ground, n_radius_sq );
				
			}
			n_lifetime = slipgun_slippery_spot_choke( n_lifetime );
			_k612 = getNextArrayKey( _a612, _k612 );
		}
			
		zombies = zombie_utility::get_round_enemy_array();
		if ( isDefined( zombies ) )
		{
			_a645 = zombies;
			_k645 = getFirstArrayKey( _a645 );
			while ( isDefined( _k645 ) )
			{
				e_zombie = _a645[ _k645 ];
				if ( isDefined( e_zombie ) )
				{					
					if ( distance2dsquared( e_zombie.origin, ground ) < n_radius_sq && e_zombie slipgun_zombie_can_slip() )
					{
						should_be_slick = abs( e_zombie.origin[ 2 ] - ground[ 2 ] ) < n_height;
						if ( should_be_slick )
							e_zombie slipgun_zombie_set_slipping();
						
					}
					n_lifetime = slipgun_slippery_spot_choke( n_lifetime );
				}
				_k645 = getNextArrayKey( _a645, _k645 );
			}
		}
		if ( n_old_lifetime == n_lifetime )
		{
			n_lifetime -= .05;
			WAIT_SERVER_FRAME;
		}
	}
	arrayRemoveValue( level.a_slippery_spots, v_origin, 0 );
	level.n_slippery_spot_count--;
}

function slipgun_slippery_spot_choke( n_lifetime )
{
	level.n_sliquifier_distance_checks++;
	if ( level.n_sliquifier_distance_checks >= 32 )
	{
		level.n_sliquifier_distance_checks = 0;
		n_lifetime -= .05;
		WAIT_SERVER_FRAME;
	}
	return n_lifetime;
}

function slipgun_pool_of_goo( v_origin, n_duration )
{
	e_fx_obj = spawn( "script_model", v_origin );
	e_fx_obj setModel( "tag_origin" );
	e_fx_obj clientfield::set( "slipgun_spot_active", 1 );
	
	wait n_duration;
	
	e_fx_obj clientfield::set( "slipgun_spot_active", 0 );
	e_fx_obj delete();
}

function slipgun_player_can_slip()
{
	if ( self laststand::player_is_in_laststand() || IS_TRUE( self.intermission ) )
		return 0;
		
	return 1;
}

function slipgun_zombie_can_slip()
{
	if ( !IS_TRUE( self.completed_emerging_into_playable_area ) )
		return 0;
	if ( IS_TRUE( self.barricade_enter ) )
		return 0;
	if ( IS_TRUE( self.in_the_ground ) )
		return 0;
	if ( IS_TRUE( self.is_traversing ) )
		return 0;
	if ( !isDefined( self.ai_state ) || self.ai_state != "zombie_think" )
		return 0;
	if ( IS_TRUE( self.is_leaping ) )
		return 0;
	
	return 1;
}

function slipgun_player_set_slipping( origin, radius )
{
	if ( isDefined( self ) )
		self thread slipgun_player_move_on_goo( origin, radius );
	
}

function slipgun_player_move_on_goo( v_origin, n_radius )
{
	if ( IS_TRUE( self.b_sliding_on_goo ) )
		return;
	
	self.b_sliding_on_goo = 1;
	self forceSlick( 1 );
	while ( distance2dSquared( self.origin, v_origin ) < n_radius )
		WAIT_SERVER_FRAME;
	
	self forceSlick( 0 );
	self.b_sliding_on_goo = undefined;
}

function slipgun_zombie_set_slipping()
{
	if ( isDefined( self ) )
		self thread slipgun_zombie_move_on_goo();
	
}

function slipgun_zombie_move_on_goo()
{
	self endon( "death" );
	if ( IS_TRUE( self.b_sliding_on_goo ) )
		return;
	
	self.b_sliding_on_goo = 1;
}

function slipgun_zombie_damage_response( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, v_direction_vec, str_tag_name, str_model_name, str_part_name, str_flags, e_inflictor, n_chargeLevel )
{
	if ( !self is_slipgun_damage( str_mod, w_weapon ) )
		return 0;
	
	self playSound( "wpn_slipgun_zombie_impact" );
	b_upgraded = w_weapon.name == SLIPGUN_UPGRADED_WEAPONFILE;
	self thread slipgun_zombie_1st_hit_response( w_weapon, e_player );
	
	playSoundAtPosition( "wpn_slipgun_zombie_impact", self.origin );
	
	return 1;
}

function slipgun_zombie_1st_hit_response( w_weapon, e_player )
{
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	
	self orientMode( "face default" );
	self.ignoreall = 1;
	self.gibbed = 1;
	
	if ( isAlive( self ) )
	{
		if ( !isDefined( self.n_goo_chain_depth ) )
			self.n_goo_chain_depth = 0;
		
		if ( self.health > 0 )
		{
			if ( e_player zm_powerups::is_insta_kill_active() )
				self.health = 1;
			
			self doDamage( level.n_slipgun_damage, self.origin, e_player, e_player, "none", level.n_slipgun_damage_mod, 0, w_weapon );
		}
	}
}

function is_slipgun_damage( str_mod, w_weapon )
{
	if ( isDefined( w_weapon ) && isDefined( w_weapon.name ) && ( w_weapon.name == SLIPGUN_WEAPONFILE || w_weapon.name == SLIPGUN_UPGRADED_WEAPONFILE ) )
		return 1;
	
	return 0;	
}

function slipgun_zombie_death_response( e_attacker )
{
	if ( !self is_slipgun_damage( self.damagemod, self.damageweapon ) )
		return 0;
	
	self slipgun_explode_into_goo( self.attacker, 0, self.damageweapon );
	return 1;
}

function slipgun_explode_into_goo( e_player, n_chain_depth, w_weapon )
{
	if ( isDefined( self.marked_for_insta_upgraded_death ) )
		return;
	
	str_tag = ( IS_TRUE( self.isdog ) ? "tag_origin" : "j_spinelower" );
	
	self playSound( "wpn_slipgun_zombie_explode" );
	
	playFx( SLIPGUN_EXPLODE_FX, self getTagOrigin( str_tag ) );
	
	if ( !IS_TRUE( self.isdog ) )
		wait .1;
	
	self ghost();
	if ( !isDefined( self.n_goo_chain_depth ) )
		self.n_goo_chain_depth = n_chain_depth;
	
	level thread slipgun_explode_to_near_zombies( e_player, self.origin, level.zombie_vars[ "slipgun_chain_radius" ], self.n_goo_chain_depth, w_weapon );
}

function slipgun_explode_to_near_zombies( e_player, v_origin, n_radius, n_chain_depth, w_weapon )
{
	n_radius_squared = n_radius * n_radius;
	
	a_enemies = zombie_utility::get_round_enemy_array();
	a_enemies = util::get_array_of_closest( v_origin, a_enemies );
	
	for ( i = 0; i < a_enemies.size; i++ )
	{
		v_trace = playerPhysicsTrace( v_origin, a_enemies[ i ] getTagOrigin( "j_head" ) );
		
		if ( v_trace != a_enemies[ i ] getTagOrigin( "j_head" ) )
			continue;
		
		if ( isAlive( a_enemies[ i ] ) && distanceSquared( a_enemies[ i ].origin, v_origin ) < n_radius_squared )
			a_enemies[ i ].slipgun_sizzle = playFxOnTag( SLIPGUN_SIZZLE_FX, a_enemies[ i ], "j_head" );
		
		wait randomFloatRange( level.zombie_vars[ "slipgun_chain_wait_min" ], level.zombie_vars[ "slipgun_chain_wait_max" ] );
		
		if ( isAlive( a_enemies[ i ] ) && distanceSquared( a_enemies[ i ].origin, v_origin ) < n_radius_squared )
		{
			if ( e_player zm_powerups::is_insta_kill_active() )
				a_enemies[ i ].health = 1;
						
			a_enemies[ i ] doDamage( level.n_slipgun_damage, v_origin, e_player, e_player, "none", level.n_slipgun_damage_mod, 0, w_weapon );
			
			if ( level.n_slippery_spot_count < level.zombie_vars[ "slipgun_reslip_max_spots" ] )
				thread slipgun_add_slippery_spot( a_enemies[ i ].origin, 24, v_origin );

		}
	}
}