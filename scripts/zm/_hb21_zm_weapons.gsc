#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_hb21_zm_weap_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_t6_weapons;
#using scripts\zm\_zm_t7_weapons;
#using scripts\zm\_zm_t8_weapons;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weapons.gsh;

#namespace hb21_zm_weapons;

REGISTER_SYSTEM_EX( "hb21_zm_weapons", &__init__, &__main__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{
}

function __main__()
{
	level.default_laststandpistol 									= getWeapon( START_WEAPON );
	level.default_solo_laststandpistol								= getWeapon( SOLO_LASTSTAND_WEAPON );
	level.laststandpistol												= level.default_laststandpistol;
	level.start_weapon													= level.default_laststandpistol;
	if ( IS_TRUE( USE_WEAPONS_START_SCORE_OVERRIDE ) )
		level.player_starting_points 								= level.round_number * START_SCORE;
	
	level.pack_a_punch_camo_index 							= CAMO_BASE_INDEX;
	level.pack_a_punch_camo_index_number_variants 	= NUMBER_OF_CAMO_VARIANTS_FROM_BASE;
	
	level.a_start_weapons = [];
	if ( IS_TRUE( USE_MULTIPLE_START_WEAPONS ) )
	{
		level.giveCustomLoadout 									= &give_start_weapons;
		setup_multiple_start_weapons();
	}
	
	level thread last_stand_pistol_rank_init();
}

function setup_multiple_start_weapons()
{
	level.a_start_weapons[ level.a_start_weapons.size ] = getWeapon( "t7_pistol_m1911" );
	level.a_start_weapons[ level.a_start_weapons.size ] = getWeapon( "pistol_standard" );
	level.a_start_weapons[ level.a_start_weapons.size ] = getWeapon( "t7_pistol_mc96" );
	level.a_start_weapons[ level.a_start_weapons.size ] = getWeapon( "pistol_revolver38" );
	level.a_valid_start_weapons = array::randomize( level.a_start_weapons );
}

function last_stand_pistol_rank_init()
{
	level.pistol_values = [];	
	
	// ww: in a solo game the ranking of the pistols is a bit different based on the upgraded 1911 swap
	// any pistol ranked level.pistol_value_solo_replace_below or lower will be ignored and the player will be given the upgraded 1911
	level.pistol_values[ level.pistol_values.size ] = level.default_laststandpistol;
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_revolver38" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_pistol_mc96" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_pistol_m1911" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_burst" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_fullauto" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_beretta93r" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_python" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_fiveseven" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_fiveseven_dw" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_kard" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_judge" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_rnma" );
	
	// NOTE : ADD YOUR NORMAL PISTOL WEAPONS HERE
	
	level.pistol_value_solo_replace_below = level.pistol_values.size - 1;  // EO: anything scoring lower than this should be replaced
	
	level.pistol_values[ level.pistol_values.size ] = level.default_solo_laststandpistol;
	
	// NOTE : ADD YOUR UPGRADED PISTOL WEAPONS HERE
	
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_revolver38_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_pistol_mc96_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_pistol_m1911_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_burst_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "pistol_fullauto_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_beretta93r_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_python_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_fiveseven_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_fiveseven_dw_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_kard_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_judge_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t6_pistol_rnma_upgraded" );
	
	// NOTE : ADD YOUR PISTOL WONDER WEAPONS HERE
	
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "ray_gun" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_raygun_mark2" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "ray_gun_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_raygun_mark2_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "raygun_mark3" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "raygun_mark3_upgraded" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_microwavegundw" );
	level.pistol_values[ level.pistol_values.size ] = getWeapon( "t7_microwavegundw_upgraded" );
}

function give_start_weapons( b_take_all_weapons, b_already_spawned )
{
	self giveWeapon( level.weaponBaseMelee );
	self give_start_weapon( 1 );
}

function give_start_weapon( b_switch_weapon = 1 )
{
	if ( !isDefined( level.a_start_weapons ) || !isArray( level.a_start_weapons ) || level.a_start_weapons.size < 1 )
	{
		self zm_utility::give_start_weapon( 1 );
		return;
	}
	
	if ( IS_TRUE( USE_CHARACTER_SPECIFIC_START_WEAPON ) && isDefined( level.a_start_weapons[ self.characterindex ] ) )
		w_weapon = level.a_start_weapons[ self.characterindex ];
	else if ( IS_TRUE( NO_TWO_PLAYERS_GET_SAME_START_WEAPON ) )
	{
		if ( !isDefined( level.a_valid_start_weapons ) || !isArray( level.a_valid_start_weapons ) || level.a_valid_start_weapons.size < 1 )
			level.a_valid_start_weapons = array::randomize( level.a_start_weapons );
		
		w_weapon = array::random( level.a_valid_start_weapons );
		arrayRemoveValue( level.a_valid_start_weapons, w_weapon );
	}
	else
		w_weapon = array::random( level.a_start_weapons );
	
	DEFAULT( self.hasCompletedSuperEE, self zm_stats::get_global_stat( "DARKOPS_GENESIS_SUPER_EE" ) > 0 );
	
	if ( self.hasCompletedSuperEE )
	{
		self zm_weapons::weapon_give( w_weapon, 0, 0, 1, 0 );
		self giveMaxAmmo( w_weapon );
		self zm_weapons::weapon_give( level.super_ee_weapon, 0, 0, 1, b_switch_weapon );
	}
	else
		self zm_weapons::weapon_give( w_weapon, 0, 0, 1, b_switch_weapon );
	
}