//=============================================================================
// VMDMenuHousingPaintWindow
// Let us select some materials and paints.
//=============================================================================
class VMDMenuHousingPaintWindow expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow ExitButton, LinkButton;
var localized string ExitButtonText, LinkButtonText, LinkButtonTextSpecific;

var VMDPaintWarp TargetWarp;
var VMDHousingScriptedTextureManager TargetManager;
var VMDBufferPlayer WindowPlayer;

var VMDMenuHousingChoicePaintValue RGBSliders[3];
var VMDMenuHousingChoiceWallMaterial MaterialSlider;
var int CurPriceNeeded, OrigValues[3], CurValues[3], OrigTexArray, CurTexArray, ImprecisionLevel;

var VMDMenuUIInfoWindow WinInfo;

var VMDButtonPos WinInfoPos, WinInfoSize, SliderTagSize, MaterialSliderPos, MaterialSliderSize, RGBSliderPos[3], RGBSliderSize;
var localized string StrCurColor, StrOldColor, StrPaintPrice, StrCurColorSame, StrCurMaterial, StrOldMaterial, StrMaterialPrice, StrCurMaterialSame, StrFinalPrice, StrCurCredits;

// ----------------------------------------------------------------------
// MADDERS: 4/14/22: Vanilla function bullshit. Clustered together because it has minimal value.
// ----------------------------------------------------------------------

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

function bool CanStack()
{
	return false;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return false;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	return false;
}

event InitWindow()
{
	Super.InitWindow();
	
        ExitButton = WinButtonBar.AddButton(ExitButtonText, HALIGN_Left);
        LinkButton = WinButtonBar.AddButton(LinkButtonText, HALIGN_Right);
	CreateInfoWindow();
	CreateSliderWindows();
	
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateInfoWindow()
{
	if (WinClient != None)
	{
		WinInfo = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfo.SetPos(WinInfoPos.X, WinInfoPos.Y);
		WinInfo.SetSize(WinInfoSize.X, WinInfoSize.Y);
		WinInfo.SetText("");
	}
}

function CreateSliderWindows()
{
	local int i;
	
	for(i=0; i<ArrayCount(RGBSliders); i++)
	{
		RGBSliders[i] = VMDMenuHousingChoicePaintValue(WinClient.NewChild(Class'VMDMenuHousingChoicePaintValue'));
		RGBSliders[i].SetPos(RGBSliderPos[i].X, RGBSliderPos[i].Y);
		RGBSliders[i].BtnSlider.SetSize(RGBSliderSize.X, RGBSliderSize.Y);
		RGBSliders[i].SetSize(RGBSliderSize.X+SliderTagSize.X, RGBSliderSize.Y);
		RGBSliders[i].BtnSlider.SetTicks(255/ImprecisionLevel, 1, 255);
	}
	
	MaterialSlider = VMDMenuHousingChoiceWallMaterial(WinClient.NewChild(Class'VMDMenuHousingChoiceWallMaterial'));
	MaterialSlider.SetPos(MaterialSliderPos.X, MaterialSliderPos.Y);
	MaterialSlider.BtnSlider.SetSize(MaterialSliderSize.X, MaterialSliderSize.Y);
	MaterialSlider.SetSize(MaterialSliderSize.X, MaterialSliderSize.Y);
	MaterialSlider.BtnSlider.SetTicks(2, 0, 1);
}

event DestroyWindow()
{
	if ((TargetWarp != None) && (!TargetWarp.bDeleteMe))
	{
		TargetWarp.bHasWindow = false;
	}
	if (WindowPlayer != None)
	{
		WindowPlayer.OverrideCameraLocation = vect(0,0,0);
		WindowPlayer.OverrideCameraRotation = rot(0,0,0);
		WindowPlayer.CreateShadow();
	}
	if ((TargetManager != None) && (!TargetManager.bDeleteMe))
	{
		if (TargetManager.NumValidatedTextures > 1)
		{
			TargetManager.CurLoadedTexture = TargetManager.ValidatedTextures[OrigTexArray];
		}
		if (TargetManager.CurDynamicPalette.MonochromeColor.R != OrigValues[0] || TargetManager.CurDynamicPalette.MonochromeColor.G != OrigValues[1] || TargetManager.CurDynamicPalette.MonochromeColor.B != OrigValues[2])
		{
			TargetManager.CurDynamicPalette.MonochromeColor.R = OrigValues[0];
			TargetManager.CurDynamicPalette.MonochromeColor.G = OrigValues[1];
			TargetManager.CurDynamicPalette.MonochromeColor.B = OrigValues[2];
		}
		//TargetManager.SetCurLoadedPalette(GetOriginalPaletteArray());
	}
}

// ----------------------------------------------------------------------
// VANILLA SHIT END!
// ----------------------------------------------------------------------

function LoadColorTextureData()
{
	local Texture TTex, TColor;
	local string TexParse, ColParse;
	local int i;
	
	if ((TargetWarp != None) && (TargetManager != None))
	{
		TTex = TargetManager.CurLoadedTexture;
		//TColor = TargetManager.CurLoadedPalette;
		
		ColParse = string(TColor);
		
		if (TargetManager.CurDynamicPalette != None)
		{
			OrigValues[0] = TargetManager.CurDynamicPalette.MonochromeColor.R;
			OrigValues[1] = TargetManager.CurDynamicPalette.MonochromeColor.G;
			OrigValues[2] = TargetManager.CurDynamicPalette.MonochromeColor.B;
		}
		
		for (i=0; i<ArrayCount(OrigValues); i++)
		{
			//OrigValues[i] = int(Mid(ColParse, Len(ColParse)-(3 - i), 1));
			CurValues[i] = OrigValues[i];
			RGBSliders[i].SetColor(i, RGBSliderSize.X, OrigValues[i]);
		}
		
		if (TargetManager.NumValidatedTextures < 2)
		{
			MaterialSlider.SetPos(MaterialSliderPos.X+1024, MaterialSliderPos.Y);
			MaterialSlider.SetSensitivity(False);
		}
		else
		{
			OrigTexArray = TargetManager.CurTextureArray;
			CurTexArray = OrigTexArray;
			
			MaterialSlider.SetPos(MaterialSliderPos.X, MaterialSliderPos.Y);
			MaterialSlider.SetSensitivity(True);
			MaterialSlider.BtnSlider.SetTicks(TargetManager.NumValidatedTextures, 0, TargetManager.NumValidatedTextures-1);
			MaterialSlider.SetMaterial(MaterialSliderSize.X, CurTexArray);
		}
	}
}

function bool ChoseNewPaint()
{
	local int i;
	
	for (i=0; i<ArrayCount(CurValues); i++)
	{
		if (CurValues[i] != OrigValues[i])
		{
			return true;
		}
	}
	return false;
}

function bool ChoseNewMaterial()
{
	if (CurTexArray != OrigTexArray)
	{
		return true;
	}
	return false;
}

function bool ChoseNewStuff()
{
	return (ChoseNewMaterial() || ChoseNewPaint());
}

//0, 0, 1 = 0+0+1 = 1.
//0, 3, 1 = 0+12+1 = 13.
function int GetOriginalPaletteArray()
{
	local int Ret;
	
	Ret += OrigValues[0] * 16;
	Ret += OrigValues[1] * 4;
	Ret += OrigValues[2];
	
	return Ret;
}

function int GetCurrentPaletteArray()
{
	local int Ret;
	
	Ret += CurValues[0] * 16;
	Ret += CurValues[1] * 4;
	Ret += CurValues[2];
	
	return Ret;
}

function UpdateInfo()
{
	local int i;
	local string BuildStr;
	
	CurPriceNeeded = 0;
 	if (TargetWarp == None || TargetWarp.bDeleteMe || !TargetWarp.bHasWindow || TargetManager == None || TargetManager.bDeleteMe)
 	{
  		Root.PopWindow();
		return;
 	}
	else
	{
		for(i=0; i<ArrayCount(RGBSliders); i++)
		{
			CurValues[i] = RGBSliders[i].GetValue();
			if (CurValues[i] != OrigValues[i])
			{
				CurPriceNeeded = TargetWarp.PaintPrice;
			}
		}
		if (TargetManager.CurDynamicPalette != None)
		{
			if (TargetManager.CurDynamicPalette.MonochromeColor.R != CurValues[0] || TargetManager.CurDynamicPalette.MonochromeColor.G != CurValues[1] || TargetManager.CurDynamicPalette.MonochromeColor.B != CurValues[2])
			{
				TargetManager.CurDynamicPalette.MonochromeColor.R = CurValues[0];
				TargetManager.CurDynamicPalette.MonochromeColor.G = CurValues[1];
				TargetManager.CurDynamicPalette.MonochromeColor.B = CurValues[2];
			}
		}
		
		if (ChoseNewPaint())
		{
			BuildStr = SprintF(StrCurColor, CurValues[0], CurValues[1], CurValues[2]);
			BuildStr = BuildStr$CR()$SprintF(StrOldColor, OrigValues[0], OrigValues[1], OrigValues[2]);
			BuildStr = BuildStr$CR()$SprintF(StrPaintPrice, TargetWarp.PaintPrice);
		}
		else
		{
			BuildStr = SprintF(StrCurColorSame, CurValues[0], CurValues[1], CurValues[2])$CR()$CR();
		}
		
		//TargetManager.SetCurLoadedPalette(GetCurrentPaletteArray());
		//TargetManager.CurLoadedPalette = TargetManager.ValidatedPalettes[GetCurrentPaletteArray()];
		
		CurTexArray = MaterialSlider.GetValue();
		if (TargetManager.NumValidatedTextures > 1)
		{
			TargetManager.CurLoadedTexture = TargetManager.ValidatedTextures[CurTexArray];
			
			if (CurTexArray != OrigTexArray)
			{
				CurPriceNeeded += TargetWarp.MaterialPrice;
			}
			
			if (ChoseNewMaterial())
			{
				BuildStr = BuildStr$CR()$CR()$SprintF(StrCurMaterial, TargetManager.PoTextureNames[CurTexArray]);
				BuildStr = BuildStr$CR()$SprintF(StrOldMaterial, TargetManager.PoTextureNames[OrigTexArray]);
				BuildStr = BuildStr$CR()$SprintF(StrMaterialPrice, TargetWarp.MaterialPrice);
			}
			else
			{
				BuildStr = BuildStr$CR()$CR()$SprintF(StrCurMaterialSame, TargetManager.PoTextureNames[CurTexArray])$CR()$CR();
			}
			
		}
		else
		{
			BuildStr = BuildStr$CR()$CR()$CR()$CR();
		}
		
		if (ChoseNewStuff())
		{
			BuildStr = BuildStr$CR()$CR()$SprintF(StrFinalPrice, CurPriceNeeded);
		}
		else
		{
			BuildStr = BuildStr$CR()$CR();
		}
		BuildStr = BuildStr$CR()$SprintF(StrCurCredits, WindowPlayer.Credits);
		
		WinInfo.Clear();
		WinInfo.SetTitle(TargetWarp.SurfaceName);
		WinInfo.SetText(BuildStr);
	}
	
	LinkButton.SetButtonText(SprintF(LinkButtonTextSpecific, CurPriceNeeded));
	LinkButton.SetSensitivity(True);
	
	if (WindowPlayer.Credits < CurPriceNeeded || !ChoseNewStuff())
	{
		LinkButton.SetSensitivity(False);
	}
}

function LinkCurrentPaint()
{
	if ((WindowPlayer != None) && (TargetWarp != None) && (!TargetWarp.bDeleteMe) && (TargetManager != None) && (!TargetManager.bDeleteMe))
	{
		if ((WindowPlayer.Credits >= CurPriceNeeded) && (ChoseNewStuff()))
		{
			WindowPlayer.Credits -= CurPriceNeeded;
			
			//TargetManager.SavedPalette = string(TargetManager.CurLoadedPalette);
			if (TargetManager.CurDynamicPalette != None)
			{
				if (TargetManager.CurDynamicPalette.MonochromeColor.R != CurValues[0] || TargetManager.CurDynamicPalette.MonochromeColor.G != CurValues[1] || TargetManager.CurDynamicPalette.MonochromeColor.B != CurValues[2])
				{
					TargetManager.CurDynamicPalette.MonochromeColor.R = CurValues[0];
					TargetManager.CurDynamicPalette.MonochromeColor.G = CurValues[1];
					TargetManager.CurDynamicPalette.MonochromeColor.B = CurValues[2];
				}
				TargetManager.SavedR = CurValues[0];
				TargetManager.SavedG = CurValues[1];
				TargetManager.SavedB = CurValues[2];
			}
			
			if (TargetManager.NumValidatedTextures > 1)
			{
				TargetManager.CurTextureArray = CurTexArray;
				TargetManager.SavedTexture = string(TargetManager.CurLoadedTexture);
			}
			
			OrigValues[0] = CurValues[0];
			OrigValues[1] = CurValues[1];
			OrigValues[2] = CurValues[2];
			OrigTexArray = CurTexArray;
			
			TargetManager.SaveConfig();
			Root.PopWindow();
		}
	}
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case ExitButton:
			Root.PopWindow();
			bHandled = True;
		break;
		case LinkButton:
			LinkCurrentPaint();
			bHandled = True;
		break;
		default:
			bHandled = False;
		break;
	}
	
	return bHandled;
}

defaultproperties
{
     StrCurColor="New Color: (R=%d, G=%d, B=%d)"
     StrOldColor="Old Color: (R=%d, G=%d, B=%d)"
     StrPaintPrice="Paint Price: +%d Credits"
     StrCurColorSame="Color: [Same]" //(R=%d, G=%d, B=%d)
     StrCurMaterial="New Material: %s"
     StrOldMaterial="Old Material: %d"
     StrMaterialPrice="Material Price: +%d Credits"
     StrCurMaterialSame="Material: %s [Same]"
     StrFinalPrice="Final Price: %d Credits"
     StrCurCredits="%d Credits Remaining"
     
     WinInfoPos=(X=198,Y=17)
     WinInfoSize=(X=169,Y=143)
     
     ImprecisionLevel=16
     SliderTagSize=(X=67,Y=0)
     
     RGBSliderPos(0)=(X=4,Y=4)
     RGBSliderPos(1)=(X=4,Y=44)
     RGBSliderPos(2)=(X=4,Y=84)
     RGBSliderSize=(X=177,Y=40)
     
     MaterialSliderPos=(X=4,Y=124)
     MaterialSliderSize=(X=177,Y=40)
     
     Title="Material/Paint Selector"
     ExitButtonText="|&Cancel"
     LinkButtonText="|&Link Appearance"
     LinkButtonTextSpecific="|&Link Appearance [%d]"
     ClientWidth=384
     ClientHeight=176
     
     clientTextures(0)=Texture'VMDHousingPaintWindowBG01'
     clientTextures(1)=Texture'VMDHousingPaintWindowBG02'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=1
     TextureCols=2
}
