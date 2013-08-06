// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIInOutFader;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.video.SColor;

/// Element for fading out or in
/**
* Here is a small example on how the class is used. In this example we fade
* in from a total red screen in the beginning. As you can see, the fader is not
* only useful for dramatic in and out fading, but also to show that the player
* is hit in a first person shooter game for example.
* Examples:
* ------
* IGUIInOutFader fader = device.getGUIEnvironment().addInOutFader();
* fader.setColor(SColor(0,255,0,0));
* fader.fadeIn(4000);
* ------
*/
abstract class IGUIInOutFader : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_IN_OUT_FADER, environment, parent, id, rectangle);
	}

	/// Gets the color to fade out to or to fade in from.
	SColor getColor() const;

	/// Sets the color to fade out to or to fade in from.
	/**
	* Params:
	* 	color=  Color to where it is faded out od from it is faded in. 
	*/
	void setColor(SColor color);
	void setColor(SColor source, SColor dest);

	/// Starts the fade in process.
	/**
	* In the beginning the whole rect is drawn by the set color
	* (black by default) and at the end of the overgiven time the
	* color has faded out.
	* Params:
	* 	time=  Time specifying how long it should need to fade in,
	* in milliseconds. 
	*/
	void fadeIn(uint time);

	/// Starts the fade out process.
	/**
	* In the beginning everything is visible, and at the end of
	* the time only the set color (black by the fault) will be drawn.
	* Params:
	* 	time=  Time specifying how long it should need to fade out,
	* in milliseconds. 
	*/
	void fadeOut(uint time);

	/// Returns if the fade in or out process is done.
	bool isReady() const;
}
