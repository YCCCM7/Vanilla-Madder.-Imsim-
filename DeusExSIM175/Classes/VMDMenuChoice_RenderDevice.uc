//=============================================================================
// VMDMenuChoice_RenderDevice
//=============================================================================

class VMDMenuChoice_RenderDevice extends MenuChoice_LowMedHigh;

var bool bGaveWarning, bKnowsDevice;
var int MaxRenderDevice;
var string DefaultRenderDevices[12], ValidRenderDevices[12];
var localized string DefaultRenderDeviceNames[12], UnknownDeviceName, WarningHeader, WarningText;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

function InitWindow()
{
	Super.InitWindow();
	
	InitRenderDevices();
}

function InitRenderDevices()
{
	local int i;
	local string TDevice, GetDevice;
	local class<Object> LoadDevice;
	
	if (MaxRenderDevice > 0) return;
	
	GetDevice = CAPS(GetConfig("Engine.Engine", "GameRenderDevice"));
	for (i=0; i<ArrayCount(DefaultRenderDevices); i++)
	{
		if (DefaultRenderDevices[i] ~= TDevice)
		{
			//CurrentValue = i;
			break;
		}
		else if (i == ArrayCount(DefaultRenderDevices)-1)
		{
			CurrentValue = 0;
			ValidRenderDevices[MaxRenderDevice] = TDevice;
			EnumText[MaxRenderDevice] = UnknownDeviceName;
			MaxRenderDevice += 1;
		}
	}
	
	for(i=0; i<ArrayCount(DefaultRenderDevices); i++)
	{
		TDevice = DefaultRenderDevices[i];
		LoadDevice = class<Object>(DynamicLoadObject(TDevice, class'Class', true));
		if (LoadDevice != None)
		{
			if (TDevice ~= GetDevice)
			{
				CurrentValue = MaxRenderDevice;
			}
			ValidRenderDevices[MaxRenderDevice] = DefaultRenderDevices[i];
			EnumText[MaxRenderDevice] = DefaultRenderDeviceNames[i];
			MaxRenderDevice += 1;
		}
	}
	
	UpdateInfoButton();
}

// ----------------------------------------------------------------------
// CycleNextValue()
// ----------------------------------------------------------------------

function CycleNextValue()
{
	Super.CycleNextValue();
	
	GiveWarning();
}

// ----------------------------------------------------------------------
// CyclePreviousValue()
// ----------------------------------------------------------------------

function CyclePreviousValue()
{
	Super.CyclePreviousValue();
	
	GiveWarning();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	InitRenderDevices();
	
	UpdateInfoButton();
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	local string GetDevice, TDevice;
	
	GetDevice = CAPS(GetConfig("Engine.Engine", "GameRenderDevice"));
	TDevice = ValidRenderDevices[CurrentValue];
	
	if (CAPS(TDevice) != CAPS(GetDevice))
	{
		class'VMDRenderFudger'.Static.SetNewRenderDevice(TDevice);
	}
}

function GiveWarning()
{
	local DeusExRootWindow Root;
	local MenuScreenDisplay DirectGuy;
	
	if (bGaveWarning) return;
	
	Root = DeusExRootWindow(GetRootWindow());
	if (Root != None)
	{
		forEach AllObjects(class'MenuScreenDisplay', DirectGuy) break;
		
		if (DirectGuy != None)
		{
			Root.MessageBox(WarningHeader, WarningText, 1, False, DirectGuy);
		}
	}
	
	bGaveWarning = true;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     DefaultRenderDevices(0)="GlideDrv.GlideRenderDevice"
     DefaultRenderDevices(1)="SoftDrv.SoftwareRenderDevice"
     DefaultRenderDevices(2)="OpenGLDrv.OpenGLRenderDevice"
     DefaultRenderDevices(3)="D3DDrv.D3DRenderDevice"
     DefaultRenderDevices(4)="D3D9Drv.D3D9RenderDevice"
     DefaultRenderDevices(5)="D3D10Drv.D3D10RenderDevice"
     DefaultRenderDevices(6)="D3D11Drv.D3D11RenderDevice"
     
     DefaultRenderDeviceNames(0)="Glide (OLD)"
     DefaultRenderDeviceNames(1)="Soft (OLD)"
     DefaultRenderDeviceNames(2)="Open GL"
     DefaultRenderDeviceNames(3)="DX 7 (OLD)"
     DefaultRenderDeviceNames(4)="DX 9"
     DefaultRenderDeviceNames(5)="DX 10"
     DefaultRenderDeviceNames(6)="DX 11"
     UnknownDeviceName="Unknown"
     
     WarningHeader="Restart Required"
     WarningText="You must restart the game for this option to take effect."
     
     defaultInfoWidth=98
     HelpText="Change the video device used to render the game"
     actionText="Re|&nder Device"
     configSetting=""
}
