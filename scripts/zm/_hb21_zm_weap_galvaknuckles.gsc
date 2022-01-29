/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           		Harry Bo21s Black Ops 3 Galvaknuckles				  ###
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
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

REGISTER_SYSTEM_EX( "hb21_zm_weap_galvaknuckles", &__init__, &__main__, undefined )

function private __init__()
{
}

function private __main__()
{
	level._allow_melee_weapon_switching = 1;
	zm_utility::register_melee_weapon_for_level( "t6_tazer_knuckles" );
	zm_melee_weapon::init( "t6_tazer_knuckles", "t6_tazer_knuckles_flourish", undefined, undefined, 6000, "tazer_upgrade", "Hold ^3&&1^7 to buy Galvaknuckles [Cost: 6000]", undefined, undefined );
	zm_melee_weapon::set_fallback_weapon( "t6_tazer_knuckles", "knife" );
}