//=============================================================================
// ColorTheme
//=============================================================================
class ColorTheme extends Actor
	abstract;

Enum EColorThemeTypes
{
	CTT_Menu,
	CTT_HUD
};

var EColorThemeTypes themeType;
var String themeName;
var Bool bSystemTheme;			// Cannot delete these
var Name colorNames[15];
var config Color colors[15], DefaultColors[15]; //MADDERS, store this separately.
var travel ColorTheme next;
var Color colBad;				// Used when invalid index or color requested

// ----------------------------------------------------------------------
// GetColorFromName()
// ----------------------------------------------------------------------

function Color GetColorFromName(Name colorName)
{
	local int  colorIndex;

	colorIndex = GetColorIndex(colorName);

	if (colorIndex != -1)
		return colors[colorIndex];
	else
		return colBad;
}

// ----------------------------------------------------------------------
// GetColorIndex()
// ----------------------------------------------------------------------

function int GetColorIndex(Name colorName)
{
	local int colorIndex;
	local bool bColorNameFound;

	for(colorIndex=0; colorIndex<arrayCount(colorNames); colorIndex++)
	{
		if (colorNames[colorIndex] == colorName) 
		{
			bColorNameFound = True;
			break;
		}
	}

	if (bColorNameFound)
		return colorIndex;
	else
		return -1;
}

// ----------------------------------------------------------------------
// GetColor()
// ----------------------------------------------------------------------

function Color GetColor(Int colorIndex)
{
	if ((colorIndex >= 0) && (colorIndex < arrayCount(colorNames)))
		return colors[colorIndex];
	else
		return colBad;
}

// ----------------------------------------------------------------------
// SetColor()
// ----------------------------------------------------------------------

function SetColor(Int colorIndex, Color newColor)
{
	if ((colorIndex >= 0) && (colorIndex < arrayCount(colorNames)))
	{
		colors[colorIndex] = newColor;
	}
	SaveConfig();
}

// ----------------------------------------------------------------------
// SetColorFromName()
// ----------------------------------------------------------------------

function SetColorFromName(Name colorName, Color newColor)
{
	local int colorIndex;

	colorIndex = GetColorIndex(colorName);

	if (colorIndex != -1)
		SetColor(colorIndex, newColor);
}

// ----------------------------------------------------------------------
// GetColorCount()
// ----------------------------------------------------------------------

function int GetColorCount()
{	
	local int colorIndex;
	
	for(colorIndex=0; colorIndex<arrayCount(colors); colorIndex++)
	{
		if (colorNames[colorIndex] == '')
			break;
	}
	
	return colorIndex;
}

// ----------------------------------------------------------------------
// GetColorName()
// ----------------------------------------------------------------------

function Name GetColorName(Int colorIndex)
{
	if ((colorIndex >= 0) && (colorIndex < arrayCount(colorNames)))
		return colorNames[colorIndex];
	else
		return '';
}

// ----------------------------------------------------------------------
// IsSystemTheme()
// ----------------------------------------------------------------------

function Bool IsSystemTheme()
{
	return bSystemTheme;
}

// ----------------------------------------------------------------------
// SetThemeName()
// ----------------------------------------------------------------------

function SetThemeName(String newThemeName)
{
	themeName = newThemeName;
}

// ----------------------------------------------------------------------
// GetThemeName()
// ----------------------------------------------------------------------

function String GetThemeName()
{
	return themeName;
}

// ----------------------------------------------------------------------
// ResetThemeToDefault()
// ----------------------------------------------------------------------

function ResetThemeToDefault()
{
	local int colorIndex;

	for(colorIndex=0; colorIndex<arrayCount(colors); colorIndex++)
	{
		if (colorNames[colorIndex] != '')
		{
			//MADDERS, 9/13/21: Default.Colors does not actually work, fun fact.
			//We are SETTING the default, so reverting to it does fuck all.
			colors[colorIndex] = DefaultColors[colorIndex];
		}
	}
	SaveConfig();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colBad=(R=255,B=255)
     bHidden=True
     bTravel=True
     NetUpdateFrequency=1.000000
}
