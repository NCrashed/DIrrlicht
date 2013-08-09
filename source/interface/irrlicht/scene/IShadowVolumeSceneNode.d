// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IShadowVolumeSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.IMesh;


/// Scene node for rendering a shadow volume into a stencil buffer.
abstract class IShadowVolumeSceneNode : ISceneNode
{
	/// constructor
	this(ISceneNode parent, ISceneManager mgr, int id)
	{
		super(parent, mgr, id);
	}

	/// Sets the mesh from which the shadow volume should be generated.
	/** 
	* To optimize shadow rendering, use a simpler mesh for shadows.
	*/
	void setShadowMesh(const IMesh mesh);

	/// Updates the shadow volumes for current light positions.
	void updateShadowVolumes();
}