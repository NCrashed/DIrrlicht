// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.S3DVertex;

import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.video.SColor;
import irrlicht.irrMath;

/// Enumeration for all vertex types there are.
enum E_VERTEX_TYPE
{
	/// Standard vertex type used by the Irrlicht engine, S3DVertex.
	EVT_STANDARD = 0,

	/// Vertex with two texture coordinates, S3DVertex2TCoords.
	/**
	* Usually used for geometry with lightmaps or other special materials. 
	*/
	EVT_2TCOORDS,

	/// Vertex with a tangent and binormal vector, video::S3DVertexTangents.
	/**
	* Usually used for tangent space normal mapping. 
	*/
	EVT_TANGENTS
};

/// Array holding the built in vertex type names
immutable(string[]) sBuiltInVertexTypeNames =
[
	"standard",
	"2tcoords",
	"tangents",
];

/// standard vertex used by the Irrlicht engine.
struct S3DVertex
{
	/// constructor
	this()(float x, float y, float z, float nx, float ny, float nz, SColor c, float tu, float tv) pure
	{
		Pos = vector3df(x,y,z);
		Normal = vector3df(nx,ny,nz);
		Color = c;
		TCoords = vector2df(tu, tv);
	}

	/// constructor
	this()(auto ref const vector3df pos, auto ref const vector3df normal,
		auto ref const SColor color, auto ref const vector2df tcoords) pure
	{
		Pos = pos;
		Normal = normal;
		Color = color;
		TCoords = tcoords;
	}

	/// Position
	vector3df Pos;

	/// Normal vector
	vector3df Normal;

	/// Color
	SColor Color;

	/// Texture coordinates
	vector2df TCoords;

	bool opEqual()(auto ref const S3DVertex other) const
	{
		return ((Pos == other.Pos) && (Normal == other.Normal) &&
			(Color == other.Color) && (TCoords == other.TCoords));
	}

	int opCmp()(auto ref const S3DVertex other) const
	{
		if ((Pos < other.Pos) ||
				((Pos == other.Pos) && (Normal < other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color < other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords < other.TCoords)))
		{
			return -1;
		} 
		else if ((Pos > other.Pos) ||
				((Pos == other.Pos) && (Normal > other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color > other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords > other.TCoords)))
		{
			return 1;
		}
		return 0;
	}

	E_VERTEX_TYPE getType() const
	{
		return E_VERTEX_TYPE.EVT_STANDARD;
	}

	S3DVertex getInterpolated()(auto ref const S3DVertex other, float d) const
	{
		d = clamp(d, 0.0f, 1.0f);
		return S3DVertex(Pos.getInterpolated(other.Pos, d),
				Normal.getInterpolated(other.Normal, d),
				Color.getInterpolated(other.Color, d),
				TCoords.getInterpolated(other.TCoords, d));
	}
}


/// Vertex with two texture coordinates.
/**
* Usually used for geometry with lightmaps
* or other special materials.
*/
struct S3DVertex2TCoords
{
	/// constructor with two different texture coords, but no normal
	this()(float x, float y, float z, SColor c, float tu, float tv, float tu2, float tv2) pure
	{
		Pos = vector3df(x, y, z);
		Normal = vector3df(0.0f);
		Color = c;
		TCoords = vector2df(tu, tv);
		TCoords2 = vector2df(tu2, tv2);
	}
	/// constructor with two different texture coords, but no normal
	this()(auto ref const vector3df pos, auto ref const SColor color,
		auto ref const vector2df tcoords, auto ref const vector2df tcoords2) pure
	{
		Pos = pos;
		Normal = vector3df(0.0f);
		Color = c;
		TCoords = tcoords;
		TCoords2 = tcoords2;
	}

	/// constructor with all values
	this()(auto ref const vector3df pos, auto ref const vector3df normal, auto ref const SColor color,
		auto ref const vector2df tcoords, auto ref const vector2df tcoords2) pure
	{
		Pos = pos;
		Normal = normal;
		Color = c;
		TCoords = tcoords;
		TCoords2 = tcoords2;		
	}

	/// constructor with all values
	this()(float x, float y, float z, float nx, float ny, float nz, auto ref const SColor c, float tu, float tv, float tu2, float tv2) pure
	{
		Pos = vector3df(x, y, z);
		Normal = vector3df(nx, ny, nz);
		Color = c;
		TCoords = vector2df(tu, tv);
		TCoords2 = vector2df(tu2, tv2);
	}

	/// constructor with the same texture coords and normal
	this()(float x, float y, float z, float nx, float ny, float nz, auto ref const SColor c, float tu, float tv) pure
	{
		Pos = vector3df(x, y, z);
		Normal = vector3df(nx, ny, nz);
		Color = c;
		TCoords = vector2df(tu, tv);
		TCoords2 = vector2df(tu, tv);
	}

	/// constructor with the same texture coords and normal
	this()(auto ref const vector3df pos, auto ref const vector3df normal,
		auto ref const SColor color, const vector2df tcoords) pure
	{
		Pos = pos;
		Normal = normal;
		Color = c;
		TCoords = tcoords;
		TCoords2 = tcoords;
	}

	/// constructor from S3DVertex
	this()(auto ref const S3DVertex o) pure
	{
		Pos = o.Pos;
		Normal = o.Normal;
		Color = o.Color;
		TCoords = o.TCoords;
		TCoords2 = o.TCoords;
	}

	/// Position
	vector3df Pos;

	/// Normal vector
	vector3df Normal;

	/// Color
	SColor Color;

	/// Texture coordinates
	vector2df TCoords;

	/// Second set of texture coordinates
	vector2df TCoords2;

	/// Equality operator
	bool opEqual()(auto ref const S3DVertex2TCoords other) const
	{ 
		return ((Pos == other.Pos) && (Normal == other.Normal) &&
			(Color == other.Color) && (TCoords == other.TCoords) &&
			(TCoords2 == other.TCoords2));
	}

	int opCmp()(auto ref const S3DVertex other) const
	{
		if ((Pos < other.Pos) ||
				((Pos == other.Pos) && (Normal < other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color < other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords < other.TCoords)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (TCoords2 < other.TCoords2)))
		{
			return -1;
		} 
		else if ((Pos > other.Pos) ||
				((Pos == other.Pos) && (Normal > other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color > other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords > other.TCoords)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (TCoords2 > other.TCoords2)))
		{
			return 1;
		}
		return 0;
	}

	E_VERTEX_TYPE getType() const
	{
		return E_VERTEX_TYPE.EVT_2TCOORDS;
	}

	S3DVertex2TCoords getInterpolated()(auto ref const S3DVertex2TCoords other, float d) const
	{
		d = clamp(d, 0.0f, 1.0f);
		return S3DVertex2TCoords(Pos.getInterpolated(other.Pos, d),
				Normal.getInterpolated(other.Normal, d),
				Color.getInterpolated(other.Color, d),
				TCoords.getInterpolated(other.TCoords, d),
				TCoords2.getInterpolated(other.TCoords2, d));
	}
}


/// Vertex with a tangent and binormal vector.
/**
* Usually used for tangent space normal mapping. 
*/
struct S3DVertexTangents
{
	/// constructor
	this()(float x, float y, float z, float nx=0.0f, float ny=0.0f, float nz=0.0f,
			SColor c = SColor(0xFFFFFFFF), float tu=0.0f, float tv=0.0f,
			float tanx=0.0f, float tany=0.0f, float tanz=0.0f,
			float bx=0.0f, float by=0.0f, float bz=0.0f) pure
	{
		Pos = vector3df(x,y,z);
		Normal = vector3df(nx,ny,nz);
		Color = c;
		TCoords = vector2df(tu, tv);
		Tangent(tanx, tany, tanz);
		Binormal(bx, by, bz);
	}

	/// constructor
	this()(auto ref const vector3df pos, auto ref const SColor c,
		auto ref const vector2df tcoords) pure
	{
		Pos = pos;
		Normal = vector3df(0.0f);
		Color = c;
		TCoords2 = tcoords;
		Tangent = vector3df(0.0f);
		Binormal = vector3df(0.0f);
	}

	/// constructor
	this()(auto ref const vector3df pos,
		auto ref const vector3df normal, auto ref const SColor c,
		auto ref const vector2df tcoords,
		auto ref const vector3df tangent = vector3df(0.0f),
		auto ref const vector3df binormal = vector3df(0.0f)) pure
	{
		Pos = pos;
		Normal = normal;
		Color = c;
		TCoords2 = tcoords;
		Tangent = tangent;
		Binormal = binormal;
	}

	/// Position
	vector3df Pos;

	/// Normal vector
	vector3df Normal;

	/// Color
	SColor Color;

	/// Texture coordinates
	vector2df TCoords;

	/// Tangent vector along the x-axis of the texture
	vector3df Tangent;

	/// Binormal vector (tangent x normal)
	vector3df Binormal;

	bool opEqual()(auto ref const S3DVertex other) const
	{
		return ((Pos == other.Pos) && (Normal == other.Normal) &&
			(Color == other.Color) && (TCoords == other.TCoords) &&
			(Tangent == other.Tangent) &&
			(Binormal == other.Binormal));
	}

	int opCmp()(auto ref const S3DVertex other) const
	{
		if ((Pos < other.Pos) ||
				((Pos == other.Pos) && (Normal < other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color < other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords < other.TCoords)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (Tangent < other.Tangent)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (Tangent == other.Tangent) && (Binormal < other.Binormal)))
		{
			return -1;
		} 
		else if ((Pos > other.Pos) ||
				((Pos == other.Pos) && (Normal > other.Normal)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color > other.Color)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords > other.TCoords)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (Tangent > other.Tangent)) ||
				((Pos == other.Pos) && (Normal == other.Normal) && (Color == other.Color) && (TCoords == other.TCoords) && (Tangent == other.Tangent) && (Binormal > other.Binormal)))
		{
			return 1;
		}
		return 0;
	}

	E_VERTEX_TYPE getType() const
	{
		return E_VERTEX_TYPE.EVT_TANGENTS;
	}

	S3DVertexTangents getInterpolated()(auto ref const S3DVertexTangents other, float d) const
	{
		d = clamp(d, 0.0f, 1.0f);
		return S3DVertexTangents(Pos.getInterpolated(other.Pos, d),
				Normal.getInterpolated(other.Normal, d),
				Color.getInterpolated(other.Color, d),
				TCoords.getInterpolated(other.TCoords, d),
				Tangent.getInterpolated(other.Tangent, d),
				Binormal.getInterpolated(other.Binormal, d));
	}
};

uint getVertexPitchFromType(E_VERTEX_TYPE vertexType) 
{
	final switch (vertexType)
	{
		case E_VERTEX_TYPE.EVT_2TCOORDS:
			return S3DVertex2TCoords.sizeof;
		case E_VERTEX_TYPE.EVT_TANGENTS:
			return S3DVertexTangents.sizeof;
		case E_VERTEX_TYPE.EVT_STANDARD:
			return S3DVertex.sizeof;
	}
}
