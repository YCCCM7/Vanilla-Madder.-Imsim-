//=============================================================================
// AIEventSender. Alert us of shit going on.
//=============================================================================
class VMDAIEventSender extends VMDFillerActors;

/*enum EAIEventType
{
	EAITYPE_Visual,
	EAITYPE_Audio,
	EAITYPE_Olifactory
};*/

var float EventVolume, EventRadius;
var name EventName;
var EAIEventType EventSense;
var Pawn EventInstigator;

function LoadEvent(Pawn NewInstigator, Name NewName, EAIEventType NewSense, float NewVolume, float NewRadius)
{
	EventInstigator = NewInstigator;
	EventName = NewName;
	EventSense = NewSense;
	EventVolume = NewVolume;
	EventRadius = NewRadius;
}

function SendEvent()
{
	Instigator = EventInstigator;
 	AISendEvent(EventName, EventSense, EventVolume, EventRadius);
	SetTimer(0.5, False);
}

function Timer()
{
	Destroy();
}

defaultproperties
{
     bHidden=True
}
