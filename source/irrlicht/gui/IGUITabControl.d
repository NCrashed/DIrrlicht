// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUITabControl;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.EGUIAlignment;
import irrlicht.gui.IGUISkin;
import irrlicht.video.SColor;
import irrlicht.core.rect;

/// A tab-page, onto which other gui elements could be added.
/**
* IGUITab refers to the page itself, not to the tab in the tabbar of an IGUITabControl. 
*/
abstract class IGUITab : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_TAB, environment, parent, id, rectangle);
	}

	/// Returns zero based index of tab if in tabcontrol.
	/**
	* Can be accessed later IGUITabControl.getTab() by this number.
	* Note that this number can change when other tabs are inserted or removed .
	*/
	size_t getNumber() const;

	/// sets if the tab should draw its background
	void setDrawBackground(bool draw=true);

	/// sets the color of the background, if it should be drawn.
	void setBackgroundColor(SColor c);

	/// returns true if the tab is drawing its background, false if not
	bool isDrawingBackground() const;

	/// returns the color of the background
	SColor getBackgroundColor() const;

	/// sets the color of the text
	void setTextColor(SColor c);

	/// gets the color of the text
	SColor getTextColor() const;
}

/// A standard tab control
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_TAB_CHANGED
*/
abstract class IGUITabControl : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_TAB_CONTROL, environment, parent, id, rectangle);
	}

	/// Adds a tab
	IGUITab addTab(wstring caption, size_t id = 0);

	/// Insert the tab at the given index
	/**
	* Returns: The tab on success or NULL on failure. 
	*/
	IGUITab insertTab(size_t idx, wstring caption, size_t id = 0);

	/// Removes a tab from the tabcontrol
	void removeTab(size_t idx);

	/// Clears the tabcontrol removing all tabs
	void clear();

	/// Returns amount of tabs in the tabcontrol
	size_t getTabCount() const;

	/// Returns a tab based on zero based index
	/**
	* Params:
	* 	idx=  zero based index of tab. Is a value betwenn 0 and getTabcount()-1;
	* Returns: Returns pointer to the Tab. Returns 0 if no tab
	* is corresponding to this tab. 
	*/
	IGUITab getTab(size_t idx) const;

	/// Brings a tab to front.
	/**
	* Params:
	* 	idx=  number of the tab.
	* Returns: Returns true if successful. 
	*/
	bool setActiveTab(size_t idx);

	/// Brings a tab to front.
	/**
	* Params:
	* 	tab=  pointer to the tab.
	* Returns: Returns true if successful. 
	*/
	bool setActiveTab(IGUITab tab);

	/// Returns which tab is currently active
	size_t getActiveTab() const;

	/// get the the id of the tab at the given absolute coordinates
	/**
	* Returns: The id of the tab or -1 when no tab is at those coordinates
	*/
	ptrdiff_t getTabAt(int xpos, int ypos) const;

	/// Set the height of the tabs
	void setTabHeight( int height );

	/// Get the height of the tabs
	/**
	* return Returns the height of the tabs 
	*/
	int getTabHeight() const;

	/// set the maximal width of a tab. Per default width is 0 which means "no width restriction".
	void setTabMaxWidth(int width );

	/// get the maximal width of a tab
	int getTabMaxWidth() const;

	/// Set the alignment of the tabs
	/**
	* Use EGUIA_UPPERLEFT or EGUIA_LOWERRIGHT 
	*/
	void setTabVerticalAlignment( EGUI_ALIGNMENT alignment );

	/// Get the alignment of the tabs
	/**
	* return Returns the alignment of the tabs 
	*/
	EGUI_ALIGNMENT getTabVerticalAlignment() const;

	/// Set the extra width added to tabs on each side of the text
	void setTabExtraWidth( int extraWidth );

	/// Get the extra width added to tabs on each side of the text
	/**
	* return Returns the extra width of the tabs 
	*/
	int getTabExtraWidth() const;
}
