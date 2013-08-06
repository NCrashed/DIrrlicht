// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIContextMenu;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.core.rect;

/// Close behavior.
/// Default is ECMC_REMOVE
enum ECONTEXT_MENU_CLOSE
{
	/// do nothing - menu stays open
	ECMC_IGNORE = 0,

	/// remove the gui element
	ECMC_REMOVE = 1,

	/// call setVisible(false)
	ECMC_HIDE = 2

 	// note to implementors - this is planned as bitset, so continue with 4 if you need to add further flags.
};

/// GUI Context menu interface.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_ELEMENT_CLOSED
* \li EGET_MENU_ITEM_SELECTED
*/
abstract class IGUIContextMenu : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_CONTEXT_MENU, environment, parent, id, rectangle);
	}

	/// set behavior when menus are closed
	void setCloseHandling(ECONTEXT_MENU_CLOSE onClose);

	/// get current behavior when the menu will be closed
	ECONTEXT_MENU_CLOSE getCloseHandling() const;

	/// Get amount of menu items
	size_t getItemCount() const;

	/// Adds a menu item.
	/**
	* Params:
	* 	text=  Text of menu item. Set this to 0 to create
	* an separator instead of a real item, which is the same like
	* calling addSeparator();
	* 	commandId=  Command id of menu item, a simple id you may
	* set to whatever you want.
	* 	enabled=  Specifies if the menu item should be enabled.
	* 	hasSubMenu=  Set this to true if there should be a submenu
	* at this item. You can access this submenu via getSubMenu().
	* 	checked=  Specifies if the menu item should be initially checked.
	* 	autoChecking=  Specifies if the item should be checked by clicking
	* Returns: Returns the index of the new item 
	*/
	size_t addItem(wstring text, size_t commandId = 0, bool enabled=true,
		bool hasSubMenu=false, bool checked=false, bool autoChecking=false);

    /// Insert a menu item at specified position.
	/**
	* Params:
	* 	idx=  Position to insert the new element,
	* should be smaller than itemcount otherwise the item is added to the end.
	* 	text=  Text of menu item. Set this to 0 to create
	* an separator instead of a real item, which is the same like
	* calling addSeparator();
	* 	commandId=  Command id of menu item, a simple id you may
	* set to whatever you want.
	* 	enabled=  Specifies if the menu item should be enabled.
	* 	hasSubMenu=  Set this to true if there should be a submenu
	* at this item. You can access this submenu via getSubMenu().
	* 	checked=  Specifies if the menu item should be initially checked.
	* 	autoChecking=  Specifies if the item should be checked by clicking
	* Returns: Returns the index of the new item 
	*/
	size_t insertItem(size_t idx, wstring text, size_t commandId = 0, bool enabled=true,
		bool hasSubMenu=false, bool checked=false, bool autoChecking=false);

	/// Find an item by it's CommandID
	/**
	* Params:
	* 	commandId=  We are looking for the first item which has this commandID
	* 	idxStartSearch=  Start searching from this index.
	* Returns: Returns the index of the item when found or otherwise -1. 
	*/
	ptrdiff_t findItemWithCommandId(size_t commandId, size_t idxStartSearch=0) const;

	/// Adds a separator item to the menu
	void addSeparator();

	/// Get text of the menu item.
	/**
	* Params:
	* 	idx=  Zero based index of the menu item 
	*/
	wstring getItemText(size_t idx) const;

	/// Sets text of the menu item.
	/**
	* Params:
	* 	idx=  Zero based index of the menu item
	* 	text=  New text of the item. 
	*/
	void setItemText(size_t idx, wstring text);

	/// Check if a menu item is enabled
	/**
	* Params:
	* 	idx=  Zero based index of the menu item 
	*/
	bool isItemEnabled(size_t idx) const;

	/// Sets if the menu item should be enabled.
	/**
	* Params:
	* 	idx=  Zero based index of the menu item
	* 	enabled=  True if it is enabled, otherwise false. 
	*/
	void setItemEnabled(size_t idx, bool enabled);

	/// Sets if the menu item should be checked.
	/**
	* Params:
	* 	idx=  Zero based index of the menu item
	* 	enabled=  True if it is enabled, otherwise false. 
	*/
	void setItemChecked(size_t idx, bool enabled);

	/// Check if a menu item is checked
	/**
	* Params:
	* 	idx=  Zero based index of the menu item 
	*/
	bool isItemChecked(size_t idx) const;

	/// Removes a menu item
	/**
	* Params:
	* 	idx=  Zero based index of the menu item 
	*/
	void removeItem(size_t idx);

	/// Removes all menu items
	void removeAllItems();

	/// Get the selected item in the menu
	/**
	* Returns: Index of the selected item, -1 if none selected. 
	*/
	int getSelectedItem() const;

	/// Get the command id of a menu item
	/**
	* Params:
	* 	idx=  Zero based index of the menu item 
	*/
	int getItemCommandId(size_t idx) const;

	/// Sets the command id of a menu item
	/**
	* Params:
	* 	idx=  Zero based index of the menu item
	* 	id=  Command id of menu item, a simple id you may
	* set to whatever you want. 
	*/
	void setItemCommandId(size_t idx, size_t id);

	/// Get a pointer to the submenu of an item.
	/**
	* 0 is returned if there is no submenu
	* Params:
	* 	idx=  Zero based index of the menu item
	* Returns: Returns a pointer to the submenu of an item. 
	*/
	IGUIContextMenu getSubMenu(size_t idx) const;

	/// should the element change the checked status on clicking
	void setItemAutoChecking(size_t idx, bool autoChecking);

	/// does the element change the checked status on clicking
	bool getItemAutoChecking(size_t idx) const;

	/// When an eventparent is set it receives events instead of the usual parent element
	void setEventParent(IGUIElement parent);
}
