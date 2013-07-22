// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IWriteFile;

import irrlicht.io.path;
import irrlicht.IReferenceCounted;

interface IWriteFile //: IReferenceCounted
{
	/// Writes an amount of bytes to the file.
	/** 
	* Params:
	* buffer 		Pointer to buffer of bytes to write.
	* sizeToWrite 	Amount of bytes to write to the file.
	*
	* Returns: How much bytes were written. 
	*/
	int write(const void* buffer, uint sizeToWrite);

	/// Changes position in file
	/**
	* Params: 
	* finalPos 			Destination position in the file.
	* relativeMovement 	If set to true, the position in the file is
	* changed relative to current position. Otherwise the position is changed
	* from begin of file.
	*
	* Returns: True if successful, otherwise false. 
	*/
	bool seek(long finalPos, bool relativeMovement = false);

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