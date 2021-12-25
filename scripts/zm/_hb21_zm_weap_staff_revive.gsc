/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###           	Harry Bo21s Black Ops 3 Staff of Revive				   ###
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
#using scripts\shared\laststand_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_revive.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#namespace hb21_zm_weap_staff_revive; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_revive", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None  
*/
function __init__()
{	
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	level.a_staff_revive_weaponfiles = [];
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	staff_revive_register_weapon_for_level( REVIVESTAFF_WEAPON, undefined, undefined, undefined, &staff_revive_weapon_obtained_cb, &staff_revive_weapon_lost_cb );
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	zm::register_player_friendly_fire_callback( &staff_revive_friendly_fire_cb );
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
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
STAFF REVIVE REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of fire variant and sets up some required properties
Notes : None
*/
function staff_revive_register_weapon_for_level( str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined )
{
	DEFAULT( level.a_staff_revive_weaponfiles, 						[] 																																																										 );
		
	w_weapon 																			= getWeapon( str_weapon );
	w_weapon.b_is_upgrade															= 0;
	
	hb21_zm_weap_staff_utility::register_staff_weapon_for_level( 	w_weapon, 												ptr_weapon_fired_cb, ptr_weapon_missile_fired_cb, ptr_weapon_grenade_fired_cb, &staff_revive_weapon_obtained_cb, ptr_weapon_lost_cb, ptr_weapon_reloaded_cb, ptr_weapon_pullout_cb, ptr_weapon_putaway_cb );
	
	ARRAY_ADD( 																		level.a_staff_revive_weaponfiles, 				w_weapon																																							 );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
STAFF REVIVE WEAPON OBTAINED CB
Description : This function is logic for a player obtaining a upgraded staff weapon
Notes : None  
*/
function staff_revive_weapon_obtained_cb( w_weapon )
{
	
}

/* 
STAFF REVIVE WEAPON LOST CB
Description : This function is logic for a player dropping a upgraded staff weapon
Notes : None  
*/
function staff_revive_weapon_lost_cb( w_weapon )
{
	
}

/* 
STAFF REVIVE FRIENDLY FIRE CB
Description : This function is logic for a players being hit by a Staff of Revive
Notes : None  
*/
function staff_revive_friendly_fire_cb( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index )
{
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_revive_weaponfiles ) )
		return;
	
	if ( self != e_attacker && self laststand::player_is_in_laststand() )
	{
		self notify( "remote_revive", e_attacker );
		self playSoundToPlayer( "wpn_revivestaff_revive_plr", e_attacker );
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== DEVELOPER ==============================

// ============================== DEVELOPER ==============================

// ============================== EVENT OVERRIDES ==============================

// ============================== EVENT OVERRIDES ==============================