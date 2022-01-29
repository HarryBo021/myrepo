/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           			Harry Bo21s Black Ops 3 Magmagat					  ###
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
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_magmagat.gsh;

#namespace hb21_zm_weap_magmagat; 

#precache( "client_fx", MAGMAGAT_AOE_FX );
#precache( "client_fx", MAGMAGAT_IMPACT_FX );
#precache( "client_fx", MAGMAGAT_PRESS_FIRE_FX );

REGISTER_SYSTEM_EX( "hb21_zm_weap_magmagat", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : None  
*/
function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "missile", "magmagat_missile", VERSION_SHIP, 1, "int", &magmagat_missile, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "magmagat_press_fire", VERSION_SHIP, 1, "int", &magmagat_press_fire, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
	
	// # FX REGISTRATION
	level._effect[ "magmagat_aoe" ] = MAGMAGAT_AOE_FX;
	level._effect[ "magmagat_impact" ] = MAGMAGAT_IMPACT_FX;
	level._effect[ "magmagat_press_fire" ] = MAGMAGAT_PRESS_FIRE_FX;
	// # FX REGISTRATION
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

// ============================== FUNCTIONALITY ==============================

function magmagat_press_fire( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
		self.fx_magmagat_press_fire = playFxOnTag( n_local_client_num, level._effect[ "magmagat_press_fire" ], self, "tag_fx_3_jnt" );
	else
	{
		if ( isDefined( self.fx_magmagat_press_fire ) )
		{
			stopFx( n_local_client_num, self.fx_magmagat_press_fire );
			self.fx_magmagat_press_fire = undefined;
		}
	}
}

function magmagat_missile( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( !IS_TRUE( n_new_value ) )
		return;
	
	playFxOnTag( n_local_client_num, level._effect[ "magmagat_aoe" ], self, "tag_origin" );
	playFx( n_local_client_num, level._effect[ "magmagat_impact" ], self.origin, anglesToUp( self.angles ) );
}

// ============================== FUNCTIONALITY ==============================