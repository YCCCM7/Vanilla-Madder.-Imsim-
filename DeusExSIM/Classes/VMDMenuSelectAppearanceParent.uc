//=============================================================================
// VMDMenuSelectAppearanceParent
//=============================================================================
class VMDMenuSelectAppearanceParent expands MenuUIScreenWindow;

#exec OBJ LOAD FILE=VMDAssets

var MenuUIInfoButtonWindow winNameBorder;
var MenuUIEditWindow EditCodeName, EditName;
var MenuUIEditWindow GenderEntry, MeshEntry, SkinEntry, PantsEntry, ChestEntry, CoatEntry, LensesEntry, FramesEntry;
var MenuUILabelWindow GenderLabel, MeshLabel, SkinLabel, PantsLabel, ChestLabel, CoatLabel, LensesLabel, FramesLabel;
var MenuUILabelWindow TrueNameLabel, CodeNameLabel;

var String filterString;

var localized string HeaderNameLabel, HeaderCodeNameLabel;
var localized string NameBlankTitle, NameBlankPrompt;

var localized string GenderNames[2], HandednessNames[2];
var localized string MaleMeshNames[8], FemaleMeshNames[8];
var localized string MaleSkinNames[64], FemaleSkinNames[64];
var localized string NihilumSkinNames[3], HiveDaysSkinNames[3];

var localized string StrUnavailable;

//MADDERS, using a method pioneered by the legendary Smoke39.
var Texture MaleSkinTexs[64], FemaleSkinTexs[64];

//TRENCH TEXES
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

//JUMPSUIT TEXES
var localized string JumpsuitCoatLabel, JumpsuitLensesLabel, JumpsuitFramesLabel;

var Texture JumpsuitShirtTexs[64];
//var Texture JumpsuitPantsTexs[64];
var Texture JumpsuitHelmetTexs[64];
var Texture JumpsuitVisorTexs[64];

var int CurJumpsuitShirtIndex, MaxJumpsuitShirtIndex;
var int CurJumpsuitPantsIndex; //, MaxJumpsuitPantsIndex;
var int CurJumpsuitHelmetIndex, MaxJumpsuitHelmetIndex;
var int CurJumpsuitVisorIndex, MaxJumpsuitVisorIndex;

//SUIT TEXES
var localized string SuitCoatLabel, SuitLensesLabel, SuitFramesLabel;

var Texture SuitShirtTexs[64];
//var Texture SuitPantsTexs[64];

var int CurSuitLensesIndex; //, MaxSuitLensesIndex
var int CurSuitFramesIndex; //, MaxSuitFramesIndex
var int CurSuitShirtIndex, MaxSuitShirtIndex;
var int CurSuitPantsIndex; //, MaxSuitPantsIndex

//DRESS SHIRT TEXES
var localized string DressShirtCoatLabel, DressShirtLensesLabel, DressShirtFramesLabel;

var Texture DressShirtShirtTexs[64];
//var Texture DressShirtPantsTexs[64];

var int CurDressShirtLensesIndex; //, MaxDressShirtLensesIndex
var int CurDressShirtFramesIndex; //, MaxDressShirtFramesIndex
var int CurDressShirtShirtIndex, MaxDressShirtShirtIndex;
var int CurDressShirtPantsIndex; //, MaxDressShirtPantsIndex

//SUIT SKIRT TEXES
var localized string SuitSkirtCoatLabel, SuitSkirtLensesLabel, SuitSkirtFramesLabel, SuitSkirtShirtLabel, SuitSkirtPantsLabel;
var localized string SuitSkirtHairNames[2];

var Texture SuitSkirtShirtTexs[64];

var int CurSuitSkirtLensesIndex; //, MaxSuitSkirtLensesIndex
var int CurSuitSkirtFramesIndex; //, MaxSuitSkirtFramesIndex
var int CurSuitSkirtShirtIndex, MaxSuitSkirtShirtIndex;
var int CurSuitSkirtHairIndex, MaxSuitSkirtHairIndex;

//DRESS TEXES
var localized string DressCoatLabel, DressLensesLabel, DressFramesLabel, DressShirtLabel, DressPantsLabel;
var localized string DressHairNames[4];

var Texture DressShirtTexs[64];
var Texture DressSkirtTexs[64];

var int CurDressShirtIndex, MaxDressShirtIndex;
var int CurDressHairIndex, MaxDressHairIndex;

var VMDBufferPlayer VMP;
var Actor DuderoniPizza; //MADDERS: In case there was any doubt I was using Smoke as a cheatsheet.
var Rotator DudRot;

//MADDERS originals. Alternating anims, custom rotation, and female JC support... When appropriate for the campaign.
var bool bFemale, bCanMakeFemale;
var int CustomRotationMod;

//MADDERS: Coat short data, and mesh indices.
var byte TrenchCoatIsShort[64];
var int CurMaleMeshIndex, MaxMaleMeshIndex, CurFemaleMeshIndex, MaxFemaleMeshIndex;
var int CurMaleSkinIndex, MaxMaleSkinIndex, CurFemaleSkinIndex, MaxFemaleSkinIndex, DDSFat;
var int CurGenderIndex, MaxGenderIndex;
var Mesh MaleMeshes[8], MaleLeftMeshes[8], FemaleMeshes[8], FemaleLeftMeshes[8];

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

function LoadHiveDaysAssetBounds()
{
	MaxMaleMeshIndex = 0;
	
	MaleSkinTexs[0] = Texture'SkinTex34';
	MaleSkinTexs[1] = Texture'SkinTex37';
	MaleSkinTexs[2] = Texture'SkinTex38';
	MaxMaleSkinIndex = 2;
	
	//Jack wears a colorful shirt, casual jeans, and a sawed down smuggler trench.
	//No glasses at this time.
	CurTrenchCoatIndex = 15;
	TrenchCoatIsShort[15] = 1;
	TrenchChestTexs[MaxTrenchChestIndex+1] = Texture(DynamicLoadObject("Supercarbon.JackShirtTex1", class'Texture', false));
	CurTrenchChestIndex = MaxTrenchChestIndex+1;
	MaxTrenchChestIndex += 1;
	CurTrenchPantsIndex = 27;
	CurTrenchFramesIndex = 5;
}

function LoadBLVAssetBounds()
{
	MaxMaleMeshIndex = 1;
	
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
	
	MaxMaleMeshIndex = 1;
	
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
	
	MaxMaleMeshIndex = 1;
	
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
	
	MaxMaleMeshIndex = 1;
	
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
	switch(Conv)
	{
		case "GrayMaskTex":
		case "BlackMaskTex":
		case "PinkMaskTex":
			return "None";
		break;
		case "RevenantSuitTex1":
			return "Revenant Suit 1";
		break;
		case "RevenantSuitTex2":
			return "Revenant Suit 2";
		break;
		case "RevenantSuitTex3":
			return "Revenant Suit 3";
		break;
	}
	
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
		case "Triad Lum Path":
			return "Lum. Path Triad";
		break;
		case "MJ12Troop":
			return "MJ12 Troop";
		break;
		case "BountyHunter2Shirt1":
			return "Bounty Hunter Shirt 1";
		break;
		case "BountyHunter2Shirt2":
			return "Bounty Hunter Shirt 2";
		break;
		case "BountyHunter2Shirt3":
			return "Bounty Hunter Shirt 3";
		break;
		case "BountyHunter2Shirt4":
			return "Bounty Hunter Shirt 4";
		break;
		case "BountyHunter2Shirt5":
			return "Bounty Hunter Shirt 5";
		break;
		case "MIB":
			return "MIB";
		break;
		case "WIB":
			return "WIB";
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

function RotatePlayerModel(bool bRight, optional int YawMod)
{
	if (YawMod == 0) YawMod = 2048;
	
	if (ButtonSkinNext != None)
	{
		if (DuderoniPizza != None)
		{
			DuderoniPizza.bHidden = true;
		}
	}
	
	if (bRight)
	{
		DudRot.Yaw += YawMod;
	}
	else
	{
		DudRot.Yaw -= YawMod;
	}
	
	if (ButtonSkinNext != None)
	{
		if (CustomRotationMod < 0) CustomRotationMod += 65536;
		CustomRotationMod = (CustomRotationMod % 65536);
	}
}

function UpdatePlayerAppearance()
{
	local bool bChestUnavailable, bPantsUnavailable, bLensesUnavailable, FlagNihilum, FlagHiveDays, TFemale;
	local int TArray, i;
	local name TMesh;
	local Texture ChestUse, CoatUse, PantsUse, LensesUse, FramesUse;
	local Actor Dud;
	
	if (MeshEntry == None || PresetEntry == None
		|| LensesEntry == None || FramesEntry == None || ChestEntry == None || CoatEntry == None || PantsEntry == None)
	{
		return;
	}
	
	Dud = DuderoniPizza;
	if (ButtonSkinNext == None)
	{
		Dud = VMP;
	}
	
	if (Dud == None)
	{
		return;
	}
	
	if (StoredCampaign ~= "Nihilum")
	{
		FlagNihilum = true;
	}
	else if (StoredCampaign ~= "HiveDays")
	{
		FlagHiveDays = true;
	}
	
	TFemale = (CurGenderIndex == 1);
	if (ButtonSkinNext == None)
	{
		TFemale = VMP.bAssignedFemale;
	}
	
	switch(TFemale)
	{
		case false:
			bFemale = false;
			if (GenderEntry != None)
			{
				GenderEntry.SetText(GenderNames[0]);
			}
			
			MeshEntry.SetText(MaleMeshNames[CurMaleMeshIndex]);
			if (SkinEntry != None)
			{
				SkinEntry.SetText(MaleSkinNames[CurMaleSkinIndex]);
			}
		break;
		case true:
			bFemale = true;
			if (GenderEntry != None)
			{
				GenderEntry.SetText(GenderNames[1]);
			}
			
			MeshEntry.SetText(FemaleMeshNames[CurFemaleMeshIndex]);
			if (SkinEntry != None)
			{
				SkinEntry.SetText(FemaleSkinNames[CurFemaleSkinIndex]);
			}
		break;
	}
	
	//MADDERS: Alternate names for our skin colors, since they're hair colors now.
	if ((FlagNihilum) && (SkinEntry != None))
	{
		SkinEntry.SetText(NihilumSkinNames[CurMaleSkinIndex]);
	}
	
	//MADDERS, 5/29/25: New names for these for Jack.
	if ((FlagHiveDays) && (SkinEntry !=  None))
	{
		SkinEntry.SetText(HiveDaysSkinNames[CurMaleSkinIndex]);
	}
	
	//MADDERS: Alternate names for our skin colors, since they're hair colors now.
	if ((StoredCampaign ~= "BloodLikeVenom") && (SkinEntry != None))
	{
		switch(CurMaleSkinIndex)
		{
			case 0:
				SkinEntry.SetText("Johnny Venom");
			break;
		}
	}
	
	//MADDERS: Bishop override
	if ((StoredCampaign ~= "Counterfeit") && (SkinEntry != None))
	{
		switch(CurMaleSkinIndex)
		{
			case 0:
			default:
				SkinEntry.SetText("Dominic");
			break;
		}
	}
	
	if (TFemale)
	{
		Dud.Mesh = FemaleMeshes[CurFemaleMeshIndex];
		if (VMDBufferPlayer(Dud) != None)
		{
			VMDBufferPlayer(Dud).FabricatedMesh = FemaleMeshes[CurFemaleMeshIndex];
			VMDBufferPlayer(Dud).FabricatedMeshLeft = FemaleLeftMeshes[CurFemaleMeshIndex];
		}
	}
	else
	{
		Dud.Mesh = MaleMeshes[CurMaleMeshIndex];
		if (VMDBufferPlayer(Dud) != None)
		{
			VMDBufferPlayer(Dud).FabricatedMesh = MaleMeshes[CurMaleMeshIndex];
			VMDBufferPlayer(Dud).FabricatedMeshLeft = MaleLeftMeshes[CurMaleMeshIndex];
		}
	}
	
	if (ButtonSkinNext == None)
	{
		TMesh = VMP.Mesh.Name;
	}
	else
	{
		TMesh = MaleMeshes[CurMaleMeshIndex].Name;
		if (TFemale) TMesh = FemaleMeshes[CurFemaleMeshIndex].Name;
	}
	
	switch(TMesh)
	{
		//1111111111111111111111111111111111
		//TRENCH COATS!
		//----------------------------------
		case 'GM_Trench':
		case 'GM_TrenchLeft':
		case 'GM_Trench_F':
		case 'VMDGM_Trench_F':
		case 'GM_Trench_FLeft':
		case 'GFM_Trench':
		case 'VMDGFM_Trench':
		case 'GFM_TrenchLeft':
			CoatLabel.SetText(CoatLabelText);
			LensesLabel.SetText(LensesLabelText);
			FramesLabel.SetText(FramesLabelText);
			ChestLabel.SetText(ChestLabelText);
			PantsLabel.SetText(PantsLabelText);
			
			ChestUse = TrenchChestTexs[CurTrenchChestIndex];
			if (CurTrenchChestIndex == 26)
			{
				if (!TFemale)
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
			if ((CurTrenchCoatIndex == 0) && (TFemale))
			{
				CoatUse = Texture'JCDentonFemaleTex2';
			}
			if ((CurTrenchPantsIndex == 0) && (TFemale))
			{
				PantsUse = Texture'JCDentonFemaleTex3';
			}
			if (CurTrenchPantsIndex == 29)
			{
				if ((TFemale) && (CurFemaleSkinIndex % 5 != 0) && (CurFemaleSkinIndex % 5 != 3))
				{
					bPantsUnavailable = true;
					PantsUse = Texture'PantsTex3';
				}
				else if ((!TFemale) && (CurMaleSkinIndex % 5 != 0) && (CurMaleSkinIndex % 5 != 3))
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
				if (TFemale)
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
			
			if (TFemale)
			{
				Dud.Multiskins[0] = FemaleSkinTexs[CurFemaleSkinIndex];
				Dud.Multiskins[3] = FemaleSkinTexs[CurFemaleSkinIndex];
			}
			else
			{
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
			
			LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
			FramesEntry.SetText(DeriveHumanName(string(FramesUse)));
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			CoatEntry.SetText(DeriveHumanName(string(CoatUse)));
			
			//Pants exceptions
			PantsEntry.SetText(DeriveHumanName(string(PantsUse)));
			if (bPantsUnavailable) PantsEntry.SetText(StrUnavailable);
			
			if (TFemale)
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
		break;
		//2222222222222222222222222222222222
		//JUMPSUITS!
		//----------------------------------
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
		case 'MP_JumpsuitLeft':
			CoatLabel.SetText(JumpsuitCoatLabel);
			LensesLabel.SetText(JumpsuitLensesLabel);
			FramesLabel.SetText(JumpsuitFramesLabel);
			ChestLabel.SetText(ChestLabelText);
			PantsLabel.SetText(PantsLabelText);
			
			ChestUse = JumpsuitShirtTexs[CurJumpsuitShirtIndex];
			if (CurJumpsuitShirtIndex == 26)
			{
				if ((CurFemaleSkinIndex % 5 != 0) && (CurFemaleSkinIndex % 5 != 3))
				{
					bChestUnavailable = true;
					ChestUse = Texture'JCDentonTex1';
				}
			}
			
			PantsUse = TrenchPantsTexs[CurJumpsuitPantsIndex];
			if (CurJumpsuitPantsIndex == 29)
			{
				if ((CurMaleSkinIndex % 5 != 0) && (CurMaleSkinIndex % 5 != 3))
				{
					bPantsUnavailable = true;
					PantsUse = Texture'PantsTex3';
				}
			}
			
			CoatUse = JumpsuitHelmetTexs[CurJumpsuitHelmetIndex];
			LensesUse = JumpsuitVisorTexs[CurJumpsuitVisorIndex];
			if (CurJumpsuitHelmetIndex < 6)
			{
				bLensesUnavailable = true;
				LensesUse = Texture'PinkMaskTex';
			}
			
			Dud.Multiskins[0] = MaleSkinTexs[CurMaleSkinIndex];
			Dud.Multiskins[3] = MaleSkinTexs[CurMaleSkinIndex];
			
			Dud.Multiskins[1] = PantsUse;
			Dud.Multiskins[2] = ChestUse;
			Dud.Multiskins[4] = Texture'PinkMaskTex';
			Dud.Multiskins[5] = Texture'PinkMaskTex';
			Dud.Multiskins[6] = CoatUse;
			Dud.Multiskins[7] = Texture'PinkMaskTex';
			Dud.Texture = LensesUse;
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			//Pants exceptions
			PantsEntry.SetText(DeriveHumanName(string(PantsUse)));
			if (bPantsUnavailable) PantsEntry.SetText(StrUnavailable);
			
			CoatEntry.SetText(DeriveHumanName(string(CoatUse)));
			
			LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
			if (bLensesUnavailable) LensesEntry.SetText(StrUnavailable);
			
			FramesEntry.SetText(StrUnavailable);
			
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
					if (CurJumpsuitVisorIndex != VMP.FaveMaleLensIndex[TArray] || 
						//CurTrenchFramesIndex != VMP.FaveMaleFramesIndex[TArray] || 
						CurJumpsuitShirtIndex != VMP.FaveMaleChestIndex[TArray] || 
						CurJumpsuitHelmetIndex != VMP.FaveMaleCoatIndex[TArray] || 
						CurJumpsuitPantsIndex != VMP.FaveMalePantsIndex[TArray] || 
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
		break;
		//3333333333333333333333333333333333
		//SUITS!
		//----------------------------------
		case 'GM_Suit':
		case 'VMDGM_Suit':
		case 'GM_SuitLeft':
			CoatLabel.SetText(SuitCoatLabel);
			LensesLabel.SetText(SuitLensesLabel);
			FramesLabel.SetText(SuitFramesLabel);
			ChestLabel.SetText(ChestLabelText);
			PantsLabel.SetText(PantsLabelText);
			
			ChestUse = SuitShirtTexs[CurSuitShirtIndex];
			
			PantsUse = TrenchPantsTexs[CurSuitPantsIndex];
			if (CurSuitPantsIndex == 29)
			{
				if ((CurMaleSkinIndex % 5 != 0) && (CurMaleSkinIndex % 5 != 3))
				{
					bPantsUnavailable = true;
					PantsUse = Texture'PantsTex3';
				}
			}
			
			LensesUse = TrenchLensesTexs[CurSuitLensesIndex];
			FramesUse = TrenchFramesTexs[CurSuitFramesIndex];
			if (FramesUse == Texture'GrayMaskTex') LensesUse = Texture'BlackMaskTex';
			
			Dud.Multiskins[0] = MaleSkinTexs[CurMaleSkinIndex];
			Dud.Multiskins[2] = MaleSkinTexs[CurMaleSkinIndex];
			
			Dud.Multiskins[1] = PantsUse;
			Dud.Multiskins[6] = LensesUse;
			Dud.Multiskins[5] = FramesUse;
			Dud.Multiskins[4] = ChestUse;
			Dud.Multiskins[3] = ChestUse;
			
			Dud.Multiskins[7] = Texture'PinkMaskTex';
			
			LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
			FramesEntry.SetText(DeriveHumanName(string(FramesUse)));
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			CoatEntry.SetText(StrUnavailable);
			
			//Pants exceptions
			PantsEntry.SetText(DeriveHumanName(string(PantsUse)));
			if (bPantsUnavailable) PantsEntry.SetText(StrUnavailable);
			
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
					if (CurSuitLensesIndex != VMP.FaveMaleLensIndex[TArray] || 
						CurSuitFramesIndex != VMP.FaveMaleFramesIndex[TArray] || 
						CurSuitShirtIndex != VMP.FaveMaleChestIndex[TArray] || 
						//CurTrenchCoatIndex != VMP.FaveMaleCoatIndex[TArray] || 
						CurSuitPantsIndex != VMP.FaveMalePantsIndex[TArray] || 
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
		break;
		//4444444444444444444444444444444444
		//DRESS SHIRTS!
		//----------------------------------
		case 'GM_DressShirt_S':
		case 'GM_DressShirt':
		case 'GM_DressShirt_F':
		case 'VMDGM_DressShirt_S':
		case 'VMDGM_DressShirt':
		case 'VMDGM_DressShirt_F':
		case 'GM_DressShirt_SLeft':
		case 'GM_DressShirtLeft':
		case 'GM_DressShirt_FLeft':
			CoatLabel.SetText(DressShirtCoatLabel);
			LensesLabel.SetText(DressShirtLensesLabel);
			FramesLabel.SetText(DressShirtFramesLabel);
			ChestLabel.SetText(ChestLabelText);
			PantsLabel.SetText(PantsLabelText);
			
			ChestUse = DressShirtShirtTexs[CurDressShirtShirtIndex];
			
			PantsUse = TrenchPantsTexs[CurDressShirtPantsIndex];
			if (CurTrenchPantsIndex == 29)
			{
				if ((CurMaleSkinIndex % 5 != 0) && (CurMaleSkinIndex % 5 != 3))
				{
					bPantsUnavailable = true;
					PantsUse = Texture'PantsTex3';
				}
			}
			
			LensesUse = TrenchLensesTexs[CurDressShirtLensesIndex];
			FramesUse = TrenchFramesTexs[CurDressShirtFramesIndex];
			if (FramesUse == Texture'GrayMaskTex') LensesUse = Texture'BlackMaskTex';
			
			Dud.Multiskins[0] = MaleSkinTexs[CurMaleSkinIndex];
			Dud.Multiskins[4] = MaleSkinTexs[CurMaleSkinIndex];
			
			Dud.Multiskins[3] = PantsUse;
			Dud.Multiskins[7] = LensesUse;
			Dud.Multiskins[6] = FramesUse;
			Dud.Multiskins[5] = ChestUse;
			
			Dud.Multiskins[1] = Texture'PinkMaskTex';
			Dud.Multiskins[2] = Texture'PinkMaskTex';
			
			LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
			FramesEntry.SetText(DeriveHumanName(string(FramesUse)));
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			CoatEntry.SetText(StrUnavailable);
			
			//Pants exceptions
			PantsEntry.SetText(DeriveHumanName(string(PantsUse)));
			if (bPantsUnavailable) PantsEntry.SetText(StrUnavailable);
			
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
					if (CurDressShirtLensesIndex != VMP.FaveMaleLensIndex[TArray] || 
						CurDressShirtFramesIndex != VMP.FaveMaleFramesIndex[TArray] || 
						CurDressShirtShirtIndex != VMP.FaveMaleChestIndex[TArray] || 
						//CurTrenchCoatIndex != VMP.FaveMaleCoatIndex[TArray] || 
						CurDressShirtPantsIndex != VMP.FaveMalePantsIndex[TArray] || 
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
		break;
		//5555555555555555555555555555555555
		//SKIRTS!
		//----------------------------------
		case 'GFM_SuitSkirt':
		case 'VMDGFM_SuitSkirt':
		case 'GFM_SuitSkirt_F':
		case 'VMDGFM_SuitSkirt_F':
		case 'GFM_SuitSkirtLeft':
		case 'GFM_SuitSkirt_FLeft':
			CoatLabel.SetText(SuitSkirtCoatLabel);
			LensesLabel.SetText(SuitSkirtLensesLabel);
			FramesLabel.SetText(SuitSkirtFramesLabel);
			ChestLabel.SetText(SuitSkirtShirtLabel);
			PantsLabel.SetText(SuitSkirtPantsLabel);
			
			ChestUse = SuitSkirtShirtTexs[CurSuitSkirtShirtIndex];
			PantsUse = SuitSkirtShirtTexs[CurSuitSkirtShirtIndex];
			
			LensesUse = TrenchLensesTexs[CurSuitSkirtLensesIndex];
			FramesUse = TrenchFramesTexs[CurSuitSkirtFramesIndex];
			if (FramesUse == Texture'GrayMaskTex') LensesUse = Texture'BlackMaskTex';
			
			Dud.Multiskins[0] = FemaleSkinTexs[CurFemaleSkinIndex];
			Dud.Multiskins[2] = FemaleSkinTexs[CurFemaleSkinIndex];
			
			if (CurSuitSkirtHairIndex == 0)
			{
				Dud.Multiskins[1] = Texture'PinkMaskTex';
			}
			else if (CurSuitSkirtHairIndex == 1)
			{
				Dud.Multiskins[1] = FemaleSkinTexs[CurFemaleSkinIndex];
			}
			
			Dud.Multiskins[3] = Texture'JCDentonFemaleSkirtLegs';
			
			Dud.Multiskins[7] = LensesUse;
			Dud.Multiskins[6] = FramesUse;
			Dud.Multiskins[5] = PantsUse;
			Dud.Multiskins[4] = ChestUse;
			
			CoatEntry.SetText(SuitSkirtHairNames[CurSuitSkirtHairIndex]);
			LensesEntry.SetText(DeriveHumanName(string(LensesUse)));
			FramesEntry.SetText(DeriveHumanName(string(FramesUse)));
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			//Pants exceptions
			PantsEntry.SetText(StrUnavailable);
			
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
					if (CurSuitSkirtLensesIndex != VMP.FaveFemaleLensIndex[TArray] || 
						CurSuitSkirtFramesIndex != VMP.FaveFemaleFramesIndex[TArray] || 
						CurSuitSkirtShirtIndex != VMP.FaveFemaleChestIndex[TArray] || 
						CurSuitSkirtHairIndex != VMP.FaveFemaleCoatIndex[TArray] || 
						//CurTrenchPantsIndex != VMP.FaveFemalePantsIndex[TArray] || 
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
		break;
		//6666666666666666666666666666666666
		//DRESSES!
		//----------------------------------
		case 'VMDGFM_Dress':
		case 'VMDGFM_DressLeft':
			CoatLabel.SetText(DressCoatLabel);
			LensesLabel.SetText(DressLensesLabel);
			FramesLabel.SetText(DressFramesLabel);
			ChestLabel.SetText(DressShirtLabel);
			PantsLabel.SetText(DressPantsLabel);
			
			ChestUse = DressShirtTexs[CurDressShirtIndex];
			PantsUse = DressSkirtTexs[CurDressShirtIndex];
			
			Dud.Multiskins[0] = FemaleSkinTexs[CurFemaleSkinIndex];
			Dud.Multiskins[7] = FemaleSkinTexs[CurFemaleSkinIndex];
			
			if (CurDressHairIndex == 0 || CurDressHairIndex == 2)
			{
				Dud.Multiskins[6] = Texture'PinkMaskTex';
			}
			else if (CurDressHairIndex == 1 || CurDressHairIndex == 3)
			{
				Dud.Multiskins[6] = FemaleSkinTexs[CurFemaleSkinIndex];
			}
			
			if (CurDressHairIndex < 2)
			{
				Dud.Multiskins[5] = Texture'PinkMaskTex';
			}
			else if (CurDressHairIndex >= 2)
			{
				Dud.Multiskins[5] = FemaleSkinTexs[CurFemaleSkinIndex];
			}
			
			Dud.Multiskins[1] = Texture'JCDentonFemaleSkirtLegs';
			
			Dud.Multiskins[3] = ChestUse;
			Dud.Multiskins[2] = PantsUse;
			Dud.Multiskins[4] = PantsUse;
			
			CoatEntry.SetText(DressHairNames[CurDressHairIndex]);
			LensesEntry.SetText(StrUnavailable);
			FramesEntry.SetText(StrUnavailable);
			
			//Chest exceptions
			ChestEntry.SetText(DeriveHumanName(string(ChestUse)));
			if (bChestUnavailable) ChestEntry.SetText(StrUnavailable);
			
			//Pants exceptions
			PantsEntry.SetText(StrUnavailable);
			
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
					if (CurDressShirtIndex != VMP.FaveFemaleChestIndex[TArray] || 
						CurDressHairIndex != VMP.FaveFemaleCoatIndex[TArray] || 
						//CurTrenchPantsIndex != VMP.FaveFemalePantsIndex[TArray] || 
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
		break;
	}
	
	if (HandednessEntry != None)
	{
		HandednessEntry.SetText(HandednessNames[CurHandednessIndex]);
	}
	
	if (ButtonSkinNext == None)
	{
		VMP.DefabricatePlayerAppearance();
	}
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
}

// ----------------------------------------------------------------------
// CreateNameEditWindow()
// ----------------------------------------------------------------------

function CreateNameEditWindow()
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
	if (ButtonSkinPrev != None)
	{
		ButtonSkinPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	if (ButtonSkinNext != None)
	{
		ButtonSkinNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
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
	if (ButtonHandednessPrev != None)
	{
		ButtonHandednessPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	if (ButtonHandednessNext != None)
	{
		ButtonHandednessNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
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
// TextChanged() 
// ----------------------------------------------------------------------

event bool TextChanged(window edit, bool bModified)
{
	EnableButtons();

	return false;
}

function LoadMalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	CurMaleMeshIndex = VMP.FaveMaleMeshIndex[TArray];
	CurMaleSkinIndex = VMP.FaveMaleSkinIndex[TArray];
	
	switch(CurMaleMeshIndex)
	{
		case 0: //Trenchcoat
		case 1:
			CurTrenchLensesIndex = VMP.FaveMaleLensIndex[TArray];
			CurTrenchFramesIndex = VMP.FaveMaleFramesIndex[TArray];
			CurTrenchChestIndex = VMP.FaveMaleChestIndex[TArray];
			CurTrenchCoatIndex = VMP.FaveMaleCoatIndex[TArray];
			CurTrenchPantsIndex = VMP.FaveMalePantsIndex[TArray];
		break;
		case 2: //Jumpsuit
			CurJumpsuitVisorIndex = VMP.FaveMaleLensIndex[TArray];
			CurJumpsuitShirtIndex = VMP.FaveMaleChestIndex[TArray];
			CurJumpsuitHelmetIndex = VMP.FaveMaleCoatIndex[TArray];
			CurJumpsuitPantsIndex = VMP.FaveMalePantsIndex[TArray];
		break;
		case 3: //Suit
			CurSuitLensesIndex = VMP.FaveMaleLensIndex[TArray];
			CurSuitFramesIndex = VMP.FaveMaleFramesIndex[TArray];
			CurSuitShirtIndex = VMP.FaveMaleChestIndex[TArray];
			CurSuitPantsIndex = VMP.FaveMalePantsIndex[TArray];
		break;
		case 4: //Dress shirt
		case 5:
		case 6:
			CurDressShirtLensesIndex = VMP.FaveMaleLensIndex[TArray];
			CurDressShirtFramesIndex = VMP.FaveMaleFramesIndex[TArray];
			CurDressShirtShirtIndex = VMP.FaveMaleChestIndex[TArray];
			CurDresSShirtPantsIndex = VMP.FaveMalePantsIndex[TArray];
		break;
	}
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function SaveMalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	VMP.FaveMaleMeshIndex[TArray] = CurMaleMeshIndex;
	VMP.FaveMaleSkinIndex[TArray] = CurMaleSkinIndex;
	
	switch(CurMaleMeshIndex)
	{
		case 0: //Trenchcoat
		case 1:
			VMP.FaveMaleLensIndex[TArray] = CurTrenchLensesIndex;
			VMP.FaveMaleFramesIndex[TArray] = CurTrenchFramesIndex;
			VMP.FaveMaleChestIndex[TArray] = CurTrenchChestIndex;
			VMP.FaveMaleCoatIndex[TArray] = CurTrenchCoatIndex;
			VMP.FaveMalePantsIndex[TArray] = CurTrenchPantsIndex;
		break;
		case 2: //Jumpsuit
			VMP.FaveMaleLensIndex[TArray] = CurJumpsuitVisorIndex;
			VMP.FaveMaleChestIndex[TArray] = CurJumpsuitShirtIndex;
			VMP.FaveMaleCoatIndex[TArray] = CurJumpsuitHelmetIndex;
			VMP.FaveMalePantsIndex[TArray] = CurJumpsuitPantsIndex;
		break;
		case 3: //Suit
			VMP.FaveMaleLensIndex[TArray] = CurSuitLensesIndex;
			VMP.FaveMaleFramesIndex[TArray] = CurSuitFramesIndex;
			VMP.FaveMaleChestIndex[TArray] = CurSuitShirtIndex;
			VMP.FaveMalePantsIndex[TArray] = CurSuitPantsIndex;
		break;
		case 4: //Dress shirt
		case 5:
		case 6:
			VMP.FaveMaleLensIndex[TArray] = CurDressShirtLensesIndex;
			VMP.FaveMaleFramesIndex[TArray] = CurDressShirtFramesIndex;
			VMP.FaveMaleChestIndex[TArray] = CurDressShirtShirtIndex;
			VMP.FaveMalePantsIndex[TArray] = CurDresSShirtPantsIndex;
		break;
	}
	
	Player.SaveConfig();
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function LoadFemalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	CurFemaleMeshIndex = VMP.FaveFemaleMeshIndex[TArray];
	CurFemaleSkinIndex = VMP.FaveFemaleSkinIndex[TArray];
	
	switch(CurFemaleMeshIndex)
	{
		case 0: //Trenchcoat
			CurTrenchLensesIndex = VMP.FaveFemaleLensIndex[TArray];
			CurTrenchFramesIndex = VMP.FaveFemaleFramesIndex[TArray];
			CurTrenchChestIndex = VMP.FaveFemaleChestIndex[TArray];
			CurTrenchCoatIndex = VMP.FaveFemaleCoatIndex[TArray];
			CurTrenchPantsIndex = VMP.FaveFemalePantsIndex[TArray];
		case 1: //Skirt
		case 2:
			CurSuitSkirtLensesIndex = VMP.FaveFemaleLensIndex[TArray];
			CurSuitSkirtFramesIndex = VMP.FaveFemaleFramesIndex[TArray];
			CurSuitSkirtShirtIndex = VMP.FaveFemaleChestIndex[TArray];
			CurSuitSkirtHairIndex = VMP.FaveFemaleCoatIndex[TArray];
		break;
		case 3: //Dress
			CurDressShirtIndex = VMP.FaveFemaleChestIndex[TArray];
			CurDressHairIndex = VMP.FaveFemaleCoatIndex[TArray];
		break;
	}
	
	SavePresetButton.SetSensitivity(False);
	LoadPresetButton.SetSensitivity(False);
}

function SaveFemalePreset(int TArray)
{
	if (VMP == None) return;
	if (SavePresetButton == None) return;
	
	VMP.FaveFemaleMeshIndex[TArray] = CurFemaleMeshIndex;
	VMP.FaveFemaleSkinIndex[TArray] = CurFemaleSkinIndex;
	
	switch(CurFemaleMeshIndex)
	{
		case 0: //Trenchcoat
			VMP.FaveFemaleLensIndex[TArray] = CurTrenchLensesIndex;
			VMP.FaveFemaleFramesIndex[TArray] = CurTrenchFramesIndex;
			VMP.FaveFemaleChestIndex[TArray] = CurTrenchChestIndex;
			VMP.FaveFemaleCoatIndex[TArray] = CurTrenchCoatIndex;
			VMP.FaveFemalePantsIndex[TArray] = CurTrenchPantsIndex;
		case 1: //Skirt
		case 2:
			VMP.FaveFemaleLensIndex[TArray] = CurSuitSkirtLensesIndex;
			VMP.FaveFemaleFramesIndex[TArray] = CurSuitSkirtFramesIndex;
			VMP.FaveFemaleChestIndex[TArray] = CurSuitSkirtShirtIndex;
			VMP.FaveFemaleCoatIndex[TArray] = CurSuitSkirtHairIndex;
		break;
		case 3: //Dress
			VMP.FaveFemaleChestIndex[TArray] = CurDressShirtIndex;
			VMP.FaveFemaleCoatIndex[TArray] = CurDressHairIndex;
		break;
	}
	
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
	CurFemaleMeshIndex = Rand(MaxFemaleMeshIndex+1);
	
	TRand = Rand(MaxMaleSkinIndex+1-DDSFat);
	CurMaleSkinIndex = TRand;
	CurFemaleSkinIndex = TRand;
	
	CurTrenchLensesIndex = Rand(MaxTrenchLensesIndex+1-DDSFat);
	CurTrenchFramesIndex = Rand(MaxTrenchFramesIndex+1-DDSFat);
	CurTrenchChestIndex = Rand(MaxTrenchChestIndex+1-DDSFat);
	CurTrenchCoatIndex = Rand(MaxTrenchCoatIndex+1-DDSFat);
	CurTrenchPantsIndex = Rand(MaxTrenchPantsIndex+1-DDSFat);
	
	CurJumpsuitShirtIndex = Rand(MaxJumpsuitShirtIndex+1);
	CurJumpsuitPantsIndex = Rand(MaxTrenchPantsIndex+1-DDSFat);
	CurJumpsuitHelmetIndex = Rand(MaxJumpsuitHelmetIndex+1);
	CurJumpsuitVisorIndex = Rand(MaxJumpsuitVisorIndex+1);
	
	CurSuitLensesIndex = Rand(MaxTrenchLensesIndex+1-DDSFat);
	CurSuitFramesIndex = Rand(MaxTrenchFramesIndex+1-DDSFat);
	CurSuitShirtIndex = Rand(MaxSuitShirtIndex+1);
	CurSuitPantsIndex = Rand(MaxTrenchPantsIndex+1-DDSFat);
	
	CurDressShirtLensesIndex = Rand(MaxTrenchLensesIndex+1-DDSFat);
	CurDressShirtFramesIndex = Rand(MaxTrenchFramesIndex+1-DDSFat);
	CurDressShirtShirtIndex = Rand(MaxDressShirtShirtIndex+1);
	curDressShirtPantsIndex = Rand(MaxTrenchPantsIndex+1-DDSFat);
	
	CurSuitSkirtLensesIndex = Rand(MaxTrenchLensesIndex+1-DDSFat);
	CurSuitSkirtFramesIndex = Rand(MaxTrenchFramesIndex+1-DDSFat);
	CurSuitSkirtShirtIndex = Rand(MaxSuitSkirtShirtIndex+1);
	CurSuitSkirtHairIndex = Rand(MaxSuitSkirtHairIndex+1);
	
	CurDressShirtIndex = Rand(MaxDressShirtIndex+1);
	CurDressHairIndex = Rand(MaxDressHairIndex+1);
	
	CurHandednessIndex = Rand(2);
	
	UpdatePlayerAppearance();
}

function EnableButtons()
{
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled, TFemale;
	local int i, FMesh, MMesh;
	
	bHandled = True;
	
	TFemale = bFemale;
	FMesh = CurFemaleMeshIndex;
	MMesh = CurMaleMeshIndex;
	
	//Hack for detecting child classes reliably.
	if (ButtonSkinNext == None)
	{
		TFemale = VMP.bAssignedFemale;
		for(i=0; i<ArrayCount(MaleMeshes); i++)
		{
			if (VMP.Mesh == MaleMeshes[i] || VMP.Mesh == MaleLeftMeshes[i])
			{
				CurMaleMeshIndex = i;
				MMesh = i;
				break;
			}
		}
		for(i=0; i<ArrayCount(FemaleMeshes); i++)
		{
			if (VMP.Mesh == FemaleMeshes[i] || VMP.Mesh == FemaleLeftMeshes[i])
			{
				CurFemaleMeshIndex = i;
				FMesh = i;
				break;
			}
		}
	}
	
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
			if (TFemale)
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
			if (TFemale)
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
			if (TFemale)
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
			if (TFemale)
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
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchLensesIndex--;
						if (CurTrenchLensesIndex < 0) CurTrenchLensesIndex = MaxTrenchLensesIndex;
					break;
					case 1:
					case 2:
						CurSuitSkirtLensesIndex--;
						if (CurSuitSkirtLensesIndex < 0) CurSuitSkirtLensesIndex = MaxTrenchLensesIndex;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchLensesIndex--;
						if (CurTrenchLensesIndex < 0) CurTrenchLensesIndex = MaxTrenchLensesIndex;
					break;
					case 2:
						CurJumpsuitVisorIndex--;
						if (CurJumpsuitVisorIndex < 0) CurJumpsuitVisorIndex = MaxJumpsuitVisorIndex;
					break;
					case 3:
						CurSuitLensesIndex--;
						if (CurSuitLensesIndex < 0) CurSuitLensesIndex = MaxTrenchLensesIndex;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtLensesIndex--;
						if (CurDressShirtLensesIndex < 0) CurDressShirtLensesIndex = MaxTrenchLensesIndex;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonLensesNext:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchLensesIndex++;
						if (CurTrenchLensesIndex > MaxTrenchLensesIndex) CurTrenchLensesIndex = 0;
					break;
					case 1:
					case 2:
						CurSuitSkirtLensesIndex++;
						if (CurSuitSkirtLensesIndex > MaxTrenchLensesIndex) CurSuitSkirtLensesIndex = 0;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchLensesIndex++;
						if (CurTrenchLensesIndex > MaxTrenchLensesIndex) CurTrenchLensesIndex = 0;
					break;
					case 2:
						CurJumpsuitVisorIndex++;
						if (CurJumpsuitVisorIndex > MaxJumpsuitVisorIndex) CurJumpsuitVisorIndex = 0;
					break;
					case 3:
						CurSuitLensesIndex++;
						if (CurSuitLensesIndex > MaxTrenchLensesIndex) CurSuitLensesIndex = 0;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtLensesIndex++;
						if (CurDressShirtLensesIndex > MaxTrenchLensesIndex) CurDressShirtLensesIndex = 0;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonFramesPrev:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchFramesIndex--;
						if (CurTrenchFramesIndex < 0) CurTrenchFramesIndex = MaxTrenchFramesIndex;
					break;
					case 1:
					case 2:
						CurSuitSkirtFramesIndex--;
						if (CurSuitSkirtFramesIndex < 0) CurSuitSkirtFramesIndex = MaxTrenchFramesIndex;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchFramesIndex--;
						if (CurTrenchFramesIndex < 0) CurTrenchFramesIndex = MaxTrenchFramesIndex;
					break;
					case 3:
						CurSuitFramesIndex--;
						if (CurSuitFramesIndex < 0) CurSuitFramesIndex = MaxTrenchFramesIndex;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtFramesIndex--;
						if (CurDressShirtFramesIndex < 0) CurDressShirtFramesIndex = MaxTrenchFramesIndex;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonFramesNext:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchFramesIndex++;
						if (CurTrenchFramesIndex > MaxTrenchFramesIndex) CurTrenchFramesIndex = 0;
					break;
					case 1:
					case 2:
						CurSuitSkirtFramesIndex++;
						if (CurSuitSkirtFramesIndex > MaxTrenchFramesIndex) CurSuitSkirtFramesIndex = 0;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchFramesIndex++;
						if (CurTrenchFramesIndex > MaxTrenchFramesIndex) CurTrenchFramesIndex = 0;
					break;
					case 3:
						CurSuitFramesIndex++;
						if (CurSuitFramesIndex > MaxTrenchFramesIndex) CurSuitFramesIndex = 0;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtFramesIndex++;
						if (CurDressShirtFramesIndex > MaxTrenchFramesIndex) CurDressShirtFramesIndex = 0;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonChestPrev:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchChestIndex--;
						if (CurTrenchChestIndex < 0) CurTrenchChestIndex = MaxTrenchChestIndex;
					break;
					case 1:
					case 2:
						CurSuitSkirtShirtIndex--;
						if (CurSuitSkirtShirtIndex < 0) CurSuitSkirtShirtIndex = MaxSuitSkirtShirtIndex;
					break;
					case 3:
						CurDressShirtIndex--;
						if (CurDressShirtIndex < 0) CurDressShirtIndex = MaxDressShirtIndex;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchChestIndex--;
						if (CurTrenchChestIndex < 0) CurTrenchChestIndex = MaxTrenchChestIndex;
					break;
					case 2:
						CurJumpsuitShirtIndex--;
						if (CurJumpsuitShirtIndex < 0) CurJumpsuitShirtIndex = MaxJumpsuitShirtIndex;
					break;
					case 3:
						CurSuitShirtIndex--;
						if (CurSuitShirtIndex < 0) CurSuitShirtIndex = MaxSuitShirtIndex;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtShirtIndex--;
						if (CurDressShirtShirtIndex < 0) CurDressShirtShirtIndex = MaxDressShirtShirtIndex;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonChestNext:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchChestIndex++;
						if (CurTrenchChestIndex > MaxTrenchChestIndex) CurTrenchChestIndex = 0;
					break;
					case 1:
					case 2:
						CurSuitSkirtShirtIndex++;
						if (CurSuitSkirtShirtIndex > MaxSuitSkirtShirtIndex) CurSuitSkirtShirtIndex = 0;
					break;
					case 3:
						CurDressShirtIndex++;
						if (CurDressShirtIndex > MaxDressShirtIndex) CurDressShirtIndex = 0;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchChestIndex++;
						if (CurTrenchChestIndex > MaxTrenchChestIndex) CurTrenchChestIndex = 0;
					break;
					case 2:
						CurJumpsuitShirtIndex++;
						if (CurJumpsuitShirtIndex > MaxJumpsuitShirtIndex) CurJumpsuitShirtIndex = 0;
					break;
					case 3:
						CurSuitShirtIndex++;
						if (CurSuitShirtIndex > MaxSuitShirtIndex) CurSuitShirtIndex = 0;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtShirtIndex++;
						if (CurDressShirtShirtIndex > MaxDressShirtShirtIndex) CurDressShirtShirtIndex = 0;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonCoatPrev:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchCoatIndex--;
						if (CurTrenchCoatIndex < 0) CurTrenchCoatIndex = MaxTrenchCoatIndex;
					break;
					case 1:
					case 2:
						CurSuitSkirtHairIndex--;
						if (CurSuitSkirtHairIndex < 0) CurSuitSkirtHairIndex = MaxSuitSkirtHairIndex;
					break;
					case 3:
						CurDressHairIndex--;
						if (CurDressHairIndex < 0) CurDressHairIndex = MaxDressHairIndex;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchCoatIndex--;
						if (CurTrenchCoatIndex < 0) CurTrenchCoatIndex = MaxTrenchCoatIndex;
					break;
					case 2:
						CurJumpsuitHelmetIndex--;
						if (CurJumpsuitHelmetIndex < 0) CurJumpsuitHelmetIndex = MaxJumpsuitHelmetIndex;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonCoatNext:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchCoatIndex++;
						if (CurTrenchCoatIndex > MaxTrenchCoatIndex) CurTrenchCoatIndex = 0;
					break;
					case 1:
					case 2:
						CurSuitSkirtHairIndex++;
						if (CurSuitSkirtHairIndex > MaxSuitSkirtHairIndex) CurSuitSkirtHairIndex = 0;
					break;
					case 3:
						CurDressHairIndex++;
						if (CurDressHairIndex > MaxDressHairIndex) CurDressHairIndex = 0;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchCoatIndex++;
						if (CurTrenchCoatIndex > MaxTrenchCoatIndex) CurTrenchCoatIndex = 0;
					break;
					case 2:
						CurJumpsuitHelmetIndex++;
						if (CurJumpsuitHelmetIndex > MaxJumpsuitHelmetIndex) CurJumpsuitHelmetIndex = 0;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonPantsPrev:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchPantsIndex--;
						if (CurTrenchPantsIndex < 0) CurTrenchPantsIndex = MaxTrenchPantsIndex;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchPantsIndex--;
						if (CurTrenchPantsIndex < 0) CurTrenchPantsIndex = MaxTrenchPantsIndex;
					break;
					case 2:
						CurJumpsuitPantsIndex--;
						if (CurJumpsuitPantsIndex < 0) CurJumpsuitPantsIndex = MaxTrenchPantsIndex;
					break;
					case 3:
						CurSuitPantsIndex--;
						if (CurSuitPantsIndex < 0) CurSuitPantsIndex = MaxTrenchPantsIndex;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtPantsIndex--;
						if (CurDressShirtPantsIndex < 0) CurDressShirtPantsIndex = MaxTrenchPantsIndex;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		case ButtonPantsNext:
			if (TFemale)
			{
				switch(FMesh)
				{
					case 0:
						CurTrenchPantsIndex++;
						if (CurTrenchPantsIndex > MaxTrenchPantsIndex) CurTrenchPantsIndex = 0;
					break;
				}
			}
			else
			{
				switch(MMesh)
				{
					case 0:
					case 1:
						CurTrenchPantsIndex++;
						if (CurTrenchPantsIndex > MaxTrenchPantsIndex) CurTrenchPantsIndex = 0;
					break;
					case 2:
						CurJumpsuitPantsIndex++;
						if (CurJumpsuitPantsIndex > MaxTrenchPantsIndex) CurJumpsuitPantsIndex = 0;
					break;
					case 3:
						CurSuitPantsIndex++;
						if (CurSuitPantsIndex > MaxTrenchPantsIndex) CurSuitPantsIndex = 0;
					break;
					case 4:
					case 5:
					case 6:
						CurDressShirtPantsIndex++;
						if (CurDressShirtPantsIndex > MaxTrenchPantsIndex) CurDressShirtPantsIndex = 0;
					break;
				}
			}
			UpdatePlayerAppearance();
		break;
		
		case ButtonPresetPrev:
			if (TFemale)
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
			if (TFemale)
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
			if (TFemale)
			{
				if (CurFemalePresetIndex > 0) SaveFemalePreset(CurFemalePresetIndex-1);
			}
			else
			{
				if (CurMalePresetIndex > 0) SaveMalePreset(CurMalePresetIndex-1);	
			}
		break;
		case LoadPresetButton:
			if (TFemale)
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

defaultproperties
{
     bHackUpdateRequired=True
     GenderLabelText="Gender:"
     MeshLabelText="Style:"
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
     
     MaleMeshes(0)=LODMesh'GM_Trench'
     MaleMeshes(1)=LODMesh'VMDGM_Trench_F'
     MaleMeshes(2)=LODMesh'VMDMP_Jumpsuit'
     MaleMeshes(3)=LODMesh'VMDGM_Suit'
     MaleMeshes(4)=LODMesh'VMDGM_DressShirt_S'
     MaleMeshes(5)=LODMesh'VMDGM_DressShirt'
     MaleMeshes(6)=LODMesh'VMDGM_DressShirt_F'
     MaleLeftMeshes(0)=LODMesh'GM_TrenchLeft'
     MaleLeftMeshes(1)=LODMesh'GM_Trench_FLeft'
     MaleLeftMeshes(2)=LODMesh'MP_JumpsuitLeft'
     MaleLeftMeshes(3)=LODMesh'GM_SuitLeft'
     MaleLeftMeshes(4)=LODMesh'GM_DressShirt_SLeft'
     MaleLeftMeshes(5)=LODMesh'GM_DressShirtLeft'
     MaleLeftMeshes(6)=LODMesh'GM_DressShirt_FLeft'
     
     MaxMaleMeshIndex=6
     FemaleMeshes(0)=LODMesh'VMDGFM_Trench'
     FemaleMeshes(1)=LODMesh'VMDGFM_SuitSkirt'
     FemaleMeshes(2)=LODMesh'VMDGFM_SuitSkirt_F'
     FemaleMeshes(3)=LODMesh'VMDGFM_Dress'
     FemaleLeftMeshes(0)=LODMesh'GFM_TrenchLeft'
     FemaleLeftMeshes(1)=LODMesh'GFM_SuitSkirtLeft'
     FemaleLeftMeshes(2)=LODMesh'GFM_SuitSkirt_FLeft'
     FemaleLeftMeshes(3)=LODMesh'VMDGFM_DressLeft'
     
     MaxFemaleMeshIndex=3
     
     StrUnavailable="(Unavailable)"
     
     HandednessNames(0)="Right Handed"
     HandednessNames(1)="Left Handed"
     
     GenderNames(0)="Male"
     GenderNames(1)="Female"
     
     MaleMeshNames(0)="Coat"
     MaleMeshNames(1)="Heavy Coat"
     MaleMeshNames(2)="Jumpsuit"
     MaleMeshNames(3)="Suit"
     MaleMeshNames(4)="Skinny Casual"
     MaleMeshNames(5)="Casual"
     MaleMeshNames(6)="Heavy Casual"
     FemaleMeshNames(0)="Coat"
     FemaleMeshNames(1)="Skirt"
     FemaleMeshNames(2)="Heavy Skirt"
     FemaleMeshNames(3)="Long Skirt"
     
     MaxGenderIndex=1
     
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
     
     MaleSkinNames(0)="Brunet"
     MaleSkinNames(1)="Black"
     MaleSkinNames(2)="Brown"
     MaleSkinNames(3)="Ginger"
     MaleSkinNames(4)="Albino"
     MaleSkinNames(5)="DDS Slot 1"
     MaleSkinNames(6)="DDS Slot 2"
     MaleSkinNames(7)="DDS Slot 3"
     MaleSkinNames(8)="DDS Slot 4"
     MaleSkinNames(9)="DDS Slot 5"
     FemaleSkinNames(0)="Brunette"
     FemaleSkinNames(1)="Black"
     FemaleSkinNames(2)="Brown"
     FemaleSkinNames(3)="Ginger"
     FemaleSkinNames(4)="Albino"
     FemaleSkinNames(5)="DDS Slot 1"
     FemaleSkinNames(6)="DDS Slot 2"
     FemaleSkinNames(7)="DDS Slot 3"
     FemaleSkinNames(8)="DDS Slot 4"
     FemaleSkinNames(9)="DDS Slot 5"
     
     NihilumSkinNames(0)="Goatee"
     NihilumSkinNames(1)="Plain"
     NihilumSkinNames(2)="Silver"
     HiveDaysSkinNames(0)="Style 1"
     HiveDaysSkinNames(1)="Style 2"
     HiveDaysSkinNames(2)="Style 3"
     
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
     
     JumpsuitCoatLabel="Headware:"
     JumpsuitLensesLabel="Visor:"
     JumpsuitFramesLabel="Frames:"
     
     JumpsuitShirtTexs(0)=Texture'VMDNSFBountyHunter2Shirt01'
     JumpsuitShirtTexs(1)=Texture'VMDNSFBountyHunter2Shirt02'
     JumpsuitShirtTexs(2)=Texture'VMDNSFBountyHunter2Shirt03'
     JumpsuitShirtTexs(3)=Texture'VMDNSFBountyHunter2Shirt04'
     JumpsuitShirtTexs(4)=Texture'VMDNSFBountyHunter2Shirt05'
     //JumpsuitShirtTexs(5)=Texture'DeusExCharacters.Skins.HKMilitaryTex1'
     JumpsuitShirtTexs(5)=Texture'DeusExCharacters.Skins.JanitorTex1'
     //JumpsuitShirtTexs(6)=Texture'DeusExCharacters.Skins.Male4Tex1'
     JumpsuitShirtTexs(6)=Texture'DeusExCharacters.Skins.MechanicTex1'
     JumpsuitShirtTexs(7)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
     JumpsuitShirtTexs(8)=Texture'DeusExCharacters.Skins.RiotCopTex2'
     //JumpsuitShirtTexs(9)=Texture'DeusExCharacters.Skins.SamCarterTex1'
     JumpsuitShirtTexs(9)=Texture'DeusExCharacters.Skins.SoldierTex1'
     JumpsuitShirtTexs(10)=Texture'DeusExCharacters.Skins.TerroristTex1'
     JumpsuitShirtTexs(11)=Texture'DeusExCharacters.Skins.TracerTongTex1'
     JumpsuitShirtTexs(12)=Texture'DeusExCharacters.Skins.UNATCOTroopTex2'
     MaxJumpsuitShirtIndex=12
     
     JumpsuitHelmetTexs(0)=Texture'PinkMaskTex'
     JumpsuitHelmetTexs(1)=Texture'DeusExCharacters.Skins.GogglesTex1'
     JumpsuitHelmetTexs(2)=Texture'VMDGogglesTex2'
     JumpsuitHelmetTexs(3)=Texture'VMDGogglesTex3'
     JumpsuitHelmetTexs(4)=Texture'VMDGogglesTex4'
     JumpsuitHelmetTexs(5)=Texture'VMDGogglesTex5'
     JumpsuitHelmetTexs(6)=Texture'DeusExCharacters.Skins.MechanicTex3'
     //JumpsuitHelmetTexs(7)=Texture'VMDMJ12TroopTex4'
     JumpsuitHelmetTexs(7)=Texture'DeusExCharacters.Skins.RiotCopTex3'
     JumpsuitHelmetTexs(8)=Texture'DeusExCharacters.Skins.SoldierTex3'
     JumpsuitHelmetTexs(9)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
     MaxJumpsuitHelmetIndex=9
     
     JumpsuitVisorTexs(0)=Texture'PinkMaskTex'
     JumpsuitVisorTexs(1)=Texture'DeusExCharacters.Skins.VisorTex1'
     MaxJumpsuitVisorIndex=1
     
     SuitCoatLabel="Coat:"
     SuitLensesLabel="Lenses:"
     SuitFramesLabel="Frames:"
     
     SuitShirtTexs(0)=Texture'DeusExCharacters.Skins.BobPageTex1'
     SuitShirtTexs(1)=Texture'DeusExCharacters.Skins.Businessman1Tex1'
     SuitShirtTexs(2)=Texture'DeusExCharacters.Skins.Businessman2Tex1'
     SuitShirtTexs(3)=Texture'DeusExCharacters.Skins.Businessman3Tex1'
     SuitShirtTexs(4)=Texture'DeusExCharacters.Skins.ButlerTex1'
     SuitShirtTexs(5)=Texture'DeusExCharacters.Skins.ChefTex1'
     SuitShirtTexs(6)=Texture'DeusExCharacters.Skins.LowerClassMale2Tex1'
     SuitShirtTexs(7)=Texture'DeusExCharacters.Skins.MIBTex1'
     SuitShirtTexs(8)=Texture'DeusExCharacters.Skins.MichaelHamnerTex1'
     SuitShirtTexs(9)=Texture'DeusExCharacters.Skins.NathanMadisonTex1'
     SuitShirtTexs(10)=Texture'DeusExCharacters.Skins.PhilipMeadTex1'
     SuitShirtTexs(11)=Texture'VMDRevenantSuitTex1'
     SuitShirtTexs(12)=Texture'VMDRevenantSuitTex2'
     SuitShirtTexs(13)=Texture'VMDRevenantSuitTex3'
     SuitShirtTexs(14)=Texture'DeusExCharacters.Skins.SailorTex1'
     SuitShirtTexs(15)=Texture'DeusExCharacters.Skins.SecretServiceTex1'
     SuitShirtTexs(16)=Texture'DeusExCharacters.Skins.TriadLumPathTex1'
     MaxSuitShirtIndex=16
     
     DressShirtCoatLabel="Coat:"
     DressShirtLensesLabel="Lenses:"
     DressShirtFramesLabel="Frames:"
     
     DressShirtShirtTexs(0)=Texture'AlexJacobsonTex1'
     DressShirtShirtTexs(1)=Texture'DeusExCharacters.Skins.BartenderTex1'
     DressShirtShirtTexs(2)=Texture'DeusExCharacters.Skins.CopTex1'
     DressShirtShirtTexs(3)=Texture'DeusExCharacters.Skins.HowardStrongTex1'
     DressShirtShirtTexs(4)=Texture'DeusExCharacters.Skins.JoeGreeneTex1'
     DressShirtShirtTexs(5)=Texture'DeusExCharacters.Skins.Male1Tex1'
     DressShirtShirtTexs(6)=Texture'DeusExCharacters.Skins.Male2Tex1'
     DressShirtShirtTexs(7)=Texture'DeusExCharacters.Skins.Male3Tex1'
     DressShirtShirtTexs(8)=Texture'DeusExCharacters.Skins.MorganEverettTex1'
     DressShirtShirtTexs(9)=Texture'DeusExCharacters.Skins.ThugMale2Tex1'
     MaxDressShirtShirtIndex=9
     
     SuitSkirtCoatLabel="Hair:"
     SuitSkirtLensesLabel="Lenses:"
     SuitSkirtFramesLabel="Frames:"
     SuitSkirtShirtLabel="Skirt:"
     SuitSkirtPantsLabel="Pants:"
     
     SuitSkirtHairNames(0)="Short"
     SuitSkirtHairNames(1)="Bun"
     MaxSuitSkirtHairIndex=1
     
     SuitSkirtShirtTexs(0)=Texture'DeusExCharacters.Skins.Businesswoman1Tex1'
     SuitSkirtShirtTexs(1)=Texture'DeusExCharacters.Skins.Female2Tex2'
     SuitSkirtShirtTexs(2)=Texture'DeusExCharacters.Skins.Female3Tex1'
     SuitSkirtShirtTexs(3)=Texture'DeusExCharacters.Skins.MaggieChowTex1'
     SuitSkirtShirtTexs(4)=Texture'DeusExCharacters.Skins.MargaretWilliamsTex1'
     SuitSkirtShirtTexs(5)=Texture'DeusExCharacters.Skins.RachelMeadTex1'
     SuitSkirtShirtTexs(6)=Texture'DeusExCharacters.Skins.SecretaryTex2'
     SuitSkirtShirtTexs(7)=Texture'DeusExCharacters.Skins.WIBTex1'
     MaxSuitSkirtShirtIndex=7
     
     DressCoatLabel="Hair:"
     DressLensesLabel="Lenses:"
     DressFramesLabel="Frames:"
     DressShirtLabel="Dress:"
     DressPantsLabel="Pants:"
     
     DressHairNames(0)="Short"
     DressHairNames(1)="Short Ponytail"
     DressHairNames(2)="Medium"
     DressHairNames(3)="Medium Ponytail"
     MaxDressHairIndex=3
     
     DressShirtTexs(0)=Texture'SarahMeadTex1'
     DressSkirtTexs(0)=Texture'SarahMeadTex2'
     MaxDressShirtIndex=0
     
     filterString="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "
     HeaderNameLabel="Real Name"
     HeaderCodeNameLabel="Code Name"
     NameBlankTitle="Name Blank!"
     NameBlankPrompt="The Real Name cannot be blank, please enter a name."
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
}
