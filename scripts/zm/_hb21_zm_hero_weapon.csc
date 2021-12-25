#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

// SPECIALISTS
#using scripts\shared\ai\margwa;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_weap_dragon_gauntlet;
#using scripts\zm\_zm_weap_keeper_skull;
#using scripts\zm\_zm_weap_glaive;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_hero_weapon;

REGISTER_SYSTEM_EX( "hb21_zm_hero_weapon", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "clientuimodel", "hero_weapon_icon_change", VERSION_SHIP, 5, "int", &hero_weapon_icon_change, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	luiLoad( "ui.uieditor.widgets.hud.zm_ammowidgetfactory_mod.zmammo_dpadiconpistolfactory" );
}

function __main__()
{
	
}

function hero_weapon_icon_change( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	ui_model = createUIModel( getUIModelForController( n_local_client_num ), "hudItems.hero_weapon_icon" );
	setUIModelValue( ui_model, n_new_value );
}