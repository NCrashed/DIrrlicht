// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IMeshSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.IShadowVolumeSceneNode;
import irrlicht.scene.IMesh;
import irrlicht.core.vector3d;

/// A scene node displaying a static mesh
abstract class IMeshSceneNode : ISceneNode
{
	/// Constructor
	/**
	* Use setMesh() to set the mesh to display.
	*/
	this(ISceneNode parent, ISceneManager mgr, int id,
			const vector3df position = vector3df(0,0,0),
			const vector3df rotation = vector3df(0,0,0),
			const vector3df scale = vector3df(1,1,1))
	{
		super(parent, mgr, id, position, rotation, scale);
	}

	/// Sets a new mesh to display
	/**
	* Params:
	* 	mesh=  Mesh to display. 
	*/
	void setMesh(IMesh mesh);

	/// Get the currently defined mesh for display.
	/**
	* Returns: Pointer to mesh which is displayed by this node. 
	*/
	IMesh getMesh();

	/// Creates shadow volume scene node as child of this node.
	/**
	* The shadow can be rendered using the ZPass or the zfail
	* method. ZPass is a little bit faster because the shadow volume
	* creation is easier, but with this method there occur ugly
	* looking artifacs when the camera is inside the shadow volume.
	* These error do not occur with the ZFail method.
	* Params:
	* 	shadowMesh=  Optional custom mesh for shadow volume.
	* 	id=  Id of the shadow scene node. This id can be used to
	* identify the node later.
	* 	zfailmethod=  If set to true, the shadow will use the
	* zfail method, if not, zpass is used.
	* 	infinity=  Value used by the shadow volume algorithm to
	* scale the shadow volume (for zfail shadow volume we support only
	* finite shadows, so camera zfar must be larger than shadow back cap,
	* which is depend on infinity parameter).
	* Returns: Pointer to the created shadow scene node. This pointer
	* should not be dropped. See IReferenceCounted::drop() for more
	* information. 
	*/
	IShadowVolumeSceneNode addShadowVolumeSceneNode(const IMesh shadowMesh = null,
		int id = -1, bool zfailmethod = true, float infinity = 1000.0f);

	/// Sets if the scene node should not copy the materials of the mesh but use them in a read only style.
	/**
	* In this way it is possible to change the materials of a mesh
	* causing all mesh scene nodes referencing this mesh to change, too.
	* Params:
	* 	readonly=  Flag if the materials shall be read-only. 
	*/
	void setReadOnlyMaterials(bool readonly);

	/// Check if the scene node should not copy the materials of the mesh but use them in a read only style
	/**
	* This flag can be set by setReadOnlyMaterials().
	* Returns: Whether the materials are read-only. 
	*/
	bool isReadOnlyMaterials() const;
}

