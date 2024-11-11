//=============================================================================
// Ammo3006Tranq.
//=============================================================================
class Ammo3006Tranq extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Poison';
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
     Mass=0.250000
     bShowInfo=True
     AmmoAmount=6
     MaxAmmo=48
     ItemName="30.06 Tranquilizer Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'BeltIconAmmo3006Tranq'
     LargeIcon=Texture'LargeIconAmmo3006Tranq'
     largeIconWidth=43
     largeIconHeight=31
     Description="Bordering on unusual, these 30.06 rounds feature soft bodied flechettes that dissolve large doses of a tranquilizing agent after impact. However, this munition is prone to producing a lethal effect at less than 20 feet, and due to issues with stabilization, the flechettes themselves exhibit abnormally large spread at range. Additionally, due to the different pressure curves during ignition, the cartridge is slightly quieter than firing stock munitions."
     beltDescription="3006 TRANQ"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=8.000000
     CollisionHeight=3.860000
     bCollideActors=True
     Multiskins(0)=Texture'Ammo3006Tranq'
}
