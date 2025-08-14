//=============================================================================
// VMDHUDDisplayLayer.
//=============================================================================
class VMDHUDDisplayLayer extends Window;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var int InternalIndex;
var MenuUILabelWindow WarningLabel;
var VMDButtonPos WarningLabelPos, WarningLabelSize;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSensitivity(false);
}

function InitTNMWarningLabel()
{
	local Color TCol;
	
	WarningLabel = CreateMenuLabel(WarningLabelPos.X, WarningLabelPos.Y, "Note: VMD Added To TNM Gameplay", Self);
	WarningLabel.SetSize(WarningLabelSize.X, WarningLabelSize.Y);
	WarningLabel.SetPos(WarningLabelPos.X, WarningLabelPos.Y);
	TCol.R = 255;
	TCol.G = 201;
	TCol.B = 14;
	WarningLabel.ColLabel = TCol;
	WarningLabel.SetTextColor(WarningLabel.ColLabel);
}

// ----------------------------------------------------------------------
// CreateMenuLabel()
// ----------------------------------------------------------------------

function MenuUILabelWindow CreateMenuLabel(int posX, int posY, String strLabel, Window winParent)
{
	local MenuUILabelWindow newLabel;
	
	newLabel = MenuUILabelWindow(winParent.NewChild(Class'MenuUILabelWindow'));
	
	newLabel.SetPos(posX, posY);
	newLabel.SetText(strLabel);
	
	return newLabel;
}

function PostDrawWindow(GC gc)
{
	local VMDBufferPlayer VMP;
	
	Super.PostDrawWindow(gc);
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((InternalIndex == 0) && (VMP != None) && (VMP.Level != None) && (VMP.Level.Pauser != ""))
	{
		VMP.ViewFlash(VMP.VMDLastTickChunk);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WarningLabelPos=(X=0,Y=246)
     WarningLabelSize=(X=512,Y=24)
}
