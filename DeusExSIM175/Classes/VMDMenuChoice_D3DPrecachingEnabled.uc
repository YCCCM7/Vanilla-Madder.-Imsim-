//=============================================================================
// VMDMenuChoice_D3DPrecachingEnabled
//=============================================================================
class VMDMenuChoice_D3DPrecachingEnabled extends MenuUIChoiceEnum;

var bool bCached;

//MADDERS: Two situations when this object initializes:
//1. We started cached, at which point changing the value can store that we've ever cached.
//2. We we started not cached, at which point being changed to true will run the first ever cache.
//Either way, we'll never cache unnecessarily.
function CycleNextValue()
{
	Super.CycleNextValue();
	if ((!bCached) && (GetValue() == 0) && (GetPlayerPawn() != None))
	{
		GetPlayerPawn().ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
		GetPlayerPawn().ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
		GetPlayerPawn().ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
		GetPlayerPawn().ConsoleCommand("FLUSH");
		GetPlayerPawn().ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
		GetPlayerPawn().ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
		GetPlayerPawn().ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
	}
	bCached = true;
}

function CyclePreviousValue()
{
	Super.CyclePreviousValue();
	if ((!bCached) && (GetValue() == 0) && (GetPlayerPawn() != None))
	{
		GetPlayerPawn().ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
		GetPlayerPawn().ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
		GetPlayerPawn().ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
		GetPlayerPawn().ConsoleCommand("FLUSH");
		GetPlayerPawn().ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
		GetPlayerPawn().ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
		GetPlayerPawn().ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
	}
	bCached = true;
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bD3DPrecachingEnabled));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bD3DPrecachingEnabled = !bool(GetValue());
}

// ----------------------------------------------------------------------
// ResetToDefault()
// ----------------------------------------------------------------------

function ResetToDefault()
{
	SetValue(defaultValue);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     enumText(0)="Enabled"
     enumText(1)="Disabled"
     defaultValue=1
     defaultInfoWidth=88
     HelpText="Whether Direct 3D 9, 10, and 11 precache. Disabling this saves load time but potentially lowers output FPS. Precaching is only ran when loading maps or save files."
     actionText="|&D3D Precaching"
}
