//=============================================================================
// ShowClassWindow
//=============================================================================
class ShowClassWindow expands ToolWindow;

// Class Name edit box
var ToolEditWindow editClassName;
var ToolEditWindow editCustomProp;

// Checkboxes
var ToolCheckboxWindow	chkEyes;
var ToolCheckboxWindow	chkArea;
var ToolCheckboxWindow	chkCylinder;
var ToolCheckboxWindow	chkMesh;
var ToolCheckboxWindow	chkLOS;
var ToolCheckboxWindow	chkVisibility;
var ToolCheckboxWindow	chkState;
var ToolCheckboxWindow	chkLight;
var ToolCheckboxWindow	chkDist;
var ToolCheckboxWindow	chkPos;
var ToolCheckboxWindow	chkHealth;

var ToolCheckboxWindow	chkZone;
var ToolCheckboxWindow	chkEnemy;
var ToolCheckboxWindow	chkInstigator;
var ToolCheckboxWindow	chkBase;
var ToolCheckboxWindow	chkOwner;
var ToolCheckboxWindow	chkBindName;
var ToolCheckboxWindow	chkLastRendered;
var ToolCheckboxWindow	chkMass;
var ToolCheckboxWindow	chkPhysics;
var ToolCheckboxWindow	chkVelocity;
var ToolCheckboxWindow	chkAccel;
var ToolCheckboxWindow	chkResponse;
var ToolCheckboxWindow	chkData;
var ToolCheckboxWindow	chkNeatNames;
var ToolCheckboxWindow	chkCustom;

// Buttons
var ToolButtonWindow btnCancel;  
var ToolButtonWindow btnOK;  

// Actor DisplayWindow
var ActorDisplayWindow actorDisplay;

var localized string strEyes, strArea, strCylinder, strMesh, strLOS, strVisibility, strState, strLight, strDist, strPos, strHealth, strZone, strEnemy, strInstigator, strBase, strOwner, strBindName, strLastRendered, strMass, strPhysics, strVelocity, strAccel, strResponse, strData, strNeatNames, strOK, strCancel, strTitle, strCurrentClass, strCustom, strCustomProp;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	local String displayClass;

	Super.InitWindow();

	// Center this window	
	SetSize(400, 445);
	SetTitle(strTitle);

	// Get a pointer to the ActorDisplayWindow
	actorDisplay = root.actorDisplay;

	// Create the controls
	CreateControls();

	// Set focus to the edit control and highlight the text in it.
	if ( actorDisplay.GetViewClass() != None )
	{
		displayClass = String(actorDisplay.GetViewClass());
		editClassName.SetText(displayClass);
		editClassName.SetInsertionPoint(Len(displayClass) - 1);
		editClassName.SetSelectedArea(0, Len(displayClass));
	}
	editCustomProp.SetText(actorDisplay.customProp);
	SetFocusWindow(editClassName);
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	// Labels
	CreateToolLabel(18, 30, strCurrentClass);
	CreateToolLabel(218, 30, strCustomProp);

	// Edit Control
	editClassName       = CreateToolEditWindow(15, 50, 185, 64);
	editCustomProp      = CreateToolEditWindow(215, 50, 150, 64);

	// Checkboxes
	chkEyes			= CreateToolCheckbox(15, 90,  strEyes, actorDisplay.AreEyesVisible());
	chkArea			= CreateToolCheckbox(15, 115, strArea, actorDisplay.IsAreaVisible());
	chkCylinder		= CreateToolCheckbox(15, 140, strCylinder, actorDisplay.IsCylinderVisible());
	chkMesh			= CreateToolCheckbox(15, 165, strMesh, actorDisplay.IsMeshVisible());
	chkLOS          = CreateToolCheckbox(15, 190, strLOS, actorDisplay.IsLOSVisible());
	chkVisibility   = CreateToolCheckbox(15, 215, strVisibility, actorDisplay.IsVisibilityVisible());
	chkState        = CreateToolCheckbox(15, 240, strState, actorDisplay.IsStateVisible());
	chkLight        = CreateToolCheckbox(15, 265, strLight, actorDisplay.IsLightVisible());
	chkDist         = CreateToolCheckbox(15, 290, strDist, actorDisplay.IsDistVisible());
	chkPos          = CreateToolCheckbox(15, 315, strPos, actorDisplay.IsPosVisible());
	chkHealth       = CreateToolCheckbox(15, 340, strHealth, actorDisplay.IsHealthVisible());
	chkData			= CreateToolCheckbox(15, 365, strData, actorDisplay.IsDataVisible());
	chkCustom		= CreateToolCheckbox(15, 390, strCustom, actorDisplay.IsCustomVisible());
	chkNeatNames	= CreateToolCheckbox(15, 415, strNeatNames, actorDisplay.IsNeatNameVisible());

	chkZone			= CreateToolCheckbox(215, 90,  strZone, actorDisplay.IsZoneVisible());
	chkEnemy		= CreateToolCheckbox(215, 115, strEnemy, actorDisplay.IsEnemyVisible());
	chkInstigator	= CreateToolCheckbox(215, 140, strInstigator, actorDisplay.IsInstigatorVisible());
	chkBase			= CreateToolCheckbox(215, 165, strBase, actorDisplay.IsBaseVisible());
	chkOwner        = CreateToolCheckbox(215, 190, strOwner, actorDisplay.IsOwnerVisible());
	chkBindName   	= CreateToolCheckbox(215, 215, strBindName, actorDisplay.IsBindNameVisible());
	chkLastRendered = CreateToolCheckbox(215, 240, strLastRendered, actorDisplay.IsLastRenderedVisible());
	chkMass	        = CreateToolCheckbox(215, 265, strMass, actorDisplay.IsMassVisible());
	chkPhysics	    = CreateToolCheckbox(215, 290, strPhysics, actorDisplay.ArePhysicsVisible());
	chkVelocity     = CreateToolCheckbox(215, 315, strVelocity, actorDisplay.IsVelocityVisible());
	chkAccel        = CreateToolCheckbox(215, 340, strAccel, actorDisplay.IsAccelerationVisible());
	chkResponse		= CreateToolCheckbox(215, 365, strResponse, actorDisplay.IsEnemyResponseVisible());

	// Buttons
	btnOK     = CreateToolButton(203,  403, strOK);
	btnCancel = CreateToolButton(300, 403, strCancel);
}


// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
		case btnOK:
			SaveSettings();
			root.PopWindow();
			break;

		case btnCancel:
			root.PopWindow();
			break;

		default:
			bHandled = False;
			break;
	}

	if ( !bHandled ) 
		bHandled = Super.ButtonActivated( buttonPressed );

	return bHandled;
}

// ----------------------------------------------------------------------
// EditActivated()
//
// Allow the user to press [Return] to accept the name
// ----------------------------------------------------------------------

event bool EditActivated(window edit, bool bModified)
{
	SaveSettings();
	root.PopWindow();
	return True;
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	if ( editClassName.GetText() == "" )
		actorDisplay.SetViewClass(None);
	else
		// let UnrealScript parse the class name for us
		GetPlayerPawn().ConsoleCommand("ShowClass "$editClassName.GetText());

	actorDisplay.ShowEyes(chkEyes.GetToggle());
	actorDisplay.ShowArea(chkArea.GetToggle());
	actorDisplay.ShowCylinder(chkCylinder.GetToggle());
	actorDisplay.ShowMesh(chkMesh.GetToggle());
	actorDisplay.ShowLOS(chkLOS.GetToggle());
	actorDisplay.ShowVisibility(chkVisibility.GetToggle());
	actorDisplay.ShowState(chkState.GetToggle());
	actorDisplay.ShowLight(chkLight.GetToggle());
	actorDisplay.ShowDist(chkDist.GetToggle());
	actorDisplay.ShowPos(chkPos.GetToggle());
	actorDisplay.ShowHealth(chkHealth.GetToggle());
	
	actorDisplay.ShowZone(chkZone.GetToggle());
	actorDisplay.ShowEnemy(chkEnemy.GetToggle());
	actorDisplay.ShowInstigator(chkInstigator.GetToggle());
	actorDisplay.ShowBase(chkBase.GetToggle());
	actorDisplay.ShowOwner(chkOwner.GetToggle());
	actorDisplay.ShowBindName(chkBindName.GetToggle());
	actorDisplay.ShowLastRendered(chkLastRendered.GetToggle());
	actorDisplay.ShowMass(chkMass.GetToggle());
	actorDisplay.ShowPhysics(chkPhysics.GetToggle());
	actorDisplay.ShowVelocity(chkVelocity.GetToggle());
	actorDisplay.ShowAcceleration(chkAccel.GetToggle());
	actorDisplay.ShowEnemyResponse(chkResponse.GetToggle());
	actorDisplay.ShowData(chkData.GetToggle());
	actorDisplay.ShowNeatNames(chkNeatNames.GetToggle());
	actorDisplay.ShowCustomProp(chkCustom.GetToggle());
	
	actorDisplay.customProp = editCustomProp.GetText();
}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     strEyes="Show |&Eyes"
     strArea="Show |&Area"
     strCylinder="Show C|&ylinder"
     strMesh="Show |&Mesh"
     strLOS="Show Line o|&f Sight"
     strVisibility="Show |&Visibility"
     strState="Sho|&w State"
     strLight="Show Li|&ght Level"
     strDist="Show |&Distance"
     strPos="Show |&Position"
     strHealth="Show |&Health"
     strZone="Show |&Zone"
     strEnemy="Show Enemy (|&J)"
     strInstigator="Show |&Instigator"
     strBase="Show |&Base"
     strOwner="Show Owner (|&K)"
     strBindName="Show Bind Name (|&Q)"
     strLastRendered="Show |&Last Rendered"
     strMass="Show Ma|&ss"
     strPhysics="Show Physics (|&U)"
     strVelocity="Show Velocity (|&X)"
     strAccel="Show Accelera|&tion"
     strResponse="Show Enemy |&Response"
     strData="Show Data (|&0)"
     strNeatNames="Show |&Neat Names"
     strCustom="Show Custom (|&#)"
     strOK="|&OK"
     strCancel="|&Cancel"
     strTitle="Show Class"
     strCurrentClass="Current View Class:"
     strCustomProp="Custom Property:"
}
