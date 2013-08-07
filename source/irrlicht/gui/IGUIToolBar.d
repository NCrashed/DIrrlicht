// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIToolBar;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUIButton;
import irrlicht.video.ITexture;
import irrlicht.core.rect;

/// Stays at the top of its parent like the menu bar and contains tool buttons
abstract class IGUIToolBar : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		this(EGUI_ELEMENT_TYPE.EGUIET_TOOL_BAR, environment, parent, id, rectangle);
	}

	/// Adds a button to the tool bar
	IGUIButton addButton(size_t id = 0, wstring text = "", wstring tooltiptext = "",
		ITexture img = null, ITexture pressedimg = null,
		bool isPushButton = false, bool useAlphaChannel = false);
}