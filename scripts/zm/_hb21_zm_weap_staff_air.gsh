/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###         	  	Harry Bo21s Black Ops 3 Staff of Air				   ###
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

#define STAFF_AIR_TABLE_FILE															"gamedata/weapons/zm/hb21_staff_air_settings.csv"
#define STAFF_AIR_TABLE_COLUMN_CONE_FOV									3
#define STAFF_AIR_TABLE_COLUMN_CONE_RANGE								4
#define STAFF_AIR_TABLE_COLUMN_WHIRLWIND_SUPERCHARGED		5
#define STAFF_AIR_TABLE_COLUMN_WHIRLWIND_LIFETIME					6
#define STAFF_AIR_TABLE_COLUMN_WHIRLWIND_RANGE					7

#define AIRSTAFF_WEAPON																"t7_staff_air"
#define AIRSTAFF_UPGRADED_WEAPON 												"t7_staff_air_upgraded"
#define AIRSTAFF_UPGRADED_WEAPON2 											"t7_staff_air_upgraded2"
#define AIRSTAFF_UPGRADED_WEAPON3 											"t7_staff_air_upgraded3"

#define AIRSTAFF_PROJECTILE_DELETE_DELAY									.75

#define AIRSTAFF_GIB_FX_TAG															"j_spine4"

#define AIRSTAFF_FLING_USE_SERVERSIDE										1
#define AIRSTAFF_FLING_TAG_CHECK												"j_spine4"
#define AIRSTAFF_FLING_MAX_FORCE												300
#define AIRSTAFF_FLING_MIN_UPWARD												.05
#define AIRSTAFF_FLING_MAX_UPWARD												.35
#define AIRSTAFF_FLING_MAX_AI_CHECK											12

#define AIRSTAFF_FLING_IMPACT_BURST_SPEED								20
#define AIRSTAFF_FLING_IMPACT_WAIT_TIMER									.05

#define AIRSTAFF_WHIRLWIND_PROXIMITY_RANGE								100
#define AIRSTAFF_WHIRLWIND_DRAG_TIME										1
#define AIRSTAFF_WHIRLWIND_DRAG_FAST_TIME								.8
#define AIRSTAFF_WHIRLWIND_KILL_RADIUS										30
#define AIRSTAFF_WHIRLWIND_TAG_CHECK										"j_spineupper"

#define AIRSTAFF_RUMBLE																	"artillery_rumble"
#define AIRSTAFF_RUMBLE_SCALE														.3
#define AIRSTAFF_RUMBLE_DURATION												1
#define AIRSTAFF_RUMBLE_RADIUS													100
#define AIRSTAFF_CHARGE_FX_TAG													"tag_fx_upg_"

// CLIENTFIELDS
// ======================================================================================================
#define AIRSTAFF_AOE_CF																	"staff_air_aoe_fx"
#define AIRSTAFF_SET_LAUNCH_SOURCE_CF										"staff_air_set_launch_source"
#define AIRSTAFF_LAUNCH_ZOMBIE_CF												"staff_air_launch_zombie"
#define AIRSTAFF_LAUNCH_RAGDOLL_IMPACT_WATCH_CF					"staff_air_ragdoll_impact_watch"

// FX
// ======================================================================================================
#define AIRSTAFF_AOE_FX 																"dlc5/zmb_weapon/fx_staff_air_impact_ug_miss"
#define AIRSTAFF_IMPACT_FX															"dlc5/zmb_weapon/fx_staff_air_impact"
#define AIRSTAFF_CHARGE_LIGHT_FX												"dlc5/zmb_weapon/fx_staff_charge_air_lv1"
#define AIRSTAFF_UPGRADE_FLASH													"harry/staff/air/fx_staff_wind_upgrade_flash"
#define AIRSTAFF_UPGRADE_GLOW													"dlc5/tomb/fx_tomb_elem_reveal_air_glow"
#define AIRSTAFF_UPGRADE_GLOW_COMPLETE									"harry/staff/air/fx_staff_wind_upgrade_glow_complete"

// MODELS
// ======================================================================================================
#define AIRSTAFF_MODEL 																	"wpn_t7_zmb_hd_staff_air_world"
#define AIRSTAFF_UPGRADED_MODEL	 											"wpn_t7_zmb_hd_staff_air_upgraded_world"
#define AIRSTAFF_PLINTH_MODEL	 													"p7_zm_ori_elm_plinth_top_wind"
#define AIRSTAFF_PLINTH_BASE_MODEL	 											"p7_zm_ori_elm_plinth_base_wind"

// SOUNDS
// ======================================================================================================
#define AIRSTAFF_AOE_LOOP_SOUND												"wpn_airstaff_tornado"
#define AIRSTAFF_AOE_IMPACT_SOUND												"wpn_airstaff_tornado_imp"
#define AIRSTAFF_CHARGE_SOUND													"wpn_airstaff_charge_"
#define AIRSTAFF_CHARGE_LOOP_SOUND											"wpn_airstaff_charge_loop"