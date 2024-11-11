//=============================================================================
// AmmoDragonsBreath.
//=============================================================================
class AmmoDragonsBreath extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Burned';
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
         		shell = spawn(class'ShellCasing2DragonsBreath',,, Owner.Location + offset);
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
		shell = spawn(class'ShellCasing2DragonsBreath',,, Owner.Location + offset);
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
     ItemName="12 Gauge Dragon's Breath Shells"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.AmmoShell'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoDragonsBreath'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoDragonsBreath'
     largeIconWidth=34
     largeIconHeight=45
     Description="These shells pack a fiery punch at close ranges, using shot coated with a combustible coating that burns at extreme temperatures. In the modern day, such munitions are actually recognized as a warcrime by the United Nations. Shells utilizing magnesium shot in the 20th century never caught on, due to their inability to cycle actions and high cost per shot. These rounds, however, are ironically incapable of being fired WITHOUT a self-ejecting action, because the amount of heat transfered to the barrel and chamber can rapidly lead to cook-off, 'walking', and deformation."
     beltDescription="DRAGON"
     Mesh=LodMesh'DeusExItems.AmmoShell'
     CollisionRadius=9.300000
     CollisionHeight=10.210000
     bCollideActors=True
     Skin=Texture'AmmoDragonsBreath'
}
