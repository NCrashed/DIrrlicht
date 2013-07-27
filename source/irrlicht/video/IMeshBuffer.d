// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.IMeshBuffer;

import irrlicht.video.SMaterial;
import irrlicht.core.aabbox3d;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.scene.EPrimitiveTypes;

/// Data structure for holding a mesh with a single material.
/**
* A part of an IMesh which has the same material on each face of that
* group. Logical groups of an IMesh need not be put into separate mesh
* buffers, but can be. Separately animated parts of the mesh must be put
* into separate mesh buffers.
* Some mesh buffer implementations have limitations on the number of
* vertices the buffer can hold. In that case, logical grouping can help.
* Moreover, the number of vertices should be optimized for the GPU upload,
* which often depends on the type of gfx card. Typial figures are
* 1000-10000 vertices per buffer.
* SMeshBuffer is a simple implementation of a MeshBuffer, which supports
* up to 65535 vertices.
* Since meshbuffers are used for drawing, and hence will be exposed
* to the driver, chances are high that they are grab()'ed from somewhere.
* It's therefore required to dynamically allocate meshbuffers which are
* passed to a video driver and only drop the buffer once it's not used in
* the current code block anymore.
*/
interface IMeshBuffer
{
	/// Get the material of this meshbuffer
	/**
	* Returns: Material of this buffer. 
	*/
	SMaterial getMaterial();

	/// Get the material of this meshbuffer
	/**
	* Returns: Material of this buffer. 
	*/
	const SMaterial getMaterial();

	/// Get type of vertex data which is stored in this meshbuffer.
	/**
	* Returns: Vertex type of this buffer. 
	*/
	E_VERTEX_TYPE getVertexType();

	/// Get access to vertex data. The data is an array of vertices.
	/**
	* Which vertex type is used can be determined by getVertexType().
	* Returns: Pointer to array of vertices. 
	*/
	const void* getVertices();

	/// Get access to vertex data. The data is an array of vertices.
	/**
	* Which vertex type is used can be determined by getVertexType().
	* Returns: Pointer to array of vertices. 
	*/
	void* getVertices();

	/// Get amount of vertices in meshbuffer.
	/**
	* Returns: Number of vertices in this buffer. 
	*/
	uint getVertexCount();

	/// Get type of index data which is stored in this meshbuffer.
	/**
	* Returns: Index type of this buffer. 
	*/
	E_INDEX_TYPE getIndexType();

	/// Get access to Indices.
	/**
	* Returns: Pointer to indices array. 
	*/
	const ushort* getIndices();

	/// Get access to Indices.
	/**
	* Returns: Pointer to indices array. 
	*/
	ushort* getIndices();

	/// Get amount of indices in this meshbuffer.
	/**
	* Returns: Number of indices in this buffer. 
	*/
	uint getIndexCount();

	/// Get the axis aligned bounding box of this meshbuffer.
	/**
	* Returns: Axis aligned bounding box of this buffer. 
	*/
	const ref aabbox3df getBoundingBox();

	/// Set axis aligned bounding box
	/**
	* Params:
	* 	box=  User defined axis aligned bounding box to use
	* for this buffer. 
	*/
	void setBoundingBox(ref const aabbox3df box);

	/// Set axis aligned bounding box
	/**
	* Params:
	* 	box=  User defined axis aligned bounding box to use
	* for this buffer. 
	*/
	void setBoundingBox(const aabbox3df box);

	/// Recalculates the bounding box. Should be called if the mesh changed.
	void recalculateBoundingBox();

	/// returns position of vertex i
	const ref vector3df getPosition(uint i);

	/// returns position of vertex i
	vector3df getPosition(uint i);

	/// returns normal of vertex i
	const ref vector3df getNormal(uint i);

	/// returns normal of vertex i
	vector3df getNormal(uint i);

	/// returns texture coord of vertex i
	const ref vector2df getTCoords(uint i);

	/// returns texture coord of vertex i
	vector2df getTCoords(uint i);

	/// Append the vertices and indices to the current buffer
	/**
	* Only works for compatible vertex types.
	* Params:
	* 	vertices=  Pointer to a vertex array.
	* 	numVertices=  Number of vertices in the array.
	* 	indices=  Pointer to index array.
	* 	numIndices=  Number of indices in array. 
	*/
	void append(const(void*) vertices, uint numVertices, const(ushort*) indices, uint numIndices);

	/// Append the meshbuffer to the current buffer
	/**
	* Only works for compatible vertex types
	* Params:
	* 	other=  Buffer to append to this one. 
	*/
	void append(const IMeshBuffer other);

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Vertex();

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Index();

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING newMappingHint, E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX );

	/// flags the meshbuffer as changed, reloads hardware buffers
	void setDirty(E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX);

	/// Get the currently used ID for identification of changes.
	/**
	* This shouldn't be used for anything outside the VideoDriver. 
	*/
	uint getChangedID_Vertex();

	/// Get the currently used ID for identification of changes.
	/**
	* This shouldn't be used for anything outside the VideoDriver. 
	*/
	uint getChangedID_Index();
};
