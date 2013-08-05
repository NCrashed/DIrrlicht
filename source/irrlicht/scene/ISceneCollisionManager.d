// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneCollisionManager;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ICameraSceneNode;
import irrlicht.scene.ITriangleSelector;
import irrlicht.core.vector3d;
import irrlicht.core.triangle3d;
import irrlicht.core.vector2d;
import irrlicht.core.line3d;

/// The Scene Collision Manager provides methods for performing collision tests and picking on scene nodes.
interface ISceneCollisionManager
{

	/// Finds the nearest collision point of a line and lots of triangles, if there is one.
	/**
	* Params:
	* 	ray=  Line with which collisions are tested.
	* 	selector=  TriangleSelector containing the triangles. It
	* can be created for example using
	* ISceneManager.createTriangleSelector() or
	* ISceneManager.createTriangleOctreeSelector().
	* 	outCollisionPoint=  If a collision is detected, this will
	* contain the position of the nearest collision to the line-start.
	* 	outTriangle=  If a collision is detected, this will
	* contain the triangle with which the ray collided.
	* 	outNode=  If a collision is detected, this will contain
	* the scene node associated with the triangle that was hit.
	* Returns: True if a collision was detected and false if not. 
	*/
	bool getCollisionPoint()(auto ref const line3d!float ray,
			ITriangleSelector selector, out vector3df outCollisionPoint,
			out triangle3df outTriangle, out ISceneNode outNode);

	/// Collides a moving ellipsoid with a 3d world with gravity and returns the resulting new position of the ellipsoid.
	/**
	* This can be used for moving a character in a 3d world: The
	* character will slide at walls and is able to walk up stairs.
	* The method used how to calculate the collision result position
	* is based on the paper "Improved Collision detection and
	* Response" by Kasper Fauerby.
	* Params:
	* 	selector=  TriangleSelector containing the triangles of
	* the world. It can be created for example using
	* ISceneManager.createTriangleSelector() or
	* ISceneManager.createTriangleOctreeSelector().
	* 	ellipsoidPosition=  Position of the ellipsoid.
	* 	ellipsoidRadius=  Radius of the ellipsoid.
	* 	ellipsoidDirectionAndSpeed=  Direction and speed of the
	* movement of the ellipsoid.
	* 	triout=  Optional parameter where the last triangle
	* causing a collision is stored, if there is a collision.
	* 	hitPosition=  Return value for the position of the collision
	* 	outFalling=  Is set to true if the ellipsoid is falling
	* down, caused by gravity.
	* 	outNode=  the node with which the ellipoid collided (if any)
	* 	slidingSpeed=  DOCUMENTATION NEEDED.
	* 	gravityDirectionAndSpeed=  Direction and force of gravity.
	* Returns: New position of the ellipsoid. 
	*/
	vector3df getCollisionResultPosition()(
		ITriangleSelector selector,
		auto ref const vector3df ellipsoidPosition,
		auto ref const vector3df ellipsoidRadius,
		auto ref const vector3df ellipsoidDirectionAndSpeed,
		out triangle3df triout,
		out vector3df hitPosition,
		out bool outFalling,
		out ISceneNode outNode,
		auto ref const vector3df gravityDirectionAndSpeed,
		float slidingSpeed = 0.0005f);

	/// Returns a 3d ray which would go through the 2d screen coodinates.
	/**
	* Params:
	* 	pos=  Screen coordinates in pixels.
	* 	camera=  Camera from which the ray starts. If null, the
	* active camera is used.
	* Returns: Ray starting from the position of the camera and ending
	* at a length of the far value of the camera at a position which
	* would be behind the 2d screen coodinates. 
	*/
	line3d!float getRayFromScreenCoordinates()(
		auto ref const position2d!int pos, ICameraSceneNode camera = null);

	/// Calculates 2d screen position from a 3d position.
	/**
	* Params:
	* 	pos=  3D position in world space to be transformed
	* into 2d.
	* 	camera=  Camera to be used. If null, the currently active
	* camera is used.
	* 	useViewPort=  Calculate screen coordinates relative to
	* the current view port. Please note that unless the driver does
	* not take care of the view port, it is usually best to get the
	* result in absolute screen coordinates (flag=false).
	* Returns: 2d screen coordinates which a object in the 3d world
	* would have if it would be rendered to the screen. If the 3d
	* position is behind the camera, it is set to (-1000,-1000). In
	* most cases you can ignore this fact, because if you use this
	* method for drawing a decorator over a 3d object, it will be
	* clipped by the screen borders. 
	*/
	position2d!int getScreenCoordinatesFrom3DPosition()(
		auto ref const vector3df pos, ICameraSceneNode camera = null, bool useViewPort = false);

	/// Gets the scene node, which is currently visible under the given screencoordinates, viewed from the currently active camera.
	/**
	* The collision tests are done using a bounding box for each
	* scene node. You can limit the recursive search so just all children of the specified root are tested.
	* Params:
	* 	pos=  Position in pixel screen coordinates, under which
	* the returned scene node will be.
	* 	idBitMask=  Only scene nodes with an id with bits set
	* like in this mask will be tested. If the BitMask is 0, this
	* feature is disabled.
	* Please note that the default node id of -1 will match with
	* every bitmask != 0
	* 	bNoDebugObjects=  Doesn't take debug objects into account
	* when true. These are scene nodes with IsDebugObject() = true.
	* 	root=  If different from 0, the search is limited to the children of this node.
	* Returns: Visible scene node under screen coordinates with
	* matching bits in its id. If there is no scene node under this
	* position, 0 is returned. 
	*/
	ISceneNode getSceneNodeFromScreenCoordinatesBB()(auto ref const position2d!int pos,
			int idBitMask = 0, bool bNoDebugObjects = false, ISceneNode root = null);

	/// Returns the nearest scene node which collides with a 3d ray and whose id matches a bitmask.
	/**
	* The collision tests are done using a bounding box for each
	* scene node. The recursive search can be limited be specifying a scene node.
	* Params:
	* 	ray=  Line with which collisions are tested.
	* 	idBitMask=  Only scene nodes with an id which matches at
	* least one of the bits contained in this mask will be tested.
	* However, if this parameter is 0, then all nodes are checked.
	* 	bNoDebugObjects=  Doesn't take debug objects into account when true. These
	* are scene nodes with IsDebugObject() = true.
	* 	root=  If different from 0, the search is limited to the children of this node.
	* Returns: Scene node nearest to ray.start, which collides with
	* the ray and matches the idBitMask, if the mask is not null. If
	* no scene node is found, 0 is returned. 
	*/
	ISceneNode getSceneNodeFromRayBB()(auto ref const line3d!float ray,
						int idBitMask = 0, bool bNoDebugObjects = false, ISceneNode root = null);

	/// Get the scene node, which the given camera is looking at and whose id matches the bitmask.
	/**
	* A ray is simply casted from the position of the camera to
	* the view target position, and all scene nodes are tested
	* against this ray. The collision tests are done using a bounding
	* box for each scene node.
	* Params:
	* 	camera=  Camera from which the ray is casted.
	* 	idBitMask=  Only scene nodes with an id which matches at least one of the
	* bits contained in this mask will be tested. However, if this parameter is 0, then
	* all nodes are checked.
	* feature is disabled.
	* Please note that the default node id of -1 will match with
	* every bitmask != 0
	* 	bNoDebugObjects=  Doesn't take debug objects into account
	* when true. These are scene nodes with IsDebugObject() = true.
	* Returns: Scene node nearest to the camera, which collides with
	* the ray and matches the idBitMask, if the mask is not null. If
	* no scene node is found, 0 is returned. 
	*/
	ISceneNode getSceneNodeFromCameraBB(ICameraSceneNode camera,
		int idBitMask = 0, bool bNoDebugObjects = false);

	/// Perform a ray/box and ray/triangle collision check on a heirarchy of scene nodes.
	/**
	* This checks all scene nodes under the specified one, first by ray/bounding
	* box, and then by accurate ray/triangle collision, finding the nearest collision,
	* and the scene node containg it.  It returns the node hit, and (via output
	* parameters) the position of the collision, and the triangle that was hit.
	* All scene nodes in the hierarchy tree under the specified node are checked. Only
	* nodes that are visible, with an ID that matches at least one bit in the supplied
	* bitmask, and which have a triangle selector are considered as candidates for being hit.
	* You do not have to build a meta triangle selector; the individual triangle selectors
	* of each candidate scene node are used automatically.
	* Params:
	* 	ray=  Line with which collisions are tested.
	* 	outCollisionPoint=  If a collision is detected, this will contain the
	* position of the nearest collision.
	* 	outTriangle=  If a collision is detected, this will contain the triangle
	* with which the ray collided.
	* 	idBitMask=  Only scene nodes with an id which matches at least one of the
	* bits contained in this mask will be tested. However, if this parameter is 0, then
	* all nodes are checked.
	* 	collisionRootNode=  the scene node at which to begin checking. Only this
	* node and its children will be checked. If you want to check the entire scene,
	* pass 0, and the root scene node will be used (this is the default).
	* 	noDebugObjects=  when true, debug objects are not considered viable targets.
	* Debug objects are scene nodes with IsDebugObject() = true.
	* Returns: Returns the scene node containing the hit triangle nearest to ray.start.
	* If no collision is detected, then 0 is returned. 
	*/
	ISceneNode getSceneNodeAndCollisionPointFromRay()(
							auto ref const line3df ray,
							out vector3df outCollisionPoint,
							out triangle3df outTriangle,
							int idBitMask = 0,
							ISceneNode collisionRootNode = null,
							bool noDebugObjects = false);
}