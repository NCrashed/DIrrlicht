// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IAnimatedMeshMD2;

import irrlicht.scene.IAnimatedMesh;

/// Types of standard md2 animations
enum EMD2_ANIMATION_TYPE
{
	EMAT_STAND = 0,
	EMAT_RUN,
	EMAT_ATTACK,
	EMAT_PAIN_A,
	EMAT_PAIN_B,
	EMAT_PAIN_C,
	EMAT_JUMP,
	EMAT_FLIP,
	EMAT_SALUTE,
	EMAT_FALLBACK,
	EMAT_WAVE,
	EMAT_POINT,
	EMAT_CROUCH_STAND,
	EMAT_CROUCH_WALK,
	EMAT_CROUCH_ATTACK,
	EMAT_CROUCH_PAIN,
	EMAT_CROUCH_DEATH,
	EMAT_DEATH_FALLBACK,
	EMAT_DEATH_FALLFORWARD,
	EMAT_DEATH_FALLBACKSLOW,
	EMAT_BOOM,

	/// Not an animation, but amount of animation types.
	EMAT_COUNT
}

/// Interface for using some special functions of MD2 meshes
interface IAnimatedMeshMD2 : IAnimatedMesh
{
	/// Get frame loop data for a default MD2 animation type.
	/**
	* Params:
	* 	l=  The EMD2_ANIMATION_TYPE to get the frames for.
	* 	outBegin=  The returned beginning frame for animation type specified.
	* 	outEnd=  The returned ending frame for the animation type specified.
	* 	outFPS=  The number of frames per second, this animation should be played at.
	* Returns: beginframe, endframe and frames per second for a default MD2 animation type. 
	*/
	void getFrameLoop(EMD2_ANIMATION_TYPE l, out int outBegin,
		out int outEnd, out int outFPS) const;

	/// Get frame loop data for a special MD2 animation type, identified by name.
	/**
	* Params:
	* 	name=  Name of the animation.
	* 	outBegin=  The returned beginning frame for animation type specified.
	* 	outEnd=  The returned ending frame for the animation type specified.
	* 	outFPS=  The number of frames per second, this animation should be played at.
	* Returns: beginframe, endframe and frames per second for a special MD2 animation type. 
	*/
	bool getFrameLoop(string name,
		out int outBegin, out int outEnd, out int outFPS) const;

	/// Get amount of md2 animations in this file.
	size_t getAnimationCount() const;

	/// Get name of md2 animation.
	/**
	* Params:
	* 	nr=  Zero based index of animation. 
	*/
	string getAnimationName(size_t nr) const;
}
