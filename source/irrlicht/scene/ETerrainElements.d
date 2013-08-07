// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ETerrainElements;

/// enumeration for patch sizes specifying the size of patches in the TerrainSceneNode
enum E_TERRAIN_PATCH_SIZE
{
	/// patch size of 9, at most, use 4 levels of detail with this patch size.
	ETPS_9 = 9,

	/// patch size of 17, at most, use 5 levels of detail with this patch size.
	ETPS_17 = 17,

	/// patch size of 33, at most, use 6 levels of detail with this patch size.
	ETPS_33 = 33,

	/// patch size of 65, at most, use 7 levels of detail with this patch size.
	ETPS_65 = 65,

	/// patch size of 129, at most, use 8 levels of detail with this patch size.
	ETPS_129 = 129
};