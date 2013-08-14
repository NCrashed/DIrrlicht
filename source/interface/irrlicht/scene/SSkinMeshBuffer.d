// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.SSkinMeshBuffer;

import irrlicht.scene.IMeshBuffer;
import irrlicht.video.SMaterial;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.core.matrix4;
import irrlicht.core.aabbox3d;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;

/// A mesh buffer able to choose between S3DVertex2TCoords, S3DVertex and S3DVertexTangents at runtime
class SSkinMeshBuffer : IMeshBuffer
{
	/// Default constructor
	this(E_VERTEX_TYPE vt = E_VERTEX_TYPE.EVT_STANDARD)
	{
		ChangedID_Vertex = 1;
		ChangedID_Index = 1;
		VertexType = vt;
		MappingHint_Vertex = E_HARDWARE_MAPPING.EHM_NEVER;
		MappingHint_Index = E_HARDWARE_MAPPING.EHM_NEVER;
		BoundingBoxNeedsRecalculated = true;
	}

	/// Get Material of this buffer.
	const(SMaterial) getMaterial() const
	{
		return Material;
	}

	/// Get Material of this buffer.
	SMaterial getMaterial()
	{
		return Material;
	}

	/// Get standard vertex at given index
	S3DVertex* getVertex(size_t index)
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return cast(S3DVertex*)&Vertices_2TCoords[index];
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return cast(S3DVertex*)&Vertices_Tangents[index];
			default:
				return &Vertices_Standard[index];
		}
	}

	/// Get pointer to vertex array
	const(void[]) getVertices() const
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return cast(const(void[]))Vertices_2TCoords;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return cast(const(void[]))Vertices_Tangents;
			default:
				return cast(const(void[]))Vertices_Standard;
		}
	}

	/// Get pointer to vertex array
	void[] getVertices()
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return cast(void[])Vertices_2TCoords;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return cast(void[])Vertices_Tangents;
			default:
				return cast(void[])Vertices_Standard;
		}
	}

	/// Get vertex count
	size_t getVertexCount() const
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return Vertices_2TCoords.length;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return Vertices_Tangents.length;
			default:
				return Vertices_Standard.length;
		}
	}

	/// Get type of index data which is stored in this meshbuffer.
	/**
	* Returns: Index type of this buffer. 
	*/
	E_INDEX_TYPE getIndexType() const
	{
		return E_INDEX_TYPE.EIT_16BIT;
	}

	/// Get pointer to index array
	const(ushort[]) getIndices() const
	{
		return Indices;
	}

	/// Get pointer to index array
	ushort[] getIndices()
	{
		return Indices;
	}

	/// Get index count
	size_t getIndexCount() const
	{
		return Indices.length;
	}

	/// Get bounding box
	aabbox3d!float getBoundingBox() const
	{
		return BoundingBox;
	}

	/// Set bounding box
	void setBoundingBox(aabbox3df box)
	{
		BoundingBox = box;
	}

	/// Recalculate bounding box
	void recalculateBoundingBox()
	{
		if(!BoundingBoxNeedsRecalculated)
			return;

		BoundingBoxNeedsRecalculated = false;

		final switch(VertexType)
		{
			case E_VERTEX_TYPE.EVT_STANDARD:
			{
				if (Vertices_Standard.length == 0)
					BoundingBox.reset(0,0,0);
				else
				{
					BoundingBox.reset(Vertices_Standard[0].Pos);
					for (size_t i=1; i<Vertices_Standard.length; ++i)
						BoundingBox.addInternalPoint(Vertices_Standard[i].Pos);
				}
				break;
			}
			case E_VERTEX_TYPE.EVT_2TCOORDS:
			{
				if (Vertices_2TCoords.length == 0)
					BoundingBox.reset(0,0,0);
				else
				{
					BoundingBox.reset(Vertices_2TCoords[0].Pos);
					for (size_t i=1; i<Vertices_2TCoords.length; ++i)
						BoundingBox.addInternalPoint(Vertices_2TCoords[i].Pos);
				}
				break;
			}
			case E_VERTEX_TYPE.EVT_TANGENTS:
			{
				if (Vertices_Tangents.length == 0)
					BoundingBox.reset(0,0,0);
				else
				{
					BoundingBox.reset(Vertices_Tangents[0].Pos);
					for (size_t i=1; i<Vertices_Tangents.length; ++i)
						BoundingBox.addInternalPoint(Vertices_Tangents[i].Pos);
				}
				break;
			}
		}
	}

	/// Get vertex type
	E_VERTEX_TYPE getVertexType() const
	{
		return VertexType;
	}

	/// Convert to 2tcoords vertex type
	void convertTo2TCoords()
	{
		if (VertexType==E_VERTEX_TYPE.EVT_STANDARD)
		{
			for(size_t n=0;n<Vertices_Standard.length;++n)
			{
				S3DVertex2TCoords Vertex;
				Vertex.Color=Vertices_Standard[n].Color;
				Vertex.Pos=Vertices_Standard[n].Pos;
				Vertex.Normal=Vertices_Standard[n].Normal;
				Vertex.TCoords=Vertices_Standard[n].TCoords;
				Vertices_2TCoords ~= Vertex;
			}
			Vertices_Standard[] = [];
			VertexType=E_VERTEX_TYPE.EVT_2TCOORDS;
		}
	}

	/// Convert to tangents vertex type
	void convertToTangents()
	{
		if (VertexType==E_VERTEX_TYPE.EVT_STANDARD)
		{
			for(size_t n=0;n<Vertices_Standard.length;++n)
			{
				S3DVertexTangents Vertex;
				Vertex.Color=Vertices_Standard[n].Color;
				Vertex.Pos=Vertices_Standard[n].Pos;
				Vertex.Normal=Vertices_Standard[n].Normal;
				Vertex.TCoords=Vertices_Standard[n].TCoords;
				Vertices_Tangents ~= Vertex;
			}
			Vertices_Standard[] = [];
			VertexType=E_VERTEX_TYPE.EVT_TANGENTS;
		}
		else if (VertexType==E_VERTEX_TYPE.EVT_2TCOORDS)
		{
			for(size_t n=0;n<Vertices_2TCoords.length;++n)
			{
				S3DVertexTangents Vertex;
				Vertex.Color=Vertices_2TCoords[n].Color;
				Vertex.Pos=Vertices_2TCoords[n].Pos;
				Vertex.Normal=Vertices_2TCoords[n].Normal;
				Vertex.TCoords=Vertices_2TCoords[n].TCoords;
				Vertices_Tangents ~= Vertex;
			}
			Vertices_2TCoords[] = [];
			VertexType=E_VERTEX_TYPE.EVT_TANGENTS;
		}
	}

	/// returns position of vertex i
	vector3df getPosition(size_t i) const
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return Vertices_2TCoords[i].Pos;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return Vertices_Tangents[i].Pos;
			default:
				return Vertices_Standard[i].Pos;
		}
	}

	/// returns normal of vertex i
	vector3df getNormal(size_t i) const
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return Vertices_2TCoords[i].Normal;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return Vertices_Tangents[i].Normal;
			default:
				return Vertices_Standard[i].Normal;
		}
	}

	/// returns texture coords of vertex i
	vector2df getTCoords(size_t i) const
	{
		switch (VertexType)
		{
			case E_VERTEX_TYPE.EVT_2TCOORDS:
				return Vertices_2TCoords[i].TCoords;
			case E_VERTEX_TYPE.EVT_TANGENTS:
				return Vertices_Tangents[i].TCoords;
			default:
				return Vertices_Standard[i].TCoords;
		}
	}


	/// append the vertices and indices to the current buffer
	void append(const(void[]) vertices, const(ushort[]) indices) {}

	/// append the meshbuffer to the current buffer
	void append(const IMeshBuffer other) {}

	/// get the current hardware mapping hint for vertex buffers
	E_HARDWARE_MAPPING getHardwareMappingHint_Vertex() const
	{
		return MappingHint_Vertex;
	}

	/// get the current hardware mapping hint for index buffers
	E_HARDWARE_MAPPING getHardwareMappingHint_Index() const
	{
		return MappingHint_Index;
	}

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING NewMappingHint, E_BUFFER_TYPE buffer=E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX )
	{
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX)
			MappingHint_Vertex=NewMappingHint;
		else if (buffer==E_BUFFER_TYPE.EBT_INDEX)
			MappingHint_Index=NewMappingHint;
		else if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
		{
			MappingHint_Vertex=NewMappingHint;
			MappingHint_Index=NewMappingHint;
		}
	}

	/// flags the mesh as changed, reloads hardware buffers
	void setDirty(E_BUFFER_TYPE buffer=E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
	{
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_VERTEX)
			++ChangedID_Vertex;
		if (buffer==E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX || buffer==E_BUFFER_TYPE.EBT_INDEX)
			++ChangedID_Index;
	}

	size_t getChangedID_Vertex() const 
	{
		return ChangedID_Vertex;
	}

	size_t getChangedID_Index() const 
	{
		return ChangedID_Index;
	}

	/// Call this after changing the positions of any vertex.
	void boundingBoxNeedsRecalculated() 
	{ 
		BoundingBoxNeedsRecalculated = true; 
	}

	S3DVertexTangents[] Vertices_Tangents;
	S3DVertex2TCoords[] Vertices_2TCoords;
	S3DVertex[]			Vertices_Standard;
	ushort[] 			Indices;

	size_t ChangedID_Vertex;
	size_t ChangedID_Index;

	//ISkinnedMesh::SJoint *AttachedJoint;
	matrix4 Transformation;

	SMaterial Material;
	E_VERTEX_TYPE VertexType;

	aabbox3d!float BoundingBox;

	// hardware mapping hint
	E_HARDWARE_MAPPING MappingHint_Vertex;
	E_HARDWARE_MAPPING MappingHint_Index;

	bool BoundingBoxNeedsRecalculated;
}

