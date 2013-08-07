// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.io.IAttributeExchangingObject;

import irrlicht.io.IAttributes;

/// Enumeration flags passed through SAttributeReadWriteOptions to the IAttributeExchangingObject object
enum E_ATTRIBUTE_READ_WRITE_FLAGS
{
	/// Serialization/Deserializion is done for an xml file
	EARWF_FOR_FILE = 0x00000001,

	/// Serialization/Deserializion is done for an editor property box
	EARWF_FOR_EDITOR = 0x00000002,

	/// When writing filenames, relative paths should be used
	EARWF_USE_RELATIVE_PATHS = 0x00000004
};


/// struct holding data describing options
struct SAttributeReadWriteOptions
{
	/// Combination of E_ATTRIBUTE_READ_WRITE_FLAGS or other, custom ones
	int Flags;

	/// Optional filename
	string Filename;
}


/// An object which is able to serialize and deserialize its attributes into an attributes object
interface IAttributeExchangingObject
{
	/// Writes attributes of the object.
	/** 
	* Implement this to expose the attributes of your scene node animator for
	* scripting languages, editors, debuggers or xml serialization purposes. 
	*/
	void serializeAttributes(out IAttributes outAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions()) const;

	/// Reads attributes of the object.
	/** 
	* Implement this to set the attributes of your scene node animator for
	* scripting languages, editors, debuggers or xml deserialization purposes. 
	*/
	void deserializeAttributes(IAttributes inAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions());
}