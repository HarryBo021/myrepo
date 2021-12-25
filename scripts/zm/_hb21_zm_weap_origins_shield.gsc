#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_equipment;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_origins_shield.gsh;

#precache( "string", "ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING" );

#namespace hb21_zm_weap_origins_shield;

REGISTER_SYSTEM_EX( "hb21_zm_weap_origins_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # VARIABLES AND SETTINGS
	zm_equipment::register( ORIGINSSHIELD_WEAPON, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_connect( &origins_shield_on_player_connect );
	callback::on_spawned( &origins_on_player_spawned );
	// # REGISTER CALLBACKS
}

function __main__()
{
	zm_equipment::register_for_level( ORIGINSSHIELD_WEAPON );
	zm_equipment::include( ORIGINSSHIELD_WEAPON );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function origins_shield_on_player_connect()
{
	self thread origins_shield_watch_first_use();
}

function origins_on_player_spawned()
{
}

function origins_shield_watch_first_use()
{
	self endon("disconnect");
	while ( IsDefined(self) )
	{
		self waittill ( "weapon_change", w_weapon );
		if ( w_weapon.name == ORIGINSSHIELD_WEAPON )
			break;
	}
	zm_equipment::show_hint_text( ORIGINSSHIELD_HINT_TEXT, ORIGINSSHIELD_HINT_TIMER );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================