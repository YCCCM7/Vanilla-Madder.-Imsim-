//================================================================
// VMDAudioFudger. Spinoff of RenderFudger.
//================================================================
class VMDAudioFudger extends VMDFudgers config;

var config string AudioDevice;

static final function SetNewAudioDevice(string NewDevice)
{
	local Package LastOuterObject;
	local Name LastClassName;
	
	LastOuterObject = Default.Class.Outer;
	LastClassName = Default.Class.Name;
	
	Default.Class.Outer = class'Actor'.Outer;
	Default.Class.Name = 'Engine';
	Default.AudioDevice = NewDevice;
	
	StaticSaveConfig();
	
	Default.Class.Outer = LastOuterObject;
	Default.Class.Name = LastClassName;
}