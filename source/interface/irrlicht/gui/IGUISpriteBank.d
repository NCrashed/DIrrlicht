// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUISpriteBank;

import irrlicht.video.SColor;
import irrlicht.video.ITexture;
import irrlicht.core.rect;
import irrlicht.core.vector2d;

/// A single sprite frame.
struct SGUISpriteFrame
{
	uint textureNumber;
	uint rectNumber;
}

/// A sprite composed of several frames.
struct SGUISprite
{
	SGUISpriteFrame[] Frames = [];
	uint frameTime = 0;
}

/// Sprite bank interface.
/**
* See_Also:
* 	http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=25742&highlight=spritebank
*/
interface IGUISpriteBank
{
	/// Returns the list of rectangles held by the sprite bank
	rect!(int)[] getPositions();

	/// Returns the array of animated sprites within the sprite bank
	SGUISprite[] getSprites();

	/// Returns the number of textures held by the sprite bank
	size_t getTextureCount() const;

	/// Gets the texture with the specified index
	ITexture getTexture(size_t index) const;

	/// Adds a texture to the sprite bank
	void addTexture(ITexture texture);

	/// Changes one of the textures in the sprite bank
	void setTexture(size_t index, ITexture texture);

	/// Add the texture and use it for a single non-animated sprite.
	/// The texture and the corresponding rectangle and sprite will all be added to the end of each array.
	/// returns the index of the sprite or -1 on failure
	int addTextureAsSprite(ITexture texture);

	/// clears sprites, rectangles and textures
	void clear();

	/// Draws a sprite in 2d with position and color
	void draw2DSprite()(size_t index, auto ref const vector2di pos,
			const rect!(int)* clip = null,
			const SColor color= SColor(255,255,255,255),
			uint starttime = 0, uint currenttime = 0,
			bool loop = true, bool center = false);

	/// Draws a sprite batch in 2d using an array of positions and a color
	void draw2DSpriteBatch(const size_t[] indices, const vector2di[] pos,
			const rect!(int)* clip = null,
			const SColor color = SColor(255,255,255,255),
			uint starttime = 0, uint currenttime = 0,
			bool loop = true, bool center = false);
}
