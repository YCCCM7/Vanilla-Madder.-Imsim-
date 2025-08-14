//=============================================================================
// VMDLadderPointAdder.
// We're just here to cram some ladder points into levels.
// Not all ladders are covered, as not all are good candidates.
//=============================================================================
class VMDLadderPointAdder extends VMDFillerActors;

var float FixTimer;
var bool bRanFixes;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var travel bool bRevisionMapSet;

//MADDERS, 11/10/24: Dynamic path rebuilding. Thanks, Aizome.
var bool bRebuilding;
var int RebuildProgress;
var Pawn TScout;
var VMDPathRebuilder VMDPR;

//MADDERS, 5/9/25: These are now vars to make inheritance easier.
var bool bRebuildRequired;
var int GM, i;
var string MN;
var Vector TSpacing;

var Actor A;
var DeusExLevelInfo LI;
var VMDBufferPawn VMBP;
var class<VMDStaticFunctions> SF;

function VMDUpdateRevisionMapStatus()
{
	switch(class'VMDStaticFunctions'.static.GetIntendedMapStyle(Self))
	{
		case 0:
			bRevisionMapSet = false;
		break;
		case 1:
			bRevisionMapSet = true;
		break;
		case 2:
			bRevisionMapSet = false;
		break;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	VMDUpdateRevisionMapStatus();
	AddLadderPoints();
	PostAddLadderPoints();
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (bRebuilding)
	{
		if (RebuildProgress < 1)
		{
			RebuildProgress += 1;
		}
		else
		{
			FinishRebuild();
		}
	}
}

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	SF = class'VMDStaticFunctions';
	
 	forEach AllActors(Class'DeusExLevelInfo', LI) break;
	if (LI == None)
	{
		return;
	}
	
	GM = LI.MissionNumber;
	if (GM > 98)
	{
		Lifespan = 1;
		return;
	}
	MN = CAPS(LI.MapName);
}

function PostAddLadderPoints()
{
	if (bRebuildRequired)
	{
		InitiateRebuild();
	}
	
	bRanFixes = true;
}

function InitiateRebuild()
{
	local int i;
	local Mover TMover;
	local NavigationPoint TPoint;
	local VMDConsole VC;
	
	VMDPR = Spawn(class'VMDPathRebuilder');
	if (VMDPR == None) return;
	
	VMDPR.AllowScoutToSpawn();
	
	forEach AllActors(class'Mover', TMover)
	{
		TMover.SetLocation(TMover.Location + Vect(0,0,10000));
	}
	
	forEach AllActors(class'NavigationPoint', TPoint)
	{
		TPoint.RouteCache = None;
		for(i=0; i<ArrayCount(TPoint.VisNoReachPaths); i++)
		{
			TPoint.upstreamPaths[i] = 0;
			TPoint.Paths[i] = 0;
			TPoint.PrunedPaths[i] = 0;
			TPoint.VisNoReachPaths[i] = None;
		}
	}
	forEach AllActors(class'NavigationPoint', TPoint)
	{
		TScout = Spawn(class'Scout',,, TPoint.Location);
		if (TScout != None)
		{
			break;
		}
	}
	
	if (TScout == None)
	{
		VMDPR.Destroy();
		return;
	}
	
	forEach AllObjects(class'VMDConsole', VC)
	{
		VC.bExpandingLadders = true;
		break;
	}
	
	bRebuilding = true;
	RebuildProgress = 0;
}

function FinishRebuild()
{
	local Actor TAct, CollisionHoes[2048];
	local int i, NumHoes, CollisionFlags[2048];
	local VMDConsole VC;
	
	forEach AllActors(class'Actor', TAct)
	{
		if (Decoration(TAct) != None || ScriptedPawn(TAct) != None || Keypoint(TAct) != None || Mover(TAct) != None)
		{
			CollisionHoes[NumHoes] = TAct;
			CollisionFlags[NumHoes] = (int(TAct.bCollideActors) * 1) + (int(TAct.bBlockActors) * 2) + (int(TAct.bBlockPlayers) * 4);
			TAct.SetCollision(False, False, False);
			NumHoes++;
		}
	}
	
	VMDPR.ScoutSetup(TScout);
	VMDPR.RedefinePaths();
	
	TScout.Destroy();
	VMDPR.Destroy();
	
	for(i=0; i<NumHoes; i++)
	{
		CollisionHoes[i].SetCollision(bool(CollisionFlags[i] & 1), bool(CollisionFlags[i] & 2), bool(CollisionFlags[i] & 4));
		if (Mover(CollisionHoes[i]) != None)
		{
			CollisionHoes[i].SetLocation(CollisionHoes[i].Location - Vect(0,0,10000));
		}
	}
	
	forEach AllObjects(class'VMDConsole', VC)
	{
		VC.bExpandingLadders = false;
		break;
	}
	
	bRebuilding = false;
	RebuildProgress = 0;
}

function AddLadderGroup(Vector LadderNormal, Vector Point1, Vector Point2, optional Vector Point3, optional Vector Point4, optional int JumpFlags, optional float JumpZMult, optional float StartJumpZMult, optional float EndJumpZMult, optional DeusExMover OpenMoverRequired)
{
	local bool bStartNextJump, bStartPreviousJump, bEndNextJump, bEndPreviousJump, bAllNextJump, bAllPreviousJump, bStartOnly, bEndOnly;
	local int i, ListSize, PointMash[4];
	local Vector BlankVect, Points[4];
	local VMDLadderPoint LP[4], Last;
	
	bStartNextJump = bool(JumpFlags & 1);
	bStartPreviousJump = bool(JumpFlags & 2);
	bEndNextJump = bool(JumpFlags & 4);
	bEndPreviousJump = bool(JumpFlags & 8);
	bAllNextJump = bool(JumpFlags & 16);
	bAllPreviousJump = bool(JumpFlags & 32);
	
	bStartOnly = bool(JumpFlags & 64);
	bEndOnly = bool(JumpFlags & 128);
	
	PointMash[0] = (JumpFlags & 256);
	PointMash[1] = (JumpFlags & 512);
	PointMash[2] = (JumpFlags & 1024);
	PointMash[3] = (JumpFlags & 2048);
	
	if (JumpZMult < 0.05)
	{
		JumpZMult = 1.0;
	}
	if (StartJumpZMult < 0.05)
	{
		StartJumpZMult = 1.0;
	}
	if (EndJumpZMult < 0.05)
	{
		EndJumpZMult = 1.0;
	}
	
	Points[0] = Point1;
	Points[1] = Point2;
	Points[2] = Point3;
	Points[3] = Point4;
	if (Point4 != BlankVect)
	{
		ListSize = 4;
	}
	else if (Point3 != BlankVect)
	{
		ListSize = 3;
	}
	else
	{
		ListSize = 2;
	}
	
	for(i=0; i<ListSize; i++)
	{
		LP[i] = Spawn(class'VMDLadderPoint',,, Points[i]);
		if (LP[i] != None)
		{
			//MADDERS, 8/12/24: Point mashing is a wicked hack. Decrease our size, and cram us into the wall.
			//In rare cases, this is required to squeeze into tight spaces elegantly.
			if (PointMash[i] > 0)
			{
				LP[i].SetCollisionSize(LP[i].Default.CollisionRadius * 0.25, LP[i].Default.CollisionHeight);
				LP[i].SetLocation(LP[i].Location + (LadderNormal*12));
			}
			
			if (Last != None)
			{
				Last.NextPoint = LP[i];
				LP[i].PreviousPoint = Last;
			}
			LP[i].JumpZMult = JumpZMult;
			LP[i].LadderNormal = LadderNormal;
			LP[i].bNextJump = bAllNextJump;
			LP[i].bPreviousJump = bAllPreviousJump;
			Last = LP[i];
		}
	}
	
	if (LP[0] != None)
	{
		LP[0].bForward = true;
		if (!bStartOnly)
		{
			LP[0].OppositePoint = LP[ListSize-1];
		}
		LP[0].bNextJump = (bStartNextJump || bAllNextJump);
		LP[0].bPreviousJump = (bStartPreviousJump || bAllPreviousJump);
		LP[0].JumpZMult = StartJumpZMult;
		LP[0].OpenMoverRequired = OpenMoverRequired;
	}
	if (LP[ListSize-1] != None)
	{
		LP[ListSize-1].bBackward = true;
		if (!bEndOnly)
		{
			LP[ListSize-1].OppositePoint = LP[0];
		}
		LP[ListSize-1].bNextJump = (bEndNextJump || bAllNextJump);
		LP[ListSize-1].bPreviousJump = (bEndPreviousJump || bAllPreviousJump);
		LP[ListSize-1].JumpZMult = EndJumpZMult;
		LP[ListSize-1].OpenMoverRequired = OpenMoverRequired;
	}
}

function Actor FindActorBySeed(class<Actor> TarClass, int TarSeed)
{
	local Actor TAct;
	
	forEach AllActors(TarClass, TAct)
	{
		if ((TAct != None) && (TarClass == TAct.Class) && (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TAct) == TarSeed))
		{
			return TAct;
		}
	}
	
	return None;
}

function string VMDGetMapName()
{
 	return class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
}

defaultproperties
{
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
