class MultitoolKeypadOverlayManager extends DeusExDecoration;

var float ProgressTimer;
var int CurArray, ArrayMax, PadType, QuantityOf[12];
var MultitoolKeypadOverlay OChildren[12];
var DeusExPlayer Player;
var Keypad Target;

function string TranslateKey(string S)
{
 	switch(CAPS(S))
 	{
 	 	case "#":
 	 	case "HASH":
 	 	 	return "Hash";
 	 	break;
 	 	case "*":
 	 	case "STAR":
 	 	 	return "Star";
 	 	break;
 	 	default:
 	 	 	return S;
 	 	break;
 	}
 	
 	return "0";
}

function int PositionOf(string S)
{
 	switch(CAPS(S))
 	{
  		case "#":
  		case "HASH":
   			return 10;
  		break;
  		case "*":
  		case "STAR":
   			return 11;
  		break;
  		default:
   			return int(S);
		break;
 	}
 	
 	return 0;
}

function ProduceArray(int Array, String Suffix)
{
 	local MultitoolKeypadOverlay MKO;
 	local string Use, LoadStr;
 	local int TarArray;
 	local Texture T;
 	
 	Use = TranslateKey(Mid(Target.HackedValidCode, Array, 1));
 	TarArray = PositionOf(Use);
 	
 	LoadStr = "BroopCodebreakerAssets.KeypadType0"$PadType$"Reveal"$Use$Suffix;
 	
 	T = Texture(DynamicLoadObject(LoadStr, class'Texture', True));
 	if (T != None)
 	{
  		if (OChildren[TarArray] == None)
  		{
  		 	OChildren[TarArray] = Spawn(class'MultitoolKeypadOverlay', Owner,,Target.Location, Target.Rotation);
  		}
  		MKO = OChildren[TarArray];
  		MKO.Mesh = Target.Mesh;
  		MKO.DrawScale = 1.02 * Target.DrawScale;
  		QuantityOf[TarArray]++;
  		MKO.Multiskins[0] = T;
  		MKO.bUnlit = True;
  		MKO.ScaleGlow = 0.75;
  		if (QuantityOf[TarArray] > 1) MKO.ScaleGlow = 20.0;
 	}
}

function FlushArrayLeft()
{
 	local int i;
 	
 	for (i=CurArray; i<ArrayMax; i++)
 	{
  		ProduceArray(i, "");
 	}
}

simulated function GeneratePoints(Keypad TPad, DeusExPlayer TOwner)
{
 	if (TPad == None || TOwner == None) return;
 	
 	Target = TPad;
 	Player = TOwner;
 	
 	ArrayMax = Len(TPad.HackedValidCode);
 	if (ArrayMax < 1)
 	{
 	 	Destroy();
 	 	return;
 	}
 	
 	if (TPad.Mesh == LODMesh'Keypad1') PadType = 1;
 	else if (TPad.Mesh == LODMesh'Keypad2') PadType = 2;
 	else if (TPad.Mesh == LODMesh'Keypad3') PadType = 3;
 	else
 	{
 	 	Destroy();
 	 	return;
 	}
 	
 	ProgressTimer = 1.6 / ArrayMax;
}

function Tick(float DT)
{
 	local bool bFlush;
 	
 	Super.Tick(DT);
 	
 	ProgressTimer -= DT;
 	if (ProgressTimer < 0)
 	{
 	 	if ((ArrayMax > 5-GetSkillMod()) && (CurArray == 0))
 	 	{
 	 	 	ProduceArray(CurArray, "FirstMulti");
 	 	}
 	 	else if ((ArrayMax > 6-GetSkillMod()) && (CurArray == 1))
 	 	{
 	 	 	ProduceArray(CurArray, "First");
 	 	}
 	 	else if ((ArrayMax > 7-GetSkillMod()) && (CurArray == 2))
 	 	{
 	 	 	ProduceArray(CurArray, "Multi");
 	 	}
 	 	else
 	 	{
 	 	 	bFlush = true;
 	 	 	FlushArrayLeft();
 	 	 	ProgressTimer = (0.35 / ArrayMax) * GetSkillMod();
 	 	 	return;
 	 	}
 	 	if (CurArray < ArrayMax)
 	 	{
 	 	 	ProgressTimer = (1.0 / ArrayMax) * GetSkillMod();
 	 	 	CurArray++;
 	 	}
 	}
}

function int GetSkillMod()
{
	local int Ret;
	
	Ret = Player.SkillSystem.GetSkillLevel(class'SkillTech');
	if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).HasSkillAugment('ElectronicsKeypads')))
	{
		Ret += 1;
 	}
 	return Ret;
}

simulated function Destroyed()
{
 	local int i;
 	
 	if (Target != None) Target.bFirstHackSpent = true;
 	for (i=0; i<12; i++)
 	{
 	 	if (OChildren[i] != None)
 	 	{
 	 	 	OChildren[i].Destroy();
 	 	}
 	}
 	
 	Super.Destroyed();
}

defaultproperties
{
     bHidden=True
     bProjTarget=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
