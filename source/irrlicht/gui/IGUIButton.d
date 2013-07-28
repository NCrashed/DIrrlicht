// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h

module irrlicht.gui.IGUIButton;

import irrlicht.gui.IGUIElement;
import irrlicht.video.ITexture;
import irrlicht.gui.IGUIFont;
import irrlicht.gui.IGUISpriteBank;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUIFont;


enum EGUI_BUTTON_STATE
{
	/// The button is not pressed
	EGBS_BUTTON_UP=0,
	/// The button is currently pressed down
	EGBS_BUTTON_DOWN,
	/// The mouse cursor is over the button
	EGBS_BUTTON_MOUSE_OVER,
	/// The mouse cursor is not over the button
	EGBS_BUTTON_MOUSE_OFF,
	/// The button has the focus
	EGBS_BUTTON_FOCUSED,
	/// The button doesn't have the focus
	EGBS_BUTTON_NOT_FOCUSED,
	/// not used, counts the number of enumerated items
	EGBS_COUNT
}

/// Names for gui button state icons
immutable string[] GUIButtonStateNames =
[
	"buttonUp",
	"buttonDown",
	"buttonMouseOver",
	"buttonMouseOff",
	"buttonFocused",
	"buttonNotFocused"
];

/// GUI Button interface.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_BUTTON_CLICKED
*/
interface IGUIButton: IGUIElement
{
	/// constructor
	abstract this(IGUIEnvironment environment, IGUIElement parent, int id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_BUTTON, environment, parent. id, rectangle);
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
	IGUIFont getOverrideFont(void) const;

	/// Get the font which is used right now for drawing
	/**
	* Currently this is the override font when one is set and the
	* font of the active skin otherwise 
	*/
	IGUIFont getActiveFont() const;

	/// Sets an image which should be displayed on the button when it is in normal state.
	/**
	* Params:
	* 	image=  Image to be displayed 
	*/
	void setImage(ITexture image = null);

	/// Sets a background image for the button when it is in normal state.
	/**
	* Params:
	* 	image=  Texture containing the image to be displayed
	* 	pos=  Position in the texture, where the image is located 
	*/
	void setImage(ITexture image, const ref rect!int pos);

	/// Sets a background image for the button when it is in pressed state.
	/**
	* If no images is specified for the pressed state via
	* setPressedImage(), this image is also drawn in pressed state.
	* Params:
	* 	image=  Image to be displayed 
	*/
	void setPressedImage(ITexture image = null);

	/// Sets an image which should be displayed on the button when it is in pressed state.
	/**
	* Params:
	* 	image=  Texture containing the image to be displayed
	* 	pos=  Position in the texture, where the image is located 
	*/
	void setPressedImage(ITexture image, const rect!int pos);

	/// Sets the sprite bank used by the button
	void setSpriteBank(IGUISpriteBank bank = null);

	/// Sets the animated sprite for a specific button state
	/**
	* Params:
	* 	index=  Number of the sprite within the sprite bank, use -1 for no sprite
	* 	state=  State of the button to set the sprite for
	* 	index=  The sprite number from the current sprite bank
	* 	color=  The color of the sprite
	* 	loop=  True if the animation should loop, false if not
	*/
	void setSprite(EGUI_BUTTON_STATE state, int index,
			SColor color=SColor(255,255,255,255), bool loop=false);

	/// Sets if the button should behave like a push button.
	/**
	* Which means it can be in two states: Normal or Pressed. With a click on the button,
	* the user can change the state of the button. 
	*/
	void setIsPushButton(bool isPushButton=true);

	/// Sets the pressed state of the button if this is a pushbutton
	void setPressed(bool pressed=true);

	/// Returns if the button is currently pressed
	bool isPressed() const;

	/// Sets if the alpha channel should be used for drawing background images on the button (default is false)
	void setUseAlphaChannel(bool useAlphaChannel=true);

	/// Returns if the alpha channel should be used for drawing background images on the button
	bool isAlphaChannelUsed() const;

	/// Returns whether the button is a push button
	bool isPushButton() const;

	/// Sets if the button should use the skin to draw its border and button face (default is true)
	void setDrawBorder(bool border=true);

	/// Returns if the border and button face are being drawn using the skin
	bool isDrawingBorder() const;

	/// Sets if the button should scale the button images to fit
	void setScaleImage(bool scaleImage=true);

	/// Checks whether the button scales the used images
	bool isScalingImage() const;
}

