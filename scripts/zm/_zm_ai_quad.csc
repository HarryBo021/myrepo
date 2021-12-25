#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_quad.gsh;

#namespace zm_ai_quad; 

REGISTER_SYSTEM_EX( "zm_ai_quad", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
}

function __main__()
{
	visionset_mgr::register_overlay_info_style_blur( "zm_ai_quad_blur", 21000, 1, 0.1, 0.5, 4 );
}

// ============================== INITIALIZE ==============================