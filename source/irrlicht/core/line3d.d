// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.line3d;

import irrlicht.core.vector3d;

/// 3D line between two points with intersection methods.
struct line3d(T)
{
	/// Constructor with two points
	this()(T xa, T ya, T za, T xb, T yb, T zb)
	{
		start = vector3d!T(xa, ya, za);
		end = vector3d!T(xb, yb, zb);
	}

	/// Constructor with two points as vectors
	this()(auto ref const vector3d!T start, auto ref const vector3d!end)
	{
		this.start = start;
		this.end = end;
	}

	line3d!T opBinary(string op)(auto ref const vector3d!T point)
		if(op == "+" || op == "-")
	{
		return line3d!T(mixin("start "~op~" point"), mixin("end "~op" point"));
	}

	auto ref line3d!T opOpAssign(string op)(auto ref const vector3d!T point)
		if(op == "+" || op == "-")
	{
		mixin("start "~op~"= point;");
		mixin("end "~op~"= point;");
		return this;
	}

	bool opEqual()(auto ref const line3d!T other)
	{
		return (start==other.start && end==other.end) || (end==other.start && start==other.end);
	}

	/// Set this line to a new line going through the two points.
	void setLine()(auto ref const T xa, auto ref const T ya, auto ref const T za, 
		auto ref const T xb, auto ref const T yb, auto ref const T zb)
	{
		start.set(xa, ya, za);
		end.set(xb, yb, zb);
	}

	/// Set this line to a new line going through the two points.
	void setLine()(auto ref const vector3d!T nstart, auto ref const vector3d!T nend)
	{
		start.set(nstart);
		end.set(nend);
	}

	/// Set this line to new line given as parameter.
	void setLine()(auto ref const line3d!T line)
	{
		start.set(line.start);
		end.set(line.end);
	}

	/// Get length of line
	/** 
	* Returns: Length of line. 
	*/
	T getLength() 
	{
		return start.getDistanceFrom(end);
	}

	/// Get squared length of line
	/**
	* Returns: Squared length of line.
	*/
	T getLengthSQ()
	{
		return start.getDistanceFromSQ(end);
	}

	/// Get middle of line
	/**
	* Returns: Center of line.
	*/
	vector3d!T getMiddle()
	{
		return (start + end)/cast(T)2;
	}

	/// Get vector of line
	/**
	* Returns: vector of line.
	*/
	vector3d!T getVector()
	{
		return end - start;
	}

	/// Check if the give point is between start and end of the line
	/**
	* Assumes that the point is already somewhere on the line.
	* Params:
	* point = Th point to test.
	* 
	* Returns: True if point is on the line between start and end, else false.
	*/
	bool isPointBetweenStartAndEnd()(auto ref const vector3d!T point)
	{
		return point.isBetweenPoints(start, end);
	}

	/// Get the closest point on this line to a point
	/**
	* Params:
	* point = Th point to compare to
	* Returns: The nearest point which is part of the line.
	*/
	vector3d!T getClosestPoint()(auto ref const vector3d!T point)
	{
		vector3d!T c = point - start;
		vector3d!T v = end - start;
		T d = cast(T)v.getLength();
		v /= d;
		T t = v.dotProduct(c);

		if (t < cast(T)0.0)
			return start;
		if (t > d)
			return end;

		v *= t;
		return start + v;
	}

	/// Chech if the line itersects with a shpere
	/**
	* Params:
	* sorigin = Origin of the shpere.
	* sradius = Readius of the sphere.
	* outdistance = The distance to the first intersection point
	* 
	* Returns: True if there is an intersection.
	* If there is one, the distance to the first intersection point
	* is stored in outdistance.
	*/
	bool getIntersectionWithSphere()(auto ref const vector3d!T sorigin, T sradius,
		out double outdistance)
	{
		immutable vector3d!T q = sorigin - start;
		T c = q.getLength();
		T v = q.dotProduct(getVector().normalize());
		T d = sradius * sradius - (c*c - v*v);

		if (d < 0.0)
		{
			outdistance = 0.0;
			return false;
		}

		outdistance = v - cast(double)sqrt(d);
		return true;
	}


	/// Start point of line
	vector3d!T start = vector3d!T(0,0,0);
	/// End point of line
	vector3d!T end =  vector3d!T(1,1,1);
}

/// Alias for an float line.
alias line3d!float line3df;

/// Alias for an integer line.
alias line3d!int line3di;