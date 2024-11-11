//=============================================================================
// VMDFakePatrolPoint.
//=============================================================================
class VMDFakePatrolPoint extends Actor;

var int MyArray, FamilySize;
var float UniversalFlashTimer, FlashTimeMin, FlashTimeMax;
var Texture LitTexture, UnlitTexture;

var VMDFakePatrolPoint PreviousPatrol, NextPatrol;
var VMDBufferPlayer OrderPlayer;

function Tick(float DT)
{
	Super.Tick(DT);
	
	if ((OrderPlayer != None) && (OrderPlayer.bEpilepsyReduction))
	{
		Texture = LitTexture;
	}
	else
	{
		UniversalFlashTimer = (UniversalFlashTimer+DT) % 1.0;
		
		if ((UniversalFlashTimer > FlashTimeMin) && (UniversalFlashTimer < FlashTimeMax))
		{
			if (Texture == UnlitTexture)
			{
				Texture = LitTexture;
			}
		}
		else
		{
			if (Texture == LitTexture)
			{
				Texture = UnlitTexture;
			}
		}
	}
}

function AddNewFamilyMember(VMDFakePatrolPoint NewMember)
{
	if (NewMember == None) return;
	
	FamilySize++;
	if (NextPatrol == None)
	{
		PreviousPatrol = NewMember;
		NextPatrol = NewMember;
		
		NewMember.NextPatrol = Self;
		NewMember.PreviousPatrol = Self;
		NewMember.MyArray = MyArray+1;
		NewMember.FamilySize = FamilySize;
		
		NewMember.UniversalFlashTimer = UniversalFlashTimer;
	}
	else if (NextPatrol.MyArray == 0)
	{
		NewMember.NextPatrol = NextPatrol;
		NewMember.PreviousPatrol = Self;
		NewMember.MyArray = MyArray+1;
		NewMember.FamilySize = FamilySize;
		
		NewMember.UniversalFlashTimer = UniversalFlashTimer;
		
		NextPatrol.PreviousPatrol = NewMember;
		NextPatrol = NewMember;
	}
}

defaultproperties
{
     bCollideWhenPlacing=True
     CollisionRadius=12.000000
     CollisionHeight=15.000000
     
     LitTexture=Texture'VMDPatrolPointerLit'
     UnlitTexture=Texture'VMDPatrolPointer'
     FamilySize=1
     FlashTimeMin=0.000000
     FlashTimeMax=1.000000
     
     bNoSmooth=True
     bAlwaysRelevant=True
     bUnlit=True
     Texture=Texture'VMDPatrolPointer'
     SoundVolume=128
     DrawScale=0.250000
     bStatic=False
     bHidden=False
}
