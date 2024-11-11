//=============================================================================
// VMDBufferAugmentationManager
//=============================================================================
class VMDBufferAugmentationManager extends AugmentationManager;

//MADDERS, 4/23/24: Update sounds on travel, thank you.
var bool bSoundUpdateQueued;

//MADDERS: Use these for signaling various messages about enabled/disabled status.
var localized string MsgAugEnabled, MsgAugDisabled;

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	bSoundUpdateQueued = true;
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDamageMult(DT, HitDamage, HitLocation);
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureSpeedMult(bool bWater)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureSpeedMult(bWater);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureJumpMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureJumpMult();
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureLungMod(bool bWater)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 0.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
		
		//MADDERS, 8/8/23: Custom tweak for aqualung. Weird.
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret += VAug.VMDConfigureLungMod(bWater);
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureHealingMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureHealingMult();
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureDecoPushMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoPushMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureDecoLiftMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoLiftMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureDecoThrowMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoThrowMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureNoiseMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureNoiseMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepDamageMult(DXW);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureWepVelocityMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
	 
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
  		VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepVelocityMult(DXW);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureWepSwingSpeedMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepSwingSpeedMult(DXW);
  		}
 	}
 	
 	return Ret;
}


function float VMDConfigureWepAccuracyMod(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 0.0;
 	Ret = 0.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret += VAug.VMDConfigureWepAccuracyMod(DXW);
 	 	}
 	}
 	
 	return Ret;
}

function VMDSignalDamageTaken(int Damage, name DamageType, Vector HitLocation, bool bCheckOnly)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	//For now, treat this as a no. Might change later? We'll see.
 	if (bCheckOnly) return;
 	
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
  		VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			VAug.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
  		}
 	}
}

function CheckAugErrors()
{
 	local bool FlagReset, bAugClutter;
 	local int KeysUsed[10], Key, i, j;
 	local Augmentation Aug, SubAug;
 	
	//MADDERs, 8/18/23: Tapering this off for now. This seems to conflict with custom aug keys, so make sure we're necessary!
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
		if ((!Aug.bAlwaysActive) && (Aug.bHasIt) && (Aug.HotKeyNum > -1))
		{
 			for (SubAug = FirstAug; SubAug != None; SubAug = SubAug.Next)
 			{
				if ((SubAug != Aug) && (SubAug.bHasIt) && (!SubAug.bAlwaysActive) && (SubAug.HotKeyNum == Aug.HotKeyNum))
				{
					bAugClutter = true;
					break;
				}
			}
		}
		if (bAugClutter) break;
	}
	if (!bAugClutter) return;
	
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
  		if (Aug.AugmentationLocation == 6)
  		{
   			if (AugLight(Aug) != None) AugLight(Aug).HotkeyNum = 12;
   			else Aug.HotKeyNum = 0;
   			continue;
  		}
  		
  		if (j > 99)
  		{
   			Log("WARNING! Infinite aug fix loop!");
   			break;
  		}
  		if (FlagReset)
  		{
   			Aug = FirstAug;
   			FlagReset = false;
  		}
  		if ((Aug != None) && (Aug.bHasIt) && (Aug.HotKeyNum > -1))
  		{
   			Key = Aug.HotKeyNum-3;
   			KeysUsed[Key]++;
   			
   			//Too many augs in this slot?
   			if (KeysUsed[Key] > 1 || Aug.HotkeyNum > 11)
   			{
    				Aug.HotKeyNum++;
    				if (Aug.HotKeyNum > 11) Aug.HotKeyNum = 3;
    				j++;
    				//-----------
    				//Reset.
    				for (i=0; i<10; i++)
    				{
     					KeysUsed[i] = 0;
    				}
    				FlagReset = true;
    				Aug = FirstAug;
   			}
  		}
 	}
}

defaultproperties
{
     MsgAugEnabled="%s enabled"
     MsgAugDisabled="%s disabled"
}
