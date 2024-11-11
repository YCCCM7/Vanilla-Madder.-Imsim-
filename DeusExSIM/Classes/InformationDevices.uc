//=============================================================================
// InformationDevices.
//=============================================================================
class InformationDevices extends VMDBufferDeco
	abstract;

var() name					textTag, FemaleTextTag; //MADDERS, 10/29/21: Female time?
var() string				TextPackage;
var() class<DataVaultImage>	imageClass;

var transient HUDInformationDisplay infoWindow;		// Window to display the information in
var transient TextWindow winText;				// Last text window we added
var Bool bSetText;
var Bool bAddToVault;					// True if we need to add this text to the DataVault
var String vaultString;
var DeusExPlayer aReader;				// who is reading this?
var localized String msgNoText;
var Bool bFirstParagraph;
var localized String ImageLabel;
var localized String AddedToDatavaultLabel;

var bool bEverRead; //Track first reading for stress reduction.
var localized String msgTooHot; //DXT addition

// ----------------------------------------------------------------------
// Destroyed()
//
// If the item is destroyed, make sure we also destroy the window
// if it happens to be visible!
// ----------------------------------------------------------------------

function Destroyed()
{
	DestroyWindow();

	Super.Destroyed();
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

function DestroyWindow()
{
	// restore the crosshairs and the other hud elements
	if (aReader != None)
	{
		DeusExRootWindow(aReader.rootWindow).hud.cross.SetCrosshair(aReader.bCrosshairVisible);
		DeusExRootWindow(aReader.rootWindow).hud.frobDisplay.Show();
	}
	
	if (infoWindow != None)
	{
		infoWindow.ClearTextWindows();
		infoWindow.Hide();
	}

	infoWindow = None;
	winText = None;
	aReader = None;
}

// ----------------------------------------------------------------------
// Tick()
//
// Only display the window while the player is in front of the object
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
	// if the reader strays too far from the object, kill the text window
	if ((aReader != None) && (infoWindow != None))
		if (aReader.FrobTarget != Self)
			DestroyWindow();
}

// ----------------------------------------------------------------------
// Frob()
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;

	Super.Frob(Frobber, frobWith);

	player = DeusExPlayer(Frobber);

	if (player != None)
	{
		if (infoWindow == None)
		{
			// Transcended - No reading while on fire
			if (IsInState('Burning'))
			{
				Player.ClientMessage(msgTooHot);
				return;
			}
			if ((VMDBufferPlayer(Player) != None) && (!bEverRead)) VMDBufferPlayer(Player).VMDModPlayerStress(-25,,, true);
			bEverRead = true;
			
			aReader = player;
			CreateInfoWindow();

			// hide the crosshairs if there's text to read, otherwise display a message
			if (infoWindow != None)
			{
				DeusExRootWindow(player.rootWindow).hud.cross.SetCrosshair(False);
				DeusExRootWindow(player.rootWindow).hud.frobDisplay.Hide();
			}
			else
				player.ClientMessage(msgNoText);
		}
		else
		{
			DestroyWindow();
		}
	}
}

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	local DeusExTextParser parser;
	local DeusExRootWindow rootWindow;
	local DeusExNote note;
	local DataVaultImage image;
	local bool bImageAdded;
	
	local name UseTextTag;
	local bool bWon;
	
	rootWindow = DeusExRootWindow(aReader.rootWindow);
	
	//LDDP, 10/25/21: Convert usage to female text flag when female.
	if ((aReader != None) && (aReader.FlagBase != None) && (aReader.FlagBase.GetBool('LDDPJCIsFemale')))
	{
		UseTextTag = FemaleTextTag;
	}
	if (!bool(UseTextTag)) UseTextTag = TextTag;
	
	// First check to see if we have a name
	if ( textTag != '' )
	{
		// Create the text parser
		parser = new(None) Class'DeusExTextParser';
								    
		// Attempt to find the text object
		if (aReader != None)
		{
			bWon = (parser.OpenText(UseTextTag,TextPackage));
			if (!bWon)
			{
				UseTextTag = TextTag;
				bWon = (parser.OpenText(UseTextTag,TextPackage));
			}
			
			if (bWon)
			{
				parser.SetPlayerName(aReader.TruePlayerName);
				
				infoWindow = rootWindow.hud.ShowInfoWindow();
				infoWindow.ClearTextWindows();
				
				vaultString = "";
				bFirstParagraph = True;
				
				while(parser.ProcessText())
					ProcessTag(parser);
				
				parser.CloseText();
				
				// Check to see if we need to save this string in the 
				// DataVault
				if (bAddToVault)
				{
					note = aReader.GetNote(UseTextTag);
					
					if (note == None)
					{
						if (((!IsA('Datacube')) && (Human(aReader).bInformationDevices)) || IsA('Datacube'))
						{
							if (IsA('Datacube'))
								note = aReader.AddNote(vaultString,, True, "Datacubes");
							else
								note = aReader.AddNote(vaultString,, True, "Literature");
							note.SetTextTag(UseTextTag);
						}
					}
					vaultString = "";
				}
			}
		}
		CriticalDelete(parser);
	}

	// do we have any image data to give the player?
	if ((imageClass != None) && (aReader != None))
	{
		image = Spawn(imageClass, aReader);
		if (image != None)  
		{
			// Display a note to the effect that there's an image here, 
			// but only if nothing else was displayed
			if (infoWindow == None)
			{
				infoWindow = rootWindow.hud.ShowInfoWindow();
				winText = infoWindow.AddTextWindow();
				winText.SetText(Sprintf(ImageLabel, image.imageDescription));
			}
			image.GiveTo(aReader);
			image.SetBase(aReader);
			bImageAdded = aReader.AddImage(image); // Transcended - Moved down as AddImage now destroys duplicates

			// Log the fact that the user just got an image.
			if (bImageAdded)
			{
				aReader.ClientMessage(Sprintf(AddedToDatavaultLabel, image.imageDescription));
			}
		}
	}
}

// ----------------------------------------------------------------------
// ProcessTag()
// ----------------------------------------------------------------------

function ProcessTag(DeusExTextParser parser)
{
	local String text;
//	local EDeusExTextTags tag;
	local byte tag;
	local Name fontName;
	local String textPart;

	tag  = parser.GetTag();

	// Make sure we have a text window to operate on.
	if (winText == None)
	{
		winText = infoWindow.AddTextWindow();
		bSetText = True;
	}

	switch(tag)
	{
		// If a winText window doesn't yet exist, create one.
		// Then add the text
		case 0:				// TT_Text:
		case 9:				// TT_PlayerName:
		case 10:			// TT_PlayerFirstName:
			text = parser.GetText();

			// Add the text
			if (bSetText)
				winText.SetText(text);
			else
				winText.AppendText(text);

			vaultString = vaultString $ text;
			bSetText = False;
			break;

		// Create a new text window
		case 18:			// TT_NewParagraph:
			// Create a new text window
			winText = infoWindow.AddTextWindow();

			// Only add a return if this is not the *first*
			// paragraph.
			if (!bFirstParagraph)
				vaultString = vaultString $ winText.CR();

			bFirstParagraph = False;

			bSetText = True;
			break;

		case 13:				// TT_LeftJustify:
			winText.SetTextAlignments(HALIGN_Left, VALIGN_Center);
			break;

		case 14:			// TT_RightJustify:
			winText.SetTextAlignments(HALIGN_Right, VALIGN_Center);
			break;

		case 12:				// TT_CenterText:
			winText.SetTextAlignments(HALIGN_Center, VALIGN_Center);
			break;

		case 26:			// TT_Font:
//			fontName = parser.GetName();
//			winText.SetFont(fontName);
			break;

		case 15:			// TT_DefaultColor:
		case 16:			// TT_TextColor:
		case 17:			// TT_RevertColor:
			winText.SetTextColor(parser.GetColor());
			break;
	}
}

singular function BaseChange()
{
	local float decorMass, decorMass2;

	if (bDeleteme)
		return;

	decormass= FMax(1, Mass);
	bBobbing = false;
	if ( Velocity.Z < -500 )
		TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , 'crushed');

	if ( (base == None) && (Physics == PHYS_None) ) // Removed requirement for bPushable, prevents floating.
		SetPhysics(PHYS_Falling);
	else if (Base != None && base.bIsPawn && Pawn(Base).CarriedDecoration != self )
	{
		Base.TakeDamage( (1-Velocity.Z/400)* decormass/Base.Mass,Instigator,Location,0.5 * Velocity , 'crushed');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else if ( Decoration(Base) != None && Velocity.Z<-500 )
	{
		decorMass2 = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((1 - decorMass/decorMass2 * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, 'stomped');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else
		instigator = None;
}

function PostBeginPlay()
{
	local string TS;
	
	Super.PostBeginPlay();
	
	//LDDP, 10/25/21: We now have a female text tag variable. Conjure one based off our base text flag, assuming it's not blank.
	if (bool(TextTag))
	{
		TS = "FemJC"$string(TextTag);
		SetPropertyText("FemaleTextTag", TS);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     bFlammable=True
     TextPackage="DeusExText"
     msgTooHot="It's too on fire to read"
     msgNoText="There's nothing interesting to read"
     ImageLabel="[Image: %s]"
     AddedToDatavaultLabel="Image %s added to DataVault"
     FragType=Class'DeusEx.PaperFragment'
     bPushable=False
     bAddToVault=True // Transcended - Added
}
