//=============================================================================
// VMDFakeRadarMarker.
//=============================================================================
class VMDFakeRadarMarker extends Actor;

var bool bPlayerAlly;
var float TimeLeft;
var Texture AllyTexture, EnemyTexture;

var ScriptedPawn ReconTarget;
var VMDBufferPlayer RenderPlayer;
var VMDFakeRadarMarker NextMark;

function Tick(float DT)
{
	local Vector TAngle, TLoc;
	
	Super.Tick(DT);
	
	if (bDeleteMe) return;
	
	ScaleGlow = TimeLeft;
	TimeLeft -= DT;
	if (TimeLeft < 0)
	{
		ScaleGlow = 0.0;
		Destroy();
	}
	else if ((ReconTarget != None) && (!ReconTarget.IsInState('Dying')) && (RenderPlayer != None))
	{
		TLoc = ReconTarget.Location;
		
		/*TAngle = Normal(ReconTarget.Location - RenderPlayer.Location);
		TLoc = RenderPlayer.Location + vect(0,0,1) * RenderPlayer.BaseEyeHeight;
		TLoc += TAngle*RenderPlayer.CollisionRadius*1.1;*/
		
		SetLocation(TLoc);
	}
}

// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
	if (RenderPlayer == None || bDeleteMe)
	{
		return;
	}
	
	if (bPlayerAlly)
	{
		Texture = AllyTexture;
	}
	else
	{
		Texture = EnemyTexture;
	}
	
	Canvas.DrawActor(self, false);
	
	Texture = None;
}

defaultproperties
{
     bCollideWhenPlacing=True
     CollisionRadius=12.000000
     CollisionHeight=15.000000
     
     AllyTexture=Texture'VMDFriendlyReconMarker'
     EnemyTexture=Texture'VMDHostileReconMarker'
     //DrawScale=0.031250
     DrawScale=0.200000
     TimeLeft=2.000000
     Lifespan=2.500000
     
     bNoSmooth=True
     bCollideWorld=False
     bUnlit=True
     Style=STY_Translucent
     bAlwaysRelevant=True
     Texture=None
     SoundVolume=128
     bStatic=False
     bHidden=False
}
