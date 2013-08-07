// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleFadeOutAffector;

import irrlicht.scene.IParticleAffector;
import irrlicht.video.SColor;

/// A particle affector which fades out the particles.
abstract class IParticleFadeOutAffector : IParticleAffector
{
	/// Sets the targetColor, i.e. the color the particles will interpolate to over time.
	void setTargetColor()(auto ref const SColor targetColor );

	/// Sets the time in milliseconds it takes for each particle to fade out (minimal 1 ms)
	void setFadeOutTime( uint fadeOutTime );

	/// Gets the targetColor, i.e. the color the particles will interpolate to over time.
	auto ref const SColor getTargetColor()() const;

	/// Gets the time in milliseconds it takes for each particle to fade out.
	uint getFadeOutTime() const;

	/// Get emitter type
	override E_PARTICLE_AFFECTOR_TYPE getType() const 
	{ 
		return E_PARTICLE_AFFECTOR_TYPE.EPAT_FADE_OUT; 
	}
}