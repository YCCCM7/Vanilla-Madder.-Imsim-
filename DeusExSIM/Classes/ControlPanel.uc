//=============================================================================
// ControlPanel.
//=============================================================================
class ControlPanel extends HackableDevices;

function StopHacking()
{
	Super.StopHacking();

	if (hackStrength == 0.0)
		PlayAnim('Open');
}

function HackAction(Actor Hacker, bool bHacked)
{
	local Actor A;

	Super.HackAction(Hacker, bHacked);

	if (bHacked)
	{
		if (Event != '')
			foreach AllActors(class 'Actor', A, Event)
				A.Trigger(Self, Pawn(Hacker));
	}
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float mindmg;
        	local bool bScramblerAugment;
		local VMDBufferPlayer VMP;
		
		VMP = VMDBufferPlayer(EventInstigator);
		
        	if ((VMP != None) && (!bLastSplashWasDrone))
		{
			bScramblerAugment = VMP.HasSkillAugment('TagTeamScrambler');
		}
		
		// Transcended - Added
		if (DamageType == 'EMP')
		{
        		if (bScramblerAugment)
			{
				HackStrength = FClamp(HackStrength - (float(Damage) / 200.0), 0.0, 1.0);
				if (HackStrength <= 0.0)
				{
					HackAction(EventInstigator, true);
					return;
				}
			}
			
			bLastSplashWasDrone = false;
			return;
		}
		if (( Level.NetMode != NM_Standalone ) && (EventInstigator.IsA('DeusExPlayer')))
			DeusExPlayer(EventInstigator).ServerConditionalNotifyMsg( DeusExPlayer(EventInstigator).MPMSG_CameraInv );
		
		bLastSplashWasDrone = false;
		
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

defaultproperties
{
     ItemName="Electronic Control Panel"
     Mesh=LodMesh'DeusExDeco.ControlPanel'
     SoundRadius=8
     SoundVolume=255
     SoundPitch=96
     AmbientSound=Sound'DeusExSounds.Generic.ElectronicsHum'
     CollisionRadius=14.500000
     CollisionHeight=23.230000
     Mass=10.000000
     Buoyancy=5.000000
}
