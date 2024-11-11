//=============================================================================
// FordSchick.
//=============================================================================
class FordSchick extends HumanCivilian;

var float FordFixTimer;

//MADDERS, 1/25/23: Bullshit barf fix for 08 smug needing the convos updated every load game.
function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	VMDConvoBindHook();
}

function VMDConvoBindHook()
{
	Super.VMDConvoBindHook();
	FordFixTimer = 1.0;
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (FordFixTimer > 0)
	{
		FordFixTimer -= DT;
	}
	else if (FordFixTimer < 0)
	{
		CommitFordFix();
		FordFixTimer = 0;
	}
}

function CommitFordFix()
{
	switch(VMDGetMapName())
	{
		//08_NYC_SMUG: LDDP convo base fix for the augumentation upgrade, courtesy of the boys at DX Rando
		case "08_NYC_SMUG":
		        class'VMDMapFixer'.Static.FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        		class'VMDMapFixer'.Static.FixConversationGiveItem(GetConversation('FemJCM08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
		break;
	}
}

//Ugly, but can't be static because iterator.
function Conversation GetConversation(Name conName)
{
    	local Conversation c;
	
    	foreach AllObjects(class'Conversation', c)
	{
        	if(c.conName == conName) return c;
    	}
	
    	return None;
}

defaultproperties
{
     CarcassType=Class'DeusEx.FordSchickCarcass'
     WalkingSpeed=0.213333
     bImportant=True
     BaseAssHeight=-23.000000
     GroundSpeed=180.000000
     Mesh=LodMesh'DeusExCharacters.GM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.FordSchickTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.FordSchickTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.PantsTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.FordSchickTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.FordSchickTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.FordSchickTex2'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="FordSchick"
     FamiliarName="Ford Schick"
     UnfamiliarName="Ford Schick"
     NameArticle=" "
}
