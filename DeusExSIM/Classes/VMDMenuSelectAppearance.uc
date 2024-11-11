//=============================================================================
// VMDMenuSelectAppearance
//=============================================================================
class VMDMenuSelectAppearance expands MenuUIScreenWindow;

#exec OBJ LOAD FILE=VMDAssets

var MenuUIInfoButtonWindow winNameBorder;
var MenuUIEditWindow EditCodeName, EditName;
var MenuUIEditWindow GenderEntry, MeshEntry, SkinEntry, PantsEntry, ChestEntry, CoatEntry, LensesEntry, FramesEntry;
var MenuUILabelWindow GenderLabel, MeshLabel, SkinLabel, PantsLabel, ChestLabel, CoatLabel, LensesLabel, FramesLabel;
var MenuUILabelWindow TrueNameLabel, CodeNameLabel;

var String filterString;

var localized string HeaderNameLabel, HeaderCodeNameLabel;
var localized string NameBlankTitle, NameBlankPrompt;

//MADDERS, using a method pioneered by the legendary Smoke39.
var Texture MaleSkinTexs[64], FemaleSkinTexs[64];
var Texture TrenchLensesTexs[64];
var Texture TrenchFramesTexs[64];
var Texture TrenchChestTexs[64];
var Texture TrenchCoatTexs[64];
var Texture TrenchPantsTexs[64];

var int CurTrenchLensesIndex, MaxTrenchLensesIndex;
var int CurTrenchFramesIndex, MaxTrenchFramesIndex;
var int CurTrenchChestIndex, MaxTrenchChestIndex;
var int CurTrenchCoatIndex, MaxTrenchCoatIndex;
var int CurTrenchPantsIndex, MaxTrenchPantsIndex;

var VMDBufferPlayer VMP;
var Actor DuderoniPizza; //MADDERS: In case there was any doubt I was using Smoke as a cheatsheet.
var Rotator DudRot;

//MADDERS originals. Alternating anims, custom rotation, and female JC support... When appropriate for the campaign.
var Name DudeSequences[8];
var int CurDudeSequence, MaxDudeSequences;
var bool bFemale, bCanMakeFemale;
var int CustomRotationMod;

//MADDERS: Coat short data, and mesh indices.
var byte TrenchCoatIsShort[64];
var int CurMaleMeshIndex, MaxMaleMeshIndex, CurFemaleMeshIndex, MaxFemaleMeshIndex;
var int CurMaleSkinIndex, MaxMaleSkinIndex, CurFemaleSkinIndex, MaxFemaleSkinIndex, DDSFat;
var int CurGenderIndex, MaxGenderIndex;
var Mesh MaleMeshes[8], FemaleMeshes[8];

//MADDERS: Arrows
var ButtonWindow ButtonGenderPrev, ButtonGenderNext;
var ButtonWindow ButtonMeshPrev, ButtonMeshNext;
var ButtonWindow ButtonSkinPrev, ButtonSkinNext;
var ButtonWindow ButtonLensesPrev, ButtonLensesNext;
var ButtonWindow ButtonFramesPrev, ButtonFramesNext;
var ButtonWindow ButtonChestPrev, ButtonChestNext;
var ButtonWindow ButtonCoatPrev, ButtonCoatNext;
var ButtonWindow ButtonPantsPrev, ButtonPantsNext;

//MADDERS: Localized strings
var localized string GenderLabelText, MeshLabelText, SkinLabelText;
var localized string LensesLabelText, FramesLabelText, ChestLabelText, CoatLabelText, PantsLabelText;

//MADDERS: Store our chain of data.
var float StoredDifficulty;
var string StoredCampaign;

struct VMDButtonPos {
	var int X;
	var int Y;
};

//MADDERS: Positions for windows. This was so needed.
var bool bHackUpdateRequired;

var Vector PlayerPreviewOffset;
var VMDButtonPos CodeNamePos, TrueNamePos, GenderPos, MeshPos, SkinPos, PantsPos, ChestPos, CoatPos, LensesPos, FramesPos;
var VMDButtonPos LabelHeaderPos;
var int ArrowLeftOffset, ArrowRightOffset;

//MADDERS, 12/20/20: Hacky stuff. You never know.
var bool DefaultGender;
var int DefaultMesh;
var string DefaultName;

//MADDERS, 9/25/22: Presets? Based.
var int CurMalePresetIndex, CurFemalePresetIndex;
var VMDButtonPos PresetPos, SavePresetButtonPos, LoadPresetButtonPos, RandomButtonPos;

var ButtonWindow ButtonPresetPrev, ButtonPresetNext;
var MenuUIEditWindow PresetEntry;
var MenuUILabelWindow PresetLabel;
var VMDMenuUIActionButtonWindow SavePresetButton, LoadPresetButton, RandomButton;

var localized string SavedLabelText, SaveMaleButtonText, SaveFemaleButtonText, LoadMaleButtonText, LoadFemaleButtonText,
	DefaultSlotText, SavedMaleSlotText, SavedFemaleSlotText;

//MADDERS, 5/29/23: Now allow handedness selection.
var int CurHandednessIndex;
var VMDButtonPos HandednessPos, SaveHandednessButtonPos;

var ButtonWindow ButtonHandednessPrev, ButtonHandednessNext;
var MenuUIEditWindow HandednessEntry;
var MenuUILabelWindow HandednessLabel;
var VMDMenuUIActionButtonWindow SaveHandednessButton;

var localized string HandednessLabelText;

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
	//ResoHeight = int(Right(GetReso, Len(GetReso)-XPos-Len("x")));
	
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
		case "FLuCHTWEG":
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

function LoadBLVAssetBounds()
{
	MaleSkinTexs[0] = Texture'DeusExCharacters.Skins.GarySavageTex0';
	//MaleSkinTexs[1] = Texture'DeusExCharacters.Skins.TobyAtanweTex0';
	MaxMaleSkinIndex = 0;
	
	//Note: Lower coat is JCDentonTex2, and upper is TobyAtanweTex2
	//We're cheating and rounding this off to just Atanwe, so customization can take place.
	CurTrenchCoatIndex = 17;
	CurTrenchChestIndex = 0;
	CurTrenchPantsIndex = 14;
	CurTrenchLensesIndex = 0;
	CurTrenchFramesIndex = 0;
	DDSFat = 5;
}

function LoadNihilumAssetBounds()
{
	local string TFaceStrings[3], TLensStrings[3], TFramesStrings[3], TShirtStrings[5], TCoatStrings[4], TPantsStrings[3];
	local Texture T;
	local int i;
	
	TFaceStrings[0] = "FGRHK.WesleyCutterTex0";
	TFaceStrings[1] = "FGRHK.WesleyCutterTex01";
	TFaceStrings[2] = "FGRHK.WesleyCutterTex02";
	
	TLensStrings[0] = "DeusExCharacters.LensesTex2";
	TLensStrings[1] = "DeusExCharacters.LensesTex1";
	TLensStrings[2] = "FGRHK.LensesTex7";
	
	TFramesStrings[0] = "DeusExCharacters.FramesTex4";
	TFramesStrings[1] = "DeusExCharacters.FramesTex1";
	TFramesStrings[2] = "DeusExCharacters.FramesTex3";
	
        TShirtStrings[0] = "FGRHK.MadIngramTex1";
        TShirtStrings[1] = "FGRHK.MadIngramTex12";
        TShirtStrings[2] = "FGRHK.MadIngramTex15";
        TShirtStrings[3] = "FGRHK.MadIngramTex13";
        TShirtStrings[4] = "FGRHK.MadIngramTex11";
	
	TCoatStrings[0] = "FGRHK.MadIngramTex2";
	TCoatStrings[1] = "FGRHK.MadIngramTex14";
	TCoatStrings[2] = "DeusExCharacters.JockTex2";
	TCoatStrings[3] = "FGRHK.MadIngramTex10";
	
	TPantsStrings[0] = "FGRHK.MadIngramTex3";
	TPantsStrings[1] = "FGRHK.MadIngramTex32";
	TPantsStrings[2] = "DeusExCharacters.SoldierTex2";
	
	//--1--1--1--1--1--1
	//FACES
	for (i=0; i<ArrayCount(TFaceStrings); i++)
	{
		T = Texture(DynamicLoadObject(TFaceStrings[i], class'Texture', false));
		if (T != None)
		{
			MaleSkinTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM FACE STRING"@TFaceStrings[i]);
		}
	}
	MaxMaleSkinIndex = ArrayCount(TFaceStrings)-1;
	
	//--2--2--2--2--2--2
	//LENSES
	for (i=0; i<ArrayCount(TLensStrings); i++)
	{
		T = Texture(DynamicLoadObject(TLensStrings[i], class'Texture', false));
		if (T != None)
		{
			TrenchLensesTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM LENS STRING"@TLensStrings[i]);
		}
	}
	MaxTrenchLensesIndex = ArrayCount(TLensStrings)-1;
	
	//--3--3--3--3--3--3
	//FRAMES
	for (i=0; i<ArrayCount(TFramesStrings); i++)
	{
		T = Texture(DynamicLoadObject(TFramesStrings[i], class'Texture', false));
		if (T != None)
		{
			TrenchFramesTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM FRAMES STRING"@TFramesStrings[i]);
		}
	}
	MaxTrenchFramesIndex = ArrayCount(TFramesStrings)-1;
	
	//--4--4--4--4--4--4
	//CHEST
	for (i=0; i<ArrayCount(TShirtStrings); i++)
	{
		T = Texture(DynamicLoadObject(TShirtStrings[i], class'Texture', false));
		if (T != None)
		{
			TrenchChestTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM SHIRT STRING"@TShirtStrings[i]);
		}
	}
	MaxTrenchChestIndex = ArrayCount(TShirtStrings)-1;
	
	//--5--5--5--5--5--5
	//COATS
	for (i=0; i<ArrayCount(TCoatStrings); i++)
	{
		T = Texture(DynamicLoadObject(TCoatStrings[i], class'Texture', false));
		if (T != None)
		{
			if (i == 2) TrenchCoatIsShort[i] = 1;
			else TrenchCoatIsShort[i] = 0;
			
			TrenchCoatTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM COAT STRING"@TCoatStrings[i]);
		}
	}
	MaxTrenchCoatIndex = ArrayCount(TCoatStrings)-1;
	
	//--6--6--6--6--6--6
	//PANTS
	for (i=0; i<ArrayCount(TPantsStrings); i++)
	{
		T = Texture(DynamicLoadObject(TPantsStrings[i], class'Texture', false));
		if (T != None)
		{
			TrenchPantsTexs[i] = T;
		}
		else
		{
			Log("FAILED TO LOAD NIHILUM PANTS STRING"@TPantsStrings[i]);
		}
	}
	MaxTrenchPantsIndex = ArrayCount(TPantsStrings)-1;
	DDSFat = 0;
}

function LoadCounterfeitAssetBounds()
{
	local string TFaceString, TChestString;
	local Texture T;
	local int i;
	
	//--1--1--1--1--1--1
	//FACES
	TFaceString = "DeusExCharacters.SmugglerTex0";
	T = Texture(DynamicLoadObject(TFaceString, class'Texture', false));
	MaleSkinTexs[0] = T;
	MaxMaleSkinIndex = 0;
	
	TChestString = "CF.DBTrenchShirt";
	T = Texture(DynamicLoadObject(TChestString, class'Texture', false));
	TrenchChestTexs[0] = T;
	
	CurTrenchLensesIndex = 0;
	CurTrenchFramesIndex = 0;
	CurTrenchChestIndex = 0;
	CurTrenchCoatIndex = 14;
	CurTrenchPantsIndex = 30;
	DDSFat = 5;
}

function LoadIWRAssetBounds()
{
	local string TFaceString, TChestString;
	local Texture T;
	local int i;
	
	//--1--1--1--1--1--1
	//FACES
	TFaceString = "DeusExCharacters.SkinTex3";
	T = Texture(DynamicLoadObject(TFaceString, class'Texture', false));
	MaleSkinTexs[0] = T;
	MaxMaleSkinIndex = 0;
	
	CurTrenchLensesIndex = 5;
	CurTrenchFramesIndex = 0;
	CurTrenchChestIndex = 22;
	CurTrenchCoatIndex = 16;
	CurTrenchPantsIndex = 7;
	DDSFat = 5;
}

function UpdatePlayerAppearance()
{
	local Actor Dud;
	local Texture ChestUse, CoatUse, PantsUse, LensesUse, FramesUse;
	local bool bChestUnavailable, bPantsUnavailable, FlagNihilum;
	local int TArray;
	
	if (GenderEntry == None || MeshEntry == None || SkinEntry == None || PresetEntry == None
		|| LensesEntry == None || FramesEntry == None || ChestEntry == None || CoatEntry == None || PantsEntry == None)
	{
		return;
	}
	
	if (StoredCampaign ~= "Nihilum")
	{
		FlagNihilum = true;
	}
	
	switch(CurGenderIndex)
	{
		case 0:
			bFemale = false;
			GenderEntry.SetText("Male");
			
			switch(CurMaleMeshIndex)
			{
				case 0:
					MeshEntry.SetText("Standard");
				break;
				case 1:
					MeshEntry.SetText("Heavy");
				break;
			}
			switch(CurMaleSkinIndex)
			{
				case 0:
					SkinEntry.SetText("Brunet");
				break;
				case 1:
					SkinEntry.SetText("Black");
				break;
				case 2:
					SkinEntry.SetText("Brown");
				break;
				case 3:
					SkinEntry.SetText("Ginger");
				break;
				case 4:
					SkinEntry.SetText("Albino");
				break;
				case 5:
					SkinEntry.SetText("DDS Slot 1");
				break;
				case 6:
					SkinEntry.SetText("DDS Slot 2");
				break;
				case 7:
					SkinEntry.SetText("DDS Slot 3");
				break;
				case 8:
					SkinEntry.SetText("DDS Slot 4");
				break;
				case 9:
					SkinEntry.SetText("DDS Slot 5");
				break;
			}
		break;
		case 1:
			bFemale = true;
			GenderEntry.SetText("Female");
			
			switch(CurFemaleMeshIndex)
			{
				case 0:
					MeshEntry.SetText("Standard");
				break;
			}
			switch(CurFemaleSkinIndex)
			{
				case 0:
					SkinEntry.SetText("Brunet");
				break;
				case 1:
					SkinEntry.SetText("Black");
				break;
				case 2:
					SkinEntry.SetText("Brown");
				break;
				case 3:
					SkinEntry.SetText("Ginger");
				break;
				case 4:
					SkinEntry.SetText("Albino");
				break;
				case 5:
					SkinEntry.SetText("DDS Slot 1");
				break;
				case 6:
					SkinEntry.SetText("DDS Slot 2");
				break;
				case 7:
					SkinEntry.SetText("DDS Slot 3");
				break;
				case 8:
					SkinEntry.SetText("DDS Slot 4");
				break;
				case 9:
					SkinEntry.SetText("DDS Slot 5");
				break;
			}
		break;
	}
	
	//MADDERS: Alternate names for our skin colors, since they're hair colors now.
	if (FlagNihilum)
	{
		switch(CurMaleSkinIndex)
		{
			case 0:
				SkinEntry.SetText("Goatee");
			break;
			case 1:
				SkinEntry.SetText("Plain");
			break;
			case 2:
				SkinEntry.SetText("Silver");
			break;
		}
	}
	
	//MADDERS: Alternate names for our skin colors, since they're hair colors now.
	if (StoredCampaign ~= "BloodLikeVenom")
	{
		switch(CurMaleSkinIndex)
		{
			case 0:
				//SkinEntry.SetText("Brunet");
				SkinEntry.SetText("Johnny Venom");
			break;
			/*case 1:
				SkinEntry.SetText("Black");
			break;*/
		}
	}
	
	//MADDERS: Bishop override
	if (StoredCampaign ~= "Counterfeit")
	{
		switch(CurMaleSkinIndex)
		{
			case 0:
			default:
				SkinEntry.SetText("Dominic");
			break;
		}
	}
	
	ChestUse = TrenchChestTexs[CurTrenchChestIndex];
	if (CurTrenchChestIndex == 26)
	{
		if (!bFemale)
		{
			bChestUnavailable = true;
			ChestUse = Texture'JCDentonTex1';
		}
		else if ((CurFemaleSkinIndex % 5 != 0) && (CurFemaleSkinIndex % 5 != 3))
		{
			bChestUnavailable = true;
			ChestUse = Texture'JCDentonTex1';
		}
	}
	
	CoatUse = TrenchCoatTexs[CurTrenchCoatIndex];
	PantsUse = TrenchPantsTexs[CurTrenchPantsIndex];
	if ((CurTrenchCoatIndex == 0) && (bFemale))
	{
		CoatUse = Texture'JCDentonFemaleTex2';
	}
	if ((CurTrenchPantsIndex == 0) && (bFemale))
	{
		PantsUse = Texture'JCDentonFemaleTex3';
	}
	if (CurTrenchPantsIndex == 29)
	{
		if ((bFemale) && (CurFemaleSkinIndex % 5 != 0) && (CurFemaleSkinIndex % 5 != 3))
		{
			bPantsUnavailable = true;
			PantsUse = Texture'PantsTex3';
		}
		else if ((!bFemale) && (CurMaleSkinIndex % 5 != 0) && (CurMaleSkinIndex % 5 != 3))
		{
			bPantsUnavailable = true;
			PantsUse = Texture'PantsTex3';
		}
	}
	
	LensesUse = TrenchLensesTexs[CurTrenchLensesIndex];
	FramesUse = TrenchFramesTexs[CurTrenchFramesIndex];
	if (FramesUse == Texture'GrayMaskTex') LensesUse = Texture'BlackMaskTex';
	
	//MADDERS, 10/12/21: Cheeky swap outs for default JC textures.
	//MADDERS, 11/3/22: Oops. This broke some shit.
	if (SavePresetButton != None)
	{
		if (bFemale)
		{
			if (CurTrenchChestIndex == 0)
			{
				ChestUse = Texture'JCDentonFemaleTex1';
			}
			if (CurTrenchCoatIndex == 0)
			{
				CoatUse = Texture'JCDentonFemaleTex2';
			}
			if (CurTrenchPantsIndex == 0)
			{
				PantsUse = Texture'JCDentonFemaleTex3';
			}
		}
		else
		{
			if (CurTrenchChestIndex == 0)
			{
				ChestUse = Texture'JCDentonTex1';
			}
			if (CurTrenchCoatIndex == 0)
			{
				CoatUse = Texture'JCDentonTex2';
			}
			if (CurTrenchPantsIndex == 0)
			{
				PantsUse = Texture'JCDentonTex3';
			}
		}
	}
	
	Dud = DuderoniPizza;
	if (Dud != None)
	{
		if (bFemale)
		{
			Dud.Mesh = FemaleMeshes[CurFemaleMeshIndex];
			Dud.Multiskins[0] = FemaleSkinTexs[CurFemaleSkinIndex];
			Dud.Multiskins[3] = FemaleSkinTexs[CurFemaleSkinIndex];
		}
		else
		{
			Dud.Mesh = MaleMeshes[CurMaleMeshIndex];
			Dud.Multiskins[0] = MaleSkinTexs[CurMaleSkinIndex];
			Dud.Multiskins[3] = MaleSkinTexs[CurMaleSkinIndex];
		}
		
		if (TrenchCoatIsShort[CurTrenchCoatIndex] == 0)
		{
			Dud.Multiskins[5] = CoatUse;
		}
		else
		{
			Dud.Multiskins[5] = Texture'PinkMaskTex';
		}
		Dud.Multiskins[1] = CoatUse;
		Dud.Multiskins[7] = LensesUse;
		Dud.Multiskins[6] = FramesUse;
		Dud.Multiskins[4] = ChestUse;
		Dud.Multiskins[2] = PantsUse;
	}
	
	LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
	FramesEntry.SetText(DeriveHumanName(string(FramesUse)));
	
	//Chest exceptions
	ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
	if (bChestUnavailable) ChestEntry.SetText("(Unavailable)");
	
	CoatEntry.SetText(DeriveHumanName(string(TrenchCoatTexs[CurTrenchCoatIndex])));
	
	//Pants exceptions
	PantsEntry.SetText(DeriveHumanName(string(TrenchPantsTexs[CurTrenchPantsIndex])));
	if (bPantsUnavailable) PantsEntry.SetText("(Unavailable)");
	
	if (bFemale)
	{
		TArray = CurFemalePresetIndex-1;
		if (CurFemalePresetIndex == 0)
		{
			PresetEntry.SetText(DefaultSlotText);
			if (SavePresetButton != None)
			{
				SavePresetButton.SetSensitivity(False);
				LoadPresetButton.SetSensitivity(False);
			}
		}
		else
		{
			PresetEntry.SetText(SprintF(SavedFemaleSlotText, CurFemalePresetIndex));
			if (SavePresetButton != None)
			{
				if (CurTrenchLensesIndex != VMP.FaveFemaleLensIndex[TArray] || 
					CurTrenchFramesIndex != VMP.FaveFemaleFramesIndex[TArray] || 
					CurTrenchChestIndex != VMP.FaveFemaleChestIndex[TArray] || 
					CurTrenchCoatIndex != VMP.FaveFemaleCoatIndex[TArray] || 
					CurTrenchPantsIndex != VMP.FaveFemalePantsIndex[TArray] || 
					CurFemaleMeshIndex != VMP.FaveFemaleMeshIndex[TArray] || 
					CurFemaleSkinIndex != VMP.FaveFemaleSkinIndex[TArray])
				{
					SavePresetButton.SetSensitivity(True);
					LoadPresetButton.SetSensitivity(True);
				}
				else
				{
					SavePresetButton.SetSensitivity(False);
					LoadPresetButton.SetSensitivity(False);
				}
			}
		}
		
		if (SavePresetButton != None)
		{
			SavePresetButton.SetButtonText(SprintF(SaveFemaleButtonText, CurFemalePresetIndex));
		}
		if (LoadPresetButton != None)
		{
			LoadPresetButton.SetButtonText(SprintF(LoadFemaleButtonText, CurFemalePresetIndex));
		}
	}
	else
	{
		TArray = CurMalePresetIndex-1;
		if (CurMalePresetIndex == 0)
		{
			PresetEntry.SetText(DefaultSlotText);
			if (SavePresetButton != None)
			{
				SavePresetButton.SetSensitivity(False);
				LoadPresetButton.SetSensitivity(False);
			}
		}
		else
		{
			PresetEntry.SetText(SprintF(SavedMaleSlotText, CurMalePresetIndex));
			if (SavePresetButton != None)
			{
				if (CurTrenchLensesIndex != VMP.FaveMaleLensIndex[TArray] || 
					CurTrenchFramesIndex != VMP.FaveMaleFramesIndex[TArray] || 
					CurTrenchChestIndex != VMP.FaveMaleChestIndex[TArray] || 
					CurTrenchCoatIndex != VMP.FaveMaleCoatIndex[TArray] || 
					CurTrenchPantsIndex != VMP.FaveMalePantsIndex[TArray] || 
					CurMaleMeshIndex != VMP.FaveMaleMeshIndex[TArray] || 
					CurMaleSkinIndex != VMP.FaveMaleSkinIndex[TArray])
				{
					SavePresetButton.SetSensitivity(True);
					LoadPresetButton.SetSensitivity(True);
				}
				else
				{
					SavePresetButton.SetSensitivity(False);
					LoadPresetButton.SetSensitivity(False);
				}
			}
		}
		
		if (SavePresetButton != None)
		{
			SavePresetButton.SetButtonText(SprintF(SaveMaleButtonText, CurMalePresetIndex));
		}
		if (LoadPresetButton != None)
		{
			LoadPresetButton.SetButtonText(SprintF(LoadMaleButtonText, CurMalePresetIndex));
		}
	}
	
	if (CurHandednessIndex == 0)
	{
		HandednessEntry.SetText("Right Handed");
	}
	else
	{
		HandednessEntry.SetText("Left Handed");
	}
}

function string RemovePackagePrefix(string S)
{
	local int Pos;
	local string Trim;
	
	Pos = InStr(S, ".");
	if (Pos == -1) return S;
	
	Trim = Right(S, Len(S)-Pos-1);
	if (InStr(Trim, ".") == -1)
	{
		//MADDERS, 6/27/24: Bounty hunter chest textures cheat. Sue me.
		if (Left(Trim, 6) ~= "VMDNSF")
		{
			Trim = Right(Trim, Len(Trim) - 6);
		}
		//MADDERS, 6/27/24: Some textures may have the VMD prefix. Oops.
		else if (Left(Trim, 3) ~= "VMD")
		{
			Trim = Right(Trim, Len(Trim) - 3);
		}
		
		//MADDERS, 6/27/24: Also remove "01", "02", etc. It's ugly.
		if (Mid(Trim, Len(Trim) - 2, 1) ~= "0")
		{
			Trim = Left(Trim, Len(Trim)-2)$Right(Trim, 1);
		}
		
		return Trim;
	}
	else
	{
		return RemovePackagePrefix(Trim);
	}
}

function string RemoveTextureLabel(string S)
{
	local int IS;
	local string S1, S2;
	local bool bTrimEx;
	
	if (Left(S, 5) ~= "Pants") bTrimEx = true;
	else if (Left(S, 11) ~= "TrenchShirt") bTrimEx = true;
	else if (Left(S, 6) ~= "Lenses") bTrimEx = true;
	else if (Left(S, 6) ~= "Frames") bTrimEx = true;
	
	//MADDERS, 4/5/21: Trim out this crap, too.
	else if (Left(S, 3) ~= "DDS")
	{
		IS = InStr(CAPS(S), "SLOT");
		if (IS > -1)
		{
			S1 = Left(S, IS);
			S2 = Right(S, Len(S) - IS - 4);
			S = S1$S2;
		}
	}
	
	S1 = "";
	S2 = "";
	
	IS = InStr(CAPS(S), "TEX");
	if (IS == -1) return S;
	else
	{
		S1 = Left(S, IS);
		if (bTrimEx) S2 = Right(S, Len(S) - IS - 3);
		
		return S1$S2;
	}
	return S;
}

function string DeriveHumanName(string Conv)
{
	local string Spaced, TS, NextTS, S1, S2, S3;
	local int i;
	local bool bLastWasSpace, bNextIsSpace, bIsCapital, bNextIsCapital, bLastWasNumber,
			bFoundGap, FlagNumberOkay;
	
	Conv = RemovePackagePrefix(Conv);
	if (Conv ~= "GrayMaskTex" || Conv ~= "BlackMaskTex" || Conv ~= "PinkMaskTex") return "None";
	Conv = RemoveTextureLabel(Conv);
	
	//8/29/22: Hack for Jojo being 1 word despite being capitalized twice inside the word. Why?
	switch(Conv)
	{
		case "JoJoFine":
			return "JoJo Fine";
		break;
		case "Triad Red Arrow":
			return "Red Arrow Triad";
		break;
	}
	
 	for(i=1; i<Len(Conv); i++)
 	{
  		TS = Mid(Conv, i, 1);
		NextTS = Mid(Conv, i+1, 1);
		bIsCapital = IsCapital(TS);
		bNextIsSpace = IsSpace(NextTS);
		bNextIsCapital = IsCapital(NextTS);
		if (IsNumber(NextTS))
		{
			if (IsNumber(TS))
			{
				bNextIsSpace = false;
				bNextIsCapital = false;
			}
		}
		if ((bLastWasNumber) && (IsNumber(TS)))
		{
			bNextIsSpace = true;
		}
		
 		if ((bIsCapital) && (!bLastWasSpace) && (!bNextIsSpace) && (!bNextIsCapital))
		{
			bFoundGap = True;
			break;
		}
		if (i == Len(Conv)) return Conv;
		
		bLastWasNumber = IsNumber(TS);
		bLastWasSpace = IsSpace(TS);
	}
	
	S1 = Right(Conv, Len(Conv) - i);
 	S2 = Left(Conv, i);
	
	S3 = S2@S1;
	if (!bFoundGap)
	{
		return (S3);
	}
	else
	{
		return DeriveHumanName(S3);
	}
}

function bool IsSpace(string S)
{
	switch(CAPS(S))
	{
		case " ":
			return true;
		break;
		default:
			return false;
		break;
	}
	return false;
}

function bool IsNumber(string S)
{
	switch(CAPS(S))
	{
		case "0":
		case "1":
		case "2":
		case "3":
		case "4":
		case "5":
		case "6":
		case "7":
		case "8":
		case "9":
			return true;
		break;
		default:
			return false;
		break;
	}
	return false;
}

function bool IsCapital(string S)
{
	//Blanks and spaces are not capitals.
	if (S == "" || S == " ") return false;
	//Numbers are considered capitals.
	if (string(int(S)) == S) return true;
	//Otherwise check for case as normal.
	return (Caps(S) == S);
}

function CyclePlayerAnimationSequence()
{
	local Actor Dud;
	
	Dud = DuderoniPizza;
	if (Dud != None)
	{
		CurDudeSequence++;
		if (CurDudeSequence > MaxDudeSequences)
		{
			CurDudeSequence = 0;
		}
		Dud.LoopAnim(DudeSequences[CurDudeSequence]);
	}
}

function RotatePlayerModel(bool bRight, optional int YawMod)
{
	if (YawMod == 0) YawMod = 2048;
	
	if (DuderoniPizza != None)
	{
		DuderoniPizza.bHidden = true;
	}
	
	if (bRight)
	{
		DudRot.Yaw += YawMod;
		//CustomRotationMod += YawMod;
	}
	else
	{
		DudRot.Yaw -= YawMod;
		//CustomRotationMod -= YawMod;
	}
	if (CustomRotationMod < 0) CustomRotationMod += 65536;
	CustomRotationMod = (CustomRotationMod % 65536);
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
		//Dud.DrawType = DT_Mesh;
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
		//Dud.DrawScale = 0.385;
		//Dud.bHidden = true;
		//Dud.LoopAnim('BreatheLight');
		//AddTimer(5.0, true,, 'CyclePlayerAnimationSequence');
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
	
	//MADDERS: Have to axe custom rotation due to key conflicts and general fuckery.
	/*TRot = Player.Rotation;
	TRot.Pitch = 0;
	TRot.Roll = 0;
	Player.SetRotation(TRot);
	
	TRot = Rotator(Vector(Player.Rotation) * -1);
	TRot.Roll = Player.ViewRotation.Roll * -1;
	TRot.Yaw += CustomRotationMod;
	
	TOffset = PlayerPreviewOffset;
	EyePos = Player.Location + Player.EyeHeight*Vect(0,0,1);
	Pos = EyePos + (TOffset >> Player.ViewRotation);
	
	Dud.bStasis = false;
	Dud.bForceStasis = false;
	Dud.SetLocation(Pos);*/
	TRot = DudRot;
	Dud.bHidden = true;
	Dud.SetRotation(TRot);
	
	//gc.DrawActor(Dud,,, True);
	gc.DrawActor(Dud,,,,,2.35);
}

// ----------------------------------------------------------------------
// RawMouseButtonPressed() : Raw event called when a mouse button is pressed

event bool RawMouseButtonPressed(float pointX, float pointY, EInputKey button, EInputState iState)
{
	local bool bHandled;
	
	bHandled = True;
	
	switch(Button) 
	{
		//MADDERS: Rotate the preview model with mousewheel.
		case IK_MouseWheelUp:
			RotatePlayerModel(true);
		break;
		case IK_MouseWheelDown:
			RotatePlayerModel(false);
		break;
		
		default:
			bHandled = False;
			break;
	}
	
	return bHandled;
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

//----------------
//GENDER - Note: We're only called if bCanMakeFemale
function CreateGenderPrevButton()
{
	ButtonGenderPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonGenderPrev.SetPos(GenderPos.X+ArrowLeftOffset, GenderPos.Y);
	ButtonGenderPrev.SetSize(14, 15);
	ButtonGenderPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateGenderNextButton()
{
	ButtonGenderNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonGenderNext.SetPos(GenderPos.X+ArrowRightOffset, GenderPos.Y);
	ButtonGenderNext.SetSize(14, 15);
	ButtonGenderNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//MESH
function CreateMeshPrevButton()
{
	ButtonMeshPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonMeshPrev.SetPos(MeshPos.X+ArrowLeftOffset, MeshPos.Y);
	ButtonMeshPrev.SetSize(14, 15);
	ButtonMeshPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateMeshNextButton()
{
	ButtonMeshNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonMeshNext.SetPos(MeshPos.X+ArrowRightOffset, MeshPos.Y);
	ButtonMeshNext.SetSize(14, 15);
	ButtonMeshNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//SKIN
function CreateSkinPrevButton()
{
	ButtonSkinPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonSkinPrev.SetPos(SkinPos.X+ArrowLeftOffset, SkinPos.Y);
	ButtonSkinPrev.SetSize(14, 15);
	ButtonSkinPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateSkinNextButton()
{
	ButtonSkinNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonSkinNext.SetPos(SkinPos.X+ArrowRightOffset, SkinPos.Y);
	ButtonSkinNext.SetSize(14, 15);
	ButtonSkinNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//LENSES
function CreateLensesPrevButton()
{
	ButtonLensesPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonLensesPrev.SetPos(LensesPos.X+ArrowLeftOffset, LensesPos.Y);
	ButtonLensesPrev.SetSize(14, 15);
	ButtonLensesPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateLensesNextButton()
{
	ButtonLensesNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonLensesNext.SetPos(LensesPos.X+ArrowRightOffset, LensesPos.Y);
	ButtonLensesNext.SetSize(14, 15);
	ButtonLensesNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//FRAMES
function CreateFramesPrevButton()
{
	ButtonFramesPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonFramesPrev.SetPos(FramesPos.X+ArrowLeftOffset, FramesPos.Y);
	ButtonFramesPrev.SetSize(14, 15);
	ButtonFramesPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateFramesNextButton()
{
	ButtonFramesNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonFramesNext.SetPos(FramesPos.X+ArrowRightOffset, FramesPos.Y);
	ButtonFramesNext.SetSize(14, 15);
	ButtonFramesNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//CHEST
function CreateChestPrevButton()
{
	ButtonChestPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonChestPrev.SetPos(ChestPos.X+ArrowLeftOffset, ChestPos.Y);
	ButtonChestPrev.SetSize(14, 15);
	ButtonChestPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateChestNextButton()
{
	ButtonChestNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonChestNext.SetPos(ChestPos.X+ArrowRightOffset, ChestPos.Y);
	ButtonChestNext.SetSize(14, 15);
	ButtonChestNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//COAT
function CreateCoatPrevButton()
{
	ButtonCoatPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonCoatPrev.SetPos(CoatPos.X+ArrowLeftOffset, CoatPos.Y);
	ButtonCoatPrev.SetSize(14, 15);
	ButtonCoatPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreateCoatNextButton()
{
	ButtonCoatNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonCoatNext.SetPos(CoatPos.X+ArrowRightOffset, CoatPos.Y);
	ButtonCoatNext.SetSize(14, 15);
	ButtonCoatNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//PANTS
function CreatePantsPrevButton()
{
	ButtonPantsPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPantsPrev.SetPos(PantsPos.X+ArrowLeftOffset, PantsPos.Y);
	ButtonPantsPrev.SetSize(14, 15);
	ButtonPantsPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreatePantsNextButton()
{
	ButtonPantsNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPantsNext.SetPos(PantsPos.X+ArrowRightOffset, PantsPos.Y);
	ButtonPantsNext.SetSize(14, 15);
	ButtonPantsNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

//----------------
//PRESET
function CreatePresetPrevButton()
{
	ButtonPresetPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPresetPrev.SetPos(PresetPos.X+ArrowLeftOffset, PresetPos.Y);
	ButtonPresetPrev.SetSize(14, 15);
	ButtonPresetPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}
function CreatePresetNextButton()
{
	ButtonPresetNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPresetNext.SetPos(PresetPos.X+ArrowRightOffset, PresetPos.Y);
	ButtonPresetNext.SetSize(14, 15);
	ButtonPresetNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

function CreatePresetSaveButton()
{
	SavePresetButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	SavePresetButton.SetButtonText("ERR");
	SavePresetButton.SetPos(SavePresetButtonPos.X, SavePresetButtonPos.Y);
	SavePresetButton.SetWidth(112);
}

function CreatePresetLoadButton()
{
	LoadPresetButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	LoadPresetButton.SetButtonText("ERR");
	LoadPresetButton.SetPos(LoadPresetButtonPos.X, LoadPresetButtonPos.Y);
	LoadPresetButton.SetWidth(112);
}

function CreateRandomButton()
{
	RandomButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	RandomButton.SetButtonText("Randomize");
	RandomButton.SetPos(RandomButtonPos.X, RandomButtonPos.Y);
	RandomButton.SetWidth(112);
}

//----------------
//HANDEDNESS
function CreateHandednessPrevButton()
{
	ButtonHandednessPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonHandednessPrev.SetPos(HandednessPos.X+ArrowLeftOffset, HandednessPos.Y);
	ButtonHandednessPrev.SetSize(14, 15);
	ButtonHandednessPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
}

function CreateHandednessNextButton()
{
	ButtonHandednessNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonHandednessNext.SetPos(HandednessPos.X+ArrowRightOffset, HandednessPos.Y);
	ButtonHandednessNext.SetSize(14, 15);
	ButtonHandednessNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

function CreateHandednessSaveButton()
{
	SaveHandednessButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	SaveHandednessButton.SetButtonText("Set as default");
	SaveHandednessButton.SetPos(SaveHandednessButtonPos.X, SaveHandednessButtonPos.Y);
	SaveHandednessButton.SetWidth(112);
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
		case ButtonGenderPrev:
			CurGenderIndex--;
			if (CurGenderIndex < 0) CurGenderIndex = MaxGenderIndex;
			
			if ((CurGenderIndex == 0) && (CurMalePresetIndex > 0) && (VMP == None || VMP.bAutoloadAppearanceSlots))
			{
				LoadMalePreset(CurMalePresetIndex-1);
			}
			else if ((CurGenderIndex == 1) && (CurFemalePresetIndex > 0) && (VMP == None || VMP.bAutoloadAppearanceSlots))
			{
				LoadFemalePreset(CurFemalePresetIndex-1);
			}
			UpdatePlayerAppearance();
		break;
		case ButtonGenderNext:
			CurGenderIndex++;
			if (CurGenderIndex > MaxGenderIndex) CurGenderIndex = 0;
			
			if ((CurGenderIndex == 0) && (CurMalePresetIndex > 0) && (VMP == None || VMP.bAutoloadAppearanceSlots))
			{
				LoadMalePreset(CurMalePresetIndex-1);
			}
			else if ((CurGenderIndex == 1) && (CurFemalePresetIndex > 0) && (VMP == None || VMP.bAutoloadAppearanceSlots))
			{
				LoadFemalePreset(CurFemalePresetIndex-1);
			}
			UpdatePlayerAppearance();
		break;
		case ButtonMeshPrev:
			if (bFemale)
			{
				CurFemaleMeshIndex--;
				if (CurFemaleMeshIndex < 0) CurFemaleMeshIndex = MaxFemaleMeshIndex;
				UpdatePlayerAppearance();
			}
			else
			{
				CurMaleMeshIndex--;
				if (CurMaleMeshIndex < 0) CurMaleMeshIndex = MaxMaleMeshIndex;
				UpdatePlayerAppearance();
			}
		break;
		case ButtonMeshNext:
			if (bFemale)
			{
				CurFemaleMeshIndex++;
				if (CurFemaleMeshIndex > MaxFemaleMeshIndex) CurFemaleMeshIndex = 0;
				UpdatePlayerAppearance();
			}
			else
			{
				CurMaleMeshIndex++;
				if (CurMaleMeshIndex > MaxMaleMeshIndex) CurMaleMeshIndex = 0;
				UpdatePlayerAppearance();
			}
		break;
		case ButtonSkinPrev:
			if (bFemale)
			{
				CurFemaleSkinIndex--;
				if (CurFemaleSkinIndex < 0) CurFemaleSkinIndex = MaxFemaleSkinIndex;
				UpdatePlayerAppearance();
			}
			else
			{
				CurMaleSkinIndex--;
				if (CurMaleSkinIndex < 0) CurMaleSkinIndex = MaxMaleSkinIndex;
				UpdatePlayerAppearance();
			}
		break;
		case ButtonSkinNext:
			if (bFemale)
			{
				CurFemaleSkinIndex++;
				if (CurFemaleSkinIndex > MaxFemaleSkinIndex) CurFemaleSkinIndex = 0;
				UpdatePlayerAppearance();
			}
			else
			{
				CurMaleSkinIndex++;
				if (CurMaleSkinIndex > MaxMaleSkinIndex) CurMaleSkinIndex = 0;
				UpdatePlayerAppearance();
			}
		break;
		case ButtonLensesPrev:
			CurTrenchLensesIndex--;
			if (CurTrenchLensesIndex < 0) CurTrenchLensesIndex = MaxTrenchLensesIndex;
			UpdatePlayerAppearance();
		break;
		case ButtonLensesNext:
			CurTrenchLensesIndex++;
			if (CurTrenchLensesIndex > MaxTrenchLensesIndex) CurTrenchLensesIndex = 0;
			UpdatePlayerAppearance();
		break;
		case ButtonFramesPrev:
			CurTrenchFramesIndex--;
			if (CurTrenchFramesIndex < 0) CurTrenchFramesIndex = MaxTrenchFramesIndex;
			UpdatePlayerAppearance();
		break;
		case ButtonFramesNext:
			CurTrenchFramesIndex++;
			if (CurTrenchFramesIndex > MaxTrenchFramesIndex) CurTrenchFramesIndex = 0;
			UpdatePlayerAppearance();
		break;
		case ButtonChestPrev:
			CurTrenchChestIndex--;
			if (CurTrenchChestIndex < 0) CurTrenchChestIndex = MaxTrenchChestIndex;
			UpdatePlayerAppearance();
		break;
		case ButtonChestNext:
			CurTrenchChestIndex++;
			if (CurTrenchChestIndex > MaxTrenchChestIndex) CurTrenchChestIndex = 0;
			UpdatePlayerAppearance();
		break;
		case ButtonCoatPrev:
			CurTrenchCoatIndex--;
			if (CurTrenchCoatIndex < 0) CurTrenchCoatIndex = MaxTrenchCoatIndex;
			UpdatePlayerAppearance();
		break;
		case ButtonCoatNext:
			CurTrenchCoatIndex++;
			if (CurTrenchCoatIndex > MaxTrenchCoatIndex) CurTrenchCoatIndex = 0;
			UpdatePlayerAppearance();
		break;
		case ButtonPantsPrev:
			CurTrenchPantsIndex--;
			if (CurTrenchPantsIndex < 0) CurTrenchPantsIndex = MaxTrenchPantsIndex;
			UpdatePlayerAppearance();
		break;
		case ButtonPantsNext:
			CurTrenchPantsIndex++;
			if (CurTrenchPantsIndex > MaxTrenchPantsIndex) CurTrenchPantsIndex = 0;
			UpdatePlayerAppearance();
		break;
		
		case ButtonPresetPrev:
			if (bFemale)
			{
				CurFemalePresetIndex--;
				if (CurFemalePresetIndex < 0) CurFemalePresetIndex = 10;
				
				if (CurFemalePresetIndex > 0 && (VMP == None || VMP.bAutoloadAppearanceSlots)) LoadFemalePreset(CurFemalePresetIndex-1);
			}
			else
			{
				CurMalePresetIndex--;
				if (CurMalePresetIndex < 0) CurMalePresetIndex = 10;
				
				if (CurMalePresetIndex > 0 && (VMP == None || VMP.bAutoloadAppearanceSlots)) LoadMalePreset(CurMalePresetIndex-1);
			}
			UpdatePlayerAppearance();
		break;
		case ButtonPresetNext:
			if (bFemale)
			{
				CurFemalePresetIndex++;
				if (CurFemalePresetIndex > 10) CurFemalePresetIndex = 0;
				
				if (CurFemalePresetIndex > 0 && (VMP == None || VMP.bAutoloadAppearanceSlots)) LoadFemalePreset(CurFemalePresetIndex-1);
			}
			else
			{
				CurMalePresetIndex++;
				if (CurMalePresetIndex > 10) CurMalePresetIndex = 0;
				
				if (CurMalePresetIndex > 0 && (VMP == None || VMP.bAutoloadAppearanceSlots)) LoadMalePreset(CurMalePresetIndex-1);
			}
			UpdatePlayerAppearance();
		break;
		case SavePresetButton:
			if (bFemale)
			{
				if (CurFemalePresetIndex > 0) SaveFemalePreset(CurFemalePresetIndex-1);
			}
			else
			{
				if (CurMalePresetIndex > 0) SaveMalePreset(CurMalePresetIndex-1);	
			}
		break;
		case LoadPresetButton:
			if (bFemale)
			{
				if (CurFemalePresetIndex > 0) LoadFemalePreset(CurFemalePresetIndex-1);
			}
			else
			{
				if (CurMalePresetIndex > 0) LoadMalePreset(CurMalePresetIndex-1);	
			}
			UpdatePlayerAppearance();
		break;
		
		case ButtonHandednessPrev:
			CurHandednessIndex--;
			if (CurHandednessIndex < 0) CurHandednessIndex = 1;
			UpdatePlayerAppearance();
		break;
		case ButtonHandednessNext:
			CurHandednessIndex++;
			if (CurHandednessIndex > 1) CurHandednessIndex = 0;
			UpdatePlayerAppearance();
		break;
		case SaveHandednessButton:
			if (VMP != None)
			{
				VMP.FaveHandedness = CurHandednessIndex;
				VMP.SaveConfig();	
			}
		break;
		
		case RandomButton:
			RandomizeAppearance();
		break;
		
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
	//GENDER
	if (ButtonGenderPrev != None)
	{
		ButtonGenderPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	if (ButtonGenderNext != None)
	{
		ButtonGenderNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	
	//----------------
	//MESH
	ButtonMeshPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonMeshNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	//----------------
	//SKINS
	ButtonSkinPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonSkinNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);	
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
	
	//----------------
	//HANDEDNESS
	ButtonHandednessPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	ButtonHandednessNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
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
	local DeusExPlayer		localPlayer;
	local String			localStartMap;
	local String            playerName;
	
	localPlayer   = player;
	//localStartMap = strStartMap;
	
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
			//StartCampaign();
		}
	}
	else if (ActionKey ~= "RESET")
	{
		//CurGenderIndex = 0;
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
		VMP.StoredPlayerMesh = string(DuderoniPizza.Mesh);
		switch(CAPS(VMP.StoredPlayerMesh))
		{
			case "DEUSEXCHARACTERS.GM_TRENCH":
				VMP.StoredPlayerMeshLeft = "VMDAssets.GM_TrenchLeft";
			break;
			case "DEUSEXCHARACTERS.GM_TRENCH_F":
				VMP.StoredPlayerMeshLeft = "VMDAssets.GM_Trench_FLeft";
			break;
			case "DEUSEXCHARACTERS.GFM_TRENCH":
				VMP.StoredPlayerMeshLeft = "VMDAssets.GFM_TrenchLeft";
			break;
			
			case "VMDASSETS.GM_TRENCH_LEFT":
				VMP.StoredPlayerMesh = "DeusExCharacters.GM_Trench";
				VMP.StoredPlayerMeshLeft = "VMDAssets.GM_TrenchLeft";
			break;
			case "VMDASSETS.GM_TRENCH_FLEFT":
				VMP.StoredPlayerMesh = "DeusExCharacters.GM_Trench_F";
				VMP.StoredPlayerMeshLeft = "VMDAssets.GM_Trench_FLeft";
			break;
			case "VMDASSETS.GFM_TRENCHLEFT":
				VMP.StoredPlayerMesh = "DeusExCharacters.GFM_Trench";
				VMP.StoredPlayerMeshLeft = "VMDAssets.GFM_TrenchLeft";
			break;
		}
		
		for(i=0; i<8; i++)
		{
			VMP.StoredPlayerSkins[i] = String(DuderoniPizza.Multiskins[i]);
		}
	}
	
	Player.SaveConfig();
}

// ----------------------------------------------------------------------
// TextChanged() 
// ----------------------------------------------------------------------

event bool TextChanged(window edit, bool bModified)
{
	EnableButtons();

	return false;
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

function LoadMalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	CurTrenchLensesIndex = VMP.FaveMaleLensIndex[TArray];
	CurTrenchFramesIndex = VMP.FaveMaleFramesIndex[TArray];
	CurTrenchChestIndex = VMP.FaveMaleChestIndex[TArray];
	CurTrenchCoatIndex = VMP.FaveMaleCoatIndex[TArray];
	CurTrenchPantsIndex = VMP.FaveMalePantsIndex[TArray];
	CurMaleMeshIndex = VMP.FaveMaleMeshIndex[TArray];
	CurMaleSkinIndex = VMP.FaveMaleSkinIndex[TArray];
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function SaveMalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	VMP.FaveMaleLensIndex[TArray] = CurTrenchLensesIndex;
	VMP.FaveMaleFramesIndex[TArray] = CurTrenchFramesIndex;
	VMP.FaveMaleChestIndex[TArray] = CurTrenchChestIndex;
	VMP.FaveMaleCoatIndex[TArray] = CurTrenchCoatIndex;
	VMP.FaveMalePantsIndex[TArray] = CurTrenchPantsIndex;
	VMP.FaveMaleMeshIndex[TArray] = CurMaleMeshIndex;
	VMP.FaveMaleSkinIndex[TArray] = CurMaleSkinIndex;
	
	Player.SaveConfig();
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function LoadFemalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	CurTrenchLensesIndex = VMP.FaveFemaleLensIndex[TArray];
	CurTrenchFramesIndex = VMP.FaveFemaleFramesIndex[TArray];
	CurTrenchChestIndex = VMP.FaveFemaleChestIndex[TArray];
	CurTrenchCoatIndex = VMP.FaveFemaleCoatIndex[TArray];
	CurTrenchPantsIndex = VMP.FaveFemalePantsIndex[TArray];
	CurFemaleMeshIndex = VMP.FaveFemaleMeshIndex[TArray];
	CurFemaleSkinIndex = VMP.FaveFemaleSkinIndex[TArray];
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function SaveFemalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	VMP.FaveFemaleLensIndex[TArray] = CurTrenchLensesIndex;
	VMP.FaveFemaleFramesIndex[TArray] = CurTrenchFramesIndex;
	VMP.FaveFemaleChestIndex[TArray] = CurTrenchChestIndex;
	VMP.FaveFemaleCoatIndex[TArray] = CurTrenchCoatIndex;
	VMP.FaveFemalePantsIndex[TArray] = CurTrenchPantsIndex;
	VMP.FaveFemaleMeshIndex[TArray] = CurFemaleMeshIndex;
	VMP.FaveFemaleSkinIndex[TArray] = CurFemaleSkinIndex;
	
	Player.SaveConfig();
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function RandomizeAppearance()
{
	local int TRand;
	
	if (bCanMakeFemale)
	{
		CurGenderIndex = Rand(MaxGenderIndex+1);
	}
	else
	{
		CurGenderIndex = 0;
	}
	CurMaleMeshIndex = Rand(MaxMaleMeshIndex+1);
	CurFemaleMeshIndex = Rand(CurFemaleMeshIndex+1);
	
	TRand = Rand(MaxMaleSkinIndex+1-DDSFat);
	CurMaleSkinIndex = TRand;
	CurFemaleSkinIndex = TRand;
	
	CurTrenchLensesIndex = Rand(MaxTrenchLensesIndex+1-DDSFat);
	CurTrenchFramesIndex = Rand(MaxTrenchFramesIndex+1-DDSFat);
	CurTrenchChestIndex = Rand(MaxTrenchChestIndex+1-DDSFat);
	CurTrenchCoatIndex = Rand(MaxTrenchCoatIndex+1-DDSFat);
	CurTrenchPantsIndex = Rand(MaxTrenchPantsIndex+1-DDSFat);
	
	CurHandednessIndex = Rand(2);
	
	UpdatePlayerAppearance();
}

defaultproperties
{
     bHackUpdateRequired=True
     GenderLabelText="Gender:"
     MeshLabelText="Build:"
     SkinLabelText="Appearance:"
     LensesLabelText="Glasses:"
     FramesLabelText="Frames:"
     ChestLabelText="Shirt:"
     CoatLabelText="Coat:"
     PantsLabelText="Pants:"
     
     SavedLabelText="Preset:"
     SaveMaleButtonText="Save Male #%d"
     SaveFemaleButtonText="Save Female #%d"
     DefaultSlotText="No Preset"
     SavedMaleSlotText="Male #%d"
     SavedFemaleSlotText="Female #%d"
     
     LoadMaleButtonText="Load Male #%d"
     LoadFemaleButtonText="Load Female #%d"
     
     HandednessLabelText="Dominant Hand"
     
     DudeSequences(0)=BreatheLight
     DudeSequences(1)=Walk
     DudeSequences(2)=BreatheLight	//Run
     DudeSequences(3)=CrouchWalk
     DudeSequences(4)=Run
     DudeSequences(5)=Walk
     DudeSequences(6)=BreatheLight
     //MADDERS: Dialing back, since it disrupts the ability to read lenses properly.
     MaxDudeSequences=2 		//6
     MaleMeshes(0)=LODMesh'GM_Trench'
     MaleMeshes(1)=LODMesh'GM_Trench_F'
     MaxMaleMeshIndex=1
     FemaleMeshes(0)=LODMesh'GFM_Trench'
     MaxFemaleMeshIndex=0
     
     MaxGenderIndex=1
     
     PlayerPreviewOffset=(X=100,Y=0,Z=0)
     CodeNamePos=(X=18,Y=36)
     TrueNamePos=(X=18,Y=92)
     //GenderPos=(X=18,Y=174)
     //MeshPos=(X=184,Y=36)
     //SkinPos=(X=184,Y=82)
     //LensesPos=(X=184,Y=128)
     //FramesPos=(X=184,Y=174)
     //ChestPos=(X=184,Y=220)
     //CoatPos=(X=184,Y=266)
     //PantsPos=(X=184,Y=312)

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
     
     MaleSkinTexs(0)=Texture'DeusExCharacters.Skins.JCDentonTex0'
     MaleSkinTexs(1)=Texture'DeusExCharacters.Skins.JCDentonTex4'
     MaleSkinTexs(2)=Texture'DeusExCharacters.Skins.JCDentonTex5'
     MaleSkinTexs(3)=Texture'DeusExCharacters.Skins.JCDentonTex6'
     MaleSkinTexs(4)=Texture'DeusExCharacters.Skins.JCDentonTex7'
     MaleSkinTexs(5)=Texture'VMDAssets.DDSSkinSlot01Male'
     MaleSkinTexs(6)=Texture'VMDAssets.DDSSkinSlot02Male'
     MaleSkinTexs(7)=Texture'VMDAssets.DDSSkinSlot03Male'
     MaleSkinTexs(8)=Texture'VMDAssets.DDSSkinSlot04Male'
     MaleSkinTexs(9)=Texture'VMDAssets.DDSSkinSlot05Male'
     MaxMaleSkinIndex=9
     FemaleSkinTexs(0)=Texture'JCDentonFemaleTex0'
     FemaleSkinTexs(1)=Texture'JCDentonFemaleTex4'
     FemaleSkinTexs(2)=Texture'JCDentonFemaleTex5'
     FemaleSkinTexs(3)=Texture'JCDentonFemaleTex6'
     FemaleSkinTexs(4)=Texture'JCDentonFemaleTex7'
     FemaleSkinTexs(5)=Texture'VMDAssets.DDSSkinSlot01Female'
     FemaleSkinTexs(6)=Texture'VMDAssets.DDSSkinSlot02Female'
     FemaleSkinTexs(7)=Texture'VMDAssets.DDSSkinSlot03Female'
     FemaleSkinTexs(8)=Texture'VMDAssets.DDSSkinSlot04Female'
     FemaleSkinTexs(9)=Texture'VMDAssets.DDSSkinSlot05Female'
     MaxFemaleSkinIndex=9
     
     TrenchLensesTexs(0)=Texture'DeusExCharacters.Skins.LensesTex5'
     TrenchLensesTexs(1)=Texture'DeusExCharacters.Skins.LensesTex6'
     TrenchLensesTexs(2)=Texture'DeusExCharacters.Skins.LensesTex1'
     TrenchLensesTexs(3)=Texture'DeusExCharacters.Skins.LensesTex2'
     TrenchLensesTexs(4)=Texture'DeusExCharacters.Skins.LensesTex3'
     TrenchLensesTexs(5)=Texture'DeusExCharacters.Skins.LensesTex4'
     TrenchLensesTexs(6)=Texture'VMDAssets.Skins.GreenLenses'
     TrenchLensesTexs(7)=Texture'VMDAssets.Skins.LimeLenses'
     TrenchLensesTexs(8)=Texture'VMDAssets.Skins.PinkLenses'
     TrenchLensesTexs(9)=Texture'VMDAssets.Skins.PurpleLenses'
     TrenchLensesTexs(10)=Texture'VMDAssets.Skins.RedLenses'
     TrenchLensesTexs(11)=Texture'DeusExItems.Skins.BlackMaskTex'
     TrenchLensesTexs(12)=Texture'VMDAssets.DDSLensesSlot01'
     TrenchLensesTexs(13)=Texture'VMDAssets.DDSLensesSlot02'
     TrenchLensesTexs(14)=Texture'VMDAssets.DDSLensesSlot03'
     TrenchLensesTexs(15)=Texture'VMDAssets.DDSLensesSlot04'
     TrenchLensesTexs(16)=Texture'VMDAssets.DDSLensesSlot05'
     MaxTrenchLensesIndex=16
     
     TrenchFramesTexs(0)=Texture'DeusExCharacters.Skins.FramesTex4'
     TrenchFramesTexs(1)=Texture'DeusExCharacters.Skins.FramesTex5'
     TrenchFramesTexs(2)=Texture'DeusExCharacters.Skins.FramesTex1'
     TrenchFramesTexs(3)=Texture'DeusExCharacters.Skins.FramesTex2'
     TrenchFramesTexs(4)=Texture'DeusExCharacters.Skins.FramesTex3'
     TrenchFramesTexs(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     TrenchFramesTexs(6)=Texture'VMDAssets.DDSFramesSlot01'
     TrenchFramesTexs(7)=Texture'VMDAssets.DDSFramesSlot02'
     TrenchFramesTexs(8)=Texture'VMDAssets.DDSFramesSlot03'
     TrenchFramesTexs(9)=Texture'VMDAssets.DDSFramesSlot04'
     TrenchFramesTexs(10)=Texture'VMDAssets.DDSFramesSlot05'
     MaxTrenchFramesIndex=10
     
     TrenchChestTexs(0)=Texture'DeusExCharacters.Skins.JCDentonTex1'
     TrenchChestTexs(1)=Texture'VMDNSFBountyHunterShirt01'
     TrenchChestTexs(2)=Texture'VMDNSFBountyHunterShirt02'
     TrenchChestTexs(3)=Texture'VMDNSFBountyHunterShirt03'
     TrenchChestTexs(4)=Texture'VMDNSFBountyHunterShirt04'
     TrenchChestTexs(5)=Texture'VMDNSFBountyHunterShirt05'
     TrenchChestTexs(6)=Texture'VMDNSFBountyHunterShirt06'
     TrenchChestTexs(7)=Texture'DeusExCharacters.Skins.DoctorTex1'
     TrenchChestTexs(8)=Texture'DeusExCharacters.Skins.FordSchickTex1'
     TrenchChestTexs(9)=Texture'DeusExCharacters.Skins.GarySavageTex1'
     TrenchChestTexs(10)=Texture'DeusExCharacters.Skins.GilbertRentonTex1'
     TrenchChestTexs(11)=Texture'DeusExCharacters.Skins.JaimeReyesTex1'
     TrenchChestTexs(12)=Texture'DeusExCharacters.Skins.JockTex1'
     TrenchChestTexs(13)=Texture'DeusExCharacters.Skins.JosephManderleyTex1'
     TrenchChestTexs(14)=Texture'DeusExCharacters.Skins.JuanLebedevTex1'
     TrenchChestTexs(15)=Texture'DeusExCharacters.Skins.MaxChenTex1'
     TrenchChestTexs(16)=Texture'DeusExCharacters.Skins.PaulDentonTex1'
     TrenchChestTexs(17)=Texture'DeusExCharacters.Skins.TriadRedArrowTex1'
     TrenchChestTexs(18)=Texture'DeusExCharacters.Skins.SmugglerTex1'
     TrenchChestTexs(19)=Texture'DeusExCharacters.Skins.StantonDowdTex1'
     TrenchChestTexs(20)=Texture'DeusExCharacters.Skins.ThugMaleTex1'
     TrenchChestTexs(21)=Texture'DeusExCharacters.Skins.TobyAtanweTex1'
     TrenchChestTexs(22)=Texture'DeusExCharacters.Skins.TrenchShirtTex1'
     TrenchChestTexs(23)=Texture'DeusExCharacters.Skins.TrenchShirtTex2'
     TrenchChestTexs(24)=Texture'DeusExCharacters.Skins.TrenchShirtTex3'
     TrenchChestTexs(25)=Texture'DeusExCharacters.Skins.WaltonSimonsTex1'
     TrenchChestTexs(26)=Texture'DeusExCharacters.Skins.Female4Tex1'
     TrenchChestTexs(27)=Texture'VMDAssets.DDSTrenchShirtSlot01'
     TrenchChestTexs(28)=Texture'VMDAssets.DDSTrenchShirtSlot02'
     TrenchChestTexs(29)=Texture'VMDAssets.DDSTrenchShirtSlot03'
     TrenchChestTexs(30)=Texture'VMDAssets.DDSTrenchShirtSlot04'
     TrenchChestTexs(31)=Texture'VMDAssets.DDSTrenchShirtSlot05'
     MaxTrenchChestIndex=31
     
     TrenchCoatTexs(0)=Texture'DeusExCharacters.Skins.JCDentonTex2'
     TrenchCoatTexs(1)=Texture'DeusExCharacters.Skins.BumMale2Tex2'
     TrenchCoatTexs(2)=Texture'DeusExCharacters.Skins.BumMale3Tex2'
     TrenchCoatTexs(3)=Texture'DeusExCharacters.Skins.BumMaleTex2'
     TrenchCoatTexs(4)=Texture'DeusExCharacters.Skins.FordSchickTex2'
     TrenchCoatTexs(5)=Texture'DeusExCharacters.Skins.GilbertRentonTex2'
     TrenchCoatTexs(6)=Texture'DeusExCharacters.Skins.GordonQuickTex2'
     TrenchCoatTexs(7)=Texture'DeusExCharacters.Skins.HarleyFilbenTex2'
     TrenchCoatTexs(8)=Texture'DeusExCharacters.Skins.JockTex2'
     TrenchCoatIsShort(8)=1
     TrenchCoatTexs(9)=Texture'DeusExCharacters.Skins.JosephManderleyTex2'
     TrenchCoatTexs(10)=Texture'DeusExCharacters.Skins.JuanLebedevTex2'
     TrenchCoatTexs(11)=Texture'DeusExCharacters.Skins.LabCoatTex1'
     TrenchCoatTexs(12)=Texture'DeusExCharacters.Skins.MaxChenTex2'
     TrenchCoatTexs(13)=Texture'DeusExCharacters.Skins.PaulDentonTex2'
     TrenchCoatTexs(14)=Texture'DeusExCharacters.Skins.TriadRedArrowTex2'
     TrenchCoatTexs(15)=Texture'DeusExCharacters.Skins.SmugglerTex2'
     TrenchCoatTexs(16)=Texture'DeusExCharacters.Skins.StantonDowdTex2'
     TrenchCoatTexs(17)=Texture'DeusExCharacters.Skins.ThugMaleTex2'
     TrenchCoatIsShort(17)=1
     TrenchCoatTexs(18)=Texture'DeusExCharacters.Skins.TobyAtanweTex2'
     TrenchCoatTexs(19)=Texture'DeusExCharacters.Skins.TrenchCoatTex1'
     TrenchCoatTexs(20)=Texture'DeusExCharacters.Skins.WaltonSimonsTex2'
     TrenchCoatTexs(21)=Texture'VMDAssets.DDSTrenchCoatSlot01'
     TrenchCoatTexs(22)=Texture'VMDAssets.DDSTrenchCoatSlot02'
     TrenchCoatTexs(23)=Texture'VMDAssets.DDSTrenchCoatSlot03'
     TrenchCoatTexs(24)=Texture'VMDAssets.DDSTrenchCoatSlot04'
     TrenchCoatTexs(25)=Texture'VMDAssets.DDSTrenchCoatSlot05'
     MaxTrenchCoatIndex=25
     
     TrenchPantsTexs(0)=Texture'DeusExCharacters.Skins.JCDentonTex3'
     TrenchPantsTexs(1)=Texture'DeusExCharacters.Skins.AlexJacobsonTex2'
     TrenchPantsTexs(2)=Texture'DeusExCharacters.Skins.BobPageTex2'
     TrenchPantsTexs(3)=Texture'DeusExCharacters.Skins.Businessman1Tex2'
     TrenchPantsTexs(4)=Texture'DeusExCharacters.Skins.Businessman2Tex2'
     TrenchPantsTexs(5)=Texture'DeusExCharacters.Skins.Businessman3Tex2'
     TrenchPantsTexs(6)=Texture'DeusExCharacters.Skins.ChadTex2'
     TrenchPantsTexs(7)=Texture'DeusExCharacters.Skins.CopTex2'
     TrenchPantsTexs(8)=Texture'DeusExCharacters.Skins.GordonQuickTex3'
     TrenchPantsTexs(9)=Texture'DeusExCharacters.Skins.HKMilitaryTex2'
     TrenchPantsTexs(10)=Texture'DeusExCharacters.Skins.HowardStrongTex2'
     TrenchPantsTexs(11)=Texture'DeusExCharacters.Skins.JanitorTex2'
     TrenchPantsTexs(12)=Texture'DeusExCharacters.Skins.JockTex3'
     TrenchPantsTexs(13)=Texture'DeusExCharacters.Skins.JoJoFineTex2'
     TrenchPantsTexs(14)=Texture'DeusExCharacters.Skins.JuanLebedevTex3'
     TrenchPantsTexs(15)=Texture'DeusExCharacters.Skins.JunkieFemaleTex2'
     TrenchPantsTexs(16)=Texture'DeusExCharacters.Skins.JunkieMaleTex2'
     TrenchPantsTexs(17)=Texture'DeusExCharacters.Skins.LowerClassMale2Tex2'
     TrenchPantsTexs(18)=Texture'DeusExCharacters.Skins.Male2Tex2'
     TrenchPantsTexs(19)=Texture'DeusExCharacters.Skins.Male4Tex2'
     TrenchPantsTexs(20)=Texture'DeusExCharacters.Skins.MaxChenTex3'
     TrenchPantsTexs(21)=Texture'DeusExCharacters.Skins.MechanicTex2'
     TrenchPantsTexs(22)=Texture'DeusExCharacters.Skins.MichaelHamnerTex2'
     TrenchPantsTexs(23)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
     TrenchPantsTexs(24)=Texture'DeusExCharacters.Skins.NathanMadisonTex2'
     TrenchPantsTexs(25)=Texture'DeusExCharacters.Skins.PantsTex1'
     TrenchPantsTexs(26)=Texture'DeusExCharacters.Skins.PantsTex10'
     TrenchPantsTexs(27)=Texture'DeusExCharacters.Skins.PantsTex2'
     TrenchPantsTexs(28)=Texture'DeusExCharacters.Skins.PantsTex3'
     TrenchPantsTexs(29)=Texture'DeusExCharacters.Skins.PantsTex4'
     TrenchPantsTexs(30)=Texture'DeusExCharacters.Skins.PantsTex5'
     TrenchPantsTexs(31)=Texture'DeusExCharacters.Skins.PantsTex6'
     TrenchPantsTexs(32)=Texture'DeusExCharacters.Skins.PantsTex7'
     TrenchPantsTexs(33)=Texture'DeusExCharacters.Skins.PantsTex8'
     TrenchPantsTexs(34)=Texture'DeusExCharacters.Skins.PantsTex9'
     TrenchPantsTexs(35)=Texture'DeusExCharacters.Skins.TriadRedArrowTex3'
     TrenchPantsTexs(36)=Texture'DeusExCharacters.Skins.RiotCopTex1'
     TrenchPantsTexs(37)=Texture'DeusExCharacters.Skins.SailorTex2'
     TrenchPantsTexs(38)=Texture'DeusExCharacters.Skins.SamCarterTex2'
     TrenchPantsTexs(39)=Texture'DeusExCharacters.Skins.SecretServiceTex2'
     TrenchPantsTexs(40)=Texture'DeusExCharacters.Skins.SoldierTex2'
     TrenchPantsTexs(41)=Texture'DeusExCharacters.Skins.ThugMale2Tex2'
     TrenchPantsTexs(42)=Texture'DeusExCharacters.Skins.ThugMale3Tex2'
     TrenchPantsTexs(43)=Texture'DeusExCharacters.Skins.ThugMaleTex3'
     TrenchPantsTexs(44)=Texture'DeusExCharacters.Skins.TiffanySavageTex2'
     TrenchPantsTexs(45)=Texture'DeusExCharacters.Skins.TracerTongTex2'
     TrenchPantsTexs(46)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
     TrenchPantsTexs(47)=Texture'VMDAssets.DDSTrenchPantsSlot01'
     TrenchPantsTexs(48)=Texture'VMDAssets.DDSTrenchPantsSlot02'
     TrenchPantsTexs(49)=Texture'VMDAssets.DDSTrenchPantsSlot03'
     TrenchPantsTexs(50)=Texture'VMDAssets.DDSTrenchPantsSlot04'
     TrenchPantsTexs(51)=Texture'VMDAssets.DDSTrenchPantsSlot05'
     MaxTrenchPantsIndex=51
     
     filterString="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "
     HeaderNameLabel="Real Name"
     HeaderCodeNameLabel="Code Name"
     NameBlankTitle="Name Blank!"
     NameBlankPrompt="The Real Name cannot be blank, please enter a name."
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Edit Class",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Reset",Key="RESET")
     Title="Appearance Setup"
     ClientWidth=324
     ClientHeight=389
     textureRows=2
     textureCols=2
     clientTextures(0)=Texture'MenuAppearanceBackground_1'
     //clientTextures(1)=Texture'MenuAppearanceBackground_2'
     clientTextures(1)=Texture'MenuAppearanceBackground_3'
     clientTextures(2)=Texture'MenuAppearanceBackground_4'
     //clientTextures(4)=Texture'MenuAppearanceBackground_5'
     clientTextures(3)=Texture'MenuAppearanceBackground_6'
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
}
