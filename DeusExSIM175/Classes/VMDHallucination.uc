//=============================================================================
// Hallucination.
// Do a bunch of fancy, trippy shit, because we are not of this world.
// Even as a non-stoner, I fucking love this thing.
//=============================================================================
class VMDHallucination extends VMDSurrealDeco;

#exec OBJ LOAD FILE=VMDDrugFX

var bool bBobDown;
var float SpinRate, BobRate, BobHeight, CurBobHeight;

var bool bFatnessIn;
var byte FatnessMin, FatnessMax;
var float CurFatness, FatnessChangeRate;

var int UnlockIndex;

function ApplySpecialStats()
{
	//MADDERS, 1/11/21: Packing this up for early release. We'll appear again once we're properly relevant.
	Destroy();
}

function Tick(float DT)
{
	local Rotator R;
	local Vector V;
	local float UseRate;
	
	//----------------------------
	//MADDERS: Spin behavior!
	R.Yaw = SpinRate*DT;
	SetRotation(Rotation + R);
	
	//----------------------------
	//MADDERS: Bob behavior!
	UseRate = BobHeight*DT;
	if (BobHeight - CurBobHeight < BobHeight / 6 || CurBobHeight < BobHeight / 6) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 12 || CurBobHeight < BobHeight / 12) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 24 || CurBobHeight < BobHeight / 24) UseRate /= 2;
	
	if (!bBobDown)
	{
		if (CurBobHeight < BobHeight)
		{
			CurBobHeight += UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight > BobHeight)
			{
				V.Z -= (CurBobHeight - BobHeight);
				CurBobHeight = BobHeight;
				bBobDown = true;
			}
			SetLocation(Location + V);
 		}
 	}
	else
	{
		if (CurBobHeight > 0)
		{
			CurBobHeight -= UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight < 0)
			{
				V.Z -= (CurBobHeight);
				CurBobHeight = 0;
				bBobDown = false;
			}
			SetLocation(Location - V);
		}
	}
	
	//----------------------------
	//MADDERS: Fatness behavior!
	if (bFatnessIn)
	{
		if (CurFatness > FatnessMin)
		{
			CurFatness -= FatnessChangeRate;
			Fatness = int(CurFatness);
		}
		else
		{
			bFatnessIn = false;
		}
	}
	else
	{
		if (CurFatness < FatnessMax)
		{
			CurFatness += FatnessChangeRate;
			Fatness = int(CurFatness);
		}
		else
		{
			bFatnessIn = true;
		}
	}
	
	Super.Tick(DT);
}

defaultproperties
{
     FatnessMin=40
     FatnessMax=216
     FatnessChangeRate=4.000000
     CurFatness=128.000000
     SpinRate=24576
     BobRate=18.000000
     BobHeight=3.000000
     DrawScale=0.500000
     Physics=PHYS_None
     bInvincible=True
     bCanBeBase=False
     bPushable=False
     Style=STY_Masked
     ItemName="Hallucination[?]"
     Mesh=LodMesh'VMDHallucination'
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Mass=2.000000
     Buoyancy=3.000000
     ScaleGlow=1.500000
     //Texture=FireTexture'VMDDrugFX.Effects.ZymeDrugEffect'
     Texture=Texture'RainbowPalette'
}
