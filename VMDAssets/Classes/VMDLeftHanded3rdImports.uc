//=============================================================================
// Rebuild imports for: DeusExItems
//=============================================================================
class VMDLeftHanded3rdImports extends VMDSimImportsParent abstract;

//-----------------------------------------------------------------------------
// Load package dependencies
//-----------------------------------------------------------------------------
#exec OBJ LOAD FILE=Effects

// 3rd person version
#exec MESH IMPORT MESH=GEPGun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\GEPGun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\GEPGun3rdLeft_d.3d
#exec MESH ORIGIN MESH=GEPGun3rdLeft X=0 Y=0 Z=0 ROLL=64 PITCH=26
#exec MESHMAP SCALE MESHMAP=GEPGun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=GEPGun3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=GEPGun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=GEPGun3rdLeft NUM=0 TEXTURE=GEPGun3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=Glock3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Glock3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Glock3rdLeft_d.3d
#exec MESH ORIGIN MESH=Glock3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Glock3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Glock3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=4
#exec MESH SEQUENCE MESH=Glock3rdLeft SEQ=Still		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glock3rdLeft SEQ=Shoot		STARTFRAME=1	NUMFRAMES=3	RATE=17

#exec MESHMAP SETTEXTURE MESHMAP=Glock3rdLeft NUM=0 TEXTURE=Glock3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=Glock3rdLeft NUM=1 TEXTURE=Glock3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=Glock3rdLeft NUM=2 TEXTURE=BlackMaskTex


// 3rd person version
#exec MESH IMPORT MESH=SniperRifle3rdLeft ANIVFILE=Models\LeftHanded3rdImports\SniperRifle3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\SniperRifle3rdLeft_d.3d
#exec MESH ORIGIN MESH=SniperRifle3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=SniperRifle3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=SniperRifle3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=SniperRifle3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=SniperRifle3rdLeft NUM=0 TEXTURE=SniperRifle3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=CombatKnife3rdLeft ANIVFILE=Models\LeftHanded3rdImports\CombatKnife3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\CombatKnife3rdLeft_d.3d
#exec MESH ORIGIN MESH=CombatKnife3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=CombatKnife3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=CombatKnife3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=CombatKnife3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=CombatKnife3rdLeft NUM=0 TEXTURE=CombatKnife3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=Crowbar3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Crowbar3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Crowbar3rdLeft_d.3d
#exec MESH ORIGIN MESH=Crowbar3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Crowbar3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Crowbar3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Crowbar3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Crowbar3rdLeft NUM=0 TEXTURE=Crowbar3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=StealthPistol3rdLeft ANIVFILE=Models\LeftHanded3rdImports\StealthPistol3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\StealthPistol3rdLeft_d.3d
#exec MESH ORIGIN MESH=StealthPistol3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=StealthPistol3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=StealthPistol3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=StealthPistol3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=StealthPistol3rdLeft NUM=0 TEXTURE=StealthPistol3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=Prod3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Prod3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Prod3rdLeft_d.3d
#exec MESH ORIGIN MESH=Prod3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Prod3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Prod3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Prod3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Prod3rdLeft NUM=0 TEXTURE=Prod3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=HideAGun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\HideAGun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\HideAGun3rdLeft_d.3d
#exec MESH ORIGIN MESH=HideAGun3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=HideAGun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=HideAGun3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=HideAGun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=HideAGun3rdLeft NUM=0 TEXTURE=HideAGun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=HideAGun3rdLeft NUM=1 TEXTURE=HideAGun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=HideAGun3rdLeft NUM=2 TEXTURE=BlackMaskTex


// 3rd person version
#exec MESH IMPORT MESH=AssaultGun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\AssaultGun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\AssaultGun3rdLeft_d.3d
#exec MESH ORIGIN MESH=AssaultGun3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=AssaultGun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=AssaultGun3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=AssaultGun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=AssaultGun3rdLeft NUM=0 TEXTURE=AssaultGun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=AssaultGun3rdLeft NUM=1 TEXTURE=AssaultGun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=AssaultGun3rdLeft NUM=2 TEXTURE=BlackMaskTex


// 3rd person version
#exec MESH IMPORT MESH=LAW3rdLeft ANIVFILE=Models\LeftHanded3rdImports\LAW3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\LAW3rdLeft_d.3d
#exec MESH ORIGIN MESH=LAW3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=LAW3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=LAW3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=LAW3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=LAW3rdLeft NUM=0 TEXTURE=LAW3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=LAM3rdLeft ANIVFILE=Models\LeftHanded3rdImports\LAM3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\LAM3rdLeft_d.3d
#exec MESH ORIGIN MESH=LAM3rdLeft X=0 Y=0 Z=0 YAW=128 PITCH=26
#exec MESHMAP SCALE MESHMAP=LAM3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=LAM3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=LAM3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=LAM3rdLeft SEQ=Open	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=LAM3rdLeft NUM=0 TEXTURE=LAM3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=LAM3rdLeft NUM=1 TEXTURE=LAM3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=PepperGun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\PepperGun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\PepperGun3rdLeft_d.3d
#exec MESH ORIGIN MESH=PepperGun3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=PepperGun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=PepperGun3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=PepperGun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=PepperGun3rdLeft NUM=0 TEXTURE=PepperGun3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=Flamethrower3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Flamethrower3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Flamethrower3rdLeft_d.3d
#exec MESH ORIGIN MESH=Flamethrower3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Flamethrower3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Flamethrower3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Flamethrower3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Flamethrower3rdLeft NUM=0 TEXTURE=Flamethrower3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=MiniCrossbow3rdLeft ANIVFILE=Models\LeftHanded3rdImports\MiniCrossbow3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\MiniCrossbow3rdLeft_d.3d
#exec MESH ORIGIN MESH=MiniCrossbow3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=MiniCrossbow3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=MiniCrossbow3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=MiniCrossbow3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=MiniCrossbow3rdLeft NUM=0 TEXTURE=MiniCrossbow3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=Shotgun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Shotgun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Shotgun3rdLeft_d.3d
#exec MESH ORIGIN MESH=Shotgun3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Shotgun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Shotgun3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Shotgun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Shotgun3rdLeft NUM=0 TEXTURE=Shotgun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=Shotgun3rdLeft NUM=1 TEXTURE=Shotgun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=Shotgun3rdLeft NUM=2 TEXTURE=BlackMaskTex


// 3rd person version
#exec MESH IMPORT MESH=AssaultShotgun3rdLeft ANIVFILE=Models\LeftHanded3rdImports\AssaultShotgun3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\AssaultShotgun3rdLeft_d.3d
#exec MESH ORIGIN MESH=AssaultShotgun3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=AssaultShotgun3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=AssaultShotgun3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=AssaultShotgun3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=AssaultShotgun3rdLeft NUM=0 TEXTURE=AssaultShotgun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=AssaultShotgun3rdLeft NUM=1 TEXTURE=AssaultShotgun3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=AssaultShotgun3rdLeft NUM=2 TEXTURE=BlackMaskTex


// 3rd person version
#exec MESH IMPORT MESH=PlasmaRifle3rdLeft ANIVFILE=Models\LeftHanded3rdImports\PlasmaRifle3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\PlasmaRifle3rdLeft_d.3d
#exec MESH ORIGIN MESH=PlasmaRifle3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=PlasmaRifle3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=PlasmaRifle3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=3
#exec MESH SEQUENCE MESH=PlasmaRifle3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=PlasmaRifle3rdLeft SEQ=Shoot	STARTFRAME=1	NUMFRAMES=2 RATE=7

#exec MESHMAP SETTEXTURE MESHMAP=PlasmaRifle3rdLeft NUM=0 TEXTURE=PlasmaRifle3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=PlasmaRifle3rdLeft NUM=1 TEXTURE=Effects.Fire.Wepn_PRifle_SFX

// 3rd person version
#exec MESH IMPORT MESH=VMDPlasmaRifle3rd ANIVFILE=Models\LeftHanded3rdImports\VMDPlasmaRifle3rd_a.3d DATAFILE=Models\LeftHanded3rdImports\VMDPlasmaRifle3rd_d.3d
#exec MESH ORIGIN MESH=VMDPlasmaRifle3rd X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=VMDPlasmaRifle3rd X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDPlasmaRifle3rd SEQ=All		STARTFRAME=0	NUMFRAMES=3
#exec MESH SEQUENCE MESH=VMDPlasmaRifle3rd SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDPlasmaRifle3rd SEQ=Shoot	STARTFRAME=1	NUMFRAMES=2 RATE=7

#exec MESHMAP SETTEXTURE MESHMAP=VMDPlasmaRifle3rd NUM=0 TEXTURE=PlasmaRifle3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=VMDPlasmaRifle3rd NUM=1 TEXTURE=Effects.Fire.Wepn_PRifle_SFX


// 3rd person version
#exec MESH IMPORT MESH=Sword3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Sword3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Sword3rdLeft_d.3d
#exec MESH ORIGIN MESH=Sword3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Sword3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Sword3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=3
#exec MESH SEQUENCE MESH=Sword3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Sword3rdLeft SEQ=On	STARTFRAME=1	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Sword3rdLeft SEQ=Off	STARTFRAME=2	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Sword3rdLeft NUM=0 TEXTURE=Sword3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=NanoSword3rdLeft ANIVFILE=Models\LeftHanded3rdImports\NanoSword3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\NanoSword3rdLeft_d.3d
#exec MESH ORIGIN MESH=NanoSword3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=NanoSword3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=NanoSword3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=7
#exec MESH SEQUENCE MESH=NanoSword3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=NanoSword3rdLeft SEQ=On	STARTFRAME=1	NUMFRAMES=3		RATE=3
#exec MESH SEQUENCE MESH=NanoSword3rdLeft SEQ=Off	STARTFRAME=4	NUMFRAMES=3		RATE=3

#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=0 TEXTURE=NanoSword3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=1 TEXTURE=Effects.Electricity.WavyBlade
#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=2 TEXTURE=NanoSword3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=3 TEXTURE=NanoSword3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=4 TEXTURE=Effects.Electricity.WEPN_NESword_SFX
#exec MESHMAP SETTEXTURE MESHMAP=NanoSword3rdLeft NUM=5 TEXTURE=Effects.Electricity.Nano_SFX_A


// 3rd person version
#exec MESH IMPORT MESH=Shuriken3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Shuriken3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Shuriken3rdLeft_d.3d
#exec MESH ORIGIN MESH=Shuriken3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Shuriken3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Shuriken3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Shuriken3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Shuriken3rdLeft NUM=0 TEXTURE=Shuriken3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=EMPGrenade3rdLeft ANIVFILE=Models\LeftHanded3rdImports\EMPGrenade3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\EMPGrenade3rdLeft_d.3d
#exec MESH ORIGIN MESH=EMPGrenade3rdLeft X=0 Y=0 Z=0 YAW=128 PITCH=26
#exec MESHMAP SCALE MESHMAP=EMPGrenade3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=EMPGrenade3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=2
#exec MESH SEQUENCE MESH=EMPGrenade3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=EMPGrenade3rdLeft SEQ=Open		STARTFRAME=1	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=EMPGrenade3rdLeft NUM=0 TEXTURE=Effects.Electricity.WEPN_EMPG_SFX
#exec MESHMAP SETTEXTURE MESHMAP=EMPGrenade3rdLeft NUM=1 TEXTURE=EMPGrenade3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=GasGrenade3rdLeft ANIVFILE=Models\LeftHanded3rdImports\GasGrenade3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\GasGrenade3rdLeft_d.3d
#exec MESH ORIGIN MESH=GasGrenade3rdLeft X=0 Y=0 Z=0 YAW=128 PITCH=26
#exec MESHMAP SCALE MESHMAP=GasGrenade3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=GasGrenade3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasGrenade3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasGrenade3rdLeft SEQ=Open		STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=GasGrenade3rdLeft NUM=0 TEXTURE=GasGrenade3rdTex1


// 3rd person version
#exec MESH IMPORT MESH=NanoVirusGrenade3rdLeft ANIVFILE=Models\LeftHanded3rdImports\NanoVirusGrenade3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\NanoVirusGrenade3rdLeft_d.3d
#exec MESH ORIGIN MESH=NanoVirusGrenade3rdLeft X=0 Y=0 Z=0 YAW=128 PITCH=26
#exec MESHMAP SCALE MESHMAP=NanoVirusGrenade3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=NanoVirusGrenade3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=3
#exec MESH SEQUENCE MESH=NanoVirusGrenade3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=NanoVirusGrenade3rdLeft SEQ=Open	STARTFRAME=1	NUMFRAMES=1
#exec MESH SEQUENCE MESH=NanoVirusGrenade3rdLeft SEQ=Closed	STARTFRAME=2	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=NanoVirusGrenade3rdLeft NUM=0 TEXTURE=NanoVirusGrenade3rdTex1
#exec MESHMAP SETTEXTURE MESHMAP=NanoVirusGrenade3rdLeft NUM=1 TEXTURE=Effects.Electricity.Nano_SFX


// 3rd person version
#exec MESH IMPORT MESH=Baton3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Baton3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Baton3rdLeft_d.3d
#exec MESH ORIGIN MESH=Baton3rdLeft X=0 Y=0 Z=0 PITCH=26
#exec MESHMAP SCALE MESHMAP=Baton3rdLeft X=0.00390625 Y=-0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Baton3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=5
#exec MESH SEQUENCE MESH=Baton3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Baton3rdLeft SEQ=Close	STARTFRAME=1	NUMFRAMES=2		RATE=4
#exec MESH SEQUENCE MESH=Baton3rdLeft SEQ=Open	STARTFRAME=3	NUMFRAMES=2		RATE=4

#exec MESHMAP SETTEXTURE MESHMAP=Baton3rdLeft NUM=0 TEXTURE=Baton3rdTex1

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//
// Multitool3rd
//
#exec MESH IMPORT MESH=Multitool3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Multitool3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Multitool3rdLeft_d.3d UNMIRROR=1
#exec MESH ORIGIN MESH=Multitool3rdLeft X=0 Y=0 Z=0 PITCH=32
#exec MESHMAP SCALE MESHMAP=Multitool3rdLeft X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=Still		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=Select	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=Idle1		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=Idle2		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Multitool3rdLeft SEQ=Idle3		STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Multitool3rdLeft NUM=0 TEXTURE=MultitoolTex1

//
// VMDLockpick
//
#exec MESH IMPORT MESH=VMDLockpick ANIVFILE=Models\LeftHanded3rdImports\VMDLockpick_a.3d DATAFILE=Models\LeftHanded3rdImports\VMDLockpick_d.3d ZEROTEX=1 UNMIRROR=1
#exec MESHMAP SCALE MESHMAP=VMDLockpick X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=Still		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=Select	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=Idle1		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=Idle2		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick SEQ=Idle3		STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=VMDLockpick NUM=0 TEXTURE=LockpickTex1

//
// VMDLockpick3rd
//
#exec MESH IMPORT MESH=VMDLockpick3rd ANIVFILE=Models\LeftHanded3rdImports\VMDLockpick3rd_a.3d DATAFILE=Models\LeftHanded3rdImports\VMDLockpick3rd_d.3d
#exec MESH ORIGIN MESH=VMDLockpick3rd X=0 Y=0 Z=0 PITCH=-64
#exec MESHMAP SCALE MESHMAP=VMDLockpick3rd X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=Select	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=Idle1	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=Idle2	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=VMDLockpick3rd SEQ=Idle3	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=VMDLockpick3rd NUM=0 TEXTURE=LockpickTex1

//
// Lockpick3rdLeft
//
#exec MESH IMPORT MESH=Lockpick3rdLeft ANIVFILE=Models\LeftHanded3rdImports\Lockpick3rdLeft_a.3d DATAFILE=Models\LeftHanded3rdImports\Lockpick3rdLeft_d.3d UNMIRROR=1
#exec MESH ORIGIN MESH=Lockpick3rdLeft X=0 Y=0 Z=0 PITCH=-64
#exec MESHMAP SCALE MESHMAP=Lockpick3rdLeft X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=Select	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=Idle1	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=Idle2	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lockpick3rdLeft SEQ=Idle3	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=Lockpick3rdLeft NUM=0 TEXTURE=LockpickTex1

//
// NanoKeyRingLeft
//
#exec MESH IMPORT MESH=NanoKeyRingLeft ANIVFILE=Models\LeftHanded3rdImports\NanoKeyRing_a.3d DATAFILE=Models\LeftHanded3rdImports\NanoKeyRing_d.3d UNMIRROR=1
#exec MESHMAP SCALE MESHMAP=NanoKeyRingLeft X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=NanoKeyRingLeft SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=NanoKeyRingLeft SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec MESHMAP SETTEXTURE MESHMAP=NanoKeyRing NUM=0 TEXTURE=NanoKeyRingTex1

defaultproperties
{
}
