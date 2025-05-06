//=============================================================================
// POVCorpse.
//=============================================================================
class POVCorpse extends DeusExPickup;

var travel String carcClassString;
var travel String KillerBindName;
var travel Name   KillerAlliance;
var travel Name   Alliance;
var travel bool   bNotDead;
var travel bool   bEmitCarcass;
var travel int    CumulativeDamage, EMPTakenTotal;
var travel int    MaxDamage;
var travel string CorpseItemName;
var travel Name   CarcassName;

//MADDERS ADDITIONS!
var travel Inventory SavedInventory;
var float SmellTimer;
var travel float StoredSize;

var travel string StoredSkins[8];
var travel string StoredMesh[3];

var travel bool bImportant, bInvincible;
var travel string StoredFamiliarName, FlagName;

var travel bool bBlockDamageTaken, bExplosive;

var travel byte StoredFatness;
var travel float StoredDrawScale;

var travel float BaseMass;

//DXT STUFF!
var travel Name TravelTag;

//MAYHEM STUFF!
var travel bool bMayhemSuspect, bMayhemPayback;

//MADDERS, 12/2/23: Left handed stuff? Based.
var() Mesh LeftPlayerViewMesh;

//MADDERS, 6/10/22: BARF! Inventory is being forcibly merged on travel. Not sure why.
//It's not THAT important our items stay, so just torch the whole damned mess.
function VMDPreTravel()
{
	local Inventory TInv, CountedInv[64];
	local int i, InvCount;
	
	if (SavedInventory != None)
	{
		for(TInv = SavedInventory; TInv != None && InvCount < ArrayCount(CountedInv); TInv = TInv.Inventory)
		{
			CountedInv[InvCount++] = TInv;
		}
		
		for (i=InvCount-1; i>= 0; i--)
		{
			if (CountedInv[i] != None)
			{
				CountedInv[i].Destroy();
			}
		}
	}
	
	Super.VMDPreTravel();
}

//MADDERS: Carrying corpses around adds awful smell. Yikes.
function Tick(float DT)
{
	local int THand;
	local Mesh TMesh;
	local VMDBufferPlayer VPlayer;
	
	Super.Tick(DT);
	
	if ((!bDeleteMe) && (DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).InHand != Self))
	{
		Destroy();
		return;
	}
	
	if (SmellTimer > 0)
	{
		SmellTimer -= DT;
	}
 	else if ((!bNotDead) && (VMDBufferPlayer(Owner) != None))
 	{
		SmellTimer = 2.00;
		VMDBufferPlayer(Owner).BloodSmellLevel += 5; //5 seconds to wear off
 	}
	
	//We have drowned. Oops.
	if ((Owner != None) && (Owner.Region.Zone.bWaterzone))
	{
		if (bNotDead)
		{
			KillCarcass(None, 'Drowned', Location);
		}
	}
	
	VPlayer = VMDBufferPlayer(Owner);
	
	if (VPlayer != None)
	{
		if ((VPlayer.InHand == Self) && (Mesh == PlayerViewMesh || Mesh == LeftPlayerViewMesh))
		{
			TMesh = VPlayer.GetHandednessPlayerMesh(THand);
			THand = GetHandType(THand);
			
			if ((Mesh == PlayerViewMesh) && (LeftPlayerViewMesh != None) && (THand == 1))
			{
				Mesh = LeftPlayerViewMesh;
				SetHand(THand);
			}
			else if ((Mesh == LeftPlayerViewMesh) && (PlayerViewMesh != None) && (THand != 1))
			{
				Mesh = PlayerViewMesh;
				SetHand(THand);
			}
			
			if (VPlayer.Mesh != TMesh)
			{
				VPlayer.Mesh = TMesh;
				VPlayer.LastMeshHandedness = THand;
			}
		}
	}
}

//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	local DeusExPlayer DXP;
	local float Ret, SpecMult;
	
	Ret = 1.0;
	DXP = DeusExPlayer(Owner);
	
	if (DXP == None) return Ret;
	
	//MADDERS: Absorb damage passively
	switch(DT)
	{
		case 'Shot':
		case 'AutoShot':
			SpecMult = 0.6;
		break;
		case 'Sabot':
		case 'Exploded':
			SpecMult = 0.8;
		break;
		default:
		 	return 1.0;
		break;
	}
	Ret *= SpecMult;
	
	return Ret;
}

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
	local float SkillValue;
	local VMDBufferPlayer VMP;
	
	//MADDERS: Don't do this for now.
	if (bCheckOnly || PlayerPawn(Owner) == None || bBlockDamageTaken) return;
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	switch(DamageType)
	{
		case 'Shot':
		case 'AutoShot':
		case 'Sabot':
		case 'Exploded':
			CumulativeDamage += Damage;
		break;
		case 'EMP':
			EMPTakenTotal += Damage;
		break;
	}
	
	if (!bInvincible)
	{
		if (CumulativeDamage >= 25)
		{
			if (bNotDead)
			{
				KillCarcass(None, DamageType, HitLocation);
			}
		}
		if (CumulativeDamage >= MaxDamage)
		{
			if (bNotDead)
			{
				KillCarcass(None, DamageType, HitLocation);
			}
			ChunkUp(Damage);
			
			if (VMP != None)
			{
				VMP.OwedMayhemFactor += VMP.MayhemGibbingValue;
			}
			Destroy();
		}
	}
}

function Explode()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;
	
	bBlockDamageTaken = True;
	
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
	
	P = DeusExPlayer(getPlayerPawn());
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
	
	//Set some flags.
	if ((bImportant) && (FlagName != ""))
	{
		PersonalFlag = P.RootWindow.StringToName(FlagName$"_Dead");
		P.FlagBase.SetBool(PersonalFlag, True);
		P.FlagBase.SetExpiration(PersonalFlag, FLAG_Bool, 0);
		PersonalFlag = P.RootWindow.StringToName(FlagName$"_Unconscious");
		P.FlagBase.DeleteFlag(PersonalFlag, FLAG_Bool);
	}
	
	//Update our name.
	ItemName = Default.ItemName@"("$StoredFamiliarName$")";	
	
	//Spawn a blood pool.
	if (!Region.Zone.bWaterZone)
	{
		EndTrace = Location - vect(0,0,320);
		hit = Trace(HitLocation2, HitNormal, EndTrace, Location, False);
		
		Pool = spawn(class'BloodPool',,, HitLocation2+HitNormal, Rotator(HitNormal));
		if (Pool != None)
		{
			Pool.maxDrawScale = CollisionRadius / 640.0;
		}
	}
	
	//Spoiler alert: I'm edible.
	if (!bInvincible)
	{
		AIStartEvent('Food', EAITYPE_Visual);
	}
	
	//MADDERS, 1/9/21: Explode MIBS and such on death.
	if ((bExplosive) && (EMPTakenTotal < 50))
	{
		Explode();
		
		if (VMP != None)
		{
			VMP.OwedMayhemFactor += VMP.MayhemGibbingValue;
		}
		Destroy();
	}
}

function ChunkUp(int Damage)
{
	local int i;
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
	
	if (StoredSize > 10.0)
	{
		for (i=0; i<StoredSize/4.0; i++)
		{
			Loc.X = (1-2*FRand()) * CollisionRadius;
			Loc.Y = (1-2*FRand()) * CollisionRadius;
			Loc.Z = (1-2*FRand()) * CollisionHeight;
			
			if (Owner != None)
			{
				Loc += Owner.Location;
			}
			else
			{
				Loc += Location;
			}
			
			Chunk = spawn(class'FleshFragment', None,, loc);
			if (Chunk != None)
			{
				Chunk.DrawScale = StoredSize / 25;
				Chunk.SetCollisionSize(Chunk.CollisionRadius / Chunk.DrawScale, Chunk.CollisionHeight / Chunk.DrawScale);
				Chunk.bFixedRotationDir = True;
				Chunk.RotationRate = RotRand(False);
			}
		}
	}
}

//MADDERS: Use render of overlays to show JC hands.
simulated event RenderOverlays( Canvas Can )
{
 	local Texture TTex;
 	
 	//Object load annoying. Do this instead.
 	if (DeusExPlayer(Owner) != None)
 	{
 	 	switch (DeusExPlayer(Owner).PlayerSkin)
  		{
   			case 0:
    				TTex = Texture'NewHand01';
   			break;
   			case 1:
    				TTex = Texture'NewHand02';
   			break;
   			case 2:
    				TTex = Texture'NewHand03';
   			break;
   			case 3:
    				TTex = Texture'NewHand04';
   			break;
   			case 4:
    				TTex = Texture'NewHand05';
   			break;
  		}
  		
  		MultiSkins[1] = TTex;
  		Super.RenderOverlays(Can);
  		
  		MultiSkins[1] = Default.Multiskins[1];
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

//MADDERS, 1/10/21: I'm tired off running around 2 different classes, one of which is scarcely related,
//to flip properties between these two. Every time I'm adding a new prop, I'll just 2 lines in here.
//About fucking time. 
function VMDTransferPOVPropertiesTo(DeusExCarcass Carc, POVCorpse POV)
{
	local int i;
	local Inventory Inv;
	
	if ((Carc != None) && (POV != None))
	{
		//MADDERS: Chain our inventory of shit!
		carc.Inventory = POV.SavedInventory;
		for (Inv=POV.SavedInventory; Inv != None; Inv = Inv.Inventory)
		{
			Inv.SetOwner(Carc);
		}
		
		//MADDERS: If we were carrying it, it definitely has been frobbed before.
		Carc.bEverNotFrobbed = false;
		
		carc.Mesh = carc.Mesh2;
		carc.KillerAlliance = POV.KillerAlliance;
		carc.KillerBindName = POV.KillerBindName;
		carc.Alliance = POV.Alliance;
		carc.bNotDead = POV.bNotDead;
		
		carc.bEmitCarcass = POV.bEmitCarcass;
		carc.CumulativeDamage = POV.CumulativeDamage;
		Carc.EMPTakenTotal = POV.EMPTakenTotal;
		carc.MaxDamage = POV.MaxDamage;
		carc.itemName = POV.CorpseItemName;
		carc.CarcassName = POV.CarcassName;
		Carc.DrawScale = StoredDrawScale;
		carc.Fatness = StoredFatness;
		carc.bHidden = False;
		carc.SetPhysics(PHYS_Falling);
		carc.SetScaleGlow();
		
		//MADDERS: Load stored skin data, if we have any.
		if (POV.StoredMesh[0] != "")
		{
			Carc.Mesh = Mesh(DynamicLoadObject(POV.StoredMesh[0], class'Mesh', true));
			Carc.Mesh2 = Mesh(DynamicLoadObject(POV.StoredMesh[1], class'Mesh', true));
			Carc.Mesh3 = Mesh(DynamicLoadObject(POV.StoredMesh[2], class'Mesh', true));
			Carc.Mesh = Carc.Mesh2;
		  	
			for (i=0; i<8; i++)
			{
				Carc.Multiskins[i] = Texture(DynamicLoadObject(POV.StoredSkins[i], class'Texture', true));
				if (Carc.Multiskins[i] == None)
				{
					Carc.Multiskins[i] = WetTexture(DynamicLoadObject(POV.StoredSkins[i], class'WetTexture', true));
				}
			}
		}
		Carc.bExplosive = POV.bExplosive;
		Carc.bInvincible = POV.bInvincible;
		Carc.bImportant = POV.bImportant;
		Carc.StoredFamiliarName = POV.StoredFamiliarName;
		Carc.FlagName = POV.FlagName;
		
		Carc.BaseMass = POV.BaseMass;
		Carc.VMDUpdateMassBuoyancy();
		
		if (!POV.bNotDead)
		{
			if ((Carc.ItemName != "") && (Carc.StoredFamiliarName != ""))
			{
				Carc.ItemName = Carc.Default.ItemName@"("$Carc.StoredFamiliarName$")";
			}
			else
			{
				Carc.ItemName = Carc.Default.ItemName;
			}
		}
		
		//MADDERS, 1/30/21: Don't bother us with this shit, thanks.
		Carc.bEverSearched = True;
		
		Carc.bMayhemSuspect = POV.bMayhemSuspect;
		Carc.bMayhemPayback = POV.bMayhemPayback;
	}
}

function VMDTransferPOVPropertiesFrom(DeusExCarcass Carc, POVCorpse POV)
{
	local int i;
	local Inventory Inv;
	
	if ((Carc != None) && (POV != None))
	{
		POV.SavedInventory = Carc.Inventory;
		for (Inv=Carc.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			Inv.SetOwner(POV);
		}
		
		// destroy the actual carcass and put the fake one
		// in the player's hands
		POV.carcClassString = String(Carc.Class);
		POV.KillerAlliance = Carc.KillerAlliance;
		POV.KillerBindName = Carc.KillerBindName;
		POV.Alliance = Carc.Alliance;
		POV.bNotDead = Carc.bNotDead;
		POV.bEmitCarcass = Carc.bEmitCarcass;
		POV.CumulativeDamage = Carc.CumulativeDamage;
		POV.EMPTakenTotal = Carc.EMPTakenTotal;
		POV.MaxDamage = Carc.MaxDamage;
		POV.CorpseItemName = Carc.itemName;
		POV.CarcassName = Carc.CarcassName;
		POV.StoredDrawScale = Carc.DrawScale;
		POV.StoredFatness = Carc.Fatness;
		
		//MADDERS: Store this for later, for gib related hijinks.
		POV.StoredSize = (Carc.CollisionRadius + Carc.CollisionHeight) / 2;
		POV.bImportant = Carc.bImportant;
		POV.StoredFamiliarName = Carc.StoredFamiliarName;
		POV.bInvincible = Carc.bInvincible;
		POV.FlagName = Carc.FlagName;
		POV.StoredMesh[0] = string(Carc.Mesh);
		POV.StoredMesh[1] = string(Carc.Mesh2);
		POV.StoredMesh[2] = string(Carc.Mesh3);
		POV.bExplosive = Carc.bExplosive;
		for (i=0; i<8; i++)
		{
			POV.StoredSkins[i] = string(Carc.Multiskins[i]);
		}
		
		POV.BaseMass = Carc.BaseMass;
		
		POV.bMayhemSuspect = Carc.bMayhemSuspect;
		POV.bMayhemPayback = Carc.bMayhemPayback;
	}
}

// Update the client numbers in multiplayer
simulated function ClientSetHandedness( float Hand )
{
	setHand(Hand);
}

// set which hand is holding weapon
simulated function setHand( float Hand )
{
	local int THand;
	
	if (VMDBufferPlayer(Owner) != None) VMDBufferPlayer(Owner).GetHandednessPlayerMesh(THand);
	THand = GetHandType(THand);
	Hand = THand;
	
	if (Hand == 2)
	{
		PlayerViewOffset.Y = 0;
		return;
	}
	
	//MADDERS, 6/1/23: Please note that our offsets were not built with handedness of -1 in mind, so invert what we'd normally do for Y.
	if (Hand == 0)
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = 0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * -Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	}
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

function int GetHandType(optional int OverrideHand)
{
	local int Ret;
	local DeusExPlayer DXP;
	local VMDBufferPlayer VMP;
	
	DXP = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Owner);
	
	Ret = -1;
	if (OverrideHand != 0) Ret = OverrideHand;
	
	if (DXP != None)
	{
		if (OverrideHand == 0)
		{
			Ret = DXP.Handedness;
		}
		if ((Ret == 1) && (LeftPlayerViewMesh == None))
		{
			Ret = -1;
		}
		
		if (VMP != None)
		{
			if ((LeftPlayerViewMesh != None) && (Ret == -1) && (VMP.HealthArmRight < 1) && (VMP.HealthArmLeft > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = 1;
			}
			else if ((PlayerViewMesh != None) && (Ret == 1) && (VMP.HealthArmLeft < 1) && (VMP.HealthArmRight > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = -1;
			}
		}
	}
	
	return Ret;
}

defaultproperties
{
     MaxDamage=10
     bDisplayableInv=False
     ItemName="body"
     // PlayerViewOffset=(X=20.000000,Y=12.000000,Z=-5.000000)
     PlayerViewOffset=(X=20.000000,Y=14.000000,Z=-5.000000)
     PlayerViewMesh=LodMesh'DeusExItems.POVCorpse'
     LeftPlayerViewMesh=LodMesh'POVCorpseLeft'
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     LandSound=Sound'DeusExSounds.Generic.FleshHit1'
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Mass=40.000000
     Buoyancy=30.000000
}
