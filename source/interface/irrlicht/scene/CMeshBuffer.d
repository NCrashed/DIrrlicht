// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.CMeshBuffer;

import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.scene.IMeshBuffer;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.video.SMaterial;
import irrlicht.core.aabbox3d;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import std.algorithm;
import std.range;

/// Template implementation of the IMeshBuffer interface
class CMeshBuffer(T) : IMeshBuffer
{
	/// Default constructor for empty meshbuffer
	this()
	{
		ChangedID_Vertex = 1;
		ChangedID_Index = 1;
		MappingHint_Vertex =E_HARDWARE_MAPPING.EHM_NEVER;
		MappingHint_Index = E_HARDWARE_MAPPING.EHM_NEVER;
	}


	/// Get material of this meshbuffer
	/**
	* Returns: Material of this buffer 
	*/
	const(SMaterial) getMaterial() const
	{
		return Material;
	}


	/// Get material of this meshbuffer
	/**
	* Returns: Material of this buffer 
	*/
	SMaterial getMaterial()
	{
		return Material;
	}


	/// Get pointer to vertices
	/**
	* Returns: Pointer to vertices. 
	*/
	const(void[]) getVertices() const
	{
		return cast(const(void[]))Vertices;
	}


	/// Get pointer to vertices
	/**
	* Returns: Pointer to vertices. 
	*/
	void[] getVertices()
	{
		return cast(void[])Vertices;
	}


	/// Get number of vertices
	/**
	* Returns: Number of vertices. 
	*/
	size_t getVertexCount() const
	{
		return Vertices.length;
	}

	/// Get type of index data which is stored in this meshbuffer.
	/**
	* Returns: Index type of this buffer. 
	*/
	E_INDEX_TYPE getIndexType() const
	{
		return E_INDEX_TYPE.EIT_16BIT;
	}

	/// Get pointer to indices
	/**
	* Returns: Pointer to indices. 
	*/
	const(ushort[]) getIndices() const
	{
		return cast(const(ushort[]))Indices;
	}


	/// Get pointer to indices
	/**
	* Returns: Pointer to indices. 
	*/
	ushort[] getIndices()
	{
		return Indices;
	}


	/// Get number of indices
	/**
	* Returns: Number of indices. 
	*/
	size_t getIndexCount() const
	{
		return Indices.length;
	}


	/// Get the axis aligned bounding box
	/**
	* Returns: Axis aligned bounding box of this buffer. 
	*/
	aabbox3d!float getBoundingBox() const
	{
		return BoundingBox;
	}

	/// Set the axis aligned bounding box
	/**
	* Params:
	* 	box=  New axis aligned bounding box for this buffer. 
	*/
	/// set user axis aligned bounding box
	void setBoundingBox(aabbox3df box)
	{
		BoundingBox = box;
	}


	/// Recalculate the bounding box.
	/**
	* should be called if the mesh changed. 
	*/
	void recalculateBoundingBox()
	{
		if (Vertices.length == 0)
			BoundingBox.reset(0,0,0);
		else
		{
			BoundingBox.reset(Vertices[0].Pos);
			foreach(ref point; Vertices[1..$])
				BoundingBox.addInternalPoint(point.Pos);
		}
	}

	/// Get type of vertex data stored in this buffer.
	/**
	* Returns: Type of vertex data. 
	*/
	E_VERTEX_TYPE getVertexType() const
	{
		return T().getType();
	}

	/// returns position of vertex i
	vector3df getPosition(size_t i) const
	{
		return Vertices[i].Pos;
	}

	/// returns normal of vertex i
	vector3df getNormal(size_t i) const
	{
		return Vertices[i].Normal;
	}

	/// returns texture coord of vertex i
	vector2df getTCoords(size_t i) const
	{
		return Vertices[i].TCoords;
	}


	/// Append the vertices and indices to the current buffer
	/**
	* Only works for compatible types, i.e. either the same type
	* or the main buffer is of standard type. Otherwise, behavior is
	* undefined.
	*/
	void append(const void[] vertices, const ushort[] indices)
	{
		if (vertices == getVertices())
			return;

		immutable vertexCount = getVertexCount();

		Vertices ~= cast(T[])(vertices);
		foreach(ref vert; Vertices[vertexCount..$])
		{
			BoundingBox.addInternalPoint(vert.Pos);
		}
		Indices ~= map!(a => cast(ushort)(a + vertexCount))(indices).array();
	}


	/// Append the meshbuffer to the current buffer
	/**
	* Only works for compatible types, i.e. either the same type
	* or the main buffer is of standard type. Otherwise, behavior is
	* undefined.
	* Params:
	* 	other=  Meshbuffer to be appended to this one.
	*/
	void append(const IMeshBuffer other)
	{
		if (this==other)
			return;

		immutable vertexCount = getVertexCount();
		Vertices ~= cast(T[])other.getVertices();
		Indices ~= map!(a => cast(ushort)(a + vertexCount))(other.getIndices()).array();

		BoundingBox.addInternalBox(other.getBoundingBox());
	}

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Vertex() const
	{
		return MappingHint_Vertex;
	}

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint_Index() const
	{
		return MappingHint_Index;
	}

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint(E_HARDWARE_MAPPING NewMappingHint, E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX )
	{
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_VERTEX)
			MappingHint_Vertex=NewMappingHint;
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_INDEX)
			MappingHint_Index=NewMappingHint;
	}


	/// flags the mesh as changed, reloads hardware buffers
	void setDirty(E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
	{
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_VERTEX)
			++ChangedID_Vertex;
		if (buffer == E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer == E_BUFFER_TYPE.EBT_INDEX)
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

	size_t ChangedID_Vertex;
	size_t ChangedID_Index;

	/// hardware mapping hint
	E_HARDWARE_MAPPING MappingHint_Vertex;
	E_HARDWARE_MAPPING MappingHint_Index;

	/// Material for this meshbuffer.
	SMaterial Material;
	/// Vertices of this buffer
	T[] Vertices = [];
	/// Indices into the vertices of this buffer.
	ushort[] Indices = [];
	/// Bounding box of this meshbuffer.
	aabbox3d!float BoundingBox;
}

/// Standard meshbuffer
alias CMeshBuffer!S3DVertex SMeshBuffer;
/// Meshbuffer with two texture coords per vertex, e.g. for lightmaps
alias CMeshBuffer!S3DVertex2TCoords SMeshBufferLightMap;
/// Meshbuffer with vertices having tangents stored, e.g. for normal mapping
alias CMeshBuffer!S3DVertexTangents SMeshBufferTangents;
