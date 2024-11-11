//=============================================================================
// HUDActiveItemsDisplay
//=============================================================================
class HUDActiveItemsDisplay extends HUDBaseWindow;

enum ESchemeTypes
{
	ST_Menu,
	ST_HUD
};

var ESchemeTypes editMode;
var Int          itemAugsOffsetX;
var Int          itemAugsOffsetY;

var HUDActiveAugsBorder  winAugsContainer;
var HUDActiveItemsBorder winItemsContainer;

//Madders additions.
var Int          itemSmellsOffsetX;
var Int          itemSmellsOffsetY;
var HUDActiveSmellsBorder winSmellsContainer;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	CreateContainerWindows();

	Hide();
}

// ----------------------------------------------------------------------
// CreateContainerWindows()
// ----------------------------------------------------------------------

function CreateContainerWindows()
{
	winAugsContainer  = HUDActiveAugsBorder(NewChild(Class'HUDActiveAugsBorder'));
	winItemsContainer = HUDActiveItemsBorder(NewChild(Class'HUDActiveItemsBorder'));
	//winSmellsContainer = HUDActiveSmellsBorder(NewChild(Class'HUDActiveSmellsBorder'));
}

// ----------------------------------------------------------------------
// AddIcon()
// ----------------------------------------------------------------------

function AddIcon(Texture newIcon, Object saveObject)
{
	local HUDActiveItem activeItem;
	
	if (saveObject.IsA('Augmentation'))
		winAugsContainer.AddIcon(newIcon, saveObject);
	//else if (SaveObject.IsA('VMDSmellManager'))
	//	winSmellsContainer.AddIcon(newIcon, saveObject);
	else
		winItemsContainer.AddIcon(newIcon, saveObject);
	
	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// RemoveIcon()
// ----------------------------------------------------------------------

function RemoveIcon(Object removeObject)
{
	if (removeObject.IsA('Augmentation'))
		winAugsContainer.RemoveObject(removeObject);
	//else if (removeObject.IsA('VMDSmellManager'))
	//	winSmellsContainer.RemoveObject(removeObject);
	else
		winItemsContainer.RemoveObject(removeObject);
	
	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// UpdateAugIconStatus()
// ----------------------------------------------------------------------

function UpdateAugIconStatus(Augmentation aug)
{
	winAugsContainer.UpdateAugIconStatus(aug);
}

// ----------------------------------------------------------------------
// ClearAugmentationDisplay()
// ----------------------------------------------------------------------

function ClearAugmentationDisplay()
{
	winAugsContainer.ClearAugmentationDisplay();
}

// ----------------------------------------------------------------------
// UpdateSmellIconStatus()
// ----------------------------------------------------------------------

function UpdateSmellIconStatus(VMDSmellManager Smell)
{
	//winSmellsContainer.UpdateSmellIconStatus(Smell);
}

// ----------------------------------------------------------------------
// ClearSmellDisplay()
// ----------------------------------------------------------------------

function ClearSmellDisplay()
{
	//winSmellsContainer.ClearSmellDisplay();
}

// ----------------------------------------------------------------------
// SetVisibility()
//
// Only show if one or more icons is being displayed
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	Show(bNewVisibility);

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
	local float augsWidth, augsHeight;
	local float itemsWidth, itemsHeight;
	local float SmellsWidth, SmellsHeight;
	
	winAugsContainer.QueryPreferredSize(augsWidth, augsHeight);
	winItemsContainer.QueryPreferredSize(itemsWidth, itemsHeight);
	//winSmellsContainer.QueryPreferredSize(SmellsWidth, SmellsHeight);
	
	preferredWidth  = augsWidth + itemsWidth + SmellsWidth;
	preferredHeight = augsHeight + itemsHeight + SmellsHeight;
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
// ----------------------------------------------------------------------

function ConfigurationChanged()
{
	local float augsWidth, augsHeight;
	local float itemsWidth, itemsHeight;
	local float SmellsWidth, SmellsHeight;
	local float itemPosX;
	
	//Madders. Hacky.
	local float AddFactor, FinalAddFactor;
	
	if (winItemsContainer != None)
	{
		winItemsContainer.QueryPreferredSize(itemsWidth, itemsHeight);
		itemPosX = 0;
	}
	
	// Position the two windows
	if ((winAugsContainer != None) && (winAugsContainer.iconCount > 0))
	{
		winAugsContainer.QueryPreferredSize(augsWidth, augsHeight);
		winAugsContainer.ConfigureChild(itemsWidth, 0, augsWidth, augsHeight);
		
		itemPosX = itemsWidth + itemAugsOffsetX;
		AddFactor = ItemAugsOffsetX;
	}
	
	/*if ((winSmellsContainer != None) && (winSmellsContainer.iconCount > 0))
	{
		winSmellsContainer.QueryPreferredSize(SmellsWidth, SmellsHeight);
		winSmellsContainer.ConfigureChild(itemsWidth+AugsWidth, 0, SmellsWidth, SmellsHeight);
		itemPosX = ItemsWidth + AddFactor; // + ItemSmellsOffsetX
	}*/
	
	// Now that we know where the Augmentation window is, position
	// the Items window

	if (winItemsContainer != None)
	{
		// First check to see if there's enough room underneat the augs display 
		// to show the active items.
		//if ((augsHeight + itemsHeight) > height)
		//+itemSmellsOffsetX
		//	winItemsContainer.ConfigureChild(itemAugsOffsetX, itemAugsOffsetY+itemSmellsOffsetY, itemsWidth, itemsHeight);
		//else
			winItemsContainer.ConfigureChild(itemPosX, augsHeight - 2, itemsWidth, itemsHeight);
	}
}

// ----------------------------------------------------------------------
// ChildRequestedReconfiguration()
// ----------------------------------------------------------------------

event bool ChildRequestedReconfiguration(window childWin)
{
	return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     itemAugsOffsetX=14
     itemAugsOffsetY=6
     itemSmellsOffsetX=0     //14
     itemSmellsOffsetY=0     //6
}
