/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###           		Harry Bo21s Black Ops 3 Staff of Ice				   ###
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
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_water.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#namespace hb21_zm_weap_staff_water; 

#precache( "model", 		WATERSTAFF_MODEL );
#precache( "model", 		WATERSTAFF_UPGRADED_MODEL );
#precache( "model", 		WATERSTAFF_PLINTH_MODEL );
#precache( "model", 		WATERSTAFF_PLINTH_BASE_MODEL );

#precache( "fx", 			WATERSTAFF_UPGRADE_GLOW );
#precache( "fx", 			WATERSTAFF_SHATTER_FX );

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_water", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ai.b_staff_water_immune - BOOLEAN - enable on ai to stop the Staff of Ice damaging them
// ai.b_staff_water_upgraded_immune - BOOLEAN - enable on ai to stop the upgraded Staff of Ice damaging them

// ai.ptr_staff_water_actor_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Ice on actors
// ai.ptr_staff_water_vehicle_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Ice on vehicles

// ai.ptr_staff_water_zombie_damage_cb - FUNCTION_POINTER - set your own function here to change what happens when a zombie is hit by the Staff of Ice
// ai.ptr_staff_water_death_cb - FUNCTION_POINTER - - set your own function here to change the death behavior when killed by the Staff of Ice

// ai.b_staff_fire_volcano_immune - BOOLEAN - enable on ai to stop the volcano being able to effect them at all
// ai.n_staff_fire_volcano_range_check_multiplier - FLOAT - option to increase the distance checks used in the volcano logic checks - can be important on flying AI as their height from the ground has a dramatic impact vs an ai on the ground
// ai.str_staff_fire_volcano_tag_check_override - STRING - set a tag name here to have the charge attack check for impact with an ai, will default to "j_spineupper" otherwise. Use this if your ai does NOT have this tag

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
	level.a_staff_water_weaponfiles = [];
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	staff_water_register_weapon_for_level( WATERSTAFF_WEAPON, undefined, &staff_water_fired );
	staff_water_register_weapon_for_level( WATERSTAFF_UPGRADED_WEAPON, undefined, &staff_water_fired );
	staff_water_register_weapon_for_level( WATERSTAFF_UPGRADED_WEAPON2, undefined, &staff_water_upgrade_fired );
	staff_water_register_weapon_for_level( WATERSTAFF_UPGRADED_WEAPON3, undefined, &staff_water_upgrade_fired );
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	
	/* ========================================================== 									REGISTER STAFF UPGRADE PEDESTALS				 		========================================================== */
	// hb21_zm_weap_staff_utility::staff_upgrade_pedestal_spawn( "ice", WATERSTAFF_WEAPON, WATERSTAFF_UPGRADED_WEAPON, WATERSTAFF_MODEL, WATERSTAFF_UPGRADED_MODEL, WATERSTAFF_PLINTH_MODEL, WATERSTAFF_PLINTH_BASE_MODEL, WATERSTAFF_UPGRADE_GLOW );
	/* ========================================================== 									REGISTER STAFF UPGRADE PEDESTALS				 		========================================================== */
	
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( 																	"scriptmover",										WATERSTAFF_BLIZZARD_CF,					VERSION_SHIP, 						1, 	"int"																																									 );
	clientfield::register( 																	"actor", 												WATERSTAFF_FREEZE_ZOMBIE_CF, 		VERSION_SHIP, 						1, 	"int"																																									 );
	clientfield::register( 																	"vehicle", 												WATERSTAFF_FREEZE_ZOMBIE_CF, 		VERSION_SHIP, 						1, 	"int"																																									 );
	clientfield::register( 																	"actor", 												WATERSTAFF_FREEZE_FX_CF, 				VERSION_SHIP, 						1, 	"int"																																									 );
	clientfield::register( 																	"vehicle", 												WATERSTAFF_FREEZE_FX_CF, 				VERSION_SHIP, 						1, 	"int"																																									 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	zm::register_actor_damage_callback( 										&staff_water_actor_damage_cb																																																												 );
	zm::register_vehicle_damage_callback( 										&staff_water_vehicle_damage_cb																																																											 );
	zm_spawner::register_zombie_damage_callback( 						&staff_water_zombie_damage_cb 																																																											 );
	zm_spawner::register_zombie_death_event_callback( 					&staff_water_death_event_cb																																																													 );
	
	level.ptr_staff_water_freeze_zombie = &staff_water_freeze_zombie;
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	
	// TO MOVE
	spawner::add_archetype_spawn_function( 									"parasite", 											&staff_water_parasite_init_cb																																														 );
	spawner::add_archetype_spawn_function( 									"zombie_dog", 										&staff_water_dog_init_cb																																														 );
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
STAFF WATER REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of water variant and sets up some required properties
Notes : None
*/
function staff_water_register_weapon_for_level( str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined )
{
	DEFAULT( level.a_staff_water_weaponfiles, [] );
	
	a_weapon_data 							= tableLookupRow( STAFF_WATER_TABLE_FILE, tableLookupRowNum( STAFF_WATER_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, str_weapon ) );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data 						= tableLookupRow( STAFF_WATER_TABLE_FILE, tableLookupRowNum( STAFF_WATER_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, "default" ) );
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon 									= getWeapon( str_weapon );
	w_weapon.b_is_upgrade					= ( toLower( a_weapon_data[ STAFF_TABLE_COLUMN_IS_UPGRADE ] ) == "true" );
	w_weapon.n_damage						= int( a_weapon_data[ STAFF_TABLE_COLUMN_DAMAGE ] );
	w_weapon.n_cone_fov					= int( a_weapon_data[ STAFF_WATER_TABLE_COLUMN_CONE_FOV ] );
	w_weapon.n_cone_range				= int( a_weapon_data[ STAFF_WATER_TABLE_COLUMN_CONE_RANGE ] );
	w_weapon.n_blizzard_lifetime			= float( a_weapon_data[ STAFF_WATER_TABLE_COLUMN_BLIZZARD_LIFETIME ] );
	w_weapon.n_blizzard_range			= int( a_weapon_data[ STAFF_WATER_TABLE_COLUMN_BLIZZARD_RANGE ] );
	
	hb21_zm_weap_staff_utility::register_staff_weapon_for_level( w_weapon, ptr_weapon_fired_cb, ptr_weapon_missile_fired_cb, ptr_weapon_grenade_fired_cb, ptr_weapon_obtained_cb, ptr_weapon_lost_cb, ptr_weapon_reloaded_cb, ptr_weapon_pullout_cb, ptr_weapon_putaway_cb );
	
	ARRAY_ADD( level.a_staff_water_weaponfiles, w_weapon );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
STAFF WATER ACTOR DAMAGE CB
Description : This function handles the damage modifications when a zombie is hit from a Staff of Ice
Notes : None
*/
function staff_water_actor_damage_cb( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) )
		return -1;
	
	if ( hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_upgraded_immune ) )
		return 0;
	else if ( !hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
		return 0;
	
	if ( isDefined( self.ptr_staff_water_actor_damage_cb ) )
		return [ [ self.ptr_staff_water_actor_damage_cb ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );
	
	return -1;
}

/* 
STAFF WATER VEHICLE DAMAGE CB
Description : This function handles the damage modifications when a zombie vehicle is hit from a Staff of Ice
Notes : None
*/
function staff_water_vehicle_damage_cb( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return n_damage;
	
	if ( !isDefined( self.damageweapon ) || self.damageweapon != w_weapon )
		self.damageweapon = w_weapon;
	if ( !isDefined( self.damagemod ) || self.damagemod != str_means_of_death )
		self.damagemod = str_means_of_death;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) )
		return n_damage;
	
	if ( hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_upgraded_immune ) )
		return 0;
	else if ( !hb21_zm_weap_staff_utility::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
		return 0;
	
	if ( isDefined( self.ptr_staff_water_vehicle_damage_cb ) )
		return [ [ self.ptr_staff_water_vehicle_damage_cb ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );
	
	return n_damage;
}

/* 
STAFF WATER ZOMBIE DAMAGE CB
Description : This function handles the reaction when a zombie is hit from a Staff of Ice
Notes : None
*/
function staff_water_zombie_damage_cb( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !hb21_zm_weap_staff_utility::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.ptr_staff_water_zombie_damage_cb ) )
		return [ [ self.ptr_staff_water_zombie_damage_cb ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	else if ( isDefined( level.ptr_staff_water_freeze_zombie ) )
		self thread [ [ level.ptr_staff_water_freeze_zombie ] ]();
	else
		self thread staff_water_freeze_zombie();
	
	return 1;
}

/* 
STAFF WATER DEATH EVENT CALLBACK
Description : This function handles logic for zombies killed by the Staff of Ice
Notes : None
*/
function staff_water_death_event_cb( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !hb21_zm_weap_staff_utility::is_staff_weapon( self.damageweapon, level.a_staff_water_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	if ( isDefined( self.ptr_staff_water_death_cb ) )
		self [ [ self.ptr_staff_water_death_cb ] ]( e_attacker, self.damagemod );	
	else
		self staff_water_kill_zombie();
	
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/* 
STAFF WATER FIRED
Description : This function handles when a player fires a Staff of Wind
Notes : None
*/
function staff_water_fired( e_projectile, w_weapon, n_charge_level )
{
	self thread staff_water_damage_cone( w_weapon );
}

/* 
STAFF WATER UPGRADE FIRED
Description : This function handles when a player fires a Staff of Ice that is upgraded and charged
Notes : None
*/
function staff_water_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_water_find_source( self, w_weapon, n_charge_level );
}

/* 
STAFF WATER DAMAGE CONE
Description : This function handles logic for the Staff of Ice uncharged attack
Notes : None
*/
function staff_water_damage_cone( w_weapon )
{
	v_origin = self.origin;
	v_fire_origin = self getPlayerCameraPos();
	v_fire_angles = self getPlayerAngles();
	for ( i = 0; i < WATERSTAFF_CONE_NETWORK_CHECKS; i++ )
		self staff_water_icicle_locate_target( w_weapon, v_origin, v_fire_origin, v_fire_angles );
		util::wait_network_frame();
	
}

/* 
STAFF WATER ICICLE LOCATE TARGET
Description : This function handles the unique aspects of the weapon being fired
Notes : Ported logic, think the intent was to limit it to 3 shots, each able to hit 3 zombies
*/
function staff_water_icicle_locate_target( w_weapon, v_origin, v_fire_origin, v_fire_angles )
{
	a_targets = util::get_array_of_closest( 	v_origin, 			getAITeamArray( level.zombie_team ), 	undefined, 		undefined, 											w_weapon.n_cone_range 																																	 );
	a_targets = array::clamp_size( 			array::filter( 	a_targets, 											1, 					&staff_water_check_zombie_hit_valid, 	self, 								w_weapon, 	v_fire_origin, 	v_fire_angles 	), WATERSTAFF_CONE_MAX_AI_CHECK	 );
	array::run_all( 										a_targets, 		&staff_water_damage_ai_response, 		self, 				w_weapon 																																																					 );
}

/* 
STAFF WATER CHECK ZOMBIE HIT VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Ice uncharged attack
Notes : None
*/
function staff_water_check_zombie_hit_valid( e_ai_zombie, e_player, w_weapon )
{
	b_fov_passed = ( util::within_fov( e_player getPlayerCameraPos(), e_player getPlayerAngles(), e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_water_cone_tag_check_override ) ? e_ai_zombie.str_staff_water_cone_tag_check_override : WATERSTAFF_CONE_TAG_CHECK ) ), cos( w_weapon.n_cone_fov ) ) );
	str_tag_trace = array::random( ( isDefined( e_ai_zombie.a_staff_water_cone_impact_tag_checks_array_override ) ? e_ai_zombie.a_staff_water_cone_impact_tag_checks_array_override : WATERSTAFF_CONE_IMPACT_TAGS ) );
	v_tag_origin = e_ai_zombie getTagOrigin( str_tag_trace );
	if ( !isDefined( v_tag_origin ) )
		v_tag_origin = e_ai_zombie.origin + ( 0, 0, 64 );
	
	return ( !IS_TRUE( e_ai_zombie.b_staff_water_cone_effect_immune ) && !IS_TRUE( e_ai_zombie.b_is_on_ice ) && b_fov_passed && bulletTracePassed( e_player getPlayerCameraPos(), v_tag_origin, 0, e_ai_zombie ) );
}

/* 
STAFF AIR DAMAGE AI RESPONSE
Description : This function runs callbacks or deals the appropriate damage to a zombie hit by the Staff of Wind uncharged attack
Notes : None
*/
function staff_water_damage_ai_response( e_player, w_weapon, b_will_die = 0, str_means_of_death = "MOD_RIFLE_BULLET" )
{
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( isDefined( self.ptr_staff_water_damage_cb ) )
		self [ [ self.ptr_staff_water_damage_cb ] ]( e_player, w_weapon );
	else
	{
		// if ( self isPlayingAnimScripted() )
			// self stopAnimScripted();
		b_instakill_active = ( isDefined( e_player ) && isPlayer( e_player ) && e_player zm_powerups::is_insta_kill_active() );
		if ( IS_TRUE( b_instakill_active ) )
			b_will_die = 1;
		
		self hb21_zm_weap_staff_utility::staff_do_damage( ( IS_TRUE( b_will_die ) ? self.health + 666 : w_weapon.n_damage ), self.origin, e_player, e_player, undefined, str_means_of_death, 0, w_weapon, undefined, undefined );
		
		// self doDamage( ( IS_TRUE( b_will_die ) ? self.health + 666 : w_weapon.n_damage ), self.origin, e_player, e_player, 0, str_means_of_death, 0, w_weapon );
	}
}

/* 
STAFF WATER KILL ZOMBIE
Description : This function handles logic for zombies that are killed by a Staff of Ice
Notes : None
*/
function staff_water_kill_zombie()
{
	self clientfield::set( WATERSTAFF_FREEZE_ZOMBIE_CF, 1 );
	self clientfield::set( WATERSTAFF_FREEZE_FX_CF, 1 );
	
	self asmSetAnimationRate( 1 );
	
	playSoundAtPosition( WATERSTAFF_ZOMBIE_COLLAPSE, self.origin );
	
	// self hb21_zm_weap_staff_utility::disable_pain_and_reaction();
	// self hb21_zm_weap_staff_utility::disable_find_flesh();
	
	// if ( !IS_TRUE( self.in_the_ground ) && !IS_TRUE( self.in_the_ceiling ) && !isVehicle( self ) )
	// {
	// 	// self.no_gib = 1; // CHECK - concerns this is what caused some mishaps with the parasites for example, may need to allow another override here
		// self.nodeathragdoll = 1; // CHECK - concerns this is what caused some mishaps with the parasites for example, may need to allow another override here
	// }
	// WATERSTAFF_SHATTER_NOTETRACKS
	self thread staff_water_death_anim_timeout();
	self util::waittill_any_array( WATERSTAFF_SHATTER_NOTETRACKS );
	// self util::waittill_any_timeout( 1, "shatter", "start_ragdoll" ); // , "die", "death" );
	
	if ( isDefined( self ) )
	{
		playFx( WATERSTAFF_SHATTER_FX, self getTagOrigin( ( isDefined( self.str_staff_water_gib_tag_override ) ? self.str_staff_water_gib_tag_override : "j_spinelower" ) ), anglesToForward( ( 0, randomInt( 360 ), 0 ) ) );
		self clientfield::set( WATERSTAFF_FREEZE_FX_CF, 0 );
		self thread hb21_zm_weap_staff_utility::zombie_gib_all( ( isDefined( self.str_staff_water_gib_tag_override ) ? self.str_staff_water_gib_tag_override : undefined ) );
	}
}

/* 
STAFF WATER DEATH ANIM TIMEOUT
Description : This function handles logic for zombies that are killed by a Staff of Ice but for whatever reason the required notifies to shatter them does not happen
Notes : None
*/
function staff_water_death_anim_timeout()
{
	// self endon( "death" );
	// self endon( "entityshutdown" );
	self util::waittill_any_timeout( WATERSTAFF_SHATTER_TIMEOUT, "shatter", "start_ragdoll" );
	// wait WATERSTAFF_SHATTER_TIMEOUT;
	if ( isDefined( self ) )
		self notify( "shatter" );
	
}

/* 
STAFF WATER AFFECT ZOMBIE
Description : This function handles logic for making a zombie 'freeze'
Notes : None
*/
function staff_water_freeze_zombie( b_attach_model = 0, b_skip_unfreeze = 0 )
{
	self endon( "death" );
	
	if ( isDefined( self.ptr_staff_water_damage_cb ) )
	{
		self [ [ self.ptr_staff_water_freeze_zombie_cb ] ]();
		return;
	}
	
	if ( !isDefined( self ) )
		return;
	if ( IS_TRUE( self.b_is_on_ice ) )
		return;
	if ( IS_TRUE( self.b_staff_hit ) )
		return;
	
	self.b_staff_hit = 1;
	self.b_is_on_ice = 1;
	
	self clientfield::set( WATERSTAFF_FREEZE_ZOMBIE_CF, 1 );
	self clientfield::set( WATERSTAFF_FREEZE_FX_CF, 1 );
	
	self hb21_zm_weap_staff_utility::disable_pain_and_reaction();
	self hb21_zm_weap_staff_utility::disable_find_flesh( 1 );
	
	i = 1;
	while ( i > WATERSTAFF_FREEZE_ANIM_RATE )
	{
		if ( !isDefined( self ) )
			return;
		
		i -= WATERSTAFF_FREEZE_ANIM_RATE_DECRIMENTS;
		self asmSetAnimationRate( i );
		wait .1;
	}
	self asmSetAnimationRate( 0 );
	
	wait randomFloatRange( WATERSTAFF_MIN_FREEZE_DELAY, WATERSTAFF_MAX_FREEZE_DELAY );
	
	if ( !isDefined( self ) )
		return;
	
	if ( IS_TRUE( b_skip_unfreeze ) )
		return;
	
	self clientfield::set( WATERSTAFF_FREEZE_ZOMBIE_CF, 0 );
	self clientfield::set( WATERSTAFF_FREEZE_FX_CF, 0 );
	
	i = 0;
	while ( i < 1 )
	{
		if ( !isDefined( self ) )
			return;
	
		i += WATERSTAFF_FREEZE_ANIM_RATE_DECRIMENTS;
		self asmSetAnimationRate( i );
		wait .1;
	}
	
	self asmSetAnimationRate( 1 );
		
	self.b_is_on_ice = undefined;			
	self.b_staff_hit = undefined;
	
	self hb21_zm_weap_staff_utility::enable_pain_and_reaction();
	self hb21_zm_weap_staff_utility::enable_find_flesh();
}

/* 
STAFF WATER FIND SOURCE
Description : This function handles logic for the Staff of Ice's upgraded charged attack
Notes : None
*/
function staff_water_find_source( e_player, w_weapon, n_charge_level )
{
	e_player endon( "death_or_disconnect" );
	
	e_projectile = undefined;
	while ( !isDefined( e_projectile ) || e_projectile != self )
		e_player waittill( "projectile_impact", w_weapon, v_impact_origin, n_radius, e_projectile, v_normal );
		
	e_player thread staff_water_position_source( v_impact_origin, w_weapon, n_charge_level );
}

/* 
STAFF WATER POSITION SOURCE
Description : This function handles logic for the upgraded Staff of Ice's area of effect charge attack
Notes : None
*/
function staff_water_position_source( v_impact_origin, w_weapon, n_charge_level )
{
	e_fx_model = util::spawn_model( "tag_origin", v_impact_origin );
	e_fx_model endon( "death" );
	
	v_impact_origin = e_fx_model zm_utility::groundpos_ignore_water_new( v_impact_origin );
	
	e_fx_model moveTo( v_impact_origin, .05 );
	e_fx_model waittill( "movedone" );
	
	e_fx_model clientfield::set( WATERSTAFF_BLIZZARD_CF, 1 );
	
	e_fx_model thread staff_water_blizzard_kill_zombies( w_weapon, self, n_charge_level );
	
	wait w_weapon.n_blizzard_lifetime;
	
	e_fx_model notify( "staff_water_blizzard_over" );
	
	e_fx_model clientfield::set( WATERSTAFF_BLIZZARD_CF, 0 );
	wait 4;
	e_fx_model delete();
}

/* 
STAFF WATER BLIZZARD KILL ZOMBIES
Description : This function handles logic for the Staff of Ice's upgraded charged attack blizzard effecting zombies
Notes : None
*/
function staff_water_blizzard_kill_zombies( w_weapon, e_player, n_charge_level )
{
	e_player endon( "death_or_disconnect" );
	self endon( "death" );
	self endon( "staff_water_blizzard_over" );
	WAIT_SERVER_FRAME;
	while ( isDefined( self ) )
	{
		a_zombies = self staff_water_blizzard_effected_zombies( w_weapon.n_blizzard_range );
		array::thread_all( a_zombies, &staff_water_blizzard_damage_zombie, w_weapon, e_player );
		WAIT_SERVER_FRAME;
	}
}

/* 
STAFF WATER BLIZZARD EFFECTED ZOMBIES
Description : Returns an array of zombies in the Staff of Ice's charge attack area of effect
Notes : None
*/
function staff_water_blizzard_effected_zombies( n_blizzard_range )
{
	return array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ) ), 1, &staff_water_blizzard_effect_zombie_valid, self, n_blizzard_range );
}

/* 
STAFF WATER BLIZZARD EFFECT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Ice's charged attack
Notes : None
*/
function staff_water_blizzard_effect_zombie_valid( e_ai_zombie, e_blizzard, n_blizzard_range )
{
	b_trace_pass = bulletTracePassed( e_blizzard.origin, e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_water_blizzard_tag_check_override ) ? e_ai_zombie.str_staff_water_blizzard_tag_check_override : WATERSTAFF_BLIZZARD_TAG_CHECK ) ), 0, e_ai_zombie );
	return ( !( IS_TRUE( e_ai_zombie.b_immune_to_staff_water_blizzard ) ) && !( IS_TRUE( e_ai_zombie.b_is_on_ice ) ) && staff_water_distance_passed( e_blizzard.origin, e_ai_zombie.origin, n_blizzard_range, e_ai_zombie.n_staff_water_blizzard_range_check_multiplier ) && b_trace_pass );
}

/* 
STAFF WATER BLIZZARD DAMAGE ZOMBIE
Description : This function handles logic for the upgraded Staff of Ice's area of effect charge attack damage to AI
Notes : None
*/
function staff_water_blizzard_damage_zombie( w_weapon, e_attacker )
{
	// assert( !isDefined( self ), "staff_water_blizzard_damage_zombie( w_weapon, e_attacker ) - called on undefined entity" );
	// assert( IS_TRUE( self.marked_for_death ), "WATER BLIZZARD MISS - entity marked for death" );
	
	// self endon( "death" );
	// e_attacker endon( "disconnect" );
	
	if ( !isDefined( self ) )
		return;
	
	if ( isDefined( self.ptr_staff_water_blizzard_damage_cb ) )
		self [ [ self.ptr_staff_water_blizzard_damage_cb ] ]( e_attacker, w_weapon );
	else
	{
		if ( IS_TRUE( self.b_is_on_ice ) )
			return;
	
		self setCanDamage( 0 );
		self staff_water_freeze_zombie( 1, 1 );
		
		if ( !isDefined( self ) )
			return;
			
		self setCanDamage( 1 );
		self staff_water_damage_ai_response( ( ( isDefined( e_attacker ) && isPlayer( e_attacker ) && isAlive( e_attacker ) ) ? e_attacker : level ), w_weapon, 1, "MOD_RIFLE_BULLET" );
		// self doDamage( self.health + 666, self.origin, e_attacker, e_attacker, 0, "MOD_RIFLE_BULLET", 0, w_weapon );
	}
}

/* 
STAFF WATER DISTANCE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Ice charged attack
Notes : None
*/
function staff_water_distance_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range ) * n_range_multiplier );
}

/* 
STAFF WATER TRACE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Ice charged attack
Notes : None
*/
function staff_water_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1 )
{
	return ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
}

// ============================== FUNCTIONALITY ==============================

// ============================== DEVELOPER ==============================


// ============================== DEVELOPER ==============================

// ============================== EVENT OVERRIDES ==============================

function staff_water_parasite_init_cb()
{
	self.str_staff_water_gib_tag_override = "j_spine";
	self.str_staff_water_blizzard_tag_check_override = "j_spine";
	self.str_staff_water_cone_tag_check_override = "j_spine";
	self.a_staff_water_cone_impact_tag_checks_array_override = array( "j_spine" );
	// self.ptr_staff_water_damage_cb = &staff_water_parasite_damage_cb;
	self.ptr_staff_water_zombie_damage_cb = &staff_water_parasite_damage_cb;
	self.ptr_staff_water_blizzard_damage_cb = &staff_water_parasite_damage_cb;
	// self.ptr_staff_water_freeze_zombie_cb = &staff_water_parasite_freeze_parasite_cb;
	self.ptr_staff_water_death_cb = &staff_water_parasite_death_cb;
	self.n_staff_water_blizzard_range_check_multiplier = 1.8;
}

function staff_water_parasite_death_cb( e_player, str_damage_mod )
{
	playFx( WATERSTAFF_SHATTER_FX, self getTagOrigin( "j_spine" ), anglesToForward( ( 0, randomInt( 360 ), 0 ) ) );
	self thread hb21_zm_weap_staff_utility::zombie_gib_all( "j_spine" );
}

function staff_water_parasite_damage_cb( e_player, w_weapon )
{
	if ( IS_TRUE( self.b_is_on_ice ) )
		return;
	
	self.b_is_on_ice = 1;
	
	self setCanDamage( 1 );
	self staff_water_damage_ai_response( ( ( isDefined( e_player ) && isPlayer( e_player ) && isAlive( e_player ) ) ? e_player : level ), w_weapon, 1, "MOD_RIFLE_BULLET" );
}

function staff_water_dog_init_cb()
{
	self.str_staff_water_gib_tag_override = "j_spine1";
	self.str_staff_water_blizzard_tag_check_override = "j_spine1";
	self.str_staff_water_cone_tag_check_override = "j_spine1";
	self.a_staff_water_cone_impact_tag_checks_array_override = array( "j_spine1" );
	self.ptr_staff_water_damage_cb = &staff_water_dog_damage_cb;
	self.ptr_staff_water_blizzard_damage_cb = &staff_water_dog_damage_cb;
	// self.ptr_staff_water_freeze_zombie_cb = &staff_water_parasite_freeze_parasite_cb;
	// self.n_staff_water_blizzard_range_check_multiplier = 1.8;
}

function staff_water_dog_damage_cb( e_player, w_weapon )
{
	self clientfield::set( WATERSTAFF_FREEZE_ZOMBIE_CF, 1 );
	self.health = 1;
	self setEntityPaused( 1 );
	wait randomFloatRange( WATERSTAFF_MIN_FREEZE_DELAY, WATERSTAFF_MAX_FREEZE_DELAY );
	self setEntityPaused( 0 );
	self hb21_zm_weap_staff_utility::staff_do_damage( self.health + 666, self.origin, e_player, e_player, undefined, "MOD_RIFLE_BULLET", 0, w_weapon, undefined, undefined );
	// self doDamage( self.health + 666, self.origin, e_player, e_player, 0, "MOD_RIFLE_BULLET", 0, w_weapon );
}

// ============================== EVENT OVERRIDES ==============================