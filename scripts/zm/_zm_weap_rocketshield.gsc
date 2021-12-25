#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_hb21_zm_weap_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_weap_rocketshield.gsh;

#precache( "string", "ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING" );
#precache( "triggerstring", "ZOMBIE_PICKUP_BOTTLE" );

#namespace zm_weap_rocketshield;

REGISTER_SYSTEM_EX( "zm_weap_rocketshield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # VARIABLES AND SETTINGS
	zm_equipment::register( ROCKETSHIELD_WEAPON, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" );
	zm_equipment::register( ROCKETSHIELD_WEAPON_UPGRADED, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" ); 
	
	zombie_utility::set_zombie_var( "riotshield_fling_damage_shield",				ROCKETSHIELD_FLING_DAMAGE_SHIELD ); 
	zombie_utility::set_zombie_var( "riotshield_knockdown_damage_shield",	ROCKETSHIELD_KNOCKDOWN_DAMAGE_SHIELD );
	zombie_utility::set_zombie_var( "riotshield_juke_damage_shield",				ROCKETSHIELD_JUKE_DAMAGE_SHIELD ); 
	zombie_utility::set_zombie_var( "riotshield_fling_force_juke",					ROCKETSHIELD_FLING_FORCE_JUKE ); 
	zombie_utility::set_zombie_var( "riotshield_fling_range",							ROCKETSHIELD_FLING_RANGE ); 
	zombie_utility::set_zombie_var( "riotshield_gib_range",							ROCKETSHIELD_GIB_RANGE ); 
	zombie_utility::set_zombie_var( "riotshield_knockdown_range",				ROCKETSHIELD_KNOCKDOWN_RANGE ); 
	setDvar( "juke_enabled", 1 );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_connect( &rocketshield_on_player_connect );
	callback::on_spawned( &rocketshield_on_player_spawned );
	level.riotshield_damage_callback = &rocketshield_player_damage_rocketshield;
	// # REGISTER CALLBACKS
}


function __main__()
{
	zm_equipment::register_for_level( ROCKETSHIELD_WEAPON );
	zm_equipment::register_for_level( ROCKETSHIELD_WEAPON_UPGRADED );
	zm_equipment::include( ROCKETSHIELD_WEAPON );
	zm_equipment::include( ROCKETSHIELD_WEAPON_UPGRADED );
	zm_equipment::set_ammo_driven( ROCKETSHIELD_WEAPON, getWeapon( ROCKETSHIELD_WEAPON ).startAmmo, ROCKETSHIELD_REFILL_ON_MAX_AMMO );
	zm_equipment::set_ammo_driven( ROCKETSHIELD_WEAPON_UPGRADED, getWeapon( ROCKETSHIELD_WEAPON_UPGRADED ).startAmmo, ROCKETSHIELD_REFILL_ON_MAX_AMMO );
	
	level thread rocketshield_spawn_recharge_tanks(); 
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function rocketshield_on_player_connect()
{
	self thread rocketshield_watch_first_use();
}

function rocketshield_on_player_spawned()
{
	self thread rocketshield_player_watch_shield_juke();
	self thread rocketshield_player_watch_upgraded_pickup_from_table();
}

function rocketshield_player_damage_rocketshield( n_damage, b_held, b_from_code = 0, str_mod = "MOD_UNKNOWN" )
{
	n_shield_damage = n_damage; 
	if ( IS_EQUAL( str_mod, "MOD_EXPLOSIVE" ) )
		n_shield_damage += n_damage * 2; 
	
	self riotshield::player_damage_shield( n_shield_damage, b_held, b_from_code, str_mod );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function rocketshield_watch_first_use()
{
	self endon( "disconnect" );
	while ( isDefined( self ) )
	{
		self waittill ( "weapon_change", w_weapon );
		if ( w_weapon.name == ROCKETSHIELD_WEAPON || w_weapon.name == ROCKETSHIELD_WEAPON_UPGRADED )
			break;
			
	}
	zm_equipment::show_hint_text( ROCKETSHIELD_HINT_TEXT, ROCKETSHIELD_HINT_TIMER );;
}

function rocketshield_player_watch_upgraded_pickup_from_table()
{
	self notify( "rocketshield_player_watch_upgraded_pickup_from_table" );
	self endon( "rocketshield_player_watch_upgraded_pickup_from_table" );
	
	str_wpn_name = getWeapon( ROCKETSHIELD_WEAPON ).name;
	str_notify = str_wpn_name + "_pickup_from_table";
	
	for ( ;; )
	{
		self waittill( str_notify );
		if ( IS_TRUE( self.b_has_upgraded_shield ) )
			self zm_equipment::buy( ROCKETSHIELD_WEAPON_UPGRADED );
		
	}
}

function rocketshield_player_watch_shield_juke()
{
	self notify( "rocketshield_player_watch_shield_juke" );
	self endon( "rocketshield_player_watch_shield_juke" );
	
	for ( ;; )
	{
		self waittill( "weapon_melee_juke", w_weapon );
		
		if ( w_weapon.name != ROCKETSHIELD_WEAPON && w_weapon.name != ROCKETSHIELD_WEAPON_UPGRADED )
			continue;
		
		if ( w_weapon.isriotshield )
		{
			self disableOffhandWeapons();
			self playSound( "zmb_rocketshield_start" );
			self rocketshield_melee_juke();
			self playSound( "zmb_rocketshield_end" );
			self enableOffhandWeapons();
			self thread hb21_zm_weap_utility::shield_check_weapon_ammo( w_weapon ); 
			self notify( "shield_juke_done" );
		}
	}
}

function rocketshield_melee_juke()
{
	self endon( "weapon_melee" );
	self endon( "weapon_melee_power" );
	self endon( "weapon_melee_charge" );
	
	n_start_time = getTime(); 

	DEFAULT( level.a_rocketshield_knockdown_enemies, [] );
	DEFAULT( level.a_rocketshield_knockdown_gib, [] );
	DEFAULT( level.a_rocketshield_fling_enemies, [] );
	DEFAULT( level.a_rocketshield_fling_vecs, [] );

	while( n_start_time + 3000 > getTime() )
	{
		self playRumbleOnEntity( "zod_shield_juke" );
		n_shield_damage = 0;

		a_enemies = rocketshield_get_juke_enemies_in_range();
		if ( isDefined( level.rocketshield_melee_juke_callback ) && isFunctionPtr( level.rocketshield_melee_juke_callback ) )
			[ [ level.rocketshield_melee_juke_callback ] ]( a_enemies );
			
		foreach( e_zombie in a_enemies )
		{
			self playSound( "zmb_rocketshield_imp" );
			e_zombie thread riotshield::riotshield_fling_zombie( self, e_zombie.fling_vec, 0 );
			n_shield_damage += level.zombie_vars[ "riotshield_juke_damage_shield" ];
		}

		if ( n_shield_damage )
			self riotshield::player_damage_shield( n_shield_damage, 0 );
		
		level.a_rocketshield_knockdown_enemies = [];
		level.a_rocketshield_knockdown_gib = [];
		level.a_rocketshield_fling_enemies = [];
		level.a_rocketshield_fling_vecs = [];

		wait .1;
	}
}

function rocketshield_get_juke_enemies_in_range()
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

function rocketshield_spawn_recharge_tanks()
{
	level flag::wait_till( "all_players_spawned" );
	
	n_spawned = 0;
	n_charges = ( level.players.size + MIN_CHARGES_IN_LEVEL );
	a_e_spawnpoints = array::randomize( struct::get_array( "zod_shield_charge" ) );
	
	foreach ( e_spawnpoint in a_e_spawnpoints )
	{
		if ( IS_TRUE( e_spawnpoint.b_spawned ) )
			n_spawned++;
		
	}
	
	foreach ( e_spawnpoint in a_e_spawnpoints )
	{
		if ( n_spawned < n_charges )
		{
			if ( !IS_TRUE( e_spawnpoint.b_spawned ) )
			{
				e_spawnpoint thread rocketshield_create_bottle_unitrigger( e_spawnpoint.origin, e_spawnpoint.angles );
				n_spawned++;
			}
		}
		else
			break;
		
	}
	
	level waittill( "start_of_round" );
	level thread rocketshield_spawn_recharge_tanks();
}

function rocketshield_create_bottle_unitrigger( v_origin, v_angles )
{
	s_struct = self;
	if ( self == level )
	{
		s_struct = spawnStruct();
		s_struct.origin = v_origin;
		s_struct.angles = v_angles;
	}
	
	s_unitrigger_stub = spawnStruct();
	s_unitrigger_stub.origin = v_origin;
	s_unitrigger_stub.angles = v_angles;
	s_unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_unitrigger_stub.script_width = 128;
	s_unitrigger_stub.script_height = 128;
	s_unitrigger_stub.script_length = 128;
	s_unitrigger_stub.require_look_at = 0;
	
	s_unitrigger_stub.e_shield_recharge = spawn( "script_model", v_origin );
	str_model_name = MODEL_SHIELD_RECHARGE;
	if ( isDefined( s_struct.model ) && isString( s_struct.model )  )
		str_model_name = s_struct.model;
		
	s_unitrigger_stub.e_shield_recharge setModel( str_model_name );
	s_unitrigger_stub.e_shield_recharge.angles = v_angles;
	
	s_struct.b_spawned = 1;
	s_unitrigger_stub.s_shield_recharge_spawnpoint = s_struct;

	s_unitrigger_stub.prompt_and_visibility_func = &rocketshield_bottle_trigger_visibility;
	zm_unitrigger::register_static_unitrigger( s_unitrigger_stub, &rocketshield_recharge_trigger_think );
	
	return s_unitrigger_stub;
}
	
function rocketshield_bottle_trigger_visibility( e_player )
{
	self setHintString( "Hold ^3[{+activate}]^7 to recharge shield." );
	
	if ( !( IS_TRUE( e_player.hasriotshield ) ) || ( ( e_player getAmmoCount( e_player.weaponriotshield ) ) == e_player.weaponriotshield.maxammo ) )
		b_is_invis = 1;
	else
		b_is_invis = 0;
	
	self setInvisibleToPlayer( e_player, b_is_invis );
	
	return !b_is_invis;
}

function rocketshield_recharge_trigger_think()
{
	while ( isDefined( self ) )
	{
		self waittill( "trigger_activated", e_player );
		
		level thread rocketshield_bottle_trigger_activate( self.stub, e_player );
		
		break;
	}
}

function rocketshield_bottle_trigger_activate( s_trig_stub, e_player )
{
	s_trig_stub notify( "bottle_collected" );
	
	if ( IS_TRUE( e_player.hasRiotShield ) )
		e_player zm_equipment::change_ammo( e_player.weaponRiotshield, 1 ); 
	
	v_origin = s_trig_stub.e_shield_recharge.origin;
	v_angles = s_trig_stub.e_shield_recharge.angles;
	
	s_trig_stub.e_shield_recharge delete();

	zm_unitrigger::unregister_unitrigger( s_trig_stub );
	
	s_trig_stub.s_shield_recharge_spawnpoint.b_spawned = undefined;
}

// ============================== FUNCTIONALITY ==============================