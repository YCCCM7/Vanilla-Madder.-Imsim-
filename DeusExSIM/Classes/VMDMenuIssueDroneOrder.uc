//=============================================================================
// VMDMenuIssueDroneOrder. Lightweight and to the point, I'd hope.
//=============================================================================
class VMDMenuIssueDroneOrder expands MenuUIWindow;

var int NumButtons, StartX, StartY, ButtonWidth, ButtonHeightOffset;
var string ButtonCommands[8], OrderTargetName;

var VMDBufferPlayer OrderPlayer;
var MenuUIMenuButtonWindow CommandsList[8], ObjectNameDisplay;

var localized string StrAddPatrol, StrCancel, StrDestroy, StrDisengageRecon, StrEngageRecon, StrGuard, StrHeal, StrIgnore, StrMarkAlly, StrMarkEnemy, StrLiteHack, StrMoveTo, StrOppress, StrRegroup, StrStartPatrol;

struct Empty {};

struct GraftedComputerSecurityRef extends Empty
{
    var Actor Value; 
};

struct GraftedHCComputerSecurityRef extends Empty
{
    var Actor Value; 
};

function bool GetReconStatus()
{
	local VMDMegh TMegh;
	local VMDSidd TSidd;
	
	if (OrderPlayer == None) return false;
	
	TMegh = OrderPlayer.FindProperMegh();
	if ((TMegh != None) && (TMegh.IsInState('Dying') || TMegh.EMPHitPoints < 1)) TMegh = None;
	
	if (TMegh != None)
	{
		if (TMegh.bReconMode)
		{
			return true;
		}
	}
	
	forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
	{
		if (TSidd.bReconMode)
		{
			return true;
		}
	}
	return false;
}

function bool MEGHCanBreak(DeusExDecoration DXD)
{
	local VMDMegh TMegh;
	
	if (DXD == None) return false;
	
	TMegh = OrderPlayer.FindProperMegh();
	if ((TMegh != None) && (TMegh.IsInState('Dying') || TMegh.EMPHitPoints < 1)) TMegh = None;
	
	if ((TMegh != None) && (DeusExWeapon(TMegh.Weapon) != None) && (DeusExWeapon(TMegh.Weapon).HitDamage >= DXD.MinDamageThreshold))
	{
		return true;
	}
	
	return false;
}

function bool SIDDCanShoot(Actor TarActor)
{
	local VMDSidd TSidd;
	
	if (TarActor == None) return false;
	
	forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
	{
		if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			if ((TSidd.FastTrace(TSidd.Location, TarActor.Location)) && (DeusExDecoration(TarActor) == None || DeusExDecoration(TarActor).MinDamageThreshold <= 4))
			{
				return true;
			}
		}
	}
	
	return false;
}

function AddNewOrder(string NewOrderType)
{
	local Vector OrderLocation;
	local Actor OrderActor;
	local VMDFakePatrolPoint FakePat, LastPat;
	local VMDMegh TMegh;
	local VMDSidd RefSidd, TSidd; //Barf. Need to confirm one, but poll many.
	local bool bReconStatus;
	
	OrderActor = OrderPlayer.LastDroneOrderActor;
	if (OrderActor == None) return;
	
	OrderLocation = OrderPlayer.LastDroneOrderLocation;
	
	TMegh = OrderPlayer.FindProperMegh();
	if ((TMegh != None) && (TMegh.IsInState('Dying') || TMegh.EMPHitPoints < 1)) TMegh = None;
	
	forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
	{
		if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			RefSidd = TSidd;
			break;
		}
	}
	
	ForEach OrderPlayer.RadiusActors(class'VMDFakePatrolPoint', FakePat, 32, OrderLocation) break;
	LastPat = GetLastPatrol();
	bReconStatus = GetReconStatus();
	
	switch(CAPS(NewOrderType))
	{
		case "ADD PATROL %S": //Compile patrol points
			if ((TMegh != None) && (FakePat == None) && (GetLastPatrolIndex() < 8) && (LastPat == None || OrderPlayer.FastTrace(LastPat.Location, OrderLocation)))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@SprintF(StrAddPatrol, GetAlphabet(GetLastPatrolIndex())));
				
				NumButtons++;
			}
		break;
		case "CANCEL": //Exit from menu
			ButtonCommands[NumButtons] = NewOrderType;
			CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
			CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
			CommandsList[NumButtons].SetWidth(ButtonWidth);
			CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrCancel);
			
			NumButtons++;
		break;
		case "DESTROY": //Break a deco
			if ((TMegh != None && MEGHCanBreak(DeusExDecoration(OrderActor))) || SIDDCanShoot(OrderActor))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrDestroy);
				
				NumButtons++;
			}
		break;
		case "GUARD": //Follow a unit and take any damage directed towards it as a declaration of war
			if ((TMegh != None) && (VMDBufferPawn(OrderActor) != None))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrGuard);
				
				NumButtons++;
			}
		break;
		case "HEAL": //Heal with medigel. Both medigel and talent required.
			if ((TMegh != None) && (TMegh.bCanHeal) && (TMegh.bHasHeal) && (VMDBufferPawn(OrderActor) != None) && (VMDBufferPawn(OrderActor).Health < VMDBufferPawn(OrderActor).StartingHealthValues[6]))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrHeal);
				
				NumButtons++;
			}
		break;
		case "IGNORE": //Stop attacking this faction
			ButtonCommands[NumButtons] = NewOrderType;
			CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
			CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
			CommandsList[NumButtons].SetWidth(ButtonWidth);
			CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrIgnore);
			
			NumButtons++;
		break;
		case "LITE HACK": //Hack into a PC and disrupt it. Talent required.
			if ((TMegh != None) && (TMegh.bCanHack) && (IsLiteHackable(OrderActor)))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrLiteHack);
				
				NumButtons++;
			}
		break;
		case "MARK ALLY": //Forgive transgressions, make them forgive the drone, in turn. Cease attacks.
			ButtonCommands[NumButtons] = NewOrderType;
			CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
			CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
			CommandsList[NumButtons].SetWidth(ButtonWidth);
			CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrMarkAlly);
			
			NumButtons++;
		break;
		case "MARK ENEMY": //Mark faction as bad guys, and start an attack
			ButtonCommands[NumButtons] = NewOrderType;
			CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
			CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
			CommandsList[NumButtons].SetWidth(ButtonWidth);
			CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrMarkEnemy);
			
			NumButtons++;
		break;
		case "MOVE TO": //Go here, or where this thing is.
			if (TMegh != None)
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrMoveTo);
				
				NumButtons++;
			}
		break;
		case "OPPRESS": //Beat dudes with baton
			if ((TMegh != None) && (!TMegh.bReconMode) && (VMDBufferPawn(OrderActor) != None) && (VMDBufferPawn(OrderActor).bMilitantCower))
			{
				if (WeaponPepperGun(TMegh.FirstWeapon()) != None || WeaponGasGrenade(TMegh.FirstWeapon()) != None || WeaponBaton(TMegh.FirstWeapon()) != None)
				{
					ButtonCommands[NumButtons] = NewOrderType;
					CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
					CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
					CommandsList[NumButtons].SetWidth(ButtonWidth);
					CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrOppress);
					
					NumButtons++;
				}
			}
		break;
		case "REGROUP": //Return to following if guarding, oppressing, or patrolling.
			if (TMegh != None)
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));			
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrRegroup);
				
				NumButtons++;
			}
		break;
		case "START PATROL": //Begin patrolling, duh
			if ((TMegh != None) && (GetLastPatrolIndex() > 1))
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));			
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrStartPatrol);
				
				NumButtons++;
			}
		break;
		case "TOGGLE RECON": //Switch whether we are observe-only.
			if (TMegh != None || RefSidd != None)
			{
				ButtonCommands[NumButtons] = NewOrderType;
				CommandsList[NumButtons] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));			
				CommandsList[NumButtons].SetPos(StartX, StartY + (ButtonHeightOffset * (NumButtons-1)));
				CommandsList[NumButtons].SetWidth(ButtonWidth);
				if (!bReconStatus)
				{
					CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrEngageRecon);
				}
				else
				{
					CommandsList[NumButtons].SetButtonText((NumButtons+1)$"."@StrDisengageRecon);
				}
				
				NumButtons++;
			}
		break;
	}
}

function bool IsLiteHackable(Actor OrderActor)
{
	local int CameraIndex, Count;
	local name TTag;
	local AutoTurret Turret;
	local ComputerSecurity CS;
	local GraftedComputerSecurity GCS;
	local GraftedHCComputerSecurity GHCCS;
	local SecurityCamera Camera;
	
	CS = ComputerSecurity(OrderActor);
	if (CS != None)
	{
		for (cameraIndex=0; cameraIndex<ArrayCount(CS.Views); cameraIndex++)
		{
			TTag = CS.Views[cameraIndex].cameraTag;
			if (TTag != '')
			{
				foreach OrderPlayer.AllActors(class'SecurityCamera', camera, TTag)
				{
					Count++;
				}
			}
			
			TTag = CS.Views[cameraIndex].turretTag;
			if (TTag != '')
			{
				foreach OrderPlayer.AllActors(class'AutoTurret', turret, TTag)
				{
					Count++;
				}
			}
		}
		
		return (Count > 0);
	}
	else if (OrderActor.IsA('RS_ComputerSecurity') || OrderActor.IsA('MyComputerSecurity'))
	{
		GCS = AizomeFudgeCast(OrderActor);
		if (GCS != None)
		{
			for (cameraIndex=0; cameraIndex<ArrayCount(GCS.Views); cameraIndex++)
			{
				TTag = GCS.Views[cameraIndex].cameraTag;
				if (TTag != '')
				{
					foreach OrderPlayer.AllActors(class'SecurityCamera', camera, TTag)
					{
						Count++;
					}
				}
				
				TTag = GCS.Views[cameraIndex].turretTag;
				if (TTag != '')
				{
					foreach OrderPlayer.AllActors(class'AutoTurret', turret, TTag)
					{
						Count++;
					}
				}
			}
			
			return (Count > 0);
		}
	}
	else if (OrderActor.IsA('HCComputerSecurity'))
	{
		GHCCS = AizomeHCFudgeCast(OrderActor);
		if (GHCCS != None)
		{
			for (cameraIndex=0; cameraIndex<ArrayCount(GHCCS.Views); cameraIndex++)
			{
				TTag = GHCCS.Views[cameraIndex].cameraTag;
				if (TTag != '')
				{
					foreach OrderPlayer.AllActors(class'SecurityCamera', camera, TTag)
					{
						Count++;
					}
				}
				
				TTag = GHCCS.Views[cameraIndex].turretTag;
				if (TTag != '')
				{
					foreach OrderPlayer.AllActors(class'AutoTurret', turret, TTag)
					{
						Count++;
					}
				}
			}
			
			return (Count > 0);
		}
	}
	
	if ((OrderActor != None) && (OrderActor.IsA('HCComputerSecurity')))
	{
		return false;
	}
	return false;
}

final function GraftedComputerSecurity AizomeFudgeCast(Actor OrderActor)
{
	local GraftedComputerSecurityRef GraftedComputerSecurityRef;
	local Empty Empty;
	local GraftedComputerSecurity Result;
	
	GraftedComputerSecurityRef.Value = OrderActor;
	Empty = GraftedComputerSecurityRef;
	
	return Result;
}

final function GraftedHCComputerSecurity AizomeHCFudgeCast(Actor OrderActor)
{
	local GraftedHCComputerSecurityRef GraftedHCComputerSecurityRef;
	local Empty Empty;
	local GraftedHCComputerSecurity Result;
	
	GraftedHCComputerSecurityRef.Value = OrderActor;
	Empty = GraftedHCComputerSecurityRef;
	
	return Result;
}

function VMDFakePatrolPoint GetLastPatrol()
{
	local VMDFakePatrolPoint FakePat, BestPat;
	local int BestArray;
	
	forEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', FakePat)
	{
		if ((FakePat != None) && (FakePat.MyArray+1 > BestArray))
		{
			BestPat = FakePat;
			BestArray = FakePat.MyArray+1;
		}
	}
	
	return BestPat;
}

function int GetLastPatrolIndex()
{
	local VMDFakePatrolPoint FakePat;
	local int Best;
	
	forEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', FakePat)
	{
		if ((FakePat != None) && (FakePat.MyArray+1 > Best))
		{
			Best = FakePat.MyArray+1;
		}
	}
	
	return Best;
}

function string GetAlphabet(int InIndex)
{
	switch(InIndex)
	{
		case 0: return "A"; break;
		case 1: return "B"; break;
		case 2: return "C"; break;
		case 3: return "D"; break;
		case 4: return "E"; break;
		case 5: return "F"; break;
		case 6: return "G"; break;
		case 7: return "H"; break;
		case 8: return "I"; break;
		case 9: return "J"; break;
		case 10: return "K"; break;
		case 11: return "L"; break;
		case 12: return "M"; break;
		case 13: return "N"; break;
		case 14: return "O"; break;
		case 15: return "P"; break;
		case 16: return "Q"; break;
		case 17: return "R"; break;
		case 18: return "S"; break;
		case 19: return "T"; break;
		case 20: return "U"; break;
		case 21: return "V"; break;
		case 22: return "W"; break;
		case 23: return "X"; break;
		case 24: return "Y"; break;
		case 25: return "Z"; break;
	}
	
	return "ERR";
}

function AddObjectName()
{
	local string OrderName;
	
	OrderName = OrderPlayer.LastDroneOrderTargetName;
	
	if (OrderName != "")
	{
		ObjectNameDisplay = MenuUIMenuButtonWindow(winClient.NewChild(Class'VMDMenuButtonDroneOrderName'));
		ObjectNameDisplay.SetPos(StartX+8, StartY-(ButtonHeightOffset*2)-2);
		ObjectNameDisplay.SetWidth(ButtonWidth-16);
		ObjectNameDisplay.SetButtonText(OrderName);
		ObjectNameDisplay.SetSensitivity(False);
	}
}

function ExecuteDroneOrder(string TarOrderType)
{
	local bool bWon, bUsedFake, bReconStatus;
	local Vector OrderLocation;
	
	local Actor OrderActor;
	local ScriptedPawn SP;
	local VMDFakePathNode FakePN;
	local VMDFakePatrolPoint LastPat, FakePat;
	local VMDFakeDestroyOtherPawn LastDest;
	local VMDMegh TMegh;
	local VMDSidd TSidd, UseSidd;
	
	OrderActor = OrderPlayer.LastDroneOrderActor;
	if (OrderActor == None) return;
	OrderLocation = OrderPlayer.LastDroneOrderLocation;
	
	TMegh = OrderPlayer.FindProperMegh();
	forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
	{
		if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			UseSidd = TSidd;
			break;
		}
	}
	bReconStatus = GetReconStatus();
	
	switch(CAPS(TarOrderType))
	{
		case "ADD PATROL %S": //Compile patrol points
			if ((TMegh != None) && (GetLastPatrolIndex() < 8) && (!TMegh.IsInState('MeghPatrolling')))
			{
				FakePat = OrderPlayer.Spawn(class'VMDFakePatrolPoint',,, OrderLocation);
				if (FakePat != None)
				{
					FakePat.OrderPlayer = OrderPlayer;
					ForEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', LastPat)
					{
						if ((LastPat != None) && (LastPat != FakePat))
						{
							LastPat.AddNewFamilyMember(FakePat);
						}
					}
					
					ForEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', LastPat)
					{
						if (LastPat != None)
						{
							LastPat.FlashTimeMin = float(LastPat.MyArray) / float(LastPat.FamilySize);
							LastPat.FlashTimeMax = float(LastPat.MyArray+1) / float(LastPat.FamilySize);
						}
					}
					
					//Sound preference?
					//bWon = true;
				}
				bUsedFake = false;
			}
		break;
		case "CANCEL": //Exit from menu
			//Do nothing lmao.
		break;
		case "DESTROY":
			if ((TMegh != None) && (DeusExDecoration(OrderActor) != None))
			{
				if (LastDest == None)
				{
					LastDest = OrderPlayer.Spawn(class'VMDFakeDestroyOtherPawn', OrderActor,, OrderActor.Location);
				}
				
				if (LastDest != None)
				{
					if (TMegh != None)
					{
						TMegh.MEGHIssueOrder('DestroyingOther', LastDest, OrderActor);
						bWon = true;
					}
				}
			}
			if ((UseSIDD != None) && (DeusExDecoration(OrderActor) != None))
			{
				if (LastDest == None)
				{
					LastDest = OrderPlayer.Spawn(class'VMDFakeDestroyOtherPawn', OrderActor,, OrderActor.Location);
				}
				
				if (LastDest != None)
				{
					forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
					{
						if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
						{
							TSidd.SIDDIssueOrder('DestroyingOther', LastDest, OrderActor);
							bWon = true;
						}
					}
				}
			}
		break;
		case "GUARD": //Follow a unit and take any damage directed towards it as a declaration of war
			if ((TMegh != None) && (VMDBufferPawn(OrderActor) != None))
			{
				TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
				
				if ((TMegh.IsInState('Attacking')) && (TMegh.Enemy != None) && (TMegh.Enemy.Alliance == ScriptedPawn(OrderActor).Alliance))
				{
					TMegh.Enemy = None;
				}
				
				//Our defining feature is the ability to make peace with this entity in a mutual sense.
				forEach OrderPlayer.AllActors(class'ScriptedPawn', SP)
				{
					if ((SP != None) && (SP.Alliance == ScriptedPawn(OrderActor).Alliance))
					{
						SP.ChangeAlly(TMegh.Alliance, 1, true);
						if (SP.Enemy == TMegh)
						{
							SP.SetEnemy(None);
						}
					}
				}
				
				TMegh.MEGHIssueOrder('GuardingOther', OrderActor);
				
				bWon = true;
			}
		break;
		case "HEAL": //Heal with medigel. Both medigel and talent required.
			if (TMegh != None)
			{
				TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
				
				if ((TMegh.IsInState('Attacking')) && (TMegh.Enemy != None) && (TMegh.Enemy.Alliance == ScriptedPawn(OrderActor).Alliance))
				{
					TMegh.Enemy = None;
				}
				
				//Our defining feature is the ability to make peace with this entity in a mutual sense.
				forEach OrderPlayer.AllActors(class'ScriptedPawn', SP)
				{
					if ((SP != None) && (SP.Alliance == ScriptedPawn(OrderActor).Alliance))
					{
						SP.ChangeAlly(TMegh.Alliance, 1, true);
						if (SP.Enemy == TMegh)
						{
							SP.SetEnemy(None);
						}
					}
				}
				
				TMegh.MEGHIssueOrder('HealingOther', OrderActor);
				
				bWon = true;
			}
		break;
		case "IGNORE": //Stop attacking this faction
			if (TMegh != None)
			{
				TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
				
				if ((TMegh.IsInState('Attacking')) && (TMegh.Enemy != None) && (TMegh.Enemy.Alliance == ScriptedPawn(OrderActor).Alliance))
				{
					TMegh.MEGHIssueOrder('MeghFollowing', OrderPlayer,, true);
					
					TMegh.Enemy = None;
				}
				bWon = true;
			}
			if (UseSidd != None)
			{
				forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
				{
					if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
					{
						TSidd.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
						
						if ((TSidd.IsInState('Attacking')) && (TSidd.Enemy != None) && (TSidd.Enemy.Alliance == ScriptedPawn(OrderActor).Alliance))
						{
							TSidd.Enemy = None;
						}
						bWon = true;
					}
				}
			}
		break;
		case "LITE HACK": //Hack into a PC and disrupt it. Talent required.
			if (TMegh != None)
			{
				TMegh.MEGHIssueOrder('LiteHacking', OrderActor);
				
				bWon = true;
			}
		break;
		case "MARK ALLY": //Forgive transgressions, make them forgive the drone, in turn. Cease attacks.
			if (TMegh != None)
			{
				TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
				
				if ((TMegh.IsInState('Attacking')) && (TMegh.Enemy != None) && (TMegh.Enemy.Alliance == ScriptedPawn(OrderActor).Alliance))
				{
					TMegh.MEGHIssueOrder('MeghFollowing', OrderPlayer,, true);
				}
				
				//Our defining feature is the ability to make peace with this entity in a mutual sense.
				forEach OrderPlayer.AllActors(class'ScriptedPawn', SP)
				{
					if ((SP != None) && (SP.Alliance == ScriptedPawn(OrderActor).Alliance))
					{
						SP.ChangeAlly(TMegh.Alliance, 1, true);
						if (SP.Enemy == TMegh)
						{
							SP.SetEnemy(None);
						}
					}
				}
				bWon = true;
			}
			if (UseSidd != None)
			{
				forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
				{
					if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
					{
						TSidd.ChangeAlly(ScriptedPawn(OrderActor).Alliance, 1, true);
						
						//Our defining feature is the ability to make peace with this entity in a mutual sense.
						forEach OrderPlayer.AllActors(class'ScriptedPawn', SP)
						{
							if ((SP != None) && (SP.Alliance == ScriptedPawn(OrderActor).Alliance))
							{
								SP.ChangeAlly(TSidd.Alliance, 1, true);
								if (SP.Enemy == TSidd)
								{
									SP.SetEnemy(None);
								}
							}
						}
						bWon = true;
					}
				}
			}
		break;
		case "MARK ENEMY": //Mark faction as bad guys, and start an attack
			if (TMegh != None)
			{
				TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, -1, true);
				TMegh.IncreaseAgitation(ScriptedPawn(OrderActor), 1.0);
				
				if ((!TMegh.IsInState('MeghPatrolling')) && (!TMegh.bReconMode))
				{
					TMegh.MEGHIssueOrder('Attacking', OrderActor);
				}
				
				bWon = true;
			}
			if (UseSidd != None)
			{
				forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
				{
					if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
					{
						TSidd.ChangeAlly(ScriptedPawn(OrderActor).Alliance, -1, true);
						TSidd.IncreaseAgitation(ScriptedPawn(OrderActor), 1.0);
						
						if ((!TSidd.IsInState('MeghPatrolling')) && (!TSidd.bReconMode))
						{
							TSidd.SIDDIssueOrder('Attacking', OrderActor);
						}
						
						bWon = true;
					}
				}
			}
		break;
		case "MOVE TO": //Go here, or where this thing is.
			if (TMegh != None)
			{
				TMegh.MEGHIssueOrder('RunningTo', OrderActor);
				
				bUsedFake = true;
				bWon = true;
			}
		break;
		case "OPPRESS": //Beat dudes with baton
			if ((TMegh != None) && (TMegh.FirstWeapon() != None) && (VMDBufferPawn(OrderActor) != None))
			{
				switch(TMegh.FirstWeapon().Class.Name)
				{
					case 'WeaponBaton':
					case 'WeaponPeppergun':
					case 'WeaponGasGrenade':
						TMegh.ChangeAlly(ScriptedPawn(OrderActor).Alliance, -1, true);
						TMegh.IncreaseAgitation(ScriptedPawn(OrderActor), 1.0);
						
						TMegh.MEGHIssueOrder('Oppressing', OrderActor);
						
						bWon = true;
					break;
				}
			}
		break;
		case "REGROUP": //Return to following if guarding, oppressing, or patrolling.
			if (TMegh != None)
			{
				if (TMegh.GetStateName() != 'MeghFollowing')
				{
					TMegh.MEGHIssueOrder('MeghFollowing', OrderPlayer);
					
					forEach OrderPlayer.AllActors(class'VMDFakePathNode', FakePN)
					{
						if (FakePN != None)
						{
							FakePN.Destroy();
						}
					}
					forEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', FakePat)
					{
						if (FakePat != None)
						{
							FakePat.Destroy();
						}
					}
					
					bUsedFake = true;
					bWon = true;
				}
			}
		break;
		case "START PATROL": //Begin patrolling, duh
			if (TMegh != None)
			{
				FakePat = GetClosestPatrolPoint(TMegh);
				if (FakePat != None)
				{
					TMegh.MEGHIssueOrder('MeghPatrolling', FakePat);
					bWon = true;
				}
			}
		break;
		case "TOGGLE RECON": //Switch whether we are observe-only.
			if ((TMegh != None) && (TMegh.bReconMode == bReconStatus))
			{
				TMegh.ToggleReconMode();
			}
			if (UseSidd != None)
			{
				forEach OrderPlayer.AllActors(class'VMDSidd', TSidd)
				{
					if ((TSidd != None) && (!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0) && (TSidd.bReconMode == bReconStatus))
					{
						TSidd.ToggleReconMode();
					}
				}
			}
		break;
	}
	
	if (bWon)
	{
		if (CAPS(TarOrderType) != "DESTROY")
		{
			forEach OrderPlayer.AllActors(class'VMDFakeDestroyOtherPawn', LastDest)
			{
				LastDest.Destroy();
			}
		}
		OrderPlayer.PlaySound(Sound'Menu_IncomingFriend', SLOT_None);
	}
	else
	{
		OrderPlayer.PlaySound(Sound'Menu_Cancel', SLOT_None);
	}
	
	if ((!bUsedFake) && (VMDFakePathNode(OrderActor) != None))
	{
		OrderActor.Destroy();
	}
	
	AddTimer(0.1, false,, 'ForcePopWindow');
}

function VMDFakePatrolPoint GetClosestPatrolPoint(VMDMegh TMegh)
{
	local float BestDist, TDist;
	local VMDFakePatrolPoint BestPat, FakePat;
	
	if (TMegh == None) return None;
	BestDist = 9999;
	
	ForEach OrderPlayer.AllActors(class'VMDFakePatrolPoint', FakePat)
	{
		if ((FakePat != None) && (OrderPlayer.FastTrace(FakePat.Location, TMegh.Location)))
		{
			TDist = VSize(FakePat.Location - TMegh.Location);
			if (TDist < BestDist)
			{
				BestDist = TDist;
				BestPat = FakePat;
			}
		}
	}
	
	return BestPat;
}

function ForcePopWindow()
{
	Root.PopWindow();
}

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
 	return false;
}

function bool CanStack()
{
 	return false;
}

event StyleChanged()
{
}

function CreateClientWindow()
{
	local int clientIndex;
	local int titleOffsetX, titleOffsetY;
	
	winClient = VMDMenuUIClientWindow(NewChild(class'VMDMenuUIClientWindow'));
	VMDMenuUIClientWindow(WinClient).bBlockReskin = true;
	VMDMenuUIClientWindow(WinClient).bBlockTranslucency = true;
	WinClient.StyleChanged();
	
	winTitle.GetOffsetWidths(titleOffsetX, titleOffsetY);
	
	winClient.SetSize(clientWidth, clientHeight);
	winClient.SetTextureLayout(textureCols, textureRows);
	
	// Set background textures
	for(clientIndex=0; clientIndex<arrayCount(clientTextures); clientIndex++)
	{
		winClient.SetClientTexture(clientIndex, clientTextures[clientIndex]);
	}
}

function InitWindow()
{
 	local int i;
	
	Super.InitWindow();
        SetTitle("Select Action Type");	
	
	if (WinTitle != None)
	{
	 	WinTitle.Show(False);
	 	WinTitle = None;
	}
	AddTimer(0.04, false,, 'AddObjectName');
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local int i;
	
	bHandled = True;
	
	Super.ButtonActivated(buttonPressed);
	
	switch(ButtonPressed)
	{
		default:
			bHandled = False;
		break;
	}
	
	for (i=0; i<ArrayCount(ButtonCommands); i++)
	{
		if (ButtonPressed == CommandsList[i])
		{
			ExecuteDroneOrder(ButtonCommands[i]);
			break;
		}
	}
	
	return bHandled;
}

event bool VirtualKeyPressed(EInputKey Key, bool bRepeat)
{
	switch(Key)
	{
		case IK_1:
			if (CommandsList[0] != None)
			{
				ButtonActivated(CommandsList[0]);
			}
		break;
		case IK_2:
			if (CommandsList[1] != None)
			{
				ButtonActivated(CommandsList[1]);
			}
		break;
		case IK_3:
			if (CommandsList[2] != None)
			{
				ButtonActivated(CommandsList[2]);
			}
		break;
		case IK_4:
			if (CommandsList[3] != None)
			{
				ButtonActivated(CommandsList[3]);
			}
		break;
		case IK_5:
			if (CommandsList[4] != None)
			{
				ButtonActivated(CommandsList[4]);
			}
		break;
		case IK_6:
			if (CommandsList[5] != None)
			{
				ButtonActivated(CommandsList[5]);
			}
		break;
		case IK_7:
			if (CommandsList[6] != None)
			{
				ButtonActivated(CommandsList[6]);
			}
		break;
		case IK_8:
			if (CommandsList[7] != None)
			{
				ButtonActivated(CommandsList[7]);
			}
		break;
		case IK_Escape:
			return Super(PersonaScreenBaseWindow).VirtualKeyPressed(key, bRepeat);
		break;
	}
	
 	return True;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
 	return false;
}

defaultproperties
{
     StrAddPatrol="Add Patrol %s"
     StrCancel="Cancel"
     StrDestroy="Destroy"
     StrDisengageRecon="Combat Mode"
     StrEngageRecon="Spotter Mode"
     StrGuard="Guard"
     StrHeal="Heal"
     StrIgnore="Ignore"
     StrLiteHack="Lite Hack"
     StrMarkAlly="Mark Ally"
     StrMarkEnemy="Mark Enemy"
     StrMoveTo="Move To"
     StrOppress="Oppress"
     StrRegroup="Regroup"
     StrStartPatrol="Start Patrol"
     StartX=256
     StartY=445
     ButtonWidth=256
     ButtonHeightOffset=27
     
     Title="ERR"
     ClientWidth=512
     ClientHeight=768
     
     clientTextures(0)=None
     clientTextures(1)=None
     clientTextures(2)=None
     clientTextures(3)=None
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=3
     TextureCols=2
}
