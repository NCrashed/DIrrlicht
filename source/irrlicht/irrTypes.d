// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.irrTypes;

//! creates four CC codes used in Irrlicht for simple ids
static uint MAKE_IRR_ID(ubyte c0, ubyte c1, ubyte c2, ubyte c3)
{
	return cast(uint)c0 | (cast(uint)c1 << 8) | 
		(cast(uint)c2 << 16) | (cast(uint)c3 << 24);
}