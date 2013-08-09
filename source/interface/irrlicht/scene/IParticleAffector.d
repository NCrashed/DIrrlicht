// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleAffector;

import irrlicht.io.IAttributeExchangingObject;
import irrlicht.scene.SParticle;

/// Types of built in particle affectors
enum E_PARTICLE_AFFECTOR_TYPE
{
	EPAT_NONE = 0,
	EPAT_ATTRACT,
	EPAT_FADE_OUT,
	EPAT_GRAVITY,
	EPAT_ROTATE,
	EPAT_SCALE,
	EPAT_COUNT
}

/// Names for built in particle affectors
immutable(string[]) ParticleAffectorTypeNames =
[
	"None",
	"Attract",
	"FadeOut",
	"Gravity",
	"Rotate",
	"Scale",
];

/// A particle affector modifies particles.
abstract class IParticleAffector : IAttributeExchangingObject
{
	/// constructor
	this()
	{
		Enabled = true;
	}

	/// Affects an array of particles.
	/**
	* Params:
	* 	now=  Current time. (Same as ITimer::getTime() would return)
	* 	particlearray=  Array of particles.
	* 	count=  Amount of particles in array. 
	*/
	void affect(uint now, SParticle[] particlearray);

	/// Sets whether or not the affector is currently enabled.
	void setEnabled(bool enabled) 
	{ 
		Enabled = enabled; 
	}

	/// Gets whether or not the affector is currently enabled.
	bool getEnabled() const 
	{ 
		return Enabled; 
	}

	/// Get emitter type
	E_PARTICLE_AFFECTOR_TYPE getType() const;

	protected bool Enabled;
}