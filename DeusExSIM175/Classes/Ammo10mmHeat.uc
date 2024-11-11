//=============================================================================
// Ammo10mm.
//=============================================================================
class Ammo10mmHeat extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Exploded';
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
      		AmmoAmount = 9;
}

function bool UseAmmo(int AmountNeeded)
{
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
         	shell = spawn(class'ShellCasingSilver',,, Owner.Location + offset);
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
     bSpecialAmmoScaling=False
     bShowInfo=True
     AmmoAmount=6
     MaxAmmo=48
     ItemName="10mm HEAT Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo10mm'
     Icon=Texture'BeltIconAmmo10mmHEAT'
     largeIcon=Texture'LargeIconAmmo10mmHEAT'
     largeIconWidth=44
     largeIconHeight=31
     Description="These 'High Explosive Advanced Trauma' or HEAT rounds prove extremely effective at punching through terrain, flesh, and armor plating alike. A truly rare find!"
     beltDescription="10MM HEAT"
     Mesh=LodMesh'DeusExItems.Ammo10mm'
     CollisionRadius=8.500000
     CollisionHeight=3.770000
     bCollideActors=True
     Multiskins(0)=Texture'Ammo10mmHEAT'
}
