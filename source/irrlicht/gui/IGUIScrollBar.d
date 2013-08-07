// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIScrollBar;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.core.rect;

/// Default scroll bar GUI element.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_SCROLL_BAR_CHANGED
*/
abstract class IGUIScrollBar :IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_SCROLL_BAR, environment, parent, id, rectangle);
	}

	/// sets the maximum value of the scrollbar.
	void setMax(int max);
	/// gets the maximum value of the scrollbar.
	int getMax() const;

	/// sets the minimum value of the scrollbar.
	void setMin(int min);
	/// gets the minimum value of the scrollbar.
	int getMin() const;

	/// gets the small step value
	int getSmallStep() const;

	/// Sets the small step
	/**
	* That is the amount that the value changes by when clicking
	* on the buttons or using the cursor keys. 
	*/
	void setSmallStep(int step);

	/// gets the large step value
	int getLargeStep() const;

	/// Sets the large step
	/**
	* That is the amount that the value changes by when clicking
	* in the tray, or using the page up and page down keys. 
	*/
	void setLargeStep(int step);

	/// gets the current position of the scrollbar
	int getPos() const;

	/// sets the current position of the scrollbar
	void setPos(int pos);
}
