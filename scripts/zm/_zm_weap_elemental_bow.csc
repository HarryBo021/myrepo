#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_default_ambient_1p_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_default_impact_zmb" );
#precache( "client_fx", "dlc1/zmb_weapon/fx_bow_default_impact_ug_zmb" );

#namespace zm_weap_elemental_bow;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow", &__init__, undefined, undefined )

function __init__()
{
	clientfield::register( "toplayer", "elemental_bow" + "_ambient_bow_fx", VERSION_SHIP, 1, "int", &elemental_bow_ambient_bow_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", "elemental_bow4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int", &elemental_bow4_arrow_impact_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ "elemental_bow_ambient_bow" ] = "dlc1/zmb_weapon/fx_bow_default_ambient_1p_zmb";
	level._effect[ "elemental_bow_arrow_impact" ] = "dlc1/zmb_weapon/fx_bow_default_impact_zmb";
	level._effect[ "elemental_bow_arrow_charged_impact" ] = "dlc1/zmb_weapon/fx_bow_default_impact_ug_zmb";
	setDvar( "bg_chargeShotUseOneAmmoForMultipleBullets", 0 );
	setDvar( "bg_zm_dlc1_chargeShotMultipleBulletsForFullCharge", 2 );
}

function elemental_bow_ambient_bow_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	self elemental_bow_ambient_bow_fx_start( localclientnum, newval, "elemental_bow_ambient_bow" );
}

function elemental_bow_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "elemental_bow_arrow_impact" ], self.origin );
	
}

function elemental_bow4_arrow_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( newval )
		playFx( localclientnum, level._effect[ "elemental_bow_arrow_charged_impact" ], self.origin );
	
}

function elemental_bow_ambient_bow_fx_delete_old( localclientnum, str_fx_name )
{
	if ( isDefined( self.fx_bow_fx_02 ) && isDefined( self.fx_bow_fx_02[ str_fx_name ] ) )
		deleteFx( localclientnum, self.fx_bow_fx_02[ str_fx_name ], 1 );
	
	if ( isDefined( self.fx_bow_fx_03 ) && isDefined( self.fx_bow_fx_03[ str_fx_name ] ) )
		deleteFx( localclientnum, self.fx_bow_fx_03[ str_fx_name ], 1 );
	
}

function elemental_bow_ambient_bow_fx_start( localclientnum, newval, str_fx_name )
{
	elemental_bow_ambient_bow_fx_delete_old( localclientnum, str_fx_name );
	if ( newval )
	{
		if ( !isSpectating( localclientnum ) )
		{
			currentweapon = getCurrentWeapon( localclientnum );
			if ( isSubStr( currentweapon.name, "elemental_bow" ) )
			{
				self.fx_bow_fx_02[ str_fx_name ] = playViewModelFx( localclientnum, level._effect[ str_fx_name], "tag_fx_02" );
				self.fx_bow_fx_03[ str_fx_name ] = playViewModelFx( localclientnum, level._effect[ str_fx_name], "tag_fx_03" );
			}
		}
		
	}
}