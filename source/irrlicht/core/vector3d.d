// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.vector3d;

import std.math;
import irrlicht.irrTypes;

//! 3d vector template class with lots of operators and methods.
/** The vector3d class is used in Irrlicht for three main purposes:
	1) As a direction vector (most of the methods assume this).
	2) As a position in 3d space (which is synonymous with a direction vector from the origin to this position).
	3) To hold three Euler rotations, where X is pitch, Y is yaw and Z is roll.
*/
struct vector3d(T)
{
	/// Constructor with three different values
	this()(T nx = 0, T ny = 0, T nz = 0)
	{
		X = nx;
		Y = ny;
		Z = nz;
	}

	/// Constructor with the same value for all elements
	this()(T n) 
	{
		X = Y = Z = n;
	}

	/// Copy constructor
	this()(auto ref const vector3d!T other)
	{
		X = other.X;
		Y = other.Y;
		Z = other.Z;
	}

	// operators

	vector3d!T opUnary(string op)()
		if(op == "-")
	{
		return vector3d!T(-X, -Y, -Z);
	}

	auto ref vector3d!T opAssign()(auto ref const vector3d!T other)
	{
		X = other.X;
		Y = other.Y;
		Z = other.Z;
		return this;
	}

	vector3d!T opBinary(string op)(auto ref const vector3d!T other)
		if(op == "+" || op == "-" || op == "*" || op == "/")
	{
		return vector3d!T(mixin("X "~op~" other.X"), mixin("Y "~op~" other.Y"), mixin("Z "~op~" other.Z"));
	}

	vector3d!T opBinary(string op)(const T v)
		if(op == "+" || op == "-" || op == "*" || op == "/")
	{
		return vector3d!T(mixin("X "~op~" v"), mixin("Y "~op~" v"), mixin("Z "~op~" v"));
	}

	auto ref vector3d!T opOpAssign(string op)(auto ref const vector3d!T other)
		if(op == "+" || op == "-" || op == "*" || op == "/")
	{
		mixin("X"~op~"=other.X");
		mixin("Y"~op~"=other.Y");
		mixin("Z"~op~"=other.Z");
		return this;
	}

	auto ref vector3d!T opOpAssign(string op)(const T v)
		if(op == "+" || op == "-" || op == "*" || op == "/")
	{
		mixin("X"~op~"=v");
		mixin("Y"~op~"=v");
		mixin("Z"~op~"=v");
		return this;
	}

	vector3d!T opBinaryRight(string op)(const T scalar)
		if(op == "*")
	{
		return vector3d!T(scalar * X, scalar * Y, scalar * Z);
	}

	/// sort in order X, Y, Z. Equality with rounding tolerance.
	/// Difference must be above rounding tolerance.
	bool opCmp()(auto ref const vector3d!T other)
	{
		if ((X<other.X && !approxEqual(X, other.X)) ||
					(approxEqual(X, other.X) && Y<other.Y && !approxEqual(Y, other.Y)) ||
					(approxEqual(X, other.X) && approxEqual(Y, other.Y) && Z<other.Z && !approxEqual(Z, other.Z)))
		{
			return -1;
		}
		else if ((X>other.X && !approxEqual(X, other.X)) ||
					(approxEqual(X, other.X) && Y>other.Y && !approxEqual(Y, other.Y)) ||
					(approxEqual(X, other.X) && approxEqual(Y, other.Y) && Z>other.Z && !approxEqual(Z, other.Z)))
		{
			return 1;
		}
		else
			return 0;
	}

	bool opEqual()(auto ref const vector3d!T other)
	{
		return equals(other);
	}

	/// returns if this vector equals the other one, taking floating point rounding errors into account
	bool equals()(auto ref const vector3d!T other, const T tolerance = 1e-05)
	{
		return approxEqual(X, other.X, tolerance) &&
			approxEqual(Y, other.Y, tolerance) &&
			approxEqual(Z, other.Z, tolerance);
	}

	auto ref vector3d!T set(const T nx, const T ny, const T nz)
	{
		X = nx;
		Y = ny;
		Z = nz;
		return this;
	}

	auto ref vector3d!T set(auto ref const vector3d!T p)
	{
		X = p.X;
		Y = p.Y;
		Z = p.Z;
		return this;
	}

	/// Get length of the vector
	T getLength() 
	{
		return cast(T)sqrt(X*X + Y*Y + Z*Z);
	}

	/// Get squared length of the vector
	/**
	* This is useful vecause it is much faster than getLength().
	* Returns: Squared length of the vector.
	*/
	T getLengthSQ()
	{
		return X*X + Y*Y + Z*Z;
	}

	/// Get the dot product with another vector.
	T dotProduct()(auto ref const vector3d!T other)
	{
		return X*other.X + Y*other.Y + Z*other.Z;
	}

	/// Get distance from another point.
	/**
	* Here, the vector is interpreted as point in 3 dimensional space.
	*/
	T getDistanceFrom(auto ref const vector3d!T other)
	{
		return vector3d!T(X - other.X, Y-other.Y, Z-other.Z).getLength();
	}

	/// Returns squared distance from another point.
	/**
	* Here, the vector is interpreted as point in 3 dimensional space.
	*/
	T getDistanceFromSQ(auto ref const vector3d!T other)
	{
		return vector3d!T(X - other.X, Y-other.Y, Z-other.Z).getLengthSQ();
	}

	/// Calculates the cross product with another vector.
	/**
	* Params: 
	* p = Vector to multiply with.
	* Returns: Crossproduct of this vector with p. 
	*/
	vector3d!T crossProduct()(auto ref const vector3d!T p)
	{
		return vector3d!T(Y * p.Z - Z * p.Y, Z * p.X - X * p.Z, X * p.Y - Y * p.X);
	}

	/// Returns if this vector interpreted as a point is on a line between two other points.
	/** 
	* It is assumed that the point is on the line.
	* Params:
	* begin = Beginning vector to compare between.
	* end = Ending vector to compare between.
	* Returns: True if this vector is between begin and end, false if not. 
	*/
	bool isBetweenPoints()(auto ref const vector3d!T begin, auto ref const vector3d!T end)
	{
		immutable T f = (end - begin).getLengthSQ();
		return getDistanceFromSQ(begin) <= f &&
			getDistanceFromSQ(end) <= f;
	}

	/// Normalizes the vector.
	/** 
	* In case of the 0 vector the result is still 0, otherwise
	* the length of the vector will be 1.
	* Returns: Reference to this vector after normalization. 
	*/
	auto ref vector3d!T normalize()
	{
		double length = X*X + Y*Y + Z*Z;
		if (length == 0)
			return this;

		length = 1 / cast(double)sqrt(length);

		X = cast(T)(X * length);
		Y = cast(T)(Y * length);
		Z = cast(T)(Z * length);
		return this;
	}

	/// Sets the length of the vector to a new value
	auto ref vector3d!T setLength()(T newlength)
	{
		normalize();
		return (this *= newlength);
	}

	/// Inverts the vector.
	vector3d!T invert()
	{
		X *= -1;
		Y *= -1;
		Z *= -1;
		return this;
	}

	/// Rotates the vector by a specified number of degrees around the Y axis and the specified center.
	/**
	* Params:
	* degrees = Number of degrees to rotate around the Y axis.
	* center = The center of the rotation. 
	*/
	void rotateXZBy()(double degrees, auto ref const vector3d!T center)
	{
		degrees *= DEGTORAD;
		double cs = cast(double)cos(degrees);
		double sn = cast(double)sin(degrees);
		X -= center.X;
		Z -= center.Z;
		set(cast(T)(X*cs - Z*sn), Y, cast(T)(X*sn + Z*cs));
		X += center.X;
		Z += center.Z;
	}

	/// Rotates the vector by a specified number of degrees around the X axis and the specified center.
	/**
	* Params: 
	* degrees = Number of degrees to rotate around the X axis.
	* center = The center of the rotation. 
	*/
	void rotateYZBy()(double degrees, auto ref const vector3d!T center)
	{
		degrees *= DEGTORAD;
		double cs = cast(double)cos(degrees);
		double sn = cast(double)sin(degrees);
		Z -= center.Z;
		Y -= center.Y;
		set(X, cast(T)(Y*cs - Z*sn), cast(T)(Y*sn + Z*cs));
		Z += center.Z;
		Y += center.Y;
	}

	/// Creates an interpolated vector between this vector and another vector.
	/**
	* Params: 
	* other = The other vector to interpolate with.
	* d = Interpolation value between 0.0f (all the other vector) and 1.0f (all this vector).
	* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	* Returns: An interpolated vector.  This vector is not modified. 
	*/
	vector3d!T getInterpolated()(auto ref const vector3d!T other, double d)
	{
		immutable double inv = 1.0 - d;
		return vector3d!T(cast(T)(other.X*inv + X*d), cast(T)(other.Y*inv + Y*d), cast(T)(other.Z*inv + Z*d));
	}

	/// Creates a quadratically interpolated vector between this and two other vectors.
	/** 
	* Params:
	* v2 = Second vector to interpolate with.
	* v3 = Third vector to interpolate with (maximum at 1.0f)
	* d = Interpolation value between 0.0f (all this vector) and 1.0f (all the 3rd vector).
	* Note that this is the opposite direction of interpolation to getInterpolated() and interpolate()
	* Returns: An interpolated vector. This vector is not modified. 
	*/
	vector3d!T getInterpolated_quadratic()(auto ref const vector3d!T v2, auto ref const vector3d!T v3, double d)
	{
		// this*(1-d)*(1-d) + 2 * v2 * (1-d) + v3 * d * d;
		immutable double inv = cast(T) 1.0 - d;
		immutable double mul0 = inv * inv;
		immutable double mul1 = cast(T) 2.0 * d * inv;
		immutable double mul2 = d * d;

		return vector3d!T(cast(T)(X * mul0 + v2.X * mul1 + v3.X * mul2),
				cast(T)(Y * mul0 + v2.Y * mul1 + v3.Y * mul2),
				cast(T)(Z * mul0 + v2.Z * mul1 + v3.Z * mul2));
	}

	/// Sets this vector to the linearly interpolated vector between a and b.
	/**
	* Params: 
	* a = first vector to interpolate with, maximum at 1.0f
	* b = second vector to interpolate with, maximum at 0.0f
	* d = Interpolation value between 0.0f (all vector b) and 1.0f (all vector a)
	* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	*/
	auto ref vector3d!T interpolate()(auto ref const vector3d!T a, auto ref const vector3d!T b, double d)
	{
		X = cast(T)(cast(double)b.X + ( ( a.X - b.X ) * d ));
		Y = cast(T)(cast(double)b.Y + ( ( a.Y - b.Y ) * d ));
		Z = cast(T)(cast(double)b.Z + ( ( a.Z - b.Z ) * d ));
		return this;
	}

	/// Get the rotations that would make a (0,0,1) direction vector point in the same direction as this direction vector.
	/** 
	* Thanks to Arras on the Irrlicht forums for this method.  This utility method is very useful for
	* orienting scene nodes towards specific targets.  For example, if this vector represents the difference
	* between two scene nodes, then applying the result of getHorizontalAngle() to one scene node will point
	* it at the other one.
	* Example:
	* --------
	* // Where target and seeker are of type ISceneNode*
	* const vector3df toTarget(target.getAbsolutePosition() - seeker.getAbsolutePosition());
	* const vector3df requiredRotation = toTarget.getHorizontalAngle();
	* seeker->setRotation(requiredRotation);
	* --------
	*
	* Returns: A rotation vector containing the X (pitch) and Y (raw) rotations (in degrees) that when applied to a
	* +Z (e.g. 0, 0, 1) direction vector would make it point in the same direction as this vector. The Z (roll) rotation
	* is always 0, since two Euler rotations are sufficient to point in any given direction. 
	*/
	vector3d!T getHorizontalAngle()
	{
		vector3d!T angle;

		immutable double tmp = (atan2(cast(double)X, cast(double)Z) * RADTODEG);
		angle.Y = cast(T)tmp;

		if (angle.Y < 0)
			angle.Y += 360;
		if (angle.Y >= 360)
			angle.Y -= 360;

		immutable double z1 = cast(double)sqrt(X*X + Z*Z);

		angle.X = cast(T)(atan2(cast(double)z1, cast(double)Y) * RADTODEG - 90.0);

		if (angle.X < 0)
			angle.X += 360;
		if (angle.X >= 360)
			angle.X -= 360;

		return angle;
	}

	/// Get the spherical coordinate angles
	/** 
	* This returns Euler degrees for the point represented by
	* this vector.  The calculation assumes the pole at (0,1,0) and
	* returns the angles in X and Y.
	*/
	vector3d!T getSphericalCoordinateAngles()()
		if(!is(T == int))
	{
		vector3d!T angle;
		immutable double length = X*X + Y*Y + Z*Z;

		if (length)
		{
			if (X!=0)
			{
				angle.Y = cast(T)(atan2(cast(double)Z,cast(double)X) * RADTODEG);
			}
			else if (Z<0)
				angle.Y=180;

			angle.X = cast(T)(acos(Y * 1/sqrt(length)) * RADTODEG);
		}
		return angle;
	}

	/// Get the spherical coordinate angles
	/** 
	* This returns Euler degrees for the point represented by
	* this vector.  The calculation assumes the pole at (0,1,0) and
	* returns the angles in X and Y.
	*/
	vector3d!T getSphericalCoordinateAngles()()
		if(is(T == int))
	{
		vector3d!int angle;
		immutable double length = X*X + Y*Y + Z*Z;

		if (length)
		{
			if (X!=0)
			{
				angle.Y = round(cast(float)(atan2(cast(double)Z,cast(double)X) * RADTODEG));
			}
			else if (Z<0)
				angle.Y=180;

			angle.X = round(cast(float)(acos(Y * 1/sqrt(length)) * RADTODEG));
		}
		return angle;
	}

	/// Builds a direction vector from (this) rotation vector.
	/** 
	* This vector is assumed to be a rotation vector composed of 3 Euler angle rotations, in degrees.
	* The implementation performs the same calculations as using a matrix to do the rotation.
    *
    * Params:
	* forwards = The direction representing "forwards" which will be rotated by this vector.
	* If you do not provide a direction, then the +Z axis (0, 0, 1) will be assumed to be forwards.
	* Returns: A direction vector calculated by rotating the forwards direction by the 3 Euler angles
	* (in degrees) represented by this vector. 
	*/
	vector3d!T rotationToDirection()(auto ref const vector3d!T forwards)
	{
		immutable double cr = cast(double)cos( DEGTORAD * X );
		immutable double sr = cast(double)sin( DEGTORAD * X );
		immutable double cp = cast(double)cos( DEGTORAD * Y );
		immutable double sp = cast(double)sin( DEGTORAD * Y );
		immutable double cy = cast(double)cos( DEGTORAD * Z );
		immutable double sy = cast(double)sin( DEGTORAD * Z );

		immutable srsp = sr*sp;
		immutable crsp = cr*sp;

		immutable double pseudoMatrix[] = [
			( cp*cy ), ( cp*sy ), ( -sp ),
			( srsp*cy-cr*sy ), ( srsp*sy+cr*cy ), ( sr*cp ),
			( crsp*cy+sr*sy ), ( crsp*sy-sr*cy ), ( cr*cp )
			];

		return vector3d!T(
			cast(T)(forwards.X * pseudoMatrix[0] +
				    forwards.Y * pseudoMatrix[3] +
				    forwards.Z * pseudoMatrix[6]),
			cast(T)(forwards.X * pseudoMatrix[1] +
				    forwards.Y * pseudoMatrix[4] +
				    forwards.Z * pseudoMatrix[7]),
			cast(T)(forwards.X * pseudoMatrix[2] +
				    forwards.Y * pseudoMatrix[5] +
				    forwards.Z * pseudoMatrix[8]));
	}

	/// Fills an array of 4 values with the vector data (usually floats).
	/** 
	* Useful for setting in shader constants for example. The fourth value
	* will always be 0. 
	*/
	void getAs4Values(out T[4] array)
	{
		array[0] = X;
		array[1] = Y;
		array[2] = Z;
		array[3] = 0;
	}

	/// Fills an array of 3 values with the vector data (usually floats).
	/** 
	* Useful for setting in shader constants for example.
	*/
	void getAs3Values(out T[3] array) const
	{
		array[0] = X;
		array[1] = Y;
		array[2] = Z;
	}

	/// X coordinate of the vector
	T X = 0;

	/// Y coordinate of the vector
	T Y = 0;

	/// Z coordinate of the vector
	T Z = 0;
}

/// Alias for a f32 3d vector.
alias vector3d!float vector3df;

/// Alias for an integer 3d vector.
alias vector3d!int vector3di;