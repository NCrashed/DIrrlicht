// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISkinnedMesh;

import irrlicht.scene.IBoneSceneNode;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.SSkinMeshBuffer;
import irrlicht.core.vector3d;
import irrlicht.core.matrix4;
import irrlicht.core.quaternion;

enum E_INTERPOLATION_MODE
{
	// constant does use the current key-values without interpolation
	EIM_CONSTANT = 0,

	// linear interpolation
	EIM_LINEAR,

	/// count of all available interpolation modes
	EIM_COUNT
}


/// Interface for using some special functions of Skinned meshes
interface ISkinnedMesh : IAnimatedMesh
{
	/// Gets joint count.
	/**
	* Returns: Amount of joints in the skeletal animated mesh. 
	*/
	size_t getJointCount() const;

	/// Gets the name of a joint.
	/**
	* Params:
	* 	number=  Zero based index of joint. The last joint
	* has the number getJointCount()-1;
	* Returns: Name of joint and null if an error happened. 
	*/
	string getJointName(size_t number) const;

	/// Gets a joint number from its name
	/**
	* Params:
	* 	name=  Name of the joint.
	* Returns: Number of the joint or -1 if not found. 
	*/
	ptrdiff_t getJointNumber(string name) const;

	/// Use animation from another mesh
	/**
	* The animation is linked (not copied) based on joint names
	* so make sure they are unique.
	* Returns: True if all joints in this mesh were
	* matched up (empty names will not be matched, and it's case
	* sensitive). Unmatched joints will not be animated. 
	*/
	bool useAnimationFrom(const ISkinnedMesh mesh);

	/// Update Normals when Animating
	/**
	* Params:
	* 	on=  If false don't animate, which is faster.
	* Else update normals, which allows for proper lighting of
	* animated meshes. 
	*/
	void updateNormalsWhenAnimating(bool on);

	/// Sets Interpolation Mode
	void setInterpolationMode(E_INTERPOLATION_MODE mode);

	/// Animates this mesh's joints based on frame input
	void animateMesh(float frame, float blend);

	/// Preforms a software skin on this mesh based of joint positions
	void skinMesh();

	/// converts the vertex type of all meshbuffers to tangents.
	/**
	* E.g. used for bump mapping. 
	*/
	void convertMeshToTangents();

	/// Allows to enable hardware skinning.
	/* This feature is not implementated in Irrlicht yet */
	bool setHardwareSkinning(bool on);

	/// A vertex weight
	struct SWeight
	{
		/// Index of the mesh buffer
		ushort buffer_id; //I doubt 32bits is needed

		/// Index of the vertex
		size_t vertex_id; //Store global ID here

		/// Weight Strength/Percentage (0-1)
		float strength;

		
		/// Internal members used by CSkinnedMesh
		package
		{
			bool *Moved;
			vector3df StaticPos;
			vector3df StaticNormal;
		}
	}


	/// Animation keyframe which describes a new position
	struct SPositionKey
	{
		float frame;
		vector3df position;
	}

	/// Animation keyframe which describes a new scale
	struct SScaleKey
	{
		float frame;
		vector3df scale;
	}

	/// Animation keyframe which describes a new rotation
	struct SRotationKey
	{
		float frame;
		quaternion rotation;
	}

	/// Joints
	class SJoint
	{
		this()
		{
			UseAnimationFrom = null;
			GlobalSkinningSpace = false;
			positionHint = -1;
			scaleHint = -1;
			rotationHint = -1;
		}

		/// The name of this joint
		string Name;

		/// Local matrix of this joint
		matrix4 LocalMatrix;

		/// List of child joints
		SJoint[] Children = [];

		/// List of attached meshes
		uint[] AttachedMeshes = [];

		/// Animation keys causing translation change
		SPositionKey[] PositionKeys = [];

		/// Animation keys causing scale change
		SScaleKey[] ScaleKeys = [];

		/// Animation keys causing rotation change
		SRotationKey[] RotationKeys = [];

		/// Skin weights
		SWeight[] Weights = [];

		/// Unnecessary for loaders, will be overwritten on finalize
		matrix4 GlobalMatrix;
		matrix4 GlobalAnimatedMatrix;
		matrix4 LocalAnimatedMatrix;
		vector3df Animatedposition;
		vector3df Animatedscale;
		quaternion Animatedrotation;

		matrix4 GlobalInversedMatrix; //the x format pre-calculates this

		/// Internal members used by CSkinnedMesh
		package
		{
			SJoint UseAnimationFrom;
			bool GlobalSkinningSpace;

			int positionHint;
			int scaleHint;
			int rotationHint;
		}
	}


	//Interface for the mesh loaders (finalize should lock these functions, and they should have some prefix like loader_

	//these functions will use the needed arrays, set values, etc to help the loaders

	/// exposed for loaders: to add mesh buffers
	ref SSkinMeshBuffer[] getMeshBuffers();

	/// exposed for loaders: joints list
	ref SJoint[] getAllJoints();

	/// exposed for loaders: joints list
	const SJoint[] getAllJoints() const;

	/// loaders should call this after populating the mesh
	void finalize();

	/// Adds a new meshbuffer to the mesh, access it as last one
	SSkinMeshBuffer addMeshBuffer();

	/// Adds a new joint to the mesh, access it as last one
	SJoint addJoint(SJoint parent = null);

	/// Adds a new weight to the mesh, access it as last one
	ref SWeight addWeight(SJoint joint);

	/// Adds a new position key to the mesh, access it as last one
	ref SPositionKey addPositionKey(SJoint joint);
	/// Adds a new scale key to the mesh, access it as last one
	ref SScaleKey addScaleKey(SJoint joint);
	/// Adds a new rotation key to the mesh, access it as last one
	ref SRotationKey addRotationKey(SJoint joint);

	/// Check if the mesh is non-animated
	bool isStatic();
}
