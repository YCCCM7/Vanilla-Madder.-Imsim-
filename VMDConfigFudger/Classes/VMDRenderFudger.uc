//================================================================
// VMDRenderFudger.
// MADDERS, 7/7/24: Okay, so, full notes...
// Method lent by the great witch Aizome8086.
// What we do is change render device in a shitty way.
// Kentie's often fucks up localization file and some other stuff.
// Launch has conflicting configuration and can't change VMDSim.exe's device.
// So instead, we use this to force a render device in a fucktacular way.
//================================================================
class VMDRenderFudger extends VMDFudgers config;

var config string GameRenderDevice;

static final function SetNewRenderDevice(string NewDevice)
{
	local Package LastOuterObject;
	local Name LastClassName;
	
	LastOuterObject = Default.Class.Outer;
	LastClassName = Default.Class.Name;
	
	Default.Class.Outer = class'Actor'.Outer;
	Default.Class.Name = 'Engine';
	Default.GameRenderDevice = NewDevice;
	
	StaticSaveConfig();
	
	Default.Class.Outer = LastOuterObject;
	Default.Class.Name = LastClassName;
}