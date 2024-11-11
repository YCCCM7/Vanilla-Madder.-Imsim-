//=============================================================================
// ComputerCameraUIChoice
//=============================================================================

class ComputerCameraUIChoice extends MenuUIChoiceEnum
	abstract;

var ComputerSecurityCameraWindow winCamera;
var ComputerScreenSecurity       securityWindow;

// Vanilla Matters
var() float TimeCost;

var int CurrentCamera;
var byte HackedAlready[3];
var ComputerSecurityCameraWindow Cameras[3];

// ----------------------------------------------------------------------
// SetCameraView()
// ----------------------------------------------------------------------

function SetCameraView(ComputerSecurityCameraWindow newCamera)
{
	local float TTimeCost;
    	local int i;
    	local string str;
	
    	winCamera = newCamera;
	
    	CurrentCamera = -1;
    	for ( i = 0; i < 3; i++ )
	{
	        if ( newCamera == Cameras[i] )
		{
            		// VM: Update time cost if it's present.
            		str = actionText;
            		if ((securityWindow.winTerm.bHacked) && (Cameras[i].camera != none))
			{
                		if ( HackedAlready[i] <= 0 )
				{
					TTimeCost = TimeCost * SecurityWindow.WinTerm.WinHack.GetAugmentScaling();
                    			if ( TTimeCost == int( TTimeCost ) )
					{
                        			str = str @ "(" $ int( TTimeCost ) $ ")";
                    			}
                    			else
					{
                        			str = str @ "(" $ FormatFloatString( TTimeCost, 0.1 ) $ ")";
                    			}
                		}
            		}
			
            		btnAction.SetButtonText( str );
			
         		CurrentCamera = i;
			
            		break;
        	}
    	}
	
    	if ( CurrentCamera < 0 )
	{
		str = ActionText;
		TTimeCost = TimeCost * SecurityWindow.WinTerm.WinHack.GetAugmentScaling();
		
                if ( TTimeCost == int( TTimeCost ) )
		{
                	str = str @ "(" $ int( TTimeCost ) $ ")";
                }
                else
		{
                	str = str @ "(" $ FormatFloatString( TTimeCost, 0.1 ) $ ")";
                }
		
        	btnAction.SetButtonText( str );
    	}
}

//MADDERS: Ours isn't static so I'm not fucking with it.
simulated function String FormatFloatString(float value, float precision)
{
	local string str;
	
	if (precision == 0.0)
		return "ERR";
	
	// build integer part
	str = String(Int(value));
	
	// build decimal part
	if (precision < 1.0)
	{
		value -= Int(value);
		str = str $ "." $ String(Int((0.5 * precision) + value * (1.0 / precision)));
	}
	
	return str;
}

// ----------------------------------------------------------------------
// SetSecurityWindow()
// ----------------------------------------------------------------------

function SetSecurityWindow(ComputerScreenSecurity newScreen)
{
	securityWindow = newScreen;
}

// ----------------------------------------------------------------------
// DisableChoice()
// ----------------------------------------------------------------------

function DisableChoice()
{
	btnAction.DisableWindow();
	btnInfo.DisableWindow();
}

// Vanilla Matters: Handle time cost.
function HandleTimeCost()
{
	if ((securityWindow.winTerm.bHacked) && (CurrentCamera >= 0))
	{
        	if (HackedAlready[CurrentCamera] <= 0)
		{
            		securityWindow.winTerm.winHack.AddTimeCost(TimeCost);
            		HackedAlready[CurrentCamera] = 1;
			
            		btnAction.SetButtonText(actionText);
        	}
    	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultInfoWidth=113
     defaultInfoPosX=154
}
