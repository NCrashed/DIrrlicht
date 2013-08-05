// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ITriangleSelector;

import irrlicht.scene.ISceneNode;
import irrlicht.core.triangle3d;
import irrlicht.core.aabbox3d;
import irrlicht.core.matrix4;
import irrlicht.core.line3d;

/// Interface to return triangles with specific properties.
/**
* Every ISceneNode may have a triangle selector, available with
* ISceneNode::getTriangleScelector() or ISceneManager::createTriangleSelector.
* This is used for doing collision detection: For example if you know, that a
* collision may have happened in the area between (1,1,1) and (10,10,10), you
* can get all triangles of the scene node in this area with the
* ITriangleSelector easily and check every triangle if it collided. 
*/
interface ITriangleSelector
{
	/// Get amount of all available triangles in this selector
	int getTriangleCount() const;

	/// Gets the triangles for one associated node.
	/**
	* This returns all triangles for one scene node associated with this
	* selector.  If there is more than one scene node associated (e.g. for
	* an IMetaTriangleSelector) this this function may be called multiple
	* times to retrieve all triangles.
	* Params:
	* 	triangles=  Array where the resulting triangles will be
	* written to.
	* 	transform=  Pointer to matrix for transforming the triangles
	* before they are returned. Useful for example to scale all triangles
	* down into an ellipsoid space. If this pointer is null, no
	* transformation will be done. 
	*/
	void getTriangles()(out triangle3df[] triangles,
		const matrix4* transform = null) const;

	/// Gets the triangles for one associated node which may lie within a specific bounding box.
	/**
	* This returns all triangles for one scene node associated with this
	* selector.  If there is more than one scene node associated (e.g. for
	* an IMetaTriangleSelector) this this function may be called multiple
	* times to retrieve all triangles.
	* This method will return at least the triangles that intersect the box,
	* but may return other triangles as well.
	* Params:
	* 	triangles=  Array where the resulting triangles will be written
	* to.
	* 	box=  Only triangles which are in this axis aligned bounding box
	* will be written into the array.
	* 	transform=  Pointer to matrix for transforming the triangles
	* before they are returned. Useful for example to scale all triangles
	* down into an ellipsoid space. If this pointer is null, no
	* transformation will be done. 
	*/
	void getTriangles()(out triangle3df[] triangles, auto ref const aabbox3d!float box,
		const matrix4* transform = null) const;

	/// Gets the triangles for one associated node which have or may have contact with a 3d line.
	/**
	* This returns all triangles for one scene node associated with this
	* selector.  If there is more than one scene node associated (e.g. for
	* an IMetaTriangleSelector) this this function may be called multiple
	* times to retrieve all triangles.
	* Please note that unoptimized triangle selectors also may return
	* triangles which are not in contact at all with the 3d line.
	* Params:
	* 	triangles=  Array where the resulting triangles will be written
	* to.
	* 	arraySize=  Size of the target array.
	* 	outTriangleCount=  Amount of triangles which have been written
	* into the array.
	* 	line=  Only triangles which may be in contact with this 3d line
	* will be written into the array.
	* 	transform=  Pointer to matrix for transforming the triangles
	* before they are returned. Useful for example to scale all triangles
	* down into an ellipsoid space. If this pointer is null, no
	* transformation will be done. 
	*/
	void getTriangles()(out triangle3df[] triangles, auto ref const line3d!float line,
		const matrix4* transform = null) const;

	/// Get scene node associated with a given triangle.
	/**
	* This allows to find which scene node (potentially of several) is
	* associated with a specific triangle.
	* Params:
	* 	triangleIndex=  the index of the triangle for which you want to find
	* the associated scene node.
	* Returns: The scene node associated with that triangle.
	*/
	ISceneNode getSceneNodeForTriangle(size_t triangleIndex) const;

	/// Get number of TriangleSelectors that are part of this one
	/**
	* Only useful for MetaTriangleSelector, others return 1
	*/
	size_t getSelectorCount() const;

	/// Get TriangleSelector based on index based on getSelectorCount
	/**
	* Only useful for MetaTriangleSelector, others return 'this' or 0
	*/
	ITriangleSelector getSelector(size_t index);

	/// Get TriangleSelector based on index based on getSelectorCount
	/**
	* Only useful for MetaTriangleSelector, others return 'this' or 0
	*/
	const ITriangleSelector getSelector(size_t index) const;
}
