/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###         	  	Harry Bo21s Black Ops 3 Staff of Air				   ###
###                                                                   					   ###
###                                                                   					   ###
###========================================#*/
// LAST UPDATE V2.5.0 - 19/12/18
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
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_hb21_zm_weap_staff_utility;
#using scripts\zm\_hb21_zm_weap_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_air.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", 		AIRSTAFF_MODEL );
#precache( "model", 		AIRSTAFF_UPGRADED_MODEL );
#precache( "model", 		AIRSTAFF_PLINTH_MODEL );
#precache( "model", 		AIRSTAFF_PLINTH_BASE_MODEL );

#precache( "fx", 			AIRSTAFF_UPGRADE_GLOW );

#namespace hb21_zm_weap_staff_air; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_air", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ai.b_staff_air_immune - BOOLEAN - enable on ai to stop the Staff of Air damaging them
// ai.b_staff_air_upgraded_immune - BOOLEAN - enable on ai to stop the upgraded Staff of Air damaging them

// ai.ptr_staff_air_actor_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Air on actors
// ai.ptr_staff_air_vehicle_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Air on vehicles

// ai.ptr_staff_air_zombie_damage_cb - FUNCTION_POINTER - set your own function here to change what happens when a zombie is hit by the Staff of Air
// ai.ptr_staff_air_death_cb - FUNCTION_POINTER - - set your own function here to change the death behavior when killed by the Staff of Air

// ai.b_staff_air_cone_immune - BOOLEAN - enable on ai to stop the normal staff cone shot being able to effect them at all

// ai.b_staff_air_whirlwind_immune - BOOLEAN - enable on ai to stop the whirlwind being able to effect them at all
// ai.n_staff_air_whirlwind_range_check_multiplier - FLOAT - option to increase the distance checks used in the whirlwind logic checks - can be important on flying AI as their height from the ground has a dramatic impact vs an ai on the ground
// ai.str_staff_air_whirlwind_tag_check - STRING - set a tag name here to have the charge attack check for impact with an ai, will default to "j_spineupper" otherwise. Use this if your ai does NOT have this tag

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required - PRE-load
Notes : None  
*/
function __init__()
{
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	level.a_staff_air_weaponfiles = [];
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	staff_air_register_weapon_for_level( AIRSTAFF_WEAPON, undefined, &staff_air_fired );
	staff_air_register_weapon_for_level( AIRSTAFF_UPGRADED_WEAPON, undefined, &staff_air_fired, undefined );
	staff_air_register_weapon_for_level( AIRSTAFF_UPGRADED_WEAPON2, undefined, &staff_air_upgrade_fired );
	staff_air_register_weapon_for_level( AIRSTAFF_UPGRADED_WEAPON3, undefined, &staff_air_upgrade_fired );
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	
	/* ========================================================== 									REGISTER STAFF UPGRADE PEDESTALS				 		========================================================== */
	// hb21_zm_weap_staff_utility::staff_upgrade_pedestal_spawn( "wind", AIRSTAFF_WEAPON, AIRSTAFF_UPGRADED_WEAPON, AIRSTAFF_MODEL, AIRSTAFF_UPGRADED_MODEL, AIRSTAFF_PLINTH_MODEL, AIRSTAFF_PLINTH_BASE_MODEL, AIRSTAFF_UPGRADE_GLOW );
	/* ========================================================== 									REGISTER STAFF UPGRADE PEDESTALS				 		========================================================== */
		
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( 																"scriptmover",								AIRSTAFF_AOE_CF, 													VERSION_SHIP, 1, "int" 																														 );
	clientfield::register( 																"actor", 										AIRSTAFF_LAUNCH_ZOMBIE_CF, 								VERSION_SHIP, 1, "int"																															 );
	clientfield::register( 																"scriptmover", 								AIRSTAFF_SET_LAUNCH_SOURCE_CF, 						VERSION_SHIP, 1, "int"																															 );
	clientfield::register( 																"actor", 										AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF, 	VERSION_SHIP, 1, "int"																															 );
	clientfield::register( 																"vehicle", 										AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF, 	VERSION_SHIP, 1, "int"																															 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	zm::register_actor_damage_callback( 									&staff_air_actor_damage_cb																																																														 );
	zm::register_vehicle_damage_callback( 									&staff_air_vehicle_damage_cb																																																													 );
	zm_spawner::register_zombie_damage_callback( 					&staff_air_zombie_damage_cb 																																																													 );
	zm_spawner::register_zombie_death_event_callback( 				&staff_air_death_event_cb																																																															 );
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	
	// TO MOVE
	spawner::add_archetype_spawn_function( 								"parasite", 									&staff_air_parasite_init_cb, 										undefined, 			undefined, 	undefined, 	undefined, 	undefined														 );
	spawner::add_archetype_spawn_function( 								"zombie_dog", 								&staff_air_dog_init_cb, 												undefined, 			undefined, 	undefined, 	undefined, 	undefined														 );
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
STAFF AIR REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of air variant and sets up some required properties
Notes : None
*/
function staff_air_register_weapon_for_level( str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined )
{
	DEFAULT( level.a_staff_air_weaponfiles, 								[]																																																							 );
	
	a_weapon_data 																	= tableLookupRow( STAFF_AIR_TABLE_FILE, 	tableLookupRowNum( STAFF_AIR_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, 	str_weapon	 )	 );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data 																= tableLookupRow( STAFF_AIR_TABLE_FILE, 	tableLookupRowNum( STAFF_AIR_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, 	"default"		 )	 );
	if ( !isDefined( a_weapon_data ) )	
		return;
	
	w_weapon 																			= getWeapon( 	str_weapon																																													 );
	w_weapon.b_is_upgrade															= ( toLower( 	a_weapon_data[ STAFF_TABLE_COLUMN_IS_UPGRADE ] ) == "true"																								 );
	w_weapon.n_damage																= int( 				a_weapon_data[ STAFF_TABLE_COLUMN_DAMAGE ]																														 );
	w_weapon.n_cone_fov															= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_CONE_FOV ]																												 );
	w_weapon.n_cone_range														= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_CONE_RANGE ]																											 );
	w_weapon.b_whirlwind_supercharged 									=	( toLower( 	a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_SUPERCHARGED ] ) == "true"																 );
	w_weapon.n_whirlwind_lifetime												= float( 			a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_LIFETIME ]																								 );
	w_weapon.n_whirlwind_range													= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_RANGE ]																								 );
	
	hb21_zm_weap_staff_utility::register_staff_weapon_for_level( 	w_weapon, 													ptr_weapon_fired_cb, ptr_weapon_missile_fired_cb, ptr_weapon_grenade_fired_cb, ptr_weapon_obtained_cb, ptr_weapon_lost_cb, ptr_weapon_reloaded_cb, ptr_weapon_pullout_cb, ptr_weapon_putaway_cb );
	
	ARRAY_ADD( 																		level.a_staff_air_weaponfiles, 						w_weapon																																			 );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
STAFF AIR ACTOR DAMAGE CB
Description : This function handles the damage modifications when a zombie is hit from a Staff of Air
Notes : None
*/
function staff_air_actor_damage_cb( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) )
		return -1;
	
	if ( hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_upgraded_immune ) )
		return 0;
	else if ( !hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	playSoundAtPosition( AIRSTAFF_AOE_IMPACT_SOUND, v_point );
	if ( isDefined( self.ptr_staff_air_actor_damage_cb ) )
		return [ [ self.ptr_staff_air_actor_damage_cb ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );
	
	return -1;
}

/* 
STAFF AIR VEHICLE DAMAGE CB
Description : This function handles the damage modifications when a zombie vehicle is hit from a Staff of Air
Notes : None
*/
function staff_air_vehicle_damage_cb( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return n_damage;
	
	if ( !isDefined( self.damageweapon ) || self.damageweapon != w_weapon )
		self.damageweapon = w_weapon;
	if ( !isDefined( self.damagemod ) || self.damagemod != str_means_of_death )
		self.damagemod = str_means_of_death;
	if ( !isDefined( self.damagehit_origin ) || self.damagehit_origin != v_point )
		self.damagehit_origin = v_point;
	if ( !isDefined( self.damagelocation ) || self.damagelocation != str_hit_loc )
		self.damagelocation = str_hit_loc;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) )
		return n_damage;
	
	if ( hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_upgraded_immune ) )
		return 0;
	else if ( !hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return n_damage;
	
	playSoundAtPosition( AIRSTAFF_AOE_IMPACT_SOUND, v_point );
	if ( isDefined( self.ptr_staff_air_vehicle_damage_cb ) )
		return [ [ self.ptr_staff_air_vehicle_damage_cb ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );
	
	return n_damage;
}

/* 
STAFF AIR ZOMBIE DAMAGE CB
Description : This function handles the reaction when a zombie is hit from a Staff of Wind
Notes : None
*/
function staff_air_zombie_damage_cb( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.ptr_staff_air_zombie_damage_cb ) )
		return [ [ self.ptr_staff_air_zombie_damage_cb ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	else
		self thread zombie_utility::setup_zombie_knockdown( e_inflictor );
	
	return 1;
}

/* 
STAFF AIR DEATH EVENT CB
Description : This function handles logic for zombies killed by the Staff of Wind
Notes : None
*/
function staff_air_death_event_cb( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !hb21_zm_weap_staff_utility::is_staff_weapon( self.damageweapon, level.a_staff_air_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	self [ [ ( isDefined( self.ptr_staff_air_death_cb ) ? self.ptr_staff_air_death_cb : &staff_air_fling_zombie_death ) ] ]( e_attacker, self.damagemod );	
}

/* 
STAFF AIR DO DAMAGE CB
Description : This function runs callbacks or deals the appropriate damage to a zombie hit by the Staff of Wind
Notes : None
*/
function staff_air_do_damage_cb( e_player, w_weapon, n_damage_override = undefined, str_means_of_death = "MOD_IMPACT" )
{
	if ( IS_TRUE( self.missingLegs ) && ( isDefined( n_damage_override ) ? n_damage_override : w_weapon.n_damage ) < self.health )
		n_damage_override = self.health + 666;
	
	self hb21_zm_weap_staff_utility::staff_do_damage( n_damage_override, undefined, e_player, undefined, undefined, str_means_of_death, undefined, w_weapon, undefined, undefined );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/* 
STAFF AIR FIRED
Description : This function handles when a player fires a Staff of Wind
Notes : None
*/
function staff_air_fired( e_projectile, w_weapon, n_charge_level )
{
	staff_air_update_source_origin( self.origin );
	e_projectile thread hb21_zm_weap_staff_utility::projectile_delete( AIRSTAFF_PROJECTILE_DELETE_DELAY );
	self staff_air_damage_cone( w_weapon );
}

/* 
STAFF AIR UPGRADE FIRED
Description : This function handles when a player fires a Staff of Wind that is upgraded and charged
Notes : None
*/
function staff_air_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_air_whirlwind_find_source( self, w_weapon );
}

/* 
STAFF AIR DAMAGE CONE
Description : This function handles logic for the Staff of Wind uncharged attack
Notes : None
*/
function staff_air_damage_cone( w_weapon )
{
	a_targets = util::get_array_of_closest( 	self.origin, 			getAITeamArray( level.zombie_team ), 	undefined, 						undefined, 										w_weapon.n_cone_range 																					);
	a_targets = array::clamp_size( 			self array::filter( 	a_targets, 											1, 									&staff_air_check_zombie_hit_valid, 	self, 								w_weapon 	), 	AIRSTAFF_FLING_MAX_AI_CHECK 	);
	array::run_all( 										a_targets, 			&staff_air_do_damage_cb, 					self, 								w_weapon																																									);

}

/* 
STAFF AIR CHECK ZOMBIE HIT VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind uncharged attack
Notes : None
*/
function staff_air_check_zombie_hit_valid( e_ai_zombie, e_player, w_weapon )
{
	return ( staff_air_trace_passed( e_player.origin, e_ai_zombie.origin ) && !IS_TRUE( e_ai_zombie.b_staff_air_cone_immune ) && util::within_fov( self getPlayerCameraPos(), self getPlayerAngles(), e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_air_fling_tag_check_override ) ? e_ai_zombie.str_staff_air_fling_tag_check_override : AIRSTAFF_FLING_TAG_CHECK ) ), cos( w_weapon.n_cone_fov ) ) );
}

/* 
STAFF AIR FLING ZOMBIE DEATH
Description : This function handles logic for zombies killed by the Staff of Wind uncharged attack
Notes : None
*/
function staff_air_fling_zombie_death( e_attacker, str_means_of_death = "MOD_IMPACT" )
{
	if ( str_means_of_death == "MOD_MELEE" )
		return;
	
	if ( IS_TRUE( self.in_the_ceiling ) || IS_TRUE( self.in_the_ground ) || str_means_of_death == "MOD_UNKNOWN" || IS_TRUE( self.b_staff_air_whirlwind_source ) || ( !math::cointoss() && !math::cointoss() ) )
		self [ [ ( math::cointoss() ? &hb21_zm_weap_staff_utility::zombie_gib_all : &hb21_zm_weap_staff_utility::zombie_gib_guts ) ] ]( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : AIRSTAFF_GIB_FX_TAG ) );
	else
		self thread staff_air_launch_zombie();
		
}

/* 
STAFF AIR LAUNCH ZOMBIE
Description : This function handles logic for zombies killed by the Staff of Wind fling logic
Notes : None
*/
function staff_air_launch_zombie()
{
	// assert( isDefined( self ), "STAFF AIR - self not defined" ); CHECK
	self endon( "entityshutdown" );
	
	if ( isVehicle( self ) )
		return;
	
	self startRagDoll();
	if ( IS_TRUE( AIRSTAFF_FLING_USE_SERVERSIDE ) )
	{
		v_direction = vectorNormalize( self.origin - level.e_staff_air_launch_source.origin );
		v_launch = vectorScale( ( v_direction[ 0 ], v_direction[ 1 ], randomFloatRange( AIRSTAFF_FLING_MIN_UPWARD, AIRSTAFF_FLING_MAX_UPWARD ) ), ( length( v_direction ) * AIRSTAFF_FLING_MAX_FORCE ) );
		WAIT_SERVER_FRAME;
		self launchRagdoll( v_launch );
		self clientfield::set( AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF, 1 );
	}
	else
		self clientfield::set( AIRSTAFF_LAUNCH_ZOMBIE_CF, 1 );
	
}

/* 
STAFF AIR WHIRLWIND FIND SOURCE
Description : This function handles logic for the Staff of Wind's upgraded charged attack
Notes : None
*/
function staff_air_whirlwind_find_source( e_player, w_weapon )
{
	e_player endon( "death_or_disconnect" );
	
	v_initial_origin = e_player.origin;
	e_projectile = undefined;
	while ( !isDefined( e_projectile ) || e_projectile != self )
		e_player waittill( "projectile_impact", w_weapon, v_impact_origin, n_radius, e_projectile, v_normal );
		
	e_ai_zombie_impacted = staff_air_whirlwind_impact_ai_check( v_impact_origin );
	if ( isDefined( e_ai_zombie_impacted ) )
	{
		staff_air_update_source_origin( v_initial_origin );
		v_impact_origin = e_ai_zombie_impacted.origin;
		v_origin = e_ai_zombie_impacted getTagOrigin( ( isDefined( e_ai_zombie_impacted.str_staff_air_whirlwind_tag_check ) ? e_ai_zombie_impacted.str_staff_air_whirlwind_tag_check : AIRSTAFF_WHIRLWIND_TAG_CHECK ) );
		e_ai_zombie_impacted staff_air_do_damage_cb( e_player, w_weapon, -1, "MOD_UNKNOWN" );
		e_player staff_air_whirlwind_proximity_kill( v_origin, w_weapon );
	}
	e_player thread staff_air_position_whirlwind( v_impact_origin, w_weapon );
}

/* 
STAFF AIR WHIRLWIND IMPACT AI CHECK
Description : Checks and registers for the Staff of Wind's charged projectile impacting a zombie
Notes : None
*/
function staff_air_whirlwind_impact_ai_check( v_impact_origin )
{
	a_zombies = staff_air_whirlwind_proximity_impacted_zombies( v_impact_origin );
	if ( !isDefined( a_zombies ) || !isArray( a_zombies ) || a_zombies.size < 1 )
		return undefined;
	
	a_zombies[ 0 ].b_staff_air_whirlwind_source = 1;
	return a_zombies[ 0 ];
}

/* 
STAFF AIR WHIRLWIND PROXIMITY IMPACTED ZOMBIES
Description : Returns an array of zombies directly hit by the Staff of Wind's charge attack projectile
Notes : None
*/
function staff_air_whirlwind_proximity_impacted_zombies( v_impact_origin )
{
	return array::filter( util::get_array_of_closest( v_impact_origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_proximity_impact_zombie_valid, v_impact_origin );	
}

/* 
STAFF AIR WHIRLWIND PROXIMITY IMPACT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack projectile
Notes : None
*/
function staff_air_whirlwind_proximity_impact_zombie_valid( e_ai_zombie, v_impact_origin )
{
	return ( distance2dSquared( v_impact_origin, e_ai_zombie.origin ) < SQR( AIRSTAFF_WHIRLWIND_PROXIMITY_RANGE ) );
}

/* 
STAFF AIR WHIRLWIND PROXIMITY KILL
Description : This function handles logic for zombies killed by the Staff of Wind's charged projectile impacting a zombie
Notes : None
*/
function staff_air_whirlwind_proximity_kill( v_whirlwind_origin, w_weapon )
{
	self endon( "death_or_disconnect" );
	a_zombies 		= staff_air_whirlwind_impact_effected_zombies( v_whirlwind_origin, SQR( w_weapon.n_whirlwind_range ) );
	array::run_all( 	a_zombies, &staff_air_do_damage_cb, self, w_weapon, -1 );	
}

/* 
STAFF AIR WHIRLWIND IMPACT EFFECTED ZOMBIES
Description : Returns an array of zombies in the Staff of Wind's charge attack area of effect
Notes : None
*/
function staff_air_whirlwind_impact_effected_zombies( v_whirlwind_origin, n_whirlwind_range_sq ) // CHECK - is this considering geometry obstructions?
{
	return array::filter( util::get_array_of_closest( v_whirlwind_origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_impact_zombie_valid, v_whirlwind_origin, n_whirlwind_range_sq );
}

/* 
STAFF AIR WHIRLWIND IMPACT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack
Notes : None
*/
function staff_air_whirlwind_impact_zombie_valid( e_ai_zombie, v_whirlwind_origin, n_proximity_range_sq )
{
	return ( !IS_TRUE( e_ai_zombie.b_staff_air_cone_immune ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_immune ) && distanceSquared( e_ai_zombie.origin, v_whirlwind_origin ) < n_proximity_range_sq && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_source ) && staff_air_trace_passed( v_whirlwind_origin, e_ai_zombie.origin ) );
}

/* 
STAFF AIR POSITION WHIRLWIND
Description : This function is the logic for the Staff of Wind's charged attack
Notes : None
*/
function staff_air_position_whirlwind( v_impact_origin, w_weapon )
{
	e_fx_model = util::spawn_model( "tag_origin", v_impact_origin, ( -90, 0, 0 ) );
	e_fx_model endon( "death" );
	
	v_impact_origin = e_fx_model zm_utility::groundpos_ignore_water_new( v_impact_origin );
	
	e_fx_model moveTo( v_impact_origin, .05 );
	e_fx_model waittill( "movedone" );
	
	e_fx_model clientfield::set( AIRSTAFF_AOE_CF, 1 );

	wait .5;
	e_fx_model thread staff_air_whirlwind_kill_zombies( w_weapon, self );
	
	wait w_weapon.n_whirlwind_lifetime - .5;
	
	staff_air_update_source_origin( v_impact_origin );
	
	e_fx_model notify( "staff_air_whirlwind_over" );
	e_fx_model clientfield::set( AIRSTAFF_AOE_CF, 0 );
	
	wait 1.5;
	e_fx_model delete();
}


/* 
STAFF AIR WHIRLWIND KILL ZOMBIES
Description : This function handles logic for the Staff of Wind's upgraded charged attack sucking zombies in
Notes : None
*/
function staff_air_whirlwind_kill_zombies( w_weapon, e_player )
{
	e_player endon( "death_or_disconnect" );
	self endon( "death" );
	self endon( "staff_air_whirlwind_over" );
	
	while ( isDefined( self ) )
	{
		array::thread_all( self staff_air_whirlwind_effected_zombies( w_weapon ), &staff_air_whirlwind_drag_zombie, self, w_weapon, e_player );
		wait .1;
	}
}

/* 
STAFF AIR WHIRLWIND EFFECTED ZOMBIES
Description : Returns an array of zombies in the Staff of Wind's charge attack area of effect
Notes : None
*/
function staff_air_whirlwind_effected_zombies( w_weapon )
{
	return self array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_effect_zombie_valid, w_weapon );
}

/* 
STAFF AIR WHIRLWIND EFFECT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack
Notes : None
*/
function staff_air_whirlwind_effect_zombie_valid( e_ai_zombie, w_weapon )
{
	return ( !IS_TRUE( e_ai_zombie.in_the_ground ) && !IS_TRUE( e_ai_zombie.in_the_ceiling ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_immune ) && !IS_TRUE( e_ai_zombie.b_staff_hit ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_attract ) && staff_air_whirlwind_range_and_trace_passed( e_ai_zombie, w_weapon ) );
}

/* 
STAFF AIR WHIRLWIND RANGE AND TRACE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack
Notes : None
*/
function staff_air_whirlwind_range_and_trace_passed( e_ai_zombie, w_weapon )
{
	return ( staff_air_distance_passed( self.origin, e_ai_zombie.origin, w_weapon.n_whirlwind_range, e_ai_zombie.n_staff_air_whirlwind_range_check_multiplier ) && staff_air_trace_passed( self.origin, e_ai_zombie.origin ) );
}

/* 
STAFF AIR WHIRLWIND DRAG ZOMBIE
Description : This function handles setting up the initial logic for the Staff of Wind's upgraded charged attack pulling a zombie to the whirlwind
Notes : None
*/
function staff_air_whirlwind_drag_zombie( e_whirlwind, w_weapon, e_player )
{
	self endon( "death" );
	if ( self isPlayingAnimScripted() )
		self stopAnimScripted();
	
	self.b_staff_hit = 1;
	self.b_staff_air_whirlwind_attract = 1;
	
	self hb21_zm_weap_staff_utility::disable_pain_and_reaction();
	self hb21_zm_weap_staff_utility::disable_find_flesh();
	
	self hb21_zm_weap_utility::create_linker_entity( self.origin + ( isDefined( self.v_staff_air_drag_linker_offset ) ? self.v_staff_air_drag_linker_offset : ( 0, 0, 0 ) ), self.angles, "tag_origin", vectorToAngles( self.origin - e_whirlwind.origin ) );
	
	str_means_of_death = undefined;
	str_means_of_death = self staff_air_whirlwind_zombie_drag_logic( e_whirlwind, w_weapon, e_player );
		
	self staff_air_do_damage_cb( e_player, w_weapon, -1, ( isDefined( str_means_of_death ) ? str_means_of_death : "MOD_IMPACT" ) );
}

/* 
STAFF AIR WHIRLWIND DRAG ZOMBIE LOGIC
Description : This function handles logic for the Staff of Wind's upgraded charged attack pulling a zombie to the whirlwind
Notes : None
*/
function staff_air_whirlwind_zombie_drag_logic( e_whirlwind, w_weapon, e_player )
{
	self endon( "death" );
	e_whirlwind endon( "staff_air_whirlwind_over" );
		
	while ( distance2dSquared( e_whirlwind.origin, self.origin ) > SQR( AIRSTAFF_WHIRLWIND_KILL_RADIUS ) )
	{
		b_staff_air_whirlwind_supercharged = ( ( IS_TRUE( self.missingLegs ) || IS_TRUE( w_weapon.b_whirlwind_supercharged ) ) ? 1 : 0 );		
		self thread staff_air_whirlwind_drag_along_ground( e_whirlwind.origin, b_staff_air_whirlwind_supercharged );
		
		WAIT_SERVER_FRAME;
	}
	
	return "MOD_UNKNOWN";
}
/* 
STAFF AIR WHIRLWIND DRAG ALONG GROUND
Description : This function handles logic for the Staff of Wind's upgraded charged attack pulling a zombie to the whirlwind
Notes : None
*/
function staff_air_whirlwind_drag_along_ground( v_position, b_staff_air_whirlwind_supercharged )
{
	// assert( isDefined( self.e_linker ), "no linker entity" );
	Blackboard::SetBlackBoardAttribute( self, WHIRLWIND_SPEED, ( IS_TRUE( b_staff_air_whirlwind_supercharged ) ? WHIRLWIND_FAST : WHIRLWIND_NORMAL ) );
	self.e_linker moveTo( zm_utility::groundpos_ignore_water_new( self.origin + vectorScale( vectorNormalize( v_position - self.origin ), 50 ) ), ( IS_TRUE( b_staff_air_whirlwind_supercharged ) ? AIRSTAFF_WHIRLWIND_DRAG_FAST_TIME : AIRSTAFF_WHIRLWIND_DRAG_TIME ) );
}

/* 
STAFF AIR DISTANCE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack
Notes : None
*/
function staff_air_distance_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range ) * n_range_multiplier );
}

/* 
STAFF AIR TRACE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Wind charged attack
Notes : None
*/
function staff_air_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1 )
{
	return ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
}

// ============================== FUNCTIONALITY ==============================

// ============================== DEVELOPER ==============================

/* 
STAFF AIR UPDATE SOURCE ORIGIN
Description : This function moves the global object to the new origin and sets a clientfield toggle
Notes : Will create the global object first if one does not exist
*/
function staff_air_update_source_origin( v_origin )
{
	if ( !isDefined( level.e_staff_air_launch_source ) )
	{
		level.e_staff_air_launch_source = util::spawn_model( "tag_origin", v_origin, ( 0, 0, 0 ) );
		level.e_staff_air_launch_source clientfield::set( AIRSTAFF_SET_LAUNCH_SOURCE_CF, 1 );
	}
	else
		level.e_staff_air_launch_source.origin = v_origin;
	
}

// ============================== DEVELOPER ==============================

// ============================== EVENT OVERRIDES ==============================

function staff_air_parasite_init_cb()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
	self.str_staff_air_fling_tag_check_override = "j_spine";
	self.v_staff_air_drag_linker_offset = ( 0, 0, -64 );
	self.ptr_staff_air_death_cb = &staff_air_parasite_death_cb;
	self.n_staff_air_whirlwind_range_check_multiplier = 1.8;
}

function staff_air_parasite_death_cb( e_attacker, str_means_of_death = "MOD_IMPACT" )
{
	self thread hb21_zm_weap_staff_utility::zombie_gib_guts( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : AIRSTAFF_GIB_FX_TAG ) );
}

function staff_air_dog_init_cb()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
	self.str_staff_air_fling_tag_check_override = "j_spine";
	self.v_staff_air_drag_linker_offset = ( 0, 0, -64 );
	// self.ptr_staff_air_death_cb = &staff_air_parasite_death_cb;
	// self.n_staff_air_whirlwind_range_check_multiplier = 1.8;
}

// ============================== EVENT OVERRIDES ==============================