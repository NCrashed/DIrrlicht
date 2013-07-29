// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IMesh;

import irrlicht.video.SMaterial;
import irrlicht.video.EMaterialFlags;
import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.core.aabbox3d;

/// Class which holds the geometry of an object.
/**
* An IMesh is nothing more than a collection of some mesh buffers
* (IMeshBuffer). SMesh is a simple implementation of an IMesh.
* A mesh is usually added to an IMeshSceneNode in order to be rendered.
*/
interface IMesh
{
	/// Get the amount of mesh buffers.
	/**
	* Returns: Amount of mesh buffers (IMeshBuffer) in this mesh. 
	*/
	size_t getMeshBufferCount() const;

	/// Get pointer to a mesh buffer.
	/**
	* Params:
	* 	nr=  Zero based index of the mesh buffer. The maximum value is
	* getMeshBufferCount() - 1;
	* Returns: Pointer to the mesh buffer or 0 if there is no such
	* mesh buffer. 
	*/
	IMeshBuffer getMeshBuffer(size_t nr);

	/// Get pointer to a mesh buffer which fits a material
	/**
	* Params:
	* 	material=  material to search for
	* Returns: Pointer to the mesh buffer or 0 if there is no such
	* mesh buffer. 
	*/
	IMeshBuffer getMeshBuffer(const SMaterial material);

	/// Get an axis aligned bounding box of the mesh.
	/**
	* Returns: Bounding box of this mesh. 
	*/
	auto ref aabbox3df getBoundingBox()() const;

	/// Set user-defined axis aligned bounding box
	/**
	* Params:
	* 	box=  New bounding box to use for the mesh. 
	*/
	void setBoundingBox()(auto ref const aabbox3df box);

	/// Sets a flag of all contained materials to a new value.
	/**
	* Params:
	* 	flag=  Flag to set in all materials.
	* 	newvalue=  New value to set in all materials. 
	*/
	void setMaterialFlag(E_MATERIAL_FLAG flag, bool newvalue);

	/// Set the hardware mapping hint
	/**
	* This methods allows to define optimization hints for the
	* hardware. This enables, e.g., the use of hardware buffers on
	* pltforms that support this feature. This can lead to noticeable
	* performance gains. 
	*/
	void setHardwareMappingHint(E_HARDWARE_MAPPING newMappingHint, E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX);

	/// Flag the meshbuffer as changed, reloads hardware buffers
	/**
	* This method has to be called every time the vertices or
	* indices have changed. Otherwise, changes won't be updated
	* on the GPU in the next render cycle. 
	*/
	void setDirty(E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX);

	/// foreach implementation
	int opApply(int delegate(IMeshBuffer) dg);

	/// foreach_reverse implementation
	int opApplyReverse(int delegate(IMeshBuffer) dg);

	/// foreach implementation with indexing
	int opApply(int delegate(size_t, IMeshBuffer) dg);

	/// foreach_reverse implementation with indexing
	int opApplyReverse(int delegate(size_t, IMeshBuffer) dg);
}
