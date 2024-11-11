//=============================================================================
// AmmoTaserSlug.
//=============================================================================
class AmmoTaserSlug extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Stunned';
}

//
// SimUseAmmo - Spawns shell casings client side
//
simulated function bool SimUseAmmo()
{
	if ( AmmoAmount > 0 )
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
	local ShellCasing2 shell;
	
	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	Y *= -1 * THand; //MADDERS, 5/30/23: Shell casing fix.
	offset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
	tempvec = 0.8 * Owner.CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	if (VMDBufferPawn(Owner) != None)
	{
		Offset = VMDBufferPawn(Owner).GetShellOffset();
	}
	
	if ( DeusExMPGame(Level.Game) != None )
	{
		if ( Level.NetMode == NM_ListenServer )
		{
         		shell = spawn(class'ShellCasing2TaserSlug',,, Owner.Location + offset);
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
		shell = spawn(class'ShellCasing2TaserSlug',,, Owner.Location + offset);
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
     Mass=1.000000
     bShowInfo=True
     AmmoAmount=8
     MaxAmmo=48
     ItemName="12 Gauge Taser Slug Shells"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.AmmoShell'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoTaserSlug'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoTaserSlug'
     largeIconWidth=34
     largeIconHeight=45
     Description="These shells are the solution to tasers having poor range. By firing a small, one-shot battery mounted to a pronged slug, these shots are extremely effective at providing a longer range sucker punch than a prod can provide. However, they're slower and must account for lead and drop. Additionally, the altered pressure curves limit these rounds to only being used in pump action shotguns."
     beltDescription="TASER"
     Mesh=LodMesh'DeusExItems.AmmoShell'
     CollisionRadius=9.300000
     CollisionHeight=10.210000
     bCollideActors=True
     Skin=Texture'AmmoTaserSlug'
}
