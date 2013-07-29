// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h

module irrlicht.gui.IGUISpriteBank;

import irrlicht.core.irrArray;
import irrlicht.core.rect;
import irrlicht.video.SColor;
import irrlicht.video.ITexture;

/// A single sprite frame.
struct SGUISpriteFrame
{
	u32 textureNumber;
	u32 rectNumber;
};

/// A sprite composed of several frames.
struct SGUISprite
{
	this()
	{
		Frames = array!SGUISpriteFrame();
		
		frameTime = 0;
	}

	array!SGUISpriteFrame Frames;
	u32 frameTime;
}


/// Sprite bank interface.
/**
* See_Also:
* 	http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=25742&highlight=spritebank
*/
interface IGUISpriteBank
{
	/// Returns the list of rectangles held by the sprite bank
	array!(rect!int) getPositions();

	/// Returns the array of animated sprites within the sprite bank
	array!SGUISprite getSprites();

	/// Returns the number of textures held by the sprite bank
	uint getTextureCount() const;

	/// Gets the texture with the specified index
	ITexture getTexture(uint index) const;

	/// Adds a texture to the sprite bank
	void addTexture(ITexture texture);

	/// Changes one of the textures in the sprite bank
	void setTexture(uint index, ITexture texture);

	/// Add the texture and use it for a single non-animated sprite.
	/// The texture and the corresponding rectangle and sprite will all be added to the end of each array.
	/// returns the index of the sprite or -1 on failure
	int addTextureAsSprite(ITexture texture);

	/// clears sprites, rectangles and textures
	void clear();

	/// Draws a sprite in 2d with position and color
	void draw2DSprite(uint index, const ref position2di pos,
			const ref rect!int clip = rect!int(),
			const ref SColor color= SColor(255,255,255,255),
			uint starttime = 0, uint currenttime = 0,
			bool loop = true, bool center = false);

	/// Draws a sprite batch in 2d using an array of positions and a color
	void draw2DSpriteBatch(const ref array!int indices, const ref array!position2di pos,
			const ref rect!int clip = rect!int(),
			const ref SColor color= SColor(255,255,255,255),
			uint starttime = 0, uint currenttime = 0,
			bool loop = true, bool center = false);
}
