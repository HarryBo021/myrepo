#using scripts\codescripts\struct;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_elemental_bow;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace _zm_weap_elemental_bow_rune_prison;

REGISTER_SYSTEM_EX( "_zm_weap_elemental_bow_rune_prison", &__init__, &__main__, undefined )


function __init__()
{
	level.w_bow_rune_prison = getWeapon( "elemental_bow_rune_prison" );
	level.w_bow_rune_prison_charged = getWeapon( "elemental_bow_rune_prison4" );
	clientfield::register( "toplayer", "elemental_bow_rune_prison" + "_ambient_bow_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_rune_prison" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "missile", "elemental_bow_rune_prison4" + "_arrow_impact_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "runeprison_rock_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "runeprison_explode_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "runeprison_lava_geyser_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "runeprison_lava_geyser_dot_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "runeprison_zombie_charring", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "runeprison_zombie_death_skull", VERSION_SHIP, 1, "int" );
	callback::on_connect( &on_connect_bow_rune_prison );
}

function __main__()
{
}

function on_connect_bow_rune_prison()
{
	self thread zm_weap_elemental_bow::bow_base_wield_watcher( "elemental_bow_rune_prison" );
	self thread zm_weap_elemental_bow::bow_base_fired_watcher( "elemental_bow_rune_prison", "elemental_bow_rune_prison4" );
	self thread zm_weap_elemental_bow::bow_base_impact_watcher( "elemental_bow_rune_prison", "elemental_bow_rune_prison4", &bow_rune_prison_impact_explosion );
}

function bow_rune_prison_impact_explosion( weapon, position, radius, attacker, normal )
{
	if ( isSubStr( weapon.name, "elemental_bow_rune_prison4" ) )
		level thread bow_rune_prison_charged_fire( self, position, weapon.name, attacker, 1 );
	else
		level thread bow_rune_prison_fire( self, position, weapon.name, attacker );
	
}

function bow_rune_prison_charged_fire( e_player, v_hit_origin, str_weapon_name, e_impact_ent, b_first )
{
	if ( b_first )
	{
		e_player.ptr_bow_rune_prison_fake_fire_impact = &bow_rune_prison_fake_fire_impact;
		v_spawn_pos = e_player zm_weap_elemental_bow::bow_get_impact_pos_on_navmesh( v_hit_origin, str_weapon_name, e_impact_ent, 48, e_player.ptr_bow_rune_prison_fake_fire_impact );
		if ( b_first )
		{
			v_inferno_pos = ( isDefined( v_spawn_pos ) ? v_spawn_pos : v_hit_origin );
			a_inferno_targets = array::get_all_closest( v_inferno_pos, getAiTeamArray( level.zombie_team ), undefined, undefined, 256 );
			a_inferno_targets = array::filter( a_inferno_targets, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
			a_inferno_targets = array::filter( a_inferno_targets, 0, &bow_rune_prison_volcano_validation_first, v_inferno_pos );
			
			if ( getDvarInt( "splitscreen_playerCount" ) > 2 )
				a_inferno_targets = array::clamp_size( a_inferno_targets, 6 );
			else
				a_inferno_targets = array::clamp_size( a_inferno_targets, 12 );
			
			foreach ( ai_enemy in a_inferno_targets )
				ai_enemy thread bow_rune_prison_charged_fire( e_player, v_hit_origin, str_weapon_name, e_impact_ent, 0 );
			
			if ( a_inferno_targets.size )
				return;
			
		}
	}
	else
		v_spawn_pos = bow_rune_prison_get_zombie_pos( self );
	
	if ( !isDefined( v_spawn_pos ) )
		return;
	
	if ( isDefined( v_spawn_pos ) )
	{
		e_volcano = util::spawn_model( "tag_origin", v_spawn_pos, ( 0, randomIntRange( 0, 360 ), 0 ) );
		if ( isAi( self ) && isAlive( self ) )
		{
			self.b_is_bow_rune_prison_hit = 1;
			self.b_is_bow_hit = 1;
			self linkTo( e_volcano );
			self setPlayerCollision( 0 );
			self thread bow_rune_prison_volcano_kill_zombie_scene();
		}
	}
	e_volcano clientfield::set( "runeprison_rock_fx", 1 );
	self thread bow_rune_prison_volcano_knockdown( v_spawn_pos );
	if ( isDefined( self ) && isAlive( self ) )
	{
		if ( isDefined( self.isdog ) && self.isdog || ( isDefined( self.missinglegs ) && self.missinglegs ) )
			self doDamage( self.health, e_volcano.origin, e_player, e_player, undefined, "MOD_BURNED", 0, level.w_bow_rune_prison_charged );
		
	}
	wait 1.8 + ( .07 * b_first );
	e_volcano clientfield::set( "runeprison_explode_fx", 1 );
	if ( isDefined( self ) && isAlive( self ) && self.archetype === "zombie" )
	{
		self notify( "hash_9d9f16be" );
		self clientfield::set( "runeprison_zombie_charring", 1 );
	}
	wait( 2 );
	if ( isDefined( self ) && isAi( self ) && isAlive( self ) )
	{
		if ( self.archetype === "mechz" )
		{
			n_mechz_max_health = level.mechz_health;
			n_damage = ( n_mechz_max_health * .2 ) / .2;
			self.b_is_bow_rune_prison_hit = 0;
			self.b_is_bow_hit = 0;
			self scene::stop( "ai_zm_dlc1_soldat_runeprison_struggle_loop" );
			self doDamage( n_damage, e_volcano.origin, e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.w_bow_rune_prison_charged );
			self thread bow_rune_prison_mechz_scene();
		}
		else if ( self.archetype === "zombie" )
		{
			if ( math::cointoss() )
			{
				gibserverutils::gibhead( self );
				self clientfield::set( "runeprison_zombie_death_skull", 1 );
			}
			self doDamage( self.health, e_volcano.origin, e_player, e_player, undefined, "MOD_BURNED", 0, level.w_bow_rune_prison_charged );
		}
		self setPlayerCollision( 1 );
		self unlink();
	}
	a_inferno_targets = array::get_all_closest( e_volcano.origin, getAiTeamArray( level.zombie_team ), undefined, undefined, 96 );
	a_inferno_targets = array::filter( a_inferno_targets, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
	a_inferno_targets = array::filter( a_inferno_targets, 0, &bow_rune_prison_volcano_validate_target );
	foreach ( ai_target in a_inferno_targets )
		ai_target doDamage( ai_target.health, e_volcano.origin, e_player, e_player, undefined, "MOD_BURNED", 0, level.w_bow_rune_prison_charged );
	
	e_volcano clientfield::set( "runeprison_rock_fx", 0 );
	wait 6;
	e_volcano delete();
}

function bow_rune_prison_volcano_knockdown( v_pos )
{
	wait .1;
	a_inferno_targets = array::get_all_closest( v_pos, getAiTeamArray( level.zombie_team ), undefined, undefined, 96 );
	a_inferno_targets = array::filter( a_inferno_targets, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
	a_inferno_targets = array::filter( a_inferno_targets, 0, &bow_rune_prison_validate_zombie );
	a_inferno_targets = array::clamp_size( a_inferno_targets, 2 );
	foreach ( ai_target in a_inferno_targets )
		ai_target thread zm_weap_elemental_bow::bow_base_do_knockdown( v_pos );
	
}

function bow_rune_prison_mechz_scene()
{
	self endon( "death" );
	self.b_mechz_hit_by_rune_prison = 1;
	wait 16;
	self.b_mechz_hit_by_rune_prison = 0;
}

function bow_rune_prison_volcano_validation_first( ai_enemy, v_inferno_pos )
{
	return !IS_TRUE( ai_enemy.b_is_bow_rune_prison_hit ) && ( bulletTracePassed( ai_enemy getCentroid(), v_inferno_pos, 0, undefined ) || bulletTracePassed( ai_enemy getCentroid(), v_inferno_pos + vectorScale( ( 0, 0, 1 ), 48 ), 0, undefined ) );
}

function bow_rune_prison_validate_zombie( ai_enemy )
{
	return !IS_TRUE( ai_enemy.b_is_bow_rune_prison_hit ) && !IS_TRUE( ai_enemy.knockdown ) && !IS_TRUE( ai_enemy.missinglegs );
}

function bow_rune_prison_volcano_validate_target( ai_enemy )
{
	return !IS_TRUE( ai_enemy.b_is_bow_rune_prison_hit );
}

function bow_rune_prison_volcano_kill_zombie_scene()
{
	self endon( "death" );
	wait .1;
	if ( self.archetype === "zombie" )
	{
		n_variant = randomIntRange( 1, 5 );
		self thread scene::play( "ai_zm_dlc1_zombie_runeprison_locked_struggle_0" + n_variant, self );
		self waittill( "hash_9d9f16be" );
		wait .5;
		self scene::play( "ai_zm_dlc1_zombie_runeprison_death_loop_0" + randomIntRange( 1, 5 ), self );
	}
	else if ( self.archetype === "mechz" )
		self scene::play( "ai_zm_dlc1_soldat_runeprison_struggle_loop", self );
	
}

function bow_rune_prison_fire( e_player, v_hit_origin, str_weapon_name, e_impact_ent )
{
	v_spawn_pos = e_player zm_weap_elemental_bow::bow_get_impact_pos_on_navmesh( v_hit_origin, str_weapon_name, e_impact_ent, 32 );
	if ( !isDefined( v_spawn_pos ) )
		return;
	
	e_rune_prison_geyser = util::spawn_model( "tag_origin", v_spawn_pos );
	e_rune_prison_geyser clientfield::set( "runeprison_lava_geyser_fx", 1 );
	n_timer = 0;
	
	while ( n_timer < 3 )
	{
		a_inferno_targets = array::get_all_closest( e_rune_prison_geyser.origin, getAiTeamArray( level.zombie_team ), undefined, undefined, 48 );
		a_inferno_targets = array::filter( a_inferno_targets, 0, &zm_weap_elemental_bow::is_bow_impact_valid );
		a_inferno_targets = array::filter( a_inferno_targets, 0, &bow_rune_prison_geyser_valid, e_rune_prison_geyser );
		array::thread_all( a_inferno_targets, &bow_rune_prison_geyser_hit_zombie, e_rune_prison_geyser, e_player );
		WAIT_SERVER_FRAME;
		n_timer = n_timer + .05;
	}
	wait 6;
	e_rune_prison_geyser delete();
}

function bow_rune_prison_geyser_valid( ai_enemy, e_rune_prison_geyser )
{
	return !IS_TRUE( ai_enemy.b_is_rune_prison_geyser_hit );
}

function bow_rune_prison_geyser_hit_zombie( e_rune_prison_geyser, e_player )
{
	self endon( "death" );
	self.b_is_rune_prison_geyser_hit = 1;
	n_timer = 0;
	if ( self.archetype === "mechz" )
	{
		n_mechz_max_health = level.mechz_health;
		n_max_damage = ( n_mechz_max_health * .05 ) / .2;
		str_mod = "MOD_PROJECTILE_SPLASH";
	}
	else
	{
		n_max_damage = ( level.zombie_health > 2482 ? 2482 : level.zombie_health );
		str_mod = "MOD_UNKNOWN";
	}
	self clientfield::set( "runeprison_lava_geyser_dot_fx", 1 );
	n_dmg_high_percent = n_max_damage * .3;
	self doDamage( n_dmg_high_percent, self.origin, e_player, e_player, undefined, str_mod, 0, level.w_bow_rune_prison );
	n_dmg_low_percent = n_max_damage * .1;
	while ( n_timer < 6 && n_dmg_high_percent < n_max_damage )
	{
		n_delay = randomFloatRange( .4, 1 );
		wait n_delay;
		n_timer = n_timer + n_delay;
		self doDamage( n_dmg_low_percent, self.origin, e_player, e_player, undefined, str_mod, 0, level.w_bow_rune_prison );
		n_dmg_high_percent = n_dmg_high_percent + n_dmg_low_percent;
	}
	self clientfield::set( "runeprison_lava_geyser_dot_fx", 0 );
	self.b_is_rune_prison_geyser_hit = 0;
}

function bow_rune_prison_get_zombie_pos( ai_enemy )
{
	n_z_diff = 12 * 2;
	while ( isDefined( ai_enemy ) && isAlive( ai_enemy ) && !IS_TRUE( ai_enemy.b_is_bow_hit ) && n_z_diff > 12 )
	{
		a_trace = bulletTrace( ai_enemy.origin, ai_enemy.origin - vectorScale( ( 0, 0, 1 ), 1000 ), 0, undefined );
		n_z_diff = ai_enemy.origin[ 2 ] - a_trace[ "position" ][ 2 ];
		wait .1;
	}
	if ( isDefined( ai_enemy ) && isAlive( ai_enemy ) && !IS_TRUE( ai_enemy.b_is_bow_hit ) )
		return ai_enemy.origin;
	
	return undefined;
}

function bow_rune_prison_fake_fire_impact( str_weapon_name, v_source, v_destination )
{
	wait .1;
	str_weapon_name = ( str_weapon_name == "elemental_bow_rune_prison4" ? "elemental_bow_rune_prison4_ricochet" : "elemental_bow_rune_prison_ricochet" );
	magicBullet( getWeapon( str_weapon_name ), v_source, v_destination, self );
}
