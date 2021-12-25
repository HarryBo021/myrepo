#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_weap_microwavegun.gsh;

#namespace zm_weap_microwavegun;

#precache( "client_fx", MICROWAVEGUN_SIZZLE_BLOOD_EYES_FX );
#precache( "client_fx", MICROWAVEGUN_SIZZLE_DEATH_MIST_FX );
#precache( "client_fx", MICROWAVEGUN_SIZZLE_DEATH_MIST_LOW_G_FX );

REGISTER_SYSTEM_EX( "zm_weap_microwavegun", &__init__, undefined, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
	// # CLIENTFIELD REGISTRATION
	clientfield::register( "actor", MICROWAVEGUN_HIT_RESPONSE_CF, VERSION_SHIP, 1, "int", &microwavegun_zombie_initial_hit_response, 0, 0 );
	clientfield::register( "actor", MICROWAVEGUN_EXPAND_RESPONSE_CF, VERSION_SHIP, 1, "int", &microwavegun_zombie_expand_response, 0, 0 );
	clientfield::register( "clientuimodel", MICROWAVEGUN_DPAD_ICON_CF, VERSION_SHIP, 1, "int", undefined, 0, 0 );
	// # CLIENTFIELD REGISTRATION
	
	// # REGISTER FX
	level._effect[ "microwavegun_sizzle_blood_eyes" ] = MICROWAVEGUN_SIZZLE_BLOOD_EYES_FX;
	level._effect[ "microwavegun_sizzle_death_mist" ] = MICROWAVEGUN_SIZZLE_DEATH_MIST_FX;
	level._effect[ "microwavegun_sizzle_death_mist_low_g" ] = MICROWAVEGUN_SIZZLE_DEATH_MIST_LOW_G_FX;
	// # REGISTER FX
}

// ============================== INITIALIZE ==============================

// ============================== FUNCTIONALITY ==============================

function microwavegun_zombie_initial_hit_response( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( isDefined( self.microwavegun_zombie_hit_response ) )
	{
		self [ [ self.microwavegun_zombie_hit_response ] ]( n_local_client_num, n_new_value, b_new_ent );
		return;
	}
	if ( n_local_client_num != 0 )
		return;
	
	if ( !isDefined( self._microwavegun_hit_response_fx ) )
		self._microwavegun_hit_response_fx = [];
	
	self.microwavegun_initial_hit_response = 1;
	a_players = getLocalPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( !isDefined( self._microwavegun_hit_response_fx[ i ] ) )
			self._microwavegun_hit_response_fx[ i ] = [];
		
		if ( n_new_value )
		{
			self microwavegun_create_hit_response_fx( i, "j_eyeball_le", level._effect[ "microwavegun_sizzle_blood_eyes" ] );
			playSound( 0, MICROWAVEGUN_IMPACT_SND, self.origin );
		}
	}
}

function microwavegun_zombie_expand_response( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( isDefined( self.microwavegun_zombie_hit_response ) )
	{
		self [ [ self.microwavegun_zombie_hit_response ] ]( n_local_client_num, n_new_value, b_new_ent );
		return;
	}
	if ( n_local_client_num != 0 )
		return;
	
	if ( !isDefined( self._microwavegun_hit_response_fx ) )
		self._microwavegun_hit_response_fx = [];
	
	b_initial_hit_occurred = IS_TRUE( self.microwavegun_initial_hit_response );
	a_players = getLocalPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( !isDefined( self._microwavegun_hit_response_fx[ i ] ) )
			self._microwavegun_hit_response_fx[ i ] = [];
		
		if ( n_new_value && b_initial_hit_occurred )
		{
			playSound( 0, MICROWAVEGUN_IMPACT_SND, self.origin );
			self thread microwavegun_bloat( i );
			continue;
		}
		self thread microwavegun_bloat( i );
		if ( b_initial_hit_occurred )
			self microwavegun_delete_hit_response_fx( i, "j_eyeball_le" );
		
		v_tag_pos = self getTagOrigin( "j_spinelower" );
		v_tag_angles = self getTagAngles( "j_spinelower" );
		if ( !isDefined( v_tag_pos ) )
		{
			v_tag_pos = self getTagOrigin( "j_spine1" );
			v_tag_angles = self getTagAngles( "j_spine1" );
		}
		str_fx = level._effect[ "microwavegun_sizzle_death_mist" ];
		if ( IS_TRUE( self.in_low_g ) )
			str_fx = level._effect[ "microwavegun_sizzle_death_mist_low_g" ];
		
		if ( isDefined( v_tag_pos ) )
			playFX( i, str_fx, v_tag_pos, anglesToForward( v_tag_angles ), anglesToUp( v_tag_angles ) );
		
		playSound( 0, MICROWAVEGUN_EXPLODE_SND, self.origin );
	}
}

function microwavegun_create_hit_response_fx( n_local_client_num, str_tag, str_effect )
{
	if ( !isDefined( self._microwavegun_hit_response_fx[ n_local_client_num ][ str_tag ] ) )
		self._microwavegun_hit_response_fx[ n_local_client_num ][ str_tag ] = playFXOnTag( n_local_client_num, str_effect, self, str_tag );
	
}

function microwavegun_delete_hit_response_fx( n_local_client_num, str_tag )
{
	if ( isDefined( self._microwavegun_hit_response_fx[ n_local_client_num ][ str_tag ] ) )
	{
		deleteFx( n_local_client_num, self._microwavegun_hit_response_fx[ n_local_client_num ][ str_tag ], 0 );
		self._microwavegun_hit_response_fx[ n_local_client_num ][ str_tag ] = undefined;
	}
}

function microwavegun_bloat( n_local_client_num )
{
	self endon( "entityshutdown" );
	n_duration_msec = 2500;
	v_tag_pos = self getTagOrigin( "j_spinelower" );
	n_bloat_max_fraction = 1;
	if ( !isDefined( v_tag_pos ) )
		n_duration_msec = 1000;
	
	self mapShaderConstant( n_local_client_num, 0, "scriptVector6", 0, 0, 0, 0 );
	n_begin_time = getRealTime();
	while ( 1 )
	{
		n_age = getRealTime() - n_begin_time;
		n_bloat_fraction = n_age / n_duration_msec;
		if ( n_bloat_fraction > n_bloat_max_fraction )
			n_bloat_fraction = n_bloat_max_fraction;
		
		if ( !isDefined( self ) )
			return;
		
		self mapShaderConstant( n_local_client_num, 0, "scriptVector6", 4 * n_bloat_fraction, 0, 0, 0 );
		if ( n_bloat_fraction >= n_bloat_max_fraction )
			break;
		
		waitRealTime .05;
	}
}

// ============================== FUNCTIONALITY ==============================