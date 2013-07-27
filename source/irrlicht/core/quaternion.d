// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.core.quaternion;

import irrlicht.irrMath;
import irrlicht.core.matrix4;
import irrlicht.core.vector3d;
import std.math;

/// Quaternion class for representing rotations.
/**
* It provides cheap combinations and avoids gimbal locks.
* Also useful for interpolations. 
*/
struct quaternion 
{
	/// Constructor
	this()(float x, float y, float z, float w) pure
	{
		X = x;
		Y = y;
		Z = z;
		W = w;
	}

	/// Constructor which converts euler angles (radians) to a quaternion
	this()(float x, float y, float z) pure
	{
		set(x, y, z);
	}

	/// Constructor which converts euler angles (radians) to a quaternion
	this()(auto ref const vector3df vec) pure
	{
		set(vec.X, vec.Y, vec.Z);
	}

	/// Constructor which converts a matrix to a quaternion
	this()(auto ref const matrix4 mat) pure
	{
		opAssign(mat);
	}

	/// Equalilty operator
	bool opEqual()(auto ref const quaternion other) const
	{
		return (approxEqual(X, other.X) &&
			approxEqual(Y, other.Y) &&
			approxEqual(Z, other.Z) &&
			approxEqual(W, other.W));
	}

	/// Assignment operator
	auto ref quaternion opAssign()(auto ref const quaternion other)
	{
		X = other.X;
		Y = other.Y;
		Z = other.Z;
		W = other.W;
		return this;
	}

	/// Matrix assignment operator
	auto ref quaternion opAssign()(auto ref const matrix4 other)
	{
		immutable float diag = m[0] + m[5] + m[10] + 1;

		if( diag > 0.0f )
		{
			immutable float scale = cast(float)(sqrt(diag) * 2.0f); // get scale from diagonal

			// TODO: speed this up
			X = (m[6] - m[9]) / scale;
			Y = (m[8] - m[2]) / scale;
			Z = (m[1] - m[4]) / scale;
			W = 0.25f * scale;
		}
		else
		{
			if (m[0]>m[5] && m[0]>m[10])
			{
				// 1st element of diag is greatest value
				// find scale according to 1st element, and double it
				immutable float scale = cast(float)(sqrt(1.0f + m[0] - m[5] - m[10]) * 2.0f);

				// TODO: speed this up
				X = 0.25f * scale;
				Y = (m[4] + m[1]) / scale;
				Z = (m[2] + m[8]) / scale;
				W = (m[6] - m[9]) / scale;
			}
			else if (m[5]>m[10])
			{
				// 2nd element of diag is greatest value
				// find scale according to 2nd element, and double it
				immutable float scale = cast(float)(sqrt(1.0f + m[5] - m[0] - m[10]) * 2.0f);

				// TODO: speed this up
				X = (m[4] + m[1]) / scale;
				Y = 0.25f * scale;
				Z = (m[9] + m[6]) / scale;
				W = (m[8] - m[2]) / scale;
			}
			else
			{
				// 3rd element of diag is greatest value
				// find scale according to 3rd element, and double it
				immutable float scale = cast(float)(sqrt(1.0f + m[10] - m[0] - m[5]) * 2.0f);

				// TODO: speed this up
				X = (m[8] + m[2]) / scale;
				Y = (m[9] + m[6]) / scale;
				Z = 0.25f * scale;
				W = (m[1] - m[4]) / scale;
			}
		}

		return normalize();
	}

	/// Add operator
	quaternion opBinary(string op)(auto ref const quaternion other) const
		if(op == "+" || op == "-")
	{
		return quaternion(mixin("X"~op~"other.X"), mixin("Y"~op~"other.Y"), mixin("Z"~op~"other.Z"));
	}

	/// Multiplication operator
	quaternion opBinary(string op)(auto ref const quaternion other) const
		if(op == "*")
	{
		quaternion tmp;

		tmp.W = (other.W * W) - (other.X * X) - (other.Y * Y) - (other.Z * Z);
		tmp.X = (other.W * X) + (other.X * W) + (other.Y * Z) - (other.Z * Y);
		tmp.Y = (other.W * Y) + (other.Y * W) + (other.Z * X) - (other.X * Z);
		tmp.Z = (other.W * Z) + (other.Z * W) + (other.X * Y) - (other.Y * X);

		return tmp;
	}

	/// Multiplication operator with scalar
	quaternion opBinary(string op)(float s) const
		if(op == "*")
	{
		return quaternion(s*X, s*Y, s*Z, s*W);
	}

	/// Multiplication operator with scalar
	auto ref quaternion opOpAssign(string op)(float s)
		if(op == "*")
	{
		X*=s;
		Y*=s;
		Z*=s;
		W*=s;
		return this;	
	}

	/// Multiplication operator
	vector3df opBinary(string op)(auto ref const vector3df v) const
		if(op == "*")
	{
		// nVidia SDK implementation
		vector3df uv, uuv;
		auto qvec = vector3df(X, Y, Z);
		uv = qvec.crossProduct(v);
		uuv = qvec.crossProduct(uv);
		uv *= (2.0f * W);
		uuv *= 2.0f;

		return v + uv + uuv;
	}

	/// Multiplication operator
	auto ref quaternion opOpAssign(string op)(auto ref const quaternion other)
		if(op == "*")
	{
		return this = (other * this);
	}

	/// Calculates the dot product
	float dotProduct()(auto ref const quaternion other) const
	{
		return (X * q2.X) + (Y * q2.Y) + (Z * q2.Z) + (W * q2.W);
	}

	/// Sets new quaternion
	auto ref quaternion set()(float x, float y, float z, float w)
	{
		X = x;
		Y = y;
		Z = z;
		W = w;
		return this;
	}

	/// Sets new quaternion based on euler angles (radians)
	auto ref quaternion set()(float x, float y, float z)
	{
		double angle;

		angle = x * 0.5;
		immutable sr = sin(angle);
		immutable cr = cos(angle);

		angle = y * 0.5;
		immutable sp = sin(angle);
		immutable cp = cos(angle);

		angle = z * 0.5;
		immutable sy = sin(angle);
		immutable cy = cos(angle);

		immutable cpcy = cp * cy;
		immutable spcy = sp * cy;
		immutable cpsy = cp * sy;
		immutable spsy = sp * sy;

		X = cast(float)(sr * cpcy - cr * spsy);
		Y = cast(float)(cr * spcy + sr * cpsy);
		Z = cast(float)(cr * cpsy - sr * spcy);
		W = cast(float)(cr * cpcy + sr * spsy);

		return normalize();		
	}

	/// Sets new quaternion based on euler angles (radians)
	auto ref quaternion set()(auto ref const vector3df vec)
	{
		return set(vec.X, vec.Y, vec.Z);
	}

	/// Sets new quaternion from other quaternion
	auto ref quaternion set()(auto ref const quaternion quat)
	{
		return (this = quat);
	}

	/// returns if this quaternion equals the other one, taking floating point rounding errors into account
	bool equals()(auto ref const quaternion other,
			const float tolerance = float.epsilon ) const
	{
		return (approxEqual(X, other.X) &&
			approxEqual(Y, other.Y) &&
			approxEqual(Z, other.Z) &&
			approxEqual(W, other.W));
	}

	/// Normalizes the quaternion
	auto ref quaternion normalize()
	{
		immutable n = X*X + Y*Y + Z*Z + W*W;

		if (n == 1)
			return this;

		//n = 1.0f / sqrtf(n);
		return (this *= cast(float)(1.0 / sqrt( n )));
	}

	/// Creates a matrix from this quaternion
	matrix4 getMatrix()() const
	{
		matrix4 m;
		getMatrix(m);
		return m;
	}

	/// Creates a matrix from this quaternion
	void getMatrix()(out matrix4 dest, 
		auto ref vector3df translation) const
	{
		dest[0] = 1.0f - 2.0f*Y*Y - 2.0f*Z*Z;
		dest[1] = 2.0f*X*Y + 2.0f*Z*W;
		dest[2] = 2.0f*X*Z - 2.0f*Y*W;
		dest[3] = 0.0f;

		dest[4] = 2.0f*X*Y - 2.0f*Z*W;
		dest[5] = 1.0f - 2.0f*X*X - 2.0f*Z*Z;
		dest[6] = 2.0f*Z*Y + 2.0f*X*W;
		dest[7] = 0.0f;

		dest[8] = 2.0f*X*Z + 2.0f*Y*W;
		dest[9] = 2.0f*Z*Y - 2.0f*X*W;
		dest[10] = 1.0f - 2.0f*X*X - 2.0f*Y*Y;
		dest[11] = 0.0f;

		dest[12] = center.X;
		dest[13] = center.Y;
		dest[14] = center.Z;
		dest[15] = 1.f;

		dest.setDefinitelyIdentityMatrix( false );
	}

	/**
	* Creates a matrix from this quaternion
	* Rotate about a center point
	* shortcut for:
	* Examples:
	* ------
	* quaternion q;
	* q.rotationFromTo( vin[i].Normal, forward );
	* q.getMatrixCenter( lookat, center, newPos );
	* matrix4 m2;
	* m2.setInverseTranslation ( center );
	* lookat *= m2;
	* matrix4 m3;
	* m2.setTranslation ( newPos );
	* lookat *= m3;
	* ------
	*/
	void getMatrixCenter()(out matrix4 dest, 
		auto ref const vector3df center, 
		auto ref const vector3df translation ) const
	{
		dest[0] = 1.0f - 2.0f*Y*Y - 2.0f*Z*Z;
		dest[1] = 2.0f*X*Y + 2.0f*Z*W;
		dest[2] = 2.0f*X*Z - 2.0f*Y*W;
		dest[3] = 0.0f;

		dest[4] = 2.0f*X*Y - 2.0f*Z*W;
		dest[5] = 1.0f - 2.0f*X*X - 2.0f*Z*Z;
		dest[6] = 2.0f*Z*Y + 2.0f*X*W;
		dest[7] = 0.0f;

		dest[8] = 2.0f*X*Z + 2.0f*Y*W;
		dest[9] = 2.0f*Z*Y - 2.0f*X*W;
		dest[10] = 1.0f - 2.0f*X*X - 2.0f*Y*Y;
		dest[11] = 0.0f;

		dest.setRotationCenter( center, translation );
	}

	/// Creates a matrix from this quaternion
	void getMatrix_transposed( out matrix4 dest ) const
	{
		dest[0] = 1.0f - 2.0f*Y*Y - 2.0f*Z*Z;
		dest[4] = 2.0f*X*Y + 2.0f*Z*W;
		dest[8] = 2.0f*X*Z - 2.0f*Y*W;
		dest[12] = 0.0f;

		dest[1] = 2.0f*X*Y - 2.0f*Z*W;
		dest[5] = 1.0f - 2.0f*X*X - 2.0f*Z*Z;
		dest[9] = 2.0f*Z*Y + 2.0f*X*W;
		dest[13] = 0.0f;

		dest[2] = 2.0f*X*Z + 2.0f*Y*W;
		dest[6] = 2.0f*Z*Y - 2.0f*X*W;
		dest[10] = 1.0f - 2.0f*X*X - 2.0f*Y*Y;
		dest[14] = 0.0f;

		dest[3] = 0.0f;
		dest[7] = 0.0f;
		dest[11] = 0.0f;
		dest[15] = 1.0f;

		dest.setDefinitelyIdentityMatrix(false);
	}

	/// Inverts this quaternion
	auto ref quaternion makeInverse()()
	{
		X = -X; Y = -Y; Z = -Z;
		return this;
	}

	/// Set this quaternion to the linear interpolation between two quaternions
	/**
	* Params:
	* 	q1=  First quaternion to be interpolated.
	* 	q2=  Second quaternion to be interpolated.
	* 	time=  Progress of interpolation. For time=0 the result is
	* q1, for time=1 the result is q2. Otherwise interpolation
	* between q1 and q2.
	*/
	auto ref quaternion lerp()(
		auto ref const quaternion q1, 
		auto ref const quaternion q2, float time)
	{
		immutable scale = 1.0f - time;
		return (this = (q1*scale) + (q2*time));
	}

	/// Set this quaternion to the result of the spherical interpolation between two quaternions
	/**
	* Params:
	* 	q1=  First quaternion to be interpolated.
	* 	q2=  Second quaternion to be interpolated.
	* 	time=  Progress of interpolation. For time=0 the result is
	* q1, for time=1 the result is q2. Otherwise interpolation
	* between q1 and q2.
	* 	threshold=  To avoid inaccuracies at the end (time=1) the
	* interpolation switches to linear interpolation at some point.
	* This value defines how much of the remaining interpolation will
	* be calculated with lerp. Everything from 1-threshold up will be
	* linear interpolation.
	*/
	auto ref quaternion slerp()(
		auto ref const quaternion q1, 
		auto ref const quaternion q2,
		float time, float threshold=0.05f)
	{
		float angle = q1.dotProduct(q2);

		// make sure we use the short rotation
		if (angle < 0.0f)
		{
			q1 *= -1.0f;
			angle *= -1.0f;
		}

		if (angle <= (1-threshold)) // spherical interpolation
		{
			immutable theta = acos(angle);
			immutable invsintheta = 1.0/(sin(theta));
			immutable scale = sin(theta * (1.0f-time)) * invsintheta;
			immutable invscale = sin(theta * time) * invsintheta;
			return (this = cast(float)((q1*scale) + (q2*invscale)));
		}
		else // linear interploation
			return lerp(q1,q2,time);
	}

	/// Create quaternion from rotation angle and rotation axis.
	/**
	* Axis must be unit length.
	* The quaternion representing the rotation is
	* q = cos(A/2)+sin(A/2)*(x*i+y*j+z*k).
	* Params:
	* 	angle=  Rotation Angle in radians.
	* 	axis=  Rotation axis. 
	*/
	auto ref quaternion fromAngleAxis()(float angle, auto ref const vector3df axis)
	{
		immutable fHalfAngle = 0.5f*angle;
		immutable fSin = sin(fHalfAngle);
		W = cast(float)cos(fHalfAngle);
		X = cast(float)fSin*axis.X;
		Y = cast(float)fSin*axis.Y;
		Z = cast(float)fSin*axis.Z;
		return this;
	}

	/// Fills an angle (radians) around an axis (unit vector)
	void toAngleAxis()(out float angle, 
		auto ref const vector3df axis) const
	{
		immutable float scale = sqrt(X*X + Y*Y + Z*Z);

		if (iszero(scale) || W > 1.0f || W < -1.0f)
		{
			angle = 0.0f;
			axis.X = 0.0f;
			axis.Y = 1.0f;
			axis.Z = 0.0f;
		}
		else
		{
			immutable float invscale = 1/scale;
			angle = cast(float)(2.0f * acos(W));
			axis.X = X * invscale;
			axis.Y = Y * invscale;
			axis.Z = Z * invscale;
		}
	}

	/// Output this quaternion to an euler angle (radians)
	void toEuler(out vector3df euler) const
	{
		immutable double sqw = W*W;
		immutable double sqx = X*X;
		immutable double sqy = Y*Y;
		immutable double sqz = Z*Z;
		immutable double test = 2.0 * (Y*W - X*Z);

		if (approxEqual(test, 1.0, 0.000001))
		{
			// heading = rotation about z-axis
			euler.Z = cast(float) (-2.0*atan2(X, W));
			// bank = rotation about x-axis
			euler.X = 0;
			// attitude = rotation about y-axis
			euler.Y = cast(float)(PI/2.0);
		}
		else if (approxEqual(test, -1.0, 0.000001))
		{
			// heading = rotation about z-axis
			euler.Z = cast(float)(2.0*atan2(X, W));
			// bank = rotation about x-axis
			euler.X = 0;
			// attitude = rotation about y-axis
			euler.Y = cast(float)(PI/-2.0);
		}
		else
		{
			// heading = rotation about z-axis
			euler.Z = cast(float)atan2(2.0 * (X*Y +Z*W),(sqx - sqy - sqz + sqw));
			// bank = rotation about x-axis
			euler.X = cast(float)atan2(2.0 * (Y*Z +X*W),(-sqx - sqy + sqz + sqw));
			// attitude = rotation about y-axis
			euler.Y = cast(float)asin( clamp(test, -1.0, 1.0) );
		}
	}

	/// Set quaternion to identity
	auto ref quaternion makeIdentity()
	{
		W = 1.0f;
		X = 0.0f;
		Y = 0.0f;
		Z = 0.0f;
		return this;		
	}

	/// Set quaternion to represent a rotation from one vector to another.
	auto ref quaternion rotationFromTo()(
		auto ref const vector3df from, 
		auto ref const vector3df to)
	{
		// Based on Stan Melax's article in Game Programming Gems
		// Copy, since cannot modify local
		vector3df v0 = from;
		vector3df v1 = to;
		v0.normalize();
		v1.normalize();

		immutable float d = v0.dotProduct(v1);
		if (d >= 1.0f) // If dot == 1, vectors are the same
		{
			return makeIdentity();
		}
		else if (d <= -1.0f) // exactly opposite
		{
			auto axis = vector3df(1.0f, 0.f, 0.f);
			axis = axis.crossProduct(v0);
			if (axis.getLength()==0)
			{
				axis.set(0.f,1.f,0.f);
				axis.crossProduct(v0);
			}
			// same as fromAngleAxis(core::PI, axis).normalize();
			return set(axis.X, axis.Y, axis.Z, 0).normalize();
		}

		immutable float s = sqrtf( (1+d)*2 ); // optimize inv_sqrt
		immutable float invs = 1.f / s;
		immutable vector3df c = v0.crossProduct(v1)*invs;
		return set(c.X, c.Y, c.Z, s * 0.5f).normalize();
	}

	/// Quaternion elements.
	float X = 0.0f; // vectorial (imaginary) part
	float Y = 0.0f;
	float Z = 0.0f;
	float W = 0.0f; // real part
}
