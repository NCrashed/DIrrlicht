// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIImage;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.video.ITexture;
import irrlicht.video.SColor;
import irrlicht.core.rect;

/// GUI element displaying an image.
abstract class IGUIImage : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_IMAGE, environment, parent, id, rectangle);
	}

	/// Sets an image texture
	void setImage(ITexture image);

	/// Gets the image texture
	ITexture getImage() const;

	/// Sets the color of the image
	void setColor(SColor color);

	/// Sets if the image should scale to fit the element
	void setScaleImage(bool scale);

	/// Sets if the image should use its alpha channel to draw itself
	void setUseAlphaChannel(bool use);

	/// Gets the color of the image
	SColor getColor() const;

	/// Returns true if the image is scaled to fit, false if not
	bool isImageScaled() const;

	/// Returns true if the image is using the alpha channel, false if not
	bool isAlphaChannelUsed() const;
}