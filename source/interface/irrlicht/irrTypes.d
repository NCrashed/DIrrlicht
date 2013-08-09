// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.irrTypes;

//! creates four CC codes used in Irrlicht for simple ids
static uint MAKE_IRR_ID(ubyte c0, ubyte c1, ubyte c2, ubyte c3)
{
	return cast(uint)c0 | (cast(uint)c1 << 8) | 
		(cast(uint)c2 << 16) | (cast(uint)c3 << 24);
}

enum _IRR_MATERIAL_MAX_TEXTURES_ = 10;
enum IRRLICHT_SDK_VERSION = "1.8";