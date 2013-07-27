// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.line2d;

import irrlicht.core.vector2d;

/// 2D line between two points with intersection methods.
struct line2d(T)
{
	/// Constructor for line between the two points.
	this()(T xa, T ya, T xb, T yb) pure
	{
		start = vector2d!T(xa, xb);
		end = vector2d!T(xb, yb);
	}

	/// Constructor for line between the two points given as vectors.
	this()(auto ref const vector2d!T start, auto ref const vector2d!T end) pure
	{
		this.start = start;
		this.end = end;
	}

	/// Copy constructor.
	this()(auto ref const line2d!T other) pure 
	{
		start = other.start;
		end = other.end;
	}

	// operators

	line2d!T opBinary(string op)(auto ref const vector2d!T point) const
		if(op == "+" || op == "-")
	{
		return line2d!T(mixin("start"~op~"point"), mixin("end"~op~"point"));
	}

	auto ref line2d!T opOpAssign(string op)(auto ref const vector2d!T point)
		if(op == "+" || op == "-")
	{
		mixin("start"~op~"= point;");
		mixin("end"~op~"= point;");
		return this;
	}

	bool opEqual()(auto ref const line2d!T other) const
	{ 
		return (start==other.start && end==other.end) || 
			(end==other.start && start==other.end);
	}

	// functions
	/// Set this line to new line going through the two points.
	void setLine()(const T xa, const T ya, const T xb, const T yb)
	{
		start.set(xa, ya); end.set(xb, yb);
	}

	/// Set this line to new line going through the two points.
	void setLine()(auto ref const vector2d!T nstart,
		auto ref const vector2d!T nend)
	{
		start.set(nstart); 
		end.set(nend);
	}

	/// Set this line to new line given as parameter.
	void setLine()(auto ref const line2d!T line)
	{
		start.set(line.start); 
		end.set(line.end);
	}

	/// Get length of line
	/**
	* Returns: Length of the line. 
	*/
	T getLength() const 
	{ 
		return start.getDistanceFrom(end); 
	}

	/// Get squared length of the line
	/**
	* Returns: Squared length of line. 
	*/
	T getLengthSQ() const 
	{ 
		return start.getDistanceFromSQ(end); 
	}

	/// Get middle of the line
	/**
	* Returns: center of the line. 
	*/
	vector2d!T getMiddle() const
	{
		return (start + end)/cast(T)2;
	}

	/// Get the vector of the line.
	/**
	* Returns: The vector of the line. 
	*/
	vector2d!T getVector() const 
	{ 
		return vector2d!T(end.X - start.X, end.Y - start.Y); 
	}

	/// Tests if this line intersects with another line.
	/**
	* Params:
	* 	l=  Other line to test intersection with.
	* 	checkOnlySegments=  Default is to check intersection between the begin and endpoints.
	* When set to false the function will check for the first intersection point when extending the lines.
	* 	outVec=  If there is an intersection, the location of the
	* intersection will be stored in this vector.
	* Returns: True if there is an intersection, false if not. 
	*/
	bool intersectWith()(auto ref const line2d!T l, out vector2d!T outVec, bool checkOnlySegments=true) const
	{
		// Uses the method given at:
		// http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		immutable float commonDenominator = cast(float)(l.end.Y - l.start.Y)*(end.X - start.X) -
										(l.end.X - l.start.X)*(end.Y - start.Y);

		immutable float numeratorA = cast(float)(l.end.X - l.start.X)*(start.Y - l.start.Y) -
										(l.end.Y - l.start.Y)*(start.X -l.start.X);

		immutable float numeratorB = cast(float)(end.X - start.X)*(start.Y - l.start.Y) -
										(end.Y - start.Y)*(start.X -l.start.X);

		if(approxEqual(commonDenominator, 0.0f))
		{
			// The lines are either coincident or parallel
			// if both numerators are 0, the lines are coincident
			if(approxEqual(numeratorA, 0.0f) && approxEqual(numeratorB, 0.0f))
			{
				// Try and find a common endpoint
				if(l.start == start || l.end == start)
					outVec = start;
				else if(l.end == end || l.start == end)
					outVec = end;
				// now check if the two segments are disjunct
				else if (l.start.X>start.X && l.end.X>start.X && l.start.X>end.X && l.end.X>end.X)
					return false;
				else if (l.start.Y>start.Y && l.end.Y>start.Y && l.start.Y>end.Y && l.end.Y>end.Y)
					return false;
				else if (l.start.X<start.X && l.end.X<start.X && l.start.X<end.X && l.end.X<end.X)
					return false;
				else if (l.start.Y<start.Y && l.end.Y<start.Y && l.start.Y<end.Y && l.end.Y<end.Y)
					return false;
				// else the lines are overlapping to some extent
				else
				{
					// find the points which are not contributing to the
					// common part
					vector2d!T maxp;
					vector2d!T minp;
					if ((start.X>l.start.X && start.X>l.end.X && start.X>end.X) || (start.Y>l.start.Y && start.Y>l.end.Y && start.Y>end.Y))
						maxp=start;
					else if ((end.X>l.start.X && end.X>l.end.X && end.X>start.X) || (end.Y>l.start.Y && end.Y>l.end.Y && end.Y>start.Y))
						maxp=end;
					else if ((l.start.X>start.X && l.start.X>l.end.X && l.start.X>end.X) || (l.start.Y>start.Y && l.start.Y>l.end.Y && l.start.Y>end.Y))
						maxp=l.start;
					else
						maxp=l.end;
					if (maxp != start && ((start.X<l.start.X && start.X<l.end.X && start.X<end.X) || (start.Y<l.start.Y && start.Y<l.end.Y && start.Y<end.Y)))
						minp=start;
					else if (maxp != end && ((end.X<l.start.X && end.X<l.end.X && end.X<start.X) || (end.Y<l.start.Y && end.Y<l.end.Y && end.Y<start.Y)))
						minp=end;
					else if (maxp != l.start && ((l.start.X<start.X && l.start.X<l.end.X && l.start.X<end.X) || (l.start.Y<start.Y && l.start.Y<l.end.Y && l.start.Y<end.Y)))
						minp=l.start;
					else
						minp=l.end;

					// one line is contained in the other. Pick the center
					// of the remaining points, which overlap for sure
					outVec = vector2d!T(0);
					if (start != maxp && start != minp)
						outVec += start;
					if (end != maxp && end != minp)
						outVec += end;
					if (l.start != maxp && l.start != minp)
						outVec += l.start;
					if (l.end != maxp && l.end != minp)
						outVec += l.end;
					outVec.X = cast(T)(outVec.X/2.0);
					outVec.Y = cast(T)(outVec.Y/2.0);
				}

				return true; // coincident
			}

			return false; // parallel
		}

		// Get the point of intersection on this line, checking that
		// it is within the line segment.
		immutable float uA = numeratorA / commonDenominator;
		if(checkOnlySegments && (uA < 0.f || uA > 1.f) )
			return false; // Outside the line segment

		immutable float uB = numeratorB / commonDenominator;
		if(checkOnlySegments && (uB < 0.f || uB > 1.f))
			return false; // Outside the line segment

		// Calculate the intersection point.
		outVec.X = cast(T)(start.X + uA * (end.X - start.X));
		outVec.Y = cast(T)(start.Y + uA * (end.Y - start.Y));
		return true;
	}

	/// Get unit vector of the line.
	/**
	* Returns: Unit vector of this line. 
	*/
	vector2d!T getUnitVector() const
	{
		T len = cast(T)(1.0 / getLength());
		return vector2d!T((end.X - start.X) * len, (end.Y - start.Y) * len);
	}

	/// Get angle between this line and given line.
	/**
	* Params:
	* 	l=  Other line for test.
	* Returns: Angle in degrees. 
	*/
	double getAngleWith()(auto ref const line2d!T l) const
	{
		vector2d!T vect = getVector();
		vector2d!T vect2 = l.getVector();
		return vect.getAngleWith(vect2);
	}

	/// Tells us if the given point lies to the left, right, or on the line.
	/**
	* Returns: 0 if the point is on the line
	* <0 if to the left, or >0 if to the right. 
	*/
	T getPointOrientation()(auto ref const vector2d!T point) const
	{
		return ( (end.X - start.X) * (point.Y - start.Y) -
				(point.X - start.X) * (end.Y - start.Y) );
	}

	/// Check if the given point is a member of the line
	/**
	* Returns: True if point is between start and end, else false. 
	*/
	bool isPointOnLine()(auto ref const vector2d!T point) const
	{
		T d = getPointOrientation(point);
		return (d == 0 && point.isBetweenPoints(start, end));
	}

	/// Check if the given point is between start and end of the line.
	/**
	* Assumes that the point is already somewhere on the line. 
	*/
	bool isPointBetweenStartAndEnd()(auto ref const vector2d!T point) const
	{
		return point.isBetweenPoints(start, end);
	}

	/// Get the closest point on this line to a point
	/**
	* Params:
	* 	checkOnlySegments=  Default (true) is to return a point on the line-segment (between begin and end) of the line.
	* When set to false the function will check for the first the closest point on the the line even when outside the segment. 
	*/
	vector2d!T getClosestPoint()(auto ref const vector2d!T point, bool checkOnlySegments=true) const
	{
		auto c = vector2d!double(cast(double)(point.X-start.X), cast(double)(point.Y- start.Y));
		auto v = vector2d!double(cast(double)(end.X-start.X), cast(double)(end.Y-start.Y));
		double d = v.getLength();
		if ( d == 0 )	// can't tell much when the line is just a single point
			return start;
		v /= d;
		double t = v.dotProduct(c);

		if ( checkOnlySegments )
		{
			if (t < 0) return vector2d!T(cast(T)start.X, cast(T)start.Y);
			if (t > d) return vector2d!T(cast(T)end.X, cast(T)end.Y);
		}

		v *= t;
		return vector2d!T(cast(T)(start.X + v.X), cast(T)(start.Y + v.Y));
	}

	/// Start point of the line.
	vector2d!T start = vector2d!T(0);
	/// End point of the line.
	vector2d!T end = vector2d!T(1);
}
