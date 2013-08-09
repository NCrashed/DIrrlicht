// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.SMaterialLayer;

import irrlicht.core.matrix4;
import irrlicht.core.irrAllocator;
import irrlicht.video.ITexture;
import std.bitmanip;

/// Texture coord clamp mode outside [0.0, 1.0]
enum E_TEXTURE_CLAMP
{
	/// Texture repeats
	ETC_REPEAT = 0,
	/// Texture is clamped to the last pixel
	ETC_CLAMP,
	/// Texture is clamped to the edge pixel
	ETC_CLAMP_TO_EDGE,
	/// Texture is clamped to the border pixel (if exists)
	ETC_CLAMP_TO_BORDER,
	/// Texture is alternatingly mirrored (0..1..0..1..0..)
	ETC_MIRROR,
	/// Texture is mirrored once and then clamped (0..1..0)
	ETC_MIRROR_CLAMP,
	/// Texture is mirrored once and then clamped to edge
	ETC_MIRROR_CLAMP_TO_EDGE,
	/// Texture is mirrored once and then clamped to border
	ETC_MIRROR_CLAMP_TO_BORDER
};

immutable(string[]) aTextureClampNames = 
[
	"texture_clamp_repeat",
	"texture_clamp_clamp",
	"texture_clamp_clamp_to_edge",
	"texture_clamp_clamp_to_border",
	"texture_clamp_mirror",
	"texture_clamp_mirror_clamp",
	"texture_clamp_mirror_clamp_to_edge",
	"texture_clamp_mirror_clamp_to_border",
];

/// Struct for holding material parameters which exist per texture layer
class SMaterialLayer
{
	/// Default constructor
	this() pure
	{
		Texture = null;
		TextureWrapU = E_TEXTURE_CLAMP.ETC_REPEAT;
		TextureWrapV = E_TEXTURE_CLAMP.ETC_REPEAT;
		BilinearFilter = true;
		TrilinearFilter = false;
		AnisotropicFilter = 0;
		LODBias = 0;
		TextureMatrix = matrix4(matrix4.eConstructor.EM4CONST_IDENTITY);
	}

	/// Copy constructor
	/**
	* Params:
	* 	other=  Material layer to copy from. 
	*/
	this(const SMaterialLayer other) pure
	{
		Texture = cast(ITexture)other.Texture;
		TextureWrapU = other.TextureWrapU;
		TextureWrapV = other.TextureWrapV;
		BilinearFilter = other.BilinearFilter;
		TrilinearFilter = other.TrilinearFilter;
		AnisotropicFilter = other.AnisotropicFilter;
		LODBias = other.LODBias;		
		// This pointer is checked during assignment
		TextureMatrix = other.TextureMatrix;
	}

	/// Assignment operator
	/**
	* Params:
	* 	other=  Material layer to copy from.
	* Returns: This material layer, updated. 
	*/
	SMaterialLayer set(const SMaterialLayer other)
	{
		// Check for self-assignment!
		if (this == other)
			return this;

		Texture = cast(ITexture)other.Texture;
		TextureMatrix = other.TextureMatrix;
		TextureWrapU = other.TextureWrapU;
		TextureWrapV = other.TextureWrapV;
		BilinearFilter = other.BilinearFilter;
		TrilinearFilter = other.TrilinearFilter;
		AnisotropicFilter = other.AnisotropicFilter;
		LODBias = other.LODBias;

		return this;
	}

	/// Gets the immutable texture transformation matrix
	/**
	* Returns: Texture matrix of this layer. 
	*/
	auto ref const matrix4 getTextureMatrix() const
	{
		return TextureMatrix;
	}

	/// Sets the texture transformation matrix to mat
	/**
	* Params:
	* 	mat=  New texture matrix for this layer. 
	*/
	void setTextureMatrix()(auto ref const matrix4 mat)
	{
		TextureMatrix = mat;
	}

	/// Equality operator
	/**
	* Params:
	* 	b=  Layer to compare to.
	* Returns: True if layers are not different, else false. 
	*/
	bool opEqual(const SMaterialLayer b) const
	{
		bool different =
			Texture != b.Texture ||
			TextureWrapU != b.TextureWrapU ||
			TextureWrapV != b.TextureWrapV ||
			BilinearFilter != b.BilinearFilter ||
			TrilinearFilter != b.TrilinearFilter ||
			AnisotropicFilter != b.AnisotropicFilter ||
			LODBias != b.LODBias;
		if (different)
			return false;
		else
			different |= (TextureMatrix != b.TextureMatrix);
		return !different;
	}

	/// Texture
	ITexture Texture;

	/// Texture Clamp Mode
	/**
	* TextureWrapU and TextureWrapV: Values are taken from E_TEXTURE_CLAMP. 
	* BilinearFilter: Is bilinear filtering enabled? Default: true
	* TrilinearFilter: Is trilinear filtering enabled? Default: false
	* If the trilinear filter flag is enabled,
	* the bilinear filtering flag is ignored.
	*/
	mixin(bitfields!( 
		ubyte, "TextureWrapU",    4, 
		ubyte, "TextureWrapV",    4, 
		bool,  "BilinearFilter",  1, 
		bool,  "TrilinearFilter", 1,
		uint,  "",                6,
	));

	/// Is anisotropic filtering enabled? Default: 0, disabled
	/**
	* In Irrlicht you can use anisotropic texture filtering
	* in conjunction with bilinear or trilinear texture
	* filtering to improve rendering results. Primitives
	* will look less blurry with this flag switched on. The number gives 
	* the maximal anisotropy degree, and is often in the range 2-16. 
	* Value 1 is equivalent to 0, but should be avoided. 
	*/
	ubyte AnisotropicFilter;

	/// Bias for the mipmap choosing decision.
	/**
	* This value can make the textures more or less blurry than with the
	* default value of 0. The value (divided by 8.f) is added to the mipmap level
	* chosen initially, and thus takes a smaller mipmap for a region
	* if the value is positive. 
	*/
	byte LODBias;

	/// Texture Matrix
	/**
	* Do not access this element directly as the internal
	* ressource management has to cope with Null pointers etc. 
	*/
	package matrix4 TextureMatrix;
};
