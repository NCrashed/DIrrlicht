// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleAnimatedMeshSceneNodeEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.scene.IAnimatedMeshSceneNode;

/// A particle emitter which emits particles from mesh vertices.
interface IParticleAnimatedMeshSceneNodeEmitter : IParticleEmitter
{
	/// Set Mesh to emit particles from
	void setAnimatedMeshSceneNode( IAnimatedMeshSceneNode node );

	/// Set whether to use vertex normal for direction, or direction specified
	void setUseNormalDirection( bool useNormalDirection = true );

	/// Set the amount that the normal is divided by for getting a particles direction
	void setNormalDirectionModifier( float normalDirectionModifier );

	/// Sets whether to emit min<->max particles for every vertex or to pick min<->max vertices
	void setEveryMeshVertex( bool everyMeshVertex = true );

	/// Get mesh we're emitting particles from
	const IAnimatedMeshSceneNode getAnimatedMeshSceneNode() const;

	/// Get whether to use vertex normal for direction, or direction specified
	bool isUsingNormalDirection() const;

	/// Get the amount that the normal is divided by for getting a particles direction
	float getNormalDirectionModifier() const;

	/// Gets whether to emit min<->max particles for every vertex or to pick min<->max vertices
	bool getEveryMeshVertex() const;

	/// Get emitter type
	E_PARTICLE_EMITTER_TYPE getType();
}
