//=============================================================================
// VMDPersonaScreenNotesLight
//=============================================================================
class VMDPersonaScreenNotesLight extends PersonaScreenBaseWindow;

// Note Items
var TileWindow                winNotes;
var PersonaCheckBoxWindow     chkConfirmNoteDeletion;
var Bool                      bConfirmNoteDeletes;
var localized String          NotesTitleText;
var PersonaActionButtonWindow btnAddNote;
var PersonaActionButtonWindow btnDeleteNote;
var PersonaNotesEditWindow    currentNoteWindow;
var PersonaNotesEditWindow    firstNoteWindow;
	
var PersonaActionButtonWindow btnEmails;
var PersonaActionButtonWindow btnOther;
var PersonaActionButtonWindow btnLiterature;
var PersonaActionButtonWindow btnDatacubes;

var MenuUIEditWindow		  searchText;
var PersonaEditWindow 		  searchBox;
var PersonaActionButtonWindow btnSearch;

var localized string defaultNoteText;
var localized string ClickToEditNote;
var localized string DeleteNoteTitle;
var localized string DeleteNotePrompt;
var localized string AddButtonLabel;
var localized string DeleteButtonLabel;
var localized string ConfirmNoteDeletionLabel;

var localized string strEmails;
var localized string strOther;
var localized string strLiterature;
var localized string strDatacubes;
var localized string strSearch;
var localized string strSearchButton;

//MADDERS: Escape key fix related.
var bool bEscapeLastHeld;
var int PopTimer;

function UpdateEscapeCheck()
{
	if (PopTimer > 0) return;
	
	if ((Root != None) && (Root.IsKeyDown(IK_Escape)))
	{
		if (bEscapeLastHeld)
		{
			PopTimer = AddTimer(0.1, False,, 'DoPop');
		}
		else
		{
			bEscapeLastHeld = true;
		}
	}
	else
	{
		bEscapeLastHeld = false;
	}
}

function DoPop()
{
	Root.PopWindow();
}

//MADDERS, 12/25/23: Gut this stuff, leave us plain.
function CreateNavBarWindow()
{
	AddTimer(0.05, True,, 'UpdateEscapeCheck');
}

//MADDERS, 12/25/23: 
function CreateClientWindow()
{
	Super.CreateClientWindow();
	
	WinClient.BorderDrawStyle = DSTY_Masked;
	WinClient.BackgroundDrawStyle = DSTY_Masked;
}

//MADDERS, 12/25/23: Bar us pushing anything uninvited.
function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	PopulateNotes();

	PersonaNavBarWindow(winNavBar).btnGoals.SetSensitivity(False);

	// Set focus to the AddNote button
	SetFocusWindow(btnAddNote);

	EnableButtons();
}

// ----------------------------------------------------------------------
// WindowReady() 
// ----------------------------------------------------------------------

event WindowReady()
{
	// Make sure the most recent note is scrolled to the top
	if (firstNoteWindow != None)
		firstNoteWindow.AskParentToShowArea();
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
	player.bConfirmNoteDeletes    = bConfirmNoteDeletes;
	player.SaveConfig();

	Super.DestroyWindow();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	CreateTitleWindow(9, 5, NotesTitleText);
	CreateTitleWindow(133, 5, strSearch);

	winNotes = CreateScrollTileWindow(16, 21, 574, 387);
	winNotes.SetMinorSpacing(4);
	
	CreateNotesButtons();
	CreateConfirmNoteDeletionCheckbox();
}

// ----------------------------------------------------------------------
// CreateNotesButtons()
// ----------------------------------------------------------------------

function CreateNotesButtons()
{
	local PersonaButtonBarWindow winActionButtons;

	winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(10, 411);
	winActionButtons.SetWidth(408);
	winActionButtons.FillAllSpace(False);
	
	btnOther = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnOther.SetButtonText(strOther);

	btnEmails = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnEmails.SetButtonText(strEmails);
	
	btnLiterature = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnLiterature.SetButtonText(strLiterature);
	
	btnDatacubes = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnDatacubes.SetButtonText(strDatacubes);
	
	btnAddNote = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnAddNote.SetButtonText(AddButtonLabel);

	btnDeleteNote = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnDeleteNote.SetButtonText(DeleteButtonLabel);
	
	searchBox = PersonaEditWindow(winClient.NewChild(Class'PersonaEditWindow'));
	searchBox.SetPos(183, 4);
	searchBox.SetWidth(280);
	searchBox.EnableEditing(True);
	searchBox.EnableSingleLineEditing(True);
	
	btnSearch = PersonaActionButtonWindow(winClient.NewChild(Class'PersonaActionButtonWindow'));
	btnSearch.SetPos(464, 1);
	btnSearch.SetButtonText(strSearchButton);
	
	//MADDERS, 12/25/23: Force non-translucency, thank you.
	BtnOther.bTranslucent = False;
	BtnEmails.bTranslucent = False;
	BtnLiterature.bTranslucent = False;
	BtnDataCubes.bTranslucent = False;
	BtnAddNote.bTranslucent = False;
	BtnDeleteNote.bTranslucent = False;
	BtnSearch.bTranslucent = False;
}

// ----------------------------------------------------------------------
// CreateConfirmNoteDeletionCheckbox()
// ----------------------------------------------------------------------

function CreateConfirmNoteDeletionCheckbox()
{
	chkConfirmNoteDeletion = PersonaCheckBoxWindow(winClient.NewChild(Class'PersonaCheckBoxWindow'));

	bConfirmNoteDeletes = player.bConfirmNoteDeletes;

	chkConfirmNoteDeletion.SetText(ConfirmNoteDeletionLabel);
	chkConfirmNoteDeletion.SetToggle(bConfirmNoteDeletes);
	chkConfirmNoteDeletion.SetWindowAlignments(HALIGN_Right, VALIGN_Top, 13, 412);
	chkConfirmNoteDeletion.SetWidth(150);
}

// ----------------------------------------------------------------------
// PopulateNotes()
//
// Loops through all the notes and displays them 
// ----------------------------------------------------------------------

function PopulateNotes()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;

	// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
	bWasVisible = winNotes.IsVisible(FALSE);
	winNotes.Hide();

	// First make sure there aren't already notes
	winNotes.DestroyAllChildren();

	// Loop through all the notes
	note = player.FirstNote;
	while(note != None)
	{
		noteWindow = CreateNoteEditWindow( note );

		if (firstNoteWindow == None)
			firstNoteWindow = noteWindow;

		// Continue on to the next note
		note = note.next;
	}

	// Show the notes again, if they were visible before
	winNotes.Show(bWasVisible);
	
	ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
}

// ----------------------------------------------------------------------
// PopulateEmails()
//
// Loops through all the notes and displays only ones from computers
// ----------------------------------------------------------------------

function PopulateEmails()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;

	// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
	bWasVisible = winNotes.IsVisible(FALSE);
	winNotes.Hide();

	// First make sure there aren't already notes
	winNotes.DestroyAllChildren();

	// Loop through all the notes
	note = player.FirstNote;
	while(note != None)
	{
		if (note.textSource == "Emails")
		{
			noteWindow = CreateNoteEditWindow( note );

			if (firstNoteWindow == None)
				firstNoteWindow = noteWindow;
		}

		// Continue on to the next note
		note = note.next;
	}

	// Show the notes again, if they were visible before
	winNotes.Show(bWasVisible);
	
	ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
}

// ----------------------------------------------------------------------
// PopulateLiterature()
//
// Loops through all the notes and displays only ones from Literature
// ----------------------------------------------------------------------

function PopulateLiterature()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;

	// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
	bWasVisible = winNotes.IsVisible(FALSE);
	winNotes.Hide();

	// First make sure there aren't already notes
	winNotes.DestroyAllChildren();

	// Loop through all the notes
	note = player.FirstNote;
	while(note != None)
	{
		if (note.textSource == "Literature")
		{
			noteWindow = CreateNoteEditWindow( note );

			if (firstNoteWindow == None)
				firstNoteWindow = noteWindow;
		}

		// Continue on to the next note
		note = note.next;
	}

	// Show the notes again, if they were visible before
	winNotes.Show(bWasVisible);
	
	ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
}

// ----------------------------------------------------------------------
// PopulateOther()
//
// Loops through all the notes and displays only ones not from datacubes, emails, books, or newspapers. (I.e. conversations/infolink or player added).
// ----------------------------------------------------------------------

function PopulateOther()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;

	// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
	bWasVisible = winNotes.IsVisible(FALSE);
	winNotes.Hide();

	// First make sure there aren't already notes
	winNotes.DestroyAllChildren();

	// Loop through all the notes
	note = player.FirstNote;
	while(note != None)
	{
		if (note.textSource != "Literature" && note.textSource != "Emails" && note.textSource != "Datacubes")
		{
			noteWindow = CreateNoteEditWindow( note );

			if (firstNoteWindow == None)
				firstNoteWindow = noteWindow;
		}
			
		// Continue on to the next note
		note = note.next;
	}

	// Show the notes again, if they were visible before
	winNotes.Show(bWasVisible);
	
	ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
}

// ----------------------------------------------------------------------
// PopulateDatacubes()
//
// Loops through all the notes and displays only ones from datacubes
// ----------------------------------------------------------------------

function PopulateDatacubes()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;

	// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
	bWasVisible = winNotes.IsVisible(FALSE);
	winNotes.Hide();

	// First make sure there aren't already notes
	winNotes.DestroyAllChildren();

	// Loop through all the notes
	note = player.FirstNote;
	while(note != None)
	{
		if (note.textSource == "Datacubes")
		{
			noteWindow = CreateNoteEditWindow( note );

			if (firstNoteWindow == None)
				firstNoteWindow = noteWindow;
		}
			
		// Continue on to the next note
		note = note.next;
	}

	// Show the notes again, if they were visible before
	winNotes.Show(bWasVisible);
	
	ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
}

function PopulateNotesSearch()
{
	local PersonaNotesEditWindow noteWindow;
	local DeusExNote note;
	local bool   bWasVisible;
	
	if (searchBox != None && (searchBox.GetText() != ""))
	{
		// Hide the notes, so we don't flood the tile window with ConfigureChanged() events
		bWasVisible = winNotes.IsVisible(FALSE);
		winNotes.Hide();

		// First make sure there aren't already notes
		winNotes.DestroyAllChildren();

		// Loop through all the notes
		note = player.FirstNote;
		while(note != None)
		{
			if (InStr(caps(note.text),caps(searchBox.GetText()))!=-1)
			{
				noteWindow = CreateNoteEditWindow( note );

				if (firstNoteWindow == None)
					firstNoteWindow = noteWindow;
			}
				
			// Continue on to the next note
			note = note.next;
		}

		// Show the notes again, if they were visible before
		winNotes.Show(bWasVisible);
	
		ScrollAreaWindow(winNotes.GetParent().GetParent()).vScale.MoveThumb(MOVETHUMB_Home);
	}
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	if (Super.ButtonActivated(buttonPressed))
		return True;

	bHandled   = True;

	switch(buttonPressed)
	{
		case btnSearch:
			PopulateNotesSearch();
			break;
		
		case btnEmails:
			PopulateEmails();
			break;
		
		case btnOther:
			PopulateOther();
			break;
		
		case btnLiterature:
			PopulateLiterature();
			break;
		
		case btnDatacubes:
			PopulateDatacubes();
			break;
		
		case btnAddNote:
			AddNote();
			break;
		
		case btnDeleteNote:
			if (bConfirmNoteDeletes)
			{
				root.MessageBox(DeleteNoteTitle, DeleteNotePrompt, 0, False, Self);
			}
			else
			{
				DeleteNote(currentNoteWindow);
				currentNoteWindow = None;
				EnableButtons();
			}				
			break;
		
		default:
			bHandled = False;
			break;
	}

	return bHandled;
}

// ----------------------------------------------------------------------
// FocusEnteredDescendant()
// ----------------------------------------------------------------------

event FocusEnteredDescendant(Window enterWindow)
{
	// Ignore this even if we're deleting
	if (PersonaNotesEditWindow(enterWindow) != None) 
	{
		currentNoteWindow = PersonaNotesEditWindow(enterWindow);
		EnableButtons();
	}
}

// ----------------------------------------------------------------------
// FocusLeftDescendant()
//
// Save the contents of the text window into the Notes window, 
// but only if the note has changed.
// ----------------------------------------------------------------------

event FocusLeftDescendant(Window leaveWindow)
{
	local PersonaNotesEditWindow noteWindow;

	noteWindow = PersonaNotesEditWindow(leaveWindow);

	if (noteWindow != None)
		SaveNote(noteWindow);
}

// ----------------------------------------------------------------------
// SaveNote()
// ----------------------------------------------------------------------

function SaveNote(PersonaNotesEditWindow noteWindow)
{
	local DeusExNote note;

	if ( noteWindow.HasTextChanged() )
	{
		note      = noteWindow.GetNote();
		note.text = noteWindow.GetText();
		noteWindow.ClearTextChangedFlag();
	}
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	// Nuke the msgbox
	root.PopWindow();

	if ( buttonNumber == 0 ) 
	{
		DeleteNote(currentNoteWindow);
		currentNoteWindow = None;
		EnableButtons();
	}

	return true;
}

// ----------------------------------------------------------------------
// AddNote()
//
// Creates a new edit window at the end of the tile window, allowing
// the user to enter a new note.  
// ----------------------------------------------------------------------

function AddNote()
{
	local DeusExNote newNote;
	local PersonaNotesEditWindow newNoteWindow;

	// Create a new note and then a window to display it in
	newNote = player.AddNote(defaultNoteText, True);

	newNoteWindow = CreateNoteEditWindow(newNote);
	newNoteWindow.Lower();
	newNoteWindow.SetSelectedArea(0, Len(defaultNoteText));
	SetFocusWindow(newNoteWindow);
}

// ----------------------------------------------------------------------
// DeleteNote()
//
// Deletes the specified note
// ----------------------------------------------------------------------

function DeleteNote(PersonaNotesEditWindow noteWindow)
{
	if (noteWindow == None)
		return;

	// Remove it from the collection
	player.DeleteNote(noteWindow.GetNote());

	// Now remove it from the list
	noteWindow.Destroy();

	// Set focus to the Delete button
	SetFocusWindow(btnAddNote);
}

// ----------------------------------------------------------------------
// ToggleChanged()
//
// Called when a note is clicked on
// ----------------------------------------------------------------------

event bool ToggleChanged(Window button, bool bNewToggle)
{
	if (button.IsA('PersonaNotesEditWindow'))
	{
		EnableButtons();
	}
	else if (button == chkConfirmNoteDeletion)
	{
		bConfirmNoteDeletes = bNewToggle;
	}

	return True;
}

// ----------------------------------------------------------------------
// Creates a note edit window
// ----------------------------------------------------------------------

function PersonaNotesEditWindow CreateNoteEditWindow(DeusExNote note)
{
	local PersonaNotesEditWindow newNoteWindow;

	newNoteWindow = PersonaNotesEditWindow(winNotes.NewChild(Class'PersonaNotesEditWindow'));
	newNoteWindow.SetNote(note);
	
	return newNoteWindow;
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	btnDeleteNote.SetSensitivity(currentNoteWindow != None);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     NotesTitleText="Notes"
     defaultNoteText="New Note"
     ClickToEditNote="Click on a Note to edit it:"
     DeleteNoteTitle="Delete Note?"
     DeleteNotePrompt="Are you sure you wish to delete this note?"
     AddButtonLabel="Add |&Note"
     DeleteButtonLabel="|&Delete Note"
     ConfirmNoteDeletionLabel="Confirm Note Deletion"
	 strDatacubes="Datac|&ubes"
	 strEmails="|&Emails"
	 strLiterature="Li|&terature"
	 strOther="Othe|&r"
	 strSearch="Find:"
	 strSearchButton="|&Find>>"
     clientBorderOffsetY=29
     ClientWidth=604
     ClientHeight=433
     clientOffsetX=15
     clientOffsetY=10
     clientTextures(0)=Texture'VMDGoalsBackgroundAlt_1'
     clientTextures(1)=Texture'VMDGoalsBackgroundAlt_2'
     clientTextures(2)=Texture'VMDGoalsBackgroundAlt_3'
     clientTextures(3)=Texture'VMDGoalsBackgroundAlt_4'
     clientTextures(4)=Texture'VMDGoalsBackgroundAlt_5'
     clientTextures(5)=Texture'VMDGoalsBackground_6'
     clientBorderTextures(0)=None
     clientBorderTextures(1)=None
     clientBorderTextures(2)=None
     clientBorderTextures(3)=None
     clientBorderTextures(4)=None
     clientBorderTextures(5)=None
     clientTextureRows=2
     clientTextureCols=3
     clientBorderTextureRows=2
     clientBorderTextureCols=3
}
