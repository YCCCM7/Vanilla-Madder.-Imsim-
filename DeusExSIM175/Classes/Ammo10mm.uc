//=============================================================================
// Ammo10mm.
//=============================================================================
class Ammo10mm extends DeusExAmmo;

//MADDERS: Replace old versions with HEAT ammo, when appropriate
function ReplaceWithHeat()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	local DeusExPlayer DXP;
	
	forEach AllActors(class'DeusExPlayer', DXP)
	{
		if ((DXP != None) && (DXP.IsA('MadIngramPlayer')))
		{
			return;
		}
	}
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'Ammo10mmHeat',,,Location - TVect, Rotation);
 	
 	//Check for success! If not? Lock us down.
 	if (Rep != None) Destroy();
 	else bCrateSummoned = true;
}

//MADDERS: NEW! Do this instead, because we're not a troll project anymore.
function ReplaceWithGasCap()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	local DeusExPlayer DXP;
 	
	forEach AllActors(class'DeusExPlayer', DXP)
	{
		if ((DXP != None) && (DXP.IsA('MadIngramPlayer')))
		{
			return;
		}
	}
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'Ammo10mmGasCap',,,Location - TVect, Rotation);
 	
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
	if (Seed == 2) // || Seed == 5
	{
		ReplaceWithGasCap();
	}
	else if (Seed == 8)
	{
		//MADDERS: Allow this easter egg ammo in non-canon campaigns. It's fun.
		if ((DXLI != None) && (DXLI.MissionNumber > 15)) ReplaceWithHeat();
		//else ReplaceWithGasCap();
	}
}

function ProcessVMDChanges()
{
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
 	Super.ProcessVMDChanges();
 	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
 	if ((Owner == None) && (!bCrateSummoned))
	{
		if (Seed == 2) // || Seed == 5
		{
			ReplaceWithGasCap();
		}
		else if (Seed == 8)
		{
			//MADDERS: Allow this easter egg ammo in non-canon campaigns. It's fun.
			if ((DXLI != None) && (DXLI.MissionNumber > 15)) ReplaceWithHeat();
			//else ReplaceWithGasCap();
		}
	}
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
     MaxAmmo=150
     ItemName="10mm Ammo"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo10mm'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo10mm'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmo10mm'
     largeIconWidth=44
     largeIconHeight=31
     Description="With their combination of high stopping power and low recoil, pistols chambered for the 10mm round have become the sidearms of choice for paramilitary forces around the world."
     beltDescription="10MM AMMO"
     Mesh=LodMesh'DeusExItems.Ammo10mm'
     CollisionRadius=8.500000
     CollisionHeight=3.770000
     bCollideActors=True
}
