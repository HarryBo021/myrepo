/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###           		Harry Bo21s Black Ops 3 Dragon Shield			   ###
###                                                                   					   ###
###                                                                   					   ###
###========================================#*/
// LAST UPDATE V2.0.0 - 23/04/19
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
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_dragonshield.gsh;

#namespace hb21_zm_weap_dragonshield;

#precache( "client_fx", 									DRAGONSHIELD_FIRE_1P_FX						 );
#precache( "client_fx", 									DRAGONSHIELD_FIRE_3P_FX						 );
#precache( "client_fx", 									DRAGONSHIELD_FIRE_UPGRADED_1P_FX						 );
#precache( "client_fx", 									DRAGONSHIELD_FIRE_UPGRADED_3P_FX						 );

REGISTER_SYSTEM_EX( "hb21_zm_weap_dragonshield", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== INITIALIZE ==============================

function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_stalingrad" || script == "zm_genesis" )
		return;
	
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	clientfield::register("allplayers", DRAGONSHIELD_BURNINATE_CF, VERSION_SHIP, 1, "counter", &dragonshield_burninate, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("allplayers", DRAGONSHIELD_BURNINATE_UPGRADED_CF, VERSION_SHIP, 1, "counter", &dragonshield_burninate_upgraded, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("actor", DRAGONSHIELD_SND_PROJECTILE_IMPACT_CF, VERSION_SHIP, 1, "counter", &dragonshield_snd_projectile_impact, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("vehicle", DRAGONSHIELD_SND_PROJECTILE_IMPACT_CF, VERSION_SHIP, 1, "counter", &dragonshield_snd_projectile_impact, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("actor", DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF, VERSION_SHIP, 1, "counter", &dragonshield_snd_zombie_knockdown, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("vehicle", DRAGONSHIELD_SND_ZOMBIE_KNOCKDOWN_CF, VERSION_SHIP, 1, "counter", &dragonshield_snd_zombie_knockdown, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
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

function dragonshield_burninate( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( self isLocalPlayer() )
		playFXOnTag( n_local_client_num, DRAGONSHIELD_FIRE_1P_FX, self, "tag_flash" );
	else
		playFXOnTag( n_local_client_num, DRAGONSHIELD_FIRE_3P_FX, self, "tag_flash" );
	
}

function dragonshield_burninate_upgraded( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( self isLocalPlayer() )
		playFXOnTag( n_local_client_num, DRAGONSHIELD_FIRE_UPGRADED_1P_FX, self, "tag_flash" );
	else
		playFXOnTag( n_local_client_num, DRAGONSHIELD_FIRE_UPGRADED_3P_FX, self, "tag_flash" );
	
}

function dragonshield_snd_projectile_impact( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	playSound( n_local_client_num, "vox_dragonshield_forcehit", self.origin );
	playSound( n_local_client_num, "wpn_dragonshield_proj_impact", self.origin );
}

function dragonshield_snd_zombie_knockdown( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	playSound( n_local_client_num, "fly_dragonshield_forcehit", self.origin );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

// ============================== FUNCTIONALITY ==============================