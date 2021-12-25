/*#==========================================###
###                                                                   							###
###                                                                   							###
###              Harry Bo21s Black Ops 3 Soul Chests v2.0.0	          	###
###                                                                   							###
###                                                                   							###
###=========================================##*/
/*==============================================

								CREDITS

===============================================
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
=============================================*/
#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_soul_chests.gsh;

#precache( "client_fx", SOULCHEST_FIRE_FX );

#namespace hb21_zm_soul_chests; 

REGISTER_SYSTEM_EX( "hb21_zm_soul_chests", &__init__, &__main__, undefined )

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
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( 							"scriptmover",					SOULCHEST_GLOW_FX_CF,				VERSION_SHIP, 	1, 	"int", 	&soulchest_glow_fx_cb,				!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT														 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
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

/* 
SOULCHEST GLOW FX CB 
Description : This function controls the fire fx on the soul chest
Notes : None 
*/
function soulchest_glow_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_soulchest_glow = playFxOnTag( n_local_client_num, SOULCHEST_FIRE_FX, self, "tag_origin" );
	}
	else
	{
		stopFx( n_local_client_num, self.fx_soulchest_glow );
		self.fx_soulchest_glow = undefined;
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== EVENT OVERRIDES ==============================



// ============================== EVENT OVERRIDES ==============================