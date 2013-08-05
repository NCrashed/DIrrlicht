// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IParticleMeshEmitter;

import irrlicht.scene.IParticleEmitter;
import irrlicht.scene.IMesh;

/// A particle emitter which emits from vertices of a mesh
interface IParticleMeshEmitter : IParticleEmitter
{
	/// Set Mesh to emit particles from
	void setMesh( IMesh mesh );

	/// Set whether to use vertex normal for direction, or direction specified
	void setUseNormalDirection( bool useNormalDirection = true );

	/// Set the amount that the normal is divided by for getting a particles direction
	void setNormalDirectionModifier( float normalDirectionModifier );

	/// Sets whether to emit min<->max particles for every vertex or to pick min<->max vertices
	void setEveryMeshVertex( bool everyMeshVertex = true );

	/// Get Mesh we're emitting particles from
	const IMesh getMesh() const;

	/// Get whether to use vertex normal for direction, or direction specified
	bool isUsingNormalDirection() const;

	/// Get the amount that the normal is divided by for getting a particles direction
	float getNormalDirectionModifier() const;

	/// Gets whether to emit min<->max particles for every vertex or to pick min<->max vertices
	bool getEveryMeshVertex() const;
}