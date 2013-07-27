// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.triangle3d;

import irrlicht.core.vector3d;
import irrlicht.core.line3d;
import irrlicht.core.plane3d;
import irrlicht.core.aabbox3d;
import irrlicht.irrMath;

//! 3d triangle template struct for doing collision detection and other things.
struct triangle3d(T)
{
	//! Constructor for triangle with given three vertices
	this()(auto ref const vector3d!T v1, auto ref const vector3d!T v2, auto ref const vector3d!T v3)
	{
		pointA = v1;
		pointB = v2;
		pointC = v3;
	}

	//! Equality operator
	bool opEqual()(auto ref const triangle3d!T other) 
	{
		return other.pointA==pointA && other.pointB==pointB && other.pointC==pointC;
	}

	//! Determines if the triangle is totally inside a bounding box.
	/** \param box Box to check.
	\return True if triangle is within the box, otherwise false. */
	bool isTotalInsideBox()(auto ref const aabbox3d!T box)
	{
		return (box.isPointInside(pointA) &&
			box.isPointInside(pointB) &&
			box.isPointInside(pointC));
	}

	//! Determines if the triangle is totally outside a bounding box.
	/** \param box Box to check.
	\return True if triangle is outside the box, otherwise false. */
	bool isTotalOutsideBox()(auto ref const aabbox3d!T box)
	{
		return ((pointA.X > box.MaxEdge.X && pointB.X > box.MaxEdge.X && pointC.X > box.MaxEdge.X) ||
			(pointA.Y > box.MaxEdge.Y && pointB.Y > box.MaxEdge.Y && pointC.Y > box.MaxEdge.Y) ||
			(pointA.Z > box.MaxEdge.Z && pointB.Z > box.MaxEdge.Z && pointC.Z > box.MaxEdge.Z) ||
			(pointA.X < box.MinEdge.X && pointB.X < box.MinEdge.X && pointC.X < box.MinEdge.X) ||
			(pointA.Y < box.MinEdge.Y && pointB.Y < box.MinEdge.Y && pointC.Y < box.MinEdge.Y) ||
			(pointA.Z < box.MinEdge.Z && pointB.Z < box.MinEdge.Z && pointC.Z < box.MinEdge.Z));
	}

	//! Get the closest point on a triangle to a point on the same plane.
	/** \param p Point which must be on the same plane as the triangle.
	\return The closest point of the triangle */
	vector3d!T closestPointOnTriangle()(auto ref const vector3d!T p)
	{
		immutable vector3d!T rab = line3d!T(pointA, pointB).getClosestPoint(p);
		immutable vector3d!T rbc = line3d!T(pointB, pointC).getClosestPoint(p);
		immutable vector3d!T rca = line3d!T(pointC, pointA).getClosestPoint(p);

		immutable T d1 = rab.getDistanceFrom(p);
		immutable T d2 = rbc.getDistanceFrom(p);
		immutable T d3 = rca.getDistanceFrom(p);

		if (d1 < d2)
			return d1 < d3 ? rab : rca;

		return d2 < d3 ? rbc : rca;
	}

	//! Check if a point is inside the triangle (border-points count also as inside)
	/*
	\param p Point to test. Assumes that this point is already
	on the plane of the triangle.
	\return True if the point is inside the triangle, otherwise false. */
	bool isPointInside()(auto ref const vector3d!T p)
	{
		immutable af64 = vector3d!double(cast(double)pointA.X, cast(double)pointA.Y, cast(double)pointA.Z);
		immutable bf64 = vector3d!double(cast(double)pointB.X, cast(double)pointB.Y, cast(double)pointB.Z);
		immutable cf64 = vector3d!double(cast(double)pointC.X, cast(double)pointC.Y, cast(double)pointC.Z);
		immutable pf64 = vector3d!double(cast(double)p.X, cast(double)p.Y, cast(double)p.Z);
		return (isOnSameSide(pf64, af64, bf64, cf64) &&
				isOnSameSide(pf64, bf64, af64, cf64) &&
				isOnSameSide(pf64, cf64, af64, bf64));
	}

	//! Check if a point is inside the triangle (border-points count also as inside)
	/** This method uses a barycentric coordinate system.
	It is faster than isPointInside but is more susceptible to floating point rounding
	errors. This will especially be noticable when the FPU is in single precision mode
	(which is for example set on default by Direct3D).
	\param p Point to test. Assumes that this point is already
	on the plane of the triangle.
	\return True if point is inside the triangle, otherwise false. */
	bool isPointInsideFast()(auto ref const vector3d!T p)
	{
		immutable vector3d!T a = pointC - pointA;
		immutable vector3d!T b = pointB - pointA;
		immutable vector3d!T c = p - pointA;

		immutable double dotAA = a.dotProduct( a);
		immutable double dotAB = a.dotProduct( b);
		immutable double dotAC = a.dotProduct( c);
		immutable double dotBB = b.dotProduct( b);
		immutable double dotBC = b.dotProduct( c);

		// get coordinates in barycentric coordinate system
		immutable double invDenom =  1/(dotAA * dotBB - dotAB * dotAB);
		immutable double u = (dotBB * dotAC - dotAB * dotBC) * invDenom;
		immutable double v = (dotAA * dotBC - dotAB * dotAC ) * invDenom;

		// We count border-points as inside to keep downward compatibility.
		// Rounding-error also needed for some test-cases.
		return (u > -float.epsilon) && (v >= 0) && (u + v < 1+float.epsilon);
	}


	//! Get an intersection with a 3d line.
	/** \param line Line to intersect with.
	\param outIntersection Place to store the intersection point, if there is one.
	\return True if there was an intersection, false if not. */
	bool getIntersectionWithLimitedLine()(auto ref const line3d!T line,
		out vector3d!T outIntersection)
	{
		return getIntersectionWithLine(line.start,
			line.getVector(), outIntersection) &&
			outIntersection.isBetweenPoints(line.start, line.end);
	}


	//! Get an intersection with a 3d line.
	/** Please note that also points are returned as intersection which
	are on the line, but not between the start and end point of the line.
	If you want the returned point be between start and end
	use getIntersectionWithLimitedLine().
	\param linePoint Point of the line to intersect with.
	\param lineVect Vector of the line to intersect with.
	\param outIntersection Place to store the intersection point, if there is one.
	\return True if there was an intersection, false if there was not. */
	bool getIntersectionWithLine()(auto ref const vector3d!T linePoint,
		auto ref const vector3d!T lineVect, out vector3d!T outIntersection)
	{
		if (getIntersectionOfPlaneWithLine(linePoint, lineVect, outIntersection))
			return isPointInside(outIntersection);

		return false;
	}


	//! Calculates the intersection between a 3d line and the plane the triangle is on.
	/** \param lineVect Vector of the line to intersect with.
	\param linePoint Point of the line to intersect with.
	\param outIntersection Place to store the intersection point, if there is one.
	\return True if there was an intersection, else false. */
	bool getIntersectionOfPlaneWithLine()(auto ref const vector3d!T linePoint,
		auto ref const vector3d!T lineVect, out vector3d!T outIntersection)
	{
		// Work with double to get more precise results (makes enough difference to be worth the casts).
		immutable linePointf64 = vector3d!double(linePoint.X, linePoint.Y, linePoint.Z);
		immutable lineVectf64  = vector3d!double(lineVect.X, lineVect.Y, lineVect.Z);
		vector3d!double outIntersectionf64;

		auto trianglef64 = triangle3d!double(vector3d!double(cast(double)pointA.X, cast(double)pointA.Y, cast(double)pointA.Z)
									,vector3d!double(cast(double)pointB.X, cast(double)pointB.Y, cast(double)pointB.Z)
									, vector3d!double(cast(double)pointC.X, cast(double)pointC.Y, cast(double)pointC.Z));
		immutable vector3d!double normalf64 = trianglef64.getNormal().normalize();
		double t2;

		if ( iszero( t2 = normalf64.dotProduct(lineVectf64) ) )
			return false;

		double d = trianglef64.pointA.dotProduct(normalf64);
		double t = -(normalf64.dotProduct(linePointf64) - d) / t2;
		outIntersectionf64 = linePointf64 + (lineVectf64 * t);

		outIntersection.X = cast(T)outIntersectionf64.X;
		outIntersection.Y = cast(T)outIntersectionf64.Y;
		outIntersection.Z = cast(T)outIntersectionf64.Z;
		return true;
	}


	//! Get the normal of the triangle.
	/** Please note: The normal is not always normalized. */
	vector3d!T getNormal()
	{
		return (pointB - pointA).crossProduct(pointC - pointA);
	}

	//! Test if the triangle would be front or backfacing from any point.
	/** Thus, this method assumes a camera position from which the
	triangle is definitely visible when looking at the given direction.
	Do not use this method with points as it will give wrong results!
	\param lookDirection Look direction.
	\return True if the plane is front facing and false if it is backfacing. */
	bool isFrontFacing()(auto ref const vector3d!T lookDirection)
	{
		immutable vector3d!T n = getNormal().normalize();
		immutable float d = cast(float)n.dotProduct(lookDirection);
		return F32_LOWER_EQUAL_0(d);
	}

	//! Get the plane of this triangle.
	plane3d!T getPlane()
	{
		return plane3d!T(pointA, pointB, pointC);
	}

	//! Get the area of the triangle
	T getArea()
	{
		return (pointB - pointA).crossProduct(pointC - pointA).getLength() * 0.5f;

	}

	//! sets the triangle's points
	void set()(auto ref const vector3d!T a, auto ref const vector3d!T b, auto ref const vector3d!T c)
	{
		pointA = a;
		pointB = b;
		pointC = c;
	}

	//! the first point of the triangle
	vector3d!T pointA;
	//! the second point of the triangle
	vector3d!T pointB;
	//! the third point of the triangle
	vector3d!T pointC;

	// Using double instead of !T to avoid integer overflows when T=int (maybe also less floating point troubles).
	private bool isOnSameSide()(auto ref const vector3d!double p1, auto ref const vector3d!double p2,
		auto ref const vector3d!double a, auto ref const vector3d!double b)
	{
		vector3d!double bminusa = b - a;
		vector3d!double cp1 = bminusa.crossProduct(p1 - a);
		vector3d!double cp2 = bminusa.crossProduct(p2 - a);
		double res = cp1.dotProduct(cp2);
		if ( res < 0 )
		{
			// This catches some floating point troubles.
			// Unfortunately slightly expensive and we don't really know the best epsilon for iszero.
			vector3d!double cp1 = bminusa.normalize().crossProduct((p1 - a).normalize());
			if ( 	iszero(cp1.X, cast(double)float.epsilon)
				&& 	iszero(cp1.Y, cast(double)float.epsilon)
				&& 	iszero(cp1.Z, cast(double)float.epsilon) )
			{
				res = 0.f;
			}
		}
		return (res >= 0.0f);
	}
}

/// Alias for a float 3d triangle.
alias triangle3d!float triangle3df;

/// Alias for an integer 3d triangle.
alias triangle3d!int triangle3di;