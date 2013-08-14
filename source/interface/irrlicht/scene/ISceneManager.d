// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ISceneManager;

import irrlicht.io.path;
import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;
import irrlicht.video.SColor;
import irrlicht.scene.ETerrainElements;
import irrlicht.scene.ESceneNodeTypes;
import irrlicht.scene.ESceneNodeAnimatorTypes;
import irrlicht.scene.EMeshWriterEnums;
import irrlicht.scene.SceneParameters;
import irrlicht.scene.IGeometryCreator;
import irrlicht.scene.ISkinnedMesh;
import irrlicht.SKeyMap;
import irrlicht.IEventReceiver;
import irrlicht.io.IReadFile;
import irrlicht.io.IAttributes;
import irrlicht.io.IWriteFile;
import irrlicht.io.IFileSystem;
import irrlicht.io.IXMLWriter;
import irrlicht.video.IVideoDriver;
import irrlicht.video.SMaterial;
import irrlicht.video.IImage;
import irrlicht.video.ITexture;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.IAnimatedMeshSceneNode;
import irrlicht.scene.IBillboardSceneNode;
import irrlicht.scene.IBillboardTextSceneNode;
import irrlicht.scene.ICameraSceneNode;
import irrlicht.scene.IDummyTransformationSceneNode;
import irrlicht.scene.ILightManager;
import irrlicht.scene.ILightSceneNode;
import irrlicht.scene.IMesh;
import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.IMeshCache;
import irrlicht.scene.IMeshLoader;
import irrlicht.scene.IMeshManipulator;
import irrlicht.scene.IMeshSceneNode;
import irrlicht.scene.IMeshWriter;
import irrlicht.scene.IMetaTriangleSelector;
import irrlicht.scene.IParticleSystemSceneNode;
import irrlicht.scene.ISceneCollisionManager;
import irrlicht.scene.ISceneLoader;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneNodeFactory;
import irrlicht.scene.ISceneNodeAnimator;
import irrlicht.scene.ISceneNodeAnimatorCollisionResponse;
import irrlicht.scene.ISceneNodeAnimatorFactory;
import irrlicht.scene.ISceneUserDataSerializer;
import irrlicht.scene.ITerrainSceneNode;
import irrlicht.scene.ITextSceneNode;
import irrlicht.scene.ITriangleSelector;
import irrlicht.scene.IVolumeLightSceneNode;
import irrlicht.scene.quake3.IQ3Shader;
import irrlicht.gui.IGUIFont;
import irrlicht.gui.IGUIEnvironment;

/// Enumeration for render passes.
/** 
* A parameter passed to the registerNodeForRendering() method of 
* the ISceneManager, specifying when the node wants to be drawn 
* in relation to the other nodes. 
*/
enum E_SCENE_NODE_RENDER_PASS
{
	/// No pass currently active
	ESNRP_NONE = 0,

	/// Camera pass. The active view is set up here. The very first pass.
	ESNRP_CAMERA = 1,

	/// In this pass, lights are transformed into camera space and added to the driver
	ESNRP_LIGHT = 2,

	/// This is used for sky boxes.
	ESNRP_SKY_BOX = 4,

	/// All normal objects can use this for registering themselves.
	/** 
	* This value will never be returned by
	* ISceneManager.getSceneNodeRenderPass(). The scene manager
	* will determine by itself if an object is transparent or solid
	* and register the object as SNRT_TRANSPARENT or SNRT_SOLD
	* automatically if you call registerNodeForRendering with this
	* value (which is default). Note that it will register the node
	* only as ONE type. If your scene node has both solid and
	* transparent material types register it twice (one time as
	* SNRT_SOLID, the other time as SNRT_TRANSPARENT) and in the
	* render() method call getSceneNodeRenderPass() to find out the
	* current render pass and render only the corresponding parts of
	* the node. 
	*/
	ESNRP_AUTOMATIC = 24,

	/// Solid scene nodes or special scene nodes without materials.
	ESNRP_SOLID = 8,

	/// Transparent scene nodes, drawn after solid nodes. They are sorted from back to front and drawn in that order.
	ESNRP_TRANSPARENT = 16,

	/// Transparent effect scene nodes, drawn after Transparent nodes. They are sorted from back to front and drawn in that order.
	ESNRP_TRANSPARENT_EFFECT = 32,

	/// Drawn after the solid nodes, before the transparent nodes, the time for drawing shadow volumes
	ESNRP_SHADOW = 64
}


/// The Scene Manager manages scene nodes, mesh recources, cameras and all the other stuff.
/**
* All Scene nodes can be created only here. There is a always growing
* list of scene nodes for lots of purposes: Indoor rendering scene nodes
* like the Octree (addOctreeSceneNode()) or the terrain renderer
* (addTerrainSceneNode()), different Camera scene nodes
* (addCameraSceneNode(), addCameraSceneNodeMaya()), scene nodes for Light
* (addLightSceneNode()), Billboards (addBillboardSceneNode()) and so on.
* A scene node is a node in the hierachical scene graph. Every scene node
* may have children, which are other scene nodes. Children move relative
* the their parents position. If the parent of a node is not visible, its
* children won't be visible, too. In this way, it is for example easily
* possible to attach a light to a moving car or to place a walking
* character on a moving platform on a moving ship.
* The SceneManager is also able to load 3d mesh files of different
* formats. Take a look at getMesh() to find out what formats are
* supported. If these formats are not enough, use
* addExternalMeshLoader() to add new formats to the engine.
*/
interface ISceneManager
{
	/// Get pointer to an animateable mesh. Loads the file if not loaded already.
	/**
	 * If you want to remove a loaded mesh from the cache again, use removeMesh().
	 *  Currently there are the following mesh formats supported:
	 *  <TABLE border="1" cellpadding="2" cellspacing="0">
	 *  <TR>
	 *    <TD>Format</TD>
	 *    <TD>Description</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>3D Studio (.3ds)</TD>
	 *    <TD>Loader for 3D-Studio files which lots of 3D packages
	 *      are able to export. Only static meshes are currently
	 *      supported by this importer.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>3D World Studio (.smf)</TD>
	 *    <TD>Loader for Leadwerks SMF mesh files, a simple mesh format
	 *    containing static geometry for games. The proprietary .STF texture format
	 *    is not supported yet. This loader was originally written by Joseph Ellis. </TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Bliz Basic B3D (.b3d)</TD>
	 *    <TD>Loader for blitz basic files, developed by Mark
	 *      Sibly. This is the ideal animated mesh format for game
	 *      characters as it is both rigidly defined and widely
	 *      supported by modeling and animation software.
	 *      As this format supports skeletal animations, an
	 *      ISkinnedMesh will be returned by this importer.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Cartography shop 4 (.csm)</TD>
	 *    <TD>Cartography Shop is a modeling program for creating
	 *      architecture and calculating lighting. Irrlicht can
	 *      directly import .csm files thanks to the IrrCSM library
	 *      created by Saurav Mohapatra which is now integrated
	 *      directly in Irrlicht. If you are using this loader,
	 *      please note that you'll have to set the path of the
	 *      textures before loading .csm files. You can do this
	 *      using
	 *      SceneManager.getParameters().setAttribute(CSM_TEXTURE_PATH,
	 *      "path/to/your/textures");</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>COLLADA (.dae, .xml)</TD>
	 *    <TD>COLLADA is an open Digital Asset Exchange Schema for
	 *        the interactive 3D industry. There are exporters and
	 *        importers for this format available for most of the
	 *        big 3d packagesat http://collada.org. Irrlicht can
	 *        import COLLADA files by using the
	 *        ISceneManager.getMesh() method. COLLADA files need
	 *        not contain only one single mesh but multiple meshes
	 *        and a whole scene setup with lights, cameras and mesh
	 *        instances, this loader can set up a scene as
	 *        described by the COLLADA file instead of loading and
	 *        returning one single mesh. By default, this loader
	 *        behaves like the other loaders and does not create
	 *        instances, but it can be switched into this mode by
	 *        using
	 *        SceneManager.getParameters().setAttribute(COLLADA_CREATE_SCENE_INSTANCES, true);
	 *        Created scene nodes will be named as the names of the
	 *        nodes in the COLLADA file. The returned mesh is just
	 *        a dummy object in this mode. Meshes included in the
	 *        scene will be added into the scene manager with the
	 *        following naming scheme:
	 *        "path/to/file/file.dea#meshname". The loading of such
	 *        meshes is logged. Currently, this loader is able to
	 *        create meshes (made of only polygons), lights, and
	 *        cameras. Materials and animations are currently not
	 *        supported but this will change with future releases.
	 *    </TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Delgine DeleD (.dmf)</TD>
	 *    <TD>DeleD (delgine.com) is a 3D editor and level-editor
	 *        combined into one and is specifically designed for 3D
	 *        game-development. With this loader, it is possible to
	 *        directly load all geometry is as well as textures and
	 *        lightmaps from .dmf files. To set texture and
	 *        material paths, see DMF_USE_MATERIALS_DIRS and
	 *        DMF_TEXTURE_PATH. It is also possible to flip
	 *        the alpha texture by setting
	 *        DMF_FLIP_ALPHA_TEXTURES to true and to set the
	 *        material transparent reference value by setting
	 *        DMF_ALPHA_CHANNEL_REF to a float between 0 and
	 *        1. The loader is based on Salvatore Russo's .dmf
	 *        loader, I just changed some parts of it. Thanks to
	 *        Salvatore for his work and for allowing me to use his
	 *        code in Irrlicht and put it under Irrlicht's license.
	 *        For newer and more enchanced versions of the loader,
	 *        take a look at delgine.com.
	 *    </TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>DirectX (.x)</TD>
	 *    <TD>Platform independent importer (so not D3D-only) for
	 *      .x files. Most 3D packages can export these natively
	 *      and there are several tools for them available, e.g.
	 *      the Maya exporter included in the DX SDK.
	 *      .x files can include skeletal animations and Irrlicht
	 *      is able to play and display them, users can manipulate
	 *      the joints via the ISkinnedMesh interface. Currently,
	 *      Irrlicht only supports uncompressed .x files.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Half-Life model (.mdl)</TD>
	 *    <TD>This loader opens Half-life 1 models, it was contributed
	 *        by Fabio Concas and adapted by Thomas Alten.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Irrlicht Mesh (.irrMesh)</TD>
	 *    <TD>This is a static mesh format written in XML, native
	 *      to Irrlicht and written by the irr mesh writer.
	 *      This format is exported by the CopperCube engine's
	 *      lightmapper.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>LightWave (.lwo)</TD>
	 *    <TD>Native to NewTek's LightWave 3D, the LWO format is well
	 *      known and supported by many exporters. This loader will
	 *      import LWO2 models including lightmaps, bumpmaps and
	 *      reflection textures.</TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Maya (.obj)</TD>
	 *    <TD>Most 3D software can create .obj files which contain
	 *      static geometry without material data. The material
	 *      files .mtl are also supported. This importer for
	 *      Irrlicht can load them directly. </TD>
	 *  </TR>
	 *  <TR>
	 *    <TD>Milkshape (.ms3d)</TD>
	 *    <TD>.MS3D files contain models and sometimes skeletal
	 *      animations from the Milkshape 3D modeling and animation
	 *      software. Like the other skeletal mesh loaders, oints
	 *      are exposed via the ISkinnedMesh animated mesh type.</TD>
	 *  </TR>
	 *  <TR>
	 *  <TD>My3D (.my3d)</TD>
	 *      <TD>.my3D is a flexible 3D file format. The My3DTools
	 *        contains plug-ins to export .my3D files from several
	 *        3D packages. With this built-in importer, Irrlicht
	 *        can read and display those files directly. This
	 *        loader was written by Zhuck Dimitry who also created
	 *        the whole My3DTools package. If you are using this
	 *        loader, please note that you can set the path of the
	 *        textures before loading .my3d files. You can do this
	 *        using
	 *        SceneManager.getParameters().setAttribute(MY3D_TEXTURE_PATH,
	 *        "path/to/your/textures");
	 *        </TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>OCT (.oct)</TD>
	 *      <TD>The oct file format contains 3D geometry and
	 *        lightmaps and can be loaded directly by Irrlicht. OCT
	 *        files<br> can be created by FSRad, Paul Nette's
	 *        radiosity processor or exported from Blender using
	 *        OCTTools which can be found in the exporters/OCTTools
	 *        directory of the SDK. Thanks to Murphy McCauley for
	 *        creating all this.</TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>OGRE Meshes (.mesh)</TD>
	 *      <TD>Ogre .mesh files contain 3D data for the OGRE 3D
	 *        engine. Irrlicht can read and display them directly
	 *        with this importer. To define materials for the mesh,
	 *        copy a .material file named like the corresponding
	 *        .mesh file where the .mesh file is. (For example
	 *        ogrehead.material for ogrehead.mesh). Thanks to
	 *        Christian Stehno who wrote and contributed this
	 *        loader.</TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Pulsar LMTools (.lmts)</TD>
	 *      <TD>LMTools is a set of tools (Windows &amp; Linux) for
	 *        creating lightmaps. Irrlicht can directly read .lmts
	 *        files thanks to<br> the importer created by Jonas
	 *        Petersen. If you are using this loader, please note
	 *        that you can set the path of the textures before
	 *        loading .lmts files. You can do this using
	 *        SceneManager.getParameters().setAttribute(LMTS_TEXTURE_PATH,
	 *        "path/to/your/textures");
	 *        Notes for<br> this version of the loader:<br>
	 *        - It does not recognise/support user data in the
	 *          *.lmts files.<br>
	 *        - The TGAs generated by LMTools don't work in
	 *          Irrlicht for some reason (the textures are upside
	 *          down). Opening and resaving them in a graphics app
	 *          will solve the problem.</TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Quake 3 levels (.bsp)</TD>
	 *      <TD>Quake 3 is a popular game by IDSoftware, and .pk3
	 *        files contain .bsp files and textures/lightmaps
	 *        describing huge prelighted levels. Irrlicht can read
	 *        .pk3 and .bsp files directly and thus render Quake 3
	 *        levels directly. Written by Nikolaus Gebhardt
	 *        enhanced by Dean P. Macri with the curved surfaces
	 *        feature. </TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Quake 2 models (.md2)</TD>
	 *      <TD>Quake 2 models are characters with morph target
	 *        animation. Irrlicht can read, display and animate
	 *        them directly with this importer. </TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Quake 3 models (.md3)</TD>
	 *      <TD>Quake 3 models are characters with morph target
	 *        animation, they contain mount points for weapons and body
	 *        parts and are typically made of several sections which are
	 *        manually joined together.</TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Stanford Triangle (.ply)</TD>
	 *      <TD>Invented by Stanford University and known as the native
	 *        format of the infamous "Stanford Bunny" model, this is a
	 *        popular static mesh format used by 3D scanning hardware
	 *        and software. This loader supports extremely large models
	 *        in both ASCII and binary format, but only has rudimentary
	 *        material support in the form of vertex colors and texture
	 *        coordinates.</TD>
	 *    </TR>
	 *    <TR>
	 *      <TD>Stereolithography (.stl)</TD>
	 *      <TD>The STL format is used for rapid prototyping and
	 *        computer-aided manufacturing, thus has no support for
	 *        materials.</TD>
	 *    </TR>
	 *  </TABLE>
	 *  To load and display a mesh quickly, just do this:
	* Examples:
	* ------
	*  SceneManager.addAnimatedMeshSceneNode(
	*		SceneManager.getMesh("yourmesh.3ds"));
	* ------
	* If you would like to implement and add your own file format loader to Irrlicht,
	* see addExternalMeshLoader().
	* Params:
	* 	filename=  Filename of the mesh to load.
	* Returns: Null if failed, otherwise pointer to the mesh.
	**/
	IAnimatedMesh getMesh(const Path filename);

	/// Get pointer to an animateable mesh. Loads the file if not loaded already.
	/**
	* Works just as getMesh(const char* filename). If you want to
	* remove a loaded mesh from the cache again, use removeMesh().
	* Params:
	* 	file=  File handle of the mesh to load.
	* Returns: NULL if failed and pointer to the mesh if successful.
	*/
	IAnimatedMesh getMesh(IReadFile file);

	/// Get interface to the mesh cache which is shared beween all existing scene managers.
	/**
	* With this interface, it is possible to manually add new loaded
	* meshes (if ISceneManager.getMesh() is not sufficient), to remove them and to iterate
	* through already loaded meshes. 
	*/
	IMeshCache getMeshCache();

	/// Get the video driver.
	/**
	* Returns: Pointer to the video Driver.
	*/
	IVideoDriver getVideoDriver();

	/// Get the active GUIEnvironment
	/**
	* Returns: Pointer to the GUIEnvironment
	*/
	IGUIEnvironment getGUIEnvironment();

	/// Get the active FileSystem
	/**
	* Returns: Pointer to the FileSystem
	*/
	IFileSystem getFileSystem();

	/// adds Volume Lighting Scene Node.
	/**
	* Example Usage:
	*	 IVolumeLightSceneNode n = smgr.addVolumeLightSceneNode(0, -1,
	*				 32, 32, //Subdivide U/V
	*				 SColor(0, 180, 180, 180), //foot color
	*				 SColor(0, 0, 0, 0) //tail color
	*				 );
	*	 if (n !is null)
	*	 {
	*		 n.setScale(vector3df(46.0f, 45.0f, 46.0f));
	*		 n.getMaterial(0).setTexture(0, smgr.getVideoDriver().getTexture("lightFalloff.png"));
	*	 }
	* Returns: Pointer to the volumeLight if successful, otherwise NULL.
	*/
	IVolumeLightSceneNode addVolumeLightSceneNode(ISceneNode parent = null, int id = -1,
		const uint subdivU = 32, const uint subdivV = 32,
		const SColor foot = SColor(51, 0, 230, 180),
		const SColor tail = SColor(0, 0, 0, 0),
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f));

	/// Adds a cube scene node
	/**
	* Params:
	* 	size=  Size of the cube, uniformly in each dimension.
	* 	parent=  Parent of the scene node. Can be 0 if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent
	* where the scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* Returns: Pointer to the created test scene node. 
	* for more information. 
	*/
	IMeshSceneNode addCubeSceneNode(float size = 10.0f, ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f));

	/// Adds a sphere scene node of the given radius and detail
	/**
	* Params:
	* 	radius=  Radius of the sphere.
	* 	polyCount=  The number of vertices in horizontal and
	* vertical direction. The total polyCount of the sphere is
	* polyCount*polyCount. This parameter must be less than 256 to
	* stay within the 16-bit limit of the indices of a meshbuffer.
	* 	parent=  Parent of the scene node. Can be 0 if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent
	* where the scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* Returns: Pointer to the created test scene node. 
	* for more information. 
	*/
	IMeshSceneNode addSphereSceneNode(float radius = 5.0f, int polyCount = 16,
			ISceneNode parent = null, int id = -1,
			const vector3df position = vector3df(0,0,0),
			const vector3df rotation = vector3df(0,0,0),
			const vector3df scale = vector3df(1.0f, 1.0f, 1.0f));

	/// Adds a scene node for rendering an animated mesh model.
	/**
	* Params:
	* 	mesh=  Pointer to the loaded animated mesh to be displayed.
	* 	parent=  Parent of the scene node. Can be NULL if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent where the
	* scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* 	alsoAddIfMeshPointerZero=  Add the scene node even if a 0 pointer is passed.
	* Returns: Pointer to the created scene node.
	*/
	IAnimatedMeshSceneNode addAnimatedMeshSceneNode(IAnimatedMesh mesh,
			ISceneNode parent = null, int id = -1,
			const vector3df position = vector3df(0,0,0),
			const vector3df rotation = vector3df(0,0,0),
			const vector3df scale = vector3df(1.0f, 1.0f, 1.0f),
			bool alsoAddIfMeshPointerZero=false);

	/// Adds a scene node for rendering a static mesh.
	/**
	* Params:
	* 	mesh=  Pointer to the loaded static mesh to be displayed.
	* 	parent=  Parent of the scene node. Can be NULL if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent where the
	* scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* 	alsoAddIfMeshPointerZero=  Add the scene node even if a 0 pointer is passed.
	* Returns: Pointer to the created scene node. 
	*/
	IMeshSceneNode addMeshSceneNode(IMesh mesh, ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f),
		bool alsoAddIfMeshPointerZero = false);

	/// Adds a scene node for rendering a animated water surface mesh.
	/**
	* Looks really good when the Material type EMT_TRANSPARENT_REFLECTION
	* is used.
	* Params:
	* 	waveHeight=  Height of the water waves.
	* 	waveSpeed=  Speed of the water waves.
	* 	waveLength=  Lenght of a water wave.
	* 	mesh=  Pointer to the loaded static mesh to be displayed with water waves on it.
	* 	parent=  Parent of the scene node. Can be NULL if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent where the
	* scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* Returns: Pointer to the created scene node.
	*/
	ISceneNode addWaterSurfaceSceneNode(IMesh mesh,
		float waveHeight = 2.0f, float waveSpeed=300.0f, float waveLength=10.0f,
		ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f));


	/// Adds a scene node for rendering using a octree to the scene graph.
	/**
	* This a good method for rendering
	* scenes with lots of geometry. The Octree is built on the fly from the mesh.
	* Params:
	* 	mesh=  The mesh containing all geometry from which the octree will be build.
	* If this animated mesh has more than one frames in it, the first frame is taken.
	* 	parent=  Parent node of the octree node.
	* 	id=  id of the node. This id can be used to identify the node.
	* 	minimalPolysPerNode=  Specifies the minimal polygons contained a octree node.
	* If a node gets less polys than this value it will not be split into
	* smaller nodes.
	* 	alsoAddIfMeshPointerZero=  Add the scene node even if a 0 pointer is passed.
	* Returns: Pointer to the Octree if successful, otherwise 0.
	*/
	IMeshSceneNode addOctreeSceneNode(IAnimatedMesh mesh, ISceneNode parent = null,
		int id = -1, int minimalPolysPerNode = 512, bool alsoAddIfMeshPointerZero = false);

	/// Adds a scene node for rendering using a octree to the scene graph.
	/**
	* Deprecated:  Use addOctreeSceneNode instead. This method may be removed by Irrlicht 1.9. 
	*/
	deprecated final IMeshSceneNode addOctTreeSceneNode(IAnimatedMesh mesh, ISceneNode parent = null,
		int id = -1, int minimalPolysPerNode=512, bool alsoAddIfMeshPointerZero=false)
	{
		return addOctreeSceneNode(mesh, parent, id, minimalPolysPerNode, alsoAddIfMeshPointerZero);
	}

	/// Adds a scene node for rendering using a octree to the scene graph.
	/**
	* This a good method for rendering scenes with lots of
	* geometry. The Octree is built on the fly from the mesh, much
	* faster then a bsp tree.
	* Params:
	* 	mesh=  The mesh containing all geometry from which the octree will be build.
	* 	parent=  Parent node of the octree node.
	* 	id=  id of the node. This id can be used to identify the node.
	* 	minimalPolysPerNode=  Specifies the minimal polygons contained a octree node.
	* If a node gets less polys than this value it will not be split into
	* smaller nodes.
	* 	alsoAddIfMeshPointerZero=  Add the scene node even if a 0 pointer is passed.
	* Returns: Pointer to the octree if successful, otherwise 0. 
	*/
	IMeshSceneNode addOctreeSceneNode(IMesh mesh, ISceneNode parent = null,
		int id = -1, int minimalPolysPerNode = 256, bool alsoAddIfMeshPointerZero = false);

	/// Adds a scene node for rendering using a octree to the scene graph.
	/**
	* Deprecated:  Use addOctreeSceneNode instead. This method may be removed by Irrlicht 1.9. 
	*/
	deprecated final IMeshSceneNode addOctTreeSceneNode(IMesh mesh, ISceneNode parent = null,
		int id = -1, int minimalPolysPerNode = 256, bool alsoAddIfMeshPointerZero = false)
	{
		return addOctreeSceneNode(mesh, parent, id, minimalPolysPerNode, alsoAddIfMeshPointerZero);
	}

	/// Adds a camera scene node to the scene graph and sets it as active camera.
	/**
	* This camera does not react on user input like for example the one created with
	* addCameraSceneNodeFPS(). If you want to move or animate it, use animators or the
	* ISceneNode.setPosition(), ICameraSceneNode.setTarget() etc methods.
	* By default, a camera's look at position (set with setTarget()) and its scene node
	* rotation (set with setRotation()) are independent. If you want to be able to
	* control the direction that the camera looks by using setRotation() then call
	* ICameraSceneNode.bindTargetAndRotation(true) on it.
	* Params:
	* 	position=  Position of the space relative to its parent where the camera will be placed.
	* 	lookat=  Position where the camera will look at. Also known as target.
	* 	parent=  Parent scene node of the camera. Can be null. If the parent moves,
	* the camera will move too.
	* 	id=  id of the camera. This id can be used to identify the camera.
	* 	makeActive=  Flag whether this camera should become the active one.
	* Make sure you always have one active camera.
	* Returns: Pointer to interface to camera if successful, otherwise 0.
	*/
	ICameraSceneNode addCameraSceneNode(ISceneNode parent = null,
		const vector3df position = vector3df(0,0,0),
		const vector3df lookat = vector3df(0,0,100),
		int id = -1, bool makeActive = true);

	/// Adds a maya style user controlled camera scene node to the scene graph.
	/**
	* This is a standard camera with an animator that provides mouse control similar
	* to camera in the 3D Software Maya by Alias Wavefront.
	* The camera does not react on setPosition anymore after applying this animator. Instead
	* use setTarget, to fix the target the camera the camera hovers around. And setDistance
	* to set the current distance from that target, i.e. the radius of the orbit the camera
	* hovers on.
	* Params:
	* 	parent=  Parent scene node of the camera. Can be null.
	* 	rotateSpeed=  Rotation speed of the camera.
	* 	zoomSpeed=  Zoom speed of the camera.
	* 	translationSpeed=  TranslationSpeed of the camera.
	* 	id=  id of the camera. This id can be used to identify the camera.
	* 	distance=  Initial distance of the camera from the object
	* 	makeActive=  Flag whether this camera should become the active one.
	* Make sure you always have one active camera.
	* Returns: Returns a pointer to the interface of the camera if successful, otherwise 0.
	*/
	ICameraSceneNode addCameraSceneNodeMaya(ISceneNode parent = null,
		float rotateSpeed = -1500.0f, float zoomSpeed = 200.0f,
		float translationSpeed = 1500.0f, int id = -1, float distance = 70.0f,
		bool makeActive = true);

	/// Adds a camera scene node with an animator which provides mouse and keyboard control appropriate for first person shooters (FPS).
	/**
	* This FPS camera is intended to provide a demonstration of a
	* camera that behaves like a typical First Person Shooter. It is
	* useful for simple demos and prototyping but is not intended to
	* provide a full solution for a production quality game. It binds
	* the camera scene node rotation to the look-at target; @see
	* ICameraSceneNode.bindTargetAndRotation(). With this camera,
	* you look with the mouse, and move with cursor keys. If you want
	* to change the key layout, you can specify your own keymap. For
	* example to make the camera be controlled by the cursor keys AND
	* the keys W,A,S, and D, do something like this:
	* Examples:
	* ------
	* SKeyMap keyMap[8];
	* keyMap[0].Action = EKA_MOVE_FORWARD;
	* keyMap[0].KeyCode = KEY_UP;
	* keyMap[1].Action = EKA_MOVE_FORWARD;
	* keyMap[1].KeyCode = KEY_KEY_W;
	* keyMap[2].Action = EKA_MOVE_BACKWARD;
	* keyMap[2].KeyCode = KEY_DOWN;
	* keyMap[3].Action = EKA_MOVE_BACKWARD;
	* keyMap[3].KeyCode = KEY_KEY_S;
	* keyMap[4].Action = EKA_STRAFE_LEFT;
	* keyMap[4].KeyCode = KEY_LEFT;
	* keyMap[5].Action = EKA_STRAFE_LEFT;
	* keyMap[5].KeyCode = KEY_KEY_A;
	* keyMap[6].Action = EKA_STRAFE_RIGHT;
	* keyMap[6].KeyCode = KEY_RIGHT;
	* keyMap[7].Action = EKA_STRAFE_RIGHT;
	* keyMap[7].KeyCode = KEY_KEY_D;
	* camera = sceneManager.addCameraSceneNodeFPS(0, 100, 500, -1, keyMap, 8);
	* ------
	* Params:
	* 	parent=  Parent scene node of the camera. Can be null.
	* 	rotateSpeed=  Speed in degress with which the camera is
	* rotated. This can be done only with the mouse.
	* 	moveSpeed=  Speed in units per millisecond with which
	* the camera is moved. Movement is done with the cursor keys.
	* 	id=  id of the camera. This id can be used to identify
	* the camera.
	* 	keyMapArray=  Optional pointer to an array of a keymap,
	* specifying what keys should be used to move the camera. If this
	* is null, the default keymap is used. You can define actions
	* more then one time in the array, to bind multiple keys to the
	* same action.
	* 	keyMapSize=  Amount of items in the keymap array.
	* 	noVerticalMovement=  Setting this to true makes the
	* camera only move within a horizontal plane, and disables
	* vertical movement as known from most ego shooters. Default is
	* 'false', with which it is possible to fly around in space, if
	* no gravity is there.
	* 	jumpSpeed=  Speed with which the camera is moved when
	* jumping.
	* 	invertMouse=  Setting this to true makes the camera look
	* up when the mouse is moved down and down when the mouse is
	* moved up, the default is 'false' which means it will follow the
	* movement of the mouse cursor.
	* 	makeActive=  Flag whether this camera should become the active one.
	* Make sure you always have one active camera.
	* Returns: Pointer to the interface of the camera if successful,
	* otherwise null.
	*/
	ICameraSceneNode addCameraSceneNodeFPS(ISceneNode parent = null,
		float rotateSpeed = 100.0f, float moveSpeed = 0.5f, int id = -1,
		SKeyMap[] keyMapArray = null, bool noVerticalMovement = false,
		float jumpSpeed = 0.0f, bool invertMouse = false,
		bool makeActive = true);

	/// Adds a dynamic light scene node to the scene graph.
	/**
	* The light will cast dynamic light on all
	* other scene nodes in the scene, which have the material flag MTF_LIGHTING
	* turned on. (This is the default setting in most scene nodes).
	* Params:
	* 	parent=  Parent scene node of the light. Can be null. If the parent moves,
	* the light will move too.
	* 	position=  Position of the space relative to its parent where the light will be placed.
	* 	color=  Diffuse color of the light. Ambient or Specular colors can be set manually with
	* the ILightSceneNode.getLightData() method.
	* 	radius=  Radius of the light.
	* 	id=  id of the node. This id can be used to identify the node.
	* Returns: Pointer to the interface of the light if successful, otherwise NULL.
	*/
	ILightSceneNode addLightSceneNode(ISceneNode parent = null,
		const vector3df position = vector3df(0,0,0),
		SColorf color = SColorf(1.0f, 1.0f, 1.0f),
		float radius = 100.0f, int id = -1);

	/// Adds a billboard scene node to the scene graph.
	/**
	* A billboard is like a 3d sprite: A 2d element,
	* which always looks to the camera. It is usually used for things
	* like explosions, fire, lensflares and things like that.
	* Params:
	* 	parent=  Parent scene node of the billboard. Can be null.
	* If the parent moves, the billboard will move too.
	* 	size=  Size of the billboard. This size is 2 dimensional
	* because a billboard only has width and height.
	* 	position=  Position of the space relative to its parent
	* where the billboard will be placed.
	* 	id=  An id of the node. This id can be used to identify
	* the node.
	* 	colorTop=  The color of the vertices at the top of the
	* billboard (default: white).
	* 	colorBottom=  The color of the vertices at the bottom of
	* the billboard (default: white).
	* Returns: Pointer to the billboard if successful, otherwise NULL.
	*/
	IBillboardSceneNode addBillboardSceneNode(ISceneNode parent = null,
		const dimension2d!float size = dimension2d!float(10.0f, 10.0f),
		const vector3df position = vector3df(0,0,0), int id = -1,
		SColor colorTop = SColor(0xFFFFFFFF), SColor colorBottom = SColor(0xFFFFFFFF));

	/// Adds a skybox scene node to the scene graph.
	/**
	* A skybox is a big cube with 6 textures on it and
	* is drawn around the camera position.
	* Params:
	* 	top=  Texture for the top plane of the box.
	* 	bottom=  Texture for the bottom plane of the box.
	* 	left=  Texture for the left plane of the box.
	* 	right=  Texture for the right plane of the box.
	* 	front=  Texture for the front plane of the box.
	* 	back=  Texture for the back plane of the box.
	* 	parent=  Parent scene node of the skybox. A skybox usually has no parent,
	* so this should be null. Note: If a parent is set to the skybox, the box will not
	* change how it is drawn.
	* 	id=  An id of the node. This id can be used to identify the node.
	* Returns: Pointer to the sky box if successful, otherwise NULL.
	*/
	ISceneNode addSkyBoxSceneNode(ITexture top, ITexture bottom,
		ITexture left, ITexture right, ITexture front,
		ITexture back, ISceneNode parent = null, int id = -1);

	/// Adds a skydome scene node to the scene graph.
	/**
	* A skydome is a large (half-) sphere with a panoramic texture
	* on the inside and is drawn around the camera position.
	* Params:
	* 	texture=  Texture for the dome.
	* 	horiRes=  Number of vertices of a horizontal layer of the sphere.
	* 	vertRes=  Number of vertices of a vertical layer of the sphere.
	* 	texturePercentage=  How much of the height of the
	* texture is used. Should be between 0 and 1.
	* 	spherePercentage=  How much of the sphere is drawn.
	* Value should be between 0 and 2, where 1 is an exact
	* half-sphere and 2 is a full sphere.
	* 	radius=  The Radius of the sphere
	* 	parent=  Parent scene node of the dome. A dome usually has no parent,
	* so this should be null. Note: If a parent is set, the dome will not
	* change how it is drawn.
	* 	id=  An id of the node. This id can be used to identify the node.
	* Returns: Pointer to the sky dome if successful, otherwise NULL.
	*/
	ISceneNode addSkyDomeSceneNode(ITexture texture,
		uint horiRes = 16, uint vertRes = 8,
		float texturePercentage = 0.9f, float spherePercentage = 2.0f, float radius = 1000.0f,
		ISceneNode parent = null, int id = -1);

	/// Adds a particle system scene node to the scene graph.
	/**
	* Params:
	* 	withDefaultEmitter=  Creates a default working point emitter
	* which emitts some particles. Set this to true to see a particle system
	* in action. If set to false, you'll have to set the emitter you want by
	* calling IParticleSystemSceneNode.setEmitter().
	* 	parent=  Parent of the scene node. Can be NULL if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  Position of the space relative to its parent where the
	* scene node will be placed.
	* 	rotation=  Initital rotation of the scene node.
	* 	scale=  Initial scale of the scene node.
	* Returns: Pointer to the created scene node.
	*/
	IParticleSystemSceneNode addParticleSystemSceneNode(
		bool withDefaultEmitter=true, ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f));

	/// Adds a terrain scene node to the scene graph.
	/**
	* This node implements is a simple terrain renderer which uses
	* a technique known as geo mip mapping
	* for reducing the detail of triangle blocks which are far away.
	* The code for the TerrainSceneNode is based on the terrain
	* renderer by Soconne and the GeoMipMapSceneNode developed by
	* Spintz. They made their code available for Irrlicht and allowed
	* it to be distributed under this licence. I only modified some
	* parts. A lot of thanks go to them.
	* This scene node is capable of loading terrains and updating
	* the indices at runtime to enable viewing very large terrains
	* very quickly. It uses a CLOD (Continuous Level of Detail)
	* algorithm which updates the indices for each patch based on
	* a LOD (Level of Detail) which is determined based on a patch's
	* distance from the camera.
	* The patch size of the terrain must always be a size of 2^N+1,
	* i.e. 8+1(9), 16+1(17), etc.
	* The MaxLOD available is directly dependent on the patch size
	* of the terrain. LOD 0 contains all of the indices to draw all
	* the triangles at the max detail for a patch. As each LOD goes
	* up by 1 the step taken, in generating indices increases by
	* -2^LOD, so for LOD 1, the step taken is 2, for LOD 2, the step
	* taken is 4, LOD 3 - 8, etc. The step can be no larger than
	* the size of the patch, so having a LOD of 8, with a patch size
	* of 17, is asking the algoritm to generate indices every 2^8 (
	* 256 ) vertices, which is not possible with a patch size of 17.
	* The maximum LOD for a patch size of 17 is 2^4 ( 16 ). So,
	* with a MaxLOD of 5, you'll have LOD 0 ( full detail ), LOD 1 (
	* every 2 vertices ), LOD 2 ( every 4 vertices ), LOD 3 ( every
	* 8 vertices ) and LOD 4 ( every 16 vertices ).
	* Params:
	* 	heightMapFileName=  The name of the file on disk, to read vertex data from. This should
	* be a gray scale bitmap.
	* 	parent=  Parent of the scene node. Can be 0 if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  The absolute position of this node.
	* 	rotation=  The absolute rotation of this node. ( NOT YET IMPLEMENTED )
	* 	scale=  The scale factor for the terrain. If you're
	* using a heightmap of size 129x129 and would like your terrain
	* to be 12900x12900 in game units, then use a scale factor of (
	* vector ( 100.0f, 100.0f, 100.0f ). If you use a Y
	* scaling factor of 0.0f, then your terrain will be flat.
	* 	vertexColor=  The default color of all the vertices. If no texture is associated
	* with the scene node, then all vertices will be this color. Defaults to white.
	* 	maxLOD=  The maximum LOD (level of detail) for the node. Only change if you
	* know what you are doing, this might lead to strange behavior.
	* 	patchSize=  patch size of the terrain. Only change if you
	* know what you are doing, this might lead to strange behavior.
	* 	smoothFactor=  The number of times the vertices are smoothed.
	* 	addAlsoIfHeightmapEmpty=  Add terrain node even with empty heightmap.
	* Returns: Pointer to the created scene node. Can be null
	* if the terrain could not be created, for example because the
	* heightmap could not be loaded. 
	*/
	ITerrainSceneNode addTerrainSceneNode(
		const Path heightMapFileName,
		ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0.0f,0.0f,0.0f),
		const vector3df rotation = vector3df(0.0f,0.0f,0.0f),
		const vector3df scale = vector3df(1.0f,1.0f,1.0f),
		SColor vertexColor = SColor(255,255,255,255),
		int maxLOD = 5, E_TERRAIN_PATCH_SIZE patchSize = E_TERRAIN_PATCH_SIZE.ETPS_17, int smoothFactor = 0,
		bool addAlsoIfHeightmapEmpty = false);

	/// Adds a terrain scene node to the scene graph.
	/**
	* Just like the other addTerrainSceneNode() method, but takes an IReadFile
	* pointer as parameter for the heightmap. For more informations take a look
	* at the other function.
	* Params:
	* 	heightMapFile=  The file handle to read vertex data from. This should
	* be a gray scale bitmap.
	* 	parent=  Parent of the scene node. Can be 0 if no parent.
	* 	id=  Id of the node. This id can be used to identify the scene node.
	* 	position=  The absolute position of this node.
	* 	rotation=  The absolute rotation of this node. ( NOT YET IMPLEMENTED )
	* 	scale=  The scale factor for the terrain. If you're
	* using a heightmap of size 129x129 and would like your terrain
	* to be 12900x12900 in game units, then use a scale factor of (
	* vector ( 100.0f, 100.0f, 100.0f ). If you use a Y
	* scaling factor of 0.0f, then your terrain will be flat.
	* 	vertexColor=  The default color of all the vertices. If no texture is associated
	* with the scene node, then all vertices will be this color. Defaults to white.
	* 	maxLOD=  The maximum LOD (level of detail) for the node. Only change if you
	* know what you are doing, this might lead to strange behavior.
	* 	patchSize=  patch size of the terrain. Only change if you
	* know what you are doing, this might lead to strange behavior.
	* 	smoothFactor=  The number of times the vertices are smoothed.
	* 	addAlsoIfHeightmapEmpty=  Add terrain node even with empty heightmap.
	* Returns: Pointer to the created scene node. Can be null
	* if the terrain could not be created, for example because the
	* heightmap could not be loaded. 
	*/
	ITerrainSceneNode addTerrainSceneNode(
		IReadFile heightMapFile,
		ISceneNode parent = null, int id = -1,
		const vector3df position = vector3df(0.0f,0.0f,0.0f),
		const vector3df rotation = vector3df(0.0f,0.0f,0.0f),
		const vector3df scale = vector3df(1.0f,1.0f,1.0f),
		SColor vertexColor = SColor(255,255,255,255),
		int maxLOD = 5, E_TERRAIN_PATCH_SIZE patchSize = E_TERRAIN_PATCH_SIZE.ETPS_17, int smoothFactor=0,
		bool addAlsoIfHeightmapEmpty = false);

	/// Adds a quake3 scene node to the scene graph.
	/**
	* A Quake3 Scene renders multiple meshes for a specific HighLanguage Shader (Quake3 Style )
	* Returns: Pointer to the quake3 scene node if successful, otherwise null.
	*/
	IMeshSceneNode addQuake3SceneNode(const IMeshBuffer meshBuffer, const IQ3Shader shader,
											ISceneNode parent = null, int id = -1
											);


	/// Adds an empty scene node to the scene graph.
	/**
	* Can be used for doing advanced transformations
	* or structuring the scene graph.
	* Returns: Pointer to the created scene node.
	*/
	ISceneNode addEmptySceneNode(ISceneNode parent = null, int id = -1);

	/// Adds a dummy transformation scene node to the scene graph.
	/**
	* This scene node does not render itself, and does not respond to set/getPosition,
	* set/getRotation and set/getScale. Its just a simple scene node that takes a
	* matrix as relative transformation, making it possible to insert any transformation
	* anywhere into the scene graph.
	* Returns: Pointer to the created scene node.
	*/
	IDummyTransformationSceneNode addDummyTransformationSceneNode(
		ISceneNode parent = null, int id = -1);

	/// Adds a text scene node, which is able to display 2d text at a position in three dimensional space
	ITextSceneNode* addTextSceneNode(IGUIFont font, wstring text,
		SColor color = SColor(100,255,255,255),
		ISceneNode parent = null, const vector3df position = vector3df(0,0,0),
		int id = -1);

	/// Adds a text scene node, which uses billboards. The node, and the text on it, will scale with distance.
	/**
	* Params:
	* 	font=  The font to use on the billboard. Pass 0 to use the GUI environment's default font.
	* 	text=  The text to display on the billboard.
	* 	parent=  The billboard's parent. Pass 0 to use the root scene node.
	* 	size=  The billboard's width and height.
	* 	position=  The billboards position relative to its parent.
	* 	id=  An id of the node. This id can be used to identify the node.
	* 	colorTop=  The color of the vertices at the top of the billboard (default: white).
	* 	colorBottom=  The color of the vertices at the bottom of the billboard (default: white).
	* Returns: Pointer to the billboard if successful, otherwise NULL.
	*/
	IBillboardTextSceneNode addBillboardTextSceneNode( IGUIFont font, wstring text,
		ISceneNode parent = null,
		const dimension2d!float size = dimension2d!float(10.0f, 10.0f),
		const vector3df position = vector3df(0,0,0), int id = -1,
		SColor colorTop = SColor(0xFFFFFFFF), SColor colorBottom = SColor(0xFFFFFFFF));

	/// Adds a Hill Plane mesh to the mesh pool.
	/**
	* The mesh is generated on the fly
	* and looks like a plane with some hills on it. It is uses mostly for quick
	* tests of the engine only. You can specify how many hills there should be
	* on the plane and how high they should be. Also you must specify a name for
	* the mesh, because the mesh is added to the mesh pool, and can be retrieved
	* again using ISceneManager.getMesh() with the name as parameter.
	* Params:
	* 	name=  The name of this mesh which must be specified in order
	* to be able to retrieve the mesh later with ISceneManager.getMesh().
	* 	tileSize=  Size of a tile of the mesh. (10.0f, 10.0f) would be a
	* good value to start, for example.
	* 	tileCount=  Specifies how much tiles there will be. If you specifiy
	* for example that a tile has the size (10.0f, 10.0f) and the tileCount is
	* (10,10), than you get a field of 100 tiles which has the dimension 100.0fx100.0f.
	* 	material=  Material of the hill mesh.
	* 	hillHeight=  Height of the hills. If you specify a negative value
	* you will get holes instead of hills. If the height is 0, no hills will be
	* created.
	* 	countHills=  Amount of hills on the plane. There will be countHills.X
	* hills along the X axis and countHills.Y along the Y axis. So in total there
	* will be countHills.X * countHills.Y hills.
	* 	textureRepeatCount=  Defines how often the texture will be repeated in
	* x and y direction.
	* return Null if the creation failed. The reason could be that you
	* specified some invalid parameters or that a mesh with that name already
	* exists. If successful, a pointer to the mesh is returned. 
	*/
	IAnimatedMesh addHillPlaneMesh(const Path name,
		const dimension2d!float tileSize, const dimension2d!uint tileCount,
		SMaterial material = null, float hillHeight = 0.0f,
		const dimension2d!float countHills = dimension2d!float(0.0f, 0.0f),
		const dimension2d!float textureRepeatCount = dimension2d!float(1.0f, 1.0f));

	/// Adds a static terrain mesh to the mesh pool.
	/**
	* The mesh is generated on the fly
	* from a texture file and a height map file. Both files may be huge
	* (8000x8000 pixels would be no problem) because the generator splits the
	* files into smaller textures if necessary.
	* You must specify a name for the mesh, because the mesh is added to the mesh pool,
	* and can be retrieved again using ISceneManager.getMesh() with the name as parameter.
	* Params:
	* 	meshname=  The name of this mesh which must be specified in order
	* to be able to retrieve the mesh later with ISceneManager.getMesh().
	* 	texture=  Texture for the terrain. Please note that this is not a
	* hardware texture as usual (ITexture), but an IImage software texture.
	* You can load this texture with IVideoDriver.createImageFromFile().
	* 	heightmap=  A grayscaled heightmap image. Like the texture,
	* it can be created with IVideoDriver.createImageFromFile(). The amount
	* of triangles created depends on the size of this texture, so use a small
	* heightmap to increase rendering speed.
	* 	stretchSize=  Parameter defining how big a is pixel on the heightmap.
	* 	maxHeight=  Defines how high a white pixel on the heighmap is.
	* 	defaultVertexBlockSize=  Defines the initial dimension between vertices.
	* Returns: Null if the creation failed. The reason could be that you
	* specified some invalid parameters, that a mesh with that name already
	* exists, or that a texture could not be found. If successful, a pointer to the mesh is returned.
	*/
	IAnimatedMesh addTerrainMesh(const Path meshname,
		IImage texture, IImage heightmap,
		const dimension2d!float stretchSize = dimension2d!float(10.0f,10.0f),
		float maxHeight=200.0f,
		const dimension2d!uint defaultVertexBlockSize = dimension2d!uint(64,64));

	/// add a static arrow mesh to the meshpool
	/**
	* Params:
	* 	name=  Name of the mesh
	* 	vtxColorCylinder=  color of the cylinder
	* 	vtxColorCone=  color of the cone
	* 	tesselationCylinder=  Number of quads the cylinder side consists of
	* 	tesselationCone=  Number of triangles the cone's roof consits of
	* 	height=  Total height of the arrow
	* 	cylinderHeight=  Total height of the cylinder, should be lesser than total height
	* 	widthCylinder=  Diameter of the cylinder
	* 	widthCone=  Diameter of the cone's base, should be not smaller than the cylinder's diameter
	* Returns: Pointer to the arrow mesh if successful, otherwise 0.
	*/
	IAnimatedMesh addArrowMesh(const Path name,
			SColor vtxColorCylinder = SColor(0xFFFFFFFF),
			SColor vtxColorCone = SColor(0xFFFFFFFF),
			uint tesselationCylinder = 4, uint tesselationCone = 8,
			float height = 1.0f, float cylinderHeight = 0.6f,
			float widthCylinder = 0.05f, float widthCone = 0.3f);

	/// add a static sphere mesh to the meshpool
	/**
	* Params:
	* 	name=  Name of the mesh
	* 	radius=  Radius of the sphere
	* 	polyCountX=  Number of quads used for the horizontal tiling
	* 	polyCountY=  Number of quads used for the vertical tiling
	* Returns: Pointer to the sphere mesh if successful, otherwise 0.
	*/
	IAnimatedMesh addSphereMesh(const Path name,
			float radius = 5.0f, uint polyCountX = 16,
			uint polyCountY = 16);

	/// Add a volume light mesh to the meshpool
	/**
	* Params:
	* 	name=  Name of the mesh
	* 	SubdivideU=  Horizontal subdivision count
	* 	SubdivideV=  Vertical subdivision count
	* 	FootColor=  Color of the bottom of the light
	* 	TailColor=  Color of the top of the light
	* Returns: Pointer to the volume light mesh if successful, otherwise 0.
	*/
	IAnimatedMesh addVolumeLightMesh(const Path name,
			const uint SubdivideU = 32, const uint SubdivideV = 32,
			const SColor FootColor = SColor(51, 0, 230, 180),
			const SColor TailColor = SColor(0, 0, 0, 0));

	/// Gets the root scene node.
	/**
	* This is the scene node which is parent
	* of all scene nodes. The root scene node is a special scene node which
	* only exists to manage all scene nodes. It will not be rendered and cannot
	* be removed from the 
	* Returns: Pointer to the root scene node.
	*/
	ISceneNode getRootSceneNode();

	/// Get the first scene node with the specified id.
	/**
	* Params:
	* 	id=  The id to search for
	* 	start=  Scene node to start from. All children of this scene
	* node are searched. If null is specified, the root scene node is
	* taken.
	* Returns: Pointer to the first scene node with this id,
	* and null if no scene node could be found.
	*/
	ISceneNode getSceneNodeFromId(int id, ISceneNode start = null);

	/// Get the first scene node with the specified name.
	/**
	* Params:
	* 	name=  The name to search for
	* 	start=  Scene node to start from. All children of this scene
	* node are searched. If null is specified, the root scene node is
	* taken.
	* Returns: Pointer to the first scene node with this id,
	* and null if no scene node could be found. 
	*/
	ISceneNode getSceneNodeFromName(string name, ISceneNode start = null);

	/// Get the first scene node with the specified type.
	/**
	* Params:
	* 	type=  The type to search for
	* 	start=  Scene node to start from. All children of this scene
	* node are searched. If null is specified, the root scene node is
	* taken.
	* Returns: Pointer to the first scene node with this type,
	* and null if no scene node could be found. 
	*/
	ISceneNode getSceneNodeFromType(ESCENE_NODE_TYPE type, ISceneNode start = null);

	/// Get scene nodes by type.
	/**
	* Params:
	* 	type=  Type of scene node to find (ESNT_ANY will return all child nodes).
	* 	outNodes=  array to be filled with results.
	* 	start=  Scene node to start from. All children of this scene
	* node are searched. If null is specified, the root scene node is
	* taken. 
	*/
	void getSceneNodesFromType(ESCENE_NODE_TYPE type,
			out ISceneNode[] outNodes,
			ISceneNode start = null);

	/// Get the current active camera.
	/**
	* Returns: The active camera is returned. Note that this can
	* be NULL, if there was no camera created yet.
	*/
	ICameraSceneNode getActiveCamera() const;

	/// Sets the currently active camera.
	/**
	* The previous active camera will be deactivated.
	* Params:
	* 	camera=  The new camera which should be active. 
	*/
	void setActiveCamera(ICameraSceneNode camera);

	/// Sets the color of stencil buffers shadows drawn by the scene manager.
	void setShadowColor(SColor color = SColor(150,0,0,0));

	/// Get the current color of shadows.
	SColor getShadowColor() const;

	/// Registers a node for rendering it at a specific time.
	/**
	* This method should only be used by SceneNodes when they get a
	* ISceneNode.OnRegisterSceneNode() call.
	* Params:
	* 	node=  Node to register for drawing. Usually scene nodes would set 'this'
	* as parameter here because they want to be drawn.
	* 	pass=  Specifies when the node wants to be drawn in relation to the other nodes.
	* For example, if the node is a shadow, it usually wants to be drawn after all other nodes
	* and will use ESNRP_SHADOW for this. See E_SCENE_NODE_RENDER_PASS for details.
	* Returns: scene will be rendered ( passed culling ) 
	*/
	uint registerNodeForRendering(ISceneNode node,
		E_SCENE_NODE_RENDER_PASS pass = E_SCENE_NODE_RENDER_PASS.ESNRP_AUTOMATIC);

	/// Draws all the scene nodes.
	/**
	* This can only be invoked between
	* IVideoDriver.beginScene() and IVideoDriver.endScene(). Please note that
	* the scene is not only drawn when calling this, but also animated
	* by existing scene node animators, culling of scene nodes is done, etc. 
	*/
	void drawAll();

	/// Creates a rotation animator, which rotates the attached scene node around itself.
	/**
	* Params:
	* 	rotationSpeed=  Specifies the speed of the animation in degree per 10 milliseconds.
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will animate it.
	*/
	ISceneNodeAnimator createRotationAnimator(const vector3df rotationSpeed);

	/// Creates a fly circle animator, which lets the attached scene node fly around a center.
	/**
	* Params:
	* 	center=  Center of the circle.
	* 	radius=  Radius of the circle.
	* 	speed=  The orbital speed, in radians per millisecond.
	* 	direction=  Specifies the upvector used for alignment of the mesh.
	* 	startPosition=  The position on the circle where the animator will
	* begin. Value is in multiples of a circle, i.e. 0.5 is half way around. (phase)
	* 	radiusEllipsoid=  if radiusEllipsoid != 0 then radius2 froms a ellipsoid
	* begin. Value is in multiples of a circle, i.e. 0.5 is half way around. (phase)
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will animate it.
	*/
	ISceneNodeAnimator createFlyCircleAnimator(
			const vector3df center=vector3df(0.0f,0.0f,0.0f),
			float radius = 100.0f, float speed = 0.001f,
			const vector3df direction = vector3df(0.0f, 1.0f, 0.0f),
			float startPosition = 0.0f,
			float radiusEllipsoid = 0.0f);

	/// Creates a fly straight animator, which lets the attached scene node fly or move along a line between two points.
	/**
	* Params:
	* 	startPoint=  Start point of the line.
	* 	endPoint=  End point of the line.
	* 	timeForWay=  Time in milli seconds how long the node should need to
	* move from the start point to the end point.
	* 	loop=  If set to false, the node stops when the end point is reached.
	* If loop is true, the node begins again at the start.
	* 	pingpong=  Flag to set whether the animator should fly
	* back from end to start again.
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will animate it.
	*/
	ISceneNodeAnimator createFlyStraightAnimator(vector3df startPoint,
		vector3df endPoint, uint timeForWay, bool loop = false, bool pingpong = false);

	/// Creates a texture animator, which switches the textures of the target scene node based on a list of textures.
	/**
	* Params:
	* 	textures=  List of textures to use.
	* 	timePerFrame=  Time in milliseconds, how long any texture in the list
	* should be visible.
	* 	loop=  If set to to false, the last texture remains set, and the animation
	* stops. If set to true, the animation restarts with the first texture.
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will animate it.
	*/
	ISceneNodeAnimator createTextureAnimator(const ITexture[] textures,
		int timePerFrame, bool loop=true);

	/// Creates a scene node animator, which deletes the scene node after some time automatically.
	/**
	* Params:
	* 	timeMs=  Time in milliseconds, after when the node will be deleted.
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will animate it.
	*/
	ISceneNodeAnimator createDeleteAnimator(uint timeMs);

	/// Creates a special scene node animator for doing automatic collision detection and response.
	/**
	* See_Also:
	* 	ISceneNodeAnimatorCollisionResponse for details.
	* Params:
	* 	world=  Triangle selector holding all triangles of the world with which
	* the scene node may collide. You can create a triangle selector with
	* ISceneManager.createTriangleSelector();
	* 	sceneNode=  SceneNode which should be manipulated. After you added this animator
	* to the scene node, the scene node will not be able to move through walls and is
	* affected by gravity. If you need to teleport the scene node to a new position without
	* it being effected by the collision geometry, then call sceneNode.setPosition(); then
	* animator.setTargetNode(sceneNode);
	* 	ellipsoidRadius=  Radius of the ellipsoid with which collision detection and
	* response is done. If you have got a scene node, and you are unsure about
	* how big the radius should be, you could use the following code to determine
	* it:
	* Examples:
	* ------
	* const aabbox3d!float box = yourSceneNode.getBoundingBox();
	* vector3df radius = box.MaxEdge - box.getCenter();
	* ------
	* 	gravityPerSecond=  Sets the gravity of the environment, as an acceleration in
	* units per second per second. If your units are equivalent to metres, then
	* vector3df(0,-10.0f,0) would give an approximately realistic gravity.
	* You can disable gravity by setting it to vector3df(0,0,0).
	* 	ellipsoidTranslation=  By default, the ellipsoid for collision detection is created around
	* the center of the scene node, which means that the ellipsoid surrounds
	* it completely. If this is not what you want, you may specify a translation
	* for the ellipsoid.
	* 	slidingValue=  DOCUMENTATION NEEDED.
	* Returns: The animator. Attach it to a scene node with ISceneNode.addAnimator()
	* and the animator will cause it to do collision detection and response.
	*/
	ISceneNodeAnimatorCollisionResponse createCollisionResponseAnimator(
		ITriangleSelector world, ISceneNode sceneNode,
		const vector3df ellipsoidRadius = vector3df(30,60,30),
		const vector3df gravityPerSecond = vector3df(0,-10.0f,0),
		const vector3df ellipsoidTranslation = vector3df(0,0,0),
		float slidingValue = 0.0005f);

	/// Creates a follow spline animator.
	/**
	* The animator modifies the position of
	* the attached scene node to make it follow a hermite spline.
	* It uses a subset of hermite splines: either cardinal splines
	* (tightness != 0.5) or catmull-rom-splines (tightness == 0.5).
	* The animator moves from one control point to the next in
	* 1/speed seconds. This code was sent in by Matthias Gall.
	*/
	ISceneNodeAnimator createFollowSplineAnimator(int startTime,
		const vector3df[] points,
		float speed = 1.0f, float tightness = 0.5f, bool loop = true, bool pingpong = false);

	/// Creates a simple ITriangleSelector, based on a mesh.
	/**
	* Triangle selectors
	* can be used for doing collision detection. Don't use this selector
	* for a huge amount of triangles like in Quake3 maps.
	* Instead, use for example ISceneManager.createOctreeTriangleSelector().
	* Please note that the created triangle selector is not automaticly attached
	* to the scene node. You will have to call ISceneNode.setTriangleSelector()
	* for this. To create and attach a triangle selector is done like this:
	* Examples:
	* ------
	* ITriangleSelector s = sceneManager.createTriangleSelector(yourMesh,
	*		 yourSceneNode);
	* yourSceneNode.setTriangleSelector(s);
	* ------
	* Params:
	* 	mesh=  Mesh of which the triangles are taken.
	* 	node=  Scene node of which visibility and transformation is used.
	* Returns: The selector, or null if not successful.
	*/
	ITriangleSelector createTriangleSelector(IMesh mesh, ISceneNode node);

	/// Creates a simple ITriangleSelector, based on an animated mesh scene node.
	/**
	* Details of the mesh associated with the node will be extracted internally.
	* Call ITriangleSelector.update() to have the triangle selector updated based
	* on the current frame of the animated mesh scene node.
	* Params:
	* 	node=  The animated mesh scene node from which to build the selector
	*/
	ITriangleSelector createTriangleSelector(IAnimatedMeshSceneNode node);


	/// Creates a simple dynamic ITriangleSelector, based on a axis aligned bounding box.
	/**
	* Triangle selectors
	* can be used for doing collision detection. Every time when triangles are
	* queried, the triangle selector gets the bounding box of the scene node,
	* an creates new triangles. In this way, it works good with animated scene nodes.
	* Params:
	* 	node=  Scene node of which the bounding box, visibility and transformation is used.
	* Returns: The selector, or null if not successful.
	*/
	ITriangleSelector createTriangleSelectorFromBoundingBox(ISceneNode node);

	/// Creates a Triangle Selector, optimized by an octree.
	/**
	* Triangle selectors
	* can be used for doing collision detection. This triangle selector is
	* optimized for huge amounts of triangle, it organizes them in an octree.
	* Please note that the created triangle selector is not automaticly attached
	* to the scene node. You will have to call ISceneNode.setTriangleSelector()
	* for this. To create and attach a triangle selector is done like this:
	* Examples:
	* ------
	* ITriangleSelector s = sceneManager.createOctreeTriangleSelector(yourMesh,
			* yourSceneNode);
	* yourSceneNode.setTriangleSelector(s);
	* ------
	* For more informations and examples on this, take a look at the collision
	* tutorial in the SDK.
	* Params:
	* 	mesh=  Mesh of which the triangles are taken.
	* 	node=  Scene node of which visibility and transformation is used.
	* 	minimalPolysPerNode=  Specifies the minimal polygons contained a octree node.
	* If a node gets less polys the this value, it will not be splitted into
	* smaller nodes.
	* Returns: The selector, or null if not successful.
	*/
	ITriangleSelector createOctreeTriangleSelector(IMesh mesh,
		ISceneNode node, int minimalPolysPerNode = 32);

	/// /// Creates a Triangle Selector, optimized by an octree.
	/**
	* Deprecated:  Use createOctreeTriangleSelector instead. This method may be removed by Irrlicht 1.9. 
	*/
	deprecated final ITriangleSelector createOctTreeTriangleSelector(IMesh mesh,
		ISceneNode node, int minimalPolysPerNode=32)
	{
		return createOctreeTriangleSelector(mesh, node, minimalPolysPerNode);
	}

	/// Creates a meta triangle selector.
	/**
	* A meta triangle selector is nothing more than a
	* collection of one or more triangle selectors providing together
	* the interface of one triangle selector. In this way,
	* collision tests can be done with different triangle soups in one pass.
	* Returns: The selector, or null if not successful.
	*/
	IMetaTriangleSelector createMetaTriangleSelector();

	/// Creates a triangle selector which can select triangles from a terrain scene node.
	/**
	* Params:
	* 	node=  Pointer to the created terrain scene node
	* 	LOD=  Level of detail, 0 for highest detail.
	* Returns: The selector, or null if not successful.
	*/
	ITriangleSelector createTerrainTriangleSelector(
		ITerrainSceneNode node, int LOD=0);

	/// Adds an external mesh loader for extending the engine with new file formats.
	/**
	* If you want the engine to be extended with
	* file formats it currently is not able to load (e.g. .cob), just implement
	* the IMeshLoader interface in your loading class and add it with this method.
	* Using this method it is also possible to override built-in mesh loaders with
	* newer or updated versions without the need to recompile the engine.
	* Params:
	* 	externalLoader=  Implementation of a new mesh loader. 
	*/
	void addExternalMeshLoader(IMeshLoader externalLoader);

	/// Returns the number of mesh loaders supported by Irrlicht at this time
	size_t getMeshLoaderCount() const;

	/// Retrieve the given mesh loader
	/**
	* Params:
	* 	index=  The index of the loader to retrieve. This parameter is an 0-based
	* array index.
	* Returns: A pointer to the specified loader, 0 if the index is incorrect. 
	*/
	IMeshLoader getMeshLoader(size_t index) const;

	/// Adds an external scene loader for extending the engine with new file formats.
	/**
	* If you want the engine to be extended with
	* file formats it currently is not able to load (e.g. .vrml), just implement
	* the ISceneLoader interface in your loading class and add it with this method.
	* Using this method it is also possible to override the built-in scene loaders
	* with newer or updated versions without the need to recompile the engine.
	* Params:
	* 	externalLoader=  Implementation of a new mesh loader. 
	*/
	void addExternalSceneLoader(ISceneLoader externalLoader);

	/// Returns the number of scene loaders supported by Irrlicht at this time
	size_t getSceneLoaderCount() const;

	/// Retrieve the given scene loader
	/**
	* Params:
	* 	index=  The index of the loader to retrieve. This parameter is an 0-based
	* array index.
	* Returns: A pointer to the specified loader, 0 if the index is incorrect. 
	*/
	ISceneLoader getSceneLoader(size_t index) const;

	/// Get pointer to the scene collision manager.
	/**
	* Returns: Pointer to the collision manager
	*/
	ISceneCollisionManager getSceneCollisionManager();

	/// Get pointer to the mesh manipulator.
	/**
	* Returns: Pointer to the mesh manipulator
	*/
	IMeshManipulator getMeshManipulator();

	/// Adds a scene node to the deletion queue.
	/**
	* The scene node is immediatly
	* deleted when it's secure. Which means when the scene node does not
	* execute animators and things like that. This method is for example
	* used for deleting scene nodes by their scene node animators. In
	* most other cases, a ISceneNode.remove() call is enough, using this
	* deletion queue is not necessary.
	* See_Also:
	* 	ISceneManager.createDeleteAnimator() for details.
	* Params:
	* 	node=  Node to detete. 
	*/
	void addToDeletionQueue(ISceneNode node);

	/// Posts an input event to the environment.
	/**
	* Usually you do not have to
	* use this method, it is used by the internal engine. 
	*/
	bool postEventFromUser(ref const SEvent event);

	/// Clears the whole 
	/**
	* All scene nodes are removed. 
	*/
	void clear();

	/// Get interface to the parameters set in this 
	/**
	* String parameters can be used by plugins and mesh loaders.
	* For example the CMS and LMTS loader want a parameter named 'CSM_TexturePath'
	* and 'LMTS_TexturePath' set to the path were attached textures can be found. See
	* CSM_TEXTURE_PATH, LMTS_TEXTURE_PATH, MY3D_TEXTURE_PATH,
	* COLLADA_CREATE_SCENE_INSTANCES, DMF_TEXTURE_PATH and DMF_USE_MATERIALS_DIRS
	*/
	IAttributes getParameters();

	/// Get current render pass.
	/**
	* All scene nodes are being rendered in a specific order.
	* First lights, cameras, sky boxes, solid geometry, and then transparent
	* stuff. During the rendering process, scene nodes may want to know what the scene
	* manager is rendering currently, because for example they registered for rendering
	* twice, once for transparent geometry and once for solid. When knowing what rendering
	* pass currently is active they can render the correct part of their geometry. 
	*/
	E_SCENE_NODE_RENDER_PASS getSceneNodeRenderPass() const;

	/// Get the default scene node factory which can create all built in scene nodes
	/**
	* Returns: Pointer to the default scene node factory
	*/
	ISceneNodeFactory getDefaultSceneNodeFactory();

	/// Adds a scene node factory to the scene manager.
	/**
	* Use this to extend the scene manager with new scene node types which it should be
	* able to create automaticly, for example when loading data from xml files. 
	*/
	void registerSceneNodeFactory(ISceneNodeFactory factoryToAdd);

	/// Get amount of registered scene node factories.
	size_t getRegisteredSceneNodeFactoryCount() const;

	/// Get a scene node factory by index
	/**
	* Returns: Pointer to the requested scene node factory, or 0 if it does not exist.
	*/
	ISceneNodeFactory getSceneNodeFactory(size_t index);

	/// Get the default scene node animator factory which can create all built-in scene node animators
	/**
	* Returns: Pointer to the default scene node animator factory
	*/
	ISceneNodeAnimatorFactory getDefaultSceneNodeAnimatorFactory();

	/// Adds a scene node animator factory to the scene manager.
	/**
	* Use this to extend the scene manager with new scene node animator types which it should be
	* able to create automaticly, for example when loading data from xml files. 
	*/
	void registerSceneNodeAnimatorFactory(ISceneNodeAnimatorFactory factoryToAdd);

	/// Get amount of registered scene node animator factories.
	size_t getRegisteredSceneNodeAnimatorFactoryCount() const;

	/// Get scene node animator factory by index
	/**
	* Returns: Pointer to the requested scene node animator factory, or 0 if it does not exist.
	*/
	ISceneNodeAnimatorFactory getSceneNodeAnimatorFactory(size_t index);

	/// Get typename from a scene node type or null if not found
	string getSceneNodeTypeName(ESCENE_NODE_TYPE type);

	/// Returns a typename from a scene node animator type or null if not found
	string getAnimatorTypeName(ESCENE_NODE_ANIMATOR_TYPE type);

	/// Adds a scene node to the scene by name
	/**
	* Returns: Pointer to the scene node added by a factory
	*/
	ISceneNode addSceneNode(string sceneNodeTypeName, ISceneNode parent = null);

	/// creates a scene node animator based on its type name
	/**
	* Params:
	* 	typeName=  Type of the scene node animator to add.
	* 	target=  Target scene node of the new animator.
	* Returns: Returns pointer to the new scene node animator or null if not successful.
	*/
	ISceneNodeAnimator createSceneNodeAnimator(string typeName, ISceneNode target = null);

	/// Creates a new scene manager.
	/**
	* This can be used to easily draw and/or store two
	* independent scenes at the same time. The mesh cache will be
	* shared between all existing scene managers, which means if you
	* load a mesh in the original scene manager using for example
	* getMesh(), the mesh will be available in all other scene
	* managers too, without loading.
	* The original/main scene manager will still be there and
	* accessible via IrrlichtDevice.getSceneManager(). If you need
	* input event in this new scene manager, for example for FPS
	* cameras, you'll need to forward input to this manually: Just
	* implement an IEventReceiver and call
	* yourNewSceneManager.postEventFromUser(), and return true so
	* that the original scene manager doesn't get the event.
	* Otherwise, all input will go to the main scene manager
	* automatically.. 
	*/
	ISceneManager createNewSceneManager(bool cloneContent = false);

	/// Saves the current scene into a file.
	/**
	* Scene nodes with the option isDebugObject set to true are
	* not being saved. The scene is usually written to an .irr file,
	* an xml based format. .irr files can Be edited with the Irrlicht
	* Engine Editor, irrEdit (http://irredit.irrlicht3d.org). To
	* load .irr files again, see ISceneManager.loadScene().
	* Params:
	* 	filename=  Name of the file.
	* 	userDataSerializer=  If you want to save some user data
	* for every scene node into the file, implement the
	* ISceneUserDataSerializer interface and provide it as parameter
	* here. Otherwise, simply specify 0 as this parameter.
	* 	node=  Node which is taken as the top node of the 
	* This node and all of its descendants are saved into the scene
	* file. Pass 0 or the scene manager to save the full scene (which
	* is also the default).
	* Returns: True if successful. 
	*/
	bool saveScene(const Path filename, ISceneUserDataSerializer userDataSerializer = null, ISceneNode node = null);

	/// Saves the current scene into a file.
	/**
	* Scene nodes with the option isDebugObject set to true are
	* not being saved. The scene is usually written to an .irr file,
	* an xml based format. .irr files can Be edited with the Irrlicht
	* Engine Editor, irrEdit (http://irredit.irrlicht3d.org). To
	* load .irr files again, see ISceneManager.loadScene().
	* Params:
	* 	file=  File where the scene is saved into.
	* 	userDataSerializer=  If you want to save some user data
	* for every scene node into the file, implement the
	* ISceneUserDataSerializer interface and provide it as parameter
	* here. Otherwise, simply specify 0 as this parameter.
	* 	node=  Node which is taken as the top node of the 
	* This node and all of its descendants are saved into the scene
	* file. Pass 0 or the scene manager to save the full scene (which
	* is also the default).
	* Returns: True if successful. 
	*/
	bool saveScene(IWriteFile file, ISceneUserDataSerializer userDataSerializer = null, ISceneNode node = null);

	/// Saves the current scene into a file.
	/**
	* Scene nodes with the option isDebugObject set to true are
	* not being saved. The scene is usually written to an .irr file,
	* an xml based format. .irr files can Be edited with the Irrlicht
	* Engine Editor, irrEdit (http://irredit.irrlicht3d.org). To
	* load .irr files again, see ISceneManager.loadScene().
	* Params:
	* 	writer=  XMLWriter with which the scene is saved.
	* 	currentPath=  Path which is used for relative file names.
	* Usually the directory of the file written into.
	* 	userDataSerializer=  If you want to save some user data
	* for every scene node into the file, implement the
	* ISceneUserDataSerializer interface and provide it as parameter
	* here. Otherwise, simply specify 0 as this parameter.
	* 	node=  Node which is taken as the top node of the 
	* This node and all of its descendants are saved into the scene
	* file. Pass 0 or the scene manager to save the full scene (which
	* is also the default).
	* Returns: True if successful. 
	*/
	bool saveScene(IXMLWriter writer, const Path currentPath, ISceneUserDataSerializer userDataSerializer = null, ISceneNode node = null);

	/// Loads a  Note that the current scene is not cleared before.
	/**
	* The scene is usually loaded from an .irr file, an xml based
	* format, but other scene formats can be added to the engine via
	* ISceneManager.addExternalSceneLoader. .irr files can Be edited
	* with the Irrlicht Engine Editor, irrEdit
	* (http://irredit.irrlicht3d.org) or saved directly by the engine
	* using ISceneManager.saveScene().
	* Params:
	* 	filename=  Name of the file to load from.
	* 	userDataSerializer=  If you want to load user data
	* possibily saved in that file for some scene nodes in the file,
	* implement the ISceneUserDataSerializer interface and provide it
	* as parameter here. Otherwise, simply specify 0 as this
	* parameter.
	* 	rootNode=  Node which is taken as the root node of the
	*  Pass 0 to add the scene directly to the scene manager
	* (which is also the default).
	* Returns: True if successful. 
	*/
	bool loadScene(const Path filename, ISceneUserDataSerializer userDataSerializer = null, ISceneNode rootNode = null);

	/// Loads a  Note that the current scene is not cleared before.
	/**
	* The scene is usually loaded from an .irr file, an xml based
	* format, but other scene formats can be added to the engine via
	* ISceneManager.addExternalSceneLoader. .irr files can Be edited
	* with the Irrlicht Engine Editor, irrEdit
	* (http://irredit.irrlicht3d.org) or saved directly by the engine
	* using ISceneManager.saveScene().
	* Params:
	* 	file=  File where the scene is loaded from.
	* 	userDataSerializer=  If you want to load user data
	* possibily saved in that file for some scene nodes in the file,
	* implement the ISceneUserDataSerializer interface and provide it
	* as parameter here. Otherwise, simply specify 0 as this
	* parameter.
	* 	rootNode=  Node which is taken as the root node of the
	*  Pass 0 to add the scene directly to the scene manager
	* (which is also the default).
	* Returns: True if successful. 
	*/
	bool loadScene(IReadFile file, ISceneUserDataSerializer userDataSerializer = null, ISceneNode rootNode = null);

	/// Get a mesh writer implementation if available
	/**
	* Note: You need to drop() the pointer after use again, see IReferenceCounted.drop()
	* for details. 
	*/
	IMeshWriter createMeshWriter(EMESH_WRITER_TYPE type);

	/// Get a skinned mesh, which is not available as header-only code
	/**
	* Note: You need to drop() the pointer after use again, see IReferenceCounted.drop()
	* for details. 
	*/
	ISkinnedMesh createSkinnedMesh();

	/// Sets ambient color of the scene
	void setAmbientLight()(auto ref const SColorf ambientColor);

	/// Get ambient color of the scene
	auto ref const SColorf getAmbientLight()() const;

	/// Register a custom callbacks manager which gets callbacks during scene rendering.
	/**
	* Params:
	* 	lightManager = the new callbacks manager. You may pass 0 to remove the
	* current callbacks manager and restore the default behavior. 
	*/
	void setLightManager(ILightManager*lightManager);

	/// Get an instance of a geometry creator.
	/**
	* The geometry creator provides some helper methods to create various types of
	* basic geometry. This can be useful for custom scene nodes. 
	*/
	const IGeometryCreator getGeometryCreator() const;

	/// Check if node is culled in current view frustum
	/**
	* Please note that depending on the used culling method this
	* check can be rather coarse, or slow. A positive result is
	* correct, though, i.e. if this method returns true the node is
	* positively not visible. The node might still be invisible even
	* if this method returns false.
	* Params:
	* 	node=  The scene node which is checked for culling.
	* Returns: True if node is not visible in the current scene, else
	* false. 
	*/
	bool isCulled(const ISceneNode node) const;
}
