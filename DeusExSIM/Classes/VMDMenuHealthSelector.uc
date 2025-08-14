//=============================================================================
// VMDMenuHealthSelector. Lightweight and to the point, I'd hope.
//=============================================================================
class VMDMenuHealthSelector expands MenuUIWindow;

//MADDERS, 8/26/23: I get really damn tired of having to define 2x as many default properties.
struct VMDButtonPos {
	var int X;
	var int Y;
};

var bool bFemale;
var int SelectedRegion;
var VMDButtonPos HealthRegionPos[7], HealthRegionSize[7], HealthRegionPosFemale[6];

var localized string StrHeadRegionDescs[3], StrTorsoRegionDescs[3], StrLeftArmRegionDescs[5], StrRightArmRegionDescs[5], StrLeftLegRegionDescs[5], StrRightLegRegionDescs[5],
			StrAnyHealTooltip, StrUrgent[2], StrArmBrokenAdvanced[2], StrLegBrokenAdvanced[2];
var VMDButtonPos HealthStatusPos, HealthStatusSize;
var MenuUILabelWindow HealthStatusLabel;

var localized string StrReload;
var VMDButtonPos MedkitPos, MedkitCountLabelPos, MedkitCountLabelSize, ReloadTipLabelPos, ReloadTipLabelSize;
var VMDHealthSelectorMedkitIcon MedkitIcon;
var MenuUILabelWindow MedkitCountLabel, ReloadTipLabel;
var Color ColNoMedkits, ColHasMedkits;

var VMDStylizedWindow MedkitSquare;
var VMDButtonpos MedkitSquarePos, MedkitSquareSize;

var Medkit Medkit;
var VMDStylizedWindow HealthRegions[7];
var Window HealthRims[7], HealthSelector;

var VMDButtonPos BiocellPos, BiocellSquarePos, BiocellSquareSize, AugScreenLabelPos, AugScreenLabelSize;
var VMDAugSelectorCellIcon BiocellIcon;
var VMDStylizedWindow BiocellSquare;
var MenuUILabelWindow AugScreenLabel;
var localized string StrDuckSwitch;

//MADDERS, 8/27/23: We can now read all our inputs dynamically. Yay. Good suggestion from HawkBird.
var EInputKey MenuValues1[9], MenuValues2[9], MenuValues3[9], HackKey,
		LeftKey[3], RightKey[3], UpKey[3], DownKey[3], AugMenuKey[3], HealthMenuKey[4],
		DuckKey[3], SwitchAmmoKey[3], HealKey[3];

var string AliasNames[9];

event StyleChanged()
{
	local ColorTheme theme;
	
	Super.StyleChanged();
	
	theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	ReloadTipLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	ReloadTipLabel.SetTextColor(ReloadTipLabel.ColLabel);
	
	AugScreenLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	AugScreenLabel.SetTextColor(AugScreenLabel.ColLabel);
	
	HealthStatusLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	HealthStatusLabel.SetTextColor(HealthStatusLabel.ColLabel);
}

//MADDERS, 8/26/23: One last hack from beyond the grave: Update our colors to menu type. Thanks.
function CreateClientWindow()
{
	local int clientIndex, titleOffsetX, titleOffsetY;
	local ColorTheme theme;
	
	winClient = MenuUIClientWindow(NewChild(class'MenuUIClientWindow'));
	
	winTitle.GetOffsetWidths(titleOffsetX, titleOffsetY);
	
	winClient.SetSize(clientWidth, clientHeight);
	winClient.SetTextureLayout(textureCols, textureRows);
	
	// Set background textures
	for(clientIndex=0; clientIndex<arrayCount(clientTextures); clientIndex++)
	{
		winClient.SetClientTexture(clientIndex, clientTextures[clientIndex]);
	}
	
	// Translucency
	if (Player.GetHUDBackgroundTranslucency())
	{
		WinClient.BackgroundDrawStyle = DSTY_Translucent;
	}
	else
	{
		WinClient.BackgroundDrawStyle = DSTY_Masked;
	}
	
	Theme = Player.ThemeManager.GetCurrentHUDColorTheme();
	WinClient.ColBackground = Theme.GetColorFromName('HUDColor_Background');
}

function UpdateHighlightedPos()
{
	local bool bAdvancedDamage;
	local float ModMult, TCap, FPer, TCap2, FPer2, DMult, BurnTime;
	local int i, TickDam, BurnDamage, BurnTimeInt;
	local string TStr;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	
	ModMult = 1.0;
	if (VMP != None)
	{
		bFemale = VMP.bAssignedFemale;
		bAdvancedDamage = VMP.VMDDoAdvancedLimbDamage();
		if (VMP.KSHealthMult > 0)
		{
			ModMult *= VMP.KSHealthMult;
		}
		
		if (VMP.ModHealthMultiplier > 0)
		{
			ModMult *= VMP.ModHealthMultiplier;
		}
	}
	
	if (!bFemale)
	{
		HealthRegions[0].SetBackground(Texture'VMDHCHeadStandard');
		HealthRims[0].SetBackground(Texture'VMDHCHeadRimStandard');
		HealthRegions[1].SetBackground(Texture'VMDHCTorsoStandard');
		HealthRims[1].SetBackground(Texture'VMDHCTorsoRimStandard');
		HealthRegions[2].SetBackground(Texture'VMDHCRightArmStandard');
		HealthRims[2].SetBackground(Texture'VMDHCRightArmRimStandard');
		HealthRegions[3].SetBackground(Texture'VMDHCLeftArmStandard');
		HealthRims[3].SetBackground(Texture'VMDHCLeftArmRimStandard');
		HealthRegions[4].SetBackground(Texture'VMDHCRightLegStandard');
		HealthRims[4].SetBackground(Texture'VMDHCRightLegRimStandard');
		HealthRegions[5].SetBackground(Texture'VMDHCLeftLegStandard');
		HealthRims[5].SetBackground(Texture'VMDHCLeftLegRimStandard');
		HealthRegions[6].SetBackground(Texture'VMDHCAnyStandard');
		HealthRims[6].SetBackground(Texture'VMDHCAnyRimStandard');
		
		HealthSelector.SetPos(HealthRegionPos[SelectedRegion].X, HealthRegionPos[SelectedRegion].Y);
	}
	else
	{
		for(i=0; i<ArrayCount(HealthRegions); i++)
		{
			if (i != 6)
			{
				HealthRegions[i].SetPos(HealthRegionPosFemale[i].X, HealthRegionPosFemale[i].Y);
			}
		}
		for(i=0; i<ArrayCount(HealthRims); i++)
		{
			if (i != 6)
			{
				HealthRims[i].SetPos(HealthRegionPosFemale[i].X, HealthRegionPosFemale[i].Y);
			}
		}
		
		HealthRegions[0].SetBackground(Texture'VMDHCFemHeadStandard');
		HealthRims[0].SetBackground(Texture'VMDHCFemHeadRimStandard');
		HealthRegions[1].SetBackground(Texture'VMDHCFemTorsoStandard');
		HealthRims[1].SetBackground(Texture'VMDHCFemTorsoRimStandard');
		HealthRegions[2].SetBackground(Texture'VMDHCFemRightArmStandard');
		HealthRims[2].SetBackground(Texture'VMDHCFemRightArmRimStandard');
		HealthRegions[3].SetBackground(Texture'VMDHCFemLeftArmStandard');
		HealthRims[3].SetBackground(Texture'VMDHCFemLeftArmRimStandard');
		HealthRegions[4].SetBackground(Texture'VMDHCFemRightLegStandard');
		HealthRims[4].SetBackground(Texture'VMDHCFemRightLegRimStandard');
		HealthRegions[5].SetBackground(Texture'VMDHCFemLeftLegStandard');
		HealthRims[5].SetBackground(Texture'VMDHCFemLeftLegRimStandard');
		
		HealthRegions[6].SetBackground(Texture'VMDHCAnyStandard');
		HealthRims[6].SetBackground(Texture'VMDHCAnyRimStandard');
		
		if (SelectedRegion == 6)
		{
			HealthSelector.SetPos(HealthRegionPos[SelectedRegion].X, HealthRegionPos[SelectedRegion].Y);
		}
		else
		{
			HealthSelector.SetPos(HealthRegionPosFemale[SelectedRegion].X, HealthRegionPosFemale[SelectedRegion].Y);
		}
	}
	
	HealthSelector.SetSize(HealthRegionSize[SelectedRegion].X, HealthRegionSize[SelectedRegion].Y);
	switch(SelectedRegion)
	{
		case 0: //Head
			if (!bFemale)
			{
				HealthRegions[0].SetBackground(Texture'VMDHCHeadHighlight');
				HealthSelector.SetBackground(Texture'VMDHCHeadRimHighlight');
			}
			else
			{
				HealthRegions[0].SetBackground(Texture'VMDHCFemHeadHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemHeadRimHighlight');
			}
			
			TCap = float(Player.Default.HealthHead) * ModMult;
			FPer = (float(Player.HealthHead) / TCap) * 100.0;
			
			if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrHeadRegionDescs[0], Player.HealthHead, int(TCap)));
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrHeadRegionDescs[1], Player.HealthHead, int(TCap)));
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrHeadRegionDescs[2], Player.HealthHead, int(TCap)));
			}
		break;
		case 1: //Torso
			if (!bFemale)
			{
				HealthRegions[1].SetBackground(Texture'VMDHCTorsoHighlight');
				HealthSelector.SetBackground(Texture'VMDHCTorsoRimHighlight');
			}
			else
			{
				HealthRegions[1].SetBackground(Texture'VMDHCFemTorsoHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemTorsoRimHighlight');
			}
			
			TCap = float(Player.Default.HealthTorso) * ModMult;
			FPer = (float(Player.HealthTorso) / TCap) * 100.0;
			
			if (Player.PoisonCounter > 0)
			{
				DMult = 1.0;
				if (Player.CombatDifficulty < 1.0)
				{
					DMult = Player.CombatDifficulty;
				}
				
				if (Player.HealthTorso <= (Player.PoisonDamage * 2.0 * DMult) * 2.0)
				{
					TStr = StrUrgent[1];
				}
			}
			
			BurnTime = Class'WeaponFlamethrower'.Default.BurnTime;
			BurnDamage = Class'WeaponFlamethrower'.Default.BurnDamage;
			
			if (!Player.bOnFire)
			{
				BurnTimeInt = 0;
			}
			else
			{
				BurnTimeInt = int((BurnTime - Player.BurnTimer) + 0.5);
			}
			
			if (BurnTimeInt > 0)
			{
				DMult = 1.0;
				if (Player.CombatDifficulty < 1.0)
				{
					DMult = Player.CombatDifficulty;
				}
				else if (Player.CombatDifficulty >= 1.0)
				{
					DMult = (Player.CombatDifficulty ** (1.0 / 3));
				}
				
				if (Player.HealthTorso <= (BurnDamage * 2.0 * DMult) * 2.0)
				{
					TStr = StrUrgent[0];
				}
			}
			
			if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrTorsoRegionDescs[0], Player.HealthTorso, int(TCap))$TStr);
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrTorsoRegionDescs[1], Player.HealthTorso, int(TCap))$TStr);
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrTorsoRegionDescs[2], Player.HealthTorso, int(TCap)));
			}
		break;
		case 2: //Right arm
			if (!bFemale)
			{
				HealthRegions[2].SetBackground(Texture'VMDHCRightArmHighlight');
				HealthSelector.SetBackground(Texture'VMDHCRightArmRimHighlight');
			}
			else
			{
				HealthRegions[2].SetBackground(Texture'VMDHCFemRightArmHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemRightArmRimHighlight');
			}
			
			TCap = float(Player.Default.HealthArmRight) * ModMult;
			FPer = (float(Player.HealthArmRight) / TCap) * 100.0;
			
			TCap2 = float(Player.Default.HealthArmLeft) * ModMult;
			FPer2 = (float(Player.HealthArmLeft) / TCap) * 100.0;
			
			if (bAdvancedDamage)
			{
				if ((FPer < 1) && (FPer2 < 1))
				{
					TStr = StrArmBrokenAdvanced[1];
				}
				else if (FPer < 1)
				{
					TStr = StrArmBrokenAdvanced[0];
				}
			}
			
			if (FPer < 1)
			{
				HealthStatusLabel.SetText(SprintF(StrRightArmRegionDescs[0], Player.HealthArmRight, int(TCap))$TStr);
			}
			else if (FPer < 34)
			{
				HealthStatusLabel.SetText(SprintF(StrRightArmRegionDescs[1], Player.HealthArmRight, int(TCap)));
			}
			else if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrRightArmRegionDescs[2], Player.HealthArmRight, int(TCap)));
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrRightArmRegionDescs[3], Player.HealthArmRight, int(TCap)));
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrRightArmRegionDescs[4], Player.HealthArmRight, int(TCap)));
			}
		break;
		case 3: //Left arm
			if (!bFemale)
			{
				HealthRegions[3].SetBackground(Texture'VMDHCLeftArmHighlight');
				HealthSelector.SetBackground(Texture'VMDHCLeftArmRimHighlight');
			}
			else
			{
				HealthRegions[3].SetBackground(Texture'VMDHCFemLeftArmHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemLeftArmRimHighlight');
			}
			
			TCap = float(Player.Default.HealthArmLeft) * ModMult;
			FPer = (float(Player.HealthArmLeft) / TCap) * 100.0;
			
			TCap2 = float(Player.Default.HealthArmRight) * ModMult;
			FPer2 = (float(Player.HealthArmRight) / TCap) * 100.0;
			
			if (bAdvancedDamage)
			{
				if ((FPer < 1) && (FPer2 < 1))
				{
					TStr = StrArmBrokenAdvanced[1];
				}
				else if (FPer < 1)
				{
					TStr = StrArmBrokenAdvanced[0];
				}
			}
			
			if (FPer < 1)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftArmRegionDescs[0], Player.HealthArmLeft, int(TCap))$TStr);
			}
			else if (FPer < 34)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftArmRegionDescs[1], Player.HealthArmLeft, int(TCap)));
			}
			else if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftArmRegionDescs[2], Player.HealthArmLeft, int(TCap)));
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftArmRegionDescs[3], Player.HealthArmLeft, int(TCap)));
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrLeftArmRegionDescs[4], Player.HealthArmLeft, int(TCap)));
			}
		break;
		case 4: //Right leg
			if (!bFemale)
			{
				HealthRegions[4].SetBackground(Texture'VMDHCRightLegHighlight');
				HealthSelector.SetBackground(Texture'VMDHCRightLegRimHighlight');
			}
			else
			{
				HealthRegions[4].SetBackground(Texture'VMDHCFemRightLegHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemRightLegRimHighlight');
			}
			
			TCap = float(Player.Default.HealthLegRight) * ModMult;
			FPer = (float(Player.HealthLegRight) / TCap) * 100.0;
			
			TCap2 = float(Player.Default.HealthLegLeft) * ModMult;
			FPer2 = (float(Player.HealthLegLeft) / TCap) * 100.0;
			
			if ((FPer < 1) && (FPer2 < 1))
			{
				TStr = StrLegBrokenAdvanced[1];
			}
			else if ((FPer < 1) && (bAdvancedDamage))
			{
				TStr = StrLegBrokenAdvanced[0];
			}
			
			if (FPer < 1)
			{
				HealthStatusLabel.SetText(SprintF(StrRightLegRegionDescs[0], Player.HealthLegRight, int(TCap))$TStr);
			}
			else if (FPer < 34)
			{
				HealthStatusLabel.SetText(SprintF(StrRightLegRegionDescs[1], Player.HealthLegRight, int(TCap)));
			}
			else if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrRightLegRegionDescs[2], Player.HealthLegRight, int(TCap)));
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrRightLegRegionDescs[3], Player.HealthLegRight, int(TCap)));
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrRightLegRegionDescs[4], Player.HealthLegRight, int(TCap)));
			}
		break;
		case 5: //Left leg
			if (!bFemale)
			{
				HealthRegions[5].SetBackground(Texture'VMDHCLeftLegHighlight');
				HealthSelector.SetBackground(Texture'VMDHCLeftLegRimHighlight');
			}
			else
			{
				HealthRegions[5].SetBackground(Texture'VMDHCFemLeftLegHighlight');
				HealthSelector.SetBackground(Texture'VMDHCFemLeftLegRimHighlight');
			}
			
			TCap = float(Player.Default.HealthLegLeft) * ModMult;
			FPer = (float(Player.HealthLegLeft) / TCap) * 100.0;
			
			TCap2 = float(Player.Default.HealthLegRight) * ModMult;
			FPer2 = (float(Player.HealthLegRight) / TCap) * 100.0;
			
			if ((FPer < 1) && (FPer2 < 1))
			{
				TStr = StrLegBrokenAdvanced[1];
			}
			else if ((FPer < 1) && (bAdvancedDamage))
			{
				TStr = StrLegBrokenAdvanced[0];
			}
			
			if (FPer < 1)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftLegRegionDescs[0], Player.HealthLegLeft, int(TCap))$TStr);
			}
			else if (FPer < 34)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftLegRegionDescs[1], Player.HealthLegLeft, int(TCap)));
			}
			else if (FPer < 67)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftLegRegionDescs[2], Player.HealthLegLeft, int(TCap)));
			}
			else if (FPer < 95)
			{
				HealthStatusLabel.SetText(SprintF(StrLeftLegRegionDescs[3], Player.HealthLegLeft, int(TCap)));
			}
			else
			{
				HealthStatusLabel.SetText(SprintF(StrLeftLegRegionDescs[4], Player.HealthLegLeft, int(TCap)));
			}
		break;
		case 6: //ANY
			HealthRegions[6].SetBackground(Texture'VMDHCAnyHighlight');
			HealthSelector.SetBackground(Texture'VMDHCAnyRimHighlight');
			
			TCap = float(Player.Default.HealthHead + Player.Default.HealthTorso + Player.Default.HealthArmLeft + Player.Default.HealthArmRight + Player.Default.HealthLegLeft + Player.Default.HealthLegRight) * ModMult;
			FPer = (float(Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight) / TCap) * 100.0;
			
			HealthStatusLabel.SetText(SprintF(StrAnyHealTooltip, Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight, int(TCap)));
		break;
	}
}

//MADDERS, 8/26/23: If you're wondering why not just pop window, it's because sometimes code
//is still executing by the time we do, which crashes the game. This offsets these by at least a frame,
//even with god awful PC FPS.
function ForcePopWindow()
{
	Root.PopWindow();
}

function InitWindow()
{
	Super.InitWindow();	
	
	//MADDERS, 8/26/23: Hide our title bar. We are very cool and minimalist UI. We're hip.
	if (WinTitle != None)
	{
	 	WinTitle.Show(False);
	 	WinTitle = None;
	}
	
	UpdateHighlightedPos();
	UpdateHealthBars();
	
	//MADDERS, 2/25/25: Small patch for real time UI support.
	AddTimer(0.1, True,, 'UpdateInfo');
}

function CreateControls()
{
	local bool bHadFirstFive;
	local int i;
	local Augmentation TAug;
	local ColorTheme Theme;
	
	Super.CreateControls();
	
	BuildKeyBindings(); //8/27/23: We can now read inputs as they are mapped in real time. Yay.
	
	//MADDERS, 2/25/25: For later reference and use.
	Medkit = Medkit(Player.FindInventoryType(Class'Medkit'));
	
	SelectedRegion = 1; //Torso
	if (Player != None)
	{
		MedkitSquare = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		MedkitSquare.SetPos(MedkitSquarePos.X, MedkitSquarePos.Y);
		MedkitSquare.SetSize(MedkitSquareSize.X, MedkitSquareSize.Y);
		MedkitSquare.SetBackground(Texture'VMDHealthControllerMedkitSquare');
		//MedkitSquare.bBlockTranslucency = true;
		MedkitSquare.StyleChanged();
		
		MedkitIcon = VMDHealthSelectorMedkitIcon(NewChild(class'VMDHealthSelectorMedkitIcon'));
		MedkitIcon.SetPos(MedkitPos.X, MedkitPos.Y);
		
		MedkitCountLabel = CreateMenuLabel(MedkitCountLabelPos.X, MedkitCountLabelPos.Y, "", Self);
		MedkitCountLabel.SetSize(MedkitCountLabelSize.X, MedkitCountLabelSize.Y);
		MedkitCountLabel.SetPos(MedkitCountLabelPos.X, MedkitCountLabelPos.Y);
		MedkitCountLabel.SetTextAlignments(HALIGN_Right, MedkitCountLabel.VAlign);
		
		ReloadTipLabel = CreateMenuLabel(ReloadTipLabelPos.X, ReloadTipLabelPos.Y, StrReload, Self);
		ReloadTipLabel.SetSize(ReloadTipLabelSize.X, ReloadTipLabelSize.Y);
		ReloadTipLabel.SetPos(ReloadTipLabelPos.X, ReloadTipLabelPos.Y);
		
		HealthStatusLabel = CreateMenuLabel(HealthStatusPos.X, HealthStatusPos.Y, "", Self);
		HealthStatusLabel.SetSize(HealthStatusSize.X, HealthStatusSize.Y);
		HealthStatusLabel.SetTextAlignments(HALIGN_Center, HealthStatusLabel.VAlign);
		
		BioCellSquare = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		BioCellSquare.SetPos(BioCellSquarePos.X, BioCellSquarePos.Y);
		BioCellSquare.SetSize(BioCellSquareSize.X, BioCellSquareSize.Y);
		BioCellSquare.SetBackground(Texture'VMDHealthControllerMedkitSquare');
		//BioCellSquare.bBlockTranslucency = true;
		BioCellSquare.StyleChanged();
		
		BioCellIcon = VMDAugSelectorCellIcon(NewChild(class'VMDAugSelectorCellIcon'));
		BioCellIcon.SetPos(BioCellPos.X, BioCellPos.Y);
		
		AugScreenLabel = CreateMenuLabel(AugScreenLabelPos.X, AugScreenLabelPos.Y, StrDuckSwitch, Self);
		AugScreenLabel.SetSize(AugScreenLabelSize.X, AugScreenLabelSize.Y);
		AugScreenLabel.SetPos(AugScreenLabelPos.X, AugScreenLabelPos.Y);
		AugScreenLabel.SetTextAlignments(HALIGN_Center, AugScreenLabel.VAlign);
	}
	
	for(i=0; i<ArrayCount(HealthRegions); i++)
	{
		HealthRegions[i] = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		HealthRegions[i].SetPos(HealthRegionPos[i].X, HealthRegionPos[i].Y);
		HealthRegions[i].SetSize(HealthRegionSize[i].X, HealthRegionSize[i].Y);
	}
	for(i=0; i<ArrayCount(HealthRims); i++)
	{
		HealthRims[i] = NewChild(class'Window');
		HealthRims[i].SetPos(HealthRegionPos[i].X, HealthRegionPos[i].Y);
		HealthRims[i].SetSize(HealthRegionSize[i].X, HealthRegionSize[i].Y);
	}
	HealthSelector = NewChild(class'Window');
}

function UpdateInfo()
{
	UpdateHealthBars();
	UpdateHighlightedPos();
}

function UpdateHealthBars()
{
	local float FPer, TCap, ModMult;
	local int IPer, THeal;
	local Color TCol;
	
	ModMult = 1.0;
	if (VMDBufferPlayer(Player) != None)
	{
		if (VMDBufferPlayer(Player).KSHealthMult > 0)
		{
			ModMult *= VMDBufferPlayer(Player).KSHealthMult;
		}
		
		if (VMDBufferPlayer(Player).ModHealthMultiplier > 0)
		{
			ModMult *= VMDBufferPlayer(Player).ModHealthMultiplier;
		}
	}
	
	//Head health
	TCap = float(Player.Default.HealthHead) * ModMult;
	FPer = (float(Player.HealthHead) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 0);
	HealthRegions[0].bBlockReskin = true;
	HealthRegions[0].bBlockTranslucency = true;
	HealthRegions[0].OverrideColor = TCol;
	HealthRegions[0].StyleChanged();
	
	//Torso health
	TCap = float(Player.Default.HealthTorso) * ModMult;
	FPer = (float(Player.HealthTorso) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 1);
	HealthRegions[1].bBlockReskin = true;
	HealthRegions[1].bBlockTranslucency = true;
	HealthRegions[1].OverrideColor = TCol;
	HealthRegions[1].StyleChanged();
	
	//Right arm health
	TCap = float(Player.Default.HealthArmRight) * ModMult;
	FPer = (float(Player.HealthArmRight) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 2);
	HealthRegions[2].bBlockReskin = true;
	HealthRegions[2].bBlockTranslucency = true;
	HealthRegions[2].OverrideColor = TCol;
	HealthRegions[2].StyleChanged();
	
	//Left arm health
	TCap = float(Player.Default.HealthArmLeft) * ModMult;
	FPer = (float(Player.HealthArmLeft) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 3);
	HealthRegions[3].bBlockReskin = true;
	HealthRegions[3].bBlockTranslucency = true;
	HealthRegions[3].OverrideColor = TCol;
	HealthRegions[3].StyleChanged();
	
	//Right leg health
	TCap = float(Player.Default.HealthLegRight) * ModMult;
	FPer = (float(Player.HealthLegRight) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 4);
	HealthRegions[4].bBlockReskin = true;
	HealthRegions[4].bBlockTranslucency = true;
	HealthRegions[4].OverrideColor = TCol;
	HealthRegions[4].StyleChanged();
	
	//Left leg health
	TCap = float(Player.Default.HealthLegLeft) * ModMult;
	FPer = (float(Player.HealthLegLeft) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 5);
	HealthRegions[5].bBlockReskin = true;
	HealthRegions[5].bBlockTranslucency = true;
	HealthRegions[5].OverrideColor = TCol;
	HealthRegions[5].StyleChanged();
	
	TCap = float(Player.Default.HealthHead + Player.Default.HealthTorso + Player.Default.HealthArmLeft + Player.Default.HealthArmRight + Player.Default.HealthLegLeft + Player.Default.HealthLegRight) * ModMult;
	FPer = (float(Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight) / TCap) * 100.0;
	IPer = int(FPer + 0.99);
	TCol = HealthColorFromPercentage(IPer, 5);
	HealthRegions[6].bBlockReskin = true;
	HealthRegions[6].bBlockTranslucency = true;
	HealthRegions[6].OverrideColor = TCol;
	HealthRegions[6].StyleChanged();
	
	MedkitCountLabel.SetText("x0");
	MedkitIcon.SetTileColor(ColNoMedkits);
	ReloadTipLabel.SetText(StrReload);
	if ((Medkit != None) && (!Medkit.bDeleteMe) && (Medkit.NumCopies > 0))
	{
		MedkitCountLabel.SetText("x"$Medkit.NumCopies);
		MedkitIcon.SetTileColor(ColHasMedkits);
		
		THeal = Player.CalculateSkillHealAmount(Medkit.HealAmount);
		ReloadTipLabel.SetText(StrReload$CR()$"+"$THeal);
	}
}

function Color HealthColorFromPercentage(int TPer, int TarRegion)
{
	local Color Ret;
	local float FPer;
	
	//Don't return pure black, because VMDStylizedWindows reject this as an override color.
	if (TPer <= 0)
	{
		Ret.R = 1;
		Ret.G = 1;
		Ret.B = 1;
	}
	else if (TPer > 95)
	{
		Ret.G = 255;
		Ret.B = 192;
	}
	//MADDERS, 3/7/25: Just use this. It's faster by a smidge, and it's more consistent with other UI.
	else
	{
		Ret = GetColorScaled(TPer * 0.01);
	}
	
	/*else if (TPer < 67)
	{
		Ret.R = 255;
		FPer = float(TPer) / 67.0;
		Ret.G = FPer * 255;
	}
	else if (TPer < 96)
	{
		FPer = (float(100 - TPer) / 33.0);
		Ret.R = FPer * 255;
		Ret.G = 255;
	}
	else
	{
		Ret.G = 255;
		Ret.B = 192;
	}*/
	
	return Ret;
}

function BuildKeyBindings()
{
	local int i, j, UsePos, Pos, Pos2;
	local string KeyName, Alias;
	
	// First, clear all the existing keybinding display 
	// strings in the MenuValues[1|2|3] arrays
	for(i=0; i<arrayCount(MenuValues1); i++)
	{
		MenuValues1[i] = IK_None;
		MenuValues2[i] = IK_None;
		MenuValues3[i] = IK_None;
	}
	
	// Now loop through all the keynames and generate
	// human-readable versions of keys that are mapped.
	for ( i=0; i<255; i++ )
	{
		KeyName = player.ConsoleCommand ( "KEYNAME "$i );
		if ( KeyName != "" )
		{
			Alias = player.ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				Pos = InStr(Alias, " " );
				Pos2 = InStr(Alias, "|"); //MADDERS, read muticommands' primary purpose.
				
				UsePos = Pos;
				if (Pos == -1 || (Pos2 > -1 && Pos2 < Pos))
				{
					UsePos = Pos2;
				}
				if (UsePos != -1)
				{
					Alias = Left(Alias, UsePos);
				}
				
				for ( j=0; j<arrayCount(AliasNames); j++ )
				{
					if ( AliasNames[j] ~= Alias )
					{
						//MADDERS, 8/27/23: Both int and GetEnum tell me type mismatch.
						//Suck on my SetPropertyText, nerd.
						SetPropertyText( "HackKey", string(GetEnum(enum'EInputKey', i)) );
						
						if (MenuValues1[j] == IK_None)
						{
							MenuValues1[j] = HackKey;
						}
						else if (MenuValues2[j] == IK_None)
						{
							MenuValues2[j] = HackKey;
						}
						else if (MenuValues3[j] == IK_None)
						{
							MenuValues3[j] = HackKey;
						}
					}
				}
			}
		}
	}
	
	//MADDERS: Plug in all our values now.
	LeftKey[0] = MenuValues1[2];
	LeftKey[1] = MenuValues2[2];
	LeftKey[2] = MenuValues3[2];
	RightKey[0] = MenuValues1[3];
	RightKey[1] = MenuValues2[3];
	RightKey[2] = MenuValues3[3];
	UpKey[0] = MenuValues1[0];
	UpKey[1] = MenuValues2[0];
	UpKey[2] = MenuValues3[0];
	DownKey[0] = MenuValues1[1];
	DownKey[1] = MenuValues2[1];
	DownKey[2] = MenuValues3[1];
	AugMenuKey[0] = MenuValues1[4];
	AugMenuKey[1] = MenuValues2[4];
	AugMenuKey[2] = MenuValues3[4];
	HealthMenuKey[0] = MenuValues1[5];
	HealthMenuKey[1] = MenuValues2[5];
	HealthMenuKey[2] = MenuValues3[5];
	DuckKey[0] = MenuValues1[6];
	DuckKey[1] = MenuValues2[6];
	DuckKey[2] = MenuValues3[6];
	SwitchAmmoKey[0] = MenuValues1[7];
	SwitchAmmoKey[1] = MenuValues2[7];
	SwitchAmmoKey[2] = MenuValues3[7];
	HealKey[0] = MenuValues1[8];
	HealKey[1] = MenuValues2[8];
	HealKey[2] = MenuValues3[8];
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local int i;
	
	bHandled = True;
	
	Super.ButtonActivated(buttonPressed);
	
	switch(ButtonPressed)
	{
		default:
			bHandled = False;
		break;
	}
	
	return bHandled;
}

event bool VirtualKeyPressed(EInputKey Key, bool bRepeat)
{
	local int IdealMove, LastRegion;
	
	LastRegion = SelectedRegion;
	IdealMove = -1;
	switch(Key)
	{
		case UpKey[0]:
		case UpKey[1]:
		case UpKey[2]:
			IdealMove = 0;
		break;
		case DownKey[0]:
		case DownKey[1]:
		case DownKey[2]:
			IdealMove = 1;
		break;
		case LeftKey[0]:
		case LeftKey[1]:
		case LeftKey[2]:
			IdealMove = 2;
		break;
		case RightKey[0]:
		case RightKey[1]:
		case RightKey[2]:
			IdealMove = 3;
		break;
		//case IK_Escape:
		case HealthMenuKey[0]:
		case HealthMenuKey[1]:
		case HealthMenuKey[2]:
		case HealthMenuKey[3]:
			PlaySound(Sound'Menu_OK', 1.0);
			AddTimer(0.01, False,, 'ForcePopWindow');
			return true;
		break;
		case HealKey[0]:
		case HealKey[1]:
		case HealKey[2]:
			UseMedkit();
			return true;
		break;
		case AugMenuKey[0]:
		case AugMenuKey[1]:
		case AugMenuKey[2]:
		case DuckKey[0]:
		case DuckKey[1]:
		case DuckKey[2]:
		case SwitchAmmoKey[0]:
		case SwitchAmmoKey[1]:
		case SwitchAmmoKey[2]:
			PlaySound(Sound'Menu_OK', 1.0);
			AddTimer(0.01, false,, 'OpenAugScreen');
			return true;
		break;
	}
	
	if (IdealMove > -1)
	{
		switch(IdealMove)
		{
			case 0: //MADDERS: Up.
				switch(SelectedRegion)
				{
					case 0: //Head goes to ANY.
						SelectedRegion = 6;
					break;
					case 1: //Torso and arms go to head.
					case 2:
					case 3:
						SelectedRegion = 0;
					break;
					case 4: //Legs go to torso.
					case 5:
						SelectedRegion = 1;
					break;
				}
			break;
			case 1: //MADDERS: Down.
				switch(SelectedRegion)
				{
					case 0: //Head goes to torso.
						SelectedRegion = 1;
					break;
					case 1: //Torso and right arm go to right leg.
					case 2:
						SelectedRegion = 4;
					break;
					case 3: //Left arm goes to left leg.
						SelectedRegion = 5;
					break;
					case 6: //ANY goes to head.
						SelectedRegion = 0;
					break;
				}
			break;
			case 2: //MADDERS: Left.
				switch(SelectedRegion)
				{
					case 0: //Head and torso goes to right arm.
					case 1:
					case 6:
						SelectedRegion = 2;
					break;
					case 3: //Left arm goes to torso.
						SelectedRegion = 1;
					break;
					case 5: //Left leg goes to right leg.
						SelectedRegion = 4;
					break;
				}
			break;
			case 3: //MADDERS: Right.
				switch(SelectedRegion)
				{
					case 0: //Head and torso goes to left arm.
					case 1:
					case 6:
						SelectedRegion = 3;
					break;
					case 2: //Right arm goes to torso.
						SelectedRegion = 1;
					break;
					case 4: //Right leg goes to left leg.
						SelectedRegion = 5;
					break;
				}
			break;
		}
		UpdateHighlightedPos();
	}
	
	if (LastRegion != SelectedRegion)
	{
		PlaySound(Sound'Menu_Press', 1.0);
	}
	
 	return True;
}

function OpenAugScreen()
{
	root.PopWindow();
	root.InvokeMenuScreen(Class'VMDMenuAugsSelector');
}

function UseMedkit()
{
	local int HealLevel, BaseHeal, THeal, PointsHealed;
	local float ModMult;
	local VMDBufferPlayer VMP;
	
	if (Player == None) return;
	VMP = VMDBufferPlayer(Player);
	
	if (MedKit == None || Medkit.bDeleteMe || Medkit.NumCopies < 1)
		return;
	
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
	
	switch(SelectedRegion)
	{
		case 0:		// head
			THeal = Min(float(Player.Default.HealthHead) * ModMult - Player.HealthHead, HealLevel);
		break;
		case 1:		// torso, right arm, left arm
			THeal = Min(float(Player.Default.HealthTorso) * ModMult - Player.HealthTorso, HealLevel);
		break;
		case 2:		//right arm, left arm
			THeal = Min(float(Player.Default.HealthArmRight) * ModMult - Player.HealthArmRight, HealLevel);
		break;
		case 3:
			THeal = Min(float(Player.Default.HealthArmLeft) * ModMult - Player.HealthArmLeft, HealLevel);
		break;
		case 4:		// right leg, left leg
			THeal = Min(float(Player.Default.HealthLegRight) * ModMult - Player.HealthLegRight, HealLevel);
		break;
		case 5:
			THeal = Min(float(Player.Default.HealthLegLeft) * ModMult - Player.HealthLegLeft, HealLevel);
		break;
		case 6:
			if (VMP != None)
			{
				THeal = VMP.HealPlayerSilent(HealLevel, False);
			}
		break;
	}
	
	//MADDERS, 3/8/25: Don't let us waste medkits on full parts.
	if (THeal <= 0)
	{
		return;
	}
	
	//MADDERS: Reduce how much healing we're using by how much is used.
	HealLevel -= THeal;
	
	pointsHealed = HealPart(SelectedRegion);
	player.GenerateTotalHealth(); // Transcended - Added
	
	//MADDERS: Rollover, bby. Now related to the skill augment.
	if ((THeal < BaseHeal) && (VMP != None) && (VMP.HasSkillAugment('MedicineWraparound')))
	{
	 	VMP.HealPlayerSilent(HealLevel, False);
	}
	
	//MADDERS, 5/26/20: Run this afterwards to un-bork healing to direct parts after killswitch has lowered HP.
	if (VMP != None)
	{
		VMP.UpdateKillswitchHealth(VMP.KillswitchTime);
	}
	
	UpdateHealthBars();
}

function int HealPart(int PartIndex, optional float pointsToHeal, optional bool bLeaveMedKit)
{
	local float healthAdded, newHealth, ModMult;
	
	// If a point value was passed in, use it as the amount of 
	// points to heal for this body part.  Otherwise use the 
	// medkit's default heal amount.
	if (pointsToHeal == 0)
	{
		pointsToHeal = player.CalculateSkillHealAmount(medKit.healAmount);
	}
	
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
	
	switch(PartIndex)
	{
		case 0:		// head
			newHealth = FMin(player.HealthHead + pointsToHeal, float(player.default.HealthHead) * ModMult);
			healthAdded = newHealth - player.HealthHead;
			player.HealthHead = NewHealth;
		break;
		case 1:		// torso
			newHealth = FMin(player.HealthTorso + pointsToHeal, float(player.default.HealthTorso) * ModMult);
			healthAdded = newHealth - player.HealthTorso;
			player.HealthTorso = newHealth;
		break;
		case 2:		// right arm
			newHealth = FMin(player.HealthArmRight + pointsToHeal, float(player.default.HealthArmRight) * ModMult);
			healthAdded = newHealth - player.HealthArmRight;
			player.HealthArmRight = newHealth;
		break;
		case 3:		// left arm
			newHealth = FMin(player.HealthArmLeft + pointsToHeal, float(player.default.HealthArmLeft) * ModMult);
			healthAdded = newHealth - player.HealthArmLeft;
			player.HealthArmLeft = newHealth;
		break;
		case 4:		// right leg
			newHealth = FMin(player.HealthLegRight + pointsToHeal, float(player.default.HealthLegRight) * ModMult);
			healthAdded = newHealth - player.HealthLegRight;
			player.HealthLegRight = newHealth;
		break;
		case 5:		// left leg
			newHealth = FMin(player.HealthLegLeft + pointsToHeal, float(player.default.HealthLegLeft) * ModMult);
			healthAdded = newHealth - player.HealthLegLeft;
			player.HealthLegLeft = newHealth;
		break;
	}
	
	// Remove the item from the player's inventory and this screen
	if (!bLeaveMedKit)
	{
		if (VMDBufferPlayer(Player) != None)
		{
			Medkit.VMDRunMedkitShellEffects(VMDBufferPlayer(Player));
		}
		medKit.UseOnce();
		Player.PlaySound(sound'MedicalHiss', SLOT_None,,, 512, Medkit.VMDGetMiscPitch2());
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

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
 	return false; // don't handle
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	VirtualKeyPressed(Button, false); //MADDERS: Massive hack. Check mouse buttons how we check all buttons.
	
	return false;
}

event bool RawMouseButtonPressed(float pointX, float pointY, EInputKey button, EInputState iState)
{
	return false; // don't handle
}

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
 	return false;
}

function bool CanStack()
{
 	return false;
}

defaultproperties
{
     HealthRegionPos(0)=(X=119,Y=56)
     HealthRegionSize(0)=(X=64,Y=64)
     HealthRegionPos(1)=(X=98,Y=93)
     HealthRegionSize(1)=(X=128,Y=256)
     HealthRegionPos(2)=(X=54,Y=115)
     HealthRegionSize(2)=(X=64,Y=256)
     HealthRegionPos(3)=(X=166,Y=115)
     HealthRegionSize(3)=(X=64,Y=256)
     HealthRegionPos(4)=(X=87,Y=218)
     HealthRegionSize(4)=(X=64,Y=256)
     HealthRegionPos(5)=(X=136,Y=218)
     HealthRegionSize(5)=(X=64,Y=256)
     HealthRegionPos(6)=(X=115,Y=0)
     HealthRegionSize(6)=(X=64,Y=64)
     MedkitSquarePos=(X=203,Y=5)
     MedkitSquareSize=(X=42,Y=42)
     
     HealthRegionPosFemale(0)=(X=119,Y=56)
     HealthRegionPosFemale(1)=(X=96,Y=94)
     HealthRegionPosFemale(2)=(X=55,Y=124)
     HealthRegionPosFemale(3)=(X=165,Y=124)
     HealthRegionPosFemale(4)=(X=87,Y=210)
     HealthRegionPosFemale(5)=(X=136,Y=210)
     
     StrReload="Reload"
     MedkitPos=(X=206,Y=8)
     MedkitCountLabelPos=(X=191,Y=33)
     MedkitCountLabelSize=(X=48,Y=24)
     ReloadTipLabelPos=(X=202,Y=52)
     ReloadTipLabelSize=(X=48,Y=48)
     ColNoMedkits=(R=96,G=96,B=96)
     ColHasMedkits=(R=255,G=255,B=255)
     
     BiocellSquarePos=(X=249,Y=5)
     BiocellSquareSize=(X=42,Y=42)
     BiocellPos=(X=252,Y=8)
     AugScreenLabelPos=(X=249,Y=52)
     AugScreenLabelSize=(X=48,Y=24)
     StrDuckSwitch="Duck"
     
     ClientWidth=302
     ClientHeight=520
     
     clientTextures(0)=None
     clientTextures(1)=None
     clientTextures(2)=None
     clientTextures(3)=None
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=1
     TextureCols=1
     
     HealthStatusPos=(X=41,Y=412)
     HealthStatusSize=(X=192,Y=128)
     StrHeadRegionDescs(0)="Head: %d/%d |nWound Lvl 1 (<67%%)|nAccuracy-"
     StrHeadRegionDescs(1)="Head: %d/%d |nGood Condition|nNo Damage Gate"
     StrHeadRegionDescs(2)="Head: %d/%d |nPristine Condition|nDamage Gated"
     StrTorsoRegionDescs(0)="Torso: %d/%d |nWound Lvl 1 (<67%%)|nSpeed-"
     StrTorsoRegionDescs(1)="Torso: %d/%d |nGood Condition|nNo Damage Gate"
     StrTorsoRegionDescs(2)="Torso: %d/%d |nPristine Condition|nDamage Gated"
     StrLeftArmRegionDescs(0)="Left Arm: %d/%d |nBroken|n2H Accuracy--|nLeft 1H Accuracy----"
     StrLeftArmRegionDescs(1)="Left Arm: %d/%d |nWound Lvl 2 (<34%%)|n2H Accuracy-|nLeft 1H Accuracy--"
     StrLeftArmRegionDescs(2)="Left Arm: %d/%d |nWound Lvl 1 (<67%%)|n2H Accuracy-|nLeft 1H Accuracy-"
     StrLeftArmRegionDescs(3)="Left Arm: %d/%d |nGood Condition|nNo Damage Gate"
     StrLeftArmRegionDescs(4)="Left Arm: %d/%d |nPristine Condition|nDamage Gated"
     StrRightArmRegionDescs(0)="Right Arm: %d/%d |nBroken|n2H Accuracy--|nRight 1H Accuracy----"
     StrRightArmRegionDescs(1)="Right Arm: %d/%d |nWound Lvl 2 (<34%%)|n2H Accuracy-|nRight 1H Accuracy--"
     StrRightArmRegionDescs(2)="Right Arm: %d/%d |nWound Lvl 1 (<67%%)|n2H Accuracy-|nRight 1H Accuracy-"
     StrRightArmRegionDescs(3)="Right Arm: %d/%d |nGood Condition|nNo Damage Gate"
     StrRightArmRegionDescs(4)="Right Arm: %d/%d |nPristine Condition|nDamage Gated"
     StrLeftLegRegionDescs(0)="Left Leg: %d/%d |nBroken|nSpeed---"
     StrLeftLegRegionDescs(1)="Left Leg: %d/%d |nWound Lvl 2 (<34%%)|nSpeed--"
     StrLeftLegRegionDescs(2)="Left Leg: %d/%d |nWound Lvl 1 (<67%%)|nSpeed-"
     StrLeftLegRegionDescs(3)="Left Leg: %d/%d |nGood Condition|nNo Damage Gate"
     StrLeftLegRegionDescs(4)="Left Leg: %d/%d |nPristine Condition|nDamage Gated"
     StrRightLegRegionDescs(0)="Right Leg: %d/%d |nBroken|nSpeed---"
     StrRightLegRegionDescs(1)="Right Leg: %d/%d |nWound Lvl 2 (<34%%)|nSpeed--"
     StrRightLegRegionDescs(2)="Right Leg: %d/%d |nWound Lvl 1 (<67%%)|nSpeed-"
     StrRightLegRegionDescs(3)="Right Leg: %d/%d |nGood Condition|nNo Damage Gate"
     StrRightLegRegionDescs(4)="Right Leg: %d/%d |nPristine Condition|nDamage Gated"
     StrAnyHealTooltip="General Healing: %d/%d |nHeal Order: Head -> Torso -> R Leg -> L Leg -> R Arm -> L Arm"
     StrArmBrokenAdvanced(0)="|nDisarmed"
     StrArmBrokenAdvanced(1)="|nImpairs Healing|nDisarmed"
     StrLegBrokenAdvanced(0)="|nForces Limp"
     StrLegBrokenAdvanced(1)="|nForces Crawl"
     StrUrgent(0)="|nUrgent! Fire!"
     StrUrgent(1)="|nUrgent! Poison!"
     
     HealthMenuKey(3)=IK_Escape //Hack.
     AliasNames(0)="MoveForward"
     AliasNames(1)="MoveBackward"
     AliasNames(2)="StrafeLeft"
     AliasNames(3)="StrafeRight"
     AliasNames(4)="OpenControllerAugWindow"
     AliasNames(5)="OpenControllerHealthWindow"
     AliasNames(6)="Duck"
     AliasNames(7)="SwitchAmmo"
     AliasNames(8)="ReloadWeapon"
}
