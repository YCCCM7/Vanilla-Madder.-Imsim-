//=============================================================================
// VMDSimCraftingImports
//=============================================================================
class VMDSimCraftingImports extends VMDSimImportsParent abstract;

//=============================
//Toolbox and Chemistry Set, plus Scrap/Chemicals
//=============================
#exec TEXTURE IMPORT NAME="VMDGrenadeHousingTex1" FILE="Textures\GrenadeHousingTex1.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="BeltIconGrenadeHousing" FILE="Textures\BeltIconGrenadeHousing.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconGrenadeHousing" FILE="Textures\LargeIconGrenadeHousing.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="VMDToolboxRed01" FILE="Textures\ToolboxRed01.pcx" GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME="VMDToolboxRed02" FILE="Textures\ToolboxRed02.pcx" GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME="VMDToolboxRed03" FILE="Textures\ToolboxRed03.pcx" GROUP=Skins FLAGS=2

#exec TEXTURE IMPORT NAME="VMDScrapMetalBolt01" FILE="Textures\ScrapMetalBolt01.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDScrapMetalBolt02" FILE="Textures\ScrapMetalBolt02.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDScrapMetalLeadPipe" FILE="Textures\ScrapMetalLeadPipe.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDScrapMetalRustyGear" FILE="Textures\ScrapMetalRustyGear.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDScrapMetalSheet" FILE="Textures\ScrapMetalSheet.pcx" GROUP=Skins

#exec OBJ LOAD FILE=CoreTexGlass
#exec TEXTURE IMPORT NAME="VMDChemistrySetFluids" FILE="Textures\ChemistrySetFluids.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDChemistrySetPlastic" FILE="Textures\ChemistrySetPlastic.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="VMDChemicalsBluePlastic" FILE="Textures\ChemicalsBluePlastic.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDChemicalsBlueLiquid" FILE="Textures\ChemicalsBlueLiquid.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDChemicalsGreenLiquid" FILE="Textures\ChemicalsGreenLiquid.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDChemicalsGoldLiquid" FILE="Textures\ChemicalsGoldLiquid.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDChemicalsPinkLiquid" FILE="Textures\ChemicalsPinkLiquid.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="BeltIconVMDToolbox" FILE="Textures\BeltIconVMDToolbox.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDToolbox" FILE="Textures\LargeIconVMDToolbox.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="BeltIconVMDScrapMetal" FILE="Textures\BeltIconScrapMetal.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="ChargedIconVMDScrapMetal" FILE="Textures\ChargedIconScrapMetal.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDScrapMetal" FILE="Textures\LargeIconScrapMetal.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="BeltIconVMDChemistrySet" FILE="Textures\BeltIconVMDChemistrySet.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDChemistrySet" FILE="Textures\LargeIconVMDChemistrySet.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDChemistrySetDry" FILE="Textures\LargeIconVMDChemistrySetDry.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDChemistrySetRotated" FILE="Textures\LargeIconVMDChemistrySetRotated.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDChemistrySetRotatedDry" FILE="Textures\LargeIconVMDChemistrySetRotatedDry.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="BeltIconVMDChemicals" FILE="Textures\BeltIconVMDChemicals.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="ChargedIconVMDChemicals" FILE="Textures\ChargedIconVMDChemicals.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="LargeIconVMDChemicals" FILE="Textures\LargeIconVMDChemicals.pcx" GROUP=UI FLAGS=2

//=============================
//VMDToolbox
//=============================

//--------
//PICKUP!
#exec MESH IMPORT MESH=VMDToolbox ANIVFILE=MODELS\VMDToolbox_a.3d DATAFILE=MODELS\VMDToolbox_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDToolbox X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDToolbox SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDToolbox SEQ=VMDToolbox STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDToolbox MESH=VMDToolbox
#exec MESHMAP SCALE MESHMAP=VMDToolbox X=0.02707117875 Y=0.02707117875 Z=0.02707117875

#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox NUM=0 TEXTURE=VMDToolboxRed01
#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox NUM=1 TEXTURE=VMDToolboxRed02
#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox NUM=2 TEXTURE=VMDToolboxRed03

//--------
//3RD!
#exec MESH IMPORT MESH=VMDToolbox3rd ANIVFILE=MODELS\VMDToolbox_a.3d DATAFILE=MODELS\VMDToolbox_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDToolbox3rd X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDToolbox3rd SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDToolbox3rd SEQ=VMDToolbox STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDToolbox3rd MESH=VMDToolbox3rd
#exec MESHMAP SCALE MESHMAP=VMDToolbox3rd X=0.02707117875 Y=0.02707117875 Z=0.02707117875

#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox3rd NUM=0 TEXTURE=VMDToolboxRed01
#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox3rd NUM=1 TEXTURE=VMDToolboxRed02
#exec MESHMAP SETTEXTURE MESHMAP=VMDToolbox3rd NUM=2 TEXTURE=VMDToolboxRed03

//=============================
//VMDScrapMetal
//=============================
#exec MESH IMPORT MESH=VMDScrapMetal ANIVFILE=MODELS\VMDScrapMetal_a.3d DATAFILE=MODELS\VMDScrapMetal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDScrapMetal X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDScrapMetal SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDScrapMetal SEQ=VMDScrapMetal STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDScrapMetal MESH=VMDScrapMetal
#exec MESHMAP SCALE MESHMAP=VMDScrapMetal X=0.013535589375 Y=0.013535589375 Z=0.013535589375

//Level 1: Bolt
#exec MESHMAP SETTEXTURE MESHMAP=VMDScrapMetal NUM=0 TEXTURE=VMDScrapMetalBolt01
#exec MESHMAP SETTEXTURE MESHMAP=VMDScrapMetal NUM=1 TEXTURE=VMDScrapMetalBolt02
//Level 2: Gear
#exec MESHMAP SETTEXTURE MESHMAP=VMDScrapMetal NUM=2 TEXTURE=VMDScrapMetalRustyGear
//Level 3: Sheet
#exec MESHMAP SETTEXTURE MESHMAP=VMDScrapMetal NUM=3 TEXTURE=VMDScrapMetalSheet
//Level 4: Lead Pipe
#exec MESHMAP SETTEXTURE MESHMAP=VMDScrapMetal NUM=4 TEXTURE=VMDScrapMetalLeadPipe

//=============================
//VMDChemistrySet
//=============================

//--------
//PICKUP!
#exec MESH IMPORT MESH=VMDChemistrySet ANIVFILE=MODELS\VMDChemistrySet_a.3d DATAFILE=MODELS\VMDChemistrySet_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemistrySet X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemistrySet SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemistrySet SEQ=VMDChemistrySet STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemistrySet MESH=VMDChemistrySet
#exec MESHMAP SCALE MESHMAP=VMDChemistrySet X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet NUM=0 TEXTURE=07WindOpacStrek
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet NUM=1 TEXTURE=VMDChemistrySetFluids
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet NUM=2 TEXTURE=VMDChemistrySetPlastic

//--------
//3RD!
#exec MESH IMPORT MESH=VMDChemistrySet3rd ANIVFILE=MODELS\VMDChemistrySet_a.3d DATAFILE=MODELS\VMDChemistrySet_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemistrySet3rd X=0 Y=-100 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemistrySet3rd SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemistrySet3rd SEQ=VMDChemistrySet STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemistrySet3rd MESH=VMDChemistrySet3rd
#exec MESHMAP SCALE MESHMAP=VMDChemistrySet3rd X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet3rd NUM=0 TEXTURE=07WindOpacStrek
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet3rd NUM=1 TEXTURE=VMDChemistrySetFluids
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemistrySet3rd NUM=2 TEXTURE=VMDChemistrySetPlastic

//=============================
//VMDChemicals. There's 4 of these.
//=============================
#exec MESH IMPORT MESH=VMDChemicals01 ANIVFILE=MODELS\VMDChemicals01_a.3d DATAFILE=MODELS\VMDChemicals01_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemicals01 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemicals01 SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemicals01 SEQ=VMDChemicals STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemicals01 MESH=VMDChemicals01
#exec MESHMAP SCALE MESHMAP=VMDChemicals01 X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals01 NUM=0 TEXTURE=VMDChemicalsBluePlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals01 NUM=4 TEXTURE=VMDChemicalsPinkLiquid

#exec MESH IMPORT MESH=VMDChemicals02 ANIVFILE=MODELS\VMDChemicals02_a.3d DATAFILE=MODELS\VMDChemicals02_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemicals02 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemicals02 SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemicals02 SEQ=VMDChemicals STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemicals02 MESH=VMDChemicals02
#exec MESHMAP SCALE MESHMAP=VMDChemicals02 X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals02 NUM=0 TEXTURE=VMDChemicalsBluePlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals02 NUM=1 TEXTURE=VMDChemicalsBlueLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals02 NUM=4 TEXTURE=VMDChemicalsPinkLiquid

#exec MESH IMPORT MESH=VMDChemicals03 ANIVFILE=MODELS\VMDChemicals03_a.3d DATAFILE=MODELS\VMDChemicals03_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemicals03 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemicals03 SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemicals03 SEQ=VMDChemicals STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemicals03 MESH=VMDChemicals03
#exec MESHMAP SCALE MESHMAP=VMDChemicals03 X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals03 NUM=0 TEXTURE=VMDChemicalsBluePlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals03 NUM=1 TEXTURE=VMDChemicalsBlueLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals03 NUM=2 TEXTURE=VMDChemicalsGreenLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals03 NUM=4 TEXTURE=VMDChemicalsPinkLiquid

#exec MESH IMPORT MESH=VMDChemicals04 ANIVFILE=MODELS\VMDChemicals04_a.3d DATAFILE=MODELS\VMDChemicals04_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDChemicals04 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDChemicals04 SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDChemicals04 SEQ=VMDChemicals STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDChemicals04 MESH=VMDChemicals04
#exec MESHMAP SCALE MESHMAP=VMDChemicals04 X=0.01624270725 Y=0.01624270725 Z=0.01624270725

#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals04 NUM=0 TEXTURE=VMDChemicalsBluePlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals04 NUM=1 TEXTURE=VMDChemicalsBlueLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals04 NUM=2 TEXTURE=VMDChemicalsGreenLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals04 NUM=3 TEXTURE=VMDChemicalsGoldLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDChemicals04 NUM=4 TEXTURE=VMDChemicalsPinkLiquid

//=============================
//VMDSyringe
//=============================
#exec TEXTURE IMPORT NAME="BeltIconCombatStim" FILE="Textures\BeltIconCombatStim.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="BeltIconMedigel" FILE="Textures\BeltIconMedigel.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="VMDSyringeMarkings" FILE="Textures\SyringeMarkings.pcx" GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME="VMDSyringeBlackPlastic" FILE="Textures\SyringeBlackPlastic.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDSyringePinkPlastic" FILE="Textures\SyringePinkPlastic.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDSyringeSilverMetal" FILE="Textures\SyringeSilverMetal.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="VMDCombatStimLiquid" FILE="Textures\CombatStimLiquid.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDMedigelLiquid" FILE="Textures\MedigelLiquid.pcx" GROUP=Skins

//
// Ammo10mm, now with fixed culling
//
#exec MESH IMPORT MESH=VMDAmmo10mm ANIVFILE=Models\VMDAmmo10mm_a.3d DATAFILE=Models\VMDAmmo10mm_d.3d
#exec MESHMAP SCALE MESHMAP=VMDAmmo10mm X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDAmmo10mm SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDAmmo10mm SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=VMDAmmo10mm NUM=0 TEXTURE=Ammo10mmTex

//--------
//PICKUP!
#exec MESH IMPORT MESH=VMDSyringe ANIVFILE=MODELS\VMDSyringe_a.3d DATAFILE=MODELS\VMDSyringe_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDSyringe X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=VMDSyringe SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSyringe SEQ=VMDSyringe STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDSyringe MESH=VMDSyringe
#exec MESHMAP SCALE MESHMAP=VMDSyringe X=0.01624270725 Y=0.01624270725 Z=0.01624270725

//#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=0 TEXTURE=07WindOpacStrek
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=0 TEXTURE=VMDSyringeMarkings
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=1 TEXTURE=VMDCombatStimLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=2 TEXTURE=VMDSyringeBlackPlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=3 TEXTURE=VMDSyringePinkPlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe NUM=4 TEXTURE=VMDSyringeSilverMetal

//--------
//3RD!
#exec MESH IMPORT MESH=VMDSyringe3rd ANIVFILE=MODELS\VMDSyringe_a.3d DATAFILE=MODELS\VMDSyringe_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDSyringe3rd X=75 Y=-25 Z=-200 PITCH=112 ROLL=0 YAW=16 //23 > 16, 128 - 16 = 112

#exec MESH SEQUENCE MESH=VMDSyringe3rd SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSyringe3rd SEQ=VMDSyringe STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDSyringe3rd MESH=VMDSyringe3rd
#exec MESHMAP SCALE MESHMAP=VMDSyringe3rd X=0.01624270725 Y=0.01624270725 Z=0.01624270725

//#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=0 TEXTURE=07WindOpacStrek
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=0 TEXTURE=VMDSyringeMarkings
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=1 TEXTURE=VMDCombatStimLiquid
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=2 TEXTURE=VMDSyringeBlackPlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=3 TEXTURE=VMDSyringePinkPlastic
#exec MESHMAP SETTEXTURE MESHMAP=VMDSyringe3rd NUM=4 TEXTURE=VMDSyringeSilverMetal

defaultproperties
{
}
