// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.SLight;

import irrlicht.video.SColor;
import irrlicht.core.vector3d;

/// Enumeration for different types of lights
enum E_LIGHT_TYPE
{
	/// point light, it has a position in space and radiates light in all directions
	ELT_POINT,
	/// spot light, it has a position in space, a direction, and a limited cone of influence
	ELT_SPOT,
	/// directional light, coming from a direction from an infinite distance
	ELT_DIRECTIONAL,

	/// Only used for counting the elements of this enum
	ELT_COUNT
};

/// Names for light types
immutable(string[]) LightTypeNames =
[
	"Point",
	"Spot",
	"Directional",
];

/// structure for holding data describing a dynamic point light.
/**
* Irrlicht supports point lights, spot lights, and directional lights.
*/
struct SLight
{
	/// Ambient color emitted by the light
	SColorf AmbientColor = SColorf(0.0f, 0.0f, 0.0f);

	/// Diffuse color emitted by the light.
	/**
	* This is the primary color you want to set. 
	*/
	SColorf DiffuseColor = SColorf(1.0f,1.0f,1.0f);

	/// Specular color emitted by the light.
	/**
	* For details how to use specular highlights, see SMaterial::Shininess 
	*/
	SColorf SpecularColor = SColorf(1.0f,1.0f,1.0f);

	/// Attenuation factors (constant, linear, quadratic)
	/**
	* Changes the light strength fading over distance.
	* Can also be altered by setting the radius, Attenuation will change to
	* (0,1.0f/radius,0). Can be overridden after radius was set. 
	*/
	vector3df Attenuation = vector3df(1.0f,0.0f,0.0f);

	/// The angle of the spot's outer cone. Ignored for other lights.
	float OuterCone = 45.0f;

	/// The angle of the spot's inner cone. Ignored for other lights.
	float InnerCone = 0.0f;

	/// The light strength's decrease between Outer and Inner cone.
	float Falloff = 2.0f;

	/// Read-ONLY! Position of the light.
	/**
	* If Type is ELT_DIRECTIONAL, it is ignored. Changed via light scene node's position. 
	*/
	vector3df Position = vector3df(0.0f,0.0f,0.0f);

	/// Read-ONLY! Direction of the light.
	/**
	* If Type is ELT_POINT, it is ignored. Changed via light scene node's rotation. 
	*/
	vector3df Direction = vector3df(0.0f,0.0f,1.0f);

	/// Read-ONLY! Radius of light. Everything within this radius will be lighted.
	float Radius = 100.0f;

	/// Read-ONLY! Type of the light. Default: ELT_POINT
	E_LIGHT_TYPE Type = E_LIGHT_TYPE.ELT_POINT;

	/// Read-ONLY! Does the light cast shadows?
	bool CastShadows = true;
}