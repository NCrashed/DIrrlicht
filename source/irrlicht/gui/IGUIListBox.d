// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIListBox;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUISpriteBank;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.video.SColor;
import irrlicht.core.rect;

/// Enumeration for listbox colors
enum EGUI_LISTBOX_COLOR
{
	/// Color of text
	EGUI_LBC_TEXT=0,
	/// Color of selected text
	EGUI_LBC_TEXT_HIGHLIGHT,
	/// Color of icon
	EGUI_LBC_ICON,
	/// Color of selected icon
	EGUI_LBC_ICON_HIGHLIGHT,
	/// Not used, just counts the number of available colors
	EGUI_LBC_COUNT
}


/// Default list box GUI element.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_LISTBOX_CHANGED
* \li EGET_LISTBOX_SELECTED_AGAIN
*/
abstract class IGUIListBox : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, int id, auto ref rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_LIST_BOX, environment, parent, id, rectangle);
	}

	/// returns amount of list items
	size_t getItemCount() const;

	/// returns string of a list item. the may id be a value from 0 to itemCount-1
	wstring getListItem(size_t id) const;

	/// adds an list item, returns id of item
	size_t addItem(wstring text);

	/// adds an list item with an icon
	/**
	* Params:
	* 	text=  Text of list entry
	* 	icon=  Sprite index of the Icon within the current sprite bank. Set it to -1 if you want no icon
	* Returns: The id of the new created item 
	*/
	size_t addItem(wstring text, ptrdiff_t icon);

	/// Removes an item from the list
	void removeItem(size_t index);

	/// get the the id of the item at the given absolute coordinates
	/**
	* Returns: The id of the listitem or -1 when no item is at those coordinates
	*/
	int getItemAt(int xpos, int ypos) const;

	/// Returns the icon of an item
	int getIcon(size_t index) const;

	/// Sets the sprite bank which should be used to draw list icons.
	/**
	* This font is set to the sprite bank of the built-in-font by
	* default. A sprite can be displayed in front of every list item.
	* An icon is an index within the icon sprite bank. Several
	* default icons are available in the skin through getIcon. 
	*/
	void setSpriteBank(IGUISpriteBank bank);

	/// clears the list, deletes all items in the listbox
	void clear();

	/// returns id of selected item. returns -1 if no item is selected.
	ptrdiff_t getSelected() const;

	/// sets the selected item. Set this to -1 if no item should be selected
	void setSelected(size_t index);

	/// sets the selected item. Set this to 0 if no item should be selected
	void setSelected(wstring item);

	/// set whether the listbox should scroll to newly selected items
	void setAutoScrollEnabled(bool scroll);

	/// returns true if automatic scrolling is enabled, false if not.
	bool isAutoScrollEnabled() const;

	/// set all item colors at given index to color
	void setItemOverrideColor(size_t index, SColor color);

	/// set all item colors of specified type at given index to color
	void setItemOverrideColor(size_t index, EGUI_LISTBOX_COLOR colorType, SColor color);

	/// clear all item colors at index
	void clearItemOverrideColor(size_t index);

	/// clear item color at index for given colortype
	void clearItemOverrideColor(size_t index, EGUI_LISTBOX_COLOR colorType);

	/// has the item at index its color overwritten?
	bool hasItemOverrideColor(size_t index, EGUI_LISTBOX_COLOR colorType) const;

	/// return the overwrite color at given item index.
	SColor getItemOverrideColor(size_t index, EGUI_LISTBOX_COLOR colorType) const;

	/// return the default color which is used for the given colorType
	SColor getItemDefaultColor(EGUI_LISTBOX_COLOR colorType) const;

	/// set the item at the given index
	void setItem(size_t index, wstring text, ptrdiff_t icon);

	/// Insert the item at the given index
	/**
	* Returns: The index on success or -1 on failure. 
	*/
	ptrdiff_t insertItem(size_t index, wstring text, ptrdiff_t icon);

	/// Swap the items at the given indices
	void swapItems(size_t index1, size_t index2);

	/// set global itemHeight
	void setItemHeight( int height );

	/// Sets whether to draw the background
	void setDrawBackground(bool draw);
}
