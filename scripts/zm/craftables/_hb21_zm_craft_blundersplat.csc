/*#===================================================================###
###                                                                   ###
###                                                                   ###
###        Harry Bo21s Black Ops 3 Acidgat Upgrade Station v1.0.0	  ###
###                                                                   ###
###                                                                   ###
###===================================================================#*/
/*=======================================================================

								CREDITS

=========================================================================
Lilrifa
Easyskanka
ProRevenge
DTZxPorter
Zeroy
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MZSlayer
AndyWhelen
HitmanVere
ProGamerzFTW
Scobalula
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
=======================================================================*/
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_hb21_zm_craft_blundersplat.gsh;

#namespace zm_craft_blundersplat;

REGISTER_SYSTEM( "zm_craft_blundersplat", &__init__, undefined )

function __init__()
{
	zm_craftables::include_zombie_craftable( BLUNDERSPLAT_NAME );
	zm_craftables::add_zombie_craftable( BLUNDERSPLAT_NAME );
	
	clientfield::register( "clientuimodel", CLIENTFIELD_BLUNDERSPLAT_CRAFTED, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", CLIENTFIELD_BLUNDERSPLAT_PARTS, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_0,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_1, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_2,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

