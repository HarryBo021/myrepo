#using scripts\shared\ai_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai\raz; 
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_raz.gsh;

#precache( "client_fx", RAZ_EYE_FX_FILE );

#namespace zm_ai_raz;

REGISTER_SYSTEM_EX( "zm_ai_raz", &__init__, &__main__, undefined )

function __init__()
{
	level._effect[ RAZ_EYE_FX ] = RAZ_EYE_FX_FILE;
	ai::add_archetype_spawn_function( "raz", &raz_spawn_setup );
}

function __main__()
{
}

function raz_spawn_setup( n_local_client_num )
{
	self._eyeglow_fx_override = level._effect[ RAZ_EYE_FX ];
	self._eyeglow_tag_override = "tag_eye_glow";
}

