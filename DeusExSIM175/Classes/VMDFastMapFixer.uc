//=============================================================================
// VMDMapFixer.
// Hi. WCCC again. This one fixes shit that needs to solved INSTANTLY, no exceptions.
// I hate that this exists, but nihilum's shitty ass, buggy elevators forced my hand.
//=============================================================================
class VMDFastMapFixer extends VMDFillerActors;

var float FixTimer;
var bool bRanFixes;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var travel bool bRevisionMapSet;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	CommitMapFixing();
}

//MADDERS: Use this for finding actors at locations.
function bool IsApproximateLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 3) && (ALoc.X > TestLoc.X - 3) && (ALoc.Y < TestLoc.Y + 3) && (ALoc.Y > TestLoc.Y - 3) && (ALoc.Z < TestLoc.Z + 10) && (ALoc.Z > TestLoc.Z - 10));
}

//MADDERS: Use this for finding actors at locations.
function bool MoverIsLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 0.5) && (ALoc.X > TestLoc.X - 0.5) && (ALoc.Y < TestLoc.Y + 0.5) && (ALoc.Y > TestLoc.Y - 0.5) && (ALoc.Z < TestLoc.Z + 0.5) && (ALoc.Z > TestLoc.Z - 0.5));
}

//Similar to above, but we only do this
function bool ItemIsLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 1.5) && (ALoc.X > TestLoc.X - 1.5) && (ALoc.Y < TestLoc.Y + 1.5) && (ALoc.Y > TestLoc.Y - 1.5));
}

function Actor AddBSPPlug(vector SpawnLoc, float Radius, float Height)
{
	local Actor A;
	
	A = Spawn(Class'VMDDynamicBlocker',,,SpawnLoc);
	if (A != None)
	{
		A.SetCollisionSize(Radius, Height);
	}
	
	return A;
}

function DumbAllReactions(ScriptedPawn SP)
{
	if (SP == None) return;
	
	SP.bReactFutz = False;
	SP.bReactPresence = False;
	SP.bReactLoudNoise = False;
	SP.bReactAlarm = False;
	SP.bReactShot = False;
	//SP.bReactGore = False;
	SP.bReactCarcass = False;
	SP.bReactDistress = False;
	SP.bReactProjectiles = False;
	SP.bFearHacking = False;
	SP.bFearWeapon = False;
	SP.bFearShot = False;
	SP.bFearInjury = False;
	SP.bFearIndirectInjury = False;
	SP.bFearCarcass = False;
	SP.bFearDistress = False;
	SP.bFearAlarm = False;
	SP.bFearProjectiles = False;
}

//MADDERS, 12/21/23: Having our cake and eating it, too. When DX rando chair size creates jank, undo it selectively.
function UnRandoSeat(Seat TargetSeat)
{
	if (TargetSeat == None) return;
	
	//NOTE: We do some 0.75 fudge for collision size tweak in Engine.Actor, and some 1.5 fudge for how that impacts both ends of our placement.
	switch(TargetSeat.Class.Name)
	{
		case 'Chair1':
			TargetSeat.SitPoint[0] = Vect(0,-6,-4.5);
			TargetSeat.SetLocation(TargetSeat.Location + vect(0,0,34.33996) - vect(0,0,1.5) - TargetSeat.PrePivot);
			TargetSeat.PrePivot = Vect(0,0,0);
			TargetSeat.SetCollisionSize(23, 33.169998 - 0.75);
		break;
		case 'OfficeChair':
			TargetSeat.SitPoint[0] = Vect(0,-4,0);
			TargetSeat.SetLocation(TargetSeat.Location + vect(0,0,20) - vect(0,0,1.5) - TargetSeat.PrePivot);
			TargetSeat.PrePivot = Vect(0,0,0);
			TargetSeat.SetCollisionSize(16, 25.549999 - 0.75);
		break;
	}
}

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing()
{
	//Parent class junk.
	local Actor A;
	local DeusExDecoration DXD;
	local VMDBufferDeco VMD;
 	local DeusExLevelInfo LI;
	local DeusExWeapon DXW;
	local Inventory TInv;
	local ScriptedPawn SP;
	
	//Door stuff.
	local vector FrameAdd[8], LocAdd, PivAdd, TestLoc;
	local DeusExMover DXM;
	local Mover TMov;
	
	//Universal bits and bobs.
	local bool FoundFlag;
	local int GM, i;
	local string MN;
	local Rotator TRot;
	local Vector PlugVect;
	local Texture FilTex[8];
	
	//MADDERS, 11/1/21: LDDP stuff.
	local class<DeusExCarcass> DXCLoad;
	local class<ScriptedPawn> SPLoad;
	local class<VMDStaticFunctions> SF;
	local DeusExCarcass DXC;
	local FlagBase Flags;
	
	SF = class'VMDStaticFunctions';
	if ((DeusExPlayer(GetPlayerPawn()) != None) && (DeusExPlayer(GetPlayerPawn()).FlagBase != None))
	{
		Flags = DeusExPlayer(GetPlayerPawn()).FlagBase;
	}
	
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
	
	switch(GM)
	{
		case 16:
			switch(MN)
			{
				//+++++++++++++++++++++++
				//Utopia Maps
				//UTOPIA_SUBWAY, AKA SUBWAY: Clean up shitty door.
				case "SUBWAY":
					A = FindActorBySeed(class'DeusExMover', 0);
					if (A != None)
					{
						A.SetLocation(A.Location + Vect(0, 0, 10000));
					}
				break;
			}
		break;
		case 66:
			switch(MN)
			{
				//66_WhiteHouse_Exterior: Fix elevator running away from us too quickly.
				case "66_WHITEHOUSE_EXTERIOR":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if (DXM.Class == Class'DeusExMover')
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								case 24:
									DXM.MoveTime = 20;
									break;
								case 25:
									DXM.MoveTime = 20;
									DXM.SetCollision(False, False, False);
								break;
							}
						}
					}
				break;
				//66_WhiteHouse_Streets: Fix elevator running away from us too quickly.
				case "66_WHITEHOUSE_STREETS":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if (DXM.Class == Class'DeusExMover')
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								case 0:
									DXM.MoveTime = 20;
								break;
								case 25:
									DXM.MoveTime = 20;
										DXM.SetCollision(False, False, False);
								break;
							}
						}
					}
				break;
			}
		break;
	}
	
	bRanFixes = true;
}

function string VMDGetMapName()
{
 	local string S, S2;
 	
 	S = GetURLMap();
 	S2 = Chr(92); //What the fuck. Can't type this anywhere!
	
	//MADDERS, 3/23/21: Uuuuh... Oceanlab machine :B:ROKE.
	//No idea how or why this happens, and only post-DXT merge. Fuck it. Chop it down.
	if (Right(S, 1) ~= " ") S = Left(S, Len(S)-1);
	
 	//HACK TO FIX TRAVEL BUGS!
 	if (InStr(S, S2) > -1)
 	{
  		do
  		{
   			S = Right(S, Len(S) - InStr(S, S2) - 1);
  		}
  		until (InStr(S, S2) <= -1);

		if (InStr(S, ".") > -1)
		{
  			S = Left(S, Len(S) - 4);
		}
 	}
 	else
	{
		if (InStr(S, ".") > -1)
		{
			S = Left(S, Len(S)-3);
		}
 	}
	
 	return CAPS(S);
}

function Actor FindActorBySeed(class<Actor> TarClass, int TarSeed)
{
	local Actor TAct;
	
	forEach AllActors(TarClass, TAct)
	{
		if ((TAct != None) && (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TAct) == TarSeed))
		{
			return TAct;
		}
	}
	
	return None;
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
