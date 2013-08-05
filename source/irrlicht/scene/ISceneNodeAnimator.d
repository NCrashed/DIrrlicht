// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneNodeAnimator;

import irrlicht.core.vector3d;
import irrlicht.scene.ESceneNodeAnimatorTypes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.IEventReceiver;
import irrlicht.io.IAttributes;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;

/// Animates a scene node. Can animate position, rotation, material, and so on.
/**
* A scene node animator is able to animate a scene node in a very simple way. It may
* change its position, rotation, scale and/or material. There are lots of animators
* to choose from. You can create scene node animators with the ISceneManager interface.
*/
abstract class ISceneNodeAnimator : IAttributeExchangingObject, IEventReceiver
{
	/// Animates a scene node.
	/**
	* Params:
	* 	node=  Node to animate.
	* 	timeMs=  Current time in milli seconds. 
	*/
	void animateNode(ISceneNode node, uint timeMs);

	/// Creates a clone of this animator.
	ISceneNodeAnimator createClone(ISceneNode node,
			ISceneManager newManager = null);

	/// Returns true if this animator receives events.
	/**
	* When attached to an active camera, this animator will be
	* able to respond to events such as mouse and keyboard events. 
	*/
	bool isEventReceiverEnabled() const
	{
		return false;
	}

	/// Event receiver, override this function for camera controlling animators
	bool OnEvent()(auto ref const SEvent event)
	{
		return false;
	}

	/// Returns type of the scene node animator
	ESCENE_NODE_ANIMATOR_TYPE getType() const
	{
		return ESCENE_NODE_ANIMATOR_TYPE.ESNAT_UNKNOWN;
	}

	/// Returns if the animator has finished.
	/**
	* This is only valid for non-looping animators with a discrete end state.
	* Returns: true if the animator has finished, false if it is still running. 
	*/
	bool hasFinished() const
	{
		return false;
	}
}