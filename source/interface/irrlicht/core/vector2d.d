// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.vector2d;

import irrlicht.core.dimension2d;
import irrlicht.irrMath;
import std.math;

/// 2d vector template class with lots of operators and methods.
/**
* As of Irrlicht 1.6, this class supercedes position2d, which should
* considered deprecated.
*/
struct vector2d(T)
{
	public
	{
		/// Constructor with two different values
		this(T nx, T ny) pure
		{
			X = nx;
			Y = ny;
		}

		/// Constructor with the same value for both members
		this(T n) pure
		{
			X = n;
			Y = n;
		}

		/// Copy constructor
		this(const vector2d!T other) pure
		{
			X = other.X;
			Y = other.Y;
		}

		this(const dimension2d!T other) pure
		{
			X = other.Width;
			Y = other.Height;
		}

		vector2d!T opUnary(string op)() const if(op == "-") 
		{
			return vector2d!T(-X, -Y);
		}

		auto ref vector2d!T opAssign(const vector2d!T other)
		{
			X = other.X;
			Y = other.Y;
			return this;
		}

		auto ref vector2d!T opAssign(const dimension2d!T other)
		{
			X = other.Width;
			Y = other.Height;
			return this;
		}

		vector2d!T opBinary(string op)(const vector2d!T other) const
			if(op == "+")
		{
			return vector2d!T(X+other.X, Y+other.Y);
		}

		vector2d!T opBinary(string op)(const dimension2d!T other) const
			if(op == "+")
		{
			return vector2d!T(X+other.Width, Y+other.Height);
		}

		auto ref vector2d opOpAssign(string op)(auto ref const vector2d!T other)
			if(op == "+")
		{
			X+= other.X;
			Y+= other.Y;
			return this;
		}

		vector2d!T opBinary(string op)(const T v) const
			if(op == "+")
		{
			return vector2d!T(X + v, Y + v);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const T v)
			if(op == "+")
		{
			X+= v;
			Y+= v;
			return this;
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const dimension2d!T other)
			if(op == "+")
		{
			X+= other.Width;
			Y+= other.Height;
			return this;
		}

		vector2d!T opBinary(string op)(const vector2d!T other) const
			if(op == "-")
		{
			return vector2d!T(X-other.X, Y-other.Y);
		}

		vector2d!T opBinary(string op)(const dimension2d!T other) const
			if(op == "-")
		{
			return vector2d!T(X-other.Width, Y-other.Height);
		}

		auto ref vector2d opOpAssign(string op)(auto ref const vector2d!T other)
			if(op == "-")
		{
			X-= other.X;
			Y-= other.Y;
			return this;
		}

		vector2d!T opBinary(string op)(const T v) const
			if(op == "-")
		{
			return vector2d!T(X - v, Y - v);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const T v)
			if(op == "-")
		{
			X-= v;
			Y-= v;
			return this;
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const dimension2d!T other)
			if(op == "-")
		{
			X-= other.Width;
			Y-= other.Height;
			return this;
		}

		vector2d!T opBinary(string op)(const vector2d!T other) const
			if(op == "*")
		{
			return vector2d!T(X*other.X, Y*other.Y);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const vector2d!T other)
			if(op == "*")
		{
			X*=other.X;
			Y*=other.Y;
			return this;
		}

		vector2d!T opBinary(string op)(const T v) const
			if(op == "*")
		{
			return vector2d!T(X*v, Y*v);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const T v)
			if(op == "*")
		{
			X*=v;
			Y*=v;
			return this;
		}

		vector2d!T opBinary(string op)(const vector2d!T other) const
			if(op == "/")
		{
			return vector2d!T(X/other.X, Y/other.Y);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const vector2d!T other)
			if(op == "/")
		{
			X/=other.X;
			Y/=other.Y;
			return this;
		}

		vector2d!T opBinary(string op)(const T v) const
			if(op == "/")
		{
			return vector2d!T(X/v, Y/v);
		}

		auto ref vector2d!T opOpAssign(string op)(auto ref const T v)
			if(op == "/")
		{
			X/=v;
			Y/=v;
			return this;
		}	
		
		/// sort in order X, Y. Equality with rounding tolerance.
		int opCmp()(auto ref const vector2d!T other) const
		{
			if ((X<other.X && X != other.X) ||
				(X != other.X && Y<other.Y && Y != other.Y))
			{
				return -1;
			}
			
			if ((X>other.X && X != other.X) ||
				(X == other.X && Y>other.Y && Y != other.Y))
			{
				return 1;
			} 

			return 0;
		}

		bool opEqual()(auto ref const vector2d!T other) const
		{
			return equals(other);
		}

		/// Checks if this vector equals ther other one.
		/**
		*	Takes floating point rounding errors into account.
		*	Params:
		*	other 	Vector to compare with.
		*
		*   Returns: True if the two vector are (almost) equal, else false.
		*/
		bool equals()(auto ref const vector2d!T other) const
		{
			return X == other.X && Y == other.Y;
		}

		auto ref vector2d!T set()(T nx, T ny)
		{
			X = nx;
			Y = ny; 
			return *this;
		}

		auto ref vector2d!T set()(auto ref const vector2d!T p)
		{
			x = p.X;
			y = p.Y;
			return this;
		}

		/// Gets the length of the vector.
		/**
		*	Returns: The length of the vector.
		*/
		T getLength() const
		{
			return cast(T)sqrt(cast(double)(X*X + Y*Y));
		}

		/// Get the squared length of this vector
		/**
		*	This is useful vecause it is much faster than getLength().
		*	Returns: The squared length of the vector.
		*/
		T getLengthSQ() const
		{
			return X*X + Y*Y;
		}

		/// Get the dot product of this vector with another.
		/**
		*	Params: 
		*	other 	Other vector to take dot product with.
		*
		*	Returns: The dot product of the two vectors.
		*/
		T dotProduct()(auto ref const vector2d!T other) const
		{
			return X*other.X + Y*other.Y;
		}

		/// Gets distance from another point.
		/**
		* Here, the vector is interpreted as a point in 2-dimensional space.
		* Params:
		* other 	Other vector to measure from.
		*
		* Returns: Distance from other point.
		*/
		T getDistanceFrom()(auto ref const vector2d!T other) const
		{
			return vector2d!T(X - other.X, Y - other.Y).getLength();
		}

		/// Returns squared distance from another point
		/**
		* Here, the vector is interpreted as a pint in 2-dimensional space.
		* Params:
		* other 	Other vector to measure from.
		*
		* Returns: Squared distance from other point.
		*/
		T getDistanceFromSQ()(auto ref const vector2d!T other) const
		{
			return vector2d!T(X - other.X, Y - other.Y).getLengthSQ();
		}

		/// Rotates the point anticlockwise around a center by an amount of degrees.
		/**
		* Params:
		* degrees 	Amount of degrees to rotate by, anticlockwise.
		*
		* Returns: This vector after transformation.
		*/
		auto ref vector2d!T rotateBy()(double degrees, auto ref const vector2d!T center = vector2d!T(0,0))
		{
			degrees *= 0.01745329252;
			immutable double cs = cast(double)cos(degrees);
			immutable double sn = cast(double)sin(degrees);

			X -= center.X;
			Y -= center.Y;

			set(cast(T)(X*cs - Y*sn), cast(T)(X*sn + Y*cs));

			X += center.X;
			Y += center.Y;
			return this;
		}

		/// Normalize the vector
		/**
		* The null vector is left untouched.
		* Returns: Reference to this vector, after normalization.
		*/
		auto ref vector2d!T normalize()
		{
			float length = cast(float)(X*X + Y*Y);
			if(length == 0)
				return this;

			length = 1/sqrt(length);

			X = cast(T)(X * length);
			Y = cast(T)(Y * length);
			return this;
		}

		private enum RADTODEG64 = 57.2957795;

		/// Calculates the angle of this vector in degrees in the trigonometric sense.
		/**
		* 0 is to the right (3 o'clock), values increase counter-clockwise.
		* This method has been suggested by Pr3t3nd3r.
		* Returns: a value between 0 and 360.
		*/
		double getAngleTrig() const
		{
			if (Y == 0)
				return X < 0 ? 180 : 0;
			else
			if (X == 0)
				return Y < 0 ? 270 : 90;

			if ( Y > 0 )
				if (X > 0)
					return atan(cast(double)Y/cast(double)X) * RADTODEG64;
				else
					return 180.0-atan(cast(double)Y/-cast(double)X) * RADTODEG64;
			else
				if (X > 0)
					return 360.0-atan(-cast(double)Y/cast(double)X) * RADTODEG64;
				else
					return 180.0-atan(-cast(double)Y/-cast(double)X) * RADTODEG64;
		}

		/// Calculates the angle or this vector in degrees in the counter trigonometric sense.
		/**
		* 0 is to the right (3 o'clock), values increase clockwise.
		* Returns: a value between 0 and 360.
		*/
		double getAngle() const
		{
			if (Y == 0) // corrected thanks to a suggestion by Jox
				return X < 0 ? 180 : 0;
			else if (X == 0)
				return Y < 0 ? 90 : 270;

			// don't use getLength her to avoid precision loss
			// avoid floating-point trouble as sqrt(y*y) is occasionally larger than y, so clamp
			immutable double tmp = clamp(cast(double)(Y / sqrt(cast(double)(X*X + Y*Y))), -1.0, 1.0);
			immutable double angle = cast(double)atan( sqrt(1 - tmp * tmp) / tmp) * RADTODEG64;

			if (X > 0 && Y > 0)
				return angle + 270;
			else
			if (X > 0 && Y < 0)
				return angle + 90;
			else
			if (X < 0 && Y < 0)
				return 90 - angle;
			else
			if (X < 0 && Y > 0)
				return 270 - angle;

			return angle;
		}

		/// Calculates the angle between this vector and antoer one in degree.
		/**
		* Params:
		* b 	Other vector to test with.
		* 
		* Returns: a value between 0 and 90.
		*/
		double getAngleWith()(auto ref const vector2d!T b) const
		{
			double tmp = cast(double)(X*b.X + Y*b.Y);

			if (tmp == 0.0)
				return 90.0;

			tmp = tmp / cast(double)sqrt(cast(double)((X*X+Y*Y) * (b.X*b.X+b.Y*b.Y)));
			if (tmp < 0.0)
				tmp = -tmp;
			if (tmp > 1.0) // avoid floating-point trouble
				tmp = 1.0;

			return cast(double)atan(sqrt(1 - tmp*tmp) / tmp) * RADTODEG64;
		}

		/// Returns if this vector interpreted as a poin is on a line between two other points.
		/**
		* It is assumed that the point is on the line
		* Params:
		* begin 	Beginning vector to compare between.
		* end 		Ending vector to compare between.
		* Returns: True if this vector is between begin and end, false if not.
		*/
		bool isBetweenPoints()(auto ref const vector2d!T begin, auto ref const vector2d!T end) const
		{
			if (begin.X != end.X)
			{
				return ((begin.X <= X && X <= end.X) ||
					(begin.X >= X && X >= end.X));
			}
			else
			{
				return ((begin.Y <= Y && Y <= end.Y) ||
					(begin.Y >= Y && Y >= end.Y));
			}
		}

		/// Creates an interpolated vector between this vector and another vector.
		/**
		* Params: 
		* other 	The other vector to interpolate with.
		* d 		Interpolation value between 0.0f (all the other vector) and 1.0f (all this vector).
		* 
		* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
		*
		* Returns: An interpolated vector.  This vector is not modified. 
		*/
		vector2d!T getInterpolated()(auto ref const vector2d!T other, double d) const
		{
			double inv = 1.0 - d;
			return vector2d!T(cast(T)(other.X*inv + X*d), cast(T)(other.Y*inv + Y*d));
		}

		/// Creates a quadratically interpolated vector between this and two other vectors.
		/**
		* Params: 
		* v2 	Second vector to interpolate with.
		* v3 	Third vector to interpolate with (maximum at 1.0f)
		* d 	Interpolation value between 0.0f (all this vector) and 1.0f (all the 3rd vector).
		* 
		* Note that this is the opposite direction of interpolation to getInterpolated() and interpolate()
		* Returns: An interpolated vector. This vector is not modified. 
		*/
		vector2d!T getInterpolated_quadratic()(auto ref const vector2d!T v2, auto ref const vector2d!T v3, double d) const
		{
			// this*(1-d)*(1-d) + 2 * v2 * (1-d) + v3 * d * d;
			immutable double inv = 1.0 - d;
			immutable double mul0 = inv * inv;
			immutable double mul1 = 2.0 * d * inv;
			immutable double mul2 = d * d;

			return vector2d!T( cast(T)(X * mul0 + v2.X * mul1 + v3.X * mul2),
				cast(T)(Y * mul0 + v2.Y * mul1 + v3.Y * mul2));
		}

		/// Sets this vector to the linearly interpolated vector between a and b.
		/**
		* Params:
		* a first vector to interpolate with, maximum at 1.0f
		* b second vector to interpolate with, maximum at 0.0f
		* d Interpolation value between 0.0f (all vector b) and 1.0f (all vector a)
		*
		* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
		*/
		auto ref vector2d!T interpolate()(auto ref const vector2d!T a, auto ref const vector2d!T b, double d)
		{
			X = cast(T)(cast(double)b.X + ( (a.X - b.X) * d ));
			Y = cast(T)(cast(double)b.Y + ( (a.Y - b.Y) * d ));
			return this;
		}

		/// X coordinate of vector;
		T X;

		/// Y coordinate of vector;
		T Y;

		vector2d!T opBinaryRight(string op)(const T scalar) const
			if(op == "*")
		{
			return this*scalar;
		}
	}
}

/// Alias fo float 2d vector 
alias vector2d!float vector2df;

/// Alias for integer 2d vector 
alias vector2d!int vector2di;
