//=============================================================================
// DeusExPickup.
//=============================================================================
class DeusExPickup extends Pickup
	abstract;

#exec OBJ LOAD FILE=VMDEffects

var bool            bBreakable;		// true if we can destroy this item
var class<Fragment> fragType;		// fragments created when pickup is destroyed
var int				maxCopies;		// 0 means unlimited copies

var localized String CountLabel;
var localized String msgTooMany;

//MADDERS: Addiction related. Travel for the sake of being harder to game yet.
//Too much work? Absolutely.
var travel int TimesUsed;

//MADDERS, 11/3/24: Allow some pickups to explode during gib, such as fire extinguisher. Fragile just makes things break.
var bool bFragile, bVolatile;

//MADDERS, 12/26/20: Mod support. If you have things like UNATCO Candy Bar, and don't want "Unatco candy bar" to come out, use this.
var bool bNameCaseSensitive;
var localized string MsgCopiesAdded;

//MADDERS, 11/11/22: Integrating, to stop needing to add your own.
var bool bIsFood; //NOTE: Can also be used with -1 food value for left click to activate while on ground.
var int HungerValue;

//MADDERS, 4/10/21: Smell system stuff. Yay.
var string SmellType;
var int SmellUnits;
var localized string SmellLabel;

//Rotation code. It ain't even hard, homes.
var travel bool bRotatedInInventory;
var bool bCanRotateInInventory;
var Texture RotatedIcon;

//MADDERS, 12/23/23: Alert people nearby we're basically stealing.
var() bool bSuperOwned;

//MADDERS, 6/24/23: Setup stuff here.
var travel bool bDidSetup;

//MADDERS, 8/7/23: Corpse drop hack for not blocking pawns.
var bool bCorpseUnclog;

//DXT: If frobbed set this, if set allow it to be picked up even when refused.
var bool bItemRefusalOverride;

// ----------------------------------------------------------------------
// Networking Replication
// ----------------------------------------------------------------------

replication
{
   //client to server function
   reliable if ((Role < ROLE_Authority) && (bNetOwner))
      UseOnce;
}

//MADDERS, 8/29/23: Update this so it adapts to rolling offsets.
simulated event RenderOverlays( canvas Canvas )
{
	local byte OldFatness;
	local Rotator NewRot;
	local DeusExPlayer DXP;
	
	OldFatness = Fatness;
	
	if (VMDOwnerIsRadarTrans())
	{
		Fatness = Rand(4) + 126;
	}
	
	DXP = DeusExPlayer(Owner);
 	//Object load annoying. Do this instead.
 	if ((DXP != None) && (VMDOwnerIsCloaked()))
 	{
		VMDRenderCloakBlock(Canvas);
 	}
	else
	{
		if ( Owner == None )
			return;
		if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
			return;
		SetLocation( Owner.Location + CalcDrawOffset() );
		NewRot = Pawn(Owner).ViewRotation;
		
		if (VMDBufferPlayer(Owner) != None)
		{
			NewRot += VMDBufferPlayer(Owner).VMDRollModifier;
		}
		
		SetRotation( NewRot );
		Canvas.DrawActor(self, false);
	}
	
	Fatness = OldFatness;
}

function VMDRenderCloakBlock(Canvas Canvas)
{
	local int i;
	local float OldSG;
	local Rotator NewRot;
	local Texture TTex, OldTex[8], CloakTex[9], OldTexture;
	local ERenderStyle OldStyle;
 	local DeusExPlayer DXP;
	
	CloakTex[0] = Texture'VMDCloakFX01';
	CloakTex[1] = Texture'VMDCloakFX02';
	CloakTex[2] = Texture'VMDCloakFX03';
	CloakTex[3] = Texture'VMDCloakFX04';
	CloakTex[4] = Texture'VMDCloakFX05';
	CloakTex[5] = Texture'VMDCloakFX06';
	CloakTex[6] = Texture'VMDCloakFX07';
	CloakTex[7] = Texture'VMDCloakFX08';
	CloakTex[8] = Texture'VMDCloakFX09';
	
	//Backup our old skins.
	for (i=0; i<ArrayCount(Multiskins); i++)
	{
		OldTex[i] = Multiskins[i];
	}
	OldTexture = Texture;
	OldStyle = Style;
  	OldSG = ScaleGlow;
	
	for (i=0; i<ArrayCount(Multiskins); i++)
	{
		Multiskins[i] = CloakTex[i+1];
	}
	ScaleGlow *= 0.1;
	Style = STY_Translucent;
	
	//MADDERS, 8/29/23: Render overlays here!
	//-----------------------
	if ( Owner == None )
		return;
	if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
		return;
	SetLocation( Owner.Location + CalcDrawOffset() );
	NewRot = Pawn(Owner).ViewRotation;
	
	if (VMDBufferPlayer(Owner) != None)
	{
		NewRot += VMDBufferPlayer(Owner).VMDRollModifier;
	}
	
	SetRotation( NewRot );
	Canvas.DrawActor(self, false);
	
	//-----------------------
	//MADDERS: Obsolete?
	//Super.RenderOverlays(Canvas);
	
	//Restore old skins.
	for (i=0; i<ArrayCount(Multiskins); i++)
	{
  		MultiSkins[i] = OldTex[i];
	}
	
	Scaleglow = OldSG;
 	Style = OldStyle;
	Texture = OldTexture;
}

//MADDERS, 8/29/23: Update this so it adapts to rolling offsets.
simulated function vector CalcDrawOffset()
{
	local float AddGap;
	local Rotator TRot;
	local vector DrawOffset, WeaponBob, AddVect;
	local Pawn PawnOwner;
	local VMDBufferPlayer VMP;
	
	PawnOwner = Pawn(Owner);
	VMP = VMDBufferPlayer(Owner);
	if (PawnOwner != None)
	{
		if (VMP != None)
		{
			TRot = VMP.VMDRollModifier;
		}
		DrawOffset = ((0.9/PawnOwner.FOVAngle * PlayerViewOffset) >> PawnOwner.ViewRotation+TRot);
		
		if ( (Level.NetMode == NM_DedicatedServer) 
			|| ((Level.NetMode == NM_ListenServer) && (Owner.RemoteRole == ROLE_AutonomousProxy)) )
		{
			DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
		}
		else
		{	
			DrawOffset += (PawnOwner.EyeHeight * vect(0,0,1));
			WeaponBob = BobDamping * PawnOwner.WalkBob;
			WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
			DrawOffset += WeaponBob;
		}
		
		if ((VMP != None) && (VMP.bUseDynamicCamera))
		{
			AddGap = 5;
			AddGap *= (VMP.CollisionRadius / VMP.Default.CollisionRadius);
			
			AddVect = Vector(VMP.ViewRotation) * AddGap;
			AddVect.Z = 0;
			
			DrawOffset += AddVect;
		}
	}
	return DrawOffset;
}

//MADDERS, 8/8/23: Drop objection framework. For when you have stuff you don't want to be yeeted at bad times.
function bool VMDHasDropObjection()
{
	return false;
}

// MADDERS, 8/7/23: Turn off bBlockActors because it results in item clogging. Setting this in DeusExCarcass isn't nice, and also doesn't stop player exploits.
function BecomePickup()
{
	Super.BecomePickup();
	
	if (bCorpseUnclog)
	{
		SetCollision(True, False, False);
	}
}

function BecomeItem()
{
	Super.BecomeItem();
	
	bOwned = false;
	bSuperOwned = false;
	bCorpseUnclog = false;
}

function ProcessVMDChanges()
{
 	if (bDidSetup) return;
 	
 	bDidSetup = True;
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	//MADDERS: Moved here for reliability sake.
   	if (!bDidSetup) ProcessVMDChanges();
}

// ----------------------------------------------------------------------
// HandlePickupQuery()
//
// If the bCanHaveMultipleCopies variable is set to True, then we want
// to stack items of this type in the player's inventory.
// ----------------------------------------------------------------------

function bool HandlePickupQuery( inventory Item )
{
	local Bool bAlreadyHas, bResult;
	local int AddBack, NumAdded, i, OldCopies;
	local float LastCharge;
	local DeusExPlayer player;
	local Inventory anItem;
	
	if ( Item.Class == Class )
	{
		player = DeusExPlayer(Owner);
		bResult = False;
		
		// Check to see if the player already has one of these in 
		// his inventory
		anItem = player.FindInventoryType(Item.Class);
		
		if ((anItem != None) && (bCanHaveMultipleCopies))
		{
			if (NumCopies >= VMDConfigureMaxCopies())
			{
				player.ClientMessage(msgTooMany);
				
				// abort the pickup
				return True;
			}
			else if (DeusExPickup(item).NumCopies > 1)
			{
				// don't actually put it in the hand, just add it to the count
				/*NumCopies += DeusExPickup(item).NumCopies;
				NumAdded += DeusExPickup(item).NumCopies;
				
				//MADDERS: Do a partial pickup, however possible.
				if ((VMDConfigureMaxCopies() > 0) && (NumCopies > VMDConfigureMaxCopies()))
				{
					AddBack = (NumCopies - VMDConfigureMaxCopies());
					NumCopies -= AddBack;
					NumAdded -= AddBack;
					DeusExPickup(Item).NumCopies = AddBack;
				}*/
				OldCopies = DeusExPickup(Item).NumCopies;
				for(i=0; i<OldCopies; i++)
				{
					NumCopies++;
					NumAdded++;
					VMDSignalCopiesAdded(Self, DeusExPickup(Item));
					DeusExPickup(Item).NumCopies--;
					DeusExPickup(Item).VMDSignalCopiesRemoved();
					if (NumCopies >= VMDConfigureMaxCopies() || DeusExPickup(Item).NumCopies <= 0)
					{
						break;
					}
				}
				
				UpdateBeltText();
				if (MsgCopiesAdded != "")
				{
					if (DeusExPickup(Item).NumCopies <= 0)
					{
						DeusExPickup(Item).Destroy();
					}
					
					if (DeusExPickup(Item).bNameCaseSensitive)
					{
						player.ClientMessage(SprintF(MsgCopiesAdded, NumAdded, ItemName));
					}
					else
					{
						player.ClientMessage(SprintF(MsgCopiesAdded, NumAdded, class'VMDStaticFunctions'.Static.VMDLower(ItemName)));
					}
					
					class'VMDStaticFunctions'.Static.AddReceivedItem(Player, DeusExPickup(Item), NumAdded, true);
				}
				
				// abort the pickup
				return True;
			}
			else
			{
				NumCopies += DeusExPickup(item).NumCopies;
				VMDSignalCopiesAdded(Self, DeusExPickup(Item));
			}
			bResult = True;
		}

		if (bResult)
		{
			//MADDERS, 1/30/21: Hack for hidden items.
			if (Item.PickupMessage != "")
			{
				if ((DeusExPickup(Item) != None) && (DeusExPickup(Item).bNameCaseSensitive))
				{
					Player.ClientMessage(Item.PickupMessage @ Item.ItemArticle @ Item.ItemName, 'Pickup');
				}
				else
				{
					Player.ClientMessage(Item.PickupMessage @ Item.ItemArticle @ class'VMDStaticFunctions'.Static.VMDLower(Item.ItemName), 'Pickup');
				}
			}
			
			// Destroy me!
         		// DEUS_EX AMSD In multiplayer, we don't want to destroy the item, we want it to set to respawn
         		if (Level.NetMode != NM_Standalone)
            			Item.SetRespawn();
         		else			
            			Item.Destroy();
		}
		else
		{
			bResult = Super.HandlePickupQuery(Item);
		}

		// Update object belt text
		if (bResult)			
			UpdateBeltText();	

		return bResult;
	}

	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// ----------------------------------------------------------------------
// UseOnce()
//
// Subtract a use, then destroy if out of uses
// ----------------------------------------------------------------------

function UseOnce()
{
	local DeusExPlayer player;
	local VMDBufferPlayer VMP;
	
	player = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Player);
	
	//MADDERS: Weird hack, but this is how we're wiring in accessory food checks, since Activate and BeginState are dubious to place hooks in.
	if (VMP != None)
	{
		VMP.CheckForAccessoryFood(Self);
	}
	NumCopies--;
	VMDSignalCopiesRemoved();
	
	//MADDERS: Mark us as having being used.
	TimesUsed++;
	
	if (!IsA('SkilledTool'))
	{
		GotoState('DeActivated');
	}
	
	if (NumCopies <= 0)
	{
		if ((Player != None) && (player.inHand == Self))
		{
			player.PutInHand(None);
		}
		Destroy();
	}
	else
	{
		UpdateBeltText();
	}
}

// ----------------------------------------------------------------------
// UpdateBeltText()
// ----------------------------------------------------------------------

function UpdateBeltText()
{
	local DeusExRootWindow root;

	if (DeusExPlayer(Owner) != None)
	{
		root = DeusExRootWindow(DeusExPlayer(Owner).rootWindow);

		// Update object belt text
		if ((bInObjectBelt) && (root != None) && (root.hud != None) && (root.hud.belt != None))
			root.hud.belt.UpdateObjectText(beltPos);
	}
}

// ----------------------------------------------------------------------
// BreakItSmashIt()
// ----------------------------------------------------------------------

simulated function BreakItSmashIt(class<fragment> FragType, float size) 
{
	local int i;
	local DeusExFragment s;
	local Actor Hit;
	local Vector EndTrace, HitNormal, HitLocation;
	local WaterPool Pool;

	for (i=0; i<Int(size); i++) 
	{
		s = DeusExFragment(Spawn(FragType, Owner));
		if (s != None)
		{
			s.Instigator = Instigator;
			s.CalcVelocity(Velocity,0);
			s.DrawScale = ((FRand() * 0.05) + 0.05) * size;
			s.Skin = GetMeshTexture();

			// play a good breaking sound for the first fragment
			if (i == 0)
				s.PlaySound(sound'GlassBreakSmall', SLOT_None,,, 768, VMDGetMiscPitch());
		}
	}

	if (IsA('WineBottle') || IsA('Liquor40oz') || IsA('LiquorBottle'))
	{
		// trace down about 20 feet if we're not in water
		if (!Region.Zone.bWaterZone)
		{
			EndTrace = Location - vect(0,0,320);
			hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
			pool = spawn(class'WaterPool',,, HitLocation+HitNormal, Rotator(HitNormal));
			if (pool != None)
			{
				pool.maxDrawScale = CollisionRadius / 15.0;				
				pool.Texture = Texture'Effects.Water.Splash_A04';
				pool.spreadTime=1.5;
			}
		}
	}

	Destroy();
}

singular function BaseChange()
{
	Super.BaseChange();

	// Make sure we fall if we don't have a base
	if ((base == None) && (Owner == None))
		SetPhysics(PHYS_Falling);
}

// ----------------------------------------------------------------------
// state Pickup
// ----------------------------------------------------------------------

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
//	function Touch( actor Other )
	{
		local Inventory Copy;
		
		if (bDeleteMe) return;
		
		VMDFrobHook(Other, FrobWith);
		
		if ((Level != None) && (Level.Game != None) && (Pawn(Other) != None) && (ValidTouch(Other))) 
		{
			Copy = SpawnCopy(Pawn(Other));
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
//			if (bActivatable && Pawn(Other).SelectedItem==None) 
//				Pawn(Other).SelectedItem=Copy;
			if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate) Copy.Activate();
			if ( PickupMessageClass == None )
			{
				// DEUS_EX CNN - use the itemArticle and itemName
				//Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				if ((NumCopies > 1) && (MsgCopiesAdded != ""))
				{
					if (bNameCaseSensitive)
					{
						Pawn(Other).ClientMessage(SprintF(MsgCopiesAdded, NumCopies, ItemName));
					}
					else
					{
						Pawn(Other).ClientMessage(SprintF(MsgCopiesAdded, NumCopies, class'VMDStaticFunctions'.Static.VMDLower(ItemName)));
					}
				}
				else
				{
					if (PickupMessage != "")
					{
						if (bNameCaseSensitive)
						{
							Pawn(Other).ClientMessage(PickupMessage @ itemArticle @ itemName, 'Pickup');
						}
						else
						{
							Pawn(Other).ClientMessage(PickupMessage @ itemArticle @ class'VMDStaticFunctions'.Static.VMDLower(itemName), 'Pickup');
						}
					}
				}
			}
			else
			{
				Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
			}
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

state DeActivated
{
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local string str;
	local VMDBufferPlayer VMP;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	winInfo.SetTitle(itemName);
	winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
	
	if ((bCanHaveMultipleCopies) && (NumCopies > 0))
	{
		// Print the number of copies
		str = CountLabel @ String(NumCopies) $ winInfo.CR() $ winInfo.CR();
		winInfo.AppendText(str);
	}
	
	VMP = VMDBufferPlayer(Owner);
	if ((VMP != None) && (VMP.bSmellsEnabled) && (SmellType != "") && (SmellUnits > 0) && (NumCopies > 0))
	{
		// Print the number of smell units.
		str = SprintF(SmellLabel, SmellType, NumCopies, SmellUnits, (NumCopies*SmellUnits));
		WinInfo.AppendText(str);
	}
	
	return True;
}

// ----------------------------------------------------------------------
// PlayLandingSound()
// ----------------------------------------------------------------------

function PlayLandingSound()
{
	if (LandSound != None)
	{
		if (Velocity.Z <= -200)
		{
			PlaySound(LandSound, SLOT_None, TransientSoundVolume,, 768, VMDGetMiscPitch());
			if (ScriptedPawn(Instigator) == None) AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 768);
		}
	}
}

//MADDERS: Allow for objections to activation, stopping any activation message as well.
//As of 12/26/20: Also allow for more dynamic messages.
function Activate()
{
	if (bActivatable)
	{
		if (VMDHasActivationObjection()) return;
		
		VMDActivateHook();
		
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));
		
		if (M_Activated != "")
		{
			Pawn(Owner).ClientMessage(SprintF(M_Activated, VMDPickupCase(M_Activated, ItemName)));
		}
		//Pawn(Owner).ClientMessage(ItemName$M_Activated);
		
		GoToState('Activated');
	}
}

state Activated
{
	function Activate()
	{
		if ((Pawn(Owner) != None) && (M_Deactivated != ""))
		{
			Pawn(Owner).ClientMessage(SprintF(M_Deactivated, VMDPickupCase(M_Deactivated, ItemName)));	
		}
		GoToState('DeActivated');	
	}
}

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	VMDUpdatePropertiesHook();
}

function GiveTo(Pawn Other)
{
	local actor A;
	
	foreach BasedActors(class'Actor', A)
	{
		if (A.Base == Self)
			A.SetBase(None);
	}
	
	Super.GiveTo(Other);
	
	// Make the object follow us, for AmbientSound mainly
	if ((Owner != None) && (Level.NetMode == NM_Standalone) && (IsA('ChargedPickup')))
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
	}
}

State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		Super.BeginState();
		SetPhysics(PHYS_None);
		Velocity = Vect(0,0,0);
		bCollideWorld = True;
	}
}

function string VMDPickupCase(string NewMessage, string NewName)
{
	local string TRip, LowName;
	
	TRip = Left(NewMessage, 2);
	if (!bNameCaseSensitive)
	{
		if (TRip ~= "%s")
		{
			LowName = Left(NewName, 1)$class'VMDStaticFunctions'.Static.VMDLower(Right(NewName, Len(NewName)-1));
		}
		else
		{
			LowName = class'VMDStaticFunctions'.Static.VMDLower(NewName);
		}
	}
	else
	{
		LowName = NewName;
	}
	
	return LowName;
}

function bool VMDHasActivationObjection()
{
	return false;
}

//MADDERS: Use this for changing our max count on the fly.
function int VMDConfigureMaxCopies()
{
	return MaxCopies;
}

function float VMDGetMiscPitch()
{
	local bool bUnderwater;
	local float GMult;
	
	if (Owner != None)
        {
	 	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).HeadRegion.Zone.bWaterZone)) bUnderwater = true;
         	else if (Owner.Region.Zone.bWaterZone) bUnderwater = True;
        }
        else if (Region.Zone.bWaterZone) bUnderwater = True;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return (1.05 - (Frand() * 0.1)) * 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return (1.05 - (Frand() * 0.1)) * GMult;
}

//MADDERS: Do NOT factor in randomization. We're already randomized, ideally.
function float VMDGetMiscPitch2()
{
	local bool bUnderwater;
	local float GMult;
	
	if (Owner != None)
        {
	 	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).HeadRegion.Zone.bWaterZone)) bUnderwater = true;
         	else if (Owner.Region.Zone.bWaterZone) bUnderwater = True;
        }
        else if (Region.Zone.bWaterZone) bUnderwater = True;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return 1.0 * GMult;
}

function int GetAddictionSeed(int Cap)
{
	local int Seed;
	
	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, Cap);
	Seed = class'VMDStaticFunctions'.Static.RipSeedChunk("Addiction", Seed);
	Seed = (Seed + TimesUsed) % Cap;
	
	return Seed;
}

//MADDERS, 1/10/21: Use an offset ver of addiction to get this.
//Currently, we use this to give feedback for food eating.
function int GetFoodSeed(int Cap)
{
	local int Seed;
	
	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, Cap);
	Seed = class'VMDStaticFunctions'.Static.RipSeedChunk("Food Desc", Seed);
	Seed = (Seed + TimesUsed + 7) % Cap;
	
	return Seed;
}

//MADDERS HOOK ADDITIONS!

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly);
function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom);
function VMDSignalCopiesRemoved();
function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	if ((Bool(Dropped)) && (Bool(Parent)))
	{
		Dropped.TimesUsed = Parent.TimesUsed;
	}
}
function VMDSignalPickupUpdate();
function VMDUpdatePropertiesHook()
{
	if (IsA('NoodleCup'))
	{
		SmellType = "Food";
		SmellUnits = 150;
	}
	else if (IsA('Fries'))
	{
		SmellType = "Food";
		SmellUnits = 150;
	}
	else if (IsA('CoffeeCup'))
	{
		SmellType = "Food";
		SmellUnits = 50;
	}
	else if (IsA('BurgerSodaCan'))
	{
		SmellType = "Food";
		SmellUnits = 100;
	}
	else if (IsA('Burger'))
	{
		SmellType = "Food";
		SmellUnits = 200;
	}
	else if (IsA('Beans'))
	{
		SmellType = "Food";
		SmellUnits = 200;
	}
	else if (IsA('KetchupBar'))
	{
		SmellType = "Food";
		SmellUnits = 150;
	}
}

//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	return 1.0;
}
//MADDERS, 5/29/22: Backwards logic is vanilla logic. IE, we let this through.
function bool VMDFilterDamageTaken(name DT, int HitDamage, Vector HitLocation)
{
	return true;
}
function int VMDConfigureCloakThresholdMod()
{
	return 0;
}

function VMDActivateHook();

function bool VMDOwnerIsCloaked()
{
	if (Owner == None) return false;
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsCloaked();
	}
	else
	{
		if (Owner.Style == STY_Translucent) return true;
	}
	
	return false;
}

function bool VMDOwnerIsRadarTrans()
{
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsRadarTrans();
	}
	
	return false;
}

//MADDERS: Rotate items in inventory with this one weird trick
function Texture VMDConfigureLargeIcon()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return RotatedIcon;
	}
	return LargeIcon;
}

function int VMDConfigureLargeIconWidth()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return LargeIconHeight;
	}
 	return LargeIconWidth;
}

function int VMDConfigureLargeIconHeight()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return LargeIconWidth;
	}
 	return LargeIconHeight;
}

//MADDERS: Setting up for scaleable inventory size. Yeet.
function int VMDConfigureInvSlotsX(Pawn Other)
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return InvSlotsY;
	}
 	return InvSlotsX;
}

function int VMDConfigureInvSlotsY(Pawn Other)
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return InvSlotsX;
	}
 	return InvSlotsY;
}

//MADDERS, 5/11/22: Use once, except don't.
function VMDDontUseOnce()
{
	local DeusExPlayer player;
	local VMDBufferPlayer VMP;
	
	player = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Player);
	
	//MADDERS: Weird hack, but this is how we're wiring in accessory food checks, since Activate and BeginState are dubious to place hooks in.
	if (VMP != None)
	{
		VMP.CheckForAccessoryFood(Self);
	}
	
	//MADDERS: Mark us as having being used.
	TimesUsed++;
	
	if (!IsA('SkilledTool'))
		GotoState('DeActivated');
	
	UpdateBeltText();
}

function VMDFrobHook(Actor Frobber, Inventory FrobWith);

//MADDERS, 6/10/22: For pre travel stuff on inv items. Yucky.
function VMDPreTravel();

//MADDERS: Do this nonsense for dropping swapped pickups.
function VMDAttemptCrateSwap(int Seed);

function string VMDGetItemName()
{
	if (NumCopies > 1)
	{
		return ItemName@"("$NumCopies$")";
	}
	else
	{
		return ItemName;
	}
}

function bool VMDDropFrom(vector StartLocation, optional bool bTest)
{
	if (!SetLocation(StartLocation))
	{
		return false;
	}
	
	if (!bTest)
	{
		DropFrom(StartLocation);
	}
	return true;
}

function bool VMDHasSkillAugment(Name S)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
	}
	if (VMP == None)
	{
		return class'VMDSkillAugmentManager'.Static.StaticSkillAugmentAssumed(S);
	}
	return VMP.HasSkillAugment(S);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	VMDUpdatePropertiesHook();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function CheckTouching();
function bool ValidTouch( actor Other );

defaultproperties
{
     SmellLabel="SMELL: Smells like %s. %d x %d Units = %d smell units total";
     MsgCopiesAdded="You found %d %s(s)"
     M_Activated="%s activated"
     M_Deactivated="%s deactivated"
     
     FragType=Class'DeusEx.GlassFragment'
     CountLabel="COUNT:"
     msgTooMany="You can't carry any more of those"
     NumCopies=1
     PickupMessage="You found"
     ItemName="DEFAULT PICKUP NAME - REPORT THIS AS A BUG"
     RespawnTime=30.000000
     LandSound=Sound'DeusExSounds.Generic.PaperHit1'
}
