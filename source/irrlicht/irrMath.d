// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.irrMath;

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
