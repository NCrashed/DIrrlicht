// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.IImageLoader;

import irrlicht.video.IImage;
import irrlicht.io.IReadFile;
import irrlicht.io.path;


/// Class which is able to create a image from a file.
/**
* If you want the Irrlicht Engine be able to load textures of
* currently unsupported file formats (e.g .gif), then implement
* this and add your new Surface loader with
* IVideoDriver::addExternalImageLoader() to the engine. 
*/
interface IImageLoader 
{
	/// Check if the file might be loaded by this class
	/**
	* Check is based on the file extension (e.g. ".tga")
	* Params:
	* 	filename=  Name of file to check.
	* Returns: True if file seems to be loadable. 
	*/
	bool isALoadableFileExtension(const Path filename) const;

	/// Check if the file might be loaded by this class
	/**
	* Check might look into the file.
	* Params:
	* 	file=  File handle to check.
	* Returns: True if file seems to be loadable. 
	*/
	bool isALoadableFileFormat(IReadFile file) const;

	/// Creates a surface from the file
	/**
	* Params:
	* 	file=  File handle to check.
	* Returns: Pointer to newly created image, or 0 upon error. 
	*/
	IImage loadImage(IReadFile file) const;
}
