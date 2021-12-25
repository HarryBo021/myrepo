#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_acid.gsh;

#namespace hb21_sym_zm_trap_acid;

#precache( "client_fx", ACID_TRAP_FX );

REGISTER_SYSTEM( "hb21_sym_zm_trap_acid", &__init__, undefined )
	
function __init__()
{	
	DEFAULT( level._effect, [] );
	level._effect[ ACID_TRAP_FX ] = ACID_TRAP_FX;
	
	clientfield::register( "actor", 	ACID_TRAP_DISSOLVE_CLIENTFIELD, VERSION_SHIP, 1, "int", &acid_trap_dissolve_effect, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", 	ACID_TRAP_DISSOLVE_CLIENTFIELD, VERSION_SHIP, 1, "int", &acid_trap_dissolve_effect, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	duplicate_render::set_dr_filter_framebuffer( ACID_TRAP_DISSOLVE_DR_NAME, ACID_TRAP_DISSOLVE_DR_PRIORITY, ACID_TRAP_DISSOLVE_FLAG, "dissolve_on", DR_TYPE_FRAMEBUFFER, ACID_TRAP_DISSOLVE_MATERIAL, DR_CULL_ALWAYS );	
	
	a_traps = struct::get_array( "trap_acid", "targetname" );
	foreach ( e_trap in a_traps )
		clientfield::register( "world", e_trap.script_noteworthy, VERSION_SHIP, 1, "int", &acid_trap_change_fx_state, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );			
	
}

function acid_trap_dissolve_effect( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entity_shutdown" );
	
	self duplicate_render::set_dr_flag( ACID_TRAP_DISSOLVE_FLAG, n_new_val );
	self duplicate_render::update_dr_filters( n_local_client_num );

	self.n_acid_trap_dissolve = 1;
	while ( isDefined( self ) && self.n_acid_trap_dissolve > 0 )
	{
		self mapShaderConstant( n_local_client_num, 0, "scriptVector0", self.n_acid_trap_dissolve ); 

		self.n_acid_trap_dissolve -= ACID_TRAP_DISSOLVE_STEP;
		wait ACID_TRAP_DISSOLVE_STEP;
	}
	
	if ( isDefined( self ) )
		self mapShaderConstant( n_local_client_num, 0, "scriptVector0", .0 ); 
	
}

function acid_trap_change_fx_state( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	a_fx_points = struct::get_array( str_field_name, "targetname" );
	foreach ( s_fx_point in a_fx_points )
		if ( !isDefined( s_fx_point.script_noteworthy ) )
			if ( n_new_val )
				s_fx_point thread acid_trap_begin_fx();
			else
				s_fx_point thread acid_trap_stop_fx();
			
}

function acid_trap_begin_fx()
{		
	if ( isDefined( self.a_acid_trap ) && self.a_acid_trap.size )
		acid_trap_stop_fx();

	if ( !isDefined( self.a_acid_trap ) )
		self.a_acid_trap = [];
	
	a_players = getLocalPlayers();
	for ( i = 0; i < a_players.size; i++ )
		self.a_acid_trap[ i ] = playFx( i, level._effect[ ACID_TRAP_FX ], self.origin );
	
}

function acid_trap_stop_fx()
{
	a_players = getLocalPlayers();
	
	for ( i = 0; i < a_players.size; i++ )
		if ( isDefined( self.a_acid_trap[ i ] ) )
			stopFx( i, self.a_acid_trap[ i ] );
	
	self.a_acid_trap = [];	
}
