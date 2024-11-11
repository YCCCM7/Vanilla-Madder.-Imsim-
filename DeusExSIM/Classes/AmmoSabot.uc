//=============================================================================
// AmmoSabot.
//=============================================================================
class AmmoSabot extends DeusExAmmo;

//MADDERS: Replace old versions with taser ammo, when appropriate.
function ReplaceWithTaserSlug()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'AmmoTaserSlug',,,Location - TVect, Rotation);
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
	if (Seed == 4 || Seed == 8 || Seed == 3)
	{
		ReplaceWithTaserSlug();
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
		if (Seed == 4 || Seed == 8 || Seed == 3)
		{
			ReplaceWithTaserSlug();
		}
	}
}

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
	
      	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      	{
        	shell = None;
      	}
      	else
      	{
        	shell = spawn(class'ShellCasing2Sabot',,, Owner.Location + offset);
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
     Mass=2.000000
     bShowInfo=True
     AmmoAmount=8
     MaxAmmo=96 
     ItemName="12 Gauge Sabot Shells"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.AmmoShell'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoSabot'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoSabot'
     largeIconWidth=35
     largeIconHeight=46
     Description="A 12 gauge shotgun shell surrounding a solid core of tungsten that can punch through all but the thickest hardened steel armor at close range; however, its ballistic profile will result in minimal damage to soft targets."
     beltDescription="SABOT"
     Skin=Texture'DeusExItems.Skins.AmmoShellTex2'
     Mesh=LodMesh'DeusExItems.AmmoShell'
     CollisionRadius=9.300000
     CollisionHeight=10.210000
     bCollideActors=True
}
