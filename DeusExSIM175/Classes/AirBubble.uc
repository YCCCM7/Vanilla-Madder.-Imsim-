//=============================================================================
// AirBubble.
//=============================================================================
class AirBubble extends Effects;

var() float RiseRate;
var vector OrigVel;
var Class<Effects> EmitOnSurface; // An effect to emit when we surface

auto state Flying
{
	simulated function Tick(float deltaTime)
	{
		Velocity.X = OrigVel.X + 8 - FRand() * 17;
		Velocity.Y = OrigVel.Y + 8 - FRand() * 17;
		Velocity.Z = RiseRate * (FRand() * 0.2 + 0.9);

		if (!Region.Zone.bWaterZone)
			Destroy();
	}
	
	//== Spawn a little ring when we hit the surface
	//--------------------
	//MADDERs, 11/6/22: Some changes made for new zone controlling BS.
	simulated function ZoneChange(ZoneInfo NewZone)
	{
		local actor splash;
		local VMDWaterLevelActor TAct;
		local Vector TLoc;

		if ((NewZone != None) && (!NewZone.bWaterZone) && (Region.Zone != None) && (Region.Zone.bWaterZone))
		{
			if ((WaterZone(Region.Zone) != None) && (WaterZone(Region.Zone).OwningTrigger != None))
			{
				TAct = WaterZone(Region.Zone).OwningTrigger.WaterLevelActor;
			}
			
			if(Region.Zone.ExitActor != None)
			{
				TLoc = Location;
				if (TAct != None)
				{
					TLoc.Z = TAct.Location.Z;
				}
				splash = Spawn(Region.Zone.ExitActor,,, TLoc);
				if ( splash != None )
				{
					splash.DrawScale = DrawScale;
					splash.LifeSpan = 0.300000;
					if(WaterRing(splash) != None)
					{
						WaterRing(splash).bNoExtraRings = True;
						
						if (TAct != None)
						{
							Splash.SetBase(TAct);
						}
					}
				}

				if(EmitOnSurface != None)
				{
					splash = Spawn(EmitOnSurface);

					if(splash != None)
					{
						splash.Velocity.Z = Velocity.Z;

						if(Effects(splash) != None)
							splash.DrawScale = DrawScale;

						//== Special cases, because nobody could think to have a unified RiseRate variable
						if(SmokeTrail(splash) != None)
						{
//							SmokeTrail(splash).RiseRate = RiseRate;
							SmokeTrail(splash).OrigVel.Z = Velocity.Z;
						}
					}
				}
			}
		}
		Super.ZoneChange(NewZone);
	}
	
	simulated function BeginState()
	{
		Super.BeginState();

		OrigVel = Velocity;
		DrawScale += FRand() * 0.1;
	}
}

defaultproperties
{
     RiseRate=50.000000
     Physics=PHYS_Projectile
     LifeSpan=10.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'DeusExItems.Skins.FlatFXTex45'
     DrawScale=0.050000
}
