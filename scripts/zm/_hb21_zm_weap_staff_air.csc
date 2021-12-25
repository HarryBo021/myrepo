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
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_air.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#precache( "client_fx", AIRSTAFF_IMPACT_FX );
#precache( "client_fx", AIRSTAFF_AOE_FX );
#precache( "client_fx", AIRSTAFF_CHARGE_LIGHT_FX );
#precache( "client_fx", AIRSTAFF_UPGRADE_GLOW );

#namespace hb21_zm_weap_staff_air; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_air", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ai.str_staff_air_gib_fx_tag - STRING - set a tag name here to have the gib fx play on that tag, will default to "j_spine4" otherwise. Use this if your ai does NOT have this tag

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
	level.a_staff_air_weaponfiles 				= [];
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	staff_air_register_weapon_for_level( 	AIRSTAFF_WEAPON																																																																										 );
	staff_air_register_weapon_for_level( 	AIRSTAFF_UPGRADED_WEAPON																																																																						 );
	staff_air_register_weapon_for_level( 	AIRSTAFF_UPGRADED_WEAPON2																																																																					 );
	staff_air_register_weapon_for_level( 	AIRSTAFF_UPGRADED_WEAPON3																																																																					 );
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( 							"scriptmover",								AIRSTAFF_AOE_CF,													VERSION_SHIP, 1, "int", &staff_air_whirlwind_fx,				!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );
	clientfield::register( 							"scriptmover", 								AIRSTAFF_SET_LAUNCH_SOURCE_CF, 						VERSION_SHIP, 1, "int", &staff_air_set_launch_source,		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );
	clientfield::register( 							"actor",											AIRSTAFF_LAUNCH_ZOMBIE_CF, 								VERSION_SHIP, 1, "int", &staff_air_launch_zombie,				!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );
	clientfield::register( 							"actor", 										AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF, 	VERSION_SHIP, 1, "int", &staff_air_ragdoll_impact_watch,	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );
	clientfield::register( 							"vehicle", 										AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF, 	VERSION_SHIP, 1, "int", &staff_air_ragdoll_impact_watch,	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	// TO MOVE
	ai::add_archetype_spawn_function( 	"parasite", 									&staff_air_parasite_init_cb																																																											 );
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
function staff_air_register_weapon_for_level( str_weapon )
{
	DEFAULT( level.a_staff_air_weaponfiles, 								[]																																																											 );
	
	a_weapon_data 																	= tableLookupRow( STAFF_AIR_TABLE_FILE, 	tableLookupRowNum( STAFF_AIR_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, 	str_weapon	 )					 );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data 																= tableLookupRow( STAFF_AIR_TABLE_FILE, 	tableLookupRowNum( STAFF_AIR_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, 	"default"		 )					 );
	if ( !isDefined( a_weapon_data ) )	
		return;
	
	w_weapon 																			= getWeapon( 	str_weapon																																																	 );
	w_weapon.b_is_upgrade															= ( toLower( 	a_weapon_data[ STAFF_TABLE_COLUMN_IS_UPGRADE ] ) == "true"																												 );
	w_weapon.n_damage																= int( 				a_weapon_data[ STAFF_TABLE_COLUMN_DAMAGE ]																																		 );
	w_weapon.n_cone_fov															= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_CONE_FOV ]																																 );
	w_weapon.n_cone_range														= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_CONE_RANGE ]																															 );
	w_weapon.b_whirlwind_supercharged 									=	( toLower( 	a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_SUPERCHARGED ] ) == "true"																				 );
	w_weapon.n_whirlwind_lifetime												= float( 			a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_LIFETIME ]																												 );
	w_weapon.n_whirlwind_range													= int( 				a_weapon_data[ STAFF_AIR_TABLE_COLUMN_WHIRLWIND_RANGE ]																												 );
	
	hb21_zm_weap_staff_utility::register_staff_weapon_for_level(	w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_air_charge_up_effects_cb, undefined, AIRSTAFF_CHARGE_LIGHT_FX														 );

	ARRAY_ADD( 																		level.a_staff_air_weaponfiles, 						w_weapon																																							 );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
STAFF AIR UPDATE CHARGE EFFECTS
Description : This function handles the effects and sounds when the charge level changes
Notes : None
*/
function staff_air_charge_up_effects_cb( n_local_client_num, w_weapon, n_charge_level )
{
	self hb21_zm_weap_staff_utility::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, AIRSTAFF_CHARGE_SOUND + n_charge_level, ( n_charge_level == 1 ? AIRSTAFF_CHARGE_LOOP_SOUND : undefined ) );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/* 
STAFF AIR WHIRLWIND FX 
Description : This function creates or destroys the area of effect on an entity
Notes : None 
*/
function staff_air_whirlwind_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_staff_air_whirlwind = playFxOnTag( n_local_client_num, AIRSTAFF_AOE_FX, self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, AIRSTAFF_RUMBLE );
		self thread hb21_zm_weap_staff_utility::staff_shake_and_rumble( n_local_client_num, AIRSTAFF_RUMBLE_SCALE, AIRSTAFF_RUMBLE_DURATION, AIRSTAFF_RUMBLE_RADIUS, AIRSTAFF_RUMBLE );
		self thread hb21_zm_weap_staff_utility::staff_aoe_looping_sound( n_local_client_num, AIRSTAFF_AOE_LOOP_SOUND, undefined, undefined, .5, 1.5 );
	}
	else
	{
		playFx( n_local_client_num, AIRSTAFF_IMPACT_FX, self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_staff_air_whirlwind );
		self.fx_staff_air_whirlwind = undefined;
	}
}

/* 
STAFF AIR SET LAUNCH SOURCE
Description : This function defines the entity to use as the point of origin for the next zombies we ragdoll launch
Notes : None
*/
function staff_air_set_launch_source( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( !isDefined( level.e_staff_air_launch_source ) )
		level.e_staff_air_launch_source = self;

}

/* 
STAFF AIR LAUNCH ZOMBIE
Description : This function handles logic for zombies killed by the Staff of Wind fling logic
Notes : None
*/
function staff_air_launch_zombie( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self endon( "entityshutdown" );
	util::server_wait( n_local_client_num, .05, CLIENT_FRAME );
	v_direction = vectorNormalize( self.origin - level.e_staff_air_launch_source.origin );
	v_launch = vectorScale( ( v_direction[ 0 ], v_direction[ 1 ], randomFloatRange( AIRSTAFF_FLING_MIN_UPWARD, AIRSTAFF_FLING_MAX_UPWARD ) ), ( length( v_direction ) * AIRSTAFF_FLING_MAX_FORCE ) );
	self launchRagdoll( v_launch );
	self thread staff_air_ragdoll_impact_watch( n_local_client_num, 0, 1 );
}

/* 
STAFF AIR RAGDOLL IMPACT WATCH
Description : This function makes a ragdoll zombie burst in to blood if it impacts collision travelling over a defined speed
Notes : None
*/
function staff_air_ragdoll_impact_watch( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( !IS_TRUE( n_new_value ) )
		return;
	
	self endon( "entityshutdown" );
 
 	self.v_start_pos = self.origin;
 
	v_prev_origin = self.origin;
	waitRealTime( AIRSTAFF_FLING_IMPACT_WAIT_TIMER );

	v_prev_vel = self.origin - v_prev_origin;
	n_prev_speed = length( v_prev_vel );
	v_prev_origin = self.origin;
	waitRealTime( AIRSTAFF_FLING_IMPACT_WAIT_TIMER );

	b_first_loop = 1;

	while ( isDefined( self ) )
	{
 		v_vel = self.origin - v_prev_origin;
		n_speed = length( v_vel );

		if ( n_speed < n_prev_speed * .5 && !b_first_loop )
		{
			if ( n_prev_speed < AIRSTAFF_FLING_IMPACT_BURST_SPEED && self.origin[ 2 ] < ( self.v_start_pos[ 2 ] + 128 ) )
				break;
			
			playFX( n_local_client_num, level._effect[ "zombie_guts_explosion" ], self getTagOrigin( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : AIRSTAFF_GIB_FX_TAG ) ) );
			self hide();
			break;
 		}

		v_prev_origin = self.origin;
		n_prev_speed = n_speed;
		b_first_loop = 0;

		waitRealTime( AIRSTAFF_FLING_IMPACT_WAIT_TIMER );
	}      
}

// ============================== FUNCTIONALITY ==============================

// ============================== EVENT OVERRIDES ==============================

function staff_air_parasite_init_cb()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
}

// ============================== EVENT OVERRIDES ==============================