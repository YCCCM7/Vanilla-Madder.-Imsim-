// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
//  File Name   :  ExtRoot.h
//  Programmer  :  Scott Martin
//  Description :  Header file for Unreal root window extension
// ----------------------------------------------------------------------
//  Copyright ©1999 ION Storm, L.P.  This software is a trade secret.
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// XRootWindow

#ifndef _EXT_ROOT_OVERLAY_H_
#define _EXT_ROOT_OVERLAY_H_

class VMDNATIVE_API XRootWindowOverlay : public XModalWindow
{
	friend class XWindow;
	friend class XTabGroupWindow;
	friend class XModalWindow;
	friend class XViewportWindow;

	public:
		XRootWindowOverlay(APlayerPawnExt *parentPawn);

		// Structors
		//virtual void Init(APlayerPawnExt *parentPawn);
		//void Init(XWindow *newParent) { debugf(TEXT("Root cannot have a parent window!")); }
		//void CleanUp(void);
		//void Destroy(void);

		// PlayerPawn this root window is associated with
		APlayerPawnExt *parentPawn;

		// Next root window in the global root window list
		XRootWindow    *nextRootWindow;

		// Cursor position info
		FLOAT          mouseX;                    // Cursor X pos
		FLOAT          mouseY;                    // Cursor Y pos
		FLOAT          prevMouseX;                // Last cursor X pos
		FLOAT          prevMouseY;                // Last cursor Y pos
		XWindow        *lastMouseWindow;          // Last window the cursor was in
		BITFIELD       bMouseMoved:1 GCC_PACK(4); // TRUE if the mouse moved
		BITFIELD       bMouseMoveLocked:1;        // TRUE if mouse movement is disabled
		BITFIELD       bMouseButtonLocked:1;      // TRUE if mouse buttons are disabled
		BITFIELD       bCursorVisible:1;          // TRUE if the cursor is visible

		// Default cursors
		XCursor        *defaultEditCursor GCC_PACK(4); // Cursor for edit widgets
		XCursor        *defaultMoveCursor;             // General movement cursor
		XCursor        *defaultHorizontalMoveCursor;   // Horizontal movement cursor
		XCursor        *defaultVerticalMoveCursor;     // Vertical movement cursor
		XCursor        *defaultTopLeftMoveCursor;      // Upper left to lower right cursor
		XCursor        *defaultTopRightMoveCursor;     // Upper right to lower left cursor

		// Sound options
		BITFIELD       bPositionalSound:1 GCC_PACK(4); // TRUE if positional sound is enabled

		// Input windows
		XWindow        *grabbedWindow GCC_PACK(4);     // Recipient window for all mouse events
		XWindow        *focusWindow;                   // Recipient window for all keyboard events

		// Input handling reference counters
		INT            handleMouseRef;    // Should root handle mouse events?
		INT            handleKeyboardRef; // Should root handle keyboard events?

		// Initialization reference counter
		INT            initCount;         // Number of windows to be initialized this tick

		// Rendered area information
		BITFIELD       bRender:1 GCC_PACK(4);   // TRUE if 3D areas should be rendered
		BITFIELD       bClipRender:1;           // TRUE if the 3D area is clipped
		BITFIELD       bStretchRawBackground:1;	// TRUE if raw background should be stretched
		FLOAT          renderX GCC_PACK(4);     // X offset of rendered area
		FLOAT          renderY;                 // Y offset of rendered area
		FLOAT          renderWidth;             // Width of rendered area
		FLOAT          renderHeight;            // Height of rendered area
		UTexture       *rawBackground;          // Background graphic drawn in unrendered areas
		FLOAT          rawBackgroundWidth;      // Width of background graphic
		FLOAT          rawBackgroundHeight;     // Height of background graphic
		FColor         rawColor;                // Color of raw background texture

		// Statistical variables
		INT            tickCycles;                // Number of cycles used during windows tick
		INT            paintCycles;               // Number of cycles used during PaintWindows call
		BITFIELD       bShowStats:1 GCC_PACK(4);  // Should statistics be shown on root window?
		BITFIELD       bShowFrames:1;             // Should we draw debugging frames around all windows?
		UTexture       *debugTexture GCC_PACK(4); // Debugging texture
		FLOAT          frameTimer;                // Timer used for frames

		// Button click information used to determine double clicks
		FLOAT         multiClickTimeout;  // Max amount of time between multiple button clicks
		FLOAT         maxMouseDist;       // Maximum mouse distance for multi-click to work
		INT           clickCount;         // Current click number (zero-based)
		INT           lastButtonType;     // Last mouse button handled
		FLOAT         lastButtonPress;    // Time remaining for last button press
		XWindow       *lastButtonWindow;  // Last window clicked in
		FLOAT         firstButtonMouseX;  // X position of initial button press
		FLOAT         firstButtonMouseY;  // Y position of initial button press

		// List of all current key states
		BYTE          keyDownMap[IK_MAX]; // TRUE if pressed, FALSE if not

		// Multipliers
		INT           hMultiplier;        // Horizontal multiplier
		INT           vMultiplier;        // Vertical multiplier

		// Snapshot-related variables
		INT           snapshotWidth;      // Snapshot width
		INT           snapshotHeight;     // Snapshot height

		struct FSceneNode *rootFrame;     // Transient pointer to the rendered frame

};  // XRootWindow


#endif // _EXT_ROOT_H_
