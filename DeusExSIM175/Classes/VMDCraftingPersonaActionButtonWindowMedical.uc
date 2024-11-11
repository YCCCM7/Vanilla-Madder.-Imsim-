//=============================================================================
// VMDCraftingPersonaActionButtonWindowMedical
//=============================================================================
class VMDCraftingPersonaActionButtonWindowMedical extends PersonaActionButtonWindow;

var Class<Inventory> CraftClass;
var int ChemicalsCost;
var bool bMetComplexity;

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Left_Textures(0)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonNormal_Left',Width=4)
     Left_Textures(1)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonPressed_Left',Width=4)
     Right_Textures(0)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonNormal_Right',Width=8)
     Right_Textures(1)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonPressed_Right',Width=8)
     Center_Textures(0)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonNormal_Center',Width=2)
     Center_Textures(1)=(Tex=Texture'DeusExUI.UserInterface.PersonaActionButtonPressed_Center',Width=2)
     buttonHeight=16
     minimumButtonWidth=20
}
