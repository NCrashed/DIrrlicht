// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IParticleSystemSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.IParticleEmitter;
import irrlicht.scene.IParticleAnimatedMeshSceneNodeEmitter;
import irrlicht.scene.IParticleBoxEmitter;
import irrlicht.scene.IParticleCylinderEmitter;
import irrlicht.scene.IParticleMeshEmitter;
import irrlicht.scene.IParticleRingEmitter;
import irrlicht.scene.IParticleSphereEmitter;
import irrlicht.scene.IParticleAffector;
import irrlicht.scene.IParticleAttractionAffector;
import irrlicht.scene.IParticleFadeOutAffector;
import irrlicht.scene.IParticleGravityAffector;
import irrlicht.scene.IParticleRotationAffector;
import irrlicht.scene.IMesh;
import irrlicht.scene.IAnimatedMeshSceneNode;
import irrlicht.video.SColor;
import irrlicht.core.dimension2d;
import irrlicht.core.vector3d;
import irrlicht.core.aabbox3d;
import std.container;

/// A particle system scene node for creating snow, fire, exlosions, smoke...
/**
* A scene node controlling a particle System. The behavior of the particles
* can be controlled by setting the right particle emitters and affectors.
* You can for example easily create a campfire by doing this:
* Examples:
* ------
* 	IParticleSystemSceneNode p = scenemgr.addParticleSystemSceneNode();
* 	p.setParticleSize(dimension2d!float(20.0f, 10.0f));
* 	IParticleEmitter em = p.createBoxEmitter(
* 		aabbox3d!float(-5,0,-5,5,1,5),
* 		vector3df(0.0f,0.03f,0.0f),
* 		40,80, SColor(0,255,255,255),SColor(0,255,255,255), 1100,2000);
* 	p.setEmitter(em);
* 	IParticleAffector paf = p.createFadeOutParticleAffector();
* 	p.addAffector(paf);
* ------
*/
abstract class IParticleSystemSceneNode : ISceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f, 1.0f, 1.0f))
	{
		super(parent, mgr, id, position, rotation, scale);
	}

	/// Sets the size of all particles.
	void setParticleSize(
		const dimension2d!float size = dimension2d!float(5.0f, 5.0f));

	/// Sets if the particles should be global.
	/**
	* If they are, the particles are affected by the movement of the
	* particle system scene node too, otherwise they completely ignore it.
	* Default is true. 
	*/
	void setParticlesAreGlobal(bool global=true);

	/// Remove all currently visible particles
	void clearParticles();

	/// Do manually update the particles.
 	/// This should only be called when you want to render the node outside the scenegraph,
 	/// as the node will care about this otherwise automatically.
	void doParticleSystem(uint time);

	/// Gets the particle emitter, which creates the particles.
	/**
	* Returns: The particle emitter. Can be 0 if none is set. 
	*/
	IParticleEmitter getEmitter();

	/// Sets the particle emitter, which creates the particles.
	/**
	* A particle emitter can be created using one of the createEmitter
	* methods. For example to create and use a simple PointEmitter, call
	* IParticleEmitter p = createPointEmitter(); setEmitter(p); p.drop();
	* Params:
	* 	emitter=  Sets the particle emitter. You can set this to 0 for
	* removing the current emitter and stopping the particle system emitting
	* new particles. 
	*/
	void setEmitter(IParticleEmitter emitter);

	/// Adds new particle effector to the particle system.
	/**
	* A particle affector modifies the particles. For example, the FadeOut
	* affector lets all particles fade out after some time. It is created and
	* used in this way:
	* Examples:
	* ------
	* IParticleAffector p = createFadeOutParticleAffector();
	* addAffector(p);
	* ------
	* Please note that an affector is not necessary for the particle system to
	* work.
	* Params:
	* 	affector=  New affector. 
	*/
	void addAffector(IParticleAffector affector);

	/// Get a list of all particle affectors.
	/**
	* Returns: The list of particle affectors attached to this node. 
	*/
	const DList!IParticleAffector getAffectors() const;

	/// Removes all particle affectors in the particle system.
	void removeAllAffectors();

	/// Creates a particle emitter for an animated mesh scene node
	/**
	* Params:
	* 	node=  Pointer to the animated mesh scene node to emit
	* particles from
	* 	useNormalDirection=  If true, the direction of each particle
	* created will be the normal of the vertex that it's emitting from. The
	* normal is divided by the normalDirectionModifier parameter, which
	* defaults to 100.0f.
	* 	direction=  Direction and speed of particle emission.
	* 	normalDirectionModifier=  If the emitter is using the normal
	* direction then the normal of the vertex that is being emitted from is
	* divided by this number.
	* 	mbNumber=  This allows you to specify a specific meshBuffer for
	* the IMesh* to emit particles from. The default value is -1, which
	* means a random meshBuffer picked from all of the meshes meshBuffers
	* will be selected to pick a random vertex from. If the value is 0 or
	* greater, it will only pick random vertices from the meshBuffer
	* specified by this value.
	* 	everyMeshVertex=  If true, the emitter will emit between min/max
	* particles every second, for every vertex in the mesh, if false, it will
	* emit between min/max particles from random vertices in the mesh.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleAnimatedMeshSceneNodeEmitter createAnimatedMeshSceneNodeEmitter(
		IAnimatedMeshSceneNode node, bool useNormalDirection = true,
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		float normalDirectionModifier = 100.0f, int mbNumber = -1,
		bool everyMeshVertex = false,
		uint minParticlesPerSecond = 5, uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin = 2000, uint lifeTimeMax = 4000,
		int maxAngleDegrees = 0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a box particle emitter.
	/**
	* Params:
	* 	box=  The box for the emitter.
	* 	direction=  Direction and speed of particle emission.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleBoxEmitter createBoxEmitter(
		const aabbox3df box = aabbox3df(-10,28,-10,10,30,10),
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		uint minParticlesPerSecond = 5,
		uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin=2000, uint lifeTimeMax=4000,
		int maxAngleDegrees=0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a particle emitter for emitting from a cylinder
	/**
	* Params:
	* 	center=  The center of the circle at the base of the cylinder
	* 	radius=  The thickness of the cylinder
	* 	normal=  Direction of the length of the cylinder
	* 	length=  The length of the the cylinder
	* 	outlineOnly=  Whether or not to put points inside the cylinder or
	* on the outline only
	* 	direction=  Direction and speed of particle emission.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleCylinderEmitter createCylinderEmitter()(
		auto ref const vector3df center, float radius,
		auto ref const vector3df normal, float length,
		bool outlineOnly = false,
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		uint minParticlesPerSecond = 5, uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin = 2000, uint lifeTimeMax = 4000,
		int maxAngleDegrees = 0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a mesh particle emitter.
	/**
	* Params:
	* 	mesh=  Pointer to mesh to emit particles from
	* 	useNormalDirection=  If true, the direction of each particle
	* created will be the normal of the vertex that it's emitting from. The
	* normal is divided by the normalDirectionModifier parameter, which
	* defaults to 100.0f.
	* 	direction=  Direction and speed of particle emission.
	* 	normalDirectionModifier=  If the emitter is using the normal
	* direction then the normal of the vertex that is being emitted from is
	* divided by this number.
	* 	mbNumber=  This allows you to specify a specific meshBuffer for
	* the IMesh* to emit particles from. The default value is -1, which
	* means a random meshBuffer picked from all of the meshes meshBuffers
	* will be selected to pick a random vertex from. If the value is 0 or
	* greater, it will only pick random vertices from the meshBuffer
	* specified by this value.
	* 	everyMeshVertex=  If true, the emitter will emit between min/max
	* particles every second, for every vertex in the mesh, if false, it will
	* emit between min/max particles from random vertices in the mesh.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleMeshEmitter createMeshEmitter(
		IMesh mesh, bool useNormalDirection = true,
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		float normalDirectionModifier = 100.0f, int mbNumber = -1,
		bool everyMeshVertex = false,
		uint minParticlesPerSecond = 5, uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin = 2000, uint lifeTimeMax = 4000,
		int maxAngleDegrees = 0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a point particle emitter.
	/**
	* Params:
	* 	direction=  Direction and speed of particle emission.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticlePointEmitter createPointEmitter(
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		uint minParticlesPerSecond = 5,
		uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin=2000, uint lifeTimeMax=4000,
		int maxAngleDegrees=0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a ring particle emitter.
	/**
	* Params:
	* 	center=  Center of ring
	* 	radius=  Distance of points from center, points will be rotated
	* around the Y axis at a random 360 degrees and will then be shifted by
	* the provided ringThickness values in each axis.
	* 	ringThickness=  : thickness of the ring or how wide the ring is
	* 	direction=  Direction and speed of particle emission.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleRingEmitter createRingEmitter()(
		auto ref const vector3df center, float radius, float ringThickness,
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		uint minParticlesPerSecond = 5,
		uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin=2000, uint lifeTimeMax=4000,
		int maxAngleDegrees=0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a sphere particle emitter.
	/**
	* Params:
	* 	center=  Center of sphere
	* 	radius=  Radius of sphere
	* 	direction=  Direction and speed of particle emission.
	* 	minParticlesPerSecond=  Minimal amount of particles emitted per
	* second.
	* 	maxParticlesPerSecond=  Maximal amount of particles emitted per
	* second.
	* 	minStartColor=  Minimal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	maxStartColor=  Maximal initial start color of a particle. The
	* real color of every particle is calculated as random interpolation
	* between minStartColor and maxStartColor.
	* 	lifeTimeMin=  Minimal lifetime of a particle, in milliseconds.
	* 	lifeTimeMax=  Maximal lifetime of a particle, in milliseconds.
	* 	maxAngleDegrees=  Maximal angle in degrees, the emitting
	* direction of the particle will differ from the original direction.
	* 	minStartSize=  Minimal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* 	maxStartSize=  Maximal initial start size of a particle. The
	* real size of every particle is calculated as random interpolation
	* between minStartSize and maxStartSize.
	* Returns: Pointer to the created particle emitter. To set this emitter
	* as new emitter of this particle system, just call setEmitter(). 
	*/
	IParticleSphereEmitter createSphereEmitter()(
		auto ref const vector3df center, float radius,
		const vector3df direction = vector3df(0.0f,0.03f,0.0f),
		uint minParticlesPerSecond = 5,
		uint maxParticlesPerSecond = 10,
		const SColor minStartColor = SColor(255,0,0,0),
		const SColor maxStartColor = SColor(255,255,255,255),
		uint lifeTimeMin=2000, uint lifeTimeMax=4000,
		int maxAngleDegrees=0,
		const dimension2df minStartSize = dimension2df(5.0f,5.0f),
		const dimension2df maxStartSize = dimension2df(5.0f,5.0f) );

	/// Creates a point attraction affector.
	/**
	* This affector modifies the positions of the particles and attracts
	* them to a specified point at a specified speed per second.
	* Params:
	* 	point=  Point to attract particles to.
	* 	speed=  Speed in units per second, to attract to the specified
	* point.
	* 	attract=  Whether the particles attract or detract from this
	* point.
	* 	affectX=  Whether or not this will affect the X position of the
	* particle.
	* 	affectY=  Whether or not this will affect the Y position of the
	* particle.
	* 	affectZ=  Whether or not this will affect the Z position of the
	* particle.
	* Returns: Pointer to the created particle affector. To add this affector
	* as new affector of this particle system, just call addAffector(). 
	*/
	IParticleAttractionAffector createAttractionAffector()(
		auto ref const vector3df point, float speed = 1.0f, bool attract = true,
		bool affectX = true, bool affectY = true, bool affectZ = true);

	/// Creates a scale particle affector.
	/**
	* This affector scales the particle to the a multiple of its size defined
	* by the scaleTo variable.
	* Params:
	* 	scaleTo=  multiple of the size which the particle will be scaled to until deletion
	* Returns: Pointer to the created particle affector.
	* To add this affector as new affector of this particle system,
	* just call addAffector(). 
	*/
	IParticleAffector createScaleParticleAffector()(auto ref const dimension2df scaleTo);

	/// Creates a fade out particle affector.
	/**
	* This affector modifies the color of every particle and and reaches
	* the final color when the particle dies. This affector looks really
	* good, if the EMT_TRANSPARENT_ADD_COLOR material is used and the
	* targetColor is SColor(0,0,0,0): Particles are fading out into
	* void with this setting.
	* Params:
	* 	targetColor=  Color whereto the color of the particle is changed.
	* 	timeNeededToFadeOut=  How much time in milli seconds should the
	* affector need to change the color to the targetColor.
	* Returns: Pointer to the created particle affector. To add this affector
	* as new affector of this particle system, just call addAffector(). 
	*/
	IParticleFadeOutAffector createFadeOutParticleAffector()(
		auto ref const SColor targetColor,
		uint timeNeededToFadeOut = 1000);

	/// Creates a gravity affector.
	/**
	* This affector modifies the direction of the particle. It assumes
	* that the particle is fired out of the emitter with huge force, but is
	* loosing this after some time and is catched by the gravity then. This
	* affector is ideal for creating things like fountains.
	* Params:
	* 	gravity=  Direction and force of gravity.
	* 	timeForceLost=  Time in milli seconds when the force of the
	* emitter is totally lost and the particle does not move any more. This
	* is the time where gravity fully affects the particle.
	* Returns: Pointer to the created particle affector. To add this affector
	* as new affector of this particle system, just call addAffector().
	*/
	IParticleGravityAffector createGravityAffector()(
		auto ref const vector3df gravity,
		uint timeForceLost = 1000);

	/// Creates a rotation affector.
	/**
	* This affector modifies the positions of the particles and attracts
	* them to a specified point at a specified speed per second.
	* Params:
	* 	speed=  Rotation in degrees per second
	* 	pivotPoint=  Point to rotate the particles around
	* Returns: Pointer to the created particle affector. To add this affector
	* as new affector of this particle system, just call addAffector(). 
	*/
	IParticleRotationAffector createRotationAffector()(
		auto ref const vector3df speed,
		auto ref const vector3df pivotPoint);
}