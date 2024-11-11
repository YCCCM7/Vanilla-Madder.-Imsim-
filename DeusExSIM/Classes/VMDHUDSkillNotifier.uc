//=============================================================================
// VMDHUDSkillNotifier.
//=============================================================================
class VMDHUDSkillNotifier extends HUDBaseWindow;

var int CurrentFrame[11], LastUIScale;
var float ShowTime, AnimRate, SwipeProgress[11];
var string LastRes;
var Texture SkillTextures[11], AnimFrames[23];

var Window SkillIcons[11];
var VMDBufferPlayer VMP;
var VMDStylizedWindow AnimatedOverlays[11];

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local int i;
	
	Super.InitWindow();
	
	GetVMP();
	
	SetSize(32, 308);
	
	SetBackgroundStyle(DSTY_Translucent);
	SetBackground(None);
	
	for(i=0; i<ArrayCount(SkillIcons); i++)
	{
		SkillIcons[i] = NewChild(class'Window');
		SkillIcons[i].SetBackgroundStyle(DSTY_Translucent);
		SkillIcons[i].SetBackground(SkillTextures[i]);
		SkillIcons[i].SetPos(4, 4 + (28*i));
		SkillIcons[i].SetSize(0,24);
		AnimatedOverlays[i] = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		AnimatedOverlays[i].SetBackground(AnimFrames[0]);
		AnimatedOverlays[i].SetPos(0, 28*i);
		AnimatedOverlays[i].SetSize(0, 32);
		AnimatedOverlays[i].bBlockTranslucency = true;
		AnimatedOverlays[i].StyleChanged();
	}
	
	AddTimer(AnimRate, true,, 'UpdateAnimations');
}

function VMDBufferPlayer GetVMP()
{
	if (VMP != None)
	{
		return VMP;
	}
	
	VMP = VMDBufferPlayer(Player);
	return VMP;
}

function ShowIcon(class<Skill> TClass)
{
	local int TIndex;
	
	switch(TClass.Name)
	{
		case 'SkillSwimming': TIndex = 0; break;
		case 'SkillEnviro': TIndex = 1; break;
		case 'SkillWeaponLowTech': TIndex = 2; break;
		case 'SkillWeaponPistol': TIndex = 3; break;
		case 'SkillWeaponRifle': TIndex = 4; break;
		case 'SkillLockpicking': TIndex = 5; break;
		case 'SkillTech': TIndex = 6; break;
		case 'SkillDemolition': TIndex = 7; break;
		case 'SkillMedicine': TIndex = 8; break;
		case 'SkillComputer': TIndex = 9; break;
		case 'SkillWeaponHeavy': TIndex = 10; break;
	}
	
	if (VMP.SkillNotifierDisplayTimes[TIndex] <= 0)
	{
		CurrentFrame[TIndex] = 0;
	}
	VMP.SkillNotifierDisplayTimes[TIndex] = ShowTime;
}

function UpdateAnimations()
{
	local int i, ResX, ResWidth, ResHeight, UIScale;
	local float TWidth, THeight;
	local string CurRes;
	
	//MADDERS, 11/11/24: We need to move ourselves around a little better now. Ugly, I know.
	CurRes = VMP.ConsoleCommand("GetCurrentRes");
	
	if (VMP.Level.Pauser != "")
	{
		ResX = InStr(CurRes,"x");
		ResWidth = int(Left(CurRes, ResX)) / VMP.CustomUIScale;
		ResHeight = int(Right(CurRes,Len(CurRes)-ResX-1)) / VMP.CustomUIScale;
		
		SetPos(ResWidth * 0.5 - 360, ResHeight*0.5 - 154);
		
		LastUIScale = -10;
	}
	else if (VMP.IsInState('Conversation'))
	{
		ResX = InStr(CurRes,"x");
		ResWidth = int(Left(CurRes, ResX)) / VMP.CustomUIScale;
		ResHeight = int(Right(CurRes,Len(CurRes)-ResX-1)) / VMP.CustomUIScale;
		
		SetPos(24, ResHeight*0.5 - 154);
		
		LastUIScale = -10;
	}
	else if (CurRes != LastRes || LastUIScale != VMP.CustomUIScale)
	{
		ResX = InStr(CurRes,"x");
		ResWidth = int(Left(CurRes, ResX)) / VMP.CustomUIScale;
		ResHeight = int(Right(CurRes,Len(CurRes)-ResX-1)) / VMP.CustomUIScale;
		
		SetPos(ResWidth*0.5 - 160, ResHeight*0.5 - 154);
		
		LastUIScale = VMP.CustomUIScale;
		LastRes = CurRes;
	}
	
	Show(VMP.bSkillNotifierVisible);
	
	for(i=0; i<ArrayCount(SkillIcons); i++)
	{
		if (VMP.SkillNotifierDisplayTimes[i] > 0)
		{
			VMP.SkillNotifierDisplayTimes[i] = FMax(-0.1, VMP.SkillNotifierDisplayTimes[i] - AnimRate);
			if (SwipeProgress[i] < 32)
			{
				SwipeProgress[i] += 1.0;
				SkillIcons[i].SetSize(FClamp(SwipeProgress[i]-4.0, 0.0, 24.0), 24);
				AnimatedOverlays[i].SetSize(SwipeProgress[i], 32);
			}
			CurrentFrame[i] = (CurrentFrame[i] + 1) % ArrayCount(AnimFrames);
			AnimatedOverlays[i].SetBackground(AnimFrames[CurrentFrame[i]]);
		}
		else
		{
			if (SwipeProgress[i] > 0)
			{
				SwipeProgress[i] -= 1.0;
				SkillIcons[i].SetSize(FClamp(SwipeProgress[i]-4.0, 0.0, 24.0), 24);
				AnimatedOverlays[i].SetSize(SwipeProgress[i], 32);
				
				CurrentFrame[i] = (CurrentFrame[i] + 1) % ArrayCount(AnimFrames);
				AnimatedOverlays[i].SetBackground(AnimFrames[CurrentFrame[i]]);
			}
		}
	}
}

defaultproperties
{
     ShowTime=5.000000
     AnimRate=0.021500
     SkillTextures(0)=Texture'DeusExUI.UserInterface.SkillIconSwimming'
     SkillTextures(1)=Texture'DeusExUI.UserInterface.SkillIconEnviro'
     SkillTextures(2)=Texture'DeusExUI.UserInterface.SkillIconWeaponLowTech'
     SkillTextures(3)=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol'
     SkillTextures(4)=Texture'VMDAssets.SkillIconWeaponRifleFixed'
     SkillTextures(5)=Texture'DeusExUI.UserInterface.SkillIconLockPicking'
     SkillTextures(6)=Texture'VMDAssets.SkillIconTechFixed'
     SkillTextures(7)=Texture'DeusExUI.UserInterface.SkillIconDemolition'
     SkillTextures(8)=Texture'DeusExUI.UserInterface.SkillIconMedicine'
     SkillTextures(9)=Texture'DeusExUI.UserInterface.SkillIconComputer'
     SkillTextures(10)=Texture'DeusExUI.UserInterface.SkillIconWeaponHeavy'
     AnimFrames(0)=Texture'VMDSkillNotifierOverlayFrame00'
     AnimFrames(1)=Texture'VMDSkillNotifierOverlayFrame01'
     AnimFrames(2)=Texture'VMDSkillNotifierOverlayFrame02'
     AnimFrames(3)=Texture'VMDSkillNotifierOverlayFrame03'
     AnimFrames(4)=Texture'VMDSkillNotifierOverlayFrame04'
     AnimFrames(5)=Texture'VMDSkillNotifierOverlayFrame05'
     AnimFrames(6)=Texture'VMDSkillNotifierOverlayFrame06'
     AnimFrames(7)=Texture'VMDSkillNotifierOverlayFrame07'
     AnimFrames(8)=Texture'VMDSkillNotifierOverlayFrame08'
     AnimFrames(9)=Texture'VMDSkillNotifierOverlayFrame09'
     AnimFrames(10)=Texture'VMDSkillNotifierOverlayFrame10'
     AnimFrames(11)=Texture'VMDSkillNotifierOverlayFrame11'
     AnimFrames(12)=Texture'VMDSkillNotifierOverlayFrame12'
     AnimFrames(13)=Texture'VMDSkillNotifierOverlayFrame13'
     AnimFrames(14)=Texture'VMDSkillNotifierOverlayFrame14'
     AnimFrames(15)=Texture'VMDSkillNotifierOverlayFrame15'
     AnimFrames(16)=Texture'VMDSkillNotifierOverlayFrame16'
     AnimFrames(17)=Texture'VMDSkillNotifierOverlayFrame17'
     AnimFrames(18)=Texture'VMDSkillNotifierOverlayFrame18'
     AnimFrames(19)=Texture'VMDSkillNotifierOverlayFrame19'
     AnimFrames(20)=Texture'VMDSkillNotifierOverlayFrame20'
     AnimFrames(21)=Texture'VMDSkillNotifierOverlayFrame21'
     AnimFrames(22)=Texture'VMDSkillNotifierOverlayFrame22'
}
