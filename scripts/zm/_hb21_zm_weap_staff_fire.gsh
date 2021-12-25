/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###         	  	Harry Bo21s Black Ops 3 Staff of Fire				   ###
###                                                                   					   ###
###                                                                   					   ###
###========================================#*/
// LAST UPDATE V2.5.0 - 19/12/18
/*============================================

											CREDITS

=============================================
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
===========================================*/
	
// SETTINGS
// ======================================================================================================

#define STAFF_FIRE_TABLE_FILE														"gamedata/weapons/zm/hb21_staff_fire_settings.csv"
#define STAFF_FIRE_TABLE_COLUMN_BURN_DAMAGE							3
#define STAFF_FIRE_TABLE_COLUMN_BURN_DURATION						4
#define STAFF_FIRE_TABLE_COLUMN_VOLCANO_RANGE						5
#define STAFF_FIRE_TABLE_COLUMN_VOLCANO_LIFETIME					6

#define FIRESTAFF_WEAPON 																"t7_staff_fire"
#define FIRESTAFF_UPGRADED_WEAPON 											"t7_staff_fire_upgraded"
#define FIRESTAFF_UPGRADED_WEAPON2 											"t7_staff_fire_upgraded2"
#define FIRESTAFF_UPGRADED_WEAPON3 											"t7_staff_fire_upgraded3"

#define FIRESTAFF_DELAY_BETWEEN_SHOTS										.35

#define FIRESTAFF_VOLCANO_STEP_SIZE											.2
#define FIRESTAFF_VOLCANO_LAST_CHECK_RANGE_MULTIPLIER			2

#define FIRESTAFF_BURN_MIN_RATE													.015
#define FIRESTAFF_BURN_MAX_RATE													.1

#define FIRESTAFF_RUMBLE																"artillery_rumble"
#define FIRESTAFF_RUMBLE_SCALE													.3
#define FIRESTAFF_RUMBLE_DURATION												1
#define FIRESTAFF_RUMBLE_RADIUS													100
#define FIRESTAFF_CHARGE_FX_TAG													"tag_fx_upg_"

#define FIRESTAFF_BURN_DR_NAME													"staff_fire_burn"
#define FIRESTAFF_BURN_DR_FLAG													"staff_fire_burn_on"
#define FIRESTAFF_BURN_DR_PRIORITY												11

// CLIENTFIELDS
// ======================================================================================================
#define FIRESTAFF_VOLCANO_CF														"staff_fire_volcano_fx"
#define FIRESTAFF_ZOMBIE_BURN_CF												"staff_fire_burn_zombie"

// FX
// ======================================================================================================
#define FIRESTAFF_VOLCANO_FX 														"dlc5/zmb_weapon/fx_staff_fire_impact_ug_exp_loop"
#define FIRESTAFF_CHARGE_LIGHT_FX												"dlc5/zmb_weapon/fx_staff_charge_fire_lv1"
#define FIRESTAFF_TORSO_FIRE_DEATH_TORSO_FX							"zombie/fx_fire_torso_zmb"
#define FIRESTAFF_TORSO_FIRE_DEATH_SMALL_FX								"zombie/fx_fire_torso_zmb"
#define FIRESTAFF_UPGRADE_FLASH													"harry/staff/fire/fx_staff_fire_upgrade_flash"
#define FIRESTAFF_UPGRADE_GLOW													"dlc5/tomb/fx_tomb_elem_reveal_fire_glow"
#define FIRESTAFF_UPGRADE_GLOW_COMPLETE									"harry/staff/fire/fx_staff_fire_upgrade_glow_complete"

// MODELS
// ======================================================================================================
#define FIRESTAFF_MODEL 																"wpn_t7_zmb_hd_staff_fire_world"
#define FIRESTAFF_UPGRADED_MODEL	 											"wpn_t7_zmb_hd_staff_fire_upgraded_world"
#define FIRESTAFF_PLINTH_MODEL	 													"p7_zm_ori_elm_plinth_top_fire"
#define FIRESTAFF_PLINTH_BASE_MODEL	 										"p7_zm_ori_elm_plinth_base_fire"

// MATERIALS
// ======================================================================================================
#define FIRESTAFF_BURN_MATERIAL													"mc/mtl_burnover"

// SOUNDS
// ======================================================================================================
#define FIRESTAFF_ZOMBIE_FIRE_LOOP_SOUND									"zmb_fire_loop"
#define FIRESTAFF_PROJ_LOOP_SOUND												"wpn_firestaff_grenade_loop"
#define FIRESTAFF_PROJ_IMPACT_SOUND											"wpn_firestaff_proj_impact"
#define FIRESTAFF_CHARGE_SOUND													"wpn_firestaff_charge_"
#define FIRESTAFF_CHARGE_LOOP_SOUND											"wpn_firestaff_charge_loop"