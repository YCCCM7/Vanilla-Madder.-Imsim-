//=============================================================================
// AmmoCrate
//=============================================================================
class AmmoCrate extends Containers;

var localized String AmmoReceived;

//MADDERS vars
var localized string AmmoCooldown, MsgCooldownTime;
var float PickupCooldown, PickupCooldownMax, SavedScaleGlow;

// ----------------------------------------------------------------------
// Frob()
//
// If we are frobbed, trigger our event
// ----------------------------------------------------------------------
function Frob(Actor Frobber, Inventory frobWith)
{
	local Actor A;
	local Pawn P;
	local DeusExPlayer Player;
   	local Inventory CurInventory;
	
	//Don't call superclass frob.
	P = Pawn(Frobber);
	Player = DeusExPlayer(Frobber);
	
	if (Player != None)
	{
		if (PickupCooldown > 0.0)
		{
			Player.ClientMessage(SprintF(AmmoCooldown, int(PickupCooldown)));
		}
		else
		{
			SavedScaleGlow = ScaleGlow;
			PickupCooldown = PickupCooldownMax;
			CurInventory = Player.Inventory;
			while (CurInventory != None)
			{
				if (CurInventory.IsA('DeusExWeapon'))
					RestockWeapon(Player,DeusExWeapon(CurInventory));
				CurInventory = CurInventory.Inventory;
			}
			Player.ClientMessage(AmmoReceived);
			PlaySound(sound'WeaponPickup', SLOT_None, 0.5+FRand()*0.25, , 256, 0.95+FRand()*0.1);
		}
	}
}

function RestockWeapon(DeusExPlayer Player, DeusExWeapon WeaponToStock)
{
   	local Ammo AmmoType;
	
 	if (WeaponToStock.AmmoType != None)
	{
		if (Level.Netmode != NM_Standalone)
		{
      			if (WeaponToStock.AmmoNames[0] == None)
         			AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoName));
      			else
         			AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoNames[0]));
      			
      			if ((AmmoType != None) && (AmmoType.AmmoAmount < WeaponToStock.PickupAmmoCount))
      			{
         			AmmoType.AddAmmo(WeaponToStock.PickupAmmoCount - AmmoType.AmmoAmount);
      			}
		}
		//MADDERS: SP support, because why not?
		else
		{
			WeaponToStock.AmmoType.AddAmmo(WeaponToStock.AmmoType.Default.AmmoAmount);
		}
	}
}

function Tick(float DT)
{
	//Flicker effect during reloading.
	if (PickupCooldown > 0.0)
	{
	 	ScaleGlow = SavedScaleGlow * 2 * (PickupCooldown % 0.65);
	 	PickupCooldown -= DT;
	}
	else if (PickupCooldown < 0.0)
	{
	 	PickupCooldown = 0;
	 	ScaleGlow = SavedScaleGlow;
	}
	Super.Tick(DT);
}

function string VMDGetItemName()
{
	local string Ret;
	
	Ret = ItemName;
	
	if (PickupCooldown > 0)
	{
		Ret = Ret$Chr(13)$Chr(10)$SprintF(MsgCooldownTime, int(PickupCooldown + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     MsgCooldownTime="(%d sec. until restock)"
     AmmoReceived="Ammo restocked"
     PickupCooldownMax=60.000000
     AmmoCooldown="Restocking... %d seconds left..."
     HitPoints=4000
     bFlammable=False
     ItemName="Ammo Crate"
     bPushable=False
     bBlockSight=True
     Mesh=LodMesh'DeusExItems.DXMPAmmobox'
     bAlwaysRelevant=True
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     Mass=3000.000000
     Buoyancy=40.000000
     bInvincible=True
}
