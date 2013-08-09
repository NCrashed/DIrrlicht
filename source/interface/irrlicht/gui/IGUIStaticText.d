// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIStaticText;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.EGUIAlignment;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.IGUIFont;
import irrlicht.video.SColor;
import irrlicht.core.rect;

/// Multi or single line text label.
abstract class IGUIStaticText : IGUIElement
{
	/// constructor
	this(IGUIEnvironment environment, IGUIElement parent, int id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_STATIC_TEXT, environment, parent, id, rectangle);
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
	* If set, the static text does not use the EGDC_BUTTON_TEXT color defined
	* in the skin, but the set color instead. You don't need to call
	* IGUIStaticText::enableOverrrideColor(true) after this, this is done
	* by this function.
	* If you set a color, and you want the text displayed with the color
	* of the skin again, call IGUIStaticText::enableOverrideColor(false);
	* Params:
	* 	color=  New color of the text. 
	*/
	void setOverrideColor(SColor color);

	/// Gets the override color
	/**
	* Returns: The override color 
	*/
	SColor getOverrideColor() const;

	/// Sets if the static text should use the overide color or the color in the gui skin.
	/**
	* Params:
	* 	enable=  If set to true, the override color, which can be set
	* with IGUIStaticText::setOverrideColor is used, otherwise the
	* EGDC_BUTTON_TEXT color of the skin. 
	*/
	void enableOverrideColor(bool enable);

	/// Checks if an override color is enabled
	/**
	* Returns: true if the override color is enabled, false otherwise 
	*/
	bool isOverrideColorEnabled() const;

	/// Sets another color for the background.
	void setBackgroundColor(SColor color);

	/// Sets whether to draw the background
	void setDrawBackground(bool draw);

	/// Gets the background color
	/**
	* Returns: The background color 
	*/
	SColor getBackgroundColor() const;

	/// Checks if background drawing is enabled
	/**
	* Returns: true if background drawing is enabled, false otherwise 
	*/
	bool isDrawBackgroundEnabled() const;

	/// Sets whether to draw the border
	void setDrawBorder(bool draw);

	/// Checks if border drawing is enabled
	/**
	* Returns: true if border drawing is enabled, false otherwise 
	*/
	bool isDrawBorderEnabled() const;

	/// Sets text justification mode
	/**
	* Params:
	* 	horizontal=  EGUIA_UPPERLEFT for left justified (default),
	* EGUIA_LOWEERRIGHT for right justified, or EGUIA_CENTER for centered text.
	* 	vertical=  EGUIA_UPPERLEFT to align with top edge,
	* EGUIA_LOWEERRIGHT for bottom edge, or EGUIA_CENTER for centered text (default). 
	*/
	void setTextAlignment(EGUI_ALIGNMENT horizontal, EGUI_ALIGNMENT vertical);

	/// Enables or disables word wrap for using the static text as multiline text control.
	/**
	* Params:
	* 	enable=  If set to true, words going over one line are
	* broken on to the next line. 
	*/
	void setWordWrap(bool enable);

	/// Checks if word wrap is enabled
	/**
	* Returns: true if word wrap is enabled, false otherwise 
	*/
	bool isWordWrapEnabled() const;

	/// Returns the height of the text in pixels when it is drawn.
	/**
	* This is useful for adjusting the layout of gui elements based on the height
	* of the multiline text in this element.
	* Returns: Height of text in pixels. 
	*/
	int getTextHeight() const;

	/// Returns the width of the current text, in the current font
	/**
	* If the text is broken, this returns the width of the widest line
	* Returns: The width of the text, or the widest broken line. 
	*/
	int getTextWidth() const;

	/// Set whether the text in this label should be clipped if it goes outside bounds
	void setTextRestrainedInside(bool restrainedInside);

	/// Checks if the text in this label should be clipped if it goes outside bounds
	bool isTextRestrainedInside() const;

	/// Set whether the string should be interpreted as right-to-left (RTL) text
	/**
	* Note:  This component does not implement the Unicode bidi standard, the
	* text of the component should be already RTL if you call this. The
	* main difference when RTL is enabled is that the linebreaks for multiline
	* elements are performed starting from the end.
	*/
	void setRightToLeft(bool rtl);

	/// Checks whether the text in this element should be interpreted as right-to-left
	bool isRightToLeft() const;
}
