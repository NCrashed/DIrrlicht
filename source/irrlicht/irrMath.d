// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.irrMath;

import std.math;
import std.traits;

/// Constant for converting from degrees to radians
enum DEGTORAD = PI / 180.0;

/// constant for converting from radians to degrees (formally known as GRAD_PI)
enum RADTODEG = 180.0 / PI;

static int   F32_AS_S32(float f)				{return (*(cast(int  *) &(f)));}
static uint  F32_AS_U32(float f)				{return (*(cast(uint *) &(f)));}
static uint* F32_AS_U32_POINTER(ref float f)	{return ( (cast(uint *) &(f)));}

enum F32_VALUE_0 =			0x00000000;
enum F32_VALUE_1 =			0x3f800000;
enum F32_SIGN_BIT =			0x80000000U;
enum F32_EXPON_MANTISSA =	0x7FFFFFFFU;


static bool	F32_LOWER_0(float f)			{return (F32_AS_U32(f) >  F32_SIGN_BIT);}
static bool	F32_LOWER_EQUAL_0(float f)		{return (F32_AS_S32(f) <= F32_VALUE_0);}
static bool	F32_GREATER_0(float f)			{return (F32_AS_S32(f) >  F32_VALUE_0);}
static bool	F32_GREATER_EQUAL_0(float f)	{return (F32_AS_U32(f) <= F32_SIGN_BIT);}
static bool	F32_EQUAL_1(float f)			{return (F32_AS_U32(f) == F32_VALUE_1);}
static bool	F32_EQUAL_0(float f)			{return ( (F32_AS_U32(f) & F32_EXPON_MANTISSA ) == F32_VALUE_0);}

// only same sign
static bool	F32_A_GREATER_B(float a, float b)	{return (F32_AS_S32((a)) > F32_AS_S32((b)));}

/// returns if a equals zero, taking rounding errors into account
bool iszero(T)(const T a, const T tolerance = T.epsilon)
	if(isFloatingPoint!T)
{
	return approxEqual(a, 0.0, tolerance);
}

/// returns if a equals zero, taking rounding errors into account
bool iszero(T)(const T a, const T tolerance = 0)
	if(isIntegral!T && isUnsigned!T)
{
	return a <= tolerance;
}

/// returns if a equals zero, taking rounding errors into account
bool iszero(T)(const T a, const T tolerance = 0)
	if(isIntegral!T && !isUnsigned!T)
{
	static if(is(T == int))
		return ( a & 0x7ffffff ) <= tolerance;
	else
		return fabs(a) <= tolerance;
}

T clamp(T)(inout(T) val, inout(T) minv, inout(T) maxv)
{
	return cast(T)fmax(fmin(val, maxv), minv);
}

private union inttofloat
{
	uint u;
	int s;
	float f;
}

static uint IR(float x)
{
	inttofloat tmp; 
	tmp.f=x; 
	return tmp.u;
}

static float FR(T)(T x)
	if(isIntegral!T)
{
	inttofloat tmp;
	tmp.u = x;
	return tmp.f;
}