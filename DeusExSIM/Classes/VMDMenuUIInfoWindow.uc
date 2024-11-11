//=============================================================================
// VMDMenuUIInfoWindow
//=============================================================================
class VMDMenuUIInfoWindow extends PersonaBaseWindow;

var PersonaScrollAreaWindow      winScroll;
var TileWindow                   winTile;
var PersonaHeaderTextWindow      winTitle;
var PersonaNormalLargeTextWindow winText;			// Last text

var int textVerticalOffset;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	CreateControls();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	winTitle = VMDMenuUIHeaderTextWindow(NewChild(Class'VMDMenuUIHeaderTextWindow'));
	winTitle.SetTextMargins(2, 1);
	
	winScroll = PersonaScrollAreaWindow(NewChild(Class'PersonaScrollAreaWindow'));
	
	winTile = TileWindow(winScroll.ClipWindow.NewChild(Class'TileWindow'));
	winTile.SetOrder(ORDER_Down);
	winTile.SetChildAlignments(HALIGN_Full, VALIGN_Top);
	winTile.MakeWidthsEqual(True);
	winTile.MakeHeightsEqual(False);
	winTile.SetMargins(4, 1);
	winTile.SetMinorSpacing(0);
	winTile.SetWindowAlignments(HALIGN_Full, VALIGN_Top);
}

// ----------------------------------------------------------------------
// SetTitle()
//
// Assume that if we're setting the title we're looking at another
// item and to clear the existing contents.
// ----------------------------------------------------------------------

function SetTitle(String newTitle)
{
	Clear();
	winTitle.SetText(newTitle);
}

// ----------------------------------------------------------------------
// SetText()
// ----------------------------------------------------------------------

function PersonaNormalLargeTextWindow SetText(String newText)
{
	winText = VMDMenuUINormalLargeTextWindow(winTile.NewChild(Class'VMDMenuUINormalLargeTextWindow'));

	winText.SetTextMargins(0, 0);
	winText.SetWordWrap(True);
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winText.SetText(newText);

	return winText;
}

// ----------------------------------------------------------------------
// AppendText()
// ----------------------------------------------------------------------

function AppendText(String newText)
{
	if (winText != None)
		winText.AppendText(newText);
	else
		SetText(newText);
}

// ----------------------------------------------------------------------
// AddInfoItem()
// ----------------------------------------------------------------------

function PersonaInfoItemWindow AddInfoItem(coerce String newLabel, coerce String newText, optional bool bHighlight)
{
	local VMDMenuUIInfoItemWindow winItem;

	winItem = VMDMenuUIInfoItemWindow(winTile.NewChild(Class'VMDMenuUIInfoItemWindow'));
	winItem.SetItemInfo(newLabel, newText, bHighlight);

	return winItem;
}

// ----------------------------------------------------------------------
// AddLine()
// ----------------------------------------------------------------------

function AddLine()
{
	winTile.NewChild(Class'VMDMenuUIInfoLineWindow');
}

// ----------------------------------------------------------------------
// Clear()
// ----------------------------------------------------------------------

function Clear()
{
	winTitle.SetText("");	
	winTile.DestroyAllChildren();
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
// ----------------------------------------------------------------------

function ConfigurationChanged()
{
	local float qWidth, qHeight;

	if (winTitle != None)
	{
		winTitle.QueryPreferredSize(qWidth, qHeight);
		winTitle.ConfigureChild(0, 0, width, qHeight);
	}

	if (winScroll != None)
	{
		winScroll.QueryPreferredSize(qWidth, qHeight);
		winScroll.ConfigureChild(0, textVerticalOffset, width, height - textVerticalOffset);
	}
}

// ----------------------------------------------------------------------
// ChildRequestedReconfiguration()
// ----------------------------------------------------------------------

function bool ChildRequestedReconfiguration(window child)
{
	ConfigurationChanged();

	return True;
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	colBackground = theme.GetColorFromName('MenuColor_Background');
	//colBorder     = theme.GetColorFromName('HUDColor_Borders');
	colText       = theme.GetColorFromName('MenuColor_ListText');
	colHeaderText = theme.GetColorFromName('MenuColor_HelpText');
	
	//bDrawBorder            = player.GetHUDBordersVisible();
	bDrawBorder = false;
	
	if (player.GetHUDBorderTranslucency())
		borderDrawStyle = DSTY_Translucent;
	else
		borderDrawStyle = DSTY_Masked;
	
	if (player.GetHUDBackgroundTranslucency())
		backgroundDrawStyle = DSTY_Translucent;
	else
		backgroundDrawStyle = DSTY_Masked;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     textVerticalOffset=20
}
