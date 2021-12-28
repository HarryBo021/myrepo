#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_astro.gsh;

#namespace zm_ai_astro;

REGISTER_SYSTEM_EX( "zm_ai_astro", &__init__, undefined, undefined )

function __init__()
{
	astro_names_count = tableLookUpRowCount( "gamedata/tables/zm/zm_astro_names.csv" );
	if ( isDefined( astro_names_count ) && astro_names_count > 0 )
		clientfield::register( "actor", "astro_name_index", VERSION_SHIP, getMinBitCountForNum( astro_names_count + 1 ), "int", &set_astro_name, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
}

function set_astro_name( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	astro_name = tableLookUp( "gamedata/tables/zm/zm_astro_names.csv", 0, newval - 1, 1 );
	self setDrawName( astro_name );
}