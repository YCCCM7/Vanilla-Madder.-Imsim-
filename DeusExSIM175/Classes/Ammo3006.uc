//=============================================================================
// Ammo3006.
//=============================================================================
class Ammo3006 extends DeusExAmmo;

//MADDERS: Replace old versions with HEAT ammo, when appropriate
function ReplaceWithHEAT()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'Ammo3006HEAT',,,Location - TVect, Rotation);
 	
 	//Check for success! If not? Lock us down.
 	if (Rep != None) Destroy();
 	else bCrateSummoned = true;
}

//MADDERS: Replace old versions with HVAP ammo, when appropriate
function ReplaceWithAP()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
 	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'Ammo3006AP',,,Location - TVect, Rotation);
 	
 	//Check for success! If not? Lock us down.
 	if (Rep != None) Destroy();
 	else bCrateSummoned = true;
}


//MADDERS: Replace old versions with HVAP ammo, when appropriate
function ReplaceWithTranq()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
 	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'Ammo3006Tranq',,,Location - TVect, Rotation);
 	
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
	if (Seed == 3 || Seed == 0)
	{
		ReplaceWithTranq();
		//ReplaceWithAP();
	}
	
	if (Seed == 6)
	{
		ReplaceWithHEAT();
	}
}

function ProcessVMDChanges()
{
 	local int Seed;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
 	Super.ProcessVMDChanges();
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
 	if ((Owner == None) && (!bCrateSummoned))
	{
		if (Seed == 3) // || Seed == 0
		{
			ReplaceWithTranq();
			//ReplaceWithAP();
		}
		if (Seed == 6)
		{
			ReplaceWithHEAT();
		}
	}
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
     MaxAmmo=96
     ItemName="30.06 Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo3006'
     largeIconWidth=43
     largeIconHeight=31
     Description="Its high velocity and accuracy have made sniper rifles using the 30.06 round the preferred tool of individuals requiring 'one shot, one kill' for over fifty years."
     beltDescription="3006 AMMO"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=8.000000
     CollisionHeight=3.860000
     bCollideActors=True
}
