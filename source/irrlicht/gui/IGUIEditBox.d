// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIEditBox;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.EGUIAlignment;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.IGUIFont;
import irrlicht.video.SColor;
import irrlicht.core.rect;
import irrlicht.core.dimension2d;

/// Single line edit box for editing simple text.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_EDITBOX_ENTER
* \li EGET_EDITBOX_CHANGED
* \li EGET_EDITBOX_MARKING_CHANGED
*/
abstract class IGUIEditBox : IGUIElement
{
	/// constructor
	this(IGUIEnvironment environment, IGUIElement parent, int id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_EDIT_BOX, environment, parent, id, rectangle);
	}

	/// Sets another skin independent font.
	/**
	* If this is set to zero, the button uses the font of the skin.
	* Params:
	* 	font=  New font to set. 
	*/
	void setOverrideFont(IGUIFont font = null);

	/// Gets the override font (if any)
	/**
	* Returns: The override font (may be 0) 
	*/
	IGUIFont getOverrideFont() const;

	/// Get the font which is used right now for drawing
	/**
	* Currently this is the override font when one is set and the
	* font of the active skin otherwise 
	*/
	IGUIFont getActiveFont() const;

	/// Sets another color for the text.
	/**
	* If set, the edit box does not use the EGDC_BUTTON_TEXT color defined
	* in the skin, but the set color instead. You don't need to call
	* IGUIEditBox::enableOverrrideColor(true) after this, this is done
	* by this function.
	* If you set a color, and you want the text displayed with the color
	* of the skin again, call IGUIEditBox::enableOverrideColor(false);
	* Params:
	* 	color=  New color of the text. 
	*/
	void setOverrideColor(SColor color);

	/// Gets the override color
	SColor getOverrideColor() const;

	/// Sets if the text should use the override color or the color in the gui skin.
	/**
	* Params:
	* 	enable=  If set to true, the override color, which can be set
	* with IGUIEditBox::setOverrideColor is used, otherwise the
	* EGDC_BUTTON_TEXT color of the skin. 
	*/
	void enableOverrideColor(bool enable);

	/// Checks if an override color is enabled
	/**
	* Returns: true if the override color is enabled, false otherwise 
	*/
	bool isOverrideColorEnabled() const;

	/// Sets whether to draw the background
	void setDrawBackground(bool draw);

	/// Turns the border on or off
	/**
	* Params:
	* 	border=  true if you want the border to be drawn, false if not 
	*/
	void setDrawBorder(bool border);

	/// Sets text justification mode
	/**
	* Params:
	* 	horizontal=  EGUIA_UPPERLEFT for left justified (default),
	* EGUIA_LOWERRIGHT for right justified, or EGUIA_CENTER for centered text.
	* 	vertical=  EGUIA_UPPERLEFT to align with top edge,
	* EGUIA_LOWERRIGHT for bottom edge, or EGUIA_CENTER for centered text (default). 
	*/
	void setTextAlignment(EGUI_ALIGNMENT horizontal, EGUI_ALIGNMENT vertical);

	/// Enables or disables word wrap.
	/**
	* Params:
	* 	enable=  If set to true, words going over one line are
	* broken to the next line. 
	*/
	void setWordWrap(bool enable);

	/// Checks if word wrap is enabled
	/**
	* Returns: true if word wrap is enabled, false otherwise 
	*/
	bool isWordWrapEnabled() const;

	/// Enables or disables newlines.
	/**
	* Params:
	* 	enable=  If set to true, the EGET_EDITBOX_ENTER event will not be fired,
	* instead a newline character will be inserted. 
	*/
	void setMultiLine(bool enable);

	/// Checks if multi line editing is enabled
	/**
	* Returns: true if multi-line is enabled, false otherwise 
	*/
	bool isMultiLineEnabled() const;

	/// Enables or disables automatic scrolling with cursor position
	/**
	* Params:
	* 	enable=  If set to true, the text will move around with the cursor position 
	*/
	void setAutoScroll(bool enable);

	/// Checks to see if automatic scrolling is enabled
	/**
	* Returns: true if automatic scrolling is enabled, false if not 
	*/
	bool isAutoScrollEnabled() const;

	/// Sets whether the edit box is a password box. Setting this to true will
	/**
	* disable MultiLine, WordWrap and the ability to copy with ctrl+c or ctrl+x
	* Params:
	* 	passwordBox=  true to enable password, false to disable
	* 	passwordChar=  the character that is displayed instead of letters 
	*/
	void setPasswordBox(bool passwordBox, wchar passwordChar = '*');

	/// Returns true if the edit box is currently a password box.
	bool isPasswordBox() const;

	/// Gets the size area of the text in the edit box
	/**
	* Returns: The size in pixels of the text 
	*/
	dimension2du getTextDimension();

	/// Sets the maximum amount of characters which may be entered in the box.
	/**
	* Params:
	* 	max=  Maximum amount of characters. If 0, the character amount is
	* infinity. 
	*/
	void setMax(uint max);

	/// Returns maximum amount of characters, previously set by setMax();
	uint getMax() const;
}

