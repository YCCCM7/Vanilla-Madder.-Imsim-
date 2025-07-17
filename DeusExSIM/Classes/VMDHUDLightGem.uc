//=============================================================================
// VMDHUDLightGem
//=============================================================================
class VMDHUDLightGem extends HUDBaseWindow;

var Actor OGGGuy;
var VMDBufferPlayer VMP;

var float ColorTransition, VisUpdateRate, ColorUpdateTimer, DeltaMult, RedGainRate, SurprisePeriodMult;
var Color LastHumanGemColor, LastRobotGemColor, CurHumanGemColor, CurRobotGemColor, RenderHumanGemColor, RenderRobotGemColor,
		ColPerfect, ColGood, ColBad, ColDetected;

var Texture TexBackground;

event InitWindow()
{
	local Actor A;
	
	Super.InitWindow();
	
	Hide();
	
	Player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	VMP = VMDBufferPlayer(Player);
	
	SetSize(128, 64);
	
	bTickEnabled = true;
	
	RedGainRate = ColBad.G * 4;
	DeltaMult = 1.0 / VisUpdateRate;
	
	forEach Player.AllActors(class'Actor', A)
	{
		if (A.IsA('DXOggMusicManager'))
		{
			OGGGuy = A;
			break;
		}
	}
}

function CreateControls()
{
}

function Tick(float DT)
{
	local float TTran;
	local Color TCol;
	
	if (ColorUpdateTimer > 0)
	{
		ColorUpdateTimer -= DT;
	}
	else
	{
		UpdateVisibility();
	}
	
	ColorTransition = FClamp(ColorTransition - (DT*DeltaMult), 0.0, 1.0);
	
	TTran = 1.0 - ColorTransition;
	
	TCol.R = (LastHumanGemColor.R * ColorTransition) + (CurHumanGemColor.R * TTran);
	TCol.G = (LastHumanGemColor.G * ColorTransition) + (CurHumanGemColor.G * TTran);
	TCol.B = (LastHumanGemColor.B * ColorTransition) + (CurHumanGemColor.B * TTran);
	RenderHumanGemColor = TCol;
	
	TCol.R = (LastRobotGemColor.R * ColorTransition) + (CurRobotGemColor.R * TTran);
	TCol.G = (LastRobotGemColor.G * ColorTransition) + (CurRobotGemColor.G * TTran);
	TCol.B = (LastRobotGemColor.B * ColorTransition) + (CurRobotGemColor.B * TTran);
	RenderRobotGemColor = TCol;
}

function UpdateVisibility()
{
	local bool bAdaptive;
	local float BaseVis, HVis, RVis, HBase, RBase;
	local color HColor, RColor;
		
	if (Player == None || Player.AugmentationSystem == None) return;
	
	if ((Player.MusicMode == MUS_Combat || (OGGGuy != None && OggGuy.GetPropertyText("MusicMode") == "MUS_Combat")) && (VMDBufferPlayer(Player) == None || VMDBufferPlayer(Player).HasSkillAugment('LockpickStealthBar')))
	{
		HColor = ColDetected;
		HColor.G = 0;
		RColor = ColDetected;
		RColor.G = 0;
	}
	else
	{
		BaseVis = Player.AIVisibility();
		
		HVis = BaseVis;
		RVis = BaseVis;
		if (Player.bOnFire)
		{
			HVis *= 1.5;
			RVis *= 1.5;
		}
		
		if (Player.UsingChargedPickup(class'AdaptiveArmor')) bAdaptive = true;
		if (Player.AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0 || bAdaptive) HVis -= BaseVis;
		if (Player.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') != -1.0 || bAdaptive) RVis -= BaseVis;
		HBase = 0.010;
		RBase = 0.006;
		
		if (VMP	!= None)
		{
			HBase *= VMP.EnemyVisionStrengthMult;
			if (VMP.ModOrganicVisibilityMultiplier >= 0.0) HVis *= VMP.ModOrganicVisibilityMultiplier;
			if (VMP.ModRobotVisibilityMultiplier >= 0.0) RVis *= VMP.ModRobotVisibilityMultiplier;
		}
		
		if (HVis < HBase)
		{
			HColor = ColPerfect;
		}
		else if (HVis < HBase*2)
		{
			HColor = ColGood;
		}
		else
		{
			HColor = ColBad;
			HColor.G = Max(0, HColor.G - ((HVis - HBase) * RedGainRate));
		}
		
		if (RVis < RBase)
		{
			RColor = ColPerfect;
		}
		else if (RVis < RBase*2)
		{
			RColor = ColGood;
		}
		else
		{
			RColor = ColBad;
			RColor.G = Max(0, RColor.G - ((RVis - RBase) * RedGainRate));
		}
	}
	
	LastHumanGemColor = CurHumanGemColor;
	LastRobotGemColor = CurRobotGemColor;
	CurHumanGemColor = HColor;
	CurRobotGemColor = RColor;
	ColorTransition = 1.0;
	
	DeltaMult = 1.0 / VisUpdateRate;
	ColorUpdateTimer = VisUpdateRate;
}

function QueueNewColor(int ColorType, int UpdateType)
{
	local int ColorsChanged;
	local float ColorDisplayMult;
	local Color TCol;
	
	if (ColorType == 0)
	{
		TCol = ColDetected;
		TCol.G = 0;
	}
	
	//0 and 2, humans.
	if (UpdateType != 1)
	{
		if (CurHumanGemColor != TCol)
		{
			LastHumanGemColor = RenderHumanGemColor;
			CurHumanGemColor = TCol;
			ColorsChanged++;
		}
	}
	//1 and 2, robots.
	if (UpdateType > 0)
	{
		if (CurRobotGemColor != TCol)
		{
			LastRobotGemColor = RenderRobotGemColor;
			CurRobotGemColor = TCol;
			ColorsChanged++;
		}
		else return;
	}
	
	if (ColorsChanged > 0)
	{
		VMP = VMDBufferPlayer(Player);
		if ((VMP != None) && (VMP.EnemySurprisePeriodMax > 0))
		{
			SurprisePeriodMult = FMin(1.0, VMP.EnemySurprisePeriodMax);
		}
		
		ColorDisplayMult = 1.0 * SurprisePeriodMult;
		ColorTransition = 1.0;
		DeltaMult = 1.0 / ColorDisplayMult;
		ColorUpdateTimer = VisUpdateRate*ColorDisplayMult;
	}
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC GC)
{
	gc.SetStyle(BackgroundDrawStyle);
	gc.SetTileColor(ColBackground);
	gc.DrawTexture(0, 0, 128, 64, 0, 0, TexBackground);
	
	gc.SetStyle(DSTY_Masked);
	
	gc.SetTileColor(RenderHumanGemColor);
	gc.DrawTexture(0, 0, 64, 64, 0, 0, Texture'HUDVMDLightbarTex2A');
	
	gc.SetTileColor(RenderRobotGemColor);
	gc.DrawTexture(64, 0, 64, 64, 0, 0, Texture'HUDVMDLightbarTex2B');
}

// ----------------------------------------------------------------------
// SetVisibility()
// ----------------------------------------------------------------------

function SetVisibility(bool bNewVisibility)
{
	Show(bNewVisibility);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    SurprisePeriodMult=1.000000
    VisUpdateRate=0.200000
    TexBackground=Texture'HUDVMDLightbarTex1'
    ColPerfect=(R=0,G=188,B=0)
    ColGood=(R=240,G=240,B=0)
    ColBad=(R=240,G=152,B=0)
    ColDetected=(R=180,G=0,B=240)
    RenderHumanGemColor=(R=240,G=255,B=0)
    RenderRobotGemColor=(R=240,G=255,B=0)
    CurHumanGemColor=(R=240,G=240,B=0)
    CurRobotGemColor=(R=240,G=240,B=0)
    LastHumanGemColor=(R=240,G=240,B=0)
    LastRobotGemColor=(R=240,G=240,B=0)
}
