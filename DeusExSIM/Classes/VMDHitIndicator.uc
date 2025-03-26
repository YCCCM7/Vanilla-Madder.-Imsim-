//=============================================================================
// VMDHitIndicator.
//=============================================================================
class VMDHitIndicator extends Window;

//Mr. Incredible: Show Time.
var float ShowTime, ShowLength;
var bool bHeadshot, bArmorHit;
var VMDBufferPlayer VMP;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local Color col;
	
	Super.InitWindow();
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	SetBackgroundStyle(DSTY_Translucent);
	SetBackground(Texture'HitIndicatorSquare');
	col.R = 255;
	col.G = 255;
	col.B = 255;
	SetIndicatorColor(col);
}

// ----------------------------------------------------------------------
// SetIndicator()
// ----------------------------------------------------------------------

function SetIndicator( bool bShow, optional bool NewbHeadshot, optional bool NewbArmorhit )
{
	if ((VMP != None) && (VMP.bHitIndicatorHasVisual))
	{
		if (bShow)
        	{
		 	bHeadshot = NewbHeadshot;
			bArmorHit = NewbArmorHit;
        	 	ShowTime = ShowLength;
		 	SetIndicatorTrans(1.0);
		 	bTickEnabled = True;
        	 	SetBackgroundStyle(DSTY_Translucent);
		}
	}
	Show(bShow);
}

// ----------------------------------------------------------------------
// SetIndicatorColor()
// ----------------------------------------------------------------------

function SetIndicatorColor(color newColor)
{
	SetTileColor(newColor);
}

function SetIndicatorTrans(float NewAlpha)
{
	local int TAlpha;
	local Color NewCol;
	
	if (NewAlpha > 1.0) NewAlpha = 1.0;
	TAlpha = Clamp(NewAlpha * 255, 0, 255);
	
	if (bHeadshot)
	{
		if (bArmorHit)
		{
			NewCol.R = TAlpha;
			NewCol.G = TAlpha * 0.5;
			NewCol.B = 0;
		}
		else
		{
			NewCol.R = TAlpha;
			NewCol.G = 0;
			NewCol.B = 0;
		}
	}
	else
	{
		if (bArmorHit)
		{
			NewCol.R = TAlpha;
			NewCol.G = TAlpha;
			NewCol.B = 0;
		}
		else
		{
			NewCol.R = TAlpha;
			NewCol.G = TAlpha;
			NewCol.B = TAlpha;
		}
	}
	SetTileColor(NewCol);
}

function Tick(float deltaTime)
{ 
 	if (ShowTime > 0)
 	{
  		ShowTime -= deltaTime;
  		SetIndicatorTrans( (ShowTime*8) / ShowLength );
 	}
 	if (ShowTime < 0)
 	{
  		Show(False);
  		ShowTime = 0;
 	}
}

function SetVisibility(bool bShow)
{
	if (bShow)
	{
		SetBackgroundStyle(DSTY_Translucent);
		SetIndicatorTrans(0.0);
  		Show(False);
	}
	else
	{
		SetBackgroundStyle(DSTY_Translucent);
		SetIndicatorTrans(0.0);
  		Show(False);
	}
}

defaultproperties
{
 ShowLength=0.350000
 bTickEnabled=True
}
