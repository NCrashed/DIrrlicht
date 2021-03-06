// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleBoxEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.core.aabbox3d;

/// A particle emitter which emits particles from a box shaped space
interface IParticleBoxEmitter : IParticleEmitter
{
	/// Set the box shape
	void setBox()(auto ref const aabbox3df box );

	/// Get the box shape set
	auto ref const aabbox3df getBox() const;
}