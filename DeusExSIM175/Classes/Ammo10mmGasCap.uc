//=============================================================================
// Ammo10mmGasCap.
//=============================================================================
class Ammo10mmGasCap extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'KnockedOut';
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
         	if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
         		shell = spawn(class'ShellCasingSilent',,, Owner.Location + offset);
         	else
           		shell = spawn(class'ShellCasing',,, Owner.Location + offset);
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
     bShowInfo=True
     AmmoAmount=6
     MaxAmmo=48
     ItemName="10mm Gas-Cap Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo10mm'
     Icon=Texture'BeltIconAmmo10mmGasCap'
     largeIcon=Texture'LargeIconAmmo10mmGasCap'
     largeIconWidth=44
     largeIconHeight=31
     Description="WARNING: READ INSTRUCTIONS BEFORE USE: Gas-Cap munitions are designed for being ricocheted off of surfaces, as opposed to use in direct fire. Aim at the target's direction at a skew, and fire at the floor along the appropriate trajectory. The activated gas capsule should spritz the target with the included solution. Give ample range for the capsule to begin releasing. Arrest targets shortly thereafter. Firing directly at targets is not advised, but is still non-lethal."
     beltDescription="10MM GAS"
     Mesh=LodMesh'DeusExItems.Ammo10mm'
     CollisionRadius=8.500000
     CollisionHeight=3.770000
     bCollideActors=True
     Multiskins(0)=Texture'Ammo10mmGasCap'
}
