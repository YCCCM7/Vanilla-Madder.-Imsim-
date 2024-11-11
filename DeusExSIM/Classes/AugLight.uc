//=============================================================================
// AugLight.
//=============================================================================
class AugLight extends VMDBufferAugmentation;

var Beam b1, b2, b3; // Transcended - A third light, just for bSpecialLit surfaces
var Beam b4, b5, b6; // Transcended - Spydrone lights

function PreTravel()
{
	// make sure we destroy the light before we travel
	if (b1 != None)
	{
		b1.Destroy();
		b1 = None;
	}
	if (b2 != None)
	{
		b2.Destroy();
		b2 = None;
	}
	if (b3 != None)
	{
		b3.Destroy();
		b3 = None;
	}
	if (b4 != None)
	{
		b4.Destroy();
		b4 = None;
	}
	if (b5 != None)
	{
		b5.Destroy();
		b5 = None;
	}
	if (b6 != None)
	{
		b6.Destroy();
		b6 = None;
	}
}

function SetBeamLocation()
{
	local bool bLowPowerMode;
	local float dist, size, radius, brightness;
	local Vector HitNormal, HitLocation, StartTrace, EndTrace;
	local Pawn TPawn;
	
	bLowPowerMode = VMDUseLowPowerMode();
	
	TPawn = Player;
	if (TPawn == None) TPawn = VMBP;
	
	if (TPawn != None)
	{
		if (b1 != None)
		{
			StartTrace = TPawn.Location;
			StartTrace.Z += TPawn.BaseEyeHeight;
			EndTrace = StartTrace + LevelValues[CurrentLevel] * Vector(TPawn.ViewRotation);
			
			Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
			if (HitLocation == vect(0,0,0))
			{
				HitLocation = EndTrace;
			}
			
			dist = VSize(HitLocation - StartTrace);
			size = fclamp(dist/LevelValues[CurrentLevel], 0, 1);
			
			radius = size*5.12 + 4.0;
			if (bLowPowerMode) Radius *= 0.5;
			
			b1.SetLocation(HitLocation-vector(TPawn.ViewRotation)*64);
			b1.LightRadius = byte(radius);
			b1.LightType = LT_Steady;
			
			//brightness = fclamp(size-0.5, 0, 1)*2*-192 + 192;
			//b1.LightBrightness = byte(brightness);  // someday we should put this back in again
			
			Brightness = 192;
			if (bLowPowerMode) Brightness = 48;
			b1.LightBrightness = Brightness;
			
			if (bLowPowerMode)
			{
				b1.LightHue = 140;
			}
			else
			{
				b1.LightHue = 32;
			}
		}
		if (b2 != None)
		{
			Radius = 4;
			if (bLowPowerMode) Radius *= 0.5;
			B2.LightRadius = byte(Radius);
			
			Brightness = 220;
			if (bLowPowerMode) Brightness = 55;
			B2.LightBrightness = Brightness;
			
			if (bLowPowerMode)
			{
				b2.LightHue = 140;
			}
			else
			{
				b2.LightHue = 32;
			}
		}
		if (b3 != None)
		{
			StartTrace = TPawn.Location;
			StartTrace.Z += TPawn.BaseEyeHeight;
			EndTrace = StartTrace + LevelValues[CurrentLevel] * Vector(TPawn.ViewRotation);
			
			Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
			if (HitLocation == vect(0,0,0))
			{
				HitLocation = EndTrace;
			}
			
			dist = VSize(HitLocation - StartTrace);
			size = dist/1024.0; //fclamp(dist/1024.0, 0, 1);
			
			radius = size*5.12 + 4.0;
			if (bLowPowerMode) Radius *= 0.5;
			
			b3.SetLocation(HitLocation-vector(TPawn.ViewRotation)*64);
			b3.LightRadius = byte(radius);
			b3.LightType = LT_Steady;
			b3.bSpecialLit = True;
			
			//brightness = fclamp(size-0.5, 0, 1)*2*-192 + 192;
			//b3.LightBrightness = byte(brightness);  // someday we should put this back in again
			
			Brightness = 192;
			if (bLowPowerMode) Brightness = 48;
			b3.LightBrightness = Brightness;
			
			if (bLowPowerMode)
			{
				b3.LightHue = 140;
			}
			else
			{
				b3.LightHue = 32;
			}
		}
		
		if ((Player != None) && (Player.aDrone != None))
		{
			if (b4 != None)
			{
				StartTrace = Player.aDrone.Location;
				EndTrace = StartTrace + LevelValues[CurrentLevel] * Vector(Player.aDrone.Rotation);
				
				Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
				if (HitLocation == vect(0,0,0))
				{
					HitLocation = EndTrace;
				}
				
				dist = VSize(HitLocation - StartTrace);
				size = (((dist / 250) * -1) * ((dist / 250) * -1));
				radius = 5;
				brightness = fclamp(size-0.5, 0, 1)*2*-192 + 192;
				b4.SetLocation(HitLocation-vector(Player.aDrone.Rotation)*64);
				b4.LightRadius = byte(radius);
				b4.LightType = LT_Steady;
			}
			if (b6 != None)
			{
				StartTrace = Player.aDrone.Location;
				EndTrace = StartTrace + LevelValues[CurrentLevel] * Vector(Player.aDrone.Rotation);
				
				Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
				if (HitLocation == vect(0,0,0))
				{
					HitLocation = EndTrace;
				}
				
				dist = VSize(HitLocation - StartTrace);
				size = (((dist / 250) * -1) * ((dist / 250) * -1));
				radius = 5;
				brightness = fclamp(size-0.5, 0, 1)*2*-192 + 192;
				b6.SetLocation(HitLocation-vector(Player.aDrone.Rotation)*64);
				b6.LightRadius = byte(radius);
				b6.LightType = LT_Steady;
				b6.bSpecialLit = True;
			}
		}
	}
}

function vector SetGlowLocation()
{
	local vector pos;
	local Pawn TPawn;
	
	TPawn = Player;
	if (TPawn == None) TPawn = VMBP;
	
	if (TPawn != None)
	{
		if (b2 != None)
		{
			pos = TPawn.Location + vect(0,0,1)*TPawn.BaseEyeHeight +
			      vect(1,1,0)*vector(TPawn.Rotation)*TPawn.CollisionRadius*1.5;
			b2.SetLocation(pos);
		}
		
		if ((b5 != None) && (Player != None) && (Player.ADrone != None))
		{
			pos = Player.aDrone.Location +
			      vect(1,1,0)*vector(Player.aDrone.Rotation)*Player.CollisionRadius*1.5;
			b5.SetLocation(pos);
		}
	}
}

state Active
{
	function Tick (float deltaTime)
	{
		SetBeamLocation();
		SetGlowLocation();
	}
	
	function BeginState()
	{
		local Pawn TPawn;
		
		Super.BeginState();
		
		TPawn = Player;
		if (TPawn == None) TPawn = VMBP;
		
		if (TPawn != None)
		{
			b1 = Spawn(class'Beam', TPawn, '', TPawn.Location);
			if (b1 != None)
			{
				AIStartEvent('Beam', EAITYPE_Visual);
				b1.LightHue = 32;
				b1.LightRadius = 4;
				b1.LightSaturation = 140;
				b1.LightBrightness = 192;
				SetBeamLocation();
			}
			b2 = Spawn(class'Beam', TPawn, '', TPawn.Location);
			if (b2 != None)
			{
				b2.LightHue = 32;
				b2.LightRadius = 4;
				b2.LightSaturation = 140;
				b2.LightBrightness = 220;
				SetGlowLocation();
			}
			b3 = Spawn(class'Beam', TPawn, '', TPawn.Location);
			if (b3 != None)
			{
				AIStartEvent('Beam', EAITYPE_Visual);
				b3.LightHue = 32;
				b3.LightRadius = byte(2 * (CurrentLevel + 1)); //4;
				b3.LightSaturation = 140;
				b3.LightBrightness = 192;
				SetBeamLocation();
			}
			
			if ((Player != None) && (Player.aDrone != None))
			{
				VMDSpawnDroneLight(Player.ADrone);
			}
		}
	}

Begin:
}

function Deactivate()
{
	Super.Deactivate();
	if (b1 != None)
	{
		b1.Destroy();
		b1 = None;
	}
	if (b2 != None)
	{
		b2.Destroy();
		b2 = None;
	}
	if (b3 != None)
	{
		b3.Destroy();
		b3 = None;
	}
}

//MADDERS, 9/25/22: Hack for low power mode on this bad boy.
simulated function float GetEnergyRate()
{
	if (VMDUseLowPowerMode())
	{
		return 0;
	}
	
	return EnergyRate;
}

function VMDSpawnDroneLight(SpyDrone TDrone)
{
	if ((TDrone != None) && (Player != None))
	{
		b4 = Spawn(class'Beam', Player, '', Player.Location);
		if (b4 != None)
		{
			AIStartEvent('Beam', EAITYPE_Visual);
			b4.LightHue = 140;
			b4.LightRadius = 1;
			b4.LightSaturation = 80;
			b4.LightBrightness = 128;
			SetBeamLocation();
		}
		b5 = Spawn(class'Beam', Player, '', Player.Location);
		if (b5 != None)
		{
			b5.LightHue = 140;
			b5.LightRadius = 4;
			b5.LightSaturation = 140;
			b5.LightBrightness = 220;
			SetGlowLocation();
		}
		b6 = Spawn(class'Beam', Player, '', Player.Location);
		if (b6 != None)
		{
			AIStartEvent('Beam', EAITYPE_Visual);
			b6.LightHue = 140;
			b6.LightRadius = 1;
			b6.LightSaturation = 80;
			b6.LightBrightness = 128;
			SetBeamLocation();
		}
	}
}

function bool VMDUseLowPowerMode()
{
	if ((Player != None) && (Player.Energy <= 5))
	{
		return true;
	}
	if ((VMBP != None) && (VMBP.Energy <= 5))
	{
		return true;
	}
	
	return false;
}

defaultproperties
{
     EnergyRate=10.000000
     MaxLevel=0
     Icon=Texture'DeusExUI.UserInterface.AugIconLight'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconLight_Small'
     AugmentationName="Light"
     Description="Bioluminescent cells within the retina provide coherent illumination of the agent's field of view. When energy reserves are virtually depleted, the light will instead operate in 'low power' mode, operating at no further cost, but reduced output.|n|nNO UPGRADES"
     LevelValues(0)=1024.000000
     AugmentationLocation=LOC_Default
     MPConflictSlot=10
}
