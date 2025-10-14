//=============================================================================
// HUDHitDisplay
//=============================================================================
class HUDHitDisplay extends HUDBaseWindow;

struct BodyPart
{
	var Window partWindow;
	var int    lastHealth;
	var int    healHealth;
	var int    displayedHealth;
	var float  damageCounter;
	var float  healCounter;
   var float  refreshCounter;
};

var BodyPart head;
var BodyPart torso;
var BodyPart armLeft;
var BodyPart armRight;
var BodyPart legLeft;
var BodyPart legRight;
var BodyPart armor;

var Color    colArmor;

var float    damageFlash;
var float    healFlash;

var Bool			bVisible;
var DeusExPlayer	player;

// Breathing underwater bar
var ProgressBarWindow winBreath;
var bool	bUnderwater;
var float	breathPercent;

// Energy bar
var ProgressBarWindow winEnergy;
var float	energyPercent;

// Used by DrawWindow
var Color colBar;
var int ypos;

// Defaults
var Texture texBackground;
var Texture texBorder;

var localized string O2Text;
var localized string EnergyText;

//MADDERS: Track hunger buildup as hunger and killswitch progression.
var ProgressBarWindow WinHunger, WinKillswitch;
var float HungerPercent, KillswitchPercent;
var localized string KillswitchText, HungerText;

var bool bFemale;
var Window BodyWin;

//MADDERS: Stress display.
var ProgressBarWindow winStress;
var float StressPercent;
var localized string StressText;

var int BarColX[4];

//Prospective Nihilum hack?
var bool bNihilumSetup, bUsingRebreather;
var int NihilumStressOffset, NihilumHungerOffset;
var int CurStressOffset, CurHungerOffset;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local VMDBufferPlayer VMP;
	
	Super.InitWindow();
	
	bTickEnabled = True;
	
	Hide();
	
	Player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.bAssignedFemale)) bFemale = true;
	
	SetSize(84, 106);
	
	if (bFemale)
	{
		CreateBodyPart(head,     Texture'HUDHitDisplay_HeadFem',     39, 17,  4,  7);
		CreateBodyPart(torso,    Texture'HUDHitDisplay_TorsoFem',    36, 25, 10,  23);
		CreateBodyPart(armLeft,  Texture'HUDHitDisplay_ArmLeftFem',  46, 27, 10,  23);
		CreateBodyPart(armRight, Texture'HUDHitDisplay_ArmRightFem', 26, 27, 10,  23);
		CreateBodyPart(legLeft,  Texture'HUDHitDisplay_LegLeftFem',  41, 44,  8,  36);
		CreateBodyPart(legRight, Texture'HUDHitDisplay_LegRightFem', 33, 44,  8,  36);
	}
	else
	{
		CreateBodyPart(head,     Texture'HUDHitDisplay_Head',     39, 17,  4,  7);
		CreateBodyPart(torso,    Texture'HUDHitDisplay_Torso',    36, 25, 10,  23);
		CreateBodyPart(armLeft,  Texture'HUDHitDisplay_ArmLeft',  46, 27, 10,  23);
		CreateBodyPart(armRight, Texture'HUDHitDisplay_ArmRight', 26, 27, 10,  23);
		CreateBodyPart(legLeft,  Texture'HUDHitDisplay_LegLeft',  41, 44,  8,  36);
		CreateBodyPart(legRight, Texture'HUDHitDisplay_LegRight', 33, 44,  8,  36);
	}
	
	bodyWin = NewChild(Class'Window');
	
	if (bFemale)
	{
		bodyWin.SetBackground(Texture'HUDHitDisplay_BodyFem');
	}
	else
	{
		bodyWin.SetBackground(Texture'HUDHitDisplay_Body');
	}
	
	bodyWin.SetBackgroundStyle(DSTY_Translucent);
	bodyWin.SetConfiguration(24, 15, 34, 68);
	bodyWin.SetTileColor(colArmor);
	bodyWin.Lower();
	
	winEnergy = CreateProgressBar(BarColX[0], 20);
	winBreath = CreateProgressBar(BarColX[2], 20);
	
	damageFlash = 0.4;  // seconds
	healFlash   = 1.0;  // seconds
	
	CreateStressHungerKillswitch(0, 0);
}

function bool IsNihilum()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	if (Bool(VMP))
	{
		return (VMP.IsA('MadIngramPlayer'));
	}
	return false;
}

function UpdateAsFemale(bool NewbFemale)
{
	bFemale = NewbFemale;
	
	if (IsNihilum()) return;
	
	if (bFemale)
	{
		Head.PartWindow.SetBackground(Texture'HUDHitDisplay_HeadFem');
		Torso.PartWindow.SetBackground(Texture'HUDHitDisplay_TorsoFem');
		ArmLeft.PartWindow.SetBackground(Texture'HUDHitDisplay_ArmLeftFem');
		ArmRight.PartWindow.SetBackground(Texture'HUDHitDisplay_ArmRightFem');
		LegLeft.PartWindow.SetBackground(Texture'HUDHitDisplay_LegLeftFem');
		LegRight.PartWindow.SetBackground(Texture'HUDHitDisplay_LegRightFem');
	}
	else
	{
		Head.PartWindow.SetBackground(Texture'HUDHitDisplay_Head');
		Torso.PartWindow.SetBackground(Texture'HUDHitDisplay_Torso');
		ArmLeft.PartWindow.SetBackground(Texture'HUDHitDisplay_ArmLeft');
		ArmRight.PartWindow.SetBackground(Texture'HUDHitDisplay_ArmRight');
		LegLeft.PartWindow.SetBackground(Texture'HUDHitDisplay_LegLeft');
		LegRight.PartWindow.SetBackground(Texture'HUDHitDisplay_LegRight');
	}
	
	if (bFemale)
	{
		bodyWin.SetBackground(Texture'HUDHitDisplay_BodyFem');
	}
	else
	{
		bodyWin.SetBackground(Texture'HUDHitDisplay_Body');
	}
}

function CreateStressHungerKillswitch(int StressX, int HungerX)
{
	if (!IsA('TNMHUDHitDisplay'))
	{
		//MADDERS: New additions.
		winStress = CreateProgressBar(BarColX[1]+StressX, 20);
		WinStress.bUseScaledColor = False;
		CurStressOffset = StressX;
		
		winHunger = CreateProgressBar(BarColX[3]+HungerX, 20);
		WinHunger.bUseScaledColor = False;
		winHunger.Default.ColForeground.R = 128;
		winHunger.Default.ColForeground.G = 128;
		winHunger.Default.ColForeground.B = 0;
        	CurHungerOffset = HungerX;
		
		winKillswitch = CreateProgressBar(BarColX[0], 20);
		WinKillswitch.bUseScaledColor = False;
		winKillswitch.Default.ColForeground.R = 128;
		winKillswitch.Default.ColForeground.G = 128;
		winKillswitch.Default.ColForeground.B = 0;
	}
}

// ----------------------------------------------------------------------
// CreateProgressBar()
// ----------------------------------------------------------------------

function ProgressBarWindow CreateProgressBar(int posX, int posY)
{
	local ProgressBarWindow winProgress;
	
	winProgress = ProgressBarWindow(NewChild(Class'ProgressBarWindow'));
	winProgress.UseScaledColor(True);
	winProgress.SetSize(5, 55);
	winProgress.SetPos(posX, posY);
	winProgress.SetValues(0, 100);
	winProgress.SetCurrentValue(0);
	winProgress.SetVertical(True);
	
	return winProgress;
}

// ----------------------------------------------------------------------
// CreateBodyPart()
// ----------------------------------------------------------------------

function CreateBodyPart(out BodyPart part, texture tx, float newX, float newY,
                        float newWidth, float newHeight)
{
	local window newWin;
	
	newWin = NewChild(Class'Window');
	newWin.SetBackground(tx);
	newWin.SetBackgroundStyle(DSTY_Translucent);
	newWin.SetConfiguration(newX, newY, newWidth, newHeight);
	newWin.SetTileColorRGB(0, 0, 0);
	
	part.partWindow      = newWin;
	part.displayedHealth = 0;
	part.lastHealth      = 0;
	part.healHealth      = 0;
	part.damageCounter   = 0;
	part.healCounter     = 0;
   	part.refreshCounter  = 0;
}

// ----------------------------------------------------------------------
// SetHitColor()
// ----------------------------------------------------------------------

function SetHitColor(out BodyPart part, float deltaSeconds, bool bHide, int hitValue)
{
	local float mult, THealthMult;
	local Color col;
	local VMDBufferPlayer VMP;
	
	part.damageCounter -= deltaSeconds;
	if (part.damageCounter < 0)
		part.damageCounter = 0;
	part.healCounter -= deltaSeconds;
	if (part.healCounter < 0)
		part.healCounter = 0;
	
   	part.refreshCounter -= deltaSeconds;
	
   	if ((part.healCounter == 0) && (part.damageCounter == 0) && (part.lastHealth == hitValue) && (part.refreshCounter > 0))
      		return;
	
   	if (part.refreshCounter <= 0)
     		part.refreshCounter = 0.5;
  	
	if (hitValue < part.lastHealth)
	{
		part.damageCounter  = damageFlash;
		part.displayedHealth = hitValue;
	}
	else if (hitValue > part.lastHealth)
	{
		part.healCounter = healFlash;
		part.healHealth = part.displayedHealth;
	}
	part.lastHealth = hitValue;
	
	if (part.healCounter > 0)
	{
		mult = part.healCounter/healFlash;
		part.displayedHealth = hitValue + (part.healHealth-hitValue)*mult;
	}
	else
	{
		part.displayedHealth = hitValue;
	}
	
	THealthMult = 1.0;
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		if (VMP.bKillswitchEngaged)
		{
			THealthMult *= VMP.KSHealthMult;
		}
		if (VMP.ModHealthMultiplier > 0)
		{
			THealthMult *= VMP.ModHealthMultiplier;
		}
	}
	
	hitValue = part.displayedHealth;
	col = winEnergy.GetColorScaled(hitValue/100.0);
	if ((VMP != None) && (VMP.bEnergyArmor))
	{
		if (Player.Energy > 0) col.B = Min(255, Col.B + (255 * (Player.Energy / 100.0)));
	}
	else if (HitValue >= 96 * THealthMult)
	{
		Col.B = 255;
	}
	
	if (part.damageCounter > 0)
	{
		mult = part.damageCounter/damageFlash;
		col.r += (255-col.r)*mult;
		col.g += (255-col.g)*mult;
		col.b += (255-col.b)*mult;
	}
	
	if (part.partWindow != None)
	{
		part.partWindow.SetTileColor(col);
		if (bHide)
		{
			if (hitValue > 0)
				part.partWindow.Show();
			else
				part.partWindow.Hide();
		}
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local bool bKS, bBlockExtra;
	local color TColor;
	local float DiffMult;
	local VMDBufferPlayer VMP;
	
	Super.DrawWindow(gc);
	
	VMP = VMDBufferPlayer(Player);
	if ((VMP != None) && (VMP.bKillswitchEngaged)) bKS = True;

	if (IsA('TNMHUDHitDisplay')) bBlockExtra = true;
	
	// Draw energy bar
	gc.SetFont(Font'FontTiny');
	
	//Energy.
	if ((!bKS || Player.Energy > 0 || bBlockExtra) && (VMP == None || !VMP.bEnergyArmor) && (Player.EnergyMax > 0))
	{
	 	gc.SetTextColor(winEnergy.GetBarColor());
	 	gc.DrawText(BarColX[0]-2, 74, 10, 8, EnergyText);
	}
        //Stress.
	if ((VMP != None) && (VMP.bStressEnabled) && (!bBlockExtra))
	{
	 	TColor.R = 244;
	 	TColor.G = 41;
	 	TColor.B = 142;
	 	gc.SetTextColor(TColor);
	 	gc.DrawText(BarColX[1]-2+CurStressOffset+1, 74, 8, 8, StressText);
	}
	
	//O2.
	// If we're underwater draw the breathometer
	if (Player.SwimTimer < Player.SwimDuration || bUsingRebreather)
	{
		ypos = breathPercent * 0.55;
		
		// draw the breath bar
		colBar = winBreath.GetBarColor();
		
		// draw the O2 text and blink it if really low
		gc.SetFont(Font'FontTiny');
		if (breathPercent < 10)
		{
			if ((player.swimTimer % 0.5) > 0.25)
				colBar.r = 255;
			else
				colBar.r = 0;
		}
		
		gc.SetTextColor(colBar);
		gc.DrawText(BarColX[2]-2, 74, 8, 8, O2Text);
	}
	//Killswitch.
	if ((bKS) && (Player.Energy <= 0) && (!bBlockExtra))
	{
		ypos = KillswitchPercent * 0.55;
		
		// draw the Killswitch bar
		colBar = winKillswitch.GetBarColor();
		
		// draw the Per text and blink it if really low
		gc.SetFont(Font'FontTiny');
		if (KillswitchPercent > 0)
		{
			//This is the REALLY bad part.
			if (KillswitchPercent > 91)
			{
		  		DiffMult = Sqrt(VMP.TimerDifficulty)/2.0;
				if ((VMP.KillswitchTime % (1.0*DiffMult)) > (0.5*DiffMult))
				{
					colBar.r = 255;
				}
				else
				{
					colBar.r = 0;
				}
				colBar.g = 0;
			}
			//Sorta bad still.
			else if (KillswitchPercent > 58)
			{
				colBar.r = 255;
				colBar.G = 127;
			}
			//Still not good, per say.
			else
			{
				colBar.r = 192;
				colBar.g = 192;
			}
		}
		
		gc.SetTextColor(colBar);
		gc.DrawText(BarColX[0]-2, 74, 8, 8, KillswitchText);
	}
	if ((VMP != None) && (VMP.bHungerEnabled) && (!bBlockExtra))
	{
		ypos = HungerPercent * 0.55;
		
		// draw the hunger bar
		colBar = winHunger.GetBarColor();
		
		// draw the Per text and blink it if really low
		gc.SetFont(Font'FontTiny');
		if (HungerPercent > 0)
		{
			if (HungerPercent > 70)
			{
				if (HungerPercent > 85)
				{
					if ((VMP.HungerTimer % (1.0*Sqrt(VMP.TimerDifficulty))) > 0.5*Sqrt(VMP.TimerDifficulty))
					{
						colBar.r = 255;
					}
					else
					{
						colBar.r = 0;
					}
				}
				colBar.g = 0;
			}
			else
			{
				colBar.r = 192;
				colBar.g = 192;
			}
		}
		
		gc.SetTextColor(colBar);
		gc.DrawText(BarColX[3]-2+CurHungerOffset, 74, 8, 8, HungerText);
	}
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
	gc.SetStyle(backgroundDrawStyle);
	gc.SetTileColor(colBackground);
	gc.DrawTexture(11, 11, 60, 76, 0, 0, texBackground);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
	if (bDrawBorder)
	{
		gc.SetStyle(borderDrawStyle);
		gc.SetTileColor(colBorder);
		gc.DrawTexture(0, 0, 84, 106, 0, 0, texBorder);
	}
}

// ----------------------------------------------------------------------
// Tick()
//
// Update the Energy and Breath displays
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
 	local float LP;
 	local string DL;
 	local ProgressBarWindow Reject, Accept;
	local VMDBufferPlayer VMP;
 	local bool bKS;
	local int THealth;
	local float THealthMult;
	
	if ((!bNihilumSetup) && (string(Class) ~= "FGRHK.TestHUDHitDisplay"))
	{
		CreateStressHungerKillswitch(NihilumStressOffset, NihilumHungerOffset);
	}
	bNihilumSetup = true;
	
	THealthMult = 1.0;
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		if (VMP.bKillswitchEngaged)
		{
			bKS = true;
		}
		if (VMP.ModHealthMultiplier > 0)
		{
			THealthMult = VMP.ModHealthMultiplier;
		}

		bUsingRebreather = VMP.UsingChargedPickup(class'Rebreather');
	}
	else
	{
		bUsingRebreather = false;
	}
	
   	// DEUS_EX AMSD Server doesn't need to do this.
   	if ((player.Level.NetMode != NM_Standalone)  && (!Player.PlayerIsClient()))
   	{
      		Hide();
      		return;
   	}
	if ((player != None) && ( bVisible ))
	{
		THealth = Player.HealthHead;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.31))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(head,     deltaSeconds, false, THealth / THealthMult);
		
		THealth = Player.HealthTorso;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.77))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(torso,    deltaSeconds, false, THealth / THealthMult);
		
		THealth = Player.HealthArmLeft;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.09))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(armLeft,  deltaSeconds, false, THealth / THealthMult);
		
		THealth = Player.HealthArmRight;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.43))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(armRight, deltaSeconds, false, THealth / THealthMult);
		
		THealth = Player.HealthLegLeft;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.55))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(legLeft,  deltaSeconds, false, THealth / THealthMult);
		
		THealth = Player.HealthLegRight;
		if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.80))) THealth = (100 * THealthMult) - THealth;
		SetHitColor(legRight, deltaSeconds, false, THealth / THealthMult);
		
		if (VMP != None)
		{
		 	HungerPercent = 100.0 * (VMP.HungerTimer / VMP.HungerCap);
		 	if ((VMP.bKillswitchEngaged) && (Player.Energy <= 0))
		 	{
		 		KillswitchPercent = 100.0 * (VMP.KillswitchTime / 5760);
		 	}
		 	else
		 	{
		 		KillswitchPercent = 0;
		 	}
		 	StressPercent = 100.0 * (VMP.ActiveStress / 100.0);
			if (!VMP.bStressEnabled) StressPercent = 0;
		 	
			//MADDERS: Stress coloration.
			if (StressPercent > 30)
			{
	  			WinStress.Default.ColForeground.R = 244;
	  			WinStress.Default.ColForeground.G = 49;
	  			WinStress.Default.ColForeground.B = 113;
			}
			else if (StressPercent > 60)
			{
	  			WinStress.Default.ColForeground.R = 244;
	  			WinStress.Default.ColForeground.G = 51;
	  			WinStress.Default.ColForeground.B = 84;
			}
			else if (StressPercent > 80)
			{
	  			WinStress.Default.ColForeground.R = 244;
	  			WinStress.Default.ColForeground.G = 56;
	  			WinStress.Default.ColForeground.B = 55;
			}
			else
			{
	 			WinStress.Default.ColForeground.R = 244;
	  			WinStress.Default.ColForeground.G = 41;
	  			WinStress.Default.ColForeground.B = 142;
			}
			winStress.SetCurrentValue(StressPercent);
		}
		
		if ((Player != None) && ((VMP == None) || (!VMP.bEnergyArmor)))
		{
			// Calculate the energy bar percentage
			energyPercent = 100.0 * (player.Energy / Max(1, player.EnergyMax));
			
			if ((VMP != None) && (VMP.HUDScramblerTimer > 0) && (!bKS))
			{
				if (VMP.IsEMPFlicker(VMP.HUDScramblerTimer+0.23))
				{
					EnergyPercent = 100 - EnergyPercent;
				}
			}
			
			winEnergy.SetCurrentValue(EnergyPercent);
		}
		else if (WinEnergy.IsVisible())
		{
			winEnergy.Hide();
		}
		
		// If we're underwater, draw the breath bar
		if (bUnderwater)
		{
			// if we are already underwater
			if (bUsingRebreather || player.HeadRegion.Zone.bWaterZone || Player.SwimTimer < Player.SwimDuration)
			{
				// if we are still underwater
				breathPercent = 100.0 * player.swimTimer / player.swimDuration;
				breathPercent = FClamp(breathPercent, 0.0, 100.0);
			}
			else
			{
				// if we are getting out of the water
				bUnderwater = False;
				breathPercent = 100;
			}
		}
		else if (bUsingRebreather || player.HeadRegion.Zone.bWaterZone || Player.SwimTimer < Player.SwimDuration)
		{
			// if we just went underwater
			bUnderwater = True;
			breathPercent = 100; //Used to be 100. Stop bad reporting.
		}
		
		if (VMP != None)
		{
			if (VMP.bHungerEnabled)
			{
				if (HungerPercent > 80)
				{
				 	WinHunger.Default.ColForeground.R = 255;
			 		WinHunger.Default.ColForeground.G = 0;
			 		WinHunger.Default.ColForeground.B = 0;
				}
				else
				{
			 		WinHunger.Default.ColForeground.R = 192;
			 		WinHunger.Default.ColForeground.G = 192;
			 		WinHunger.Default.ColForeground.B = 0;
				}
				
				WinHunger.SetCurrentValue(HungerPercent);
			}
			else
			{
				WinHunger.SetCurrentValue(0);
			}
		}
		else
		{
			if (WinHunger.IsVisible())
				WinHunger.Hide();
		}
		
		if ((bKS) && (Player.Energy <= 0))
		{
			if (!winKillswitch.IsVisible())
				winKillswitch.Show();
			
			if (KillswitchPercent > 91)
			{
			 	winKillswitch.Default.ColForeground.R = 255;
			 	winKillswitch.Default.ColForeground.G = 0;
			 	winKillswitch.Default.ColForeground.B = 0;
			}
			else if (KillswitchPercent > 58)
			{
			 	winKillswitch.Default.ColForeground.R = 255;
			 	winKillswitch.Default.ColForeground.G = 127;
			 	winKillswitch.Default.ColForeground.B = 0;
			}
			else
			{
			 	winKillswitch.Default.ColForeground.R = 192;
			 	winKillswitch.Default.ColForeground.G = 192;
			 	winKillswitch.Default.ColForeground.B = 0;	 
			}
			
			winKillswitch.SetCurrentValue(KillswitchPercent);
		}
		else
		{
			if (winKillswitch.IsVisible())
				winKillswitch.Hide();
		}
		
		// Now show or hide the breath meter
		if (bUnderwater)
		{
			if (!winBreath.IsVisible())
				winBreath.Show();
			
			winBreath.SetCurrentValue(breathPercent);
		}
		else
		{
			if (winBreath.IsVisible())
				winBreath.Hide();
		}
		
		Show();
	}
	else
		Hide();
}

// ----------------------------------------------------------------------
// SetVisibility()
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	bVisible = bNewVisibility;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colArmor=(R=255,G=255,B=255)
     texBackground=Texture'DeusExUI.UserInterface.HUDHitDisplayBackground_1'
     texBorder=Texture'DeusExUI.UserInterface.HUDHitDisplayBorder_1'
     O2Text="O2"
     EnergyText="EN"
     StressText="ST"
     KillswitchText="KS"
     HungerText="HU"
     
     BarColX(0)=14
     BarColX(1)=22
     BarColX(2)=57
     BarColX(3)=65
     NihilumStressOffset=6
     NihilumHungerOffset=10
}
