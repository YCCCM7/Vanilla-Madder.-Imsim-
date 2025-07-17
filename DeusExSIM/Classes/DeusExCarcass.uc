//=============================================================================
// DeusExCarcass.
//=============================================================================
class DeusExCarcass extends Carcass;

struct InventoryItemCarcass  {
	var() class<Inventory> Inventory;
	var() int              count;
};

var(Display) mesh Mesh2;		// mesh for secondary carcass
var(Display) mesh Mesh3;		// mesh for floating carcass
var(Inventory) InventoryItemCarcass InitialInventory[8];  // Initial inventory items held in the carcass
var() bool bHighlight;

var String			KillerBindName;		// what was the bind name of whoever killed me?
var Name			KillerAlliance;		// what alliance killed me?
var bool			bGenerateFlies;		// should we make flies?
var FlyGenerator	flyGen;
var Name			Alliance;			// this body's alliance
var Name			CarcassName;		// original name of carcass
var int				MaxDamage;			// maximum amount of cumulative damage
var bool			bNotDead;			// this body is just unconscious
var() bool			bEmitCarcass;		// make other NPCs aware of this body
var bool		    bQueuedDestroy;	// For multiplayer, semaphore so you can't doublefrob bodies (since destroy is latent)

var bool			bInit;

// Used for Received Items window
var bool bSearchMsgPrinted;

var localized string msgSearching;
var localized string msgEmpty;
var localized string msgNotDead;
var localized string msgAnimalCarcass;
var localized string msgCannotPickup;
var localized String msgRecharged;
var localized string itemName;			// human readable name

var() bool bInvincible;
var bool bAnimalCarcass;

//MADDERS ADDITIONS!
var bool bExplosive, bEverDrewGrenade;
var float LastFrobTime, DoubleFrobTime, SmellSeconds, SmellCooldown; //Two frobs in 1/4 sec = pick up corpse anyways.
var bool bEverNotFrobbed;

var Actor BloodCloud;
var bool bSpawnedBloodCloud;
var Vector BloodCloudOffset;

//MADDERS: Store stuck projectiles here.
var class<Inventory> StuckProjectiles[4];
var byte StuckCount[4];
var int TimesMunched, EMPTakenTotal;

var bool bImportant;
var string StoredFamiliarName, FlagName;

var bool bFrobbable, bEverSearched;
var localized string MsgTimeTraveller, MsgLayingOnGrenade;

//MADDERS, 8/12/21: Inherit this from pawns for consistency sake.
var int MyPawnSeed;

//MADDERS, 12/26/20: For semi-static ammo retrieval rates.
var string AmmoLootSeed;

//MADDERS, 5/17/22: Mayhem stuff.
var bool bMayhemSuspect, bMayhemPayback;

//MADDERS, 8/11/23: Unconscious detection stuff. Crude, but workable.
var bool bKOEmitCarcass;

//MADDERS, 2/20/25: Build blood smell over time.
var float BloodSmellLevel;
var VMDSmellManager BloodSmell;

//MADDERS, 8/26/23: Save this so our weight is consistent.
var float BaseMass;

//MADDERS, 4/29/25: For corpses that shouldn't be eaten.
//We do not clone this to POV, because picking us up and dropping us implies we're no longer an exception.
var bool bBlockAnimalFoodRoutines;

//MADDERS: Allow us to return the firing sytem type. Currently only used for open chamber augment.
function int VMDOwnerFiringSystem(Ammo A)
{
	local Inventory Inv;
	
	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if ((DeusExWeapon(Inv) != None) && (DeusExWeapon(Inv).AmmoType == Self))
		{
			return DeusExWeapon(Inv).FiringSystemOperation;
		}
	}
	
	return 0;
}

//MADDERS: Forgot to add test boxes, this somehow aced the fuck outta my tests, without even trying.
//Man I love adding hook functions.
function bool VMDBlockDumpOfItem( Inventory I )
{
	if (WeaponCombatKnife(I) != None) return true;
	if ((DeusExWeapon(I) == None) && (I.InvSlotsX > 90)) return true;
	if ((DeusExWeapon(I) != None) && (DeusExWeapon(I).VMDConfigureInvSlotsX(None) > 90)) return true;
	if (I.Default.Mesh == LODMesh'TestBox') return true;
	if (ChargedPickup(I) != None) return true;
	
	//MADDERS: Destroy our inventory at random. Not a perfect retrieval rate, except for nanokeys.
	if (Nanokey(I) == None)
	{
		//MADDERS: Pickups survive more often, being less volatile.
		if (Pickup(I) != None)
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) == 0)
			{
		 		return true;
			}
		}
		else
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) != 2)
			{
				return true;
			}
		}
 	}
	return false;
}

//MADDERS: Walking on dead bodies smell like ass. Fact.
function Touch(Actor Other)
{
	if ((VMDBufferPlayer(Other) != None) && (!bHidden) && (!bInvincible) && (!bNotDead) && (Level.TimeSeconds > (SmellSeconds+SmellCooldown)))
	{
		SmellSeconds = Level.TimeSeconds;
		if (bAnimalCarcass)
		{
			//only 6 for animals
			VMDBufferPlayer(Other).AddBloodLevel(Max(10, 10 * (Mass / 150)));
		}
		else
		{
			//30 seconds to wear off
			VMDBufferPlayer(Other).AddBloodLevel(Max(30, 30 * (Mass / 150)));
		}
	}
}

function bool ShouldExplode()
{
	local bool Ret, bDidFirst;
	local int LastAmmoRand, i, NumWins;
	local Vector EndTrace, StartTrace, HL, HN, RandChunk;
	local Actor HitAct;
	local Inventory item, nextitem, lastitem;
	local Projectile Proj;
	local VMDFireChild TFire;
	
	if ((bExplosive) && (EMPTakenTotal < 75)) return true;
	
 	if (Inventory != None)
 	{
  		bDidFirst = false;
  		item = Inventory;
  		
  		do
  		{
   			nextitem = Item.Inventory;
   			if ((DeusExWeapon(item) != None) && (DeusExWeapon(Item).bVolatile))
   			{
    				if ((DeusExWeapon(item).bHandToHand) && (!DeusExWeapon(item).bInstantHit))
    				{
     					//NEW: Configure a proper radius, because so far this seems unreliable to a fault!
					//---------------------------------------------
					//MADDERS: Don't blow up empty grenade counts.
					if ((DeusExWeapon(Item).AmmoType != None) && (DeusExWeapon(Item).AmmoType.AmmoAmount > 0))
					{
     						Proj = Spawn(DeusExWeapon(item).ProjectileClass, Self,, Location + vect(0,0,5), RotRand(False));
     						Proj.TakeDamage(100, None, Proj.Location, vect(0,0,0), 'Exploded');
					}
     					if (!bDidFirst) Inventory = nextitem;
     					else lastItem.Inventory = NextItem;
     					
     					Item.Destroy();
    				}
				else if ((WeaponFlamethrower(Item) != None || WeaponRetributorFlamethrower(Item) != None) && (Region.Zone == None || !Region.Zone.bWaterZone))
				{
					Ret = True;
					for(i=0; i<16; i++)
					{
						StartTrace = Location;
						RandChunk = VRand() * 96;
						RandChunk.Z = 0;
						EndTrace = StartTrace + (vect(0,0,-1) * CollisionHeight * 2.2) + RandChunk;
						
						HitAct = Trace(HL, HN, EndTrace, StartTrace);
						if (HitAct == Level || Mover(HitAct) != None)
						{
							TFire = Spawn(class'VMDFireChild',HitAct,, HL+(HN*12));
							if (TFire != None)
							{
								TFire.DrawScale = (FRand() + 1.0) / 4;
								TFire.LifeSpan =  5 + Rand(10) + FRand();
								TFire.Texture = FireTexture'Effects.Fire.flame_b';
								TFire.SetBase(HitAct);
								
								// turn off the sound and lights for all but the first one
								if (NumWins > 0)
								{
									TFire.AmbientSound = None;
									TFire.LightType = LT_None;
								}
								NumWins++;
								
								// turn on/off extra fire and smoke
								if (FRand() < 0.9)
								{
									TFire.smokeGen.Destroy();
								}
								if (FRand() < 0.25)
								{
									TFire.AddFire(1.5);
								}
							}
						}
					}
     					if (!bDidFirst) Inventory = nextitem;
     					else lastItem.Inventory = NextItem;
     					
     					Item.Destroy();
				}
    				else
    				{
     					if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
     					else lastItem.Inventory = nextitem;
     					Ret = True;
     					lastitem = item;
     					
     					Item.Destroy();
    				}
   			}
   			else if ((DeusExAmmo(item) != None) && (DeusExAmmo(Item).bVolatile))
   			{
    				if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
    				else lastItem.Inventory = nextitem;
    				Ret = True;
    				lastitem = item;
     				
    				Item.Destroy();
   			}
			else if (DeusExPickup(Item) != None && (DeusExPickup(Item).bFragile || DeusExPickup(Item).bVolatile || DeusExPickup(Item).bBreakable))
			{
    				if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
    				else lastItem.Inventory = nextitem;
				if (FireExtinguisher(Item) != None)
				{
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 0, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 8192, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 16384, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 24576, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 32768, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 40960, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 49152, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 57344, 0));
				}
				
				if (DeusExPickup(Item).bVolatile)
				{
	    				MiniExplode();
				}
    				lastitem = item;
     				
    				Item.Destroy();
			}
			else
   			{
    				if (!bDidFirst) bDidFirst = True;
    				lastitem = item;
   			}
   			
   			item = nextitem;
  		}
  		until ((Nextitem == None) && (item == None));
 	}
 	
 	return Ret;
}

function MiniExplode()
{
	local int i;
	local float explosionDamage, explosionRadius, GSpeed;
	local ExplosionLight light;
	local ScorchMark s;
	local SphereEffect sphere;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	explosionDamage = 35;
	explosionRadius = 96;
	
	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'SmallExplosion2', SLOT_None,,, explosionRadius*16);
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;
	
	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	
	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;
	
	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}
	
	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
		else
			spawn(class'FleshFragment',,,Location);
	}
	
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

function Explode()
{
	local int i;
	local float explosionDamage, explosionRadius, GSpeed;
	local ExplosionLight light;
	local ScorchMark s;
	local SphereEffect sphere;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	explosionDamage = 100;
	explosionRadius = 256;
	
	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;
	
	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);
	
	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;
	
	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}
	
	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
		else
			spawn(class'FleshFragment',,,Location);
	}
	
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

function DeusExWeapon FindWeaponOwner(DeusExAmmo DXA)
{
	local DeusExWeapon DXW, Ret;
	
	forEach AllActors(Class'DeusExWeapon', DXW)
	{
		if (DXW.AmmoType == DXA)
		{
			Ret = DXW;
			break;
		}
	}
	
	return Ret;
}

//MADDERS: Dump inventory items on gib!
function DumpItemInventory()
{
 	local Inventory item, NextItem, LastItem;
 	local float MassMult;
 	local Vector Offs, R;
 	local bool FlagNullItem;
	local int AmmoRet;
	local DeusExAmmo DXA, ODXA;
	local DeusExWeapon DXW, ODXW;
	local VMDBufferPlayer VMP;
 	
 	if (ShouldExplode())
 	{
  		Explode();
  		if ((bExplosive) && (EMPTakenTotal < 75)) return; //Only return when we were already gonna 'splode!
 	}
 	
	//throw our shit everywhere.
	if (!IsA('Animal') && !IsA('Robot'))
	{
		if (Inventory != None)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;
				DeleteInventory(item);
				
				//Experimental clause for the mystery flung shit.
				item.SetLocation(Self.Location);
				
				VMP = VMDBufferPlayer(GetPlayerPawn());
				ODXA = None;
				ODXW = None;
				DXW = DeusExWeapon(Item);
				if (DXW != None)
				{
					ODXA = DeusExAmmo(DXW.AmmoType);
				}
				DXA = DeusExAmmo(Item);
				if (DXA != None)
				{
					ODXW = GetOwningWeapon(DXA);
				}
				
				FlagNullItem = False;
				if (Item.IsA('Ammo') || Item.IsA('DeusExWeapon')) if (Item.GetPropertyText("AmmoAmount") ~= "0" || Item.GetPropertyText("bNativeAttack") ~= "True" || Item.Default.Mesh == LODMesh'TestBox') FlagNullItem = True;
				else if ((DeusExWeapon(Item) == None) && (Item.InvSlotsX > 90)) FlagNullItem = True;
				else if ((DeusExWeapon(Item) != None) && (DeusExWeapon(Item).VMDConfigureInvSlotsX(None) > 90)) FlagNullItem = True;
				
				if (FlagNullItem)
				{
					Item.Destroy();
					if (LastItem != None) LastItem.Inventory = NextItem;
					else Inventory = NextItem;
				}
				else
				{
					 LastItem = Item;
				}
				
				MassMult = 1 + Min(3 / Max(item.Mass, 2.5), 2);
				
				Offs = Location;
				Offs.X += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Y += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Z += (FRand() + 0.5) * CollisionHeight;
				
				R = VRand() + vect(0,0,1);
				
				if ((DXW != None) && (DXW.PickupAmmoCount > -1))
				{
					AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(0, 0, DXW, ODXA, VMP);
					
					DXW.AIRating = DXW.Default.AIRating;
					DXW.bMuzzleFlash = 0;
					DXW.PickupAmmoCount = Max(0, Min(DXW.ReloadCount, AmmoRet));
					DXW.EraseMuzzleFlashTexture();
				}
				if (DXA != None)
				{
					if ((ODXW != None) && (ODXW.PickupAmmoCount > -1))
					{
						AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(1, 1, ODXW, DXA, VMP);
						
						DXA.AmmoAmount = AmmoRet;
						
						//MADDERS, 1/13/21: Don't drop 0 ammo, thanks.
						if (AmmoRet <= 0) DXA.Destroy();
					}
					else
					{
						AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(1, 1, FindWeaponOwner(DXA), DXA, VMP);
						
						DXA.AmmoAmount = AmmoRet;
						
						//MADDERS, 1/13/21: Don't drop 0 ammo, thanks.
						if (AmmoRet <= 0) DXA.Destroy();
					}
				}
				
				if ((DeusExPickup(Item) != None) && (Credits(Item) == None))
				{
					DeusExPickup(Item).NumCopies = 1;
				}
				
				//MADDERS, 8/7/23: I'm lazy. Sue me.
				item.SetPropertyText("bCorpseUnclog", "True");
				
				if ((DXW != None) && (DXW.PickupAmmoCount < 0))
				{
					DXW.PickupAmmoCount = 0;
				}
				item.SetPhysics(PHYS_Falling);
				item.RemoteRole = ROLE_DumbProxy;
				item.NetPriority = 2.5;
				item.BecomePickup();
				item.bCollideWorld = True;
				item.GoToState('PickUp', 'Dropped');
				item.Velocity = R * (Rand(50) + 100) * MassMult;
				item.Velocity = item.Velocity + Velocity; //Magic clause for relative velocity!
				item.bFixedRotationDir = True;
				item.RotationRate = RotRand(True);
				
				item.RespawnTime = 0;
				
				if (VMDBlockDumpOfItem(item)) item.Destroy();
				item = nextItem;
			}
			until (item == None);
		}
	}
}

// ----------------------------------------------------------------------
// InitFor()
// ----------------------------------------------------------------------

function InitFor(Actor Other)
{
	local int i;
	local ScriptedPawn SP;
	local VMDBufferPawn VMBP;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.bEnemyReactKOdDudes))
	{
		bKOEmitCarcass = true;
	}
	
	SP = ScriptedPawn(Other);
	VMBP = VMDBufferPawn(Other);
	if (Other != None)
	{
		//MADDERS, 9/11/21: Clone fatness for goofy stuff.
		Fatness = Other.Fatness;
		DrawScale = Other.DrawScale;
		
		MyPawnSeed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Other);
		
		//MADDERS: Store this data for use with complex corpse interactions.
		FlagName = Other.BindName;
		if (VMBP != None)
		{
			if (class'VMDStaticFunctions'.Static.TargetIsMayhemable(Other))
			{
				bMayhemPayback = VMBP.bAntiMayhemSuspect;
				bMayhemSuspect = VMBP.bMayhemSuspect;
			}
			
			if (VMBP.bCorpseUnfrobbable)
			{
				bFrobbable = False;
			}
			
			Texture = VMBP.StoredTexture;
			Skin = VMBP.StoredSkin;
			for (i=0; i<8; i++)
			{
				if (VMBP.StoredMultiskins[i] != None)
				{
					Multiskins[i] = VMBP.StoredMultiskins[i];
				}
			}
			StoredFamiliarName = VMBP.FamiliarName;
			
			if ((VMDBufferPlayer(GetPlayerPawn()) != None) && (VMDBufferPlayer(GetPlayerPawn()).HasSkillAugment('MeleeProjectileLooting')))
			{
				for (i=0; i<4; i++)
				{
					StuckProjectiles[i] = VMBP.StuckProjectiles[i];
					StuckCount[i] = VMBP.StuckCount[i];
				}
			}
		}
		
		if (bAnimalCarcass)
			itemName = msgAnimalCarcass;
		
		// set as unconscious or add the pawns name to the description
		//if (!bAnimalCarcass)
		//{
			//MADDERS, 12/20/20: Show familiar names of not ded dudes.
			if (bNotDead)
			{
				if (SP.FamiliarName != "")
				{
					itemName = msgNotDead@"("$ScriptedPawn(Other).FamiliarName$")";
				}
				else
				{
					itemName = msgNotDead;
				}
			}
			else if (SP != None)
			{
				if (SP.FamiliarName != "")
				{
					itemName = itemName@"("$ScriptedPawn(Other).FamiliarName$")";
				}
				else
				{
					itemName = itemName;
				}
			}
		//}
		
		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = 0.8*Mass;

		if (SP != None)
		{
			bImportant = SP.bImportant;
			if (SP.bBurnedToDeath)
			{
				//G-Flex: Give burn victims close to 1/4 corpse-health instead of 1
				//G-Flex: Instacrowbargibbing burnt bodies feels dumb, albeit hilarious
				//G-Flex: Adding one health to prevent purely hypothetical instagib due to rounding
				CumulativeDamage = MaxDamage * 0.75 - 1;
			}
		}
		SetScaleGlow();
		
		// Will this carcass spawn flies?
		if (bAnimalCarcass)
		{
			if ((FRand() < 0.2) && (!bNotDead))
			{
				bGenerateFlies = true;
			}
		}
		else if (!Other.IsA('Robot') && (!bNotDead || bKOEmitCarcass))
		{
			if ((FRand() < 0.1) && (!bNotDead))
			{
				bGenerateFlies = true;
			}
			bEmitCarcass = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;
		
		if ((bNotDead) && (IsA('ScubaDiverCarcass')))
			AmbientSound = Sound'RebreatherLoop';
		
		CarcassName = Other.Name;
		
		VMDUpdateMassBuoyancy();
	}
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------

function PostBeginPlay()
{
	local int i, j;
	local DeusExAmmo DXA;
	local Inventory inv;
	local VMDSmellManager TManager;
	
	bCollideWorld = true;
	
	// Use the carcass name by default
	CarcassName = Name;
	BaseMass = Mass;
	
	// Add initial inventory items
	for (i=0; i<8; i++)
	{
		if ((InitialInventory[i].inventory != None) && (InitialInventory[i].count > 0))
		{
			for (j=0; j<InitialInventory[i].count; j++)
			{
				inv = spawn(InitialInventory[i].inventory, self);
				if (inv != None)
				{
					inv.bHidden = True;
					inv.SetPhysics(PHYS_None);
					AddInventory(inv);
					if ((DeusExWeapon(Inv) != None) && (DeusExWeapon(Inv).AmmoType == None) && (class<DeusExAmmo>(DeusExWeapon(Inv).AmmoName) != None))
					{
						DXA = DeusExAmmo(Spawn(DeusExWeapon(Inv).AmmoName, self));
						if (DXA != None)
						{
							DeusExWeapon(Inv).AmmoType = DXA;
							DXA.bHidden = True;
							DXA.SetPhysics(PHYS_None);
							AddInventory(DXA);
						}
					}
				}
			}
		}
	}
	
	// use the correct mesh
	if (Region.Zone.bWaterZone)
	{
		Mesh = Mesh3;
		bNotDead = False;		// you will die in water every time
	}
	
	if (IsA('ScubaDiverCarcass') && (bNotDead))
		AmbientSound = Sound'RebreatherLoop';
	
	if ((bAnimalCarcass) && (ItemName == Default.ItemName))
		itemName = msgAnimalCarcass;
	
	MaxDamage = 0.8*Mass;
	SetScaleGlow();
	
	SetTimer(30.0, False);
	
	VMDUpdateMassBuoyancy();
	
	BloodSmell = Spawn(class'VMDSmellManager', Self,, Location);
	
	Super.PostBeginPlay();
}

// ----------------------------------------------------------------------
// ZoneChange()
// ----------------------------------------------------------------------

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	// use the correct mesh for water
	if (NewZone.bWaterZone)
	{
		//MADDERS: We have drowned. Oops.
		if ((bNotDead) && (!IsA('ScubaDiverCarcass')))
		{
			KillCarcass(Instigator, 'Drowned', Location);
		}
		
		//MADDERS: Blood cloud when hitting water. Spicy.
		if ((!bNotDead) && (!bSpawnedBloodCloud))
		{
			BloodCloud = Spawn(Class'BloodCloudEffectLarge',Self,,Location+(Velocity/60));
			bSpawnedBloodCloud = true;
		}
		Mesh = Mesh3;
	}
}

// ----------------------------------------------------------------------
// Destroyed()
// ----------------------------------------------------------------------

function Destroyed()
{
	if (flyGen != None)
	{
		flyGen.StopGenerator();
		flyGen = None;
	}

	Super.Destroyed();
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

function Tick(float deltaSeconds)
{
	local float OldSmellLevel;
	
	if ((BloodSmellLevel < 30) && (KillerAlliance == 'Player') && (!bNotDead))
	{
		OldSmellLevel = BloodSmellLevel;
		BloodSmellLevel += DeltaSeconds;
		if ((BloodSmellLevel >= 10) && (OldSmellLevel < 10))
		{
			BloodSmell.InitNodes('PlayerBloodSmell', 3, 0.75, 280, true);
		}
		else if ((BloodSmellLevel >= 30) && (OldSmellLevel < 30))
		{
			BloodSmell.InitNodes('PlayerBloodSmell', 5, 0.75, 480, true); //MADDERS, 2/22/25: Don't do strong, it fucks with AI states.
		}
	}
	
	//MADDERS: Blood clouds suck ass at following carcasses, so force their hand.
	if (BloodCloud != None)
	{
		BloodCloud.SetLocation(Location+BloodCloudOffset);
	}
	
	if (!bInit)
	{
		bInit = true;
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}
	Super.Tick(deltaSeconds);
}

// ----------------------------------------------------------------------
// Timer()
// ----------------------------------------------------------------------

function Timer()
{
	if (bGenerateFlies)
	{
		flyGen = Spawn(Class'FlyGenerator', , , Location, Rotation);
		if (flyGen != None)
			flyGen.SetBase(self);
	}
}

// ----------------------------------------------------------------------
// ChunkUp()
// ----------------------------------------------------------------------

function ChunkUp(int Damage)
{
	local int i;
	local float size;
	local Vector loc;
	local FleshFragment chunk;
	local VMDBufferPlayer VMP;
	
	if (bMayhemSuspect)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
		if (VMP != None)
		{
			if (bNotDead)
			{
				VMP.OwedMayhemFactor += VMP.MayhemKilledValue;
				
				if (AIGetLightLevel(Location) < 0.01)
				{
					VMP.OwedMayhemFactor -= VMP.MayhemDarknessValue;
				}
				if (bMayhemPayback) VMP.OwedMayhemFactor += VMP.MayhemLivingValue;
			}
			VMP.OwedMayhemFactor += VMP.MayhemGibbingValue;
		}
	}
	
	// gib the carcass
	size = (CollisionRadius + CollisionHeight) / 2;
	if (size > 10.0)
	{
		for (i=0; i<size/4.0; i++)
		{
			loc.X = (1-2*FRand()) * CollisionRadius;
			loc.Y = (1-2*FRand()) * CollisionRadius;
			loc.Z = (1-2*FRand()) * CollisionHeight;
			loc += Location;
			chunk = spawn(class'FleshFragment', None,, loc);
			if (chunk != None)
			{
				chunk.DrawScale = size / 25;
				chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
				chunk.bFixedRotationDir = True;
				chunk.RotationRate = RotRand(False);
			}
		}
	}
	
	Super.ChunkUp(Damage);
}

// ----------------------------------------------------------------------
// TakeDamage()
// ----------------------------------------------------------------------

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, name damageType)
{
	local int i;
	
	if (bInvincible)
		return;
	
	// only take "gib" damage from these damage types
	if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'Munch') || (damageType == 'Tantalus'))
	{
		if ((damageType != 'Munch') && (damageType != 'Tantalus'))
		{
         		if ((DeusExMPGame(Level.Game) == None) || (DeusExMPGame(Level.Game).bSpawnEffects))
         		{
            			spawn(class'BloodSpurt',,,HitLocation);
            			spawn(class'BloodDrop',,, HitLocation);
            			for (i=0; i<Damage; i+=10)
               				spawn(class'BloodDrop',,, HitLocation);
         		}
		}
		
		// this section copied from Carcass::TakeDamage() and modified a little
		if (!bDecorative)
		{
			bBobbing = false;
			SetPhysics(PHYS_Falling);
		}
		if ((Physics == PHYS_None) && (Momentum.Z < 0))
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if (DamageType == 'Shot')
			Damage *= 0.4;
		CumulativeDamage += Damage;
		if ((CumulativeDamage >= 12) && (bNotDead))
		{
			KillCarcass(InstigatedBy, DamageType, HitLocation);
		}
		if (CumulativeDamage >= MaxDamage)
		{
			if (bNotDead) KillCarcass(InstigatedBy, DamageType, HitLocation);
			//MADDERS: Dump our shit instead of just gibbing!
			DumpItemInventory();
			ChunkUp(Damage);
		}
		if (bDecorative)
			Velocity = vect(0,0,0);
	}
	if (DamageType == 'EMP')
	{
		EMPTakenTotal += Damage;
	}
	
	SetScaleGlow();
}

// ----------------------------------------------------------------------
// SetScaleGlow()
//
// sets the scale glow for the carcass, based on damage
// ----------------------------------------------------------------------

function SetScaleGlow()
{
	local float pct;

	// scaleglow based on damage
	pct = FClamp(1.0-float(CumulativeDamage)/MaxDamage, 0.1, 1.0);
	ScaleGlow = pct;
}

function DeusExWeapon GetOwningWeapon(DeusExAmmo A)
{
	local Inventory Inv;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if ((DeusExWeapon(Inv) != None) && (DeusExWeapon(Inv).AmmoType == A))
		{
			return DeusExWeapon(Inv);
		}
	}
	return None;
}

// ----------------------------------------------------------------------
// Frob()
//
// search the body for inventory items and give them to the frobber
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local int ItemsFound;
	
	local DeusExPlayer Player;
	local POVCorpse corpse;
	
	// Can we assume only the *PLAYER* would actually be frobbing carci?
	//------------
	//MADDERS, 10/22/22: Yes. Yes we will.
	Player = DeusExPlayer(Frobber);
	
	// No doublefrobbing in multiplayer.
	if (bQueuedDestroy || !bFrobbable)
		return;
	
	//MADDERS, 6/4/23: Darkness code. Neat.
	if (VMDRejectPickup())
	{
	 	return;
	}
	
	// if we've already been searched, let the player pick us up
	// don't pick up animal carcii
	if (!bAnimalCarcass)
	{
      		// DEUS_EX AMSD Since we don't have animations for carrying corpses, and since it has no real use in multiplayer,
      		// and since the PutInHand propagation doesn't just work, this is work we don't need to do.
      		// Were you to do it, you'd need to check the respawning issue, destroy the POVcorpse it creates and point to the
      		// one in inventory (like I did when giving the player starting inventory).
		if ((((Inventory == None) && (bEverSearched)) || (Abs(LastFrobTime - Level.TimeSeconds) < DoubleFrobTime)) && (player != None) && (player.inHand == None) && (Level.NetMode == NM_Standalone))
		{
			if (!bInvincible)
			{
				corpse = Spawn(class'POVCorpse');
				if (corpse != None)
				{
					Corpse.VMDTransferPOVPropertiesFrom(Self, Corpse);
					
					corpse.Frob(player, None);
					corpse.SetBase(player);
					player.PutInHand(corpse);
					bQueuedDestroy = True;
					Destroy();
					return;
				}
			}
		}
	}
	LastFrobTime = Level.TimeSeconds;
	
	bSearchMsgPrinted = False;
	if (Player != None)
	{
		// Make sure the "Received Items" display is cleared
      		// DEUS_EX AMSD Don't bother displaying in multiplayer.  For propagation
      		// reasons it is a lot more of a hassle than it is worth.
		if ((player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).Hud != None) && (Level.NetMode == NM_Standalone))
		{
			DeusExRootWindow(player.rootWindow).hud.receivedItems.RemoveItems();
		}
		
		if ((Inventory != None) || ((StuckProjectiles[0] != None) && (StuckCount[0] > 0)))
		{
			ItemsFound += LootStuckProjectiles(Player);
			
			UnloadWeapons();
			ReloadWeapons(Player);
			ItemsFound += LootPickups(Player);
			ItemsFound += LootWeaponsAmmo(Player);
		}
		
		if (ItemsFound <= 0)
		{
			Player.ClientMessage(msgEmpty);
		}
	}
	
   	if ((player != None) && (Level.Netmode != NM_Standalone))
   	{
      		player.ClientMessage(Sprintf(msgRecharged, 25));
      		
      		PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
      		
      		player.Energy += 25;
      		if (player.Energy > player.EnergyMax)
         		player.Energy = player.EnergyMax;
   	}
	
	bEverSearched = true;
	
	Super.Frob(Frobber, frobWith);
	
   	if ((Level.Netmode != NM_Standalone) && (Player != None))   
   	{
	   	bQueuedDestroy = true;
	   	Destroy();	  
   	}
}

function bool PlayerOwnsCarcass(DeusExPlayer Player)
{
	local Inventory Inv, PInv;
	
	if (Inventory == None) return false;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.Owner == Player)
		{
			return true;
		}
		else
		{
			for(PInv = Player.Inventory; PInv != None; PInv = PInv.Inventory)
			{
				if (PInv == Inv) return true;
			}
		}
	}
	
	return false;
}

function int LootStuckProjectiles(DeusExPlayer Player)
{
	local int i, Ret;
	
	local Inventory TItem;
	local DeusExAmmo DXA, FindDXA;
	local DeusExWeapon DXW, FindDXW;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (Player == None) return 0;
	
	//MADDERS: Retrieve stuck projectiles, should we have any.
	for (i=0; i<ArrayCount(StuckProjectiles); i++)
	{
		if ((StuckProjectiles[i] != None) && (StuckCount[i] > 0))	// or spawn the ammo
		{
			if (VMP != None)
			{
				VMP.MarkItemClassDiscovered(StuckProjectiles[i]);
			}
			
			TItem = Spawn(StuckProjectiles[i]);
			
			TItem.SetCollision(True, False, False);
			TItem.SetPropertyText("bCorpseUnclog", "True");
			
			DXA = DeusExAmmo(TItem);
			DXW = DeusExWeapon(TItem);
			if (DXA != None)
			{
				FindDXA = DeusExAmmo(Player.FindInventoryType(DXA.Class));
				
				//MADDERS, 12/26/20: Don't add ammo we don't have room for, thanks.
				//MADDERS, 1/19/21: Oops. Give us the ammo if we don't have it yet.
				if (FindDXA == None || FindDXA.AmmoAmount < FindDXA.VMDConfigureMaxAmmo())
				{
					if (!bSearchMsgPrinted)
					{
						player.ClientMessage(msgSearching);
						bSearchMsgPrinted = True;
					}
					
					//AddReceivedItem(Player, DXA, StuckCount[i]);
					
					DXA.AmmoAmount = StuckCount[i];
					DXA.Frob(Player, None);
					StuckCount[i] = 0;
					
					Ret++;
				}
				else
				{
					DXA.Destroy();
				}
			}
			if (DXW != None)
			{
				//MADDERs, 10/22/22: Block icon for a couple of reasons. It's complicated.
				//DXW.VMDHackbReceivedIconBlock = true;
				
				DXW.PickupAmmoCount = StuckCount[i];
				FindDXA = DeusExAmmo(Player.FindInventoryType(DXW.AmmoName));
				FindDXW = DeusExWeapon(Player.FindInventoryType(DXW.Class));
				Player.FrobTarget = DXW;
				Player.ParseRightClick();
				
				if (DXW == None || DXW.bDeleteMe || DXW.Owner == Player || DXW.PickupAmmoCount < StuckCount[i])
				{
					if (!bSearchMsgPrinted)
					{
						player.ClientMessage(msgSearching);
						bSearchMsgPrinted = True;
					}
					
					//MADDERS, 12/26/20: Don't add ammo we don't have room for, thanks.
					if (FindDXA != None)
					{
						//AddReceivedItem(Player, FindDXA, StuckCount[i]);
					}
					else if ((DXW == None || DXW.bDeleteMe) && (FindDXW != None))
					{
						//AddReceivedItem(Player, FindDXW, StuckCount[i]);
					}
					else
					{
						if (DXW.Owner == Player)
						{
							//AddReceivedItem(Player, DXW, StuckCount[i]);
						}
						else
						{
							//AddReceivedItem(Player, DXW, StuckCount[i] - DXW.PickupAmmoCount);
						}
					}
					StuckCount[i] = 0;
					
					Ret++;
				}
				else
				{
					DXW.Destroy();
				}
			}
		}
	}
	
	return Ret;
}

function UnloadWeapons()
{
	local Inventory TItem, NextItem;
	local DeusExWeapon DXW;
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		NextItem = TItem.Inventory;
		
		DXW = DeusExWeapon(TItem);
		if ((DXW != None) && (!DXW.VMDHasJankyAmmo()))
		{
			DXW.PickupAmmoCount = 0;
		}
	}
}

function ReloadWeapons(DeusExPlayer Player)
{
	local int AmmoGive, NumAmmo;
	
	local Inventory TItem, NextItem;
	local DeusExAmmo DXA;
	local DeusExWeapon OwningDXW;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (Player == None) return;
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		NextItem = TItem.Inventory;
		
		DXA = DeusExAmmo(TItem);
		if ((DXA != None) && (DXA.AmmoAmount > 0))
		{
			if (VMP != None)
			{
				VMP.MarkItemDiscovered(DXA);
			}
			
			OwningDXW = FindWeaponOwner(DXA);
			if (OwningDXW != None)
			{
				DetermineWeaponLoadCount(OwningDXW, NumAmmo, VMDBufferPlayer(Player));
			}
			DXA.AmmoAmount = 0;
			DeleteInventory(DXA);
		}
	}
}

function DetermineWeaponLoadCount(DeusExWeapon W, out int NumAmmo, VMDBufferPlayer Player)
{
	local DeusExAmmo ODXA;
	local int AmmoGive, AmmoRetRate, SeedGet, SeedRip;
	
	if (W == None || Player == None) return;
	
	if ((W.bHandToHand) && (!W.bInstantHit) && (W.GoverningSkill == class'SkillDemolition'))
	{
		AmmoGive = 1;
	}
	else
	{
		ODXA = DeusExAmmo(W.AmmoType);
		if (ODXA == None) return;
		
		//MADDERS, 1/3/21: Do this on the static end now.
		AmmoRetRate = Max(3, class'VMDStaticFunctions'.Static.GWARR(W, ODXA, Player));
		
		SeedGet = ((class'VMDStaticFunctions'.Static.DeriveAdvancedActorSeedPreRand(MyPawnSeed, Self, 42, 5, true)+NumAmmo)%42);
		SeedRip = class'VMDStaticFunctions'.Static.RipSeedChunk("Ammo Looting", SeedGet);
		AmmoGive = Min(int((float(SeedRip) * AmmoRetRate) / 20.0), AmmoRetRate);
		AmmoGive += class'VMDStaticFunctions'.Static.GWARAdd(W, Player);
	}
	
	//LastAmmoRand = AmmoGive;
	W.PickupAmmoCount = Clamp(AmmoGive, 1, W.ReloadCount);
	W.ClipCount = Min(W.ReloadCount, W.ReloadCount - W.PickupAmmoCount);
	NumAmmo++;
}

function int LootCredits(DeusExPlayer Player)
{
	local int Ret, TCreds;
	
	local Inventory TItem, NextItem;
	local Credits TCred;
	
	if (Player == None) return 0;
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		//MADDERS, 10/23/22: Oh no. We goofed. Time to farded and shidded.
		if (PlayerPawn(TItem.Owner) != None) break;
		NextItem = TItem.Inventory;
		
		TCred = Credits(TItem);
		if (TCred != None)
		{
			if (!bSearchMsgPrinted)
			{
				player.ClientMessage(msgSearching);
				bSearchMsgPrinted = True;
			}
			
			TCreds = TCred.NumCredits*TCred.NumCopies;
			AddReceivedItem(Player, TItem, TCreds);
			
			Player.Credits += TCreds;
			Player.ClientMessage(Sprintf(TCred.MsgCreditsAdded, TCreds));
			VMDRemoveInventory(TCred, false);
			
			Ret++;
		}
	}
	
	return Ret;
}

function int LootNanoKeys(DeusExPlayer Player)
{
	local int Ret;
	
	local Inventory TItem, NextItem;
	local NanoKey TKey;
	
	if (Player == None) return 0;
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		//MADDERS, 10/23/22: Oh no. We goofed. Time to farded and shidded.
		if (PlayerPawn(TItem.Owner) != None) break;
		NextItem = TItem.Inventory;
		
		TKey = Nanokey(TItem);
		if (TKey != None)
		{
			if (!bSearchMsgPrinted)
			{
				player.ClientMessage(msgSearching);
				bSearchMsgPrinted = True;
			}
			
			Player.PickupNanoKey(TKey);
			AddReceivedItem(Player, TKey, 1);
			VMDRemoveInventory(TKey, False);
			
			Ret++;
		}
	}
	
	return Ret;
}

function int LootPickups(DeusExPlayer Player)
{
	local bool bPickedItemUp;
	local int Ret, ItemCount;
	local float LastCharge;
	
	local Inventory TItem, NextItem;
	local ChargedPickup TCharge;
	local Credits TCred;
	local NanoKey TKey;
	local DeusExPickup DXP, FindPickup;
	local VMDBufferPlayer VMP;
	
	if (Player == None) return 0;
	VMP = VMDBufferPlayer(Player);
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		//MADDERS, 10/23/22: Oh no. We goofed. Time to farded and shidded.
		if (PlayerPawn(TItem.Owner) != None) break;
		NextItem = TItem.Inventory;
		
		TCharge = ChargedPickup(TItem);
		TCred = Credits(TItem);
		TKey = Nanokey(TItem);
		DXP = DeusExPickup(TItem);
		
		//MADDERS, 10/22/22: Don't give feedback on non-pickups.
		bPickedItemUp = (DXP == None);
		
		if (TCred != None)
		{
			bPickedItemUp = true;
			Ret += LootCredits(Player);
		}
		else if (TKey != None)
		{
			bPickedItemUp = true;
			Ret += LootNanokeys(Player);
		}
		else if (DXP != None)
		{
			if (VMP != None)
			{
				VMP.MarkItemDiscovered(DXP);
			}
			
			if (TCharge != None)
			{
				TCharge.VMDSignalCorpseLooting();
				LastCharge = (float(TCharge.Charge) / float(TCharge.Default.Charge));
				LastCharge = (LastCharge * 100.0) + 0.5;
				if (LastCharge <= 2)
				{
					VMDRemoveInventory(TCharge, False);
					continue;
				}
			}
			
			if ((DXP.bCanHaveMultipleCopies) && (Player.FindInventoryType(DXP.Class) != None))
			{
				FindPickup = DeusExPickup(Player.FindInventoryType(DXP.Class));
				ItemCount = DXP.NumCopies;
				
				if ((FindPickup.MaxCopies > 0) && (DXP.NumCopies + FindPickup.NumCopies > FindPickup.VMDConfigureMaxCopies()))
				{
					if ((FindPickup.VMDConfigureMaxCopies() - FindPickup.NumCopies) > 0)
					{
						if (!bSearchMsgPrinted)
						{
							player.ClientMessage(msgSearching);
							bSearchMsgPrinted = True;
						}
						
						ItemCount = (FindPickup.VMDConfigureMaxCopies() - FindPickup.numCopies);
						DXP.NumCopies -= ItemCount;
						FindPickup.NumCopies = FindPickup.VMDConfigureMaxCopies();
						FindPickup.UpdateBeltText();
						Player.ClientMessage(FindPickup.PickupMessage @ FindPickup.itemArticle @ FindPickup.itemName, 'Pickup');
						//AddReceivedItem(Player, FindPickup, ItemCount);
						
						VMDRemoveInventory(DXP, true);
					}
					else if (FindPickup.InvSlotsX <= 90)
					{
						Player.ClientMessage(SprintF(MsgCannotPickup, FindPickup.ItemName));
						VMDRemoveInventory(DXP, true);
					}
				}
				else
				{
					if (!bSearchMsgPrinted)
					{
						player.ClientMessage(msgSearching);
						bSearchMsgPrinted = True;
					}
					
					bPickedItemUp = true;
					
					FindPickup.NumCopies += ItemCount;
					FindPickup.VMDSignalCopiesAdded(FindPickup, DXP);
					FindPickup.UpdateBeltText();
					VMDRemoveInventory(DXP, false);
					
					Player.ClientMessage(FindPickup.PickupMessage @ FindPickup.itemArticle @ FindPickup.itemName, 'Pickup');
					if (TCharge != None)
					{
						AddReceivedItem(Player, FindPickup, LastCharge);
					}
					else
					{
						AddReceivedItem(Player, FindPickup, ItemCount);
					}
				}
			}
			else
			{
				// Transcended - Drop the item on the ground
				if ((VMP != None) && (VMP.GetItemRefusalSetting(DXP) == 2))
				{
					VMP.ClientMessage(SprintF(VMP.ItemRefusedString, DXP.ItemName));
					VMDRemoveInventory(DXP, Level.NetMode == NM_Standalone);
				}
				else if ((VMP != None) && (VMP.VMDConfigureInvSlotsX(DXP) > 90))
				{
					VMP.ClientMessage(Sprintf(VMP.InventoryFullNull, DXP.ItemName));
				}
				else if (!Player.FindInventorySlot(DXP, True))
				{
					Player.ClientMessage(SprintF(Player.InventoryFull, DXP.ItemName, DXP.InvSlotsX, DXP.InvSlotsY));
					VMDRemoveInventory(DXP, Level.NetMode == NM_Standalone);
				}
				else
				{
					if ((Player.Inventory == None || Level.Game.PickupQuery(Player, DXP)))
					{
						Player.FrobTarget = DXP;
						if (Player.HandleItemPickup(DXP))
						{
							if (!bSearchMsgPrinted)
							{
								player.ClientMessage(msgSearching);
								bSearchMsgPrinted = True;
							}
							
							bPickedItemUp = true;
							
						   	DeleteInventory(DXP);
							
						   	// DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
						   	DXP.bInObjectBelt = False;
					   		DXP.BeltPos = -1;
							DXP.SpawnCopy(Player);
							
							// Show the item received in the ReceivedItems window and also 
							// display a line in the Log
							//AddReceivedItem(Player, DXP, 1);
							
							Player.ClientMessage(DXP.PickupMessage @ DXP.ItemArticle @ DXP.ItemName, 'Pickup');
							PlaySound(DXP.PickupSound);
						}
					}
				}
			}
			Ret++;
		}
	}
	
	return Ret;
}

function int LootWeaponsAmmo(DeusExPlayer Player)
{
	local bool bPickedItemUp, bWeaponWasDropped;
	local int Ret, LastAmmoRand;
	local string TName;
	
	local Inventory TItem, NextItem;
	local DeusExWeapon DXW, FindWeapon, LastAddedWeapon;
	local DeusExAmmo TDXA, FindAmmo;
	local VMDBufferPlayer VMP;
	
	if (Player == None || Inventory == None) return 0;
	VMP = VMDBufferPlayer(Player);
	
	for(TItem = Inventory; TItem != None; TItem = NextItem)
	{
		//MADDERS, 10/23/22: Oh no. We goofed. Time to farded and shidded.
		if (PlayerPawn(TItem.Owner) != None) break;
		NextItem = TItem.Inventory;
		
		//Reset vars. Barf.
		bPickedItemUp = False;
		bWeaponWasDropped = False;
		FindAmmo = None;
		FindWeapon = None;
		
		DXW = DeusExWeapon(TItem);
		//MADDERS: Delete LAM's if we never drew them. Nerf for grenadiers.
		//-----------------
		//MADDERS, 7/2/24: No longer delete, just postpone.
		if ((DXW != None) && (DXW.VMDIsWeaponName("LAM") || DXW.VMDIsWeaponName("EMPGrenade")) && (DXW.bHandToHand) && (!DXW.bInstantHit) && (!bEverDrewGrenade) && (VMP == None || !VMP.HasSkillAugment('DemolitionLooting'))) 
		{
			TName = DXW.ItemName;
			if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
			//item.Destroy();
			Player.ClientMessage(SprintF(MsgLayingOnGrenade, TName));
		}
		else if (DXW != None)
		{
			if (VMP != None)
			{
				VMP.MarkItemDiscovered(DXW);
			}
			
			FindWeapon = DeusExWeapon(Player.FindInventoryType(DXW.Class));
			LastAmmoRand = DXW.PickupAmmoCount;
			
			if ((FindWeapon != None) || ((FindWeapon == None) && (!FindAdvancedInventorySlot(Player, DXW, true))))
			{
				if (DXW.PickupAmmoCount > 0 || DXW.VMDIsMeleeWeapon())
				{
					FindAmmo = DeusExAmmo(Player.FindInventoryType(DXW.AmmoName));
					
					if ((FindAmmo != None) && (FindAmmo.AmmoAmount < FindAmmo.VMDConfigureMaxAmmo()) && (!DXW.VMDHasJankyAmmo() || FindWeapon != None))
					{
						if (!bSearchMsgPrinted)
						{
							player.ClientMessage(msgSearching);
							bSearchMsgPrinted = True;
						}
						
                           			FindAmmo.AddAmmo(DXW.PickupAmmoCount);
						
						//MADDERS, 1/19/21: Don't show the same icon twice for grenades and such.
						if (DXW.PickupAmmoCount > 0)
						{
							//if ((FindWeapon != None) && (FindWeapon != LastAddedWeapon || FindWeapon.Icon != FindAmmo.Icon))
							//if (DXW.Icon != FindAmmo.Icon)
							//{
								AddReceivedItem(Player, FindAmmo, DXW.PickupAmmoCount);
							//}
			    			}
						
						// Update the ammo display on the object belt
						Player.UpdateAmmoBeltText(FindAmmo);
						
						if (DXW.PickupAmmoCount > 0)
						{
							// if this is an illegal ammo type, use the weapon name to print the message
							if (FindAmmo.PickupViewMesh == Mesh'TestBox')
							{
								TName = DXW.ItemName;
								if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
								
								Player.ClientMessage(DXW.PickupMessage @ DXW.ItemArticle @ TName @ "("$DXW.PickupAmmoCount$")", 'Pickup');
							}
							else
							{
								TName = FindAmmo.ItemName;
								if (!FindAmmo.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
								
								Player.ClientMessage(FindAmmo.PickupMessage @ FindAmmo.ItemArticle @ TName @ "("$DXW.PickupAmmoCount$")", 'Pickup');
							}
						}
						
						DXW.PickupAmmoCount = 0;
						
						if ((FindWeapon != None) && (DXW.VMDIsMeleeWeapon()))
						{
							if (FindWeapon != None)
							{
								FindWeapon.VMDTransferWeaponMods(DXW, FindWeapon);
							}
							VMDRemoveInventory(DXW, true);
						}
					}
					else
					{
						if (DXW.AmmoName.Default.PickupViewMesh != LodMesh'DeusExItems.TestBox')
						{
							if (class<DeusExAmmo>(DXW.AmmoName) != None)
							{
								TDXA = DeusExAmmo(Spawn(DXW.AmmoName));
								if (TDXA != None)
								{
									TDXA.SetCollision(True, False, False);
									TDXA.bCorpseUnclog = true;
									
                           						TDXA.AmmoAmount = DXW.PickupAmmoCount;
									Player.FrobTarget = TDXA;
									Player.ParseRightClick();
									
									DXW.PickupAmmoCount = -1;
								}
							}
						}
						else if (DXW.InvSlotsX <= 90)
						{
							bWeaponWasDropped = true;
							VMDRemoveInventory(DXW, true);
							
							TName = DXW.ItemName;
							if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
							Player.ClientMessage(SprintF(MsgCannotPickup, TName));
						}
					}
				}
				
				if ((FindWeapon == None) && (!FindAdvancedInventorySlot(Player, DXW, true)))
				{
					// Transcended - Drop the item on the ground
					if ((VMP != None) && (VMP.GetItemRefusalSetting(DXW) == 2))
					{
						TName = DXW.ItemName;
						if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
						
						VMP.ClientMessage(Sprintf(VMP.ItemRefusedString, TName));
						VMDRemoveInventory(DXW, Level.Netmode == NM_Standalone);
					}
					else
					{
						//MADDERS: Hack for commando gun message.
						if ((VMP != None) && (VMP.VMDConfigureInvSlotsX(DXW) > 90))
						{
							TName = DXW.ItemName;
							if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
							
							VMP.ClientMessage(Sprintf(VMP.InventoryFullNull, TName));
						}
						else
						{
							if (VMP != None)
							{
								TName = DXW.ItemName;
								if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
								
								VMP.ClientMessage(SprintF(VMP.InventoryFullFeedback, TName, VMP.VMDConfigureInvSlotsX(DXW), VMP.VMDConfigureInvSlotsY(DXW)));
							}
							else if (DXW != None)
							{
								TName = DXW.ItemName;
								if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
								
								VMP.ClientMessage(SprintF(Player.InventoryFull, TName));
							}
							
							VMDRemoveInventory(DXW, true);
						}
					}
				}
				
				// Only destroy the weapon if the player already has it.
				if ((FindWeapon != None) && (!bWeaponWasDropped) && (DXW.InvSlotsX <= 90))
				{
					if (DXW != None && (DXW.VMDIsMeleeWeapon() || DXW.VMDIsWeaponName("LAW")))
					{
						TName = DXW.ItemName;
						if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
						
						Player.ClientMessage(SprintF(MsgCannotPickup, TName));
						VMDRemoveInventory(DXW, true);
					}
					else
					{
						if (FindWeapon != None)
						{
							FindWeapon.VMDTransferWeaponMods(DXW, FindWeapon);
						}
						VMDRemoveInventory(DXW, false);
					}
				}
				
				Ret++;
				bPickedItemUp = True;
			}
			
			if (!bPickedItemUp)
			{
				// check if the pawn is allowed to pick this up
				if ((Player.Inventory == None || Level.Game.PickupQuery(Player, DXW)))
				{
					Ret++;
					Player.FrobTarget = DXW;
					if (Player.HandleItemPickup(DXW))
					{
						if (!bSearchMsgPrinted)
						{
							player.ClientMessage(msgSearching);
							bSearchMsgPrinted = True;
						}
						
						bPickedItemUp = true;
						
						DeleteInventory(DXW);
						
                           			// DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
                           			DXW.bInObjectBelt = False;
                           			DXW.BeltPos = -1;
						
                           			DXW.SpawnCopy(Player);
						
						// Show the item received in the ReceivedItems window and also 
						// display a line in the Log
						if (LastAmmoRand < 1 || DXW.AmmoType == None || DXW.AmmoType.Icon != DXW.Icon)
						{
							//AddReceivedItem(Player, DXW, 1);
						}
						LastAddedWeapon = DXW;
						DXW.VMDSignalPickupUpdate();
						
						TName = DXW.ItemName;
						if (!DXW.bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
						
						Player.ClientMessage(DXW.PickupMessage @ DXW.ItemArticle @ TName, 'Pickup');
						PlaySound(DXW.PickupSound);
					}
				}
			}
		}
	}
	
	return Ret;
}

function bool VMDRemoveInventory(Inventory TInv, bool bDrop)
{
	local bool bDropWon;
	local int TAmmoCount;
	local vector TLoc;
	local DeusExAmmo DXA;
	local DeusExPickup DXP;
	local DeusExWeapon DXW;
	
	if (TInv == None) return false;
	if (Pawn(TInv.Owner) != None)
	{
		DeleteInventory(TInv);
		return true;
	}
	
	//MADDERS, 10/22/22: Deletion is deletion. Just fucking go for it.
	if (!bDrop)
	{
		DeleteInventory(TInv);
		
		bDropWon = true;
		TInv.Destroy();
	}
	
	//MADDERS, 10/22/22: Attempt proprietary drop from functionality. If it fails, don't remove from inventory.
	else
	{
		DXA = DeusExAmmo(TInv);
		DXP = DeusExPickup(TInv);
		DXW = DeusExWeapon(TInv);
		
		TLoc = Location;
		if (DXW == None)
		{
			TLoc.X = Location.X + (FRand() * CollisionRadius);
			TLoc.Y = Location.Y + (FRand() * CollisionRadius);
		}
		TLoc.Z -= CollisionHeight;
		TLoc.Z += TInv.CollisionHeight + 1;
		
		//MADDERS, 8/7/23: I'm lazy. Sue me.
		TInv.SetPropertyText("bCorpseUnclog", "True");
		if (DXA != None)
		{
			bDropWon = DXA.VMDDropFrom(TLoc, true);
		}
		if (DXP != None)
		{
			bDropWon = DXP.VMDDropFrom(TLoc, true);
		}
		if (DXW != None)
		{
			TAmmoCount = Max(0, DXW.PickupAmmoCount);
			bDropWon = DXW.VMDDropFrom(TLoc, true);
		}
		else
		{
			bDropWon = true; //Nothing else we can do. Aight.
		}
		
		if (bDropWon)
		{
			DeleteInventory(TInv);
			
			TInv.DropFrom(TLoc);
			
			if (DXW != None)
			{
				DXW.PickupAmmoCount = TAmmoCount;
				DXW.ClipCount = Min(DXW.ReloadCount, DXW.ReloadCount - DXW.PickupAmmoCount);
			}
		}
	}
	
	return bDropWon;
}

function bool FindAdvancedInventorySlot(DeusExPlayer Play, Inventory I, bool bSO)
{
	local bool bWin;
	local DeusExPickup DXP;
	local DeusEXWeapon DXW;
	
	DXP = DeusExPickup(I);
	DXW = DeusExWeapon(I);
	
	bWin = Play.FindInventorySlot(I, bSO);
	if (!bWin)
	{
		if ((DXP != None) && (DXP.bCanRotateInInventory))
		{
			DXP.bRotatedInInventory = !DXP.bRotatedInInventory;
			bWin = Play.FindInventorySlot(I, bSO);
		}
		else if ((DXW != None) && (DXW.bCanRotateInInventory))
		{
			DXW.bRotatedInInventory = !DXW.bRotatedInInventory;
			bWin = Play.FindInventorySlot(I, bSO);
		}
	}
	
	if (!bWin)
	{
		if (DXP != None) DXP.bRotatedInInventory = !DXP.bRotatedInInventory;
		if (DXW != None) DXW.bRotatedInInventory = !DXW.bRotatedInInventory;
	}
	
	return bWin;
}

//MADDERS: Limit certain items from displaying pickup icons!
function bool IsDisplayException( Inventory Inv )
{
 	return false;
}

// ----------------------------------------------------------------------
// AddReceivedItem()
// ----------------------------------------------------------------------

function AddReceivedItem(DeusExPlayer player, Inventory item, int count)
{
	local DeusExWeapon w;
	local Inventory altAmmo;
	
	if (IsDisplayException(Item)) return;
	
	if (!bSearchMsgPrinted)
	{
		player.ClientMessage(msgSearching);
		bSearchMsgPrinted = True;
	}
	
	DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(item, Count);
	
	// Make sure the object belt is updated
	if (item.IsA('Ammo'))
		player.UpdateAmmoBeltText(Ammo(item));
	else
		player.UpdateBeltText(item);
	
	// Deny 20mm and WP rockets off of bodies in multiplayer
	if ( Level.NetMode != NM_Standalone )
	{
		if ( item.IsA('WeaponAssaultGun') || item.IsA('WeaponGEPGun') )
		{
			w = DeusExWeapon(player.FindInventoryType(item.Class));
			if (( Ammo20mm(w.AmmoType) != None ) || ( AmmoRocketWP(w.AmmoType) != None ))
			{
				altAmmo = Spawn( w.AmmoNames[0] );
				DeusExAmmo(altAmmo).AmmoAmount = w.PickupAmmoCount;
				altAmmo.Frob(player,None);
				altAmmo.Destroy();
				w.AmmoType.Destroy();
				w.LoadAmmo( 0 );
			}
		}
	}
}

// ----------------------------------------------------------------------
// AddInventory()
//
// copied from Engine.Pawn
// Add Item to this carcasses inventory. 
// Returns true if successfully added, false if not.
// ----------------------------------------------------------------------

function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	
	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == NewItem )
			return false;
	
	// The item should not have been destroyed if we get here.
	assert(NewItem!=None);
	
	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	NewItem.InitialState = 'Idle2';
	
	//MADDERS, 8/17/24: Shove this near us for corpse looting consistency.
	NewItem.SetLocation(Location);
	Inventory = NewItem;
	
	VMDUpdateMassBuoyancy();
	
	return true;
}

// ----------------------------------------------------------------------
// DeleteInventory()
// 
// copied from Engine.Pawn
// Remove Item from this pawn's inventory, if it exists.
// Returns true if it existed and was deleted, false if it did not exist.
// ----------------------------------------------------------------------

function bool DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;
	
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			break;
		}
	}
   	Item.SetOwner(None);
	
	VMDUpdateMassBuoyancy();
}

// ----------------------------------------------------------------------
// auto state Dead
// ----------------------------------------------------------------------

auto state Dead
{
	function Timer()
	{
		// overrides goddamned lifespan crap
      		// DEUS_EX AMSD In multiplayer, we want corpses to have lifespans.  
      		if (Level.NetMode == NM_Standalone)		
         		Global.Timer();
      		else
         		Super.Timer();
	}

	function HandleLanding()
	{
		local Vector HitLocation, HitNormal, EndTrace;
		local Actor hit;
		local BloodPool Pool;
		
		if ((!bNotDead) && (!bHidden))
		{
			// trace down about 20 feet if we're not in water
			if (!Region.Zone.bWaterZone)
			{
				EndTrace = Location - vect(0,0,320);
				hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
            			if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
            			{
               				Pool = None;
           			}
            			else
            			{
               				Pool = spawn(class'BloodPool',,, HitLocation+HitNormal, Rotator(HitNormal));
            			}
				if (Pool != None)
					Pool.maxDrawScale = CollisionRadius / 40.0;
			}
			
			// alert NPCs that I'm food
			AIStartEvent('Food', EAITYPE_Visual);
		}
		
		// by default, the collision radius is small so there won't be as
		// many problems spawning carcii
		// expand the collision radius back to where it's supposed to be
		// don't change animal carcass collisions
		if (!bAnimalCarcass)
		{
			if (ChildMaleCarcass(Self) != None || ChildMale2Carcass(Self) != None)
			{
				SetCollisionSize(32.0, Default.CollisionHeight);
			}
			else
			{
				SetCollisionSize(40.0, Default.CollisionHeight);
			}
		}
		
		// alert NPCs that I'm really disgusting
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}

Begin:
	while (Physics == PHYS_Falling)
	{
		Sleep(1.0);
	}
	HandleLanding();
}

//MADDERS: Make corpses take fall damage. Courtesy of Lork.
function Landed(vector HitNormal)
{
    	Super.Landed(HitNormal);
	
	AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 96);
	
    	if (Velocity.Z < -1500)
	{
        	TakeDamage(500, None, Location, Velocity, 'Exploded');
	}
    	else if (Velocity.Z < -1000)
	{
        	TakeDamage(50, None, Location, Velocity, 'Shot');
	}
    	else if (Velocity.Z < -500)
	{
        	TakeDamage(5, None, Location, Velocity, 'Shot');
	}
}

//MADDERS: Murder this mo fugga if he takes lethal damage.
function KillCarcass(pawn Killer, name damageType, vector HitLocation)
{
	local Name PersonalFlag;
	local Vector HitLocation2, HitNormal, EndTrace;
	local Actor hit;
	local BloodPool pool;
	local DeusExPlayer P;
	local VMDBufferPlayer VMP;
	
	bNotDead = False;
	
	P = DeusExPlayer(GetPlayerPawn());
	VMP = VMDBufferPlayer(P);
	
	if (bMayhemSuspect)
	{
		if (VMP != None)
		{
			VMP.OwedMayhemFactor += VMP.MayhemKilledValue;
			if (bMayhemPayback) VMP.OwedMayhemFactor += VMP.MayhemLivingValue;
			
			if (AIGetLightLevel(Location) < 0.01)
			{
				VMP.OwedMayhemFactor -= VMP.MayhemDarknessValue;
			}
		}
	}
	
	if (IsA('ScubaDiverCarcass'))
		AmbientSound = None;		// Stop breathing
	
	//Set some flags.
	if ((P != None) && (bImportant) && (FlagName != ""))
	{
		PersonalFlag = P.RootWindow.StringToName(FlagName$"_Dead");
		P.FlagBase.SetBool(PersonalFlag, True);
		P.FlagBase.SetExpiration(PersonalFlag, FLAG_Bool, 0);
		PersonalFlag = P.RootWindow.StringToName(FlagName$"_Unconscious");
		P.FlagBase.DeleteFlag(PersonalFlag, FLAG_Bool);
	}
	
	//Update our name.
	if (StoredFamiliarName != "")
	{
		itemName = Default.itemName@"("$StoredFamiliarName$")";
	}
	else
	{
		itemName = Default.itemName;
	}
	
	//Spawn a blood pool.
	if (!Region.Zone.bWaterZone)
	{
		EndTrace = Location - vect(0,0,320);
		hit = Trace(HitLocation2, HitNormal, EndTrace, Location, False);
		
		Pool = spawn(class'BloodPool',,, HitLocation2+HitNormal, Rotator(HitNormal));
		if (Pool != None)
		{
			Pool.maxDrawScale = CollisionRadius / 40.0; //MADDERS: Used to be 640. Oops.
		}
	}
	
	//Spoiler alert: I'm edible.
	if (!bInvincible)
	{
		AIStartEvent('Food', EAITYPE_Visual);
	}
	
	//MADDERS, 1/9/21: Explode MIBS and such on death.
	if ((bExplosive) && (EMPTakenTotal < 75))
	{
		Explode();
		
		if (VMP != None)
		{
			VMP.OwedMayhemFactor += VMP.MayhemGibbingValue;
		}
		Destroy();
	}
}

function bool VMDRejectPickup()
{
	//MADDERS: Do this if we're in the dark, as to identify us.
	if ((bEverNotFrobbed) && (AIGETLIGHTLEVEL(Location) <= 0.005))
	{
	 	bEverNotFrobbed = false;
	 	return true;
	}
	bEverNotFrobbed = false;
	return false;
}

function VMDUpdateMassBuoyancy()
{
	local int WepCount;
	local DeusExAmmo DXA;
	local DeusExPickup DXP;
	local DeusExWeapon DXW;
	local Inventory TInv;
	
	if (Inventory == None) return;
	
	Mass = BaseMass;
	Buoyancy = Mass * 1.2;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	
	for (TInv = Inventory; TInv != None; TInv = TInv.Inventory)
	{
		DXA = DeusExAmmo(TInv);
		DXP = DeusExPickup(TInv);
		DXW = DeusExWeapon(TInv);
		
		if (DXA != None)
		{
			//Mass += TInv.Mass * FMax(1.0, DXA.AmmoAmount / DXA.Default.AmmoAmount);
			//Buoyancy += TInv.Buoyancy * FMax(1.0, DXA.AmmoAmount / DXA.Default.AmmoAmount);
		}
		else if (DXP != None)
		{
			Mass += TInv.Mass * Max(1, DXP.NumCopies);
			Buoyancy += TInv.Buoyancy * Max(1, DXP.NumCopies);
		}
		else if ((DXW != None) && (!DXW.VMDHasJankyAmmo()))
		{
			WepCount++;
			Mass += TInv.Mass;
			Buoyancy += TInv.Buoyancy;
		}
		else
		{
			Mass += TInv.Mass;
			Buoyancy += TInv.Buoyancy;
		}
	}
	
	if (WepCount > 0)
	{
		for (TInv = Inventory; TInv != None; TInv = TInv.Inventory)
		{
			DXA = DeusExAmmo(TInv);
			if (DXA != None)
			{
				Mass += TInv.Mass * FMax(1.0, DXA.AmmoAmount / DXA.Default.AmmoAmount);
				Buoyancy += TInv.Buoyancy * FMax(1.0, DXA.AmmoAmount / DXA.Default.AmmoAmount);
			}
		}
	}
	
	//MADDERS, 8/28/23: If we're in water, start shedding guns. Almost forgot the water part...
	if ((Mass > Buoyancy) && (WepCount > 0) && (Region.Zone.bWaterZone))
	{
		VMDJetisonWeapons();
	}
}

function VMDJetisonWeapons()
{
	local float MostNetMass, NetMass;
	local DeusExWeapon DXW, Best;
	local Inventory TInv;
	
	MostNetMass = -99999;
	for (TInv = Inventory; TInv != None; TInv = TInv.Inventory)
	{
		DXW = DeusExWeapon(TInv);
		if ((DXW != None) && (!DXW.VMDHasJankyAmmo()))
		{
			NetMass = DXW.Mass - DXW.Buoyancy;
			if (NetMass > MostNetMass)
			{
				Best = DXW;
				MostNetMass = NetMass;
			}
		}
	}
	
	if (Best != None)
	{
		VMDRemoveInventory(Best, true);
		VMDUpdateMassBuoyancy();
	}
}

function bool VMDHasInventory( Inventory TestItem )
{
	local Inventory TInv;
	
	for(TInv = Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if (TInv == TestItem)
		{
			return true;
		}
	}
	
	return false;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function HandleLanding();
function CheckZoneCarcasses();
function AddFliesAndRats();

defaultproperties
{
     MsgTimeTraveller="You know better than to invoke a time paradox... Let's just not."
     MsgLayingOnGrenade="You are unable to safely retrieve the %s"
     
     //MADDERS additions.
     SmellCooldown=7.500000
     SmellSeconds=-500
     DoubleFrobTime=0.650000
     LastFrobTime=-500
     bFrobbable=True
     bEverNotFrobbed=true
     
     bHighlight=True
     msgSearching="You found:"
     msgEmpty="You don't find anything"
     msgNotDead="Unconscious"
     msgAnimalCarcass="Animal Carcass"
     msgCannotPickup="You cannot pickup the %s"
     msgRecharged="Recharged %d points"
     ItemName="Dead Body"
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
     CollisionRadius=20.000000
     CollisionHeight=7.000000
     bCollideWorld=False
     Mass=150.000000
     Buoyancy=170.000000
     BindName="DeadBody"
     bVisionImportant=True
}
