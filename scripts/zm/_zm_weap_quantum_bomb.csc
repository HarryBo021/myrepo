#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_powerup_lose_points;
#using scripts\zm\_zm_powerup_empty_clip;
#using scripts\zm\_zm_powerup_lose_perk;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_quantum_bomb.gsh;

#precache( "client_fx", QUANTUM_BOMB_VIEWMODEL_TWIST_FX );
#precache( "client_fx", QUANTUM_BOMB_VIEWMODEL_PRESS_FX );

#namespace zm_weap_quantum_bomb;

REGISTER_SYSTEM_EX( "zm_weap_quantum_bomb", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # REGISTER FX
	level._effect[ "quantum_bomb_viewmodel_twist" ] = QUANTUM_BOMB_VIEWMODEL_TWIST_FX;
	level._effect[ "quantum_bomb_viewmodel_press" ] = QUANTUM_BOMB_VIEWMODEL_PRESS_FX;
	level._effect[ "powerup_on_red" ] = "zombie/fx_powerup_on_red_zmb";
	// # REGISTER FX
	
	// # REGISTER CALLBACKS
	callback::add_weapon_type( getWeapon( "t7_quantum_bomb" ), &quantum_bomb_spawned );
	level thread quantum_bomb_notetrack_think();
	// # REGISTER CALLBACKS
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function quantum_bomb_notetrack_think()
{
	for ( ; ; )
	{
		level waittill( "notetrack", n_local_client_num, str_note );
		switch ( str_note )
		{
			case "quantum_bomb_twist":
			{
				playViewmodelFX( n_local_client_num, level._effect[ "quantum_bomb_viewmodel_twist" ], "tag_weapon" );
				break;
			}
			case "quantum_bomb_press":
			{
				playViewmodelFX( n_local_client_num, level._effect[ "quantum_bomb_viewmodel_press" ], "tag_weapon" );
				break;
			}
		}
	}
}

function quantum_bomb_spawned( n_local_client_num, b_play_sound )
{
	e_temp_ent = spawn( 0, self.origin, "script_origin" );
	e_temp_ent playLoopSound( "wpn_quantum_rise", .5 );
	while ( isDefined( self ) )
	{
		e_temp_ent.origin = self.origin;
		wait .05;
	}
	e_temp_ent delete();
}

// ============================== CALLBACKS ==============================