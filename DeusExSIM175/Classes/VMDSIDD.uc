//=============================================================================
// VMDSIDD.
//=============================================================================
class VMDSIDD extends Robot;

var localized string MsgSIDDKilled;

var(SIDD) bool bReconMode, bSaidOutOfAmmo, FlopDirection, bHasSkillware;
var(SIDD) float SpinUpModifier, FlopTime, ShowFlashTimer;
var(SIDD) string CustomName;
var(SIDD) VMDSIDDBase TurretBase;

var(SIDDAI) int NumReconTargets;
var(SIDDAI) float ReconScanTimer, TargetAcquiredSpeechTimer;

var(SIDDAI) Actor DestroyOtherActor;
var(SIDDAI) ScriptedPawn ReconTargets[16], DestroyOtherPawn, SIDDLastEnemy;

var(SIDDAI) AllianceInfoEx CachedAlliances[16];

var(SIDDHacks) bool bQueueTalentUpdate, bDebugState;
var(SIDDHacks) int LastYaw;
var(SIDDHacks) DeusExWeapon LastFirstWeapon;

function PostSpecialStatCheck()
{
	local DeusExWeapon DXW;
	
	Super.PostSpecialStatCheck();
	
	//MADDERS, 10/12/22: Boy. It really likes giving us ammo. Let's immediately stop doing that shit.
	DXW = GetFirstWeapon();
	if ((DXW != None) && (DXW.AmmoType != None))
	{
		DXW.AmmoType.AmmoAmount = 0;
	}
}

function ShowMuzzleFlash()
{
	ShowFlashTimer = 0.1;
}

function TweenToShoot(float TweenTime)
{
	ShowFlashTimer = 0.0;
	TweenAnimPivot('Shoot', tweentime);
}

function PlayShoot()
{
	local float TRate;
	local WeaponSIDDPistol TPis;
	
	TRate = 1.0;
	
	TPis = WeaponSIDDPistol(GetFirstWeapon());
	if (TPis != None)
	{
		TRate = 1.0 * TPis.SpinUpPercentage;
	}
	
	ShowFlashTimer = 0.0;
	PlayAnimPivot('Shoot', TRate, 0);
}

function DeusExWeapon GetFirstWeapon()
{
	local Inventory Inv;
	local DeusExWeapon DXW;
	
	if (LastFirstWeapon != None) return LastFirstWeapon;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		DXW = DeusExWeapon(Inv);
		if (DXW != None)
		{
			LastFirstWeapon = DXW;
			return DXW;
		}
	}
	return None;
}

function bool VMDCanBeSIDDEnemy(Actor Other)
{
	if (Other == None || PlayerPawn(Other) != None) return false;
	
	switch(Other.Class.Name)
	{
		case 'JaimeReyes':
		case 'PaulDenton':
		case 'AlexJacobson':
		case 'SamCarter':
		case 'JCDouble':
		case 'VMDMEGH':
		case 'VMDSIDD':
			ScriptedPawn(Other).ChangeAlly('PlayerDrone', 1.0, true);
			return false;
		break;
	}
	
	return true;
}

function PlayOutOfAmmoSound()
{
	if (bSaidOutOfAmmo) return;
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextOutOfAmmo);
	
	if (!bDeleteMe)
	{
		bSaidOutOfAmmo = true;
		PlaySound(SpeechOutOfAmmo, SLOT_None,,, 2048);
	}
}

// ----------------------------------------------------------------------
// ChangeAlly()
// ----------------------------------------------------------------------

function ChangeAlly(Name newAlly, optional float allyLevel, optional bool bPermanent, optional bool bHonorPermanence)
{
	local int i;
	
	//if (!bReconMode)
	//{
		// Members of the same alliance will ALWAYS be friendly to each other
		if (newAlly == Alliance)
		{
			allyLevel  = 1;
			bPermanent = true;
		}
		
		if (bHonorPermanence)
		{
			for (i=0; i<16; i++)
				if (AlliancesEx[i].AllianceName == newAlly)
					if (AlliancesEx[i].bPermanent)
						break;
			if (i < 16)
				return;
		}		
		
		if (allyLevel < -1)
			allyLevel = -1;
		if (allyLevel > 1)
			allyLevel = 1;
		
		for (i=0; i<16; i++)
			if ((AlliancesEx[i].AllianceName == newAlly) || (AlliancesEx[i].AllianceName == ''))
				break;
		
		if (i >= 16)
			for (i=15; i>0; i--)
			AlliancesEx[i] = AlliancesEx[i-1];
		
		AlliancesEx[i].AllianceName         = newAlly;
		AlliancesEx[i].AllianceLevel        = allyLevel;
		AlliancesEx[i].AgitationLevel       = 0;
		AlliancesEx[i].bPermanent           = bPermanent;
		
		bAlliancesChanged    = True;
		bNoNegativeAlliances = False;
	//}
	/*else
	{
		// Members of the same alliance will ALWAYS be friendly to each other
		if (newAlly == Alliance)
		{
			allyLevel  = 1;
			bPermanent = true;
		}
		
		if (bHonorPermanence)
		{
			for (i=0; i<16; i++)
				if (CachedAlliances[i].AllianceName == newAlly)
					if (CachedAlliances[i].bPermanent)
						break;
			if (i < 16)
				return;
		}		
		
		if (allyLevel < -1)
			allyLevel = -1;
		if (allyLevel > 1)
			allyLevel = 1;
		
		for (i=0; i<16; i++)
			if ((CachedAlliances[i].AllianceName == newAlly) || (CachedAlliances[i].AllianceName == ''))
				break;
		
		if (i >= 16)
			for (i=15; i>0; i--)
			CachedAlliances[i] = CachedAlliances[i-1];
		
		CachedAlliances[i].AllianceName         = newAlly;
		CachedAlliances[i].AllianceLevel        = allyLevel;
		CachedAlliances[i].AgitationLevel       = 0;
		CachedAlliances[i].bPermanent           = bPermanent;
		
		bAlliancesChanged    = True;
		bNoNegativeAlliances = False;
	}*/
}

// ----------------------------------------------------------------------
// AgitateAlliance()
// ----------------------------------------------------------------------

function AgitateAlliance(Name newEnemy, float agitation)
{
	local int   i;
	local float oldLevel;
	local float newLevel;
	
	if (NewEnemy == 'Player') return;
	
	//if (!bReconMode)
	//{
		if (newEnemy != '')
		{
			for (i=0; i<16; i++)
				if ((AlliancesEx[i].AllianceName == newEnemy) || (AlliancesEx[i].AllianceName == ''))
					break;
			
			if (i < 16)
			{
				if ((AlliancesEx[i].AllianceName == '') || !(AlliancesEx[i].bPermanent))
				{
					if (AlliancesEx[i].AllianceName == '')
						AlliancesEx[i].AllianceLevel = 0;
					oldLevel = AlliancesEx[i].AgitationLevel;
					newLevel = oldLevel + agitation;
						if (newLevel > 1.0)
						newLevel = 1.0;
					AlliancesEx[i].AllianceName   = newEnemy;
					AlliancesEx[i].AgitationLevel = newLevel;
					if ((newEnemy == 'Player') && (oldLevel < 1.0) && (newLevel >= 1.0))  // hack
						PlayerAgitationTimer = 2.0;
					bAlliancesChanged = True;
				}
			}
		}
	//}
	/*else
	{
		if (newEnemy != '')
		{
			for (i=0; i<16; i++)
				if ((CachedAlliances[i].AllianceName == newEnemy) || (CachedAlliances[i].AllianceName == ''))
					break;
			
			if (i < 16)
			{
				if ((CachedAlliances[i].AllianceName == '') || !(CachedAlliances[i].bPermanent))
				{
					if (CachedAlliances[i].AllianceName == '')
						CachedAlliances[i].AllianceLevel = 0;
					oldLevel = CachedAlliances[i].AgitationLevel;
					newLevel = oldLevel + agitation;
						if (newLevel > 1.0)
						newLevel = 1.0;
					CachedAlliances[i].AllianceName   = newEnemy;
					CachedAlliances[i].AgitationLevel = newLevel;
					if ((newEnemy == 'Player') && (oldLevel < 1.0) && (newLevel >= 1.0))  // hack
						PlayerAgitationTimer = 2.0;
					bAlliancesChanged = True;
				}
			}
		}
	}*/
}


// ----------------------------------------------------------------------
// UpdateAgitation()
// ----------------------------------------------------------------------

function UpdateAgitation(float deltaSeconds)
{
	local float mult;
	local float decrement;
	local int   i;
	
	//if (!bReconMode)
	//{
		if (AgitationCheckTimer > 0)
		{
			AgitationCheckTimer -= deltaSeconds;
			if (AgitationCheckTimer < 0)
				AgitationCheckTimer = 0;
		}	
		
		decrement = 0;
		if (AgitationTimer > 0)
		{
			if (AgitationTimer < deltaSeconds)
			{
				mult = 1.0 - (AgitationTimer/deltaSeconds);
				AgitationTimer = 0;
				decrement = mult * (AgitationDecayRate*deltaSeconds);
			}
			else
				AgitationTimer -= deltaSeconds;
		}
		else
			decrement = AgitationDecayRate*deltaSeconds;
		
		if (bAlliancesChanged && (decrement > 0))
		{
			bAlliancesChanged = False;
			for (i=15; i>=0; i--)
			{
				if ((AlliancesEx[i].AllianceName != '') && (!AlliancesEx[i].bPermanent))
				{
					if (AlliancesEx[i].AgitationLevel > 0)
					{
						bAlliancesChanged = true;
						AlliancesEx[i].AgitationLevel -= decrement;
						if (AlliancesEx[i].AgitationLevel < 0)
							AlliancesEx[i].AgitationLevel = 0;
					}
				}
			}
		}
	//}
	/*else
	{
		if (AgitationCheckTimer > 0)
		{
			AgitationCheckTimer -= deltaSeconds;
			if (AgitationCheckTimer < 0)
				AgitationCheckTimer = 0;
		}	
		
		decrement = 0;
		if (AgitationTimer > 0)
		{
			if (AgitationTimer < deltaSeconds)
			{
				mult = 1.0 - (AgitationTimer/deltaSeconds);
				AgitationTimer = 0;
				decrement = mult * (AgitationDecayRate*deltaSeconds);
			}
			else
				AgitationTimer -= deltaSeconds;
		}
		else
			decrement = AgitationDecayRate*deltaSeconds;
		
		if (bAlliancesChanged && (decrement > 0))
		{
			bAlliancesChanged = False;
			for (i=15; i>=0; i--)
			{
				if ((CachedAlliances[i].AllianceName != '') && (!CachedAlliances[i].bPermanent))
				{
					if (CachedAlliances[i].AgitationLevel > 0)
					{
						bAlliancesChanged = true;
						CachedAlliances[i].AgitationLevel -= decrement;
						if (CachedAlliances[i].AgitationLevel < 0)
							CachedAlliances[i].AgitationLevel = 0;
					}
				}
			}
		}
	}*/
}

function ToggleReconMode()
{
	/*bReconMode = !bReconMode;
	if (bReconMode)
	{
		CacheAlliances();
	}
	else
	{
		UncacheAlliances();
	}*/
}

function CacheAlliances()
{
	local int i;
	local AllianceInfoEx EmptyAlliance;
	local ScriptedPawn SP;
	
	for (i=0; i<ArrayCount(AlliancesEx); i++)
	{
		CachedAlliances[i] = AlliancesEx[i];
		AlliancesEx[i] = EmptyAlliance;
	}
	
	//Our defining feature is the ability to make peace with this entity in a mutual sense.
	forEach AllActors(class'ScriptedPawn', SP)
	{
		if ((SP != None) && (SP.GetPawnAllianceType(Self) == ALLIANCE_Hostile))
		{
			SP.ChangeAlly('PlayerDrone', 1, true);
			if (SP.Enemy == Self)
			{
				SP.SetEnemy(None);
			}
		}
	}
}

function UncacheAlliances()
{
	local int i;
	local AllianceInfoEx EmptyAlliance;
	
	for (i=0; i<ArrayCount(AlliancesEx); i++)
	{
		AlliancesEx[i] = CachedAlliances[i];
		CachedAlliances[i] = EmptyAlliance;
	}
}

function int VMDGetMaxHealth()
{
	local int Ret;
	
	if (VMDGetMissionNumber() < 5)
	{
		Ret = 15;
	}
	else
	{
		Ret = 30;
	}
	
	if (VMDMayhemEnabled())
	{
		Ret *= 2;
	}
	
	return Ret;
}

function int VMDGetMaxEMPHitPoints()
{
	local int Ret;
	
	Ret = 50;
	
	if (VMDMayhemEnabled())
	{
		Ret *= 2;
	}
	
	return Ret;
}

function bool VMDMayhemEnabled()
{
	if (GetLastVMP() != None)
	{
		return LastVMP.bMayhemSystemEnabled;
	}
	return false;
}

//MADDERS, 9/14/22: Reduce select damage types that hard counter us. Try and balance things out, you know?
function float ShieldDamage(Name damageType)
{
	local float Ret;
	
	switch(DamageType)
	{
		case 'Exploded':
			Ret = 0.35;
		break;
		case 'Burned':
			Ret = 0.5;
		break;
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

//MADDERS, 9/14/22: Don't draw shield tho.
function DrawShield()
{
}

function PlayTargetAcquiredSound()
{
	if (TargetAcquiredSpeechTimer > 0.0) return;
	
	TargetAcquiredSpeechTimer = 2.0;
	Super.PlayTargetAcquiredSound();
}

function int VMDGetMissionNumber()
{
	local DeusExLevelInfo DXLI;
	
	ForEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		return DXLI.MissionNumber;
	}
	
	return 1;
}

simulated event RenderOverlays( canvas Canvas )
{
	Super.RenderOverlays(Canvas);
}

function string VMDGetDisplayName(string InName)
{
	if (CustomName == "")
	{
		return InName;
	}
	else
	{
		return CustomName;
	}
}

function InvokeSIDDManagementWindow(DeusExPlayer DXP)
{
 	local DeusExRootWindow Root;
	local VMDMenuSIDDManagement TarWindow;
	
	if (DXP == None) return;
	
  	Root = DeusExRootWindow(DXP.RootWindow);
    	if (Root != None)
  	{
		//Set to true for real time ordering.
   		TarWindow = VMDMenuSIDDManagement(Root.InvokeMenuScreen(Class'VMDMenuSIDDManagement', False));
		if (TarWindow != None)
		{
			if (TarWindow.CustomNameEntry != None)
			{
				TarWindow.CustomNameEntry.SetText(CustomName);
			}
			TarWindow.UpdateInfo();
		}
	}
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	Super.Frob(Frobber, FrobWith);
	
	if ((EMPHitPoints > 0) && (DeusExPlayer(Frobber) != None))
	{
		InvokeSIDDManagementWindow(DeusExPlayer(Frobber));
	}
}

function CheckHealthScaling()
{
  	bSetupBuffedHealth = True;
 	
	StartingHealthValues[0] = HealthHead;
	StartingHealthValues[1] = HealthTorso;
	StartingHealthValues[2] = HealthArmLeft;
	StartingHealthValues[3] = HealthArmRight;
	StartingHealthValues[4] = HealthLegLeft;
	StartingHealthValues[5] = HealthLegRight;
	
	StartingHealthValues[6] = VMDGetMaxHealth();
}

function ApplySpecialStats()
{
	local VMDBufferPlayer VMP;
	
	Super.ApplySpecialStats();
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (bQueueTalentUpdate))
	{
		bQueueTalentUpdate = false;
		UpdateTalentEffects(VMP);
	}
}

function UpdateHackAlliances()
{
	local string TName;
	local ScriptedPawn SP;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP == None) return;
	
	TName = VMP.VMDGetMapName();
	switch(TName)
	{
		case "75_ZODIAC_NEWMEXICO_HOLLOMAN":
			ChangeAlly('Good_guys', 1, true);
			ForEach AllActors(class'ScriptedPawn', SP)
			{
				if (SP.IsA('AmandaShaysFast'))
				{
					SP.ChangeAlly('PlayerDrone', 1, true);
				}
			}
		break;
	}
}

function DropAmmo(Vector DropVect)
{
	local DeusExWeapon DXW;
	local DeusExAmmo DXA;
	
	DXW = GetFirstWeapon();
	if (DXW != None)
	{
		DXA = DeusExAmmo(DXW.AmmoType);
	}
	
	if ((DXA != None) && (!DXA.bDeleteMe) && (DXA.PickupViewMesh != LODMesh'TestBox'))
	{
		if (DXA.AmmoAmount <= 0)
		{
			DXA.Destroy();
		}
		else
		{
			DXA.DropFrom(DropVect);
			DXA.AmmoAmount = Min(DXA.MaxAmmo, DXA.AmmoAmount);
		}
	}
}

function ReturnToItem()
{
	local VMDSIDDPickup TPick;
	
	DropAmmo(Location);
	
	VMDCleanFakeDroneActors();
	
	TPick = Spawn(class'VMDSIDDPickup',,, Location, Rotation);
	if (TPick != None)
	{
		TPick.CustomName = CustomName;
		TPick.DroneHealth = Health;
		TPick.DroneEMPHealth = EMPHitPoints;
		Destroy();
	}
}

function SetupWeapon(bool bDrawWeapon, optional bool bForce)
{
	if ((bKeepWeaponDrawn) && (!bForce))
	{
		bDrawWeapon = true;
	}
	
	if (bDrawWeapon)
	{
		SwitchToBestWeapon();
	}
	else
	{
		SetWeapon(None);
	}
}

function UpdateTalentEffects(VMDBufferPlayer VMP)
{
	local bool bForceReconState, NewbReconMode;
	local VMDMEGH TMegh, LastMEGH;
	local VMDSIDD TSidd, LastSIDD;
	
	forEach AllActors(Class'VMDMEGH', TMegh)
	{
		if ((TMegh != Self) && (!TMegh.IsInState('Dying')) && (TMegh.EMPHitPoints > 0))
		{
			bForceReconState = true;
			NewbReconMode = TMegh.bReconMode;
			LastMEGH = TMegh;
			break;
		}
	}
	forEach AllActors(class'VMDSidd', TSidd)
	{
		if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			//bForceReconState = true;
			//NewbReconMode = TSidd.bReconMode;
			LastSIDD = TSidd;
			break;
		}
	}
	
	/*if (bForceReconState)
	{
		bReconMode = NewbReconMode;
		if (bReconMode)
		{
			CacheAlliances();
		}
		else
		{
			UncacheAlliances();
		}
		
		if (LastMEGH != None)
		{
			MatchAlliances(LastMEGH);
		}
		else if (LastSIDD != None)
		{
			MatchAlliances(LastSIDD);
		}
	}*/

	if ((VMP != None) && (EMPHitPoints > 0))
	{
		BaseAccuracy = -0.25;
		SpinUpModifier = 1.0;
		bHasSkillware = false;
		if (VMP.HasSkillAugment("TagTeamSkillware"))
		{
			BaseAccuracy = -0.5;
			SpinUpModifier = 5.00;
			bHasSkillware = true;
		}
	}
	
	AIStartEvent('WeaponDrawn', EAITYPE_Visual);
	if (Health < 1) Health = 1;
	
	SetupWeapon(true, true);
	if (TurretBase == None)
	{
		TurretBase = Spawn(class'VMDSIDDBase');
	}
	UpdateHackAlliances();
}

function SIDDIssueOrder(name NewOrderName, Actor NewOrderActor, optional Actor NewSecondaryOrderActor, optional bool bDontWipe)
{
	local bool bLockOrderActor, bEngageOrderActor;
	
	if (!bDontWipe)
	{
		DestroyOtherActor = None;
		DestroyOtherPawn = None;
		SIDDLastEnemy = None;
	}
	
	switch(NewOrderName)
	{
		case 'Attacking':
			if (ScriptedPawn(NewOrderActor) == None)
			{
				return;
			}
			bLockOrderActor = true;
			bEngageOrderActor = true;
		break;
		case 'DestroyingOther':
			if (ScriptedPawn(NewOrderActor) == None)
			{
				return;
			}
			DestroyOtherPawn = ScriptedPawn(NewOrderActor);
			DestroyOtherActor = NewSecondaryOrderActor;
			bLockOrderActor = true;
			bEngageOrderActor = true;
		break;
	}
	
	if (bLockOrderActor) OrderActor = NewOrderActor;
	SetOrders(NewOrderName,, true);
	if (bLockOrderActor) OrderActor = NewOrderActor;
	
	if (bEngageOrderActor)
	{
		SetEnemy(ScriptedPawn(NewOrderActor));
	}
}

function FollowOrders(optional bool bDefer)
{
	local bool bSetEnemy;
	local bool bUseOrderActor;

	if (Orders != '')
	{
		if ((Orders == 'Fleeing') || (Orders == 'Attacking') || 
			/*(Orders == 'DestroyingOther') ||*/ (Orders == 'Oppressing'))
		{
			bSetEnemy      = true;
			bUseOrderActor = true;
		}
		else if ((Orders == 'WaitingFor') || (Orders == 'GoingTo') ||
		         (Orders == 'RunningTo') || (Orders == 'Following') ||
		         (Orders == 'Sitting') || (Orders == 'Shadowing') ||
		         (Orders == 'DebugFollowing') || (Orders == 'DebugPathfinding'))
		{
			bSetEnemy      = false;
			bUseOrderActor = true;
		}
		else
		{
			bSetEnemy      = false;
			bUseOrderActor = false;
		}
		if (bUseOrderActor)
		{
			FindOrderActor();
			if (bSetEnemy)
				SetEnemy(Pawn(OrderActor), 0, true);
		}
		if (bDefer)  // hack
			SetState(Orders);
		else
			GotoState(Orders);
	}
	else
	{
		if (bDefer)
			SetState('Wandering');
		else
			GotoState('Wandering');
	}
}

function AddReconTarget(ScriptedPawn NewEnemy)
{
	local int i;
	
	if (NewEnemy == None) return;
	if (!VMDCanBeSIDDEnemy(NewEnemy)) return;
	
	if (NumReconTargets < ArrayCount(ReconTargets))
	{
		for(i=0; i<NumReconTargets; i++)
		{
			if (NewEnemy == ReconTargets[i])
			{
				return;
			}
		}
		
		ReconTargets[NumReconTargets] = NewEnemy;
		NumReconTargets++;
	}
}

function GiveReconPulse()
{
	local bool bPaved;
	local int i, j, HighestValid;
	
	local ScriptedPawn SP;
	local VMDBufferPlayer RenderPlayer;
	local VMDFakeRadarMarker RadarMark, LastMark;
	
	ForEach AllActors(class'VMDBufferPlayer', RenderPlayer) break;
	if (RenderPlayer == None) return;
	
	forEach AllActors(class'ScriptedPawn', SP)
	{
		if ((SP.GetPawnAllianceType(RenderPlayer) == ALLIANCE_Hostile) && (FastTrace(SP.Location, Location)) && (AICanSee(orderActor, , false, false, false, true) > 0))
		{
			AddReconTarget(SP);
		}
	}
	
	For (i=0; i<ArrayCount(ReconTargets); i++)
	{
		if ((ReconTargets[i] != None) && (!ReconTargets[i].bDeleteMe) && (!ReconTargets[i].IsInState('Dying')) && (!ReconTargets[i].IsA('VMDMegh')) && (!ReconTargets[i].IsA('VMDSidd')) && (FastTrace(ReconTargets[i].Location, Location)))
		{
			HighestValid = i;
			RadarMark = Spawn(class'VMDFakeRadarMarker',,, ReconTargets[i].Location);
			if (RadarMark != None)
			{
				RadarMark.bPlayerAlly = (ReconTargets[i].GetPawnAllianceType(RenderPlayer) != ALLIANCE_Hostile);
				RadarMark.RenderPlayer = RenderPlayer;
				RadarMark.ReconTarget = ReconTargets[i];
				if (LastMark != None)
				{
					LastMark.NextMark = RadarMark;
				}
				else
				{
					RenderPlayer.FirstRadarMark = RadarMark;
				}
				LastMark = RadarMark;
			}
		}
		else
		{
			For (j=i+1; j<ArrayCount(ReconTargets); j++)
			{
				if ((ReconTargets[j] != None) && (FastTrace(ReconTargets[j].Location, Location)))
				{
					bPaved = true;
					ReconTargets[i] = ReconTargets[j];
					ReconTargets[j] = None;
					j--;
					break;
				}
			}
			if (!bPaved)
			{
				ReconTargets[i] = None;
			}
		}
	}
	
	NumReconTargets = HighestValid+1;
}

function IncreaseAgitation(Actor actorInstigator, optional float AgitationLevel)
{
	local Pawn  instigator;
	local float minLevel;
	local int TProvo;
	
	//MADDERS, 8/29/22: Don't hate the player, no matter what.
	//Last time I made a coop AI, it didn't retain this lesson very well, despite all reason. Scary, but true.
	if (!VMDCanBeSIDDEnemy(ActorInstigator))
	{
		return;
	}
	
	instigator = InstigatorToPawn(actorInstigator);
	if (instigator != None)
	{
		AgitationTimer = AgitationSustainTime;
		if (AgitationCheckTimer <= 0)
		{
			AgitationCheckTimer = 1.5;  // hardcoded for now
			if (AgitationLevel == 0)
			{
				if (MaxProvocations < 0)
					MaxProvocations = 0;
				
				//MADDERS: Forgive aggression less in general, but more if we're in a combat state.
				//Update: This system is more than a little jank. Just skip aggression while fighting.
				TProvo = MaxProvocations-1;
				if (TProvo < 0)
					TProvo = 0;
				
				AgitationLevel = 1.0/(TProvo+1);
			}
			if (AgitationLevel > 0)
			{
				bAlliancesChanged = True;
				bNoNegativeAlliances = False;
				AgitateAlliance(instigator.Alliance, AgitationLevel);
			}
		}
	}
}

function SetOrders(Name orderName, optional Name newOrderTag, optional bool bImmediate)
{
	local bool bHostile;
	local Pawn orderEnemy;
	
	switch (orderName)
	{
		case 'Attacking':
		case 'Fleeing':
		case 'Alerting':
		case 'Seeking':
			bHostile = true;
			break;
		default:
			bHostile = false;
			break;
	}
	
	if (!bHostile)
	{
		bSeatHackUsed = false;  // hack!
		Orders   = orderName;
		OrderTag = newOrderTag;

		if (bImmediate)
			FollowOrders(true);
	}
	else
	{
		ReactionLevel = 1.0;
		if ((NewOrderTag == '') && (ScriptedPawn(OrderActor) != None))
		{
			OrderEnemy = ScriptedPawn(OrderActor);
		}
		else
		{
			orderEnemy = Pawn(FindTaggedActor(newOrderTag, false, Class'Pawn'));
		}
		
		if (orderEnemy != None)
		{
			ChangeAlly(orderEnemy.Alliance, -1, true);
			if (SetEnemy(orderEnemy))
				SetState(orderName);
		}
	}
}

function bool SetEnemy(Pawn newEnemy, optional float newSeenTime, optional bool bForce)
{
	local bool FlagGo;
	
	if (!VMDCanBeSIDDEnemy(NewEnemy))
	{
		return false;
	}
	
	/*if (bReconMode)
	{
		AddReconTarget(ScriptedPawn(NewEnemy));
		return false;
	}*/
	//else
	//{
		FlagGo = false;
		if (bForce) FlagGo = True;
		else if (IsValidEnemy(newEnemy))
		{
			if (Robot(newEnemy) == None || !Robot(newEnemy).IsInState('Disabled')) FlagGo = True;
		}
		
		if (FlagGo)
		{
			if (newEnemy != Enemy)
			{
				EnemyTimer = 0;
			}
			Enemy = newEnemy;
			EnemyLastSeen = newSeenTime;	
			
			return True;
		}
		else
		{
			return False;
		}
	//}
}

//MADDERS, 8/31/22: Stop attacking if we're in recon mode.
//Instead, mark dudes out.
function HandleEnemy()
{
	/*if (bReconMode)
	{
		if ((Enemy != None) && (FastTrace(Enemy.Location, Location)))
		{
			AddReconTarget(ScriptedPawn(Enemy));
		}
	}*/
	//else
	//{
		SetState('HandlingEnemy', 'Begin');
	//}
}

function int GetDroneWeaponMaxRange()
{
	local int Ret;
	
	Ret = 736;
	if (bHasSkillware) Ret = 920;
	
	return Ret;
}

function int GetDroneWeaponMinRange()
{
	return 0;
}

function Tick(float DT)
{
	local float GetYaw, YawMargins[2];
	local Vector TLoc;
	local DeusExAmmo DXA;
	local DeusExPlayer HackPlayer;
	local DeusExWeapon DXW;
	
	if (bDebugState)
	{
		BroadcastMessage("SIDD CURRENT STATE?"@GetStateName());
		Log("SIDD CURRENT STATE?"@GetStateName());
		bDebugState = false;
	}
	
	if ((SparkGen != None) && (!SparkGen.bDeleteMe))
	{
		TLoc = Location;
		TLoc.z += CollisionHeight/2;
		SparkGen.SetLocation(TLoc);
	}
	
	if (ShowFlashTimer > 0)
	{
		Multiskins[2] = Texture'FlatFXTex34';
	}
	else
	{
		Multiskins[2] = Texture'BlackMaskTex';
	}
	
	if (ShowFlashTimer > -0.65)
	{
		ShowFlashTimer -= DT;
	}
	
	if ((!IsInState('Dying')) && (EMPHitPoints > 0))
	{
		MaxRange = GetDroneWeaponMaxRange();
		MinRange = GetDroneWeaponMinRange();
		
		if (FlopTime > -1.0)
		{
			FlopTime -= DT;
		}
		else
		{
			FlopTime = 3.0;
			FlopDirection = !FlopDirection;
		}
		
		if ((FlopTime > 0.0) && (IsInState('Standing')))
		{
			if (FlopDirection)
			{
				DesiredRotation.Yaw += 10922 * DT * 2;
			}
			else
			{
				DesiredRotation.Yaw -= 10922 * DT * 2;
			}
		}
		
		HackPlayer = DeusExPlayer(GetPlayerPawn());
		
		if (TargetAcquiredSpeechTimer >= 0.0)
		{
			TargetAcquiredSpeechTimer -= DT;
		}
		
		/*if (bReconMode)
		{
			ReconScanTimer += DT;
			if (ReconScanTimer > 2.0)
			{
				GiveReconPulse();
				ReconScanTimer = 0;
			}
		}*/
		
		if (IsInState('DestroyingOther'))
		{
			if (DestroyOtherPawn == None)
			{
				SIDDIssueOrder('Standing', None);
			}
			else if (Enemy != DestroyOtherPawn)
			{
				SetEnemy(DestroyOtherPawn);
			}
		}
		
		DXW = GetFirstWeapon();
		if (DXW != None)
		{
			DXA = DeusExAmmo(DXW.AmmoType);
			if (DXA == None || DXA.AmmoAmount <= 0 || DXW.ClipCount >= DXW.ReloadCount)
			{
				Multiskins[1] = Texture'PinkMaskTex';
				if (AnimSequence != 'Still2')
				{
					PlayAnim('Still2',, 0);
				}
				if (!bSaidOutOfAmmo)
				{
					PlayOutOfAmmoSound();
				}
			}
			else
			{
				Multiskins[1] = Texture'Ammo762mmTex';
				if (Enemy == None || ShowFlashTimer <= -0.65)
				{
					if (AnimSequence != 'Still')
					{
						PlayAnim('Still',, 0);
					}
				}
			}
		}
		
		if ((TurretBase != None) && (!TurretBase.bDeleteMe))
		{
			GetYaw = Rotation.Yaw;
			if (GetYaw != LastYaw)
			{
				SoundRadius = 24;
				SoundPitch = 64;
				SoundVolume = 128;
				AmbientSound = Sound'AutoTurretMove';
			}
			else
			{
				AmbientSound = None;
			}
			LastYaw = GetYaw;
			
			TurretBase.SetLocation(Location);
			TurretBase.SetRotation(rot(0,0,0));
			
			YawMargins[0] = 729;
			YawMargins[1] = 1457;
			GetYaw = float(Rotation.Yaw) % 2184.53;
			
			if (GetYaw < YawMargins[0])
			{
				TurretBase.Multiskins[4] = Texture'VMDSIDDTex05C';
			}
			else if (GetYaw < YawMargins[1])
			{
				TurretBase.Multiskins[4] = Texture'VMDSIDDTex05B';
			}
			else
			{
				TurretBase.Multiskins[4] = Texture'VMDSIDDTex05A';
			}
		}
	}
	Super.Tick(DT);
}

function UpdateMagSkin()
{
	local DeusExWeapon DXW;
	local DeusExAmmo DXA;
	
	DXW = GetFirstWeapon();
	if (DXW != None)
	{
		DXA = DeusExAmmo(DXW.AmmoType);
		if (DXA == None || DXA.AmmoAmount <= 0 || DXW.ClipCount >= DXW.ReloadCount)
		{	
			Multiskins[1] = Texture'PinkMaskTex';
		}
		else
		{
			Multiskins[1] = Texture'Ammo762mmTex';
		}
	}
}

function PlaySIDDDeathSound()
{
	local VMDBufferPlayer VMP;
	
	AIEndEvent('WeaponDrawn', EAITYPE_Visual);
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		VMP.PlaySound(sound'NanoSwordSelect', SLOT_Interface, 255,, 255, 3.0);
		VMP.ClientMessage(SprintF(MsgSIDDKilled, CustomName));
		
		VMDCleanFakeDroneActors();
	}
}

function VMDEMPHook()
{
	PlaySIDDDeathSound();
}

function Carcass SpawnCarcass()
{
	if (EMPHitPoints > 0)
	{
		PlaySIDDDeathSound();
	}
	return Super.SpawnCarcass();
}

function Destroyed()
{
	Super.Destroyed();
	
	if (TurretBase != None)
	{
		TurretBase.Destroy();
	}
}

function VMDCleanFakeDroneActors()
{
	local VMDMEGH UseMegh, TMegh;
	local VMDSIDD UseSidd, TSidd;
	
	local VMDFakeDestroyOtherPawn TDest;
	
	forEach AllActors(class'VMDSIDD', TSidd)
	{
		if ((TSidd != Self) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			UseSidd = TSidd;
			break;
		}
	}
	forEach AllActors(class'VMDMEGH', TMegh)
	{
		if ((!TMegh.IsInState('Dying')) && (TMegh.EMPHitPoints > 0))
		{
			UseMegh = TMegh;
			break;
		}
	}
	
	if ((UseSidd == None) && (UseMegh == None))
	{
		forEach AllActors(class'VMDFakeDestroyOtherPawn', TDest)
		{
			TDest.Destroy();
		}
	}
}

state DestroyingOther expands Attacking
{
	function bool HasEnemyTimedOut()
	{
		return false;
	}
	function UpdateActorVisibility(actor seeActor, float deltaSeconds, float checkTime, bool bCheckDir)
	{
		EnemyLastSeen = 0;
	}
}

function bool AISafeToShoot(out Actor hitActor, vector traceEnd, vector traceStart, optional vector extent, optional bool bIgnoreLevel)
{
	local Actor            traceActor;
	local Vector           hitLocation;
	local Vector           hitNormal;
	local Pawn             tracePawn;
	local DeusExDecoration traceDecoration;
	local DeusExMover      traceMover;
	local bool             bSafe;
	local float TPen, NeededPen;
	local Vector PenBoxMin, PenBoxMax;
	
	// Future improvement:
	// Ideally, this should use the ammo type to determine how many shots
	// it will take to destroy an obstruction, and call it unsafe if it takes
	// more than x shots.  Also, if the ammo is explosive, and the
	// obstruction is too close, it should never be safe...
	
	bSafe    = true;
	hitActor = None;
	
	foreach TraceActors(Class'Actor', traceActor, hitLocation, hitNormal, traceEnd, traceStart, extent)
	{
		if (hitActor == None)
			hitActor = traceActor;
		if (traceActor == Level)
		{
			if (!bIgnoreLevel)
				bSafe = false;
			break;
		}
		tracePawn = Pawn(traceActor);
		if (tracePawn != None)
		{
			if (TracePawn == DestroyOtherPawn)
			{
				bSafe = true;
				break;
			}
			if (tracePawn != self)
			{
				if (GetPawnAllianceType(tracePawn) != ALLIANCE_Hostile)
					bSafe = false;
				break;
			}
		}
		traceDecoration = DeusExDecoration(traceActor);
		if (traceDecoration != None)
		{
			if (TraceDecoration == DestroyOtherActor)
			{
				bSafe = true;
				break;
			}
			else if (((traceDecoration.bExplosive) && (VSize(traceDecoration.Location - Location) <= (traceDecoration.explosionRadius))) || traceDecoration.bInvincible)
			{
				bSafe = false;
				break;
			}
			/*if ((traceDecoration.HitPoints > 20) || (traceDecoration.minDamageThreshold > 4))  // hack
			{
				bSafe = false;
				break;
			}*/
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon).ProjectileClass != None) && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon) != None) && ((DeusExWeapon(Weapon).Default.HitDamage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
		}
		traceMover = DeusExMover(traceActor);
		if (traceMover != None)
		{
			//MADDERS: Modified, ported code, with the intent of letting us shoot through thin doors.
			if (DeusExWeapon(Weapon) != None)
			{
				//HACK: Use metal as the group so we assume ricochets are always possible.
				TPen = DeusExWeapon(Weapon).VMDGetMaterialPenetration(Level);
				if ((TPen > 0) && (DeusExWeapon(Weapon).VMDAngleMeansRicochet(HitLocation, HitLocation - TraceStart, HitNormal, 'Metal', TraceActor)))
				{
					TPen = 0;
				}
				
				TraceMover.GetBoundingBox(PenBoxMin, PenBoxMax, false, TraceMover.KeyPos[TraceMover.KeyNum]+TraceMover.BasePos, TraceMover.KeyRot[TraceMover.KeyNum]+TraceMover.BaseRot);
				//NeededPen = Abs(((PenBoxMin-TraceMover.BasePos) >> ViewRotation).X);
				NeededPen = Abs(((PenBoxMax-PenBoxMin) >> ViewRotation).X);
			}
			
			if ((!traceMover.bBreakable) && (TPen < NeededPen))
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon).ProjectileClass != None) && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage) < traceMover.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			/*else if (((traceMover.doorStrength > 0.2) || (traceMover.minDamageThreshold > 8)) && (TPen < NeededPen))  // hack
			{
				bSafe = false;
				break;
			}*/
			else if (DeusExWeapon(Weapon).Default.HitDamage < traceMover.minDamageThreshold && (TPen < NeededPen))
			{
				bSafe = false;
				break;
			}
			else  // hack
				break;
		}
		if (Inventory(traceActor) != None)
		{
			bSafe = false;
			break;
		}
	}

	return (bSafe);
}

// ----------------------------------------------------------------------
// GetPawnWeaponRanges()
// ----------------------------------------------------------------------

function GetPawnWeaponRanges(Pawn other, out float minRange, out float maxAccurateRange, out float maxRange)
{
	local DeusExWeapon            pawnWeapon;
	local Class<DeusExProjectile> projectileClass;
	
	pawnWeapon = DeusExWeapon(other.Weapon);
	if (pawnWeapon != None)
	{
		pawnWeapon.GetWeaponRanges(minRange, maxAccurateRange, maxRange);
		
		if (IsThrownWeapon(pawnWeapon))  // hack
		{
			minRange = 0;
		}
		else if ((Other == Self) && (projectileClass != None) && (ShieldDamage(projectileClass.Default.DamageType) < 1))
		{
			minRange *= ShieldDamage(projectileClass.Default.DamageType); // Transcended - Sacrifice some health for more consistent firing
		}
	}
	else
	{
		minRange         = 0;
		maxAccurateRange = other.CollisionRadius;
		maxRange         = maxAccurateRange;
	}
	
	if (maxAccurateRange > maxRange)
		maxAccurateRange = maxRange;
	if (minRange > maxRange)
		minRange = maxRange;
	
	MinRange = GetDroneWeaponMinRange();
	MaxRange = GetDroneWeaponMaxRange()*2;
	MaxAccurateRange = GetDroneWeaponMaxRange()*1;
}

// ----------------------------------------------------------------------
// GetWeaponBestRange()
// ----------------------------------------------------------------------

function GetWeaponBestRange(DeusExWeapon dxWeapon, out float bestRangeMin, out float bestRangeMax)
{
	local float temp;
	local float minRange,   maxRange;
	local float AIMinRange, AIMaxRange;
	
	if (dxWeapon != None)
	{
		dxWeapon.GetWeaponRanges(minRange, maxRange, temp);
		if (IsThrownWeapon(dxWeapon))  // hack
			minRange = 0;
		AIMinRange = dxWeapon.AIMinRange;
		AIMaxRange = dxWeapon.AIMaxRange;

		if ((AIMinRange > 0) && (AIMinRange >= minRange) && (AIMinRange <= maxRange))
			bestRangeMin = AIMinRange;
		else
			bestRangeMin = minRange;
		if ((AIMaxRange > 0) && (AIMaxRange >= minRange) && (AIMaxRange <= maxRange))
			bestRangeMax = AIMaxRange;
		else
			bestRangeMax = maxRange;

		if (bestRangeMin > bestRangeMax)
			bestRangeMin = bestRangeMax;
	}
	else
	{
		bestRangeMin = 0;
		bestRangeMax = 0;
	}
	
	BestRangeMin = GetDroneWeaponMaxRange();
	BestRangeMax = GetDroneWeaponMinRange();
}

// ----------------------------------------------------------------------
// AICanShoot()
// ----------------------------------------------------------------------

function bool AICanShoot(pawn target, bool bLeadTarget, bool bCheckReadiness, optional float throwAccuracy, optional bool bDiscountMinRange)
{
	local DeusExWeapon dxWeapon;
	local Vector X, Y, Z;
	local Vector projStart, projEnd;
	local float  tempMinRange, tempMaxRange;
	local float  temp;
	local float  dist;
	local float  extraDist;
	local actor  hitActor;
	local Vector hitLocation, hitNormal;
	local Vector extent;
	local bool   bIsThrown;
	local float  elevation;
	local bool   bSafe;
	
	if (target == None)
		return false;
	if (target.bIgnore)
		return false;

	dxWeapon = DeusExWeapon(Weapon);
	if (dxWeapon == None)
		return false;
	if ((bCheckReadiness) && (!dxWeapon.bReadyToFire))
		return false;
	
	if ((DXWeapon.WeaponDamageType() == 'TearGas') && (VMDBufferPawn(Target) != None) && (ScriptedPawn(Target).bStunned || VMDBufferPawn(Target).bAerosolImmune))
	{
		FindBestEnemy(false);
		return false;
	}
	if ((DXWeapon.WeaponDamageType() == 'Poison') && (ScriptedPawn(Target) != None) && (ScriptedPawn(Target).PoisonCounter > 0))
	{
		FindBestEnemy(false);
		return false;
	}
	
	if (dxWeapon.ReloadCount > 0)
	{
		if (dxWeapon.AmmoType == None)
			return false;
		if (dxWeapon.AmmoType.AmmoAmount <= 0)
			return false;
	}
	if (FireElevation > 0)
	{
		elevation = FireElevation + (CollisionHeight+target.CollisionHeight);
		if (elevation < 10)
			elevation = 10;
		if (Abs(Location.Z-target.Location.Z) > elevation)
			return false;
	}
	bIsThrown = IsThrownWeapon(dxWeapon);

	extraDist = target.CollisionRadius;
	//extraDist = 0;

	GetPawnWeaponRanges(self, tempMinRange, tempMaxRange, temp);

	if (bDiscountMinRange)
		tempMinRange = 0;

	if (tempMinRange >= tempMaxRange)
		return false;

	ViewRotation = Rotation;
	GetAxes(ViewRotation, X, Y, Z);
	projStart = dxWeapon.ComputeProjectileStart(X, Y, Z);
	if (bLeadTarget && !dxWeapon.bInstantHit && (dxWeapon.ProjectileSpeed > 0))
	{
		if (bIsThrown)
		{
			// compute target's position 1.5 seconds in the future
			projEnd = target.Location + (target.Velocity*1.5);
		}
		else
		{
			// projEnd = target.Location + (target.Velocity*dist/dxWeapon.ProjectileSpeed);
			if (!ComputeTargetLead(target, projStart, dxWeapon.ProjectileSpeed,
			                       5.0, projEnd))
				return false;
		}
	}
	else
		projEnd = target.Location;

	if (bIsThrown)
		projEnd += vect(0,0,-1)*(target.CollisionHeight-5);

	dist = VSize(projEnd - Location);
	if (dist < 0)
		dist = 0;

	if ((dist < tempMinRange) || (dist-extraDist > tempMaxRange))
		return false;
	
	//MADDERS: Ported code for shooting through select movers. We'll be using this for wall banging.
    	if (!bIsThrown)
    	{
        	bSafe = FastTrace(target.Location, projStart);
        	if (!bSafe)
            		bSafe = AISafeToShoot(hitActor, target.Location, projStart);
        	if ((!bSafe) && (target.bIsPlayer))  // players only... hack
        	{
            		projEnd += vect(0,0,1)*target.BaseEyeHeight;
            		//bSafe = FastTrace(target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
            		bSafe = AISafeToShoot(hitActor, target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
        	}
        	if (!bSafe)
            		return false;
    	}
	/*if (!bIsThrown)
	{
		bSafe = FastTrace(target.Location, projStart);
		if ((!bSafe) && (target.bIsPlayer))  // players only... hack
		{
			projEnd += vect(0,0,1)*target.BaseEyeHeight;
			bSafe = FastTrace(target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
		}
		if (!bSafe)
			return false;
	}*/

	if (dxWeapon.bInstantHit)
		return (AISafeToShoot(hitActor, projEnd, projStart, , true));
	else
	{
		if (dxWeapon.ProjectileClass != None)
		{
			extent.X = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Y = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Z = dxWeapon.ProjectileClass.default.CollisionHeight;
		}
		if ((bIsThrown) && (throwAccuracy > 0))
		{
			return (AISafeToThrow(projEnd, projStart, throwAccuracy, extent));
		}
		else
		{
			return (AISafeToShoot(hitActor, projEnd, projStart, extent*3));
		}
	}
}

function AllianceInfoEx GetAllEx(int i)
{
	return AlliancesEx[i];
}

function AllianceInfoEx GetCachedAll(int i)
{
	return AlliancesEx[i];
}

function MatchAlliances(ScriptedPawn SP)
{
	local int i;
	local AllianceInfoEx TAll;
	
	if (SP == None) return;
	
	for(i=0; i<ArrayCount(AlliancesEx); i++)
	{
		if (VMDMEGH(SP) != None)
		{
			TAll = VMDMEGH(SP).GetAllEx(i);
			AlliancesEx[i] = TAll;
			TAll = VMDMEGH(SP).GetCachedAll(i);
			CachedAlliances[i] = TAll;
		}
		if (VMDSIDD(SP) != None)
		{
			TAll = VMDSIDD(SP).GetAllEx(i);
			AlliancesEx[i] = TAll;
			TAll = VMDSIDD(SP).GetCachedAll(i);
			CachedAlliances[i] = TAll;
		}
	}
}

defaultproperties
{
     SoundVolume=128
     SoundPitch=64
     SoundRadius=24
     MsgSIDDKilled="ERROR: Lost connection to %s!"
     
     bKeepWeaponDrawn=True
     SpinUpModifier=1.000000
     CustomName="S.I.D.D."
     
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot3TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot3TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot3OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot3CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot3Scanning'
     
     Orders=Standing
     HitboxArchetype="Roller"
     bKeepWeaponDrawn=False //Used to be true, but now recon mode handles this.
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot3TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot3TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot3OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot3CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot3Scanning'
     
     explosionSound=Sound'DeusExSounds.Robot.SecurityBot2Explode'
     bEmitDistress=False
     bAimForHead=True
     InitialInventory(0)=(Inventory=class'WeaponSIDDPistol')
     InitialInventory(1)=(Inventory=class'Ammo762mm', Count=0)
     Alliance=Player
     InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1.000000,bPermanent=True)
     InitialAlliances(1)=(AllianceName=PaulDenton,AllianceLevel=1.000000,bPermanent=True)
     WalkSound=None
     GroundSpeed=0.000000
     WaterSpeed=0.000000
     AirSpeed=0.000000
     AccelRate=0.000000
     Health=15
     EMPHitPoints=50
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'VMDSIDDTurret'
     CollisionRadius=12.000000
     CollisionHeight=11.500000
     Mass=50.000000
     Buoyancy=25.000000
     BindName="VMDSIDD"
     FamiliarName="S.I.D.D."
     UnfamiliarName="S.I.D.D."
     BaseEyeHeight=5.750000
}
