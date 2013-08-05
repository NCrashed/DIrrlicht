// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleGravityAffector;

import irrlicht.scene.IParticleAffector;
import irrlicht.core.vector3d;

/// A particle affector which applies gravity to particles.
abstract class IParticleGravityAffector : IParticleAffector
{
	/// Set the time in milliseconds when the gravity force is totally lost
	/** 
	* At that point the particle does not move any more. 
	*/
	void setTimeForceLost( float timeForceLost );

	/// Set the direction and force of gravity in all 3 dimensions.
	void setGravity()( auto ref const vector3df gravity );

	/// Get the time in milliseconds when the gravity force is totally lost
	float getTimeForceLost() const;

	/// Get the direction and force of gravity.
	auto ref const vector3df getGravity()() const;

	/// Get emitter type
	override E_PARTICLE_AFFECTOR_TYPE getType() const 
	{ 
		return E_PARTICLE_AFFECTOR_TYPE.EPAT_GRAVITY; 
	}
}