#using scripts\codescripts\struct;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_placeable_mine;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_dragon_strike.gsh;

#namespace dragon_strike;

#precache( "model", DRAGON_STRIKE_AIRSTRIKE_DRAGON );

REGISTER_SYSTEM_EX( "zm_weap_dragon_strike", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "scriptmover", DRAGON_STRIKE_SPAWN_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_ON_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_FX_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_FX_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_INVALID_FX_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_INVALID_FX_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_FLARE_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_FX_FADEOUT_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", DRAGON_STRIKE_MARKER_UPGRADED_FX_FADEOUT_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", DRAGON_STRIKE_ZOMBIE_FIRE_CF, VERSION_SHIP, 2, "int" );
	clientfield::register( "vehicle", DRAGON_STRIKE_ZOMBIE_FIRE_CF, VERSION_SHIP, 2, "int" );
	clientfield::register( "clientuimodel", DRAGON_STRIKE_INVALID_USE_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "clientuimodel", DRAGON_STRIKE_HUD_ICON_CF, VERSION_SHIP, 1, "int" );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER DRAGON STRIKE WEAPONS
	level.a_dragon_strike_weapons = [];
	register_dragon_strike_weapon_for_level( getWeapon( DRAGON_STRIKE_WEAPON ), undefined, undefined, undefined, &dragonstike_weapon_obtained_cb, &dragonstike_weapon_lost_cb, undefined, undefined, undefined, undefined, undefined );
	register_dragon_strike_weapon_for_level( getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ), undefined, undefined, undefined, &dragonstike_weapon_obtained_cb, &dragonstike_weapon_lost_cb, undefined, undefined, undefined, undefined, undefined );
	// # REGISTER DRAGON STRIKE WEAPONS

	// # REGISTER CALLBACKS
	level.func_custom_placeable_mine_round_replenish = &dragon_strike_placeable_mine_round_replenish;
	zm::register_player_damage_callback( &dragon_strike_player_damage_callback );
	zm_spawner::register_zombie_death_event_callback( &dragon_strike_zombie_death_event );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned );
	// # REGISTER CALLBACKS
}

function register_dragon_strike_weapon_for_level( ut_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined, ptr_weapon_first_raise_cb = undefined, ptr_weapon_charge_cb = undefined )
{	
	w_weapon = ( !isWeapon( ut_weapon ) ? getWeapon( ut_weapon ) : ut_weapon );
	
	w_weapon.ptr_weapon_fired_cb				= ptr_weapon_fired_cb;
	w_weapon.ptr_weapon_missile_fired_cb	= ptr_weapon_missile_fired_cb;
	w_weapon.ptr_weapon_grenade_fired_cb	= ptr_weapon_grenade_fired_cb;
	w_weapon.ptr_weapon_obtained_cb 		= ptr_weapon_obtained_cb;
	w_weapon.ptr_weapon_lost_cb 				= ptr_weapon_lost_cb;
	w_weapon.ptr_weapon_reloaded_cb 		= ptr_weapon_reloaded_cb;
	w_weapon.ptr_weapon_pullout_cb 			= ptr_weapon_pullout_cb;
	w_weapon.ptr_weapon_putaway_cb 		= ptr_weapon_putaway_cb;
	w_weapon.ptr_weapon_first_raise_cb 		= ptr_weapon_first_raise_cb;
	w_weapon.ptr_weapon_charge_cb 			= ptr_weapon_charge_cb;
	
	ARRAY_ADD( level.a_dragon_strike_weapons, w_weapon );
}

function __main__()
{
	zm_placeable_mine::add_mine_type( DRAGON_STRIKE_WEAPON );
	zm_placeable_mine::add_mine_type( DRAGON_STRIKE_UPGRADED_WEAPON );
	if ( isDefined( level.retrieveHints[ DRAGON_STRIKE_WEAPON ] ) )
		arrayRemoveIndex( level.retrieveHints, DRAGON_STRIKE_WEAPON, 1 );
	
	if ( isDefined( level.retrieveHints[ DRAGON_STRIKE_UPGRADED_WEAPON ] ) )
		arrayRemoveIndex( level.retrieveHints, DRAGON_STRIKE_UPGRADED_WEAPON, 1 );
	
	s_dragon_strike_struct = struct::get( "dragon_strike_controller", "targetname" );
	if ( isDefined( s_dragon_strike_struct ) )
		s_dragon_strike_struct thread dragon_strike_controller();
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

function dragonstike_weapon_obtained_cb( w_weapon )
{
	self thread zm_equipment::show_hint_text( "Hold [{+actionslot 4}] to equip Dragon Strike Controller" );
	self clientfield::set_player_uimodel( DRAGON_STRIKE_HUD_ICON_CF, 1 );
}

function dragonstike_weapon_lost_cb( w_weapon )
{
	self clientfield::set_player_uimodel( DRAGON_STRIKE_HUD_ICON_CF, 0 );
}

function on_player_connect()
{
	self thread dragon_strike_watch_first_use();
	self thread on_player_disconnect();
	self thread dragon_strike_player_watch_max_ammo();
}

function on_player_spawned()
{
	if ( !self flag::exists( "show_dragon_strike_reticule" ) )
		self flag::init( "show_dragon_strike_reticule" );
	
	if ( !self flag::exists( "dragon_strike_active" ) )
		self flag::init( "dragon_strike_active" );
	
	self thread dragon_strike_watch_weapon_change();
	self thread dragon_strike_specify_weapon_request();
}

function dragon_strike_player_damage_callback( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time, n_bone_index )
{
	if ( isDefined( e_inflictor ) && isDefined( e_inflictor.item ) && ( e_inflictor.item == getWeapon( DRAGON_STRIKE_FIRE_WEAPON ) || e_inflictor.item == getWeapon( DRAGON_STRIKE_FIRE_UPGRADED_WEAPON ) ) )
		return 0;
	else
		return -1;
	
}

function dragon_strike_placeable_mine_round_replenish()
{
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		foreach ( e_placeable_mine in level.placeable_mines )
		{
			if ( a_players[ i ] zm_utility::is_player_placeable_mine( e_placeable_mine ) )
			{
				if ( e_placeable_mine == getWeapon( DRAGON_STRIKE_WEAPON ) || e_placeable_mine == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
				{
					a_players[ i ] dragon_strike_give_ammo();
					continue;
				}
				a_players[ i ] giveWeapon( e_placeable_mine );
				a_players[ i ] zm_utility::set_player_placeable_mine( e_placeable_mine );
				a_players[ i ] setActionSlot( 4, "weapon", e_placeable_mine );
				a_players[ i ] setWeaponAmmoClip( e_placeable_mine, 2 );
				break;
			}
		}
	}
}

function dragon_strike_zombie_death_event( e_attacker )
{
	if ( isDefined( self ) && ( self.damageWeapon === getWeapon( DRAGON_STRIKE_FIRE_WEAPON ) || self.damageWeapon === getWeapon( DRAGON_STRIKE_FIRE_UPGRADED_WEAPON ) ) )
	{
		if ( isDefined( e_attacker ) && isDefined( e_attacker.player ) )
			e_attacker.player.n_dragon_strike_kills++;
		
	}
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

function dragon_strike_controller()
{
	self endon( "kill_trigger" );
	self zm_unitrigger::create_unitrigger( "Press & hold ^3&&1^7 for Dragon Strike Controller", 64, &dragon_strike_prompt_and_visibility, undefined );
	e_model = getEnt( self.target, "targetname" );
	e_model scene::init( "p7_fxanim_zm_stal_dragon_strike_console_bundle", e_model) ;
	e_model playLoopSound( "zmb_ds_machine_lp" );
	while ( isDefined( self ) )
	{
		self waittill( "trigger_activated", e_player );
		
		if ( e_player hasWeapon( getWeapon( DRAGON_STRIKE_WEAPON ) ) )
			continue;
			
		e_player playSound( "zmb_ds_machine_grab" );
		e_player zm_weapons::weapon_give( getWeapon( DRAGON_STRIKE_WEAPON ), 0, 0, 1, 1 );
	}
}

function dragon_strike_prompt_and_visibility( e_player )
{	
	b_visible = 1;
	if ( e_player hasWeapon( getWeapon( DRAGON_STRIKE_WEAPON ) ) )
		b_visible = 0;
		
	if ( b_visible )
		self setVisibleToPlayer( e_player );
	else
		self setInvisibleToPlayer( e_player );
		
	return b_visible;
}

function dragon_strike_player_watch_max_ammo()
{
	self endon( "disconnect" );
	self notify( "dragon_strike_player_watch_max_ammo" );
	self endon( "dragon_strike_player_watch_max_ammo" );
	for ( ; ; )
	{
		self waittill( "zmb_max_ammo" );
		wait .05;
		self dragon_strike_give_ammo();
	}
}

function dragon_strike_give_ammo()
{
	w_dragon_strike = self zm_utility::get_player_placeable_mine();
	if ( w_dragon_strike == getWeapon( DRAGON_STRIKE_WEAPON ) )
		n_max_ammo = 1;
	else if ( w_dragon_strike == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
		n_max_ammo = 2;
	else
		return;
	
	if ( self getAmmoCount( w_dragon_strike ) < n_max_ammo )
	{
		if ( array::contains( level.a_dragon_riders, self ) )
			self waittill( "dragon_rider_exit" ); // hash_2e47bc4a
		
		self setWeaponAmmoClip( w_dragon_strike, n_max_ammo );
	}
}

function on_player_disconnect()
{
	self waittill( "disconnect" );
	if ( isDefined( self.e_dragon_strike_marker ) && !self flag::get( "dragon_strike_active" ) )
	{
		e_dragon_strike_marker = self.e_dragon_strike_marker;
		e_dragon_strike_marker clientfield::set( DRAGON_STRIKE_MARKER_ON_CF, 0 );
		wait .3;
		e_dragon_strike_marker delete();
	}
}

function dragon_strike_watch_first_use()
{
	self endon( "disconnect" );
	while ( isDefined(self ) )
	{
		self waittill( "weapon_change", w_weapon );
		if ( w_weapon == getWeapon( DRAGON_STRIKE_WEAPON ) )
			break;
		
	}
	zm_equipment::show_hint_text( "Press [{+attack}] for Dragon Strike" );
}

function dragon_strike_watch_weapon_change()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "weapon_change", w_weapon, w_previous_weapon );
		if ( is_dragon_strike_weapon( w_weapon ) )
		{
			if ( self.b_dragon_strike_active === 0 )
			{
				self playSoundToPlayer( DRAGON_STRIKE_UI_ERROR_SND, self );
				self thread zm_equipment::show_hint_text( "Dragon Strike unavailable." );
				self switch_to_weapon_if_primary( w_previous_weapon );
				continue;
			}
			else
				self thread dragon_strike_watch_fired( w_previous_weapon );
			
		}
		else
		{
			self notify( "dragon_strike_cancel" );
			self flag::clear( "show_dragon_strike_reticule" );
		}
	}
}

function is_dragon_strike_weapon( w_weapon )
{
	if ( w_weapon == getWeapon( DRAGON_STRIKE_WEAPON ) || w_weapon == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
		return 1;
	
	return 0;
}

function dragon_strike_watch_fired( w_previous_weapon )
{
	self endon( "dragon_strike_cancel" );
	self endon( "disconnect" );
	self flag::set( "show_dragon_strike_reticule" );
	self thread dragon_strike_marker_origin_logic();
	self waittill( "weapon_fired" );
	if ( self flag::get( "dragon_strike_active" ) )
	{
		self playSoundToPlayer( DRAGON_STRIKE_UI_ERROR_SND, self );
		self thread zm_equipment::show_hint_text( "Dragon Strike inbound!" );
		self switch_to_weapon_if_primary( w_previous_weapon );
		return;
	}
	else if ( self dragon_strike_marker_origin_exists() )
	{
		self flag::set( "dragon_strike_active" );
		self playSoundToPlayer( DRAGON_STRIKE_UI_ACTIVATE_SND, self );
		self zm_audio::create_and_play_dialog( "dragon_strike", "call_in" );
		self util::delay( .5, "death", &switch_to_weapon_if_primary, w_previous_weapon );
		self thread dragon_strike_fired( self.s_dragon_strike_marker );
		self thread dragon_strike_waittill_done();
		return;
	}
	self playSoundToPlayer( DRAGON_STRIKE_UI_ERROR_SND, self );
	self thread zm_equipment::show_hint_text( "Invalid Dragon Strike location." );
	self dragon_strike_give_ammo();
	self thread dragon_strike_watch_fired( w_previous_weapon );
}

function dragon_strike_marker_origin_exists()
{
	if ( isDefined( self.v_dragon_strike_marker_origin ) )
		return 1;
	
	return 0;
}

function dragon_strike_waittill_done()
{
	self endon( "disconnect" );
	self.b_dragon_strike_active = 0;
	self flag::wait_till_clear( "dragon_strike_active" );
	self.b_dragon_strike_active = 1;
	// if ( IS_TRUE( level.var_d4286019 ) )
	// {
	// 	w_dragon_strike = self zm_utility::get_player_placeable_mine();
	// 	self dragon_strike_give_ammo();
	// }
}

function dragon_strike_dragon_flyover_animation( s_dragon_strike_marker )
{
	self clientfield::set( DRAGON_STRIKE_SPAWN_FX_CF, 1 );
	self thread animation::play( DRAGON_STRIKE_AIRSTRIKE_ANIM, self );
}

function dragon_strike_fired( s_dragon_strike_marker )
{
	self endon( "disconnect" );
	w_dragon_strike = self zm_utility::get_player_placeable_mine();
	if ( w_dragon_strike == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
	{
		b_upgraded = 1;
		n_range = DRAGON_STRIKE_UPGRADED_RANGE;
		n_attract_distance = DRAGON_STRIKE_UPGRADED_ATTRACT_RANGE;
		w_dragon_strike = getWeapon( DRAGON_STRIKE_FIRE_UPGRADED_WEAPON );
	}
	else
	{
		b_upgraded = 0;
		n_range = DRAGON_STRIKE_RANGE;
		n_attract_distance = DRAGON_STRIKE_ATTRACT_RANGE;
		w_dragon_strike = getWeapon( DRAGON_STRIKE_FIRE_WEAPON );
	}
	self setWeaponAmmoClip( w_dragon_strike, self getAmmoCount( w_dragon_strike ) - 1 );
	self flag::clear( "show_dragon_strike_reticule" );
	self.e_dragon_strike_marker thread dragon_strike_poi_control( n_attract_distance, w_dragon_strike );
	level thread dragon_strike_dragon_flyover( self, s_dragon_strike_marker, b_upgraded, n_range, w_dragon_strike );
	level waittill( "dragon_strike_anim_done" );
	self notify( "dragon_strike_exploded", self.n_dragon_strike_kills );
	self flag::clear( "dragon_strike_active" );
}

function dragon_strike_dragon_flyover( e_player, s_dragon_strike_marker, b_upgraded, n_range, e_attacker )
{
	e_dragon = util::spawn_anim_model( DRAGON_STRIKE_AIRSTRIKE_DRAGON, s_dragon_strike_marker.var_53d81d57, s_dragon_strike_marker.angles + vectorScale( ( 1, 0, 0 ), 25 ) );
	e_dragon dragon_strike_dragon_flyover_animation( s_dragon_strike_marker );
	if ( isDefined( e_player ) )
	{
		e_dragon.player = e_player;
		e_player.n_dragon_strike_kills = 0;
	}
	for ( i = 0; i < 4; i++ )
	{
		e_dragon waittill( "fireball" );
		e_dragon.v_dragon_throat_origin = e_dragon getTagOrigin( "tag_throat_fx" );
		n_fireballs = 6;
		do
		{
			v_new_origin = s_dragon_strike_marker.v_loc + dragon_strike_add_vectors();
			n_fireballs--;
		}
		while ( bulletTracePassed( e_dragon.v_dragon_throat_origin, v_new_origin, 0, e_dragon ) && n_fireballs > 0 );
		e_bullet = magicBullet( e_attacker, e_dragon.v_dragon_throat_origin, v_new_origin, e_dragon );
		level thread dragon_strike_set_ai_clientfields( b_upgraded, e_bullet, s_dragon_strike_marker.v_loc, n_range );
	}
	e_dragon thread dragon_strike_wait_for_anim();
	while ( isDefined( e_bullet ) )
		wait .05;
	
	level notify( "dragon_strike_over" );
}

function dragon_strike_set_ai_clientfields( b_upgraded, e_bullet, v_origin, n_range )
{
	while ( isDefined( e_bullet ) )
		wait .05;
	
	a_ai_zombies = array::get_all_closest( v_origin, getAIArchetypeArray( "zombie" ), undefined, undefined, n_range );
	if ( b_upgraded )
		n_clientfield = 2;
	else
		n_clientfield = 1;
	
	foreach( ai_zombie in a_ai_zombies )
	{
		if ( isDefined( ai_zombie ) && !IS_TRUE( ai_zombie.b_dragon_strike_immune ) )
		{
			ai_zombie clientfield::set( DRAGON_STRIKE_ZOMBIE_FIRE_CF, n_clientfield );
			wait randomFloat( .1 );
		}
	}
}

function dragon_strike_add_vectors()
{
	n_x = randomIntRange( -50, 50 );
	n_y = randomIntRange( -50, 50 );
	v_angles = ( n_x, n_y, 0 );
	return v_angles;
}

function dragon_strike_poi_control( n_attract_distance, w_dragon_strike )
{
	self clientfield::set( DRAGON_STRIKE_FLARE_FX_CF, 1 );
	v_origin = getClosestPointOnNavMesh( self.origin, 128 );
	e_poi = util::spawn_model( "tag_origin", v_origin );
	e_poi zm_utility::create_zombie_point_of_interest( n_attract_distance, 64, 10000 );
	level waittill( "dragon_strike_over" );
	if ( isDefined( self ) )
	{
		self clientfield::set( DRAGON_STRIKE_FLARE_FX_CF, 0 );
		if ( w_dragon_strike == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
			self clientfield::increment( DRAGON_STRIKE_MARKER_UPGRADED_FX_FADEOUT_CF );
		else
			self clientfield::increment( DRAGON_STRIKE_MARKER_FX_FADEOUT_CF );
		
	}
	e_poi delete();
	wait 3.5;
	if ( isDefined( self ) )
		self clientfield::set( DRAGON_STRIKE_MARKER_ON_CF, 0 );
	
	wait .3;
	if ( isDefined( self ) )
		self delete();
	
}

function dragon_strike_wait_for_anim()
{
	self waittill( "scriptedanim" );
	level notify( "dragon_strike_anim_done" );
	self delete();
}

function dragon_strike_marker_origin_logic()
{
	self notify( "dragon_strike_marker_origin_logic" );
	self endon( "dragon_strike_marker_origin_logic" );
	self endon( "disconnect" );
	v_origin_scale = vectorScale( ( 0, 0, 1 ), 8 );
	if ( !isDefined( self.e_dragon_strike_marker ) )
		self.e_dragon_strike_marker = util::spawn_model( "tag_origin", self.origin );
	
	util::wait_network_frame();
	self.e_dragon_strike_marker clientfield::set( DRAGON_STRIKE_MARKER_ON_CF, 1 );
	w_dragon_strike = self zm_utility::get_player_placeable_mine();
	if ( w_dragon_strike == getWeapon( DRAGON_STRIKE_UPGRADED_WEAPON ) )
	{
		str_valid_clientfield = DRAGON_STRIKE_MARKER_UPGRADED_FX_CF;
		str_invalid_clientfield = DRAGON_STRIKE_MARKER_UPGRADED_INVALID_FX_CF;
	}
	str_valid_clientfield = DRAGON_STRIKE_MARKER_FX_CF;
	str_invalid_clientfield = DRAGON_STRIKE_MARKER_INVALID_FX_CF;
	while ( self flag::get( "show_dragon_strike_reticule" ) )
	{
		v_start = self getEye();
		v_forward = self getWeaponForwardDir();
		v_end = v_start + v_forward * 2500;
		a_trace = bulletTrace( v_start, v_end, 0, self.e_dragon_strike_marker, 1, 0, self.var_1e43571f );
		self.v_dragon_strike_marker_origin = a_trace[ "position" ];
		if ( isDefined( self.s_dragon_strike_marker ) )
			self.s_dragon_strike_marker struct::delete();
		
		self.s_dragon_strike_marker = self dragon_strike_return_struct( self.v_dragon_strike_marker_origin );
		if ( !isDefined( self.s_dragon_strike_marker ) )
		{
			self dragon_strike_marker_set( str_invalid_clientfield );
			wait .1;
			continue;
		}
		self.e_dragon_strike_marker clientfield::increment( str_valid_clientfield );
		self.e_dragon_strike_marker moveTo( self.v_dragon_strike_marker_origin + v_origin_scale, .05 );
		wait .1;
	}
	if ( self flag::get( "dragon_strike_active" ) )
		return;
	
	self.e_dragon_strike_marker clientfield::set( DRAGON_STRIKE_MARKER_ON_CF, 0 );
	wait .3;
	self.e_dragon_strike_marker delete();
}

function dragon_strike_return_struct( v_loc )
{
	n_count = 0;
	v_forward = v_loc - self.origin;
	v_angles = vectorToAngles( v_forward );
	v_angles = ( v_angles[ 0 ], v_angles[ 1 ], 0 );
	v_forward_angles = anglesToForward( v_angles );
	v_origin = ( v_loc[ 0 ] + v_forward_angles[ 0 ] * 1000, v_loc[ 1 ] + v_forward_angles[ 1 ] * 1000, v_loc[ 2 ] + 2000 );
	while ( n_count < 360 )
	{
		if ( bulletTracePassed( v_origin, v_loc + ( 0, 0, 96 ), 0, self.e_dragon_strike_marker ) )
		{
			s_struct = spawnStruct();
			s_struct.origin = ( v_loc[ 0 ] + v_forward_angles[ 0 ] * 20000, v_loc[ 1 ] + v_forward_angles[ 1 ] * 20000, v_loc[ 2 ] + 8000 );
			s_struct.angles = anglesToUp( vectorToAngles( v_loc - s_struct.origin ) );
			s_struct.v_loc = v_loc;
			s_struct.v_origin = v_origin;
			return s_struct;
		}
		else
		{
			n_count = n_count + 90;
			v_new_angles = ( v_angles[ 0 ], v_angles[ 1 ] + 90, 0 );
			v_angles = v_new_angles;
			v_forward_angles = anglesToForward( v_new_angles );
			v_origin = ( v_loc[ 0 ] + v_forward_angles[ 0 ] * 1000, v_loc[ 1 ] + v_forward_angles[ 1 ] * 1000, v_loc[ 2 ] + 2000 );
		}
	}
	return undefined;
}

function dragon_strike_marker_set( str_clientfield )
{
	self.e_dragon_strike_marker clientfield::increment( str_clientfield );
	self.e_dragon_strike_marker moveTo( self.v_dragon_strike_marker_origin, .05 );
	self.v_dragon_strike_marker_origin = undefined;
}

function switch_to_weapon_if_primary( w_weapon )
{
	if ( !isDefined( w_weapon ) || zm_utility::is_hero_weapon( w_weapon ) )
	{
		if ( isDefined( self.prev_weapon_before_equipment_change ) )
			w_weapon = self.prev_weapon_before_equipment_change;
		else if ( isDefined( self.weapon_stowed ) )
			w_weapon = self.weapon_stowed;
		else
		{
			a_primaries = self getWeaponsListPrimaries();
			if ( a_primaries.size > 0 )
				w_weapon = a_primaries[ 0 ];
			else
				return;
			
		}
	}
	self switchToWeapon( w_weapon );
}

function dragon_strike_specify_weapon_request()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "specify_weapon_request", w_weapon );
		if ( is_dragon_strike_weapon( w_weapon ) && ( self getAmmoCount( w_weapon ) == 0 || self.b_dragon_strike_active === 0 ) )
			self clientfield::increment_uimodel( DRAGON_STRIKE_INVALID_USE_CF );
		
	}
}

// ============================== FUNCTIONALITY ==============================