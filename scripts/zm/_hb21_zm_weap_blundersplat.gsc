/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           			Harry Bo21s Black Ops 3 Acidgat						  ###
###                                                                   							  ###
###                                                                   							  ###
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
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_blundersplat.gsh;

#namespace hb21_zm_weap_blundersplat; 

#using_animtree( "generic" );

REGISTER_SYSTEM_EX( "hb21_zm_weap_blundersplat", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None  
*/
function __init__()
{		
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "missile", "blundersplat_missile", VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
	
	// # VARIABLES AND SETTINGS
	level.w_blundersplat = getWeapon( BLUNDERSPLAT_WEAPONFILE );
	level.w_blundersplat_upgraded = getWeapon( BLUNDERSPLAT_UPGRADED_WEAPONFILE );
	level.w_blundersplat_projectile = getWeapon( BLUNDERSPLAT_PROJECTILE_WEAPONFILE );
	level.w_blundersplat_grenade = getWeapon( BLUNDERSPLAT_GRENADE_WEAPONFILE );
	level.w_blundersplat.ptr_weapon_fired_cb = &blundersplat_additional_fire;
	level.w_blundersplat_upgraded.ptr_weapon_fired_cb = &blundersplat_additional_fire;
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	zm_spawner::register_zombie_damage_callback( &blundersplat_zombie_damage_response );	
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

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function blundersplat_zombie_damage_response( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, v_direction_vec, str_tag_name, str_model_name, str_part_name, str_flags, e_inflictor, n_chargeLevel )
{
	if ( isDefined( w_weapon ) && w_weapon == level.w_blundersplat_projectile )
	{
		if ( str_mod == "MOD_IMPACT" )
			self thread zombie_wait_for_blundersplat_hit( e_inflictor );
		
		return 1;
	}
	if ( isDefined( w_weapon ) && w_weapon == level.w_blundersplat_grenade )
		return 1;
	
	return 0;
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function blundersplat_zombie_target_valid( e_zombie, v_fire_origin, v_fire_angles )
{
	return util::within_fov( v_fire_origin, v_fire_angles, e_zombie.origin, cos( BLUNDERSPLAT_FOV_RANGE ) ) && !IS_TRUE( e_zombie.b_blundersplat_marked );
}

function blundersplat_additional_fire( w_weapon )
{
	b_is_not_upgraded = w_weapon == level.w_blundersplat;
	n_fuse_timer = randomFloatRange( ( b_is_not_upgraded ? 1 : 3 ), ( b_is_not_upgraded ? 2.5 : 4 ) );
	
	v_fire_angles = self getPlayerAngles();
	v_fire_origin = self getPlayerCameraPos();

	a_zombies = array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ), undefined, undefined, BLUNDERSPLAT_MAX_RANGE ), 1, &blundersplat_zombie_target_valid, v_fire_origin, v_fire_angles );

	foreach ( e_zombie in a_zombies )
	{
		str_tag = array::random( BLUNDERSPLAT_TARGET_TAGS );
		if ( bulletTracePassed( v_fire_origin, e_zombie getTagOrigin( str_tag ), 1, self, e_zombie ) )
		{
			e_zombie thread blundersplat_marked();
			e_dart = magicBullet( level.w_blundersplat_projectile, v_fire_origin, e_zombie getTagOrigin( str_tag ), self );
			e_dart thread blundersplat_reset_grenade_fuse( n_fuse_timer, b_is_not_upgraded );
			return;
		}
	}
	v_trace_end = v_fire_origin + anglesToForward( v_fire_angles ) * BLUNDERSPLAT_PROJECTILE_FORWARD_TRACE;
	a_trace = bulletTrace( v_fire_origin, v_trace_end, 1, self );
	v_offset_pos = a_trace[ "position" ] + blundersplat_marked_get_spread( BLUNDERSPLAT_PROJECTILE_SPREAD );
	e_dart = magicBullet( level.w_blundersplat_projectile, v_fire_origin, v_offset_pos, self );
	e_dart thread blundersplat_reset_grenade_fuse( n_fuse_timer );
}

function blundersplat_marked_get_spread( n_spread )
{
	n_x = randomIntRange( n_spread * -1, n_spread );
	n_y = randomIntRange( n_spread * -1, n_spread );
	n_z = randomIntRange( n_spread * -1, n_spread );
	return ( n_x, n_y, n_z );
}

function blundersplat_marked()
{
	self endon ( "death" );
	self.b_blundersplat_marked = 1;
	wait 1;
	self.b_blundersplat_marked = undefined;
}

function blundersplat_reset_grenade_fuse( n_fuse_timer = randomFloatRange( 1, 1.5 ), b_is_not_upgraded = 1 )
{	
	self waittill( "death" );
	a_grenades = getEntArray( "grenade", "classname" );
	foreach ( e_grenade in a_grenades )
	{
		if( isDefined( e_grenade.model ) && e_grenade.model == BLUNDERSPLAT_PROJECTILE_MODEL && !isDefined( e_grenade.fuse_reset ) )
		{
			e_grenade.fuse_reset = 1;
			e_grenade.fuse_time = n_fuse_timer;
			e_grenade resetMissileDetonationTime( n_fuse_timer );
			e_grenade zm_utility::create_zombie_point_of_interest( ( b_is_not_upgraded ? 250 : 500 ) , ( b_is_not_upgraded ? 5 : 10 ), 10000 );
			return;
		}
	}
}

function zombie_wait_for_blundersplat_hit( e_inflictor )
{
	if ( !isDefined( self.b_blundersplat_tagged ) )
	{
		a_grenades = getEntArray( "grenade", "classname" );
		if ( !isDefined( a_grenades ) || a_grenades.size <= 0 )
			return 0;
		
		self.b_blundersplat_tagged = 1;
		foreach ( e_grenade in a_grenades )
		{
			if ( isDefined( e_grenade.model ) && e_grenade.model == BLUNDERSPLAT_PROJECTILE_MODEL && e_grenade isLinkedTo( self ) )
			{
				while ( !isDefined( e_grenade.fuse_time ) )
						util::wait_network_frame();
					
				n_fuse_timer = e_grenade.fuse_time;
				e_grenade thread blundersplat_grenade_detonate_on_target_death( self );
			}
		}
		self thread blundersplat_target_animate_and_die( n_fuse_timer, e_inflictor );
	}
}

function blundersplat_grenade_detonate_on_target_death( e_target )
{
	self endon( "death" );
	e_target endon( "blundersplat_target_timeout" );
	e_target waittill( "blundersplat_target_killed" );
	self.fuse_reset = 1;
	self resetMissileDetonationTime( .05 );
}

function blundersplat_target_animate_and_die( n_fuse_timer, e_inflictor )
{
	self endon( "death" );
	self endon( "blundersplat_target_timeout" );
	self thread blundersplat_target_timeout( n_fuse_timer );
	self thread blundersplat_check_for_target_death();
	self.blockingPain = 1;
	self.b_acid_stunned = 1;
	wait n_fuse_timer;
	self notify( "killed_by_a_blundersplat" );
	self doDamage( self.health + 666, self.origin, e_inflictor );
}

function blundersplat_target_timeout( n_fuse_timer = 1 )
{
	self endon( "death" );
	self endon( "blundersplat_target_killed" );
	wait n_fuse_timer;
	self notify( "blundersplat_target_timeout" );
}

function blundersplat_check_for_target_death()
{
	self endon( "blundersplat_target_killed" );
	self waittill( "death" );
	self notify( "killed_by_a_blundersplat" );
	self notify( "blundersplat_target_killed" );
}


function blundersplat_upgrade_machine( e_table_trigger, e_table_model )
{
	e_trigger = spawn( "trigger_radius_use", e_table_trigger.origin, 0, 40, 80 );
	e_trigger.targetname = "blundersplat_upgrade_machine";
	e_trigger triggerIgnoreTeam();
	e_trigger setVisibleToAll();
	e_trigger setTeamForTrigger( "none" );
	e_trigger useTriggerRequireLookAt();
	e_trigger setCursorHint( "HINT_NOICON" );
	
	e_machine = e_table_model;
	e_machine useAnimTree( #animtree );
	
	forward = anglesToForward( e_machine.angles ) * 3;
	right = anglesToRight( e_machine.angles ) * 21;
	up = anglesToUp( e_machine.angles ) * 2;
	
	e_weapon_model = spawn( "script_model", e_machine.origin + forward + right + up );
	e_weapon_model.angles = e_machine.angles + ( 0, 90, -90 );
	e_weapon_model setModel( "tag_origin" );
	
	e_trigger thread blundersplat_upgrade_machine_hintstring_logic();
	
	while ( 1 )
	{
		e_owner = undefined;
		e_trigger waittill( "trigger", e_player );
		
		w_weapon = e_player getCurrentWeapon();
		if ( ( w_weapon != getWeapon( BLUNDERGAT_WEAPONFILE ) && w_weapon != getWeapon( BLUNDERGAT_UPGRADED_WEAPONFILE ) ) || !zombie_utility::is_player_valid( e_player ) )
			continue;
	
		e_player zm_weapons::weapon_take( w_weapon );
		e_trigger setHintString( "" );
		e_owner = e_player;
		e_trigger notify( "blundersplat_machine_in_use" );
		
		e_weapon_model setModel( w_weapon.worldModel );
		e_weapon_model useWeaponHideTags( w_weapon );
	
		e_weapon_model playSound( "fly_blundergat_insert" );
		
		e_machine animScripted( BLUNDERSPLAT_START_ANIM, e_machine.origin, e_machine.angles, BLUNDERSPLAT_START_ANIM );
		wait getAnimLength( BLUNDERSPLAT_START_ANIM );
		
		e_weapon_model playSound( "evt_blundersplat_upgrade" );
		
		w_weapon = getWeapon( ( ( w_weapon == getWeapon( BLUNDERGAT_UPGRADED_WEAPONFILE ) ) ? BLUNDERSPLAT_UPGRADED_WEAPONFILE : BLUNDERSPLAT_WEAPONFILE ) );
		e_weapon_model setModel( w_weapon.worldModel );
		e_weapon_model useWeaponHideTags( w_weapon );
		
		e_machine animScripted( BLUNDERSPLAT_IDLE_ANIM, e_machine.origin, e_machine.angles, BLUNDERSPLAT_IDLE_ANIM );
	
		wait 3.2;
		
		e_machine animScripted( BLUNDERSPLAT_END_ANIM, e_machine.origin, e_machine.angles, BLUNDERSPLAT_END_ANIM );
		wait getAnimLength( BLUNDERSPLAT_END_ANIM );
		
		e_trigger setHintStringForPlayer( e_owner, "Hold ^3&&1^7 to pick up " + w_weapon.displayname );
		
		e_trigger blundersplat_upgrade_machine_wait_for_take_or_timeout( e_owner, w_weapon );
		
		e_trigger setHintString( "" );
		e_weapon_model setModel( "tag_origin" );
		
		e_trigger thread blundersplat_upgrade_machine_hintstring_logic();
	}
}

function blundersplat_upgrade_machine_hintstring_logic()
{
	self endon( "blundersplat_machine_in_use" );
	while ( 1 )
	{
		a_players = getPlayers();
		for ( i = 0; i < a_players.size; i++ )
		{
			w_weapon = a_players[ i ] getCurrentWeapon();
			if ( ( w_weapon == getWeapon( "t8_shotgun_blundergat" ) || w_weapon == getWeapon( "t8_shotgun_blundergat_upgraded" ) ) && zombie_utility::is_player_valid( a_players[ i ] ) )
			{
				self setHintStringForPlayer( a_players[ i ], "Hold ^3&&1^7 to place " + w_weapon.displayname );
			}
			else
			{
				self setHintStringForPlayer( a_players[ i ], "" );
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function blundersplat_upgrade_machine_wait_for_take_or_timeout( e_owner, w_weapon )
{
	self endon( "blundersplat_upgrade_machine_timed_out" );
	self thread blundersplat_upgrade_machine_timeout();
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		
		if ( e_player != e_owner || !zombie_utility::is_player_valid( e_player ) )
			continue;
		
		e_player zm_weapons::weapon_give( w_weapon, 0, 0, 1, 1 );
		self notify( "blundersplat_upgrade_machine_done" );
		break;
	}
}

function blundersplat_upgrade_machine_timeout()
{
	self endon( "blundersplat_upgrade_machine_done" );
	wait BLUNDERSPLAT_UPGRADE_TIMEOUT;
	self notify( "blundersplat_upgrade_machine_timed_out" );
}

// ============================== FUNCTIONALITY ==============================