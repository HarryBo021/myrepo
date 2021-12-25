#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

#define _ARRAY_ADD(__array,__item) if ( isDefined( __item ) ) MAKE_ARRAY(__array) __array[__array.size]=__item;

#namespace hb21_zm_weap_utility;

REGISTER_SYSTEM_EX( "hb21_zm_weap_utility", &__init__, &__main__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{
	clientfield::register("clientuimodel", "hudItems.dpadLeftAmmo", 21000, 5, "int");
	clientfield::register( "allplayers", "rs_ammo",	VERSION_SHIP, 1, "int" );
	
	level.riotshield_melee_power = &riotshield_melee_power;
	
	callback::on_spawned( &on_player_spawned );
}

function __main__()
{
}

function riotshield_melee_power( w_weapon )
{
	if ( isDefined( w_weapon.ptr_weapon_melee_power_cb ) )
	{
		self [ [ w_weapon.ptr_weapon_melee_power_cb ] ]( w_weapon );
		// self zm_equipment::change_ammo( w_weapon, -1 );
		// self thread check_weapon_ammo( w_weapon );
	}
	else
		riotshield::riotshield_melee( w_weapon );
}

function on_player_spawned()
{
	self thread monitor_shield_player_watch_max_ammo();
	self thread monitor_shield_ammo_change();
	self thread dpad_left_ammo_set_logic();
	self thread monitor_loadout_change();
	self thread monitor_loadout_pullout_putaway();
	self thread monitor_weapon_fired();
	self thread monitor_weapon_missile_fired();
	self thread monitor_weapon_grenade_fired();
}

function monitor_shield_player_watch_max_ammo()
{
	self notify( "monitor_shield_player_watch_max_ammo" );
	self endon( "monitor_shield_player_watch_max_ammo" );
	
	for ( ;; )
	{
		self waittill( "zmb_max_ammo" );
		WAIT_SERVER_FRAME;
		if ( IS_TRUE( self.hasriotshield )  )
			self thread shield_check_weapon_ammo( self.weaponriotshield ); 
		
	}
}

function monitor_shield_ammo_change()
{
	self notify( "monitor_shield_ammo_change" );
	self endon( "monitor_shield_ammo_change" );
	
	for ( ;; )
	{
		self waittill( "equipment_ammo_changed", w_equipment );
		if ( isString( w_equipment ) )
			w_equipment = getWeapon( w_equipment );
		if ( IS_TRUE( w_equipment.isriotshield ) )
			self thread shield_check_weapon_ammo( w_equipment );
		
	}
}

function shield_check_weapon_ammo( w_weapon )
{
	WAIT_SERVER_FRAME;
	
	if ( isDefined( self ) )
	{
		n_ammo = self getWeaponAmmoClip( w_weapon );
		self clientfield::set( "rs_ammo", n_ammo ); 
	}
}

function monitor_loadout_change()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_loadout_change" );
	self endon( "monitor_loadout_change" );
	a_loadout = self getWeaponsList( 1 );
	while ( isDefined( self ) )
	{
		WAIT_SERVER_FRAME;
		a_new_loadout = self getWeaponsList( 1 );
		
		for ( i = 0; i < a_new_loadout.size; i++ )
		{
			if ( !isInArray( a_loadout, a_new_loadout[ i ] ) )
			{
				if ( isDefined( a_new_loadout[ i ].ptr_weapon_obtained_cb ) )
					self [ [ a_new_loadout[ i ].ptr_weapon_obtained_cb ] ]( a_new_loadout[ i ] ); // CHECK - ternary
			
				level notify( a_new_loadout[ i ].name + "_obtained", self );
				// iPrintLnBold( "WEAPON OBTAINED!!! = " + a_new_loadout[ i ].name );
			}
		}
		for ( i = 0; i < a_loadout.size; i++ )
		{
			if ( !isInArray( a_new_loadout, a_loadout[ i ] ) )
			{
				if ( isDefined( a_loadout[ i ].ptr_weapon_lost_cb ) )
					self [ [ a_loadout[ i ].ptr_weapon_lost_cb ] ]( a_loadout[ i ] ); // CHECK - ternary
				
				level notify( a_loadout[ i ].name + "_lost", self );
			}
		}
		a_loadout = a_new_loadout;
	}
}

/* 
MONITOR STAFF USAGE
Description : This function monitors a players current weapon to see if its a staff
Notes : This function monitors a players current weapon to see if its a staff, if it is a "upgraded" staff, it enables the "revive staff" on d-pad left
*/
function monitor_loadout_pullout_putaway()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_loadout_pullout_putaway" );
	self endon( "monitor_loadout_pullout_putaway" );
	
	while ( isDefined( self ) )
	{
		self waittill( "weapon_change", w_new_weapon, w_previous_weapon );
		
		if ( isDefined( w_previous_weapon.ptr_weapon_putaway_cb ) )
			self [ [ w_previous_weapon.ptr_weapon_putaway_cb ] ]( w_previous_weapon, w_new_weapon ); // CHECK - ternary
		
		// if ( !self hasWeapon( w_previous_weapon ) && isDefined( w_previous_weapon.ptr_weapon_lost_cb ) )
		// 	self [ [ w_previous_weapon.ptr_weapon_lost_cb ] ]( w_previous_weapon ); // CHECK - ternary
				
		if ( isDefined( w_new_weapon.ptr_weapon_pullout_cb ) )
			self [ [ w_new_weapon.ptr_weapon_pullout_cb ] ]( w_previous_weapon, w_new_weapon ); // CHECK - ternary
		
	}
}

function monitor_weapon_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_fired" );
	self endon( "monitor_weapon_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "weapon_fired", w_weapon );
		
		if ( isDefined( w_weapon.ptr_weapon_fired_cb ) )
			self thread [ [ w_weapon.ptr_weapon_fired_cb ] ]( w_weapon );
			
	}
}

function monitor_weapon_missile_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_missile_fired" );
	self endon( "monitor_weapon_missile_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "missile_fire", e_projectile, w_weapon );
		
		if ( isDefined( e_projectile ) && IS_TRUE( e_projectile.b_additional_shot ) )
			continue;
		
		if ( isDefined( w_weapon.ptr_weapon_missile_fired_cb ) )
			self thread [ [ w_weapon.ptr_weapon_missile_fired_cb ] ]( e_projectile, w_weapon, self.chargeshotlevel );
			
	}
}

function monitor_weapon_grenade_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_grenade_fired" );
	self endon( "monitor_weapon_grenade_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "grenade_fire", e_projectile, w_weapon );
		
		if ( isDefined( e_projectile ) && IS_TRUE( e_projectile.b_additional_shot ) )
			continue;
		
		if ( isDefined( w_weapon.ptr_weapon_grenade_fired_cb ) )
			self thread [ [ w_weapon.ptr_weapon_grenade_fired_cb ] ]( e_projectile, w_weapon, self.chargeshotlevel );
			
	}
}

function dpad_left_ammo_set_logic()
{
	self notify("dpad_left_ammo_set_logic");
	self endon("dpad_left_ammo_set_logic");
	self endon("death");
	self endon("disconnect");
	while(1)
	{
		if ( isDefined( self.dpad_left_ammo_weapon ) )
			ammo = self getammocount( self.dpad_left_ammo_weapon );
		else
			ammo = 0;
		
		self clientfield::set_player_uimodel("hudItems.dpadLeftAmmo", ammo);
		wait .05;
	}
}

function register_weapon_exclude_for_explode_death_anims( w_weapon )
{
	DEFAULT( level.a_explode_death_excluded_weapons, [] );
	ARRAY_ADD( level.a_explode_death_excluded_weapons, w_weapon );
}

// NOT WORKING YET

function waittill_any_array_pass_notify( o_return_notify_object, str_pass_notify, a_array ) // CHECK - move to hb21_utility and update other packs
{
	// o_return_notify_object endon( "death" ); // CHECK - failsafe incase the return object gets deleted?
	for ( i = 0; i < a_array.size; i++ )
		self thread waittill_notify_pass_notify( o_return_notify_object, str_pass_notify, a_array[ i ] );
	
	
	// o_return_notify_object notify( str_pass_notify, a_paramaters );
}

function waittill_notify_pass_notify( o_return_notify_object, str_notify, str_waittill, str_endon ) // CHECK - move to hb21_utility and update other packs
{
	// o_return_notify_object endon( "death" ); // CHECK - failsafe incase the return object gets deleted?
	o_return_notify_object endon( str_notify ); // CHECK - failsafe to kill all threads when one returns?
	// NEED A ENDON CONTROL?
	iPrintLn( "WAIT FOR NOTIFY : " + str_waittill );
	self waittill( str_waittill, o_param_0, o_param_1, o_param_2, o_param_3, o_param_4, o_param_5, o_param_6, o_param_7, o_param_8, o_param_9 );
	iPrintLn( "CAUGHT NOTIFY : " + str_waittill );
	a_paramaters = [];
	_ARRAY_ADD( a_paramaters, o_param_0 );
	_ARRAY_ADD( a_paramaters, o_param_1 );
	_ARRAY_ADD( a_paramaters, o_param_2 );
	_ARRAY_ADD( a_paramaters, o_param_3 );
	_ARRAY_ADD( a_paramaters, o_param_4 );
	_ARRAY_ADD( a_paramaters, o_param_5 );
	_ARRAY_ADD( a_paramaters, o_param_6 );
	_ARRAY_ADD( a_paramaters, o_param_7 );
	_ARRAY_ADD( a_paramaters, o_param_8 );
	_ARRAY_ADD( a_paramaters, o_param_9 );
	o_return_notify_object notify( str_notify, a_paramaters );
}

// NOT WORKING YET ^^^^^^^^^^^

function error_callback_log( message, return_value )
{
	// STORE INFO HERE
	
	if ( isDefined( return_value ) )
		return return_value;
	
}

function increment_ignoreall() // CHECK - move to hb21_utility and update other packs
{
	DEFAULT( self.ignorall_count, 0 );
	self.ignorall_count++;
	self.ignoreall = ( self.ignorall_count > 0 );
}

function decrement_ignoreall() // CHECK - move to hb21_utility and update other packs
{
	DEFAULT( self.ignorall_count, 0 );
	self.ignorall_count = math::clamp( self.ignorall_count - 1, 0 );
	self.ignoreall = ( self.ignorall_count > 0 );
}

function spawn_trigger_radius_use( v_origin, v_angles, n_spawn_flag, n_radius, n_height )
{
	if ( !isDefined( v_origin ) )
		v_origin = error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ORIGIN
	if ( !isDefined( v_angles ) )
		v_angles = error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ANGLES
	if ( !isDefined( n_spawn_flag ) )
		n_spawn_flag = error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 1 ); // FUNCTION CALLED WITH NO SPAWN FLAGS
	if ( !isDefined( n_radius ) )
		n_radius = error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 256 ); // FUNCTION CALLED WITH NO RADIUS
	if ( !isDefined( n_height ) )
		n_height = error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 128 ); // FUNCTION CALLED WITH NO HEIGHT
	
	e_trigger = spawn( "trigger_radius_use", v_origin, n_spawn_flag, n_radius, n_height );
	e_trigger.angles = v_angles;
	
	e_trigger triggerIgnoreTeam();
	e_trigger setHintString( "" );
	
	return e_trigger;
}

function create_linker_entity( v_origin, v_angles, str_model = "tag_origin", v_rotate_to_angle = undefined )
{
	if ( isDefined( self.e_linker ) )
		return;
	
	self.e_linker = util::spawn_model( str_model, v_origin, v_angles );
	self linkTo( self.e_linker );
	
	if ( isDefined( v_rotate_to_angle ) )
		self.e_linker.angles = v_rotate_to_angle;

	self thread linker_remove_failsafe();
}

function linker_remove_failsafe()
{
	self.e_linker endon( "linker_delete" );
	self waittill( "death" );
	self delete_linker_entity(); 
}

function delete_linker_entity()
{
	if ( !isDefined( self.e_linker ) )
		return;
	
	self.e_linker notify( "linker_delete" );
	self.e_linker unLink();
	self.e_linker delete();
}