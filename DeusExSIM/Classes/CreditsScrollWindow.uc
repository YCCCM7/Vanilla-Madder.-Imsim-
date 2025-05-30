//=============================================================================
// CreditsScrollWindow
//=============================================================================
class CreditsScrollWindow extends DeusExBaseWindow;

var TileWindow   winScroll;
var Window       winFadeBottom;
var Window       winFadeTop;
var String       ScrollMusicString;
var int		     savedSongSection;
var Bool         bRenderingEnabled;
var Float        currentScrollSpeed;
var Bool         bBold;
var bool         bLoadIntro;
var bool         bScrolling;

// Defaults
var Name         textName;
var Float        scrollSpeed;
var Float        minScrollSpeed;
var Float        maxScrollSpeed;
var Float        speedAdjustment;
var Int          blankLineHeight;
var Int          maxTileWidth;
var Int          maxTextWidth;
var Font         fontHeader;
var Font         fontText;
var Color        colHeader;
var Color        colText;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	SetBackgroundStyle(DSTY_Normal);
	SetBackground(Texture'Solid');
	SetTileColor(colBlack);

	StopRendering();
	CreateControls();
	StartMusic();
	
	//MADDERS, 2/24/21: Late addition, I hate to admit. Didn't expect so many last minute flexes from Hawk, G-Flex, and similar.
	if (CreditsWindow(Self) != None) // Not QuotesWindow, from DXT, pasted in finally at 5/24/23.
	{
		TransVMDCredits();
	}
	ProcessText();

	// Hide the mousey
	root.ShowCursor(False);

	bTickEnabled = True;
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
	StopMusic();

	// Re-enable rendering
	if (bRenderingEnabled)
		root.EnableRendering(True);

	// Show the mousey
	root.ShowCursor(True);

	Super.DestroyWindow();
}

// ----------------------------------------------------------------------
// StopRendering()
// ----------------------------------------------------------------------

function StopRendering()
{
	// Stop the renderer to speed things up
	bRenderingEnabled = root.IsRenderingEnabled();

	if (bRenderingEnabled)
		root.EnableRendering(False);
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	winScroll = TileWindow(NewChild(Class'TileWindow'));

	winScroll.SetWidth(maxTileWidth);
	winScroll.SetOrder(ORDER_Down);
	winScroll.SetChildAlignments(HALIGN_Center, VALIGN_Top);
	winScroll.SetMargins(0, 0);
	winScroll.SetMinorSpacing(0);
	winScroll.SetMajorSpacing(0);
	winScroll.MakeWidthsEqual(False);
	winScroll.MakeHeightsEqual(False);
	winScroll.SetPos(0, root.Height);
	winScroll.FillParent(False);

	// Create the two fading windows (top and bottom)

	winFadeTop = NewChild(Class'Window');
	winFadeTop.SetBackground(Texture'FadeTop');
	winFadeTop.SetBackgroundStyle(DSTY_Modulated);

	winFadeBottom = NewChild(Class'Window');
	winFadeBottom.SetBackground(Texture'FadeBottom');
	winFadeBottom.SetBackgroundStyle(DSTY_Modulated);
}

// ----------------------------------------------------------------------
// StartMusic()
// ----------------------------------------------------------------------

function StartMusic()
{
	local Music CreditsMusic;

	if (ScrollMusicString != "")
	{
		CreditsMusic = Music(DynamicLoadObject(ScrollMusicString, class'Music'));

		if (CreditsMusic != None)
		{
			savedSongSection = player.SongSection;
			player.ClientSetMusic(CreditsMusic, 0, 255, MTRAN_FastFade);
		}
	}
}

// ----------------------------------------------------------------------
// StopMusic()
// ----------------------------------------------------------------------

function StopMusic()
{
	// Shut down the music
	player.ClientSetMusic(player.Level.Song, savedSongSection, 255, MTRAN_FastFade);
}

// ----------------------------------------------------------------------
// SetLoadIntro()
// ----------------------------------------------------------------------

function SetLoadIntro(bool bNewLoadIntro)
{
	bLoadIntro = bNewLoadIntro;
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
	local int diff;

	if (bScrolling)
	{
		scrollSpeed -= deltaTime;

		diff = 0;
		while (scrollSpeed < 0.0)
		{
			scrollSpeed += currentScrollSpeed;
			diff++;
		}

		if (diff > 0)
		{
			winScroll.SetPos(winScroll.x, winScroll.y - diff);

			// Check to see if we've finished scrolling
			if ((winScroll.y + winScroll.height) < 0)
			{
				bScrolling = False;
				FinishedScrolling();
			}
		}
	}
}

// ----------------------------------------------------------------------
// FinishedScrolling()
// ----------------------------------------------------------------------

function FinishedScrolling()
{
	root.PopWindow();
}

// ----------------------------------------------------------------------
// PrintHeader()
// ----------------------------------------------------------------------

function PrintHeader(String headerText)
{
	local TextWindow winText;

	winText = TextWindow(winScroll.NewChild(Class'TextWindow'));
	winText.SetWidth(maxTextWidth);
	winText.SetText(headerText);
	winText.SetTextColor(colHeader);
	winText.SetFont(fontHeader);
	winText.SetTextMargins(0, 0);
	winText.SetTextAlignments(HALIGN_Center, VALIGN_Top);
}

// ----------------------------------------------------------------------
// PrintText()
// ----------------------------------------------------------------------

function PrintText(String itemText, optional bool bLeftJustify)
{
	local TextWindow winText;

	winText = TextWindow(winScroll.NewChild(Class'TextWindow'));
	winText.SetWidth(maxTextWidth);
	winText.SetText(itemText);
	winText.SetTextColor(colText);
	winText.SetFont(fontText);
	winText.SetTextMargins(0, 0);

	if (bLeftJustify)
		winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	else
		winText.SetTextAlignments(HALIGN_Center, VALIGN_Top);
}

// ----------------------------------------------------------------------
// PrintAlignText()
// ----------------------------------------------------------------------

function PrintAlignText(String itemLabel, String itemText)
{
	local AlignWindow winAlign;
	local TextWindow  winText;

	winAlign = AlignWindow(winScroll.NewChild(Class'AlignWindow'));
	winAlign.SetChildVAlignment(VALIGN_Top);
	winAlign.SetChildSpacing(5);
	winAlign.SetWidth(maxTextWidth);

	winText = TextWindow(winAlign.NewChild(Class'TextWindow'));
	winText.SetFont(fontText);
	winText.SetTextColor(colText);
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winText.SetTextMargins(0, 0);
	winText.SetText(itemLabel);

	winText = TextWindow(winAlign.NewChild(Class'TextWindow'));
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winText.SetFont(fontText);
	winText.SetTextColor(colText);
	winText.SetTextMargins(0, 0);
	winText.SetWordWrap(True);
	winText.SetText(itemText);
}

// ----------------------------------------------------------------------
// PrintLn()
// ----------------------------------------------------------------------

function PrintLn()
{
	local Window winLine;

	winLine = winScroll.NewChild(Class'Window');
	winLine.SetSize(4, blankLineHeight);
}

// ----------------------------------------------------------------------
// PrintGraphic()
// ----------------------------------------------------------------------

function PrintGraphic(Texture graphic, int sizeX, int sizeY)
{
	local Window winGraphic;

	winGraphic = winScroll.NewChild(Class'Window');
	winGraphic.SetSize(sizeX, sizeY);
	winGraphic.SetBackground(graphic);
}

// ----------------------------------------------------------------------
// PrintPicture()
// ----------------------------------------------------------------------

function PrintPicture(
	Texture pictureTextures[6], 
	int textureCols,
	int textureRows,
	int imageX, 
	int imageY)
{
	local PictureWindow winPicture;

	winPicture = PictureWindow(winScroll.NewChild(Class'PictureWindow'));
	winPicture.SetTextures(pictureTextures, textureCols, textureRows);
	winPicture.SetSize(imageX, imageY);
}

// ----------------------------------------------------------------------
// MouseButtonReleased()
//
// Exit the window if the mouse button is presse
// ----------------------------------------------------------------------

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button,
                               int numClicks)
{
	FinishedScrolling();
	return True;
}

// ----------------------------------------------------------------------
// VirtualKeyPressed()
//
// Called when a key is pressed; provides a virtual key value
// ----------------------------------------------------------------------

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bKeyHandled;
	bKeyHandled = Super.VirtualKeyPressed(key, bRepeat);

	if ( IsKeyDown( IK_Alt ) || IsKeyDown( IK_Shift ) )
		return False;

	switch( key ) 
	{	
		// Decrease print rate
		case IK_Down:
		case IK_Minus:
			if (currentScrollSpeed < minScrollSpeed)
				currentScrollSpeed += speedAdjustment;
			break;

		// Increase print rate
		case IK_Equals:
		case IK_Up:
			if (currentScrollSpeed > maxScrollSpeed)
				currentScrollSpeed -= speedAdjustment;
 			break;

		// Pause
		case IK_S:
			if (IsKeyDown(IK_Ctrl))
				bTickEnabled = False;
			break;

		case IK_Q:
			if (IsKeyDown(IK_Ctrl))
				bTickEnabled = True;
			break;

		case IK_Space:
			if (bTickEnabled)
				bTickEnabled = False;
			else
				bTickEnabled = True;
			break;
	}

	return bKeyHandled;
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
// ----------------------------------------------------------------------

function ConfigurationChanged()
{
	local float qWidth, qHeight;

	if (winFadeTop != None)
	{
		winFadeTop.QueryPreferredSize(qWidth, qHeight);
		winFadeTop.ConfigureChild(0, 0, width, qHeight);
	}

	if (winFadeBottom != None)
	{
		winFadeBottom.QueryPreferredSize(qWidth, qHeight);
		winFadeBottom.ConfigureChild(0, height - qHeight, width, qHeight);
	}

	if (winScroll != None)
	{
		winScroll.QueryPreferredSize(qWidth, qHeight);
		winScroll.ConfigureChild((width / 2) - (qwidth / 2), winScroll.vMargin0, qWidth, qHeight);
	}
}

// ----------------------------------------------------------------------
// ProcessText()
// ----------------------------------------------------------------------

function ProcessText()
{
	local DeusExTextParser parser;

	// First check to see if we have a name
	if (textName != '')
	{
		// Create the text parser
		parser = new(None) Class'DeusExTextParser';

		// Attempt to find the text object
		if (parser.OpenText(textName))
		{
			while(parser.ProcessText())
				ProcessTextTag(parser);

			parser.CloseText();
		}

		CriticalDelete(parser);
	}

	ProcessFinished();
}

// ----------------------------------------------------------------------
// ProcessFinished()
// ----------------------------------------------------------------------

function ProcessFinished()
{
}

// ----------------------------------------------------------------------
// ProcessTextTag()
// ----------------------------------------------------------------------

function ProcessTextTag(DeusExTextParser parser)
{
	local String text;
	local byte tag;
	local Name fontName;
	local String textPart;
	local String fileStringName;
	local String fileStringDesc;

	tag  = parser.GetTag();

	switch(tag)
	{
		case 0:				// TT_Text:
			text = parser.GetText();

			if (text == "")
			{
				PrintLn();
			}
			else
			{
				if (bBold)
				{
					bBold = False;
					PrintHeader(parser.GetText());
				}
				else
				{
					PrintText(parser.GetText());
				}
			}
			break;

		case 1:				// TT_File (graphic, baby!)
			parser.GetFileInfo(fileStringName, fileStringDesc);
//			PrintGraphic(Texture(DynamicLoadObject(fileStringName, Class'Texture')));
			break;

		// Bold
		case 19:	// header
			bBold = True;
			break;

		case 13:				// TT_LeftJustify:
			break;

		case 12:				// TT_CenterText:
			break;
	}
}

// Transcended - Janky but fine for 2 minutes of work
function TransVMDCredits()
{
	PrintHeader("Vanilla? Madder.");
	PrintText("");
	PrintText("");
	PrintHeader("Some Assets Created By:");
	PrintText("My Dude, Bogie");
	PrintText("");
	PrintText("");
	PrintHeader("Native Code Babysitting By:");
	PrintText("The Great Witch, Aizome8086");
	PrintText("");
	PrintText("");
	PrintHeader("Some Native Code Lent By:");
	PrintText("Kentie, Open Source Via Kentie.net");
	PrintText("");
	PrintText("");
	PrintHeader("Infamy Mercenaries:");
	PrintText("NSF Hunter A");
	PrintText("Deep Lax - Eleven Labs");
	PrintText("");
	PrintText("NSF Hunter B");
	PrintText("J Tyson - Eleven Labs");
	PrintText("");
	PrintText("NSF Hunter C");
	PrintText("ZeroPresence");
	PrintText("");
	PrintText("Retributor A");
	PrintText("Some other guy");
	PrintText("");
	PrintText("Retributor B");
	PrintText("Tobin - Storyteller - ElevenLabs");
	PrintText("");
	PrintText("Retributor C");
	PrintText("Kojak Spitflo");
	PrintText("Probably my favorite voice of the batch");
	PrintText("");
	PrintText("Revenant A");
	PrintText("Fred - Energetic, Optimistic, and Engaging - Eleven Labs");
	PrintText("");
	PrintText("Revenant B");
	PrintText("The Epic Brandon - Eleven Labs");
	PrintText("Don't use this one, he requires oceans of editing.");
	PrintText("");
	PrintText("Revenant C");
	PrintText("P1SM");
	PrintText("");
	PrintText("");
	PrintText("Hate that eleven labs was used for many roles?");
	PrintText("We'd be happy to have you audition for the next release!");
	PrintText("");
	PrintText("");
	PrintHeader("Primary Testing By:");
	PrintText("Edgiator");
	PrintText("Michael 'Hawk' Bird");
	PrintText("Wolf Guy AKA Wofl Guy");
	PrintText("The Intergalactic Superpope");
	PrintText("WelshGamer_99");
	PrintText("SolidDew");
	PrintText("Jehuty, #1 VMD Tester");
	PrintText("");
	PrintText("");
	PrintHeader("Major Inspiration From:");
	PrintText("Smoke39, the OG god of R&D, and Cheek-Clapper in Chief.");
	PrintText("");
	PrintText("");
	PrintHeader("Supplemental Documentation:");
	PrintText("Artifechs & DXGalaxy.org");
	PrintText("");
	PrintText("");
	PrintHeader("Vanilla Matter");
	PrintText("Name on loan from The Markie...");
	PrintText("");
	PrintText("He invented immersive sim in 2004, ya' know.");
	PrintText("");
	PrintText("");
	PrintHeader("Deus Ex: Transcended");
	PrintText("Assets loaned to VMD by Hawk Bird");
	PrintText("");
	PrintText("I'm Hawk and I approve this message.");
	PrintText("");
	PrintHeader("DXT Created By:");
	PrintText("");
	PrintText("Hawk Bird");
	PrintText("VMD is my favourite mod on the citadel.");
	PrintText("");
	PrintText("");
	PrintText("DX Rando Crew:");
	PrintText("Die4Ever");
	PrintText("TheAstropath");
	PrintText("MQDuck");
	PrintText("");
	PrintText("");
	PrintHeader("DXT Special Thanks:");
	PrintText("Bjorn Ehrby");
	PrintText("");
	PrintText("");
	PrintText("Hanfling");
	PrintText("");
	PrintText("");
	PrintText("The_Markie");
	PrintText("");
	PrintText("");
	PrintText("G-Flex");
	PrintText("");
	PrintText("");
	PrintText("Y|yukichigai");
	PrintText("");
	PrintText("");
	PrintText("Lork");
	PrintText("");
	PrintText("");
	PrintText("Smoke39");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("");
	PrintText("Oh, and some other jackass did some things for VMD, I guess. Not too important.");
	PrintText("");
	PrintText("");
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     currentScrollSpeed=0.040000
     bScrolling=True
     scrollSpeed=0.040000
     minScrollSpeed=0.200000
     maxScrollSpeed=0.010000
     speedAdjustment=0.010000
     blankLineHeight=15
     maxTileWidth=600
     maxTextWidth=550
     fontHeader=Font'DeusExUI.FontConversationLargeBold'
     fontText=Font'DeusExUI.FontConversationLarge'
     colHeader=(R=255,G=255,B=255)
     colText=(R=200,G=200,B=200)
     ScreenType=ST_Credits
}
