//=============================================================================
// Multitool.
//=============================================================================
class Multitool extends SkilledTool;

var float MaxRange, HackPotency;
var int HandSkinIndex;
var MultitoolKeypadOverlayManager LastKeypadManager;
var Actor LastHackTarget;

replication
{
   	//client to server function
   	reliable if ((Role < ROLE_Authority) && (bNetOwner))
      		GeneratePoints, DontUseOnce;
}

function GenerateSkilledBreak(float HackValue)
{
	HackValue = (1.0 - HackValue);
	if ((VMDHasSkillAugment('ElectronicsSpeed')))
	{
		HackValue = HackValue ** 2;
	}
	
	PlaySound(Sound'Beep6', SLOT_Misc,,,, VMDGetMiscPitch2());
	Owner.AISendEvent('MegaFutz', EAITYPE_Audio, 5.0, 600 * Sqrt(HackValue));
	Owner.AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 1200 * Sqrt(HackValue));
}

//MADDERS: Use render of overlays to show JC hands.
simulated event RenderOverlays( Canvas Can )
{
 	local Texture TTex;
	local bool bFemale;
	local VMDBufferPlayer VMBP;
	
 	//Object load annoying. Do this instead.
 	VMBP = VMDBufferPlayer(Owner);
	if (VMBP != None)
 	{
		bFemale = VMBP.bAssignedFemale;
	}
	
 	//Object load annoying. Do this instead.
 	if ((HandSkinIndex > -1) && (DeusExPlayer(Owner) != None) && (!VMDOwnerIsCloaked()))
 	{
  		switch (DeusExPlayer(Owner).PlayerSkin)
  		{
   			case 0: //White
				if (bFemale)
				{
					TTex = Texture'NewHand01Female';
				}
				else
				{
    					TTex = Texture'NewHand01';
				}
   			break;
   			case 1: //Black
				if (bFemale)
				{
					TTex = Texture'NewHand02Female';
				}
				else
				{
    					TTex = Texture'NewHand02';
				}
   			break;
   			case 2: //Brown
				if (bFemale)
				{
					TTex = Texture'NewHand03Female';
				}
				else
				{
    					TTex = Texture'NewHand03';
				}
   			break;
   			case 3: //Redhead
				if (bFemale)
				{
					TTex = Texture'NewHand04Female';
				}
				else
				{
    					TTex = Texture'NewHand04';
				}
   			break;
   			case 4: //Pale
				if (bFemale)
				{
					TTex = Texture'NewHand05Female';
				}
				else
				{
    					TTex = Texture'NewHand05';
				}
   			break;
  		}
  		
  		MultiSkins[HandSkinIndex] = TTex;
  		Super.RenderOverlays(Can);
  		
  		MultiSkins[HandSkinIndex] = Default.Multiskins[HandSkinIndex];
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   	return (BeltSpot == 8);
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 5;
}

function UseOnce()
{
	local float HackValue;
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(Owner);
	if (HackableDevices(LastHackTarget) != None)
	{
		if ((HackableDevices(LastHackTarget).bAltHacking) && (!(HackableDevices(LastHackTarget).HackStrength ~= 0.0)))
		{
			HackValue = 0.1;
			if ((Player != None) && (Player.SkillSystem != None))
			{
				HackValue = Player.SkillSystem.GetSkillLevelValue(class'SkillTech');
			}
			GenerateSkilledBreak(HackValue);
			
			HackableDevices(LastHackTarget).bAltHacking = false;
		}
	}
	LastHackTarget = None;
	
	Super.UseOnce();
}

function DontUseOnce()
{
	local DeusExPlayer player;
	
	player = DeusExPlayer(Owner);
	
	//MADDERS: Spend tools only if we're warmed up, or aren't free.
	if (Keypad(LastHackTarget) == None)
	{
		if ((NumCopies > 1) && (!IsFreebie(LastHackTarget))) NumCopies--;
		if (HackableDevices(LastHackTarget) != None) HackableDevices(LastHackTarget).bFirstHackSpent = true;
	}
	GotoState('StopIt');
	
	UpdateBeltText();
}

function bool IsFreebie(Actor HackTar)
{
	//Keypads only spend multitools the first time.
	if (Keypad(HackTar) != None)
	{
		//MADDERS: Hacking for real means no freebies.
		if (!Keypad(HackTar).GetCodebreakerPreference()) return false;
		if (Keypad(HackTar).bAltHacking) return false;
		if (Keypad(HackTar).bFirstHackSpent) return false;
		return true;
	}
	
	return false;
}

//Use these for setup and wipe.
function ActivateProxy()
{
	local Keypad KeyBoi;
	
	if (FindKeypad(KeyBoi))
	{
		if ((!KeyBoi.bAltHacking) && (KeyBoi.GetCodebreakerPreference()))
		{
			GeneratePoints();
			PlaySound(Sound'TouchTone3',,,,, VMDGetMiscPitch2());
		}
	}
}

function DeactivateProxy()
{
	local Keypad K;
	local DeusExPlayer DXP;
	local float TSkill;
	local HackableDevices HD;
	
	DXP = DeusExPlayer(Owner);
	K = Keypad(LastHackTarget);
	HD = HackableDevices(LastHackTarget);
	
	//MADDERS: Spend tools only if we're warmed up, or aren't free.
	if ((DXP != None) && (DXP.SkillSystem != None) && (K != None))
	{
		TSkill = DXP.SkillSystem.GetSkillLevelValue(class'SkillTech');
		
		if (IsFreebie(K))
		{
		}
		else
		{
			//MADDERS, 12/14/20: Oops. Left this in.
			//if ((HD != None) && (HD.HackStrength > 0.0)) GenerateSkilledBreak(TSkill);
			//if (NumCopies > 1) NumCopies--;
			K.bFirstHackSpent = true;
		}
	}
	WipePoints();
}

//-------------------------------
//SETUP AND WIPE FUNCTIONS!
function bool FindKeypad(out Keypad OutKey)
{
 	local DeusExPlayer DXP;
 	local Actor HitAct;
 	local vector StartLoc, EndLoc, HitNorm, HitLoc;
 	
 	if (DeusExPlayer(Owner) == None) return false;
 	
 	DXP = DeusExPlayer(Owner);
 	
 	StartLoc = DXP.Location + (vect(0,0,1) * DXP.BaseEyeHeight);
 	EndLoc = StartLoc + (vector(DXP.ViewRotation) * MaxRange);
 	HitAct = DXP.Trace(HitLoc, HitNorm, EndLoc, StartLoc, True);
 	
 	if (Keypad(HitAct) != None)
 	{
  		OutKey = Keypad(HitAct);
  		return True;
 	}
 	
 	return false;
}

function bool IsMulti(String Search, string Comp)
{
 	local string TStr;
 	local int i, Count;
 	
 	for (i=0; i<Len(Comp); i++)
 	{     
  		TStr = Mid(Comp, i, 1);
  		if (TStr ~= Search) Count++;
 	}
 	
 	return (Count > 1);
}

function bool IsMegaMulti(String Search, string Comp)
{
 	local string TStr;
 	local int i, Count;
 	
 	for (i=0; i<Len(Comp); i++)
 	{     
  		TStr = Mid(Comp, i, 1);
  		if (TStr ~= Search) Count++;
 	}
 	
 	return (Count > 2);
}

simulated function WipePoints()
{
 	if (LastKeypadManager != None) LastKeypadManager.Destroy();
}

simulated function GeneratePoints()
{
 	local Keypad InPad;
 	local string Chunker;
 	local int i;
 	
 	if (!FindKeypad(InPad)) return;
 	if (InPad.HackedValidCode ~= "")
 	{
 	 	for (i=0; i<Len(InPad.ValidCode); i++)
  		{
   			Chunker = Chunker$Rand(10);
  		}
  		InPad.HackedValidCode = Chunker;
 	}
 	
 	LastKeypadManager = Spawn(class'MultitoolKeypadOverlayManager', Owner,, InPad.Location, InPad.Rotation);
 	LastKeypadManager.GeneratePoints(InPad, DeusExPlayer(Owner));
}

function float GetHackPotency(Actor RelTar)
{
 	local float Ret, SM, SV;
 	local int SL, i, CC, AC;
	local DeusExPlayer Player;
	
	Ret = 0.1;
	
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).SkillSystem != None))
	{
		Ret = DeusExPlayer(Owner).SkillSystem.GetSkillLevelValue(class'SkillTech');
	}
	if ((Keypad(RelTar) != None) && (VMDHasSkillAugment('ElectronicsKeypads')))
	{
		//MADDERS, 7/24/23: This talent has been overhauled now.
		//Ret *= 1.35;
	}
	
	return Ret;
}

//MADDERS: Scale multitool count upwards with the relevant skill augment.
function int VMDConfigureMaxCopies()
{
	local int Ret;
	
	Ret = MaxCopies;
	if (VMDHasSkillAugment('TagTeamInvaderCapacity'))
	{
		Ret += 10;
	}
	return Ret;
}

defaultproperties
{
     SelectTilt(0)=(X=20.000000,Y=10.000000)
     SelectTilt(1)=(X=25.000000,Y=5.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.500000
     
     DownTilt(0)=(X=7.500000,Y=-20.000000)
     DownTilt(1)=(X=2.500000,Y=-25.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.350000
     
     UseLoopTilt(0)=(X=-5.000000,Y=-2.500000)
     UseLoopTilt(1)=(X=5.000000,Y=-2.500000)
     UseLoopTilt(2)=(X=-5.000000,Y=-2.500000)
     UseLoopTilt(3)=(X=3.750000,Y=8.125000)
     UseLoopTilt(4)=(X=-5.000000,Y=-2.500000)
     UseLoopTilt(5)=(X=6.250000,Y=10.833000)
     UseLoopTiltIndices=6
     UseLoopTiltTimer(0)=0.000000
     UseLoopTiltTimer(1)=0.150000
     UseLoopTiltTimer(2)=0.300000
     UseLoopTiltTimer(3)=0.450000
     UseLoopTiltTimer(4)=0.650000
     UseLoopTiltTimer(5)=0.850000
     
     UseBeginTilt(0)=(X=-10.000000,Y=5.000000)
     UseBeginTilt(1)=(X=-2.500000,Y=5.000000)
     UseBeginTiltIndices=2
     UseBeginTiltTimer(0)=0.000000
     UseBeginTiltTimer(1)=0.500000
     
     UseEndTilt(0)=(X=10.000000,Y=-5.000000)
     UseEndTilt(1)=(X=2.500000,Y=-5.000000)
     UseEndTiltIndices=2
     UseEndTiltTimer(0)=0.000000
     UseEndTiltTimer(1)=0.450000
     
     MsgCopiesAdded="You found %d %ss"
     
     HackPotency=0.003000
     MaxRange=112 //EQUAL TO FROB DISTANCE!
     HandSkinIndex=5
     UseSound=Sound'DeusExSounds.Generic.MultitoolUse'
     //MADDERS: Nerfing this by 10, since the augment can increase by 10.
     maxCopies=10
     bCanHaveMultipleCopies=True
     ItemName="Multitool"
     PlayerViewOffset=(X=20.000000,Y=10.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.MultitoolPOV'
     LeftPlayerViewMesh=LodMesh'MultitoolPOVLeft'
     PickupViewMesh=LodMesh'DeusExItems.Multitool'
     ThirdPersonMesh=LodMesh'DeusExItems.Multitool3rd'
     LeftThirdPersonMesh=LodMesh'Multitool3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconMultitool'
     largeIcon=Texture'DeusExUI.Icons.LargeIconMultitool'
     largeIconWidth=28
     largeIconHeight=46
     Description="A disposable electronics tool. By using electromagnetic resonance detection and frequency modulation to dynamically alter the flow of current through a circuit, skilled agents can use the multitool to manipulate code locks, cameras, autogun turrets, alarms, or other security systems."
     beltDescription="MULTITOOL"
     Mesh=LodMesh'DeusExItems.Multitool'
     CollisionRadius=4.800000
     CollisionHeight=0.860000
     Mass=1.000000 //MADDERS: There's 0% chance this shit weighs 20 lbs per 1 lockpick. Likely, this is 1 lb in a stack of 20.
     Buoyancy=0.500000
}
