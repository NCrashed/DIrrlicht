// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIFont;

import irrlicht.video.SColor;
import irrlicht.core.rect;
import irrlicht.core.dimension2d;

/// An enum for the different types of GUI font.
enum EGUI_FONT_TYPE
{
	/// Bitmap fonts loaded from an XML file or a texture.
	EGFT_BITMAP = 0,

	/// Scalable vector fonts loaded from an XML file.
	/**
	* These fonts reside in system memory and use no video memory
	* until they are displayed. These are slower than bitmap fonts
	* but can be easily scaled and rotated. 
	*/
	EGFT_VECTOR,

	/// A font which uses a the native API provided by the operating system.
	/**
	* Currently not used. 
	*/
	EGFT_OS,

	/// An external font type provided by the user.
	EGFT_CUSTOM
}

/// Font interface.
interface IGUIFont
{
	/// Draws some text and clips it to the specified rectangle if wanted.
	/**
	* Params:
	* 	text=  Text to draw
	* 	position=  Rectangle specifying position where to draw the text.
	* 	color=  Color of the text
	* 	hcenter=  Specifies if the text should be centered horizontally into the rectangle.
	* 	vcenter=  Specifies if the text should be centered vertically into the rectangle.
	* 	clip=  Optional pointer to a rectangle against which the text will be clipped.
	* If the pointer is null, no clipping will be done. 
	*/
	void draw()(const wstring text, auto ref const rect!int position,
		SColor color, bool hcenter = false, bool vcenter = false,
		const rect!int clip = rect!int(0,0,0,0));

	/// Calculates the width and height of a given string of text.
	/**
	* Returns: Returns width and height of the area covered by the text if
	* it would be drawn. 
	*/
	dimension2d!uint getDimension(const string text) const;

	/// Calculates the index of the character in the text which is on a specific position.
	/**
	* Params:
	* 	text=  Text string.
	* 	pixel_x=  X pixel position of which the index of the character will be returned.
	* Returns: Returns zero based index of the character in the text, and -1 if no no character
	* is on this position. (=the text is too short). 
	*/
	int getCharacterFromPos(const string text, int pixel_x) const;

	/// Returns the type of this font
	abstract EGUI_FONT_TYPE getType() const;

	/// Sets global kerning width for the font.
	void setKerningWidth (int kerning);

	/// Sets global kerning height for the font.
	void setKerningHeight (int kerning);

	/// Gets kerning values (distance between letters) for the font. If no parameters are provided,
	/**
	* the global kerning distance is returned.
	* Params:
	* 	thisLetter=  If this parameter is provided, the left side kerning
	* for this letter is added to the global kerning value. For example, a
	* space might only be one pixel wide, but it may be displayed as several
	* pixels.
	* 	previousLetter=  If provided, kerning is calculated for both
	* letters and added to the global kerning value. For example, in a font
	* which supports kerning pairs a string such as 'Wo' may have the 'o'
	* tucked neatly under the 'W'.
	*/
	int getKerningWidth(const wstring thisLetter = "", const wstring previousLetter = "") const;

	/// Returns the distance between letters
	int getKerningHeight() const;

	/// Define which characters should not be drawn by the font.
	/**
	* For example " " would not draw any space which is usually blank in
	* most fonts.
	* Params:
	* 	s=  String of symbols which are not send down to the videodriver
	*/
	void setInvisibleCharacters( const wstring s );
}
