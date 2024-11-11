//=============================================================================
// VMDSkillAugmentGemInvisible
//=============================================================================
class VMDSkillAugmentGemInvisible extends VMDSkillAugmentGem;

function SetSkillData(string NewSkillAugmentID, string NewSkillAugmentName, string NewSkillAugmentDesc, int NewSkillLevel, int NewSecondarySkillLevel, int NewPageNumber)
{
	Right_Textures[0].Tex = None;
	Right_Textures[1].Tex = None;
}

function SetSkillData2(class<Skill> NewSkillType, class<Skill> NewSecondarySkillType, string NewSkillTypeStr)
{
  	GemBorder.SetBackground(None);
}

function UpdateSkillIcons(int LockedBoughtHigh)
{
	Right_Textures[0].Tex = None;
	Right_Textures[1].Tex = None;
}

function UpdateCheckOverlay(bool bBought)
{
	GemOverlay.SetBackground(None);
}

defaultproperties
{
     buttonHeight=0
     minimumButtonWidth=0
     Right_Textures(0)=(Tex=None,Width=0)
     Right_Textures(1)=(Tex=None,Width=0)
}
