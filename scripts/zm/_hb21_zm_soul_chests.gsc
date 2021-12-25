/*#==========================================###
###                                                                   							###
###                                                                   							###
###              Harry Bo21s Black Ops 3 Soul Chests v2.0.0	          	###
###                                                                   							###
###                                                                   							###
###=========================================##*/
/*==============================================

								CREDITS

===============================================
Raptroes
Hubashuba
WillJones1989
alexbgt
NoobForLunch
Symbo
TheIronicTruth
JAMAKINBACONMAN
Sethnorris
Yen466
Lilrifa
Easyskanka
Erthrock
Will Luffey
ProRevenge
DTZxPorter
Zeroy
JBird632
StevieWonder87
BluntStuffy
RedSpace200
Frost Iceforge
thezombieproject
Smasher248
JiffyNoodles
MadGaz
MZSlayer
AndyWhelen
Collie
ProGamerzFTW
Scobalula
Azsry
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
TheSkyeLord
=============================================*/
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_soul_chests.gsh;

#precache( "model", SOULCHEST_MODEL );

#precache( "fx", SOULCHEST_TRAIL_FX );
#precache( "fx", SOULCHEST_FIRE_FX );
#precache( "fx", SOULCHEST_COLLECT_FX );
#precache( "fx", SOULCHEST_COMPLETE_FX );

#using_animtree( "generic" );

#namespace hb21_zm_soul_chests;

REGISTER_SYSTEM_EX( "hb21_zm_soul_chests", &__init__, &__main__, undefined )

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// entity.ptr_soul_chest_open_cb 							- FUNCTION_POINTER 	- set your own function here to handle the logic called when a soul chest opens
// entity.ptr_soul_chest_close_cb 							- FUNCTION_POINTER 	- set your own function here to handle the logic called when a soul chest closes
// entity.ptr_soul_chest_complete_location_cb 			- FUNCTION_POINTER 	- set your own function here to handle the logic called when a soul chest has absorbed enough zombie souls
// entity.ptr_soul_chest_complete_cb 						- FUNCTION_POINTER 	- set your own function here to handle the logic called on a soul chest when it is completed
// entity.ptr_soul_chest_all_complete_cb 					- FUNCTION_POINTER 	- set your own function here to handle the logic called on a soul chest when all are completed

// entity.n_soul_chest_souls_required 						- INTEGER						- set a custom kill requirement on this soul chest
// entity.b_soul_chest_no_timeout 							- BOOLEAN					- set a soul chest to have no time out
// entity.n_soul_chest_timeout_duration					- FLOAT							- set a soul chest time out duration
// entity.str_soul_chest_soul_fx								- STRING						- set a custom fx to show being dragged to the soul chest

// ai.str_soul_chest_soul_fx_spawn_tag 					- STRING 						- set the tag to spawn a zombie soul fx on that then moves to the soul chest

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ============================== INITIALIZE ==============================

/* 
INITIALIZE 
Description : This function calls our main functionality to start
Notes : If soul chests can be found in the map, the script will abort  
*/
function __init__()
{
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	level.a_soul_chests 																= [];
	level.n_soul_chest_kills_required 											= int( SOULCHEST_INITIAL_LIMIT );
	/* ========================================================== 									REGISTER DEFAULT SETTINGS								 	========================================================== */
	
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	clientfield::register( 																"scriptmover",																				SOULCHEST_GLOW_FX_CF,			VERSION_SHIP, 	1, 				"int"																						 );
	/* ========================================================== 									REGISTER CLIENTFIELDS								 			========================================================== */
	
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	zm_spawner::register_zombie_death_event_callback( 				&soul_chest_death_event_cb																																																															 );
	/* ========================================================== 									REGISTER CALLBACKS								 				========================================================== */
	
	array::run_all( 																		struct::get_array( "harrybo21_soul_chest", "script_noteworthy" ), 	&soul_chest_spawn_chest 																																							 );
}

/* 
MAIN 
Description : This function starts the script and will setup everything required - POST-load
Notes : None  
*/
function __main__()
{
}

// ============================== INITIALIZE ==============================

// ============================== CALLBACKS ==============================

/* 
SOUL CHEST DEATH EVENT CB
Description : This function handles logic for zombies killed by the a soul chest
Notes : None
*/
function soul_chest_death_event_cb( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	e_soul_chest = self soul_chest_zombie_touching_soul_chest();
	
	if ( !isDefined( e_soul_chest ) )
		return;
	
	e_soul_chest thread soul_chest_take_zombie_soul( self );
}

// ============================== CALLBACKS ==============================

// ============================== FUNCTIONALITY ==============================

/* 
SOUL CHEST SPAWN CHEST
Description : This function will spawn a soul chest at the struct that its called on
Notes : None  
*/
function soul_chest_spawn_chest()
{
	e_soul_chest_base_model = util::spawn_model( "tag_origin", self.origin );
	e_soul_chest_base_model.angles = self.angles;
	e_soul_chest_base_model enableLinkTo();
	
	e_soul_chest_model = util::spawn_model( SOULCHEST_MODEL, self.origin );
	e_soul_chest_model.script_noteworthy = "harrybo21_soul_chest";
	e_soul_chest_model.angles = self.angles;
	e_soul_chest_model useAnimTree( #animtree );
	e_soul_chest_model.animname = "soul_box";
	e_soul_chest_model linkTo( e_soul_chest_base_model );
	e_soul_chest_model.e_base_model = e_soul_chest_base_model;
	
	e_soul_chest_model.e_collision = spawn( "script_model", self.origin, 1 );
	e_soul_chest_model.e_collision.angles = self.angles;
	e_soul_chest_model.e_collision setModel( "zm_collision_perks1" );
	e_soul_chest_model.e_collision disconnectPaths();
	e_soul_chest_model.e_collision linkTo( e_soul_chest_base_model );
	
	if ( isDefined( self.target ) )
		e_soul_chest_model.target = self.target;
	
	e_soul_chest_model.n_soul_chest_kills = 0;
	e_soul_chest_model.n_soul_chest_timer = 0;
	e_soul_chest_model.b_soul_chest_active = 0;
		
	ARRAY_ADD( level.a_soul_chests, e_soul_chest_model );
}

/* 
SOUL CHEST DELETE CHEST
Description : This function will completely delete a soul chest. It will remove the clip that was spawned there, reconnect the pathing to it, delete the chest and then delete the trigger
Notes : None  
*/
function soul_chest_delete_chest()
{
	a_soul_chest_triggers = getEntArray( self.target, "targetname" );
	if ( isDefined( a_soul_chest_triggers ) && isArray( a_soul_chest_triggers ) && a_soul_chest_triggers.size > 0 )
		for ( i = 0; i < a_soul_chest_triggers.size; i++ )
			a_soul_chest_triggers[ i ] delete();
	
	self.e_collision connectPaths();
	self.e_collision delete();
	self.e_base_model delete();
	self delete();
}

/* 
SOUL CHEST OPEN 
Description : This function will activate a soul chest
Notes : None  
*/
function soul_chest_open()
{
	self.b_soul_chest_active = 1;
	self.n_soul_chest_kills = 0;
	self.n_soul_chest_timer = 0;
		
	if ( !IS_TRUE( self.b_soul_chest_no_timeout ) )
		self thread soul_chest_watch_for_timeout( ( isDefined( self.n_soul_chest_timeout_duration ) ? self.n_soul_chest_timeout_duration : SOULCHEST_TIMEOUT ) );
		
	if ( isDefined( self.ptr_soul_chest_open_cb ) )
		return self [ [ self.ptr_soul_chest_open_cb ] ]();
		
	self playLoopSound( "zmb_footprintbox_glow_lp", .1 );
	self clientfield::set( SOULCHEST_GLOW_FX_CF, 1 );
	
	self animation::play( SOULCHEST_OPEN, self.origin, self.angles, 1, 0, 0, 0, 0, 0, 1 );
	}

/* 
SOUL CHEST CLOSE
Description : This function will deactivate a soul chest
Notes : None  
*/
function soul_chest_close()
{
	if ( isDefined( self.ptr_soul_chest_close_cb ) )
		return self [ [ self.ptr_soul_chest_close_cb ] ]();
	
	self clientfield::set( SOULCHEST_GLOW_FX_CF, 0 );
	
	self stopLoopSound( .1 );
	
	self.b_soul_chest_closing = 1;
	self animation::play( SOULCHEST_CLOSE, self.origin, self.angles, 1, 0, 0, 0, 0, 0, 1 );
	self.b_soul_chest_closing = undefined;
}

/* 
SOUL CHEST WATCH FOR TIMEOUT
Description : There is the option to set a count down timer, if used, this function keeps check if a box should "timeout". This feature can be disables
Notes : None  
*/
function soul_chest_watch_for_timeout( n_soul_chest_timeout_duration )
{
	self endon( "death" );
	self endon( "delete" );
	self notify( "zm_soul_chest_timeout" );
	self endon( "disconnect" );
	self endon( "zm_soul_chest_timeout" );
	
	if ( !isDefined( self ) )
		return;
	
	self.n_soul_chest_timer = 0;
	while ( self.n_soul_chest_timer < n_soul_chest_timeout_duration )
	{
		self.n_soul_chest_timer += .05;
		wait .05;
	}
	self notify( "zm_soul_chest_timeout" );
}

/* 
SOUL CHEST COMPLETED LOCATION
Description : This function handles the logic for a chest being completed. You can safely ignore this, as there are two fuunctions further down you can use to edit rewards and other such things
Notes : None  
*/
function soul_chest_completed_location()
{
	if ( IS_TRUE( self.b_soul_chest_completed ) )
		return;
	
	self.b_soul_chest_completed = 1;
	
	if ( isDefined( self.ptr_soul_chest_complete_location_cb ) )
		return self [ [ self.ptr_soul_chest_complete_location_cb ] ]();
	
	soul_chest_increase_global_count();
	
	self soul_chest_close();
	
	v_origin = self.origin;
	
	wait 1;
	self.e_collision unLink();
	self.e_base_model moveZ( 30, 1, 1 );
	wait .5;
	v_start_angles = self.angles;
	
	for ( i = 0; i < randomIntRange( 5, 7 ); i++ )
	{
		self.e_base_model rotateTo( v_start_angles + ( randomFloatRange( -10, 10 ), randomFloatRange( -10, 10 ), randomFloatRange( -10, 10 ) ), randomFloatRange( .2, .4 ) );
		self.e_base_model waittill( "rotatedone" );
	}
	
	self.e_base_model rotateTo( v_start_angles, .3 );
	self.e_base_model moveZ( -60, .5, .5 );
	self.e_base_model waittill( "rotatedone" );
	
	playFX( SOULCHEST_COMPLETE_FX, v_origin );
	
	playSoundAtPosition( SOULCHEST_COMPLETED_SOUND, v_origin );
	
	self.e_base_model waittill( "movedone" );
	
	if ( isDefined( level.a_soul_chests ) && isArray( level.a_soul_chests ) && level.a_soul_chests.size > 0 && isInArray( level.a_soul_chests, self ) )
		arrayRemoveValue( level.a_soul_chests, self );
	
	self soul_chest_delete_chest();
	
	soul_chest_complete_logic( v_origin );
}

/* 
SOUL CHEST COMPLETE LOGIC
Description : This function will run if a single chest is completed, if the completed chest is the "last" one, then this function is ignored, and @soul_chest_all_complete_logic will run "instead"
Notes : "origin" - is the origin on the chest that was just completed  
*/
function soul_chest_complete_logic( v_origin )
{
	level notify( "soul_chest_complete", v_origin );
	
	if ( !isDefined( level.a_soul_chests ) || level.a_soul_chests.size < 1 )
		return soul_chest_all_complete_logic( v_origin );
		
	if ( isDefined( self.ptr_soul_chest_complete_cb ) )
		return self [ [ self.ptr_soul_chest_complete_cb ] ]( v_origin );
		
	// ============================================== //
	// This is where you will script the response to a induvidual chest being filled
	// origin = the origin of the chest that was just completed. This will be floor level
	// You can manually change the kills required here by changing the following :
	// level.current_count = amount;
	// I chose top spawn a powerup and reward the players some points as a example
	// ============================================== //
	
	zm_powerups::special_powerup_drop( v_origin );
	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
		a_players[ i ] zm_score::add_to_player_score( 500 );
	
}

/* 
SOUL CHEST ALL COMPLETE LOGIC
Description : This function will run when the last soul chest is complete
Notes : "origin" - is the origin on the chest that was just completed  
Notes : Be aware that the "induvidual" chest reward function above will "not" run if the below function is. So if there was something from your old reward that this "also" requires, you will also need to add it here
*/
function soul_chest_all_complete_logic( v_origin )
{
	level notify( "soul_chests_complete", v_origin );
	
	if ( isDefined( self.ptr_soul_chest_all_complete_cb ) )
		return self [ [ self.ptr_soul_chest_all_complete_cb ] ]( v_origin );
	
	// ============================================== //
	// This is where you will script the response to all the chests being filled
	// origin = the origin of the chest that was just completed. This will be floor level
	// I chose top spawn a powerup and reward the players some points as a example
	// ============================================== //
	
	zm_powerups::special_powerup_drop( v_origin );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] zm_score::add_to_player_score( 1000 );
	
	level thread soul_chest_spawn_completion_reward();
}

/* 
SOUL CHEST ZOMBIE TOUCHING SOUL CHEST
Description : This function will check if a zombie has died within range of a soul chest
Notes : None  
*/
function soul_chest_zombie_touching_soul_chest()
{
	if ( self soul_chest_is_touching_excluder() )
		return;
	
	a_soul_chests = util::get_array_of_closest( self.origin, getEntArray( "harrybo21_soul_chest", "script_noteworthy" ) );
	if ( !isDefined( a_soul_chests ) || !isArray( a_soul_chests ) || a_soul_chests.size < 1 )
		return;
	
	for ( i = 0; i < a_soul_chests.size; i++ )
	{
		a_soul_chest_areas = undefined;
		
		if ( !isDefined( a_soul_chests[ i ].target ) )
			continue;
		
		a_soul_chest_areas = getEntArray( a_soul_chests[ i ].target, "targetname" );
		if ( !isDefined( a_soul_chest_areas ) || !isArray( a_soul_chest_areas ) || a_soul_chest_areas.size < 1 )
			continue;
		
		for ( a = 0; a < a_soul_chest_areas.size; a++ )
			if ( self isTouching( a_soul_chest_areas[ a ] ) )
				return a_soul_chests[ i ];
		
	}
	return undefined;
}

/* 
SOUL CHEST IS TOUCHING EXCLUDER
Description : Checks if a zombie is touching a volume placed in radiant that will "on purpose" stop him from being able to effect soul chests.
Notes : None
*/
function soul_chest_is_touching_excluder()
{
	a_excluders = getEntArray( "harrybo21_chest_ignore_area", "targetname" );
	
	if ( !isDefined( a_excluders ) || a_excluders.size < 1 )
		return 0;
	
	for ( i = 0; i < a_excluders.size; i++ )
	{
		if ( self isTouching( a_excluders[ i ] ) )
			return 1;
			
	}
	
	return 0;
}

/* 
SOUL CHEST TAKE ZOMBIE SOUL
Description : This function handles when a zombie dies, and his soul is taken by the chest. If the chest was "closed", it will open, if it was already open then ( if you use it ) the timer countdown is reset
Notes : None  
*/
function soul_chest_take_zombie_soul( e_zombie )
{
	if ( !isDefined( self ) || IS_TRUE( self.b_soul_chest_completed ) || IS_TRUE( self.b_soul_chest_closing ) )
		return;
	
	if ( !isDefined( self.n_soul_chest_souls_required ) && self.n_soul_chest_kills >= level.n_soul_chest_kills_required )
		return;
	else if ( isDefined( self.n_soul_chest_souls_required ) && self.n_soul_chest_kills >= self.n_soul_chest_souls_required )
		return;
	
	if ( !IS_TRUE( self.b_soul_chest_active ) )
		self thread soul_chest_open();
	
	self soul_chest_soul_move_to_chest( e_zombie );
	
	if ( isDefined( self.n_soul_chest_souls_required ) && self.n_soul_chest_kills >= self.n_soul_chest_souls_required )
		self soul_chest_completed_location();
	else if ( !isDefined( self.n_soul_chest_souls_required ) && self.n_soul_chest_kills >= level.n_soul_chest_kills_required )
		self soul_chest_completed_location();
	
}

/* 
SOUL CHEST SOUL MOVE TO CHEST
Description : This function is just to control the soul getting from the zombie to the chest
Notes : None  
*/
function soul_chest_soul_move_to_chest( e_zombie )
{
	self.n_soul_chest_timer = 0;
	self.n_soul_chest_kills++;
	
	e_fx_model = util::spawn_model( "tag_origin", e_zombie getTagOrigin( ( isDefined( e_zombie.str_soul_chest_soul_fx_spawn_tag ) ? e_zombie.str_soul_chest_soul_fx_spawn_tag : SOULCHEST_AI_DEFAULT_SOUL_SPAWN_TAG ) ) );
	playFxOnTag( ( isDefined( self.str_soul_chest_soul_fx ) ? self.str_soul_chest_soul_fx : SOULCHEST_TRAIL_FX ), e_fx_model, "tag_origin" );
	e_fx_model playSound( SOULCHEST_SOUL_SPAWN_SOUND );
	
	e_fx_model moveTo( self.origin, 1 );
	e_fx_model waittill ( "movedone" );
	
	playFx( SOULCHEST_COLLECT_FX, e_fx_model.origin );
	playSoundAtPosition( SOULCHEST_SOUL_COLLETED_SOUND, e_fx_model.origin );
	e_fx_model delete();
	
	self notify( "soul_collected" );
}

/* 
SOUL CHEST INCREASE GLOBAL COUNT
Description : This function increases the next chests requirement of kills upon completing another. If you want to have a set number for "every" box, then set SOULCHEST_START_ADD_AMOUNT to "0" in the gsh
Notes : None  
*/
function soul_chest_increase_global_count()
{
	level.n_soul_chest_kills_required = int( level.n_soul_chest_kills_required * SOULCHEST_LIMIT_MULTIPLIER );
}

/* 
SOUL CHEST SPAWN COMPLETION REWARD
Description : This function spawns a weapon at a location on the map when all soul chests in the predefined array are completed
Notes : None  
*/
function soul_chest_spawn_completion_reward()
{
	s_struct = struct::get( "soul_chest_final_reward", "targetname" );
	
	if ( !isDefined( s_struct ) )
		return;
	
	e_model = util::spawn_model( getWeaponWorldModel( getWeapon( SOULCHEST_COMPLETE_REWARD_WEAPON ) ), s_struct.origin + ( 0, 0, 64 ) );
	e_model thread zm_powerups::powerup_wobble();
	
	e_trigger = spawn( "trigger_radius_use", s_struct.origin, 0, 80, 80 );
		
	e_trigger triggerIgnoreTeam();
	e_trigger setCursorHint( "HINT_NOICON" );
	e_trigger setHintString( "Press & hold ^3&&1^7 for " + getWeapon( SOULCHEST_COMPLETE_REWARD_WEAPON ).displayname );
	
	while ( isDefined( e_trigger ) )
	{
		e_trigger waittill( "trigger", e_player );
		if ( e_player hasWeapon( getWeapon( SOULCHEST_COMPLETE_REWARD_WEAPON ) ) )
			continue;
		
		e_player zm_weapons::weapon_give( getWeapon( SOULCHEST_COMPLETE_REWARD_WEAPON ), 0, 0, 1, 0 );
	}
}

// ============================== FUNCTIONALITY ==============================

// ============================== DEVELOPER ==============================

// ============================== DEVELOPER ==============================