// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIComboBox;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.EGUIAlignment;
import irrlicht.core.rect;

/// Combobox widget
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_COMBO_BOX_CHANGED
*/
abstract class IGUIComboBox : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		this(EGUI_ELEMENT_TYPE.EGUIET_COMBO_BOX, environment, parent, id, rectangle);
	}

	/// Returns amount of items in box
	size_t getItemCount() const;

	/// Returns string of an item. the idx may be a value from 0 to itemCount-1
	wstring getItem(size_t idx) const;

	/// Returns item data of an item. the idx may be a value from 0 to itemCount-1
	uint getItemData(size_t idx) const;

	/// Returns index based on item data
	ptrdiff_t getIndexForItemData(uint data ) const;

	/// Adds an item and returns the index of it
	size_t addItem(wstring text, uint data = 0);

	/// Removes an item from the combo box.
	/**
	* Warning. This will change the index of all following items 
	*/
	void removeItem(size_t idx);

	/// Deletes all items in the combo box
	void clear();

	/// Returns id of selected item. returns -1 if no item is selected.
	ptrdiff_t getSelected() const;

	/// Sets the selected item. Set this to -1 if no item should be selected
	void setSelected(ptrdiff_t idx);

	/// Sets text justification of the text area
	/**
	* Params:
	* 	horizontal=  EGUIA_UPPERLEFT for left justified (default),
	* EGUIA_LOWEERRIGHT for right justified, or EGUIA_CENTER for centered text.
	* 	vertical=  EGUIA_UPPERLEFT to align with top edge,
	* EGUIA_LOWEERRIGHT for bottom edge, or EGUIA_CENTER for centered text (default). 
	*/
	void setTextAlignment(EGUI_ALIGNMENT horizontal, EGUI_ALIGNMENT vertical);

	/// Set the maximal number of rows for the selection listbox
	void setMaxSelectionRows(size_t max);

	/// Get the maximimal number of rows for the selection listbox
	size_t getMaxSelectionRows() const;
}