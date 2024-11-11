//=============================================================================
// HUDActiveSmellsBorder
//=============================================================================
class HUDActiveSmellsBorder extends HUDActiveItemsBorderBase;

var String SmellTypes[8];

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	// Create *ALL* the icons, but hide them.
	CreateIcons();
}

// ----------------------------------------------------------------------
// CreateIcons()
// ----------------------------------------------------------------------

function CreateIcons()
{
	local int SmellsIndex;
	local HUDActiveSmell iconWindow;
	
	for(SmellsIndex=0; SmellsIndex<=ArrayCount(SmellTypes); SmellsIndex++)
	{
		iconWindow = HUDActiveSmell(winIcons.NewChild(Class'HUDActiveSmell'));
		iconWindow.SetSmellType(SmellTypes[SmellsIndex]);
		iconWindow.Hide();
	}
}

// ----------------------------------------------------------------------
// ClearSmellDisplay()
// ----------------------------------------------------------------------

function ClearSmellDisplay()
{
	local Window currentWindow;
	local Window foundWindow;
	
	// Loop through all our children and check to see if 
	// we have a match.
	
	currentWindow = winIcons.GetTopChild();
	while(currentWindow != None)
	{
		currentWindow.Hide();
      		currentWindow.SetClientObject(None);
		currentWindow = currentWindow.GetLowerSibling();
	}
	
	iconCount = 0;
}

function VMDBufferPlayer BuffPlayer()
{
	return VMDBufferPlayer(GetPlayerPawn());
}

// ----------------------------------------------------------------------
// AddIcon()
//
// Find the appropriate 
// ----------------------------------------------------------------------

function AddIcon(Texture newIcon, Object saveObject)
{
	local HUDActiveSmell SmellItem;
	
	SmellItem = FindSmellWindowByType(VMDSmellManager(saveObject).SmellType);
	
	if (SmellItem != None)
	{
		SmellItem.SetIcon(newIcon);
		SmellItem.SetClientObject(saveObject);
		SmellItem.SetObject(saveObject);
		SmellItem.Show();
		
		// Hide if there are no icons visible
		if (++iconCount == 1)
			Show();
		
		AskParentForReconfigure();
	}
}

// ----------------------------------------------------------------------
// RemoveObject()
// ----------------------------------------------------------------------

function RemoveObject(Object removeObject)
{
	local HUDActiveSmell SmellItemWindow;
	
	SmellItemWindow = FindSmellWindowByType(VMDSmellManager(removeObject).SmellType);
	
	if (SmellItemWindow != None)
	{
		SmellItemWindow.Hide();
      		SmellItemWindow.SetClientObject(None);
		
		// Hide if there are no icons visible
		if (--iconCount == 0)
			Hide();
		
		AskParentForReconfigure();
	}
}

function HUDActiveSmell FindSmellWindowByType(String SmellType)
{
	local Window currentWindow;
	local Window foundWindow;
	
	// Loop through all our children and check to see if 
	// we have a match.
	
	currentWindow = winIcons.GetTopChild(False);
	
	while(currentWindow != None)
	{
		if (HUDActiveSmell(currentWindow).SmellType ~= SmellType)
		{
			foundWindow = currentWindow;
			break;
		}
		currentWindow = currentWindow.GetLowerSibling(False);
	}
	
	return HUDActiveSmell(foundWindow);
}

// ----------------------------------------------------------------------
// UpdateSmellIconStatus()
// ----------------------------------------------------------------------

function UpdateSmellIconStatus(VMDSmellManager Smell)
{
	local HUDActiveSmell iconWindow;
	
	// First make sure this object isn't already in the window
	iconWindow = HUDActiveSmell(winIcons.GetTopChild());
	while(iconWindow != None)
	{
		// Abort if this object already exists!!
		if (iconWindow.GetClientObject() == Smell)
		{
			iconWindow.UpdateSmellIconStatus();
			break;
		}
		iconWindow = HUDActiveSmell(iconWindow.GetLowerSibling());
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     SmellTypes(0)="PlayerSmell"
     SmellTypes(1)="PlayerAnimalSmell"
     SmellTypes(2)="PlayerFoodSmell"
     SmellTypes(3)="StrongPlayerFoodSmell"
     SmellTypes(4)="PlayerBloodSmell"
     SmellTypes(5)="StrongPlayerBloodSmell"
     texBorderTop=Texture'DeusExUI.UserInterface.HUDAugmentationsBorder_Top'
     texBorderCenter=Texture'DeusExUI.UserInterface.HUDAugmentationsBorder_Center'
     texBorderBottom=Texture'DeusExUI.UserInterface.HUDAugmentationsBorder_Bottom'
     borderTopMargin=13
     borderBottomMargin=9
     borderWidth=62
     topHeight=37
     topOffset=26
     bottomHeight=32
     bottomOffset=28
     tilePosX=20
     tilePosY=13
}
