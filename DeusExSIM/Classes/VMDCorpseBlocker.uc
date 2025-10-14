//=============================================================================
// VMDCorpseBlocker.
//=============================================================================
class VMDCorpseBlocker extends VMDBufferDeco;

var float TargetRadius, TargetHeight, StartingRadius, StartingHeight;

function Tick(float DT)
{
	local bool bCenteredDeath;
	local float InvTime, ColDiff;
	local VMDBufferPawn VMBP;
	
	Super.Tick(DT);
	
	VMBP = VMDBufferPawn(Owner);
	if (VMBP != None)
	{
		InvTime = 1.0 - VMBP.AnimFrame;
		//SetCollisionSize((TargetRadius * AnimFrame) + (StartingRadius * InvTime), (TargetHeight * AnimFrame) + (StartingHeight * InvTime));
		SetCollisionSize(StartingRadius, (TargetHeight * AnimFrame) + (StartingHeight * InvTime));
		if (!bCenteredDeath)
		{
			ColDiff = CollisionHeight - StartingHeight;
			SetLocation(VMBP.Location + (Vect(0, 0, 1) * ColDiff));
		}
	}
	else if (!bDeleteMe)
	{
		Destroy();
	}
}

function string VMDGetItemName()
{
	local string Ret;
	local VMDBufferPawn VMBP;
	local VMDBufferPlayer VMP;
	
	VMBP = VMDBufferPawn(Owner);
	if (VMBP != None)
	{
		Ret = VMBP.UnfamiliarName;
		
		VMP = VMBP.GetLastVMP();
		if (VMBP != None)
		{
			Ret = VMP.GetDisplayName(VMBP);
		}
	}
	
	return Ret;
}

//MADDERS, 8/26/25: Similarly, no. Stop fucking up our collision params.
singular function BaseChange()
{
}

//MADDERS, 3/18/21: Ha-ha... NO.
singular function DripWater(float deltaTime)
{
}

//MADDERS, 0/12/25: Don't play landed sounds.
function Landed(vector HitNormal)
{
}

defaultproperties
{
     TargetRadius=40.000000
     TargetHeight=7.000000
     
     bHidden=False
     bInvincible=True
     
     CollisionHeight=0.000000
     CollisionRadius=0.000000
     Physics=PHYS_None
     Mesh=None
     
     bBlockActors=False
     bBlockPlayers=False
     bCollideActors=False
     bProjTarget=True
     bCollideWorld=True
     
     bPushable=False
}
