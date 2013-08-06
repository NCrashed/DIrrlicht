// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IAttributes;

import irrlicht.video.SColor;
import irrlicht.video.ITexture;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.core.aabbox3d;
import irrlicht.core.line2d;
import irrlicht.core.line3d;
import irrlicht.core.position2d;
import irrlicht.core.triangle3d;
import irrlicht.core.rect;
import irrlicht.core.dimension2d;
import irrlicht.core.matrix4;
import irrlicht.core.quaternion;
import irrlicht.core.plane3d;
import irrlicht.core.irrArray;
import irrlicht.io.IXMLReader;
import irrlicht.io.IXMLWriter;
import irrlicht.io.EAttributes;
import std.traits;

/// Provides a generic interface for attributes and their values and the possiblity to serialize them
interface IAttributes 
{
	/// Returns amount of attributes in this collection of attributes.
	size_t getAttributeCount() const;

	/// Returns attribute name by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	string getAttributeName(size_t index);

	/// Returns the type of an attribute
	/**
	* Params:
	* 	attributeName=  Name for the attribute 
	*/
	E_ATTRIBUTE_TYPE getAttributeType(string attributeName);

	/// Returns attribute type by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	E_ATTRIBUTE_TYPE getAttributeType(size_t index);

	/// Returns the type string of the attribute
	/**
	* Params:
	* 	attributeName=  String for the attribute type 
	*/
	string getAttributeTypeString(string attributeName);

	/// Returns the type string of the attribute by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	string getAttributeTypeString(size_t index);

	/// Returns if an attribute with a name exists
	bool existsAttribute(string attributeName);

	/// Returns attribute index from name, -1 if not found
	int findAttribute(string attributeName) const;

	/// Removes all attributes
	void clear();

	/// Reads attributes from a xml file.
	/**
	* Params:
	* 	reader=  The XML reader to read from
	* 	readCurrentElementOnly=  If set to true, reading only works if current element has the name 'attributes' or
	* the name specified using elementName.
	* 	elementName=  The surrounding element name. If it is null, the default one, "attributes" will be taken.
	* If set to false, the first appearing list of attributes are read. 
	*/
	bool read(IXMLReader reader, bool readCurrentElementOnly = false, string elementName = "");

	/// Write these attributes into a xml file
	/**
	* Params: 
	* writer = The XML writer to write to
	* writeXMLHeader = Writes a header to the XML file, required if at the beginning of the file
	* elementName = The surrounding element name. If it is null, the default one, "attributes" will be taken.
	*/
	bool write(IXMLWriter writer, bool writeXMLHeader = false, string elementName = "");

	// Base attribute setting
	/*
	* Implementation should support following types:
	* - POD types (int, long, uint, ulong, float, double, bool and other)
	* - string and wstring
	* - void[] arrays
	* - stringw[] arrays 
	* - POD types arrays
	* - SColor and SColorf
	* - vector3d and vector2d
	* - rect
	* - dimenstion2d
	* - matrix4
	* - quaternion
	* - aabbox3d
	* - plane3d
	* - triangle3d
	* - line3d and line2d
	* - ITexture
	* - Enums with string literals
	* - User pointer void*
	*/

	/// Adds an attribute as Type
	void add(Type)(string attributeName, Type value);

	/// Sets an attribute as Type value
	void setAttribute(Type)(string attributeName, Type value);

	/// Sets an attribute as Type value
	void setAttribute(Type)(size_t index, Type value);

	/// Gets an attribute as integer value
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	Type getAttribute(Type)(string attributeName) const;

	/// Gets an attribute as Type value
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	Type getAttribute(Type)(size_t index) const;


	/// Gets an attribute as string.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	target=  Buffer where the string is copied to. 
	*/
	void getAttribute(Type)(string attributeName, out Type target)
		if(isSomeString!Type);

	/*

		Enumeration Attribute

	*/

	/// Adds an attribute as enum
	void addEnum(string attributeName, string enumValue, immutable(string[]) enumerationLiterals);

	/// Adds an attribute as enum
	void addEnum(string attributeName, int enumValue, immutable(string[]) enumerationLiterals);

	/// Sets an attribute as enumeration
	void setAttribute()(string attributeName, string enumValue, immutable(string[]) enumerationLiterals);

	/// Gets an attribute as enumeration
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	string getAttributeAsEnumeration(string attributeName);

	/// Gets an attribute as enumeration
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	enumerationLiteralsToUse=  Use these enumeration literals to get
	* the index value instead of the set ones. This is useful when the
	* attribute list maybe was read from an xml file, and only contains the
	* enumeration string, but no information about its index.
	* Returns: Returns value of the attribute previously set by setAttribute()
	*/
	int getAttributeAsEnumeration(string attributeName, immutable(string[]) enumerationLiteralsToUse);

	/// Gets an attribute as enumeration
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	* 	enumerationLiteralsToUse=  Use these enumeration literals to get
	* the index value instead of the set ones. This is useful when the
	* attribute list maybe was read from an xml file, and only contains the
	* enumeration string, but no information about its index.
	* Returns: Returns value of the attribute previously set by setAttribute()
	*/
	int getAttributeAsEnumeration(size_t index, immutable(string[]) enumerationLiteralsToUse);

	/// Gets an attribute as enumeration
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	string getAttributeAsEnumeration(size_t index);

	/// Gets the list of enumeration literals of an enumeration attribute
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	outLiterals=  Set of strings to choose the enum name from. 
	*/
	void getAttributeEnumerationLiteralsOfEnumeration(string attributeName, out string[] outLiterals);

	/// Gets the list of enumeration literals of an enumeration attribute
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	* 	outLiterals=  Set of strings to choose the enum name from. 
	*/
	void getAttributeEnumerationLiteralsOfEnumeration(size_t index, out string[] outLiterals);

	/// Sets an attribute as enumeration
	void setAttribute()(size_t index, string enumValue, immutable(string[]) enumerationLiterals);


	/*

		Texture Attribute

	*/

	/// Adds an attribute as texture reference
	void add(Type)(string attributeName, Type texture, string filename = "")
		if(is(Type == ITexture));

	/// Sets an attribute as texture reference
	void setAttribute(Type)(string attributeName, Type texture, string filename = "")
		if(is(Type == ITexture));

	/// Sets an attribute as texture reference
	void setAttribute(Type)(size_t index, Type texture, string filename = "")
		if(is(Type == ITexture));

}
