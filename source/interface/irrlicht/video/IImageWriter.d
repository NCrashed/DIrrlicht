// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IImageWriter;

import irrlicht.io.IWriteFile;
import irrlicht.video.IImage;
import irrlicht.io.path;

/// Interface for writing software image data.
interface IImageWriter
{
	/// Check if this writer can write a file with the given extension
	/**
	* Params:
	* 	filename=  Name of the file to check.
	* Returns: True if file extension specifies a writable type. 
	*/
	bool isAWriteableFileExtension(const Path filename) const;

	/// Write image to file
	/**
	* Params:
	* 	file=  File handle to write to.
	* 	image=  Image to write into file.
	* 	param=  Writer specific parameter, influencing e.g. quality.
	* Returns: True if image was successfully written. 
	*/
	bool writeImage(IWriteFile file, IImage image, uint param = 0) const;
}
