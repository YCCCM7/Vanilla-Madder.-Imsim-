//=============================================================================
// VMDSmellNode.
//=============================================================================
class VMDSmellManager extends VMDBufferDeco;

var bool bSmellActive, bNeedNodeUpdate;
var string SmellType;
var float SmellRadius, SmellUpdateTime, SmellTimer;
var int SmellArraySize, LastArray;
var VMDSmellNode Nodes[16];

var String IconLoad;
var bool bLoadNewIcon;
var Texture Icon;

function Destroyed()
{
 	local int i;
 	
 	for(i=0; i<SmellArraySize; i++)
 	{
  		if (Nodes[i] != None) Nodes[i].Destroy();
 	}
 	
 	Super.Destroyed();
}

function InitNodes(String NewSmell, int NewSize, float NewUpdateTime, float NewRadius, bool NewbSmellActive)
{
 	local int i;
 	
 	SmellType = NewSmell;
 	SmellArraySize = NewSize;
 	SmellUpdateTime = NewUpdateTime;
	SmellRadius = NewRadius;
	bSmellActive = NewbSmellActive;
 	
 	for(i=0; i<SmellArraySize; i++)
 	{
  		Nodes[i] = Spawn(Class'VMDSmellNode',,,Location, Rotation);
  		if (Nodes[i] != None)
  		{
   			Nodes[i].SetCollisionSize(SmellRadius, 10);
   			Nodes[i].SmellType = SmellType;
   			Nodes[i].SmellOwner = Self;
  		}
 	}
}

function UpdateNodes()
{
 	local int i;
 	
 	for(i=0; i<SmellArraySize; i++)
 	{
  		if (Nodes[i] != None)
  		{
   			Nodes[i].SetCollisionSize(SmellRadius, 10);
   			Nodes[i].SmellType = SmellType;
   			Nodes[i].SmellOwner = Self;
  		}
 	}
}

function LoadNewIcon()
{
 	local Texture T;
 	
	//Don't load the same icon twice, thank you. Saves memory!
	if (String(Icon) == IconLoad) return;
	
 	T = Texture(DynamicLoadObject(IconLoad, class'Texture', true));
 	if (T != None)
 	{
  		Icon = T;
 	}
}

function SetSmellActive(bool NewbSmellActive)
{
 	bSmellActive = NewbSmellActive;
}

function Tick(float DT)
{ 
 	Super.Tick(DT);
 	
 	if (Owner == None) return;
 	
 	if (bNeedNodeUpdate)
 	{
  		UpdateNodes();
  		bNeedNodeUpdate = false;
 	}
 	if (bLoadNewIcon)
 	{
  		LoadNewIcon();
  		bLoadNewIcon = false;
 	}
 	SmellTimer += DT;
 	if (SmellTimer > SmellUpdateTime)
 	{
  		SetLocation(Owner.Location);
  		SmellTimer = 0;
  		LastArray++;
  		if (LastArray >= SmellArraySize) LastArray = 0;
  		if (Nodes[LastArray] != None)
  		{
   			if (Nodes[LastArray].SetLocation(Owner.Location))
   			{
    				Nodes[LastArray].SignalPositionChanged();
   			}
 	 	}
 	}
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
     bInvincible=True
     bHidden=True
     bAlwaysRelevant=True
     
     CollisionHeight=0.000000
     CollisionRadius=0.000000
     Physics=PHYS_None
     
     bBlockActors=False
     bBlockPlayers=False
     bCollideActors=False
     bProjTarget=False
     bCollideWorld=False
     
     bPushable=False
}
