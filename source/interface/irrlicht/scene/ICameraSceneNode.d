// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ICameraSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.SViewFrustum;
import irrlicht.io.IAttributes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.IEventReceiver;
import irrlicht.core.vector3d;
import irrlicht.core.matrix4;

/// Scene Node which is a (controlable) camera.
/**
* The whole scene will be rendered from the cameras point of view.
* Because the ICameraScenNode is a SceneNode, it can be attached to any
* other scene node, and will follow its parents movement, rotation and so
* on.
*/
abstract class ICameraSceneNode : ISceneNode, IEventReceiver
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0),
		const vector3df rotation = vector3df(0,0,0),
		const vector3df scale = vector3df(1.0f,1.0f,1.0f))
	{
		super(parent, mgr, id, position, rotation, scale);
		IsOrthogonal = false;
	}

	/// Sets the projection matrix of the camera.
	/**
	* The matrix4 class has some methods to build a
	* projection matrix. e.g:
	* matrix4.buildProjectionMatrixPerspectiveFovLH.
	* Note that the matrix will only stay as set by this method until
	* one of the following Methods are called: setNearValue,
	* setFarValue, setAspectRatio, setFOV.
	* Params:
	* 	projection=  The new projection matrix of the camera.
	* 	isOrthogonal=  Set this to true if the matrix is an
	* orthogonal one (e.g. from matrix4.buildProjectionMatrixOrtho).
	*/
	void setProjectionMatrix(ref const matrix4 projection, bool isOrthogonal = false);

	final void setProjectionMatrix(matrix4 projection, bool isOrthogonal = false)
	{
		setProjectionMatrix(projection, isOrthogonal);
	}

	/// Gets the current projection matrix of the camera.
	/**
	* Returns: The current projection matrix of the camera. 
	*/
	ref const matrix4 getProjectionMatrix() const;

	/// Gets the current view matrix of the camera.
	/**
	* Returns: The current view matrix of the camera. 
	*/
	ref const matrix4 getViewMatrix() const;

	/// Sets a custom view matrix affector.
	/**
	* The matrix passed here, will be multiplied with the view
	* matrix when it gets updated. This allows for custom camera
	* setups like, for example, a reflection camera.
	* Params:
	* 	affector=  The affector matrix. 
	*/
	void setViewMatrixAffector(ref const matrix4 affector);

	final void setViewMatrixAffector(matrix4 affector)
	{
		setViewMatrixAffector(affector);
	}

	/// Get the custom view matrix affector.
	/**
	* Returns: The affector matrix. 
	*/
	ref const matrix4 getViewMatrixAffector() const;

	/// It is possible to send mouse and key events to the camera.
	/**
	* Most cameras may ignore this input, but camera scene nodes
	* which are created for example with
	* ISceneManager.addCameraSceneNodeMaya or
	* ISceneManager.addCameraSceneNodeFPS, may want to get
	* this input for changing their position, look at target or
	* whatever. 
	*/
//	bool OnEvent(ref const SEvent event);

	/// Sets the look at target of the camera
	/**
	* If the camera's target and rotation are bound ( @see
	* bindTargetAndRotation() ) then calling this will also change
	* the camera's scene node rotation to match the target.
	* Note that setTarget uses the current absolute position 
	* internally, so if you changed setPosition since last rendering you must
	* call updateAbsolutePosition before using this function.
	* Params:
	* 	pos=  Look at target of the camera, in world co-ordinates. 
	*/
	void setTarget(ref const vector3df pos);

	final void setTarget(vector3df pos)
	{
		setTarget(pos);
	}

	/// Sets the rotation of the node.
	/**
	* This only modifies the relative rotation of the node.
	* If the camera's target and rotation are bound ( @see
	* bindTargetAndRotation() ) then calling this will also change
	* the camera's target to match the rotation.
	* Params:
	* 	rotation=  New rotation of the node in degrees. 
	*/
	void setRotation(ref const vector3df rotation);

	final void setRotation(vector3df rotation)
	{
		setRotation(rotation);
	}

	/// Gets the current look at target of the camera
	/**
	* Returns: The current look at target of the camera, in world co-ordinates 
	*/
	ref const vector3df getTarget() const;

	/// Sets the up vector of the camera.
	/**
	* Params:
	* 	pos=  New upvector of the camera. 
	*/
	void setUpVector(ref const vector3df pos);

	final void setUpVector(vector3df pos)
	{
		setUpVector(pos);
	}

	/// Gets the up vector of the camera.
	/**
	* Returns: The up vector of the camera, in world space. 
	*/
	ref const vector3df getUpVector() const;


	/// Gets the value of the near plane of the camera.
	/**
	* Returns: The value of the near plane of the camera. 
	*/
	float getNearValue() const;

	/// Gets the value of the far plane of the camera.
	/**
	* Returns: The value of the far plane of the camera. 
	*/
	float getFarValue() const;

	/// Gets the aspect ratio of the camera.
	/**
	* Returns: The aspect ratio of the camera. 
	*/
	float getAspectRatio() const;

	/// Gets the field of view of the camera.
	/**
	* Returns: The field of view of the camera in radians. 
	*/
	float getFOV() const;

	/// Sets the value of the near clipping plane. (default: 1.0f)
	/**
	* Params:
	* 	zn=  New z near value. 
	*/
	void setNearValue(float zn);

	/// Sets the value of the far clipping plane (default: 2000.0f)
	/**
	* Params:
	* 	zf=  New z far value. 
	*/
	void setFarValue(float zf);

	/// Sets the aspect ratio (default: 4.0f / 3.0f)
	/**
	* Params:
	* 	aspect=  New aspect ratio. 
	*/
	void setAspectRatio(float aspect);

	/// Sets the field of view (Default: PI / 2.5f)
	/**
	* Params:
	* 	fovy=  New field of view in radians. 
	*/
	void setFOV(float fovy);

	/// Get the view frustum.
	/**
	* Needed sometimes by bspTree or LOD render nodes.
	* Returns: The current view frustum. 
	*/
	ref const SViewFrustum getViewFrustum() const;

	/// Disables or enables the camera to get key or mouse inputs.
	/**
	* If this is set to true, the camera will respond to key
	* inputs otherwise not. 
	*/
	void setInputReceiverEnabled(bool enabled);

	/// Checks if the input receiver of the camera is currently enabled.
	bool isInputReceiverEnabled() const;

	/// Checks if a camera is orthogonal.
	bool isOrthogonal() const
	{
		return IsOrthogonal;
	}

	/// Binds the camera scene node's rotation to its target position and vice vera, or unbinds them.
	/**
	* When bound, calling setRotation() will update the camera's
	* target position to be along its +Z axis, and likewise calling
	* setTarget() will update its rotation so that its +Z axis will
	* point at the target point. FPS camera use this binding by
	* default; other cameras do not.
	* Params:
	* 	bound=  True to bind the camera's scene node rotation
	* and targetting, false to unbind them.
	* @see getTargetAndRotationBinding() 
	*/
	void bindTargetAndRotation(bool bound);

	/// Queries if the camera scene node's rotation and its target position are bound together.
	/**
	* @see bindTargetAndRotation() 
	*/
	bool getTargetAndRotationBinding() const;

	/// Writes attributes of the camera node
	override void serializeAttributes(out IAttributes outAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions()) const
	{
		super.serializeAttributes(outAttr, options);

		if (outAttr is null)
			return;
		outAttr.add("IsOrthogonal", IsOrthogonal );
	}

	/// Reads attributes of the camera node
	override void deserializeAttributes(IAttributes inAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions())
	{
		super.deserializeAttributes(inAttr, options);
		if (inAttr is null)
			return;

		if ( inAttr.findAttribute("IsOrthogonal") )
			IsOrthogonal = inAttr.getAttribute!bool("IsOrthogonal");
	}

	protected void cloneMembers(ICameraSceneNode toCopyFrom)
	{
		IsOrthogonal = toCopyFrom.IsOrthogonal;
	}

	protected bool IsOrthogonal;
}
