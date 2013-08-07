// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ITextSceneNode;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.video.SColor;
import irrlicht.core.vector3d;

/// A scene node for displaying 2d text at a position in three dimensional space
abstract class ITextSceneNode : ISceneNode
{
	/// constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0))
	{
		super(parent, mgr, id, position);
	}

	/// sets the text string
	void setText(wstring text);

	/// sets the color of the text
	void setTextColor(SColor color);
}