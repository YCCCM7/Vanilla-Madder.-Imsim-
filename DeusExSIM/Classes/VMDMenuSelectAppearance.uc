//=============================================================================
// VMDMenuSelectAppearance
//=============================================================================
class VMDMenuSelectAppearance expands VMDMenuSelectAppearanceParent;

#exec OBJ LOAD FILE=VMDAssets

function AdjustWindowPositionHack()
{
	local int ResoWidth, ResoHeight, XPos;
	local float UISpaceX, UISpaceY, HackMult, RelX, RelY;
	local string GetReso;
	
	if (DuderoniPizza == None || Player == None) return;
	
	UISpaceX = Width + X*2;
	
	GetReso = Player.ConsoleCommand("GetCurrentRes");
	XPos = InStr(GetReso,"x");
	ResoWidth = int(Left(GetReso, XPos));
	
	HackMult = UISpaceX / float(ResoWidth);
	RelX = (655.0 / 1600.0) * ResoWidth * HackMult;
	RelY = Y;
	
	SetPos(RelX, RelY);
}

event DestroyWindow()
{
	if (DuderoniPizza != None)
	{
		DuderoniPizza.bHidden = false;
	}
	
	Super.DestroyWindow();
}

function SetCampaignData(float NewDifficulty, string NewCampaign)
{
	local bool bFemaleInapplicable;
	
	VMP = VMDBufferPlayer(Player);
	
	StoredDifficulty = NewDifficulty;
	StoredCampaign = NewCampaign;
	DDSFat = 5;
	
	switch(CAPS(VMP.CampaignNewGameMap))
	{
		case "21_TOKYO_BANK":
		case "21_INTRO1":
		case "69_ZODIAC_INTRO":
		case "80_BURDEN_INTRO":
		case "59_INTRO":
		case "44in":
		case "CF_00_Intro":
		case "GOTEM":
		case "01_BASE":
		case "01_APARTMENTBUILDING":
		case "16_THE_HQ":
		case "CORRUPTION_INTRO":
		case "16_FLINSCHMAP":
		case "71_WHITEHOUSE":
		case "FLUCHTWEG":
		case "17_FLINSCHMAP":
		case "51_GVILLE_DOWNTOWN":
		case "16_RESCUE_INTRO": //Non-aroo has us play a thug.
			bFemaleInapplicable = true;
		break;
	}
	
	switch(CAPS(NewCampaign))
	{
		//No sunglasses, but limit to paul textures, too.
		case "ZODIAC":
		case "OTHERPAULNOFOOD":
		case "OTHERPAULNOFOODNOINTRO":
		case "OTHERPAULZEROFOOD":
		case "OTHERPAULZEROFOODNOINTRO":
			CurTrenchChestIndex = 16;
			CurTrenchCoatIndex = 13;
			CurTrenchPantsIndex = 33;
			TrenchLensesTexs[0] = Texture'BlackMaskTex';
			MaxTrenchLensesIndex = 0;
			TrenchFramesTexs[0] = Texture'GrayMaskTex';
			MaxTrenchFramesIndex = 0;
			MaleSkinTexs[0] = Texture'DeusExCharacters.Skins.PaulDentonTex0';
			MaleSkinTexs[1] = Texture'DeusExCharacters.Skins.PaulDentonTex4';
			MaleSkinTexs[2] = Texture'DeusExCharacters.Skins.PaulDentonTex5';
			MaleSkinTexs[3] = Texture'DeusExCharacters.Skins.PaulDentonTex6';
			MaleSkinTexs[4] = Texture'DeusExCharacters.Skins.PaulDentonTex7';
			if (EditCodeName != None) EditCodeName.SetText("Paul Denton");
			if (EditName != None) EditName.SetText("Paul Denton");
		break;
		//Only parse paul textures for zodiac, but with sunglasses.
		case "REDSUN":
		case "REDSUN2020":
			CurTrenchChestIndex = 16;
			CurTrenchCoatIndex = 13;
			CurTrenchPantsIndex = 33;
			MaleSkinTexs[0] = Texture'DeusExCharacters.Skins.PaulDentonTex0';
			MaleSkinTexs[1] = Texture'DeusExCharacters.Skins.PaulDentonTex4';
			MaleSkinTexs[2] = Texture'DeusExCharacters.Skins.PaulDentonTex5';
			MaleSkinTexs[3] = Texture'DeusExCharacters.Skins.PaulDentonTex6';
			MaleSkinTexs[4] = Texture'DeusExCharacters.Skins.PaulDentonTex7';
			if (EditCodeName != None) EditCodeName.SetText("Joseph");
			if (EditName != None) EditName.SetText("Joseph");
		break;
		case "NIHILUM":
			if (EditCodeName != None) EditCodeName.SetText("Mad Ingram");
			if (EditName != None) EditName.SetText("Mad Ingram");
			LoadNihilumAssetBounds();
		break;
		case "COUNTERFEIT":
			if (EditCodeName != None) EditCodeName.SetText("Dominic Bishop");
			if (EditName != None) EditName.SetText("Dominic Bishop");
			LoadCounterfeitAssetBounds();
		break;
		case "IWR":
			if (EditCodeName != None) EditCodeName.SetText("Alex Denton");
			if (EditName != None) EditName.SetText("Alex Denton");
			LoadIWRAssetBounds();
		break;
		//Forcibly cram all this shit in for Venom's appearance. Yeah, I thought of it. So what?
		case "BLOODLIKEVENOM":
			if (EditCodeName != None) EditCodeName.SetText("Johnny Venom");
			if (EditName != None) EditName.SetText("Johnny Venom");
			LoadBLVAssetBounds();
		break;
		//TODO: Setup trestkon and all that BS from TNM.
		//Update: Lolno. TNM is too elaborate to simply drop in.
		case "TNM":
		break;
		//05/29/25: Oh hey, it's me.
		case "HIVEDAYS":
			if (EditCodeName != None) EditCodeName.SetText("Jack Ruben");
			if (EditName != None) EditName.SetText("Jack Ruben");
			
			LoadHiveDaysAssetBounds();
		break;
		//Allow female gender for all campaigns except zodiac, redsun, and TNM.
		default:
			//MADDERS: Only if the option is enabled. I think this is best left as "opt-in".
			if (VMP != None)
			{
				if ((VMP.bAllowFemJC) && (!bFemaleInapplicable))
				{
					bCanMakeFemale = true;
					CreateGenderPrevButton();
					CreateGenderNextButton();
				}
				
				CreatePresetSaveButton();
				CreatePresetLoadButton();
				CreatePresetPrevButton();
				CreatePresetNextButton();
			}
			StyleChanged();
		break;
	}
	DefaultName = EditName.GetText();
	DefaultGender = bool(CurGenderIndex);
	if (DefaultGender)
	{
		DefaultMesh = CurFemaleMeshIndex;
	}
	else
	{
		DefaultMesh = CurMaleMeshIndex;
	}
	
	CreateHandednessSaveButton();
	CurHandednessIndex = VMP.FaveHandedness;
	
	UpdatePlayerAppearance();
	AddTimer(0.1, false,, 'UpdatePlayerAppearance');
}

function CreateEntryWindows()
{
	GenderEntry = CreateMenuEditWindow(GenderPos.X, GenderPos.Y, 113, 32, winClient);
	MeshEntry = CreateMenuEditWindow(MeshPos.X, MeshPos.Y, 113, 32, winClient);
	SkinEntry = CreateMenuEditWindow(SkinPos.X, SkinPos.Y, 113, 32, winClient);
	PantsEntry = CreateMenuEditWindow(PantsPos.X, PantsPos.Y, 113, 32, winClient);
	ChestEntry = CreateMenuEditWindow(ChestPos.X, ChestPos.Y, 113, 32, winClient);
	CoatEntry = CreateMenuEditWindow(CoatPos.X, CoatPos.Y, 113, 32, winClient);
	LensesEntry = CreateMenuEditWindow(LensesPos.X, LensesPos.Y, 113, 32, winClient);
	FramesEntry = CreateMenuEditWindow(FramesPos.X, FramesPos.Y, 113, 32, winClient);
	GenderEntry.SetSensitivity(false);
	MeshEntry.SetSensitivity(false);
	SkinEntry.SetSensitivity(false);
	PantsEntry.SetSensitivity(false);
	ChestEntry.SetSensitivity(false);
	CoatEntry.SetSensitivity(false);
	LensesEntry.SetSensitivity(false);
	FramesEntry.SetSensitivity(false);
	
	PresetEntry = CreateMenuEditWindow(PresetPos.X, PresetPos.Y, 113, 32, WinClient);
	PresetEntry.SetSensitivity(false);
	
	HandednessEntry = CreateMenuEditWindow(HandednessPos.X, HandednessPos.Y, 113, 32, WinClient);
	HandednessEntry.SetSensitivity(false);
}

function CreateFieldLabels()
{
	GenderLabel = CreateMenuLabel(GenderPos.X+LabelHeaderPos.X, GenderPos.Y+LabelHeaderPos.Y, GenderLabelText, winClient);
	MeshLabel = CreateMenuLabel(MeshPos.X+LabelHeaderPos.X, MeshPos.Y+LabelHeaderPos.Y, MeshLabelText, winClient);
	SkinLabel = CreateMenuLabel(SkinPos.X+LabelHeaderPos.X, SkinPos.Y+LabelHeaderPos.Y, SkinLabelText, winClient);
	LensesLabel = CreateMenuLabel(LensesPos.X+LabelHeaderPos.X, LensesPos.Y+LabelHeaderPos.Y, LensesLabelText, winClient);
	FramesLabel = CreateMenuLabel(FramesPos.X+LabelHeaderPos.X, FramesPos.Y+LabelHeaderPos.Y, FramesLabelText, winClient);
	ChestLabel = CreateMenuLabel(ChestPos.X+LabelHeaderPos.X, ChestPos.Y+LabelHeaderPos.Y, ChestLabelText, winClient);
	CoatLabel = CreateMenuLabel(CoatPos.X+LabelHeaderPos.X, CoatPos.Y+LabelHeaderPos.Y, CoatLabelText, winClient);
	PantsLabel = CreateMenuLabel(PantsPos.X+LabelHeaderPos.X, PantsPos.Y+LabelHeaderPos.Y, PantsLabelText, winClient);
	
	TrueNameLabel = CreateMenuLabel(TrueNamePos.X+LabelHeaderPos.X, TrueNamePos.Y+LabelHeaderPos.Y, HeaderNameLabel, winClient);
	CodeNameLabel = CreateMenuLabel(CodeNamePos.X+LabelHeaderPos.X, CodeNamePos.Y+LabelHeaderPos.Y, HeaderCodeNameLabel, winClient);
	
	PresetLabel = CreateMenuLabel(PresetPos.X+LabelHeaderPos.X, PresetPos.Y+LabelHeaderPos.Y, SavedLabelText, WinClient);
	
	HandednessLabel = CreateMenuLabel(HandednessPos.X+LabelHeaderPos.X, HandednessPos.Y+LabelHeaderPos.Y, HandednessLabelText, WinClient);
}

// Smoke39 - let us see what we look like
function PostDrawWindow(GC gc)
{
	//local float RelX, RelY;
	local Vector EyePos, Pos, TOffset;
	local Rotator TRot;
	local Actor Dud;
	local JCDouble JCD;
	
	if (!bIsVisible)
		return;
	
	if (DuderoniPizza == None )
	{
		//MADDERS: Now render this guy from the backdrop, existing in our setup map.
		ForEach Player.AllActors(class'JCDouble', JCD)
		{
			DuderoniPizza = JCD;
			break;
		}
		//DuderoniPizza = Player.Spawn(class'Effects');
		if (JCD == None) return;
		
		Dud = DuderoniPizza;
		Dud.Mesh = LodMesh'GM_Trench';
		Dud.MultiSkins[0] = Texture'JCDentonTex0';
		Dud.MultiSkins[1] = Texture'JCDentonTex2';
		Dud.MultiSkins[2] = Texture'JCDentonTex3';
		Dud.MultiSkins[3] = Texture'JCDentonTex0';
		Dud.MultiSkins[4] = Texture'JCDentonTex1';
		Dud.MultiSkins[5] = Texture'JCDentonTex2';
		Dud.MultiSkins[6] = Texture'FramesTex4';
		Dud.MultiSkins[7] = Texture'LensesTex5';
		DudRot = Dud.Rotation; //MADDERS: Store initial rot and modify it freely.
	}
	Dud = DuderoniPizza;
	if (bFemale)
	{
		Dud.DrawScale = 1.05;
	}
	else
	{
		Dud.DrawScale = 1.0;
	}
	
	TRot = DudRot;
	Dud.bHidden = true;
	Dud.SetRotation(TRot);
	
	gc.DrawActor(Dud,,,,,2.35);
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
	SetFocusWindow(editName);
	editName.SetSelectedArea(0, Len(editName.GetText()));
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	AddTimer(0.02, false,, 'AdjustWindowPositionHack');
	
	CreateCodeNameEditWindow();
	CreateNameEditWindow();
	
	CreateEntryWindows();
	CreateFieldLabels();
	CreateMeshPrevButton();
	CreateMeshNextButton();
	CreateSkinPrevButton();
	CreateSkinNextButton();
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
	
	CreateHandednessPrevButton();
	CreateHandednessNextButton();
	
	CreateRandomButton();
	
	UpdatePlayerAppearance();
	EnableButtons();
}

// ----------------------------------------------------------------------
// CreateCodeNameEditWindow()
// ----------------------------------------------------------------------

function CreateCodeNameEditWindow()
{
	editCodeName = CreateMenuEditWindow(CodeNamePos.X, CodeNamePos.Y, 113, 32, winClient);
	
	editCodeName.SetText(player.FamiliarName);
	editCodeName.SetSensitivity(False);
}

// ----------------------------------------------------------------------
// CreateNameEditWindow()
// ----------------------------------------------------------------------

function CreateNameEditWindow()
{
	editName = CreateMenuEditWindow(TrueNamePos.X, TrueNamePos.Y, 113, 32, winClient);
	
	editName.SetText(player.TruePlayerName);
	editName.MoveInsertionPoint(MOVEINSERT_End);
	editName.SetFilter(filterString);
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
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	local DeusExPlayer		localPlayer;
	local String			localStartMap;
	local String            playerName;
	
	localPlayer   = player;
	
	if (actionKey ~= "START")
	{
		// Make sure the name isn't blank
		playerName = TrimSpaces(editName.GetText());
		
		if (playerName == "")
		{
			root.MessageBox(NameBlankTitle, NameBlankPrompt, 1, False, Self);
		}
		else
		{
			SaveSettings();
			InvokeNewGameScreen(StoredCampaign);
		}
	}
	else if (ActionKey ~= "RESET")
	{
		CurFemaleMeshIndex = int(DefaultGender);
		bFemale = bool(CurFemaleMeshIndex);
		CurMaleMeshIndex = DefaultMesh;
		
		EditName.SetText(DefaultName);
		
		CurFemaleSkinIndex = 0;
		CurMaleSkinIndex = 0;
		CurTrenchLensesIndex = 0;
		CurTrenchFramesIndex = 0;
		CurTrenchChestIndex = 0;
		CurTrenchCoatIndex = 0;
		CurTrenchPantsIndex = 0;
		UpdatePlayerAppearance();
	}
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	local int i;
	
	Player.TruePlayerName = editName.GetText();
	if (bFemale)
	{
		Player.PlayerSkin = CurFemaleSkinIndex % 5;
	}
	else
	{
		Player.PlayerSkin = CurMaleSkinIndex % 5;
	}
	
	//MADDERS: We're always black in nihilum. No explanation needed.
	if ((StoredCampaign ~= "Nihilum") || (StoredCampaign ~= "Counterfeit"))
	{
		Player.PlayerSkin = 1;
	}
	
	if (VMP != None)
	{
		switch(CurHandednessIndex)
		{
			case 0:
				VMP.PreferredHandedness = -1;
			break;
			case 1:
				VMP.PreferredHandedness = 1;
			break;
		}
		
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(3);
		
		//MADDERS: Cram in our skin, gender, and mesh data.
		VMP.bAssignedFemale = bFemale;
		VMP.Mesh = DuderoniPizza.Mesh;
		for(i=0; i<8; i++)
		{
			VMP.Multiskins[i] = DuderoniPizza.Multiskins[i];
		}
		VMP.Texture = DuderoniPizza.Texture;
		
		VMP.DefabricatePlayerAppearance();
	}
	
	Player.SaveConfig();
}

function StartCampaign()
{
	switch(Caps(StoredCampaign))
	{
		case "VANILLA":
			Player.ShowIntro(True);
		break;
		case "OMEGA":
		case "CARONE":
		case "HOTEL CARONE":
			Player.StartNewGame(VMP.CampaignNewGameMap);
		break;
		default:
			if (VMP != None)
			{
				VMP.ShowCustomIntro(VMP.CampaignNewGameMap);
			}
			//NOTE: Failing to be a VMDBufferPawn = Play Vanilla again. Emergency "o fuk" switch.
			else
			{
				Player.ShowIntro(True);
			}
		break;
	}
}

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign)
{
	local VMDMenuSelectClass NewGame;
	
	//newGame = VMDMenuSelectSpecializations(root.InvokeMenuScreen(Class'VMDMenuSelectSpecializations'));
	newGame = VMDMenuSelectClass(root.InvokeMenuScreen(Class'VMDMenuSelectClass'));
	
	if (newGame != None)
	{
		DuderoniPizza.bHidden = false;
		newGame.SetCampaignData(Campaign);
	}
}

defaultproperties
{
     PlayerPreviewOffset=(X=100,Y=0,Z=0)
     CodeNamePos=(X=18,Y=36)
     TrueNamePos=(X=18,Y=92)
     
     GenderPos=(X=184,Y=36)
     MeshPos=(X=184,Y=82)
     SkinPos=(X=184,Y=128)
     
     //Lower half? Lowered in Y by 16 on 8/9/23. Then another 20 units to reduce user error.
     LensesPos=(X=184,Y=175)
     FramesPos=(X=184,Y=221)
     ChestPos=(X=37,Y=152)
     CoatPos=(X=37,Y=198)
     PantsPos=(X=37,Y=244)
     
     LabelHeaderPos=(X=3,Y=-19)
     ArrowLeftOffset=-15
     ArrowRightOffset=113
     
     PresetPos=(X=37,Y=292)
     SavePresetButtonPos=(X=37,Y=356)
     LoadPresetButtonPos=(X=37,Y=316)
     
     HandednessPos=(X=184,Y=292)
     SaveHandednessButtonPos=(X=184,Y=316)
     
     RandomButtonPos=(X=184,Y=356)
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Edit Class",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Reset",Key="RESET")
     Title="Appearance Setup"
     ClientWidth=324
     ClientHeight=389
     textureRows=2
     textureCols=2
     clientTextures(0)=Texture'MenuAppearanceBackground_1'
     clientTextures(1)=Texture'MenuAppearanceBackground_3'
     clientTextures(2)=Texture'MenuAppearanceBackground_4'
     clientTextures(3)=Texture'MenuAppearanceBackground_6'
}
