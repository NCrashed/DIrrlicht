module irrlicht.video.IVideoModeList;

/// A list of all available video modes.
/** 
*You can get a list via IrrlichtDevice::getVideoModeList(). If you are confused
*now, because you think you have to create an Irrlicht Device with a video
*mode before being able to get the video mode list, let me tell you that
*there is no need to start up an Irrlicht Device with EDT_DIRECT3D8, EDT_OPENGL or
*EDT_SOFTWARE: For this (and for lots of other reasons) the null device,
*EDT_NULL exists.
*/

import irrlicht.IReferenceCounted;
import irrlicht.core.dimension2d;

class IVideoModeList : IReferenceCounted
{
	/// Gets amount of video modes in the list.
	/** 
	*Returns: Returns amount of video modes. 
	*/
	int getVideoModeCount();
	
	/// Get the screen size of a video mode in pixels.
	/** 
	*Params:
	*	modeNumber= zero based index of the video mode.
	*Returns: Size of screen in pixels of the specified video mode. 
	*/
	dimension2d!uint getVideoModeResolution(int modeNumber);
	
	/// Get a supported screen size with certain constraints.
	/**
	*Params: 
	*	minSize= Minimum dimensions required.
	*	maxSize= Maximum dimensions allowed.
	*Returns: Size of screen in pixels which matches the requirements.
	as good as possible. */
	dimension2d!uint getVideoModeResolution(const ref dimension2d!uint minSize, 
		const ref dimension2d!uint maxSize);
	
	/// Get the pixel depth of a video mode in bits.
	/**
	*Params: 
	*	modeNumber= zero based index of the video mode.
	*Returns: Size of each pixel of the specified video mode in bits. 
	*/
	int getVideoModeDepth(int modeNumber);
	
	/// Get current desktop screen resolution.
	/** 
	*Returns: Size of screen in pixels of the current desktop video mode. 
	*/
	const dimension2d!uint getDesktopResolution();
	
	/// Get the pixel depth of a video mode in bits.
	/** 
	*Returns: Size of each pixel of the current desktop video mode in bits. 
	*/
	int getDesktopDepth();
}