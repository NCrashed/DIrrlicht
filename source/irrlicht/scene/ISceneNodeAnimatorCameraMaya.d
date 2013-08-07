// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneNodeAnimatorCameraMaya;

import irrlicht.scene.ISceneNodeAnimator;

/// Special scene node animator for Maya-style cameras
/**
* This scene node animator can be attached to a camera to make it act like a 3d
* modelling tool.
* The camera is moving relative to the target with the mouse, by pressing either
* of the three buttons.
* In order to move the camera, set a new target for the camera. The distance defines
* the current orbit radius the camera moves on. Distance can be changed via the setter
* or by mouse events.
*/
abstract class ISceneNodeAnimatorCameraMaya : ISceneNodeAnimator
{
	/// Returns the speed of movement
	float getMoveSpeed() const;

	/// Sets the speed of movement
	void setMoveSpeed(float moveSpeed);

	/// Returns the rotation speed
	float getRotateSpeed() const;

	/// Set the rotation speed
	void setRotateSpeed(float rotateSpeed);

	/// Returns the zoom speed
	float getZoomSpeed() const;

	/// Set the zoom speed
	void setZoomSpeed(float zoomSpeed);

	/// Returns the current distance, i.e. orbit radius
	float getDistance() const;

	/// Set the distance
	void setDistance(float distance);
}