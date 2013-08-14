// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IBillboardSceneNode;

import irrlicht.video.SColor;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.ISceneNode;
import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;

/// A billboard scene node.
/**
* A billboard is like a 3d sprite: A 2d element,
* which always looks to the camera. It is usually used for explosions, fire,
* lensflares, particles and things like that.
*/
abstract class IBillboardSceneNode : ISceneNode
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id,
		const vector3df position = vector3df(0,0,0))
	{
		super(parent, mgr, id, position);
	}

	/// Sets the size of the billboard, making it rectangular.
	void setSize(ref const dimension2df size);

	final void setSize(dimension2df size)
	{
		setSize(size);
	}

	/// Sets the size of the billboard with independent widths of the bottom and top edges.
	/**
	* Params:
	* 	height=  The height of the billboard.
	* 	bottomEdgeWidth=  The width of the bottom edge of the billboard.
	* 	topEdgeWidth=  The width of the top edge of the billboard.
	*/
	void setSize(float height, float bottomEdgeWidth, float topEdgeWidth);

	/// Returns the size of the billboard.
	/**
	* This will return the width of the bottom edge of the billboard.
	* Use getWidths() to retrieve the bottom and top edges independently.
	* Returns: Size of the billboard.
	*/
	dimension2d!float getSize() const;

	/// Gets the size of the the billboard and handles independent top and bottom edge widths correctly.
	/**
	* Params:
	* 	height = The height of the billboard.
	* 	bottomEdgeWidth = The width of the bottom edge of the billboard.
	* 	topEdgeWidth = The width of the top edge of the billboard.
	*/
	void getSize(out float height, out float bottomEdgeWidth, out float topEdgeWidth) const;

	/// Set the color of all vertices of the billboard
	/**
	* Params:
	* 	overallColor=  Color to set 
	*/
	void setColor(SColor overallColor);

	/// Set the color of the top and bottom vertices of the billboard
	/**
	* Params:
	* 	topColor=  Color to set the top vertices
	* 	bottomColor=  Color to set the bottom vertices 
	*/
	void setColor(SColor topColor,
			SColor bottomColor);

	/// Gets the color of the top and bottom vertices of the billboard
	/**
	* Params:
	* 	topColor = Stores the color of the top vertices
	* 	bottomColor = Stores the color of the bottom vertices 
	*/
	void getColor(out SColor topColor,
			out SColor bottomColor) const;
}
