//=============================================================================
// Ammo762mm.
//=============================================================================
class Ammo762mm extends DeusExAmmo;

//
// SimUseAmmo - Spawns shell casings client side
//
simulated function bool SimUseAmmo()
{
	if (AmmoAmount > 0)
	{
		return True;
	}
	return False;
}

function bool UseAmmo(int AmountNeeded)
{
	if (Super.UseAmmo(AmountNeeded))
	{
		return True;
	}
	
	return False;
}

function VMDForceShellCasing(int THand)
{
	local vector offset, tempvec, X, Y, Z;
	local DeusExFragment shell;
	local DeusExWeapon W;
	
	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	Y *= -1 * THand; //MADDERS, 5/30/23: Shell casing fix.
	offset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
	tempvec = 0.8 * Owner.CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	if (VMDBufferPawn(Owner) != None)
	{
		Offset = VMDBufferPawn(Owner).GetShellOffset();
	}
	
	// use silent shells if the weapon has been silenced
	W = DeusExWeapon(Pawn(Owner).Weapon);
      	if ((Level != None) && (DeusExMPGame(Level.Game) != None))
      	{
		if ( Level.NetMode == NM_ListenServer )
		{
			if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
			{
				if (WeaponAssaultGun(W) != None || WeaponSIDDPistol(W) != None || WeaponMJ12Commando(W) != None)
				{
           				shell = spawn(class'ShellCasingSilent',,, Owner.Location + offset);
				}
				else
				{
           				shell = spawn(class'ShellCasingRifleSilent',,, Owner.Location + offset);
				}
			}
			else
			{
				if (WeaponAssaultGun(W) != None || WeaponSIDDPistol(W) != None || WeaponMJ12Commando(W) != None)
				{
            				shell = spawn(class'ShellCasing',,, Owner.Location + offset);
				}
				else
				{
            				shell = spawn(class'ShellCasingRifle',,, Owner.Location + offset);
				}
			}
			
			if (Shell != None)
			{
				shell.RemoteRole = ROLE_None;
			}
		}
		else
	        	shell = None;
      	}
      	else
      	{
        	if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
		{
			if (WeaponAssaultGun(W) != None || WeaponSIDDPistol(W) != None || WeaponMJ12Commando(W) != None)
			{
           			shell = spawn(class'ShellCasingSilent',,, Owner.Location + offset);
			}
			else
			{
           			shell = spawn(class'ShellCasingRifleSilent',,, Owner.Location + offset);
			}
		}
         	else
		{
			if (WeaponAssaultGun(W) != None || WeaponSIDDPistol(W) != None || WeaponMJ12Commando(W) != None)
			{
            			shell = spawn(class'ShellCasing',,, Owner.Location + offset);
			}
			else
			{
            			shell = spawn(class'ShellCasingRifle',,, Owner.Location + offset);
			}
		}
      	}
	
	if (shell != None)
	{
		if (VMDBufferPawn(Owner) != None)
		{
			shell.Velocity = VMDBufferPawn(Owner).GetShellVelocity();
		}
		else
		{
			shell.Velocity = (FRand()*20+90) * Y + (10-FRand()*20) * X;
		}
		shell.Velocity.Z = 0;
	}
}

defaultproperties
{
     Mass=0.500000
     bShowInfo=True
     AmmoAmount=30
     MaxAmmo=270
     ItemName="7.62x28mm Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo762mm'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo762'
     largeIconWidth=46
     largeIconHeight=34
     Description="The 7.62x28mm round was prototyped for many years, before eventually being refined and favored for a variety of reasons, the chief of which being soft recoil and low ammunition carry weight. Its widespread adoption among national security forces within the UN and NATO has made it ubiquitous ever since."
     beltDescription="7.62 AMMO"
     Mesh=LodMesh'DeusExItems.Ammo762mm'
     CollisionRadius=6.000000
     CollisionHeight=0.750000
     bCollideActors=True
}
