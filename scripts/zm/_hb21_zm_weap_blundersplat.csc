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
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_blundersplat.gsh;

#namespace hb21_zm_weap_blundersplat; 

#precache( "client_fx", BLUNDERSPLAT_PROJECTILE_FX );

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
	clientfield::register( "missile", "blundersplat_missile", VERSION_SHIP, 1, "int", &blundersplat_missile, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// # CLIENTFIELD REGISTRATION
	
	// # FX REGISTRATION
	level._effect[ "blundersplat_light" ] = BLUNDERSPLAT_PROJECTILE_FX;
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

function blundersplat_missile( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( self.weapon.name == BLUNDERSPLAT_GRENADE_WEAPONFILE )
		self thread blundersplat_missile_sound_and_fx_loop( n_local_client_num );
	
}

function blundersplat_missile_sound_and_fx_loop( n_local_client_num )
{
	self endon( "entityshutdown" );
	
	self.e_sndent = self playLoopSound( "wpn_blundersplat_proj_loop", 0 );
	
	wait .1;
	n_interval = .3;
	while ( 1 )
	{
		fx = playFxOnTag( n_local_client_num, level._effect[ "blundersplat_light" ], self, "tag_origin" );
		wait n_interval;
		stopFx( n_local_client_num, fx );
		n_interval = n_interval / 1.2;
		if ( n_interval < .1 )
			interval = .1;
		
	}
}

// ============================== FUNCTIONALITY ==============================