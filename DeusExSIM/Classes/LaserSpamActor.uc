//=============================================================================
// LaserSpamActor.
//=============================================================================
class LaserSpamActor extends Containers;

var() int SpamCount, JumpDist;
var() bool bBlueSpam;

var() int PitchClamp;
var() int YawClamp;

var() bool bLockX, bLockY, bLockZ;

//Y/y: Spam lasers everywhere, just for fun. 06/07/13
function ApplySpecialStats()
{
 local BeamTrigger BT;
 local LaserTrigger LT;
 local Actor TraceAct;
 local Vector ScoutLoc, LastLoc, HitNorm, HitLoc;
 local Rotator RayAngle;
 local int i;
 
 ScoutLoc = Location;
 
 if (FastTrace(ScoutLoc, Location))
 {
  for(i=0; i<SpamCount; i++)
  {
   LastLoc = ScoutLoc;
   do
   {
    ScoutLoc = LastLoc;
    if (!bLockX) ScoutLoc.X += JumpDist -  Rand((JumpDist*2)+1);
    if (!bLockY) ScoutLoc.Y += JumpDist -  Rand((JumpDist*2)+1);
    if (!bLockZ) ScoutLoc.Z += JumpDist -  Rand((JumpDist*2)+1);
   }
   until (FastTrace(ScoutLoc, LastLoc));
   
   RayAngle.Pitch = Rotation.Pitch + (Rand(65536) / PitchClamp);
   RayAngle.Yaw = Rotation.Yaw +(Rand(65536) / YawClamp);
   
   TraceAct = Trace(HitLoc, HitNorm, ScoutLoc + vector(RayAngle)*2048, ScoutLoc, True);
   
   if (bBlueSpam)
   {
    BT = spawn(class'BeamTrigger',,Tag,HitLoc, Rotator(vector(RayAngle) * -1));
    BT.ClassProximityType = class'DeusExPlayer';
    BT.TriggerType = TT_ClassProximity;
    BT.Event = Event;
   }
   else
   {
    LT = spawn(class'LaserTrigger',,Tag,HitLoc, Rotator(vector(RayAngle) * -1));
    
    //For fuck's sake. TT_PlayerProximity triggers on decos, too.
    //Bypass this with a class proximity check for DeusExPlayer.
    //ONE HACK TO RULE THEM ALL. ~Y/y
    LT.ClassProximityType = class'DeusExPlayer';
    LT.TriggerType = TT_ClassProximity;
    LT.Event = Event;
   }
  }
 }
 
 Destroy();
}

defaultproperties
{
     bDirectional=True //Severely underrated.
     PitchClamp=2
     YawClamp=1
     SpamCount=30
     JumpDist=80

     bInvincible=True
     bFlammable=False
     ItemName="Metal Crate"
     bBlockSight=True
     Mesh=LodMesh'DeusExDeco.CrateUnbreakableSmall'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Mass=40.000000
     Buoyancy=50.000000
}
