//=============================================================================
// MADDERS, 4/18/22: Wild and hacky, let's get whacky.
//=============================================================================
class VMDHousingScriptedTextureManager extends Info
					config(VMDHousing)
					abstract;

var Texture CurLoadedTexture, ValidatedTextures[16]; //CurLoadedPalette, ValidatedPalettes[64];
var int NumValidatedTextures, NumValidatedPalettes, CurTextureArray;
var() byte DefaultR, DefaultG, DefaultB;

var() string PotentialTextures[16], PoTextureNames[16];
var string PotentialPalettes[64];

var() string DefaultTexture, DefaultPalette;
var ScriptedMonochromeTexture CurDynamicPalette;
var() ScriptedTexture TargetScriptedTexture;

var config string SavedTexture; //, SavedPalette;
var config byte SavedR, SavedG, SavedB;

simulated function BeginPlay()
{
	Super.BeginPlay();
	
	InitTextureBullshit();
}

function InitTextureBullshit()
{
	local string TLoad, TrimChunk, StrName;
		
	if (TargetScriptedTexture != None)
	{
		TargetScriptedTexture.NotifyActor = Self;
		
		//CurDynamicPalette = new(None,'',RF_Transient) Class'ScriptedMonochromeTexture';
		
		StrName = string(Class.Name);
		TrimChunk = Right(StrName, (3-(25-Len(StrName))));
		if (Len(TrimChunk) < 2) TrimChunk = "0"$TrimChunk;
		TLoad = "GEHPaintTex.GEHPaintPaletteTex"$TrimChunk;
		
		CurDynamicPalette = ScriptedMonochromeTexture(DynamicLoadObject(TLoad, class'ScriptedMonochromeTexture', true));
		if (CurDynamicPalette != None)
		{
			CurDynamicPalette.Init(4, 4);
			CurDynamicPalette.MonochromeColor.A = 255;
			
			if (SavedR > 0 || SavedG > 0 || SavedB > 0)
			{
				CurDynamicPalette.MonochromeColor.R = SavedR;
				CurDynamicPalette.MonochromeColor.G = SavedG;
				CurDynamicPalette.MonochromeColor.B = SavedB;
			}
			else
			{
				CurDynamicPalette.MonochromeColor.R = DefaultR;
				CurDynamicPalette.MonochromeColor.G = DefaultG;
				CurDynamicPalette.MonochromeColor.B = DefaultB;
			}
		}
	}
}

simulated function Destroyed()
{
	if (TargetScriptedTexture != None)
	{
		TargetScriptedTexture.NotifyActor = None;
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
 	local VMDHousingScriptedTextureManager TexTar;
 	local ScriptedTexture UseTex;
 	
 	UseTex = Tex;
 	TexTar = VMDHousingScriptedTextureManager(UseTex.NotifyActor);
	
 	if ((TexTar == Self) && (UseTex.SourceTexture != None))
 	{
		if ((TexTar.CurLoadedTexture != None) && (TexTar.CurLoadedTexture != UseTex.SourceTexture))
		{
			if (VMDHousingScriptedTexture(UseTex) != None)
			{
				VMDHousingScriptedTexture(UseTex).LastTexGroup = class'VMDStaticFunctions'.Static.RetrieveTextureGroup(TexTar.CurLoadedTexture, PlayerPawnExt(GetPlayerPawn()));
			}
			UseTex.ReplaceTexture(TexTar.CurLoadedTexture);
			UseTex.Palette = TexTar.CurLoadedTexture.Palette;
		}
		//if (TexTar.CurLoadedPalette != None)
		if ((CurDynamicPalette != None) && (CurDynamicPalette != UseTex.MacroTexture))
		{
			UseTex.MacroTexture = CurDynamicPalette;
		}
 	}
}

function PostBeginPlay()
{
	local Texture TLoad;
	local Palette TLoad2;
	local int i;
	
	Super.PostBeginPlay();
	
	//Part 1: Load texture.
	TLoad = Texture(DynamicLoadObject(SavedTexture, class'Texture', True));
	if (TLoad == None)
	{
		TLoad = Texture(DynamicLoadObject(DefaultTexture, class'Texture', False));
	}
	if (TLoad != None)
	{
		CurLoadedTexture = TLoad;
	}
	
	//Part 2: Load palette.
	/*TLoad = Texture(DynamicLoadObject(SavedPalette, class'Texture', True));
	if (TLoad == None)
	{
		TLoad = Texture(DynamicLoadObject(DefaultPalette, class'Texture', False));
	}
	if (TLoad != None)
	{
		CurLoadedPalette = TLoad;
	}*/
	
	//Part 3: Load other textures.
	for(i=0; i<ArrayCount(PotentialTextures); i++)
	{
		if (PotentialTextures[i] != "")
		{
			TLoad = Texture(DynamicLoadObject(PotentialTextures[i], class'Texture', True));
			if (TLoad != None)
			{
				ValidatedTextures[NumValidatedTextures++] = TLoad;
			}
		}
	}
	
	//Part 4: Load other palettes.
	/*for(i=0; i<ArrayCount(PotentialPalettes); i++)
	{
		if (PotentialPalettes[i] != "")
		{
			TLoad = Texture(DynamicLoadObject(PotentialPalettes[i], class'Texture', True));
			if (TLoad != None)
			{
				ValidatedPalettes[NumValidatedPalettes++] = TLoad;
			}
		}
	}*/
	
	if (NumValidatedTextures > 1)
	{
		for(i=0; i<NumValidatedTextures; i++)
		{
			if (CurLoadedTexture == ValidatedTextures[i])
			{
				CurTextureArray = i;
				break;
			}
		}
	}
}

function SetCurDynamicPalette(byte NewR, byte NewG, byte NewB)
{
	if (CurDynamicPalette != None)
	{
		CurDynamicPalette.MonochromeColor.R = NewR;
		CurDynamicPalette.MonochromeColor.G = NewG;
		CurDynamicPalette.MonochromeColor.B = NewB;
	}
}

function SetCurLoadedPalette(int i)
{
	//CurLoadedPalette = ValidatedPalettes[i];
}

defaultproperties
{
    PotentialPalettes(0)="VMDHousingPaintBase.VMDPaintCoat000"
    PotentialPalettes(1)="VMDHousingPaintBase.VMDPaintCoat001"
    PotentialPalettes(2)="VMDHousingPaintBase.VMDPaintCoat002"
    PotentialPalettes(3)="VMDHousingPaintBase.VMDPaintCoat003"
    PotentialPalettes(4)="VMDHousingPaintBase.VMDPaintCoat010"
    PotentialPalettes(5)="VMDHousingPaintBase.VMDPaintCoat011"
    PotentialPalettes(6)="VMDHousingPaintBase.VMDPaintCoat012"
    PotentialPalettes(7)="VMDHousingPaintBase.VMDPaintCoat013"
    PotentialPalettes(8)="VMDHousingPaintBase.VMDPaintCoat020"
    PotentialPalettes(9)="VMDHousingPaintBase.VMDPaintCoat021"
    PotentialPalettes(10)="VMDHousingPaintBase.VMDPaintCoat022"
    PotentialPalettes(11)="VMDHousingPaintBase.VMDPaintCoat023"
    PotentialPalettes(12)="VMDHousingPaintBase.VMDPaintCoat030"
    PotentialPalettes(13)="VMDHousingPaintBase.VMDPaintCoat031"
    PotentialPalettes(14)="VMDHousingPaintBase.VMDPaintCoat032"
    PotentialPalettes(15)="VMDHousingPaintBase.VMDPaintCoat033"
    PotentialPalettes(16)="VMDHousingPaintBase.VMDPaintCoat100"
    PotentialPalettes(17)="VMDHousingPaintBase.VMDPaintCoat101"
    PotentialPalettes(18)="VMDHousingPaintBase.VMDPaintCoat102"
    PotentialPalettes(19)="VMDHousingPaintBase.VMDPaintCoat103"
    PotentialPalettes(20)="VMDHousingPaintBase.VMDPaintCoat110"
    PotentialPalettes(21)="VMDHousingPaintBase.VMDPaintCoat111"
    PotentialPalettes(22)="VMDHousingPaintBase.VMDPaintCoat112"
    PotentialPalettes(23)="VMDHousingPaintBase.VMDPaintCoat113"
    PotentialPalettes(24)="VMDHousingPaintBase.VMDPaintCoat120"
    PotentialPalettes(25)="VMDHousingPaintBase.VMDPaintCoat121"
    PotentialPalettes(26)="VMDHousingPaintBase.VMDPaintCoat122"
    PotentialPalettes(27)="VMDHousingPaintBase.VMDPaintCoat123"
    PotentialPalettes(28)="VMDHousingPaintBase.VMDPaintCoat130"
    PotentialPalettes(29)="VMDHousingPaintBase.VMDPaintCoat131"
    PotentialPalettes(30)="VMDHousingPaintBase.VMDPaintCoat132"
    PotentialPalettes(31)="VMDHousingPaintBase.VMDPaintCoat133"
    PotentialPalettes(32)="VMDHousingPaintBase.VMDPaintCoat200"
    PotentialPalettes(33)="VMDHousingPaintBase.VMDPaintCoat201"
    PotentialPalettes(34)="VMDHousingPaintBase.VMDPaintCoat202"
    PotentialPalettes(35)="VMDHousingPaintBase.VMDPaintCoat203"
    PotentialPalettes(36)="VMDHousingPaintBase.VMDPaintCoat210"
    PotentialPalettes(37)="VMDHousingPaintBase.VMDPaintCoat211"
    PotentialPalettes(38)="VMDHousingPaintBase.VMDPaintCoat212"
    PotentialPalettes(39)="VMDHousingPaintBase.VMDPaintCoat213"
    PotentialPalettes(40)="VMDHousingPaintBase.VMDPaintCoat220"
    PotentialPalettes(41)="VMDHousingPaintBase.VMDPaintCoat221"
    PotentialPalettes(42)="VMDHousingPaintBase.VMDPaintCoat222"
    PotentialPalettes(43)="VMDHousingPaintBase.VMDPaintCoat223"
    PotentialPalettes(44)="VMDHousingPaintBase.VMDPaintCoat230"
    PotentialPalettes(45)="VMDHousingPaintBase.VMDPaintCoat231"
    PotentialPalettes(46)="VMDHousingPaintBase.VMDPaintCoat232"
    PotentialPalettes(47)="VMDHousingPaintBase.VMDPaintCoat233"
    PotentialPalettes(48)="VMDHousingPaintBase.VMDPaintCoat300"
    PotentialPalettes(49)="VMDHousingPaintBase.VMDPaintCoat301"
    PotentialPalettes(50)="VMDHousingPaintBase.VMDPaintCoat302"
    PotentialPalettes(51)="VMDHousingPaintBase.VMDPaintCoat303"
    PotentialPalettes(52)="VMDHousingPaintBase.VMDPaintCoat310"
    PotentialPalettes(53)="VMDHousingPaintBase.VMDPaintCoat311"
    PotentialPalettes(54)="VMDHousingPaintBase.VMDPaintCoat312"
    PotentialPalettes(55)="VMDHousingPaintBase.VMDPaintCoat313"
    PotentialPalettes(56)="VMDHousingPaintBase.VMDPaintCoat320"
    PotentialPalettes(57)="VMDHousingPaintBase.VMDPaintCoat321"
    PotentialPalettes(58)="VMDHousingPaintBase.VMDPaintCoat322"
    PotentialPalettes(59)="VMDHousingPaintBase.VMDPaintCoat323"
    PotentialPalettes(60)="VMDHousingPaintBase.VMDPaintCoat330"
    PotentialPalettes(61)="VMDHousingPaintBase.VMDPaintCoat331"
    PotentialPalettes(62)="VMDHousingPaintBase.VMDPaintCoat332"
    PotentialPalettes(63)="VMDHousingPaintBase.VMDPaintCoat333"
    DefaultR=255
    DefaultG=255
    DefaultB=255
    
    RemoteRole=ROLE_SimulatedProxy
    bStatic=False
    bAlwaysRelevant=True
    bNoDelete=True
}
