//=============================================================================
// AmmoShell.
//=============================================================================
class AmmoShell extends DeusExAmmo;

//MADDERS: Replace old versions with D.B. ammo, when appropriate.
function ReplaceWithDragonsBreath()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'AmmoDragonsBreath',,,Location - TVect, Rotation);
 	Rep.bOwned = bOwned;
	Rep.bSuperOwned = bSuperOwned;
 	
 	//Check for success! If not? Lock us down.
 	if (Rep != None) Destroy();
 	else bCrateSummoned = true;
}

//MADDERS: Do this nonsense for dropping swapped ammos.
function VMDAttemptCrateSwap(int Seed)
{
	local DeusExLevelInfo DXLI;
 	
 	Super.VMDAttemptCrateSwap(Seed);
 	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
	if ((Seed == 1) && (DXLI.MissionNumber > 9)) //MADDERS, 5/27/23: Way too much D.B. in mission 9
	{
		ReplaceWithDragonsBreath();
	}
}

function ProcessVMDChanges()
{
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
 	Super.ProcessVMDChanges();
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
 	if ((Owner == None) && (!bCrateSummoned))
	{
		if ((Seed == 1) && (DXLI.MissionNumber > 9)) //MADDERS, 5/27/23: Way too much D.B. in mission 9
		{
			ReplaceWithDragonsBreath();
		}
	}
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
         		shell = spawn(class'ShellCasing2',,, Owner.Location + offset);
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
		shell = spawn(class'ShellCasing2',,, Owner.Location + offset);
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
     MaxAmmo=96
     ItemName="12 Gauge Buckshot Shells"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.AmmoShell'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoShells'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoShells'
     largeIconWidth=34
     largeIconHeight=45
     Description="Standard 12 gauge shotgun shells; very effective for close-quarters combat against soft targets, but useless against body armor."
     beltDescription="BUCKSHOT"
     Mesh=LodMesh'DeusExItems.AmmoShell'
     CollisionRadius=9.300000
     CollisionHeight=10.210000
     bCollideActors=True
}
