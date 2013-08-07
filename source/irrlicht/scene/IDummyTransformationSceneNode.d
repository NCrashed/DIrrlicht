// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IDummyTransformationSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.core.matrix4;

/// Dummy scene node for adding additional transformations to the scene graph.
/**
* This scene node does not render itself, and does not respond to set/getPosition,
* set/getRotation and set/getScale. Its just a simple scene node that takes a
* matrix as relative transformation, making it possible to insert any transformation
* anywhere into the scene graph.
* This scene node is for example used by the IAnimatedMeshSceneNode for emulating
* joint scene nodes when playing skeletal animations.
*/
abstract class IDummyTransformationSceneNode : ISceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id)
	{
		super(parent, mgr, id);
	}

	/// Returns a reference to the current relative transformation matrix.
	/**
	* This is the matrix, this scene node uses instead of scale, translation
	* and rotation. 
	*/
	ref matrix4 getRelativeTransformationMatrix();
}