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
    PotentialPalettes(0)="VMDAssets.VMDPaintCoat000"
    PotentialPalettes(1)="VMDAssets.VMDPaintCoat001"
    PotentialPalettes(2)="VMDAssets.VMDPaintCoat002"
    PotentialPalettes(3)="VMDAssets.VMDPaintCoat003"
    PotentialPalettes(4)="VMDAssets.VMDPaintCoat010"
    PotentialPalettes(5)="VMDAssets.VMDPaintCoat011"
    PotentialPalettes(6)="VMDAssets.VMDPaintCoat012"
    PotentialPalettes(7)="VMDAssets.VMDPaintCoat013"
    PotentialPalettes(8)="VMDAssets.VMDPaintCoat020"
    PotentialPalettes(9)="VMDAssets.VMDPaintCoat021"
    PotentialPalettes(10)="VMDAssets.VMDPaintCoat022"
    PotentialPalettes(11)="VMDAssets.VMDPaintCoat023"
    PotentialPalettes(12)="VMDAssets.VMDPaintCoat030"
    PotentialPalettes(13)="VMDAssets.VMDPaintCoat031"
    PotentialPalettes(14)="VMDAssets.VMDPaintCoat032"
    PotentialPalettes(15)="VMDAssets.VMDPaintCoat033"
    PotentialPalettes(16)="VMDAssets.VMDPaintCoat100"
    PotentialPalettes(17)="VMDAssets.VMDPaintCoat101"
    PotentialPalettes(18)="VMDAssets.VMDPaintCoat102"
    PotentialPalettes(19)="VMDAssets.VMDPaintCoat103"
    PotentialPalettes(20)="VMDAssets.VMDPaintCoat110"
    PotentialPalettes(21)="VMDAssets.VMDPaintCoat111"
    PotentialPalettes(22)="VMDAssets.VMDPaintCoat112"
    PotentialPalettes(23)="VMDAssets.VMDPaintCoat113"
    PotentialPalettes(24)="VMDAssets.VMDPaintCoat120"
    PotentialPalettes(25)="VMDAssets.VMDPaintCoat121"
    PotentialPalettes(26)="VMDAssets.VMDPaintCoat122"
    PotentialPalettes(27)="VMDAssets.VMDPaintCoat123"
    PotentialPalettes(28)="VMDAssets.VMDPaintCoat130"
    PotentialPalettes(29)="VMDAssets.VMDPaintCoat131"
    PotentialPalettes(30)="VMDAssets.VMDPaintCoat132"
    PotentialPalettes(31)="VMDAssets.VMDPaintCoat133"
    PotentialPalettes(32)="VMDAssets.VMDPaintCoat200"
    PotentialPalettes(33)="VMDAssets.VMDPaintCoat201"
    PotentialPalettes(34)="VMDAssets.VMDPaintCoat202"
    PotentialPalettes(35)="VMDAssets.VMDPaintCoat203"
    PotentialPalettes(36)="VMDAssets.VMDPaintCoat210"
    PotentialPalettes(37)="VMDAssets.VMDPaintCoat211"
    PotentialPalettes(38)="VMDAssets.VMDPaintCoat212"
    PotentialPalettes(39)="VMDAssets.VMDPaintCoat213"
    PotentialPalettes(40)="VMDAssets.VMDPaintCoat220"
    PotentialPalettes(41)="VMDAssets.VMDPaintCoat221"
    PotentialPalettes(42)="VMDAssets.VMDPaintCoat222"
    PotentialPalettes(43)="VMDAssets.VMDPaintCoat223"
    PotentialPalettes(44)="VMDAssets.VMDPaintCoat230"
    PotentialPalettes(45)="VMDAssets.VMDPaintCoat231"
    PotentialPalettes(46)="VMDAssets.VMDPaintCoat232"
    PotentialPalettes(47)="VMDAssets.VMDPaintCoat233"
    PotentialPalettes(48)="VMDAssets.VMDPaintCoat300"
    PotentialPalettes(49)="VMDAssets.VMDPaintCoat301"
    PotentialPalettes(50)="VMDAssets.VMDPaintCoat302"
    PotentialPalettes(51)="VMDAssets.VMDPaintCoat303"
    PotentialPalettes(52)="VMDAssets.VMDPaintCoat310"
    PotentialPalettes(53)="VMDAssets.VMDPaintCoat311"
    PotentialPalettes(54)="VMDAssets.VMDPaintCoat312"
    PotentialPalettes(55)="VMDAssets.VMDPaintCoat313"
    PotentialPalettes(56)="VMDAssets.VMDPaintCoat320"
    PotentialPalettes(57)="VMDAssets.VMDPaintCoat321"
    PotentialPalettes(58)="VMDAssets.VMDPaintCoat322"
    PotentialPalettes(59)="VMDAssets.VMDPaintCoat323"
    PotentialPalettes(60)="VMDAssets.VMDPaintCoat330"
    PotentialPalettes(61)="VMDAssets.VMDPaintCoat331"
    PotentialPalettes(62)="VMDAssets.VMDPaintCoat332"
    PotentialPalettes(63)="VMDAssets.VMDPaintCoat333"
    DefaultR=255
    DefaultG=255
    DefaultB=255
    
    RemoteRole=ROLE_SimulatedProxy
    bStatic=False
    bAlwaysRelevant=True
    bNoDelete=True
}
