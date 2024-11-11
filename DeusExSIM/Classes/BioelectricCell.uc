//=============================================================================
// BioelectricCell.
//=============================================================================
class BioelectricCell extends DeusExPickup;

var int rechargeAmount;
var int mpRechargeAmount;

var localized String msgRecharged, MsgRechargedPoint;
var localized String RechargesLabel;

//MADDERS additions
var localized string MsgFullyCharged;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 5;
}

function PostBeginPlay()
{
   	Super.PostBeginPlay();
   	if (Level.NetMode != NM_Standalone)
      		rechargeAmount = mpRechargeAmount;
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local int i, ChargedPts;
		local Vector TVect;
		local BiocellSpark TSpark;
		local DeusExPlayer player;
		local VMDBufferPawn VMBP;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();

		Player = DeusExPlayer(Owner);
		VMBP = VMDBufferPawn(Owner);
		if (Player != None)
		{
			VMP = VMDBufferPlayer(Owner);
			
			if ((MedicalBot(Player.FrobTarget) != None) && (VMDHasSkillAugment('MedicineWraparound')))
			{
				MedicalBot(Player.FrobTarget).ChargeBot(Player, 100);
				player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256, VMDGetMiscPitch2());
			}
			else
			{
				Owner.AISendEvent('LoudNoise', EAITYPE_Audio, 1.0, 256);
				//NOTE: +1.0 is float compensation.
				if (Player.Energy+1.0 >= Player.EnergyMax)
				{
				 	Player.ClientMessage(MsgFullyCharged);
				 	GoToState('Deactivated');
				 	return;
				}
				else
				{
				 	//MADDERS: Cure HUD EMP and plug mutator function!
				 	if (VMP != None)
				 	{
 						VMP.VMDRegisterFoodEaten(0, "Biocell");
				  		VMP.HUDEMPTimer = 0;
				  		if (Level.Pauser == "")
						{
							VMP.ShowHUD(True);
							
							if ((DeusExRootWindow(VMP.RootWindow) != None) && (DeusExRootWindow(VMP.RootWindow).AugDisplay != None))
							{
								DeusExRootWindow(VMP.RootWindow).AugDisplay.Show();
							}
						}
				 	}
					
					ChargedPts = Min(rechargeAmount, Player.EnergyMax - Player.Energy);
					if (ChargedPts == 1) player.ClientMessage(Sprintf(msgRechargedPoint, ChargedPts));
				 	else player.ClientMessage(Sprintf(msgRecharged, ChargedPts));
				 	
				 	Player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256, VMDGetMiscPitch2());
				 	
				 	player.Energy += rechargeAmount;
				 	if (player.Energy > player.EnergyMax)
					{
						player.Energy = player.EnergyMax;
					}
				}
			}
		}
		else if (VMBP != None)
		{
			VMBP.Energy = FClamp(VMBP.Energy + RechargeAmount, 0, VMBP.EnergyMax);
			VMBP.PlaySound(sound'BioElectricHiss', SLOT_None,,, 512, VMDGetMiscPitch2());
			
			TVect = VMBP.Location + (Vector(VMBP.Rotation) * VMBP.CollisionRadius * 0.65);
			for (i=0; i<6; i++)
			{
				TSpark = Spawn(class'BiocellSpark',,, TVect, Rotator(TVect - VMBP.Location));
				if (TSpark != None)
				{
					if (i < 4)
					{
						TSpark.Texture = FireTexture'LaserSpot2';
					}
					
					if (VMBP.Region.Zone != None)
					{
						TSpark.Velocity = (VRand() * 10) - (VMBP.Region.Zone.ZoneGravity * 0.125);
					}
					else
					{
						TSpark.Velocity = (VRand() * 10);
					}
					TSpark.SetBase(VMBP);
				}
			}
		}
		
		UseOnce();
	}
Begin:
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local string str;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName);
	winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
	winInfo.AppendText(Sprintf(RechargesLabel, RechargeAmount));

	// Print the number of copies
	str = CountLabel @ String(NumCopies);
	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ str);

	return True;
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
	return (BeltSpot == 0);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDHasActivationObjection()
{
	//NOTE: +1.0 is float compensation.
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).Energy+1.0 >= DeusExPlayer(Owner).EnergyMax))
	{
		if (MedicalBot(DeusExPlayer(Owner).FrobTarget) == None || VMDHasSkillAugment('MedicineWraparound'))
		{
			DeusExPlayer(Owner).ClientMessage(MsgFullyCharged);
			return true;
		}
	}
	return false;
}

//MADDERS: Scale bio cell count with the relevant skill augment.
function int VMDConfigureMaxCopies()
{
	local int Ret;
	
	Ret = MaxCopies;
	
	//MADDERS, 5/31/22: No longer current. Oops.
	/*if ((VMDHasSkillAugment('MedicineWraparound')))
	{
		Ret += 5;
	}*/
	
	return Ret;
}

defaultproperties
{
     M_Activated="You recharge using the %s"
     msgRechargedPoint="Recharged %d point"
     MsgCopiesAdded="You found %d %ss"
     
     MsgFullyCharged="You are already fully charged!"
     rechargeAmount=25
     mpRechargeAmount=50
     msgRecharged="Recharged %d points"
     RechargesLabel="Recharges %d Energy Units"
     maxCopies=15
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Bioelectric Cell"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.BioCell'
     PickupViewMesh=LodMesh'DeusExItems.BioCell'
     ThirdPersonMesh=LodMesh'DeusExItems.BioCell'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconBioCell'
     largeIcon=Texture'DeusExUI.Icons.LargeIconBioCell'
     largeIconWidth=44
     largeIconHeight=43
     Description="A bioelectric cell provides efficient storage of energy in a form that can be utilized by a number of different devices.|n|n<UNATCO OPS FILE NOTE JR289-VIOLET> Augmented agents have been equipped with an interface that allows them to transparently absorb energy from bioelectric cells. -- Jaime Reyes <END NOTE>"
     beltDescription="BIOCELL"
     Mesh=LodMesh'DeusExItems.BioCell'
     CollisionRadius=4.700000
     CollisionHeight=0.930000
     Mass=0.400000
     Buoyancy=0.300000
}
