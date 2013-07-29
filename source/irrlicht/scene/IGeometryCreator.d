// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IGeometryCreator;

import irrlicht.scene.IMesh;
import irrlicht.video.IImage;
import irrlicht.video.IVideoDriver;
import irrlicht.video.SMaterial;
import irrlicht.video.SColor;
import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;

/// Helper class for creating geometry on the fly.
/**
* You can get an instance of this class through ISceneManager.getGeometryCreator() 
*/
abstract class IGeometryCreator
{
	/// Creates a simple cube mesh.
	/**
	* Params:
	* 	size=  Dimensions of the cube.
	* Returns: Generated mesh.
	*/
	IMesh createCubeMesh(const vector3df size = vector3df(5.0f,5.0f,5.0f)) const;

	/// Create a pseudo-random mesh representing a hilly terrain.
	/**
	* Params:
	* 	tileSize=  The size of each tile.
	* 	tileCount=  The number of tiles in each dimension.
	* 	material=  The material to apply to the mesh.
	* 	hillHeight=  The maximum height of the hills.
	* 	countHills=  The number of hills along each dimension.
	* 	textureRepeatCount=  The number of times to repeat the material texture along each dimension.
	* Returns: Generated mesh.
	*/
	IMesh createHillPlaneMesh()(
			auto ref const dimension2d!float tileSize,
			auto ref const dimension2d!uint tileCount,
			SMaterial material, float hillHeight,
			auto ref const dimension2d!float countHills,
			auto ref const dimension2d!float textureRepeatCount) const;

	/// Create a simple rectangular textured plane mesh.
	/**
	* Params:
	* 	tileSize=  The size of each tile.
	* 	tileCount=  The number of tiles in each dimension.
	* 	material=  The material to apply to the mesh.
	* 	textureRepeatCount=  The number of times to repeat the material texture along each dimension.
	* Returns: Generated mesh.
	*/
	IMesh createPlaneMesh()(
			auto ref const dimension2d!float tileSize,
			const dimension2d!uint tileCount = dimension2du(1,1),
			SMaterial* material=0,
			const dimension2df textureRepeatCount = dimension2df(1.0f,1.0f)) const
	{
		return createHillPlaneMesh(tileSize, tileCount, material, 0.0f, dimension2df(0.0f), textureRepeatCount);
	}

	/// Create a terrain mesh from an image representing a heightfield.
	/**
	* Params:
	* 	texture=  The texture to apply to the terrain.
	* 	heightmap=  An image that will be interpreted as a heightmap. The
	* brightness (average color) of each pixel is interpreted as a height,
	* with a 255 brightness pixel producing the maximum height.
	* 	stretchSize=  The size that each pixel will produce, i.e. a
	* 512x512 heightmap
	* and a stretchSize of (10.f, 20.f) will produce a mesh of size
	* 5120.f x 10240.f
	* 	maxHeight=  The maximum height of the terrain.
	* 	driver=  The current video driver.
	* 	defaultVertexBlockSize=  (to be documented)
	* 	debugBorders=  (to be documented)
	* Returns: Generated mesh.
	*/
	IMesh createTerrainMesh()(IImage texture,
			IImage heightmap,
			auto ref const dimension2d!float stretchSize,
			float maxHeight, IVideoDriver driver,
			auto ref const dimension2d!uint defaultVertexBlockSize,
			bool debugBorders = false) const;

	/// Create an arrow mesh, composed of a cylinder and a cone.
	/**
	* Params:
	* 	tesselationCylinder=  Number of quads composing the cylinder.
	* 	tesselationCone=  Number of triangles composing the cone's roof.
	* 	height=  Total height of the arrow
	* 	cylinderHeight=  Total height of the cylinder, should be lesser
	* than total height
	* 	widthCylinder=  Diameter of the cylinder
	* 	widthCone=  Diameter of the cone's base, should be not smaller
	* than the cylinder's diameter
	* 	colorCylinder=  color of the cylinder
	* 	colorCone=  color of the cone
	* Returns: Generated mesh.
	*/
	IMesh createArrowMesh(const uint tesselationCylinder = 4u,
			const uint tesselationCone = 8u, const float height = 1.0f,
			const float cylinderHeight = 0.6f, const float widthCylinder = 0.05f,
			const float widthCone = 0.3f, const SColor colorCylinder = SColor(0xFFFFFFFF),
			const SColor colorCone = SColor(0xFFFFFFFF)) const;


	/// Create a sphere mesh.
	/**
	* Params:
	* 	radius=  Radius of the sphere
	* 	polyCountX=  Number of quads used for the horizontal tiling
	* 	polyCountY=  Number of quads used for the vertical tiling
	* Returns: Generated mesh.
	*/
	IMesh createSphereMesh(float radius = 5.0f,
			uint polyCountX = 16u, uint polyCountY = 16u) const;

	/// Create a cylinder mesh.
	/**
	* Params:
	* 	radius=  Radius of the cylinder.
	* 	length=  Length of the cylinder.
	* 	tesselation=  Number of quads around the circumference of the cylinder.
	* 	color=  The color of the cylinder.
	* 	closeTop=  If true, close the ends of the cylinder, otherwise leave them open.
	* 	oblique=  (to be documented)
	* Returns: Generated mesh.
	*/
	IMesh createCylinderMesh(float radius, float length,
			uint tesselation,
			const SColor color = SColor(0xffffffff),
			bool closeTop = true, float oblique = 0.0f) const;

	/// Create a cone mesh.
	/**
	* Params:
	* 	radius=  Radius of the cone.
	* 	length=  Length of the cone.
	* 	tesselation=  Number of quads around the circumference of the cone.
	* 	colorTop=  The color of the top of the cone.
	* 	colorBottom=  The color of the bottom of the cone.
	* 	oblique=  (to be documented)
	* Returns: Generated mesh.
	*/
	IMesh createConeMesh(float radius, float length, uint tesselation,
			const SColor colorTop = SColor(0xffffffff),
			const SColor colorBottom = SColor(0xffffffff),
			float oblique = 0.0f) const;

	/// Create a volume light mesh.
	/**
	* Params:
	* 	subdivideU=  Horizontal patch count.
	* 	subdivideV=  Vertical patch count.
	* 	footColor=  Color at the bottom of the light.
	* 	tailColor=  Color at the mid of the light.
	* 	lpDistance=  Virtual distance of the light point for normals.
	* 	lightDim=  Dimensions of the light.
	* Returns: Generated mesh.
	*/
	IMesh createVolumeLightMesh(
			const uint subdivideU = 32u, const uint subdivideV=32u,
			const SColor footColor = SColor(0xffffffff),
			const SColor tailColor = SColor(0xffffffff),
			const float lpDistance = 8.0f,
			const vector3df lightDim = vector3df(1.0f,1.2f,1.0f)) const;
}
