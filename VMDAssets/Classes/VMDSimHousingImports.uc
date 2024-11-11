//=============================================================================
// VMDSimHousingImports
//=============================================================================
class VMDSimHousingImports extends VMDSimImportsParent abstract;

//=============================
//FOOD STUFF!
//=============================
#exec TEXTURE IMPORT NAME="FoodWarpGreen" FILE="Textures\FoodWarpMapTex.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="FoodWarpBlue" FILE="Textures\FoodWarpEnviroTex.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="FoodWarpTooltip" FILE="Textures\FoodWarpTooltip.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="HDFoodWarpTooltipA" FILE="Textures\HDFoodWarpTooltipA.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="HDFoodWarpTooltipB" FILE="Textures\HDFoodWarpTooltipB.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="HDFoodWarpTooltipC" FILE="Textures\HDFoodWarpTooltipC.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="HDFoodWarpTooltipD" FILE="Textures\HDFoodWarpTooltipD.pcx" GROUP=Skins

//Soda can-ish
#exec MESH IMPORT MESH=FoodWarpCan ANIVFILE=MODELS\VMDFoodWarp_a.3d DATAFILE=MODELS\VMDFoodWarp_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FoodWarpCan X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=FoodWarpCan SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=FoodWarpCan SEQ=FoodWarpCan STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=FoodWarpCan MESH=FoodWarpCan
#exec MESHMAP SCALE MESHMAP=FoodWarpCan X=0.019 Y=0.019 Z=0.019 //0.023

#exec MESHMAP SETTEXTURE MESHMAP=FoodWarpCan NUM=0 TEXTURE=FoodWarpGreen

//Soy packet-ish
#exec MESH IMPORT MESH=FoodWarpPacket ANIVFILE=MODELS\VMDFoodWarp2_a.3d DATAFILE=MODELS\VMDFoodWarp2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FoodWarpPacket X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=FoodWarpPacket SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=FoodWarpPacket SEQ=FoodWarpPacket STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=FoodWarpPacket MESH=FoodWarpPacket
#exec MESHMAP SCALE MESHMAP=FoodWarpPacket X=0.021 Y=0.021 Z=0.021

#exec MESHMAP SETTEXTURE MESHMAP=FoodWarpPacket NUM=0 TEXTURE=FoodWarpGreen

//Candy bar-ish
#exec MESH IMPORT MESH=FoodWarpBar ANIVFILE=MODELS\VMDFoodWarp3_a.3d DATAFILE=MODELS\VMDFoodWarp3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FoodWarpBar X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=FoodWarpBar SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=FoodWarpBar SEQ=FoodWarpBar STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=FoodWarpBar MESH=FoodWarpBar
#exec MESHMAP SCALE MESHMAP=FoodWarpBar X=0.016 Y=0.016 Z=0.016

#exec MESHMAP SETTEXTURE MESHMAP=FoodWarpBar NUM=0 TEXTURE=FoodWarpGreen

//=============================
//PAINT WARP STUFF!
//=============================
#exec TEXTURE IMPORT NAME="PaintWarpYellow" FILE="Textures\PaintWarpMapTex.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="PaintWarpOrange" FILE="Textures\PaintWarpEnviroTex.pcx" GROUP=Skins

#exec TEXTURE IMPORT NAME="PaintWarpTooltip" FILE="Textures\PaintWarpTooltip.pcx" GROUP=Skins

//It's a brush.
#exec MESH IMPORT MESH=PaintWarpBrush ANIVFILE=MODELS\VMDPaintWarp_a.3d DATAFILE=MODELS\VMDPaintWarp_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PaintWarpBrush X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=PaintWarpBrush SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=PaintWarpBrush SEQ=PaintWarpBrush STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=PaintWarpBrush MESH=PaintWarpBrush
#exec MESHMAP SCALE MESHMAP=PaintWarpBrush X=0.019 Y=0.019 Z=0.019 //0.023

#exec MESHMAP SETTEXTURE MESHMAP=PaintWarpBrush NUM=0 TEXTURE=PaintWarpYellow

//=============================
//TIP STUFF!
//=============================

//House tip, square
#exec MESH IMPORT MESH=HousingTipSquareHD ANIVFILE=MODELS\VMDHousingTipSquare_a.3d DATAFILE=MODELS\VMDHousingTipSquare_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=HousingTipSquareHD X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=HousingTipSquareHD SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HousingTipSquareHD SEQ=HousingTipSquareHD STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=HousingTipSquareHD MESH=HousingTipSquareHD
#exec MESHMAP SCALE MESHMAP=HousingTipSquareHD X=0.02 Y=0.02 Z=0.02

#exec MESHMAP SETTEXTURE MESHMAP=HousingTipSquareHD NUM=0 TEXTURE=HDFoodWarpTooltipA
#exec MESHMAP SETTEXTURE MESHMAP=HousingTipSquareHD NUM=1 TEXTURE=HDFoodWarpTooltipB
#exec MESHMAP SETTEXTURE MESHMAP=HousingTipSquareHD NUM=2 TEXTURE=HDFoodWarpTooltipC
#exec MESHMAP SETTEXTURE MESHMAP=HousingTipSquareHD NUM=3 TEXTURE=HDFoodWarpTooltipD

//House tip, square
#exec MESH IMPORT MESH=HousingTipSquare ANIVFILE=MODELS\VMDHousingTipSquareLowDef_a.3d DATAFILE=MODELS\VMDHousingTipSquareLowDef_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=HousingTipSquare X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=64

#exec MESH SEQUENCE MESH=HousingTipSquare SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HousingTipSquare SEQ=HousingTipSquare STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=HousingTipSquare MESH=HousingTipSquare
#exec MESHMAP SCALE MESHMAP=HousingTipSquare X=0.02 Y=0.02 Z=0.02

#exec MESHMAP SETTEXTURE MESHMAP=HousingTipSquare NUM=0 TEXTURE=FoodWarpTooltip

//=============================
//DECO STUFF!
//=============================

#exec OBJ LOAD FILE=CoreTexWater

//Water level actor
#exec MESH IMPORT MESH=VMDWaterLevelActor ANIVFILE=MODELS\VMDWaterLevelActor_a.3d DATAFILE=MODELS\VMDWaterLevelActor_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDWaterLevelActor X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDWaterLevelActor SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDWaterLevelActor SEQ=VMDWaterLevelActor STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDWaterLevelActor MESH=VMDWaterLevelActor
#exec MESHMAP SCALE MESHMAP=VMDWaterLevelActor X=0.020000 Y=0.020000 Z=0.020000

#exec MESHMAP SETTEXTURE MESHMAP=VMDWaterLevelActor NUM=0 TEXTURE=BlueWater

//Bath bubble
#exec TEXTURE IMPORT NAME="VMDBubbleGloss" FILE="Textures\BubbleGloss.pcx" GROUP=Skins
#exec TEXTURE IMPORT NAME="VMDBubbleGray" FILE="Textures\BubbleGray.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDBathBubble ANIVFILE=MODELS\VMDBathBubble_a.3d DATAFILE=MODELS\VMDBathBubble_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDBathBubble X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDBathBubble SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDBathBubble SEQ=VMDBathBubble STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDBathBubble MESH=VMDBathBubble
#exec MESHMAP SCALE MESHMAP=VMDBathBubble X=0.020000 Y=0.020000 Z=0.020000

#exec MESHMAP SETTEXTURE MESHMAP=VMDBathBubble NUM=0 TEXTURE=VMDBubbleGray

//=============================
//LIST STUFF!
//=============================

#exec TEXTURE IMPORT NAME="VMDHousingFoodListWindowBG01" FILE="Textures\VMDHousingFoodListWindowBG01.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingFoodListWindowBG02" FILE="Textures\VMDHousingFoodListWindowBG02.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="VMDHousingPaintWindowBG01" FILE="Textures\VMDHousingPaintWindowBG01.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingPaintWindowBG02" FILE="Textures\VMDHousingPaintWindowBG02.pcx" GROUP=UI FLAGS=2

#exec TEXTURE IMPORT NAME="VMDHousingListTile0" FILE="Textures\VMDHousingListTile0.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingListTile1" FILE="Textures\VMDHousingListTile1.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingListTile2" FILE="Textures\VMDHousingListTile2.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingListTile0Highlight" FILE="Textures\VMDHousingListTile0Highlight.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingListTile1Highlight" FILE="Textures\VMDHousingListTile1Highlight.pcx" GROUP=UI FLAGS=2
#exec TEXTURE IMPORT NAME="VMDHousingListTile2Highlight" FILE="Textures\VMDHousingListTile2Highlight.pcx" GROUP=UI FLAGS=2

defaultproperties
{
}
