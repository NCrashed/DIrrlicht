// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IImage;

import irrlicht.core.vector2d;
import irrlicht.core.dimension2d;
import irrlicht.core.rect;
import irrlicht.video.SColor;

/// Interface for software image data.
/**
*	Image loaders create these images from files. IVideoDrivers
* convert these images into their (hardware) textures.
*/
interface IImage 
{
	/// Lock function. Use this to get a pointer to the image data.
	/** 
	* After you don't need the pointer anymore, you must call unlock().
	* Returns: Pointer to the image data. What type of data is pointed to
	* depends on the color format of the image. For example if the color
	* format is ECF_A8R8G8B8, it is of u32. Be sure to call unlock() after
	* you don't need the pointer any more. 
	*/
	void* lock();

	/// Unlock function
	/**
	* Should be called aftr the pointer received by lock() is not
	* needed anymore.
	*/
	void unlock();

	/// Returns width and height of image data.
	ref const dimension2d!uint getDimension();

	/// Returns bits per pixel.
	uint getBitsPerPixel();

	/// Returns bytes per pixel
	uint getBytesPerPixel();

	/// Returns image data size in bytes
	uint getImageDataSizeInBytes();

	/// Returns image data size in pixels
	uint getImageDataSizeInPixels();

	/// Returns a pixel
	SColor getPixe(uint x, uint y);

	/// Sets a pixel
	void setPixel(uint x, uint y, const SColor color, bool blend = false);

	/// Retuns the color format
	ECOLOR_FORMAT getColorFormat();

	/// Returns mask for red value of a pixel
	uint getRedMask();

	/// Returns mask for green value of a pixel
	uint getGreenMask();

	/// Returns mask for blue value of a pixel
	uint getBlueMask();

	/// Returns mask for alpha value of a pixel
	uint getAlphaMask();

	/// Returns pitch of image
	uint getPitch();

	/// Copies the image into the target, scaling the image to fit
	void copyToScaling(void* target, uint width, uint height, ECOLOR_FORMAT format = ECOLOR_FORMAT.ECF_A8R8G8B8, uint pitch = 0);

	/// Copies the image into the target, scaling the image to fit
	void copyToScaling(IImage target);

	/// Copies this surface into another
	void copyTo(IImage target, const vector2d!int pos = vector2d!int(0,0));

	/// Copies this surface into another
	void copyTo(IImage target, const vector2d!int pos, const rect!int sourceRect, const (rect!int)* clipRect = null);

	/// Copies this surface into another, using the alpha mask and cliprect and a color to add with
	void copyToWithAlpha(IImage target, const vector2d!int pos,
		rect!int sourceRect, const SColor color,
		const (rect!int)* clipRect = null);

	/// Copies this surface into another, scaling it to fit, appyling a box filter
	void copyToScalingBoxFilter(IImage target, int bias = 0, bool blend = false);

	/// Fills the surface with given color
	void fill(const SColor color);

	/// get the amount of Bits per Pixel of the given color format
	static final uint getBitsPerPixelFromFormat(const ECOLOR_FORMAT format)
	{
		final switch(format)
		{
			case ECOLOR_FORMAT.ECF_A1R5G5B5:
				return 16u;
			case ECOLOR_FORMAT.ECF_R5G6B5:
				return 16u;
			case ECOLOR_FORMAT.ECF_R8G8B8:
				return 24u;
			case ECOLOR_FORMAT.ECF_A8R8G8B8:
				return 32u;
			case ECOLOR_FORMAT.ECF_R16F:
				return 16u;
			case ECOLOR_FORMAT.ECF_G16R16F:
				return 32u;
			case ECOLOR_FORMAT.ECF_A16B16G16R16F:
				return 64u;
			case ECOLOR_FORMAT.ECF_R32F:
				return 32u;
			case ECOLOR_FORMAT.ECF_G32R32F:
				return 64u;
			case ECOLOR_FORMAT.ECF_A32B32G32R32F:
				return 128u;
			case ECOLOR_FORMAT.ECF_UNKNOWN:
				return 0u;
		}
	}

	/// test if the color format is only viable for RenderTarget textures
	/**
	* Since we don't have support for e.g. floating point IImage formats
	* one should test if the color format can be used for arbitrary usage, or
	* if it is restricted to RTTs.
	*/
	static final bool isRenderTargetOnlyFormat(const ECOLOR_FORMAT format)
	{
		switch(format)
		{
			case ECOLOR_FORMAT.ECF_A1R5G5B5:
			case ECOLOR_FORMAT.ECF_R5G6B5:
			case ECOLOR_FORMAT.ECF_R8G8B8:
			case ECOLOR_FORMAT.ECF_A8R8G8B8:
				return false;
			default:
				return true;
		}
	}
}