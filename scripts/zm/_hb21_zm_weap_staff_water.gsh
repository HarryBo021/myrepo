/*#========================================###
###                                                                   					   ###
###                                                                   					   ###
###           		Harry Bo21s Black Ops 3 Staff of Ice				   ###
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

#define STAFF_WATER_TABLE_FILE														"gamedata/weapons/zm/hb21_staff_water_settings.csv"
#define STAFF_WATER_TABLE_COLUMN_CONE_FOV								3
#define STAFF_WATER_TABLE_COLUMN_CONE_RANGE							4
#define STAFF_WATER_TABLE_COLUMN_BLIZZARD_LIFETIME				5
#define STAFF_WATER_TABLE_COLUMN_BLIZZARD_RANGE					6

#define WATERSTAFF_WEAPON 															"t7_staff_water"
#define WATERSTAFF_UPGRADED_WEAPON 										"t7_staff_water_upgraded"
#define WATERSTAFF_UPGRADED_WEAPON2 										"t7_staff_water_upgraded2"
#define WATERSTAFF_UPGRADED_WEAPON3 										"t7_staff_water_upgraded3"

#define WATERSTAFF_OIP_DAMAGE													11275

#define WATERSTAFF_CONE_NETWORK_CHECKS									3
#define WATERSTAFF_CONE_IMPACT_TAGS										array( "j_hip_le", "j_hip_ri", "j_spine4", "j_elbow_le", "j_elbow_ri", "j_clavicle_le", "j_clavicle_ri" )
#define WATERSTAFF_CONE_TAG_CHECK											"j_spine4" // j_spine1 for dogs
#define WATERSTAFF_CONE_MAX_AI_CHECK										100

#define WATERSTAFF_BLIZZARD_TAG_CHECK									"j_spine4" // j_spine1 for dogs

#define WATERSTAFF_FREEZE_FX_TAG												"j_spine4" // j_spine1 for dogs

#define WATERSTAFF_MIN_FREEZE_DELAY											1.8
#define WATERSTAFF_MAX_FREEZE_DELAY											2.3
#define WATERSTAFF_FREEZE_ANIM_RATE_INCRIMENTS						.05
#define WATERSTAFF_FREEZE_ANIM_RATE_DECRIMENTS						.1
#define WATERSTAFF_FREEZE_ANIM_RATE											.3
#define WATERSTAFF_SHATTER_NOTETRACKS									array( "shatter", "start_ragdoll" ) // , "die", "death"
#define WATERSTAFF_SHATTER_TIMEOUT											1.5
#define WATERSTAFF_FREEZE_DR_NAME												"staff_water_freeze"
#define WATERSTAFF_FREEZE_DR_FLAG												"staff_water_freeze_on"
#define WATERSTAFF_FREEZE_DR_PRIORITY										10
#define WATERSTAFF_FREEZE_DR_INCRIMENTS									.02
#define WATERSTAFF_FREEZE_DR_DECRIMENTS									.01

#define WATERSTAFF_RUMBLE															"artillery_rumble"
#define WATERSTAFF_RUMBLE_SCALE												.3
#define WATERSTAFF_RUMBLE_DURATION											1
#define WATERSTAFF_RUMBLE_RADIUS												100
#define WATERSTAFF_CHARGE_FX_TAG												"tag_fx_upg_"

// CLIENTFIELDS
// ======================================================================================================
#define WATERSTAFF_BLIZZARD_CF													"staff_water_blizzard_fx"
#define WATERSTAFF_FREEZE_ZOMBIE_CF											"staff_water_freeze_zombie"
#define WATERSTAFF_FREEZE_FX_CF													"staff_water_freeze_fx"
	
// FX
// ======================================================================================================
#define WATERSTAFF_SHATTER_FX 													"dlc5/zmb_weapon/fx_staff_ice_exp"
#define WATERSTAFF_BLIZZARD_FX 													"dlc5/zmb_weapon/fx_staff_ice_impact_ug_hit"
#define WATERSTAFF_CHARGE_LIGHT_FX											"dlc5/zmb_weapon/fx_staff_charge_ice_lv1"
#define WATERSTAFF_ICICLE_FX 														"dlc5/zmb_weapon/fx_staff_ice_trail_bolt"
#define WATERSTAFF_UPGRADE_FLASH												"harry/staff/water/fx_staff_water_upgrade_flash"
#define WATERSTAFF_UPGRADE_GLOW												"dlc5/tomb/fx_tomb_elem_reveal_ice_glow"
#define WATERSTAFF_UPGRADE_GLOW_COMPLETE								"harry/staff/water/fx_staff_water_upgrade_glow_complete"

// MODELS
// ======================================================================================================
#define WATERSTAFF_MODEL 															"wpn_t7_zmb_hd_staff_water_world"
#define WATERSTAFF_UPGRADED_MODEL	 										"wpn_t7_zmb_hd_staff_water_upgraded_world"
#define WATERSTAFF_PLINTH_MODEL	 												"p7_zm_ori_elm_plinth_top_ice"
#define WATERSTAFF_PLINTH_BASE_MODEL	 									"p7_zm_ori_elm_plinth_base_ice"

// MATERIALS
// ======================================================================================================
#define WATERSTAFF_FREEZE_MATERIAL											"mc/mtl_freezeover"

// SOUNDS
// ======================================================================================================
#define WATERSTAFF_IMPACT_SOUND												"wpn_waterstaff_storm_imp"
#define WATERSTAFF_BLIZZARD_SOUND											"wpn_waterstaff_storm"
#define WATERSTAFF_FREEZE_ZOMBIE_SOUND									"wpn_waterstaff_freeze_zombie"
#define WATERSTAFF_ZOMBIE_SHATTER												"wpn_waterstaff_shatter_zombie"
#define WATERSTAFF_ZOMBIE_COLLAPSE											"wpn_waterstaff_collapse_zombie"
#define WATERSTAFF_ZOMBIE_IMPACT												"wpn_waterstaff_impact_zombie"
#define WATERSTAFF_CHARGE_SOUND												"wpn_waterstaff_charge_"
#define WATERSTAFF_CHARGE_LOOP_SOUND										"wpn_waterstaff_charge_loop"