//=============================================================================
// VMDSkillAugmentTreeBranch
//=============================================================================
class VMDSkillAugmentTreeBranch extends Window;

var int PageNumber;
var Texture TreeTypes[2];

function SetTreeData(string LoadID, int NewPageNumber, bool bBought)
{
	local Texture T;
	
	if (InStr(LoadID, ".") <= 0)
	{
		LoadID = "VMDAssets."$LoadID;
		//LoadID = "DeusEx."$LoadID;
	}
	
	T = Texture(DynamicLoadObject(LoadID, class'Texture', true));
	TreeTypes[0] = T;
	T = Texture(DynamicLoadObject(LoadID$"Highlight", class'Texture', true));
	TreeTypes[1] = T;
	
	PageNumber = NewPageNumber;
	UpdateTexture(bBought);
}

function UpdateTexture(bool bBought)
{
	SetBackground(TreeTypes[int(bBought)]);
}

defaultproperties
{
}
