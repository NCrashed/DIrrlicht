// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleRotationAffector;

import irrlicht.scene.IParticleAffector;
import irrlicht.core.vector3d;

/// A particle affector which rotates the particle system.
abstract class IParticleRotationAffector : IParticleAffector
{
	/// Set the point that particles will rotate around
	void setPivotPoint()( auto ref const vector3df point );

	/// Set the speed in degrees per second in all 3 dimensions
	void setSpeed()( auto const vector3df speed );

	/// Get the point that particles are attracted to
	auto ref const vector3df getPivotPoint()() const;

	/// Get the speed in degrees per second in all 3 dimensions
	auto ref const vector3df getSpeed()() const;

	/// Get emitter type
	override E_PARTICLE_AFFECTOR_TYPE getType() const 
	{ 
		return E_PARTICLE_AFFECTOR_TYPE.EPAT_ROTATE; 
	}
}