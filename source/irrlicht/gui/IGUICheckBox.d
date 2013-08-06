// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUICheckBox;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.core.rect;

/// GUI Check box interface.
/** 
* This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_CHECKBOX_CHANGED
*/
abstract class IGUICheckBox : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_CHECK_BOX, environment, parent, id, rectangle);
	}

	/// Set if box is checked.
	void setChecked(bool checked);

	/// Returns true if box is checked.
	bool isChecked() const;
}