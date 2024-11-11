//=============================================================================
// VMDSimMeshImports
//=============================================================================
class VMDSimMeshImports extends VMDSimImportsParent abstract;

//=============================
//VMDSpeechBubble
//=============================
#exec TEXTURE IMPORT NAME="VMDSpeechBubbleTex0" FILE="Textures\VMDSpeechBubbleTex0.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDSpeechBubbleTex1" FILE="Textures\VMDSpeechBubbleTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDSpeechBubble ANIVFILE=MODELS\VMDSpeechBubble_a.3d DATAFILE=MODELS\VMDSpeechBubble_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDSpeechBubble X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=-64

#exec MESH SEQUENCE MESH=VMDSpeechBubble SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSpeechBubble SEQ=VMDSpeechBubble STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDSpeechBubble MESH=VMDSpeechBubble
#exec MESHMAP SCALE MESHMAP=VMDSpeechBubble X=0.04511863125 Y=0.04511863125 Z=0.04511863125

#exec MESHMAP SETTEXTURE MESHMAP=VMDSpeechBubble NUM=0 TEXTURE=VMDSpeechBubbleTex0
#exec MESHMAP SETTEXTURE MESHMAP=VMDSpeechBubble NUM=1 TEXTURE=VMDSpeechBubbleTex1

//=============================
//VMDHallucination
//=============================
#exec MESH IMPORT MESH=VMDHallucination ANIVFILE=MODELS\VMDHallucination_a.3d DATAFILE=MODELS\VMDHallucination_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDHallucination X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=-64

#exec MESH SEQUENCE MESH=VMDHallucination SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDHallucination SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDHallucination SEQ=PortalOpen STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDHallucination SEQ=PortalClose STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDHallucination MESH=VMDHallucination
#exec MESHMAP SCALE MESHMAP=VMDHallucination X=0.030139245675 Y=0.030139245675 Z=0.030139245675

//MADDERS: This is technically the wrong texture now, but keep it loaded anyways. There's no harm in it.
//#exec MESHMAP SETTEXTURE MESHMAP=VMDHallucination NUM=0 TEXTURE=RainbowPalette

//=============================
//VMDNGPortal. We're directly related to VMDHallucination.
//=============================
#exec TEXTURE IMPORT NAME="VMDNGPlusPortalTex1" FILE="Textures\NGPlusPortalTex1.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDNGPlusPortalTex2" FILE="Textures\NGPlusPortalTex2.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDNGPlusPortalTex3" FILE="Textures\NGPlusPortalTex3.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDNGPlusPortalTex4" FILE="Textures\NGPlusPortalTex4.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDNGPortal ANIVFILE=MODELS\VMDNGPortal_a.3d DATAFILE=MODELS\VMDNGPortal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDNGPortal X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=-64

#exec MESH SEQUENCE MESH=VMDNGPortal SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDNGPortal SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDNGPortal SEQ=PortalOpen STARTFRAME=0 NUMFRAMES=9 RATE=9
#exec MESH SEQUENCE MESH=VMDNGPortal SEQ=PortalClose STARTFRAME=9 NUMFRAMES=9 RATE=9

#exec MESHMAP NEW   MESHMAP=VMDNGPortal MESH=VMDNGPortal
#exec MESHMAP SCALE MESHMAP=VMDNGPortal X=0.030139245675 Y=0.030139245675 Z=0.030139245675

//MADDERS: This is technically the wrong texture now, but keep it loaded anyways. There's no harm in it.
#exec MESHMAP SETTEXTURE MESHMAP=VMDNGPortal NUM=0 TEXTURE=VMDNGPlusPortalTex1
#exec MESHMAP SETTEXTURE MESHMAP=VMDNGPortal NUM=1 TEXTURE=VMDNGPlusPortalTex2
#exec MESHMAP SETTEXTURE MESHMAP=VMDNGPortal NUM=2 TEXTURE=VMDNGPlusPortalTex3
#exec MESHMAP SETTEXTURE MESHMAP=VMDNGPortal NUM=3 TEXTURE=VMDNGPlusPortalTex4
//#exec MESHMAP SETTEXTURE MESHMAP=VMDNGPortal NUM=4 TEXTURE=RainbowPalette

//=============================
//VMDPreloadHack. Used for revving up animated textures before they're first seen.
//=============================
#exec MESH IMPORT MESH=VMDPreloadHack ANIVFILE=MODELS\VMDPreloadHack_a.3d DATAFILE=MODELS\VMDPreloadHack_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDPreloadHack X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=-64

#exec MESH SEQUENCE MESH=VMDPreloadHack SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPreloadHack SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPreloadHack SEQ=PortalOpen STARTFRAME=0 NUMFRAMES=9 RATE=9
#exec MESH SEQUENCE MESH=VMDPreloadHack SEQ=PortalClose STARTFRAME=9 NUMFRAMES=9 RATE=9

#exec MESHMAP NEW   MESHMAP=VMDPreloadHack MESH=VMDPreloadHack
#exec MESHMAP SCALE MESHMAP=VMDPreloadHack X=0.030139245675 Y=0.030139245675 Z=0.030139245675

#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=0 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=1 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=2 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=3 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=4 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=5 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=6 TEXTURE=BlackMaskTex
#exec MESHMAP SETTEXTURE MESHMAP=VMDPreloadHack NUM=7 TEXTURE=BlackMaskTex

//=============================
//LogicMesh
//=============================
#exec MESH IMPORT MESH=LogicMesh ANIVFILE=MODELS\LogicMesh_a.3d DATAFILE=MODELS\LogicMesh_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=LogicMesh X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=-64

#exec MESH SEQUENCE MESH=LogicMesh SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=LogicMesh SEQ=LogicMesh STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=LogicMesh MESH=LogicMesh
#exec MESHMAP SCALE MESHMAP=LogicMesh X=0.0902372625 Y=-0.0902372625 Z=0.0902372625

#exec MESHMAP SETTEXTURE MESHMAP=LogicMesh NUM=0 TEXTURE=BlackMaskTex

//=============================
//VMDSodacan
//=============================
//
// Sodacan
//
#exec MESH IMPORT MESH=VMDSodacan ANIVFILE=Models\VMDSodacan_a.3d DATAFILE=Models\VMDSodacan_d.3d
#exec MESHMAP SCALE MESHMAP=VMDSodacan X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDSodacan SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSodacan SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec TEXTURE IMPORT NAME=VMDSodacanTex5 FILE=Textures\VMDSodaCanTex5.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=VMDSodacan NUM=0 TEXTURE=SodacanTex1

//=============================
//VMDRifleShellCasing
//=============================
#exec OBJ LOAD FILE=DeusExItems

#exec MESH IMPORT MESH=VMDRifleShellCasing ANIVFILE=Models\VMDRifleShellCasing_a.3d DATAFILE=Models\VMDRifleShellCasing_d.3d
#exec MESH ORIGIN MESH=VMDRifleShellCasing X=0 Y=0 Z=0 YAW=0
#exec MESHMAP SCALE MESHMAP=VMDRifleShellCasing X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDRifleShellCasing SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDRifleShellCasing SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=VMDRifleShellCasing NUM=0 TEXTURE=ShellCasingTex1

//=============================
//VMDTaserSlug
//=============================
#exec MESH IMPORT MESH=VMDTaserSlug ANIVFILE=Models\VMDTaserSlug_a.3d DATAFILE=Models\VMDTaserSlug_d.3d
#exec MESH ORIGIN MESH=VMDTaserSlug X=0 Y=2500 Z=0 YAW=64
#exec MESHMAP SCALE MESHMAP=VMDTaserSlug X=0.001953125 Y=0.001953125 Z=0.001953125 //0.00390625 * 0.5
#exec MESH SEQUENCE MESH=VMDTaserSlug SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDTaserSlug SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec TEXTURE IMPORT NAME=TaserSlug FILE=Textures\TaserSlugDetailed.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=TaserSlugSpent FILE=Textures\TaserSlugSpentDetailed.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=VMDTaserSlug NUM=0 TEXTURE=TaserSlug

//=============================
//Security bots, now with tread shiat.
//=============================
//
// VMDSecurityBot3
//
#exec MESH IMPORT MESH=VMDSecurityBot3 ANIVFILE=Models\VMDSecurityBot3_a.3d DATAFILE=Models\VMDSecurityBot3_d.3d
#exec MESH ORIGIN MESH=VMDSecurityBot3 X=0 Y=0 Z=7296 YAW=64

#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=All			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=Still			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=Walk			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=Run			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=Shoot			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=BreatheLight	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=DeathFront	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=DeathBack		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot3 SEQ=Idle			STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=VMDSecurityBot3 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=VMDSecurityBot3Tex1Tread0 FILE=Textures\SecurityBot3Tex1Tread0.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=VMDSecurityBot3Tex1Tread1 FILE=Textures\SecurityBot3Tex1Tread1.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=VMDSecurityBot3Tex1Tread2 FILE=Textures\SecurityBot3Tex1Tread2.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot3 NUM=0 TEXTURE=SecurityBot3Tex1
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot3 NUM=1 TEXTURE=VMDSecurityBot3Tex1Tread0
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot3 NUM=2 TEXTURE=VMDSecurityBot3Tex1Tread0

//
// VMDSecurityBot4
//
#exec MESH IMPORT MESH=VMDSecurityBot4 ANIVFILE=Models\VMDSecurityBot4_a.3d DATAFILE=Models\VMDSecurityBot4_d.3d
#exec MESH ORIGIN MESH=VMDSecurityBot4 X=0 Y=0 Z=7296 YAW=64

#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=All			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=Still			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=Walk			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=Run			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=Shoot			STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=BreatheLight	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=DeathFront	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=DeathBack		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSecurityBot4 SEQ=Idle			STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=VMDSecurityBot4 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=VMDSecurityBot4Tex1Tread0 FILE=Textures\SecurityBot4Tex1Tread0.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=VMDSecurityBot4Tex1Tread1 FILE=Textures\SecurityBot4Tex1Tread1.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=VMDSecurityBot4Tex1Tread2 FILE=Textures\SecurityBot4Tex1Tread2.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot4 NUM=0 TEXTURE=SecurityBot4Tex1
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot4 NUM=1 TEXTURE=VMDSecurityBot4Tex1Tread0
#exec MESHMAP SETTEXTURE MESHMAP=VMDSecurityBot4 NUM=2 TEXTURE=VMDSecurityBot4Tex1Tread0

//
// VMDInvertedTracer
//
#exec MESH IMPORT MESH=VMDInvertedTracer ANIVFILE=Models\Tracer_a.3d DATAFILE=Models\Tracer_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=VMDInvertedTracer X=0 Y=0 Z=0 YAW=64 UNMIRROR=1
#exec MESHMAP SCALE MESHMAP=VMDInvertedTracer X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDInvertedTracer SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDInvertedTracer SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=VMDInvertedTracer NUM=0 TEXTURE=TracerTex1


defaultproperties
{
}
