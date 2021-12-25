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
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_water.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#precache( "client_fx", WATERSTAFF_BLIZZARD_FX );
#precache( "client_fx", WATERSTAFF_ICICLE_FX );
#precache( "client_fx", WATERSTAFF_CHARGE_LIGHT_FX );

#namespace hb21_zm_weap_staff_water; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_water", &__init__, &__main__, undefined )

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
	level.a_staff_water_weaponfiles = [];
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	staff_water_register_weapon_for_level( 							WATERSTAFF_WEAPON																																																																																 );
	staff_water_register_weapon_for_level( 							WATERSTAFF_UPGRADED_WEAPON																																																																												 );
	staff_water_register_weapon_for_level( 							WATERSTAFF_UPGRADED_WEAPON2																																																																											 );
	staff_water_register_weapon_for_level( 							WATERSTAFF_UPGRADED_WEAPON3																																																																											 );
	/* ========================================================== 									REGISTER STAFF WEAPONS								 		========================================================== */
	
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( "scriptmover",									WATERSTAFF_BLIZZARD_CF,				VERSION_SHIP, 								1, 												"int", 			&staff_water_blizzard_fx,						!CF_HOST_ONLY, 							!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "actor", 											WATERSTAFF_FREEZE_ZOMBIE_CF, 	VERSION_SHIP, 								1, 												"int", 			&staff_water_freeze_zombie, 					!CF_HOST_ONLY, 							!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "vehicle", 										WATERSTAFF_FREEZE_ZOMBIE_CF, 	VERSION_SHIP, 								1, 												"int", 			&staff_water_freeze_zombie, 					!CF_HOST_ONLY, 							!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "actor", 											WATERSTAFF_FREEZE_FX_CF, 			VERSION_SHIP, 								1, 												"int", 			&staff_water_freeze_fx, 						!CF_HOST_ONLY, 							!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	clientfield::register( "vehicle", 										WATERSTAFF_FREEZE_FX_CF, 			VERSION_SHIP, 								1, 												"int", 			&staff_water_freeze_fx, 						CF_HOST_ONLY, 							!CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	duplicate_render::set_dr_filter_framebuffer_duplicate( 	WATERSTAFF_FREEZE_DR_NAME, 		WATERSTAFF_FREEZE_DR_PRIORITY, WATERSTAFF_FREEZE_DR_FLAG, 	undefined, 	DR_TYPE_FRAMEBUFFER_DUPLICATE, 	WATERSTAFF_FREEZE_MATERIAL, 	DR_CULL_NEVER								 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	// TO MOVE
	ai::add_archetype_spawn_function( 								"parasite", 										&staff_water_parasite_init_cb																																																																 );
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
Description : This function handles registering this weapon file as a staff of air variant and sets up some required properties
Notes : None
*/
function staff_water_register_weapon_for_level( str_weapon )
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
	hb21_zm_weap_staff_utility::register_staff_weapon_for_level( w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_water_charge_up_effects_cb, undefined, WATERSTAFF_CHARGE_LIGHT_FX	 );
	
	ARRAY_ADD( level.a_staff_water_weaponfiles, w_weapon );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
STAFF WATER UPDATE CHARGE EFFECTS
Description : This function handles the effects and sounds when the charge level changes
Notes : None
*/
function staff_water_charge_up_effects_cb( n_local_client_num, w_weapon, n_charge_level )
{
	self hb21_zm_weap_staff_utility::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, WATERSTAFF_CHARGE_SOUND + n_charge_level, ( n_charge_level == 1 ? WATERSTAFF_CHARGE_LOOP_SOUND : undefined ) );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/* 
STAFF WATER BLIZZARD FX 
Description : This function creates or destroys the Staff of Ice blizzard effect on an entity
Notes : None 
*/
function staff_water_blizzard_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_water_staff_blizzard = playFxOnTag( n_local_client_num, WATERSTAFF_BLIZZARD_FX, self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, WATERSTAFF_RUMBLE );
		self thread hb21_zm_weap_staff_utility::staff_shake_and_rumble( n_local_client_num, WATERSTAFF_RUMBLE_SCALE, WATERSTAFF_RUMBLE_DURATION, WATERSTAFF_RUMBLE_RADIUS, WATERSTAFF_RUMBLE );
		self thread hb21_zm_weap_staff_utility::staff_aoe_looping_sound( n_local_client_num, WATERSTAFF_BLIZZARD_SOUND, WATERSTAFF_IMPACT_SOUND, undefined, 1.5, 1.5 );
	}
	else
	{
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_water_staff_blizzard );
		self.fx_water_staff_blizzard = undefined;
	}
}

/* 
STAFF WATER FREEZE FX
Description : This function handles the icicle fx that appear on frozen zombies
Notes : None 
*/
function staff_water_freeze_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump ) 
{
	self notify( "staff_water_freeze_fx" );
	self endon( "staff_water_freeze_fx" );
	self endon( "entityshutdown" );
	
	if ( IS_TRUE( n_new_value ) )
	{
		if ( isDefined( self.fx_water_staff_frozen ) )
			deleteFx( n_local_client_num, self.fx_water_staff_frozen, 1 );
		
		self.fx_water_staff_frozen = playFxOnTag( n_local_client_num, WATERSTAFF_ICICLE_FX, self, ( isDefined( self.str_staff_water_freeze_fx_tag_override ) ? self.str_staff_water_freeze_fx_tag_override : WATERSTAFF_FREEZE_FX_TAG ) );
		// self util::waittill_any_timeout( 1, "shatter" );
	}
	else
	{
		if ( isDefined( self.fx_water_staff_frozen ) )
			deleteFx( n_local_client_num, self.fx_water_staff_frozen, 1 );
		
		self.fx_water_staff_frozen = undefined;
	
	}
}

function staff_water_freeze_zombie( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump ) 
{
	self notify( "staff_water_freeze_zombie" );
	self endon( "staff_water_freeze_zombie" );
	self endon( "entityshutdown" );
	// self endon( "death" );

	if ( !isDefined( self ) )
		return;

	if ( !isDefined( self.n_water_staff_frozen ) )
		self.n_water_staff_frozen = ( IS_TRUE( n_new_value ) ? WATERSTAFF_FREEZE_DR_INCRIMENTS : 0 );
	
	if ( IS_TRUE( n_new_value ) )
	{
		self duplicate_render::set_dr_flag( WATERSTAFF_FREEZE_DR_FLAG, n_new_value );
		self duplicate_render::update_dr_filters( n_local_client_num );
		self playSound( n_local_client_num, WATERSTAFF_FREEZE_ZOMBIE_SOUND );
	}
	n_incriment = ( IS_TRUE( n_new_value ) ? WATERSTAFF_FREEZE_DR_INCRIMENTS : 0 - WATERSTAFF_FREEZE_DR_DECRIMENTS );
	
	n_emmisive_buff = 1;
	
	self mapShaderConstant( n_local_client_num, 0, "scriptVector0", self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen );
	self mapShaderConstant( n_local_client_num, 8, "scriptVector2", self.n_water_staff_frozen * n_emmisive_buff, self.n_water_staff_frozen * n_emmisive_buff, 0, 0 );
	while ( isDefined( self ) )
	{
		if ( self.n_water_staff_frozen > 1 && IS_TRUE( n_new_value ) )
		{
			self.n_water_staff_frozen = 1;
			self mapShaderConstant( n_local_client_num, 0, "scriptVector0", 1, 1, 1, 1 );
			self mapShaderConstant( n_local_client_num, 8, "scriptVector2", n_emmisive_buff, n_emmisive_buff, 0, 0 );
			self notify( "staff_water_freeze_zombie" );
		}
		else if ( self.n_water_staff_frozen < 0 && !IS_TRUE( n_new_value ) )
		{
			self.n_water_staff_frozen = 0;
			self mapShaderConstant( n_local_client_num, 0, "scriptVector0", 0, 0, 0, 0 );
			self mapShaderConstant( n_local_client_num, 8, "scriptVector2", 0, 0, 0, 0 );
			break;
		}
		
		self.n_water_staff_frozen += n_incriment;
		self mapShaderConstant( n_local_client_num, 0, "scriptVector0", self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen );
		self mapShaderConstant( n_local_client_num, 8, "scriptVector2", self.n_water_staff_frozen * n_emmisive_buff, self.n_water_staff_frozen * n_emmisive_buff, 0, 0 );
		WAIT_CLIENT_FRAME;
	}
	if ( !IS_TRUE( n_new_value ) )
	{
		self duplicate_render::set_dr_flag( WATERSTAFF_FREEZE_DR_FLAG, n_new_value );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
}

// ============================== FUNCTIONALITY ==============================

// ============================== EVENT OVERRIDES ==============================

function staff_water_parasite_init_cb()
{
	self.str_staff_water_gib_tag_override = "j_spine";
}

// ============================== EVENT OVERRIDES ==============================