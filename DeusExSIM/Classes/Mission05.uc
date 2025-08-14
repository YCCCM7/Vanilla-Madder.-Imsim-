//=============================================================================
// Mission05.
//=============================================================================
class Mission05 extends MissionScript;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local PaulDentonCarcass carc;
	local PaulDenton Paul;
	local Terrorist T;
	local AnnaNavarre Anna;
	local VMDBufferPlayer VMP;
	
	local Vector LocationMod;
	local int CurLap;
	local Inventory ContinueItem;
	local SpawnPoint ContinuePoint;
	local int OldScrap, OldChem;
	local VMDScrapMetal TScrap;
	local VMDChemicals TChem;
	
	Super.FirstFrame();
	
	if (localURL == "05_NYC_UNATCOMJ12LAB")
	{
		// make sure this goal is completed
		Player.GoalCompleted('EscapeToBatteryPark');

		// delete Paul's carcass if he's still alive
		if (!flags.GetBool('PaulDenton_Dead'))
		{
			foreach AllActors(class'PaulDentonCarcass', carc)
				carc.Destroy();
		}

		// if the player has already talked to Paul, delete him
		//if (flags.GetBool('M05PaulDentonDone') ||
		//	flags.GetBool('PlayerBailedOutWindow'))
		
		if (flags.GetBool('M05PaulDentonDone') || flags.GetBool('PaulDenton_Dead'))
		{
			foreach AllActors(class'PaulDenton', Paul)
				Paul.Destroy();
		}
		
		// if Miguel is not following the player, delete him
		if (flags.GetBool('MeetMiguel_Played') &&
			!flags.GetBool('MiguelFollowing'))
		{
			foreach AllActors(class'Terrorist', T)
				if (T.BindName == "Miguel")
					T.Destroy();
		}
		
		// remove the player's inventory and put it in a room
		// also, heal the player up to 50% of his total health
		if (!flags.GetBool('MS_InventoryRemoved'))
		{
			Player.HealthHead = Max(50, Player.HealthHead);
			Player.HealthTorso = Max(50, Player.HealthTorso);
			Player.HealthLegLeft = Max(50, Player.HealthLegLeft);
			Player.HealthLegRight = Max(50, Player.HealthLegRight);
			Player.HealthArmLeft = Max(50, Player.HealthArmLeft);
			Player.HealthArmRight = Max(50, Player.HealthArmRight);
			Player.GenerateTotalHealth();
			
			if (POVCorpse(Player.InHand) != None)
			{
				POVCorpse(Player.InHand).Destroy();
			}
			
			//== Y|y: There is an odd glitch with laser sights which can generate a "ghost" laser
			//==  so we need to force the laser off
			if (DeusExWeapon(Player.inHand) != None)
			{
				DeusExWeapon(Player.inHand).LaserOff();
			}
			
			//MADDERS: Wipe relevant smells, so we don't cause any extra hijinks.
			VMP = VMDBufferPlayer(Player);
			if (VMP != None)
			{
				VMP.BloodSmellLevel = 0;
				VMP.HungerTimer = 0;
				
				OldScrap = VMP.CurScrap;
				OldChem = VMP.CurChemicals;
				
				if (OldScrap > 0)
				{
					TScrap = Spawn(class'VMDScrapMetal');
					TScrap.NumCopies = OldScrap;
					TScrap.SpawnCopy(Player);
				}
				if (OldChem > 0)
				{
					TChem = Spawn(class'VMDChemicals');
					TChem.NumCopies = OldChem;
					TChem.SpawnCopy(Player);
				}
				
				VMP.CurScrap = 0;
				VMP.CurChemicals = 0;
				
				VMDTransferDroneToItem(VMP);
			}
			
			if (Player.Inventory != None)
			{
				CurLap = 0;
				ContinueItem = Player.Inventory;
				while (ContinueItem != None)
				{
					switch(CurLap)
					{
						case 0:
							LocationMod = vect(0, 0, 0);
						break;
						case 1:
							LocationMod = vect(-40, 0, 0);
						break;
						case 2:
							LocationMod = vect(40, 0, 0);
						break;
					}
					
					VMDDumpItems(ContinueItem, Player, ContinueItem, LocationMod);
					CurLap = (CurLap+1) % 3;
				}
			}
			
			flags.SetBool('MS_InventoryRemoved', True,, 6);
		}
		
		// make Anna not flee in this mission
		foreach AllActors(class'AnnaNavarre', Anna)
		{
			if (!flags.GetBool('VMD_AnnaMJ12Goodies'))
			{
				Anna.bAugsGuardDown = True;
				flags.SetBool('VMD_AnnaMJ12Goodies', True,, 6);
			}
		}
	}
	else if (localURL == "05_NYC_UNATCOHQ")
	{
		// if Miguel is following the player, unhide him
		if (flags.GetBool('MiguelFollowing'))
		{
			foreach AllActors(class'Terrorist', T)
				if (T.BindName == "Miguel")
					T.EnterWorld();
		}

		// make Anna not flee in this mission
		foreach AllActors(class'AnnaNavarre', Anna)
		{
			Anna.MinHealth = 0;
			
			if (!flags.GetBool('VMD_AnnaUNATCO5Goodies'))
			{
				Anna.AddToInitialInventory(class'BioelectricCell', 5);
				flags.SetBool('VMD_AnnaUNATCO5Goodies', True,, 6);
			}
		}
	}
	else if (localURL == "05_NYC_UNATCOISLAND")
	{
		// if Miguel is following the player, unhide him
		if (flags.GetBool('MiguelFollowing'))
		{
			foreach AllActors(class'Terrorist', T)
				if (T.BindName == "Miguel")
					T.EnterWorld();
		}
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	Super.PreTravel();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local AnnaNavarre Anna;
	local DatalinkTrigger DT;
	local DeusExMover M;
	local WaltonSimons Walton;

	Super.Timer();

	if (localURL == "05_NYC_UNATCOHQ")
	{
		// unlock a door
		if (flags.GetBool('CarterUnlock') &&
			!flags.GetBool('MS_DoorUnlocked'))
		{
			foreach AllActors(class'DeusExMover', M, 'supplydoor')
			{
				M.bLocked = False;
				M.lockStrength = 0.0;
			}

			flags.SetBool('MS_DoorUnlocked', True,, 6);
		}

		// kill Anna when a flag is set
		if (flags.GetBool('annadies') &&
			!flags.GetBool('MS_AnnaKilled'))
		{
			foreach AllActors(class'AnnaNavarre', Anna)
			{
				Anna.HealthTorso = 0;
				Anna.Health = 0;
				Anna.TakeDamage(1, Anna, Anna.Location, vect(0,0,0), 'Shot');
			}

			flags.SetBool('MS_AnnaKilled', True,, 6);
		}

		// make Anna attack the player after a convo is played
		if (flags.GetBool('M05AnnaAtExit_Played') &&
			!flags.GetBool('MS_AnnaAttacking'))
		{
			foreach AllActors(class'AnnaNavarre', Anna)
				Anna.SetOrders('Attacking', '', True);

			flags.SetBool('MS_AnnaAttacking', True,, 6);
		}

		// unhide Walton Simons
		if (flags.GetBool('simonsappears') &&
			!flags.GetBool('MS_SimonsUnhidden'))
		{
			foreach AllActors(class'WaltonSimons', Walton)
			{
				Walton.EnterWorld();
				Walton.bLookingForEnemy = false;
				Walton.bLookingForLoudNoise = false;
				Walton.bLookingForAlarm = false;
				Walton.bLookingForDistress = false;
				Walton.bLookingForProjectiles = false;
				Walton.bLookingForShot = false;
				Walton.bLookingForInjury = false;
				Walton.bLookingForIndirectInjury = false;
			}
			flags.SetBool('MS_SimonsUnhidden', True,, 6);
		}

		// hide Walton Simons
		if ((flags.GetBool('M05MeetManderley_Played') ||
			flags.GetBool('M05SimonsAlone_Played')) &&
			!flags.GetBool('MS_SimonsHidden'))
		{
			foreach AllActors(class'WaltonSimons', Walton)
				Walton.LeaveWorld();

			flags.SetBool('MS_SimonsHidden', True,, 6);
		}

		// mark a goal as completed
		if (flags.GetBool('KnowsAnnasKillphrase1') &&
			flags.GetBool('KnowsAnnasKillphrase2') &&
			!flags.GetBool('MS_KillphraseGoalCleared'))
		{
			Player.GoalCompleted('FindAnnasKillphrase');
			flags.SetBool('MS_KillphraseGoalCleared', True,, 6);
		}

		// clear a goal when anna is out of commision
		if (flags.GetBool('AnnaNavarre_Dead') &&
			!flags.GetBool('MS_EliminateAnna'))
		{
			Player.GoalCompleted('EliminateAnna');
			flags.SetBool('MS_EliminateAnna', True,, 6);
		}
	}
	else if (localURL == "05_NYC_UNATCOMJ12LAB")
	{
		// After the player talks to Paul, start a datalink
		if (!flags.GetBool('MS_DL_Played') &&
			flags.GetBool('PaulInMedLab_Played'))
		{
			//MADDERS, 5/21/25: Call the trigger like so, so Paul's alive datalink actually calls its skill award. Thanks.
			//Player.StartDataLinkTransmission("DL_Paul");
			forEach AllActors(class'DatalinkTrigger', DT, 'DL_Paul')
			{
				DT.Trigger(None, Player);
			}
			flags.SetBool('MS_DL_Played', True,, 6);
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDItemShouldBeSkipped(DeusExPlayer Player, Inventory Inv)
{
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local Inventory TItem;
	
	//MADDERS, 5/16/22: Luckily, Player and Inv is never going to be "None".
	if (Inv.IsA('NanoKeyRing')) return true;
	
	DXA = DeusExAmmo(Inv);
	if ((DXA != None) && (DXA.AmmoAmount == 0))
	{
		return true;
	}
	else if (!Inv.bDisplayableInv)
	{
		if ((DXA != None) && (Player.Inventory != None) && (DXA.PickupViewMesh != LODMesh'DeusExItems.TestBox'))
		{
			for(TItem = Player.Inventory; TItem != None; TItem = TItem.Inventory)
			{
				//Oh hello, little LAM.
				DXW = DeusExWeapon(TItem);
				if ((DXW != None) && (DXW.AmmoType == Inv) && (DXW.Default.Icon == DXA.Default.Icon))
				{
					return true;
				}
			}
			return false;
		}
		else
		{
			return true;
		}
	}
	
	return false;
}

function VMDDumpItems(out Inventory ContinueItem, DeusExPlayer Player, Inventory StartInv, Vector LocationMod)
{
	local Inventory item, nextItem;
	local SpawnPoint SP, LastSP;
	local DeusExAmmo DXA;
	local DeusExPickup DXP;
	local DeusExWeapon DXw;
	
	item = StartInv;
	nextItem = None;
	ContinueItem = None;
	
	foreach AllActors(class'SpawnPoint', SP, 'player_inv')
	{
		// Find the next item we can process.
		while((item != None) && (VMDItemShouldBeSkipped(Player, Item)))
		{
			item = item.Inventory;
		}
		if (item != None)
		{
			if (ChargedPickup(Item) != None)
			{
				Player.RemoveChargedDisplay(ChargedPickup(Item));
			}
			
			nextItem = item.Inventory;
			Player.DeleteInventory(item);
			
			if (!Item.SetLocation(SP.Location + LocationMod))
			{
				item.DropFrom(SP.Location);
			}
			else
			{
				Item.DropFrom(SP.Location + LocationMod);
			}
			DXA = DeusExAmmo(Item);
			DXP = DeusExPickup(Item);
			DXW = DeusExWeapon(Item);
			
			// restore any ammo amounts for a weapon to default
			// Transcended - Except these
			//-------------------------
			//MADDERS, 5/16/22: Annotation pileup. I know. However, here's the strat:
			//Leave grenades and throwing knives and shit as having their ammo on them.
			//Set anything else to 0, since its ammo will be being dumped out in short order.
			if (DXA != None)
			{
				DXA.bCrateSummoned = true; //MADDERS, 12/3/23: Stop swapping out existing ammos, thank you.
			}
			else if (DXW != None)
			{
				DXw.bReloadWasntEmpty = True; //MADDERS, 2/23/25: No empty mags when reloading from unloaded weapons in armory.
				
				DXW.bRotatedInInventory = false;
				if (DXW.bLasing) DXW.LaserOff();
				if (DXW.bZoomed) DXW.ScopeOff();
				
				if (DXW.AmmoType != None)
				{
					//Also, don't do this to LAW.
					if ((!DXW.VMDHasJankyAmmo()) && (DXW.ReloadCount > 0))
					{
						//MADDERS: Just set pickup ammo count to nil.
						DXW.PickupAmmoCount = 0;
						DXW.ClipCount = DXW.ReloadCount;
					}
				}
			}
			else if (DXP != None)
			{
				DXP.bRotatedInInventory = false;
				if (VMDScrapMetal(Item) != None)
				{
					VMDScrapMetal(Item).UpdateModel();
				}
				else if (VMDChemicals(Item) != None)
				{
					VMDChemicals(Item).UpdateModel();
				}
			}
		}
		
		if (nextItem == None)
		{
			ContinueItem = None;
			break;
		}
		else
		{
			ContinueItem = NextItem;
			item = nextItem;
		}
	}
}

function VMDTransferDroneToItem(VMDBufferPlayer VMP)
{
	
}

defaultproperties
{
}
