/*#========================================###
###                                                                   						###
###                                                                   						###
###           			Harry Bo21s Black Ops 3 Staff Utility				###
###                                                                   						###
###                                                                   						###
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
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_hb21_zm_weap_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_fire.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_air.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_water.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_lightning.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_revive.gsh;

#namespace hb21_zm_weap_staff_utility;

REGISTER_SYSTEM_EX( "hb21_zm_weap_staff_utility", &__init__, &__main__, undefined )

#precache( "client_fx", STAFF_SOUL_COLLECT_TRAIL );

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None  
*/
function __init__() 
{	
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	STAFF_ICON_CF, 		VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT						 );	
	clientfield::register( "toplayer", 			STAFF_CHARGE_CF, 	VERSION_SHIP, 3, "int", &staff_charge_sounds, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT	 );
	// # CLIENTFIELD REGISTRATION
	
	// # VARIABLES AND SETTINGS
	level.a_staff_weaponfiles = [];
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_localplayer_spawned( &on_local_player_spawned );
	// # REGISTER CALLBACKS
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
REGISTER STAFF WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff and sets up some required properties
Notes : None
*/
function register_staff_weapon_for_level( ut_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined, ptr_weapon_first_raise_cb = undefined, ptr_weapon_charge_cb = undefined, ptr_weapon_charge_reset_cb = undefined, str_weapon_charge_fx = "" )
{	
	w_weapon = ( !isWeapon( ut_weapon ) ? getWeapon( ut_weapon ) : ut_weapon );
	
	w_weapon.ptr_weapon_fired_cb				= ptr_weapon_fired_cb;
	w_weapon.ptr_weapon_obtained_cb 		= ptr_weapon_obtained_cb;
	w_weapon.ptr_weapon_lost_cb 				= ptr_weapon_lost_cb;
	w_weapon.ptr_weapon_reloaded_cb 		= ptr_weapon_reloaded_cb;
	w_weapon.ptr_weapon_pullout_cb 			= ptr_weapon_pullout_cb;
	w_weapon.ptr_weapon_putaway_cb 		= ptr_weapon_putaway_cb;
	w_weapon.ptr_weapon_first_raise_cb 		= ptr_weapon_first_raise_cb;
	w_weapon.ptr_weapon_charge_cb 			= ptr_weapon_charge_cb;
	w_weapon.ptr_weapon_charge_reset_cb	= ptr_weapon_charge_reset_cb;
	w_weapon.str_weapon_charge_fx			= str_weapon_charge_fx;
	
	ARRAY_ADD( level.a_staff_weaponfiles, w_weapon );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
ON PLAYER SPAWNED 
Description : This function defines all the required values and functions on the players
Notes : None  
*/
function on_local_player_spawned( n_local_client_num ) 
{
	self thread staff_watch_change_weapon( n_local_client_num );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/*
STAFF CHARGE SOUNDS
Description : This function handles the sounds a player hears when charging a staff
Notes : None  
*/
function staff_charge_sounds( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	w_weapon = getCurrentWeapon( n_local_client_num );
	if ( !is_staff_weapon( w_weapon ) )
		return;
	
	if ( isDefined( w_weapon.ptr_weapon_charge_cb ) )
		self [ [ w_weapon.ptr_weapon_charge_cb ] ]( n_local_client_num, w_weapon, n_new_value );
	else
		self play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_new_value );
}

/*
PLAY STAFF CHARGE UP SOUNDS
Description : This function handles the sounds a player hears when charging a staff
Notes : None  
*/
function play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level = 0, str_one_shot_sound = undefined, str_looping_sound = undefined )
{
	if ( n_charge_level > 0 )
	{
		if ( isDefined( str_one_shot_sound ) )
			self playSound( n_local_client_num, str_one_shot_sound );
	
		if ( !isDefined( self.snd_str_staff_charge_loop_sound ) )
			self.snd_str_staff_charge_loop_sound = self playLoopSound( str_looping_sound, .5 );
		
	}
	else
	{
		if ( !isDefined( self.snd_str_staff_charge_loop_sound ) )
			return;
	
		self stopLoopSound( self.snd_str_staff_charge_loop_sound, .5 );
		self.snd_str_staff_charge_loop_sound = undefined;
	}
}

/* 
IS STAFF WEAPON
Description : This function checks a weapon to see if it is a staff, or if it is in the specific array passed
Notes : None  
*/
function is_staff_weapon( w_weapon )
{
	return ( isDefined( level.a_staff_weaponfiles ) && isArray( level.a_staff_weaponfiles ) && isInArray( level.a_staff_weaponfiles, w_weapon ) );
}

/* 
IS UPGRADED STAFF WEAPON
Description : This is a function checks if this weapon is a upgraded staff weapon
Notes : None
*/
function is_upgraded_staff_weapon( w_weapon )
{
	return ( is_staff_weapon( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) );
}

/* 
STAFF AOE LOOPING SOUND
Description : This function stops the sounds and plays the explode sound when the Staff of Air's charge attack finishes
Notes : None 
*/
function staff_aoe_looping_sound( n_local_client_num, str_loop_sound, str_start_sound = undefined, str_end_sound = undefined, n_loop_sound_fade_in_time = 0, n_loop_sound_fade_out_time = 0 )
{
	e_ent = spawn( n_local_client_num, self.origin, "script_origin" );
	e_ent linkTo( self );
	
	e_ent endon( "death" );
	e_ent endon( "entity_shutdown" );
	
	if ( isDefined( str_start_sound ) )
		e_ent playSound( n_local_client_num, str_start_sound );
	
	e_ent.e_staff_sndent = e_ent playLoopSound( str_loop_sound, n_loop_sound_fade_in_time );
	self waittill( "staff_aoe_looping_sound_end" );
	e_ent stopLoopSound( e_ent.e_staff_sndent, n_loop_sound_fade_out_time );
	
	if ( isDefined( str_end_sound ) )
		e_ent playSound( n_local_client_num, str_end_sound );
	
	wait n_loop_sound_fade_out_time;
	if ( isDefined( e_ent ) )
		e_ent delete();

}

/* 
STAFF SHAKE AND RUMBLE 
Description : This function causes a player's screen to rumble and shake if they are near the effect
Notes : None 
*/
function staff_shake_and_rumble( n_local_client_num, n_scale = .3, n_duration = 1, n_radius = 100, str_rumble_name = "artillery_rumble" )
{
	self notify( "staff_shake_and_rumble" );
	self endon( "staff_shake_and_rumble" );
	self endon( "entity_shutdown" );
	
	while ( isDefined( self ) )
	{
		self earthquake( n_scale, n_duration, self.origin, n_radius );
		self playRumbleOnEntity( n_local_client_num, str_rumble_name );
		WAIT_CLIENT_FRAME;
	}
}

/*
STAFF WATCH CHANGE WEAPON
Description : This function handles starting / stopping sounds and fx when the player switches weapon
Notes : None  
*/
function staff_watch_change_weapon( n_local_client_num )
{
	self endon( "death_or_disconnect" );
	self notify( "staff_watch_change_weapon" );
	self endon( "staff_watch_change_weapon" );
	
	while ( isDefined( self ) )
	{
		self waittill( "weapon_change", w_weapon, w_old_weapon );
		
		if ( !isDefined( w_weapon ) || w_weapon == level.weaponNone )
			continue;
		
		if ( is_staff_weapon( w_weapon ) )
		{
			self notify( "staff_weapon_equipped" );
			// self staff_watch_charge_level( n_local_client_num );
			if ( isDefined( w_weapon.str_weapon_charge_fx ) )
				self thread staff_watch_charge_level( n_local_client_num, w_weapon.str_weapon_charge_fx );
				
		}
	}
}

/* 
STAFF WATCH CHARGE LEVEL
Description : This function handles the sound and fx logic when a player is charging their staff
Notes : None
*/
function staff_watch_charge_level( n_local_client_num, str_fx )
{
	self endon( "staff_weapon_equipped" );
	while ( isDefined( self ) )
	{
		n_charge = getWeaponChargeLevel( n_local_client_num );
		if ( n_charge > 0 )
		{
			if ( !isDefined( self.fx_staff_light ) )
				self.fx_staff_light = playViewmodelFx( n_local_client_num, str_fx, "tag_fx_upg_1" );
			
		}
		else
		{
			if ( isDefined( self.fx_staff_light ) )
			{
				stopFx( n_local_client_num, self.fx_staff_light );
				self.fx_staff_light = undefined;
			}
		}
		
		WAIT_CLIENT_FRAME;
	}
}

// ============================== FUNCTIONALITY ==============================