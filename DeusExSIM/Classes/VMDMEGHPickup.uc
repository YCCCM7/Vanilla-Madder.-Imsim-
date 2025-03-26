//=============================================================================
// VMDMEGHPickup.
//=============================================================================
class VMDMEGHPickup extends DeusExPickup;

var localized string MsgCantDeployUnderwater, MsgNoRoomToDeploy, DroneHPLabel, DroneEMPHPLabel, DroneNameLabel;
var travel int DroneHealth, DroneEMPHealth;
var travel bool bDroneHealthBuff, bDroneHealing, bDroneReconMode, bDroneAutoReload;
var travel string CustomName;

function string VMDGetItemName()
{
	if (CustomName == "")
	{
		return ItemName;
	}
	return CustomName;
}

function VMDCraftingCalledBullshit()
{
	DroneHealth = VMDGetMaxHealth();
	DroneEMPHealth = VMDGetMaxEMPHealth();
}

function int VMDGetMaxHealth()
{
	local bool bVMDMayhemEnabled;
	local int Ret;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		bDroneHealthBuff = VMP.HasSkillAugment('ElectronicsDroneArmor');
		bVMDMayhemEnabled = VMP.bMayhemSystemEnabled;
	}
	
	if (VMDGetMissionNumber() < 5)
	{
		if (!bDroneHealthBuff)
		{
			Ret = 25;
		}
		else
		{
			Ret = 75;
		}
	}
	else
	{
		if (!bDroneHealthBuff)
		{
			Ret = 50;
		}
		else
		{
			Ret = 150;
		}
	}
	
	if (bVMDMayhemEnabled)
	{
		Ret *= 2;
	}
	
	return Ret;
}

function int VMDGetMaxEMPHealth()
{
	local bool bVMDMayhemEnabled;
	local int Ret;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		bDroneHealthBuff = VMP.HasSkillAugment('ElectronicsDroneArmor');
		bVMDMayhemEnabled = VMP.bMayhemSystemEnabled;
	}
	
	Ret = 100;
	if (bDroneHealthBuff)
	{
		Ret += 200;
	}
	
	if (bVMDMayhemEnabled)
	{
		Ret *= 2;
	}
	
	return Ret;
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

function bool DeployHelidrone(VMDBufferPlayer VMP)
{
	local VMDMEGH TMegh;
	local Vector SpawnLoc;
	
	if (VMP == None) return false;
	
	SpawnLoc = VMP.Location + ((vect(1.75,0,0)*VMP.CollisionRadius) >> VMP.Rotation);
	
	TMegh = Spawn(class'VMDMegh',,, SpawnLoc, VMP.Rotation);
	if (TMegh != None)
	{
		VMP.PlaySound(Sound'MedicalBotRaiseArm', SLOT_None,,, 512, 2.0);
		
		TMegh.CustomName = CustomName;
		TMegh.Health = DroneHealth;
		TMegh.EMPHitPoints = DroneEMPHealth;
		TMegh.bHealthBuffed = bDroneHealthBuff;
		TMegh.bCanHeal = bDroneHealing;
		TMegh.bReconMode = bDroneReconMode;
		TMegh.bAutoReload = bDroneAutoReload;
		TMegh.SetupWeapon(!TMegh.bReconMode, true);
		
		TMegh.UpdateTalentEffects(VMP);
		return true;
	}
	return false;
}

function UpdateDroneSkins()
{
	if (VMDBufferPlayer(Owner) != None)
	{
		bDroneHealing = (VMDBufferPlayer(Owner).HasSkillAugment('TagTeamMedicalSyringe'));
	}
	
	if (!bDroneHealthBuff)
	{
		Multiskins[0] = Texture'VMDMeghTex01';
		Multiskins[1] = Texture'VMDMeghTex02';
		if (bDroneHealing)
		{
			Multiskins[2] = Texture'VMDMeghTex03NoHealing';
		}
		else
		{
			Multiskins[2] = Texture'VMDMeghTex03';
		}
		Multiskins[3] = Texture'VMDMeghTex04';
		Multiskins[4] = Texture'VMDMeghTex05';
	}
	else
	{
		Multiskins[0] = Texture'VMDMeghTex01Heavy';
		Multiskins[1] = Texture'VMDMeghTex02Heavy';
		if (bDroneHealing)
		{
			Multiskins[2] = Texture'VMDMeghTex03NoHealingHeavy';
		}
		else
		{
			Multiskins[2] = Texture'VMDMeghTex03Heavy';
		}
		Multiskins[3] = Texture'VMDMeghTex04Heavy';
		Multiskins[4] = Texture'VMDMeghTex05Heavy';
	}
}

function VMDUpdatePropertiesHook()
{
	Super.VMDUpdatePropertiesHook();
	
	UpdateDroneSkins();
}

// ----------------------------------------------------------------------
state Activated
{
	function Activate()
	{
		// can't turn it off
	}
	
	function BeginState()
	{
		local VMDBufferPlayer VMP;
		local bool bWin;
				
		Super.BeginState();
		
		VMP = VMDBufferPlayer(Owner);
		if (VMP != None)
		{
			bWin = DeployHelidrone(VMP);
		}
		
		if (bWin)
		{
			UseOnce();
		}
		else
		{
			VMDDontUseOnce();
		}
	}
Begin:
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDHasActivationObjection()
{
	local VMDBufferPlayer VMP;
	local Vector SpawnLoc;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP != None)
	{
		if ((VMP.Region.Zone != None) && (VMP.Region.Zone.bWaterZone))
		{
			VMP.ClientMessage(MsgCantDeployUnderwater);
			return true;
		}
		SpawnLoc = VMP.Location + ((vect(1.75,0,0)*VMP.CollisionRadius) + (vect(1,0,0) * class'VMDMEGH'.Default.CollisionRadius) >> VMP.Rotation);
		if (!FastTrace(VMP.Location, SpawnLoc))
		{
			VMP.ClientMessage(SprintF(MsgNoRoomToDeploy, CustomName));
			return true;
		}
	}
	return false;
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local DeusExPlayer player;
	local String outText;
	local int i;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	player = DeusExPlayer(Owner);
	
	if (player != None)
	{
		winInfo.SetTitle(itemName);
		winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
		
		outText = OutText$SprintF(DroneNameLabel, CustomName)$WinInfo.CR();
		outText = OutText$DroneHealth@DroneHPLabel$winInfo.CR();
		outText = OutText$DroneEMPHealth@DroneEMPHPLabel;
		
		winInfo.AppendText(outText);
	}

	return True;
}

defaultproperties
{
     bVolatile=True
     DroneHealth=25
     DroneEMPHealth=100
     bNameCaseSensitive=True
     CustomName="M.E.G.H."
     
     DroneNameLabel="Name: %s"
     DroneHPLabel="hit points left"
     DroneEMPHPLabel="circuit strength left"
     M_Activated="You toss out %s, and let it fly"
     MsgCantDeployUnderwater="You cannot deploy this underwater"
     MsgNoRoomToDeploy="There's not enough room to deploy %s"
     
     bCanHaveMultipleCopies=False
     bActivatable=True
     ItemName="M.E.G.H."
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDHelidronePickup'
     PickupViewMesh=LodMesh'VMDHelidronePickup'
     ThirdPersonMesh=LodMesh'VMDHelidronePickup'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconVMDMegh'
     largeIcon=Texture'LargeIconVMDMegh'
     InvSlotsX=2
     InvSlotsY=2
     largeIconWidth=84
     largeIconHeight=84
     Description="The Modular Electric General-Use Helidrone, or MEGH, is a small assistant for use in the field. The base model can be equipped with 'small' stature weapons. Note that the drone cannot throw grenades, and will have to improvise. Additionally, there are many aftermarket upgrades that exist for the model. Due to networking limits, you can only have one MEGH at a time."
     beltDescription="HELIDRONE"
     Mesh=LodMesh'VMDHelidronePickup'
     CollisionRadius=12.000000
     CollisionHeight=8.500000
     Mass=25.000000
     Buoyancy=12.500000
}
