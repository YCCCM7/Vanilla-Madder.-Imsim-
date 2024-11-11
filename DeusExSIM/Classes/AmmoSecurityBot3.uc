//=============================================================================
// AmmoSecurityBot3.
//
// Offsets shell spawning for the 4 guns
//=============================================================================
class AmmoSecurityBot3 extends Ammo762mm;

var() int ShellGun;

function bool UseAmmo(int AmountNeeded)
{
	local vector offset, tempvec, X, Y, Z;
	local ShellCasing shell;
	local DeusExWeapon W;
	
	// 0 = BottomLeft | 1 = BottomRight | 2 = TopLeft | 3 = TopRight
	
	ShellGun += 1;
	if (ShellGun > 3)
		ShellGun = 0;

	if (Super(DeusExAmmo).UseAmmo(AmountNeeded))
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		if (ShellGun == 0 || ShellGun == 2)
		{
			offset = Owner.CollisionRadius * X - 0.5 * Owner.CollisionRadius * Y;
		}
		else
		{
			offset = Owner.CollisionRadius * X + 0.5 * Owner.CollisionRadius * Y;
		}
		
		if (ShellGun == 0 || ShellGun == 1)
		{
			tempvec = 0.4 * Owner.CollisionHeight * Z;
		}
		else
		{
			tempvec = 0.8 * Owner.CollisionHeight * Z;
		}
		offset.Z += tempvec.Z;

		// use silent shells if the weapon has been silenced
		W = DeusExWeapon(Pawn(Owner).Weapon);
		if ( DeusExMPGame(Level.Game) != None )
		{
			if ( Level.NetMode == NM_ListenServer )
			{
				if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
				{
					shell = spawn(class'ShellCasingSilent',,, Owner.Location + offset);
				}
				else
				{
					shell = spawn(class'ShellCasing',,, Owner.Location + offset);
				}
				shell.RemoteRole = ROLE_None;
			}
			else
				shell = None;
		}
		else
		{
			if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
			{
				shell = spawn(class'ShellCasingSilent',,, Owner.Location + offset);
			}
			else
			{
				shell = spawn(class'ShellCasing',,, Owner.Location + offset);
			}
		}

		if (shell != None)
		{
			if (ShellGun == 0 || ShellGun == 2)
			{
				shell.Velocity = (FRand()*20+90) * -Y - (10-FRand()*20) * -X;
			}
			else
			{
				shell.Velocity = (FRand()*20+90) * Y + (10-FRand()*20) * X;
			}
			shell.Velocity.Z = 0;
			
			// if(shellmesh != None)
				// shell.mesh = shellmesh;
		}
		return True;
	}

	return False;
}

defaultproperties
{
}
