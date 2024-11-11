//=============================================================================
// VMDFakeDestroyOtherPawn.
//=============================================================================
class VMDFakeDestroyOtherPawn extends ScriptedPawn;

function Tick(float DT)
{
	local VMDBufferPlayer VMP;
	local VMDMegh TMegh;
	local VMDSIDD TSidd;
	
	Super.Tick(DT);
	
	/*if (GetStateName() != 'Paralyzed')
	{
		GoToState('Paralyzed');
	}*/
	
	if ((Owner == None) && (!bDeleteMe))
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
		if (VMP != None)
		{
			TMegh = VMP.FindProperMegh();
			if (TMegh != None)
			{
				TMegh.MEGHIssueOrder('Following', VMP);
			}
			
			forEach AllActors(class'VMDSIDD', TSidd)
			{
				if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
				{
					TSidd.SIDDIssueOrder('Standing', None);
				}
			}
		}
		Destroy();
	}
}

function PlayWalking()
{
	LoopAnimPivot('Still');
}
function TweenToWalking(float tweentime)
{
	TweenAnimPivot('Still', tweentime);
}

// Approximately five million stubbed out functions...
function PlayRunningAndFiring() {}
function TweenToShoot(float tweentime) {}
function PlayShoot() {}
function TweenToAttack(float tweentime) {}
function PlayAttack() {}
function PlayPanicRunning() {}
function PlaySittingDown() {}
function PlaySitting() {}
function PlayStandingUp() {}
function PlayRubbingEyesStart() {}
function PlayRubbingEyes() {}
function PlayRubbingEyesEnd() {}
function PlayStunned() {}
function PlayFalling() {}
function PlayLanded(float impactVel) {}
function PlayDuck() {}
function PlayRising() {}
function PlayCrawling() {}
function PlayPushing() {}
function PlayFiring() {}
function PlayTakingHit(EHitLocation hitPos) {}

function PlayTurning() {}
function TweenToRunning(float tweentime) {}
function PlayRunning() {}
function TweenToWaiting(float tweentime) {}
function PlayWaiting() {}
function TweenToSwimming(float tweentime) {}
function PlaySwimming() {}

defaultproperties
{
     DrawScale=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     GroundSpeed=0.000000
     WaterSpeed=0.000000
     AirSpeed=0.000000
     AccelRate=0.000000
     JumpZ=0.000000
     Orders=Paralyzed
     InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000,bPermanent=True)
     InitialAlliances(1)=(AllianceName=PlayerDrone,AllianceLevel=-1.000000,bPermanent=True)
     
     bHasShadow=False
     bHighlight=False
     bSpawnBubbles=False
     bCanFly=True
     Health=1
     UnderWaterTime=9999.000000
     bTransient=True
     Physics=PHYS_Flying
     DrawType=DT_Mesh
     Mesh=Mesh'DeusExCharacters.Fly'
     AmbientSound=None
     bBlockActors=False
     bBlockPlayers=False
     bBounce=True
     Mass=0.100000
     Buoyancy=0.100000
     RotationRate=(Pitch=0,Yaw=0)
     BindName=""
     FamiliarName=""
     UnfamiliarName=""
}
