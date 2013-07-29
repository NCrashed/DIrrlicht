// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.SColor;

import irrlicht.irrMath;
import std.math : fmin, fmax, round, approxEqual, floor;

/// An enum for the color format of textures used by the Irrlicht Engine.
/**
*	A color format specifies how color information is stored.
*/
enum ECOLOR_FORMAT
{
	/// 16 bit color format used by ther software driver.
	/**
	* It is thus preferred by all other irrlicht engine video drivers.
	* There are 5 bits fore every color component, and a single bit is left
	* for alpha information.
	*/
	ECF_A1R5G5B5 = 0,

	/// Standart 16 bit color format.
	ECF_R5G6B5,

	/// 24 bit color, no alpha channel, but 8 bit for red, green and blue.
	ECF_R8G8B8,

	/// Default 32 bit color format. 8 bits are used for every component: red, green, blue and alpha.
	ECF_A8R8G8B8,

	/* Floating Point formats. The following formats may only be used for render target textures. */

	/// 16 bit floating point format usdign 16 bits for the red channel.
	ECF_R16F,

	/// 32 bit floating point format usding 16 bits for the red channel and 16 bits for the green channel.
	ECF_G16R16F,

	/// 64 bit floating point format 16 bits are used for the red, green, blue and alpha channels.
	ECF_A16B16G16R16F,

	/// 32 bit floating point format using 32 bits for the red channel.
	ECF_R32F,

	/// 64 bit floatin point format using 32 bits for the red channel and 32 bits fore the green channel.
	ECF_G32R32F,

	/// 128 bit floating point format. 32 bits are used for the red, green, blue and alpha channels.
	ECF_A32B32G32R32F,

	/// Unknown color format
	ECF_UNKNOWN
};

static pure nothrow
{
	/// Creates a 16 bit A1R5G5B5 color
	ushort RGBA16(uint r, uint g, uint b, uint a = 0xFF) 
	{
		return cast(ushort)(
			(a & 0x80) << 8 |
			(r & 0xF8) << 7 |
			(g & 0xF8) << 2 |
			(b & 0XF8) >> 3);
	}

	/// Creates a 16 bit A1R5G5B5 color
	ushort RGB16(uint r, uint g, uint b)
	{
		return RGBA16(r, g, b);
	}

	/// Creates a 16bit A1R5G5B5 color, based on 16 bit input values
	ushort RGB16from16(ushort r, ushort g, ushort b) 
	{
		return (0x8000 |
			(r & 0x1F) << 10 |
			(g & 0x1F) << 5  |
			(b & 0x1F));
	}

	/// Converts a 32 bit (X8R8G8B8) color to a 16bit A1R5G5B5 color
	ushort X8R8G8B8toA1R5G5B5(uint color) 
	{
		return cast(ushort)(0x8000 |
			( color & 0x00F80000) >> 9 |
			( color & 0x0000F800) >> 6 |
			( color & 0x000000F8) >> 3);
	}

	/// Converts a 32bit (A8R8G8B8) color to a 16bit A1R5G5B5 color
	ushort A8R8G8B8toA1R5G5B5(uint color)
	{
		return cast(ushort)(( color & 0x80000000) >> 16 |
			( color & 0x00F80000) >> 9 |
			( color & 0x0000F800) >> 6 |
			( color & 0x000000F8) >> 3);
	}

	/// Converts a 32bit (A8R8G8B8) color to a 16bit R5G6B5 color
	ushort A8R8G8B8toR5G6B5(uint color)
	{
		return cast(ushort)(( color & 0x00F80000) >> 8 |
			( color & 0x0000FC00) >> 5 |
			( color & 0x000000F8) >> 3);
	}

	/// Convert A8R8G8B8 Color from A1R5G5B5 color
	/** 
	* Build a nicer 32bit Color by extending dest lower bits with source high bits. 
	*/
	uint A1R5G5B5toA8R8G8B8(ushort color)
	{
		return ( (( -( cast(int) color & 0x00008000 ) >> cast(int) 31 ) & 0xFF000000 ) |
				(( color & 0x00007C00 ) << 9) | (( color & 0x00007000 ) << 4) |
				(( color & 0x000003E0 ) << 6) | (( color & 0x00000380 ) << 1) |
				(( color & 0x0000001F ) << 3) | (( color & 0x0000001C ) >> 2)
				);
	}

	/// Returns A8R8G8B8 Color from R5G6B5 color
	uint R5G6B5toA8R8G8B8(ushort color)
	{
		return 0xFF000000 |
			((color & 0xF800) << 8)|
			((color & 0x07E0) << 5)|
			((color & 0x001F) << 3);
	}


	/// Returns A1R5G5B5 Color from R5G6B5 color
	ushort R5G6B5toA1R5G5B5(ushort color)
	{
		return 0x8000 | (((color & 0xFFC0) >> 1) | (color & 0x1F));
	}

	/// Returns R5G6B5 Color from A1R5G5B5 color
	ushort A1R5G5B5toR5G6B5(ushort color)
	{
		return (((color & 0x7FE0) << 1) | (color & 0x1F));
	}

	/// Returns the alpha component from A1R5G5B5 color
	/** 
	* In Irrlicht, alpha refers to opacity.
	* Returns: The alpha value of the color. 0 is transparent, 1 is opaque. 
	*/
	uint getAlpha(ushort color)
	{
		return ((color >> 15)&0x1);
	}


	/// Returns the red component from A1R5G5B5 color.
	/** 
	* Shift left by 3 to get 8 bit value. 
	*/
	uint getRed(ushort color)
	{
		return ((color >> 10)&0x1F);
	}


	/// Returns the green component from A1R5G5B5 color
	/** 
	* Shift left by 3 to get 8 bit value. 
	*/
	uint getGreen(ushort color)
	{
		return ((color >> 5)&0x1F);
	}

	/// Returns the blue component from A1R5G5B5 color
	/** 
	* Shift left by 3 to get 8 bit value. 
	*/
	uint getBlue(ushort color)
	{
		return (color & 0x1F);
	}


	/// Returns the average from a 16 bit A1R5G5B5 color
	int getAverage(short color)
	{
		return ((getRed(color)<<3) + (getGreen(color)<<3) + (getBlue(color)<<3)) / 3;
	}

}

/// Class representing a 32 bit ARGB color.
/** 
* The color values for alpha, red, green, and blue are
* stored in a single uint. So all four values may be between 0 and 255.
* Alpha in Irrlicht is opacity, so 0 is fully transparent, 255 is fully opaque (solid).
* This struct is used by most parts of the Irrlicht Engine
* to specify a color. Another way is using the struct SColorf, which
* stores the color values in 4 floats.
* This struct must consist of only one uint and must not use virtual functions.
*/
struct SColor 
{
	/// Constructs the color from 4 values representing the alpha, red, green and blue component.
	/** 
	* Must be values between 0 and 255. 
	*/
	this(uint a, uint r, uint g, uint b) pure
	{
		color = ((a & 0xFF) << 24 |
			((r & 0xFF) << 16) |
			((g & 0xFF) << 8) |
			((b & 0xFF)));
	}

	/// Constructs the color from a 32 bit value. Could be another color.
	this(uint clr) pure
	{
		color = clr;
	}

	/// Returns the alpha component of the color.
	/**
	* The alpha component defines how opaque a color is.
	* Returns: The alpha value of the color. 0 is fully transparent, 255 is fully opaque
	*/
	uint getAlpha() pure const
	{
		return color >> 24;
	}

	/// Returns the red component of the color.
	/**
	* Returns: Value between 0 and 255, specifying how red the color is.
	* 0 means no red, 255 means full red.
	*/
	uint getRed() pure const
	{
		return (color >> 16) & 0xFF;
	}

	/// Returns the green component of the color.
	/**
	* Returns: Value between 0 and 255, specifying how green the color is.
	* 0 means no green, 255 means full green.
	*/
	uint getGreen() pure const
	{
		return (color >> 8) & 0xFF;
	}

	/// Returns the blue component of the color.
	/**
	* Returns: Value between 0 and 255, specifying how blue the color is.
	* 0 means no blue, 255 means full blue.
	*/
	uint getBlue() pure const
	{
		return color & 0xFF;
	}

	/// Get lightness of the color in the range [0, 255]
	float getLightness() pure const
	{
		return 0.5f*cast(float)(fmax(fmax(getRed(), getGreen()), getBlue()) + fmin(fmin(getRed(), getGreen()), getBlue()));
	}

	/// Get luminance of the color in the range [0, 255]
	float getLuminance() pure const
	{
		return 0.3f*getRed() + 0.59f*getGreen() + 0.11f*getBlue();
	}

	/// Get average intensity of the color in the range [0, 255].
	uint getAverage() pure const
	{
		return (getRed() + getGreen() + getBlue()) / 3;
	}

	/// Sets the alpha component of the Color.
	/**
	* The alpha component defines how transparent a color should be.
	* Params:
	* a 	The alpha value of the color. 0 is fully transparent, 255 is fully opaque.
	*/
	void setAlpha(uint a)
	{
		color = ((a & 0xff)<<24) | (color & 0x00ffffff);
	}

	/// Sets the red component of the Color.
	/**
	* Params:
	* r 	Has to be a value between 0 and 255.
	* 0 means no red, 255 means full red.
	*/
	void setRed(uint r)
	{
		color = ((r & 0xff)<<16) | (color & 0xff00ffff);
	}

	/// Sets the green component of the Color.
	/**
	* Params:
	* g 	Has to be a value between 0 and 255.
	* 0 means no green, 255 means full green.
	*/
	void setGreen(uint g)
	{
		color = ((g & 0xff)<<8) | (color & 0xffff00ff);
	}

	/// Sets the blue component of the Color.
	/**
	* Params:
	* b 	Has to be a value between 0 and 255.
	* 0 means no blue, 255 means full blue.
	*/
	void setBlue(uint b)
	{
		color = (b & 0xff) | (color & 0xffffff00);
	}

	/// Calculates a 16 bit A1R5G5B5 value of this color.
	/**
	* Returns: 16 bit A1R5G5B5 value of this color.
	*/
	ushort toA1R5G5B5() const
	{
		return A8R8G8B8toA1R5G5B5(color);
	}

	/// Converts color to OpenGL color format
	/**
	* From ARGB to RGBA in 4 byte components for endian aware
	* passing to OpenGL.
	* Params:
	* dest 	address where the 4x8 bit OpenGL color is stored.
	*/
	void toOpenGLColor(ubyte* dest) const
	{
		*dest = cast(ubyte)getRed();
		*++dest = cast(ubyte)getGreen();
		*++dest = cast(ubyte)getBlue();
		*++dest = cast(ubyte)getAlpha();
	}

	/// Sets all four components of the color at once.
	/**
	* Constructs the color from 4 values representing the alpha,
	* red, green, and blue components of the color. Must be values
	* between 0 and 255.
	*
	* Params:
	* a 	Alpha component of the color. The alpha component
	* defines how transparent a color should be. Has to be a value
	* between 0 and 255. 255 means not transparent (opaque), 0 means
	* fully transparent.
	* r 	Sets the red component of the Color. Has to be a 
	* value between 0 and 255. 0 means no red, 255 means full red.
	* g 	Sets the green component of the Color. Has to be a 
	* value between 0 and 255. 0 means no green, 255 means full green.
	* b 	Sets the blue component of the Color. Has to be a 
	* value between 0 and 255. 0 means no blue, 255 means full blue.	
	*/
	void set(uint a, uint r, uint g, uint b)
	{
		color = (((a & 0xff)<<24) | ((r & 0xff)<<16) | ((g & 0xff)<<8) | (b & 0xff));
	}

	void set(uint col)
	{
		color = col;
	}

	/// Compared the color to another color
	/**
	* Returns: True if ther colors are the same, and false if not.
	*/
	bool opEqual()(auto ref const SColor other) const
	{
		return other.color == color;
	}

	/// Comparison operator
	int opCmp()(auto ref const SColor other) const
	{
		if (color < other.color)
			return -1;
		else if (color > other.color)
			return 1;
		else
			return 0;
	}

	/// Adds two colors, result is clamped to 0..255 values
	/**
	* Params:
	* other 	Color to add to this color
	*
	* Returns: Addition of the two colors, clamped to 0..255 values.
	*/
	SColor opBinary(string op)(auto ref const SColor other) const
		if(op == "+")
	{
		return SColor(fmin(getAlpha() + other.getAlpha(), 255u),
			fmin(getRed() + ohter.getREd(), 255u).
			fmin(getGreen() + other.getGreen(), 255u),
			fmin(getBlue() + other.getBlue(), 255u));
	}

	/// Interpolates the color with a f32 value to another color
	/**
	* Params: 
	* other		Other color
	* d 		value between 0.0f and 1.0f
	*
	* Returns: Interpolated color. 
	*/
	SColor getInterpolated()(auto ref const SColor other, float d) const
	{
		d = clamp(d, 0.0f, 1.0f);
		immutable float inv = 1.0f - d;
		return SColor(cast(uint)round(other.getAlpha()*inv + getAlpha()*d),
			cast(uint)round(other.getRed()*inv + getRed()*d),
			cast(uint)round(other.getGreen()*inv + getGreen()*d),
			cast(uint)round(other.getBlue()*inv + getBlue()*d));
	}

	/// Returns interpolated color. (quadratic)
	/**
	* Params:
	* c1 	first color to interpolate with
	* c2 	second color to interpolate with
	* d 	value between 0.0f and 1.0f.
	*/
	SColor getInterpolated_quadratic()(auto ref const SColor c1, auto ref const SColor c2, float d) const
	{
		// this*(1-d)*(1-d) + 2 * c1 * (1-d) + c2 * d * d;
		d = clamp(d, 0.0f, 1.0f);
		immutable float inv = 1.0f - d;
		immutable float mul0 = inv * inv;
		immutable float mul1 = 2.0f * d * inv;
		immutable float mul2 = d * d;

		return SColor(
			cast(uint)clamp(floor(
				getAlpha() * mul0 + c1.getAlpha() * mul1 + c2.getAlpha() * mul2), 0, 255),
			cast(uint)clamp(floor(
				getRed()   * mul0 + c1.getRed()   * mul1 + c2.getRed()   * mul2), 0, 255),
			cast(uint)clamp(floor(
				getGreen() * mul0 + c1.getGreen() * mul1 + c2.getGreen() * mul2), 0, 255),
			cast(uint)clamp(floor(
				getBlue()  * mul0 + c1.getBlue()  * mul1 + c2.getBlue()  * mul2), 0, 255));
	}

	/// Set the color by expecting data in the given format
	/**
	* Params:
	* data 		must point to valid memory containing color information in the given format
	* format 	tells the format in which data is available.
	*/
	void setData(const void* data, ECOLOR_FORMAT format)
	{
		switch(format)
		{
			case ECOLOR_FORMAT.ECF_A1R5G5B5:
				color = A1R5G5B5toA8R8G8B8(*cast(ushort*)data);
				break;
			case ECOLOR_FORMAT.ECF_R5G6B5:
				color = R5G6B5toA8R8G8B8(*cast(ushort*)data);
				break;
			case ECOLOR_FORMAT.ECF_A8R8G8B8:
				color = *cast(ushort*)data;
				break;
			case ECOLOR_FORMAT.ECF_R8G8B8:
			{
				ubyte* p = cast(ubyte*)data;
				set(255, p[0], p[1], p[2]);
				break;
			}
			default:
				color = 0xFFFFFFFF;
		}
	}

	/// Write the color to data in the defined format
	/**
	* Params:
	* data 		target to write the color. Must contain sufficiently large memory to receive the number of bytes for format.
	* format 	tells the format used to write the color int data.
	*/
	void getData(void* data, ECOLOR_FORMAT format) const
	{
		switch(format)
		{
			case ECOLOR_FORMAT.ECF_A1R5G5B5:
			{
				ushort* dest = cast(ushort*)data;
				*dest = A8R8G8B8toA1R5G5B5(color);
				break;
			}
			case ECOLOR_FORMAT.ECF_R5G6B5:
			{
				ushort* dest = cast(ushort*)data;
				*dest = A8R8G8B8toR5G6B5(color);
				break;
			}
			case ECOLOR_FORMAT.ECF_R8G8B8:
			{
				ubyte* dest = cast(ubyte*)data;
				dest[0] = cast(ubyte)getRed();
				dest[1] = cast(ubyte)getGreen();
				dest[2] = cast(ubyte)getBlue();
				break;
			}
			case ECOLOR_FORMAT.ECF_A8R8G8B8:
			{
				uint* dest = cast(uint*)data;
				*dest = color;
				break;
			}
			default:
		}
	}

	/// color in A8R8G8B8 format
	uint color;
}


/// Class representing a color with four floats.
/** 
* The color values for red, green, blue
* and alpha are each stored in a 32 bit floating point variable.
* So all four values may be between 0.0f and 1.0f.
* Another, faster way to define colors is using the class SColor, which
* stores the color values in a single 32 bit integer.
*/
struct SColorf
{
	/// Constructs a color from up to four color values: red, green, blue, and alpha.
	/** 
	* Params:
	* r		Red color component. Should be a value between
	* 0.0f meaning no red and 1.0f, meaning full red.
	* g		Green color component. Should be a value between 0.0f
	* meaning no green and 1.0f, meaning full green.
	* b		Blue color component. Should be a value between 0.0f
	* meaning no blue and 1.0f, meaning full blue.
	* a		Alpha color component of the color. The alpha
	* component defines how transparent a color should be. Has to be
	* a value between 0.0f and 1.0f, 1.0f means not transparent
	* (opaque), 0.0f means fully transparent. 
	*/
	this(float r, float g, float b, float a = 1.0f) pure
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	/// Constructs a color from 32 bit Color
	/**
	* Params:
	* c 	32 bit color from which this SColorf clas is
	* constructed from.
	*/
	this(SColor c) pure
	{
		immutable float inv = 1.0f / 255.0f;
		r = c.getRed() * inv;
		g = c.getGreen() * inv;
		b = c.getBlue() * inv;
		a = c.getAlpha() * inv;
	}

	/// Converts this color to a SColor without floats
	SColor toSColor()
	{
		return SColor(cast(uint)round(a*255.0f), 
			cast(uint)round(r*255.0f),
			cast(uint)round(g*255.0f),
			cast(uint)round(b*255.0f));
	}

	/// Sets three color components to new values at once.
	/**
	* Params: 
	* rr 	Red color component. Should be a value between 0.0f meaning
	* no red (=black) and 1.0f, meaning full red.
	* gg	Green color component. Should be a value between 0.0f meaning
	* no green (=black) and 1.0f, meaning full green.
	* bb	Blue color component. Should be a value between 0.0f meaning
	* no blue (=black) and 1.0f, meaning full blue. 
	*/
	void set(float rr, float gg, float bb)
	{
		r = rr;
		g = gg;
		b = bb;
	}

	/// Sets all four color components to new values at once.
	/** 
	* Params:
	* aa	Alpha component. Should be a value between 0.0f meaning
	* fully transparent and 1.0f, meaning opaque.
	* rr	Red color component. Should be a value between 0.0f meaning
	* no red and 1.0f, meaning full red.
	* gg	Green color component. Should be a value between 0.0f meaning
	* no green and 1.0f, meaning full green.
	* bb	Blue color component. Should be a value between 0.0f meaning
	* no blue and 1.0f, meaning full blue. 
	*/
	void set(float aa, float rr, float gg, float bb)
	{
		a = aa;
		r = rr;
		g = gg;
		b = bb;
	}

	/// Interpolates the color with a f32 value to another color
	/**
	* Params: 
	* other		Other color
	* d 	value between 0.0f and 1.0f
	* 
	* Returns: Interpolated color. 
	*/
	SColorf getInterpolated()(auto ref const SColorf other, float d)
	{
		d = clamp(d, 0.0f, 1.0f);
		immutable float inv = 1.0f - d;
		return SColorf(other.r*inv + r*d,
			other.g*inv + g*d, 
			other.b*inv + b*d,
			other.a*inv + a*d);
	}

	/// Returns interpolated color. ( quadratic )
	/**
	* Params: 
	* c1	first color to interpolate with
	* c2	second color to interpolate with
	* d		value between 0.0f and 1.0f. 
	*/
	SColorf getInterpolated_quadratic()(auto ref const SColorf c1, auto ref const SColorf c2,
		float d)
	{
		d = clamp(d, 0.0f, 1.0f);
		// this*(1-d)*(1-d) + 2 * c1 * (1-d) + c2 * d * d;
		immutable float inv = 1.0f - d;
		immutable float mul0 = inv * inv;
		immutable float mul1 = 2.0f * d * inv;
		immutable float mul2 = d * d;

		return SColorf(r * mul0 + c1.r * mul1 + c2.r * mul2,
			g * mul0 + c1.g * mul1 + c2.g * mul2,
			b * mul0 + c1.b * mul1 + c2.b * mul2,
			a * mul0 + c1.a * mul1 + c2.a * mul2);
	}

	/// Sets a color component by index. R = 0, G = 1, B = 2, A = 3
	void setColorComponentValue(int index, float value)
	{
		switch(index)
		{
			case 0: r = value; break;
			case 1: g = value; break;
			case 2: b = value; break;
			case 3: a = value; break;
			default:
		}
	}

	/// Returns the alpha component of the color in the range 0.0 (transparent) to 1.0 (opaque)
	float getAlpha()
	{
		return a;
	}

	/// Returns the red component of the color in the range 0.0 to 1.0
	float getRed()
	{
		return r;
	}

	/// Returns the green component of the color in the range 0.0 to 1.0
	float getGreen()
	{
		return g;
	}

	/// Returns the blue component of the color in the range 0.0 to 1.0
	float getBlue()
	{
		return b;
	}

	/// red color component
	float r = 0.0f;

	/// green color component
	float g = 0.0f;

	/// blue component
	float b = 0.0f;

	/// alpha color component
	float a = 1.0f;
}

/// Struct representing a color in HSL format
/** 
* The color values for hue, saturation, luminance
* are stored in 32bit floating point variables. Hue is in range [0,360],
* Luminance and Saturation are in percent [0,100]
*/
struct SColorHSL
{
	this(float h = 0.0f, float s = 0.0f, float l = 0.0f) pure
	{
		Hue = h;
		Saturation = s;
		Luminance = l;
	}

	void fromRGB()(auto ref const SColorf color)
	{
		immutable float maxVal = cast(float)fmax(color.getRed(), fmax(color.getGreen(), color.getBlue()));
		immutable float minVal = cast(float)fmin(color.getRed(), fmin(color.getGreen(), color.getBlue()));
		Luminance = (maxVal + minVal) * 50;

		if (approxEqual(maxVal, minVal))
		{
			Hue = 0.0f;
			Saturation = 0.0f;
			return;
		}

		immutable float delta = maxVal - minVal;
		if (Luminance <= 50)
		{
			Saturation = (delta)/(maxVal + minVal);
		}
		else
		{
			Saturation = (delta)/(2 - maxVal - minVal);
		}
		Saturation *= 100;

		if (approxEqual(maxVal, color.getRed()))
			Hue = (color.getGreen() - color.getBlue())/delta;
		else if (approxEqual(maxVal, color.getGreen()))
			Hue = 2 + ((color.getBlue()-color.getRed())/delta);
		else // blue is max
			Hue = 4 + ((color.getRed()-color.getGreen())/delta);

		Hue *= 60.0f;
		while(Hue < 0.0f)
			Hue += 360;
	}

	void toRGB(ref SColorf color)
	{
		immutable float l = Luminance / 100;
		if (approxEqual(Saturation, 0.0f)) // grey
		{
			color.set(l, l, l);
			return;
		}

		float rm2;

		if (Luminance <= 50)
		{
			rm2 = l + l * (Saturation/100);
		}
		else
		{
			rm2 = l + (1-l)*(Saturation/100);
		}

		immutable float rm1 = 2.0f*l -rm2;
		immutable float h = Hue / 360.0f;

		color.set( toRGB1(rm1, rm2, h + 1.0f/3.0f),
			toRGB1(rm1, rm2, h),
			toRGB1(rm1, rm2, h - 1.0f/3.0f));
	}

	float Hue = 0.0f;
	float Saturation = 0.0f;
	float Luminance = 0.0f;

	// algorithm from Foley/Van-Dam
	private float toRGB1(float rm1, float rm2, float rh)
	{
		if(rh < 0)
			rh += 1;
		if(rh > 1)
			rh -= 1;

		if(rh < 1.0f/6.0f)
			rm1 = rm1 + (rm2 - rm1) * rh * 6.0f;
		else if(rh < 0.5f)
			rm1 = rm2;
		else if(rh < 2.0f/3.0f)
			rm1 = rm1 + (rm2 - rm1) * ((2.0f/3.0f)-rh)*6.0f;

		return rm1;
	}
}