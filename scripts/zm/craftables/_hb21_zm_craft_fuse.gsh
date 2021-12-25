/*#===================================================================###
###                                                                   ###
###                                                                   ###
###        Harry Bo21s Black Ops 3 Acidgat Upgrade Station v1.0.0	  ###
###                                                                   ###
###                                                                   ###
###===================================================================#*/
/*=======================================================================

								CREDITS

=========================================================================
Lilrifa
Easyskanka
ProRevenge
DTZxPorter
Zeroy
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MZSlayer
AndyWhelen
HitmanVere
ProGamerzFTW
Scobalula
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
=======================================================================*/
	
// SETTINGS
// ======================================================================================================
#define BLUNDERSPLAT_NAME										"craft_blundersplat_zm" 					// believe this is the kvp on the bench trigger
#define BLUNDERSPLAT_WEAPON										"dragon_shield"								// This is the weapon youll get after built
#define BLUNDERSPLAT_MODEL										"p6_anim_zm_al_packasplat" 					// This is the model that is spawned on the bench when built
#define BLUNDERSPLAT_START_ANIM									"fxanim_zom_al_packasplat_start_anim" 		
#define BLUNDERSPLAT_IDLE_ANIM									"fxanim_zom_al_packasplat_idle_anim" 		
#define BLUNDERSPLAT_END_ANIM									"fxanim_zom_al_packasplat_end_anim" 		

#define CRAFT_READY_STRING										"Hold ^3&&1^7 to craft Blundergat Upgrade" 	// This is the string itll show at the bench when you are ready to craft
#define CRAFT_GRAB_STRING										"Hold ^3&&1^7 to take NAME" 				// This is the string itll show at the bench when you are ready to take the object
#define CRAFT_GRABED_STRING										"Took NAME!!!!!!!!!!!!!!!!!!!!!!!" 			// This is the string itll show at the bench when you take the object ( only shows for a brief moment )

#define CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_0			"p6_zm_al_packasplat_engine" 				// This is the model name for a part ( must be unique! )
#define CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_1			"p6_zm_al_packasplat_iv" 					// This is the model name for a part ( must be unique! )
#define CLIENTFIELD_BLUNDERSPLAT_PIECE_CRAFTABLE_PART_2			"p6_zm_al_packasplat_suitcase" 				// This is the model name for a part ( must be unique! )

#define BLUNDERSPLAT_OFFSET										0 											// Offset for the model to spawn on a "open" bench
