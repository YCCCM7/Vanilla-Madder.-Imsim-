//=============================================================================
// Ammo3006HEAT.
//=============================================================================
class Ammo3006HEAT extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Exploded';
}

function bool UseAmmo(int AmountNeeded)
{
	local vector offset, tempvec, X, Y, Z;
	local ShellCasing shell;
	local DeusExWeapon W;
	
	if (Super.UseAmmo(AmountNeeded))
	{
		return True;
	}
	
	return False;
}

function VMDForceShellCasing()
{
	local vector offset, tempvec, X, Y, Z;
	local ShellCasing shell;
	local DeusExWeapon W;
	
	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
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
            	shell = spawn(class'ShellCasingRed',,, Owner.Location + offset);
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
     bVolatile=True
     
     bNameCaseSensitive=True
     bShowInfo=True
     AmmoAmount=6
     MaxAmmo=48
     ItemName="30.06 HEAT Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'BeltIconAmmo3006HEAT'
     LargeIcon=Texture'LargeIconAmmo3006HEAT'
     largeIconWidth=43
     largeIconHeight=31
     Description="These 30.06 rounds are meant for bullying armored targets. Packed with an explosive charge and an armor piercing nose, they are quite capable of vaporizing anything unlucky enough to be their target, or even standing directly behind said target."
     beltDescription="3006 HEAT"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=8.000000
     CollisionHeight=3.860000
     bCollideActors=True
     Multiskins(0)=Texture'Ammo3006HEAT'
}
