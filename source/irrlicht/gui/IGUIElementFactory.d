// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIElementFactory;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;

/// Interface making it possible to dynamically create GUI elements
/**
* To be able to add custom elements to Irrlicht and to make it possible for the
* scene manager to save and load them, simply implement this interface and register it
* in your gui environment via IGUIEnvironment.registerGUIElementFactory.
*/
interface IGUIElementFactory
{
	/// adds an element to the gui environment based on its type id
	/**
	* Params:
	* 	type=  Type of the element to add.
	* 	parent=  Parent scene node of the new element, can be null to add to the root.
	* Returns: Pointer to the new element or null if not successful. 
	*/
	IGUIElement addGUIElement(EGUI_ELEMENT_TYPE type, IGUIElement parent = null);

	/// adds a GUI element to the GUI Environment based on its type name
	/**
	* Params:
	* 	typeName=  Type name of the element to add.
	* 	parent=  Parent scene node of the new element, can be null to add it to the root.
	* Returns: Pointer to the new element or null if not successful. 
	*/
	IGUIElement addGUIElement(string typeName, IGUIElement parent = null);

	/// Get amount of GUI element types this factory is able to create
	size_t getCreatableGUIElementTypeCount() const;

	/// Get type of a createable element type
	/**
	* Params:
	* 	idx=  Index of the element type in this factory. Must be a value between 0 and
	* getCreatableGUIElementTypeCount() 
	*/
	EGUI_ELEMENT_TYPE getCreateableGUIElementType(size_t idx) const;

	/// Get type name of a createable GUI element type by index
	/**
	* Params:
	* 	idx=  Index of the type in this factory. Must be a value between 0 and
	* getCreatableGUIElementTypeCount() 
	*/
	string getCreateableGUIElementTypeName(size_t idx) const;

	/// returns type name of a createable GUI element
	/**
	* Params:
	* 	type=  Type of GUI element.
	* Returns: Name of the type if this factory can create the type, otherwise "". 
	*/
	string getCreateableGUIElementTypeName(EGUI_ELEMENT_TYPE type) const;
}