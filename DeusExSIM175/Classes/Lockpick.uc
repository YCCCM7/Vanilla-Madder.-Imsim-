//=============================================================================
// Lockpick.
//=============================================================================
class Lockpick extends SkilledTool;

var DeusExMover LastMover;
var float PickPotency;
var int HandSkinIndex;

function GenerateSkilledBreak(float pickvalue)
{
	PickValue = (1.0 - PickValue);
	
	//MADDERS, 1/30/21: Buffing this somewhat.
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).HasSkillAugment("LockpickStartStealth")))
	{
		PickValue /= 1.5;
	}
	
	PlaySound(sound'Switch4ClickOff', SLOT_Misc,,,, VMDGetMiscPitch2());
	Owner.AISendEvent('MegaFutz', EAITYPE_Audio, 5.0, 450 * Sqrt(Pickvalue));
	Owner.AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 900 * Sqrt(Pickvalue));
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

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 5;
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
	return (BeltSpot == 7);
}

function UseOnce()
{
	local float PickValue;
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(Owner);
	if (LastMover != None)
	{
		if ((LastMover.bAltPicking) && (LastMover.bLocked))
		{
			PickValue = 0.1;
			if ((Player != None) && (Player.SkillSystem != None))
			{
				PickValue = Player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking');
			}
			GenerateSkilledBreak(PickValue);
			
			LastMover.bAltPicking = false;
		}
	}
	LastMover = None;
	
	Super.UseOnce();
}

function DontUseOnce()
{
	local DeusExPlayer player;
	
	player = DeusExPlayer(Owner);
	
	//MADDERS: Spend amp (copies) as needed, but don't remove the last.
	if (NumCopies > 1) NumCopies--;
	
	GotoState('StopIt');
	
	UpdateBeltText();
}

function float GetPickPotency()
{
 	local float Ret, SM, SV;
 	local int SL, i, CC, AC;
	local DeusExPlayer Player;
 	
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).SkillSystem != None))
	{
		return DeusExPlayer(Owner).SkillSystem.GetSkillLevelValue(class'SkillLockpicking');
	}
	return 0.1;
}

//MADDERS: Scale lockpick count upwards with the relevant skill augment.
function int VMDConfigureMaxCopies()
{
	local int Ret;
	
	Ret = MaxCopies;
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).HasSkillAugment("TagTeamInvaderCapacity")))
	{
		Ret += 10;
	}
	return Ret;
}

defaultproperties
{
     MsgCopiesAdded="You found %d %ss"
     
     PickPotency=0.003000
     HandSkinIndex=0
     UseSound=Sound'DeusExSounds.Generic.LockpickRattling'
     //MADDERS: Nerfing this by 10, since the talent can increase by 10.
     maxCopies=10
     bCanHaveMultipleCopies=True
     ItemName="Lockpick"
     PlayerViewOffset=(X=16.000000,Y=8.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.LockpickPOV'
     PickupViewMesh=LodMesh'DeusExItems.Lockpick'
     ThirdPersonMesh=LodMesh'DeusExItems.Lockpick3rd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconLockPick'
     largeIcon=Texture'DeusExUI.Icons.LargeIconLockPick'
     largeIconWidth=45
     largeIconHeight=44
     Description="A disposable lockpick. The tension wrench is steel, but appropriate needles are formed from fast congealing polymers.|n|n<UNATCO OPS FILE NOTE AJ006-BLACK> Here's what they don't tell you: despite the product literature, you can use a standard lockpick to bypass all but the most high-class nanolocks. -- Alex Jacobson <END NOTE>"
     beltDescription="LOCKPICK"
     Mesh=LodMesh'DeusExItems.Lockpick'
     CollisionRadius=11.750000
     CollisionHeight=1.900000
     Mass=1.000000 //MADDERS: There's 0% chance this shit weighs 20 lbs per 1 lockpick. Likely, this is 1 lb in a stack of 20.
     Buoyancy=0.500000
}
