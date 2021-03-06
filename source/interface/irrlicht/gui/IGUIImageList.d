// This file is part of the "Irrlicht Engine".
// written by Reinhard Ostermeier, reinhard@nospam.r-ostermeier.de

module irrlicht.gui.IGUIImageList;

import irrlicht.gui.IGUIElement;
import irrlicht.core.rect;
import irrlicht.core.dimension2d;
import irrlicht.core.vector2d;

/// Font interface.
interface IGUIImageList
{
	/// Draws an image and clips it to the specified rectangle if wanted
	/**
	* Params:
	* 	index= Index of the image
	* 	destPos= Position of the image to draw
	* 	clip= Optional pointer to a rectalgle against which the text will be clipped.
	* 
	* If the pointer is null, no clipping will be done.
	*/
	void draw(int index, vector2d!int destPos,
		const rect!(int)* clip = null);

	/// Returns the count of Images in the list.
	/**
	* Returns: Returns the count of Images in the list.
	*/
	size_t getImageCount() const;

	/// Returns the size of the images in the list.
	/**
	* Returns: Returns the size of the images in the list.
	*/
	dimension2d!int getImageSize();
}

