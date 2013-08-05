// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IBoneSceneNode;

import irrlicht.scene.ISceneManager;
import irrlicht.scene.ISceneNode;
import irrlicht.core.aabbox3d;

/// Enumeration for different bone animation modes
enum E_BONE_ANIMATION_MODE
{
	/// The bone is usually animated, unless it's parent is not animated
	EBAM_AUTOMATIC=0,

	/// The bone is animated by the skin, if it's parent is not animated then animation will resume from this bone onward
	EBAM_ANIMATED,

	/// The bone is not animated by the skin
	EBAM_UNANIMATED,

	/// Not an animation mode, just here to count the available modes
	EBAM_COUNT

}

enum E_BONE_SKINNING_SPACE
{
	/// local skinning, standard
	EBSS_LOCAL=0,

	/// global skinning
	EBSS_GLOBAL,

	EBSS_COUNT
}

/// Names for bone animation modes
immutable(string[]) BoneAnimationModeNames =
[
	"automatic",
	"animated",
	"unanimated",
];


/// Interface for bones used for skeletal animation.
/**
* Used with ISkinnedMesh and IAnimatedMeshSceneNode. 
*/
abstract class IBoneSceneNode : ISceneNode
{
	this(ISceneNode parent, ISceneManager mgr, int id=-1)
	{ 
		super(parent, mgr, id);
		positionHint = -1;
		scaleHint = -1;
		rotationHint = -1;
	}

	/// Get the name of the bone
	/**
	* Deprecated:  Use getName instead. This method may be removed by Irrlicht 1.9 
	*/
	deprecated string getBoneName() const 
	{ 
		return getName(); 
	}

	/// Get the index of the bone
	uint getBoneIndex() const;

	/// Sets the animation mode of the bone.
	/**
	* Returns: True if successful. (Unused) 
	*/
	bool setAnimationMode(E_BONE_ANIMATION_MODE mode);

	/// Gets the current animation mode of the bone
	E_BONE_ANIMATION_MODE getAnimationMode() const;

	/// Get the axis aligned bounding box of this node
	auto ref const aabbox3d!float getBoundingBox()() const;

	/// Returns the relative transformation of the scene node.
	//matrix4 getRelativeTransformation() const;

	/// The animation method.
	override void OnAnimate(uint timeMs);

	/// The render method.
	/**
	* Does nothing as bones are not visible. 
	*/
	override void render() 
	{ 

	}

	/// How the relative transformation of the bone is used
	void setSkinningSpace( E_BONE_SKINNING_SPACE space );

	/// How the relative transformation of the bone is used
	E_BONE_SKINNING_SPACE getSkinningSpace() const;

	/// Updates the absolute position based on the relative and the parents position
	void updateAbsolutePositionOfAllChildren();

	int positionHint;
	int scaleHint;
	int rotationHint;
}
