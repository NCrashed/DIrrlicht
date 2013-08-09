// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IBillboardTextSceneNode;

import irrlicht.video.SColor;
import irrlicht.scene.IBillboardSceneNode;
import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneManager;
import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;

/// A billboard text scene node.
/**
* Acts like a billboard which displays the currently set text.
* Due to the exclusion of RTTI in Irrlicht we have to avoid multiple
* inheritance. Hence, changes to the ITextSceneNode interface have
* to be copied here manually.
*/
abstract class IBillboardTextSceneNode : IBillboardSceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0))
	{
		super(parent, mgr, id, position);
	}

	/// Sets the size of the billboard.
	void setSize()(auto ref const dimension2d!float size);

	/// Returns the size of the billboard.
	auto ref const dimension2d!float getSize()() const;

	/// Set the color of all vertices of the billboard
	/**
	* Params:
	* 	overallColor=  the color to set 
	*/
	void setColor()(auto ref const SColor overallColor);

	/// Set the color of the top and bottom vertices of the billboard
	/**
	* Params:
	* 	topColor=  the color to set the top vertices
	* 	bottomColor=  the color to set the bottom vertices 
	*/
	void setColor()(auto ref const SColor topColor, auto ref const SColor bottomColor);

	/// Gets the color of the top and bottom vertices of the billboard
	/**
	* Params:
	* 	topColor=  stores the color of the top vertices
	* 	bottomColor=  stores the color of the bottom vertices 
	*/
	override void getColor(out SColor topColor, out SColor bottomColor) const;

	/// sets the text string
	void setText(wstring text);

	/// sets the color of the text
	void setTextColor()(auto ref const SColor color);
}