// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleAttractionAffector;

import irrlicht.scene.IParticleAffector;
import irrlicht.core.vector3d;

/// A particle affector which attracts or detracts particles.
abstract class IParticleAttractionAffector : IParticleAffector
{
	/// Set the point that particles will attract to
	void setPoint()(auto ref const vector3df point );

	/// Set whether or not the particles are attracting or detracting
	void setAttract( bool attract );

	/// Set whether or not this will affect particles in the X direction
	void setAffectX( bool affect );

	/// Set whether or not this will affect particles in the Y direction
	void setAffectY( bool affect );

	/// Set whether or not this will affect particles in the Z direction
	void setAffectZ( bool affect );

	/// Get the point that particles are attracted to
	auto ref const vector3df getPoint()() const;

	/// Get whether or not the particles are attracting or detracting
	bool getAttract() const;

	/// Get whether or not the particles X position are affected
	bool getAffectX() const;

	/// Get whether or not the particles Y position are affected
	bool getAffectY() const;

	/// Get whether or not the particles Z position are affected
	bool getAffectZ() const;

	/// Get emitter type
	override E_PARTICLE_AFFECTOR_TYPE getType() const 
	{ 
		return E_PARTICLE_AFFECTOR_TYPE.EPAT_ATTRACT; 
	}
}