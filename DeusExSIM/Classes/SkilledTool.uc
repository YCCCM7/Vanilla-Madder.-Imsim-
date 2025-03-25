//=============================================================================
// SkilledTool.
//=============================================================================
class SkilledTool extends DeusExPickup
	abstract;

var() sound			useSound;
var bool			bBeingUsed;
var bool			bProxyHit;

//Used for activation delay!
var float HackCooldown;

//MADDERS, 5/31/23: Left handed stuff? Based.
var() Mesh LeftPlayerViewMesh, LeftThirdPersonMesh;

//MADDERS, 12/13/23: Tilt sequences. Might regret this. We'll see.
var(TiltSequences) bool bDebugTilt;
var float TiltAddTime;

var(TiltSequences) vector SelectTilt[8], DownTilt[8], UseBeginTilt[8], UseLoopTilt[8], UseEndTilt[8];

var(TiltSequences) float SelectTiltTimer[8], DownTiltTimer[8], UseBeginTiltTimer[8], UseLoopTiltTimer[8], UseEndTiltTimer[8];

var(TiltSequences) int SelectTiltIndices, DownTiltIndices, UseBeginTiltIndices, UseLoopTiltIndices, UseEndTiltIndices;

// ----------------------------------------------------------------------
// PlayUseAnim()
// ----------------------------------------------------------------------

function PlayUseAnim()
{
	if (!bProxyHit)
	{
		ActivateProxy();
		bProxyHit = True;
	}
	
	if (!IsInState('UseIt'))
		GotoState('UseIt');
}

// ----------------------------------------------------------------------
// StopUseAnim()
// ----------------------------------------------------------------------

function StopUseAnim()
{
	if (bProxyHit)
	{
		DeactivateProxy();
		bProxyHit = False;
	}

	if (IsInState('UseIt'))
		GotoState('StopIt');
}

// ----------------------------------------------------------------------
// PlayIdleAnim()
// ----------------------------------------------------------------------

function PlayIdleAnim()
{
	local float rnd;

	rnd = FRand();

	if (rnd < 0.1)
		PlayAnim('Idle1');
	else if (rnd < 0.2)
		PlayAnim('Idle2');
	else if (rnd < 0.3)
		PlayAnim('Idle3');
}

// ----------------------------------------------------------------------
// PickupFunction()
//
// called when the object is picked up off the ground
// ----------------------------------------------------------------------

function PickupFunction(Pawn Other)
{
	GotoState('Idle2');
}

// ----------------------------------------------------------------------
// BringUp()
//
// called when the object is put in hand
// ----------------------------------------------------------------------

function BringUp()
{
	//MADDERS, 5/31/23: Update handedness as is appropriate.
	if (Owner.IsA('PlayerPawn'))
	{
		SetHand(PlayerPawn(Owner).Handedness);
	}
	
	if (!IsInState('Idle'))
		GotoState('Idle');
}

// ----------------------------------------------------------------------
// PutDown()
//
// called to put the object away
// ----------------------------------------------------------------------

function PutDown()
{
	if (IsInState('Idle'))
		GotoState('DownItem');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state Idle
{
	function Timer()
	{
		PlayIdleAnim();
	}

Begin:
	//bHidden = False;
	bOnlyOwnerSee = True;
	PlayAnim('Select',, 0.1);
DontPlaySelect:
	FinishAnim();
	PlayAnim('Idle1',, 0.1);
	SetTimer(3.0, True);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state UseIt
{
	function PutDown()
	{
		
	}

Begin:
	if (( Level.NetMode != NM_Standalone ) && ( Owner != None ))
		SetLocation( Owner.Location );		
	AmbientSound = useSound;
	//MADDERS: Shift pitch accordingly.
	SoundPitch = 64 * VMDGetMiscPitch2();
	
	PlayAnim('UseBegin',, 0.1);
	FinishAnim();
	LoopAnim('UseLoop',, 0.1);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state StopIt
{
	function PutDown()
	{
		
	}

Begin:
	AmbientSound = None;
	PlayAnim('UseEnd',, 0.1);
	FinishAnim();
	GotoState('Idle', 'DontPlaySelect');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state DownItem
{
	function PutDown()
	{
		
	}

Begin:
	AmbientSound = None;
	if (!VMDOwnerIsCloaked()) bHidden = False;		// make sure we can see the animation
	PlayAnim('Down',, 0.1);
	FinishAnim();
	bHidden = True;	// hide it correctly
	GotoState('Idle2');
}

//
//
//
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// Decrease the volume and radius for mp
	if ( Level.NetMode != NM_Standalone )
	{
		SoundVolume = 96;
		SoundRadius = 16;
	}
}

function ActivateProxy();
function DeactivateProxy();

// Update the client numbers in multiplayer
simulated function ClientSetHandedness( float Hand )
{
	setHand(Hand);
}

// set which hand is holding weapon
simulated function setHand( float Hand )
{
	local int THand;
	
	if (VMDBufferPlayer(Owner) != None) VMDBufferPlayer(Owner).GetHandednessPlayerMesh(THand);
	THand = GetHandType(THand);
	Hand = THand;
	
	if (Hand == 2)
	{
		PlayerViewOffset.Y = 0;
		return;
	}
	
	//MADDERS, 6/1/23: Please note that our offsets were not built with handedness of -1 in mind, so invert what we'd normally do for Y.
	if (Hand == 0)
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = 0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * -Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	}
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

function int GetHandType(optional int OverrideHand)
{
	local int Ret;
	local DeusExPlayer DXP;
	local VMDBufferPlayer VMP;
	
	DXP = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Owner);
	
	Ret = -1;
	if (OverrideHand != 0) Ret = OverrideHand;
	
	if (DXP != None)
	{
		if (OverrideHand == 0)
		{
			Ret = DXP.Handedness;
		}
		if ((Ret == 1) && (LeftPlayerViewMesh == None))
		{
			Ret = -1;
		}
		
		if (VMP != None)
		{
			if ((LeftPlayerViewMesh != None) && (Ret == -1) && (VMP.HealthArmRight < 1) && (VMP.HealthArmLeft > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = 1;
			}
			else if ((PlayerViewMesh != None) && (Ret == 1) && (VMP.HealthArmLeft < 1) && (VMP.HealthArmRight > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = -1;
			}
		}
	}
	
	return Ret;
}

simulated function Tick(float DT)
{
	local int THand;
	local Mesh TMesh;
	local VMDBufferPlayer VPlayer;
	
	Super.Tick(DT);
	
	VMDUpdateTiltEffects(DT);
	
	if (HackCooldown > 0) HackCooldown -= DT;
	
	VPlayer = VMDBufferPlayer(Owner);
	
	if (VPlayer != None)
	{
		if ((VPlayer.InHand == Self) && (Mesh == PlayerViewMesh || Mesh == LeftPlayerViewMesh))
		{
			TMesh = VPlayer.GetHandednessPlayerMesh(THand);
			THand = GetHandType(THand);
			
			if ((Mesh == PlayerViewMesh) && (LeftPlayerViewMesh != None) && (THand == 1))
			{
				Mesh = LeftPlayerViewMesh;
				SetHand(THand);
			}
			else if ((Mesh == LeftPlayerViewMesh) && (PlayerViewMesh != None) && (THand != 1))
			{
				Mesh = PlayerViewMesh;
				SetHand(THand);
			}
			if ((Mesh == Default.ThirdPersonMesh) && (LeftThirdPersonMesh != None) && (THand == 1))
			{
				ThirdPersonMesh = LeftThirdPersonMesh;
			}
			else if ((Mesh == LeftThirdPersonMesh) && (Default.ThirdPersonMesh != None) && (THand != 1))
			{
				ThirdPersonMesh = Default.ThirdPersonMesh;
			}
			
			if ((VPlayer.Mesh != TMesh) && (TMesh != None))
			{
				VPlayer.Mesh = TMesh;
				VPlayer.LastMeshHandedness = THand;
			}
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function VMDDebugTilt(float DT)
{
 	local DeusExPlayer Player;
 	local HUDMissionStartTextDisplay HUD;
 	local string Message;
 	
 	if (!bDebugTilt) return;
	
	Player = DeusExPlayer(Owner);
 	if (Player == None || Player.InHand != Self) return;
	
 	switch(AnimSequence)
	{
		case 'Select':
		case 'Down':
		case 'UseBegin':
		case 'UseLoop':
		case 'UseEnd':
 			TiltAddTime += DT;
 			
 			if (TiltAddTime % 0.10 > 0.025) return;
 			Message = Mid(String(AnimFrame), 2+int(AnimFrame<0), 3);
 			
  			if ((DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
  			{
    				HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
  			}
  			if (HUD != None)
  			{
    				HUD.shadowDist = 0;
    				HUD.Message = "";
    				HUD.charIndex = 0;
    				HUD.winText.SetText("");
    				HUD.winTextShadow.SetText("");
    				HUD.displayTime = 3.00;
    				HUD.perCharDelay = 0.00;
    				HUD.AddMessage(Message);
    				HUD.StartMessage();
  			}
		break;
	}
}

//Update our tilts!
simulated function VMDUpdateTiltEffects(float DT)
{
	local float TAF, UVM, UVM2, TXChunk, TYChunk;
	local int UseIndex, NumIndices, i;
	local vector UseVec, UseVec2;
	local int TPitch;
 	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
 	if (VMP == None || !VMP.bAllowPickupTiltEffects) return;
	
 	if (Level.Netmode == NM_Standalone) VMDDebugTilt(DT);
 	
 	UVM = 0.10;
 	UVM2 = 0.05;
 	
 	UseIndex = -1;
 	switch(AnimSequence)
 	{
  		//010101010101010101010101010101
  		//SELECT/DOWN TILT!
  		//010101010101010101010101010101
  		case 'Select':
   			NumIndices = SelectTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > SelectTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = SelectTilt[UseIndex];
  		break;
  		case 'Down':
   			NumIndices = DownTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > DownTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = DownTilt[UseIndex];
  		break;
  		//020202020202020202020202020202
  		//USE TILT!
  		//020202020202020202020202020202
  		case 'UseBegin':
   			NumIndices = UseBeginTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > UseBeginTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = UseBeginTilt[UseIndex];
  		break;
  		case 'UseLoop':
   			NumIndices = UseLoopTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > UseLoopTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = UseLoopTilt[UseIndex];
  		break;
  		case 'UseEnd':
   			NumIndices = UseEndTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > UseEndTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = UseEndTilt[UseIndex];
  		break;
	}
 	
 	if (UseIndex == -1) return;
 	
 	if (UseVec != vect(0,0,0))
 	{
		UseVec.X *= -1 * GetHandType();
		
  		TAF = AnimRate * DT;
  		UseVec = UseVec * TAF * UVM;
		
		TXChunk = UseVec.X * 6144 * 0.01;
		TXChunk += VMP.TiltEffectYawFloat;
		VMP.TiltEffectYawFloat = TXChunk % 1.0;
		
  		VMP.ViewRotation.Yaw += int(TXChunk);
		
		TYChunk = UseVec.Y * 6144 * 0.01;
		TYChunk += VMP.TiltEffectPitchFloat;
		VMP.TiltEffectPitchFloat = TYChunk % 1.0;
		
  		TPitch = VMP.ViewRotation.Pitch + int(TYChunk);
  		if ((TPitch > 18000) && (TPitch < 32768)) TPitch = 18000;
		else if ((TPitch >= 32768) && (TPitch < 49152)) TPitch = 49152;
  		VMP.ViewRotation.Pitch = TPitch;
 	}
}

function int Sign(coerce float InValue)
{
	if (InValue > 0) return 1;
	else if (InValue < 0) return -1;
	
	return 0;
}

defaultproperties
{
     CountLabel="Uses:"
}
