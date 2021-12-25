/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###           		Harry Bo21s Black Ops 3 Dragon Shield			   ###
###                                                                   					   ###
###                                                                   					   ###
###========================================#*/
// LAST UPDATE V2.0.0 - 23/04/19
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
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weap_riotshield;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_dragonshield.gsh;

#precache( "string", 								"ZOMBIE_DRAGON_SHIELD_HINT"							 );
#precache( "string", 								"ZOMBIE_DRAGON_SHIELD_PICKUP"						 );
#precache( "string", 								"ZOMBIE_DRAGON_SHIELD_UPGRADE_PICKUP"		 );
#precache( "string", 								"DRAGON_SHIELD_UPGRADE"								 );
#precache( "model", 								DRAGONSHIELD_MODEL											 );

#namespace hb21_zm_weap_dragonshield;

REGISTER_SYSTEM_EX( "hb21_zm_weap_dragonshield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None  
*/
function __init__()
{	
	str_script = toLower( getDvarString( "mapname" ) );
	if ( str_script == "zm_stalingrad" || str_script == "zm_genesis" )
		return;
	
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "allplayers", DRAGONSHIELD_BURNINATE_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "allplayers", DRAGONSHIELD_BURNINATE_UPGRADED_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", DRAGONSHIELD_SND_PROJECTILE_IMPACT_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "vehicle", DRAGONSHIELD_SND_PROJECTILE_IMPACT_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "vehicle", DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF, VERSION_SHIP, 1, "counter" );
	// # CLIENTFIELD REGISTRATION
	
	// # VARIABLES AND SETTINGS
	zombie_utility::set_zombie_var( "dragonshield_proximity_fling_radius", DRAGONSHIELD_PROXIMITY_FLING_RADIUS );
	zombie_utility::set_zombie_var( "dragonshield_proximity_knockdown_radius", DRAGONSHIELD_PROXIMITY_KNOCKDOWN_RADIUS );
	zombie_utility::set_zombie_var( "dragonshield_cylinder_radius", DRAGONSHIELD_CYLINDER_RADIUS );
	zombie_utility::set_zombie_var( "dragonshield_fling_range", DRAGONSHIELD_FLING_RANGE );
	zombie_utility::set_zombie_var( "dragonshield_gib_range", DRAGONSHIELD_GIB_RANGE );
	zombie_utility::set_zombie_var( "dragonshield_gib_damage", DRAGONSHIELD_GIB_DAMAGE );
	zombie_utility::set_zombie_var( "dragonshield_knockdown_range", DRAGONSHIELD_KNOCKDOWN_RANGE );
	zombie_utility::set_zombie_var( "dragonshield_knockdown_damage", DRAGONSHIELD_KNOCKDOWN_DAMAGE );
	zombie_utility::set_zombie_var( "dragonshield_projectile_lifetime", DRAGONSHIELD_PROJECTILE_LIFETIME );
	level.dragonshield_gib_refs = [];
	level.dragonshield_gib_refs[ level.dragonshield_gib_refs.size ] = "guts";
	level.dragonshield_gib_refs[ level.dragonshield_gib_refs.size ] = "right_arm";
	level.dragonshield_gib_refs[ level.dragonshield_gib_refs.size ] = "left_arm";
	// # VARIABLES AND SETTINGS
	
	// # REGISTER DRAGONSHIELD WEAPONS
	dragon_shield_register_weapon_for_level( DRAGONSHIELD_WEAPON, DRAGONSHIELD_WEAPON_PROJECTILE, &"ZOMBIE_DRAGON_SHIELD_PICKUP", &dragon_shield_melee );
	dragon_shield_register_weapon_for_level( DRAGONSHIELD_WEAPON_UPGRADED, DRAGONSHIELD_WEAPON_UPGRADED_PROJECTILE, &"ZOMBIE_DRAGON_SHIELD_UPGRADE_PICKUP", &dragon_shield_melee );
	// # REGISTER DRAGONSHIELD WEAPONS
	
	// # REGISTER CALLBACKS
	level.basic_zombie_dragonshield_knockdown = &dragon_shield_zombie_knockdown;
	callback::on_connect( &dragon_shield_on_player_connect );
	callback::on_spawned( &dragon_shield_on_player_spawned );
	// # REGISTER CALLBACKS
	
	array::run_all( struct::get_array( "harrybo21_dragon_shield_upgrade_trigger", "script_noteworthy" ), &dragon_shield_upgrade_trigger );	
}

/* 
MAIN 
Description : This function starts the script and will setup everything required - POST-load
Notes : None  
*/
function __main__()
{
}

/* 
DRAGON SHIELD REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a Dragon Shield variant and sets up some required properties
Notes : None
*/
function dragon_shield_register_weapon_for_level( str_weapon, str_weapon_projectile, str_pickup_hint, ptr_weapon_melee_power_cb )
{
	DEFAULT( level.a_dragon_shield_weaponfiles, [] );
	DEFAULT( level.a_dragon_shield_projectile_weaponfiles, [] );
	
	w_weapon = getWeapon( str_weapon );
	w_weapon.str_dragon_shield_projectile = str_weapon_projectile;
	w_weapon.w_weapon_projectile = getWeapon( str_weapon_projectile );
	w_weapon.str_dragon_shield = str_weapon;
	w_weapon.ptr_weapon_melee_power_cb	= ptr_weapon_melee_power_cb;
	
	zm_equipment::register( str_weapon, str_pickup_hint, &"ZOMBIE_DRAGON_SHIELD_HINT", undefined, "riotshield" );
	zm_equipment::register_for_level( str_weapon );
	zm_equipment::include( str_weapon );
	zm_equipment::set_ammo_driven( str_weapon, w_weapon.startAmmo, DRAGONSHIELD_REFILL_ON_MAX_AMMO );
	
	ARRAY_ADD( level.a_dragon_shield_weaponfiles, w_weapon );
	ARRAY_ADD( level.a_dragon_shield_projectile_weaponfiles, w_weapon.w_weapon_projectile );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
DRAGON SHIELD ON PLAYER CONNECT
Description : This function handles setting up logic for the Dragon Shield on player connects
Notes : None
*/
function dragon_shield_on_player_connect()
{
	self thread dragon_shield_watch_first_use();
}

/* 
DRAGON SHIELD ON PLAYER SPAWNED
Description : This function handles setting up logic for the Dragon Shield on player spawns
Notes : None
*/
function dragon_shield_on_player_spawned()
{
	self thread dragon_shield_player_watch_upgraded_pickup_from_table();
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function dragon_shield_melee( w_weapon )
{
	if ( self getAmmoCount( w_weapon ) > 0 && !IS_TRUE( self.b_dragon_shield_projectile_disabled ) )
	{
		self zm_equipment::change_ammo( w_weapon, -1 );
		self thread dragon_shield_fire_projectile( w_weapon );
		self thread dragonshield_fired( w_weapon );
	}
	else
		riotshield::riotshield_melee( w_weapon );
	
}

function dragonshield_fired(w_weapon)
{
	physicsExplosionCylinder( self.origin, 600, 240, 1 );
	self thread dragonshield_affect_ais( ( w_weapon.name == DRAGONSHIELD_WEAPON_UPGRADED ? 2 : 1 ) );
	// self notify( "hash_10fa975d", w_weapon );
}

function dragonshield_affect_ais( n_clientfield )
{
	if ( !isDefined( level.dragonshield_knockdown_enemies ) )
	{
		level.dragonshield_knockdown_enemies = [];
		level.dragonshield_knockdown_gib = [];
		level.dragonshield_fling_enemies = [];
		level.dragonshield_fling_vecs = [];
	}
	self dragonshield_get_enemies_in_range();
	// self.var_3a6322f2 = 0;
	level.dragonshield_network_choke_count = 0;
	for ( i = 0; i < level.dragonshield_fling_enemies.size; i++ )
	{
		if ( level.dragonshield_fling_enemies[ i ].archetype === "zombie" )
			level.dragonshield_fling_enemies[ i ] clientfield::set( "dragon_strike_zombie_fire", n_clientfield );
		
		level.dragonshield_fling_enemies[ i ] thread dragonshield_fling_zombie( self, level.dragonshield_fling_vecs[ i ], i );
		dragonshield_network_choke();
	}
	for ( i = 0; i < level.dragonshield_knockdown_enemies.size; i++ )
	{
		if ( level.dragonshield_knockdown_enemies[ i ].archetype === "zombie" )
			level.dragonshield_knockdown_enemies[ i ] clientfield::set( "dragon_strike_zombie_fire", n_clientfield );
		
		level.dragonshield_knockdown_enemies[ i ] thread dragonshield_knockdown_zombie( self, level.dragonshield_knockdown_gib[ i ] );
		dragonshield_network_choke();
	}
	// self notify("hash_8c80a390", self.var_3a6322f2);
	level.dragonshield_knockdown_enemies = [];
	level.dragonshield_knockdown_gib = [];
	level.dragonshield_fling_enemies = [];
	level.dragonshield_fling_vecs = [];
}

function dragonshield_get_enemies_in_range()
{
	v_view_pos = self getWeaponMuzzlePoint();
	a_zombies = array::get_all_closest( v_view_pos, getAITeamArray( level.zombie_team ), undefined, undefined, level.zombie_vars[ "dragonshield_knockdown_range" ] );
	if ( !isDefined( a_zombies ) )
		return;
	
	n_knockdown_range_squared = SQR( level.zombie_vars[ "dragonshield_knockdown_range" ] );	
	n_gib_range_squared = SQR( level.zombie_vars[ "dragonshield_gib_range" ] );
	n_fling_range_squared = SQR( level.zombie_vars[ "dragonshield_fling_range" ] );
	n_cylinder_radius_squared = SQR( level.zombie_vars[ "dragonshield_cylinder_radius" ] );
	n_prox_knockdown_range_squared = SQR( level.zombie_vars[ "dragonshield_proximity_knockdown_radius" ] );
	n_prox_fling_range_squared = SQR( level.zombie_vars[ "dragonshield_proximity_fling_radius" ] );
	v_forward_view_angles = self getWeaponForwardDir();
	v_end_pos = v_view_pos + vectorScale( v_forward_view_angles, level.zombie_vars[ "dragonshield_knockdown_range" ] );
	
	for ( i = 0; i < a_zombies.size; i++)
	{
		if ( !isDefined( a_zombies[ i ]) || !isAlive( a_zombies[ i ] ) )
			continue;
		
		v_test_origin = a_zombies[ i ] getCentroid();
		n_test_range_squared = distanceSquared( v_view_pos, v_test_origin );
		if ( n_test_range_squared > n_knockdown_range_squared )
			return;
		
		v_normal = vectorNormalize( v_test_origin - v_view_pos );
		n_dot = vectorDot( v_forward_view_angles, v_normal );
		if ( n_test_range_squared < n_prox_fling_range_squared )
		{
			level.dragonshield_fling_enemies[ level.dragonshield_fling_enemies.size ] = a_zombies[ i ];
			n_dist_mult = 1;
			v_fling_vec = vectorNormalize( v_test_origin - v_view_pos );
			v_fling_vec = ( v_fling_vec[ 0 ], v_fling_vec[ 1 ], abs( v_fling_vec[ 2 ] ) );
			v_fling_vec = vectorScale( v_fling_vec, 50 + 50 * n_dist_mult );
			level.dragonshield_fling_vecs[ level.dragonshield_fling_vecs.size ] = v_fling_vec;
			continue;
		}
		else if ( n_test_range_squared < n_prox_knockdown_range_squared && 0 > n_dot )
		{
			if ( !isDefined( a_zombies[ i ].dragonshield_knockdown_func ) )
				a_zombies[ i ].dragonshield_knockdown_func = level.basic_zombie_dragonshield_knockdown;
			
			level.dragonshield_knockdown_enemies[ level.dragonshield_knockdown_enemies.size ] = a_zombies[ i ];
			level.dragonshield_knockdown_gib[ level.dragonshield_knockdown_gib.size ] = 0;
			continue;
		}
		if ( 0 > n_dot )
			continue;
		
		v_radial_origin = pointOnSegmentNearestToPoint( v_view_pos, v_end_pos, v_test_origin );
		if ( distanceSquared( v_test_origin, v_radial_origin ) > n_cylinder_radius_squared )
			continue;
		
		if ( 0 == a_zombies[ i ] damageConeTrace( v_view_pos, self ) )
			continue;
		
		n_projectile_life = level.zombie_vars[ "dragonshield_projectile_lifetime" ];
		a_zombies[ i ].n_dragonshield_knockdown_delay = n_projectile_life * sqrt( n_test_range_squared ) / level.zombie_vars[ "dragonshield_knockdown_range" ];
		if ( n_test_range_squared < n_fling_range_squared )
		{
			level.dragonshield_fling_enemies[ level.dragonshield_fling_enemies.size ] = a_zombies[ i ];
			n_dist_mult = ( n_fling_range_squared - n_test_range_squared ) / n_fling_range_squared;
			v_fling_vec = vectorNormalize( v_test_origin - v_view_pos );
			if ( 5000 < n_test_range_squared )
				v_fling_vec = v_fling_vec + vectorNormalize( v_test_origin - v_radial_origin );
			
			v_fling_vec = ( v_fling_vec[ 0 ], v_fling_vec[ 1 ], abs( v_fling_vec[ 2 ] ) );
			v_fling_vec = vectorScale( v_fling_vec, 50 + 50 * n_dist_mult );
			level.dragonshield_fling_vecs[ level.dragonshield_fling_vecs.size ] = v_fling_vec;
			continue;
		}
		if ( n_test_range_squared < n_gib_range_squared )
		{
			if ( !isDefined( a_zombies[ i ].dragonshield_knockdown_func ) )
				a_zombies[ i ].dragonshield_knockdown_func = level.basic_zombie_dragonshield_knockdown;
			
			level.dragonshield_knockdown_enemies[ level.dragonshield_knockdown_enemies.size ] = a_zombies[ i ];
			level.dragonshield_knockdown_gib[ level.dragonshield_knockdown_gib.size ] = 1;
			continue;
		}
		if ( !isDefined( a_zombies[ i ].dragonshield_knockdown_func ) )
			a_zombies[ i ].dragonshield_knockdown_func = level.basic_zombie_dragonshield_knockdown;
		
		level.dragonshield_knockdown_enemies[ level.dragonshield_knockdown_enemies.size ] = a_zombies[ i ];
		level.dragonshield_knockdown_gib[ level.dragonshield_knockdown_gib.size ] = 0;
	}
}

function dragonshield_fling_zombie( e_player, v_fling_vec, n_index )
{
	n_delay = self.n_dragonshield_knockdown_delay;
	if ( isDefined( n_delay ) && n_delay > .05 )
		wait n_delay;
	
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( isDefined( self.dragonshield_fling_func ) )
	{
		self [ [ self.dragonshield_fling_func ] ]( e_player );
		return;
	}
	self dragonshield_kill_zombie( e_player );
	if ( self.health <= 0 )
	{
		if ( !IS_TRUE( self.no_damage_points ) )
		{
			n_points = 10;
			if ( !n_index )
				n_points = zm_score::get_zombie_death_player_points();
			else if ( 1 == n_index )
				n_points = 30;
			
			e_player zm_score::player_add_points( "riotshield_fling", n_points );
		}
		self startRagdoll();
		self launchRagdoll( v_fling_vec );
		self.dragonshield_death = 1;
		// e_player.var_3a6322f2++;
	}
}

function dragonshield_kill_zombie( e_attacker )
{
	self.marked_for_death = 1;
	if ( isDefined( self ) )
		self doDamage( self.health + 666, e_attacker.origin, e_attacker );
	
}

function dragonshield_knockdown_zombie( e_player, b_gib )
{
	self endon( "death" );
	self clientfield::increment( DRAGONSHIELD_SND_PROJECTILE_IMPACT_CF );
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( isDefined( self.dragonshield_knockdown_func ) )
		self [ [ self.dragonshield_knockdown_func ] ]( e_player, b_gib );
	
}

function dragonshield_network_choke()
{
	level.dragonshield_network_choke_count++;
	if ( !level.dragonshield_network_choke_count % 10 )
	{
		util::wait_network_frame();
		util::wait_network_frame();
		util::wait_network_frame();
	}
}

function dragon_shield_fire_projectile( w_weapon )
{
	self playRumbleOnEntity( "zod_shield_juke" );
	self clientfield::increment( ( w_weapon.name == DRAGONSHIELD_WEAPON_UPGRADED ? DRAGONSHIELD_BURNINATE_UPGRADED_CF : DRAGONSHIELD_BURNINATE_CF ) );
	v_view_pos = self getWeaponMuzzlePoint();
	e_fireball = magicBullet( w_weapon.w_weapon_projectile, v_view_pos, v_view_pos + level.zombie_vars[ "dragonshield_knockdown_range" ] * self getWeaponForwardDir(), self );
}

function dragon_shield_zombie_knockdown( e_player, b_gib )
{
	n_delay = self.n_dragonshield_knockdown_delay;
	if ( isDefined( n_delay ) && n_delay > .05 )
		wait n_delay;
	
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( !isVehicle( self ) )
	{
		if ( b_gib && !IS_TRUE( self.gibbed ) )
		{
			if ( isArray( level.dragonshield_gib_refs ) )
				self.a.gib_ref = array::random( level.dragonshield_gib_refs );
			
			self thread zombie_death::do_gib();
		}
		else
			self zombie_utility::setup_zombie_knockdown( e_player );
		
	}
	if ( isDefined( level.override_dragonshield_damage_func ) )
		self [ [ level.override_dragonshield_damage_func ] ]( e_player, b_gib );
	else
	{
		n_damage = level.zombie_vars[ "dragonshield_knockdown_damage" ];
		self clientfield::increment( DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF );
		self.dragonshield_handle_pain_notetracks = &handle_dragonshield_pain_notetracks;
		self doDamage( n_damage, e_player.origin, e_player );
		if ( !isVehicle( self ) )
			self animCustom( &playdragonshieldpainanim );
		
		// if ( self.health <= 0 )
		// 	e_player.var_3a6322f2++;
		
	}
}

function playdragonshieldpainanim()
{
	self notify( "end_play_dragonshield_pain_anim" );
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "end_play_dragonshield_pain_anim" );
	if ( IS_TRUE( self.marked_for_death ) )
		return;
	
	if ( self.damageyaw <= -135 || self.damageyaw >= 135 )
	{
		if ( IS_TRUE( self.missingLegs ) )
			str_fall_anim = "zm_dragonshield_fall_front_crawl";
		else
			str_fall_anim = "zm_dragonshield_fall_front";
		
		str_getup_anim = "zm_dragonshield_getup_belly_early";
	}
	else if ( self.damageyaw > -135 && self.damageyaw < -45 )
	{
		str_fall_anim = "zm_dragonshield_fall_left";
		str_getup_anim = "zm_dragonshield_getup_belly_early";
	}
	else if ( self.damageyaw > 45 && self.damageyaw < 135 )
	{
		str_fall_anim = "zm_dragonshield_fall_right";
		str_getup_anim = "zm_dragonshield_getup_belly_early";
	}
	else
	{
		str_fall_anim = "zm_dragonshield_fall_back";
		if ( randomInt( 100 ) < 50 )
			str_getup_anim = "zm_dragonshield_getup_back_early";
		else
			str_getup_anim = "zm_dragonshield_getup_back_late";
		
	}
	self setAnimStateFromASD( str_fall_anim );
	self zombie_shared::doNoteTracks( "dragonshield_fall_anim", self.dragonshield_handle_pain_notetracks );
	if ( !isDefined( self ) || !isAlive( self ) || IS_TRUE( self.missingLegs ) || IS_TRUE( self.marked_for_death ) )
		return;
	
	self setAnimStateFromASD( str_getup_anim );
	self zombie_shared::doNoteTracks( "dragonshield_getup_anim" );
}

function handle_dragonshield_pain_notetracks( str_note )
{
	if ( str_note == "zombie_knockdown_ground_impact" )
	{
		playFX( level._effect[ "thundergun_knockdown_ground" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
		self clientfield::increment( DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF );
	}
}

function dragon_shield_watch_first_use()
{
	self endon( "disconnect" );
	while ( isDefined( self ) )
	{
		self waittill( "weapon_change", w_weapon );
		if ( is_dragon_shield_weapon( w_weapon ) )
			break;
		
	}
	zm_equipment::show_hint_text( &"ZOMBIE_DRAGON_SHIELD_HINT", 5 );
}

function dragon_shield_player_watch_upgraded_pickup_from_table()
{
	self endon( "disconnect" );
	self notify( "dragon_shield_player_watch_upgraded_pickup_from_table" );
	self endon( "dragon_shield_player_watch_upgraded_pickup_from_table" );
	
	while ( isDefined( self ) )
	{
		self waittill( DRAGONSHIELD_WEAPON + "_pickup_from_table" );
		if ( IS_TRUE( self.b_has_upgraded_dragon_shield ) )
			self zm_equipment::buy( DRAGONSHIELD_WEAPON_UPGRADED );
		
	}
}

function dragon_shield_upgrade_trigger()
{
	e_trigger = spawn( "trigger_radius_use", self.origin + ( 0, 0, 48 ), 0, 40, 80 );
	e_trigger.script_noteworthy = "harrybo21_dragon_shield_upgrade_trigger";
	
	e_trigger triggerIgnoreTeam();
	e_trigger useTriggerRequireLookAt();
	e_trigger setCursorHint( "HINT_NOICON" );
	e_trigger setHintString( &"ZOMBIE_DRAGON_SHIELD_UPGRADE" );
	
	while ( isDefined( e_trigger ) )
	{
		e_trigger waittill( "trigger", e_player );
		
		if ( e_player laststand::player_is_in_laststand() || IS_TRUE( e_player.intermission ) || !e_player hasWeapon( getWeapon( DRAGONSHIELD_WEAPON ) ) )
			continue;
		
		e_trigger setHintString( "" );
		e_player zm_weapons::weapon_take( getWeapon( DRAGONSHIELD_WEAPON ) );
		
		e_model = util::spawn_model( DRAGONSHIELD_MODEL, e_trigger.origin );
		e_model.angles = self.angles;
		
		playSoundAtPosition( DRAGON_SHIELD_UPGRADE_PLACE_SOUND, e_trigger.origin );
		e_model playLoopSound( DRAGON_SHIELD_UPGRADE_LOOP_SOUND );
		
		wait 1;
		
		e_model moveTo( e_model.origin - ( 0, 0, 100 ), 3 );
		wait 5;
		
		playSoundAtPosition( DRAGON_SHIELD_UPGRADE_ENHANCE_SOUND, e_trigger.origin );
		
		e_model moveTo( e_model.origin + ( 0, 0, 100 ), 3 );
		wait 5;
		
		playSoundAtPosition( DRAGON_SHIELD_UPGRADE_READY_SOUND, e_trigger.origin );
		e_player playLocalSound( DRAGON_SHIELD_UPGRADE_SUCCESS_LARGE_SOUND );
		
		e_player notify( "dragon_shield_pickup_from_table" );
		
		e_player zm_weapons::weapon_give( getWeapon( DRAGONSHIELD_WEAPON_UPGRADED ), 0, 0, 1, 1 );
		e_player.b_has_upgraded_dragon_shield = 1;
		
		e_trigger setHintString( &"ZOMBIE_DRAGON_SHIELD_UPGRADE" );
		e_model delete();
	}
}

function is_dragon_shield_weapon( w_weapon, a_array = level.a_dragon_shield_weaponfiles )
{
	return ( isDefined( a_array ) && isArray( a_array ) && isInArray( a_array, w_weapon ) );
}

// ============================== FUNCTIONALITY ==============================