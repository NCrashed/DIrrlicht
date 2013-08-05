// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleSphereEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.core.vector3d;

/// A particle emitter which emits from a spherical space.
abstract class IParticleSphereEmitter : IParticleEmitter
{
	/// Set the center of the sphere for particle emissions
	void setCenter()(auto ref const vector3df center );

	/// Set the radius of the sphere for particle emissions
	void setRadius( float radius );

	/// Get the center of the sphere for particle emissions
	auto ref const vector3df getCenter() const;

	/// Get the radius of the sphere for particle emissions
	float getRadius() const;
}