// Copyright (C) 2008-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IDynamicMeshBuffer;

import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.IVertexBuffer;
import irrlicht.scene.IIndexBuffer;
import irrlicht.video.SMaterial;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.core.aabbox3d;
import std.range;

/**
* a dynamic meshBuffer 
*/
interface IDynamicMeshBuffer : IMeshBuffer
{
	IVertexBuffer   getVertexBuffer() const;
	IIndexBuffer  getIndexBuffer()() const;

	void setVertexBuffer(IVertexBuffer vertexBuffer);
	void setIndexBuffer()(IIndexBuffer indexBuffer);

	/// Get the material of this meshbuffer
	/**
	* Returns: Material of this buffer. 
	*/
	SMaterial getMaterial();

	/// Get the material of this meshbuffer
	/**
	* Returns: Material of this buffer. 
	*/
	const SMaterial getMaterial() const;

	/// Get the axis aligned bounding box of this meshbuffer.
	/**
	* Returns: Axis aligned bounding box of this buffer. 
	*/
	auto ref const aabbox3df getBoundingBox()() const;

	/// Set axis aligned bounding box
	/**
	* Params:
	* 	box=  User defined axis aligned bounding box to use
	* for this buffer. 
	*/
	void setBoundingBox()(auto ref const aabbox3df box);

	/// Recalculates the bounding box. Should be called if the mesh changed.
	void recalculateBoundingBox();

	/// Append the vertices and indices to the current buffer
	/**
	* Only works for compatible vertex types.
	* Params:
	* 	vertices=  Pointer to a vertex array.
	* 	numVertices=  Number of vertices in the array.
	* 	indices=  Pointer to index array.
	* 	numIndices=  Number of indices in array. 
	*/
	void append(const void[] vertices, const ushort[] indices);


	/// Append the meshbuffer to the current buffer
	/**
	* Only works for compatible vertex types
	* Params:
	* 	other=  Buffer to append to this one. 
	*/
	void append(const IMeshBuffer other);

	// ------------------- To be removed? -------------------  //

	/// get the current hardware mapping hint
	deprecated final E_HARDWARE_MAPPING getHardwareMappingHint_Vertex() const
	{
		return getVertexBuffer().getHardwareMappingHint();
	}

	/// get the current hardware mapping hint
	deprecated final E_HARDWARE_MAPPING getHardwareMappingHint_Index() const
	{
		return getIndexBuffer().getHardwareMappingHint();
	}

	/// set the hardware mapping hint, for driver
	deprecated final void setHardwareMappingHint( E_HARDWARE_MAPPING NewMappingHint, 
		E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX )
	{
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_VERTEX)
			getVertexBuffer().setHardwareMappingHint(NewMappingHint);
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_INDEX)
			getIndexBuffer().setHardwareMappingHint(NewMappingHint);
	}

	/// flags the mesh as changed, reloads hardware buffers
	deprecated final void setDirty(E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
	{
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_VERTEX)
			getVertexBuffer().setDirty();
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_INDEX)
			getIndexBuffer().setDirty();
	}

	deprecated final size_t getChangedID_Vertex() const
	{
		return getVertexBuffer().getChangedID();
	}

	deprecated final size_t getChangedID_Index() const
	{
		return getIndexBuffer().getChangedID();
	}

	// ------------------- Old interface -------------------  //

	/// Get type of vertex data which is stored in this meshbuffer.
	/**
	* Returns: Vertex type of this buffer. 
	*/
	deprecated final E_VERTEX_TYPE getVertexType() const
	{
		return getVertexBuffer().getType();
	}

	/// Get access to vertex data. The data is an array of vertices.
	/**
	* Which vertex type is used can be determined by getVertexType().
	* Returns: Pointer to array of vertices. 
	*/
	deprecated final const void* getVertices() const
	{
		return getVertexBuffer().getData();
	}

	/// Get access to vertex data. The data is an array of vertices.
	/**
	* Which vertex type is used can be determined by getVertexType().
	* Returns: Pointer to array of vertices. 
	*/
	deprecated final void* getVertices()
	{
		return getVertexBuffer().getData();
	}

	/// Get amount of vertices in meshbuffer.
	/**
	* Returns: Number of vertices in this buffer. 
	*/
	deprecated final size_t getVertexCount() const
	{
		return getVertexBuffer().size();
	}

	/// Get type of index data which is stored in this meshbuffer.
	/**
	* Returns: Index type of this buffer. 
	*/
	deprecated final E_INDEX_TYPE getIndexType() const
	{
		return getIndexBuffer().getType();
	}

	/// Get access to Indices.
	/**
	* Returns: Pointer to indices array. 
	*/
	deprecated final Range getIndices(Range)() const
		if(isRandomAccessRange!Range)
	{
		return getIndexBuffer().getData();
	}

	/// Get access to Indices.
	/**
	* Returns: Pointer to indices array. 
	*/
	deprecated final Range getIndices(Range)()
		if(isRandomAccessRange!Range)
	{
		return getIndexBuffer().getData();
	}

	/// Get amount of indices in this meshbuffer.
	/**
	* Returns: Number of indices in this buffer. 
	*/
	deprecated final size_t getIndexCount() const
	{
		return getIndexBuffer().size();
	}

	/// returns position of vertex i
	deprecated final auto ref const vector3df getPosition(size_t i)() const
	{
		return getVertexBuffer()[i].Pos;
	}

	/// returns position of vertex i
	deprecated final auto ref vector3df getPosition()(size_t i)
	{
		return getVertexBuffer()[i].Pos;
	}

	/// returns texture coords of vertex i
	deprecated final auto ref const vector2df getTCoords()(size_t i) const
	{
		return getVertexBuffer()[i].TCoords;
	}

	/// returns texture coords of vertex i
	deprecated final auto ref vector2df getTCoords()(size_t i)
	{
		return getVertexBuffer()[i].TCoords;
	}

	/// returns normal of vertex i
	deprecated final auto ref const vector3df getNormal(size_t i) const
	{
		return getVertexBuffer()[i].Normal;
	}

	/// returns normal of vertex i
	deprecated final auto ref vector3df getNormal(size_t i)
	{
		return getVertexBuffer()[i].Normal;
	}
}