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
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_one_inch_punch.gsh;

#namespace hb21_zm_weap_one_inch_punch; 

REGISTER_SYSTEM_EX( "hb21_zm_weap_one_inch_punch", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "allplayers", OIP_IMPACT_CF, VERSION_SHIP, 2, "int", &oip_impact_shake, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function oip_impact_shake( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( n_new_value >= 1 )
	{
		self earthquake( .5, .5, self.origin, 300 );
		self playRumbleOnEntity( n_local_client_num, "damage_heavy" );
		physicsExplosionCylinder( n_local_client_num, self.origin, 75 * n_new_value, 60, 1 );
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================