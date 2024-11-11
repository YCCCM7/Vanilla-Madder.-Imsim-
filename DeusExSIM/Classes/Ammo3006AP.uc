//=============================================================================
// Ammo3006AP.
//=============================================================================
class Ammo3006AP extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Sabot';
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
	local ShellCasingRifle shell;
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
      	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      	{
        	shell = None;
      	}
      	else
      	{
            	shell = spawn(class'ShellCasingRifleSilver',,, Owner.Location + offset);
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
     Mass=0.400000
     bNameCaseSensitive=True
     bShowInfo=True
     AmmoAmount=6
     MaxAmmo=48
     ItemName="30.06 HVAP Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'BeltIconAmmo3006AP'
     LargeIcon=Texture'LargeIconAmmo3006AP'
     largeIconWidth=43
     largeIconHeight=31
     Description="These 30.06 rounds are specially made with an even higher volume of propellant, along with a solid tungsten core. In essence, they can shoot through material and armor with shrewd efficiency."
     beltDescription="3006 HVAP"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=8.000000
     CollisionHeight=3.860000
     bCollideActors=True
     Multiskins(0)=Texture'Ammo3006AP'
}
