//=============================================================================
// VMDPlayerHands
//=============================================================================
class VMDPlayerHands extends Inventory;

var float LastSpeed;
var name LastGetAnim;
var vector LowPlayerViewOffset;

var bool bLastDuck, bLastAirborne, bHideHands, bLastHideHands;
var float PushSpeed, BloodRenderMult;

//-----------------------
//TILT SEQUENCES! Tasty.
var(TiltSequences) vector WalkTilt[8], RunTilt[8], CrouchWalkTilt[8], TreadTilt[8],
				JumpTilt, LandTilt, StartCrouchTilt, EndCrouchTilt;

//Nasty hack. 0 = Current. 1 = Cap.
var(TiltSequences) float WalkTiltTimer[8], RunTiltTimer[8], CrouchWalkTiltTimer[8], TreadTiltTimer[8],
				JumpLandTimer, CrouchTimer, IgnoreTimer,
				JumpRate, LandRate, StartCrouchRate, EndCrouchRate;

//Number of indices we actually fucking use. Don't overdo it.
var(TiltSequences) int WalkTiltIndices, RunTiltIndices, CrouchWalkTiltIndices, TreadTiltIndices;


//Weapon copy over variables.
var bool bDebugTilt;
var float TiltAddTime;
var Mesh LeftPlayerViewMesh;

function VMDDebugTilt(float DT)
{
 	local VMDBufferPlayer VMP;
 	local HUDMissionStartTextDisplay HUD;
 	local string Message;
 	
 	if (!bDebugTilt) return;
	
	VMP = VMDBufferPlayer(Owner);
 	if (VMP == None || VMP.InHand != None) return; 
 	TiltAddTime += DT;
 	
 	if (TiltAddTime % 0.05 > 0.0125) return;
 	Message = Mid(String(AnimFrame), 2+int(AnimFrame<0), 3);
 	
  	if ((DeusExRootWindow(VMP.RootWindow) != None) && (DeusExRootWindow(VMP.RootWindow).HUD != None))
  	{
    		HUD = DeusExRootWindow(VMP.RootWindow).HUD.startDisplay;
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
}

function int Sign(coerce float InValue)
{
	if (InValue > 0) return 1;
	else if (InValue < 0) return -1;
	
	return 0;
}

//Update our tilts!
simulated function VMDUpdateTiltEffects(float DT)
{
	local bool bDuck, bAirborne;
	local float TAF, UVM, TXChunk, TYChunk, TMath;
	local int UseIndex, NumIndices, i;
	local vector UseVec;
	local int TPitch;
 	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
 	if (VMP == None || !VMP.bAllowPlayerHandsTiltEffects) return;
	
	bDuck = (VMP.bCrouchOn || VMP.bForceDuck || VMP.bDuck != 0);
	bAirborne = (VMP.Physics == PHYS_Falling);
	
	//MADDERS, 12/24/23: Do this shit to tidy up the unexpected, and make this less jarring.
	if (IgnoreTimer > 0)
	{
		if (bDuck)
		{
			CrouchTimer = 1.0;
		}
		else
		{
			CrouchTimer = 0;
		}
		
		if (bAirborne)
		{
			JumpLandTimer = 1.0;
		}
		else
		{
			JumpLandTimer = 0.0;
		}
	}
	
 	if (Level.Netmode == NM_Standalone) VMDDebugTilt(DT);
 	
 	UVM = 0.25;
 	
	if (IgnoreTimer <= 0)
	{
		//=============================
		//PART 1! PROCESS DUCK START/END EVENT!
		UseVec = vect(0,0,0);
 		UseIndex = -1;
		
		if (bDuck)
		{
			if ((CrouchTimer < 1.0) && (!VMP.VMDUsingLadder()))
			{
				TMath = DT * StartCrouchRate;
				CrouchTimer = FMin(1.0, CrouchTimer + TMath);
				
		  		UseVec = StartCrouchTilt * TMath * UVM;
			}
		}
		else
		{
			if ((CrouchTimer > 0.0) && (!VMP.VMDUsingLadder()))
			{
				TMath = DT * EndCrouchRate;
				CrouchTimer = FMax(0.0, CrouchTimer - TMath);
				
		  		UseVec = EndCrouchTilt * TMath * UVM;
			}
		}
		
		if (UseVec != Vect(0,0,0))
		{
			TXChunk = UseVec.X * 6144 * 0.01;
			if (TXChunk%1.0 > 0.0)
			{
				if (FRand() < TXChunk%1.0)
				{
					TXChunk = (TXChunk - (TXChunk%1.0)) + Sign(TXChunk);
				}
				else
				{
					TXChunk = TXChunk - (TXChunk%1.0);
				}
			}
  			VMP.ViewRotation.Yaw += TXChunk;
			
			TYChunk = UseVec.Y * 6144 * 0.01;
			if (TYChunk%1.0 > 0.0)
			{
				if (FRand() < TYChunk%1.0)
				{
					TYChunk = (TYChunk - (TYChunk%1.0)) + Sign(TYChunk);
				}
				else
				{
					TYChunk = TYChunk - (TYChunk%1.0);
				}
			}
  			TPitch = VMP.ViewRotation.Pitch + TYChunk;
  			if ((TPitch > 18000) && (TPitch < 32768)) TPitch = 18000;
 			else if ((TPitch >= 32768) && (TPitch < 49152)) TPitch = 49152;
 			VMP.ViewRotation.Pitch = TPitch;
		}
		
		//=============================
		//PART 2! PROCESS JUMP/LAND EVENT!
		UseVec = vect(0,0,0);
 		UseIndex = -1;
		
		if (bAirborne)
		{
			if (JumpLandTimer < 1.0)
			{
				TMath = DT * JumpRate;
				JumpLandTimer = FMin(1.0, JumpLandTimer + TMath);
				
	  			UseVec = JumpTilt * TMath * UVM;
			}
		}
		else
		{
			if (JumpLandTimer > 0.0)
			{
				TMath = DT * LandRate;
				JumpLandTimer = FMax(0.0, JumpLandTimer - TMath);
				
		  		UseVec = LandTilt * TMath * UVM;
			}
		}
		
		if (UseVec != Vect(0,0,0))
		{
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
	
	//=============================
	//PART 3! NORMAL TILT STUFF, TOO!
	UseVec = vect(0,0,0);
 	UseIndex = -1;
 	switch(AnimSequence)
 	{
  		case 'Walk':
   			NumIndices = WalkTiltIndices;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > WalkTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = WalkTilt[UseIndex];
  		break;
  		case 'Run':
   			NumIndices = RunTiltIndices;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > RunTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = RunTilt[UseIndex];
  		break;
  		case 'CrouchWalk':
   			NumIndices = CrouchWalkTiltIndices;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > CrouchWalkTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = CrouchWalkTilt[UseIndex];
  		break;
  		case 'Tread':
   			NumIndices = TreadTiltIndices;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > TreadTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = TreadTilt[UseIndex];
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
		
  		VMP.ViewRotation.Yaw += TXChunk;
		
		TYChunk = UseVec.Y * 6144 * 0.01;
		TYChunk += VMP.TiltEffectPitchFloat;
		VMP.TiltEffectPitchFloat = TYChunk % 1.0;
		
  		TPitch = VMP.ViewRotation.Pitch + int(TYChunk);
  		if ((TPitch > 18000) && (TPitch < 32768)) TPitch = 18000;
		else if ((TPitch >= 32768) && (TPitch < 49152)) TPitch = 49152;
  		VMP.ViewRotation.Pitch = TPitch;
 	}
}

function int GetSuperiorAxis(Vector TVect)
{
	local int Ret;
	local float AbsX, AbsY;
	
	Ret = 1;
	AbsX = Abs(TVect.X);
	AbsY = Abs(TVect.Y)*1.1;
	
	//Pos X = Forward, AKA 1
	//Neg X = Backward, AKA 2
	//Pos Y = Right, AKA 3
	//Neg Y = Left, AKA 4
	if (AbsY > AbsX)
	{
		if (TVect.Y > 0)
		{
			Ret = 4;
		}
		else
		{
			Ret = 3;
		}
	}
	else
	{
		if (TVect.X <= 0)
		{
			Ret = 2;
		}
	}
	
	return Ret;
}

function bool IsPlayerStill(VMDBufferPlayer VMP, float VelSize, bool bAqua)
{
	if (VelSize < 25 + (100 * int(bAqua))) return true;
	if ((VMP.HealthLegLeft + VMP.HealthLegRight)*GetSpeedMult() < 60) return true;
	if (VMP.HealthLegLeft <= 0 || VMP.HealthLegRight <= 0) return true;
	
	return false;
}

//Figure out what anim we're doing.
function name GetAnimType(out int bFastAnim)
{
	local Name Ret;
	local VMDBufferPlayer VMP;
	local bool bAirborne, bAqua, bFall, bPush, bStill, bIgnore, bRolling;
	local int VelDir;
	local float VelSize;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None) return 'Still';
	
	Ret = 'Still';
	VelDir = GetSuperiorAxis(VMP.Velocity << VMP.Rotation);
	VelSize = VSize(VMP.Velocity);
	
	if (VMP.Region.Zone != None)
	{
 		bAqua = VMP.Region.Zone.bWaterZone;
	}
	bAirborne = (VMP.Physics == PHYS_Falling);
	bFall = (VMP.Velocity.Z < -50);
	bStill = IsPlayerStill(VMP, VelSize, bAqua);
	bIgnore = (VMP.IsInState('Conversation') || VMP.PlayerHandsLevel < VMP.PlayerHandsCap);
	bRolling = (VMP.RollTimer > 0 || VMP.DodgeRollTimer > 0);
	
	if (bAqua)
	{
		IgnoreTimer = 1.5;
	}
	else if (bIgnore)
	{
		IgnoreTimer = 0.3;
	}
	
	if ((IgnoreTimer > 0 && !bAqua) || VMP.VMDUsingLadder() || (bRolling && bAirborne))
	{
		return 'Still';
	}
	
	//MADDERS, 12/23/23: Looks like trash. Might revisit with a custom sequence later?
	//bPush = (VMP.AnimSequence == 'PushButton');
	
	if (bPush)
	{
		if ((VMP.AnimFrame > 0) && (VMP.AnimFrame < 0.5 / PushSpeed))
		{
			bFastAnim = 2;
			Ret = 'PushButton';
		}
		else
		{
			bFastAnim = 2;
			Ret = 'Still';
		}
	}
	else if (bStill)
	{
		if (!bAqua)
		{
			if (!bAirborne)
			{
				if (VMP.bCrouchOn || VMP.bForceDuck || VMP.bDuck != 0)
				{
					bFastAnim = 2;
					Ret = 'Crouch';
				}
				else
				{
					Ret = 'Still';
				}
			}
			else
			{
				if (bFall)
				{
					bFastAnim = 2;
					Ret = 'Jump';
				}
				else
				{
					bFastAnim = 2;
					Ret = 'Jump';
				}
			}
		}
		else
		{
			Ret = 'Tread';
		}
	}
	else
	{
		if (!bAqua)
		{
			if (!bAirborne)
			{
				if (VMP.bCrouchOn || VMP.bForceDuck || VMP.bDuck != 0)
				{
					if (VelDir == 1 || (VelDir == 2 && VelSize > 255))
					{
						Ret = 'CrouchWalk';
					}
					else
					{
						bFastAnim = 2;
						Ret = 'Crouch';
					}
				}
				else
				{
					if (VelSize > 225)
					{
						//MADDERS, 3/29/25: Don't run with 1 arm. Looks terrible.
						if (VMP.HealthArmRight < 20 || VMP.HealthArmLeft < 20)
						{
							bFastAnim = 1;
							Ret = 'Walk';
						}
						else if (VelDir == 1 || (VelDir == 2 && VelSize > 255))
						{
							bFastAnim = 1;
							Ret = 'Run';
						}
						else
						{
							bFastAnim = 1;
							Ret = 'Walk';
						}
					}
					else
					{
						bFastAnim = 1;
						Ret = 'Walk';
					}
				}
			}
			else
			{
				if (bFall)
				{
					bFastAnim = 2;
					Ret = 'Jump';
				}
				else
				{
					bFastAnim = 2;
					Ret = 'Jump';
				}
			}
		}
		else
		{
			Ret = 'Tread';
		}
	}
	
	return Ret;
}

function bool ShouldRenderHands(VMDBufferPlayer VMP)
{
	if (VMP == None || !VMP.bPlayerHandsEnabled)
	{
		return False;
	}
	if ((!VMP.IsInState('PlayerWalking')) && (!VMP.IsInState('PlayerSwimming')))
	{
		return False;
	}
	if (VMP.InHand != None)
	{
		return False;
	}
	if (VMP.CarriedDecoration != None)
	{
		return False;
	}
	if (VMP.OverrideCameraLocation != Vect(0,0,0) || VMP.OverrideCameraRotation != Rot(0,0,0))
	{
		return False;
	}
	if (VMP.DesiredFOV != VMP.DefaultFOV)
	{
		return False;
	}
	return True;
}

function Tick(float DT)
{
	local int i, bFastAnim, THand;
	local float TRate, TSpeed;
	local Name TAnim;
	local Vector SetLoc;
	local Mesh TMesh;
	local VMDBufferPlayer VMP;
	
	bHideHands = True;
	
	Super.Tick(DT);
	
	if (IgnoreTimer > 0)
	{
		IgnoreTimer -= DT;
	}
	
	if (Owner != None)
	{
		SetLoc = Owner.Location + CalcDrawOffset();
		SetLocation(SetLoc);
	}
	
	//Note: This function cannot return true if we have no player.
	VMP = VMDBufferPlayer(Owner);
	if (ShouldRenderHands(VMP))
	{
		//MADDERS, 12/23/23: Tilt camera according to anim sequences.
		VMDUpdateTiltEffects(DT);
		
		//MADDERS, 12/23/23: Hack for weird mesh reset shit that goes on sometimes.
		TMesh = VMP.GetHandednessPlayerMesh(THand);
		THand = GetHandType(THand);
		
		if ((Mesh != LeftPlayerViewMesh) && (LeftPlayerViewMesh != None) && (THand == 1))
		{
			Mesh = LeftPlayerViewMesh;
			SetHand(THand);
		}
		else if ((Mesh != PlayerViewMesh) && (PlayerViewMesh != None) && (THand != 1))
		{
			Mesh = PlayerViewMesh;
			SetHand(THand);
		}
		
		if ((VMP.Mesh != TMesh) && (TMesh != None))
		{
			VMP.Mesh = TMesh;
			VMP.LastMeshHandedness = THand;
		}
		
		if (!bLastHideHands)
		{
			bHideHands = False;
		}
		bLastHideHands = False;
		
		TSpeed = GetSpeedMult();
		TAnim = GetAnimType(bFastAnim);
		
		if (LastGetAnim != TAnim || TAnim == 'Walk' || TAnim == 'Still' || !IsAnimating() || TSpeed != LastSpeed)
		{
			LastSpeed = TSpeed;
			if ((bFastAnim == 2) && (VMP.AnimFrame > 0)) //Quick one-offs only.
			{
				switch(TAnim)
				{
					case 'PushButton':
						PlayAnim(TAnim, PushSpeed, 0.1);
						AnimFrame = 0.25;
					break;
					case 'Jump':
						TweenAnim(TAnim, 0.1);
						AnimFrame = 0.0;
					break;
					case 'Land':
						TweenAnim(TAnim, 0.1);
						AnimFrame = 0.0;
					break;
					case 'Crouch':
						TweenAnim(TAnim, 0.1);
						AnimFrame = 0.0;
					break;
					case 'Still':
						TweenAnim(TAnim, 0.1);
						AnimFrame = 0.0;
					break;
				}
			}
			else if (bFastAnim > 0)
			{
				LoopAnim(TAnim, TSpeed, 0.1, 1.0);
			}
			else
			{
				LoopAnim(TAnim, 1.0, 0.1, 1.0);
			}
		}
		LastGetAnim = AnimSequence;
	}
	else
	{
		bLastHideHands = True;
		IgnoreTimer = 0.3;
	}
}

function float GetSpeedMult()
{
	local float Ret;
	local VMDBufferPlayer VMP;
	
	Ret = 1.0;
	VMP = VMDBufferPlayer(Owner);
	
	if ((VMP != None) && (VMDBufferAugmentationManager(VMP.AugmentationSystem) != None))
	{
		//MADDERS, 12/23/23: Do this instead. Otherwise stacking gets very silly.
		Ret = VMDBufferAugmentationManager(VMP.AugmentationSystem).VMDConfigureSpeedMult(False);
		
		//Ret = VMP.GroundSpeed / VMP.Default.GroundSpeed;
	}
	
	return Ret;
}

simulated function vector CalcDrawOffset()
{
	local vector DrawOffset, WeaponBob, SwitchOffset;
	local VMDBufferPlayer VMP;
	local Vector TempVect;
	local float AddGap, TPer, TCap;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP != None)
	{
		TCap = VMP.PlayerHandsCap;
		TPer = 1.0 - FClamp(VMP.PlayerHandsLevel / TCap, 0.0, 1.0);
		SwitchOffset = (LowPlayerViewOffset - PlayerViewOffset) * TPer;
		
		TempVect = (0.9/VMP.Default.FOVAngle * (PlayerViewOffset + SwitchOffset));
		DrawOffset = (TempVect >> VMP.ViewRotation);
		
		DrawOffset += (VMP.EyeHeight * vect(0,0,1));
		WeaponBob = BobDamping * VMP.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * VMP.WalkBob.Z;
		DrawOffset += WeaponBob;
		
		if (VMP.bUseDynamicCamera)
		{
			AddGap = 5;
			
			AddGap *= (VMP.CollisionRadius / VMP.Default.CollisionRadius);
			DrawOffset += Vector(VMP.ViewRotation) * AddGap;
		}
	}
	
	return DrawOffset;
}

simulated function PostBeginPlay()
{
	// DEUS_EX CNN - scale since network passes vector components as ints
	LowPlayerViewOffset = (Default.PlayerViewOffset - vect(0,0,20)) * 100;
	
	Super.PostBeginPlay();
}

function BecomePickup()
{
	SetCollision(False, False, False);
	bCollideWorld = False;
}

function bool VMDIndexIsCloakException(int TestIndex)
{
	return false;
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
	
	if (Hand == 0)
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = -0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	}
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

function bool VMDOwnerIsCloaked()
{
	if (Owner == None) return false;
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsCloaked();
	}
	else
	{
		if (Owner.Style == STY_Translucent) return true;
	}
	return false;
}

function bool VMDOwnerIsRadarTrans()
{
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsRadarTrans();
	}
	
	return false;
}

//MADDERS: Use render of overlays to show JC hands.
simulated event RenderOverlays( Canvas Can )
{
	local bool bFemale;
	local byte OldFatness;
	local int i, BL;
	local float OldSG, RM;
	local ERenderStyle OldStyle;
  	local Texture TTex, OldTex[8], CloakTex[9], OldTexture;
	local VMDBufferPlayer VMP;
	
 	//Object load annoying. Do this instead.
 	VMP = VMDBufferPlayer(Owner);
	if (VMP != None)
 	{
		bFemale = VMP.bAssignedFemale;
		
		//Backup our old skins.
		/*for (i=0; i<ArrayCount(Multiskins); i++)
		{
			OldTex[i] = Multiskins[i];
		}*/
		OldTexture = Texture;
		OldStyle = Style;
  		OldSG = ScaleGlow;
		OldFatness = Fatness;
		
		if (VMDOwnerIsRadarTrans())
		{
			Fatness = Rand(4) + 126;
		}
		
  		switch (VMP.PlayerSkin)
  		{
   			case 0: //White
				if (bFemale)
				{
					TTex = Texture'NewHand01Female';
				}
				else
				{
    					TTex = Texture'NewHand01';
				}
   			break;
   			case 1: //Black
				if (bFemale)
				{
					TTex = Texture'NewHand02Female';
				}
				else
				{
    					TTex = Texture'NewHand02';
				}
   			break;
   			case 2: //Brown
				if (bFemale)
				{
					TTex = Texture'NewHand03Female';
				}
				else
				{
    					TTex = Texture'NewHand03';
				}
   			break;
   			case 3: //Redhead
				if (bFemale)
				{
					TTex = Texture'NewHand04Female';
				}
				else
				{
    					TTex = Texture'NewHand04';
				}
   			break;
   			case 4: //Pale
				if (bFemale)
				{
					TTex = Texture'NewHand05Female';
				}
				else
				{
    					TTex = Texture'NewHand05';
				}
   			break;
  		}
		
		/*switch(VMP.PlayerSkin)
		{
			case 0:	TTex = Texture'JCDentonTex0'; break;
			case 1:	TTex = Texture'JCDentonTex4'; break;
			case 2:	TTex = Texture'JCDentonTex5'; break;
			case 3:	TTex = Texture'JCDentonTex6'; break;
			case 4:	TTex = Texture'JCDentonTex7'; break;
		}*/
		
		VMDSetHandTextures(TTex, 'Normal');
		
		//Backup our old skins.
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
			OldTex[i] = Multiskins[i];
		}
  		
		if (VMDOwnerIsCloaked())
		{
			ScaleGlow *= 0.1;
			Style = STY_Translucent;
			Texture = CloakTex[8];
			VMDSetHandTextures(TTex, 'Cloak');
			
			VMDRenderBlock(Can);
		}
		else
		{
  			VMDRenderBlock(Can);
			
			BL = VMP.VMDGetBloodLevel();
			
			//THEN render a blood splash on our hands as an additional indicator.
			if (BL > 0)
			{
				RM = 1.0;
				switch (BL)
				{
					case 1:
  						TTex = Texture'WeaponBloodOverlayLight';
					break;
					case 2:
  						TTex = Texture'WeaponBloodOverlayHeavy';
 					break;
				}
				ScaleGlow = OldSG * BloodRenderMult * RM; //Looks like shit at full alpha.
				Style = STY_Translucent;
				VMDSetHandTextures(TTex, 'Blood');
  				
  				VMDRenderBlock(Can);
			}
		}
		
		//Restore old skins.
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
  			MultiSkins[i] = OldTex[i];
		}
		Scaleglow = OldSG;
 		Style = OldStyle;
		Texture = OldTexture;
		Fatness = OldFatness;
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

function VMDSetHandTextures(Texture TTex, name Context)
{
	local Texture CloakTex[9];
	local VMDBufferPlayer VMP;
	
	CloakTex[0] = Texture'VMDCloakFX01';
	CloakTex[1] = Texture'VMDCloakFX02';
	CloakTex[2] = Texture'VMDCloakFX03';
	CloakTex[3] = Texture'VMDCloakFX04';
	CloakTex[4] = Texture'VMDCloakFX05';
	CloakTex[5] = Texture'VMDCloakFX06';
	CloakTex[6] = Texture'VMDCloakFX07';
	CloakTex[7] = Texture'VMDCloakFX08';
	CloakTex[8] = Texture'VMDCloakFX09';
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None) return;
	
	if (Mesh == LeftPlayerViewMesh)
	{
		if (VMP.HealthArmLeft < 20)
		{
			if (Context == 'Blood' || Context == 'Cloak')
			{
				Multiskins[0] = Texture'BlackMaskTex';
				Multiskins[1] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[0] = Texture'PinkMaskTex';
				Multiskins[1] = Texture'PinkMaskTex';
			}
		}
		else
		{
			Multiskins[0] = TTex;
			Multiskins[1] = TTex;
			if (Context == 'Blood')
			{
				Multiskins[1] = TTex;
			}
			else if (Context == 'Cloak')
			{
				Multiskins[0] = CloakTex[0];
				Multiskins[1] = CloakTex[1];
			}
			else
			{
				//Multiskins[1] = VMP.Default.Multiskins[1];
			}
		}
		if (VMP.HealthArmRight < 20)
		{
			if (Context == 'Blood' || Context == 'Cloak')
			{
				Multiskins[2] = Texture'BlackMaskTex';
				Multiskins[3] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[2] = Texture'PinkMaskTex';
				Multiskins[3] = Texture'PinkMaskTex';
			}
		}
		else
		{
			Multiskins[2] = TTex;
			Multiskins[3] = TTex;
			if (Context == 'Blood')
			{
				Multiskins[3] = TTex;
			}
			else if (Context == 'Cloak')
			{
				Multiskins[2] = CloakTex[2];
				Multiskins[3] = CloakTex[3];
			}
			else
			{
				//Multiskins[3] = VMP.Default.Multiskins[1];
			}
		}
	}
	else
	{
		if (VMP.HealthArmRight < 20)
		{
			if (Context == 'Blood' || Context == 'Cloak')
			{
				Multiskins[0] = Texture'BlackMaskTex';
				Multiskins[1] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[0] = Texture'PinkMaskTex';
				Multiskins[1] = Texture'PinkMaskTex';
			}
		}
		else
		{
			Multiskins[0] = TTex;
			Multiskins[1] = TTex;
			if (Context == 'Blood')
			{
				Multiskins[1] = TTex;
			}
			else if (Context == 'Cloak')
			{
				Multiskins[0] = CloakTex[0];
				Multiskins[1] = CloakTex[1];
			}
			else
			{
				//Multiskins[1] = VMP.Default.Multiskins[1];
			}
		}
		if (VMP.HealthArmLeft < 20)
		{
			if (Context == 'Blood' || Context == 'Cloak')
			{
				Multiskins[2] = Texture'BlackMaskTex';
				Multiskins[3] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[2] = Texture'PinkMaskTex';
				Multiskins[3] = Texture'PinkMaskTex';
			}
		}
		else
		{
			Multiskins[2] = TTex;
			Multiskins[3] = TTex;
			if (Context == 'Blood')
			{
				Multiskins[3] = TTex;
			}
			else if (Context == 'Cloak')
			{
				Multiskins[2] = CloakTex[2];
				Multiskins[3] = CloakTex[3];
			}
			else
			{
				//Multiskins[3] = VMP.Default.Multiskins[1];
			}
		}
	}
}

function VMDRenderBlock(Canvas Canvas)
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int THand;
	local PlayerPawn PlayerOwner;
	
	if (bHideHands || Owner == None)
		return;
	
	PlayerOwner = PlayerPawn(Owner);
	
	if (PlayerOwner != None)
	{
		if (PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV)
		{
		 	if (VMDBufferPlayer(Owner) == None || VMDBufferPlayer(Owner).DrugEffectTimer > 10 || (VMDBufferPlayer(Owner).AddictionStates[4] > 0 && VMDBufferPlayer(Owner).AddictionTimers[4] >= 300))
			{
				return;
			}
		}
		bPlayerOwner = true;
		THand = GetHandType();
	}
	
	if (!bPlayerOwner || PlayerOwner.Player == None)
	{
		Pawn(Owner).WalkBob = vect(0,0,0);
	}
	
	SetLocation(Owner.Location + CalcDrawOffset());
	NewRot = Pawn(Owner).ViewRotation;
	
	//3/23/22: Patched in a lean fix. Yeah, really.
	if (THand == 0)
	{
		newRot.Roll += -2 * Default.Rotation.Roll;
	}
	else
	{
		newRot.Roll += Default.Rotation.Roll * THand;
	}
	
	if (VMDBufferPlayer(Owner) != None)
	{
		NewRot += VMDBufferPlayer(Owner).VMDRollModifier;
	}
	
	setRotation(newRot);
	
	Canvas.DrawActor(self, false);
}

defaultproperties
{
     WalkTilt(0)=(X=-12.500000,Y=-7.500000)
     WalkTilt(1)=(X=6.250000,Y=7.500000)
     WalkTilt(2)=(X=12.500000,Y=-7.500000)
     WalkTilt(2)=(X=-6.250000,Y=7.500000)
     WalkTiltIndices=4
     WalkTiltTimer(0)=0.000000
     WalkTiltTimer(1)=0.250000
     WalkTiltTimer(2)=0.500000
     WalkTiltTimer(3)=0.750000
     
     RunTilt(0)=(X=25.000000,Y=-7.500000)
     RunTilt(1)=(X=-12.500000,Y=7.500000)
     RunTilt(2)=(X=-25.000000,Y=-7.500000)
     RunTilt(3)=(X=12.500000,Y=7.500000)
     RunTiltIndices=4
     RunTiltTimer(0)=0.000000
     RunTiltTimer(1)=0.250000
     RunTiltTimer(2)=0.500000
     RunTiltTimer(3)=0.750000
     
     CrouchWalkTilt(0)=(X=-20.000000,Y=-10.000000)
     CrouchWalkTilt(1)=(X=10.000000,Y=10.000000)
     CrouchWalkTilt(2)=(X=20.000000,Y=-10.000000)
     CrouchWalkTilt(2)=(X=-10.000000,Y=10.000000)
     CrouchWalkTiltIndices=4
     CrouchWalkTiltTimer(0)=0.000000
     CrouchWalkTiltTimer(1)=0.250000
     CrouchWalkTiltTimer(2)=0.500000
     CrouchWalkTiltTimer(3)=0.750000
     
     TreadTilt(0)=(X=0.000000,Y=35.000000)
     TreadTilt(1)=(X=0.000000,Y=-35.000000)
     TreadTiltIndices=2
     TreadTiltTimer(0)=0.000000
     TreadTiltTimer(1)=0.500000
     
     JumpTilt=(X=0.000000,Y=-60.000000)
     JumpRate=10.000000
     LandTilt=(X=0.000000,Y=60.000000)
     LandRate=20.000000
     StartCrouchTilt=(X=0.000000,Y=50.000000)
     StartCrouchRate=4.000000
     EndCrouchTilt=(X=0.000000,Y=-50.000000)
     EndCrouchRate=4.000000
     
     PushSpeed=3.000000
     BloodRenderMult=0.900000
     
     bOnlyOwnerSee=true
     bLastHideHands=True
     bHideHands=True
     bHidden=True
     Physics=PHYS_None
     bCollideWorld=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Icon=None
     LargeIcon=None
     PickupMessage=""
     ItemArticle=""
     ItemName=""
     BeltDescription=""
     PlayerViewOffset=(X=5.000000,Y=0.000000,Z=-10.000000)
     PlayerViewMesh=LodMesh'VMDPlayerHands'
     LeftPlayerViewMesh=LodMesh'VMDPlayerHandsLeft'
}
