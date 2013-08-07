// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.plane3d;

import irrlicht.core.vector3d;
import std.math;

/// Enumeration for intersection relations of 3d objects
enum EIntersectionRelation3D
{
	ISREL3D_FRONT = 0,
	ISREL3D_BACK,
	ISREL3D_PLANAR,
	ISREL3D_SPANNING,
	ISREL3D_CLIPPED
};

/// Template plane class with some intersection testing methods.
/** 
* It has to be ensured, that the normal is always normalized. The constructors
* and setters of this class will not ensure this automatically. So any normal
* passed in has to be normalized in advance. No change to the normal will be
* made by any of the class methods.
*/
struct plane3d(T)
{
	this()(auto ref const vector3d!T MPoint, auto ref const vector3d!T Normal)
	{
		this.Normal = Normal;
		recalculateD(MPoint);
	}

	this()(T px, T py, T pz, T nx, T ny, T nz)
	{
		Normal = vector3d!T(nx, ny, nz);
		recalculateD(vector3d!T(px, py, pz));
	}

	this()(auto ref const vector3d!T normal, const T d)
	{
		Normal = normal;
		D = d;
	}

	this()(auto ref const vector3d!T point1, auto ref const vector3d!T point2, auto ref const vector3d!T point3)
	{
		setPlane(point1, point2, point3);
	}

	bool opEqual()(auto ref const plane3d!T other)
	{
		return approxEqual(D, other.D) && Normal == other.Normal;
	}

	void setPlane()(auto ref const vector3d!T point, auto ref const vector3d!T nvector)
	{
		Normal = nvector;
		recalculateD(point);
	}

	void setPlane()(auto ref const vector3d!T nvect, T d)
	{
		Normal = nvect;
		D = d;
	}

	void setPlane()(auto ref const vector3d!T point1, auto ref const vector3d!T point2, auto ref const vector3d!T point3)
	{
		// creates the plane from 3 memberpoints
		Normal = (point2 - point1).crossProduct(point3 - point1);
		Normal.normalize();

		recalculateD(point1);
	}

	/// Get an intersection with a 3d line.
	/** 
	* Params:
	* lineVect = Vector of the line to intersect with.
	* linePoint = Point of the line to intersect with.
	* outIntersection = Place to store the intersection point, if there is one.
	* 
	* Returns: true if there was an intersection, false if there was not.
	*/
	bool getIntersectionWithLine()(auto ref const vector3d!T linePoint,
		auto ref const vector3d!T lineVect,
		out vector3d!T outIntersection) const
	{
		T t2 = Normal.dotProduct(lineVect);

		if (t2 == 0)
			return false;

		T t = -(Normal.dotProduct(linePoint) + D) / t2;
		outIntersection = linePoint + (lineVect * t);
		return true;
	}

	/// Get percentage of line between two points where an intersection with this plane happens.
	/** 
	* Only useful if known that there is an intersection.
	* Params:
	* linePoint1 = Point1 of the line to intersect with.
	* linePoint2 = Point2 of the line to intersect with.
	*
	* Returns: Where on a line between two points an intersection with this plane happened.
	* For example, 0.5 is returned if the intersection happened exactly in the middle of the two points.
	*/
	float getKnownIntersectionWithLine()(auto ref const vector3d!T linePoint1,
		auto ref const vector3d!T linePoint2) const
	{
		vector3d!T vect = linePoint2 - linePoint1;
		float t2 = cast(float)Normal.dotProduct(vect);
		return cast(float)-((Normal.dotProduct(linePoint1) +D) / t2);
	}

	/// Get an intersection with a 3d line, limited between two 3d points.
	/** 
	* Params:
	* linePoint1 = Point 1 of the line.
	* linePoint2 = Point 2 of the line.
	* outIntersection = Place to store the intersection point, if there is one.
	*
	* Returns: True if there was an intersection, false if there was not.
	*/
	bool getIntersectionWithLimitedLine(U : T)(
		auto ref const vector3d!U linePoint1,
		auto ref const vector3d!U linePoint2,
		out vector3d!U outIntersection)
	{
		return (getIntersectionWithLine(linePoint1, linePoint2 - linePoint1, outIntersection) && 
			outIntersection.isBetweenPoints(linePoint1, linePoint2));
	}

	/// Classifies the relation of a point to this plane.
	/** 
	* Params:
	* point = Point to classify its relation.
	*
	* Returns: ISREL3D_FRONT if the point is in front of the plane,
	* ISREL3D_BACK if the point is behind of the plane, and
	* ISREL3D_PLANAR if the point is within the plane. 
	*/
	EIntersectionRelation3D classifyPointRelation()(auto ref const vector3d!T point) const
	{
		immutable T d = Normal.dotProduct(point) + D;

		if (d < -float.epsilon)
			return EIntersectionRelation3D.ISREL3D_BACK;

		if (d > float.epsilon)
			return EIntersectionRelation3D.ISREL3D_FRONT;

		return EIntersectionRelation3D.ISREL3D_PLANAR;
	}

	/// Recalculates the distance from origin by applying a new member point to the plane.
	void recalculateD()(auto ref const vector3d!T MPoint)
	{
		D = - MPoint.dotProduct(Normal);
	}

	/// Gets a member point of the plane.
	vector3d!T getMemberPoint()
	{
		return Normal * -D;
	}

	/// Tests if there is an intersection with the other plane
	/** 
	* Returns: True if there is a intersection. 
	*/
	bool existsIntersection()(auto ref const plane3d!T other)
	{
		vector3d!T cross = other.Normal.crossProduct(Normal);
		return cross.getLength() > float.epsilon;
	}

	/// Intersects this plane with another.
	/** 
	* Params:
	* other = Other plane to intersect with.
	* outLinePoint = Base point of intersection line.
	* outLineVect = Vector of intersection.
	* Returns: True if there is a intersection, false if not. 
	*/
	bool getIntersectionWithPlane()(auto ref const plane3d!T other,
		out vector3d!T outLinePoint,
		out vector3d!T outLineVect) const
	{
		immutable T fn00 = Normal.getLength();
		immutable T fn01 = Normal.dotProduct(other.Normal);
		immutable T fn11 = other.Normal.getLength();
		immutable double det = fn00*fn11 - fn01*fn01;

		if (fabs(det) < double.epsilon )
			return false;

		immutable double invdet = 1.0 / det;
		immutable double fc0 = (fn11*-D + fn01*other.D) * invdet;
		immutable double fc1 = (fn00*-other.D + fn01*D) * invdet;

		outLineVect = Normal.crossProduct(other.Normal);
		outLinePoint = Normal*cast(T)fc0 + other.Normal*cast(T)fc1;
		return true;
	}

	/// Get the intersection point with two other planes if there is one.
	bool getIntersectionWithPlanes()(auto ref const plane3d!T o1,
		auto ref const plane3d!T o2,
		out vector3d!T outPoint) const
	{
		vector3d!T linePoint, lineVect;
		if (getIntersectionWithPlane(o1, linePoint, lineVect))
			return o2.getIntersectionWithLine(linePoint, lineVect, outPoint);

		return false;
	}

	/// Test if the triangle would be front or backfacing from any point.
	/** 
	* Thus, this method assumes a camera position from
	* which the triangle is definitely visible when looking into
	* the given direction.
	* Note that this only works if the normal is Normalized.
	* Do not use this method with points as it will give wrong results!
	* Params:
	* lookDirection = Look direction.
	* Returns: True if the plane is front facing and
	* false if it is backfacing. 
	*/
	bool isFrontFacing()(auto ref const vector3d!T lookDirection)
	{
		immutable float d = Normal.dotProduct(lookDirection);
		return LOWER_EQUAL_0 ( d );
	}

	/// Get the distance to a point.
	/** 
	* Note: that this only works if the normal is normalized. 
	*/
	T getDistanceTo()(auto ref const vector3d!T point)
	{
		return point.dotProduct(Normal) + D;
	}

	/// Normal vector of the plane
	vector3d!T Normal;

	/// Distance from origin
	T D;
}

/// Alias for a f32 3d plane.
alias plane3d!float plane3df;

/// Alias for an integer 3d plane.
alias plane3d!int plane3di;