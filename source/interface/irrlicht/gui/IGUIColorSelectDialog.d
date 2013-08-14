// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIColorSelectDialog;

import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.core.rect;

/// Standard color chooser dialog.
abstract class IGUIColorSelectDialog : IGUIElement
{
	/// constructor
	this(IGUIEnvironment environment, IGUIElement parent, size_t id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_COLOR_SELECT_DIALOG, environment, parent, id, rectangle);
	}
}