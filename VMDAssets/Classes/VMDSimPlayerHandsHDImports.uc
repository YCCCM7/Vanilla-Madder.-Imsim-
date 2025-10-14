//=============================================================================
// VMDSimPlayerHandsHDImports
//=============================================================================
class VMDSimPlayerHandsHDImports extends VMDSimImportsParent abstract;

//
// VMDPlayerHands
//
#exec MESH IMPORT MESH=VMDPlayerHands ANIVFILE=Models\VMDPlayerHandsHDAnimated_a.3d DATAFILE=Models\VMDPlayerHandsHDAnimated_d.3d
#exec MESH ORIGIN MESH=VMDPlayerHands X=0 Y=0 Z=17920 YAW=64
#exec MESH LODPARAMS MESH=VMDPlayerHands STRENGTH=0.5

#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=All					STARTFRAME=0   NUMFRAMES=51

#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Still				STARTFRAME=0   NUMFRAMES=1           
#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Walk					STARTFRAME=1   NUMFRAMES=10  RATE=10 

#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Run					STARTFRAME=11  NUMFRAMES=10  RATE=18 
#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=CrouchWalk			STARTFRAME=21  NUMFRAMES=9   RATE=5  	GROUP=Ducking
#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Crouch				STARTFRAME=30  NUMFRAMES=3   RATE=6  	GROUP=Ducking
#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Jump					STARTFRAME=33 NUMFRAMES=1   RATE=10 
#exec MESH SEQUENCE MESH=VMDPlayerHands SEQ=Tread				STARTFRAME=34 NUMFRAMES=12  RATE=15 

#exec MESHMAP SCALE MESHMAP=VMDPlayerHands X=0.0078125 Y=0.01171875 Z=0.00390625
//#exec MESHMAP SCALE MESHMAP=VMDPlayerHands X=0.0078125 Y=0.01171875 Z=0.0078125

//
// VMDPlayerHandsLeft
//
#exec MESH IMPORT MESH=VMDPlayerHandsLeft ANIVFILE=Models\VMDPlayerHandsHDAnimated_a.3d DATAFILE=Models\VMDPlayerHandsHDAnimated_d.3d UNMIRROR=1
#exec MESH ORIGIN MESH=VMDPlayerHandsLeft X=0 Y=0 Z=17920 YAW=64
#exec MESH LODPARAMS MESH=VMDPlayerHandsLeft STRENGTH=0.5

#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=All					STARTFRAME=0   NUMFRAMES=366         
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Still				STARTFRAME=0   NUMFRAMES=1           
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Walk					STARTFRAME=1   NUMFRAMES=10  RATE=10
 
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Run					STARTFRAME=11  NUMFRAMES=10  RATE=18 
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=CrouchWalk			STARTFRAME=21  NUMFRAMES=9   RATE=5  	GROUP=Ducking
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Crouch				STARTFRAME=30  NUMFRAMES=3   RATE=6  	GROUP=Ducking
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Jump					STARTFRAME=33 NUMFRAMES=1   RATE=10 
#exec MESH SEQUENCE MESH=VMDPlayerHandsLeft SEQ=Tread				STARTFRAME=34 NUMFRAMES=12  RATE=15 

#exec MESHMAP SCALE MESHMAP=VMDPlayerHandsLeft X=0.0078125 Y=0.01171875 Z=0.00390625
//#exec MESHMAP SCALE MESHMAP=VMDPlayerHandsLeft X=0.0078125 Y=0.01171875 Z=0.0078125

defaultproperties
{
}
