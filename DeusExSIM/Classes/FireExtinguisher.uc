//=============================================================================
// FireExtinguisher.
//=============================================================================
class FireExtinguisher extends DeusExPickup;

#exec OBJ LOAD FILE=Ambient

var MobileProjectileGenerator gen;
var localized string MsgNotInHand;

function Timer()
{
	Destroy();
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local Vector loc;
		local Rotator rot;
		local DeusExPlayer DXP;
		local ScriptedPawn SP;
		
		Super.BeginState();
		
		DXP = DeusExPlayer(Owner);
		SP = ScriptedPawn(Owner);
		
		// force-extinguish the player
		if (DXP != None)
		{
		 	if (DXP.bOnFire)
			{
				DeusExPlayer(Owner).ExtinguishFire();
			}
		}
		else if ((SP != None) && (Animal(Owner) == None) && (Robot(Owner) == None))
		{
			if (SP.bOnFire)
			{
				SP.ExtinguishFire();
			}
		}
		
		// spew halon gas
		if (DXP != None)
		{
			rot = DXP.ViewRotation;
			loc = Vector(rot) * Owner.CollisionRadius;
			loc.Z += Owner.CollisionHeight * 0.9;
			loc += Owner.Location;
		}
		else if (SP != None)
		{
			rot = SP.Rotation;
			//MADDERS, 7/6/24: This looks like shit.
			//loc = Vector(rot) * Owner.CollisionRadius;
			//loc.Z += Owner.CollisionHeight * 0.9;
			loc = Owner.Location;
		}
		
		gen = Spawn(class'MobileProjectileGenerator', None,, loc, rot);
		if (gen != None)
		{
			gen.ProjectileClass = class'HalonGas';
			gen.SetBase(Owner);
			gen.SetOwner(Owner);
			gen.LifeSpan = 4; //3
			gen.ejectSpeed = 300;
			gen.projectileLifeSpan = 1.5;
			gen.frequency = 0.9;
			gen.checkTime = 0.1;
			gen.bAmbientSound = True;
			gen.AmbientSound = sound'SteamVent2';
			gen.SoundVolume = 192;
			gen.SoundPitch = 32;
		}

		// blast for 3 seconds, then destroy
		//G-Flex: *properly* extend to 4 seconds
		SetTimer(4.0, False); //3.0
	}
	function Tick(float deltaTime)
	{
		Super.Tick(deltaTime);
		
		if (gen != None)
		{
			if (Owner == None || Owner.IsInState('Dying'))
			{
				Gen.Destroy();
				Destroy();
			}
			else if (DeusExPlayer(Owner) != None)
			{
				//G-Flex: make spray face same way as player
				gen.SetRotation(Pawn(Owner).ViewRotation);
				//G-Flex: stop spraying if out of hand
				//G-Flex: then destroy extinguisher
				if (DeusExPlayer(Owner).inHand != Self)
				{
					gen.Destroy();
					Destroy();
				}
			}
			else if (ScriptedPawn(Owner) != None)
			{
				//MADDERS, 7/6/24: What that guy said.
				gen.SetRotation(Pawn(Owner).Rotation);
			}
		}
	}
	function EndState()
	{
		Super.EndState();
		if (gen != None)
		{
			gen.Destroy();
			gen = None;
			Destroy();
		}
		
		if (VMDBufferPawn(Owner) != None)
		{
			VMDBufferPawn(Owner).ActiveExtinguisher = None;
		}
	}
Begin:
}

state DeActivated
{
}

function bool VMDHasActivationObjection()
{
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).InHand != Self))
	{
		DeusExPlayer(Owner).ClientMessage(MsgNotInHand);
		return true;
	}
	return false;
}

defaultproperties
{
     MsgNotInHand="The extinguisher must be in hand first"
     M_Activated="You spray the %s"
     bVolatile=True
     
     bActivatable=True
     ItemName="Fire Extinguisher"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.FireExtinguisher'
     PickupViewMesh=LodMesh'DeusExItems.FireExtinguisher'
     ThirdPersonMesh=LodMesh'DeusExItems.FireExtinguisher'
     LandSound=Sound'DeusExSounds.Generic.GlassDrop'
     Icon=Texture'DeusExUI.Icons.BeltIconFireExtinguisher'
     largeIcon=Texture'DeusExUI.Icons.LargeIconFireExtinguisher'
     largeIconWidth=25
     largeIconHeight=49
     Description="A chemical fire extinguisher."
     beltDescription="FIRE EXT"
     Mesh=LodMesh'DeusExItems.FireExtinguisher'
     CollisionRadius=8.000000
     CollisionHeight=10.270000
     Mass=4.000000
     Buoyancy=2.500000
}