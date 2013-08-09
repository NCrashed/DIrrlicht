// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IMetaTriangleSelector;

import irrlicht.scene.ITriangleSelector;

/// Interface for making multiple triangle selectors work as one big selector.
/**
* This is nothing more than a collection of one or more triangle selectors
* providing together the interface of one triangle selector. In this way,
* collision tests can be done with different triangle soups in one pass.
*/
interface IMetaTriangleSelector : ITriangleSelector
{
	/// Adds a triangle selector to the collection of triangle selectors.
	/**
	* Params:
	* 	toAdd=  Pointer to an triangle selector to add to the list. 
	*/
	void addTriangleSelector(ITriangleSelector toAdd);

	/// Removes a specific triangle selector from the collection.
	/**
	* Params:
	* 	toRemove=  Pointer to an triangle selector which is in the
	* list but will be removed.
	* Returns: True if successful, false if not. 
	*/
	bool removeTriangleSelector(ITriangleSelector toRemove);

	/// Removes all triangle selectors from the collection.
	void removeAllTriangleSelectors();
}
