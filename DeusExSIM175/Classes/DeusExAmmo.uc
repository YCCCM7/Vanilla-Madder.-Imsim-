//=============================================================================
// DeusExAmmo.
//=============================================================================
class DeusExAmmo extends Ammo
	abstract;

var localized String msgInfoRounds;

// True if this ammo can be displayed in the Inventory screen
// by clicking on the "Ammo" button.

var bool bShowInfo;
var int MPMaxAmmo; //Max Ammo in multiplayer.

//VANILLA MADDERS ADDITIONS!
var bool bVolatile, bCrateSummoned, bDidSetup, bSpecialAmmoScaling; //Used for our hook function!

//MADDERS, 9/22/20: Mod support. If you have things like UNATCO Candy Bar, and don't want "Unatco candy bar" to come out, use this.
var bool bNameCaseSensitive;

//MADDERS, 8/7/23: Corpse drop hack for not blocking pawns.
var bool bCorpseUnclog;

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
	
	bCorpseUnclog = false;
}

function string VMDGetItemName()
{
	return ItemName@"("$AmmoAmount$")";
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

function ProcessVMDChanges()
{
 	if (bDidSetup) return;
 
 	bDidSetup = True;
}

//MADDERS, 1/28/21: Use this for max ammo configuring.
function int VMDConfigureMaxAmmo()
{
	if ((Level.NetMode != NM_Standalone) && (MPMaxAmmo > 0)) return MPMaxAmmo;
	return MaxAmmo;
}

function name VMDGetSpecialDamageType()
{
	return 'None';
}

//MADDERS, 1/9/21: Use for shell casings for select situations. Don't integrate into UseAmmo.
function VMDForceShellCasing()
{
}

//MADDERS, 6/10/22: For pre travel stuff on inv items. Yucky.
function VMDPreTravel();

//MADDERS: Do this nonsense for dropping swapped ammos.
function VMDAttemptCrateSwap(int Seed);

//MADDERS, 4/8/21: Add support for infinite ammo zones.
function bool UseAmmo(int AmountNeeded)
{
	local VMDAmmoUseNegationActor AUNA;
	
	forEach AllActors(class'VMDAmmoUseNegationActor', AUNA)
	{
		if ((AUNA != None) && (AUNA.Region.Zone == Region.Zone))
		{
			return true;
		}
	}
	
	if (AmmoAmount < AmountNeeded) return False;   // Can't do it
	AmmoAmount -= AmountNeeded;
	return True;
}

auto state Pickup
{	
	// When touched by an actor.
	// Now, when frobbed by an actor - DEUS_EX CNN
	function Frob(Actor Other, Inventory frobWith)
	{
		local string TName;
		
		if (bDeleteMe) return;
		
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			TName = ItemName;
			if (!bNameCaseSensitive) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
			
			if (Level.Game.LocalLog != None)
			{
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			}
			if (Level.Game.WorldLog != None)
			{
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			}
			SpawnCopy(Pawn(Other));
			if ( PickupMessageClass == None )
			{
				// DEUS_EX CNN - use the itemArticle and itemName
				Pawn(Other).ClientMessage(PickupMessage @ itemArticle @ TName @ "("$AmmoAmount$")", 'Pickup');
			}
			else
			{
				Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
			}
			
			class'VMDStaticFunctions'.Static.AddReceivedItem(DeusExPlayer(Owner), Self, AmmoAmount, true);
			
			PlaySound (PickupSound);		
			if ( Level.Game.Difficulty > 1 )
			{
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
			}
			if ( Pawn(Other).MoveTarget == self )
			{
				Pawn(Other).MoveTimer = -1.0;
			}
		}
		else if ((bTossedOut) && (Other.Class == Class) && (Inventory(Other).bTossedOut))
		{
			Destroy();
		}
	}
}

//MADDERS, 6/5/24: Fix ability to obtain impossible amounts of ammo, thank you.
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;
	
	if (parentammo != None)
	{
		Copy = spawn(parentammo,Other,,,rot(0,0,0));
		Copy.Tag = Tag;
		Copy.Event = Event;
		Copy.Instigator = Other;
		Ammo(Copy).AmmoAmount = Min(MaxAmmo, AmmoAmount);
		Copy.BecomeItem();
		Other.AddInventory( Copy );
		Copy.GotoState('');
		if (Level.Game.ShouldRespawn(self))
		{
			GotoState('Sleeping');
		}
		else
		{
			AmmoAmount -= Min(MaxAmmo, AmmoAmount);
			if (AmmoAmount <= 0)
			{
				Destroy();
			}
		}
		return Copy;
	}
	else
	{
		if (Level.Game.ShouldRespawn(self))
		{
			Copy = spawn(Class,Other,,,rot(0,0,0));
			Copy.Tag = Tag;
			Copy.Event = Event;
			GotoState('Sleeping');
		}
		else if (AmmoAmount > MaxAmmo)
		{
			Copy = spawn(Class,Other,,,rot(0,0,0));
			Copy.Tag = Tag;
			Copy.Event = Event;
		}
		else
		{
			Copy = self;
		}
		
		Copy.RespawnTime = 0.0;
		Copy.bHeldItem = true;
		Copy.GiveTo(Other);
		Ammo(Copy).AmmoAmount = Min(MaxAmmo, AmmoAmount);
		
		if ((!Level.Game.ShouldRespawn(self)) && (AmmoAmount > MaxAmmo))
		{
			AmmoAmount -= MaxAmmo;
			class'VMDStaticFunctions'.Static.AddReceivedItem(DeusExPlayer(Other), Self, MaxAmmo, true);
		}
	}
	return Copy;
}

function bool HandlePickupQuery( inventory Item )
{
	local int AmmoToAdd;
	local string TName;
	
	if ( (class == item.class) || (ClassIsChildOf(item.class, class'Ammo') && (class == Ammo(item).parentammo)) ) 
	{
		TName = Item.ItemName;
		if ((DeusExAmmo(Item) != None) && (!DeusExAmmo(Item).bNameCaseSensitive)) TName = class'VMDStaticFunctions'.Static.VMDLower(TName);
		
		AmmoToAdd = Min(Ammo(Item).AmmoAmount, (VMDConfigureMaxAmmo() - AmmoAmount));
		
		if (AmmoAmount >= VMDConfigureMaxAmmo()) return true;
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (Item.PickupMessageClass == None)
		{
			// DEUS_EX CNN - use the itemArticle and itemName
			//-----
			//MADDERS: Label ammo given as well.
			Pawn(Owner).ClientMessage( Item.PickupMessage @ Item.itemArticle @ TName @ "("$AmmoToAdd$")", 'Pickup' );
		}
		else
		{
			Pawn(Owner).ReceiveLocalizedMessage( Item.PickupMessageClass, 0, None, None, item.Class );
		}
		class'VMDStaticFunctions'.Static.AddReceivedItem(DeusExPlayer(Owner), Self, AmmoToAdd, true);
		
		item.PlaySound( item.PickupSound );
		
		AddAmmo(AmmoToAdd);
		if (Level.Netmode != NM_Standalone || Ammo(Item).AmmoAmount <= AmmoToAdd)
		{
			item.SetRespawn();
		}
		else
		{
			Ammo(Item).AmmoAmount -= AmmoToAdd;
		}
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

//MADDERS: Some ammo has culled bottoms, so level this guy out.
function Landed(vector HitNormal)
{
	local Rotator Rot;
	
	Super.Landed(HitNormal);
	
	Rot = Rotator(HitNormal);
	Rot.Yaw = Rotation.Yaw;
	
	SetRotation(Rot);
}

function bool AddAmmo(int AmmoToAdd)
{
	//Don't even bother. Null control bby.
	if (AmmoToAdd == 0) return false;
	
	if (AmmoAmount >= VMDConfigureMaxAmmo()) return false;
	if (bSpecialAmmoScaling)
	{
		AmmoAmount += Max(1, AmmoToAdd * (VMDConfigureMaxAmmo() / Default.MaxAmmo));
	}
	else
	{
		AmmoAmount += Max(1, AmmoToAdd);
	}
	if (AmmoAmount > VMDConfigureMaxAmmo()) AmmoAmount = VMDConfigureMaxAmmo();
	return true;
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
   	if (Level.NetMode != NM_Standalone)
   	{   
      		if (MPMaxAmmo == 0)      
         		MPMaxAmmo = AmmoAmount * 3;
      		MaxAmmo = MPMaxAmmo;
   	}
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName);
	winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());

	// number of rounds left
	winInfo.AppendText(Sprintf(msgInfoRounds, AmmoAmount));

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
			PlaySound(LandSound, SLOT_None, TransientSoundVolume,, 768);
			if (ScriptedPawn(Instigator) == None) AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 768);
		}
	}
}

function TravelPostAccept()
{
	// Make the object follow us, for AmbientSound mainly
	if ((Owner != None) && (Level.NetMode == NM_Standalone))
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
	}
	
	Super.TravelPostAccept();
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
	if ((Owner != None) && (Level.NetMode == NM_Standalone))
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
	}
}

singular function BaseChange()
{
	Super.BaseChange();

	// Make sure we fall if we don't have a base
	if ((base == None) && (Owner == None))
		SetPhysics(PHYS_Falling);
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	//MADDERS: Moved here for reliability sake.
   	if (!bDidSetup) ProcessVMDChanges();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function CheckTouching();
function bool ValidTouch( actor Other );

defaultproperties
{
     msgInfoRounds="%d Rounds Remaining"
     bDisplayableInv=False
     PickupMessage="You found"
     ItemName="DEFAULT AMMO NAME - REPORT THIS AS A BUG"
     ItemArticle=""
     LandSound=Sound'DeusExSounds.Generic.PaperHit1'
}
