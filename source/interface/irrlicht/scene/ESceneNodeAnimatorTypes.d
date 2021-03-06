// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ESceneNodeAnimatorTypes;

/// An enumeration for all types of built-in scene node animators
enum ESCENE_NODE_ANIMATOR_TYPE : uint
{
	/// Fly circle scene node animator
	ESNAT_FLY_CIRCLE = 0,

	/// Fly straight scene node animator
	ESNAT_FLY_STRAIGHT,

	/// Follow spline scene node animator
	ESNAT_FOLLOW_SPLINE,

	/// Rotation scene node animator
	ESNAT_ROTATION,

	/// Texture scene node animator
	ESNAT_TEXTURE,

	/// Deletion scene node animator
	ESNAT_DELETION,

	/// Collision respose scene node animator
	ESNAT_COLLISION_RESPONSE,

	/// FPS camera animator
	ESNAT_CAMERA_FPS,

	/// Maya camera animator
	ESNAT_CAMERA_MAYA,

	/// Amount of built-in scene node animators
	ESNAT_COUNT,

	/// Unknown scene node animator
	ESNAT_UNKNOWN,
}