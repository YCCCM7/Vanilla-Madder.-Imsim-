//=============================================================================
// SkillRadioBox
//=============================================================================
class SkillRadioBox extends RadioBoxWindow;

var TileWindow skillWindow;

event InitWindow()
{
	Super.InitWindow();

	skillWindow = TileWindow(NewChild(Class'TileWindow'));
}

defaultproperties
{
}
