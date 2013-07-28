// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IMeshManipulator;

import irrlicht.core.vector3d;
import irrlicht.core.aabbox3d;
import irrlicht.core.matrix4;
import irrlicht.video.SColor;
import irrlicht.video.S3DVertex;
import irrlicht.video.IAnimatedMesh;
import irrlicht.scene.IMeshBuffer;
import irrlicht.scene.IMesh;
import irrlicht.scene.SVertexManipulator;
import irrlicht.scene.SMesh;
import std.traits;

/// An interface for easy manipulation of meshes.
/**
* Scale, set alpha value, flip surfaces, and so on. This exists for
* fixing problems with wrong imported or exported meshes quickly after
* loading. It is not intended for doing mesh modifications and/or
* animations during runtime.
*/
abstract class IMeshManipulator
{
	/// Flips the direction of surfaces.
	/**
	* Changes backfacing triangles to frontfacing
	* triangles and vice versa.
	* Params:
	* 	mesh=  Mesh on which the operation is performed. 
	*/
	void flipSurfaces(IMesh mesh) const;

	/// Sets the alpha vertex color value of the whole mesh to a new value.
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	alpha=  New alpha value. Must be a value between 0 and 255. 
	*/
	void setVertexColorAlpha(IMesh mesh, int alpha) const
	{
		apply(new SVertexColorSetAlphaManipulator(alpha), mesh, false);
	}

	/// Sets the alpha vertex color value of the whole mesh to a new value.
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	alpha=  New alpha value. Must be a value between 0 and 255. 
	*/
	void setVertexColorAlpha(IMeshBuffer buffer, int alpha) const
	{
		apply(new SVertexColorSetAlphaManipulator(alpha), buffer);
	}

	/// Sets the colors of all vertices to one color
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	color=  New color. 
	*/
	void setVertexColors(IMesh mesh, SColor color) const
	{
		apply(new SVertexColorSetManipulator(color), mesh);
	}

	/// Sets the colors of all vertices to one color
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	color=  New color. 
	*/
	void setVertexColors(IMeshBuffer buffer, SColor color) const
	{
		apply(new SVertexColorSetManipulator(color), buffer);
	}

	/// Recalculates all normals of the mesh.
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	smooth=  If the normals shall be smoothed.
	* 	angleWeighted=  If the normals shall be smoothed in relation to their angles. More expensive, but also higher precision. 
	*/
	void recalculateNormals(IMesh mesh, bool smooth = false,
			bool angleWeighted = false) const;

	/// Recalculates all normals of the mesh buffer.
	/**
	* Params:
	* 	buffer=  Mesh buffer on which the operation is performed.
	* 	smooth=  If the normals shall be smoothed.
	* 	angleWeighted=  If the normals shall be smoothed in relation to their angles. More expensive, but also higher precision. 
	*/
	void recalculateNormals(IMeshBuffer buffer,
			bool smooth = false, bool angleWeighted = false) const;

	/// Recalculates tangents, requires a tangent mesh
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	recalculateNormals=  If the normals shall be recalculated, otherwise original normals of the mesh are used unchanged.
	* 	smooth=  If the normals shall be smoothed.
	* 	angleWeighted=  If the normals shall be smoothed in relation to their angles. More expensive, but also higher precision.
	*/
	void recalculateTangents(IMesh mesh,
			bool recalculateNormals=false, bool smooth=false,
			bool angleWeighted=false) const;

	/// Recalculates tangents, requires a tangent mesh buffer
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	recalculateNormals=  If the normals shall be recalculated, otherwise original normals of the buffer are used unchanged.
	* 	smooth=  If the normals shall be smoothed.
	* 	angleWeighted=  If the normals shall be smoothed in relation to their angles. More expensive, but also higher precision.
	*/
	void recalculateTangents(IMeshBuffer buffer,
			bool recalculateNormals=false, bool smooth=false,
			bool angleWeighted=false) const;

	/// Scales the actual mesh, not a scene node.
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	factor=  Scale factor for each axis. 
	*/
	void scale()(IMesh mesh, auto ref const vector3df factor) const
	{
		apply(new SVertexPositionScaleManipulator(factor), mesh, true);
	}

	/// Scales the actual meshbuffer, not a scene node.
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	factor=  Scale factor for each axis. 
	*/
	void scale()(IMeshBuffer buffer, auto ref const vector3df factor) const
	{
		apply(new SVertexPositionScaleManipulator(factor), buffer, true);
	}

	/// Scales the actual mesh, not a scene node.
	/**
	* Deprecated:  Use scale() instead. This method may be removed by Irrlicht 1.9 
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	factor=  Scale factor for each axis. 
	*/
	deprecated void scaleMesh()(IMesh mesh, auto ref const vector3df factor) const {return scale(mesh,factor);}

	/// Scale the texture coords of a mesh.
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	factor=  Vector which defines the scale for each axis.
	* 	level=  Number of texture coord, starting from 1. Support for level 2 exists for LightMap buffers. 
	*/
	void scaleTCoords()(IMesh mesh, auto ref const vector2df factor, uint level=1u) const
	{
		apply(new SVertexTCoordsScaleManipulator(factor, level), mesh);
	}

	/// Scale the texture coords of a meshbuffer.
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	factor=  Vector which defines the scale for each axis.
	* 	level=  Number of texture coord, starting from 1. Support for level 2 exists for LightMap buffers. 
	*/
	void scaleTCoords()(IMeshBuffer buffer, auto ref const vector2df factor, uint level=1u) const
	{
		apply(new SVertexTCoordsScaleManipulator(factor, level), buffer);
	}

	/// Applies a transformation to a mesh
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	m=  transformation matrix. 
	*/
	void transform()(IMesh mesh, auto ref const matrix4 m) const
	{
		apply(new SVertexPositionTransformManipulator(m), mesh, true);
	}

	/// Applies a transformation to a meshbuffer
	/**
	* Params:
	* 	buffer=  Meshbuffer on which the operation is performed.
	* 	m=  transformation matrix. 
	*/
	void transform()(IMeshBuffer buffer, auto ref const matrix4 m) const
	{
		apply(new SVertexPositionTransformManipulator(m), buffer, true);
	}

	/// Applies a transformation to a mesh
	/**
	* Deprecated:  Use transform() instead. This method may be removed by Irrlicht 1.9 
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	m=  transformation matrix. 
	*/
	deprecated void transformMesh()(IMesh mesh, auto ref const matrix4 m) const {return transform(mesh,m);}

	/// Creates a planar texture mapping on the mesh
	/**
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	resolution=  resolution of the planar mapping. This is
	* the value specifying which is the relation between world space
	* and texture coordinate space. 
	*/
	void makePlanarTextureMapping()(IMesh mesh, float resolution = 0.001f) const;

	/// Creates a planar texture mapping on the meshbuffer
	/**
	* Params:
	* 	meshbuffer=  Buffer on which the operation is performed.
	* 	resolution=  resolution of the planar mapping. This is
	* the value specifying which is the relation between world space
	* and texture coordinate space. 
	*/
	void makePlanarTextureMapping()(IMeshBuffer meshbuffer, float resolution = 0.001f) const;

	/// Creates a planar texture mapping on the buffer
	/**
	* This method is currently implemented towards the LWO planar mapping. A more general biasing might be required.
	* Params:
	* 	mesh=  Mesh on which the operation is performed.
	* 	resolutionS=  Resolution of the planar mapping in horizontal direction. This is the ratio between object space and texture space.
	* 	resolutionT=  Resolution of the planar mapping in vertical direction. This is the ratio between object space and texture space.
	* 	axis=  The axis along which the texture is projected. The allowed values are 0 (X), 1(Y), and 2(Z).
	* 	offset=  Vector added to the vertex positions (in object coordinates).
	*/
	void makePlanarTextureMapping()(IMesh mesh,
			float resolutionS, float resolutionT,
			ubyte axis, auto ref const vector3df offset) const;

	/// Creates a planar texture mapping on the meshbuffer
	/**
	* This method is currently implemented towards the LWO planar mapping. A more general biasing might be required.
	* Params:
	* 	buffer=  Buffer on which the operation is performed.
	* 	resolutionS=  Resolution of the planar mapping in horizontal direction. This is the ratio between object space and texture space.
	* 	resolutionT=  Resolution of the planar mapping in vertical direction. This is the ratio between object space and texture space.
	* 	axis=  The axis along which the texture is projected. The allowed values are 0 (X), 1(Y), and 2(Z).
	* 	offset=  Vector added to the vertex positions (in object coordinates).
	*/
	void makePlanarTextureMapping()(IMeshBuffer buffer,
			float resolutionS, float resolutionT,
			ubyte axis, auto ref const vector3df offset) const;

	/// Clones a static IMesh into a modifiable SMesh.
	/**
	* All meshbuffers in the returned SMesh
	* are of type SMeshBuffer or SMeshBufferLightMap.
	* Params:
	* 	mesh=  Mesh to copy.
	* Returns: Cloned mesh. If you no longer need the
	* cloned mesh, you should call SMesh::drop(). See
	* IReferenceCounted::drop() for more information. 
	*/
	SMesh createMeshCopy(IMesh mesh) const;

	/// Creates a copy of the mesh, which will only consist of S3DVertexTangents vertices.
	/**
	* This is useful if you want to draw tangent space normal
	* mapped geometry because it calculates the tangent and binormal
	* data which is needed there.
	* Params:
	* 	mesh=  Input mesh
	* 	recalculateNormals=  The normals are recalculated if set,
	* otherwise the original ones are kept. Note that keeping the
	* normals may introduce inaccurate tangents if the normals are
	* very different to those calculated from the faces.
	* 	smooth=  The normals/tangents are smoothed across the
	* meshbuffer's faces if this flag is set.
	* 	angleWeighted=  Improved smoothing calculation used
	* 	recalculateTangents=  Whether are actually calculated, or just the mesh with proper type is created.
	* Returns: Mesh consisting only of S3DVertexTangents vertices. If
	* you no longer need the cloned mesh, you should call
	* IMesh::drop(). See IReferenceCounted::drop() for more
	* information. 
	*/
	IMesh createMeshWithTangents(IMesh mesh,
			bool recalculateNormals=false, bool smooth=false,
			bool angleWeighted=false, bool recalculateTangents=true) const;

	/// Creates a copy of the mesh, which will only consist of S3DVertex2TCoord vertices.
	/**
	* Params:
	* 	mesh=  Input mesh
	* Returns: Mesh consisting only of S3DVertex2TCoord vertices. If
	* you no longer need the cloned mesh, you should call
	* IMesh::drop(). See IReferenceCounted::drop() for more
	* information. 
	*/
	IMesh createMeshWith2TCoords(IMesh mesh) const;

	/// Creates a copy of the mesh, which will only consist of S3DVertex vertices.
	/**
	* Params:
	* 	mesh=  Input mesh
	* Returns: Mesh consisting only of S3DVertex vertices. If
	* you no longer need the cloned mesh, you should call
	* IMesh::drop(). See IReferenceCounted::drop() for more
	* information. 
	*/
	IMesh createMeshWith1TCoords(IMesh mesh) const;

	/// Creates a copy of a mesh with all vertices unwelded
	/**
	* Params:
	* 	mesh=  Input mesh
	* Returns: Mesh consisting only of unique faces. All vertices
	* which were previously shared are now duplicated. If you no
	* longer need the cloned mesh, you should call IMesh::drop(). See
	* IReferenceCounted::drop() for more information. 
	*/
	IMesh createMeshUniquePrimitives(IMesh mesh) const;

	/// Creates a copy of a mesh with vertices welded
	/**
	* Params:
	* 	mesh=  Input mesh
	* 	tolerance=  The threshold for vertex comparisons.
	* Returns: Mesh without redundant vertices. If you no longer need
	* the cloned mesh, you should call IMesh::drop(). See
	* IReferenceCounted::drop() for more information. 
	*/
	IMesh createMeshWelded(IMesh mesh, float tolerance=float.epsilon) const;

	/// Get amount of polygons in mesh.
	/**
	* Params:
	* 	mesh=  Input mesh
	* Returns: Number of polygons in mesh. 
	*/
	int getPolyCount(IMesh mesh) const;

	/// Get amount of polygons in mesh.
	/**
	* Params:
	* 	mesh=  Input mesh
	* Returns: Number of polygons in mesh. 
	*/
	int getPolyCount(IAnimatedMesh mesh) const;

	/// Create a new AnimatedMesh and adds the mesh to it
	/**
	* Params:
	* 	mesh=  Input mesh
	* 	type=  The type of the animated mesh to create.
	* Returns: Newly created animated mesh with mesh as its only
	* content. When you don't need the animated mesh anymore, you
	* should call IAnimatedMesh::drop(). See
	* IReferenceCounted::drop() for more information. 
	*/
	IAnimatedMesh createAnimatedMesh(IMesh mesh,
		E_ANIMATED_MESH_TYPE type = E_ANIMATED_MESH_TYPE.EAMT_UNKNOWN) const;

	/// Vertex cache optimization according to the Forsyth paper
	/**
	* More information can be found at
	* http://home.comcast.net/~tom_forsyth/papers/fast_vert_cache_opt.html
	* The function is thread-safe (read: you can optimize several
	* meshes in different threads).
	* Params:
	* 	mesh=  Source mesh for the operation.
	* Returns: A new mesh optimized for the vertex cache. 
	*/
	IMesh createForsythOptimizedMesh(const IMesh mesh) const;

	/// Apply a manipulator on the Meshbuffer
	/**
	* Params:
	* 	func=  A functor defining the mesh manipulation.
	* 	buffer=  The Meshbuffer to apply the manipulator to.
	* 	boundingBoxUpdate=  Specifies if the bounding box should be updated during manipulation.
	* Returns: True if the functor was successfully applied, else false. 
	*/
	bool apply(Functor)(const Functor func, IMeshBuffer buffer, bool boundingBoxUpdate=false) const
		//if(isCallable!Functor)
	{
		return apply_(func, buffer, boundingBoxUpdate, func);
	}


	/// Apply a manipulator on the Mesh
	/**
	* Params:
	* 	func=  A functor defining the mesh manipulation.
	* 	mesh=  The Mesh to apply the manipulator to.
	* 	boundingBoxUpdate=  Specifies if the bounding box should be updated during manipulation.
	* Returns: True if the functor was successfully applied, else false. 
	*/
	bool apply(Functor)(const Functor func, IMesh mesh, bool boundingBoxUpdate=false) const
		//if(isCallable!Functor)
	{
		if (mesh is null)
			return true;

		bool result = true;
		aabbox3df bufferbox;

		foreach(i, buffer; mesh)
		{
			result &= apply(func, buffer, boundingBoxUpdate);
			if (boundingBoxUpdate)
			{
				if (0==i)
					bufferbox.reset(buffer.getBoundingBox());
				else
					bufferbox.addInternalBox(buffer.getBoundingBox());
			}
		}
		if (boundingBoxUpdate)
			mesh.setBoundingBox(bufferbox);
		return result;
	}

	/// Apply a manipulator based on the type of the functor
	/**
	* Params:
	* 	func=  A functor defining the mesh manipulation.
	* 	buffer=  The Meshbuffer to apply the manipulator to.
	* 	boundingBoxUpdate=  Specifies if the bounding box should be updated during manipulation.
	* 	typeTest=  Unused parameter, which handles the proper call selection based on the type of the Functor which is passed in two times.
	* Returns: True if the functor was successfully applied, else false. 
	*/
	protected bool apply_(Functor)(const Functor func, IMeshBuffer buffer, bool boundingBoxUpdate, const IVertexManipulator typeTest) const @trusted
		//if(isCallable!Functor)
	{
		if (!buffer)
			return true;

		aabbox3df bufferbox;
		for (uint i; i<buffer.getVertexCount(); ++i)
		{
			final switch (buffer.getVertexType())
			{
				case E_VERTEX_TYPE.EVT_STANDARD:
				{
					S3DVertex* verts = cast(S3DVertex*)buffer.getVertices();
					func(verts[i]);
				}
				break;
				case E_VERTEX_TYPE.EVT_2TCOORDS:
				{
					S3DVertex2TCoords* verts = cast(S3DVertex2TCoords*)buffer.getVertices();
					func(verts[i]);
				}
				break;
				case E_VERTEX_TYPE.EVT_TANGENTS:
				{
					S3DVertexTangents* verts = cast(S3DVertexTangents*)buffer.getVertices();
					func(verts[i]);
				}
				break;
			}
			if (boundingBoxUpdate)
			{
				if (0==i)
					bufferbox.reset(buffer.getPosition(0));
				else
					bufferbox.addInternalPoint(buffer.getPosition(i));
			}
		}
		if (boundingBoxUpdate)
			buffer.setBoundingBox(bufferbox);
		return true;
	}
}
