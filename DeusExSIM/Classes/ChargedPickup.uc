//=============================================================================
// ChargedPickup.
//=============================================================================
class ChargedPickup extends DeusExPickup
	abstract;

var() class<Skill> skillNeeded;
var() bool bOneUseOnly;
var() sound ActivateSound;
var() sound DeactivateSound;
var() sound LoopSound;
var Texture ChargedIcon;
var travel bool bIsActive;
var localized String ChargeRemainingLabel;

//MADDERS additions. Stack charge per copy.
var travel int ChargeStacks[8];
var bool bLatentChargeCost; //Do we use up charge from being on?
var localized string ChargeLabel, StrSecondsLeft;

 //Use this for fraction simulation. Yikes. Use the other for limiting how much we can score upon being looted.
var int LatentChargeSteps, MaxLootCharge, LastActivationCharge;
var localized string MsgConflictingPickup;

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local DeusExPlayer player;
	local String outText;
	local float TDrainRate;
	local int i;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	player = DeusExPlayer(Owner);
	
	if (player != None)
	{
		TDrainRate = 4;
		if (Player.SkillSystem != None) TDrainRate *= Player.SkillSystem.GetSkillLevelValue(SkillNeeded);
		
		//MADDERS, 1/8/21: Update charge stacks at all times.
		ChargeStacks[NumCopies-1] = Charge;
		
		winInfo.SetTitle(itemName);
		winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
		
		outText = ChargeRemainingLabel$winInfo.CR();
		if (NumCopies > 1)
		{
			for (i=0; i<NumCopies; i++)
			{
				if (bLatentChargeCost)
				{
					outText = OutText$"#"$((i+1))@Int(VMDGetCurrentCharge(i) + 0.5) $ "%"@ChargeLabel@SprintF(StrSecondsLeft, int((Default.Charge / (10 * TDrainRate) * VMDGetCurrentCharge(i) / 100)+0.5));
				}
				else
				{
					outText = OutText$"#"$((i+1))@Int(VMDGetCurrentCharge(i) + 0.5) $ "%"@ChargeLabel;
				}
				if (i < (NumCopies-1)) OutText = OutText$winInfo.CR();
			}
		}
		else
		{
			if (bLatentChargeCost)
			{
				outText = OutText$Int(VMDGetCurrentCharge(0) + 0.5) $ "%"@ChargeLabel@SprintF(StrSecondsLeft, int((Default.Charge / (10 * TDrainRate) * VMDGetCurrentCharge(0) / 100)+0.5));
			}
			else
			{
				outText = OutText$Int(VMDGetCurrentCharge(0) + 0.5) $ "%"@ChargeLabel;
			}
		}
		winInfo.AppendText(outText);
	}
	
	return True;
}

// ----------------------------------------------------------------------
// GetCurrentCharge()
// ----------------------------------------------------------------------

simulated function Float GetCurrentCharge()
{
	return (Float(Charge) / Float(Default.Charge)) * 100.0;
}

// ----------------------------------------------------------------------
// ChargedPickupBegin()
// ----------------------------------------------------------------------

function ChargedPickupBegin(DeusExPlayer Player)
{
	Player.AddChargedDisplay(Self);
	SetLocation(Player.Location); // Transcended - Center on the player when activated to prevent the sound coming from inside a wall etc
	PlaySound(ActivateSound, SLOT_None);
	if (LoopSound != None)
	{
		AmbientSound = LoopSound;
		if (bLatentChargeCost) SoundVolume = 128;
		else SoundVolume = 32;
	}
	
   	//DEUS_EX AMSD In multiplayer, remove it from the belt if the belt
   	//is the only inventory.
   	if ((Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory))
   	{
      		if (DeusExRootWindow(Player.rootWindow) != None)
         		DeusExRootWindow(Player.rootWindow).DeleteInventory(self);
		
      		bInObjectBelt = False;
      		BeltPos = default.BeltPos;
   	}
	
	bIsActive = True;
}

// ----------------------------------------------------------------------
// ChargedPickupEnd()
// ----------------------------------------------------------------------

function ChargedPickupEnd(DeusExPlayer Player)
{
	Player.RemoveChargedDisplay(Self);
	PlaySound(DeactivateSound, SLOT_None);
	if (LoopSound != None)
		AmbientSound = None;
	
	// remove it from our inventory if this is a one
	// use item
	if (bOneUseOnly)
		Player.DeleteInventory(Self);
	
	bIsActive = False;
}

// ----------------------------------------------------------------------
// IsActive()
// ----------------------------------------------------------------------

simulated function bool IsActive()
{
	return bIsActive;
}

// ----------------------------------------------------------------------
// ChargedPickupUpdate()
// ----------------------------------------------------------------------

function ChargedPickupUpdate(DeusExPlayer Player)
{
}

// ----------------------------------------------------------------------
// CalcChargeDrain()
// ----------------------------------------------------------------------

simulated function int CalcChargeDrain(DeusExPlayer Player)
{
	local float skillValue;
	local float drain;
	
	drain = 4.0;
	skillValue = 1.0;
	
	if (skillNeeded != None)
		skillValue = Player.SkillSystem.GetSkillLevelValue(skillNeeded);
	drain *= skillValue;
	if (Int(Drain) < 1) Drain = 1.0;
	
	if (!bLatentChargeCost)
	{
		//MADDERS, 8/6/25: Community voted, 70% want no latent charge cost, like in alpha.
		/*LatentChargeSteps++;
		
		//3.34 charge per second, or AKA 1000 charge lasts 5 minutes
		//Used to be 2.5 per second, then 5.0. We're getting there.
		if (LatentChargeSteps >= 3)
		{
			LatentChargeSteps = 0;
			Drain = 1;
		}
		else
		{*/
			Drain = 0;
		//}
	}
	
	return Int(drain);
}

// ----------------------------------------------------------------------
// function UsedUp()
//
// copied from Pickup, but modified to keep items from
// automatically switching
// ----------------------------------------------------------------------

function UsedUp()
{
	local DeusExPlayer Player;
	
	if ( Pawn(Owner) != None )
	{
		//MADDERS: This fucks up our ability to re-use pickups... and it's old, redundant code anyways.
		//bActivatable = false;
		
		//MADDERS, 1/30/21: Hack for hidden items.
		if (ExpireMessage != "")
		{
			Pawn(Owner).ClientMessage(ExpireMessage);
		}
	}
	if (Owner != None)
	{
		Owner.PlaySound(DeactivateSound);
	}
	Player = DeusExPlayer(Owner);
	
	if (Player != None)
	{
		if (Player.inHand == Self)
			ChargedPickupEnd(Player);
	}
	
	//MADDERS: This destroys if at 1 copy anyways.
	UseOnce();
}

// ----------------------------------------------------------------------
// state DeActivated
// ----------------------------------------------------------------------

state DeActivated
{
}

// ----------------------------------------------------------------------
// state Activated
// ----------------------------------------------------------------------

state Activated
{
	function Timer()
	{
		local float GSpeed;
		local DeusExPlayer Player;

		Player = DeusExPlayer(Owner);
		if (Player != None)
		{
			//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
			if ((AmbientSound != None) && (Level != None) && (Level.Game != None))
			{
				GSpeed = Level.Game.GameSpeed;
				if (GSpeed > 1.0)
				{
					SoundPitch = Min(255, 64 + (16 * (GSpeed - 1.0)));
				}
				else
				{
					SoundPitch = Max(1, 64 * GSpeed);
				}
			}
			
			ChargedPickupUpdate(Player);
			Charge -= CalcChargeDrain(Player);
			
			//MADDERS, 1/8/21: Update charge stacks at all times.
			ChargeStacks[NumCopies-1] = Charge;
			if (Charge <= 0)
				UsedUp();
		}
	}

	function BeginState()
	{
		local DeusExPlayer Player;

		Super.BeginState();

		Player = DeusExPlayer(Owner);
		if (Player != None)
		{
			// remove it from our inventory, but save our owner info
			if (bOneUseOnly)
			{
//				Player.DeleteInventory(Self);
				
				// Remove from player's hand
				Player.PutInHand(None);

				SetOwner(Player);
			}

			ChargedPickupBegin(Player);
			SetTimer(0.1, True);
		}
	}

	function EndState()
	{
		local DeusExPlayer Player;

		Super.EndState();

		Player = DeusExPlayer(Owner);
		if (Player != None)
		{
			ChargedPickupEnd(Player);
			SetTimer(0.1, False);
		}
	}

	function Activate()
	{
		// if this is a single-use item, don't allow the player to turn it off
		if (bOneUseOnly)
			return;
		
		//MADDERS: Augment required to toggle this guy off again.
		//MADDERS, 5/28/23: Nope. Now we do things differently. Instead, cost us 50% charge to do so, vs 15%.
		//if ((VMDHasSkillAugment('EnviroDeactivate')))
		//{
			if ((Charge > 0) && (Charge < LastActivationCharge))
			{
				if (VMDHasSkillAugment('EnviroDeactivate'))
				{
					Charge -= (Default.Charge * 0.15);
				}
				else
				{
					Charge -= (Default.Charge * 0.5);
				}
			}
			
			Super.Activate();
			
			if (Charge <= 0)
			{
				UseOnce();
			}
		//}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS: Use this for array relevant reasons.
simulated function Float VMDGetCurrentCharge(int Array)
{
	return (Float(ChargeStacks[Array]) / Float(Default.Charge)) * 100.0;
}

//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	local class<Skill> TSkill;
	local DeusExPlayer DXP;
	local float Ret, SpecMult;
	
	DXP = DeusExPlayer(Owner);
	if (DXP == None) return 1.0;
	TSkill = SkillNeeded;
	Ret = DXP.SkillSystem.GetSkillLevelValue(TSkill);
	switch(DT)
	{
		default:
		 return 1.0;
		break;
	}
	Ret *= SpecMult;
	return Ret;
}

function VMDFrobHook(Actor Frobber, Inventory FrobWith)
{
	Super.VMDFrobHook(Frobber, FrobWith);
}

//MADDERS: Charge stacking nonsense.
function VMDSignalPickupUpdate()
{
	Super.VMDSignalPickupUpdate();
	
	if (ChargeStacks[NumCopies-1] <= 0)
	{
		ChargeStacks[NumCopies-1] = Charge;
	}
}

function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom)
{
	local ChargedPickup AT, AF;
	
	Super.VMDSignalCopiesAdded(AddTo, AddFrom);
	
	AT = ChargedPickup(AddTo);
	AF = ChargedPickup(AddFrom);
	
	if ((AT != None) && (AF != None))
	{
		if (AT.bActive)
		{
			AT.ChargeStacks[AT.NumCopies-1] = AT.ChargeStacks[AT.NumCopies-2];
			AT.ChargeStacks[AT.NumCopies-2] = AF.Charge;
		}
		else
		{
			AT.ChargeStacks[AT.NumCopies-1] = AF.Charge;
			AT.Charge = AF.Charge;
		}
	}
}

function VMDSignalCopiesRemoved()
{
	Super.VMDSignalCopiesRemoved();
	
	ChargeStacks[NumCopies] = 0;
	if (NumCopies > 0)
	{
		Charge = ChargeStacks[NumCopies-1];
	}
	bIsActive = false;
}

function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	local ChargedPickup D, P;
	
	Super.VMDSignalDropUpdate(Dropped, Parent);
	
	D = ChargedPickup(Dropped);
	P = ChargedPickup(Parent);
	
	if ((D != None) && (P != None))
	{
		D.Charge = P.ChargeStacks[P.NumCopies]; //-1
		D.ChargeStacks[0] = D.Charge;
		P.ChargeStacks[P.NumCopies] = 0; //-1
		P.Charge = P.ChargeStacks[P.NumCopies-1];
	}
}

function UseOnce()
{
	local ChargedPickup TCharge;
	local Inventory TInv;
	local VMDBufferPawn VMBP;
	
	if (NumCopies > 1)
	{
		//ChargeStacks[NumCopies-1] = 0;
		//Charge = ChargeStacks[NumCopies-2];
		//bIsActive = false;
	}
	
	VMBP = VMDBufferPawn(Owner);
	if ((NumCopies <= 0) && (VMBP != None) && (!VMBP.bHasAugmentations) && (!VMBP.Default.bFearEMP))
	{
		VMBP.bFearEMP = false;
		for (TInv = TInv.Inventory; TInv != None; TInv = TInv.Inventory)
		{
			TCharge = ChargedPickup(TInv);
			if ((TCharge != None) && (TCharge != Self))
			{
				VMBP.bFearEMP = true;
			}
		}
	}
	
	Super.UseOnce();
}

function TravelPostAccept()
{
    	Super.TravelPostAccept();
	
    	// Make the object follow us, for AmbientSound mainly
    	if (Owner != None)
    	{
        	AttachTag = Owner.Name;
        	SetPhysics(PHYS_Trailer);
    	}
}

function VMDUpdatePropertiesHook()
{
	Super.VMDUpdatePropertiesHook();
}

function int VMDConfigureMaxCopies()
{
	if (VMDHasSkillAugment('EnviroCopyStacks'))
	{
		return MaxCopies+2;
	}
	else if (VMDHasSkillAugment('EnviroCopies'))
	{
		return MaxCopies+1;
	}
	
	return MaxCopies;
}

//MADDEERS, cap off total charge during looting. Thermo camo, I'm looking at you.
function VMDSignalCorpseLooting()
{
	local float TMaxCharge, ChargePenalty, LootLevel;
	local DeusExPlayer DXP;
	
	TMaxCharge = MaxLootCharge;
	
	DXP = DeusExPlayer(GetPlayerPawn());
	if ((DXP != None) && (DXP.SkillSystem != None))
	{
		LootLevel = DXP.SkillSystem.GetSkillLevel(class'SkillEnviro');
		if (VMDHasSkillAugment('EnviroLooting'))
		{
			LootLevel *= 2;
		}
		ChargePenalty = (6.0 - LootLevel) / 6.0;
		ChargePenalty = ChargePenalty * TMaxCharge;
	}
	
	if (Charge > TMaxCharge-ChargePenalty) Charge = TMaxCharge-ChargePenalty;
}

//
// Give this inventory item to a pawn.
//
function GiveTo( pawn Other )
{
	local actor A;
	
	foreach BasedActors(class'Actor', A)
	{
		if (A.Base == Self)
			A.SetBase(None);
	}
	
	Instigator = Other;
	BecomeItem();
	Other.AddInventory( Self );
	GotoState('Idle2');
	
    	// Make the object follow us, for AmbientSound mainly
    	if (Owner != None)
    	{
        	AttachTag = Owner.Name;
        	SetPhysics(PHYS_Trailer);
    	}
}

function VMDActivateHook()
{
	Super.VMDActivateHook();
	
	LastActivationCharge = Charge;
}

function string VMDGetItemName()
{
	return ItemName@"("$int( (float(Charge)*100.0 / float(Default.Charge)) + 0.5 )$"%)";
}

defaultproperties
{
     //MADDERS additions.
     bLatentChargeCost=True
     ChargeLabel="charge remaining"
     StrSecondsLeft="(%d seconds)"
     MaxLootCharge=99999
     MsgCopiesAdded="You found %d %ss"
     MsgConflictingPickup="This wearable conflicts with the %s you are already wearing."
     
     MaxCopies=1
     bCanHaveMultipleCopies=True
     bOneUseOnly=True
     ActivateSound=Sound'DeusExSounds.Pickup.PickupActivate'
     DeActivateSound=Sound'DeusExSounds.Pickup.PickupDeactivate'
     ChargeRemainingLabel="Charge remaining:"
     bActivatable=True
     Charge=2000
}
