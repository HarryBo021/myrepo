#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_callbacks;
#using scripts\zm\_zm_elemental_zombies;
#using scripts\zm\_zm_light_zombie;
#using scripts\zm\_zm_shadow_zombie;
#insert scripts\zm\_zm_ai_margwa_elemental.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", MARGWA_ELEMENTAL_FIRE_ROAR_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_FIRE_SPAWN_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_FIRE_ATTACK_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_FIRE_HEAD_HIT_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_ROAR_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_SPAWN_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_OPEN_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_LOOP_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_CLOSE_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_DEFENSE_DISAPPEAR_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_DEFENSE_BALL_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_SHADOW_HEAD_HIT_FX_FILE );
#precache( "client_fx", MARGWA_ELEMENTAL_LIGHT_ROAR_FX_FILE );
#precache( "client_fx", "MARGWA_ELEMENTAL_LIGHT_SPAWN_FX_FILE" );
#precache( "client_fx", MARGWA_ELEMENTAL_ELECTRIC_ROAR_FX_FILE );

#namespace zm_ai_margwa_elemental;

#using_animtree( "generic" );

function autoexec init()
{
	callback::add_weapon_type( MARGWA_ELEMENTAL_SHADOW_ATTACK_WEAPON, &shadow_margwa_skull_animate );
	clientfield::register( "actor", MARGWA_ELEMENTAL_TYPE_CF, VERSION_SHIP, 3, "int", &margwa_elemental_type_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", MARGWA_ELEMENTAL_DEFENSE_ACTOR_APPEAR_DISAPPEAR_FX_CF, VERSION_SHIP, 1, "int", &margwa_defense_actor_appear_disappear_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register(  "scriptmover", MARGWA_ELEMENTAL_PLAY_MARGWA_FIRE_ATTACK_CF, VERSION_SHIP, 1, "counter", &play_margwa_fire_attack_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", MARGWA_ELEMENTAL_MARGWA_DEFENSE_HOVERING_FX_CF, VERSION_SHIP, 3, "int", &margwa_defense_hovering_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF, VERSION_SHIP, 1, "int", &shadow_margwa_attack_portal_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", MARGWA_ELEMENTAL_MARGWA_SHOCK_FX_CF, VERSION_SHIP, 1, "int", &margwa_shock_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level._effect[ MARGWA_ELEMENTAL_FIRE_ROAR_FX ] = MARGWA_ELEMENTAL_FIRE_ROAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_SPAWN_FX ] = MARGWA_ELEMENTAL_FIRE_SPAWN_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_ATTACK_FX ] = MARGWA_ELEMENTAL_FIRE_ATTACK_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_DISAPPEAR_FX ] = MARGWA_ELEMENTAL_FIRE_DEFENSE_DISAPPEAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ] = MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX ] = MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_FIRE_HEAD_HIT_FX ] = MARGWA_ELEMENTAL_FIRE_HEAD_HIT_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_ROAR_FX ] = MARGWA_ELEMENTAL_SHADOW_ROAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_SPAWN_FX ] = MARGWA_ELEMENTAL_SHADOW_SPAWN_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_OPEN_FX ] = MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_OPEN_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_LOOP_FX ] = MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_LOOP_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_CLOSE_FX ] = MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_CLOSE_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_DISAPPEAR_FX ] = MARGWA_ELEMENTAL_SHADOW_DEFENSE_DISAPPEAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_APPEAR_FX ] = MARGWA_ELEMENTAL_SHADOW_DEFENSE_APPEAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_BALL_FX ] = MARGWA_ELEMENTAL_SHADOW_DEFENSE_BALL_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_SHADOW_HEAD_HIT_FX ] = MARGWA_ELEMENTAL_SHADOW_HEAD_HIT_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_LIGHT_ROAR_FX ] = MARGWA_ELEMENTAL_LIGHT_ROAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_LIGHT_SPAWN_FX ] = MARGWA_ELEMENTAL_LIGHT_SPAWN_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_ELECTRIC_ROAR_FX ] = MARGWA_ELEMENTAL_ELECTRIC_ROAR_FX_FILE;
	level._effect[ MARGWA_ELEMENTAL_ELECTRIC_SPAWN_FX ] = MARGWA_ELEMENTAL_ELECTRIC_SPAWN_FX_FILE;
}

function private margwa_elemental_type_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self util::waittill_dobj( n_local_client_num );
	switch ( n_new_value )
	{
		case 1:
		{
			self margwa_fire_setup( n_local_client_num );
			break;
		}
		case 2:
		{
			self margwa_electric_setup( n_local_client_num );
			break;
		}
		case 3:
		{
			self margwa_light_setup( n_local_client_num );
			break;
		}
		case 4:
		{
			self margwa_shadow_setup( n_local_client_num );
			break;
		}
	}
}

function margwa_shock_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self clear_margwa_shock_fx( n_local_client_num );
	if ( n_new_value )
	{
		if ( !isDefined( self.fx_margwa_shock ) )
		{
			str_tag = "j_spineupper";
			if ( !self isAi() )
				str_tag = "tag_origin";
			
			self.fx_margwa_shock = playFxOnTag( n_local_client_num, level._effect[ "tesla_zombie_shock" ], self, str_tag );
			self playSound( 0, "zmb_electrocute_zombie" );
		}
		if ( isDemoPlaying() )
			self thread clear_margwa_shock_fx_demo( n_local_client_num );
		
	}
}

function clear_margwa_shock_fx_demo( n_local_client_num )
{
	self notify( "clear_margwa_shock_fx" );
	self endon( "clear_margwa_shock_fx" );
	level waittill( "demo_jump" );
	self clear_margwa_shock_fx( n_local_client_num );
}

function clear_margwa_shock_fx( n_local_client_num )
{
	if ( isDefined( self.fx_margwa_shock ) )
	{
		deleteFx( n_local_client_num, self.fx_margwa_shock, 1 );
		self.fx_margwa_shock = undefined;
	}
	self notify( "clear_margwa_shock_fx" );
}

function private margwa_fire_setup( n_local_client_num )
{
	self.margwa_roar_effect = level._effect[ MARGWA_ELEMENTAL_FIRE_ROAR_FX ];
	self.margwa_spawn_effect = level._effect[ MARGWA_ELEMENTAL_FIRE_SPAWN_FX ];
	self.margwa_head_hit_fx = level._effect[ MARGWA_ELEMENTAL_FIRE_HEAD_HIT_FX ];
	self.margwa_play_spawn_effect = &margwa_spawn_fx;
}

function private margwa_electric_setup( n_local_client_num )
{
	self.margwa_roar_effect = level._effect[ MARGWA_ELEMENTAL_ELECTRIC_ROAR_FX ];
	self.margwa_spawn_effect = level._effect[ MARGWA_ELEMENTAL_ELECTRIC_SPAWN_FX ];
}

function private margwa_shadow_setup( n_local_client_num )
{
	self.margwa_roar_effect = level._effect[ MARGWA_ELEMENTAL_SHADOW_ROAR_FX ];
	self.margwa_spawn_effect = level._effect[ MARGWA_ELEMENTAL_SHADOW_SPAWN_FX ];
	self.margwa_head_hit_fx = level._effect[ MARGWA_ELEMENTAL_SHADOW_HEAD_HIT_FX ];
	self.margwa_play_spawn_effect = &margwa_spawn_fx;
}

function private margwa_light_setup( n_local_client_num )
{
	self.margwa_roar_effect = level._effect[ MARGWA_ELEMENTAL_LIGHT_ROAR_FX ];
	self.margwa_spawn_effect = level._effect[ MARGWA_ELEMENTAL_LIGHT_SPAWN_FX ];
}

function private margwa_spawn_fx( n_local_client_num )
{
	playFxOnTag( n_local_client_num, self.margwa_spawn_effect, self, "tag_origin" );
}

function private play_margwa_fire_attack_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	playFxOnTag( n_local_client_num, MARGWA_ELEMENTAL_FIRE_ATTACK_FX_FILE, self, "tag_origin" );
}

function private margwa_defense_actor_appear_disappear_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value == 1 )
		playFX( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_DISAPPEAR_FX ], self getTagOrigin( "j_spine_1" ) );
	
}

function private margwa_defense_hovering_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value == 1 )
	{
		playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ], self, "tag_origin" );
		self.fx_margwa_defense_fx = playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX ], self, "tag_origin" );
		self.fx_margwa_defense_end_fx = level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ];
	}
	if ( n_new_value == 2 )
	{
		playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ], self, "tag_origin" );
		self.fx_margwa_defense_fx = playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX ], self, "tag_origin" );
		self.fx_margwa_defense_end_fx = level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ];
	}
	if ( n_new_value == 3 )
	{
		playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX ], self, "tag_origin" );
		self.fx_margwa_defense_fx = playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_FIRE_DEFENSE_FIREBALL_FX ], self, "tag_origin" );
		self.fx_margwa_defense_end_fx = level._effect[MARGWA_ELEMENTAL_FIRE_DEFENSE_APPEAR_FX];
	}
	if ( n_new_value == 4 )
	{
		playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_APPEAR_FX ], self, "tag_origin" );
		self.fx_margwa_defense_fx = playFxOnTag( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_BALL_FX ], self, "tag_origin" );
		self.fx_margwa_defense_end_fx = level._effect[ MARGWA_ELEMENTAL_SHADOW_DEFENSE_APPEAR_FX ];
	}
	if ( n_new_value == 0 && isDefined( self.fx_margwa_defense_fx ) )
	{
		stopFx( n_local_client_num, self.fx_margwa_defense_fx );
		if ( isDefined( self.fx_margwa_defense_end_fx ) )
			playFxOnTag( n_local_client_num, self.fx_margwa_defense_end_fx, self, "tag_origin" );
		
	}
}

function private shadow_margwa_attack_portal_fx_cb( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_value == 1 )
	{
		v_vector = anglesToForward( self.angles );
		v_portal_pos = self.origin + v_vector * 96 + vectorScale( ( 0, 0, 1 ), 72 );
		self.fx_margwa_portal = playFX( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_OPEN_FX ], v_portal_pos, v_vector );
		playSound( 0, MARGWA_ELEMENTAL_SHADOW_PORTAL_OPEN_SOUND, v_portal_pos );
		audio::playLoopAt( MARGWA_ELEMENTAL_SHADOW_PORTAL_LOOP_SOUND, v_portal_pos );
		wait .45;
		if ( isAlive( self ) && self clientfield::get( MARGWA_ELEMENTAL_SHADOW_MARGWA_ATTACK_PORTAL_FX_CF ) == 1 )
			self.fx_margwa_portal = playFx( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_LOOP_FX ], v_portal_pos, v_vector );
		
	}
	if ( n_new_value == 0 && isDefined( self.fx_margwa_portal ) )
	{
		v_vector = anglesToForward( self.angles );
		v_portal_pos = self.origin + v_vector * 96 + vectorScale( ( 0, 0, 1 ), 72 );
		if ( isDefined( self.fx_margwa_portal ) )
			stopFx( n_local_client_num, self.fx_margwa_portal );
		
		playSound( 0, MARGWA_ELEMENTAL_SHADOW_PORTAL_CLOSE_SOUND, v_portal_pos );
		audio::stopLoopAt( MARGWA_ELEMENTAL_SHADOW_PORTAL_LOOP_SOUND, v_portal_pos );
		playFx( n_local_client_num, level._effect[ MARGWA_ELEMENTAL_SHADOW_ATTACK_PORTAL_CLOSE_FX ], v_portal_pos, v_vector );
	}
}

function shadow_margwa_skull_animate( n_local_client_num )
{
	self util::waittill_dobj( n_local_client_num );
	e_skull = self;
	if ( isDefined( e_skull) )
	{
		e_skull useAnimTree( #animtree );
		e_skull setAnim( MARGWA_ELEMENTAL_SHADOW_ATTACK_CHOMP_ANIM );
	}
}

