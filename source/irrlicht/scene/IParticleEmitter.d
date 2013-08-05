// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleEmitter;

import irrlicht.io.IAttributeExchangingObject;
import irrlicht.scene.SParticle;
import irrlicht.video.SColor;
import irrlicht.core.dimension2d;
import irrlicht.core.vector3d;

/// Types of built in particle emitters
enum E_PARTICLE_EMITTER_TYPE
{
	EPET_POINT = 0,
	EPET_ANIMATED_MESH,
	EPET_BOX,
	EPET_CYLINDER,
	EPET_MESH,
	EPET_RING,
	EPET_SPHERE,
	EPET_COUNT
}

/// Names for built in particle emitters
immutable(string[]) ParticleEmitterTypeNames =
[
	"Point",
	"AnimatedMesh",
	"Box",
	"Cylinder",
	"Mesh",
	"Ring",
	"Sphere",
];

/// A particle emitter for using with particle systems.
/**
* A Particle emitter emitts new particles into a particle system.
*/
interface IParticleEmitter : IAttributeExchangingObject
{
	/// Prepares an array with new particles to emitt into the system
	/**
	* Params:
	* 	now =  Current time.
	* 	timeSinceLastCall =  Time elapsed since last call, in milliseconds.
	* 	outArray =  Pointer which will point to the array with the new
	* particles to add into the system.
	* Returns: Amount of new particles in the array. Can be 0. 
	*/
	int emitt(uint now, uint timeSinceLastCall, out SParticle[] outArray);

	/// Set direction the emitter emits particles
	void setDirection()(auto ref const vector3df newDirection);

	/// Set minimum number of particles the emitter emits per second
	void setMinParticlesPerSecond( uint minPPS );

	/// Set maximum number of particles the emitter emits per second
	void setMaxParticlesPerSecond( uint maxPPS );

	/// Set minimum starting color for particles
	void setMinStartColor()(auto ref const SColor color );

	/// Set maximum starting color for particles
	void setMaxStartColor()(auto ref const SColor color );

	/// Set the maximum starting size for particles
	void setMaxStartSize()(auto ref const dimension2df size );

	/// Set the minimum starting size for particles
	void setMinStartSize()(auto ref const dimension2df size );

	/// Set the minimum particle life-time in milliseconds
	void setMinLifeTime( uint lifeTimeMin );

	/// Set the maximum particle life-time in milliseconds
	void setMaxLifeTime( uint lifeTimeMax );

	///	Set maximal random derivation from the direction
	void setMaxAngleDegrees( int maxAngleDegrees );

	/// Get direction the emitter emits particles
	auto ref const vector3df getDirection() const;

	/// Get the minimum number of particles the emitter emits per second
	uint getMinParticlesPerSecond() const;

	/// Get the maximum number of particles the emitter emits per second
	uint getMaxParticlesPerSecond() const;

	/// Get the minimum starting color for particles
	auto ref const SColor getMinStartColor() const;

	/// Get the maximum starting color for particles
	auto ref const SColor getMaxStartColor() const;

	/// Get the maximum starting size for particles
	auto ref const dimension2df getMaxStartSize() const;

	/// Get the minimum starting size for particles
	auto ref const dimension2df getMinStartSize() const;

	/// Get the minimum particle life-time in milliseconds
	uint getMinLifeTime() const;

	/// Get the maximum particle life-time in milliseconds
	uint getMaxLifeTime() const;

	///	Get maximal random derivation from the direction
	int getMaxAngleDegrees() const;

	/// Get emitter type
	E_PARTICLE_EMITTER_TYPE getType() const;
}

alias IParticleEmitter IParticlePointEmitter;
