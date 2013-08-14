// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IAnimatedMeshSceneNode;

import irrlicht.scene.IMesh;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.IBoneSceneNode;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.IAnimatedMeshMD2;
import irrlicht.scene.IAnimatedMeshMD3;
import irrlicht.scene.IShadowVolumeSceneNode;
import irrlicht.core.vector3d;

enum E_JOINT_UPDATE_ON_RENDER
{
	/// do nothing
	EJUOR_NONE = 0,

	/// get joints positions from the mesh (for attached nodes, etc)
	EJUOR_READ,

	/// control joint positions in the mesh (eg. ragdolls, or set the animation from animateJoints() )
	EJUOR_CONTROL
}

/// Callback interface for catching events of ended animations.
/**
* Implement this interface and use
* IAnimatedMeshSceneNode.setAnimationEndCallback to be able to
* be notified if an animation playback has ended.
**/
interface IAnimationEndCallBack
{
	/// Will be called when the animation playback has ended.
	/**
	* See_Also:
	* 	IAnimatedMeshSceneNode.setAnimationEndCallback for
	* more informations.
	* Params:
	* 	node=  Node of which the animation has ended. 
	*/
	void OnAnimationEnd(IAnimatedMeshSceneNode node);
}

/// Scene node capable of displaying an animated mesh and its shadow.
/**
* The shadow is optional: If a shadow should be displayed too, just
* invoke the IAnimatedMeshSceneNode.createShadowVolumeSceneNode().
*/
abstract class IAnimatedMeshSceneNode : ISceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		vector3df position = vector3df(0,0,0),
		vector3df rotation = vector3df(0,0,0),
		vector3df scale = vector3df(1.0f, 1.0f, 1.0f))
	{
		super(parent, mgr, id, position, rotation, scale);
	}

	/// Sets the current frame number.
	/**
	* From now on the animation is played from this frame.
	* Params:
	* 	frame=  Number of the frame to let the animation be started from.
	* The frame number must be a valid frame number of the IMesh used by this
	* scene node. Set IAnimatedMesh.getMesh() for details. 
	*/
	void setCurrentFrame(float frame);

	/// Sets the frame numbers between the animation is looped.
	/**
	* The default is 0 - MaximalFrameCount of the mesh.
	* Params:
	* 	begin=  Start frame number of the loop.
	* 	end=  End frame number of the loop.
	* Returns: True if successful, false if not. 
	*/
	bool setFrameLoop(int begin, int end);

	/// Sets the speed with which the animation is played.
	/**
	* Params:
	* 	framesPerSecond=  Frames per second played. 
	*/
	void setAnimationSpeed(float framesPerSecond);

	/// Gets the speed with which the animation is played.
	/**
	* Returns: Frames per second played. 
	*/
	float getAnimationSpeed() const;

	/// Creates shadow volume scene node as child of this node.
	/**
	* The shadow can be rendered using the ZPass or the zfail
	* method. ZPass is a little bit faster because the shadow volume
	* creation is easier, but with this method there occur ugly
	* looking artifacs when the camera is inside the shadow volume.
	* These error do not occur with the ZFail method.
	* Params:
	* 	shadowMesh=  Optional custom mesh for shadow volume.
	* 	id=  Id of the shadow scene node. This id can be used to
	* identify the node later.
	* 	zfailmethod=  If set to true, the shadow will use the
	* zfail method, if not, zpass is used.
	* 	infinity=  Value used by the shadow volume algorithm to
	* scale the shadow volume (for zfail shadow volume we support only
	* finite shadows, so camera zfar must be larger than shadow back cap,
	* which is depend on infinity parameter).
	* Returns: Pointer to the created shadow scene node. This pointer
	* should not be dropped. See IReferenceCounted.drop() for more
	* information. 
	*/
	IShadowVolumeSceneNode addShadowVolumeSceneNode(const IMesh shadowMesh = null,
		int id=-1, bool zfailmethod=true, float infinity=1000.0f);


	/// Get a pointer to a joint in the mesh (if the mesh is a bone based mesh).
	/**
	* With this method it is possible to attach scene nodes to
	* joints for example possible to attach a weapon to the left hand
	* of an animated model. This example shows how:
	* Examples:
	* ------
	* ISceneNode* hand =
		* yourAnimatedMeshSceneNode.getJointNode("LeftHand");
	* hand.addChild(weaponSceneNode);
	* ------
	* Please note that the joint returned by this method may not exist
	* before this call and the joints in the node were created by it.
	* Params:
	* 	jointName=  Name of the joint.
	* Returns: Pointer to the scene node which represents the joint
	* with the specified name. Returns 0 if the contained mesh is not
	* an skinned mesh or the name of the joint could not be found. 
	*/
	IBoneSceneNode getJointNode(string jointName);

	/// same as getJointNode(string jointName), but based on id
	IBoneSceneNode getJointNode(size_t jointID);

	/// Gets joint count.
	/**
	* Returns: Amount of joints in the mesh. 
	*/
	size_t getJointCount() const;

	/// Starts a default MD2 animation.
	/**
	* With this method it is easily possible to start a Run,
	* Attack, Die or whatever animation, if the mesh contained in
	* this scene node is an md2 mesh. Otherwise, nothing happens.
	* Params:
	* 	anim=  An MD2 animation type, which should be played, for
	* example EMAT_STAND for the standing animation.
	* Returns: True if successful, and false if not, for example if
	* the mesh in the scene node is not a md2 mesh. 
	*/
	bool setMD2Animation(EMD2_ANIMATION_TYPE anim);

	/// Starts a special MD2 animation.
	/**
	* With this method it is easily possible to start a Run,
	* Attack, Die or whatever animation, if the mesh contained in
	* this scene node is an md2 mesh. Otherwise, nothing happens.
	* This method uses a character string to identify the animation.
	* If the animation is a standard md2 animation, you might want to
	* start this animation with the EMD2_ANIMATION_TYPE enumeration
	* instead.
	* Params:
	* 	animationName=  Name of the animation which should be
	* played.
	* Returns: Returns true if successful, and false if not, for
	* example if the mesh in the scene node is not an md2 mesh, or no
	* animation with this name could be found. 
	*/
	bool setMD2Animation(string animationName);

	/// Returns the currently displayed frame number.
	float getFrameNr() const;
	/// Returns the current start frame number.
	int getStartFrame() const;
	/// Returns the current end frame number.
	int getEndFrame() const;

	/// Sets looping mode which is on by default.
	/**
	* If set to false, animations will not be played looped. 
	*/
	void setLoopMode(bool playAnimationLooped);

	/// returns the current loop mode
	/**
	* When true the animations are played looped 
	*/
	bool getLoopMode() const;

	/// Sets a callback interface which will be called if an animation playback has ended.
	/**
	* Set this to 0 to disable the callback again.
	* Please note that this will only be called when in non looped
	* mode, see IAnimatedMeshSceneNode.setLoopMode(). 
	*/
	void setAnimationEndCallback(IAnimationEndCallBack callback = null);

	/// Sets if the scene node should not copy the materials of the mesh but use them in a read only style.
	/**
	* In this way it is possible to change the materials a mesh
	* causing all mesh scene nodes referencing this mesh to change
	* too. 
	*/
	void setReadOnlyMaterials(bool readonly);

	/// Returns if the scene node should not copy the materials of the mesh but use them in a read only style
	bool isReadOnlyMaterials() const;

	/// Sets a new mesh
	void setMesh(IAnimatedMesh mesh);

	/// Returns the current mesh
	IAnimatedMesh getMesh();

	/// Get the absolute transformation for a special MD3 Tag if the mesh is a md3 mesh, or the absolutetransformation if it's a normal scenenode
	SMD3QuaternionTag getMD3TagTransformation(string tagname);

	/// Set how the joints should be updated on render
	void setJointMode(E_JOINT_UPDATE_ON_RENDER mode);

	/// Sets the transition time in seconds
	/**
	* Note: This needs to enable joints, and setJointmode set to
	* EJUOR_CONTROL. You must call animateJoints(), or the mesh will
	* not animate. 
	*/
	void setTransitionTime(float time);

	/// animates the joints in the mesh based on the current frame.
	/**
	* Also takes in to account transitions. 
	*/
	void animateJoints(bool calculateAbsolutePositions = true);

	/// render mesh ignoring its transformation.
	/**
	* Culling is unaffected. 
	*/
	void setRenderFromIdentity( bool On );

	/// Creates a clone of this scene node and its children.
	/**
	* Params:
	* 	newParent=  An optional new parent.
	* 	newManager=  An optional new scene manager.
	* Returns: The newly created clone of this node. 
	*/
	override ISceneNode clone(ISceneNode newParent = null, ISceneManager newManager = null);
}
