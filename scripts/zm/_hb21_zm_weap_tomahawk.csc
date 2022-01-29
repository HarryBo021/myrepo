/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           Harry Bo21s Black Ops 3 Hell's Retriever/Redeemer		  ###
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
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_tomahawk.gsh;

#namespace hb21_zm_weap_tomahawk; 

REGISTER_SYSTEM( "hb21_zm_weap_tomahawk", &__init__, undefined )

function __init__()
{
	clientfield::register( "clientuimodel", "tomahawk_in_use", 					VERSION_SHIP, 2, "int", undefined, 0, 1 );
	// clientfield::register( "toplayer", "upgraded_tomahawk_in_use", 	VERSION_SHIP, 1, "int", &tomahawk_in_use, 0, 1 );
	clientfield::register( "actor", "play_tomahawk_hit_sound", 			VERSION_SHIP, 1, "int", &tomahawk_play_impact_sound, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}



function tomahawk_play_impact_sound( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self playSound( n_local_client_num, "wpn_tomahawk_impact" );
}
