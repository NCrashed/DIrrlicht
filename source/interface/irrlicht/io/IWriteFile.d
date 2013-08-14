// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.io.IWriteFile;

import irrlicht.io.path;

interface IWriteFile
{
	/// Writes an amount of bytes to the file.
	/** 
	* Params:
	* buffer 		Pointer to buffer of bytes to write.
	* sizeToWrite 	Amount of bytes to write to the file.
	*
	* Returns: How much bytes were written. 
	*/
	int write(const void* buffer, size_t sizeToWrite);

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
	bool seek(ulong finalPos, bool relativeMovement = false);

	/// Get the current position in the file.
	/** 
	* Returns: Current position in the file in bytes. 
	*/
	ulong getPos();

	/// Get name of file.
	/** 
	* Returns: File name as zero terminated character string. 
	*/
	const Path getFileName();
}