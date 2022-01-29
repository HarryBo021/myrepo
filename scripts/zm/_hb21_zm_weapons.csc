#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_hb21_zm_weap_utility;
#using scripts\zm\_zm_t6_weapons;
#using scripts\zm\_zm_t7_weapons;
#using scripts\zm\_zm_t8_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_weapons;

REGISTER_SYSTEM_EX( "hb21_zm_weapons", &__init__, &__main__, undefined )

function __init__()
{
	luiLoad( "ui.uieditor.widgets.hud.zm_ammowidgetfactory_mod.zmammo_propfactory" );
	luiLoad( "ui.uieditor.widgets.hud.zm_ammowidgetfactory_mod.zmammo_clipinfofactory" );
}

function __main__()
{
}