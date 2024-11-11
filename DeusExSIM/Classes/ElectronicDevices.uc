//=============================================================================
// ElectronicDevices.
//=============================================================================
class ElectronicDevices extends VMDBufferDeco
	abstract;

//Do we care if skill level is met for hacking?
var() bool bSkillFilterHacking;

//MADDERS: Limit PC usage based on skill level. Shit like this is arbitrary. ~That Guy, 1/29/06
//--------
//PS: Someone get TG to start labeling his freaking vars! ~Nick "NVS Hacker", 3/14/06

var() int HackSkillRequired; //0 = Trained, 1 = Advanced, and so on. -1 lets us be randomized, if the above bool is true.

defaultproperties
{
     bSkillFilterHacking=False
     HackSkillRequired=0
     
     bInvincible=True
     FragType=Class'DeusEx.PlasticFragment'
     bPushable=False
}
