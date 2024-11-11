//=============================================================================
// MusicChangeTrigger.
//=============================================================================
class MusicChangeTrigger expands Trigger;

var() Music MyMusic;

function Trigger(Actor Other, Pawn Instigator)
{
	if (VMDBufferPlayer(Other) != None) SwapMusic(VMDBufferPlayer(Other));
}

singular function Touch(Actor Other)
{
	if (VMDBufferPlayer(Other) != None) SwapMusic(VMDBufferPlayer(Other));
}

function bool SwapMusic(VMDBufferPlayer VMP)
{
	if ((VMP != None) && (VMP.ModSwappedMusic != MyMusic))
	{
		VMP.ModSwappedMusic = MyMusic;
		VMP.ClientSetMusic(MyMusic, VMP.MusicMode, 255, MTRAN_FastFade);
	}
}

defaultproperties
{
     bTriggerOnceOnly=False
     CollisionRadius=96.000000
}
