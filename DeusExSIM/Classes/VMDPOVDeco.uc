//=============================================================================
// VMDPOVDeco.
//=============================================================================
class VMDPOVDeco extends DeusExPickup;

var travel string DecoClassString;

//111111111111111111111111111111111111
//Actor Variables
var travel bool StoredbBlockSight, StoredbUnlit,
		StoredbCollideActors, StoredbCollideWorld, StoredbBlockActors, StoredbBlockPlayers, StoredbProjTarget,
		StoredbSpecialLit;
var travel byte StoredSoundRadius, StoredSoundVolume, StoredSoundPitch,
		StoredLightBrightness, StoredLightHue, StoredLightSaturation, StoredLightRadius, StoredLightPeriod,
			StoredLightPhase, StoredLightCone, StoredVolumeBrightness, StoredVolumeRadius, StoredVolumeFog;
var travel float StoredTransientSoundVolume, StoredTransientSoundRadius,
			StoredCollisionHeight, StoredCollisionRadius,
			StoredMass, StoredBuoyancy;
var travel name StoredEvent, StoredTag;
var travel string StoredMesh, StoredMultiskins[8], StoredSkin, StoredTexture, StoredAmbientSound,
			StoredBindName, StoredBarkBindName, StoredFamiliarName, StoredUnfamiliarName;

var travel ELightType StoredLightType;
var travel ELightEffect StoredLightEffect;
var travel ERenderStyle StoredStyle;

var travel vector StoredPrePivot;

//222222222222222222222222222222222222
//Decoration Variables
var travel bool StoredbPushable;
var travel string StoredPushSound, StoredEndPushSound,
			StoredContents, StoredContent2, StoredContent3;

//333333333333333333333333333333333333
//DeusExDecoration Variables
var travel bool StoredbInvincible, /*StoredbFloating,*/ StoredbFlammable, StoredbExplosive, StoredbHighlight, StoredbCanBeBase, StoredbGenerateFlies;
var travel byte StoredFatness;
var travel int StoredHitPoints, StoredMinDamageThreshold, StoredExplosionDamage;
var travel float StoredFlammability, StoredExplosionRadius;
var travel string StoredItemName, StoredFragType;

//444444444444444444444444444444444444
//VMDBufferDeco Variables
var travel bool StoredbMemorable, StoredbSuperOwned;
var travel int StoredStoredSeed;

//555555555555555555555555555555555555
//Containers Variables
var travel bool StoredbGenerateTrash;
var travel int StoredNumThings;

//666666666666666666666666666666666666
//Special Variables

var() byte StoredBarrelSkinColor;

function TravelPostAccept()
{
	local int i;
	
	Super.TravelPostAccept();
	
	//Load these using ID strings.
	Mesh = Mesh(DynamicLoadObject(StoredMesh, class'Mesh', true));
	PickupViewMesh = Mesh;
	PlayerViewMesh = Mesh;
	for (i=0; i<ArrayCount(Multiskins); i++)
	{
		if (StoredMultiskins[i] != "")
		{
			Multiskins[i] = Texture(DynamicLoadObject(StoredMultiskins[i], class'Texture', true));
		}
	}
	if (StoredSkin != "") Skin = Texture(DynamicLoadObject(StoredSkin, class'Texture', true));
	if (StoredTexture != "") Texture = Texture(DynamicLoadObject(StoredTexture, class'Texture', true));
	if (StoredAmbientSound != "") AmbientSound = Sound(DynamicLoadObject(StoredAmbientSound, class'Sound', true));
}

auto state Pickup
{
	// if we hit the ground fast enough, break it, smash it!!!
	function Landed(Vector HitNormal)
	{
		Super.Landed(HitNormal);
		
		if (bBreakable)
			if (VSize(Velocity) > 400)
				BreakItSmashIt(fragType, (CollisionRadius + CollisionHeight) / 2);
	}
	
	// changed from Touch to Frob - DEUS_EX CNN
	function Frob(Actor Other, Inventory frobWith)
	{
		local Inventory Copy;
		
		if (bDeleteMe) return;
		
		VMDFrobHook(Other, FrobWith);
		
		if ((Level != None) && (Level.Game != None) && (Pawn(Other) != None) && (ValidTouch(Other))) 
		{
			Copy = SpawnCopy(Pawn(Other));
			
			if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate) Copy.Activate();
			
			PlaySound (PickupSound,,2.0);	
			
			if (Pickup(Copy) != None)
			{
				Pickup(Copy).PickupFunction(Pawn(Other));
			}
			
			SetPhysics(PHYS_Interpolating);
			Velocity = vect(0,0,0);	// Prevent items with momentum from falling out of world.
		}
	}
}

//MADDERS, 8/24/23: And here we are again. Copy to/from all willy nilly. Sigh.
function VMDTransferPOVPropertiesTo(DeusExDecoration Deco, VMDPOVDeco POV)
{
	local int i;
	local VMDBufferDeco VDeco;
	
	if ((Deco != None) && (POV != None))
	{
		//MADDERS, 8/27/23: Derp. Stored the seed, and cram setup in ASAP.
		//Our seed technically gets shifted when recreated via drop methology.
		//Thankfully we have one frame to get this in, so prioritization should be more than enough.
		VDeco = VMDBufferDeco(Deco);
		if (VDeco != None)
		{
			VDeco.bDidSetup = true;
			VDeco.bMemorable = POV.StoredbMemorable;
			VDeco.bEverNotFrobbed = false; //Reveal us.
			VDeco.StoredSeed = POV.StoredStoredSeed;
			VDeco.bSuperOwned = POV.StoredbSuperOwned; //MADDERS, 12/23/23: We might be owned by somebody!
		}
		
		//111111111111111111111111111111111111
		//Actor Variables
		Deco.bBlockSight = POV.StoredbBlockSight;
		Deco.bUnlit = POV.StoredbUnlit;
		Deco.SetCollision(POV.StoredbCollideActors, POV.StoredbBlockActors, POV.StoredbBlockPlayers);
		Deco.bCollideWorld = POV.StoredbCollideWorld;
		Deco.bProjTarget = POV.StoredbProjTarget;
		Deco.bSpecialLit = POV.StoredbSpecialLit;
		
		Deco.SoundRadius = POV.StoredSoundRadius;
		Deco.SoundVolume = POV.StoredSoundVolume;
		Deco.SoundPitch = POV.StoredSoundPitch;
		Deco.LightBrightness = POV.StoredLightBrightness;
		Deco.LightHue = POV.StoredLightHue;
		Deco.LightSaturation = POV.StoredLightSaturation;
		Deco.LightRadius = POV.StoredLightRadius;
		Deco.LightPeriod = POV.StoredLightPeriod;
		Deco.LightPhase = POV.StoredLightPhase;
		Deco.LightCone = POV.StoredLightCone;
		Deco.VolumeBrightness = POV.StoredVolumeBrightness;
		Deco.VolumeRadius = POV.StoredVolumeRadius;
		Deco.VolumeFog = POV.StoredVolumeFog;
		
		Deco.TransientSoundVolume = POV.StoredTransientSoundVolume;
		Deco.TransientSoundRadius = POV.StoredTransientSoundRadius;
		Deco.SetCollisionSize(POV.StoredCollisionRadius, POV.StoredCollisionHeight);
		Deco.Mass = POV.StoredMass;
		Deco.Buoyancy = POV.StoredBuoyancy;
		
		Deco.Event = POV.StoredEvent;
		Deco.Tag = POV.StoredTag;
		
		//Load these using ID strings.
		Deco.Mesh = Mesh(DynamicLoadObject(POV.StoredMesh, class'Mesh', true));
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
			if (POV.StoredMultiskins[i] != "")
			{
				Deco.Multiskins[i] = Texture(DynamicLoadObject(POV.StoredMultiskins[i], class'Texture', true));
			}
		}
		if (POV.StoredSkin != "") Deco.Skin = Texture(DynamicLoadObject(POV.StoredSkin, class'Texture', true));
		if (POV.StoredTexture != "") Deco.Texture = Texture(DynamicLoadObject(POV.StoredTexture, class'Texture', true));
		if (POV.StoredAmbientSound != "") Deco.AmbientSound = Sound(DynamicLoadObject(POV.StoredAmbientSound, class'Sound', true));
		
		Deco.BindName = POV.StoredBindName;
		Deco.BarkBindName = POV.StoredBarkBindName;
		Deco.FamiliarName = POV.StoredFamiliarName;
		Deco.UnfamiliarName = POV.StoredUnfamiliarName;
		Deco.ConBindEvents();
		
		Deco.LightType = POV.StoredLightType;
		Deco.LightEffect = POV.StoredLightEffect;
		Deco.Style = POV.StoredStyle;
		
		Deco.PrePivot = POV.StoredPrePivot;
		
		//222222222222222222222222222222222222
		//Decoration Variables
		Deco.bPushable = POV.StoredbPushable;
		
		//Load these using ID strings.
		if (POV.StoredPushSound != "") Deco.PushSound = Sound(DynamicLoadObject(POV.StoredPushSound, class'Sound', true));
		if (POV.StoredEndPushSound != "") Deco.EndPushSound = Sound(DynamicLoadObject(POV.StoredEndPushSound, class'Sound', true));
		if (POV.StoredContents != "") Deco.Contents = class<Inventory>(DynamicLoadObject(POV.StoredContents, class'Class', true));
		if (POV.StoredContents != "") Deco.Content2 = class<Inventory>(DynamicLoadObject(POV.StoredContent2, class'Class', true));
		if (POV.StoredContents != "") Deco.Content3 = class<Inventory>(DynamicLoadObject(POV.StoredContent3, class'Class', true));
		
		//333333333333333333333333333333333333
		//DeusExDecoration Variables
		Deco.bInvincible = POV.StoredbInvincible;
		//Deco.bFloating = POV.StoredbFloating; MADDERS, 12/3/23: Don't copy this. Useless and bad.
		Deco.bFlammable = POV.StoredbFlammable;
		Deco.bExplosive = POV.StoredbExplosive;
		Deco.bHighlight = POV.StoredbHighlight;
		Deco.bCanBeBase = POV.StoredbCanBeBase;
		Deco.bGenerateFlies = POV.StoredbGenerateFlies;
		
		Deco.Fatness = POV.StoredFatness;
		
		Deco.HitPoints = POV.StoredHitPoints;
		Deco.MinDamageThreshold = POV.StoredMinDamageThreshold;
		Deco.ExplosionDamage = POV.StoredExplosionDamage;
		
		Deco.Flammability = POV.StoredFlammability;
		Deco.ExplosionRadius = POV.StoredExplosionRadius;
		Deco.ItemName = POV.StoredItemName;
		
		//Load these using ID strings.
		Deco.FragType = class<Fragment>(DynamicLoadObject(POV.StoredFragType, class'Class', true));
		
		//555555555555555555555555555555555555
		//Containers Variables
		if (Containers(Deco) != None)
		{
			Containers(Deco).bGenerateTrash = POV.StoredbGenerateTrash;
			Containers(Deco).NumThings = POV.StoredNumThings;
		}
		
		//66666666666666666666666666666666666
		//Barrel Variables
		if (Barrel1(Deco) != None)
		{
			Barrel1(Deco).VMDSetSkinColor(StoredBarrelSkinColor);
		}
	}
}

function VMDTransferPOVPropertiesFrom(DeusExDecoration Deco, VMDPOVDeco POV)
{
	local int i;
	local VMDBufferDeco VDeco;
	
	if ((Deco != None) && (POV != None))
	{
		POV.DecoClassString = string(Deco.Class);
		
		//111111111111111111111111111111111111
		//Actor Variables
		POV.StoredbBlockSight = Deco.bBlockSight;
		POV.StoredbUnlit = Deco.bUnlit;
		POV.StoredbCollideActors = Deco.bCollideActors;
		POV.StoredbCollideWorld = Deco.bCollideWorld;
		POV.StoredbBlockActors = Deco.bBlockActors;
		POV.StoredbBlockPlayers = Deco.bBlockPlayers;
		POV.StoredbProjTarget = Deco.bProjTarget;
		POV.StoredbSpecialLit = Deco.bSpecialLit;
		
		POV.StoredSoundRadius = Deco.SoundRadius;
		POV.StoredSoundVolume = Deco.SoundVolume;
		POV.StoredSoundPitch = Deco.SoundPitch;
		POV.StoredLightBrightness = Deco.LightBrightness;
		POV.StoredLightHue = Deco.LightHue;
		POV.StoredLightSaturation = Deco.LightSaturation;
		POV.StoredLightRadius = Deco.LightRadius;
		POV.StoredLightPeriod = Deco.LightPeriod;
		POV.StoredLightPhase = Deco.LightPhase;
		POV.StoredLightCone = Deco.LightCone;
		POV.StoredVolumeBrightness = Deco.VolumeBrightness;
		POV.StoredVolumeRadius = Deco.VolumeRadius;
		POV.StoredVolumeFog = Deco.VolumeFog;
		
		POV.StoredTransientSoundVolume = Deco.TransientSoundVolume;
		POV.StoredTransientSoundRadius = Deco.TransientSoundRadius;
		POV.StoredCollisionHeight = Deco.CollisionHeight;
		POV.StoredCollisionRadius = Deco.CollisionRadius;
		
		if ((VMDBufferDeco(Deco) != None) && (VMDBufferDeco(Deco).bSwappedCollision))
		{
			POV.StoredCollisionRadius = Deco.CollisionHeight;
			POV.StoredCollisionHeight = Deco.CollisionRadius;
		}
		
		POV.StoredMass = Deco.Mass;
		POV.StoredBuoyancy = Deco.Buoyancy;
		
		POV.StoredEvent = Deco.Event;
		POV.StoredTag = Deco.Tag;
		
		//Load these using ID strings.
		POV.StoredMesh = string(Deco.Mesh);
		POV.Mesh = Deco.Mesh;
		POV.PickupViewMesh = Deco.Mesh;
		POV.PlayerViewMesh = Deco.Mesh;
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
			if (Deco.Multiskins[i] != None)
			{
				POV.StoredMultiskins[i] = string(Deco.Multiskins[i]);
				Multiskins[i] = Deco.Multiskins[i];
			}
		}
		if (Deco.Texture != None) POV.StoredTexture = string(Deco.Texture);
		POV.Texture = Deco.Texture;
		if (Deco.Skin != None) POV.StoredSkin = string(Deco.Skin);
		POV.Skin = Deco.Skin;
		
		if (Deco.AmbientSound != None) POV.StoredAmbientSound = string(Deco.AmbientSound);
		
		POV.StoredBindName = Deco.BindName;
		POV.StoredBarkBindName = Deco.BarkBindName;
		POV.StoredFamiliarName = Deco.FamiliarName;
		POV.StoredUnfamiliarName = Deco.UnfamiliarName;
		
		POV.StoredLightType = Deco.LightType;
		POV.StoredLightEffect = Deco.LightEffect;
		POV.StoredStyle = Deco.Style;
		
		POV.StoredPrePivot = Deco.PrePivot;
		
		//222222222222222222222222222222222222
		//Decoration Variables
		POV.StoredbPushable = Deco.bPushable;
		
		//Load these using ID strings.
		if (Deco.PushSound != None) POV.StoredPushSound = string(Deco.PushSound);
		if (Deco.EndPushSound != None) POV.StoredEndPushSound = string(Deco.EndPushSound);
		if (Deco.Contents != None) POV.StoredContents = string(Deco.Contents);
		if (Deco.Content2 != None) POV.StoredContent2 = string(Deco.Content2);
		if (Deco.Content3 != None) POV.StoredContent3 = string(Deco.Content3);
		
		//333333333333333333333333333333333333
		//DeusExDecoration Variables
		POV.StoredbInvincible = Deco.bInvincible;
		//POV.StoredbFloating = Deco.bFloating; MADDERS, 12/3/23: Don't copy this. Useless and bad.
		POV.StoredbFlammable = Deco.bFlammable;
		POV.StoredbExplosive = Deco.bExplosive;
		POV.StoredbHighlight = Deco.bHighlight;
		POV.StoredbCanBeBase = Deco.bCanBeBase;
		POV.StoredbGenerateFlies = Deco.bGenerateFlies;
		
		POV.StoredFatness = Deco.Fatness;
		
		POV.StoredHitPoints = Deco.HitPoints;
		POV.StoredMinDamageThreshold = Deco.MinDamageThreshold;
		POV.StoredExplosionDamage = Deco.ExplosionDamage;
		
		POV.StoredFlammability = Deco.Flammability;
		POV.StoredExplosionRadius = Deco.ExplosionRadius;
		POV.StoredItemName = Deco.ItemName;
		
		//Load these using ID strings.
		if (Deco.FragType != None) POV.StoredFragType = string(Deco.FragType);
		
		//444444444444444444444444444444444444
		//VMDBufferDeco Variables
		VDeco = VMDBufferDeco(Deco);
		if (VDeco != None)
		{
			POV.StoredbMemorable = VDeco.bMemorable;
			POV.StoredStoredSeed = VDeco.StoredSeed;
			POV.StoredbSuperOwned = VDeco.bSuperOwned; //MADDERS, 12/23/23: We might be owned by somebody!
		}
		
		//555555555555555555555555555555555555
		//Containers Variables
		if (Containers(Deco) != None)
		{
			POV.StoredbGenerateTrash = Containers(Deco).bGenerateTrash;
			POV.StoredNumThings = Containers(Deco).NumThings;
		}
		
		//66666666666666666666666666666666666
		//Barrel Variables
		if (Barrel1(Deco) != None)
		{
			POV.StoredBarrelSkinColor = Barrel1(Deco).SkinColor;
		}
	}
}

// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
	if (DeusExPlayer(Owner) == None || StoredCollisionRadius <= 0)
		return;
	
	SetLocation(Owner.Location + CalcDrawOffset());
	SetRotation(Pawn(Owner).Rotation); //View
	Canvas.DrawActor(Self, False);
}

simulated function vector CalcDrawOffset()
{
	//local float AddGap;
	local vector DrawOffset, WeaponBob, TViewOffset;
	local DeusExPlayer DXP;
	//local VMDBufferPlayer VMP;
	
	DXP = DeusExPlayer(Owner);
	if (DXP == None) return DrawOffset;
	//VMP = VMDBufferPlayer(Owner);
	
	//Start with our offset, adjust it by our size and owner's size.
	TViewOffset = PlayerViewOffset*0.01;
	TViewOffset.X += (StoredCollisionRadius + DXP.CollisionRadius) * 1.0;
	TViewOffset.Z += DXP.CollisionHeight / 2;
	
	TViewOffset *= 100;
	
	//Then do FOV and make it relative to rotation.
	DrawOffset = ((0.9/DXP.FOVAngle * TViewOffset) >> DXP.Rotation); //View
	
	//Don't forget to add our eyeheight, so it *looks* like the center.
	//DrawOffset += (DXP.EyeHeight * vect(0,0,1));
	
	//Lastly, toss in walk bob as needed.
	//WeaponBob = BobDamping * DXP.WalkBob;
	//WeaponBob.Z = (0.45 + 0.55 * BobDamping) * DXP.WalkBob.Z;
	//DrawOffset += WeaponBob;
	
	/*if ((VMP != None) && (VMP.bUseDynamicCamera))
	{
		AddGap = 5;
		
		AddGap *= (VMP.CollisionRadius / VMP.Default.CollisionRadius);
		DrawOffset += Vector(VMP.ViewRotation) * AddGap;
	}*/
	
	return DrawOffset;
}

defaultproperties
{
     bUnlit=True
     Style=STY_Translucent
     PickupMessage="You pick up the %d"
     
     bDisplayableInv=False
     ItemName="decoration"
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     PlayerViewMesh=None
     PickupViewMesh=None
     Mesh=None
     
     LandSound=None
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=1.000000
}
