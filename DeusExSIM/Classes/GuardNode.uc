//=============================================================================
// GuardNode
// (by G-Flex)
//
// Designates areas where ScriptedPawns should pay special attention
// (or no attention at all)
//=============================================================================
class GuardNode extends Keypoint;

var() bool			bPrimary; //is this the first node in the list?
var() bool			bTriggerOnceOnly; //do we only trigger events once?
var   bool			bAlreadyTriggered; //have we already triggered events?
var() bool			bEnclosed; //does this not penetrate world geometry?
var() bool			bInverted; //count points outside instead of inside
var() GuardNode		nextNode; //link to another area as well
var() name			Alliances[8]; //who are we watching out for?
var() enum ENodeType
{
	NT_Normal,
	NT_KeepOut,
	NT_Exclusion
}					NodeType; //what sort of area this is

var() enum ECheckType
{
	CT_Player,
	CT_Alliance,
	CT_All
}					CheckType; //how we check for pawns

var() enum EShape
{
	SHAPE_Sphere,
	SHAPE_Cube,
	SHAPE_Cylinder
}					Shape; //shape of the area

function GuardNode CreateLinkedNode(vector newLocation, optional bool bCopy)
{
	nextNode = Spawn(class'GuardNode', Self,,newLocation,);
	if (bCopy && (nextNode != None))
	{
		nextNode.bTriggerOnceOnly = bTriggerOnceOnly;
		nextNode.bEnclosed = bEnclosed;
		nextNode.Alliances[0] = Alliances[0];
		nextNode.Alliances[1] = Alliances[1];
		nextNode.Alliances[2] = Alliances[2];
		nextNode.Alliances[3] = Alliances[3];
		nextNode.Alliances[4] = Alliances[4];
		nextNode.Alliances[5] = Alliances[5];
		nextNode.Alliances[6] = Alliances[6];
		nextNode.Alliances[7] = Alliances[7];
		nextNode.CheckType = CheckType;
		nextNode.NodeType = NodeType;
		nextNode.Shape = Shape;
		nextNode.Event = Event;
		nextNode.Tag = Tag;
		nextNode.SetCollisionSize(CollisionRadius, CollisionHeight);
	}
	return nextNode;
}

//exclusion, suspicion, normal, notfound
function name PawnReaction(Pawn checkPawn, vector checkLocation)
{
	local GuardNode checkNode;
	local name reaction;
	
	if (!bPrimary)
	{
		log("GuardNode.PawnReaction() called on non-primary node " $ Name, 'ScriptWarning');
		return 'NODE_NOT_PRIMARY';
	}
	
	reaction = 'NotFound';
	checkNode = self;
	
	//G-Flex: check for exclusion first to prevent triggering events
	while (checkNode != None)
	{
		if (checkNode.NodeType == NT_Exclusion)
		{
			if (checkNode.PointInArea(checkLocation) && checkNode.PawnRelevant(checkPawn))
				return 'Exclusion';
		}
		checkNode = checkNode.nextNode;
	}

	//G-Flex: now check for others
	checkNode = self;
	while (checkNode != None)
	{
		if ((checkNode.NodeType != NT_Exclusion) && checkNode.PawnRelevant(checkPawn)
		 && checkNode.PointInArea(checkLocation))
		{
			//G-Flex: trigger our event
			checkNode.TriggerEvents(checkPawn);
			//G-Flex: suspicion takes precedence over normal response
			if (checkNode.NodeType == NT_KeepOut)
				reaction = 'Suspicion';
			else if (reaction != 'Suspicion')
				reaction = 'Normal';
		}
		checkNode = checkNode.nextNode;
	}

	return reaction;
}

function bool PawnRelevant(Pawn checkPawn)
{
	local int i;

	if (CheckType == CT_Player)
	{
		if (checkPawn.IsA('PlayerPawn'))
			return true;
	}
	
	else if (CheckType == CT_All)
		return true;
	
	else if (CheckType == CT_Alliance)
	{
		for(i = 0; i < 8; i++)
		{
			if (checkPawn.Alliance == Alliances[i])
				return true;
		}
	}
}

function TriggerEvents(Pawn checkPawn)
{
	local Actor a;

	if ((event != '') && !(bAlreadyTriggered && bTriggerOnceOnly))
	{
		foreach AllActors(class'Actor', A, Event)
			A.Trigger(Self, checkPawn);
	}
	if (bTriggerOnceOnly)
		bAlreadyTriggered = true;;
	return;
}

function bool PointInArea(vector checkLocation)
{
	local bool bIsInArea;
	bIsInArea = false;

	//simple radius check
	if (Shape == SHAPE_Sphere)
	{
		if (VSize(Location - checkLocation) <= CollisionRadius)
			bIsInArea = true;
	}
	//check height then on the x-y plane
	else if (Shape == SHAPE_Cylinder)
	{
		if ((Abs(Location.Z - checkLocation.Z) <= CollisionHeight) &&
		  (VSize(((vect(1,0,0) * Location.X) + (vect(0,1,0) * Location.Y)) -
		  ((vect(1,0,0) * checkLocation.X) + (vect(0,1,0) * checkLocation.Y))) <=
		  CollisionRadius))
			bIsInArea = true;
	}
	//more of a rectangular prism, really
	else if (Shape == SHAPE_Cube)
	{
		if ((Abs(Location.Z - checkLocation.Z) <= CollisionHeight)
		  && (Abs(Location.X - checkLocation.X) <= CollisionRadius)
		  && (Abs(Location.Y - checkLocation.Y) <= CollisionRadius))
			bIsInArea = true;
	}

	//G-Flex: if enclosed area, make sure no level geometry is in the way
	if (bIsInArea && (bEnclosed && !FastTrace(checkLocation, Location)))
		bIsInArea = false;
	if (bInverted)
		bIsInArea = !bIsInArea;
	return bIsInArea;
}

defaultproperties
{
     bEnclosed=True
     bStatic=False
     CollisionRadius=2500.000000
     CollisionHeight=2000.000000
}
