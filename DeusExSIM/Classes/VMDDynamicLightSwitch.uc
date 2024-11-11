//=============================================================================
// VMDDynamicLightSwitch.
//=============================================================================
class VMDDynamicLightSwitch extends LightSwitch;

var() bool bStartOff;

function ApplySpecialStats()
{
	Super.ApplySpecialStats();
	
	if (bStartOff)
	{
		ToggleLights();
	}
}

function ToggleLights()
{
	local Light L;
	local int Count;
	local VMDBufferPlayer VMP;
	
	forEach AllActors(class'Light', L, Event)
	{
		if (L != None)
		{
			if (L.LightBrightness == 0) L.LightBrightness = L.BlendTweenRate[3];
			else
			{
				L.BlendTweenRate[3] = L.LightBrightness;
				L.LightBrightness = 0;
			}
			Count++;
		}
	}
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((Count > 0) && (GetPlayerPawn() != None))
	{
		//Flush GCache.
		if ((VMP != None) && (VMP.bD3DPrecachingEnabled))
		{
			VMP.ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
			VMP.ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
			VMP.ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
			VMP.ConsoleCommand("Flush");
			VMP.ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
			VMP.ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
			VMP.ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
		}
		else
		{
			GetPlayerPawn().ConsoleCommand("Flush");
		}
	}
}

function Frob(Actor Frobber, Inventory frobWith)
{
	ToggleLights();
	
	Super.Frob(Frobber, FrobWith);
}

singular function SupportActor(Actor standingActor)
{
	// do nothing
}

function Bump(actor Other)
{
	// do nothing
}

defaultproperties
{
}
