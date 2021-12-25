#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_hb21_zm_weap_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_weap_castle_rocketshield.gsh;

#namespace zm_weap_castle_rocketshield;

REGISTER_SYSTEM_EX( "zm_weap_castle_rocketshield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # VARIABLES AND SETTINGS
	zm_equipment::register( ROCKETSHIELD_CASTLE_WEAPON, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" );
	zm_equipment::register( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" ); 
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_connect( &rocketshield_castle_on_player_connect );
	callback::on_spawned( &rocketshield_castle_on_player_spawned );
	// # REGISTER CALLBACKS
}


function __main__()
{
	zm_equipment::register_for_level( ROCKETSHIELD_CASTLE_WEAPON );
	zm_equipment::register_for_level( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED );
	zm_equipment::include( ROCKETSHIELD_CASTLE_WEAPON );
	zm_equipment::include( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED );
	zm_equipment::set_ammo_driven( ROCKETSHIELD_CASTLE_WEAPON, getWeapon( ROCKETSHIELD_CASTLE_WEAPON ).startAmmo, ROCKETSHIELD_CASTLE_REFILL_ON_MAX_AMMO );
	zm_equipment::set_ammo_driven( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED, getWeapon( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED ).startAmmo, ROCKETSHIELD_CASTLE_REFILL_ON_MAX_AMMO );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function rocketshield_castle_on_player_connect()
{
	self thread rocketshield_castle_watch_first_use();
}

function rocketshield_castle_on_player_spawned()
{
	self thread rocketshield_castle_player_watch_shield_juke();
	self thread rocketshield_castle_player_watch_upgraded_pickup_from_table();
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function rocketshield_castle_watch_first_use()
{
	self endon( "disconnect" );
	while ( isDefined( self ) )
	{
		self waittill ( "weapon_change", w_weapon );
		if ( w_weapon.name == ROCKETSHIELD_CASTLE_WEAPON || w_weapon.name == ROCKETSHIELD_CASTLE_WEAPON_UPGRADED )
			break;
			
	}
	zm_equipment::show_hint_text( ROCKETSHIELD_CASTLE_HINT_TEXT, ROCKETSHIELD_CASTLE_HINT_TIMER );
}

function rocketshield_castle_player_watch_upgraded_pickup_from_table()
{
	self notify( "rocketshield_castle_player_watch_upgraded_pickup_from_table" );
	self endon( "rocketshield_castle_player_watch_upgraded_pickup_from_table" );
	
	str_wpn_name = getWeapon( ROCKETSHIELD_CASTLE_WEAPON ).name;
	str_notify = str_wpn_name + "_pickup_from_table";
	
	for ( ;; )
	{
		self waittill( str_notify );
		if ( IS_TRUE( self.b_has_upgraded_shield ) )
			self zm_equipment::buy( ROCKETSHIELD_CASTLE_WEAPON_UPGRADED );
		
	}
}

function rocketshield_castle_player_watch_shield_juke()
{
	self notify( "rocketshield_castle_player_watch_shield_juke" );
	self endon( "rocketshield_castle_player_watch_shield_juke" );
	
	for ( ;; )
	{
		self waittill( "weapon_melee_juke", w_weapon );
		
		if ( w_weapon.name != ROCKETSHIELD_CASTLE_WEAPON && w_weapon.name != ROCKETSHIELD_CASTLE_WEAPON_UPGRADED )
			continue;
		
		if ( w_weapon.isriotshield )
		{
			self disableOffhandWeapons();
			self playSound( "zmb_rocketshield_start" );
			self rocketshield_castle_melee_juke();
			self playSound( "zmb_rocketshield_end" );
			self enableOffhandWeapons();
			self thread hb21_zm_weap_utility::shield_check_weapon_ammo( w_weapon ); 
			self notify( "shield_juke_done" );
		}
	}
}

function rocketshield_castle_melee_juke()
{
	self endon( "weapon_melee" );
	self endon( "weapon_melee_power" );
	self endon( "weapon_melee_charge" );
	
	n_start_time = getTime(); 

	DEFAULT( level.a_rocketshield_castle_knockdown_enemies, [] );
	DEFAULT( level.a_rocketshield_castle_knockdown_gib, [] );
	DEFAULT( level.a_rocketshield_castle_fling_enemies, [] );
	DEFAULT( level.a_rocketshield_castle_fling_vecs, [] );

	while( n_start_time + 3000 > getTime() )
	{
		self playRumbleOnEntity( "zod_shield_juke" );
		n_shield_damage = 0;

		a_enemies = rocketshield_castle_get_juke_enemies_in_range();
		if ( isDefined( level.rocketshield_castle_melee_juke_callback ) && isFunctionPtr( level.rocketshield_castle_melee_juke_callback ) )
			[ [ level.rocketshield_castle_melee_juke_callback ] ]( a_enemies );
			
		foreach( e_zombie in a_enemies )
		{
			self playSound( "zmb_rocketshield_imp" );
			e_zombie thread riotshield::riotshield_fling_zombie( self, e_zombie.fling_vec, 0 );
			n_shield_damage += level.zombie_vars[ "riotshield_juke_damage_shield" ];
		}

		if ( n_shield_damage )
			self riotshield::player_damage_shield( n_shield_damage, 0 );
		
		level.a_rocketshield_castle_knockdown_enemies = [];
		level.a_rocketshield_castle_knockdown_gib = [];
		level.a_rocketshield_castle_fling_enemies = [];
		level.a_rocketshield_castle_fling_vecs = [];

		wait .1;
	}
}

function rocketshield_castle_get_juke_enemies_in_range()
{
	v_view_pos = self.origin;
	a_zombies = array::get_all_closest( v_view_pos, getAITeamArray( level.zombie_team ), undefined, undefined, RIOTSHIELD_JUKE_DISTANCE );
	if ( !isDefined( a_zombies ) )
		return;

	v_forward = anglesToForward( self getPlayerAngles() );
	v_up = anglesToUp( self getPlayerAngles() );
	v_segment_start = v_view_pos + ( RIOTSHIELD_JUKE_KILL_HALFWIDTH * v_forward );
	v_segment_end = v_segment_start + ( ( RIOTSHIELD_JUKE_DISTANCE-RIOTSHIELD_JUKE_KILL_HALFWIDTH ) * v_forward );

	n_fling_force = level.zombie_vars[ "riotshield_fling_force_juke" ]; 
	n_fling_force_vlo = n_fling_force * .5; 
	n_fling_force_vhi = n_fling_force * .6; 
	
	a_enemies = [];
	
	for ( i = 0; i < a_zombies.size; i++ )
	{
		if ( !isDefined( a_zombies[ i ] ) || !isAlive( a_zombies[ i ] ) )
			continue;

		if ( a_zombies[ i ].archetype == ARCHETYPE_MARGWA )
			continue;
		
		v_test_origin = a_zombies[ i ] getCentroid();
		v_radial_origin = pointOnSegmentNearestToPoint( v_segment_start, v_segment_end, v_test_origin );
		v_lateral = v_test_origin - v_radial_origin;
		
		if ( abs(v_lateral[ 2 ]) > RIOTSHIELD_JUKE_KILL_VERT_LIMIT )
			continue;
		
		v_lateral = ( v_lateral[ 0 ], v_lateral[ 1 ], 0 );
		n_length = length( v_lateral );
		if ( n_length > RIOTSHIELD_JUKE_KILL_HALFWIDTH )
			continue;
	
		v_lateral = ( v_lateral[ 0 ], v_lateral[ 1 ], 0 ); 
		a_zombies[ i ].fling_vec = n_fling_force * v_forward + randomFloatRange( n_fling_force_vlo, n_fling_force_vhi ) * v_up;
		a_enemies[ a_enemies.size ] = a_zombies[ i ];
	}
	return a_enemies; 
}

// ============================== FUNCTIONALITY ==============================