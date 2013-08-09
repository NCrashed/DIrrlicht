// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ISceneNodeAnimatorCameraFPS;

import irrlicht.scene.ISceneNodeAnimator;
import irrlicht.IEventReceiver;
import irrlicht.SKeyMap;

/// Special scene node animator for FPS cameras
/**
* This scene node animator can be attached to a camera to make it act
* like a first person shooter 
*/
abstract class ISceneNodeAnimatorCameraFPS : ISceneNodeAnimator
{
	/// Returns the speed of movement in units per millisecond
	float getMoveSpeed() const;

	/// Sets the speed of movement in units per millisecond
	void setMoveSpeed(float moveSpeed);

	/// Returns the rotation speed in degrees
	/**
	* The degrees are equivalent to a half screen movement of the mouse,
	* i.e. if the mouse cursor had been moved to the border of the screen since
	* the last animation. 
	*/
	float getRotateSpeed() const;

	/// Set the rotation speed in degrees
	void setRotateSpeed(float rotateSpeed);

	/// Sets the keyboard mapping for this animator 
	/**
	* Params:
	* 	map=  Array of keyboard mappings, see irr::SKeyMap
	*/
	void setKeyMap(SKeyMap[] map);

	/// Gets the keyboard mapping for this animator
	const(SKeyMap[]) getKeyMap() const;

	/// Sets whether vertical movement should be allowed.
	/**
	* If vertical movement is enabled then the camera may fight with 
	* gravity causing camera shake. Disable this if the camera has 
	* a collision animator with gravity enabled. 
	*/
	void setVerticalMovement(bool allow);

	/// Sets whether the Y axis of the mouse should be inverted.
	/**
	* If enabled then moving the mouse down will cause
	* the camera to look up. It is disabled by default. 
	*/
	void setInvertMouse(bool invert);
}
