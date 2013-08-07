// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.SParticle;

import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;
import irrlicht.video.SColor;

/// Struct for holding particle data
struct SParticle
{
	/// Position of the particle
	vector3df pos;

	/// Direction and speed of the particle
	vector3df vector;

	/// Start life time of the particle
	uint startTime;

	/// End life time of the particle
	uint endTime;

	/// Current color of the particle
	SColor color;

	/// Original color of the particle.
	/** That's the color of the particle it had when it was emitted. */
	SColor startColor;

	/// Original direction and speed of the particle.
	/** The direction and speed the particle had when it was emitted. */
	vector3df startVector;

	/// Scale of the particle.
	/** The current scale of the particle. */
	dimension2df size;

	/// Original scale of the particle.
	/** The scale of the particle when it was emitted. */
	dimension2df startSize;
}