//=============================================================================
// VMDSimMagazineImports
//=============================================================================
class VMDSimMagazineImports extends VMDSimImportsParent abstract;

//=============================
//AssaultGunMag
//=============================
#exec TEXTURE IMPORT NAME="VMDAssaultGunMagTex1" FILE="Textures\AssaultGunMagTex1.pcx" GROUP=Skins

//=============================
//AssaultShotgunMag
//=============================
#exec TEXTURE IMPORT NAME="VMDAssaultShotgunMagTex1" FILE="Textures\AssaultShotgunMagTex1.pcx" GROUP=Skins

//Animation set 01
#exec MESH IMPORT MESH=VMDAssaultShotgunMag01 ANIVFILE=MODELS\AssaultShotgunMag01_a.3d DATAFILE=MODELS\AssaultShotgunMag01_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDAssaultShotgunMag01 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag01 SEQ=All              STARTFRAME=0 NUMFRAMES=6
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag01 SEQ=VMDAssaultShotgunMag01 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag01 SEQ=Drop STARTFRAME=1 NUMFRAMES=3 RATE=27
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag01 SEQ=Land STARTFRAME=4 NUMFRAMES=2 RATE=60

#exec MESHMAP NEW   MESHMAP=VMDAssaultShotgunMag01 MESH=VMDAssaultShotgunMag01
#exec MESHMAP SCALE MESHMAP=VMDAssaultShotgunMag01 X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDAssaultShotgunMag01 NUM=0 TEXTURE=VMDAssaultShotgunMagTex1

//Animation set 02
#exec MESH IMPORT MESH=VMDAssaultShotgunMag02 ANIVFILE=MODELS\AssaultShotgunMag02_a.3d DATAFILE=MODELS\AssaultShotgunMag02_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDAssaultShotgunMag02 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag02 SEQ=All              STARTFRAME=0 NUMFRAMES=7
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag02 SEQ=VMDAssaultShotgunMag02 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag02 SEQ=Drop STARTFRAME=1 NUMFRAMES=2 RATE=18
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag02 SEQ=Land STARTFRAME=3 NUMFRAMES=3 RATE=90

#exec MESHMAP NEW   MESHMAP=VMDAssaultShotgunMag02 MESH=VMDAssaultShotgunMag02
#exec MESHMAP SCALE MESHMAP=VMDAssaultShotgunMag02 X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDAssaultShotgunMag02 NUM=0 TEXTURE=VMDAssaultShotgunMagTex1

//Animation set 03
#exec MESH IMPORT MESH=VMDAssaultShotgunMag03 ANIVFILE=MODELS\AssaultShotgunMag03_a.3d DATAFILE=MODELS\AssaultShotgunMag03_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDAssaultShotgunMag03 X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag03 SEQ=All              STARTFRAME=0 NUMFRAMES=7
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag03 SEQ=VMDAssaultShotgunMag03 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag03 SEQ=Drop STARTFRAME=1 NUMFRAMES=2 RATE=18
#exec MESH SEQUENCE MESH=VMDAssaultShotgunMag03 SEQ=Land STARTFRAME=3 NUMFRAMES=7 RATE=160

#exec MESHMAP NEW   MESHMAP=VMDAssaultShotgunMag03 MESH=VMDAssaultShotgunMag02
#exec MESHMAP SCALE MESHMAP=VMDAssaultShotgunMag03 X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDAssaultShotgunMag03 NUM=0 TEXTURE=VMDAssaultShotgunMagTex1

//=============================
//FlamethrowerMag
//=============================
#exec TEXTURE IMPORT NAME="VMDFlamethrowerMagTex1" FILE="Textures\FlamethrowerMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDFlamethrowerMag ANIVFILE=MODELS\FlamethrowerMag_a.3d DATAFILE=MODELS\FlamethrowerMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDFlamethrowerMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDFlamethrowerMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDFlamethrowerMag SEQ=VMDFlamethrowerMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDFlamethrowerMag MESH=VMDFlamethrowerMag
#exec MESHMAP SCALE MESHMAP=VMDFlamethrowerMag X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDFlamethrowerMag NUM=0 TEXTURE=VMDFlamethrowerMagTex1

//=============================
//PepperGunMag
//=============================
#exec TEXTURE IMPORT NAME="VMDPepperGunMagTex1" FILE="Textures\PepperGunMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDPeppergunMag ANIVFILE=MODELS\PeppergunMag_a.3d DATAFILE=MODELS\PeppergunMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDPeppergunMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDPeppergunMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPeppergunMag SEQ=VMDPeppergunMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDPeppergunMag MESH=VMDPeppergunMag
#exec MESHMAP SCALE MESHMAP=VMDPeppergunMag X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDPeppergunMag NUM=0 TEXTURE=VMDPeppergunMagTex1

//=============================
//PistolMag
//=============================
#exec TEXTURE IMPORT NAME="VMDPistolMagTex1" FILE="Textures\PistolMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDPistolMag ANIVFILE=MODELS\PistolMag_a.3d DATAFILE=MODELS\PistolMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDPistolMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDPistolMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPistolMag SEQ=VMDPistolMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDPistolMag MESH=VMDPistolMag
#exec MESHMAP SCALE MESHMAP=VMDPistolMag X=0.0029296875 Y=0.0029296875 Z=0.0029296875

#exec MESHMAP SETTEXTURE MESHMAP=VMDPistolMag NUM=0 TEXTURE=VMDPistolMagTex1

//=============================
//PlasmaRifleMag
//=============================
#exec TEXTURE IMPORT NAME="VMDPlasmaRifleMagTex1" FILE="Textures\PlasmaRifleMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDPlasmaRifleMag ANIVFILE=MODELS\PlasmaRifleMag_a.3d DATAFILE=MODELS\PlasmaRifleMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDPlasmaRifleMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDPlasmaRifleMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPlasmaRifleMag SEQ=VMDPlasmaRifleMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDPlasmaRifleMag MESH=VMDPlasmaRifleMag
#exec MESHMAP SCALE MESHMAP=VMDPlasmaRifleMag X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDPlasmaRifleMag NUM=0 TEXTURE=VMDPlasmaRifleMagTex1

//=============================
//ProdMag
//=============================
#exec TEXTURE IMPORT NAME="VMDProdMagTex1" FILE="Textures\ProdMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDProdMag ANIVFILE=MODELS\ProdMag_a.3d DATAFILE=MODELS\ProdMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDProdMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDProdMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDProdMag SEQ=VMDProdMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDProdMag MESH=VMDProdMag
#exec MESHMAP SCALE MESHMAP=VMDProdMag X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDProdMag NUM=0 TEXTURE=VMDProdMagTex1

//=============================
//SniperRifleMag
//=============================
#exec TEXTURE IMPORT NAME="VMDSniperRifleMagTex1" FILE="Textures\SniperRifleMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDSniperRifleMag ANIVFILE=MODELS\SniperRifleMag_a.3d DATAFILE=MODELS\SniperRifleMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDSniperRifleMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDSniperRifleMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDSniperRifleMag SEQ=VMDSniperRifleMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDSniperRifleMag MESH=VMDSniperRifleMag
#exec MESHMAP SCALE MESHMAP=VMDSniperRifleMag X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=VMDSniperRifleMag NUM=0 TEXTURE=VMDSniperRifleMagTex1

//=============================
//StealthPistolMag
//=============================
#exec TEXTURE IMPORT NAME="VMDStealthPistolMagTex1" FILE="Textures\StealthPistolMagTex1.pcx" GROUP=Skins

#exec MESH IMPORT MESH=VMDStealthPistolMag ANIVFILE=MODELS\StealthPistolMag_a.3d DATAFILE=MODELS\StealthPistolMag_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VMDStealthPistolMag X=0 Y=0 Z=0 PITCH=0 ROLL=0 YAW=0

#exec MESH SEQUENCE MESH=VMDStealthPistolMag SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDStealthPistolMag SEQ=VMDStealthPistolMag STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=VMDStealthPistolMag MESH=VMDStealthPistolMag
#exec MESHMAP SCALE MESHMAP=VMDStealthPistolMag X=0.003515625 Y=0.003515625 Z=0.003515625

#exec MESHMAP SETTEXTURE MESHMAP=VMDStealthPistolMag NUM=0 TEXTURE=VMDStealthPistolMagTex1

defaultproperties
{
}
