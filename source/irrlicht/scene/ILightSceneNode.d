// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ILightSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.video.SLight;
import irrlicht.core.vector3d;

/// Scene node which is a dynamic light.
/**
* You can switch the light on and off by making it visible or not. It can be
* animated by ordinary scene node animators. If the light type is directional or
* spot, the direction of the light source is defined by the rotation of the scene
* node (assuming (0,0,1) as the local direction of the light).
*/
abstract class ILightSceneNode : ISceneNode
{
	/// constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0))
	{
		super(parent, mgr, id, position);
	}

	/// Sets the light data associated with this ILightSceneNode
	/**
	* Params:
	* 	light=  The new light data. 
	*/
	void setLightData()(auto ref const SLight light);

	/// Gets the light data associated with this ILightSceneNode
	/**
	* Returns: The light data. 
	*/
	auto ref const SLight getLightData()() const;

	/// Gets the light data associated with this ILightSceneNode
	/**
	* Returns: The light data. 
	*/
	ref SLight getLightData()();

	/// Sets if the node should be visible or not.
	/**
	* All children of this node won't be visible either, when set
	* to true.
	* Params:
	* 	isVisible=  If the node shall be visible. 
	*/
	override void setVisible(bool isVisible);

	/// Sets the light's radius of influence.
	/**
	* Outside this radius the light won't lighten geometry and cast no
	* shadows. Setting the radius will also influence the attenuation, setting
	* it to (0,1/radius,0). If you want to override this behavior, set the
	* attenuation after the radius.
	* Params:
	* 	radius=  The new radius. 
	*/
	void setRadius(float radius);

	/// Gets the light's radius of influence.
	/**
	* Returns: The current radius. 
	*/
	float getRadius() const;

	/// Sets the light type.
	/**
	* Params:
	* 	type=  The new type. 
	*/
	void setLightType(E_LIGHT_TYPE type);

	/// Gets the light type.
	/**
	* Returns: The current light type. 
	*/
	E_LIGHT_TYPE getLightType() const;

	/// Sets whether this light casts shadows.
	/**
	* Enabling this flag won't automatically cast shadows, the meshes
	* will still need shadow scene nodes attached. But one can enable or
	* disable distinct lights for shadow casting for performance reasons.
	* Params:
	* 	shadow=  True if this light shall cast shadows. 
	*/
	void enableCastShadow(bool shadow=true);

	/// Check whether this light casts shadows.
	/**
	* Returns: True if light would cast shadows, else false. 
	*/
	bool getCastShadow() const;
}
