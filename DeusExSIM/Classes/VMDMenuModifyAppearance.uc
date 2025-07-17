//=============================================================================
// VMDMenuModifyAppearance
//=============================================================================
class VMDMenuModifyAppearance expands VMDMenuSelectAppearanceParent;

#exec OBJ LOAD FILE=VMDAssets

function AdjustWindowPositionHack()
{
	local int ResoWidth, ResoHeight, XPos;
	local float UISpaceX, UISpaceY, HackMult, RelX, RelY;
	local string GetReso;
	
	if (Player == None) return;
	
	UISpaceX = Width + X*2;
	
	GetReso = Player.ConsoleCommand("GetCurrentRes");
	XPos = InStr(GetReso,"x");
	ResoWidth = int(Left(GetReso, XPos));
	
	HackMult = UISpaceX / float(ResoWidth);
	RelX = (1000.0 / 1600.0) * ResoWidth * HackMult;
	RelY = Y;
	
	SetPos(RelX, RelY);
}

event DestroyWindow()
{
	if (VMP != None)
	{
		VMP.bUnlit = false;
		VMP.bBehindView = false;
		VMP.OverrideCameraLocation = Vect(0,0,0);
		VMP.OverrideCameraRotation = Rot(0,0,0);
	}
	
	Super.DestroyWindow();
}

function SetCampaignData(string NewCampaign)
{
	local bool TFemale;
	local int i;
	
	VMP = VMDBufferPlayer(Player);
	TFemale = VMP.bAssignedFemale;
	
	StoredCampaign = NewCampaign;
	
	switch(CAPS(NewCampaign))
	{
		//No sunglasses, but limit to paul textures, too.
		case "ZODIAC":
		case "OTHERPAULNOFOOD":
		case "OTHERPAULNOFOODNOINTRO":
		case "OTHERPAULZEROFOOD":
		case "OTHERPAULZEROFOODNOINTRO":
			TrenchLensesTexs[0] = Texture'BlackMaskTex';
			MaxTrenchLensesIndex = 0;
			TrenchFramesTexs[0] = Texture'GrayMaskTex';
			MaxTrenchFramesIndex = 0;
		break;
		//Only parse paul textures for zodiac, but with sunglasses.
		case "REDSUN":
		case "REDSUN2020":
		break;
		case "NIHILUM":
			LoadNihilumAssetBounds();
		break;
		case "COUNTERFEIT":
			LoadCounterfeitAssetBounds();
		break;
		case "IWR":
			LoadIWRAssetBounds();
		break;
		//Forcibly cram all this shit in for Venom's appearance. Yeah, I thought of it. So what?
		case "BLOODLIKEVENOM":
			LoadBLVAssetBounds();
		break;
		//TODO: Setup trestkon and all that BS from TNM.
		//Update: Lolno. TNM is too elaborate to simply drop in.
		case "TNM":
		break;
		//05/29/25: Oh hey, it's me.
		case "HIVEDAYS":
			LoadHiveDaysAssetBounds();
		break;
		//Allow female gender for all campaigns except zodiac, redsun, and TNM.
		default:
			//MADDERS: Only if the option is enabled. I think this is best left as "opt-in".
			if (VMP != None)
			{
				CreatePresetSaveButton();
				CreatePresetLoadButton();
				CreatePresetPrevButton();
				CreatePresetNextButton();
			}
			StyleChanged();
		break;
	}
	
	if (TFemale)
	{
		for(i=0; i<=MaxFemaleMeshIndex; i++)
		{
			if (VMP.Mesh == FemaleMeshes[i] || VMP.Mesh == FemaleLeftMeshes[i])
			{
				CurFemaleMeshIndex = i;
				break;
			}
		}
	}
	else
	{
		for(i=0; i<=MaxMaleMeshIndex; i++)
		{
			if (VMP.Mesh == MaleMeshes[i] || VMP.Mesh == MaleLeftMeshes[i])
			{
				CurMaleMeshIndex = i;
				break;
			}
		}
	}
	
	if (!TFemale)
	{
		if (CurMaleMeshIndex == 0 || CurMaleMeshIndex == 1)
		{
			for(i=0; i<=MaxTrenchLensesIndex; i++)
			{
				if (VMP.Multiskins[7] == TrenchLensesTexs[i])
				{
					CurTrenchLensesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchFramesIndex; i++)
			{
				if (VMP.Multiskins[6] == TrenchFramesTexs[i])
				{
					CurTrenchFramesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchChestIndex; i++)
			{
				if (VMP.Multiskins[4] == TrenchChestTexs[i])
				{
					CurTrenchChestIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchCoatIndex; i++)
			{
				if (VMP.Multiskins[1] == TrenchCoatTexs[i])
				{
					CurTrenchCoatIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchPantsIndex; i++)
			{
				if (VMP.Multiskins[2] == TrenchPantsTexs[i])
				{
					CurTrenchPantsIndex = i;
					break;
				}
			}
		}
		else if (CurMaleMeshIndex == 2)
		{
			for(i=0; i<=MaxTrenchPantsIndex; i++)
			{
				if (VMP.Multiskins[1] == TrenchPantsTexs[i])
				{
					CurJumpsuitPantsIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxJumpsuitShirtIndex; i++)
			{
				if (VMP.Multiskins[1] == JumpsuitShirtTexs[i])
				{
					CurJumpsuitShirtIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxJumpsuitHelmetIndex; i++)
			{
				if (VMP.Multiskins[6] == JumpsuitHelmetTexs[i])
				{
					CurJumpsuitHelmetIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxJumpsuitVisorIndex; i++)
			{
				if (VMP.Texture == JumpsuitVisorTexs[i])
				{
					CurJumpsuitVisorIndex = i;
					break;
				}
			}
		}
		else if (CurMaleMeshIndex == 3)
		{
			for(i=0; i<=MaxTrenchLensesIndex; i++)
			{
				if (VMP.Multiskins[6] == TrenchLensesTexs[i])
				{
					CurSuitLensesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchFramesIndex; i++)
			{
				if (VMP.Multiskins[5] == TrenchFramesTexs[i])
				{
					CurSuitFramesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchPantsIndex; i++)
			{
				if (VMP.Multiskins[1] == TrenchPantsTexs[i])
				{
					CurSuitPantsIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxSuitShirtIndex; i++)
			{
				if (VMP.Multiskins[4] == SuitShirtTexs[i])
				{
					CurSuitShirtIndex = i;
					break;
				}
			}
		}
		else if (CurMaleMeshIndex == 4 || CurMaleMeshIndex == 5 || CurMaleMeshIndex == 6)
		{
			for(i=0; i<=MaxTrenchLensesIndex; i++)
			{
				if (VMP.Multiskins[7] == TrenchLensesTexs[i])
				{
					CurDressShirtLensesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchFramesIndex; i++)
			{
				if (VMP.Multiskins[6] == TrenchFramesTexs[i])
				{
					CurDressShirtFramesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchPantsIndex; i++)
			{
				if (VMP.Multiskins[3] == TrenchPantsTexs[i])
				{
					CurDressShirtPantsIndex = i;
					break;
				}
			}
			for (i=0; i<=MaxDressShirtShirtIndex; i++)
			{
				if (VMP.Multiskins[5] == DressShirtShirtTexs[i])
				{
					CurDressShirtShirtIndex = i;
					break;
				}
			}
		}
	}
	else
	{
		if (CurFemaleMeshIndex == 0)
		{
			for(i=0; i<=MaxTrenchLensesIndex; i++)
			{
				if (VMP.Multiskins[7] == TrenchLensesTexs[i])
				{
					CurTrenchLensesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchFramesIndex; i++)
			{
				if (VMP.Multiskins[6] == TrenchFramesTexs[i])
				{
					CurTrenchFramesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchChestIndex; i++)
			{
				if (VMP.Multiskins[4] == TrenchChestTexs[i])
				{
					CurTrenchChestIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchCoatIndex; i++)
			{
				if (VMP.Multiskins[1] == TrenchCoatTexs[i])
				{
					CurTrenchCoatIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchPantsIndex; i++)
			{
				if (VMP.Multiskins[2] == TrenchPantsTexs[i])
				{
					CurTrenchPantsIndex = i;
					break;
				}
			}
		}
		if (CurFemaleMeshIndex == 1 || CurFemaleMeshIndex == 2)
		{
			for(i=0; i<=MaxTrenchLensesIndex; i++)
			{
				if (VMP.Multiskins[7] == TrenchLensesTexs[i])
				{
					CurSuitSkirtLensesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxTrenchFramesIndex; i++)
			{
				if (VMP.Multiskins[6] == TrenchFramesTexs[i])
				{
					CurSuitSkirtFramesIndex = i;
					break;
				}
			}
			for(i=0; i<=MaxSuitSkirtShirtIndex; i++)
			{
				if (VMP.Multiskins[4] == SuitSkirtShirtTexs[i])
				{
					CurSuitSkirtShirtIndex = i;
					break;
				}
			}
			if (VMP.Multiskins[1] != Texture'PinkMaskTex')
			{
				CurSuitSkirtHairIndex = 1;
			}
		}
		if (CurFemaleMeshIndex == 3)
		{
			for(i=0; i<=MaxDressShirtIndex; i++)
			{
				if (VMP.Multiskins[3] == DressShirtTexs[i])
				{
					CurDressShirtIndex = i;
					break;
				}
			}
			if (VMP.Multiskins[5] == Texture'PinkMaskTex')
			{
				if (VMP.Multiskins[6] == Texture'PinkMaskTex')
				{
					CurDressHairIndex = 0;
				}
				else
				{
					CurDressHairIndex = 1;
				}
			}
			else
			{
				if (VMP.Multiskins[6] == Texture'PinkMaskTex')
				{
					CurDressHairIndex = 2;
				}
				else
				{
					CurDressHairIndex = 3;
				}
			}
		}
	}
	
	DudRot = VMP.Rotation;
	
	UpdatePlayerAppearance();
	AddTimer(0.1, false,, 'UpdatePlayerAppearance');
}

function CreateEntryWindows()
{
	//GenderEntry = CreateMenuEditWindow(GenderPos.X, GenderPos.Y, 113, 32, winClient);
	MeshEntry = CreateMenuEditWindow(MeshPos.X, MeshPos.Y, 113, 32, winClient);
	//SkinEntry = CreateMenuEditWindow(SkinPos.X, SkinPos.Y, 113, 32, winClient);
	PantsEntry = CreateMenuEditWindow(PantsPos.X, PantsPos.Y, 113, 32, winClient);
	ChestEntry = CreateMenuEditWindow(ChestPos.X, ChestPos.Y, 113, 32, winClient);
	CoatEntry = CreateMenuEditWindow(CoatPos.X, CoatPos.Y, 113, 32, winClient);
	LensesEntry = CreateMenuEditWindow(LensesPos.X, LensesPos.Y, 113, 32, winClient);
	FramesEntry = CreateMenuEditWindow(FramesPos.X, FramesPos.Y, 113, 32, winClient);
	//GenderEntry.SetSensitivity(false);
	MeshEntry.SetSensitivity(false);
	//SkinEntry.SetSensitivity(false);
	PantsEntry.SetSensitivity(false);
	ChestEntry.SetSensitivity(false);
	CoatEntry.SetSensitivity(false);
	LensesEntry.SetSensitivity(false);
	FramesEntry.SetSensitivity(false);
	
	PresetEntry = CreateMenuEditWindow(PresetPos.X, PresetPos.Y, 113, 32, WinClient);
	PresetEntry.SetSensitivity(false);
	
	//HandednessEntry = CreateMenuEditWindow(HandednessPos.X, HandednessPos.Y, 113, 32, WinClient);
	//HandednessEntry.SetSensitivity(false);
}

function CreateFieldLabels()
{
	//GenderLabel = CreateMenuLabel(GenderPos.X+LabelHeaderPos.X, GenderPos.Y+LabelHeaderPos.Y, GenderLabelText, winClient);
	MeshLabel = CreateMenuLabel(MeshPos.X+LabelHeaderPos.X, MeshPos.Y+LabelHeaderPos.Y, MeshLabelText, winClient);
	//SkinLabel = CreateMenuLabel(SkinPos.X+LabelHeaderPos.X, SkinPos.Y+LabelHeaderPos.Y, SkinLabelText, winClient);
	LensesLabel = CreateMenuLabel(LensesPos.X+LabelHeaderPos.X, LensesPos.Y+LabelHeaderPos.Y, LensesLabelText, winClient);
	FramesLabel = CreateMenuLabel(FramesPos.X+LabelHeaderPos.X, FramesPos.Y+LabelHeaderPos.Y, FramesLabelText, winClient);
	ChestLabel = CreateMenuLabel(ChestPos.X+LabelHeaderPos.X, ChestPos.Y+LabelHeaderPos.Y, ChestLabelText, winClient);
	CoatLabel = CreateMenuLabel(CoatPos.X+LabelHeaderPos.X, CoatPos.Y+LabelHeaderPos.Y, CoatLabelText, winClient);
	PantsLabel = CreateMenuLabel(PantsPos.X+LabelHeaderPos.X, PantsPos.Y+LabelHeaderPos.Y, PantsLabelText, winClient);
	
	//TrueNameLabel = CreateMenuLabel(TrueNamePos.X+LabelHeaderPos.X, TrueNamePos.Y+LabelHeaderPos.Y, HeaderNameLabel, winClient);
	//CodeNameLabel = CreateMenuLabel(CodeNamePos.X+LabelHeaderPos.X, CodeNamePos.Y+LabelHeaderPos.Y, HeaderCodeNameLabel, winClient);
	
	PresetLabel = CreateMenuLabel(PresetPos.X+LabelHeaderPos.X, PresetPos.Y+LabelHeaderPos.Y, SavedLabelText, WinClient);
	
	//HandednessLabel = CreateMenuLabel(HandednessPos.X+LabelHeaderPos.X, HandednessPos.Y+LabelHeaderPos.Y, HandednessLabelText, WinClient);
}

// Smoke39 - let us see what we look like
function PostDrawWindow(GC gc)
{
	local Rotator TRot;
	
	if (!bIsVisible)
		return;
	
	TRot = DudRot;
	if (VMP != None)
	{
		VMP.SetRotation(TRot);
		VMP.ViewRotation = TRot;
	}
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);
	
	Show();
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	AddTimer(0.02, false,, 'AdjustWindowPositionHack');
	
	CreateEntryWindows();
	CreateFieldLabels();
	CreateMeshPrevButton();
	CreateMeshNextButton();
	CreateFramesPrevButton();
	CreateFramesNextButton();
	CreateLensesPrevButton();
	CreateLensesNextButton();
	CreateCoatPrevButton();
	CreateCoatNextButton();
	CreateChestPrevButton();
	CreateChestNextButton();
	CreatePantsPrevButton();
	CreatePantsNextButton();
	
	CreateRandomButton();
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	switch( buttonPressed )
	{
		default:
			bHandled = False;
		break;
	}
	
	if ( !bHandled )
		bHandled = Super.ButtonActivated(buttonPressed);
	
	return bHandled;
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	root.PopWindow();
	return true;
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	local Color colButtonFace;
	
	Super.StyleChanged();
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	// Title colors
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
	
	//----------------
	//MESH
	ButtonMeshPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonMeshNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);	
	//----------------
	//LENSES
	ButtonLensesPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonLensesNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	//----------------
	//FRAMES
	ButtonFramesPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonFramesNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	//----------------
	//CHEST
	ButtonChestPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonChestNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	//----------------
	//COAT
	ButtonCoatPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonCoatNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	//----------------
	//PANTS
	ButtonPantsPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonPantsNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);

	//----------------
	//PRESETS
	if (ButtonPresetPrev != None)
	{
		ButtonPresetPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	if (ButtonPresetNext != None)
	{
		ButtonPresetNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
}

// ----------------------------------------------------------------------
// TrimSpaces()
// ----------------------------------------------------------------------

function String TrimSpaces(String trimString)
{
	local int trimIndex;
	local int trimLength;

	if ( trimString == "" ) 
		return trimString;

	trimIndex = Len(trimString) - 1;
	while ((trimIndex >= 0) && (Mid(trimString, trimIndex, 1) == " ") )
		trimIndex--;

	if ( trimIndex < 0 )
		return "";

	trimString = Mid(trimString, 0, trimIndex + 1);

	trimIndex = 0;
	while((trimIndex < Len(trimString) - 1) && (Mid(trimString, trimIndex, 1) == " "))
		trimIndex++;

	trimLength = len(trimString) - trimIndex;
	trimString = Right(trimString, trimLength);

	return trimString;
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	if (actionKey ~= "START")
	{
		SaveSettings();
		ConfirmNewDress();
	}
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	local int i;
	
	if (VMP != None)
	{
		//MADDERS: Cram in our skin, gender, and mesh data.
		VMP.DefabricatePlayerAppearance();
	}
	
	Player.SaveConfig();
}

function DoPop()
{
	Root.PopWindow();
}

function ConfirmNewDress()
{
	AddTimer(0.01, false,, 'DoPop');
}

defaultproperties
{
     MeshPos=(X=184,Y=36)
     LensesPos=(X=184,Y=82)
     FramesPos=(X=184,Y=128)
     ChestPos=(X=37,Y=59)
     CoatPos=(X=37,Y=105)
     PantsPos=(X=37,Y=151)
     
     LabelHeaderPos=(X=3,Y=-19)
     ArrowLeftOffset=-15
     ArrowRightOffset=113
     
     PresetPos=(X=37,Y=199)
     SavePresetButtonPos=(X=37,Y=233)
     LoadPresetButtonPos=(X=37,Y=217)
     
     RandomButtonPos=(X=184,Y=217)
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Other,Text="|&Done",Key="START")
     Title="Appearance Setup"
     ClientWidth=324
     ClientHeight=271
     textureRows=2
     textureCols=2
     clientTextures(0)=Texture'MenuModifyAppearanceBackground_1'
     clientTextures(1)=Texture'MenuModifyAppearanceBackground_2'
     clientTextures(2)=Texture'MenuModifyAppearanceBackground_3'
     clientTextures(3)=Texture'MenuModifyAppearanceBackground_4'
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
}
