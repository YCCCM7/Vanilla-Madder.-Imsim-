//=============================================================================
// VMDPoisonScout.
//=============================================================================
class VMDPoisonScout extends VMDBufferPawn;

var int NumPoisonPoints, OriginalPointIndex, CurPointTraversed;
var float PoisonDumpDist;
var Vector PoisonPoints[32];
var VMDFakePathNode FakeNode;

function PostBeginPlay()
{
	if (Owner == None)
	{
		Destroy();
		return;
	}
	
	SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight);
	
	Super.PostBeginPlay();
}

function Vector GetPoisonPoint(int FetchIndex)
{
	return PoisonPoints[FetchIndex];
}

function PlayFootStep()
{
}

singular function DripWater(float deltaTime)
{
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
}

function SetDistress(bool bDistress)
{
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if ((Owner == None || FakeNode == None) && (!bDeleteMe))
	{
		Destroy();
		return;
	}
	
	if (NumPoisonPoints >= ArrayCount(PoisonPoints)-1)
	{
		return;
	}
	
	if (NumPoisonPoints == -1 || (VSize(FakeNode.Location - Location) < 30 && OriginalPointIndex == 0) || VSize(Location - PoisonPoints[NumPoisonPoints]) > PoisonDumpDist)
	{
		NumPoisonPoints += 1;
		PoisonPoints[NumPoisonPoints] = Location;
		
		if ((NumPoisonPoints > 0) && (VSize(FakeNode.Location - Location) < 30) && (OriginalPointIndex == 0))
		{
			OriginalPointIndex = NumPoisonPoints;
			GroundSpeed = 100;
			StartingGroundSpeed = GroundSpeed;
			Velocity = Vect(0,0,0);
			Acceleration = Vect(0,0,0);
			SetOrders('Following',, true);
		}
	}
}

defaultproperties
{
     bHidden=True
     bInsignificant=True
     bHasShadow=False
     bHateHacking=False
     bHateWeapon=False
     bHateShot=False
     bHateInjury=False
     bHateIndirectInjury=False
     bHateCarcass=False
     bHateDistress=False
     bReactFutz=False
     bReactPresence=False
     bReactLoudNoise=False
     bReactAlarm=False
     bReactShot=False
     bReactCarcass=False
     bReactDistress=False
     bReactProjectiles=False
     bFearHacking=False
     bFearWeapon=False
     bFearShot=False
     bFearInjury=False
     bFearIndirectInjury=False
     bFearCarcass=False
     bFearDistress=False
     bFearAlarm=False
     bFearProjectiles=False
     UnderWaterTime=0.000000
     Mass=0.000000
     Buoyancy=0.000000
     SmellTypes(0)=
     SmellTypes(1)=
     SmellTypes(2)=
     SmellTypes(3)=
     SmellTypes(4)=
     SmellTypes(5)=
     SmellTypes(6)=
     SmellTypes(7)=
     SmellTypes(8)=
     SmellTypes(9)=
     bStasis=False
     bCanBleed=False
     bCanOpenDoors=False
     bInvincible=True
     NumPoisonPoints=-1
     PoisonDumpDist=120.000000
     bBlockPlayers=False
     bBlockActors=False
     bCollideActors=False
     bProjTarget=False
     CarcassType=Class'DeusEx.Male1Carcass'
     WalkingSpeed=1.000000
     walkAnimMult=1.000000
     GroundSpeed=2000.000000
     DrawType=DT_None
     Mesh=LodMesh'TranscendedModels.TransGM_DressShirt_F'
     MultiSkins(0)=Texture'SolidGreen'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(3)=Texture'SolidGreen'
     MultiSkins(4)=Texture'SolidGreen'
     MultiSkins(5)=Texture'SolidGreen'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=0.000000
     CollisionHeight=47.500000
     BindName=""
     FamiliarName=""
     UnfamiliarName=""
     Orders=RunningTo
}
