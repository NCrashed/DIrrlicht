// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.EHardwareBufferFlags;

enum E_HARDWARE_MAPPING
{
	/// Don't store on the hardware
	EHM_NEVER=0,

	/// Rarely changed, usually stored completely on the hardware
	EHM_STATIC,

	/// Sometimes changed, driver optimized placement
	EHM_DYNAMIC,

	/// Always changed, cache optimizing on the GPU
	EHM_STREAM
};

enum E_BUFFER_TYPE
{
	/// Does not change anything
	EBT_NONE=0,
	/// Change the vertex mapping
	EBT_VERTEX,
	/// Change the index mapping
	EBT_INDEX,
	/// Change both vertex and index mapping to the same value
	EBT_VERTEX_AND_INDEX
};