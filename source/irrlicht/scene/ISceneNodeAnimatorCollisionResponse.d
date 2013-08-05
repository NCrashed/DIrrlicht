// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneNodeAnimatorCollisionResponse;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneNodeAnimator;
import irrlicht.scene.ITriangleSelector;
import irrlicht.core.vector3d;

/// Callback interface for catching events of collisions.
/**
* Implement this interface and use
* ISceneNodeAnimatorCollisionResponse.setCollisionCallback to be able to
* be notified if a collision has occurred.
**/
interface ICollisionCallback
{
	/// Will be called when a collision occurrs.
	/**
	* See_Also:
	* 	ISceneNodeAnimatorCollisionResponse.setCollisionCallback for more information.
	* Params:
	* 	animator=  Collision response animator in which the collision occurred. You can call
	* this animator's methods to find the node, collisionPoint and/or collision triangle.
	* Returns: true if the collision was handled in the animator. The animator's target
	* node will *not* be stopped at the collision point, but will instead move fully
	* to the location that triggered the collision check.
	* false if the collision was not handled in the animator. The animator's
	* target node will be moved to the collision position.
	*/
	bool onCollision(const ISceneNodeAnimatorCollisionResponse animator);
}

/// Special scene node animator for doing automatic collision detection and response.
/**
* This scene node animator can be attached to any single scene node
* and will then prevent it from moving through specified collision geometry
* (e.g. walls and floors of the) world, as well as having it fall under gravity.
* This animator provides a simple implementation of first person shooter cameras.
* Attach it to a camera, and the camera will behave as the player control in a
* first person shooter game: The camera stops and slides at walls, walks up stairs,
* falls down if there is no floor under it, and so on.
* The animator will treat any change in the position of its target scene
* node as movement, including a setPosition(), as movement.  If you want to
* teleport the target scene node manually to a location without it being effected
* by collision geometry, then call setTargetNode(node) after calling node.setPosition().
*/
abstract class ISceneNodeAnimatorCollisionResponse : ISceneNodeAnimator
{
	/// Check if the attached scene node is falling.
	/**
	* Falling means that there is no blocking wall from the scene
	* node in the direction of the gravity. The implementation of
	* this method is very fast, no collision detection is done when
	* invoking it.
	* Returns: True if the scene node is falling, false if not. 
	*/
	bool isFalling() const;

	/// Sets the radius of the ellipsoid for collision detection and response.
	/**
	* If you have a scene node, and you are unsure about how big
	* the radius should be, you could use the following code to
	* determine it:
	* Examples:
	* ------
	* aabbox!float box = yourSceneNode.getBoundingBox();
	* vector3df radius = box.MaxEdge - box.getCenter();
	* ------
	* Params:
	* 	radius=  New radius of the ellipsoid. 
	*/
	void setEllipsoidRadius()(auto ref const vector3df radius);

	/// Returns the radius of the ellipsoid for collision detection and response.
	/**
	* Returns: Radius of the ellipsoid. 
	*/
	auto ref const vector3df getEllipsoidRadius()() const;

	/// Sets the gravity of the environment.
	/**
	* A good example value would be vector3df(0,-100.0f,0)
	* for letting gravity affect all object to fall down. For bigger
	* gravity, make increase the length of the vector. You can
	* disable gravity by setting it to vector3df(0,0,0);
	* Params:
	* 	gravity=  New gravity vector. 
	*/
	void setGravity()(auto ref const vector3df gravity);

	/// Get current vector of gravity.
	/** 
	* Returns: Gravity vector. 
	*/
	auto ref vector3df getGravity()() const;

	/// 'Jump' the animator, by adding a jump speed opposite to its gravity
	/**
	* Params:
	* 	jumpSpeed=  The initial speed of the jump; the velocity will be opposite
	* to this animator's gravity vector. 
	*/
	void jump(float jumpSpeed);

	/// Should the Target react on collision ( default = true )
	void setAnimateTarget ( bool enable );
	bool getAnimateTarget () const;

	/// Set translation of the collision ellipsoid.
	/**
	* By default, the ellipsoid for collision detection is
	* created around the center of the scene node, which means that
	* the ellipsoid surrounds it completely. If this is not what you
	* want, you may specify a translation for the ellipsoid.
	* Params:
	* 	translation=  Translation of the ellipsoid relative
	* to the position of the scene node. 
	*/
	void setEllipsoidTranslation()(auto ref const vector3df translation);

	/// Get the translation of the ellipsoid for collision detection.
	/**
	* See_Also:
	* 	
	* ISceneNodeAnimatorCollisionResponse.setEllipsoidTranslation()
	* for more details.
	* Returns: Translation of the ellipsoid relative to the position
	* of the scene node. 
	*/
	auto ref const vector3df getEllipsoidTranslation() const;

	/// Sets a triangle selector holding all triangles of the world with which the scene node may collide.
	/**
	* Params:
	* 	newWorld=  New triangle selector containing triangles
	* to let the scene node collide with. 
	*/
	void setWorld(ITriangleSelector newWorld);

	/// Get the current triangle selector containing all triangles for collision detection.
	ITriangleSelector getWorld() const;

	/// Set the single node that this animator will act on.
	/**
	* Params:
	* 	node=  The new target node. Setting this will force the animator to update
				* its last target position for the node, allowing setPosition() to teleport
				* the node through collision geometry. 
				*/
	void setTargetNode(ISceneNode node);

	/// Gets the single node that this animator is acting on.
	/**
	* Returns: The node that this animator is acting on. 
	*/
	ISceneNode getTargetNode() const;

	/// Returns true if a collision occurred during the last animateNode()
	bool collisionOccurred() const;

	/// Returns the last point of collision.
	auto ref const vector3df getCollisionPoint()() const;

	/// Returns the last triangle that caused a collision
	auto ref const triangle3df getCollisionTriangle()() const;

	/// Returns the position that the target node will be moved to, unless the collision is consumed in a callback.
	/**
	* If you have a collision callback registered, and it consumes the collision, then the
	* node will ignore the collision and will not stop at this position. Instead, it will
	* move fully to the position that caused the collision to occur. 
	*/
	auto ref const vector3df  getCollisionResultPosition() const;

	/// Returns the node that was collided with.
	ISceneNode getCollisionNode() const;

	/// Sets a callback interface which will be called if a collision occurs.
	/**
	* Params:
	* 	callback=  collision callback handler that will be called when a collision
	* occurs. Set this to 0 to disable the callback.
	*/
	void setCollisionCallback(ICollisionCallback callback);
}