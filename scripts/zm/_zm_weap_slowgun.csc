#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_slowgun.gsh;

#precache( "client_fx", "weapon/paralyzer/fx_paralyzer_body_disintegrate" );
#precache( "client_fx", "weapon/paralyzer/fx_paralyzer_body_disintegrate_ug" );
#precache( "client_fx", "weapon/paralyzer/fx_paralyzer_hit_dmg" );
#precache( "client_fx", "weapon/paralyzer/fx_paralyzer_hit_dmg_ug" );
#precache( "client_fx", "weapon/paralyzer/fx_paralyzer_hit_noharm_view" );

#namespace zm_weap_slowgun; 

REGISTER_SYSTEM( "zm_weap_slowgun", &__init__, undefined )

function __init__()
{
	clientfield::register( "actor", "anim_rate", VERSION_SHIP, 5, "float", &zm_audio::sndsetzombiecontext, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers", "anim_rate", VERSION_SHIP, 5, "float", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "sndParalyzerLoop", VERSION_SHIP, 1, "int", &sndparalyzerloop, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "slowgun_fx", VERSION_SHIP, 3, "int", &slowgun_actor_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "slowgun_fx", VERSION_SHIP, 1, "int", &slowgun_player_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	setupClientfieldAnimSpeedCallbacks( "actor", 1, "anim_rate" );
	setupClientfieldAnimSpeedCallbacks( "allplayers", 1, "anim_rate" );
	
	level.weaponZMSlowGun = getWeapon( SLOWGUN_WEAPONFILE );
	level.weaponZMSlowGunUpgraded = getWeapon( SLOWGUN_UPGRADED_WEAPONFILE );
	callback::on_localplayer_spawned( &localplayer_spawned );	
	level._effect["zombie_slowgun_explosion"] = "weapon/paralyzer/fx_paralyzer_body_disintegrate";
	level._effect["zombie_slowgun_explosion_ug"] = "weapon/paralyzer/fx_paralyzer_body_disintegrate_ug";
	level._effect["zombie_slowgun_sizzle"] = "weapon/paralyzer/fx_paralyzer_hit_dmg";
	level._effect["zombie_slowgun_sizzle_ug"] = "weapon/paralyzer/fx_paralyzer_hit_dmg_ug";
	level._effect["player_slowgun_sizzle_1st"] = "weapon/paralyzer/fx_paralyzer_hit_noharm_view";
}

function slowgun_dial_sounds( localclientnum )
{
	self notify( "stop_slowgun_dial_sounds" );
	self endon( "stop_slowgun_dial_sounds" );
	self endon( "disconnect" );
	self endon( "entityshutdown" );
	self.slowgun_digit1 = 0;
	while ( 1 )
	{
		overheating = isWeaponOverHeating( localclientnum, 0 );
		heat = isWeaponOverHeating( localclientnum, 1 );
		digit1 = int( heat ) % 10;
		if ( self.slowgun_digit1 != digit1 )
			self playSound( localclientnum, "wpn_paralyzer_counter_tick" );
		
		self.slowgun_digit1 = digit1;
		wait .05;
	}
}

function sndparalyzerloop(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if ( newval == 1 )
	{
		if ( !isDefined( self.sndparalyzerloopent ) )
			self.sndparalyzerloopent = spawn( 0, self.origin, "script_origin" );
		
		self.sndparalyzerloopent playLoopSound( "fly_paralyzer_loop", 1 );
		self thread slowgun_dial_sounds( localclientnum );
	}
	else if ( isDefined( self.sndparalyzerloopent ) )
	{
		self.sndparalyzerloopent delete();
		self.sndparalyzerloopent = undefined;
	}
	self notify( "stop_slowgun_dial_sounds" );
}

function slowgun_player_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( newval )
		self thread play_sizzle_player( localclientnum );
	else
		self notify( "end_sizzle" );
	
}

function play_sizzle_player( localclientnum, upgraded )
{
	self notify( "end_sizzle");
	self endon( "end_sizzle");
	followed = playerBeingSpectated( localclientnum );
	while ( isDefined( self ) && followed == playerBeingSpectated( localclientnum ) )
	{
		sizzle = "player_slowgun_sizzle_1st";
		if ( isDefined( level._effect[ sizzle ] ) )
			playViewmodelFx( localclientnum, level._effect[ sizzle ], "tag_camera" );
		
		wait .1;
	}
}


function slowgun_actor_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	upgraded = ( newval == 6 || newval == 5 );
	if ( newval == 6 || newval == 2 )
	{
		self notify( "end_sizzle" );
		tag1 = "j_head";
		tag2 = "j_spinelower";
		tag3 = "j_elbow_le";
		tag4 = "j_elbow_ri";
		if ( IS_TRUE( self.isdog ) )
		{
			tag1 = "tag_origin";
			tag2 = "tag_origin";
			tag3 = "tag_origin";
			tag4 = "tag_origin";
		}
		self playSound( localclientnum, "wpn_paralyzer_dsintegrate" );
		effect = "zombie_slowgun_explosion";
		if ( upgraded )
			effect = "zombie_slowgun_explosion_ug";
		
		if ( isDefined( level._effect[ effect ] ) )
		{
			angles = self.angles;
			forward = anglesToForward( angles );
			right = anglesToForward( angles );
			which = randomInt( 3 );
			playFx( localclientnum, level._effect[ effect ], self getTagOrigin( tag2 ), -1 * forward );
			switch ( which )
			{
				case 0:
				{
					playFx( localclientnum, level._effect[ effect ], self getTagOrigin( tag1 ), forward );
					break;
				}
				case 1:
				{
					back_and_to_the_left = -.5 * ( forward + right );
					playFx( localclientnum, level._effect[ effect ], self getTagOrigin( tag3 ), back_and_to_the_left );
					break;
				}
				default:
				{
					playFx( localclientnum, level._effect[ effect ], self getTagOrigin(tag4), right );
					break;
				}
			}
		}
		if ( !IS_TRUE( self.isdog ) )
			wait .1;
		
	}
	else if ( newval == 5 || newval == 1 )
		self thread play_sizzle( localclientnum, upgraded );
	else
		self notify( "end_sizzle" );
	
}

function play_sizzle( localclientnum, upgraded )
{
	self notify( "end_sizzle" );
	self endon( "end_sizzle" );
	while ( isDefined( self ) )
	{
		sizzle = "zombie_slowgun_sizzle";
		if ( upgraded )
			sizzle = "zombie_slowgun_sizzle_ug";
		
		if ( !isDefined( self.slowgun_sizzle_bone ) || randomInt( 4 ) == 0 )
			self pick_slowgun_sizzle_bone();
		
		if ( isDefined( level._effect[ sizzle ] ) )
			playFxOnTag( localclientnum, level._effect[ sizzle ], self, self.slowgun_sizzle_bone );
		
		wait .1;
	}
}

function pick_slowgun_sizzle_bone()
{
	bone = "";
	which = randomInt( 3 );
	switch ( which )
	{
		case 0:
		{
			bone = "j_spinelower";
			break;
		}
		case 1:
		{
			bone = "j_spineupper";
			break;
		}
		default:
		{
			bone = "j_spine4";
			break;
		}
	}
	self.slowgun_sizzle_bone = bone;
}

function __main__()
{	
	callback::on_localplayer_spawned( &localplayer_spawned );
}

function localplayer_spawned( localClientNum )
{
	self thread watch_for_slowguns( localClientNum );
}

function watch_for_slowguns( localclientnum )
{
	self endon( "disconnect" );
	self notify( "watch_for_slowguns" );
	self endon( "watch_for_slowguns" );

	while( isdefined(self) )
	{
		self waittill( "weapon_change", w_new_weapon, w_old_weapon ); 
		
		if ( w_new_weapon == level.weaponZMSlowGun || w_new_weapon == level.weaponZMSlowGunUpgraded )
			self thread slowgun_colour_change( localclientnum, w_new_weapon, w_new_weapon == level.weaponZMSlowGunUpgraded );
		
	}
}

function slowgun_colour_change( localclientnum, w_weapon, b_is_upgraded )
{
	self endon( "disconnect" );
	self endon( "weapon_change" ); 
	
	while ( 1 )
	{
		wait .01;
		n_state = isWeaponOverHeating( localclientnum, 0, w_weapon );
		setUIModelValue( GetUIModel( GetUIModelForController( localclientnum ), "currentWeapon.isOverHeating" ), int( n_state ) );
		
		if ( IS_TRUE( n_state ) )
			n_state = 2;
		else if ( IS_TRUE( b_is_upgraded ) )
			n_state = 1;
		
		n_brightness = isWeaponOverHeating( localclientnum, 1, w_weapon );
		
		setUIModelValue( GetUIModel( GetUIModelForController( localclientnum ), "currentWeapon.overHeatPercent" ), n_brightness );
		n_brightness = int(n_brightness) / 100;
		
		if ( n_brightness < .2 )
			n_brightness = .2;
		
		self mapShaderConstant( localClientNum, 0, "scriptVector2", 1, n_brightness, n_state, 0 );
	}
}