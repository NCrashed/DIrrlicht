// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIFileOpenDialog;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.io.path;

/// Standard file chooser dialog.
/**
* \warning When the user selects a folder this does change the current working directory
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_DIRECTORY_SELECTED
* \li EGET_FILE_SELECTED
* \li EGET_FILE_CHOOSE_DIALOG_CANCELLED
*/
abstract class IGUIFileOpenDialog : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_FILE_OPEN_DIALOG, environment, parent, id, rectangle);
	}
	
	/// Returns the filename of the selected file. Returns NULL, if no file was selected.
	wstring getFileName() const;

	/// Returns the directory of the selected file. Returns NULL, if no directory was selected.
	const Path getDirectoryName();
}
