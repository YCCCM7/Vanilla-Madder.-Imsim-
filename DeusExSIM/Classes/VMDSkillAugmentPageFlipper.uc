//=============================================================================
// VMDSkillAugmentPageFlipper
//=============================================================================
class VMDSkillAugmentPageFlipper extends PersonaBorderButtonWindow;

var bool bNext, bSkillPage;
var int NextPage;

var Texture DefBackward[2], DefForward[2];

function UpdateTex(optional bool bHighlight)
{
 	if (!bHighlight)
 	{
  		if (!bNext)
  		{
   			Right_Textures[0].Tex = DefBackward[0];
   			Right_Textures[1].Tex = DefBackward[1];
  		}
  		else
  		{
   			Right_Textures[0].Tex = DefForward[0];
   			Right_Textures[1].Tex = DefForward[1];
  		}
 	}
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetWidth(16);
}

// ----------------------------------------------------------------------
// SetSkill()
// ----------------------------------------------------------------------

function SetSkillPage(bool NewbNext, bool NewbSkillPage, int NewNextPage)
{
	bNext = NewbNext;
	bSkillPage = NewbSkillPage;
	NextPage = NewNextPage;
	UpdateTex(False);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'SkillAugmentPageBackward',Width=16)
     Right_Textures(1)=(Tex=Texture'SkillAugmentPageBackward',Width=16)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     //MADDERS: Flip these for the sake of standing out.
     DefBackward(0)=Texture'SkillAugmentPageBackwardHighlight'
     DefBackward(1)=Texture'SkillAugmentPageBackward'
     DefForward(0)=Texture'SkillAugmentPageForwardHighlight'
     DefForward(1)=Texture'SkillAugmentPageForward'
     fontButtonText=Font'DeusExUI.FontMenuTitle'
     buttonHeight=80
     minimumButtonWidth=16
}
