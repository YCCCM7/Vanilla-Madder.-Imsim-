//=============================================================================
// VMDHUDDroneIndicator.
//=============================================================================
class VMDHUDDroneIndicator extends Window;

var bool bDesiredVisibility;
var float FadeTimer, FadeCap;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(16, 16);
	SetBackgroundStyle(DSTY_Translucent);
	SetBackground(None);
}

function ShowTex(int NewAlliance)
{
	bDesiredVisibility = true;
	switch(NewAlliance)
	{
		case -2:
			SetBackground(Texture'VMDHUDIconDroneNoAlliance');
		break;
		case -1:
			SetBackground(Texture'VMDHUDIconDroneHostile');
		break;
		case 1:
			SetBackground(Texture'VMDHUDIconDroneFriendly');
		break;
		case 0:
			SetBackground(Texture'VMDHUDIconDroneNeutral');
		break;
	}
}

function Tick(float DT)
{
 	if ((FadeTimer > 0) && (!bDesiredVisibility))
 	{
		FadeTimer = FMax(0.0, FadeTimer - DT);
		SetIndicatorColor((FadeTimer / FadeCap) * 255.0);
	}
 	else if ((FadeTimer < FadeCap) && (bDesiredVisibility))
	{
		FadeTimer = FMin(FadeCap, FadeTimer + DT);
		SetIndicatorColor((FadeTimer / FadeCap) * 255.0);
	}
}

function SetIndicatorColor(float NewAlpha)
{
	local Color NewColor;
	
	NewAlpha = Max(0, NewAlpha);
	NewColor.R = NewAlpha;
	NewColor.G = NewAlpha;
	NewColor.B = NewAlpha;
	SetTileColor(NewColor);
}

defaultproperties
{
    bTickEnabled=True
    FadeCap=0.500000
}
