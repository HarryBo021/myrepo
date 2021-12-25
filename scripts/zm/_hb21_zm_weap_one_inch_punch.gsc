/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###         	Harry Bo21s Black Ops 3 One Inch Punch				   ###
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
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_spawner;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_one_inch_punch.gsh;

#precache( "fx", OIP_ZOMBIE_GLOW );
#precache( "model", OIP_TABLET_MODEL );
#precache( "model", OIP_TABLET_MUDDY_MODEL );

#namespace hb21_zm_weap_one_inch_punch; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_one_inch_punch", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "allplayers", OIP_IMPACT_CF, VERSION_SHIP, 2, "int" );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER CALLBACKS
	zm_spawner::register_zombie_death_event_callback( &oip_death_event_cb );
	zm_spawner::register_zombie_damage_callback( &oip_zombie_damage_cb );
	callback::on_connect( &oip_on_player_connect );
	// # REGISTER CALLBACKS
}

function __main__()
{
	zm_utility::register_melee_weapon_for_level( OIP_WEAPON );
	zm_melee_weapon::init( OIP_WEAPON, OIP_WEAPON_FLOURISH, undefined, undefined, 10000, "oip_upgrade", "Hold ^3&&1^7 to buy One Inch Punch [Cost: 10000]", "oip", undefined );
	zm_melee_weapon::init( OIP_UPGRADED_WEAPON, OIP_UPGRADED_WEAPON_FLOURISH, undefined, undefined, 10000, "oip_upgraded_upgrade", "Hold ^3&&1^7 to buy One Inch Punch [Cost: 10000]", "oip", undefined );
	zm_melee_weapon::set_fallback_weapon( OIP_WEAPON, "knife" );
	zm_melee_weapon::set_fallback_weapon( OIP_UPGRADED_WEAPON, "knife" );
	
	level thread oip_upgrade_area_logic();
	
	foreach ( e_oip_model in getEntArray( "one_inch_punch_pickup", "targetname" ) )
	{
		playFxOnTag( OIP_ZOMBIE_GLOW, e_oip_model, "tag_origin" );
		e_oip_model zm_unitrigger::create_unitrigger( "Press & hold ^3&&1^7 for One Inch Punch", 64, undefined, &oip_pickup_location_logic );
	}
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function oip_on_player_connect()
{
	self thread oip_melee_charge_watcher();
	self thread oip_melee_watcher();
	self thread oip_melee_logic();
}

function oip_zombie_damage_cb( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( is_upgraded_staff_weapon( self.damageweapon ) && str_means_of_death == "MOD_MELEE" && self hasWeapon( getWeapon( OIP_UPGRADED_WEAPON ) ) )
	{
		str_punch_element = e_attacker oip_get_staff_element();
		b_punch_upgraded = 1;
	}
	else 
	{
		if ( !isDefined( self ) || ( self.damageweapon != getWeapon( OIP_WEAPON ) && self.damageweapon != getWeapon( OIP_UPGRADED_WEAPON ) ) )
			return 0;
	
		str_punch_element = e_attacker oip_get_staff_element();
		b_punch_upgraded = self.damageweapon == getWeapon( OIP_UPGRADED_WEAPON );
	}
	
	
	
	if ( IS_TRUE( b_punch_upgraded ) && isDefined( str_punch_element ) )
	{
		switch ( str_punch_element )
		{
			case "fire":
			{
				self thread [ [ level.ptr_staff_fire_zombie_set_and_restore_flame_state ] ]();
				break;
			}
			case "ice":
			{
				self thread [ [ level.ptr_staff_water_freeze_zombie ] ]();
				break;
			}
			case "lightning":
			{
				self thread [ [ level.ptr_staff_lightning_stun_zombie ] ]();
				break;
			}
		}
	}
	else
		self thread zombie_utility::setup_zombie_knockdown( e_inflictor );
	
	return 1;
}

function oip_death_event_cb( e_attacker )
{
	if ( isDefined( self.e_oip_right_arm_fx ) && isEntity( self.e_oip_right_arm_fx ) )
		self.e_oip_right_arm_fx delete();
	if ( isDefined( self.e_oip_left_arm_fx ) && isEntity( self.e_oip_left_arm_fx ) )
		self.e_oip_left_arm_fx delete();
	
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( is_upgraded_staff_weapon( self.damageweapon ) && self.damagemod == "MOD_MELEE" && self hasWeapon( getWeapon( OIP_UPGRADED_WEAPON ) ) )
	{
		str_punch_element = e_attacker oip_get_staff_element();
		b_punch_upgraded = 1;
	}
	else 
	{
		if ( !isDefined( self ) || ( self.damageweapon != getWeapon( OIP_WEAPON ) && self.damageweapon != getWeapon( OIP_UPGRADED_WEAPON ) ) )
			return;
	
		str_punch_element = e_attacker oip_get_staff_element();
		b_punch_upgraded = self.damageweapon == getWeapon( OIP_UPGRADED_WEAPON );
	}
	self setCanDamage( 0 );
	
	self oip_count_to_upgrade( self.damageweapon, e_attacker );
	
	if ( IS_TRUE( b_punch_upgraded ) && isDefined( str_punch_element ) )
	{
		switch ( str_punch_element )
		{
			case "fire":
			{
				self clientfield::set( "staff_fire_burn_zombie", 1 );
				break;
			}
			case "ice":
			{
				self clientfield::set( "staff_water_freeze_fx", 1 );
				self clientfield::set( "staff_water_freeze_zombie", 1 );
				break;
			}
			case "lightning":
			{
				self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_impact_fx_veh" : "staff_lightning_impact_fx" ), 1 );
				break;
			}
		}
	}
	self clientfield::set( "staff_air_ragdoll_impact_watch", 1 );
	e_attacker thread oip_zombie_punch_death( self );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function oip_melee_charge_watcher()
{
	self endon( "disconnect" );
	self notify( "oip_melee_charge_watcher" );
	self endon( "oip_melee_charge_watcher" );
	while ( isDefined( self ) )
	{
		self waittill( "weapon_melee_charge", w_weapon );
		self notify( "oip_fired", w_weapon );
	}
}

function oip_melee_watcher()
{
	self endon( "disconnect" );
	self notify( "oip_melee_watcher" );
	self endon( "oip_melee_watcher" );
	while ( isDefined( self ) )
	{
		self waittill( "weapon_melee", w_weapon );
		self notify( "oip_fired", w_weapon );
	}
}

function oip_melee_logic()
{
	self endon( "disconnect" );
	self notify( "oip_melee_logic" );
	self endon( "oip_melee_logic" );
	
	while ( isDefined( self ) )
	{
		self waittill( "oip_fired", w_weapon );
		
		if ( is_upgraded_staff_weapon( w_weapon ) && self hasWeapon( getWeapon( OIP_UPGRADED_WEAPON ) ) )
		{
			str_element = self oip_get_staff_element();
			n_range_mod = ( ( isDefined( str_element ) && str_element == "air" ) ? 2 : 1 );
		}
		else	
		{
			if ( w_weapon.name != OIP_WEAPON && w_weapon.name != OIP_UPGRADED_WEAPON )
				continue;
		
			str_element = self oip_get_staff_element();
			n_range_mod = ( ( w_weapon.name == OIP_UPGRADED_WEAPON && ( isDefined( str_element ) && str_element == "air" ) ) ? 2 : 1 );
		}
		
		self clientfield::set( OIP_IMPACT_CF, n_range_mod );
		util::wait_network_frame();
		self clientfield::set( OIP_IMPACT_CF, 0 );

		v_punch_effect_fwd = anglesToForward( self getPlayerAngles() );
		v_punch_yaw = get_2d_yaw( ( 0, 0, 0 ), v_punch_effect_fwd );
		
		foreach( e_ai_zombie in util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ), undefined, undefined, 100 ) )
			if ( self is_player_facing( e_ai_zombie, v_punch_yaw ) )
				self thread oip_zombie_punch_damage( e_ai_zombie, ( distanceSquared( self.origin, e_ai_zombie.origin ) <= ( 4096 * n_range_mod ) ? 1 : .5 ) );
			
		
	}
}

function oip_pickup_location_logic()
{
	self endon( "kill_trigger" );
	
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player hasWeapon( getWeapon( OIP_WEAPON ) ) )
			continue;
			
		e_player thread zm_melee_weapon::award_melee_weapon( OIP_WEAPON );
	}
}

function oip_count_to_upgrade( w_weapon, e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( IS_TRUE( self.b_oip_in_upgrade_area ) && !IS_TRUE( e_attacker.b_oip_upgrade_done ) && isDefined( w_weapon ) && w_weapon == getWeapon( OIP_WEAPON ) )
	{
		if ( !isDefined( e_attacker.n_oip_kills ) )
			e_attacker.n_oip_kills = 0;
	
		e_attacker.n_oip_kills++;
		
		if ( e_attacker.n_oip_kills >= OIP_KILLS_TO_UPGRADE )
		{
			e_attacker.b_oip_upgrade_done = 1;
			
			e_oip_model = util::spawn_model( OIP_TABLET_MODEL, self.origin + ( 0, 0, 48 ), self.angles );
			playFXOnTag( OIP_ZOMBIE_GLOW, e_oip_model, "tag_origin" );
			e_oip_model.owner = e_attacker;
			e_oip_model zm_unitrigger::create_unitrigger( "", 64, &oip_unitrigger_prompt_and_visibility, &oip_take_upgrade_stone );
			foreach ( e_player in level.players )
				if ( e_player != e_attacker )
					e_oip_model setInvisibleToPlayer( e_player );
				
			
		}
	}
}

function oip_upgrade_area_logic()
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		b_player_in_area = 0;
		foreach ( e_player in level.players )
		{
			if ( e_player oip_touching_any_upgrade_area() && !IS_TRUE( e_player.b_oip_upgrade_done ) && e_player hasWeapon( getWeapon( OIP_WEAPON ) ) )
			{
				b_player_in_area = 1;
				break;
			}
		}
		
		if ( !b_player_in_area )
		{
			WAIT_SERVER_FRAME;
			continue;			
		}
		
		foreach ( e_zombie in getAiArchetypeArray( "zombie" ) ) 
		{
			if ( e_zombie oip_touching_any_upgrade_area() && !IS_TRUE( e_zombie.b_oip_in_upgrade_area ) )
				e_zombie oip_zombie_touched_upgrade_area();
			
		}
		WAIT_SERVER_FRAME;
	}
}

function oip_zombie_touched_upgrade_area()
{
	self.b_oip_in_upgrade_area = 1;
	
	if ( isDefined( self.e_oip_right_arm_fx ) && isEntity( self.e_oip_right_arm_fx ) )
		self.e_oip_right_arm_fx delete();
	if ( isDefined( self.e_oip_left_arm_fx ) && isEntity( self.e_oip_left_arm_fx ) )
		self.e_oip_left_arm_fx delete();
	
	if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "right_arm" )
	{}
	else
	{
		self.e_oip_right_arm_fx = spawn( "script_model", self getTagOrigin( "j_wrist_ri" ) );
		self.e_oip_right_arm_fx setModel( "tag_origin" );
		self.e_oip_right_arm_fx.angles = self getTagAngles( "j_wrist_ri" );
		self.e_oip_right_arm_fx linkTo( self, "j_wrist_ri" );
		playFXOnTag( OIP_ZOMBIE_GLOW, self.e_oip_right_arm_fx, "tag_origin" );
	}
	if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "left_arm" )
	{}
	else
	{
		self.e_oip_left_arm_fx = spawn( "script_model", self getTagOrigin( "j_wrist_le" ) );
		self.e_oip_left_arm_fx setModel( "tag_origin" );
		self.e_oip_left_arm_fx.angles = self getTagAngles( "j_wrist_le" );
		self.e_oip_left_arm_fx linkTo( self, "j_wrist_le" );
		playFXOnTag( OIP_ZOMBIE_GLOW, self.e_oip_left_arm_fx, "tag_origin" );
	}
	
	self thread oip_check_zombie_and_player_still_in_area();
}

function oip_unitrigger_prompt_and_visibility( e_player )
{
	self setInvisibleToPlayer( e_player );
	if ( isDefined( self.stub.related_parent ) && e_player == self.stub.related_parent.owner )
	{
		self setVisibleToPlayer( e_player );
		return 1;
	}
	return 0;
}

function oip_take_upgrade_stone()
{
	self endon( "kill_trigger" );
	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player != self.stub.related_parent.owner )
			continue;
		
		break;
	}
	e_player.b_oip_upgrade_done = undefined;
	e_player.n_oip_kills = undefined;
	e_player thread zm_melee_weapon::award_melee_weapon( OIP_UPGRADED_WEAPON );
	self.stub.related_parent delete();
	zm_unitrigger::unregister_unitrigger( self.stub );
}


function oip_touching_any_upgrade_area()
{
	foreach ( e_oip_upgrade_area in getEntArray( "harrybo21_one_inch_punch_upgrade", "script_noteworthy" ) )
		if ( self isTouching( e_oip_upgrade_area ) )
			return 1;
		
	return 0;
}

function oip_check_zombie_and_player_still_in_area()
{
	self endon( "delete" );
	self endon( "oip_failsafe" );

	while ( isDefined( self ) )
	{
		if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "right_arm" && isDefined( self.e_oip_right_arm_fx ) && isEntity( self.e_oip_right_arm_fx ) )
			self.e_oip_right_arm_fx delete();
		if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "left_arm" && isDefined( self.e_oip_left_arm_fx ) && isEntity( self.e_oip_left_arm_fx ) )
			self.e_oip_left_arm_fx delete();
		
		b_player_in_area = 0;
		foreach ( e_player in level.players )
		{
			if ( e_player oip_touching_any_upgrade_area() && !IS_TRUE( e_player.b_oip_upgrade_done ) && e_player hasWeapon( getWeapon( OIP_WEAPON ) ) )
			{
				b_player_in_area = 1;
				break;
			}
		}
		if ( !self oip_touching_any_upgrade_area() )	
			b_player_in_area = 0;
		
		if ( !b_player_in_area )
		{
			if ( isDefined( self.e_oip_right_arm_fx ) && isEntity( self.e_oip_right_arm_fx ) )
				self.e_oip_right_arm_fx delete();
			if ( isDefined( self.e_oip_left_arm_fx ) && isEntity( self.e_oip_left_arm_fx ) )
				self.e_oip_left_arm_fx delete();
	
			self.b_oip_in_upgrade_area = undefined;
			break;			
		}
		WAIT_SERVER_FRAME;
	}
}

function oip_get_staff_element()
{
	a_weapons = self getWeaponsListPrimaries();
	if ( !isDefined( a_weapons ) || a_weapons.size < 1 || !isArray( a_weapons ) )
		return undefined;
	for ( i = 0; i < a_weapons.size; i++ )
	{
		if ( !isDefined( a_weapons[ i ] ) || a_weapons[ i ] == level.weaponNone )
			continue;
			
		if ( isInArray( level.a_staff_fire_weaponfiles, a_weapons[ i ] ) )
			return "fire";
		if ( isInArray( level.a_staff_water_weaponfiles, a_weapons[ i ] ) )
			return "ice";
		if ( isInArray( level.a_staff_lightning_weaponfiles, a_weapons[ i ] ) )
			return "lightning";
		if ( isInArray( level.a_staff_air_weaponfiles, a_weapons[ i ] ) )
			return "air";
			
	}
}

function get_2d_yaw( v_origin, v_target )
{
	return vectorToAngles( v_target - v_origin )[ 1 ];
}

function is_player_facing( zombie, v_punch_yaw )
{
	v_player_to_zombie_yaw = get_2d_yaw( self.origin, zombie.origin );
	yaw_diff = v_player_to_zombie_yaw - v_punch_yaw;
	if ( yaw_diff < 0 )
		yaw_diff *= -1;
	
	if ( yaw_diff < 35 )
		return 1;
	else
		return 0;
	
}

function oip_handle_pain_notetracks( str_note )
{
	if ( str_note == "zombie_knockdown_ground_impact" )
		playFx( level._effect[ "punch_knockdown_ground" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
	
}

function oip_zombie_punch_damage( e_ai_zombie, n_mod )
{
	self endon( "disconnect" );
	e_ai_zombie.punch_handle_pain_notetracks = &oip_handle_pain_notetracks;
	if ( isDefined( n_mod ) )
	{
		n_mod = ( self hasPerk( "specialty_widowswine" ) ? n_mod * 1.1 : n_mod );
		n_base_damage = ( IS_TRUE( self.b_punch_upgraded ) ? OIP_UPGRADED_DAMAGE : OIP_DAMAGE );
		
		n_damage = int( n_base_damage * n_mod );
		e_ai_zombie doDamage( n_damage, e_ai_zombie.origin, self, self, 0, "MOD_MELEE", 0, self.current_melee_weapon );
	}
}

function oip_gib_zombies_head( e_player )
{
	e_player endon( "disconnect" );
	self zombie_utility::zombie_head_gib();
}

function oip_zombie_punch_death( e_ai_zombie )
{
	e_ai_zombie thread oip_gib_zombies_head( self );

	if ( isDefined( e_ai_zombie ) )
		e_ai_zombie oip_zombie_launch( e_ai_zombie.attacker );

}

function oip_zombie_launch( e_attacker )
{
	self doDamage( self.health, self.origin, self, self, 0, "MOD_MELEE", 0, e_attacker.current_melee_weapon );
	self startRagDoll();
	self launchRagdoll( oip_determine_launch_vector( e_attacker, self ) );
}

function oip_determine_launch_vector( e_attacker, e_ai_zombie )
{
	return ( vectorNormalize( e_ai_zombie.origin - e_attacker.origin ) * randomIntRange( 125, 150 ) ) + ( 0, 0, randomIntRange( 75, 150 ) );
}

function is_upgraded_staff_weapon( w_weapon )
{
	if ( !isDefined( level.ptr_is_staff_weapon ) )
		return 0;
		
	return ( [ [ level.ptr_is_staff_weapon ] ]( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) );
}

// ============================== FUNCTIONALITY ==============================