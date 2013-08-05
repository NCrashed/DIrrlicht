// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ITerrainSceneNode;

// The code for the TerrainSceneNode is based on the terrain renderer by
// Soconne and the GeoMipMapSceneNode developed by Spintz. They made their
// code available for Irrlicht and allowed it to be distributed under this
// licence. I only modified some parts. A lot of thanks go to them.

import irrlicht.scene.ETerrainElements;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.IDynamicMeshBuffer;
import irrlicht.scene.IMesh;
import irrlicht.scene.IMeshBuffer;
import irrlicht.io.IReadFile;
import irrlicht.video.SColor;
import irrlicht.core.aabbox3d;
import irrlicht.core.vector3d;

/// A scene node for displaying terrain using the geo mip map algorithm.
/**
* The code for the TerrainSceneNode is based on the Terrain renderer by Soconne and
 * the GeoMipMapSceneNode developed by Spintz. They made their code available for Irrlicht
 * and allowed it to be distributed under this licence. I only modified some parts.
 * A lot of thanks go to them.
 * This scene node is capable of very quickly loading
 * terrains and updating the indices at runtime to enable viewing very large terrains. It uses a
 * CLOD (Continuous Level of Detail) algorithm which updates the indices for each patch based on
 * a LOD (Level of Detail) which is determined based on a patch's distance from the camera.
 * The Patch Size of the terrain must always be a size of ( 2^N+1, i.e. 8+1(9), 16+1(17), etc. ).
 * The MaxLOD available is directly dependent on the patch size of the terrain. LOD 0 contains all
 * of the indices to draw all the triangles at the max detail for a patch. As each LOD goes up by 1
 * the step taken, in generating indices increases by - 2^LOD, so for LOD 1, the step taken is 2, for
 * LOD 2, the step taken is 4, LOD 3 - 8, etc. The step can be no larger than the size of the patch,
 * so having a LOD of 8, with a patch size of 17, is asking the algoritm to generate indices every
 * 2^8 ( 256 ) vertices, which is not possible with a patch size of 17. The maximum LOD for a patch
 * size of 17 is 2^4 ( 16 ). So, with a MaxLOD of 5, you'll have LOD 0 ( full detail ), LOD 1 ( every
 * 2 vertices ), LOD 2 ( every 4 vertices ), LOD 3 ( every 8 vertices ) and LOD 4 ( every 16 vertices ).
 **/
abstract class ITerrainSceneNode : ISceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0.0f, 0.0f, 0.0f),
		const vector3df rotation = vector3df(0.0f, 0.0f, 0.0f),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f) )
	{
		super(parent, mgr, id, position, rotation, scale);
	}

	/// Get the bounding box of the terrain.
	/**
	* Returns: The bounding box of the entire terrain. 
	*/
	auto ref const aabbox3d!float getBoundingBox()() const;

	/// Get the bounding box of a patch
	/**
	* Returns: The bounding box of the chosen patch. 
	*/
	auto ref const aabbox3d!float getBoundingBox()(int patchX, int patchZ) const;

	/// Get the number of indices currently in the meshbuffer
	/**
	* Returns: The index count. 
	*/
	size_t getIndexCount() const;

	/// Get pointer to the mesh
	/**
	* Returns: Pointer to the mesh. 
	*/
	IMesh getMesh();

	/// Get pointer to the buffer used by the terrain (most users will not need this)
	IMeshBuffer getRenderBuffer();


	/// Gets the meshbuffer data based on a specified level of detail.
	/**
	* Params:
	* 	mb=  A reference to an IDynamicMeshBuffer object
	* 	LOD=  The level of detail you want the indices from. 
	*/
	void getMeshBufferForLOD(out IDynamicMeshBuffer mb, int LOD = 0) const;

	/// Gets the indices for a specified patch at a specified Level of Detail.
	/**
	* Params:
	* 	indices=  A reference to an array of u32 indices.
	* 	patchX=  Patch x coordinate.
	* 	patchZ=  Patch z coordinate.
	* 	LOD=  The level of detail to get for that patch. If -1,
	* then get the CurrentLOD. If the CurrentLOD is set to -1,
	* meaning it's not shown, then it will retrieve the triangles at
	* the highest LOD (0).
	* Returns: Number of indices put into the buffer. 
	*/
	int getIndicesForPatch(out uint[] indices,
		int patchX, int patchZ, int LOD = 0);

	/// Populates an array with the CurrentLOD of each patch.
	/**
	* Params:
	* 	LODs=  A reference to a array<int> to hold the
	* values
	* Returns: Number of elements in the array 
	*/
	size_t getCurrentLODOfPatches(out int[] LODs) const;

	/// Manually sets the LOD of a patch
	/**
	* Params:
	* 	patchX=  Patch x coordinate.
	* 	patchZ=  Patch z coordinate.
	* 	LOD=  The level of detail to set the patch to. 
	*/
	void setLODOfPatch(int patchX, int patchZ, int LOD=0);

	/// Get center of terrain.
	auto ref const vector3df getTerrainCenter()() const;

	/// Get height of a point of the terrain.
	float getHeight(float x, float y) const;

	/// Sets the movement camera threshold.
	/**
	* It is used to determine when to recalculate
	* indices for the scene node. The default value is 10.0f. 
	*/
	void setCameraMovementDelta(float delta);

	/// Sets the rotation camera threshold.
	/**
	* It is used to determine when to recalculate
	* indices for the scene node. The default value is 1.0f. 
	*/
	void setCameraRotationDelta(float delta);

	/// Sets whether or not the node should dynamically update its associated selector when the geomipmap data changes.
	/**
	* Params:
	* 	bVal=  Boolean value representing whether or not to update selector dynamically. 
	*/
	void setDynamicSelectorUpdate(bool bVal);

	/// Override the default generation of distance thresholds.
	/**
	* For determining the LOD a patch is rendered at. If any LOD
	* is overridden, then the scene node will no longer apply scaling
	* factors to these values. If you override these distances, and
	* then apply a scale to the scene node, it is your responsibility
	* to update the new distances to work best with your new terrain
	* size. 
	*/
	bool overrideLODDistance(int LOD, double newDistance);

	/// Scales the base texture, similar to makePlanarTextureMapping.
	/**
	* Params:
	* 	scale=  The scaling amount. Values above 1.0
	* increase the number of time the texture is drawn on the
	* terrain. Values below 0 will decrease the number of times the
	* texture is drawn on the terrain. Using negative values will
	* flip the texture, as well as still scaling it.
	* 	scale2=  If set to 0 (default value), this will set the
	* second texture coordinate set to the same values as in the
	* first set. If this is another value than zero, it will scale
	* the second texture coordinate set by this value. 
	*/
	void scaleTexture(float scale = 1.0f, float scale2=0.0f);

	/// Initializes the terrain data.  Loads the vertices from the heightMapFile.
	/**
	* The file must contain a loadable image of the heightmap. The heightmap
	* must be square.
	* Params:
	* 	file=  The file to read the image from. File is not rewinded.
	* 	vertexColor=  Color of all vertices.
	* 	smoothFactor=  Number of smoothing passes. 
	*/
	bool loadHeightMap(IReadFile file, 
		SColor vertexColor = SColor(255,255,255,255),
		int smoothFactor=0);

	/// Initializes the terrain data.  Loads the vertices from the heightMapFile.
	/**
	* The data is interpreted as (signed) integers of the given bit size or
	* floats (with 32bits, signed). Allowed bitsizes for integers are
	* 8, 16, and 32. The heightmap must be square.
	* Params:
	* 	file=  The file to read the RAW data from. File is not rewinded.
	* 	bitsPerPixel=  Size of data if integers used, for floats always use 32.
	* 	signedData=  Whether we use signed or unsigned ints, ignored for floats.
	* 	floatVals=  Whether the data is float or int.
	* 	width=  Width (and also Height, as it must be square) of the heightmap. Use 0 for autocalculating from the filesize.
	* 	vertexColor=  Color of all vertices.
	* 	smoothFactor=  Number of smoothing passes. 
	*/
	bool loadHeightMapRAW(IReadFile file, int bitsPerPixel = 16,
		bool signedData = false, bool floatVals = false, int width =0 ,
		SColor vertexColor = SColor(255,255,255,255),
		int smoothFactor = 0);

}