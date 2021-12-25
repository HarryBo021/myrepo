#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
	
#namespace zm_craft_fuse;

#precache( "client_fx", "zombie/fx_fuse_glow_blue_zod_zmb" );

REGISTER_SYSTEM_EX( "zm_craft_fuse", &__init__, &__main__, undefined )

function __init__()
{
	RegisterClientField( "world", "police_box_fuse_01", 1, 1, "int", &zm_utility::setSharedInventoryUIModels, 0 );
	RegisterClientField( "world", "police_box_fuse_02", 1, 1, "int", &zm_utility::setSharedInventoryUIModels, 0 );
	RegisterClientField( "world", "police_box_fuse_03", 1, 1, "int", &zm_utility::setSharedInventoryUIModels, 0 );
	RegisterClientField( "scriptmover", "item_glow_fx", 1, 1, "int", &item_glow_fx, 0, 0 );
	
	level._effect[ "fuse_glow" ] = "zombie/fx_fuse_glow_blue_zod_zmb";
	
	zm_craftables::include_zombie_craftable( "police_box" );
	zm_craftables::add_zombie_craftable( "police_box" );
}

function __main__()
{
}

function item_glow_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self notify( "item_glow_fx" );
	self endon( "item_glow_fx" );
	self util::waittill_dobj( n_local_client_num );
	if ( !isDefined( self ) )
		return;
	
	if ( isDefined( self.item_glow_fx ) )
	{
		stopFx(n_local_client_num, self.item_glow_fx );
		self.item_glow_fx = undefined;
	}
	self.item_glow_fx = playFXOnTag( n_local_client_num, level._effect[ "fuse_glow" ], self, "tag_origin" );
}