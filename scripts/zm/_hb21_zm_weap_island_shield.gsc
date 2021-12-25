#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_equipment;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_island_shield.gsh;

#precache( "string", "ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING" );

#namespace hb21_zm_weap_island_shield;

REGISTER_SYSTEM_EX( "hb21_zm_weap_island_shield", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # VARIABLES AND SETTINGS
	zm_equipment::register( ISLANDSHIELD_WEAPON, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" );
	// # VARIABLES AND SETTINGS
	
	// # REGISTER CALLBACKS
	callback::on_connect( &island_shield_on_player_connect );
	callback::on_spawned( &island_on_player_spawned );
	// # REGISTER CALLBACKS
}

function __main__()
{
	zm_equipment::register_for_level( ISLANDSHIELD_WEAPON );
	zm_equipment::include( ISLANDSHIELD_WEAPON );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function island_shield_on_player_connect()
{
	self thread island_shield_watch_first_use();
}

function island_on_player_spawned()
{
}

function island_shield_watch_first_use()
{
	self endon("disconnect");
	while ( IsDefined(self) )
	{
		self waittill ( "weapon_change", w_weapon );
		if ( w_weapon.name == ISLANDSHIELD_WEAPON )
			break;
			
	}
	zm_equipment::show_hint_text( ISLANDSHIELD_HINT_TEXT, ISLANDSHIELD_HINT_TIMER );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================