// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
//
// created by Dean Wadsworth aka Varmint Dec 31 2007
module irrlicht.scene.IVolumeLightSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.ESceneNodeTypes;
import irrlicht.scene.IMeshBuffer;
import irrlicht.video.SColor;
import irrlicht.core.vector3d;

abstract class IVolumeLightSceneNode : ISceneNode
{
	/// constructor
	this()(ISceneNode parent, ISceneManager mgr, int id,
		auto ref const vector3df position,
		auto ref const vector3df rotation,
		auto ref const vector3df scale)
	{
		super(parent, mgr, id, position, rotation, scale);
	}

	/// Returns type of the scene node
	override ESCENE_NODE_TYPE getType() const 
	{ 
		return ESCENE_NODE_TYPE.ESNT_VOLUME_LIGHT; 
	}

	/// Sets the number of segments across the U axis
	void setSubDivideU(const uint inU);

	/// Sets the number of segments across the V axis
	void setSubDivideV(const uint inV);

	/// Returns the number of segments across the U axis
	uint getSubDivideU() const;

	/// Returns the number of segments across the V axis
	uint getSubDivideV() const;

	/// Sets the color of the base of the light
	void setFootColor()(auto ref const SColor inColor);

	/// Sets the color of the tip of the light
	void setTailColor()(auto ref const SColor inColor);

	/// Returns the color of the base of the light
	auto ref const SColor getFootColor() const;

	/// Returns the color of the tip of the light
	auto ref const SColor getTailColor() const;
}