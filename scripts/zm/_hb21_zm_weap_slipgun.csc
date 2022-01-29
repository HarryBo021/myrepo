/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           			Harry Bo21s Black Ops 3 Sliquifier						  ###
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
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_slipgun.gsh;

#namespace hb21_zm_weap_slipgun; 

#precache( "client_fx", SLIPGUN_AOE_FX );

REGISTER_SYSTEM( "hb21_zm_weap_slipgun", &__init__, undefined )

function __init__()
{
	clientfield::register( "world", "add_sliquifier_to_box", 1, 1, "int", &add_sliquifier_to_box, 0, 0 );
	clientfield::register( "scriptmover", "slipgun_spot_active", VERSION_SHIP, 1, "int", &slipgun_spot_active, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function add_sliquifier_to_box( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	w_weapon = getWeapon( SLIPGUN_WEAPONFILE );
	addZombieBoxWeapon( w_weapon, w_weapon.worldmodel, w_weapon.isDualWield );
}

function slipgun_spot_active( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entity_shutdown" );
	
	if ( IS_TRUE( n_new_val ) )
	{
		if ( !isDefined( self.fx_slipspot ) )
			self.fx_slipspot = playFxOnTag( n_local_client_num, SLIPGUN_AOE_FX, self, "script_origin" );
		
	}
	else
	{
		if ( isDefined( self.fx_slipspot ) )
		{
			stopFx( n_local_client_num, self.fx_slipspot );
			self.fx_slipspot = undefined;
		}
	}
}