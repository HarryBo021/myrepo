#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

// SPECIALISTS
#using scripts\zm\_zm_hero_weapon;
#using scripts\shared\ai\margwa;
#using scripts\zm\_zm_weap_annihilator;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_weap_dragon_gauntlet;
#using scripts\zm\_zm_weap_keeper_skull;
#using scripts\zm\_zm_weap_glaive;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_hero_weapon;

#precache( "fx", "zombie/fx_powerup_on_green_zmb" );

REGISTER_SYSTEM_EX( "hb21_zm_hero_weapon", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "clientuimodel", "hero_weapon_icon_change", VERSION_SHIP, 5, "int" );
	
	setup_hero_triggers();
}

function __main__()
{
	
}

function setup_hero_triggers()
{
	a_triggers = getEntArray( "hb21_hero_weapons", "targetname" );
	if ( !isDefined( a_triggers ) || a_triggers.size < 1 )
		return;
	
	for ( i = 0; i < a_triggers.size; i++ )
		a_triggers[ i ] thread hero_weapon_trigger( getWeapon( a_triggers[ i ].script_string ) );
	
}

function hero_weapon_trigger( w_weapon )
{
	n_lua_index = get_index( w_weapon.name );
	
	self setHintstring( "Press & hold ^3&&1^7 for " + makeLocalizedString( w_weapon.displayname ) );
	
	s_struct = struct::get( self.target, "targetname" );
	e_model = util::spawn_model( getWeaponWorldModel( w_weapon ), s_struct.origin, s_struct.angles );
	e_model thread hero_wobble();
	
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		
		// if ( IS_TRUE( e_player.autokill_glaive_active ) )
			// continue;
		
		if ( IS_TRUE( e_player.hero_taking ) )
			continue;
		
		// if ( isDefined( e_player.var_4bd1ce6b ) )
			// continue;
		
		if ( e_player hasWeapon( w_weapon ) )
			continue;
		
		e_player thread give_hero_weapon( w_weapon, n_lua_index );
	}
}

function get_index( str_weapon )
{
	switch ( str_weapon )
	{
		case "hero_gravityspikes_melee" :
			return 1;
		case "skull_gun" :
			return 2;
		case "dragon_gauntlet_flamethrower" :
			return 3;
		case "glaive_apothicon_0" :
		case "glaive_apothicon_1" :
		case "glaive_apothicon_2" :
		case "glaive_apothicon_3" :
		case "glaive_keeper_0" :
		case "glaive_keeper_1" :
		case "glaive_keeper_2" :
		case "glaive_keeper_3" :
			return 4;
		default :
			return 0;
			
	}
}

function hero_weapon_trigger_failsafe()
{
	self endon( "disconnect" );
	self.hero_taking = 1;
	self util::waittill_any( "player_downed", "death", "hero_weapon_change_complete", "disconnect" );
	self.hero_taking = 0;
}

function give_hero_weapon( w_weapon, n_lua_index )
{
	
	if ( IsSubStr(w_weapon.name, "glaive_keeper") )
		w_weapon = getWeapon( "glaive_keeper_" + self.characterindex );
	
	if ( IsSubStr(w_weapon.name, "glaive_apothicon") )
		w_weapon = getWeapon( "glaive_apothicon_" + self.characterindex );
		
	// if ( IS_TRUE( self.autokill_glaive_active ) )
		// return;
	
	if ( IS_TRUE( self.hero_taking ) )
		return;
	
	if ( isDefined( self.var_4bd1ce6b ) )
	{
		self thread zm_weap_dragon_gauntlet::function_22d7caeb();
	}
	
	if ( self hasWeapon( w_weapon ) )
		return;
	
	n_lua_index = get_index( w_weapon.name );
	
	self thread hero_weapon_trigger_failsafe();
	w_old_hero = self zm_utility::get_player_hero_weapon();
	if ( isDefined( w_old_hero ) && w_old_hero != level.weaponNone )
	{
		self zm_hero_weapon::set_hero_weapon_state( w_old_hero, 0 );
		self takeWeapon( w_old_hero ); 
		self zm_utility::set_player_hero_weapon( undefined );
	}
	
	self notify( "destroy_ground_spikes" );
	if ( isDefined( self.var_c0d25105 ) )
		self.var_c0d25105._glaive_must_return_to_owner = 1; //  notify( "returned_to_owner" );
	
	self clientfield::set_player_uimodel( "hero_weapon_icon_change", n_lua_index );
	w_previous = self getCurrentWeapon();
	self zm_weapons::weapon_give( w_weapon );
	self gadgetPowerSet( 0, 99 );
	self switchToWeapon( w_weapon );
	self waittill( "weapon_change_complete" );
	self setLowReady( 1 ); 
	self switchToWeapon( w_previous );
	self util::waittill_any_timeout( 1.0, "weapon_change_complete" );
	self setLowReady( 0 );
	self gadgetPowerSet( 0, 100 );
	self zm_hero_weapon::set_hero_weapon_state( w_weapon, 2 );
	self notify( "hero_weapon_change_complete" );
}

function hero_wobble()
{
	playFxOnTag( "zombie/fx_powerup_on_green_zmb", self, "tag_weapon" );
	
	while ( isdefined( self ) )
	{
		n_wait_time = randomFloatRange( 2.5, 5 );
		n_yaw = randomInt( 360 );
		if ( n_yaw > 300 )
			n_yaw = 300;
		else if ( n_yaw < 60 )
			n_yaw = 60;
		
		n_yaw = self.angles[ 1 ] + n_yaw;
		n_new_angles = ( -60 + randomint( 120 ), n_yaw, -45 + randomInt( 90 ) );
		self rotateTo( n_new_angles, n_wait_time, n_wait_time * .5, n_wait_time * .5 );
		wait randomFloat( n_wait_time - .1 );
	}
}