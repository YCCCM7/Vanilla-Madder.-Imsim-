//=============================================================================
// ExternalMoveActor.
//=============================================================================
class ExternalMoveActor extends Containers;

var() Actor Target;
var() int PhysType; //0 = Projectile, 1 = Walking, 2 = Flying
var() int NumKeys;
var() bool bAddLoc, bAddRot, bLoop;
var() bool bChangesLoc, bChangesRot, bChangesScale, bChangePhysics;

var() Vector PosKeys[8];
var() Rotator RotKeys[8];
var() float ChangeTimes[8], ChangeScales[8];

var int CurKey, DebugLaps;
var Rotator LastRot;
var Vector LastPos;
var float ChangeProgress, LastScale;

var Vector InitPos;
var Rotator InitRot;
var float InitScale;

function UpdateFrames()
{
 local int i;
 
 if (Target != None)
 {
  InitScale = Target.DrawScale;
  InitRot = Target.Rotation;
  InitPos = Target.Location;
 }
 
 PosKeys[1] += PosKeys[0];
 PosKeys[2] += PosKeys[1];
 PosKeys[3] += PosKeys[2];
 PosKeys[4] += PosKeys[3];
 PosKeys[5] += PosKeys[4];
 PosKeys[6] += PosKeys[5];
 PosKeys[7] += PosKeys[6];
 
 if (bAddLoc)
 {
  for (i=0; i<8; i++)
  {
   PosKeys[i] += Target.Location;
  }
 }
 
 if (bAddRot)
 {
  for (i=0; i<8; i++)
  {
   RotKeys[i] += Target.Rotation;
  }
 }
}

function Tick(float DT)
{
 local Vector V;
 local Rotator R;
 local float Prog;
 
 local float FR;
  
 if (CurKey < NumKeys && Target != None)
 {
  if (ChangeProgress < 0)
  {
   UpdateFrames();
   ChangeProgress = 0;
   LastPos = Target.Location;
   LastRot = Target.Rotation;
   LastScale = Target.DrawScale;
   if (bChangePhysics)
   {
    switch(PhysType)
    {
     case 0:
      Target.SetPhysics(PHYS_Projectile);
     break;
     case 1:
      Target.SetPhysics(PHYS_Walking);
     break;
     case 2:
      Target.SetPhysics(PHYS_Flying);
     break;
    }
   }
  }
  else
  {
   if (ChangeProgress < ChangeTimes[CurKey])
   {
    ChangeProgress += DT;
    Prog = (ChangeProgress / ChangeTimes[CurKey]);
    
    //V = LastPos;
    if (bChangesLoc)
    {
     V.X += LastPos.X + (PosKeys[CurKey].X - LastPos.X) * Prog;
     V.Y += LastPos.Y + (PosKeys[CurKey].Y - LastPos.Y) * Prog;
     V.Z += LastPos.Z + (PosKeys[CurKey].Z - LastPos.Z) * Prog;
     Target.SetLocation(V);
    }
    //R = LastRot;
    if (bChangesRot)
    {
     R.Pitch += LastRot.Pitch + (RotKeys[CurKey].Pitch - LastRot.Pitch) * Prog;
     R.Yaw += LastRot.Yaw + (RotKeys[CurKey].Yaw - LastRot.Yaw) * Prog;
     R.Roll += LastRot.Roll + (RotKeys[CurKey].Roll - LastRot.Roll) * Prog;
     Target.SetRotation(R);
    }
    if (bChangesScale) Target.DrawScale = LastScale + (ChangeScales[CurKey] - LastScale) * Prog;
   }
   if (ChangeProgress >= ChangeTimes[CurKey])
   {
    Target.SetLocation(PosKeys[CurKey]);
    LastPos = PosKeys[CurKey];
    if (bChangesRot)
    {
     Target.SetRotation(RotKeys[CurKey]);
     LastRot = RotKeys[CurKey];
     LastScale = ChangeScales[CurKey];
    }
    if (bChangesScale)
    {
     Target.DrawScale = ChangeScales[CurKey];
     LastScale = ChangeScales[CurKey];
    }
    CurKey++;
    ChangeProgress = 0;
   }
  }
 }
 if ((bLoop) && (Target != None) && (CurKey >= NumKeys))
 {
  LastRot = InitRot;
  LastPos = InitPos;
  LastScale = InitScale;
  ChangeProgress = 0;
  CurKey = 0;
 }
}

defaultproperties
{
     bAddLoc=False
     NumKeys=2
     PhysType=2
     ChangeProgress=-1.000000
     ChangeTimes(0)=2.000000
     ChangeTimes(1)=2.000000
     ChangeTimes(2)=2.000000
     ChangeTimes(3)=2.000000
     ChangeTimes(4)=2.000000
     ChangeTimes(5)=2.000000
     ChangeTimes(6)=2.000000
     ChangeTimes(7)=2.000000
     ChangeScales(0)=1.000000
     ChangeScales(1)=1.000000
     ChangeScales(2)=1.000000
     ChangeScales(3)=1.000000
     ChangeScales(4)=1.000000
     ChangeScales(5)=1.000000
     ChangeScales(6)=1.000000
     ChangeScales(7)=1.000000
     bStasis=False

     bDirectional=True //Severely underrated.
     bHidden=True

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
