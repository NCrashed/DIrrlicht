// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.SSharedMeshBuffer;

import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.video.SMaterial;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.core.aabbox3d;

/// Implementation of the IMeshBuffer interface with shared vertex list
class SSharedMeshBuffer : IMeshBuffer
{
	/// constructor
	this()
	{
		ChangedID_Vertex = 1;
		ChangedID_Index = 1;
		MappingHintVertex = E_HARDWARE_MAPPING.EHM_NEVER;
		MappingHintIndex = E_HARDWARE_MAPPING.EHM_NEVER;
	}

	/// constructor
	this(S3DVertex[] vertices)
	{
		Vertices = vertices;
	}

	/// returns the material of this meshbuffer
	const(SMaterial) getMaterial() const
	{
		return Material;
	}

	/// returns the material of this meshbuffer
	SMaterial getMaterial()
	{
		return Material;
	}

	/// returns pointer to vertices
	const(void[]) getVertices() const
	{
		if (Vertices !is null)
			return cast(void[])Vertices;
		else
			return null;
	}

	/// returns pointer to vertices
	void[] getVertices()
	{
		if (Vertices !is null)
			return cast(void[])Vertices;
		else
			return null;
	}

	/// returns amount of vertices
	size_t getVertexCount() const
	{
		if (Vertices !is null)
			return Vertices.length;
		else
			return 0;
	}

	/// returns pointer to Indices
	const(ushort[]) getIndices() const
	{
		return cast(const(ushort[]))Indices;
	}

	/// returns pointer to Indices
	ushort[] getIndices()
	{
		return Indices;
	}

	/// returns amount of indices
	size_t getIndexCount() const
	{
		return Indices.length;
	}

	/// Get type of index data which is stored in this meshbuffer.
	E_INDEX_TYPE getIndexType() const
	{
		return E_INDEX_TYPE.EIT_16BIT;
	}

	/// returns an axis aligned bounding box
	aabbox3d!float getBoundingBox() const
	{
		return BoundingBox;
	}

	/// set user axis aligned bounding box
	void setBoundingBox(aabbox3df box)
	{
		BoundingBox = box;
	}

	/// returns which type of vertex data is stored.
	E_VERTEX_TYPE getVertexType() const
	{
		return E_VERTEX_TYPE.EVT_STANDARD;
	}

	/// recalculates the bounding box. should be called if the mesh changed.
	void recalculateBoundingBox()
	{
		if (Vertices !is null || Vertices.length == 0 || Indices.length == 0)
			BoundingBox.reset(0,0,0);
		else
		{
			BoundingBox.reset(Vertices[Indices[0]].Pos);
			foreach(index; Indices[1..$])
				BoundingBox.addInternalPoint(Vertices[index].Pos);
		}
	}

	/// returns position of vertex i
	vector3df getPosition(size_t i) const
	{
		assert(Vertices !is null);
		return Vertices[Indices[i]].Pos;
	}

	/// returns normal of vertex i
	vector3df getNormal(size_t i) const
	{
		assert(Vertices !is null);
		return Vertices[Indices[i]].Normal;
	}

	/// returns texture coord of vertex i
	vector2df getTCoords(size_t i) const
	{
		assert(Vertices !is null);
		return Vertices[Indices[i]].TCoords;
	}

	/// append the vertices and indices to the current buffer
	void append(const(void[]) vertices, const(ushort[]) indices) {}

	/// append the meshbuffer to the current buffer
	void append(const IMeshBuffer other) {}

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Vertex() const
	{
		return MappingHintVertex;
	}

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Index() const
	{
		return MappingHintIndex;
	}

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING NewMappingHint, E_BUFFER_TYPE buffer=E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX )
	{
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_VERTEX)
			MappingHintVertex = NewMappingHint;
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_INDEX)
			MappingHintIndex = NewMappingHint;
	}

	/// flags the mesh as changed, reloads hardware buffers
	void setDirty(E_BUFFER_TYPE buffer=E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
	{
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_VERTEX)
			++ChangedID_Vertex;
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_INDEX)
			++ChangedID_Index;
	}

	/// Get the currently used ID for identification of changes.
	/**
	* This shouldn't be used for anything outside the VideoDriver. 
	*/
	size_t getChangedID_Vertex() const 
	{
		return ChangedID_Vertex;
	}

	/// Get the currently used ID for identification of changes.
	/**
	* This shouldn't be used for anything outside the VideoDriver. 
	*/
	size_t getChangedID_Index() const 
	{
		return ChangedID_Index;
	}

	/// Material of this meshBuffer
	SMaterial Material;

	/// Shared Array of vertices
	S3DVertex[] Vertices = [];

	/// Array of Indices
	ushort[] Indices = [];

	/// ID used for hardware buffer management
	size_t ChangedID_Vertex;

	/// ID used for hardware buffer management
	size_t ChangedID_Index;

	/// Bounding box
	aabbox3df BoundingBox;

	/// hardware mapping hint
	E_HARDWARE_MAPPING MappingHintVertex;
	E_HARDWARE_MAPPING MappingHintIndex;
}
