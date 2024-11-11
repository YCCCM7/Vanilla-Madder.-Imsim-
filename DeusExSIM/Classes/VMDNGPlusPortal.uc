//=============================================================================
// VMDNGPlusPortal
//=============================================================================
class VMDNGPlusPortal extends VMDSurrealDeco;

#exec OBJ LOAD FILE=VMDDrugFX
#exec OBJ LOAD FILE=Ambient

var bool bBobDown;
var float SpinRate, BobRate, BobHeight, CurBobHeight;

var bool bFatnessIn;
var byte FatnessMin, FatnessMax;
var float CurFatness, FatnessChangeRate;

var bool bOpening, bClosing;
var int FatnessDifference, YawDifference;
var int StartingFatness, StartingYaw;
var float OpenProgress, ColorHue;
var Texture PortalFXTextures[4];

var name FlagRequired;

var Mover CampMovers[3];
var int CampMoverFrames[3];

function BeginPlay()
{
	local int TSeed;
	
	Super.BeginPlay();
	
	SetTimer(0.5, True);
	
	StartingFatness = Fatness;
	StartingYaw = Rotation.Yaw;
	
	TSeed = class'VMDStaticFunctions'.Static.StripBaseActorSeed(Self) % 4;
	Multiskins[4] = PortalFXTextures[TSeed];
}

function Timer()
{
	local int NumWins;
	local FlagBase FB;
	local VMDBufferPlayer VMP;
	
	bHidden = true;
	
	forEach AllActors(class'VMDBufferPlayer', VMP)
	{
		FB = VMP.FlagBase;
		if (FlagRequired == '' || (FB != None && FB.GetBool(FlagRequired)))
		{
			NumWins++;
		}
		if (CampMovers[0] == None || CampMovers[0].KeyNum == CampMoverFrames[0])
		{
			NumWins++;
		}
		if (CampMovers[1] == None || CampMovers[1].KeyNum == CampMoverFrames[1])
		{
			NumWins++;
		}
		if (CampMovers[2] == None || CampMovers[2].KeyNum == CampMoverFrames[2])
		{
			NumWins++;
		}
		bHidden = (NumWins < 4);
		
		if (!bHidden)
		{
			if (VSize(VMP.Location - Location) < 160)
			{
				if ((!bOpening) && (!bClosing) && (Mesh == LODMesh'VMDHallucination'))
				{
					Mesh = LODMesh'VMDNGPortal';
					FatnessDifference = Fatness - StartingFatness;
					SetCollisionSize(20, 20);
					YawDifference = (Rotation.Yaw % 65536) - StartingYaw;
					bOpening = true;
					PlayAnim('PortalOpen');
					PlaySound(Sound'VMDPortalOpen');
				}
			}
			else
			{
				if ((!bClosing) && (!bOpening) && (Mesh == LODMesh'VMDNGPortal'))
				{
					bClosing = true;
					PlayAnim('PortalClose');
					PlaySound(Sound'VMDPortalClose');
				}
			}
		}
	}
	
	if (bHidden)
	{
		SetCollision(False, False, False);
		SoundRadius = 0;
		SoundVolume = 0;
		LightBrightness = 0;
	}
	else
	{
		SetCollision(True, True, True);
		SoundRadius = 32;
		SoundVolume = 64;
		LightBrightness = 96;
	}
}

function Tick(float DT)
{
	local Rotator R;
	local Vector V;
	local float UseRate;
	
	//MADDERS, 4/3/24: We glow. Hell yeah.
	ColorHue += (DT * 90);
	if (Colorhue >= 255)
	{
		ColorHue = 0;
	}
	LightHue = Byte(ColorHue);
	
	//----------------------------
	//MADDERS: Bob behavior!
	UseRate = BobHeight*DT;
	if (BobHeight - CurBobHeight < BobHeight / 6 || CurBobHeight < BobHeight / 6) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 12 || CurBobHeight < BobHeight / 12) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 24 || CurBobHeight < BobHeight / 24) UseRate /= 2;
	
	if (!bBobDown)
	{
		if (CurBobHeight < BobHeight)
		{
			CurBobHeight += UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight > BobHeight)
			{
				V.Z -= (CurBobHeight - BobHeight);
				CurBobHeight = BobHeight;
				bBobDown = true;
			}
			SetLocation(Location + V);
 		}
 	}
	else
	{
		if (CurBobHeight > 0)
		{
			CurBobHeight -= UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight < 0)
			{
				V.Z -= (CurBobHeight);
				CurBobHeight = 0;
				bBobDown = false;
			}
			SetLocation(Location - V);
		}
	}
	
	if (bOpening)
	{
		OpenProgress += DT;
		if (OpenProgress >= 1.0)
		{
			bOpening = false;
			OpenProgress = 1.0;
			AmbientSound = Sound'EMPZone';
			SoundPitch = 64;
		}
		
		Fatness = StartingFatness + (FatnessDifference * (1.0 - OpenProgress));
		CurFatness = float(Fatness);
		
		R = Rotation;
		R.Yaw = StartingYaw + (YawDifference * (1.0 - OpenProgress));
		SetRotation(R);
	}
	else if (bClosing)
	{
		OpenProgress -= DT;
		if (OpenProgress <= 0.0)
		{
			bClosing = false;
			OpenProgress = 0.0;
			Mesh = LODMesh'VMDHallucination';
			AmbientSound = Sound'BoatLargeIdle';
			SoundPitch = 192;
			SetCollisionSize(4, 4);
		}
		
		Fatness = StartingFatness + (FatnessDifference * (1.0 - OpenProgress));
		CurFatness = float(Fatness);
		
		R = Rotation;
		R.Yaw = StartingYaw + (YawDifference * (1.0 - OpenProgress));
		SetRotation(R);
	}
	else if (Mesh == LODMesh'VMDHallucination')
	{
		//----------------------------
		//MADDERS: Spin behavior!
		R.Yaw = SpinRate*DT;
		SetRotation(Rotation + R);
		
		//----------------------------
		//MADDERS: Fatness behavior!
		if (bFatnessIn)
		{
			if (CurFatness > FatnessMin)
			{
				CurFatness -= FatnessChangeRate * DT;
				Fatness = byte(CurFatness);
			}
			else
			{
				bFatnessIn = false;
			}
		}
		else
		{
			if (CurFatness < FatnessMax)
			{
				CurFatness += FatnessChangeRate * DT;
				Fatness = byte(CurFatness);
			}
			else
			{
				bFatnessIn = true;
			}
		}
	}
	
	Super.Tick(DT);
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	if (VMDBufferPlayer(Frobber) != None)
	{
		VMDBufferPlayer(Frobber).StartNewGamePlus();
	}
}

defaultproperties
{
     PortalFXTextures(0)=Texture'VMDNGPortalFX1'
     PortalFXTextures(1)=Texture'VMDNGPortalFX2'
     PortalFXTextures(2)=Texture'VMDNGPortalFX3'
     PortalFXTextures(3)=Texture'VMDNGPortalFX4'
     
     AmbientSound=Sound'BoatLargeIdle'
     SoundPitch=192
     
     bUnlit=True
     LightType=LT_Steady
     LightBrightness=96
     LightSaturation=0
     LightHue=0
     LightRadius=5
     LightPeriod=32
     LightCone=128
     VolumeBrightness=64
     
     bHidden=True
     bDirectional=True
     FatnessMin=40
     FatnessMax=216
     FatnessChangeRate=240.000000
     CurFatness=128.000000
     SpinRate=24576
     BobRate=18.000000
     BobHeight=3.000000
     DrawScale=0.500000
     Physics=PHYS_None
     bInvincible=True
     bCanBeBase=False
     bPushable=False
     Style=STY_Normal
     ItemName="Start NG Plus?"
     Mesh=LodMesh'VMDHallucination'
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Mass=2.000000
     Buoyancy=3.000000
     ScaleGlow=2.000000
     Texture=Texture'ZymeBaseTexture'
}
