/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###           			Harry Bo21s Black Ops 3 Acidgat						  ###
###                                                                   							  ###
###                                                                   							  ###
###========================================#*/
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
#define BLUNDERGAT_WEAPONFILE										"t8_shotgun_blundergat"
#define BLUNDERGAT_UPGRADED_WEAPONFILE					"t8_shotgun_blundergat_upgraded"
#define BLUNDERSPLAT_WEAPONFILE									"t8_shotgun_acidgat"
#define BLUNDERSPLAT_UPGRADED_WEAPONFILE					"t8_shotgun_acidgat_upgraded"
#define BLUNDERSPLAT_PROJECTILE_WEAPONFILE				"t8_shotgun_acidgat_bullet"
#define BLUNDERSPLAT_GRENADE_WEAPONFILE					"t8_shotgun_acidgat_explosive"

#define BLUNDERSPLAT_PROJECTILE_FORWARD_TRACE		20000
#define BLUNDERSPLAT_PROJECTILE_SPREAD						80
#define BLUNDERSPLAT_FOV_RANGE									30
#define BLUNDERSPLAT_MAX_RANGE									1500
#define BLUNDERSPLAT_TARGET_TAGS									array( "j_hip_le", "j_hip_ri", "j_spine4", "j_elbow_le", "j_elbow_ri", "j_clavicle_le", "j_clavicle_ri" )
#define BLUNDERSPLAT_UPGRADE_TIMEOUT							15
	
// MODELS
// ======================================================================================================
#define BLUNDERSPLAT_PROJECTILE_MODEL						"t8_wpn_zmb_projectile_blundergat"

// ANIMS
// ======================================================================================================
#define BLUNDERSPLAT_START_ANIM									"t8_fxanim_zom_al_packasplat_start_anim" 		
#define BLUNDERSPLAT_IDLE_ANIM										"t8_fxanim_zom_al_packasplat_idle_anim" 		
#define BLUNDERSPLAT_END_ANIM										"t8_fxanim_zom_al_packasplat_end_anim" 	

// FX
// ======================================================================================================
#define BLUNDERSPLAT_PROJECTILE_FX								"harry/blundersplat/fx_blundersplat_blink"