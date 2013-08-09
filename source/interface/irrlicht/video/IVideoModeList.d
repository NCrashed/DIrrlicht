// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IVideoModeList;

import irrlicht.core.dimension2d;

/// A list of all available video modes.
/** 
* You can get a list via IrrlichtDevice::getVideoModeList(). If you are confused
* now, because you think you have to create an Irrlicht Device with a video
* mode before being able to get the video mode list, let me tell you that
* there is no need to start up an Irrlicht Device with EDT_DIRECT3D8, EDT_OPENGL or
* EDT_SOFTWARE: For this (and for lots of other reasons) the null device,
* EDT_NULL exists.
*/
interface IVideoModeList
{
	/// Gets amount of video modes in the list.
	/** 
	* Returns: Returns amount of video modes. 
	*/
	size_t getVideoModeCount() const;
	
	/// Get the screen size of a video mode in pixels.
	/** 
	* Params:
	*	modeNumber= zero based index of the video mode.
	* Returns: Size of screen in pixels of the specified video mode. 
	*/
	dimension2d!uint getVideoModeResolution()(size_t modeNumber) const;
	
	/// Get a supported screen size with certain constraints.
	/**
	* Params: 
	*	minSize= Minimum dimensions required.
	*	maxSize= Maximum dimensions allowed.
	* Returns: Size of screen in pixels which matches the requirements.
	* as good as possible. 
	*/
	dimension2d!uint getVideoModeResolution()(auto ref const dimension2d!uint minSize, 
		auto ref const dimension2d!uint maxSize) const;
	
	/// Get the pixel depth of a video mode in bits.
	/**
	* Params: 
	*	modeNumber= zero based index of the video mode.
	* Returns: Size of each pixel of the specified video mode in bits. 
	*/
	int getVideoModeDepth(size_t modeNumber) const;
	
	/// Get current desktop screen resolution.
	/** 
	* Returns: Size of screen in pixels of the current desktop video mode. 
	*/
	auto ref const dimension2d!uint getDesktopResolution()() const;
	
	/// Get the pixel depth of a video mode in bits.
	/** 
	* Returns: Size of each pixel of the current desktop video mode in bits. 
	*/
	int getDesktopDepth() const;
}