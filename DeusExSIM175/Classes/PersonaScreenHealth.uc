//=============================================================================
// PersonaScreenHealth
//=============================================================================
class PersonaScreenHealth extends PersonaScreenBaseWindow;

var PersonaActionButtonWindow   btnHealAll;
var PersonaInfoWindow           winInfo;
var PersonaItemDetailWindow     winMedKits;
var PersonaHealthItemButton     selectedHealthButton;
var PersonaOverlaysWindow       winOverlays;
var PersonaHealthBodyWindow     winBody;

var PersonaHealthItemButton   partButtons[6];
var PersonaHealthRegionWindow regionWindows[6];
var localized String          HealthPartDesc[4];
var Float                     playerHealth[6];

var Bool bShowHealButtons;

var localized String MedKitUseText;
var localized String HealthTitleText;
var localized String HealAllButtonLabel;
var localized String HealthLocationHead;
var localized String HealthLocationTorso;
var localized String HealthLocationRightArm;
var localized String HealthLocationLeftArm;
var localized String HealthLocationRightLeg;
var localized String HealthLocationLeftLeg;
var localized String PointsHealedLabel;

//MADDERS additions.
var bool bShowingStatuses;

var PersonaActionButtonWindow BtnShowHealthInfo, BtnShowStatInfo;
var localized string ShowHealthInfoLabel, ShowStatInfoLabel,
			StrStatusTitle,
			StrOverdoseDesc[4],
			StrPoisonDesc[2], StrFireDesc[2], StrNanoVirusDesc[2],
			StrKillswitchDesc[9],
			StrMayhemDesc[3],
			StrHungerDesc[3],
			StrBloodSmellDesc[4], StrFoodSmellDesc[6],
			StrAddictionDesc[4], StrWithdrawalDesc[5], StrSubstanceNames[6],
			StrCombatStimDesc[3], StrPharmacistDesc[2], StrSodaBuffDesc[2], StrCandyBuffDesc[2], StrCigarettesBuffDesc[2], StrZymeBuffDesc[2],
			StrAdaptiveArmorDesc[2], StrBallisticArmorDesc[2], StrHazmatSuitDesc[2], StrRebreatherDesc[2], StrTechGogglesDesc[2],
			StrInebriationDesc[2],
			StrRollCooldownDesc[2],
			StrStressDesc[8], StrStressModifiers[23];

struct VMDButtonPos {
	var int X;
	var int Y;
};

var VMDButtonPos NewInfoOffset, ShowHealthInfoPos, ShowStatInfoPos;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	EnableButtons();
	
	if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bShowHealthStatuses || IsA('HUDMedBotHealthScreen')))
	{
		bShowingStatuses = true;
		VMDShowStatusInfo();
	}
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	CreateTitleWindow(9, 5, HealthTitleText);
	CreateInfoWindow();
	CreateOverlaysWindow();
	CreateBodyWindow();
	CreateRegionWindows();
	CreateButtons();
	CreateMedKitWindow();
	CreatePartButtons();
	CreateStatusWindow();
	
	CreateVMDButtons();
	
	PersonaNavBarWindow(winNavBar).btnHealth.SetSensitivity(False);
}

// ----------------------------------------------------------------------
// CreateStatusWindow()
// ----------------------------------------------------------------------

function CreateStatusWindow()
{
	winStatus = PersonaStatusLineWindow(winClient.NewChild(Class'PersonaStatusLineWindow'));
	winStatus.SetPos(348+NewInfoOffset.X, 269+NewInfoOffset.Y);
	WinStatus.SetMaxLines(1);
}

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	winInfo = PersonaInfoWindow(winClient.NewChild(Class'PersonaInfoWindow'));
	winInfo.SetPos(348+NewInfoOffset.X, 22+NewInfoOffset.Y);
	winInfo.SetSize(238, 239);
}

// ----------------------------------------------------------------------
// CreateButtons()
// ----------------------------------------------------------------------

function CreateButtons()
{
	local PersonaButtonBarWindow winActionButtons;

	winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(13, 407);
	winActionButtons.SetWidth(92);
	winActionButtons.FillAllSpace(False);

	btnHealAll = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnHealAll.SetButtonText(HealAllButtonLabel);
}

// ----------------------------------------------------------------------
// CreateMedKitWindow()
// ----------------------------------------------------------------------

function CreateMedKitWindow()
{
	winMedKits = PersonaItemDetailWindow(winClient.NewChild(Class'PersonaItemDetailWindow'));
	winMedKits.SetPos(346+NewInfoOffset.X, 307+NewInfoOffset.Y);
	winMedKits.SetWidth(242);
	winMedKits.SetIcon(Class'MedKit'.Default.LargeIcon);
	winMedKits.SetIconSize(
		Class'MedKit'.Default.largeIconWidth,
		Class'MedKit'.Default.largeIconHeight);

	UpdateMedKits();
}

// ----------------------------------------------------------------------
// CreatePartButtons()
// ----------------------------------------------------------------------

function CreatePartButtons()
{
	partButtons[0] = CreatePartButton(0, 141,  42, 40, 54, HealthPartDesc[0], HealthLocationHead);
	partButtons[1] = CreatePartButton(1, 133,  98, 56, 73, HealthPartDesc[1], HealthLocationTorso);
	partButtons[2] = CreatePartButton(2,  90, 131, 28, 65, HealthPartDesc[2], HealthLocationRightArm);
	partButtons[3] = CreatePartButton(3, 204, 131, 28, 65, HealthPartDesc[2], HealthLocationLeftArm);
	partButtons[4] = CreatePartButton(4, 119, 234, 41, 94, HealthPartDesc[3], HealthLocationRightLeg);
	partButtons[5] = CreatePartButton(5, 162, 234, 41, 94, HealthPartDesc[3], HealthLocationLeftLeg);
}

// ----------------------------------------------------------------------
// CreatePartButton()
// ----------------------------------------------------------------------

function PersonaHealthItemButton CreatePartButton(
	int partIndex,
	int posX, int posY, 
	int sizeX, int sizeY, 
	String partDesc, String partTitle)
{
	local PersonaHealthItemButton newPart;

	newPart = PersonaHealthItemButton(winClient.NewChild(Class'PersonaHealthItemButton'));
	newPart.SetPos(posX, posY);
	newPart.SetSize(sizeX, sizeY);
	newPart.SetBorderSize(sizeX, sizeY);
	newPart.SetDesc(partDesc);
	newPart.SetTitle(partTitle);

	return newPart;
}

// ----------------------------------------------------------------------
// CreateRegionWindows()
// ----------------------------------------------------------------------

function CreateRegionWindows()
{
	local float TMult;
	
	TMult = 1.0;
	if (VMDBufferPlayer(Player) != None)
	{
		TMult = VMDBufferPlayer(Player).KSHealthMult;
		
		if (VMDBufferPlayer(Player).ModHealthMultiplier > 0)
		{
			TMult *= VMDBufferPlayer(Player).ModHealthMultiplier;
		}
	}
	regionWindows[0] = CreateRegionWindow(0, 218,  29, player.HealthHead,     float(player.default.HealthHead)*TMult,     HealthLocationHead);
	regionWindows[1] = CreateRegionWindow(1,  27,  43, player.HealthTorso,    float(player.default.HealthTorso)*TMult,    HealthLocationTorso);
	regionWindows[2] = CreateRegionWindow(2,  19, 237, player.HealthArmRight, float(player.default.HealthArmRight)*TMult, HealthLocationRightArm);
	regionWindows[3] = CreateRegionWindow(3, 230, 237, player.HealthArmLeft,  float(player.default.HealthArmLeft)*TMult,  HealthLocationLeftArm);
	regionWindows[4] = CreateRegionWindow(4,  24, 347, player.HealthLegRight, float(player.default.HealthLegRight)*TMult, HealthLocationRightLeg);
	regionWindows[5] = CreateRegionWindow(5, 222, 347, player.HealthLegLeft,  float(player.default.HealthLegLeft)*TMult,  HealthLocationLeftLeg);
}

// ----------------------------------------------------------------------
// CreateRegionWindow()
// ----------------------------------------------------------------------

function PersonaHealthRegionWindow CreateRegionWindow(
	int partIndex,
	int posX, int posY, 
	int healthValue, int maxHealthValue, 
	String partTitle)
{
	local PersonaHealthRegionWindow newRegion;

	newRegion = PersonaHealthRegionWindow(winClient.NewChild(Class'PersonaHealthRegionWindow'));
	newRegion.SetPos(posX, posY);
	newRegion.SetMaxHealth(maxHealthValue);
	newRegion.SetHealth(healthValue);
	newRegion.SetPartIndex(partIndex);
	newRegion.SetTitle(partTitle);
	newRegion.ShowHealButton(bShowHealButtons);
	newRegion.Raise();

	return newRegion;
}

// ----------------------------------------------------------------------
// UpdateRegionWindows()
// ----------------------------------------------------------------------

function UpdateRegionWindows()
{
	local int partIndex;

	for(partIndex=0; partIndex<arrayCount(regionWindows); partIndex++)
		regionWindows[partIndex].Destroy();

	CreateRegionWindows();
}

// ----------------------------------------------------------------------
// CreateBodyWindow()
// ----------------------------------------------------------------------

function CreateBodyWindow()
{
	winBody = PersonaHealthBodyWindow(winClient.NewChild(Class'PersonaHealthBodyWindow'));
	winBody.SetPos(24, 36);
	winBody.Lower();
}

// ----------------------------------------------------------------------
// CreateOverlaysWindow()
// ----------------------------------------------------------------------

function CreateOverlaysWindow()
{
	winOverlays = PersonaOverlaysWindow(winClient.NewChild(Class'PersonaHealthOverlaysWindow'));
	winOverlays.SetPos(24, 36);
	winOverlays.Lower();
}

// ----------------------------------------------------------------------
// UpdateMedKits()
// ----------------------------------------------------------------------

function UpdateMedKits()
{
	local MedKit medKit;

	if (winMedKits != None)
	{
		winMedKits.SetText(MedKitUseText);

		medKit = MedKit(player.FindInventoryType(Class'MedKit'));

		if (medKit != None)
			winMedKits.SetCount(medKit.NumCopies);
		else
			winMedKits.SetCount(0);	
	}
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated(Window buttonPressed)
{
	local bool bHandled;
	local int pointsHealed;
	local VMDBufferPlayer VMP;
	local float ModMult;
	
	//MADDERS: Ported health region washover code.
	local int HealLevel, THeal, BaseHeal;
	local int TIndex;

	if (Super.ButtonActivated(buttonPressed))
		return True;

	bHandled = True;
	
	VMP = VMDBufferPlayer(Player);
	
	// Check if this is one of our Augmentation buttons
	if (buttonPressed.IsA('PersonaHealthItemButton'))
	{
		SelectHealth(PersonaHealthItemButton(buttonPressed));
	}
	else if (buttonPressed.IsA('PersonaHealthActionButtonWindow'))
	{
		PushHealth();
		
		//MADDERS: Run a quick calc on how much healing we need.
		HealLevel = player.CalculateSkillHealAmount(class'Medkit'.Default.HealAmount);
		BaseHeal = HealLevel;
		
		//MADDERS...
		//A man heals limb X by 36 points, limb X has 60 health.
		//-Heal Level = 36
		//-THeal = min of 100-PlayerHealthHead vs 36
		//-THeal is 36.
		//-36 - 36 = 0
		
		//MADDERS, 12/21/21: Now scale with mod stuff, too.
		ModMult = 1.0;
		if (VMP != None)
		{
			if (VMP.ModHealthMultiplier > 0)
			{
				ModMult *= VMP.ModHealthMultiplier;
			}
			if (VMP.KSHealthMult < 1.0)
			{
				ModMult *= VMP.KSHealthMult;
			}
		}
		
		switch(PersonaHealthActionButtonWindow(buttonPressed).GetPartIndex())
		{
			case 0:		// head
				THeal = Min(float(Player.Default.HealthHead) * ModMult - Player.HealthHead, HealLevel);
				TIndex = 0;
			break;
			case 1:		// torso, right arm, left arm
				THeal = Min(float(Player.Default.HealthTorso) * ModMult - Player.HealthTorso, HealLevel);
				TIndex = 1;
			break;
			case 2:		//right arm, left arm
				THeal = Min(float(Player.Default.HealthArmRight) * ModMult - Player.HealthArmRight, HealLevel);
				TIndex = 2;
			break;
			case 3:
				THeal = Min(float(Player.Default.HealthArmLeft) * ModMult - Player.HealthArmLeft, HealLevel);
				TIndex = 3;
			break;
			case 4:		// right leg, left leg
				THeal = Min(float(Player.Default.HealthLegRight) * ModMult - Player.HealthLegRight, HealLevel);
				TIndex = 4;
			break;
			case 5:
				THeal = Min(float(Player.Default.HealthLegLeft) * ModMult - Player.HealthLegLeft, HealLevel);
				TIndex = 5;
			break;
		}
		//MADDERS: Reduce how much healing we're using by how much is used.
		HealLevel -= THeal;
		
		pointsHealed = HealPart(regionWindows[PersonaHealthActionButtonWindow(buttonPressed).GetPartIndex()]);
		player.PopHealth( playerHealth[0],playerHealth[1],playerHealth[2],playerHealth[3],playerHealth[4],playerHealth[5]);
		player.GenerateTotalHealth(); // Transcended - Added
		
		//MADDERS: Rollover, bby. Now related to the skill augment.
		if ((THeal < BaseHeal) && (VMP != None) && (VMP.HasSkillAugment("MedicineWraparound")))
		{
		 	VMDBufferPlayer(player).HealPlayerSilent(HealLevel, False);
		 	PlayerHealth[0] = player.HealthHead;
		 	PlayerHealth[1] = player.HealthTorso;
		 	PlayerHealth[2] = player.HealthArmRight;
		 	PlayerHealth[3] = player.HealthArmLeft;
		 	PlayerHealth[4] = player.HealthLegRight;
		 	PlayerHealth[5] = player.HealthLegLeft;
		 	
	 	 	for (TIndex=0; TIndex<6; TIndex++)
		 	{
		  		regionWindows[TIndex].SetHealth(PlayerHealth[TIndex]);
		 	}
		}
		
		//MADDERS, 5/26/20: Run this afterwards to un-bork healing to direct parts after killswitch has lowered HP.
		if (VMP != None)
		{
			VMP.UpdateKillswitchHealth(VMP.KillswitchTime);
		}
		
		if (WinStatus != None)
		{
		 	if (HealLevel > 0) winStatus.AddText(Sprintf(PointsHealedLabel, BaseHeal));
		 	else winStatus.AddText(Sprintf(PointsHealedLabel, BaseHeal));
			
			//MADDERS: Readout the above shit now, instead.
			//winStatus.AddText(Sprintf(PointsHealedLabel, pointsHealed));
		}
		EnableButtons();
		
		//MADDERS, 6/5/22: Update status info. Groovy.
		if (bShowingStatuses)
		{
			VMDShowStatusInfo();
		}
	}
	else if (buttonPressed.GetParent().IsA('PersonaHealthRegionWindow'))
	{
		partButtons[PersonaHealthRegionWindow(buttonPressed.GetParent()).GetPartIndex()].PressButton(IK_None);
	}
	else
	{
		switch(buttonPressed)
		{
			case btnHealAll:
				HealAllParts();
			break;
			case BtnShowHealthInfo:
				bShowingStatuses = False;
				if (VMDBufferPlayer(Player) != None)
				{
					VMDBufferPlayer(Player).bShowHealthStatuses = false;
					VMDBufferPlayer(Player).SaveConfig();
				}
				
				if (SelectedHealthButton != None)
				{
					selectedHealthButton.SelectButton(True);
					
					// Update the display
					winInfo.SetTitle(selectedHealthButton.GetTitle());
					winInfo.SetText(selectedHealthButton.GetDesc());
				}
				else
				{
					WinInfo.SetTitle("");
					WinInfo.Clear();
				}
			break;
			case BtnShowStatInfo:
				bShowingStatuses = True;
				if (VMDBufferPlayer(Player) != None)
				{
					VMDBufferPlayer(Player).bShowHealthStatuses = true;
					VMDBufferPlayer(Player).SaveConfig();
				}
				VMDShowStatusInfo();
			break;
			default:
				bHandled = False;
			break;
		}
	}

	return bHandled;
}

// ----------------------------------------------------------------------
// SelectHealth()
// ----------------------------------------------------------------------

function SelectHealth(PersonaHealthItemButton buttonPressed)
{
	// Don't do extra work.
	if (selectedHealthButton != buttonPressed)
	{
		// Deselect current button
		if (selectedHealthButton != None)
		{
			selectedHealthButton.SelectButton(False);
		}
		
		selectedHealthButton = buttonPressed;
		selectedHealthButton.SelectButton(True);
		
		if (!bShowingStatuses)
		{
			// Update the display
			winInfo.SetTitle(selectedHealthButton.GetTitle());
			winInfo.SetText(selectedHealthButton.GetDesc());
		}
		
		EnableButtons();
	}
}

// ----------------------------------------------------------------------
// PushHealth()
// ----------------------------------------------------------------------

function PushHealth()
{
	playerHealth[0] = player.HealthHead;
	playerHealth[1] = player.HealthTorso;
	playerHealth[2] = player.HealthArmRight;
	playerHealth[3] = player.HealthArmLeft;
	playerHealth[4] = player.HealthLegRight;
	playerHealth[5] = player.HealthLegLeft;
}

// ----------------------------------------------------------------------
// HealAllParts()
//
// Uses as many medkits as possible to heal as much damage.  Health
// points are distributed evenly among parts
// ----------------------------------------------------------------------

function int HealAllParts()
{
	local MedKit medkit;
	local int    healPointsAvailable;
	local int    healPointsRemaining;
	local int    pointsHealed;
	local int    regionIndex;
	local float  damageAmount;
	local bool   bPartDamaged;
	
	pointsHealed = 0;
	PushHealth();
	
	// First determine how many medkits the player has
	healPointsAvailable = GetMedKitHealPoints();
	healPointsRemaining = healPointsAvailable;
	
	// Now loop through all the parts repeatedly until 
	// we either:
	// 
	// A) Run out of parts to heal or 
	// B) Run out of points to distribute.
	
	while(healPointsRemaining > 0) 
	{
		bPartDamaged = False;

		// Loop through all the parts
		for(regionIndex=0; regionIndex<arrayCount(regionWindows); regionIndex++)
		{
			damageAmount = regionWindows[regionIndex].maxHealth - regionWindows[regionIndex].currentHealth;

			if ((damageAmount > 0) && (healPointsRemaining > 0))
			{
				// Heal this part
				pointsHealed += HealPart(regionWindows[regionIndex], 1, True);

				healPointsRemaining--;
				bPartDamaged = True;
			}
		}

		if (!bPartDamaged)
			break;
	}
		
	// Now remove any medkits we may have used
	RemoveMedKits(healPointsAvailable - healPointsRemaining);

	player.PopHealth( playerHealth[0],playerHealth[1],playerHealth[2],playerHealth[3],playerHealth[4],playerHealth[5]);
	player.GenerateTotalHealth(); // Transcended - Added

	EnableButtons();
	
	//MADDERS, 6/5/22: Update status info. Groovy.
	if (bShowingStatuses)
	{
		VMDShowStatusInfo();
	}

	winStatus.AddText(Sprintf(PointsHealedLabel, pointsHealed));

	return pointsHealed;
}

// ----------------------------------------------------------------------
// GetMedKitHealPoints()
// ----------------------------------------------------------------------

function int GetMedKitHealPoints()
{
	local MedKit medkit;

	medKit = MedKit(player.FindInventoryType(Class'MedKit'));

	if (medKit != None)
		return player.CalculateSkillHealAmount(medKit.NumCopies * medKit.healAmount);
	else
		return 0;
}

// ----------------------------------------------------------------------
// RemoveMedKits
// ----------------------------------------------------------------------

function RemoveMedKits(int healPointsUsed)
{
	local MedKit medkit;
	local int    healPointsRemaining;

	healPointsRemaining = healPointsUsed;
	medKit = MedKit(player.FindInventoryType(Class'MedKit'));

	while((medKit != None) && (healPointsRemaining > 0))
	{
		healPointsRemaining -= player.CalculateSkillHealAmount(medkit.healAmount);
		UseMedKit(medkit);
		medKit = MedKit(player.FindInventoryType(Class'MedKit'));
	}
}

// ----------------------------------------------------------------------
// HealPart()
//
// Returns the amount of damage healed
// ----------------------------------------------------------------------

function int HealPart(PersonaHealthRegionWindow region, optional float pointsToHeal, optional bool bLeaveMedKit)
{
	local float healthAdded, newHealth;
	local medKit medKit;
	
	local float ModMult;

	// First make sure the player has a medkit
	medKit = MedKit(player.FindInventoryType(Class'MedKit'));
	
	if ((region == None) || (medKit == None))
		return 0;

	// If a point value was passesd in, use it as the amount of 
	// points to heal for this body part.  Otherwise use the 
	// medkit's default heal amount.

	if (pointsToHeal == 0)
		pointsToHeal = player.CalculateSkillHealAmount(medKit.healAmount);
	
	// Heal the selected body part by the number of 
	// points available in the part
	
	ModMult = 1.0;
	if (VMDBufferPlayer(Player) != None)
	{
		if (VMDBufferPlayer(Player).ModHealthMultiplier > 0)
		{
			ModMult *= VMDBufferPlayer(Player).ModHealthMultiplier;
		}
		if (VMDBufferPlayer(Player).KSHealthMult < 1.0)
		{
			ModMult *= VMDBufferPlayer(Player).KSHealthMult;
		}
	}
	
	// If our player is in a multiplayer game, heal across 3 hit locations
	if ( player.PlayerIsClient() )
	{
		switch(region.GetPartIndex())
		{
			case 0:		// head
				newHealth = FMin(playerHealth[0] + pointsToHeal, float(player.default.HealthHead) * ModMult);
				healthAdded = newHealth - playerHealth[0];
				playerHealth[0] = newHealth;
			break;
			case 1:		// torso, right arm, left arm
			case 2:
			case 3:
				pointsToHeal *= 0.333;	// Divide heal points among parts
				newHealth = FMin(playerHealth[1] + pointsToHeal, float(player.default.HealthTorso) * ModMult);
				healthAdded = newHealth - playerHealth[1];
				playerHealth[1] = newHealth;
				regionWindows[1].SetHealth(newHealth);
				newHealth = FMin(playerHealth[2] + pointsToHeal, float(player.default.HealthArmRight) * ModMult);
				healthAdded = newHealth - playerHealth[2];
				playerHealth[2] = newHealth;
				regionWindows[2].SetHealth(newHealth);
				newHealth = FMin(playerHealth[3] + pointsToHeal, float(player.default.HealthArmLeft) * ModMult);
				healthAdded = newHealth - playerHealth[3];
				playerHealth[3] = newHealth;
				regionWindows[3].SetHealth(newHealth);
			break;
			case 4:		// right leg, left leg
			case 5:
				pointsToHeal *= 0.5;		// Divide heal points among parts
				newHealth = FMin(playerHealth[4] + pointsToHeal, float(player.default.HealthLegRight) * ModMult);
				healthAdded = newHealth - playerHealth[4];
				playerHealth[4] = newHealth;
				regionWindows[4].SetHealth(newHealth);
				newHealth = FMin(playerHealth[5] + pointsToHeal, float(player.default.HealthLegLeft) * ModMult);
				healthAdded = newHealth - playerHealth[5];
				playerHealth[5] = newHealth;
				regionWindows[5].SetHealth(newHealth);
			break;
		}
	}
	else
	{
		switch(region.GetPartIndex())
		{
			case 0:		// head
				newHealth = FMin(playerHealth[0] + pointsToHeal, float(player.default.HealthHead) * ModMult);
				healthAdded = newHealth - playerHealth[0];
				playerHealth[0] = newHealth;
			break;
			case 1:		// torso
				newHealth = FMin(playerHealth[1] + pointsToHeal, float(player.default.HealthTorso) * ModMult);
				healthAdded = newHealth - playerHealth[1];
				playerHealth[1] = newHealth;
			break;
			case 2:		// right arm
				newHealth = FMin(playerHealth[2] + pointsToHeal, float(player.default.HealthArmRight) * ModMult);
				healthAdded = newHealth - playerHealth[2];
				playerHealth[2] = newHealth;
			break;
			case 3:		// left arm
				newHealth = FMin(playerHealth[3] + pointsToHeal, float(player.default.HealthArmLeft) * ModMult);
				healthAdded = newHealth - playerHealth[3];
				playerHealth[3] = newHealth;
			break;
			case 4:		// right leg
				newHealth = FMin(playerHealth[4] + pointsToHeal, float(player.default.HealthLegRight) * ModMult);
				healthAdded = newHealth - playerHealth[4];
				playerHealth[4] = newHealth;
			break;
			case 5:		// left leg
				newHealth = FMin(playerHealth[5] + pointsToHeal, float(player.default.HealthLegLeft) * ModMult);
				healthAdded = newHealth - playerHealth[5];
				playerHealth[5] = newHealth;
			break;
		}
	}
	
	region.SetHealth(newHealth);
	
	// Remove the item from the player's invenory and this screen
	if (!bLeaveMedKit)
	{
		UseMedKit(medkit);
	}
	else
	{
		if (VMDBufferPlayer(Player) != None)
		{
			VMDBufferPlayer(Player).VMDRegisterFoodEaten(0, "Medkit");
		}
	}
	
	return healthAdded;
}

// ----------------------------------------------------------------------
// UseMedKit()
// ----------------------------------------------------------------------

function UseMedKit(MedKit medkit)
{
	if (medKit != None)
	{
		if (VMDBufferPlayer(Player) != None)
		{
			Medkit.VMDRunMedkitShellEffects(VMDBufferPlayer(Player));
		}
		medKit.UseOnce();
		UpdateMedKits();

		EnableButtons();
	}
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	local int regionIndex;
	local medKit medKit;

	// First make sure the player has a medkit
	medKit = MedKit(player.FindInventoryType(Class'MedKit'));

	// Heal All button available as long as one or more
	// parts is damaged and the player has at least one
	// kit

	btnHealAll.EnableWindow((medKit != None) && (IsPlayerDamaged()));

	// Loop through the region windows, since they have Heal buttons
	// attached to them
	for (regionIndex=0; regionIndex<arrayCount(regionWindows); regionIndex++)
		regionWindows[regionIndex].EnableButtons();
}

// ----------------------------------------------------------------------
// IsPlayerDamaged()
//
// Looks at all the player's parts to see if he/she/it is damaged
// ----------------------------------------------------------------------

function bool IsPlayerDamaged()
{
	local int regionIndex;
	local bool bDamaged;

	bDamaged = False;

	for(regionIndex=0; regionIndex<arrayCount(regionWindows); regionIndex++)
	{
		if (regionWindows[regionIndex].maxHealth > regionWindows[regionIndex].currentHealth)
		{
			bDamaged = True;
			break;
		}
	}

	return bDamaged;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function CreateVMDButtons()
{
	BtnShowHealthInfo = PersonaActionButtonWindow(NewChild(Class'PersonaActionButtonWindow'));
	BtnShowHealthInfo.SetButtonText(ShowHealthInfoLabel);
	BtnshowHealthInfo.SetPos(ShowHealthInfoPos.X, ShowHealthInfoPos.Y);
	
	BtnShowStatInfo = PersonaActionButtonWindow(NewChild(Class'PersonaActionButtonWindow'));
	BtnShowStatInfo.SetButtonText(ShowStatInfoLabel);
	BtnshowStatInfo.SetPos(ShowStatInfoPos.X, ShowStatInfoPos.Y);
}

function VMDShowStatusInfo()
{
	local int OverdoseDamage,
		BurnDamage, BurnTimeInt,
		KSTimeLeftInt, KSSteps,
		HungerTimeLeftInt, HungerPercentInt, HungerDamageInt,
		MayhemMod, MayhemForgive,
		SmellUnits, SmellUnitsThresh[2], SkillLevel,
		i;
	local float OverdoseWeight, BurnTime, KSTime, KSTimeLeft, HungerTimeLeft, HungerPercent, SmellMults[2], DMult, SkillValue, SkillValue2, TMath;
	local string TStr[2], KSBarfStr[2], StressBarfStr;
	local VMDBufferPlayer VMP;
	local VMDFakeBuffAura Auras[6];
	local ChargedPickup TPickup;
	
	VMP = VMDBufferPlayer(Player);
	if (WinInfo == None || VMP == None) return;
	
	SkillValue = 1.0;
	if (VMP.SkillSystem != None)
	{
		skillValue = VMP.SkillSystem.GetSkillLevelValue(class'SkillEnviro');
	}
	SkillValue2 = (SkillValue + 1.0) / 2;
	
	DMult = 1.0;
	if (VMP.CombatDifficulty < 1.0) DMult = VMP.CombatDifficulty;
		
	if (VMP.Level.NetMode != NM_Standalone)
	{
		BurnTime = Class'WeaponFlamethrower'.Default.MPBurnTime;
		BurnDamage = Class'WeaponFlamethrower'.Default.MPBurnDamage;
	}
	else
	{
		BurnTime = Class'WeaponFlamethrower'.Default.BurnTime;
		BurnDamage = Class'WeaponFlamethrower'.Default.BurnDamage;
	}
	
	if (!VMP.bOnFire)
	{
		BurnTimeInt = 0;
	}
	else
	{
		BurnTimeInt = int((BurnTime - VMP.BurnTimer) + 0.5);
	}
	
	WinInfo.Clear();
	WinInfo.SetTitle(StrStatusTitle);
	
	//0. OOPS! Almost forgot: Overdose!
	if (VMP.IsOverdosed())
	{
		if (VMP.AddictionTimers[4] > VMP.AddictionThresholds[4]*2.5)
		{
 			OverdoseWeight = VMP.AddictionTimers[4]-600;
			OverdoseWeight = FClamp(int((OverdoseWeight + 20.0) / 20.0), 1, 11);
			
			if (OverdoseWeight > 10) OverdoseDamage = 5;
			else if (OverdoseWeight > 5) OverdoseDamage = 4;
			else OverdoseDamage = 3;
			
			TStr[0] = SprintF(StrOverdoseDesc[0], StrSubstanceNames[4]);
			TStr[1] = SprintF(StrOverdoseDesc[1], OverdoseDamage);
			AddStatusListing(Texture'StatusIconOverdose', TStr[0]$CR()$TStr[1]);
		}
		if (VMP.AddictionTimers[3] > VMP.AddictionThresholds[3]*3)
		{
 			OverdoseWeight = VMP.AddictionTimers[3]-899;
			OverdoseWeight = FClamp(int((OverdoseWeight + 20.0) / 20.0), 1, 11);
			
			if (OverdoseWeight > 10) OverdoseDamage = 5;
			else if (OverdoseWeight > 5) OverdoseDamage = 4;
			else OverdoseDamage = 3;
			
			TStr[0] = SprintF(StrOverdoseDesc[0], StrSubstanceNames[3]);
			TStr[1] = SprintF(StrOverdoseDesc[1], OverdoseDamage);
			AddStatusListing(Texture'StatusIconOverdose', TStr[0]$CR()$TStr[1]);
		}
		if (VMP.WaterBuildup > 300)
		{
			OverdoseDamage = 3;
			TStr[0] = SprintF(StrOverdoseDesc[0], StrSubstanceNames[5]);
			TStr[1] = SprintF(StrOverdoseDesc[1], OVerdoseDamage);
			AddStatusListing(Texture'StatusIconOverdose', TStr[0]$CR()$TStr[1]);
		}
	}
	
	//Immediate status effects. We aren't listing EMP here because it's intuitive.
	//1. Poison
	if (Player.PoisonCounter > 0)
	{
		TStr[0] = StrPoisonDesc[0];
		TStr[1] = SprintF(StrPoisonDesc[1], VMP.PoisonCounter, int(VMP.PoisonDamage*2.0*DMult), (VMP.PoisonCounter*2));
		AddStatusListing(Texture'StatusIconPoisonEffect', TStr[0]$CR()$TStr[1]);
	}
	//2. Fire
	if (BurnTimeInt > 0)
	{
		TStr[0] = StrFireDesc[0];
		TStr[1] = SprintF(StrFireDesc[1], BurnTimeInt, int(BurnDamage*2.0*DMult), BurnTimeInt);
		AddStatusListing(Texture'StatusIconFire', TStr[0]$CR()$TStr[1]);
	}
	//3. Nanovirus
	if (VMP.HUDScramblerTimer > 0)
	{
		TStr[0] = StrNanoVirusDesc[0];
		TStr[1] = SprintF(StrNanoVirusDesc[1], int(VMP.HUDScramblerTimer+0.5));
		AddStatusListing(Texture'StatusIconNanoVirus', TStr[0]$CR()$TStr[1]);
	}
	
	//4. EMP. Skipped.
	
	//5. Killswitch info.
	if ((VMP.bKillswitchEngaged) && (VMP.bImmersiveKillswitch))
	{
		KSTime = 5760 / (Sqrt(VMP.TimerDifficulty) / 2) / 60;
		KSTimeLeft = Max(5760 - VMP.KillswitchTime, 0) / (Sqrt(VMP.TimerDifficulty) / 2) / 60;
		KSTimeLeftInt = int(KSTimeLeft + 0.5);
		
		TStr[0] = StrKillswitchDesc[0];
		TStr[1] = SprintF(StrKillswitchDesc[1], KSTimeLeftInt);
		
     		//StrKillswitchDesc(3)="Cellular Degeneration"
     		//StrKillswitchDesc(4)="Nausea"
     		//StrKillswitchDesc(5)="Macular degeneration"
     		//StrKillswitchDesc(6)="Heart Palpitations"
     		//StrKillswitchDesc(7)="Organ Failure"
		
		//SITUATION A: We're playing on at least hard, so health scaling is real. Ugh.
		if ((class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Killswitch Health")) && (VMP.KillswitchTime > 0))
		{
			KSSteps = 1;
			if (VMP.KillswitchTime > 3360) KSSteps++;
			if (VMP.KillswitchTime > 4320) KSSteps++;
			if (VMP.KillswitchTime > 5280) KSSteps++;
			if (VMP.KillswitchTime > 5520) KSSteps++;
			if (VMP.KillswitchTime > 5760) KSSteps++;
			
			for(i=0; i<KSSteps; i++)
			{
				switch(i)
				{
					case 0:
						KSBarfStr[0] = StrKillswitchDesc[3];
					break;
					case 1:
						KSBarfStr[0] = StrKillswitchDesc[4];
					break;
					case 2:
						KSBarfStr[0] = StrKillswitchDesc[5];
					break;
					case 3:
						KSBarfStr[0] = StrKillswitchDesc[6];
					break;
					case 4:
						KSBarfStr[0] = StrKillswitchDesc[7];
					break;
					case 5:
						KSBarfStr[0] = StrKillswitchDesc[8];
					break;
				}
				
				if (i > 0)
				{
					if (KSSteps - i > 1)
					{
						KSBarfStr[1] = KSBarfStr[1]$","@KSBarfStr[0];
					}
					else
					{
						if (KSSteps > 2)
						{
							KSBarfStr[1] = KSBarfStr[1]$", &"@KSBarfStr[0];
						}
						else
						{
							KSBarfStr[1] = KSBarfStr[1]@"&"@KSBarfStr[0];
						}
					}
				}
				else
				{
					KSBarfStr[1] = KSBarfStr[0];
				}
			}
			
			TStr[1] = TStr[1]$CR()$StrKillswitchDesc[2]@KSBarfStr[1];
		}
		//SITUATION B: We're playing on easier difficulties, so just worry about the other 2 effects.
		else if (VMP.KillswitchTime > 3360)
		{
			KSSteps = 2;
			if (VMP.KillswitchTime > 4320) KSSteps++;
			if (VMP.KillswitchTime > 5280) KSSteps++;
			if (VMP.KillswitchTime > 5520) KSSteps++;
			if (VMP.KillswitchTime > 5760) KSSteps++;
			
			for(i=1; i<KSSteps; i++)
			{
				switch(i)
				{
					case 0:
						KSBarfStr[0] = StrKillswitchDesc[3];
					break;
					case 1:
						KSBarfStr[0] = StrKillswitchDesc[4];
					break;
					case 2:
						KSBarfStr[0] = StrKillswitchDesc[5];
					break;
					case 3:
						KSBarfStr[0] = StrKillswitchDesc[6];
					break;
					case 4:
						KSBarfStr[0] = StrKillswitchDesc[7];
					break;
					case 5:
						KSBarfStr[0] = StrKillswitchDesc[8];
					break;
				}
				
				if (i > 1)
				{
					if (KSSteps - i > 1)
					{
						KSBarfStr[1] = KSBarfStr[1]$","@KSBarfStr[0];
					}
					else
					{
						if (KSSteps > 2+1)
						{
							KSBarfStr[1] = KSBarfStr[1]$", &"@KSBarfStr[0];
						}
						else
						{
							KSBarfStr[1] = KSBarfStr[1]@"&"@KSBarfStr[0];
						}
					}
				}
				else
				{
					KSBarfStr[1] = KSBarfStr[0];
				}
			}
			
			TStr[1] = TStr[1]$CR()$StrKillswitchDesc[2]@KSBarfStr[1];
		}
		AddStatusListing(Texture'StatusIconKillswitch', TStr[0]$CR()$TStr[1]);
	}
	
	//6. Infamy active? On nightmare plus, it will be.
	if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Mayhem"))
	{
		MayhemForgive = VMP.SavedMayhemForgiveness;
		MayhemMod = Min(VMP.OwedMayhemFactor+MayhemForgive, 125);
		
		TStr[0] = StrMayhemDesc[0];
		if (MayhemMod < 0)
		{
			TStr[1] = SprintF(StrMayhemDesc[2], VMP.MayhemFactor, int(Abs(MayhemMod)));
		}
		else
		{
			TStr[1] = SprintF(StrMayhemDesc[1], VMP.MayhemFactor, MayhemMod);
		}
		AddStatusListing(Texture'StatusIconMayhem', TStr[0]$CR()$TStr[1]);
	}
	
	//7. Always list hunger, options allowing.
	if (VMP.bHungerEnabled)
	{
		HungerPercent = 100.0 * (VMP.HungerTimer / VMP.HungerCap);
		HungerPercentInt = Min(100, int(HungerPercent+0.5));
		
		HungerTimeLeft = (VMP.HungerCap - VMP.HungerTimer) / Sqrt(VMP.TimerDifficulty) / 60;
		HungerTimeLeftInt = int(HungerTimeLeft + 0.5);
		
		TStr[0] = StrHungerDesc[0];
		if (VMP.HungerTimer >= VMP.HungerCap)
		{
			HungerDamageInt = Max(1, ((VMP.HungerTimer - VMP.HungerCap) / 60.0))*2;
			
			TStr[1] = SprintF(StrHungerDesc[2], HungerDamageInt);
		}
		else
		{
			TStr[1] = SprintF(StrHungerDesc[1], HungerPercentInt, HungerTimeLeftInt);
		}
		AddStatusListing(Texture'StatusIconHunger', TStr[0]$CR()$TStr[1]);
	}
	
	//8/9: Smell stuff. Lovely.
	if (VMP.bSmellsEnabled)
	{
		SmellMults[0] = 1.0;
		SmellMults[1] = 1.0;
		
		if (VMP.SkillSystem != None)
		{
			SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillLockpicking');
		}
		if (VMP.HasSkillAugment("LockpickScent"))
		{
			SmellMults[0] = 1.25 + (0.25 * SkillLevel);
			SmellMults[1] = 1.15 + (0.15 * SkillLevel);
		}
		
		//8. If blood smell is too high, list it.
		if (VMP.BloodSmellLevel >= 45*SmellMults[0])
		{
			SmellUnits = int(VMP.BloodSmellLevel);
			SmellUnitsThresh[0] = int(45*SmellMults[0]);
			SmellUnitsThresh[1] = int(90*SmellMults[0]);
			
			if (VMP.BloodSmellLevel >= SmellUnitsThresh[1])
			{
				TStr[0] = StrBloodSmellDesc[1];
				TStr[1] = SprintF(StrBloodSmellDesc[3], SmellUnits, SmellUnitsThresh[1]);
			}
			else
			{
				TStr[0] = StrBloodSmellDesc[0];
				TStr[1] = SprintF(StrBloodSmellDesc[2], SmellUnits, SmellUnitsThresh[0]);
			}
			
			AddStatusListing(Texture'StatusIconBloodSmell', TStr[0]$CR()$TStr[1]);
		}
		
		//9. Regardless of level, ALWAYS list food smell.
		SmellUnits = VMP.ScoreFood();
		SmellUnitsThresh[0] = int(VMP.FoodSmellThresholds[0]*SmellMults[1]);
		SmellUnitsThresh[1] = int(VMP.FoodSmellThresholds[1]*SmellMults[1]);
		
		if (SmellUnits >= SmellUnitsThresh[1])
		{
			TStr[0] = StrFoodSmellDesc[2];
			TStr[1] = SprintF(StrFoodSmellDesc[5], SmellUnits, SmellUnitsThresh[1]);
		}
		else if (SmellUnits >= SmellUnitsThresh[0])
		{
			TStr[0] = StrFoodSmellDesc[1];
			TStr[1] = SprintF(StrFoodSmellDesc[4], SmellUnits, SmellUnitsThresh[0]);
		}
		else
		{
			TStr[0] = StrFoodSmellDesc[0];
			TStr[1] = SprintF(StrFoodSmellDesc[3], SmellUnits, SmellUnitsThresh[0]);
		}
		
		AddStatusListing(Texture'StatusIconFoodSmell', TStr[0]$CR()$TStr[1]);
	}
	
	//10. Next up is addictions. Ugh.
	if (VMP.bAddictionEnabled > 1)
	{
		if (VMP.AddictionStates[0] > 0)
		{
			if (VMP.AddictionTimers[0] <= 0)
			{
				TStr[0] = SprintF(StrAddictionDesc[1], StrSubstanceNames[0]);
				TStr[1] = SprintF(StrAddictionDesc[3], StrWithdrawalDesc[0]);
			}
			else
			{
				TStr[0] = SprintF(StrAddictionDesc[0], StrSubstanceNames[0]);
				TStr[1] = SprintF(StrAddictionDesc[2], int(VMP.AddictionTimers[0]));
			}
			
			AddStatusListing(Texture'StatusIconAddiction', TStr[0]$CR()$TStr[1]);
		}
		if (VMP.AddictionStates[1] > 0)
		{
			if (VMP.AddictionTimers[1] <= 0)
			{
				TStr[0] = SprintF(StrAddictionDesc[1], StrSubstanceNames[1]);
				TStr[1] = SprintF(StrAddictionDesc[3], StrWithdrawalDesc[1]);
			}
			else
			{
				TStr[0] = SprintF(StrAddictionDesc[0], StrSubstanceNames[1]);
				TStr[1] = SprintF(StrAddictionDesc[2], int(VMP.AddictionTimers[1]));
			}
			
			AddStatusListing(Texture'StatusIconAddiction', TStr[0]$CR()$TStr[1]);
		}
	}
	if (VMP.bAddictionEnabled > 0)
	{
		if (VMP.AddictionStates[2] > 0)
		{
			if (VMP.AddictionTimers[1] <= 0)
			{
				TStr[0] = SprintF(StrAddictionDesc[1], StrSubstanceNames[2]);
				TStr[1] = SprintF(StrAddictionDesc[3], StrWithdrawalDesc[2]);
			}
			else
			{
				TStr[0] = SprintF(StrAddictionDesc[0], StrSubstanceNames[2]);
				TStr[1] = SprintF(StrAddictionDesc[2], int(VMP.AddictionTimers[2]));
			}
			
			AddStatusListing(Texture'StatusIconAddiction', TStr[0]$CR()$TStr[1]);
		}
		if (VMP.AddictionStates[3] > 0)
		{
			if (VMP.AddictionTimers[1] <= 0)
			{
				TStr[0] = SprintF(StrAddictionDesc[1], StrSubstanceNames[3]);
				TStr[1] = SprintF(StrAddictionDesc[3], StrWithdrawalDesc[3]);
			}
			else
			{
				TStr[0] = SprintF(StrAddictionDesc[0], StrSubstanceNames[3]);
				TStr[1] = SprintF(StrAddictionDesc[2], int(VMP.AddictionTimers[3]));
			}
			
			AddStatusListing(Texture'StatusIconAddiction', TStr[0]$CR()$TStr[1]);
		}
		if (VMP.AddictionStates[4] > 0)
		{
			if (VMP.AddictionTimers[1] <= 0)
			{
				TStr[0] = SprintF(StrAddictionDesc[1], StrSubstanceNames[4]);
				TStr[1] = SprintF(StrAddictionDesc[3], StrWithdrawalDesc[4]);
			}
			else
			{
				TStr[0] = SprintF(StrAddictionDesc[0], StrSubstanceNames[4]);
				TStr[1] = SprintF(StrAddictionDesc[2], int(VMP.AddictionTimers[4]));
			}
			
			AddStatusListing(Texture'StatusIconAddiction', TStr[0]$CR()$TStr[1]);
		}
	}
	
	//12. Combat stim.
	Auras[0] = VMDFakeBuffAura(VMP.FindInventoryType(class'CombatStimAura'));
	if (Auras[0] != None)
	{
		TStr[0] = StrCombatStimDesc[0];
		if (Auras[0].Charge > 320)
		{
			TStr[1] = SprintF(StrCombatStimDesc[2], int((float(Auras[0].Charge-320) / 40.0) + 0.5), int((float(Auras[0].Charge) / 40.0) + 0.5));
		}
		else
		{
			TStr[1] = SprintF(StrCombatStimDesc[1], int((float(Auras[0].Charge) / 40.0) + 0.5));
		}
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconPharmacistBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//13. Pharmacist.
	Auras[1] = VMDFakeBuffAura(VMP.FindInventoryType(class'PharmacistArmorAura'));
	if (Auras[1] != None)
	{
		TStr[0] = StrPharmacistDesc[0];
		TStr[1] = SprintF(StrPharmacistDesc[1], int((float(Auras[1].Charge) / 40.0) + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconPharmacistBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//14a. Soda buff.
	Auras[2] = VMDFakeBuffAura(VMP.FindInventoryType(class'SodaBuffAura'));
	if (Auras[2] != None)
	{
		TStr[0] = StrSodaBuffDesc[0];
		TStr[1] = SprintF(StrSodaBuffDesc[1], int((float(Auras[2].Charge) / 40.0) + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconSodaBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//14b. Candy buff.
	Auras[3] = VMDFakeBuffAura(VMP.FindInventoryType(class'CandyBuffAura'));
	if (Auras[3] != None)
	{
		TStr[0] = StrCandyBuffDesc[0];
		TStr[1] = SprintF(StrCandyBuffDesc[1], int((float(Auras[3].Charge) / 40.0) + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconCandyBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//14c. Cigarettes buff.
	Auras[4] = VMDFakeBuffAura(VMP.FindInventoryType(class'CigarettesBuffAura'));
	if (Auras[4] != None)
	{
		TStr[0] = StrCigarettesBuffDesc[0];
		TStr[1] = SprintF(StrCigarettesBuffDesc[1], int((float(Auras[4].Charge) / 40.0) + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconCigarettesBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//14d. Zyme buff.
	Auras[5] = VMDFakeBuffAura(VMP.FindInventoryType(class'ZymeArmorAura'));
	if (Auras[5] != None)
	{
		TStr[0] = StrZymeBuffDesc[0];
		TStr[1] = SprintF(StrZymeBuffDesc[1], int((float(Auras[5].Charge) / 40.0) + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconZymeBuff', TStr[0]$CR()$TStr[1]);
	}
	
	//14e. Inebriation.
	if (VMP.DrugEffectTimer > 0)
	{
		TStr[0] = StrInebriationDesc[0];
		TStr[1] = SprintF(StrInebriationDesc[1], int(VMP.DrugEffectTimer + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconDrunk', TStr[0]$CR()$TStr[1]);
	}
	
	//15a. Ballistic Armor.
	TPickup = (FetchActivePickup(VMP, 'BallisticArmor'));
	if (TPickup != None)
	{
		TMath = int(SkillValue * 4) * 10;
		TMath = ((float(TPickup.Charge) / TMath) + 0.5);
		
		TStr[0] = StrBallisticArmorDesc[0];
		TStr[1] = SprintF(StrBallisticArmorDesc[1], int(100 - (SkillValue2 * 50)), int(100 - (SkillValue2 * 75)), (TPickup.Charge * 100 / TPickup.Default.Charge));
		
		//BARF! We are filler.
		AddStatusListing(TPickup.Icon, TStr[0]$CR()$TStr[1]);
	}

	//15b. Hazmat Suit.
	TPickup = (FetchActivePickup(VMP, 'HazmatSuit'));
	if (TPickup != None)
	{
		TMath = int(SkillValue * 4) * 10;
		TMath = ((float(TPickup.Charge) / TMath) + 0.5);
		
		TStr[0] = StrHazmatSuitDesc[0];
		TStr[1] = SprintF(StrHazmatSuitDesc[1], int(100 - (SkillValue2 * 50)), int(100 - (SkillValue2 * 75)), (TPickup.Charge * 100 / TPickup.Default.Charge));
		
		//BARF! We are filler.
		AddStatusListing(TPickup.Icon, TStr[0]$CR()$TStr[1]);
	}
	
	//15c. Infrared Goggles.
	TPickup = (FetchActivePickup(VMP, 'TechGoggles'));
	if (TPickup != None)
	{
		TMath = int(SkillValue * 4) * 10;
		TMath = ((float(TPickup.Charge) / TMath) + 0.5);
		
		TStr[0] = StrTechGogglesDesc[0];
		TStr[1] = SprintF(StrTechGogglesDesc[1], int(TMath));
		
		//BARF! We are filler.
		AddStatusListing(TPickup.Icon, TStr[0]$CR()$TStr[1]);
	}
	
	//15d. Rebreather.
	TPickup = (FetchActivePickup(VMP, 'Rebreather'));
	if (TPickup != None)
	{
		TMath = int(SkillValue * 4) * 10;
		TMath = ((float(TPickup.Charge) / TMath) + 0.5);
		
		TStr[0] = StrRebreatherDesc[0];
		TStr[1] = SprintF(StrRebreatherDesc[1], int(TMath));
		
		//BARF! We are filler.
		AddStatusListing(TPickup.Icon, TStr[0]$CR()$TStr[1]);
	}
	
	//15e. Thermoptic Camo.
	TPickup = (FetchActivePickup(VMP, 'AdaptiveArmor'));
	if (TPickup != None)
	{
		TMath = int(SkillValue * 4) * 10;
		TMath = ((float(TPickup.Charge) / TMath) + 0.5);
		
		TStr[0] = StrAdaptiveArmorDesc[0];
		TStr[1] = SprintF(StrAdaptiveArmorDesc[1], int(TMath));
		
		//BARF! We are filler.
		AddStatusListing(TPickup.Icon, TStr[0]$CR()$TStr[1]);
	}
	
	//16. Roll cooldown.
	if (VMP.RollCooldownTimer > 0)
	{
		TStr[0] = StrRollCooldownDesc[0];
		TStr[1] = SprintF(StrRollCooldownDesc[1], int(VMP.RollCooldownTimer + 0.5));
		
		//BARF! We are filler.
		AddStatusListing(Texture'StatusIconRollCooldown', TStr[0]$CR()$TStr[1]);
	}
	
	//17. Stress system and modifiers.
	if (VMP.bStressEnabled)
	{
		StressBarfStr = GetStressBarfStr(VMP);
		if (VMP.ActiveStress > 80)
		{
			TStr[0] = StrStressDesc[3];
			TStr[1] = StrStressDesc[7]$CR()$StressBarfStr;
			AddStatusListing(Texture'StatusIconStress03', TStr[0]$CR()$TStr[1]);
		}
		else if (VMP.ActiveStress > 60)
		{
			TStr[0] = StrStressDesc[2];
			TStr[1] = StrStressDesc[6]$CR()$StressBarfStr;
			AddStatusListing(Texture'StatusIconStress02', TStr[0]$CR()$TStr[1]);
		}
		else if (VMP.ActiveStress > 30)
		{
			TStr[0] = StrStressDesc[1];
			TStr[1] = StrStressDesc[5]$CR()$StressBarfStr;
			AddStatusListing(Texture'StatusIconStress01', TStr[0]$CR()$TStr[1]);
		}
		else
		{
			TStr[0] = StrStressDesc[0];
			TStr[1] = StrStressDesc[4]$CR()$StressBarfStr;
			AddStatusListing(Texture'StatusIconStress00', TStr[0]$CR()$TStr[1]);
		}
	}
}

function ChargedPickup FetchActivePickup(VMDBufferPlayer VMP, name CheckType)
{
	local Inventory TInv;
	
	if (VMP == None) return None;
	
	for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if ((ChargedPickup(TInv) != None) && (ChargedPickup(TInv).bIsActive) && (TInv.IsA(CheckType)))
		{
			return ChargedPickup(TInv);
		}
	}
	
	return None;
}

function string GetStressBarfStr(VMDBufferPlayer VMP)
{
	local string Ret, TallyStr[25];
	local int TalliedStrings, i;
	
 	local float TMult, DarkMult, LightLevel, AddStress,
 		DrugMult, THealthMult, EnergyMult, FoodMult;
 	local bool bIndoors, bDark, bPawnProxy, LastDrugged;
 	local DeusExWeapon DXW;
 	local bool bSpotted, bSuperDark;
 	local int SpotNeutral, SpotHostile, SpotRobot, SpotAnimal, SpotEdgy, HTotal;
	
	if (VMP == None) return "";
	
	//++++++++++++++++++++++++++++++++++++++++
	//BARFAPALOOZA BEGIN!
	//++++++++++++++++++++++++++++++++++++++++
	
 	//Setup baseline vars. This is gonna get messy.
 	DrugMult = 1.0;
 	THealthMult = 0.0;
 	HTotal = VMP.VMDGetHealthTotal();
	
 	//Step 1: Health multiplier.
 	//--------------------
 	//1b: Broad health.
 	if (HTotal < 150*VMP.GetHealthMult("All"))
	{
		THealthMult = 0.2;
		TallyStr[TalliedStrings++] = StrStressModifiers[2];
	}
 	else if (HTotal < 300*VMP.GetHealthMult("All"))
	{
		THealthMult = 0.15;
		TallyStr[TalliedStrings++] = StrStressModifiers[1];
	}
 	else if (HTotal < 450*VMP.GetHealthMult("All"))
	{
		THealthMult = 0.10;
		TallyStr[TalliedStrings++] = StrStressModifiers[0];
 	}
	
 	//--------------------
 	//1c: Arms are "grazes" but can add up.
 	if (VMP.HealthArmRight < 50*VMP.GetHealthMult("Right Arm") || VMP.HealthArmLeft < 50*VMP.GetHealthMult("Left Arm"))
	{
		THealthMult += 0.05;
		TallyStr[TalliedStrings++] = StrStressModifiers[3];
	}
	
 	//1d: Legs are vital, and can really freak us out
 	if ((VMP.HealthLegLeft < 15*VMP.GetHealthMult("Left Leg")) && (VMP.HealthLegRight < 15*VMP.GetHealthMult("Right Leg")))
	{
		THealthMult += 0.1;
		TallyStr[TalliedStrings++] = StrStressModifiers[5];
	}
 	else if (VMP.HealthLegLeft < 50*VMP.GetHealthMult("Left Leg") || VMP.HealthLegRight < 50*VMP.GetHealthMult("Right Leg"))
	{
		THealthMult += 0.05;
		TallyStr[TalliedStrings++] = StrStressModifiers[4];
 	}
	
 	//1e: Vital organs fucking suck. Head especially.
 	if (VMP.HealthTorso < 35*VMP.GetHealthMult("Torso"))
	{
		THealthMult += 0.1;
		TallyStr[TalliedStrings++] = StrStressModifiers[7];
	}
 	else if (VMP.HealthTorso < 65*VMP.GetHealthMult("Torso"))
	{
		THealthMult += 0.05;
		TallyStr[TalliedStrings++] = StrStressModifiers[6];
 	}
	
 	if (VMP.HealthHead < 35*VMP.GetHealthMult("Head"))
	{
		THealthMult += 0.15;
		TallyStr[TalliedStrings++] = StrStressModifiers[9];
	}
 	else if (VMP.HealthHead < 65*VMP.GetHealthMult("Head"))
	{
		THealthMult += 0.05;
		TallyStr[TalliedStrings++] = StrStressModifiers[8];
 	}
	
	//MADDERS: Turn off this stress when in god mode. Why not?
	if (VMP.ReducedDamageType == 'All') THealthMult = 0;
	
 	//Step 2: Char- Er... Darkness
 	LightLevel = VMP.AIGETLIGHTLEVEL(VMP.Location);
 	bDark = (LightLevel <= 0.005);
 	DarkMult = FClamp(LightLevel, 0.0, 0.2) * 3;
 	
 	//Step 2b: 
 	if (VMP.LocationIsSuperDark(VMP.Location))
 	{
  		TallyStr[TalliedStrings++] = StrStressModifiers[11];
  		bSuperDark = true;
 	}
	else if (bDark)
	{
		TallyStr[TalliedStrings++] = StrStressModifiers[10];
	}
 	bIndoors = !VMP.VMDIsOpenSky();
 	
 	//Step 3: How many baddies have us spotted?
	if ((VMP.ReducedDamageType != 'All') && (VMP.bDetectable))
	{
 		bSpotted = VMP.SpottedByHostiles(SpotRobot, SpotHostile, SpotNeutral, SpotEdgy);
	}
	
 	//Step 4: Being drugged lowers our fucks given.
 	LastDrugged = (VMP.DrugEffectTimer > 0);
 	if (LastDrugged)
 	{
  		TallyStr[TalliedStrings++] = StrStressModifiers[12];
 	}
 	
 	//Step 5: Energy charge and hunger.
 	if (VMP.Energy < VMP.EnergyMax*0.15)
	{
		TallyStr[TalliedStrings++] = StrStressModifiers[14];
	}
 	else if (VMP.Energy > VMP.EnergyMax*0.85)
	{
		TallyStr[TalliedStrings++] = StrStressModifiers[13];
	}
	
 	if (VMP.HungerTimer < VMP.HungerCap*0.45)
	{
		TallyStr[TalliedStrings++] = StrStressModifiers[15];
	}
 	else
	{
 		if (VMP.HungerTimer > VMP.HungerCap*0.85) TallyStr[TalliedStrings++] = StrStressModifiers[17];
		else if (VMP.HungerTimer > VMP.HungerCap*0.70) TallyStr[TalliedStrings++] = StrStressModifiers[16];
 	}
	
 	//Step 6: Add up stress gained.
 	if (!bDark || bSuperDark)
 	{
  		if (bIndoors)
		{
			TallyStr[TalliedStrings++] = StrStressModifiers[20];
  		}
		
  		if (bSpotted)
  		{
			if (SpotHostile > 1)
			{
				TallyStr[TalliedStrings++] = StrStressModifiers[18];
			}
			if (SpotNeutral > 0)
			{
				TallyStr[TalliedStrings++] = StrStressModifiers[19];
			}
  		}
 	}
	
 	//GOOD STATUS!
  	if (VMP.bDuck == 1 || VMP.bCrouchOn || VMP.CollisionHeight < (VMP.Default.CollisionHeight / 2))
	{
		TallyStr[TalliedStrings++] = StrStressModifiers[21];
	}
  	if (DeusExWeapon(VMP.InHand) != None)
  	{
   		DXW = DeusExWeapon(VMP.InHand);
   		if ((DXW.AmmoType == None) || (DXW.AmmoType.AmmoAmount < DXW.ReloadCount * 0.2) || (DXW.ClipCount >= DXW.ReloadCount) || (DXW.ClipCount >= (float(DXW.ReloadCount) * 0.8)))
   		{
    			if (!DXW.bHandToHand)
    			{
				TallyStr[TalliedStrings++] = StrStressModifiers[22];
    			}
   		}
  	}
	
	//++++++++++++++++++++++++++++++++++++++++
	//BARFAPALOOZA END!
	//++++++++++++++++++++++++++++++++++++++++
	
	for(i=0; i<TalliedStrings; i++)
	{
		if (i > 0)
		{
			if (TalliedStrings - i > 1)
			{
				Ret = Ret$","@TallyStr[i];
			}
			else
			{
				if (TalliedStrings > 2)
				{
					Ret = Ret$", &"@TallyStr[i];
				}
				else
				{
					Ret = Ret@"&"@TallyStr[i];
				}
			}
		}
		else
		{
			Ret = TallyStr[i];
		}
	}
	
	Ret = CAPS(Left(Ret, 1))$Right(Ret, Len(Ret)-1);
	
	return Ret;
	
	/*StrStressDesc[8], StrStressModifiers[11], StrStressModifiers[25]
		
     	StrStressModifiers(0)="your health is lackluster"
     	StrStressModifiers(1)="your health is low"
     	StrStressModifiers(2)="your health is very low"
     	StrStressModifiers(3)="your arms are injured"
     	StrStressModifiers(4)="your legs are injured"
     	StrStressModifiers(5)="your legs are heavily injured"
     	StrStressModifiers(6)="your torso is injured"
     	StrStressModifiers(7)="your torso is heavily injured"
     	StrStressModifiers(8)="your head is injured"
     	StrStressModifiers(9)="your head is heavily injured"
     	StrStressModifiers(10)="you are under the coaxing cover of darkness"
     	StrStressModifiers(11)="you are nearly invisible beneath the cover of darkness"
     	StrStressModifiers(12)="you are calmed by your state of inebriation"
     	StrStressModifiers(13)="you are well charged"
     	StrStressModifiers(14)="you bio energy is low"
     	StrStressModifiers(15)="you are well fed"
     	StrStressModifiers(16)="you are hungry"
     	StrStressModifiers(17)="you are famished"
     	StrStressModifiers(18)="you are surrounded by enemies"
     	StrStressModifiers(19)="you are surrounded by unknown parties"
     	StrStressModifiers(20)="you are comfortable from being indoors"
     	StrStressModifiers(21)="you are steady and ducked low"
     	StrStressModifiers(22)="your weapon is low on ammo"*/
}

function AddStatusListing(Texture TTex, string InStr)
{
	local AlignWindow TAlign;
	local PersonaNormalTextWindow winText;
	local Window winIcon;
	
	if (WinInfo == None || WinInfo.WinTile == None) return;
	
	TAlign = AlignWindow(WinInfo.WinTile.NewChild(Class'AlignWindow'));
	TAlign.SetChildVAlignment(VALIGN_Top);
	TAlign.SetChildSpacing(4);
	
	//Add icon
	winIcon = TAlign.NewChild(Class'Window');
	winIcon.SetBackground(TTex);
	winIcon.SetBackgroundStyle(DSTY_Masked);
	winIcon.SetSize(42, 42);
	
	//Add description
	winText = PersonaNormalTextWindow(TAlign.NewChild(Class'PersonaNormalTextWindow'));
	winText.SetWordWrap(True);
	winText.SetTextMargins(0, 0);
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	
	winText.AppendText(InStr);
	
	WinInfo.AddLine();
}

defaultproperties
{
     HealthPartDesc(0)="Head wounds are fatal in the vast majority of threat scenarios; however, in those cases where death is not instantaneous, agents will often find that head injuries impair vision and aim. Care should be taken to heal such injuries as quickly as possible or death may result.|n|nLight Wounds: Slightly decreased accuracy.|nMedium Wounds: Wavering vision.|nHeavy Wounds: Death."
     HealthPartDesc(1)="The torso is by far the portion of the human anatomy able to absorb the most damage, but it is also the easiest to target in close quarters combat. As progressively more damage is inflicted to the torso, agents may find their movements impaired and eventually bleed to death even if a mortal blow to a vital organ is not suffered.|n|nLight Wounds: Slightly impaired movement.|nMedium Wounds: Significantly impaired movement.|nMajor Wounds: Death."
     HealthPartDesc(2)="Obviously damage to the arm is of concern in any combat situation as it has a direct effect on the agent's ability to utilize a variety of weapons. Losing the use of one arm will certainly lower the agent's combat efficiency, while the loss of both arms will render it nearly impossible for an agent to present even a nominal threat to most hostiles. Of course, for one-handed weapons, only the arm actively holding the weapon is of concern.|n|nLight Wounds: Slightly decreased accuracy.|nMedium Wounds: Moderately decreased accuracy.|nMajor Wounds: Significantly decreased accuracy."
     HealthPartDesc(3)="Injuries to the leg will result in drastically diminished mobility. If an agent in hostile territory is unfortunate enough to lose the use of both legs but still remain otherwise viable, they are ordered to execute UNATCO Special Operations Order 99009 (Self-Termination).|n|nLight Wounds: Slightly impaired movement.|nMedium Wounds: Moderately impaired movement.|nHeavy Wounds: Significantly impaired movement."
     bShowHealButtons=True
     MedKitUseText="To heal a specific region of the body, click on the region, then click the Heal button."
     HealthTitleText="Health"
     HealAllButtonLabel="H|&eal All"
     HealthLocationHead="Head"
     HealthLocationTorso="Torso"
     HealthLocationRightArm="Right Arm"
     HealthLocationLeftArm="Left Arm"
     HealthLocationRightLeg="Right Leg"
     HealthLocationLeftLeg="Left Leg"
     PointsHealedLabel="%d points healed"
     clientBorderOffsetY=32
     ClientWidth=596
     ClientHeight=427
     clientOffsetX=25
     clientOffsetY=5
     clientTextures(0)=Texture'DeusExUI.UserInterface.HealthBackground_1'
     clientTextures(1)=Texture'NewHealthBackground_2'
     clientTextures(2)=Texture'NewHealthBackground_3'
     clientTextures(3)=Texture'DeusExUI.UserInterface.HealthBackground_4'
     clientTextures(4)=Texture'NewHealthBackground_5'
     clientTextures(5)=Texture'NewHealthBackground_6'
     clientBorderTextures(0)=Texture'DeusExUI.UserInterface.HealthBorder_1'
     clientBorderTextures(1)=Texture'NewHealthBorder_2'
     clientBorderTextures(2)=Texture'NewHealthBorder_3'
     clientBorderTextures(3)=Texture'DeusExUI.UserInterface.HealthBorder_4'
     clientBorderTextures(4)=Texture'NewHealthBorder_5'
     clientBorderTextures(5)=Texture'NewHealthBorder_6'
     clientTextureRows=2
     clientTextureCols=3
     clientBorderTextureRows=2
     clientBorderTextureCols=3
     
     ShowHealthInfoLabel="Show Part Info"
     ShowStatInfoLabel="Show Status Info"
     NewInfoOffset=(X=0,Y=13)
     ShowHealthInfoPos=(X=371,Y=52)
     ShowStatInfoPos=(X=495,Y=52)
     StrStatusTitle="Statuses and Effects"
     StrOverdoseDesc(0)="You have overdosed on %s"
     StrOverdoseDesc(1)="You are taking bursts of %d damage at random intervals"
     StrPoisonDesc(0)="You are poisoned"
     StrPoisonDesc(1)="%d tick(s) of %d damage remaining, over %d second(s)."
     StrFireDesc(0)="You are on fire"
     StrFireDesc(1)="%d tick(s) of %d damage remaining, over %d second(s)."
     StrNanoVirusDesc(0)="Your systems are scrambled"
     StrNanoVirusDesc(1)="Unreliable HUD readout for %d more second(s)."
     StrKillswitchDesc(0)="Your killswitch is active"
     StrKillswitchDesc(1)="You have %d minute(s) remaining."
     StrKillswitchDesc(2)="You are suffering from:"
     StrKillswitchDesc(3)="cellular degeneration"
     StrKillswitchDesc(4)="nausea"
     StrKillswitchDesc(5)="heart palpitations"
     StrKillswitchDesc(6)="macular degeneration"
     StrKillswitchDesc(7)="neural degeneration"
     StrKillswitchDesc(8)="organ failure"
     StrMayhemDesc(0)="You are at risk of gaining infamy"
     StrMayhemDesc(1)="You have %d point(s) of infamy. You may gain up to %d infamy point(s) after this mission concludes."
     StrMayhemDesc(2)="You have %d point(s) of infamy. You may lose up to %d infamy point(s) after this mission concludes."
     StrHungerDesc(0)="Food is essential"
     StrHungerDesc(1)="You are at %d%% hunger. You will be starving in %d minutes."
     StrHungerDesc(2)="You are literally starving. Every 10 second(s), you will suffer up to %d point(s) of damage."
     StrBloodSmellDesc(0)="You smell of blood"
     StrBloodSmellDesc(1)="You smell heavily of blood"
     StrBloodSmellDesc(2)="You are at %d blood smell units. Drop below %d to lose your smell."
     StrBloodSmellDesc(3)="You are at %d blood smell units. Drop below %d to lower your smell."
     StrFoodSmellDesc(0)="You do not smell of food"
     StrFoodSmellDesc(1)="You smell of food"
     StrFoodSmellDesc(2)="You smell heavily of food"
     StrFoodSmellDesc(3)="You are at %d food smell units. You will acquire a smell at %d units."
     StrFoodSmellDesc(4)="You are at %d food smell units. Drop below %d to lose your smell."
     StrFoodSmellDesc(5)="You are at %d food smell units. Drop below %d to lower your smell."
     StrAddictionDesc(0)="You are addicted to %d"
     StrAddictionDesc(1)="You are addicted to and craving %d"
     StrAddictionDesc(2)="You are still satiated for %d second(s)."
     StrAddictionDesc(3)="Symptoms: %s. Stay dry to kick your habit."
     StrSubstanceNames(0)="sugar"
     StrSubstanceNames(1)="caffeine"
     StrSubstanceNames(2)="nicotine"
     StrSubstanceNames(3)="alcohol"
     StrSubstanceNames(4)="zyme"
     StrSubstanceNames(5)="water"
     StrWithdrawalDesc(0)="sugar cravings"
     StrWithdrawalDesc(1)="decreased run speed"
     StrWithdrawalDesc(2)="decreased focus & migraines"
     StrWithdrawalDesc(3)="decreased accuracy & nausea"
     StrWithdrawalDesc(4)="decreased focus & lack of coordination"
     StrCombatStimDesc(0)="You are hopped up on combat stims"
     StrCombatStimDesc(1)="You are under extreme stress, have 65%% bonus melee speed/aim focus rate, and 35%% bonus movement speed. You will crash in %d second(s)."
     StrCombatStimDesc(2)="You are under extreme stress, have 65%% bonus melee speed/aim focus rate, and 35%% bonus movement speed. Additionally, you have %d second(s) more clarity against visual effects. You will crash in %d second(s)."
     StrPharmacistDesc(0)="You are under the care of pharmaceuticals"
     StrPharmacistDesc(1)="You have a 50%% resistance to toxic effects for %d second(s)."
     StrSodaBuffDesc(0)="You are hopped up on caffeine"
     StrSodaBuffDesc(1)="You have 65%% bonus aim focus rate for %d second(s)."
     StrCandyBuffDesc(0)="You are energized by sugar"
     StrCandyBuffDesc(1)="You have 15%% bonus movement speed for %d second(s)."
     StrCigarettesBuffDesc(0)="You are mellowed by nicotine"
     StrCigarettesBuffDesc(1)="You have continuously reduced stress but take 2x damage from toxins for %d second(s)."
     StrZymeBuffDesc(0)="You are blitzed via zyme"
     StrZymeBuffDesc(1)="Lord only knows what all is happening to you, but it'll continue for another %d second(s)."
     StrAdaptiveArmorDesc(0)="You are wearing thermoptic camo"
     StrAdaptiveArmorDesc(1)="This hides your visual signature to humans, robots, and lasers. It has %d second(s) more power left in its reserves."
     StrBallisticArmorDesc(0)="You are wearing ballistic armor"
     StrBallisticArmorDesc(1)="This reduces bullet/melee damage by %d%% and armor piercing/explosive damage by %d%%. It has %d%% power remaining."
     StrHazmatSuitDesc(0)="You are wearing a hazmat suit"
     StrHazmatSuitDesc(1)="This reduces damage from radiation/gas damage by %d%% and burning/electric damage by %d%%. It also grants immunity to aerosol based damage. It has %d%% power remaining."
     StrRebreatherDesc(0)="You are inhaling via a rebreather"
     StrRebreatherDesc(1)="This allows your oxygen level to stabilize, even while underwater. They have %d second(s) more power left in them."
     StrTechGogglesDesc(0)="You are wearing tech goggles"
     StrTechGogglesDesc(1)="This grants you the ability to see heat signatures, even through walls. They have %d second(s) more power left in them."
     StrInebriationDesc(0)="You are inebriated"
     StrInebriationDesc(1)="You will continue to be disoriented for %d second(s)."
     StrRollCooldownDesc(0)="You are on cooldown for your roll"
     StrRollCooldownDesc(1)="You cannot roll for another %d second(s)."
     StrStressDesc(0)="Your stress level is: good"
     StrStressDesc(1)="Your stress level is: shaky"
     StrStressDesc(2)="Your stress level is: rattled"
     StrStressDesc(3)="Your stress level is: terrified"
     StrStressDesc(4)="Your aim focus rate is increased by 25%."
     StrStressDesc(5)="Your aim focus rate is standard."
     StrStressDesc(6)="Your aim focus rate is impaired by 16%."
     StrStressDesc(7)="Your aim focus rate is impaired by 35% and your heart is racing."
     StrStressModifiers(0)="your health is lackluster"
     StrStressModifiers(1)="your health is low"
     StrStressModifiers(2)="your health is very low"
     StrStressModifiers(3)="your arms are injured"
     StrStressModifiers(4)="your legs are injured"
     StrStressModifiers(5)="your legs are heavily injured"
     StrStressModifiers(6)="your torso is injured"
     StrStressModifiers(7)="your torso is heavily injured"
     StrStressModifiers(8)="your head is injured"
     StrStressModifiers(9)="your head is heavily injured"
     StrStressModifiers(10)="you are under the coaxing cover of darkness"
     StrStressModifiers(11)="you are nearly invisible beneath the cover of darkness"
     StrStressModifiers(12)="you are calmed by your state of inebriation"
     StrStressModifiers(13)="you are well charged"
     StrStressModifiers(14)="your bio energy is low"
     StrStressModifiers(15)="you are well fed"
     StrStressModifiers(16)="you are hungry"
     StrStressModifiers(17)="you are famished"
     StrStressModifiers(18)="you are surrounded by enemies"
     StrStressModifiers(19)="you are near unknown parties"
     StrStressModifiers(20)="you are comfortable from being indoors"
     StrStressModifiers(21)="you are steady and ducked low"
     StrStressModifiers(22)="your weapon is low on ammo"
}
