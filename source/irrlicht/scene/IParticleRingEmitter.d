// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleRingEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.core.vector3d;

/// A particle emitter which emits particles along a ring shaped area.
interface IParticleRingEmitter : IParticleEmitter
{
	/// Set the center of the ring
	void setCenter()(auto ref const vector3df center );

	/// Set the radius of the ring
	void setRadius( float radius );

	/// Set the thickness of the ring
	void setRingThickness( float ringThickness );

	/// Get the center of the ring
	auto ref const vector3df getCenter() const;

	/// Get the radius of the ring
	float getRadius() const;

	/// Get the thickness of the ring
	float getRingThickness() const;
}