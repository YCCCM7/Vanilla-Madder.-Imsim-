//=============================================================================
// Cart.
//=============================================================================
class Cart extends VMDBufferDeco;

var float rollTimer;
var float pushTimer;
var vector pushVel;
var bool bJustPushed;

function StartRolling(vector vel)
{
	// Transfer momentum
	SetPhysics(PHYS_Rolling);
	pushVel = Vel;
	pushVel.Z = 0;
	Velocity = pushVel;
	rollTimer = 2;
	bJustPushed = True;
	pushTimer = 0.5;
	AmbientSound = Sound'UtilityCart';
}

//
// give us velocity in the direction of the push
//
function Bump(actor Other)
{
	if (bJustPushed)
		return;

	if ((Other != None) && (Physics != PHYS_Falling))
		if (abs(Location.Z-Other.Location.Z) < (CollisionHeight+Other.CollisionHeight-1))  // no bump if landing on cart
			StartRolling(0.25*Other.Velocity*Other.Mass/Mass);
}

//
// simulate less friction (wheels)
//
function Tick(float deltaTime)
{
	Super.Tick(deltaTime);
	
	if ((Physics == PHYS_Rolling) && (rollTimer > 0))
	{
		rollTimer -= deltaTime;
		Velocity = pushVel;
		
		if (pushTimer > 0)
			pushTimer -= deltaTime;
		else
			bJustPushed = False;
	}
	
	// make the sound pitch depend on the velocity
	if (VSize(Velocity) > 1)
	{
		SoundPitch = Clamp(2*VSize(Velocity), 32, 64);
	}
	else
	{
		// turn off the sound when it stops
		AmbientSound = None;
		SoundPitch = Default.SoundPitch;
	}
}

//MADDERS: Fix for landing stopping the cart's operation.
function Landed(vector HitNormal)
{
	local float VelMod;
	
	Super.Landed(HitNormal);
	
	//MADDERS: Apply rolling velocity based on speed.
	//Vertical falling = speed loss
	//Horizontal falling = speed gain (sliding down stairs)
	VelMod = (Abs(Velocity.Z) / 200);
	if (VelMod < 0.25) VelMod = 0.25;
	StartRolling(Velocity / VelMod);
	
	//Lower the duration we roll for, since we're moving as such.
	RollTimer = 1.0 / VelMod;
}

//MADDERS: Misc function for returning -1 or 1 based on negative or positive numbers, respectively.
function float Sign(float In)
{
	if (In == 0) return 0;
	return (In / Abs(In));
}

defaultproperties
{
     bBlockSight=True
     bCanBeBase=True
     ItemName="Utility Push-Cart"
     Mesh=LodMesh'DeusExDeco.Cart'
     SoundRadius=16
     CollisionRadius=28.000000
     CollisionHeight=26.780001
     Mass=40.000000
     Buoyancy=45.000000
}
