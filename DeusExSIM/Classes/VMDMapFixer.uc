//=============================================================================
// VMDMapFixer.
// Hi. WCCC here. I want to apologize for the utter nonsense that is this class.
// As far as I can tell, it doesn't murk performance in any noticable way, as it's only ever ran once.
// I've used switch/cases and minimized AllActor calls when practically possible... But better can be done.
// My rationale for using this actor is largely to fix non-patched maps and to fix other mods.
// In theory, I can use this with non-linear tweaks along the way, but so far this is not the case.
// I'm sure one day this'll get me canceled harder than those times I said the Z word on twitter.
//=============================================================================
class VMDMapFixer extends VMDFillerActors;

var float FixTimer;
var bool bRanFixes;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var bool bRevisionMapSet;

//Localized strings for any keys we add, usually for patching purposes.
var localized string VMDPatchedTruckDesc;



//MADDERS, 2/21/25: Can't be bothered to rewrite this shit constantly. Just store it here.
//Parent class junk.
var Actor A;
var DeusExAmmo DXA;
var DeusExDecoration DXD;
var DeusExLevelInfo DXLI;
var DeusExWeapon DXW;
var Inventory TInv;
var Pawn TPawn;
var ScriptedPawn SP;
var Seat TSeat;
var VMDBufferDeco VMD;
var VMDBufferPawn VMBP;

//Door stuff.
var vector FrameAdd[8], LocAdd, PivAdd, TestLoc;
var DeusExMover DXM;
var Mover TMov;

//Universal bits and bobs.
var bool FoundFlag;
var float Diff;
var int GM, i;
var Rotator TRot;
var Vector PlugVect;
var Texture FilTex[8];

//Semi-vague classes.
var Computers Comp;
var Keypad KP;
var Light Lig;
var MapExit MapEx;
var Nanokey Key;
var PatrolPoint Pat, StoredPats[3];

//Specific classes
var AllianceTrigger ATrig;
var AutoTurret ATur;
var AutoTurretSmall SATur;
var ConversationTrigger ConTrig;
var CrateExplosiveSmall CExpSmall;
var Credits Cred;
var DatalinkTrigger DataTrig;
var Dispatcher TDispatch;
var ElectronicDevices ED;
var FlagTrigger FT;
var OrdersTrigger OTrig;
var SkillAwardTrigger SAT;
var VMDCabinetCampActor TCamp;
var VMDNGPlusPortal NGPortal;
var WeaponBaton Bat;

//MADDERS: Used for training purposes.
var Ammo10mm TenMil;
var Ammo3006 ThirtyOught;
var DataCube DC;
var Skill SK;

//MADDERS, 11/1/21: LDDP stuff.
var class<DeusExCarcass> DXCLoad;
var class<DeusExWeapon> LDXW;
var class<ScriptedPawn> SPLoad;
var DeusExCarcass DXC;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function Conversation GetConversation(Name conName)
{
    	local Conversation c;
	
    	foreach AllObjects(class'Conversation', c)
	{
        	if(c.conName == conName) return c;
    	}
	
    	return None;
}

static function FixConversationGiveItem(Conversation c, string fromName, Class<Inventory> fromClass, Class<Inventory> to)
{
    	local ConEvent e;
    	local ConEventTransferObject t;
	
    	if (c == None) return;
	
    	for(e=c.eventList; e!=None; e=e.nextEvent)
	{
        	t = ConEventTransferObject(e);
        	if(t == None) continue;
		
        	if((t.objectName == fromName) && (t.giveObject == fromClass))
		{
            		t.objectName = string(to.name);
            		t.giveObject = to;
        	}
    	}
}

function Tick(float DT)
{
	local string MapName;
	local FlagBase Flags;
	local VMDBufferPlayer VMP;
	local class<VMDStaticFunctions> SF;
	
 	Super.Tick(DT);
 	
	if (!bRanFixes)
	{
 		if (FixTimer < 0.5)
		{
			FixTimer += DT;
		}
		else if (FixTimer > -10)
 		{
 	 		FixTimer = -30;
			CommitMapFixing(MapName, Flags, VMP, SF);

			if ((TestLoc != vect(0,0,0)) && (VMP != None))
			{
				VMP.SetLocation(TestLoc);
				VMP.ConsoleCommand("Invisible 1");
			}
			
			//MADDERS: 11/1/21: Update our convo shit for max compatibility, thanks to some LDDP fuckery we're doing. What a weird methodology I chose.
			VMP.ConBindEvents();
			
			bRanFixes = true;
	 	}
	}
}

//MADDERS: Shortcut for spawning oodles of these things in training.
function SpawnSpeechBubble(Vector NewLocation, int NewIndex, bool NewbUnlit, optional bool bExplodes)
{
	local VMDSpeechBubble SB;
	
	SB = Spawn(class'VMDSpeechBubble',,,NewLocation);
	if (SB != None)
	{
		SB.TipIndex = NewIndex;
		SB.bUnlit = NewbUnlit;
		
		SB.UpdateWrittenData();
		if (bExplodes)
		{
			SB.SpawnExplosionEffect();
		}
	}
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

function Actor CreateHallucination(vector SpawnLoc, int UnlockIndex, bool bIsHidden)
{
	local VMDHallucination Hally;
	
	Hally = Spawn(class'VMDHallucination',,,SpawnLoc);
	if (Hally != None)
	{
		Hally.UnlockIndex = UnlockIndex;
		Hally.bHidden = bIsHidden;
	}
	
	return Hally;
}

function bool GetFlagBool(name FlagName)
{
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(GetPlayerPawn());
	
	if ((DXP != None) && (DXP.FlagBase != None))
	{
		return DXP.FlagBase.GetBool(FlagName);
	}
	
	return false;
}

function SetMoverFragmentType(DeusExMover DXM, string MaterialClass)
{
	if (DXM == None) return;
	
	MaterialClass = CAPS(MaterialClass);
	
	switch(MaterialClass)
	{
		case "GLASS":
     			DXM.ExplodeSound1 = Sound'GlassBreakSmall';
     			DXM.ExplodeSound2 = Sound'GlassBreakLarge';
			DXM.FragmentClass = class'GlassFragment';
		break;
		case "METAL":
     			DXM.ExplodeSound1 = Sound'MediumExplosion1';
     			DXM.ExplodeSound2 = Sound'MediumExplosion1';
			DXM.FragmentClass = class'MetalFragment';
		break;
		case "PLASTIC":
     			DXM.ExplodeSound1 = Sound'PlasticHit1';
     			DXM.ExplodeSound2 = Sound'GlassBreakSmall';
			DXM.FragmentClass = class'PlasticFragment';
		break;
		case "WOOD":
     			DXM.ExplodeSound1 = Sound'WoodBreakSmall';
     			DXM.ExplodeSound2 = Sound'WoodBreakLarge';
			DXM.FragmentClass = class'WoodFragment';
		break;
	}
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
	SP.bHateShot = False; //MADDERS, 2/27/25: Common point of issue.
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
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	SF = class'VMDStaticFunctions';
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.FlagBase != None))
	{
		Flags = VMP.FlagBase;
	}
	
	MapName = VMDGetMapName();
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
	
	//MADDERS, 4/15/21: Accurate setup for HC movers. Yeah it's trash, but it's reliable.
	forEach AllActors(class'Mover', TMov)
	{
		if ((TMov != None) && (TMov.IsA('CBreakableGlass')))
		{
			TMov.BlendTweenRate[0] = float(TMov.GetPropertyText("DoorStrength"));
		}
	}
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
		if ((TAct != None) && (TarClass == TAct.Class) && (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TAct) == TarSeed))
		{
			return TAct;
		}
	}
	
	return None;
}

defaultproperties
{
     VMDPatchedTruckDesc="Gas station truck"
     
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
