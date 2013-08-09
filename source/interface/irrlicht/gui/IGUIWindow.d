// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIWindow;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.EMessageBoxFlags;
import irrlicht.gui.IGUIButton;
import irrlicht.core.rect;

/// Default moveable window GUI element with border, caption and close icons.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_ELEMENT_CLOSED
*/
abstract class IGUIWindow : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_WINDOW, environment, parent, id, rectangle);
	}

	/// Returns pointer to the close button
	/**
	* You can hide the button by calling setVisible(false) on the result. 
	*/
	IGUIButton getCloseButton() const;

	/// Returns pointer to the minimize button
	/**
	* You can hide the button by calling setVisible(false) on the result. 
	*/
	IGUIButton getMinimizeButton() const;

	/// Returns pointer to the maximize button
	/**
	* You can hide the button by calling setVisible(false) on the result. 
	*/
	IGUIButton getMaximizeButton() const;

	/// Returns true if the window can be dragged with the mouse, false if not
	bool isDraggable() const;

	/// Sets whether the window can be dragged by the mouse
	void setDraggable(bool draggable);

	/// Set if the window background will be drawn
	void setDrawBackground(bool draw);

	/// Get if the window background will be drawn
	bool getDrawBackground() const;

	/// Set if the window titlebar will be drawn
	/// Note: If the background is not drawn, then the titlebar is automatically also not drawn
	void setDrawTitlebar(bool draw);

	/// Get if the window titlebar will be drawn
	bool getDrawTitlebar() const;

	/// Returns the rectangle of the drawable area (without border and without titlebar)
	/**
	* The coordinates are given relative to the top-left position of the gui element.<br>
	* So to get absolute positions you have to add the resulting rectangle to getAbsolutePosition().UpperLeftCorner.<br>
	* To get it relative to the parent element you have to add the resulting rectangle to getRelativePosition().UpperLeftCorner.
	* Beware that adding a menu will not change the clientRect as menus are own gui elements, so in that case you might want to subtract
	* the menu area additionally.	
	*/
	rect!int getClientRect() const;
}
