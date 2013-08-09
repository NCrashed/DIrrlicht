module irrlicht.video.IVideoDriver;

import irrlicht.core.rect;
import irrlicht.video.SColor;
import irrlicht.video.ITexture;
import irrlicht.video.SMaterial;
import irrlicht.video.EDriverTypes;
import irrlicht.video.EDriverFeatures;
import irrlicht.video.SExposedVideoData;
import irrlicht.core.irrArray;
import irrlicht.core.matrix4;
import irrlicht.core.plane3d;
import irrlicht.core.dimension2d;
import irrlicht.core.vector2d;
import irrlicht.core.vector3d;
import irrlicht.core.triangle3d;
import irrlicht.io.IAttributes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.io.IReadFile;
import irrlicht.io.IWriteFile;
import irrlicht.io.path;
import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.IMesh;
import irrlicht.scene.IMeshManipulator;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.EPrimitiveTypes;
import irrlicht.video.S3DVertex;
import irrlicht.video.SVertexIndex;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.SLight;
import irrlicht.video.IImage;
import irrlicht.video.IImageLoader;
import irrlicht.video.IImageWriter;
import irrlicht.video.IMaterialRenderer;
import irrlicht.video.IGPUProgrammingServices;

/**
*	Mixin template generating enum E_TRANSFORMATION_STATE with
*	texCount texture constants.
*/
private template MixinETransformationState(uint texCount)
{
	import std.conv;

	private template TextureSection(uint count)
	{
		static if(count > 0)
			enum TextureSection = TextureSection!(count-1) 
			~ q{
				/// Texture transformation
				ETS_TEXTURE_}~to!string(count)~q{,
			};
		else
			enum TextureSection = q{
				/// Texture transformation
				ETS_TEXTURE_0,
			};
	}

	enum MixinETransformationState = `
		enum E_TRANSFORMATION_STATE
		{
		/// View transformation
		ETS_VIEW = 0,
		/// World transformation
		ETS_WORLD,
		/// Projection transformation
		ETS_PROJECTION,
	` ~ TextureSection!texCount ~ `

		/// Not used
		ETS_COUNT
		}
	`;
}

/// enumeration for geometry transformation states
//pragma(msg, MixinETransformationState!MATERIAL_MAX_TEXTURES);
mixin(MixinETransformationState!MATERIAL_MAX_TEXTURES);

/// enumeration for signaling resources which were lost after the last render cycle
/** 
* These values can be signaled by the driver, telling the app that some resources
* were lost and need to be recreated. Irrlicht will sometimes recreate the actual objects,
* but the content needs to be recreated by the application. 
*/
enum E_LOST_RESOURCE
{
	/// The whole device/driver is lost
	ELR_DEVICE = 1,
	/// All texture are lost, rare problem
	ELR_TEXTURES = 2,
	/// The Render Target Textures are lost, typical problem for D3D
	ELR_RTTS = 4,
	/// The HW buffers are lost, will be recreated automatically, but might require some more time this frame
	ELR_HW_BUFFERS = 8
}

/// Special render targets, which usually map to dedicated hardware
/** 
* These render targets (besides 0 and 1) need not be supported by gfx cards 
*/
enum E_RENDER_TARGET
{
	/// Render target is the main color frame buffer
	ERT_FRAME_BUFFER=0,
	/// Render target is a render texture
	ERT_RENDER_TEXTURE,
	/// Multi-Render target textures
	ERT_MULTI_RENDER_TEXTURES,
	/// Render target is the main color frame buffer
	ERT_STEREO_LEFT_BUFFER,
	/// Render target is the right color buffer (left is the main buffer)
	ERT_STEREO_RIGHT_BUFFER,
	/// Render to both stereo buffers at once
	ERT_STEREO_BOTH_BUFFERS,
	/// Auxiliary buffer 0
	ERT_AUX_BUFFER0,
	/// Auxiliary buffer 1
	ERT_AUX_BUFFER1,
	/// Auxiliary buffer 2
	ERT_AUX_BUFFER2,
	/// Auxiliary buffer 3
	ERT_AUX_BUFFER3,
	/// Auxiliary buffer 4
	ERT_AUX_BUFFER4
}

/// Enum for the types of fog distributions to choose from
enum E_FOG_TYPE
{
	EFT_FOG_EXP=0,
	EFT_FOG_LINEAR,
	EFT_FOG_EXP2
}

immutable(string[]) FogTypeNames =
[
	"FogExp",
	"FogLinear",
	"FogExp2",
];

struct SOverrideMaterial
{
	/// The Material values
	SMaterial Material;

	/// Which values are taken for override
	/**
	* OR'ed values from E_MATERIAL_FLAGS. 
	*/
	uint EnableFlags;

	/// Set in which render passes the material override is active.
	/**
	* OR'ed values from E_SCENE_NODE_RENDER_PASS. 
	*/
	ushort EnablePasses;

	/// Global enable flag, overwritten by the SceneManager in each pass
	/**
	* The Scenemanager uses the EnablePass array and sets Enabled to
	* true if the Override material is enabled in the current pass. 
	*/
	bool Enabled = false;

	/// Apply the enabled overrides
	void apply(SMaterial material)
	{
		if (Enabled)
		{
			for (uint i; i<32; ++i)
			{
				const uint num=(1<<i);
				if (EnableFlags & num)
				{
					switch (cast(E_MATERIAL_FLAG)num)
					{
					case E_MATERIAL_FLAG.EMF_WIREFRAME: material.Wireframe = Material.Wireframe; break;
					case E_MATERIAL_FLAG.EMF_POINTCLOUD: material.PointCloud = Material.PointCloud; break;
					case E_MATERIAL_FLAG.EMF_GOURAUD_SHADING: material.GouraudShading = Material.GouraudShading; break;
					case E_MATERIAL_FLAG.EMF_LIGHTING: material.Lighting = Material.Lighting; break;
					case E_MATERIAL_FLAG.EMF_ZBUFFER: material.ZBuffer = Material.ZBuffer; break;
					case E_MATERIAL_FLAG.EMF_ZWRITE_ENABLE: material.ZWriteEnable = Material.ZWriteEnable; break;
					case E_MATERIAL_FLAG.EMF_BACK_FACE_CULLING: material.BackfaceCulling = Material.BackfaceCulling; break;
					case E_MATERIAL_FLAG.EMF_FRONT_FACE_CULLING: material.FrontfaceCulling = Material.FrontfaceCulling; break;
					case E_MATERIAL_FLAG.EMF_BILINEAR_FILTER: material.TextureLayer[0].BilinearFilter = Material.TextureLayer[0].BilinearFilter; break;
					case E_MATERIAL_FLAG.EMF_TRILINEAR_FILTER: material.TextureLayer[0].TrilinearFilter = Material.TextureLayer[0].TrilinearFilter; break;
					case E_MATERIAL_FLAG.EMF_ANISOTROPIC_FILTER: material.TextureLayer[0].AnisotropicFilter = Material.TextureLayer[0].AnisotropicFilter; break;
					case E_MATERIAL_FLAG.EMF_FOG_ENABLE: material.FogEnable = Material.FogEnable; break;
					case E_MATERIAL_FLAG.EMF_NORMALIZE_NORMALS: material.NormalizeNormals = Material.NormalizeNormals; break;
					case E_MATERIAL_FLAG.EMF_TEXTURE_WRAP:
						material.TextureLayer[0].TextureWrapU = Material.TextureLayer[0].TextureWrapU;
						material.TextureLayer[0].TextureWrapV = Material.TextureLayer[0].TextureWrapV;
						break;
					case E_MATERIAL_FLAG.EMF_ANTI_ALIASING: material.AntiAliasing = Material.AntiAliasing; break;
					case E_MATERIAL_FLAG.EMF_COLOR_MASK: material.ColorMask = Material.ColorMask; break;
					case E_MATERIAL_FLAG.EMF_COLOR_MATERIAL: material.ColorMaterial = Material.ColorMaterial; break;
					case E_MATERIAL_FLAG.EMF_USE_MIP_MAPS: material.UseMipMaps = Material.UseMipMaps; break;
					case E_MATERIAL_FLAG.EMF_BLEND_OPERATION: material.BlendOperation = Material.BlendOperation; break;
					case E_MATERIAL_FLAG.EMF_POLYGON_OFFSET:
						material.PolygonOffsetDirection = Material.PolygonOffsetDirection;
						material.PolygonOffsetFactor = Material.PolygonOffsetFactor; break;
					default:
					}
				}
			}
		}
	}
}

struct IRenderTarget
{
	this(ITexture texture,
			E_COLOR_PLANE colorMask=E_COLOR_PLANE.ECP_ALL,
			E_BLEND_FACTOR blendFuncSrc=E_BLEND_FACTOR.EBF_ONE,
			E_BLEND_FACTOR blendFuncDst=E_BLEND_FACTOR.EBF_ONE_MINUS_SRC_ALPHA,
			E_BLEND_OPERATION blendOp=E_BLEND_OPERATION.EBO_NONE)
	{
		RenderTexture = texture;
		TargetType = E_RENDER_TARGET.ERT_RENDER_TEXTURE;
		ColorMask = colorMask;
		BlendFuncSrc = blendFuncSrc;
		BlendFuncDst = blendFuncDst;
		BlendOp = blendOp;
	}

	this(E_RENDER_TARGET target,
			E_COLOR_PLANE colorMask=E_COLOR_PLANE.ECP_ALL,
			E_BLEND_FACTOR blendFuncSrc=E_BLEND_FACTOR.EBF_ONE,
			E_BLEND_FACTOR blendFuncDst=E_BLEND_FACTOR.EBF_ONE_MINUS_SRC_ALPHA,
			E_BLEND_OPERATION blendOp=E_BLEND_OPERATION.EBO_NONE)
	{
		RenderTexture = null;
		TargetType = target;
		ColorMask = colorMask;
		BlendFuncSrc = blendFuncSrc;
		BlendFuncDst = blendFuncDst;
		BlendOp = blendOp;
	}

	bool opEqual()(auto ref const IRenderTarget other) const
	{
		return ((RenderTexture == other.RenderTexture) &&
			(TargetType == other.TargetType) &&
			(ColorMask == other.ColorMask) &&
			(BlendFuncSrc == other.BlendFuncSrc) &&
			(BlendFuncDst == other.BlendFuncDst) &&
			(BlendOp == other.BlendOp));
	}

	ITexture RenderTexture;
	E_RENDER_TARGET TargetType;
	E_COLOR_PLANE ColorMask;
	E_BLEND_FACTOR BlendFuncSrc;
	E_BLEND_FACTOR BlendFuncDst;
	E_BLEND_OPERATION BlendOp;
}

/// Interface to driver which is able to perform 2d and 3d graphics functions.
/**
* This interface is one of the most important interfaces of
* the Irrlicht Engine: All rendering and texture manipulation is done with
* this interface. You are able to use the Irrlicht Engine by only
* invoking methods of this interface if you like to, although the
* irrlicht.scene.ISceneManager interface provides a lot of powerful classes
* and methods to make the programmer's life easier.
*/
interface IVideoDriver
{
	/// Applications must call this method before performing any rendering.
	/**
	* This method can clear the back- and the z-buffer.
	* Params:
	* 	backBuffer=  Specifies if the back buffer should be
	* cleared, which means that the screen is filled with the color
	* specified. If this parameter is false, the back buffer will
	* not be cleared and the color parameter is ignored.
	* 	zBuffer=  Specifies if the depth buffer (z buffer) should
	* be cleared. It is not nesesarry to do so if only 2d drawing is
	* used.
	* 	color=  The color used for back buffer clearing
	* 	videoData=  Handle of another window, if you want the
	* bitmap to be displayed on another window. If this is an empty
	* element, everything will be displayed in the default window.
	* Note: This feature is not fully implemented for all devices.
	* 	sourceRect=  Pointer to a rectangle defining the source
	* rectangle of the area to be presented. Set to null to present
	* everything. Note: not implemented in all devices.
	* Returns: False if failed. 
	*/
	bool beginScene(bool backBuffer = true, bool zBuffer = true,
			SColor color = SColor(255,0,0,0),
			const SExposedVideoData videoData = SExposedVideoData(),
			rect!(int)* sourceRect = null);

	/// Presents the rendered image to the screen.
	/**
	* Applications must call this method after performing any
	* rendering.
	* Returns: False if failed and true if succeeded. 
	*/
	bool endScene();

	/// Queries the features of the driver.
	/**
	* Returns true if a feature is available
	* Params:
	* 	feature=  Feature to query.
	* Returns: True if the feature is available, false if not. 
	*/
	bool queryFeature(E_VIDEO_DRIVER_FEATURE feature) const;

	/// Disable a feature of the driver.
	/**
	* Can also be used to enable the features again. It is not
	* possible to enable unsupported features this way, though.
	* Params:
	* 	feature=  Feature to disable.
	* 	flag=  When true the feature is disabled, otherwise it is enabled. 
	*/
	void disableFeature(E_VIDEO_DRIVER_FEATURE feature, bool flag=true);

	/// Get attributes of the actual video driver
	/**
	* The following names can be queried for the given types:
	* MaxTextures (int) The maximum number of simultaneous textures supported by the driver. This can be less than the supported number of textures of the driver. Use _IRR_MATERIAL_MAX_TEXTURES_ to adapt the number.
	* MaxSupportedTextures (int) The maximum number of simultaneous textures supported by the fixed function pipeline of the (hw) driver. The actual supported number of textures supported by the engine can be lower.
	* MaxLights (int) Number of hardware lights supported in the fixed function pipieline of the driver, typically 6-8. Use light manager or deferred shading for more.
	* MaxAnisotropy (int) Number of anisotropy levels supported for filtering. At least 1, max is typically at 16 or 32.
	* MaxUserClipPlanes (int) Number of additional clip planes, which can be set by the user via dedicated driver methods.
	* MaxAuxBuffers (int) Special render buffers, which are currently not really usable inside Irrlicht. Only supported by OpenGL
	* MaxMultipleRenderTargets (int) Number of render targets which can be bound simultaneously. Rendering to MRTs is done via shaders.
	* MaxIndices (int) Number of indices which can be used in one render call (i.e. one mesh buffer).
	* MaxTextureSize (int) Dimension that a texture may have, both in width and height.
	* MaxGeometryVerticesOut (int) Number of vertices the geometry shader can output in one pass. Only OpenGL so far.
	* MaxTextureLODBias (float) Maximum value for LOD bias. Is usually at around 16, but can be lower on some systems.
	* Version (int) Version of the driver. Should be Major*100+Minor
	* ShaderLanguageVersion (int) Version of the high level shader language. Should be Major*100+Minor.
	* AntiAlias (int) Number of Samples the driver uses for each pixel. 0 and 1 means anti aliasing is off, typical values are 2,4,8,16,32
	*/
	const IAttributes getDriverAttributes() const;

	/// Check if the driver was recently reset.
	/**
	* For d3d devices you will need to recreate the RTTs if the
	* driver was reset. Should be queried right after beginScene().
	*/
	bool checkDriverReset();

	/// Sets transformation matrices.
	/**
	* Params:
	* 	state=  Transformation type to be set, e.g. view,
	* world, or projection.
	* 	mat=  Matrix describing the transformation. 
	*/
	void setTransform()(E_TRANSFORMATION_STATE state, auto ref const matrix4 mat);

	/// Returns the transformation set by setTransform
	/**
	* Params:
	* 	state=  Transformation type to query
	* Returns: Matrix describing the transformation. 
	*/
	auto ref const matrix4 getTransform(E_TRANSFORMATION_STATE state) const;

	/// Retrieve the number of image loaders
	/**
	* Returns: Number of image loaders 
	*/
	size_t getImageLoaderCount() const;

	/// Retrieve the given image loader
	/**
	* Params:
	* 	n=  The index of the loader to retrieve. This parameter is an 0-based
	* array index.
	* Returns: A pointer to the specified loader, 0 if the index is incorrect. 
	*/
	IImageLoader getImageLoader(size_t n);

	/// Retrieve the number of image writers
	/**
	* Returns: Number of image writers 
	*/
	size_t getImageWriterCount() const;

	/// Retrieve the given image writer
	/**
	* Params:
	* 	n=  The index of the writer to retrieve. This parameter is an 0-based
	* array index.
	* Returns: A pointer to the specified writer, 0 if the index is incorrect. 
	*/
	IImageWriter getImageWriter(size_t n);

	/// Sets a material.
	/**
	* All 3d drawing functions will draw geometry using this material thereafter.
	* Params:
	* 	material=  Material to be used from now on. 
	*/
	void setMaterial(const SMaterial material);

	/// Get access to a named texture.
	/**
	* Loads the texture from disk if it is not
	* already loaded and generates mipmap levels if desired.
	* Texture loading can be influenced using the
	* setTextureCreationFlag() method. The texture can be in several
	* imageformats, such as BMP, JPG, TGA, PCX, PNG, and PSD.
	* Params:
	* 	filename=  Filename of the texture to be loaded.
	* Returns: Pointer to the texture, or 0 if the texture
	* could not be loaded. 
	*/
	ITexture getTexture(const Path filename);

	/// Get access to a named texture.
	/**
	* Loads the texture from disk if it is not
	* already loaded and generates mipmap levels if desired.
	* Texture loading can be influenced using the
	* setTextureCreationFlag() method. The texture can be in several
	* imageformats, such as BMP, JPG, TGA, PCX, PNG, and PSD.
	* Params:
	* 	file=  Pointer to an already opened file.
	* Returns: Pointer to the texture, or 0 if the texture
	* could not be loaded. 
	*/
	ITexture getTexture(IReadFile file);

	/// Returns a texture by index
	/**
	* Params:
	* 	index=  Index of the texture, must be smaller than
	* getTextureCount() Please note that this index might change when
	* adding or removing textures
	* Returns: Pointer to the texture, or 0 if the texture was not
	* set or index is out of bounds. 
	*/
	ITexture getTextureByIndex(size_t index);

	/// Returns amount of textures currently loaded
	/**
	* Returns: Amount of textures currently loaded 
	*/
	size_t getTextureCount() const;

	/// Renames a texture
	/**
	* Params:
	* 	texture=  Pointer to the texture to rename.
	* 	newName=  New name for the texture. This should be a unique name. 
	*/
	void renameTexture(ITexture texture, const Path newName);

	/// Creates an empty texture of specified size.
	/**
	* Params:
	* 	size=  Size of the texture.
	* 	name=  A name for the texture. Later calls to
	* getTexture() with this name will return this texture
	* 	format=  Desired color format of the texture. Please note
	* that the driver may choose to create the texture in another
	* color format.
	* Returns: Pointer to the newly created texture. 
	*/
	ITexture addTexture()(auto ref const dimension2d!uint size,
		const Path name, ECOLOR_FORMAT format = ECOLOR_FORMAT.ECF_A8R8G8B8);

	/// Creates a texture from an IImage.
	/**
	* Params:
	* 	name=  A name for the texture. Later calls of
	* getTexture() with this name will return this texture
	* 	image=  Image the texture is created from.
	* 	mipmapData=  Optional pointer to a set of images which
	* build up the whole mipmap set. Must be images of the same color
	* type as image. If this parameter is not given, the mipmaps are
	* derived from image.
	* Returns: Pointer to the newly created texture. 
	*/
	ITexture addTexture()(const Path name, IImage image, void[] mipmapData = null);

	/// Adds a new render target texture to the texture cache.
	/**
	* Params:
	* 	size=  Size of the texture, in pixels. Width and
	* height should be a power of two (e.g. 64, 128, 256, 512, ...)
	* and it should not be bigger than the backbuffer, because it
	* shares the zbuffer with the screen buffer.
	* 	name=  An optional name for the RTT.
	* 	format=  The color format of the render target. Floating point formats are supported.
	* Returns: Pointer to the created texture or 0 if the texture
	* could not be created. 
	*/
	ITexture addRenderTargetTexture()(auto ref const dimension2d!uint size,
			const Path name = "rt", const ECOLOR_FORMAT format = ECOLOR_FORMAT.ECF_UNKNOWN);

	/// Removes a texture from the texture cache and deletes it.
	/**
	* This method can free a lot of memory!
	* Please note that after calling this, the pointer to the
	* ITexture may no longer be valid, if it was not grabbed before
	* by other parts of the engine for storing it longer. So it is a
	* good idea to set all materials which are using this texture to
	* 0 or another texture first.
	* Params:
	* 	texture=  Texture to delete from the engine cache. 
	*/
	void removeTexture(ITexture texture);

	/// Removes all textures from the texture cache and deletes them.
	/**
	* This method can free a lot of memory!
	* Please note that after calling this, the pointer to the
	* ITexture may no longer be valid, if it was not grabbed before
	* by other parts of the engine for storing it longer. So it is a
	* good idea to set all materials which are using this texture to
	* 0 or another texture first. 
	*/
	void removeAllTextures();

	/// Remove hardware buffer
	void removeHardwareBuffer(const IMeshBuffer mb);

	/// Remove all hardware buffers
	void removeAllHardwareBuffers();

	/// Create occlusion query.
	/**
	* Use node for identification and mesh for occlusion test. 
	*/
	void addOcclusionQuery(ISceneNode node,
			const IMesh mesh = null);

	/// Remove occlusion query.
	void removeOcclusionQuery(ISceneNode node);

	/// Remove all occlusion queries.
	void removeAllOcclusionQueries();

	/// Run occlusion query. Draws mesh stored in query.
	/**
	* If the mesh shall not be rendered visible, use
	* overrideMaterial to disable the color and depth buffer. 
	*/
	void runOcclusionQuery(ISceneNode node, bool visible=false);

	/// Run all occlusion queries. Draws all meshes stored in queries.
	/**
	* If the meshes shall not be rendered visible, use
	* overrideMaterial to disable the color and depth buffer. 
	*/
	void runAllOcclusionQueries(bool visible=false);

	/// Update occlusion query. Retrieves results from GPU.
	/**
	* If the query shall not block, set the flag to false.
	* Update might not occur in this case, though 
	*/
	void updateOcclusionQuery(ISceneNode node, bool block=true);

	/// Update all occlusion queries. Retrieves results from GPU.
	/**
	* If the query shall not block, set the flag to false.
	* Update might not occur in this case, though 
	*/
	void updateAllOcclusionQueries(bool block=true);

	/// Return query result.
	/**
	* Return value is the number of visible pixels/fragments.
	* The value is a safe approximation, i.e. can be larger than the
	* actual value of pixels. 
	*/
	uint getOcclusionQueryResult(ISceneNode node) const;

	/// Sets a boolean alpha channel on the texture based on a color key.
	/**
	* This makes the texture fully transparent at the texels where
	* this color key can be found when using for example draw2DImage
	* with useAlphachannel==true.  The alpha of other texels is not modified.
	* Params:
	* 	texture=  Texture whose alpha channel is modified.
	* 	color=  Color key color. Every texel with this color will
	* become fully transparent as described above. Please note that the
	* colors of a texture may be converted when loading it, so the
	* color values may not be exactly the same in the engine and for
	* example in picture edit programs. To avoid this problem, you
	* could use the makeColorKeyTexture method, which takes the
	* position of a pixel instead a color value.
	* 	zeroTexels=  \deprecated If set to true, then any texels that match
	* the color key will have their color, as well as their alpha, set to zero
	* (i.e. black). This behavior matches the legacy (buggy) behavior prior
	* to release 1.5 and is provided for backwards compatibility only.
	* This parameter may be removed by Irrlicht 1.9. 
	*/
	void makeColorKeyTexture(ITexture texture,
					SColor color,
					bool zeroTexels = false) const;

	/// Sets a boolean alpha channel on the texture based on the color at a position.
	/**
	* This makes the texture fully transparent at the texels where
	* the color key can be found when using for example draw2DImage
	* with useAlphachannel==true.  The alpha of other texels is not modified.
	* Params:
	* 	texture=  Texture whose alpha channel is modified.
	* 	colorKeyPixelPos=  Position of a pixel with the color key
	* color. Every texel with this color will become fully transparent as
	* described above.
	* 	zeroTexels=  \deprecated If set to true, then any texels that match
	* the color key will have their color, as well as their alpha, set to zero
	* (i.e. black). This behavior matches the legacy (buggy) behavior prior
	* to release 1.5 and is provided for backwards compatibility only.
	* This parameter may be removed by Irrlicht 1.9. 
	*/
	void makeColorKeyTexture(ITexture texture,
			vector2d!int colorKeyPixelPos,
			bool zeroTexels = false) const;

	/// Creates a normal map from a height map texture.
	/**
	* If the target texture has 32 bit, the height value is
	* stored in the alpha component of the texture as addition. This
	* value is used by the EMT_PARALLAX_MAP_SOLID material and
	* similar materials.
	* Params:
	* 	texture=  Texture whose alpha channel is modified.
	* 	amplitude=  Constant value by which the height
	* information is multiplied.
	*/
	void makeNormalMapTexture(ITexture texture, float amplitude = 1.0f) const;

	/// Sets a new render target.
	/**
	* This will only work if the driver supports the
	* EVDF_RENDER_TO_TARGET feature, which can be queried with
	* queryFeature(). Usually, rendering to textures is done in this
	* way:
	* Examples:
	* ------
	* // create render target
	* ITexture target = driver.addRenderTargetTexture(dimension2d!uint(128,128), "rtt1");
	* // ...
	* driver.setRenderTarget(target); // set render target
	* // .. draw stuff here
	* driver.setRenderTarget(null); // set previous render target
	* ------
	* Please note that you cannot render 3D or 2D geometry with a
	* render target as texture on it when you are rendering the scene
	* into this render target at the same time. It is usually only
	* possible to render into a texture between the
	* IVideoDriver.beginScene() and endScene() method calls.
	* Params:
	* 	texture=  New render target. Must be a texture created with
	* IVideoDriver.addRenderTargetTexture(). If set to 0, it sets
	* the previous render target which was set before the last
	* setRenderTarget() call.
	* 	clearBackBuffer=  Clears the backbuffer of the render
	* target with the color parameter
	* 	clearZBuffer=  Clears the zBuffer of the rendertarget.
	* Note that because the frame buffer may share the zbuffer with
	* the rendertarget, its zbuffer might be partially cleared too
	* by this.
	* 	color=  The background color for the render target.
	* Returns: True if sucessful and false if not. 
	*/
	bool setRenderTarget(ITexture texture,
		bool clearBackBuffer=true, bool clearZBuffer=true,
		SColor color = SColor(0,0,0,0));

	/// set or reset special render targets
	/**
	* This method enables access to special color buffers such as
	* stereoscopic buffers or auxiliary buffers.
	* Params:
	* 	target=  Enum value for the render target
	* 	clearTarget=  Clears the target buffer with the color
	* parameter
	* 	clearZBuffer=  Clears the zBuffer of the rendertarget.
	* Note that because the main frame buffer may share the zbuffer with
	* the rendertarget, its zbuffer might be partially cleared too
	* by this.
	* 	color=  The background color for the render target.
	* Returns: True if sucessful and false if not. 
	*/
	bool setRenderTarget(E_RENDER_TARGET target, bool clearTarget=true,
				bool clearZBuffer=true,
				SColor color = SColor(0,0,0,0));

	/// Sets new multiple render targets.
	bool setRenderTarget(const IRenderTarget[] texture,
		bool clearBackBuffer=true, bool clearZBuffer=true,
		SColor color=SColor(0,0,0,0));

	/// Sets a new viewport.
	/**
	* Every rendering operation is done into this new area.
	* Params:
	* 	area=  Rectangle defining the new area of rendering
	* operations. 
	*/
	void setViewPort()(auto ref const rect!int area);

	/// Gets the area of the current viewport.
	/**
	* Returns: Rectangle of the current viewport. 
	*/
	auto ref const rect!int getViewPort() const;

	/// Draws a vertex primitive list
	/**
	* Note that, depending on the index type, some vertices might be not
	* accessible through the index list. The limit is at 65535 vertices for 16bit
	* indices. Please note that currently not all primitives are available for
	* all drivers, and some might be emulated via triangle renders.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	vertexCount=  Amount of vertices in the array.
	* 	indexList=  Pointer to array of indices. These define the vertices used
	* for each primitive. Depending on the pType, indices are interpreted as single
	* objects (for point like primitives), pairs (for lines), triplets (for
	* triangles), or quads.
	* 	primCount=  Amount of Primitives
	* 	vType=  Vertex type, e.g. EVT_STANDARD for S3DVertex.
	* 	pType=  Primitive type, e.g. EPT_TRIANGLE_FAN for a triangle fan.
	* 	iType=  Index type, e.g. EIT_16BIT for 16bit indices. 
	*/
	void drawVertexPrimitiveList(const void* vertices, size_t vertexCount,
			const void* indexList, size_t primCount,
			E_VERTEX_TYPE vType=E_VERTEX_TYPE.EVT_STANDARD,
			E_PRIMITIVE_TYPE pType=E_PRIMITIVE_TYPE.EPT_TRIANGLES,
			E_INDEX_TYPE iType=E_INDEX_TYPE.EIT_16BIT);

	/// Draws a vertex primitive list in 2d
	/**
	* Compared to the general (3d) version of this method, this
	* one sets up a 2d render mode, and uses only x and y of vectors.
	* Note that, depending on the index type, some vertices might be
	* not accessible through the index list. The limit is at 65535
	* vertices for 16bit indices. Please note that currently not all
	* primitives are available for all drivers, and some might be
	* emulated via triangle renders. This function is not available
	* for the sw drivers.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	vertexCount=  Amount of vertices in the array.
	* 	indexList=  Pointer to array of indices. These define the
	* vertices used for each primitive. Depending on the pType,
	* indices are interpreted as single objects (for point like
	* primitives), pairs (for lines), triplets (for triangles), or
	* quads.
	* 	primCount=  Amount of Primitives
	* 	vType=  Vertex type, e.g. EVT_STANDARD for S3DVertex.
	* 	pType=  Primitive type, e.g. EPT_TRIANGLE_FAN for a triangle fan.
	* 	iType=  Index type, e.g. EIT_16BIT for 16bit indices. 
	*/
	void draw2DVertexPrimitiveList(const void* vertices, size_t vertexCount,
			const void* indexList, size_t primCount,
			E_VERTEX_TYPE vType=E_VERTEX_TYPE.EVT_STANDARD,
			E_PRIMITIVE_TYPE pType=E_PRIMITIVE_TYPE.EPT_TRIANGLES,
			E_INDEX_TYPE iType=E_INDEX_TYPE.EIT_16BIT);

	/// Draws an indexed triangle list.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices / 3. 
	*/
	final void drawIndexedTriangleList(const S3DVertex[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_STANDARD, E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws an indexed triangle list.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices / 3. 
	*/
	final void drawIndexedTriangleList(const S3DVertex2TCoords[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_2TCOORDS, E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws an indexed triangle list.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices / 3. 
	*/
	final void drawIndexedTriangleList(const S3DVertexTangents[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_TANGENTS, E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws an indexed triangle fan.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices - 2. 
	*/
	final void drawIndexedTriangleFan(const S3DVertex[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_STANDARD, E_PRIMITIVE_TYPE.EPT_TRIANGLE_FAN, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws an indexed triangle fan.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices - 2. 
	*/
	final void drawIndexedTriangleFan(const S3DVertex2TCoords[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_2TCOORDS, E_PRIMITIVE_TYPE.EPT_TRIANGLE_FAN, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws an indexed triangle fan.
	/**
	* Note that there may be at maximum 65536 vertices, because
	* the index list is an array of 16 bit values each with a maximum
	* value of 65536. If there are more than 65536 vertices in the
	* list, results of this operation are not defined.
	* Params:
	* 	vertices=  Pointer to array of vertices.
	* 	indexList=  Pointer to array of indices.
	* 	triangleCount=  Amount of Triangles. Usually amount of indices - 2. 
	*/
	final void drawIndexedTriangleFan(const S3DVertexTangents[] vertices,
		const ushort[] indexList, size_t triangleCount)
	{
		drawVertexPrimitiveList(vertices.ptr, vertices.length, indexList.ptr, triangleCount, E_VERTEX_TYPE.EVT_TANGENTS, E_PRIMITIVE_TYPE.EPT_TRIANGLE_FAN, E_INDEX_TYPE.EIT_16BIT);
	}

	/// Draws a 3d line.
	/**
	* For some implementations, this method simply calls
	* drawVertexPrimitiveList for some triangles.
	* Note that the line is drawn using the current transformation
	* matrix and material. So if you need to draw the 3D line
	* independently of the current transformation, use
	* Examples:
	* ------
	* driver.setMaterial(someMaterial);
	* driver.setTransform(E_TRANSFORMATION_STATE.ETS_WORLD, IdentityMatrix);
	* ------
	* for some properly set up material before drawing the line.
	* Some drivers support line thickness set in the material.
	* Params:
	* 	start=  Start of the 3d line.
	* 	end=  End of the 3d line.
	* 	color=  Color of the line. 
	*/
	void draw3DLine()(auto ref const vector3df start,
		auto ref const vector3df end, SColor color = SColor(255,255,255,255));

	/// Draws a 3d triangle.
	/**
	* This method calls drawVertexPrimitiveList for some triangles.
	* This method works with all drivers because it simply calls
	* drawVertexPrimitiveList, but it is hence not very fast.
	* Note that the triangle is drawn using the current
	* transformation matrix and material. So if you need to draw it
	* independently of the current transformation, use
	* Examples:
	* ------
	* driver.setMaterial(someMaterial);
	* driver.setTransform(ETS_WORLD, IdentityMatrix);
	* ------
	* for some properly set up material before drawing the triangle.
	* Params:
	* 	triangle=  The triangle to draw.
	* 	color=  Color of the line. 
	*/
	void draw3DTriangle()(auto const triangle3df triangle,
		SColor color = SColor(255,255,255,255));

	/// Draws a 3d axis aligned box.
	/**
	* This method simply calls draw3DLine for the edges of the
	* box. Note that the box is drawn using the current transformation
	* matrix and material. So if you need to draw it independently of
	* the current transformation, use
	* Examples:
	* ------
	* driver.setMaterial(someMaterial);
	* driver.setTransform(ETS_WORLD, IdentityMatrix);
	* ------
	* for some properly set up material before drawing the box.
	* Params:
	* 	box=  The axis aligned box to draw
	* 	color=  Color to use while drawing the box. 
	*/
	void draw3DBox()(auto ref const aabbox3d!float box,
		SColor color = SColor(255,255,255,255));

	/// Draws a 2d image without any special effects
	/**
	* Params:
	* 	texture=  Pointer to texture to use.
	* 	destPos=  Upper left 2d destination position where the
	* image will be drawn. 
	*/
	void draw2DImage()(const ITexture texture,
		auto ref const vector2d!int destPos);

	/// Draws a 2d image using a color
	/**
	* (if color is other than
	* Color(255,255,255,255)) and the alpha channel of the texture.
	* Params:
	* 	texture=  Texture to be drawn.
	* 	destPos=  Upper left 2d destination position where the
	* image will be drawn.
	* 	sourceRect=  Source rectangle in the image.
	* 	clipRect=  Pointer to rectangle on the screen where the
	* image is clipped to.
	* If this pointer is NULL the image is not clipped.
	* 	color=  Color with which the image is drawn. If the color
	* equals Color(255,255,255,255) it is ignored. Note that the
	* alpha component is used: If alpha is other than 255, the image
	* will be transparent.
	* 	useAlphaChannelOfTexture=  If true, the alpha channel of
	* the texture is used to draw the image.
	*/
	void draw2DImage()(const ITexture texture, auto ref const vector2d!int destPos,
		auto ref const rect!int sourceRect, const rect!(int)* clipRect = null,
		SColor color=SColor(255,255,255,255), bool useAlphaChannelOfTexture=false);

	/// Draws a set of 2d images, using a color and the alpha channel of the texture.
	/**
	* The images are drawn beginning at pos and concatenated in
	* one line. All drawings are clipped against clipRect (if != 0).
	* The subtextures are defined by the array of sourceRects and are
	* chosen by the indices given.
	* Params:
	* 	texture=  Texture to be drawn.
	* 	pos=  Upper left 2d destination position where the image
	* will be drawn.
	* 	sourceRects=  Source rectangles of the image.
	* 	indices=  List of indices which choose the actual
	* rectangle used each time.
	* 	kerningWidth=  Offset to Position on X
	* 	clipRect=  Pointer to rectangle on the screen where the
	* image is clipped to.
	* If this pointer is 0 then the image is not clipped.
	* 	color=  Color with which the image is drawn.
	* Note that the alpha component is used. If alpha is other than
	* 255, the image will be transparent.
	* 	useAlphaChannelOfTexture=  If true, the alpha channel of
	* the texture is used to draw the image. 
	*/
	void draw2DImageBatch()(const ITexture texture,
			auto ref const position2d!int pos,
			const rect!(int)[] sourceRects,
			const int[] indices,
			int kerningWidth=0,
			const rect!(int)* clipRect = null,
			SColor color=SColor(255,255,255,255),
			bool useAlphaChannelOfTexture=false);

	/// Draws a set of 2d images, using a color and the alpha channel of the texture.
	/**
	* All drawings are clipped against clipRect (if != 0).
	* The subtextures are defined by the array of sourceRects and are
	* positioned using the array of positions.
	* Params:
	* 	texture=  Texture to be drawn.
	* 	positions=  Array of upper left 2d destinations where the
	* images will be drawn.
	* 	sourceRects=  Source rectangles of the image.
	* 	clipRect=  Pointer to rectangle on the screen where the
	* images are clipped to.
	* If this pointer is 0 then the image is not clipped.
	* 	color=  Color with which the image is drawn.
	* Note that the alpha component is used. If alpha is other than
	* 255, the image will be transparent.
	* 	useAlphaChannelOfTexture=  If true, the alpha channel of
	* the texture is used to draw the image. 
	*/
	void draw2DImageBatch()(const ITexture texture,
			const position2d!(int)[] positions,
			const rect!(int)[] sourceRects,
			const rect!(int)* clipRect=null,
			SColor color=SColor(255,255,255,255),
			bool useAlphaChannelOfTexture=false);

	/// Draws a part of the texture into the rectangle. Note that colors must be an array of 4 colors if used.
	/**
	* Suggested and first implemented by zola.
	* Params:
	* 	texture=  The texture to draw from
	* 	destRect=  The rectangle to draw into
	* 	sourceRect=  The rectangle denoting a part of the texture
	* 	clipRect=  Clips the destination rectangle (may be 0)
	* 	colors=  Array of 4 colors denoting the color values of
	* the corners of the destRect
	* 	useAlphaChannelOfTexture=  True if alpha channel will be
	* blended. 
	*/
	void draw2DImage()(const ITexture texture, auto ref const rect!int destRect,
		auto ref const rect!int sourceRect, const rect!(int)* clipRect = null,
		const SColor[4] colors = null, bool useAlphaChannelOfTexture = false);

	/// Draws a 2d rectangle.
	/**
	* Params:
	* 	color=  Color of the rectangle to draw. The alpha
	* component will not be ignored and specifies how transparent the
	* rectangle will be.
	* 	pos=  Position of the rectangle.
	* 	clip=  Pointer to rectangle against which the rectangle
	* will be clipped. If the pointer is null, no clipping will be
	* performed. 
	*/
	void draw2DRectangle()(SColor color, auto ref const rect!int pos,
		const rect!(int)* clip = null);

	/// Draws a 2d rectangle with a gradient.
	/**
	* Params:
	* 	colorLeftUp=  Color of the upper left corner to draw.
	* The alpha component will not be ignored and specifies how
	* transparent the rectangle will be.
	* 	colorRightUp=  Color of the upper right corner to draw.
	* The alpha component will not be ignored and specifies how
	* transparent the rectangle will be.
	* 	colorLeftDown=  Color of the lower left corner to draw.
	* The alpha component will not be ignored and specifies how
	* transparent the rectangle will be.
	* 	colorRightDown=  Color of the lower right corner to draw.
	* The alpha component will not be ignored and specifies how
	* transparent the rectangle will be.
	* 	pos=  Position of the rectangle.
	* 	clip=  Pointer to rectangle against which the rectangle
	* will be clipped. If the pointer is null, no clipping will be
	* performed. 
	*/
	void draw2DRectangle()(auto ref const rect!int pos,
			SColor colorLeftUp, SColor colorRightUp,
			SColor colorLeftDown, SColor colorRightDown,
			const rect!(int)* clip = null);

	/// Draws the outline of a 2D rectangle.
	/**
	* Params:
	* 	pos=  Position of the rectangle.
	* 	color=  Color of the rectangle to draw. The alpha component
	* specifies how transparent the rectangle outline will be. 
	*/
	void draw2DRectangleOutline()(auto ref const recti pos,
			SColor color=SColor(255,255,255,255));

	/// Draws a 2d line. Both start and end will be included in coloring.
	/**
	* Params:
	* 	start=  Screen coordinates of the start of the line
	* in pixels.
	* 	end=  Screen coordinates of the start of the line in
	* pixels.
	* 	color=  Color of the line to draw. 
	*/
	void draw2DLine()(auto ref const position2d!int start,
				auto ref const position2d!int end,
				SColor color = SColor(255,255,255,255));

	/// Draws a pixel.
	/**
	* Params:
	* 	x=  The x-position of the pixel.
	* 	y=  The y-position of the pixel.
	* 	color=  Color of the pixel to draw. 
	*/
	void drawPixel()(uint x, uint y, auto ref const SColor color);

	/// Draws a non filled concyclic regular 2d polyon.
	/**
	* This method can be used to draw circles, but also
	* triangles, tetragons, pentagons, hexagons, heptagons, octagons,
	* enneagons, decagons, hendecagons, dodecagon, triskaidecagons,
	* etc. I think you'll got it now. And all this by simply
	* specifying the vertex count. Welcome to the wonders of
	* geometry.
	* Params:
	* 	center=  Position of center of circle (pixels).
	* 	radius=  Radius of circle in pixels.
	* 	color=  Color of the circle.
	* 	vertexCount=  Amount of vertices of the polygon. Specify 2
	* to draw a line, 3 to draw a triangle, 4 for tetragons and a lot
	* (>10) for nearly a circle. 
	*/
	void draw2DPolygon()(auto ref vector2d!int center,
			float radius,
			SColor color=SColor(100,255,255,255),
			int vertexCount=10);

	/// Draws a shadow volume into the stencil buffer.
	/**
	* To draw a stencil shadow, do this: First, draw all geometry.
	* Then use this method, to draw the shadow volume. Then, use
	* IVideoDriver.drawStencilShadow() to visualize the shadow.
	* Please note that the code for the opengl version of the method
	* is based on free code sent in by Philipp Dortmann, lots of
	* thanks go to him!
	* Params:
	* 	triangles=  Array of 3d vectors, specifying the shadow
	* volume.
	* 	zfail=  If set to true, zfail method is used, otherwise
	* zpass.
	* 	debugDataVisible=  The debug data that is enabled for this
	* shadow node
	*/
	void drawStencilShadowVolume(const vector3df[] triangles, bool zfail=true, uint debugDataVisible=0);

	/// Fills the stencil shadow with color.
	/**
	* After the shadow volume has been drawn into the stencil
	* buffer using IVideoDriver::drawStencilShadowVolume(), use this
	* to draw the color of the shadow.
	* Please note that the code for the opengl version of the method
	* is based on free code sent in by Philipp Dortmann, lots of
	* thanks go to him!
	* Params:
	* 	clearStencilBuffer=  Set this to false, if you want to
	* draw every shadow with the same color, and only want to call
	* drawStencilShadow() once after all shadow volumes have been
	* drawn. Set this to true, if you want to paint every shadow with
	* its own color.
	* 	leftUpEdge=  Color of the shadow in the upper left corner
	* of screen.
	* 	rightUpEdge=  Color of the shadow in the upper right
	* corner of screen.
	* 	leftDownEdge=  Color of the shadow in the lower left
	* corner of screen.
	* 	rightDownEdge=  Color of the shadow in the lower right
	* corner of screen. 
	*/
	void drawStencilShadow(bool clearStencilBuffer=false,
		SColor leftUpEdge = SColor(255,0,0,0),
		SColor rightUpEdge = SColor(255,0,0,0),
		SColor leftDownEdge = SColor(255,0,0,0),
		SColor rightDownEdge = SColor(255,0,0,0));

	/// Draws a mesh buffer
	/**
	* Params:
	* 	mb=  Buffer to draw 
	*/
	void drawMeshBuffer(const IMeshBuffer mb);

	/// Draws normals of a mesh buffer
	/**
	* Params:
	* 	mb=  Buffer to draw the normals of
	* 	length=  length scale factor of the normals
	* 	color=  Color the normals are rendered with
	*/
	void drawMeshBufferNormals(const IMeshBuffer mb, float length=10.0f, SColor color=SColor(0xffffffff));

	/// Sets the fog mode.
	/**
	* These are global values attached to each 3d object rendered,
	* which has the fog flag enabled in its material.
	* Params:
	* 	color=  Color of the fog
	* 	fogType=  Type of fog used
	* 	start=  Only used in linear fog mode (linearFog=true).
	* Specifies where fog starts.
	* 	end=  Only used in linear fog mode (linearFog=true).
	* Specifies where fog ends.
	* 	density=  Only used in exponential fog mode
	* (linearFog=false). Must be a value between 0 and 1.
	* 	pixelFog=  Set this to false for vertex fog, and true if
	* you want per-pixel fog.
	* 	rangeFog=  Set this to true to enable range-based vertex
	* fog. The distance from the viewer is used to compute the fog,
	* not the z-coordinate. This is better, but slower. This might not
	* be available with all drivers and fog settings. 
	*/
	void setFog(SColor color=SColor(0,255,255,255),
			E_FOG_TYPE fogType=E_FOG_TYPE.EFT_FOG_LINEAR,
			float start=50.0f, float end=100.0f, float density=0.01f,
			bool pixelFog=false, bool rangeFog=false);

	/// Gets the fog mode.
	void getFog(out SColor color, out E_FOG_TYPE fogType,
			out float start, out float end, out float density,
			out bool pixelFog, out bool rangeFog);

	/// Get the current color format of the color buffer
	/**
	* Returns: Color format of the color buffer. 
	*/
	ECOLOR_FORMAT getColorFormat() const;

	/// Get the size of the screen or render window.
	/**
	* Returns: Size of screen or render window. 
	*/
	auto ref const dimension2d!uint getScreenSize()() const;

	/// Get the size of the current render target
	/**
	* This method will return the screen size if the driver
	* doesn't support render to texture, or if the current render
	* target is the screen.
	* Returns: Size of render target or screen/window 
	*/
	auto ref const dimension2d!uint getCurrentRenderTargetSize()() const;

	/// Returns current frames per second value.
	/**
	* This value is updated approximately every 1.5 seconds and
	* is only intended to provide a rough guide to the average frame
	* rate. It is not suitable for use in performing timing
	* calculations or framerate independent movement.
	* Returns: Approximate amount of frames per second drawn. 
	*/
	int getFPS() const;

	/// Returns amount of primitives (mostly triangles) which were drawn in the last frame.
	/**
	* Together with getFPS() very useful method for statistics.
	* Params:
	* 	mode=  Defines if the primitives drawn are accumulated or
	* counted per frame.
	* Returns: Amount of primitives drawn in the last frame. 
	*/
	uint getPrimitiveCountDrawn( uint mode =0 ) const;

	/// Deletes all dynamic lights which were previously added with addDynamicLight().
	void deleteAllDynamicLights();

	/// adds a dynamic light, returning an index to the light
	/**
	* Params:
	* light = the light data to use to create the light
	*
	* Returns: An index to the light, or -1 if an error occurs
	*/
	int addDynamicLight()(auto ref const SLight light);

	/// Returns the maximal amount of dynamic lights the device can handle
	/**
	* Returns: Maximal amount of dynamic lights. 
	*/
	size_t getMaximalDynamicLightAmount() const;

	/// Returns amount of dynamic lights currently set
	/**
	* Returns: Amount of dynamic lights currently set 
	*/
	size_t getDynamicLightCount() const;

	/// Returns light data which was previously set by IVideoDriver::addDynamicLight().
	/**
	* Params:
	* 	idx=  Zero based index of the light. Must be 0 or
	* greater and smaller than IVideoDriver::getDynamicLightCount.
	* Returns: Light data. 
	*/
	auto ref const SLight getDynamicLight(size_t idx) const;

	/// Turns a dynamic light on or off
	/**
	* Params:
	* lightIndex = the index returned by addDynamicLight
	* turnOn = true to turn the light on, false to turn it off
	*/
	void turnLightOn(size_t lightIndex, bool turnOn);

	/// Gets name of this video driver.
	/**
	* Returns: Returns the name of the video driver, e.g. in case
	* of the Direct3D8 driver, it would return "Direct3D 8.1". 
	*/
	wstring getName() const;

	/// Adds an external image loader to the engine.
	/**
	* This is useful if the Irrlicht Engine should be able to load
	* textures of currently unsupported file formats (e.g. gif). The
	* IImageLoader only needs to be implemented for loading this file
	* format. A pointer to the implementation can be passed to the
	* engine using this method.
	* Params:
	* 	loader=  Pointer to the external loader created. 
	*/
	void addExternalImageLoader(IImageLoader loader);

	/// Adds an external image writer to the engine.
	/**
	* This is useful if the Irrlicht Engine should be able to
	* write textures of currently unsupported file formats (e.g
	* .gif). The IImageWriter only needs to be implemented for
	* writing this file format. A pointer to the implementation can
	* be passed to the engine using this method.
	* Params:
	* 	writer=  Pointer to the external writer created. 
	*/
	void addExternalImageWriter(IImageWriter writer);

	/// Returns the maximum amount of primitives
	/**
	* (mostly vertices) which the device is able to render with
	* one drawVertexPrimitiveList call.
	* Returns: Maximum amount of primitives. 
	*/
	size_t getMaximalPrimitiveCount() const;

	/// Enables or disables a texture creation flag.
	/**
	* These flags define how textures should be created. By
	* changing this value, you can influence for example the speed of
	* rendering a lot. But please note that the video drivers take
	* this value only as recommendation. It could happen that you
	* enable the ETCF_ALWAYS_16_BIT mode, but the driver still creates
	* 32 bit textures.
	* Params:
	* 	flag=  Texture creation flag.
	* 	enabled=  Specifies if the given flag should be enabled or
	* disabled. 
	*/
	void setTextureCreationFlag(E_TEXTURE_CREATION_FLAG flag, bool enabled=true);

	/// Returns if a texture creation flag is enabled or disabled.
	/**
	* You can change this value using setTextureCreationFlag().
	* Params:
	* 	flag=  Texture creation flag.
	* Returns: The current texture creation flag enabled mode. 
	*/
	bool getTextureCreationFlag(E_TEXTURE_CREATION_FLAG flag) const;

	/// Creates a software image from a file.
	/**
	* No hardware texture will be created for this image. This
	* method is useful for example if you want to read a heightmap
	* for a terrain renderer.
	* Params:
	* 	filename=  Name of the file from which the image is
	* created.
	* Returns: The created image. 
	*/
	IImage createImageFromFile(const Path filename);

	/// Creates a software image from a file.
	/**
	* No hardware texture will be created for this image. This
	* method is useful for example if you want to read a heightmap
	* for a terrain renderer.
	* Params:
	* 	file=  File from which the image is created.
	* Returns: The created image.
	*/
	IImage createImageFromFile(IReadFile file);

	/// Writes the provided image to a file.
	/**
	* Requires that there is a suitable image writer registered
	* for writing the image.
	* Params:
	* 	image=  Image to write.
	* 	filename=  Name of the file to write.
	* 	param=  Control parameter for the backend (e.g. compression
	* level).
	* Returns: True on successful write. 
	*/
	bool writeImageToFile(IImage image, const Path filename, uint param = 0);

	/// Writes the provided image to a file.
	/**
	* Requires that there is a suitable image writer registered
	* for writing the image.
	* Params:
	* 	image=  Image to write.
	* 	file=   An already open IWriteFile object. The name
	* will be used to determine the appropriate image writer to use.
	* 	param=  Control parameter for the backend (e.g. compression
	* level).
	* Returns: True on successful write. 
	*/
	bool writeImageToFile(IImage image, IWriteFile file, uint param =0);

	/// Creates a software image from a byte array.
	/**
	* No hardware texture will be created for this image. This
	* method is useful for example if you want to read a heightmap
	* for a terrain renderer.
	* Params:
	* 	format=  Desired color format of the texture
	* 	size=  Desired size of the image
	* 	data=  A byte array with pixel color information
	* 	ownForeignMemory=  If true, the image will use the data
	* pointer directly and own it afterwards. If false, the memory
	* will by copied internally.
	* 	deleteMemory=  Whether the memory is deallocated upon
	* destruction.
	* Returns: The created image.
	*/
	IImage createImageFromData()(ECOLOR_FORMAT format,
		auto ref const dimension2d!uint size, void *data,
		bool ownForeignMemory=false,
		bool deleteMemory = true);

	/// Creates an empty software image.
	/**
	* Params:
	* 	format=  Desired color format of the image.
	* 	size=  Size of the image to create.
	* Returns: The created image.
	*/
	IImage createImage()(ECOLOR_FORMAT format, auto ref const dimension2d!uint size);

	/// Creates a software image by converting it to given format from another image.
	/**
	* Deprecated:  Create an empty image and use copyTo(). This method may be removed by Irrlicht 1.9.
	* Params:
	* 	format=  Desired color format of the image.
	* 	imageToCopy=  Image to copy to the new image.
	* Returns: The created image.
	*/
	deprecated IImage createImage()(ECOLOR_FORMAT format, IImage imageToCopy);

	/// Creates a software image from a part of another image.
	/**
	* Deprecated:  Create an empty image and use copyTo(). This method may be removed by Irrlicht 1.9.
	* Params:
	* 	imageToCopy=  Image to copy to the new image in part.
	* 	pos=  Position of rectangle to copy.
	* 	size=  Extents of rectangle to copy.
	* Returns: The created image.
	*/
	deprecated IImage createImage()(IImage imageToCopy,
			auto ref const position2d!int pos,
			auto ref const dimension2d!uint size);

	/// Creates a software image from a part of a texture.
	/**
	* Params:
	* 	texture=  Texture to copy to the new image in part.
	* 	pos=  Position of rectangle to copy.
	* 	size=  Extents of rectangle to copy.
	* Returns: The created image.
	*/
	IImage createImage()(ITexture texture,
			auto ref const position2d!int pos,
			auto ref const dimension2d!uint size);

	/// Event handler for resize events. Only used by the engine internally.
	/**
	* Used to notify the driver that the window was resized.
	* Usually, there is no need to call this method. 
	*/
	void OnResize()(auto ref const dimension2d!uint size);

	/// Adds a new material renderer to the video device.
	/**
	* Use this method to extend the VideoDriver with new material
	* types. To extend the engine using this method do the following:
	* Derive a class from IMaterialRenderer and override the methods
	* you need. For setting the right renderstates, you can try to
	* get a pointer to the real rendering device using
	* IVideoDriver::getExposedVideoData(). Add your class with
	* IVideoDriver::addMaterialRenderer(). To use an object being
	* displayed with your new material, set the MaterialType member of
	* the SMaterial struct to the value returned by this method.
	* If you simply want to create a new material using vertex and/or
	* pixel shaders it would be easier to use the
	* IGPUProgrammingServices interface which you can get
	* using the getGPUProgrammingServices() method.
	* Params:
	* 	renderer=  A pointer to the new renderer.
	* 	name=  Optional name for the material renderer entry.
	* Returns: The number of the material type which can be set in
	* SMaterial::MaterialType to use the renderer. -1 is returned if
	* an error occured. For example if you tried to add an material
	* renderer to the software renderer or the null device, which do
	* not accept material renderers. 
	*/
	int addMaterialRenderer(IMaterialRenderer renderer, string name = "");

	/// Get access to a material renderer by index.
	/**
	* Params:
	* 	idx=  Id of the material renderer. Can be a value of
	* the E_MATERIAL_TYPE enum or a value which was returned by
	* addMaterialRenderer().
	* Returns: Pointer to material renderer or null if not existing. 
	*/
	IMaterialRenderer getMaterialRenderer(size_t idx);

	/// Get amount of currently available material renderers.
	/**
	* Returns: Amount of currently available material renderers. 
	*/
	size_t getMaterialRendererCount() const;

	/// Get name of a material renderer
	/**
	* This string can, e.g., be used to test if a specific
	* renderer already has been registered/created, or use this
	* string to store data about materials: This returned name will
	* be also used when serializing materials.
	* Params:
	* 	idx=  Id of the material renderer. Can be a value of the
	* E_MATERIAL_TYPE enum or a value which was returned by
	* addMaterialRenderer().
	* Returns: String with the name of the renderer, or 0 if not
	* exisiting 
	*/
	string getMaterialRendererName(size_t idx) const;

	/// Sets the name of a material renderer.
	/**
	* Will have no effect on built-in material renderers.
	* Params:
	* 	idx=  Id of the material renderer. Can be a value of the
	* E_MATERIAL_TYPE enum or a value which was returned by
	* addMaterialRenderer().
	* 	name=  New name of the material renderer. 
	*/
	void setMaterialRendererName(size_t idx, string name);

	/// Creates material attributes list from a material
	/**
	* This method is useful for serialization and more.
	* Please note that the video driver will use the material
	* renderer names from getMaterialRendererName() to write out the
	* material type name, so they should be set before.
	* Params:
	* 	material=  The material to serialize.
	* 	options=  Additional options which might influence the
	* serialization.
	* Returns: The IAttributes container holding the material
	* properties. 
	*/
	IAttributes createAttributesFromMaterial(const SMaterial material,
		SAttributeReadWriteOptions options = SAttributeReadWriteOptions());

	/// Fills an SMaterial structure from attributes.
	/**
	* Please note that for setting material types of the
	* material, the video driver will need to query the material
	* renderers for their names, so all non built-in materials must
	* have been created before calling this method.
	* Params:
	* 	outMaterial=  The material to set the properties for.
	* 	attributes=  The attributes to read from. 
	*/
	void fillMaterialStructureFromAttributes(SMaterial outMaterial, IAttributes attributes);

	/// Returns driver and operating system specific data about the IVideoDriver.
	/**
	* This method should only be used if the engine should be
	* extended without having to modify the source of the engine.
	* Returns: Collection of device dependent pointers. 
	*/
	auto ref const SExposedVideoData getExposedVideoData()();

	/// Get type of video driver
	/**
	* Returns: Type of driver. 
	*/
	E_DRIVER_TYPE getDriverType() const;

	/// Gets the IGPUProgrammingServices interface.
	/**
	* Returns: Pointer to the IGPUProgrammingServices. Returns 0
	* if the video driver does not support this. For example the
	* Software driver and the Null driver will always return 0. 
	*/
	IGPUProgrammingServices getGPUProgrammingServices();

	/// Returns a pointer to the mesh manipulator.
	IMeshManipulator getMeshManipulator();

	/// Clears the ZBuffer.
	/**
	* Note that you usually need not to call this method, as it
	* is automatically done in IVideoDriver::beginScene() or
	* IVideoDriver::setRenderTarget() if you enable zBuffer. But if
	* you have to render some special things, you can clear the
	* zbuffer during the rendering process with this method any time.
	*/
	void clearZBuffer();

	/// Make a screenshot of the last rendered frame.
	/**
	* Returns: An image created from the last rendered frame. 
	*/
	IImage createScreenShot(ECOLOR_FORMAT format=ECOLOR_FORMAT.ECF_UNKNOWN, E_RENDER_TARGET target=E_RENDER_TARGET.ERT_FRAME_BUFFER);

	/// Check if the image is already loaded.
	/**
	* Works similar to getTexture(), but does not load the texture
	* if it is not currently loaded.
	* Params:
	* 	filename=  Name of the texture.
	* Returns: Pointer to loaded texture, or 0 if not found. 
	*/
	ITexture findTexture(const Path filename);

	/// Set or unset a clipping plane.
	/**
	* There are at least 6 clipping planes available for the user
	* to set at will.
	* Params:
	* 	index=  The plane index. Must be between 0 and
	* MaxUserClipPlanes.
	* 	plane=  The plane itself.
	* 	enable=  If true, enable the clipping plane else disable
	* it.
	* Returns: True if the clipping plane is usable. 
	*/
	bool setClipPlane()(size_t index, auto ref const plane3df plane, bool enable=false);

	/// Enable or disable a clipping plane.
	/**
	* There are at least 6 clipping planes available for the user
	* to set at will.
	* Params:
	* 	index=  The plane index. Must be between 0 and
	* MaxUserClipPlanes.
	* 	enable=  If true, enable the clipping plane else disable
	* it. 
	*/
	void enableClipPlane(size_t index, bool enable);

	/// Set the minimum number of vertices for which a hw buffer will be created
	/**
	* Params:
	* 	count=  Number of vertices to set as minimum. 
	*/
	void setMinHardwareBufferVertexCount(size_t count);

	/// Get the global Material, which might override local materials.
	/**
	* Depending on the enable flags, values from this Material
	* are used to override those of local materials of some
	* meshbuffer being rendered.
	* Returns: Reference to the Override Material. 
	*/
	ref SOverrideMaterial getOverrideMaterial();

	/// Get the 2d override material for altering its values
	/**
	* The 2d override materual allows to alter certain render
	* states of the 2d methods. Not all members of SMaterial are
	* honored, especially not MaterialType and Textures. Moreover,
	* the zbuffer is always ignored, and lighting is always off. All
	* other flags can be changed, though some might have to effect
	* in most cases.
	* Please note that you have to enable/disable this effect with
	* enableInitMaterial2D(). This effect is costly, as it increases
	* the number of state changes considerably. Always reset the
	* values when done.
	* Returns: Material reference which should be altered to reflect
	* the new settings.
	*/
	ref SMaterial getMaterial2D();

	/// Enable the 2d override material
	/**
	* Params:
	* 	enable=  Flag which tells whether the material shall be
	* enabled or disabled. 
	*/
	void enableMaterial2D(bool enable=true);

	/// Get the graphics card vendor name.
	string getVendorInfo();

	/// Only used by the engine internally.
	/**
	* The ambient color is set in the scene manager, see
	* ISceneManager::setAmbientLight().
	* Params:
	* 	color=  New color of the ambient light. 
	*/
	void setAmbientLight()(auto ref const SColorf color);

	/// Only used by the engine internally.
	/**
	* Passes the global material flag AllowZWriteOnTransparent.
	* Use the SceneManager attribute to set this value from your app.
	* Params:
	* 	flag=  Default behavior is to disable ZWrite, i.e. false. 
	*/
	void setAllowZWriteOnTransparent(bool flag);

	/// Get the maximum texture size supported.
	dimension2du getMaxTextureSize() const;

	/// Color conversion convenience function
	/**
	* Convert an image (as array of pixels) from source to destination
	* array, thereby converting the color format. The pixel size is
	* determined by the color formats.
	* Params:
	* 	sP=  Pointer to source
	* 	sF=  Color format of source
	* 	sN=  Number of pixels to convert, both array must be large enough
	* 	dP=  Pointer to destination
	* 	dF=  Color format of destination
	*/
	void convertColor(const void* sP, ECOLOR_FORMAT sF, int sN,
			void* dP, ECOLOR_FORMAT dF) const;
}
