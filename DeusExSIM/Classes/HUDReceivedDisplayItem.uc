//=============================================================================
// HUDReceivedDisplayItem
//=============================================================================
class HUDReceivedDisplayItem extends TileWindow;

var DeusExPlayer player;

var Window     winIcon;
var TextWindow winLabel;

var Color colText;
var Font fontLabel;

//MADDERES, 8/10/23: We can now stack existing items already being displayed. Store some info to make this possible.
var class<Inventory> LastItemClass;
var int LastCount;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	SetOrder(ORDER_DownThenRight);
	SetChildAlignments(HALIGN_Center, VALIGN_Top);
	SetMargins(0, 0);
	SetMinorSpacing(2);
	MakeWidthsEqual(False);
	MakeHeightsEqual(False);

	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);

	StyleChanged();
}

// ----------------------------------------------------------------------
// SetItem()
// ----------------------------------------------------------------------

event SetItem(Inventory invItem, int count)
{
	local String labelText;
	
	if (InvItem == None) return;
	
	LastItemClass = InvItem.Class;
	LastCount = Count;
	
	winIcon = NewChild(Class'Window');
	winIcon.SetSize(42, 37);
	winIcon.SetBackgroundStyle(DSTY_Masked);
	winIcon.SetBackground(invItem.Icon);
	
	winLabel = TextWindow(NewChild(Class'TextWindow'));
	winLabel.SetFont(fontLabel);
	winLabel.SetTextColor(colText);
	winLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	
	labelText = invItem.Class.Default.beltDescription;
	if (count > 1)
		labelText = labelText $ " (" $ String(count) $ ")";
	
	winLabel.SetText(labelText);
}

event AddToCount(Inventory AddItem, int AddAmount)
{
	local String LabelText;
	
	if (AddItem == None) return;
	
	LastCount += AddAmount;
	
	LabelText = AddItem.BeltDescription;
	if (LastCount > 1)
	{
		LabelText = LabelText $ " (" $ String(LastCount) $ ")";
	}
	
	WinLabel.SetText(LabelText);
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;

	theme = player.ThemeManager.GetCurrentHUDColorTheme();

	colText = theme.GetColorFromName('HUDColor_NormalText');

	if (winLabel != None)
		winLabel.SetTextColor(colText);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     fontLabel=Font'DeusExUI.FontMenuSmall_DS'
}
