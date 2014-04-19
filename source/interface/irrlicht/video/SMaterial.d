// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.SMaterial;

import irrlicht.video.SColor;
import irrlicht.core.matrix4;
import irrlicht.core.irrArray;
import irrlicht.video.EMaterialTypes;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.SMaterialLayer;
import irrlicht.video.ITexture;
import irrlicht.irrMath;
import irrlicht.irrTypes;
import std.bitmanip;

/// Flag for EMT_ONETEXTURE_BLEND, ( BlendFactor ) BlendFunc = source * sourceFactor + dest * destFactor
enum E_BLEND_FACTOR : uint 
{
	EBF_ZERO	= 0,			///< src & dest	(0, 0, 0, 0)
	EBF_ONE,					///< src & dest	(1, 1, 1, 1)
	EBF_DST_COLOR, 				///< src	(destR, destG, destB, destA)
	EBF_ONE_MINUS_DST_COLOR,	///< src	(1-destR, 1-destG, 1-destB, 1-destA)
	EBF_SRC_COLOR,				///< dest	(srcR, srcG, srcB, srcA)
	EBF_ONE_MINUS_SRC_COLOR, 	///< dest	(1-srcR, 1-srcG, 1-srcB, 1-srcA)
	EBF_SRC_ALPHA,				///< src & dest	(srcA, srcA, srcA, srcA)
	EBF_ONE_MINUS_SRC_ALPHA,	///< src & dest	(1-srcA, 1-srcA, 1-srcA, 1-srcA)
	EBF_DST_ALPHA,				///< src & dest	(destA, destA, destA, destA)
	EBF_ONE_MINUS_DST_ALPHA,	///< src & dest	(1-destA, 1-destA, 1-destA, 1-destA)
	EBF_SRC_ALPHA_SATURATE		///< src	(min(srcA, 1-destA), idem, ...)
}

/// Values defining the blend operation used when blend is enabled
enum E_BLEND_OPERATION : uint
{
	EBO_NONE = 0,	///< No blending happens
	EBO_ADD,		///< Default blending adds the color values
	EBO_SUBTRACT,	///< This mode subtracts the color values
	EBO_REVSUBTRACT,///< This modes subtracts destination from source
	EBO_MIN,		///< Choose minimum value of each color channel
	EBO_MAX,		///< Choose maximum value of each color channel
	EBO_MIN_FACTOR,	///< Choose minimum value of each color channel after applying blend factors, not widely supported
	EBO_MAX_FACTOR,	///< Choose maximum value of each color channel after applying blend factors, not widely supported
	EBO_MIN_ALPHA,	///< Choose minimum value of each color channel based on alpha value, not widely supported
	EBO_MAX_ALPHA	///< Choose maximum value of each color channel based on alpha value, not widely supported
};

/// MaterialTypeParam: e.g. DirectX: D3DTOP_MODULATE, D3DTOP_MODULATE2X, D3DTOP_MODULATE4X
enum E_MODULATE_FUNC : uint
{
	EMFN_MODULATE_1X	= 1,
	EMFN_MODULATE_2X	= 2,
	EMFN_MODULATE_4X	= 4
};

/// Comparison function, e.g. for depth buffer test
enum E_COMPARISON_FUNC : uint
{
	/// Test never succeeds, this equals disable
	ECFN_NEVER=0,
	/// <= test, default for e.g. depth test
	ECFN_LESSEQUAL=1,
	/// Exact equality
	ECFN_EQUAL=2,
	/// exclusive less comparison, i.e. <
	ECFN_LESS,
	/// Succeeds almost always, except for exact equality
	ECFN_NOTEQUAL,
	/// >= test
	ECFN_GREATEREQUAL,
	/// inverse of <=
	ECFN_GREATER,
	/// test succeeds always
	ECFN_ALWAYS
};

/// Enum values for enabling/disabling color planes for rendering
enum E_COLOR_PLANE : uint
{
	/// No color enabled
	ECP_NONE=0,
	/// Alpha enabled
	ECP_ALPHA=1,
	/// Red enabled
	ECP_RED=2,
	/// Green enabled
	ECP_GREEN=4,
	/// Blue enabled
	ECP_BLUE=8,
	/// All colors, no alpha
	ECP_RGB=14,
	/// All planes enabled
	ECP_ALL=15
};

/// Source of the alpha value to take
/**
* This is currently only supported in EMT_ONETEXTURE_BLEND. You can use an
* or'ed combination of values. Alpha values are modulated (multiplicated). 
*/
enum E_ALPHA_SOURCE : uint
{
	/// Use no alpha, somewhat redundant with other settings
	EAS_NONE=0,
	/// Use vertex color alpha
	EAS_VERTEX_COLOR,
	/// Use texture alpha channel
	EAS_TEXTURE
};

/// EMT_ONETEXTURE_BLEND: pack srcFact, dstFact, Modulate and alpha source to MaterialTypeParam
/**
* alpha source can be an OR'ed combination of E_ALPHA_SOURCE values. 
*/
float pack_textureBlendFunc ( const E_BLEND_FACTOR srcFact, const E_BLEND_FACTOR dstFact, const E_MODULATE_FUNC modulate = E_MODULATE_FUNC.EMFN_MODULATE_1X, const E_ALPHA_SOURCE alphaSource = E_ALPHA_SOURCE.EAS_TEXTURE )
{
	const uint tmp = (alphaSource << 12) | (modulate << 8) | (srcFact << 4) | dstFact;
	return FR(tmp);
}

/// EMT_ONETEXTURE_BLEND: unpack srcFact & dstFact and Modulo to MaterialTypeParam
/**
* The fields don't use the full byte range, so we could pack even more... 
*/
void unpack_textureBlendFunc ( out E_BLEND_FACTOR srcFact, out E_BLEND_FACTOR dstFact,
		out E_MODULATE_FUNC modulo, out uint alphaSource, const float param )
{
	immutable uint state = IR(param);
	alphaSource = (state & 0x0000F000) >> 12;
	modulo	= cast(E_MODULATE_FUNC)( ( state & 0x00000F00 ) >> 8 );
	srcFact = cast(E_BLEND_FACTOR)( ( state & 0x000000F0 ) >> 4 );
	dstFact = cast(E_BLEND_FACTOR)( ( state & 0x0000000F ) );
}

/// EMT_ONETEXTURE_BLEND: has BlendFactor Alphablending
bool textureBlendFunc_hasAlpha ( const E_BLEND_FACTOR factor )
{
	switch ( factor )
	{
		case E_BLEND_FACTOR.EBF_SRC_ALPHA:
		case E_BLEND_FACTOR.EBF_ONE_MINUS_SRC_ALPHA:
		case E_BLEND_FACTOR.EBF_DST_ALPHA:
		case E_BLEND_FACTOR.EBF_ONE_MINUS_DST_ALPHA:
		case E_BLEND_FACTOR.EBF_SRC_ALPHA_SATURATE:
			return true;
		default:
			return false;
	}
}


/// These flags are used to specify the anti-aliasing and smoothing modes
/**
* Techniques supported are multisampling, geometry smoothing, and alpha
* to coverage.
* Some drivers don't support a per-material setting of the anti-aliasing
* modes. In those cases, FSAA/multisampling is defined by the device mode
* chosen upon creation via irr::SIrrCreationParameters.
*/
enum E_ANTI_ALIASING_MODE
{
	/// Use to turn off anti-aliasing for this material
	EAAM_OFF=0,
	/// Default anti-aliasing mode
	EAAM_SIMPLE=1,
	/// High-quality anti-aliasing, not always supported, automatically enables SIMPLE mode
	EAAM_QUALITY=3,
	/// Line smoothing
	EAAM_LINE_SMOOTH=4,
	/// point smoothing, often in software and slow, only with OpenGL
	EAAM_POINT_SMOOTH=8,
	/// All typical anti-alias and smooth modes
	EAAM_FULL_BASIC=15,
	/// Enhanced anti-aliasing for transparent materials
	/**
	* Usually used with EMT_TRANSPARENT_ALPHA_REF and multisampling. 
	*/
	EAAM_ALPHA_TO_COVERAGE=16
};

/// These flags allow to define the interpretation of vertex color when lighting is enabled
/**
* Without lighting being enabled the vertex color is the only value defining the fragment color.
* Once lighting is enabled, the four values for diffuse, ambient, emissive, and specular take over.
* With these flags it is possible to define which lighting factor shall be defined by the vertex color
* instead of the lighting factor which is the same for all faces of that material.
* The default is to use vertex color for the diffuse value, another pretty common value is to use
* vertex color for both diffuse and ambient factor. 
*/
enum E_COLOR_MATERIAL
{
	/// Don't use vertex color for lighting
	ECM_NONE=0,
	/// Use vertex color for diffuse light, this is default
	ECM_DIFFUSE,
	/// Use vertex color for ambient light
	ECM_AMBIENT,
	/// Use vertex color for emissive light
	ECM_EMISSIVE,
	/// Use vertex color for specular light
	ECM_SPECULAR,
	/// Use vertex color for both diffuse and ambient light
	ECM_DIFFUSE_AND_AMBIENT
};

/// Flags for the definition of the polygon offset feature
/**
* These flags define whether the offset should be into the screen, or towards the eye. 
*/
enum E_POLYGON_OFFSET : ubyte
{
	/// Push pixel towards the far plane, away from the eye
	/**
	* This is typically used for rendering inner areas. 
	*/
	EPO_BACK=0,
	/// Pull pixels towards the camera.
	/**
	* This is typically used for polygons which should appear on top
	* of other elements, such as decals. 
	*/
	EPO_FRONT=1
};

/// Names for polygon offset direction
immutable(string[]) PolygonOffsetDirectionNames =
[
	"Back",
	"Front",
];


/// Maximum number of texture an SMaterial can have.
enum MATERIAL_MAX_TEXTURES = _IRR_MATERIAL_MAX_TEXTURES_;

/// Class for holding parameters for a material renderer
class SMaterial
{

	/// Default constructor. Creates a solid, lit material with white colors
	this() pure
	{ 
		MaterialType = E_MATERIAL_TYPE.EMT_SOLID;
		AmbientColor = SColor(255,255,255,255);
		DiffuseColor = SColor(255,255,255,255);
		EmissiveColor = SColor(0,0,0,0);
		MaterialTypeParam = 0.0f;
		MaterialTypeParam2 = 0.0f;
		Thickness = 1.0f;
		ZBuffer = E_COMPARISON_FUNC.ECFN_LESSEQUAL;
		AntiAliasing = E_ANTI_ALIASING_MODE.EAAM_SIMPLE;
		ColorMask = E_COLOR_PLANE.ECP_ALL;
		ColorMaterial = E_COLOR_MATERIAL.ECM_DIFFUSE;
		BlendOperation = E_BLEND_OPERATION.EBO_NONE;
		PolygonOffsetFactor = 0;
		PolygonOffsetDirection = E_POLYGON_OFFSET.EPO_FRONT;
		Wireframe = false;
		PointCloud = false;
		GouraudShading = true;
		Lighting = true;
		ZWriteEnable = true;
		BackfaceCulling = true;
		FrontfaceCulling = false;
		FogEnable = false;
		NormalizeNormals = false;
		UseMipMaps = true;
	}

	/// Copy constructor
	/**
	* Params:
	* 	other=  Material to copy from. 
	*/
	this(const SMaterial other) pure
	{
		MaterialType = other.MaterialType;
		AmbientColor = other.AmbientColor;
		DiffuseColor = other.DiffuseColor;
		EmissiveColor = other.EmissiveColor;
		MaterialTypeParam = other.MaterialTypeParam;
		MaterialTypeParam2 = other.MaterialTypeParam2;
		Thickness = other.Thickness;
		ZBuffer = other.ZBuffer;
		AntiAliasing = other.AntiAliasing;
		ColorMask = other.ColorMask;
		ColorMaterial = other.ColorMaterial;
		BlendOperation = other.BlendOperation;
		PolygonOffsetFactor = other.PolygonOffsetFactor;
		PolygonOffsetDirection = other.PolygonOffsetDirection;
		Wireframe = other.Wireframe;
		PointCloud = other.PointCloud;
		GouraudShading = other.GouraudShading;
		Lighting = other.Lighting;
		ZWriteEnable = other.ZWriteEnable;
		BackfaceCulling = other.BackfaceCulling;
		FrontfaceCulling = other.FrontfaceCulling;
		FogEnable = other.FogEnable;
		NormalizeNormals = other.NormalizeNormals;
		UseMipMaps = other.UseMipMaps;

		foreach(i, ref layer; other.TextureLayer)
			TextureLayer[i] = new SMaterialLayer(layer);	
	}

	/// Assignment operator
	/**
	* Params:
	* 	other=  Material to copy from. 
	*/
	SMaterial set(const SMaterial other)
	{
		// Check for self-assignment!
		if (this == other)
			return this;

		MaterialType = other.MaterialType;

		AmbientColor = other.AmbientColor;
		DiffuseColor = other.DiffuseColor;
		EmissiveColor = other.EmissiveColor;
		SpecularColor = other.SpecularColor;
		Shininess = other.Shininess;
		MaterialTypeParam = other.MaterialTypeParam;
		MaterialTypeParam2 = other.MaterialTypeParam2;
		Thickness = other.Thickness;

		foreach(i, ref layer; other.TextureLayer)
			TextureLayer[i] = new SMaterialLayer(layer);

		Wireframe = other.Wireframe;
		PointCloud = other.PointCloud;
		GouraudShading = other.GouraudShading;
		Lighting = other.Lighting;
		ZWriteEnable = other.ZWriteEnable;
		BackfaceCulling = other.BackfaceCulling;
		FrontfaceCulling = other.FrontfaceCulling;
		FogEnable = other.FogEnable;
		NormalizeNormals = other.NormalizeNormals;
		ZBuffer = other.ZBuffer;
		AntiAliasing = other.AntiAliasing;
		ColorMask = other.ColorMask;
		ColorMaterial = other.ColorMaterial;
		BlendOperation = other.BlendOperation;
		PolygonOffsetFactor = other.PolygonOffsetFactor;
		PolygonOffsetDirection = other.PolygonOffsetDirection;
		UseMipMaps = other.UseMipMaps;

		return this;
	}

	/// Texture layer array.
	SMaterialLayer TextureLayer[MATERIAL_MAX_TEXTURES];

	/// Type of the material. Specifies how everything is blended together
	E_MATERIAL_TYPE MaterialType;

	/// How much ambient light (a global light) is reflected by this material.
	/**
	* The default is full white, meaning objects are completely
	* globally illuminated. Reduce this if you want to see diffuse
	* or specular light effects. 
	*/
	SColor AmbientColor;

	/// How much diffuse light coming from a light source is reflected by this material.
	/**
	* The default is full white. 
	*/
	SColor DiffuseColor;

	/// Light emitted by this material. Default is to emit no light.
	SColor EmissiveColor;

	/// How much specular light (highlights from a light) is reflected.
	/**
	* The default is to reflect white specular light. See
	* SMaterial::Shininess on how to enable specular lights. 
	*/
	SColor SpecularColor;

	/// Value affecting the size of specular highlights.
	/**
	* A value of 20 is common. If set to 0, no specular
	* highlights are being used. To activate, simply set the
	* shininess of a material to a value in the range [0.5;128]:
	* Examples:
	* ------
	* sceneNode.getMaterial(0).Shininess = 20.0f;
	* ------
	* You can change the color of the highlights using
	* Examples:
	* ------
	* sceneNode.getMaterial(0).SpecularColor.set(255,255,255,255);
	* ------
	* The specular color of the dynamic lights
	* (SLight.SpecularColor) will influence the the highlight color
	* too, but they are set to a useful value by default when
	* creating the light scene node. Here is a simple example on how
	* to use specular highlights:
	* Examples:
	* ------
	* // load and display mesh
	* IAnimatedMeshSceneNode node = smgr.addAnimatedMeshSceneNode(
	* smgr.getMesh("data/faerie.md2"));
	* node.setMaterialTexture(0, driver.getTexture("data/Faerie2.pcx")); // set diffuse texture
	* node.setMaterialFlag(E_MATERIAL_FLAG.EMF_LIGHTING, true); // enable dynamic lighting
	* node.getMaterial(0).Shininess = 20.0f; // set size of specular highlights
	* // add white light
	* ILightSceneNode light = smgr.addLightSceneNode(0,
	*	 vector3df(5,5,5), SColorf(1.0f, 1.0f, 1.0f));
	* ------
	*/
	float Shininess;

	/// Free parameter, dependent on the material type.
	/**
	* Mostly ignored, used for example in EMT_PARALLAX_MAP_SOLID
	* and EMT_TRANSPARENT_ALPHA_CHANNEL. 
	*/
	float MaterialTypeParam;

	/// Second free parameter, dependent on the material type.
	/**
	* Mostly ignored. 
	*/
	float MaterialTypeParam2;

	/// Thickness of non-3dimensional elements such as lines and points.
	float Thickness;

	/// Is the ZBuffer enabled? Default: ECFN_LESSEQUAL
	/**
	* Values are from E_COMPARISON_FUNC. 
	*/
	ubyte ZBuffer;

	/// Sets the antialiasing mode
	/**
	* Values are chosen from E_ANTI_ALIASING_MODE. Default is 
	* EAAM_SIMPLE|EAAM_LINE_SMOOTH, i.e. simple multi-sample
	* anti-aliasing and lime smoothing is enabled. 
	*/
	ubyte AntiAliasing;

	/**
	* ColorMask: Defines the enabled color planes. Values are defined as or'ed values of the E_COLOR_PLANE enum.
	* Only enabled color planes will be rendered to the current render
	* target. Typical use is to disable all colors when rendering only to
	* depth or stencil buffer, or using Red and Green for Stereo rendering.
	* 
	* BlendOperation: Store the blend operation of choice. Values to be chosen from E_BLEND_OPERATION. The actual way to use this value
	* is not yet determined, so ignore it for now. 
	*/
	mixin(bitfields!(
		ubyte,				"ColorMask",		4,
		E_BLEND_OPERATION, 	"BlendOperation", 	4,
	));

	/**
	* Wireframe: Draw as wireframe or filled triangles? Default: false
	* The user can access a material flag using
	* Examples:
	* ------
	* material.Wireframe = true; \\ or
	* material.setFlag(EMF_WIREFRAME, true); 
	* ------
	* 
	* PointCloud: Draw as point cloud or filled triangles? Default: false
	* 
	* GouraudShading: Flat or Gouraud shading? Default: true
	* 
	* Lighting: Will this material be lighted? Default: true
	* 
	* ZWriteEnable: Is the zbuffer writeable or is it read-only. Default: true.
	* This flag is forced to false if the MaterialType is a
	* transparent type and the scene parameter
	* ALLOW_ZWRITE_ON_TRANSPARENT is not set.
	* 
	* BackfaceCulling: Is backface culling enabled? Default: true
	* 
	* FrontfaceCulling: Is frontface culling enabled? Default: false
	* 
	* FogEnable: Is fog enabled? Default: false 
	*/
	mixin(bitfields!(
		bool,	"Wireframe", 		1,
		bool,	"PointCloud",		1,
		bool,	"GouraudShading",	1,
		bool,	"Lighting",			1,
		bool,	"ZWriteEnable",		1,
		bool,	"BackfaceCulling",	1,
		bool,	"FrontfaceCulling", 1,
		bool,	"FogEnable",		1,
	));

	/**
	* NormalizeNormals: Should normals be normalized? 
	* Always use this if the mesh lit and scaled. Default: false
	* 
	* UseMipMaps: Shall mipmaps be used if available. Sometimes, 
	* disabling mipmap usage can be useful. Default: true
	* 
	* ColorMaterial: Defines the interpretation of vertex color 
	* in the lighting equation. Values should be chosen from E_COLOR_MATERIAL.
	* When lighting is enabled, vertex color can be used instead of the 
	* material values for light modulation. This allows to easily change e.g. the
	* diffuse light behavior of each face. The default, ECM_DIFFUSE, will result in
	* a very similar rendering as with lighting turned off, just with light shading.
	* 
	* PolygonOffsetFactor: Factor specifying how far the polygon offset 
	* should be made. Specifying 0 disables the polygon offset. The direction is specified spearately.
	* The factor can be from 0 to 7. 
	*/
	mixin(bitfields!(
		bool,	"NormalizeNormals", 	1,
		bool,	"UseMipMaps",			1,
		ubyte,	"ColorMaterial",		3,
		ubyte,	"PolygonOffsetFactor",	3,
	));

	/// Flag defining the direction the polygon offset is applied to.
	/**
	* Can be to front or to back, specififed by values from E_POLYGON_OFFSET. 
	*/
	E_POLYGON_OFFSET PolygonOffsetDirection;

	/// Gets the texture transformation matrix for level i
	/**
	* Params:
	* 	i=  The desired level. Must not be larger than MATERIAL_MAX_TEXTURES.
	* Returns: Texture matrix for texture level i. 
	*/
	matrix4 getTextureMatrix(size_t i)
	{
		return TextureLayer[i].getTextureMatrix();
	}

	/// Gets the immutable texture transformation matrix for level i
	/**
	* Params:
	* 	i=  The desired level.
	* Returns: Texture matrix for texture level i, or identity matrix for levels larger than MATERIAL_MAX_TEXTURES. 
	*/
	matrix4 getTextureMatrix(size_t i)
	{
		assert(i<MATERIAL_MAX_TEXTURES);
		return TextureLayer[i].getTextureMatrix();
	}

	/// Sets the i-th texture transformation matrix
	/**
	* Params:
	* 	i=  The desired level.
	* 	mat=  Texture matrix for texture level i. 
	*/
	void setTextureMatrix()(size_t i, auto ref const matrix4 mat)
	{
		if (i>=MATERIAL_MAX_TEXTURES)
			return;
		TextureLayer[i].setTextureMatrix(mat);
	}

	/// Gets the i-th texture
	/**
	* Params:
	* 	i=  The desired level.
	* Returns: Texture for texture level i, if defined, else 0. 
	*/
	ITexture getTexture(size_t i)
	{
		return i < MATERIAL_MAX_TEXTURES ? TextureLayer[i].Texture : null;
	}

	/// Sets the i-th texture
	/**
	* If i>=MATERIAL_MAX_TEXTURES this setting will be ignored.
	* Params:
	* 	i=  The desired level.
	* 	tex=  Texture for texture level i. 
	*/
	void setTexture(size_t i, ITexture tex)
	{
		if (i>=MATERIAL_MAX_TEXTURES)
			return;
		TextureLayer[i].Texture = tex;
	}

	/// Sets the Material flag to the given value
	/**
	* Params:
	* 	flag=  The flag to be set.
	* 	value=  The new value for the flag. 
	*/
	void setFlag(E_MATERIAL_FLAG flag, bool value)
	{
		final switch (flag)
		{
			case E_MATERIAL_FLAG.EMF_WIREFRAME:
				Wireframe = value; break;
			case E_MATERIAL_FLAG.EMF_POINTCLOUD:
				PointCloud = value; break;
			case E_MATERIAL_FLAG.EMF_GOURAUD_SHADING:
				GouraudShading = value; break;
			case E_MATERIAL_FLAG.EMF_LIGHTING:
				Lighting = value; break;
			case E_MATERIAL_FLAG.EMF_ZBUFFER:
				ZBuffer = value; break;
			case E_MATERIAL_FLAG.EMF_ZWRITE_ENABLE:
				ZWriteEnable = value; break;
			case E_MATERIAL_FLAG.EMF_BACK_FACE_CULLING:
				BackfaceCulling = value; break;
			case E_MATERIAL_FLAG.EMF_FRONT_FACE_CULLING:
				FrontfaceCulling = value; break;
			case E_MATERIAL_FLAG.EMF_BILINEAR_FILTER:
			{
				for (size_t i=0; i<MATERIAL_MAX_TEXTURES; ++i)
					TextureLayer[i].BilinearFilter = value;
			}
			break;
			case E_MATERIAL_FLAG.EMF_TRILINEAR_FILTER:
			{
				for (size_t i=0; i<MATERIAL_MAX_TEXTURES; ++i)
					TextureLayer[i].TrilinearFilter = value;
			}
			break;
			case E_MATERIAL_FLAG.EMF_ANISOTROPIC_FILTER:
			{
				if (value)
					for (size_t i=0; i<MATERIAL_MAX_TEXTURES; ++i)
						TextureLayer[i].AnisotropicFilter = 0xFF;
				else
					for (size_t i=0; i<MATERIAL_MAX_TEXTURES; ++i)
						TextureLayer[i].AnisotropicFilter = 0;
			}
			break;
			case E_MATERIAL_FLAG.EMF_FOG_ENABLE:
				FogEnable = value; break;
			case E_MATERIAL_FLAG.EMF_NORMALIZE_NORMALS:
				NormalizeNormals = value; break;
			case E_MATERIAL_FLAG.EMF_TEXTURE_WRAP:
			{
				for (size_t i=0; i<MATERIAL_MAX_TEXTURES; ++i)
				{
					TextureLayer[i].TextureWrapU = cast(E_TEXTURE_CLAMP)value;
					TextureLayer[i].TextureWrapV = cast(E_TEXTURE_CLAMP)value;
				}
			}
			break;
			case E_MATERIAL_FLAG.EMF_ANTI_ALIASING:
				AntiAliasing = value?E_ANTI_ALIASING_MODE.EAAM_SIMPLE:E_ANTI_ALIASING_MODE.EAAM_OFF; break;
			case E_MATERIAL_FLAG.EMF_COLOR_MASK:
				ColorMask = value?E_COLOR_PLANE.ECP_ALL:E_COLOR_PLANE.ECP_NONE; break;
			case E_MATERIAL_FLAG.EMF_COLOR_MATERIAL:
				ColorMaterial = value?E_COLOR_MATERIAL.ECM_DIFFUSE:E_COLOR_MATERIAL.ECM_NONE; break;
			case E_MATERIAL_FLAG.EMF_USE_MIP_MAPS:
				UseMipMaps = value; break;
			case E_MATERIAL_FLAG.EMF_BLEND_OPERATION:
				BlendOperation = value?E_BLEND_OPERATION.EBO_ADD:E_BLEND_OPERATION.EBO_NONE; break;
			case E_MATERIAL_FLAG.EMF_POLYGON_OFFSET:
				PolygonOffsetFactor = value?1:0;
				PolygonOffsetDirection = E_POLYGON_OFFSET.EPO_BACK;
				break;
		}
	}

	/// Gets the Material flag
	/**
	* Params:
	* 	flag=  The flag to query.
	* Returns: The current value of the flag. 
	*/
	bool getFlag(E_MATERIAL_FLAG flag)
	{
		final switch (flag)
		{
			case E_MATERIAL_FLAG.EMF_WIREFRAME:
				return Wireframe;
			case E_MATERIAL_FLAG.EMF_POINTCLOUD:
				return PointCloud;
			case E_MATERIAL_FLAG.EMF_GOURAUD_SHADING:
				return GouraudShading;
			case E_MATERIAL_FLAG.EMF_LIGHTING:
				return Lighting;
			case E_MATERIAL_FLAG.EMF_ZBUFFER:
				return ZBuffer!= E_COMPARISON_FUNC.ECFN_NEVER;
			case E_MATERIAL_FLAG.EMF_ZWRITE_ENABLE:
				return ZWriteEnable;
			case E_MATERIAL_FLAG.EMF_BACK_FACE_CULLING:
				return BackfaceCulling;
			case E_MATERIAL_FLAG.EMF_FRONT_FACE_CULLING:
				return FrontfaceCulling;
			case E_MATERIAL_FLAG.EMF_BILINEAR_FILTER:
				return TextureLayer[0].BilinearFilter;
			case E_MATERIAL_FLAG.EMF_TRILINEAR_FILTER:
				return TextureLayer[0].TrilinearFilter;
			case E_MATERIAL_FLAG.EMF_ANISOTROPIC_FILTER:
				return TextureLayer[0].AnisotropicFilter!=0;
			case E_MATERIAL_FLAG.EMF_FOG_ENABLE:
				return FogEnable;
			case E_MATERIAL_FLAG.EMF_NORMALIZE_NORMALS:
				return NormalizeNormals;
			case E_MATERIAL_FLAG.EMF_TEXTURE_WRAP:
				return !(TextureLayer[0].TextureWrapU ||
						TextureLayer[0].TextureWrapV ||
						TextureLayer[1].TextureWrapU ||
						TextureLayer[1].TextureWrapV ||
						TextureLayer[2].TextureWrapU ||
						TextureLayer[2].TextureWrapV ||
						TextureLayer[3].TextureWrapU ||
						TextureLayer[3].TextureWrapV);
			case E_MATERIAL_FLAG.EMF_ANTI_ALIASING:
				return (AntiAliasing==1);
			case E_MATERIAL_FLAG.EMF_COLOR_MASK:
				return (ColorMask!=E_COLOR_PLANE.ECP_NONE);
			case E_MATERIAL_FLAG.EMF_COLOR_MATERIAL:
				return (ColorMaterial != E_COLOR_MATERIAL.ECM_NONE);
			case E_MATERIAL_FLAG.EMF_USE_MIP_MAPS:
				return UseMipMaps;
			case E_MATERIAL_FLAG.EMF_BLEND_OPERATION:
				return BlendOperation != E_BLEND_OPERATION.EBO_NONE;
			case E_MATERIAL_FLAG.EMF_POLYGON_OFFSET:
				return PolygonOffsetFactor != 0;
		}
	}

	/// Equality operator
	/**
	* Params:
	* 	b=  Material to compare to.
	* Returns: True if the materials not differ, else false. 
	*/
	bool opEqual(const SMaterial b)
	{
		bool different =
			MaterialType != b.MaterialType ||
			AmbientColor != b.AmbientColor ||
			DiffuseColor != b.DiffuseColor ||
			EmissiveColor != b.EmissiveColor ||
			SpecularColor != b.SpecularColor ||
			Shininess != b.Shininess ||
			MaterialTypeParam != b.MaterialTypeParam ||
			MaterialTypeParam2 != b.MaterialTypeParam2 ||
			Thickness != b.Thickness ||
			Wireframe != b.Wireframe ||
			PointCloud != b.PointCloud ||
			GouraudShading != b.GouraudShading ||
			Lighting != b.Lighting ||
			ZBuffer != b.ZBuffer ||
			ZWriteEnable != b.ZWriteEnable ||
			BackfaceCulling != b.BackfaceCulling ||
			FrontfaceCulling != b.FrontfaceCulling ||
			FogEnable != b.FogEnable ||
			NormalizeNormals != b.NormalizeNormals ||
			AntiAliasing != b.AntiAliasing ||
			ColorMask != b.ColorMask ||
			ColorMaterial != b.ColorMaterial ||
			BlendOperation != b.BlendOperation ||
			PolygonOffsetFactor != b.PolygonOffsetFactor ||
			PolygonOffsetDirection != b.PolygonOffsetDirection ||
			UseMipMaps != b.UseMipMaps;
		for (size_t i=0; (i<MATERIAL_MAX_TEXTURES) && !different; ++i)
		{
			different |= (TextureLayer[i] != b.TextureLayer[i]);
		}
		return !different;
	}

	bool isTransparent()
	{
		return MaterialType==E_MATERIAL_TYPE.EMT_TRANSPARENT_ADD_COLOR ||
			MaterialType==E_MATERIAL_TYPE.EMT_TRANSPARENT_ALPHA_CHANNEL ||
			MaterialType==E_MATERIAL_TYPE.EMT_TRANSPARENT_VERTEX_ALPHA ||
			MaterialType==E_MATERIAL_TYPE.EMT_TRANSPARENT_REFLECTION_2_LAYER;
	}
};

/// global const identity Material
export immutable SMaterial IdentityMaterial = new immutable SMaterial();
