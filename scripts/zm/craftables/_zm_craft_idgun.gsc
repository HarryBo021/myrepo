#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_idgun.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\craftables\_zm_craft_idgun.gsh;

#namespace zm_craft_idgun;

REGISTER_SYSTEM_EX( "zm_craft_idgun", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "clientuimodel", 	CLIENTFIELD_IDGUN_PARTS, 										VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", 	CLIENTFIELD_IDGUN_CRAFTED, 									VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_IDGUN_ADD_TO_BOX, 								VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_IDGUN_REMOVE_FROM_BOX, 					VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_HEART,			VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_SKELETON,		VERSION_SHIP, 1, "int" );
	clientfield::register( "world", 				CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_XENOMATTER, 	VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
}

function __main__()
{
	s_heart 			= zm_craftables::generate_zombie_craftable_piece( IDGUN_NAME, "part_heart", 			32, 64, 0, 	undefined, &on_pickup_common_idgun, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_HEART, 				CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	s_skeleton 		= zm_craftables::generate_zombie_craftable_piece( IDGUN_NAME, "part_skeleton", 		32, 64, 0, 	undefined, &on_pickup_common_idgun, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_SKELETON, 		CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	s_xenomatter 	= zm_craftables::generate_zombie_craftable_piece( IDGUN_NAME, "part_xenomatter", 	32, 64, 0, 	undefined, &on_pickup_common_idgun, undefined, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_IDGUN_XENOMATTER, 	CRAFTABLE_IS_SHARED, undefined, undefined, undefined, 2 );
	
	s_idgun 						= spawnStruct();
	s_idgun.name 				= IDGUN_NAME;
	s_idgun.weaponname 	= IDGUN_GENESIS_0_WEAPON;
	s_idgun.onbuyweapon 	= &on_buy_weapon_idgun;
	s_idgun.triggerthink 		= &idgun_craftable;
	s_idgun zm_craftables::add_craftable_piece( s_heart );
	s_idgun zm_craftables::add_craftable_piece( s_skeleton );
	s_idgun zm_craftables::add_craftable_piece( s_xenomatter );
	
	zm_craftables::include_zombie_craftable( s_idgun );
	zm_craftables::add_zombie_craftable( IDGUN_NAME, "Hold ^3[{+activate}]^7 to Craft Apothicon Servant", "", "Hold ^3[{+activate}]^7 to Take Apothicon Servant", &on_fully_crafted_idgun, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::make_zombie_craftable_open( IDGUN_NAME, IDGUN_MODEL, vectorScale( ( 0, -1, 0 ), 90 ), ( 0, 0, 0 ) );
	level.zombie_craftableStubs[ IDGUN_NAME ].v_origin_offset = vectorScale( ( 0, 0, 1 ), 10 );
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function idgun_craftable()
{
	zm_craftables::craftable_trigger_think( IDGUN_NAME + "_craftable_trigger", IDGUN_NAME, IDGUN_GENESIS_0_WEAPON, "Hold ^3[{+activate}]^7 to Take Apothicon Servant", DELETE_TRIGGER, ONE_USE_AND_FLY );
}

function on_pickup_common_idgun( e_player )
{
	e_player playSound( "zmb_craftable_pickup" );	
	
	if ( isDefined( level.craft_idgun_piece_pickup_vo_override ) )
		e_player thread [ [ level.craft_idgun_piece_pickup_vo_override ] ]();
		
	foreach ( e_player_index in level.players )
		e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_IDGUN_CRAFTED, CLIENTFIELD_IDGUN_PARTS, 0 );
	
	self pickup_from_mover_idgun();
	self.piece_owner = e_player;
}


function on_fully_crafted_idgun( e_player )
{
	if ( !IS_TRUE( self.b_idgun_crafted ) )
	{
		self.b_idgun_crafted = 1;
		foreach ( e_player_index in level.players )
		{
			if ( zm_utility::is_player_valid( e_player ) )
				e_player_index thread zm_craftables::player_show_craftable_parts_ui( CLIENTFIELD_IDGUN_CRAFTED, CLIENTFIELD_IDGUN_PARTS, 1 );
			
		}	
		self.model.angles = self.angles + vectorScale( ( 0, -1, 0 ), 90 );
	}
	return 1;
}

function on_buy_weapon_idgun( player )
{
	level clientfield::set( CLIENTFIELD_IDGUN_ADD_TO_BOX, 1 );
	level.zombie_weapons[ getWeapon( IDGUN_GENESIS_0_WEAPON ) ].is_in_box = 1;
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function pickup_from_mover_idgun()
{	
	if ( isDefined( level.craft_idgun_pickup_override ) )
		[ [ level.craft_idgun_pickup_override ] ]();
	
}

// ============================== FUNCTIONALITY ==============================