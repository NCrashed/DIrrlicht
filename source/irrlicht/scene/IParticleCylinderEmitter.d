// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleCylinderEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.core.vector3d;

/// A particle emitter which emits from a cylindrically shaped space.
interface IParticleCylinderEmitter : IParticleEmitter
{
	/// Set the center of the radius for the cylinder, at one end of the cylinder
	void setCenter()(auto ref const vector3df center );

	/// Set the normal of the cylinder
	void setNormal()(auto ref const vector3df normal );

	/// Set the radius of the cylinder
	void setRadius( float radius );

	/// Set the length of the cylinder
	void setLength( float length );

	/// Set whether or not to draw points inside the cylinder
	void setOutlineOnly( bool outlineOnly = true );

	/// Get the center of the cylinder
	auto ref const vector3df getCenter() const;

	/// Get the normal of the cylinder
	auto ref const vector3df getNormal() const;

	/// Get the radius of the cylinder
	float getRadius() const;

	/// Get the center of the cylinder
	float getLength() const;

	/// Get whether or not to draw points inside the cylinder
	bool getOutlineOnly() const;
}