// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.matrix4;

import std.math;
//import std.regex;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.core.plane3d;
import irrlicht.core.aabbox3d;
import irrlicht.core.rect;
import irrlicht.irrMath;

// enable this to keep track of changes to the matrix
// and make simpler identity check for seldomly changing matrices
// otherwise identity check will always compare the elements
private enum USE_MATRIX_TEST = true;

/// 4x4 matrix. Mostly used as transformation matrix for 3d calculations.
/** 
* The matrix is a D3D style matrix, row major with translations in the 4th row. 
*/
struct CMatrix4(T)
{
	/// Constructor flags
	enum eConstructor
	{
		EM4CONST_NOTHING = 0,
		EM4CONST_COPY,
		EM4CONST_IDENTITY,
		EM4CONST_TRANSPOSED,
		EM4CONST_INVERSE,
		EM4CONST_INVERSE_TRANSPOSED
	}

	/// Default constructor
	/** 
	* Params:
	* constructor = Choose the initialization style 
	*/
	this()( eConstructor constructor = eConstructor.EM4CONST_IDENTITY )
	{
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix = false;

		switch(constructor)
		{
			case eConstructor.EM4CONST_NOTHING:
			case eConstructor.EM4CONST_COPY:
				break;
			case eConstructor.EM4CONST_IDENTITY:
			case eConstructor.EM4CONST_INVERSE:
			default:
				makeIdentity();
				break;
		}
	}
	
	/// Copy constructor
	/** 
	* Params:
	* other = Other matrix to copy from
	* constructor = Choose the initialization style 
	*/
	this()(auto ref const CMatrix4!T other, eConstructor constructor = eConstructor.EM4CONST_COPY)
	{
		static if(USE_MATRIX_TEST)
		{
			definitelyIdentityMatrix = false;
		}

		final switch(constructor)
		{
			case eConstructor.EM4CONST_IDENTITY:
				makeIdentity();
				break;
			case eConstructor.EM4CONST_NOTHING:
				break;
			case eConstructor.EM4CONST_COPY:
				this = other;
				goto case eConstructor.EM4CONST_TRANSPOSED;
			case eConstructor.EM4CONST_TRANSPOSED:
				other.getTransposed(this);
				break;
			case eConstructor.EM4CONST_INVERSE_TRANSPOSED:
				goto case eConstructor.EM4CONST_INVERSE;
			case eConstructor.EM4CONST_INVERSE:
				if (!other.getInverse(this))
					M[] = 0;
				else
					this = getTransposed();
				break;
		}
	}

	this(this)
	{
		M[] = M.dup[];
	}

	/// Simple operator for directly accessing every element of the matrix.
	ref T opApply()(const size_t row, const size_t col)
	{
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix=false;

		return M[ row * 4 + col ];
	}

	/// Simple operator for directly accessing every element of the matrix.
	T opIndex()(const size_t row, const size_t col) const
	{
		return M[ row * 4 + col ];
	}

	/// Simple operator for linearly accessing every element of the matrix.
	T opIndex()(const size_t index) const 
	{
		return M[index];
	}

	void opIndexAssign()(const T value, const size_t row, const size_t col)
	{
		M[ row * 4 + col ] = value;
	}

	void opIndexAssign()(const T value, const size_t index)
	{
		M[index] = value;
	}

	/// Sets this matrix equal to the other matrix.
	auto ref CMatrix4!T opAssign()(auto ref const CMatrix4!T other)
	{
		if (this == other)
			return this;

		M[] = other.M[];
		
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = other.definitelyIdentityMatrix;

		return this;
	}

	/// Sets all elements of this matrix to the value.
	auto ref CMatrix4!T opAssign()(auto ref const T scalar)
	{
		for (uint i = 0; i < 16; ++i)
			M[i]=scalar;

		static if ( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return *this;
	}

	/// Returns pointer to internal array
	const T[16] pointer() 
	{
		return M;
	}

	/// Returns pointer to internal array
	T[16] pointer()
	{
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix=false;

		return M;
	}

	/// Returns true if other matrix is equal to this matrix.
	bool opEqual()(auto ref const CMatrix4!T other)
	{
		static if ( USE_MATRIX_TEST )
		{
			if (definitelyIdentityMatrix && other.definitelyIdentityMatrix)
				return true;
		}

		for (uint i = 0; i < 16; ++i)
			if (M[i] != other.M[i])
				return false;

		return true;
	}

	CMatrix4!T opBinary(string op)(auto ref const CMatrix4!T other)
		if(op == "+" || op == "-")
	{
		CMatrix4!T temp = CMatrix4!T(eConstructor.EM4CONST_NOTHING);

		enum com = regex("?", "g");

		mixin(replace(q{temp[0] = M[0]+other[0];
		temp[1] = M[1] ? other[1];
		temp[2] = M[2] ? other[2];
		temp[3] = M[3] ? other[3];
		temp[4] = M[4] ? other[4];
		temp[5] = M[5] ? other[5];
		temp[6] = M[6] ? other[6];
		temp[7] = M[7] ? other[7];
		temp[8] = M[8] ? other[8];
		temp[9] = M[9] ? other[9];
		temp[10] = M[10] ? other[10];
		temp[11] = M[11] ? other[11];
		temp[12] = M[12] ? other[12];
		temp[13] = M[13] ? other[13];
		temp[14] = M[14] ? other[14];
		temp[15] = M[15] ? other[15];}, com, op));

		return temp;
	}

	auto ref CMatrix4!T opOpAssign(string op)(auto ref const CMatrix4!T other)
		if(op == "+" || op == "-")
	{
		enum com = regex("?", "g");

		mixin(replace(q{M[0] ?= other[0];
		M[1] ?= other[1];
		M[2] ?= other[2];
		M[3] ?= other[3];
		M[4] ?= other[4];
		M[5] ?= other[5];
		M[6] ?= other[6];
		M[7] ?= other[7];
		M[8] ?= other[8];
		M[9] ?= other[9];
		M[10] ?= other[10];
		M[11] ?= other[11];
		M[12] ?= other[12];
		M[13] ?= other[13];
		M[14] ?= other[14];
		M[15] ?= other[15];}, com, op));

		return this;
	}

	/// Set this matrix to the product of two matrices
	/** 
	* Calculate b*a 
	*/
	auto ref CMatrix4!T setbyproduct()(auto ref const CMatrix4!T other_a, auto ref const CMatrix4!T other_b)
	{
		static if(USE_MATRIX_TEST)
		{
			if ( other_a.isIdentity () )
				return (this = other_b);
			else
			if ( other_b.isIdentity () )
				return (this = other_a);
			else
				return setbyproduct_nocheck(other_a,other_b);
		}
		else
		{
			return setbyproduct_nocheck(other_a,other_b);
		}
	}

	/// Set this matrix to the product of two matrices
	/** 
	* Calculate b*a, no optimization used,
	* use it if you know you never have a identity matrix 
	* goal is to reduce stack use and copy
	*/
	auto ref CMatrix4!T setbyproduct_nocheck()(auto ref const CMatrix4!T other_a, auto ref const CMatrix4!T other_b)
	{
		immutable T[16] m1 = other_a.M;
		immutable T[16] m2 = other_b.M;

		M[0] = m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3];
		M[1] = m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3];
		M[2] = m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3];
		M[3] = m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3];

		M[4] = m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7];
		M[5] = m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7];
		M[6] = m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7];
		M[7] = m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7];

		M[8] = m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11];
		M[9] = m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11];
		M[10] = m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11];
		M[11] = m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11];

		M[12] = m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15];
		M[13] = m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15];
		M[14] = m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15];
		M[15] = m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15];

		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Multiply by another matrix.
	/** 
	* Calculate other*this 
	*/
	CMatrix4!T opBinary(string op)(auto ref const CMatrix4!T m2)
		if(op == "*")
	{
		static if(USE_MATRIX_TEST)
		{
			// Testing purpose..
			if ( this.isIdentity() )
				return m2;
			if ( m2.isIdentity() )
				return this;
		}

		CMatrix4!T m3 = CMatrix4!T( eConstructor.EM4CONST_NOTHING );

		immutable T[16] m1 = M;

		m3[0] = m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3];
		m3[1] = m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3];
		m3[2] = m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3];
		m3[3] = m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3];

		m3[4] = m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7];
		m3[5] = m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7];
		m3[6] = m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7];
		m3[7] = m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7];

		m3[8] = m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11];
		m3[9] = m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11];
		m3[10] = m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11];
		m3[11] = m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11];

		m3[12] = m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15];
		m3[13] = m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15];
		m3[14] = m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15];
		m3[15] = m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15];
		
		return m3;
	}

	/// Multiply by another matrix.
	/** 
	* Calculate and return other*this 
	*/
	auto ref CMatrix4!T opOpAssign(string op)(auto ref const CMatrix4!T other)
		if(op == "*")
	{
		static if(USE_MATRIX_TEST)
		{
			// do checks on your own in order to avoid copy creation
			if ( !other.isIdentity() )
			{
				if ( this.isIdentity() )
				{
					return (this = other);
				}
				else
				{
					CMatrix4!T temp = CMatrix4!T(this);
					return setbyproduct_nocheck( temp, other );
				}
			}
			return this;
		} 
		else
		{
			CMatrix4!T temp = CMatrix4!T(this);
			return setbyproduct_nocheck( temp, other );
		}
	}

	/// Multiply by scalar.
	CMatrix4!T opBinary(string op)(auto ref const T scalar)
		if(op == "*")
	{
		CMatrix4!T temp = CMatrix4!T( eConstructor.EM4CONST_NOTHING );

		temp[0] = M[0]*scalar;
		temp[1] = M[1]*scalar;
		temp[2] = M[2]*scalar;
		temp[3] = M[3]*scalar;
		temp[4] = M[4]*scalar;
		temp[5] = M[5]*scalar;
		temp[6] = M[6]*scalar;
		temp[7] = M[7]*scalar;
		temp[8] = M[8]*scalar;
		temp[9] = M[9]*scalar;
		temp[10] = M[10]*scalar;
		temp[11] = M[11]*scalar;
		temp[12] = M[12]*scalar;
		temp[13] = M[13]*scalar;
		temp[14] = M[14]*scalar;
		temp[15] = M[15]*scalar;

		return temp;
	}

	CMatrix4!T opBinaryRight(string op)(auto ref const T scalar)
		if(op == "+" || op == "-")
	{
		return this*scalar;
	}
	
	/// Multiply by scalar.
	auto ref CMatrix4!T opOpAssign(string op)(auto ref const T scalar)
		if(op == "*")
	{
		M[0]*=scalar;
		M[1]*=scalar;
		M[2]*=scalar;
		M[3]*=scalar;
		M[4]*=scalar;
		M[5]*=scalar;
		M[6]*=scalar;
		M[7]*=scalar;
		M[8]*=scalar;
		M[9]*=scalar;
		M[10]*=scalar;
		M[11]*=scalar;
		M[12]*=scalar;
		M[13]*=scalar;
		M[14]*=scalar;
		M[15]*=scalar;

		return this;
	}

	/// Set matrix to identity
	auto ref CMatrix4!T makeIdentity()
	{
		M[] = 0;
		M[0] = M[5] = M[10] = M[15] = cast(T)1;
		
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix = true;

		return this;
	}

	/// Returns true if the matrix is the identity matrix
	bool isIdentity() const
	{
		static if( USE_MATRIX_TEST )
		{
			if (definitelyIdentityMatrix)
				return true;
		}

		if (!approxEqual( M[12], cast(T)0 ) || !approxEqual( M[13], cast(T)0 ) || !approxEqual( M[14], cast(T)0 ) || !approxEqual( M[15], cast(T)1 ))
			return false;

		if (!approxEqual( M[ 0], cast(T)1 ) || !approxEqual( M[ 1], cast(T)0 ) || !approxEqual( M[ 2], cast(T)0 ) || !approxEqual( M[ 3], cast(T)0 ))
			return false;

		if (!approxEqual( M[ 4], cast(T)0 ) || !approxEqual( M[ 5], cast(T)1 ) || !approxEqual( M[ 6], cast(T)0 ) || !approxEqual( M[ 7], cast(T)0 ))
			return false;

		if (!approxEqual( M[ 8], cast(T)0 ) || !approxEqual( M[ 9], cast(T)0 ) || !approxEqual( M[10], cast(T)1 ) || !approxEqual( M[11], cast(T)0 ))
			return false;

		static if( USE_MATRIX_TEST )
			*cast(bool*)&definitelyIdentityMatrix = true;

		return true;
	}

	/// Returns true if the matrix is orthogonal
	bool isOrthogonal()
	{
		T dp=M[0] * M[4 ] + M[1] * M[5 ] + M[2 ] * M[6 ] + M[3 ] * M[7 ];
		if (!iszero(dp))
			return false;
		dp = M[0] * M[8 ] + M[1] * M[9 ] + M[2 ] * M[10] + M[3 ] * M[11];
		if (!iszero(dp))
			return false;
		dp = M[0] * M[12] + M[1] * M[13] + M[2 ] * M[14] + M[3 ] * M[15];
		if (!iszero(dp))
			return false;
		dp = M[4] * M[8 ] + M[5] * M[9 ] + M[6 ] * M[10] + M[7 ] * M[11];
		if (!iszero(dp))
			return false;
		dp = M[4] * M[12] + M[5] * M[13] + M[6 ] * M[14] + M[7 ] * M[15];
		if (!iszero(dp))
			return false;
		dp = M[8] * M[12] + M[9] * M[13] + M[10] * M[14] + M[11] * M[15];
		return (iszero(dp));
	}

	/// Returns true if the matrix is the identity matrix
	bool isIdentity_integer_base()
	{
		static if( USE_MATRIX_TEST )
		{
			if (definitelyIdentityMatrix)
				return true;
		}

		if(IR(M[0])!=F32_VALUE_1)	return false;
		if(IR(M[1])!=0)				return false;
		if(IR(M[2])!=0)				return false;
		if(IR(M[3])!=0)				return false;

		if(IR(M[4])!=0)				return false;
		if(IR(M[5])!=F32_VALUE_1)	return false;
		if(IR(M[6])!=0)				return false;
		if(IR(M[7])!=0)				return false;

		if(IR(M[8])!=0)				return false;
		if(IR(M[9])!=0)				return false;
		if(IR(M[10])!=F32_VALUE_1)	return false;
		if(IR(M[11])!=0)			return false;

		if(IR(M[12])!=0)			return false;
		if(IR(M[13])!=0)			return false;
		if(IR(M[13])!=0)			return false;
		if(IR(M[15])!=F32_VALUE_1)	return false;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=true;

		return true;
	}

	/// Set the translation of current matrix. Will erase any previous values.
	auto ref CMatrix4!T setTranslation()(auto ref const vector3d!T translation)
	{
		M[12] = translation.X;
		M[13] = translation.Y;
		M[14] = translation.Z;
		
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix = false;

		return this;
	}

	/// Gets the current translation
	vector3d!T getTranslation() const
	{
		return vector3d!T(M[12], M[13], M[14]);
	}

	/// Set the inverse translation of the current matrix. Will erase any previous values.
	auto ref CMatrix4!T setInverseTranslation()( auto ref const vector3d!T translation )
	{
		M[12] = -translation.X;
		M[13] = -translation.Y;
		M[14] = -translation.Z;
		
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix = false;

		return this;
	}

	/// Make a rotation matrix from Euler angles. The 4th row and column are unmodified.
	auto ref CMatrix4!T setRotationRadians()(auto ref const vector3d!T rotation )
	{
		immutable cr = cos( rotation.X );
		immutable sr = sin( rotation.X );
		immutable cp = cos( rotation.Y );
		immutable sp = sin( rotation.Y );
		immutable cy = cos( rotation.Z );
		immutable sy = sin( rotation.Z );

		M[0] = cast(T)( cp*cy );
		M[1] = cast(T)( cp*sy );
		M[2] = cast(T)( -sp );

		immutable srsp = sr*sp;
		immutable crsp = cr*sp;

		M[4] = cast(T)( srsp*cy-cr*sy );
		M[5] = cast(T)( srsp*sy+cr*cy );
		M[6] = cast(T)( sr*cp );

		M[8] = cast(T)( crsp*cy+sr*sy );
		M[9] = cast(T)( crsp*sy-sr*cy );
		M[10] = cast(T)( cr*cp );
		
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Make a rotation matrix from Euler angles. The 4th row and column are unmodified.
	auto ref CMatrix4!T setRotationDegrees()(auto ref const vector3d!T rotation )
	{
		return setRotationRadians( rotation * DEGTORAD );
	}

	/// Returns the rotation, as set by setRotation().
	/** 
	* This code was orginally written by by Chev. 
	* Note: that it does not necessarily return
	* the *same* Euler angles as those set by setRotationDegrees(), but the rotation will
	* be equivalent, i.e. will have the same result when used to rotate a vector or node.
	*/
	vector3d!T getRotationDegrees()
	{
		vector3d!T scale = getScale();
		// we need to check for negative scale on to axes, which would bring up wrong results
		if (scale.Y<0 && scale.Z<0)
		{
			scale.Y =-scale.Y;
			scale.Z =-scale.Z;
		}
		else if (scale.X<0 && scale.Z<0)
		{
			scale.X =-scale.X;
			scale.Z =-scale.Z;
		}
		else if (scale.X<0 && scale.Y<0)
		{
			scale.X =-scale.X;
			scale.Y =-scale.Y;
		}
		immutable vector3d!double invScale = vector3d!double(1.0/scale.X, 1.0/scale.Y, 1.0/scale.Z);

		double Y = -cast(double)asin(clamp(this[2]*invScale.X, -1.0, 1.0));
		immutable C = cos(Y);
		Y *= RADTODEG;

		double rotx, roty, X, Z;

		if (!iszero(C))
		{
			immutable invC = 1.0 / C;
			rotx = this[10] * invC * invScale.Z;
			roty = this[6] * invC * invScale.Y;
			X = cast(double)atan2( roty, rotx ) * RADTODEG;
			rotx = this[0] * invC * invScale.X;
			roty = this[1] * invC * invScale.X;
			Z = cast(double)atan2( roty, rotx ) * RADTODEG;
		}
		else
		{
			X = 0.0;
			rotx = this[5] * invScale.Y;
			roty = -this[4] * invScale.Y;
			Z = cast(double)atan2( roty, rotx ) * RADTODEG;
		}

		// fix values that get below zero
		if (X < 0.0) X += 360.0;
		if (Y < 0.0) Y += 360.0;
		if (Z < 0.0) Z += 360.0;

		return vector3d!T(cast(T)X,cast(T)Y,cast(T)Z);
	}

	/// Make an inverted rotation matrix from Euler angles.
	/** 
	* The 4th row and column are unmodified. 
	*/
	auto ref CMatrix4!T setInverseRotationRadians()(auto ref const vector3d!T rotation )
	{
		immutable cr = cos( rotation.X );
		immutable sr = sin( rotation.X );
		immutable cp = cos( rotation.Y );
		immutable sp = sin( rotation.Y );
		immutable cy = cos( rotation.Z );
		immutable sy = sin( rotation.Z );

		M[0] = cast(T)( cp*cy );
		M[4] = cast(T)( cp*sy );
		M[8] = cast(T)( -sp );

		immutable srsp = sr*sp;
		immutable crsp = cr*sp;

		M[1] = cast(T)( srsp*cy-cr*sy );
		M[5] = cast(T)( srsp*sy+cr*cy );
		M[9] = cast(T)( sr*cp );

		M[2] = cast(T)( crsp*cy+sr*sy );
		M[6] = cast(T)( crsp*sy-sr*cy );
		M[10] = cast(T)( cr*cp );
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Make an inverted rotation matrix from Euler angles.
	/** 
	* The 4th row and column are unmodified. 
	*/
	auto ref CMatrix4!T setInverseRotationDegrees()(auto ref const vector3d!T rotation )
	{
		return setInverseRotationRadians( rotation * DEGTORAD );
	}

	/// Make a rotation matrix from angle and axis, assuming left handed rotation.
	/** 
	* The 4th row and column are unmodified. 
	*/
	auto ref CMatrix4!T setRotationAxisRadians()(auto ref const T angle, auto ref const vector3d!T axis)
	{
 		immutable c = cos(angle);
		immutable s = sin(angle);
		immutable t = 1.0 - c;

		immutable tx  = t * axis.X;
		immutable ty  = t * axis.Y;		
		immutable tz  = t * axis.Z;

		immutable sx  = s * axis.X;
		immutable sy  = s * axis.Y;
		immutable sz  = s * axis.Z;
		
		M[0] = cast(T)(tx * axis.X + c);
		M[1] = cast(T)(tx * axis.Y + sz);
		M[2] = cast(T)(tx * axis.Z - sy);

		M[4] = cast(T)(ty * axis.X - sz);
		M[5] = cast(T)(ty * axis.Y + c);
		M[6] = cast(T)(ty * axis.Z + sx);

		M[8]  = cast(T)(tz * axis.X + sy);
		M[9]  = cast(T)(tz * axis.Y - sx);
		M[10] = cast(T)(tz * axis.Z + c);

		static if ( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Set Scale
	auto ref CMatrix4!T setScale()(auto ref const vector3d!T scale )
	{
		M[0] = scale.X;
		M[5] = scale.Y;
		M[10] = scale.Z;
		static if(USE_MATRIX_TEST)
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Set Scale
	auto ref CMatrix4!T setScale()( const T scale ) 
	{ 
		return setScale(vector3d!T(scale,scale,scale)); 
	}

	/// Get Scale
	/**
	* Note that this returns the absolute (positive) values unless only scale is set.
	* Unfortunately it does not appear to be possible to extract any original negative
	* values. The best that we could do would be to arbitrarily make one scale
	* negative if one or three of them were negative.
	* FIXME - return the original values.
	*/
	vector3d!T getScale()
	{
		// See http://www.robertblum.com/articles/2005/02/14/decomposing-matrices

		// Deal with the 0 rotation case first
		// Prior to Irrlicht 1.6, we always returned this value.
		if(iszero(M[1]) && iszero(M[2]) &&
			iszero(M[4]) && iszero(M[6]) &&
			iszero(M[8]) && iszero(M[9]))
		{
			return vector3d!T(M[0], M[5], M[10]);
		}

		// We have to do the full calculation.
		return vector3d!T(cast(T)sqrt(M[0] * M[0] + M[1] * M[1] + M[2] * M[2]),
							cast(T)sqrt(M[4] * M[4] + M[5] * M[5] + M[6] * M[6]),
							cast(T)sqrt(M[8] * M[8] + M[9] * M[9] + M[10] * M[10]));

	}

	/// Translate a vector by the inverse of the translation part of this matrix.
	void inverseTranslateVect()( out vector3df vect )
	{
		vect.X = vect.X-M[12];
		vect.Y = vect.Y-M[13];
		vect.Z = vect.Z-M[14];
	}

	/// Rotate a vector by the inverse of the rotation part of this matrix.
	void inverseRotateVect()( out vector3df vect )
	{
		vector3df tmp = vect;
		vect.X = tmp.X*M[0] + tmp.Y*M[1] + tmp.Z*M[2];
		vect.Y = tmp.X*M[4] + tmp.Y*M[5] + tmp.Z*M[6];
		vect.Z = tmp.X*M[8] + tmp.Y*M[9] + tmp.Z*M[10];
	}

	/// Rotate a vector by the rotation part of this matrix.
	void rotateVect()( out vector3df vect )
	{
		vector3df tmp = vect;
		vect.X = tmp.X*M[0] + tmp.Y*M[4] + tmp.Z*M[8];
		vect.Y = tmp.X*M[1] + tmp.Y*M[5] + tmp.Z*M[9];
		vect.Z = tmp.X*M[2] + tmp.Y*M[6] + tmp.Z*M[10];
	}

	/// An alternate transform vector method, writing into a second vector
	void rotateVect()(out vector3df outVec, auto ref const vector3df inVec)
	{
		outVec.X = inVec.X*M[0] + inVec.Y*M[4] + inVec.Z*M[8];
		outVec.Y = inVec.X*M[1] + inVec.Y*M[5] + inVec.Z*M[9];
		outVec.Z = inVec.X*M[2] + inVec.Y*M[6] + inVec.Z*M[10];
	}

	/// An alternate transform vector method, writing into an array of 3 floats
	void rotateVect()(out T[3] outVec, auto ref const vector3df inVec)
	{
		outVec.X = inVec.X*M[0] + inVec.Y*M[4] + inVec.Z*M[8];
		outVec.Y = inVec.X*M[1] + inVec.Y*M[5] + inVec.Z*M[9];
		outVec.Z = inVec.X*M[2] + inVec.Y*M[6] + inVec.Z*M[10];
	}

	/// Transforms the vector by this matrix
	void transformVect()(out vector3df vect)
	{
		float vector[3];

		vector[0] = vect.X*M[0] + vect.Y*M[4] + vect.Z*M[8] + M[12];
		vector[1] = vect.X*M[1] + vect.Y*M[5] + vect.Z*M[9] + M[13];
		vector[2] = vect.X*M[2] + vect.Y*M[6] + vect.Z*M[10] + M[14];

		vect.X = vector[0];
		vect.Y = vector[1];
		vect.Z = vector[2];
	}

	/// Transforms input vector by this matrix and stores result in output vector
	void transformVect()(out vector3df outVec, auto ref const vector3df inVec )
	{
		outVec.X = inVec.X*M[0] + inVec.Y*M[4] + inVec.Z*M[8] + M[12];
		outVec.Y = inVec.X*M[1] + inVec.Y*M[5] + inVec.Z*M[9] + M[13];
		outVec.Z = inVec.X*M[2] + inVec.Y*M[6] + inVec.Z*M[10] + M[14];
	}

	/// An alternate transform vector method, writing into an array of 4 floats
	void transformVect()(out T[4] outVec,auto ref const vector3df inVec)
	{
		outVec[0] = inVec.X*M[0] + inVec.Y*M[4] + inVec.Z*M[8] + M[12];
		outVec[1] = inVec.X*M[1] + inVec.Y*M[5] + inVec.Z*M[9] + M[13];
		outVec[2] = inVec.X*M[2] + inVec.Y*M[6] + inVec.Z*M[10] + M[14];
		outVec[3] = inVec.X*M[3] + inVec.Y*M[7] + inVec.Z*M[11] + M[15];
	}

	/// An alternate transform vector method, reading from and writing to an array of 3 floats
	void transformVec3()(out T[3] outVec, auto ref const(T[3]) inVec)
	{
		outVec[0] = inVec[0]*M[0] + inVec[1]*M[4] + inVec[2]*M[8] + M[12];
		outVec[1] = inVec[0]*M[1] + inVec[1]*M[5] + inVec[2]*M[9] + M[13];
		outVec[2] = inVec[0]*M[2] + inVec[1]*M[6] + inVec[2]*M[10] + M[14];
	}

	/// Translate a vector by the translation part of this matrix.
	void translateVect()( out vector3df vect )
	{
		vect.X = vect.X+M[12];
		vect.Y = vect.Y+M[13];
		vect.Z = vect.Z+M[14];
	}

	/// Transforms a plane by this matrix
	void transformPlane()( out plane3df plane)
	{
		vector3df member;
		// Transform the plane member point, i.e. rotate, translate and scale it.
		transformVect(member, plane.getMemberPoint());

		// Transform the normal by the transposed inverse of the matrix
		CMatrix4!T transposedInverse = CMatrix4!T(this, eConstructor.EM4CONST_INVERSE_TRANSPOSED);
		vector3df normal = plane.Normal;
		transposedInverse.transformVect(normal);

		plane.setPlane(member, normal);
	}

	/// Transforms a plane by this matrix
	void transformPlane()( auto ref const plane3df inPlane, out plane3df outPlane)
	{
		outPlane = inPlane;
		transformPlane( outPlane );
	}

	/// Transforms a axis aligned bounding box
	/** 
	* The result box of this operation may not be accurate at all. For
	* correct results, use transformBoxEx() 
	*/
	void transformBox()(out aabbox3df box)
	{
		static if ( USE_MATRIX_TEST )
		{
			if (isIdentity())
				return;
		}

		transformVect(box.MinEdge);
		transformVect(box.MaxEdge);
		box.repair();
	}

	/// Transforms a axis aligned bounding box
	/** 
	* The result box of this operation should by accurate, but this operation
	* is slower than transformBox(). 
	*/
	void transformBoxEx(out aabbox3df box)
	{
		static if ( USE_MATRIX_TEST )
		{
			if (isIdentity())
				return;
		}

		immutable float Amin[3] = [box.MinEdge.X, box.MinEdge.Y, box.MinEdge.Z];
		immutable float Amax[3] = [box.MaxEdge.X, box.MaxEdge.Y, box.MaxEdge.Z];

		float Bmin[3];
		float Bmax[3];

		Bmin[0] = Bmax[0] = M[12];
		Bmin[1] = Bmax[1] = M[13];
		Bmin[2] = Bmax[2] = M[14];

		for (uint i = 0; i < 3; ++i)
		{
			for (uint j = 0; j < 3; ++j)
			{
				immutable float a = this[j,i] * Amin[j];
				immutable float b = this[j,i] * Amax[j];

				if (a < b)
				{
					Bmin[i] += a;
					Bmax[i] += b;
				}
				else
				{
					Bmin[i] += b;
					Bmax[i] += a;
				}
			}
		}

		box.MinEdge.X = Bmin[0];
		box.MinEdge.Y = Bmin[1];
		box.MinEdge.Z = Bmin[2];

		box.MaxEdge.X = Bmax[0];
		box.MaxEdge.Y = Bmax[1];
		box.MaxEdge.Z = Bmax[2];
	}

	/// Multiplies this matrix by a 1x4 matrix
	void multiplyWith1x4Matrix(T[] matrix)
	in
	{
		assert(matrix.length >= 4);
	}
	body
	{
		/*
		0  1  2  3
		4  5  6  7
		8  9  10 11
		12 13 14 15
		*/

		T mat[4];
		mat[0] = matrix[0];
		mat[1] = matrix[1];
		mat[2] = matrix[2];
		mat[3] = matrix[3];

		matrix[0] = M[0]*mat[0] + M[4]*mat[1] + M[8]*mat[2] + M[12]*mat[3];
		matrix[1] = M[1]*mat[0] + M[5]*mat[1] + M[9]*mat[2] + M[13]*mat[3];
		matrix[2] = M[2]*mat[0] + M[6]*mat[1] + M[10]*mat[2] + M[14]*mat[3];
		matrix[3] = M[3]*mat[0] + M[7]*mat[1] + M[11]*mat[2] + M[15]*mat[3];
	}

	/// Calculates inverse of matrix. Slow.
	/** 
	* Returns: false if there is no inverse matrix.
	*/
	bool makeInverse()
	{
		static if( USE_MATRIX_TEST )
		{
			if (definitelyIdentityMatrix)
				return true;
		}

		CMatrix4!T temp = CMatrix4!T( eConstructor.EM4CONST_NOTHING );

		if (getInverse(temp))
		{
			this = temp;
			return true;
		}

		return false;
	}

	/// Inverts a primitive matrix which only contains a translation and a rotation
	/** 
	* Params:
	* outMatrix = where result matrix is written to. 
	*/
	bool getInversePrimitive(out CMatrix4!T outMatrix)
	{
		outMatrix.M[0 ] = M[0];
		outMatrix.M[1 ] = M[4];
		outMatrix.M[2 ] = M[8];
		outMatrix.M[3 ] = 0;

		outMatrix.M[4 ] = M[1];
		outMatrix.M[5 ] = M[5];
		outMatrix.M[6 ] = M[9];
		outMatrix.M[7 ] = 0;

		outMatrix.M[8 ] = M[2];
		outMatrix.M[9 ] = M[6];
		outMatrix.M[10] = M[10];
		outMatrix.M[11] = 0;

		outMatrix.M[12] = cast(T)-(M[12]*M[0] + M[13]*M[1] + M[14]*M[2]);
		outMatrix.M[13] = cast(T)-(M[12]*M[4] + M[13]*M[5] + M[14]*M[6]);
		outMatrix.M[14] = cast(T)-(M[12]*M[8] + M[13]*M[9] + M[14]*M[10]);
		outMatrix.M[15] = 1;

		static if ( USE_MATRIX_TEST )
			outMatrix.definitelyIdentityMatrix = definitelyIdentityMatrix;

		return true;
	}

	/// Gets the inversed matrix of this one
	/** 
	* Params:
	* outMatrix = where result matrix is written to.
	* 
	* Returns: false if there is no inverse matrix. 
	*/
	bool getInverse(out CMatrix4!T outMatrix) const
	{
		/// Calculates the inverse of this Matrix
		/// The inverse is calculated using Cramers rule.
		/// If no inverse exists then 'false' is returned.

		static if ( USE_MATRIX_TEST )
		{
			if ( this.isIdentity() )
			{
				outMatrix = this;
				return true;
			}
		}

		float d = (this[0, 0] * this[1, 1] - this[0, 1] * this[1, 0]) * (this[2, 2] * this[3, 3] - this[2, 3] * this[3, 2]) -
			(this[0, 0] * this[1, 2] - this[0, 2] * this[1, 0]) * (this[2, 1] * this[3, 3] - this[2, 3] * this[3, 1]) +
			(this[0, 0] * this[1, 3] - this[0, 3] * this[1, 0]) * (this[2, 1] * this[3, 2] - this[2, 2] * this[3, 1]) +
			(this[0, 1] * this[1, 2] - this[0, 2] * this[1, 1]) * (this[2, 0] * this[3, 3] - this[2, 3] * this[3, 0]) -
			(this[0, 1] * this[1, 3] - this[0, 3] * this[1, 1]) * (this[2, 0] * this[3, 2] - this[2, 2] * this[3, 0]) +
			(this[0, 2] * this[1, 3] - this[0, 3] * this[1, 2]) * (this[2, 0] * this[3, 1] - this[2, 1] * this[3, 0]);

		if( iszero ( d, float.epsilon ) )
			return false;

		d = 1.0 / d ;

		outMatrix[0, 0] = d * (this[1, 1] * (this[2, 2] * this[3, 3] - this[2, 3] * this[3, 2]) +
				 this[1, 2] * (this[2, 3] *  this[3, 1] - this[2, 1] * this[3, 3]) +
				 this[1, 3] * (this[2, 1] *  this[3, 2] - this[2, 2] * this[3, 1]));
		outMatrix[0, 1] = d * (this[2, 1] * (this[0, 2] * this[3, 3] - this[0, 3] * this[3, 2]) +
				 this[2, 2] * (this[0, 3] *  this[3, 1] - this[0, 1] * this[3, 3]) +
				 this[2, 3] * (this[0, 1] *  this[3, 2] - this[0, 2] * this[3, 1]));
		outMatrix[0, 2] = d * (this[3, 1] * (this[0, 2] * this[1, 3] - this[0, 3] * this[1, 2]) +
				 this[3, 2] * (this[0, 3] *  this[1, 1] - this[0, 1] * this[1, 3]) +
				 this[3, 3] * (this[0, 1] *  this[1, 2] - this[0, 2] * this[1, 1]));
		outMatrix[0, 3] = d * (this[0, 1] * (this[1, 3] * this[2, 2] - this[1, 2] * this[2, 3]) +
				 this[0, 2] * (this[1, 1] *  this[2, 3] - this[1, 3] * this[2, 1]) +
				 this[0, 3] * (this[1, 2] *  this[2, 1] - this[1, 1] * this[2, 2]));
		outMatrix[1, 0] = d * (this[1, 2] * (this[2, 0] * this[3, 3] - this[2, 3] * this[3, 0]) +
				 this[1, 3] * (this[2, 2] *  this[3, 0] - this[2, 0] * this[3, 2]) +
				 this[1, 0] * (this[2, 3] *  this[3, 2] - this[2, 2] * this[3, 3]));
		outMatrix[1, 1] = d * (this[2, 2] * (this[0, 0] * this[3, 3] - this[0, 3] * this[3, 0]) +
				 this[2, 3] * (this[0, 2] *  this[3, 0] - this[0, 0] * this[3, 2]) +
				 this[2, 0] * (this[0, 3] *  this[3, 2] - this[0, 2] * this[3, 3]));
		outMatrix[1, 2] = d * (this[3, 2] * (this[0, 0] * this[1, 3] - this[0, 3] * this[1, 0]) +
				 this[3, 3] * (this[0, 2] *  this[1, 0] - this[0, 0] * this[1, 2]) +
				 this[3, 0] * (this[0, 3] *  this[1, 2] - this[0, 2] * this[1, 3]));
		outMatrix[1, 3] = d * (this[0, 2] * (this[1, 3] * this[2, 0] - this[1, 0] * this[2, 3]) +
				 this[0, 3] * (this[1, 0] *  this[2, 2] - this[1, 2] * this[2, 0]) +
				 this[0, 0] * (this[1, 2] *  this[2, 3] - this[1, 3] * this[2, 2]));
		outMatrix[2, 0] = d * (this[1, 3] * (this[2, 0] * this[3, 1] - this[2, 1] * this[3, 0]) +
				 this[1, 0] * (this[2, 1] *  this[3, 3] - this[2, 3] * this[3, 1]) +
				 this[1, 1] * (this[2, 3] *  this[3, 0] - this[2, 0] * this[3, 3]));
		outMatrix[2, 1] = d * (this[2, 3] * (this[0, 0] * this[3, 1] - this[0, 1] * this[3, 0]) +
				 this[2, 0] * (this[0, 1] *  this[3, 3] - this[0, 3] * this[3, 1]) +
				 this[2, 1] * (this[0, 3] *  this[3, 0] - this[0, 0] * this[3, 3]));
		outMatrix[2, 2] = d * (this[3, 3] * (this[0, 0] * this[1, 1] - this[0, 1] * this[1, 0]) +
			 	 this[3, 0] * (this[0, 1] *  this[1, 3] - this[0, 3] * this[1, 1]) +
				 this[3, 1] * (this[0, 3] *  this[1, 0] - this[0, 0] * this[1, 3]));
		outMatrix[2, 3] = d * (this[0, 3] * (this[1, 1] * this[2, 0] - this[1, 0] * this[2, 1]) +
				 this[0, 0] * (this[1, 3] *  this[2, 1] - this[1, 1] * this[2, 3]) +
				 this[0, 1] * (this[1, 0] *  this[2, 3] - this[1, 3] * this[2, 0]));
		outMatrix[3, 0] = d * (this[1, 0] * (this[2, 2] * this[3, 1] - this[2, 1] * this[3, 2]) +
				 this[1, 1] * (this[2, 0] *  this[3, 2] - this[2, 2] * this[3, 0]) +
				 this[1, 2] * (this[2, 1] *  this[3, 0] - this[2, 0] * this[3, 1]));
		outMatrix[3, 1] = d * (this[2, 0] * (this[0, 2] * this[3, 1] - this[0, 1] * this[3, 2]) +
				 this[2, 1] * (this[0, 0] *  this[3, 2] - this[0, 2] * this[3, 0]) +
				 this[2, 2] * (this[0, 1] *  this[3, 0] - this[0, 0] * this[3, 1]));
		outMatrix[3, 2] = d * (this[3, 0] * (this[0, 2] * this[1, 1] - this[0, 1] * this[1, 2]) +
				 this[3, 1] * (this[0, 0] *  this[1, 2] - this[0, 2] * this[1, 0]) +
				 this[3, 2] * (this[0, 1] *  this[1, 0] - this[0, 0] * this[1, 1]));
		outMatrix[3, 3] = d * (this[0, 0] * (this[1, 1] * this[2, 2] - this[1, 2] * this[2, 1]) +
				 this[0, 1] * (this[1, 2] *  this[2, 0] - this[1, 0] * this[2, 2]) +
				 this[0, 2] * (this[1, 0] *  this[2, 1] - this[1, 1] * this[2, 0]));

		static if( USE_MATRIX_TEST )
			outMatrix.definitelyIdentityMatrix = definitelyIdentityMatrix;

		return true;
	}

	/// Builds a right-handed perspective projection matrix based on a field of view
	auto ref CMatrix4!T buildProjectionMatrixPerspectiveFovRH()(float fieldOfViewRadians, float aspectRatio, float zNear, float zFar)
	{
		immutable double h = 1.0 / (cast(double)tan(fieldOfViewRadians*0.5));
		assert(aspectRatio!=0.f); //divide by zero
		immutable T w = cast(T)(h / aspectRatio);

		assert(zNear!=zFar); //divide by zero
		M[0] = w;
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)h;
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(zFar/(zNear-zFar)); // DirectX version
//		M[10] = cast(T)(zFar+zNear/(zNear-zFar)); // OpenGL version
		M[11] = -1;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear*zFar/(zNear-zFar)); // DirectX version
//		M[14] = cast(T)(2.0f*zNear*zFar/(zNear-zFar)); // OpenGL version
		M[15] = 0;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed perspective projection matrix based on a field of view
	auto ref CMatrix4!T buildProjectionMatrixPerspectiveFovLH()(float fieldOfViewRadians, float aspectRatio, float zNear, float zFar)
	{
		immutable double h = 1.0 / (cast(double)tan(fieldOfViewRadians*0.5));
		assert(aspectRatio!=0.f); //divide by zero
		immutable T w = cast(T)(h / aspectRatio);

		assert(zNear!=zFar); //divide by zero
		M[0] = w;
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)h;
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(zFar/(zFar-zNear));
		M[11] = 1;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(-zNear*zFar/(zFar-zNear));
		M[15] = 0;

		static if ( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed perspective projection matrix based on a field of view, with far plane at infinity
	auto ref CMatrix4!T buildProjectionMatrixPerspectiveFovInfinityLH()(float fieldOfViewRadians, float aspectRatio, float zNear, float epsilon = 0.0f)
	{
		immutable double h = 1.0 / (cast(double)tan(fieldOfViewRadians*0.5));
		assert(aspectRatio!=0.f); //divide by zero
		immutable T w = cast(T)(h / aspectRatio);

		M[0] = w;
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)h;
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(1.f-epsilon);
		M[11] = 1;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear*(epsilon-1.f));
		M[15] = 0;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a right-handed perspective projection matrix.
	auto ref CMatrix4!T buildProjectionMatrixPerspectiveRH()(float widthOfViewVolume, float heightOfViewVolume, float zNear, float zFar)
	{
		assert(widthOfViewVolume!=0.f); //divide by zero
		assert(heightOfViewVolume!=0.f); //divide by zero
		assert(zNear!=zFar); //divide by zero

		M[0] = cast(T)(2*zNear/widthOfViewVolume);
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)(2*zNear/heightOfViewVolume);
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(zFar/(zNear-zFar));
		M[11] = -1;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear*zFar/(zNear-zFar));
		M[15] = 0;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed perspective projection matrix.
	auto ref CMatrix4!T buildProjectionMatrixPerspectiveLH()(float widthOfViewVolume, float heightOfViewVolume, float zNear, float zFar)
	{
		assert(widthOfViewVolume!=0.f); //divide by zero
		assert(heightOfViewVolume!=0.f); //divide by zero
		assert(zNear!=zFar); //divide by zero

		M[0] = cast(T)(2*zNear/widthOfViewVolume);
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)(2*zNear/heightOfViewVolume);
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(zFar/(zFar-zNear));
		M[11] = 1;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear*zFar/(zNear-zFar));
		M[15] = 0;
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed orthogonal projection matrix.
	auto ref CMatrix4!T buildProjectionMatrixOrthoLH()(float widthOfViewVolume, float heightOfViewVolume, float zNear, float zFar)
	{
		assert(widthOfViewVolume!=0.f); //divide by zero
		assert(heightOfViewVolume!=0.f); //divide by zero
		assert(zNear!=zFar); //divide by zero
		
		M[0] = cast(T)(2/widthOfViewVolume);
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)(2/heightOfViewVolume);
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(1/(zFar-zNear));
		M[11] = 0;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear/(zNear-zFar));
		M[15] = 1;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a right-handed orthogonal projection matrix.
	auto ref CMatrix4!T buildProjectionMatrixOrthoRH(float widthOfViewVolume, float heightOfViewVolume, float zNear, float zFar)
	{
		assert(widthOfViewVolume!=0.0f); //divide by zero
		assert(heightOfViewVolume!=0.0f); //divide by zero
		assert(zNear!=zFar); //divide by zero
		
		M[0] = cast(T)(2/widthOfViewVolume);
		M[1] = 0;
		M[2] = 0;
		M[3] = 0;

		M[4] = 0;
		M[5] = cast(T)(2/heightOfViewVolume);
		M[6] = 0;
		M[7] = 0;

		M[8] = 0;
		M[9] = 0;
		M[10] = cast(T)(1/(zNear-zFar));
		M[11] = 0;

		M[12] = 0;
		M[13] = 0;
		M[14] = cast(T)(zNear/(zNear-zFar));
		M[15] = 1;

		static if ( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed look-at matrix.
	auto ref CMatrix4!T buildCameraLookAtMatrixLH()(
			auto ref const vector3df position,
			const vector3df target,
			const vector3df upVector)
	{
		vector3df zaxis = target - position;
		zaxis.normalize();

		vector3df xaxis = upVector.crossProduct(zaxis);
		xaxis.normalize();

		vector3df yaxis = zaxis.crossProduct(xaxis);

		M[0] = cast(T)xaxis.X;
		M[1] = cast(T)yaxis.X;
		M[2] = cast(T)zaxis.X;
		M[3] = 0;

		M[4] = cast(T)xaxis.Y;
		M[5] = cast(T)yaxis.Y;
		M[6] = cast(T)zaxis.Y;
		M[7] = 0;

		M[8] = cast(T)xaxis.Z;
		M[9] = cast(T)yaxis.Z;
		M[10] = cast(T)zaxis.Z;
		M[11] = 0;

		M[12] = cast(T)-xaxis.dotProduct(position);
		M[13] = cast(T)-yaxis.dotProduct(position);
		M[14] = cast(T)-zaxis.dotProduct(position);
		M[15] = 1;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = false;

		return this;
	}

	/// Builds a right-handed look-at matrix.
	auto ref CMatrix4!T buildCameraLookAtMatrixRH()(
			auto ref const vector3df position,
			auto ref const vector3df target,
			auto ref const vector3df upVector)
	{
		vector3df zaxis = position - target;
		zaxis.normalize();

		vector3df xaxis = upVector.crossProduct(zaxis);
		xaxis.normalize();

		vector3df yaxis = zaxis.crossProduct(xaxis);

		M[0] = cast(T)xaxis.X;
		M[1] = cast(T)yaxis.X;
		M[2] = cast(T)zaxis.X;
		M[3] = 0;

		M[4] = cast(T)xaxis.Y;
		M[5] = cast(T)yaxis.Y;
		M[6] = cast(T)zaxis.Y;
		M[7] = 0;

		M[8] = cast(T)xaxis.Z;
		M[9] = cast(T)yaxis.Z;
		M[10] = cast(T)zaxis.Z;
		M[11] = 0;

		M[12] = cast(T)-xaxis.dotProduct(position);
		M[13] = cast(T)-yaxis.dotProduct(position);
		M[14] = cast(T)-zaxis.dotProduct(position);
		M[15] = 1;
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a matrix that flattens geometry into a plane.
	/** 
	* Params:
	* light = light source
	* plane = plane into which the geometry if flattened into
	* point = value between 0 and 1, describing the light source.
	* If this is 1, it is a point light, if it is 0, it is a directional light. 
	*/
	auto ref CMatrix4!T buildShadowMatrix()(auto ref const vector3df light, auto ref const plane3df plane, float point = 1.0f)
	{
		plane.Normal.normalize();
		immutable float d = plane.Normal.dotProduct(light);

		M[ 0] = cast(T)(-plane.Normal.X * light.X + d);
		M[ 1] = cast(T)(-plane.Normal.X * light.Y);
		M[ 2] = cast(T)(-plane.Normal.X * light.Z);
		M[ 3] = cast(T)(-plane.Normal.X * point);

		M[ 4] = cast(T)(-plane.Normal.Y * light.X);
		M[ 5] = cast(T)(-plane.Normal.Y * light.Y + d);
		M[ 6] = cast(T)(-plane.Normal.Y * light.Z);
		M[ 7] = cast(T)(-plane.Normal.Y * point);

		M[ 8] = cast(T)(-plane.Normal.Z * light.X);
		M[ 9] = cast(T)(-plane.Normal.Z * light.Y);
		M[10] = cast(T)(-plane.Normal.Z * light.Z + d);
		M[11] = cast(T)(-plane.Normal.Z * point);

		M[12] = cast(T)(-plane.D * light.X);
		M[13] = cast(T)(-plane.D * light.Y);
		M[14] = cast(T)(-plane.D * light.Z);
		M[15] = cast(T)(-plane.D * point + d);
	
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a left-handed look-at matrix.
	auto ref const CMatrix4!T buildCameraLookAtMatrixRH()(
		auto ref const vector3df position,
		auto ref const vector3df target,
		auto ref const vector3df upVector)
	{
		vector3df zaxis = target - position;
		zaxis.normalize();

		vector3df xaxis = upVector.crossProduct(zaxis);
		xaxis.normalize();

		vector3df yaxis = zaxis.crossProduct(xaxis);

		M[0] = cast(T)xaxis.X;
		M[1] = cast(T)yaxis.X;
		M[2] = cast(T)zaxis.X;
		M[3] = 0;

		M[4] = cast(T)xaxis.Y;
		M[5] = cast(T)yaxis.Y;
		M[6] = cast(T)zaxis.Y;
		M[7] = 0;

		M[8] = cast(T)xaxis.Z;
		M[9] = cast(T)yaxis.Z;
		M[10] = cast(T)zaxis.Z;
		M[11] = 0;

		M[12] = cast(T)-xaxis.dotProduct(position);
		M[13] = cast(T)-yaxis.dotProduct(position);
		M[14] = cast(T)-zaxis.dotProduct(position);
		M[15] = 1;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	auto ref CMatrix4!T buildCameraLookAtMatrixRH()(
		auto ref const vector3df position,
		auto ref const vector3df target,
		auto ref const vector3df upVector)
	{
		vector3df zaxis = position - target;
		zaxis.normalize();

		vector3df xaxis = upVector.crossProduct(zaxis);
		xaxis.normalize();

		vector3df yaxis = zaxis.crossProduct(xaxis);

		M[0] = cast(T)xaxis.X;
		M[1] = cast(T)yaxis.X;
		M[2] = cast(T)zaxis.X;
		M[3] = 0;

		M[4] = cast(T)xaxis.Y;
		M[5] = cast(T)yaxis.Y;
		M[6] = cast(T)zaxis.Y;
		M[7] = 0;

		M[8] = cast(T)xaxis.Z;
		M[9] = cast(T)yaxis.Z;
		M[10] = cast(T)zaxis.Z;
		M[11] = 0;

		M[12] = cast(T)-xaxis.dotProduct(position);
		M[13] = cast(T)-yaxis.dotProduct(position);
		M[14] = cast(T)-zaxis.dotProduct(position);
		M[15] = 1;

		static if ( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Builds a matrix which transforms a normalized Device Coordinate to Device Coordinates.
	/** 
	* Used to scale (-1,-1)(1,1) to viewport, for example from (-1,-1) (1,1) to the viewport (0,0)(0,640) 
	*/
	auto ref CMatrix4!T buildNDCToDCMatrix()(auto ref const rect!int viewport, float zScale)
	{
		immutable float scaleX = (viewport.getWidth() - 0.75f ) * 0.5f;
		immutable float scaleY = -(viewport.getHeight() - 0.75f ) * 0.5f;

		immutable float dx = -0.5f + ( (viewport.UpperLeftCorner.X + viewport.LowerRightCorner.X ) * 0.5f );
		immutable float dy = -0.5f + ( (viewport.UpperLeftCorner.Y + viewport.LowerRightCorner.Y ) * 0.5f );

		makeIdentity();
		M[12] = cast(T)dx;
		M[13] = cast(T)dy;
		return setScale(vector3d!T(cast(T)scaleX, cast(T)scaleY, cast(T)zScale));
	}

	/// Creates a new matrix as interpolated matrix from two other ones.
	/** 
	* Params:
	* b = other matrix to interpolate with
	* time = Must be a value between 0 and 1. 
	*/
	CMatrix4!T interpolate()(auto ref const CMatrix4!T b, float time)
	{
		CMatrix4!T mat = CMatrix4!T( eConstructor.EM4CONST_NOTHING );

		for (uint i=0; i < 16; i += 4)
		{
			mat.M[i+0] = cast(T)(M[i+0] + ( b.M[i+0] - M[i+0] ) * time);
			mat.M[i+1] = cast(T)(M[i+1] + ( b.M[i+1] - M[i+1] ) * time);
			mat.M[i+2] = cast(T)(M[i+2] + ( b.M[i+2] - M[i+2] ) * time);
			mat.M[i+3] = cast(T)(M[i+3] + ( b.M[i+3] - M[i+3] ) * time);
		}
		return mat;
	}

	/// Gets transposed matrix
	CMatrix4!T getTransposed() const
	{
		CMatrix4!T t = CMatrix4!T( eConstructor.EM4CONST_NOTHING );
		getTransposed ( t );
		return t;
	}

	/// Gets transposed matrix
	void getTransposed(out CMatrix4!T dest) const
	{
		dest[ 0] = M[ 0];
		dest[ 1] = M[ 4];
		dest[ 2] = M[ 8];
		dest[ 3] = M[12];

		dest[ 4] = M[ 1];
		dest[ 5] = M[ 5];
		dest[ 6] = M[ 9];
		dest[ 7] = M[13];

		dest[ 8] = M[ 2];
		dest[ 9] = M[ 6];
		dest[10] = M[10];
		dest[11] = M[14];

		dest[12] = M[ 3];
		dest[13] = M[ 7];
		dest[14] = M[11];
		dest[15] = M[15];

		static if( USE_MATRIX_TEST )
			dest.definitelyIdentityMatrix = definitelyIdentityMatrix;
	}

	/// Builds a matrix that rotates from one vector to another
	/**
	* Params: 
	* from = vector to rotate from
	* to = vector to rotate to
	*
	* See_Also: http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToMatrix/index.htm
	*/
	auto ref CMatrix4!T buildRotateFromTo()(auto ref const vector3df from, auto ref const vector3df to)
	{
		// unit vectors
		vector3df f = vector3df(from);
		vector3df t = vector3df(to);
		f.normalize();
		t.normalize();

		// axis multiplication by sin
		vector3df vs = vector3df(t.crossProduct(f));

		// axis of rotation
		vector3df v = vector3df(vs);
		v.normalize();

		// cosinus angle
		T ca = f.dotProduct(t);

		vector3df vt = vector3df(v * (1 - ca));

		M[0] = vt.X * v.X + ca;
		M[5] = vt.Y * v.Y + ca;
		M[10] = vt.Z * v.Z + ca;

		vt.X *= v.Y;
		vt.Z *= v.X;
		vt.Y *= v.Z;

		M[1] = vt.X - vs.Z;
		M[2] = vt.Z + vs.Y;
		M[3] = 0;

		M[4] = vt.X + vs.Z;
		M[6] = vt.Y - vs.X;
		M[7] = 0;

		M[8] = vt.Z - vs.Y;
		M[9] = vt.Y + vs.X;
		M[11] = 0;

		M[12] = 0;
		M[13] = 0;
		M[14] = 0;
		M[15] = 1;

		return this;
	}

	/// Builds a combined matrix which translates to a center before rotation and translates from origin afterwards
	/**
	* Params: 
	* center = Position to rotate around
	* translate = Translation applied after the rotation
	*/
	void setRotationCenter()(auto ref const vector3df center, auto ref const vector3df translate)
	{
		M[12] = -M[0]*center.X - M[4]*center.Y - M[8]*center.Z + (center.X - translation.X );
		M[13] = -M[1]*center.X - M[5]*center.Y - M[9]*center.Z + (center.Y - translation.Y );
		M[14] = -M[2]*center.X - M[6]*center.Y - M[10]*center.Z + (center.Z - translation.Z );
		M[15] = cast(T) 1.0;
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;
	}

	/// Builds a matrix which rotates a source vector to a look vector over an arbitrary axis
	/** 
	* Params:
	* camPos = viewer position in world coo
	* center = object position in world-coo and rotation pivot
	* translation = object final translation from center
	* axis = axis to rotate about
	* from = source vector to rotate from
	*/
	void buildAxisAlignedBillboard()(auto ref const vector3df camPos,
				auto ref const vector3df center,
				auto ref const vector3df translation,
				auto ref const vector3df axis,
				auto ref const vector3df from)
	{
		// axis of rotation
		vector3df up = axis;
		up.normalize();
		immutable vector3df forward = (camPos - center).normalize();
		immutable vector3df right = up.crossProduct(forward).normalize();

		// correct look vector
		immutable vector3df look = right.crossProduct(up);

		// rotate from to
		// axis multiplication by sin
		immutable vector3df vs = look.crossProduct(from);

		// cosinus angle
		immutable float ca = from.dotProduct(look);

		vector3df vt = vector3df(up * (1.f - ca));

		M[0] = cast(T)(vt.X * up.X + ca);
		M[5] = cast(T)(vt.Y * up.Y + ca);
		M[10] = cast(T)(vt.Z * up.Z + ca);

		vt.X *= up.Y;
		vt.Z *= up.X;
		vt.Y *= up.Z;

		M[1] = cast(T)(vt.X - vs.Z);
		M[2] = cast(T)(vt.Z + vs.Y);
		M[3] = 0;

		M[4] = cast(T)(vt.X + vs.Z);
		M[6] = cast(T)(vt.Y - vs.X);
		M[7] = 0;

		M[8] = cast(T)(vt.Z - vs.Y);
		M[9] = cast(T)(vt.Y + vs.X);
		M[11] = 0;

		setRotationCenter(center, translation);
	}


	/*
		construct 2D Texture transformations
		rotate about center, scale, and transform.
	*/

	/// Set to a texture transformation matrix with the given parameters.	
	auto ref CMatrix4!T buildTextureTransform()( float rotateRad,
			auto ref const vector2df rotatecenter,
			auto ref const vector2df translate,
			auto ref const vector2df scale)
	{
		immutable float c = cosf(rotateRad);
		immutable float s = sinf(rotateRad);

		M[0] = cast(T)(c * scale.X);
		M[1] = cast(T)(s * scale.Y);
		M[2] = 0;
		M[3] = 0;

		M[4] = cast(T)(-s * scale.X);
		M[5] = cast(T)(c * scale.Y);
		M[6] = 0;
		M[7] = 0;

		M[8] = cast(T)(c * scale.X * rotatecenter.X + -s * rotatecenter.Y + translate.X);
		M[9] = cast(T)(s * scale.Y * rotatecenter.X +  c * rotatecenter.Y + translate.Y);
		M[10] = 1;
		M[11] = 0;

		M[12] = 0;
		M[13] = 0;
		M[14] = 0;
		M[15] = 1;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Set texture transformation rotation
	/** 
	* Rotate about z axis, recenter at (0.5,0.5).
	* Doesn't clear other elements than those affected
	* Params:
	* rotateRad = Angle in radians
	* 
	* Returns: Altered matrix 
	*/
	auto ref CMatrix4!T setTextureRotationCenter()( float rotateRad )
	{
		immutable float c = cosf(rotateRad);
		immutable float s = sinf(rotateRad);
		M[0] = cast(T)c;
		M[1] = cast(T)s;

		M[4] = cast(T)-s;
		M[5] = cast(T)c;

		M[8] = cast(T)(0.5f * ( s - c) + 0.5f);
		M[9] = cast(T)(-0.5f * ( s + c) + 0.5f);

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = definitelyIdentityMatrix && (rotateRad==0.0f);

		return this;
	}

	/// Set texture transformation translation
	/**
	* Doesn't clear other elements than those affected.
	* Params:
	* x = Offset on x axis
	* y = Offset on y axis
	*
	* Returns: Altered matrix 
	*/
	auto ref CMatrix4!T setTextureTranslate()( float x, float y )
	{
		M[8] = cast(T)x;
		M[9] = cast(T)y;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = definitelyIdentityMatrix && (x==0.0f) && (y==0.0f);

		return this;
	}

	/// Set texture transformation translation, using a transposed representation
	/** 
	* Doesn't clear other elements than those affected.
	* Params:
	* x = Offset on x axis
	* y = Offset on y axis
	* 
	* Returns: Altered matrix 
	*/
	auto ref CMatrix4!T setTextureTranslateTransposed()( float x, float y )
	{
		M[2] = cast(T)x;
		M[6] = cast(T)y;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = definitelyIdentityMatrix && (x==0.0f) && (y==0.0f) ;

		return this;
	}

	/// Set texture transformation scale
	/** 
	* Doesn't clear other elements than those affected.
	* Params:
	* sx = Scale factor on x axis
	* sy = Scale factor on y axis
	*
	* Returns: Altered matrix. 
	*/
	auto ref CMatrix4!T setTextureScale()( float sx, float sy )
	{
		M[0] = cast(T)sx;
		M[5] = cast(T)sy;

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = definitelyIdentityMatrix && (sx==1.0f) && (sy==1.0f);

		return this;
	}

	/// Set texture transformation scale, and recenter at (0.5,0.5)
	/** 
	* Doesn't clear other elements than those affected.
	* Params:
	* sx = Scale factor on x axis
	* sy = Scale factor on y axis
	* 
	* Returns: Altered matrix. 
	*/
	auto ref CMatrix4!T setTextureScaleCenter()( float sx, float sy )
	{
		M[0] = cast(T)sx;
		M[5] = cast(T)sy;
		M[8] = cast(T)(0.5f - 0.5f * sx);
		M[9] = cast(T)(0.5f - 0.5f * sy);

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = definitelyIdentityMatrix && (sx==1.0f) && (sy==1.0f);

		return this;
	}

	/// Sets all matrix data members at once
	auto ref CMatrix4!T setM(const T[16] data)
	{
		M[] = data[];

		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix=false;

		return this;
	}

	/// Sets if the matrix is definitely identity matrix
	void setDefinitelyIdentityMatrix(bool isDefinitelyIdentityMatrix)
	{
		static if( USE_MATRIX_TEST )
			definitelyIdentityMatrix = isDefinitelyIdentityMatrix;
	}

	/// Gets if the matrix is definitely identity matrix
	bool getDefinitelyIdentityMatrix()
	{
		static if( USE_MATRIX_TEST )
			return definitelyIdentityMatrix;
		else
			return false;
	}

	/// Compare two matrices using the equal method
	bool equals()(auto ref const CMatrix4!T other, const T tolerance = cast(T)double.epsilon)
	{
		static if( USE_MATRIX_TEST )
		{
			if (definitelyIdentityMatrix && other.definitelyIdentityMatrix)
				return true;
		}

		for (uint i = 0; i < 16; ++i)
			if (!approxEqual(M[i], other.M[i], tolerance))
				return false;

		return true;
	}

	private
	{
		/// Matrix data, strored in row-major order
		T[16] M;

		static if(USE_MATRIX_TEST)
		{
			/// Flag is this matrix is identity matrix
			bool definitelyIdentityMatrix;
		}
	}
}

/// Alias for float matrix
alias CMatrix4!float matrix4;

/// Global const identity matrix
export immutable matrix4 IdentityMatrix = matrix4(matrix4.eConstructor.EM4CONST_IDENTITY);