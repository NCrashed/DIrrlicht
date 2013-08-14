// Copyright (C) 2006-2012 Michael Zeilfelder
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUISpinBox;

import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUIEditBox;
import irrlicht.core.rect;

/// Single line edit box + spin buttons
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_SPINBOX_CHANGED
*/
abstract class IGUISpinBox : IGUIElement
{
	/// constructor
	this(IGUIEnvironment environment, IGUIElement parent,
				int id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_SPIN_BOX, environment, parent, id, rectangle);
	}

	/// Access the edit box used in the spin control
	IGUIEditBox getEditBox() const;

	/// set the current value of the spinbox
	/**
	* Params:
	* 	val=  value to be set in the spinbox 
	*/
	void setValue(float val);

	/// Get the current value of the spinbox
	float getValue() const;

	/// set the range of values which can be used in the spinbox
	/**
	* Params:
	* 	min=  minimum value
	* 	max=  maximum value 
	*/
	void setRange(float min, float max);

	/// get the minimum value which can be used in the spinbox
	float getMin() const;

	/// get the maximum value which can be used in the spinbox
	float getMax() const;

	/// Step size by which values are changed when pressing the spinbuttons
	/**
	* The step size also determines the number of decimal places to display
	* Params:
	* 	step=  stepsize used for value changes when pressing spinbuttons 
	*/
	void setStepSize(float step=1.0f);

	/// Sets the number of decimal places to display.
	/// Note that this also rounds the range to the same number of decimal places.
	/**
	* Params:
	* 	places=  The number of decimal places to display, use -1 to reset 
	*/
	void setDecimalPlaces(int places);

	/// get the current step size
	float getStepSize() const;
}

