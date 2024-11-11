//=============================================================================
// PersonaRenameWindow
//=============================================================================
class PersonaRenameWindow extends PersonaEditWindow;

var Inventory SelectedItem;
var Augmentation SelectedAugmentation;
var string strTitle;

event bool TextChanged(window edit, bool bModified)
{
	RenameItem();

	return false;
}

function RenameItem()
{
	local string boxText;
	if (SelectedItem != None)
	{
		if (GetText() != "")
		{
			boxText = GetText();
		}
		if (boxText != "" && strTitle != "")
		{
			if (Left(boxText, Len(strTitle)) == strTitle)
			{
				boxText = Mid(boxText, Len(strTitle));
			}
		}
		if (boxText != "" && BoxText != class'PersonaScreenInventory'.Default.AmmoTitleLabel)
		{
			SelectedItem.ItemName = BoxText;
		}
	}
	else if (SelectedAugmentation != None)
	{
		if (GetText() != "")
		{
			boxText = GetText();
		}
		if (boxText != "" && strTitle != "")
		{
			if (Left(boxText, Len(strTitle)) == strTitle)
			{
				boxText = Mid(boxText, Len(strTitle));
			}
		}
		if (boxText != "")
		{
			SelectedAugmentation.AugmentationName = BoxText;
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
