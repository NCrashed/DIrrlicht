// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.ICursorControl;

import irrlicht.gui.IGUISpriteBank;
import irrlicht.core.vector2d;
import irrlicht.core.rect;
import irrlicht.core.dimension2d;

/// Default icons for cursors
enum ECURSOR_ICON
{
	// Following cursors might be system specific, or might use an Irrlicht icon-set. No guarantees so far.
	ECI_NORMAL,		// arrow
	ECI_CROSS,		// Crosshair
	ECI_HAND, 		// Hand
	ECI_HELP,		// Arrow and question mark
	ECI_IBEAM,		// typical text-selection cursor
	ECI_NO, 		// should not click icon
	ECI_WAIT, 		// hourclass
	ECI_SIZEALL,  	// arrow in all directions
	ECI_SIZENESW,	// resizes in direction north-east or south-west
	ECI_SIZENWSE, 	// resizes in direction north-west or south-east
	ECI_SIZENS, 	// resizes in direction north or south
	ECI_SIZEWE, 	// resizes in direction west or east
	ECI_UP,			// up-arrow

	// Implementer note: Should we add system specific cursors, which use guaranteed the system icons,
	// then I would recommend using a naming scheme like ECI_W32_CROSS, ECI_X11_CROSSHAIR and adding those
	// additionally.

	ECI_COUNT		// maximal of defined cursors. Note that higher values can be created at runtime
}

/// Names for ECURSOR_ICON
immutable(string[]) GUICursorIconNames =
[
	"normal",
	"cross",
	"hand",
	"help",
	"ibeam",
	"no",
	"wait",
	"sizeall",
	"sizenesw",
	"sizenwse",
	"sizens",
	"sizewe",
	"sizeup",
];

/// structure used to set sprites as cursors.
struct SCursorSprite
{
	this( IGUISpriteBank spriteBank, size_t spriteId, const vector2d!int hotspot = vector2d!int(0,0) )
	{
		SpriteBank = spriteBank;
		SpriteId = spriteId;
		HotSpot = hotspot;
	}

	IGUISpriteBank SpriteBank = null;
	size_t SpriteId;
	vector2d!int HotSpot;
}

/// platform specific behavior flags for the cursor
enum ECURSOR_PLATFORM_BEHAVIOR
{
	/// default - no platform specific behavior
	ECPB_NONE = 0,

	/// On X11 try caching cursor updates as XQueryPointer calls can be expensive.
	/**
	* Update cursor positions only when the irrlicht timer has been updated or the timer is stopped.
	*	 This means you usually get one cursor update per device.run() which will be fine in most cases.
	*	 See_Also:
	*	 	this forum-thread for a more detailed explanation:
	*	 http://irrlicht.sourceforge.net/forum/viewtopic.php?f=7&t=45525
	*/
	ECPB_X11_CACHE_UPDATES = 1
}

/// Interface to manipulate the mouse cursor.
interface ICursorControl
{
	/// Changes the visible state of the mouse cursor.
	/**
	* Params:
	* 	visible=  The new visible state. If true, the cursor will be visible,
	* if false, it will be invisible. 
	*/
	void setVisible(bool visible);

	/// Returns if the cursor is currently visible.
	/**
	* Returns: True if the cursor is visible, false if not. 
	*/
	bool isVisible() const;

	/// Sets the new position of the cursor.
	/**
	* The position must be
	* between (0.0f, 0.0f) and (1.0f, 1.0f), where (0.0f, 0.0f) is
	* the top left corner and (1.0f, 1.0f) is the bottom right corner of the
	* render window.
	* Params:
	* 	pos=  New position of the cursor. 
	*/
	void setPosition()(auto ref const vector2d!float pos);

	/// Sets the new position of the cursor.
	/**
	* The position must be
	* between (0.0f, 0.0f) and (1.0f, 1.0f), where (0.0f, 0.0f) is
	* the top left corner and (1.0f, 1.0f) is the bottom right corner of the
	* render window.
	* Params:
	* 	x=  New x-coord of the cursor.
	* 	y=  New x-coord of the cursor. 
	*/
	void setPosition()(float x, float y);

	/// Sets the new position of the cursor.
	/**
	* Params:
	* 	pos=  New position of the cursor. The coordinates are pixel units. 
	*/
	void setPosition()(auto ref const vector2d!int pos);

	/// Sets the new position of the cursor.
	/**
	* Params:
	* 	x=  New x-coord of the cursor. The coordinates are pixel units.
	* 	y=  New y-coord of the cursor. The coordinates are pixel units. 
	*/
	void setPosition()(int x, int y);

	/// Returns the current position of the mouse cursor.
	/**
	* Returns: Returns the current position of the cursor. The returned position
	* is the position of the mouse cursor in pixel units. 
	*/
	auto ref const vector2d!int getPosition()();

	/// Returns the current position of the mouse cursor.
	/**
	* Returns: Returns the current position of the cursor. The returned position
	* is a value between (0.0f, 0.0f) and (1.0f, 1.0f), where (0.0f, 0.0f) is
	* the top left corner and (1.0f, 1.0f) is the bottom right corner of the
	* render window. 
	*/
	vector2d!float getRelativePosition();

	/// Sets an absolute reference rect for setting and retrieving the cursor position.
	/**
	* If this rect is set, the cursor position is not being calculated relative to
	* the rendering window but to this rect. You can set the rect pointer to 0 to disable
	* this feature again. This feature is useful when rendering into parts of foreign windows
	* for example in an editor.
	* Params:
	* 	rect=  A pointer to an reference rectangle or 0 to disable the reference rectangle.
	*/
	void setReferenceRect(rect!(int)* rect = null);

	/// Sets the active cursor icon
	/**
	* Setting cursor icons is so far only supported on Win32 and Linux 
	*/
	void setActiveIcon(ECURSOR_ICON iconId);

	/// Gets the currently active icon
	ECURSOR_ICON getActiveIcon() const;

	/// Add a custom sprite as cursor icon.
	/**
	* Returns: Identification for the icon 
	*/
	ECURSOR_ICON addIcon()(auto ref const SCursorSprite icon);

	/// replace a cursor icon.
	/**
	* Changing cursor icons is so far only supported on Win32 and Linux
	*	 Note that this only changes the icons within your application, system cursors outside your
	*	 application will not be affected.
	*/
	void changeIcon()(ECURSOR_ICON iconId, auto ref const SCursorSprite sprite);

	/// Return a system-specific size which is supported for cursors. Larger icons will fail, smaller icons might work.
	dimension2di getSupportedIconSize() const;

	/// Set platform specific behavior flags.
	void setPlatformBehavior(ECURSOR_PLATFORM_BEHAVIOR behavior);

	/// Return platform specific behavior.
	/**
	* Returns: Behavior set by setPlatformBehavior or ECPB_NONE for platforms not implementing specific behaviors.
	*/
	ECURSOR_PLATFORM_BEHAVIOR getPlatformBehavior() const;
}