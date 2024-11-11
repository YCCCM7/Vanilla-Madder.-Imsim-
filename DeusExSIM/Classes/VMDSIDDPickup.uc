//=============================================================================
// VMDSIDDPickup.
//=============================================================================
class VMDSIDDPickup extends DeusExPickup;

var localized string MsgCantDeployUnderwater, MsgNoRoomToDeploy, DroneHPLabel, DroneEMPHPLabel, DroneNameLabel;
var travel int DroneHealth, DroneEMPHealth;
var travel string CustomName;
var bool bItemDrawn;

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
		bVMDMayhemEnabled = VMP.bMayhemSystemEnabled;
	}
	
	if (VMDGetMissionNumber() < 5)
	{
		Ret = 15;
	}
	else
	{
		Ret = 30;
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
		bVMDMayhemEnabled = VMP.bMayhemSystemEnabled;
	}
	
	Ret = 50;
	
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

function bool DeployTurret(VMDBufferPlayer VMP)
{
	local VMDSIDD TSidd;
	local Vector SpawnLoc;
	
	if (VMP == None) return false;
	
	SpawnLoc = VMP.Location + ((vect(1.75,0,0)*VMP.CollisionRadius) >> VMP.Rotation);
	
	TSidd = Spawn(class'VMDSIDD',,, SpawnLoc, VMP.Rotation);
	if (TSidd != None)
	{
		VMP.PlaySound(Sound'RepairBotLowerArm', SLOT_None,,, 512, 1.2);
		
		TSidd.CustomName = CustomName;
		TSidd.Health = DroneHealth;
		TSidd.EMPHitPoints = DroneEMPHealth;
		
		TSidd.UpdateTalentEffects(VMP);
		return true;
	}
	return false;
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
			bWin = DeployTurret(VMP);
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
		SpawnLoc = VMP.Location + ((vect(1.75,0,0)*VMP.CollisionRadius) + (vect(1,0,0) * class'VMDSIDD'.Default.CollisionRadius) >> VMP.Rotation);
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

//MADDERS, 12/23/23: Hacky, but basically treat us like drawing a gun in public.
//This only makes sense, since we're part pistol lol.
auto state Pickup
{
	function BeginState()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);
		bItemDrawn = false;
		
		Super.BeginState();
	}
}

function Tick(float DT)
{
	if (DeusExPlayer(Owner) == None) return;
	
	if (DeusExPlayer(Owner).InHand == Self)
	{
		if (!bItemDrawn)
		{
			// alert NPCs that I'm putting away my gun
			AIStartEvent('WeaponDrawn', EAITYPE_Visual);
			bItemDrawn = true;
		}
	}
	else
	{
		if (bItemDrawn)
		{
			// alert NPCs that I'm putting away my gun
			AIEndEvent('WeaponDrawn', EAITYPE_Visual);
			bItemDrawn = false;
		}
	}
}

defaultproperties
{
     bVolatile=True
     DroneHealth=15
     DroneEMPHealth=50
     bNameCaseSensitive=True
     CustomName="S.I.D.D."
     
     DroneNameLabel="Name: %s"
     DroneHPLabel="hit points left"
     DroneEMPHPLabel="circuit strength left"
     M_Activated="You deploy the %d"
     MsgCantDeployUnderwater="You cannot deploy this underwater"
     MsgNoRoomToDeploy="There's not enough room to deploy %s"
     
     bCanHaveMultipleCopies=False
     bActivatable=True
     ItemName="S.I.D.D."
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDSIDDPickup'
     PickupViewMesh=LodMesh'VMDSIDDPickup'
     ThirdPersonMesh=LodMesh'VMDSIDD3rd'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconVMDSIDD'
     largeIcon=Texture'LargeIconVMDSIDD'
     InvSlotsX=2
     InvSlotsY=2
     largeIconWidth=84
     largeIconHeight=84
     Description="The Static Improvised Defense Device, or SIDD, is a miniature turret you can deploy to the field. Unlike MEGH, you can have as many SIDD turrets as you deem necessary. However, SIDD cannot move, and must be picked up manually. SIDD runs on 7.62mm ammunition."
     beltDescription="TURRET"
     Mesh=LodMesh'VMDSIDDPickup'
     CollisionRadius=12.000000
     CollisionHeight=8.500000
     Mass=20.000000
     Buoyancy=10.000000
}
