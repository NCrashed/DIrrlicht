// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IReadFile;

//import irrlicht.IReferenceCounted;
import irrlicht.io.path;

/// Interface providing read acess to a file
interface IReadFile //: IReferenceCounted
{
	/// Reads an amount of bytes from the file.
	/**
	* Params:
	* buffer 		Pointer to buffer where read bytes are written to.
	* sizeToRead 	Amount of bytes to read from the file.
	*
	* Returns: How many bytes were read. 
	*/
	int read(void* buffer, uint sizeToRead);

	/// Changes position in file
	/**
	* Params: 
	* finalPos 			Destination position in the file.
	* relativeMovement 	If set to true, the position in the file is
	* changed relative to current position. Otherwise the position is changed
	* from beginning of file.
	*
	* Returns: True if successful, otherwise false. 
	*/
	bool seek(long finalPos, bool relativeMovement = false);

	/// Get size of file.
	/** 
	* Returns: Size of the file in bytes. 
	*/
	long getSize();

	/// Get the current position in the file.
	/** 
	* Returns: Current position in the file in bytes. 
	*/
	long getPos();

	/// Get name of file.
	/** 
	* Returns: File name as zero terminated character string. 
	*/
	const Path getFileName();
}

/// Internal function, please do not use
IReadFile createReadFile(const Path fileName);

/// Internal function, please do not use
IReadFile createLimitReadFile(const Path fileName, IReadFile alreadyOpenedFile, long pos, long areaSize);

//! Internal function, please do not use.
IReadFile createMemoryReadFile(void* memory, long size, const Path fileName, bool deleteMemoryWhenDropped);