//=============================================================================
// AugmentationCannister.
//=============================================================================
class AugmentationCannister extends DeusExPickup;

var() travel Name AddAugs[2];

var localized string AugsAvailable;
var localized string MustBeUsedOn;
var string DirtyLineBreak;

// ----------------------------------------------------------------------
// Network Replication
// ---------------------------------------------------------------------

replication
{
   //server to client variables
   reliable if ((Role == ROLE_Authority) && (bNetOwner))
      AddAugs;
}

function string VMDGetItemName()
{
	local DeusExPlayer TPlayer;
	local string Aug1, Aug2;
	
	TPlayer = DeusExPlayer(GetPlayerPawn());
	if (TPlayer == None) return ItemName;
	
	Aug1 = GetAugmentationFrob(0, TPlayer).AugmentationName;
	Aug2 = GetAugmentationFrob(1, TPlayer).AugmentationName;
	
	if (Aug1 == "")
	{
		if (Aug2 == "")
		{
			return ItemName;
		}
		else
		{
			return ItemName@"("$Aug2$")";
		}
	}
	else
	{
		if (Aug2 == "")
		{
			return ItemName@"("$Aug1$")";
		}
		else
		{
			return ItemName@"("$Aug1$"/"$Aug2$")";
		}
	}
	
	return ItemName;
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local String outText;
	local Int canIndex;
	local Augmentation aug;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.Clear();
	winInfo.SetTitle(itemName);
	winInfo.SetText(Description);

	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ AugsAvailable);
	winInfo.AppendText(winInfo.CR() $ winInfo.CR());

	for(canIndex=0; canIndex<ArrayCount(AddAugs); canIndex++)
	{
		if (AddAugs[canIndex] != '')
		{
			aug = GetAugmentation(canIndex);

			if (aug != None)
				winInfo.AppendText("("$aug.default.AugLocsText[aug.default.AugmentationLocation]$")" @ aug.default.AugmentationName $ winInfo.CR()); // Transcended - Add aug location
		}
	}
	
	// Transcended - Add aug description
	for(canIndex=0; canIndex<ArrayCount(AddAugs); canIndex++)
	{
		aug = GetAugmentation(canIndex);

		if (aug != None)
		{
			winInfo.AppendText(winInfo.CR() $ winInfo.CR());														// Create a new line to show the aug descriptions
			winInfo.AppendText(DirtyLineBreak $ winInfo.CR());														// ----- to break up the text
			winInfo.AppendText(AugsAvailable @ aug.AugmentationName $ winInfo.CR());								// Augmentation name
			winInfo.AppendText(DirtyLineBreak $ winInfo.CR() $ winInfo.CR());										// ----- to break up the text
			winInfo.AppendText(Sprintf(aug.OccupiesSlotLabel, aug.AugLocsText[aug.AugmentationLocation]));			// Show the location
			winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ aug.Description);										// Show the description
			winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ Sprintf(aug.EnergyRateLabel, Int(aug.EnergyRate)));	// Show the energy rate
			
			if (aug.bAlwaysActive)
				winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ aug.AlwaysActiveLabel);							// Show if this aug is always active e.g. EMP shield
		}
	}
	
	winInfo.AppendText(winInfo.CR() $ MustBeUsedOn);

	return True;
}

// ----------------------------------------------------------------------
// GetAugmentation()
// ----------------------------------------------------------------------

simulated function Augmentation GetAugmentation(int augIndex)
{
	local Augmentation anAug;
	local DeusExPlayer player;

	// First make sure we have a valid value
	if ((augIndex < 0) || (augIndex > (ArrayCount(AddAugs) - 1)))
		return None;

	if (AddAugs[augIndex] == '')
		return None;

	// Loop through all the augmentation objects and look 
	// for the augName that matches the one stored in 
	// this object

	player = DeusExPlayer(Owner);

	if (player != None)
	{
		anAug = player.AugmentationSystem.FirstAug;
		while(anAug != None)
		{
			if (addAugs[augIndex] == anAug.Class.Name)
				break;

			anAug = anAug.next;
		}
	}

	return anAug;
}

// ----------------------------------------------------------------------
// function SpawnCopy()
// DEUS_EX AMSD In multiplayer, it creates a copy (for respawning purposes) and gives
// THAT to the player.  The copy doesn't copy the augadd settings.  So
// we need to overwrite the spawncopy funciton here.
// ----------------------------------------------------------------------
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
   	local Int augIndex;
   	local AugmentationCannister CopyCan;

	Copy = Super.SpawnCopy(Other);
   	CopyCan = AugmentationCannister(Copy);
   	for (augIndex = 0; augIndex < ArrayCount(Addaugs); augIndex++)
   	{
      		CopyCan.addAugs[augIndex] = addAugs[augIndex];
   	}
}


auto state Pickup
{
// ----------------------------------------------------------------------
// function Frob()
// For autoinstalling in deathmatch, we need to overload frob here
// ----------------------------------------------------------------------
   	function Frob(Actor Other, Inventory frobWith)
   	{
      		local Inventory Copy;
      		local int AugZeroPriority;
      		local int AugOnePriority;
      		local Augmentation AugZero;
      		local Augmentation AugOne;
		
      		//If we aren't autoinstalling, just return.
      		if ( (Level.NetMode == NM_Standalone) || (DeusExMPGame(Level.Game) == None) || (DeusExMPGame(Level.Game).bAutoInstall == False) ||
           		(DeusExPlayer(Other) == None) )
      		{
			if (Other != None)
			{
         			Super.Frob(Other,frobWith);
         			return;
			}
      		}
      		if ((Level != None) && (Level.Game != None) && (DeusExPlayer(Other) != None) && (ValidTouch(Other)))
      		{
         		if (Level.Game.LocalLog != None)
            			Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
         		if (Level.Game.WorldLog != None)
            			Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			
         		SetOwner(DeusExPlayer(Other));
			
         		AugZero = GetAugmentation(0);
         		AugOne = GetAugmentation(1);
			
        		if (AugZero != None)
            			AugZeroPriority = DeusExPlayer(Other).GetAugPriority(AugZero);
         		else
            			AugZeroPriority = -10;
			
         		if (AugOne != None)
            			AugOnePriority = DeusExPlayer(Other).GetAugPriority(AugOne);
         		else
            			AugOnePriority = -10;
			
         		if ((AugZeroPriority < 0) || (AugOnePriority < 0))
         		{
            			Pawn(Other).ClientMessage("No available augmentations found.");
         		}
         		else if (AugZeroPriority < 0)
         		{ 
            			Pawn(Other).ClientMessage("Autoinstalling Augmentation "$AugOne.AugmentationName$".");
            			DeusExPlayer(Other).AugmentationSystem.GivePlayerAugmentation(AugOne.Class);
         		}
         		else if (AugOnePriority < 0)
         		{
            			Pawn(Other).ClientMessage("Autoinstalling Augmentation "$AugZero.AugmentationName$".");
            			DeusExPlayer(Other).AugmentationSystem.GivePlayerAugmentation(AugZero.Class);
         		}
         		else if (AugZeroPriority < AugOnePriority)
         		{
            			Pawn(Other).ClientMessage("Autoinstalling Augmentation "$AugZero.AugmentationName$".");
            			DeusExPlayer(Other).AugmentationSystem.GivePlayerAugmentation(AugZero.Class);
         		}
         		else
         		{
            			Pawn(Other).ClientMessage("Autoinstalling Augmentation "$AugOne.AugmentationName$".");
            			DeusExPlayer(Other).AugmentationSystem.GivePlayerAugmentation(AugOne.Class);
         		}
			
         		SetOwner(None);
      		}
   	}
   	
   	function BeginState()
   	{
      		Super.BeginState();
   	}
}

// ----------------------------------------------------------------------
// GetAugmentation()
// ----------------------------------------------------------------------

simulated function Augmentation GetAugmentationFrob(int augIndex, DeusExPlayer player)
{
	local Augmentation anAug;
	local int i;

	// First make sure we have a valid value
	if ((augIndex < 0) || (augIndex > (ArrayCount(AddAugs) - 1))) //
		return None;

	// Loop through all the augmentation objects and look 
	// for the augName that matches the one stored in 
	// this object

	if (player != None)
	{
		//== Instead of returning none, just generate a random augmentation
		if (AddAugs[augIndex] == '')
		{
			//== Don't stop if we somehow do the random thing and get None
			while(anAug == None)
			{
				for(i = Int(Frand() * (ArrayCount(player.AugmentationSystem.AugClasses) - 3)); i >= 0; i--)
				{
					if(anAug == None)
						anAug = player.AugmentationSystem.FirstAug;
					else
						anAug = anAug.next;
	
					//== No default augmentations
					if (anAug.Default.Class.Name == 'AugIFF' || anAug.Default.Class.Name == 'AugLight' || anAug.Default.Class.Name == 'AugDatalink' || anAug.Default.Class.Name == 'AugAimBot')
						anAug = None;
				}
			}
			AddAugs[augIndex] = anAug.Class.Name;
			return anAug;
		}

		anAug = player.AugmentationSystem.FirstAug;
		while(anAug != None)
		{
			if (addAugs[augIndex] == anAug.Class.Name)
				break;

			anAug = anAug.next;
		}
	}

	return anAug;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     DirtyLineBreak="-------------------------------------------"
     AugsAvailable="Can Add:"
     MustBeUsedOn="Can only be installed with the help of a MedBot."
     ItemName="Augmentation Canister"
     ItemArticle="an"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AugmentationCannister'
     PickupViewMesh=LodMesh'DeusExItems.AugmentationCannister'
     ThirdPersonMesh=LodMesh'DeusExItems.AugmentationCannister'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconAugmentationCannister'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAugmentationCannister'
     largeIconWidth=19
     largeIconHeight=49
     Description="An augmentation canister teems with nanoscale mecanocarbon ROM modules suspended in a carrier serum. When injected into a compatible host subject, these modules augment an individual with extra-sapient abilities. However, proper programming of augmentations must be conducted by a medical robot, otherwise terminal damage may occur. For more information, please see 'Face of the New Man' by Kelley Chance."
     beltDescription="AUG CAN"
     Mesh=LodMesh'DeusExItems.AugmentationCannister'
     CollisionRadius=4.310000
     CollisionHeight=10.240000
     Mass=10.000000
     Buoyancy=12.000000
}
