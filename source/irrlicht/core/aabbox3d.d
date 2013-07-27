// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.aabbox3d;

import irrlicht.core.vector3d;
import irrlicht.core.plane3d;
import irrlicht.core.line3d;

/// Axis aligned bounding box in 3d dimensional space.
/**
*  Has some useful methods used with occlusion culling or clipping.
*/
struct aabbox3d(T)
{
	/// Constructor with min edge and max edge.
	this()(auto ref const vector3d!T min, auto ref const vector3d!T max) pure
	{
		MinEdge = min;
		MaxEdge = max;
	}

	/// Constructor with only one point
	this()(auto ref const vector3d!T init) pure
	{
		MinEdge = init;
		MaxEdge = init;
	}

	/// Constructor with min edge and max edge as single values, not vectors
	this()(T minx, T miny, T minz, T maxx, T maxy, T maxz) pure
	{
		MinEdge = vector3d!T(minx, miny, minz);
		MaxEdge = vector3d!T(maxx, maxy, maxz);
	}

	bool opEqual()(auto ref const aabbox3d!T other) const
	{
		return (MinEdge == other.MinEdge && other.MaxEdge == MaxEdge);
	}

	/// Resets the bounding box to a one-point box
	/**
	* Params: 
	* x = X coord of the point.
	* y = Y coord of the point.
	* z = Z coord of the point.
	*/
	void reset()(T x, T y, T z)
	{
		MaxEdge.set(x, y, z);
		MinEdge = MaxEdge;
	}

	/// Resets the boinding box.
	/**
	* Params:
	* initValue = New box to set this one to.
	*/
	void reset()(auto ref const aabbox3d!T initValue)
	{
		this = initValue;
	}

	/// Resets the bounding box to a one-point box.
	/**
	* Params:
	* initValue = New point.
	*/
	void reset()(auto ref const vector3d!T initValue)
	{
		MaxEdge = initValue;
		MinEdge = initValue;
	}

	/// Adds a point to the boinding box
	/**
	* The box grows bigger, if point was outside of the box.
	* Params:
	* p = Point to add into the box.
	*/
	void addInternalPoint()(auto ref const vector3d!T p)
	{
		addInternalPoint(p.X, p.Y, p.Z);
	}

	/// Adds another boundng box
	/**
	* The box grows bigger, if the new box was outsid of the box.
	* Params:
	* b = Other bounding box to add into this box.
	*/
	void addInternalBox()(auto ref const aabbox3d!T b)
	{
		addInternalPoint(b.MaxEdge);
		addInternalPoint(b.MinEdge);
	}

	/// Adds a point to the bounding box
	/**
	* The box grows bigger, if point is outsid of the box.
	* Params:
	* x = X coordinate of the point to add to this box.
	* y = Y coordinate of the point to add to this box.
	* z = Z coordinate of the point to add to this box.
	*/
	void addInternalPoint()(T x, T y, T z)
	{
		if (x>MaxEdge.X) MaxEdge.X = x;
		if (y>MaxEdge.Y) MaxEdge.Y = y;
		if (z>MaxEdge.Z) MaxEdge.Z = z;

		if (x<MinEdge.X) MinEdge.X = x;
		if (y<MinEdge.Y) MinEdge.Y = y;
		if (z<MinEdge.Z) MinEdge.Z = z;
	}

	/// Get center of the bounding box
	/**
	* Returns: Center of the bounding box.
	*/
	vector3d!T getCenter() const
	{
		return (MinEdge + MaxEdge) / 2;
	}

	/// Get extent of the box (maximal distance of two points in the box)
	/**
	* Returns: Extent of the boundign box.
	*/
	vector3d!T getExtent() const
	{
		return MaxEdge - MinEdge;
	}

	/// Check if the box is empty
	/**
	* This means that there is no space between the min and max edge.
	* Returns: True if box is empty, else false.
	*/
	bool isEmpty() const
	{
		return MinEdge == MaxEdge;
	}

	/// Get the volume enclosed by the box in cubed units.
	T getVolume() const
	{
		immutable vector3d!T e = getExtent();
		return e.X * e.Y * e.Z;
	}

	/// Get the surface area of the box in squared units.
	T getArea() const
	{
		immutable vector3d!T e = getExtent();
		return 2*(e.X*e.Y + e.X*e.Z + e.Y*e.Z);
	}

	/// Stores all 8 edges of the box into an array.
	/**
	* Params:
	* edges = Pointer to array of 8 edges.
	*/
	void getEdges(out vector3d!(T)[8] edges) const
	{
		immutable vector3d!T middle = getCenter();
		immutable vector3d!T diag = getCenter() - MaxEdge;

		/*
		Edges are stored in this way:
		Hey, am I an ascii artist, or what? :) niko.
               /3--------/7
              / |       / |
             /  |      /  |
            1---------5   |
            |  /2- - -|- -6
            | /       |  /
            |/        | /
            0---------4/
		*/

		edges[0].set(middle.X + diag.X, middle.Y + diag.Y, middle.Z + diag.Z);
		edges[1].set(middle.X + diag.X, middle.Y - diag.Y, middle.Z + diag.Z);
		edges[2].set(middle.X + diag.X, middle.Y + diag.Y, middle.Z - diag.Z);
		edges[3].set(middle.X + diag.X, middle.Y - diag.Y, middle.Z - diag.Z);
		edges[4].set(middle.X - diag.X, middle.Y + diag.Y, middle.Z + diag.Z);
		edges[5].set(middle.X - diag.X, middle.Y - diag.Y, middle.Z + diag.Z);
		edges[6].set(middle.X - diag.X, middle.Y + diag.Y, middle.Z - diag.Z);
		edges[7].set(middle.X - diag.X, middle.Y - diag.Y, middle.Z - diag.Z);
	}

	/// Repairs the box
	/**
	* Necessary if for example MinEdge and MaxEdge are swapped.
	*/
	void repair()
	{
		T t;

		if (MinEdge.X > MaxEdge.X)
			{ t=MinEdge.X; MinEdge.X = MaxEdge.X; MaxEdge.X=t; }
		if (MinEdge.Y > MaxEdge.Y)
			{ t=MinEdge.Y; MinEdge.Y = MaxEdge.Y; MaxEdge.Y=t; }
		if (MinEdge.Z > MaxEdge.Z)
			{ t=MinEdge.Z; MinEdge.Z = MaxEdge.Z; MaxEdge.Z=t; }
	}

	/// Calculates a new interpolated bounding box.
	/** 
	* d=0 returns other, d=1 returns this, all other values blend between
	* the two boxes.
	* Params:
	* other = Other box to interpolate between
	* d = Value between 0.0f and 1.0f.
	* Returns: Interpolated box. 
	*/
	aabbox3d!T getInterpolated()(auto ref const aabbox3d!T other, float d) const
	{
		immutable float inv = 1.0f - d;
		return aabbox3d!t((other.MinEdge*inv) + (MinEdge*d),
			(other.MaxEdge*inv) + (MaxEdge*d));
	}

	/// Determines if a point is within this box.
	/** 
	* Border is included (IS part of the box)!
	* Params:
	* p = Point to check.
	* Returns: True if the point is within the box and false if not 
	*/
	bool isPointInside()(auto ref const vector3d!T p) const
	{
		return (p.X >= MinEdge.X && p.X <= MaxEdge.X &&
			p.Y >= MinEdge.Y && p.Y <= MaxEdge.Y &&
			p.Z >= MinEdge.Z && p.Z <= MaxEdge.Z);
	}

	/// Determines if a point is within this box and not its borders.
	/** 
	* Border is excluded (NOT part of the box)!
	* Params:
	* p = Point to check.
	* Returns: True if the point is within the box and false if not. 
	*/
	bool isFullInside()(auto ref const aabbox3d!T other) const
	{
		return (MinEdge.X >= other.MinEdge.X && MinEdge.Y >= other.MinEdge.Y && MinEdge.Z >= other.MinEdge.Z &&
			MaxEdge.X <= other.MaxEdge.X && MaxEdge.Y <= other.MaxEdge.Y && MaxEdge.Z <= other.MaxEdge.Z);
	}

	/// Determines if the axis-aligned box intersects with another axis-aligned box.
	/** 
	* Params:
	* other = Other box to check a intersection with.
	*
	* Returns: True if there is an intersection with the other box,
	* otherwise false. 
	*/
	bool intersectsWithBox()(auto ref const aabbox3d!T other) const
	{
		return (MinEdge.X <= other.MaxEdge.X && MinEdge.Y <= other.MaxEdge.Y && MinEdge.Z <= other.MaxEdge.Z &&
			MaxEdge.X >= other.MinEdge.X && MaxEdge.Y >= other.MinEdge.Y && MaxEdge.Z >= other.MinEdge.Z);
	}

	/// Tests if the box intersects with a line
	/**
	* Params: 
	* line = Line to test intersection with.
	*
	* Returns: True if there is an intersection , else false. 
	*/
	bool intersectsWithLine()(auto ref const line3d!T line) const
	{
		return intersectsWithLine(line.getMiddle(), line.getVector().normalize(),
				cast(T)(line.getLength() * 0.5));
	}

	/// Tests if the box intersects with a line
	/**
	* Params: 
	* linemiddle = Center of the line.
	* linevect = Vector of the line.
	* halflength = Half length of the line.
	*
	* Returns: True if there is an intersection, else false. 
	*/
	bool intersectsWithLine()(auto ref const vector3d!T linemiddle,
				auto ref const vector3d!T linevect, T halflength) const
	{
		immutable vector3d!T e = getExtent() * cast(T)0.5;
		immutable vector3d!T t = getCenter() - linemiddle;

		if ((fabs(t.X) > e.X + halflength * fabs(linevect.X)) ||
			(fabs(t.Y) > e.Y + halflength * fabs(linevect.Y)) ||
			(fabs(t.Z) > e.Z + halflength * fabs(linevect.Z)) )
			return false;

		T r = e.Y * cast(T)fabs(linevect.Z) + e.Z * cast(T)fabs(linevect.Y);
		if (fabs(t.Y*linevect.Z - t.Z*linevect.Y) > r )
			return false;

		r = e.X * cast(T)fabs(linevect.Z) + e.Z * cast(T)fabs(linevect.X);
		if (fabs(t.Z*linevect.X - t.X*linevect.Z) > r )
			return false;

		r = e.X * cast(T)fabs(linevect.Y) + e.Y * cast(T)fabs(linevect.X);
		if (fabs(t.X*linevect.Y - t.Y*linevect.X) > r)
			return false;

		return true;
	}

	/// Classifies a relation with a plane.
	/**
	* Params: 
	* plane = Plane to classify relation to.
	*
	* Returns: ISREL3D_FRONT if the box is in front of the plane,
	* ISREL3D_BACK if the box is behind the plane, and
	* ISREL3D_CLIPPED if it is on both sides of the plane. 
	*/
	EIntersectionRelation3D classifyPlaneRelation()(auto ref const plane3d!T plane) const
	{
		vector3d!T nearPoint(MaxEdge);
		vector3d!T farPoint(MinEdge);

		if (plane.Normal.X > cast(T)0)
		{
			nearPoint.X = MinEdge.X;
			farPoint.X = MaxEdge.X;
		}

		if (plane.Normal.Y > cast(T)0)
		{
			nearPoint.Y = MinEdge.Y;
			farPoint.Y = MaxEdge.Y;
		}

		if (plane.Normal.Z > cast(T)0)
		{
			nearPoint.Z = MinEdge.Z;
			farPoint.Z = MaxEdge.Z;
		}

		if (plane.Normal.dotProduct(nearPoint) + plane.D > cast(T)0)
			return ISREL3D_FRONT;

		if (plane.Normal.dotProduct(farPoint) + plane.D > cast(T)0)
			return ISREL3D_CLIPPED;

		return ISREL3D_BACK;
	}

	/// The near edge
	vector3d!T MinEdge = vector3d!T(-1, -1, -1);

	/// The far edge
	vector3d!T MaxEdge = vector3d!T(1, 1, 1);;
}

/// Alias for a float 3d bounding box.
alias aabbox3d!float aabbox3df;

/// Alias for an integer 3d bounding box.
alias aabbox3d!int aabbox3di;