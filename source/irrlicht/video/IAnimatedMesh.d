// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.IAnimatedMesh;

import irrlicht.core.aabbox3d;
import irrlicht.video.IMesh;

/// Possible types of (animated) meshes.
enum E_ANIMATED_MESH_TYPE
{
	/// Unknown animated mesh type.
	EAMT_UNKNOWN,

	/// Quake 2 MD2 model file
	EAMT_MD2,

	/// Quake 3 MD3 model file
	EAMT_MD3,

	/// Maya .obj static model
	EAMT_OBJ,

	/// Quake 3 .bsp static Map
	EAMT_BSP,

	/// 3D Studio .3ds file
	EAMT_3DS,

	/// My3D Mesh, the file format by Zhuck Dimitry
	EAMT_MY3D,

	/// Pulsar LMTools .lmts file. This Irrlicht loader was written by Jonas Petersen
	EAMT_LMTS,

	/// Cartography Shop .csm file. This loader was created by Saurav Mohapatra.
	EAMT_CSM,

	/// .oct file for Paul Nette's FSRad or from Murphy McCauley's Blender .oct exporter.
	/**
	* The oct file format contains 3D geometry and lightmaps and
	* can be loaded directly by Irrlicht 
	*/
	EAMT_OCT,

	/// Halflife MDL model file
	EAMT_MDL_HALFLIFE,

	/// generic skinned mesh
	EAMT_SKINNED
};

/// Interface for an animated mesh.
/**
* There are already simple implementations of this interface available so
* you don't have to implement this interface on your own if you need to:
* You might want to use irrlicht.scene.SAnimatedMesh, irrlicht.scene.SMesh,
* irrlicht.scene.SMeshBuffer etc. 
*/
interface IAnimatedMesh : IMesh
{
	/// Gets the frame count of the animated mesh.
	/**
	* Returns: The amount of frames. If the amount is 1,
	* it is a static, non animated mesh. 
	*/
	uint getFrameCount() const;

	/// Gets the animation speed of the animated mesh.
	/**
	* Returns: The number of frames per second to play the
	* animation with by default. If the amount is 0,
	* it is a static, non animated mesh. 
	*/
	float getAnimationSpeed() const;

	/// Sets the animation speed of the animated mesh.
	/**
	* Params:
	* 	fps=  Number of frames per second to play the
	* animation with by default. If the amount is 0,
	* it is not animated. The actual speed is set in the
	* scene node the mesh is instantiated in.
	*/
	void setAnimationSpeed(float fps);

	/// Returns the IMesh interface for a frame.
	/**
	* Params:
	* 	frame=  Frame number as zero based index. The maximum
	* frame number is getFrameCount() - 1;
	* 	detailLevel=  Level of detail. 0 is the lowest, 255 the
	* highest level of detail. Most meshes will ignore the detail level.
	* 	startFrameLoop=  Because some animated meshes (.MD2) are
	* blended between 2 static frames, and maybe animated in a loop,
	* the startFrameLoop and the endFrameLoop have to be defined, to
	* prevent the animation to be blended between frames which are
	* outside of this loop.
	* If startFrameLoop and endFrameLoop are both -1, they are ignored.
	* 	endFrameLoop=  see startFrameLoop.
	* Returns: Returns the animated mesh based on a detail level. 
	*/
	IMesh getMesh(int frame, int detailLevel=255, int startFrameLoop=-1, int endFrameLoop=-1);

	/// Returns the type of the animated mesh.
	/**
	* In most cases it is not neccessary to use this method.
	* This is useful for making a safe downcast. For example,
	* if getMeshType() returns EAMT_MD2 it's safe to cast the
	* IAnimatedMesh to IAnimatedMeshMD2.
	* Returns: s Type of the mesh. 
	*/
	E_ANIMATED_MESH_TYPE getMeshType() const;
}
