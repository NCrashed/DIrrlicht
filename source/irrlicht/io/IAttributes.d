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

/// Provides a generic interface for attributes and their values and the possiblity to serialize them
interface IAttributes 
{
	/// Returns amount of attributes in this collection of attributes.
	uint getAttributeCount() const;

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
	/// \param writer: The XML writer to write to
	/// \param writeXMLHeader: Writes a header to the XML file, required if at the beginning of the file
	/// \param elementName: The surrounding element name. If it is null, the default one, "attributes" will be taken.
	bool write(IXMLWriter writer, bool writeXMLHeader = false, string elementName = "");

	/*

		Integer Attribute

	*/

	/// Adds an attribute as integer
	void addInt(string attributeName, int value);

	/// Sets an attribute as integer value
	void setAttribute(string attributeName, int value);

	/// Gets an attribute as integer value
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	int getAttributeAsInt(string attributeName) const;

	/// Gets an attribute as integer value
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	int getAttributeAsInt(size_t index) const;

	/// Sets an attribute as integer value
	void setAttribute(size_t index, int value);

	/*

		Float Attribute

	*/

	/// Adds an attribute as float
	void addFloat(string attributeName, float value);

	/// Sets a attribute as float value
	void setAttribute(string attributeName, float value);

	/// Gets an attribute as float value
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	float getAttributeAsFloat(string attributeName);

	/// Gets an attribute as float value
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	float getAttributeAsFloat(size_t index);

	/// Sets an attribute as float value
	void setAttribute(size_t index, float value);

	/*

		String Attribute

	*/

	/// Adds an attribute as string
	void addString(string attributeName, string value);

	/// Sets an attribute value as string.
	/**
	* Params:
	* 	attributeName=  Name for the attribute
	* 	value=  Value for the attribute. Set this to 0 to delete the attribute 
	*/
	void setAttribute(string attributeName, string value);

	/// Gets an attribute as string.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute()
	* or 0 if attribute is not set. 
	*/
	string getAttributeAsString(string attributeName);

	/// Gets an attribute as string.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	target=  Buffer where the string is copied to. 
	*/
	void getAttributeAsString(string attributeName, out char[] target);

	/// Returns attribute value as string by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	string getAttributeAsString(size_t index);

	/// Sets an attribute value as string.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	* 	value=  String to which the attribute is set. 
	*/
	void setAttribute(size_t index, string value);

	// wide strings

	/// Adds an attribute as string
	void addString(string attributeName, wstring value);

	/// Sets an attribute value as string.
	/**
	* Params:
	* 	attributeName=  Name for the attribute
	* 	value=  Value for the attribute. Set this to 0 to delete the attribute 
	*/
	void setAttribute(string attributeName, wstring value);

	/// Gets an attribute as string.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute()
	* or 0 if attribute is not set. 
	*/
	wstring getAttributeAsStringW(string attributeName);

	/// Gets an attribute as string.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	target=  Buffer where the string is copied to. 
	*/
	void getAttributeAsStringW(string attributeName, out wchar[] target);

	/// Returns attribute value as string by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	*/
	wstring getAttributeAsStringW(size_t index);

	/// Sets an attribute value as string.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	* \\param value String to which the attribute is set. 
	*/
	void setAttribute(size_t index, wstring value);

	/*

		Binary Data Attribute

	*/

	/// Adds an attribute as binary data
	void addBinary(string attributeName, void[] data);

	/// Sets an attribute as binary data
	void setAttribute(string attributeName, void[] data);

	/// Gets an attribute as binary data
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* 	outData=  Pointer to buffer where data shall be stored.
	* 	maxSizeInBytes=  Maximum number of bytes to write into outData.
	*/
	void getAttributeAsBinaryData(string attributeName, void[] outData);

	/// Gets an attribute as binary data
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1.
	* 	outData=  Pointer to buffer where data shall be stored.
	* 	maxSizeInBytes=  Maximum number of bytes to write into outData.
	*/
	void getAttributeAsBinaryData(size_t index, void[] outData);

	/// Sets an attribute as binary data
	void setAttribute(size_t index, void[] data);

	/*
		Array Attribute
	*/

	/// Adds an attribute as wide string array
	void addArray(string attributeName, const wstring[] value);

	/// Sets an attribute value as a wide string array.
	/**
	* Params:
	* 	attributeName=  Name for the attribute
	* 	value=  Value for the attribute. Set this to 0 to delete the attribute 
	*/
	void setAttribute(string attributeName, const wstring[] value);

	/// Gets an attribute as an array of wide strings.
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute()
	* or 0 if attribute is not set. 
	*/
	wstring[] getAttributeAsArray(string attributeName);

	/// Returns attribute value as an array of wide strings by index.
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	wstring[] getAttributeAsArray(size_t index);

	/// Sets an attribute as an array of wide strings
	void setAttribute(size_t index, const wstring[] value);


	/*

		Bool Attribute

	*/

	/// Adds an attribute as bool
	void addBool(string attributeName, bool value);

	/// Sets an attribute as boolean value
	void setAttribute(string attributeName, bool value);

	/// Gets an attribute as boolean value
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	bool getAttributeAsBool(string attributeName);

	/// Gets an attribute as boolean value
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	bool getAttributeAsBool(size_t index);

	/// Sets an attribute as boolean value
	void setAttribute(size_t index, bool value);

	/*

		Enumeration Attribute

	*/

	/// Adds an attribute as enum
	void addEnum(string attributeName, string enumValue, const(string[]) enumerationLiterals);

	/// Adds an attribute as enum
	void addEnum(string attributeName, int enumValue, const(string[]) enumerationLiterals);

	/// Sets an attribute as enumeration
	void setAttribute(string attributeName, string enumValue, const(string[]) enumerationLiterals);

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
	int getAttributeAsEnumeration(string attributeName, const(string[]) enumerationLiteralsToUse);

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
	int getAttributeAsEnumeration(size_t index, const(string[]) enumerationLiteralsToUse);

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
	void setAttribute(size_t index, string enumValue, const(string[]) enumerationLiterals);


	/*

		SColor Attribute

	*/

	/// Adds an attribute as color
	void addColor(string attributeName, SColor value);


	/// Sets a attribute as color
	void setAttribute(string attributeName, SColor color);

	/// Gets an attribute as color
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	SColor getAttributeAsColor(string attributeName);

	/// Gets an attribute as color
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	SColor getAttributeAsColor(size_t index);

	/// Sets an attribute as color
	void setAttribute(size_t index, SColor color);

	/*

		SColorf Attribute

	*/

	/// Adds an attribute as floating point color
	void addColorf(string attributeName, SColorf value);

	/// Sets a attribute as floating point color
	void setAttribute(string attributeName, SColorf color);

	/// Gets an attribute as floating point color
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	SColorf getAttributeAsColorf(string attributeName);

	/// Gets an attribute as floating point color
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	SColorf getAttributeAsColorf(size_t index);

	/// Sets an attribute as floating point color
	void setAttribute(size_t index, SColorf color);


	/*

		Vector3d Attribute

	*/

	/// Adds an attribute as 3d vector
	void addVector3d(string attributeName, vector3df value);

	/// Sets a attribute as 3d vector
	void setAttribute(string attributeName, vector3df v);

	/// Gets an attribute as 3d vector
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	vector3df getAttributeAsVector3d(string attributeName);

	/// Gets an attribute as 3d vector
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	vector3df getAttributeAsVector3d(size_t index);

	/// Sets an attribute as vector
	void setAttribute(size_t index, vector3df v);

	/*

		Vector2d Attribute

	*/

	/// Adds an attribute as 2d vector
	void addVector2d(string attributeName, vector2df value);

	/// Sets a attribute as 2d vector
	void setAttribute(string attributeName, vector2df v);

	/// Gets an attribute as vector
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	vector2df getAttributeAsVector2d(string attributeName);

	/// Gets an attribute as position
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	vector2df getAttributeAsVector2d(size_t index);

	/// Sets an attribute as 2d vector
	void setAttribute(size_t index, vector2df v);

	/*

		Position2d Attribute

	*/

	/// Adds an attribute as 2d position
	deprecated void addPosition2d(string attributeName, position2di value);

	/// Sets a attribute as 2d position
	deprecated void setAttribute(string attributeName, position2di v);

	/// Gets an attribute as position
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	deprecated position2di getAttributeAsPosition2d(string attributeName);

	/// Gets an attribute as position
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	deprecated position2di getAttributeAsPosition2d(size_t index);

	/// Sets an attribute as 2d position
	deprecated void setAttribute(size_t index, position2di v);

	/*

		Rectangle Attribute

	*/

	/// Adds an attribute as rectangle
	void addRect(string attributeName, rect!int value);

	/// Sets an attribute as rectangle
	void setAttribute(string attributeName, rect!int v);

	/// Gets an attribute as rectangle
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	rect!int getAttributeAsRect(string attributeName);

	/// Gets an attribute as rectangle
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	rect!int getAttributeAsRect(size_t index);

	/// Sets an attribute as rectangle
	void setAttribute(size_t index, rect!int v);


	/*

		Dimension2d Attribute

	*/

	/// Adds an attribute as dimension2d
	void addDimension2d(string attributeName, dimension2d!uint value);

	/// Sets an attribute as dimension2d
	void setAttribute(string attributeName, dimension2d!uint v);

	/// Gets an attribute as dimension2d
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	dimension2d!uint getAttributeAsDimension2d(string attributeName);

	/// Gets an attribute as dimension2d
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	dimension2d!uint getAttributeAsDimension2d(size_t index);

	/// Sets an attribute as dimension2d
	void setAttribute(size_t index, dimension2d!uint v);


	/*
		matrix attribute
	*/

	/// Adds an attribute as matrix
	void addMatrix(string attributeName, const matrix4 v);

	/// Sets an attribute as matrix
	void setAttribute(string attributeName, const matrix4 v);

	/// Gets an attribute as a matrix4
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	matrix4 getAttributeAsMatrix(string attributeName);

	/// Gets an attribute as matrix
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	matrix4 getAttributeAsMatrix(size_t index);

	/// Sets an attribute as matrix
	void setAttribute(size_t index, const matrix4 v);

	/*
		quaternion attribute

	*/

	/// Adds an attribute as quaternion
	void addQuaternion(string attributeName, quaternion v);

	/// Sets an attribute as quaternion
	void setAttribute(string attributeName, quaternion v);

	/// Gets an attribute as a quaternion
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	quaternion getAttributeAsQuaternion(string attributeName);

	/// Gets an attribute as quaternion
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	quaternion getAttributeAsQuaternion(size_t index);

	/// Sets an attribute as quaternion
	void setAttribute(size_t index, quaternion v);

	/*

		3d bounding box

	*/

	/// Adds an attribute as axis aligned bounding box
	void addBox3d(string attributeName, aabbox3df v);

	/// Sets an attribute as axis aligned bounding box
	void setAttribute(string attributeName, aabbox3df v);

	/// Gets an attribute as a axis aligned bounding box
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	aabbox3df getAttributeAsBox3d(string attributeName);

	/// Gets an attribute as axis aligned bounding box
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	aabbox3df getAttributeAsBox3d(size_t index);

	/// Sets an attribute as axis aligned bounding box
	void setAttribute(size_t index, aabbox3df v);

	/*

		plane

	*/

	/// Adds an attribute as 3d plane
	void addPlane3d(string attributeName, plane3df v);

	/// Sets an attribute as 3d plane
	void setAttribute(string attributeName, plane3df v);

	/// Gets an attribute as a 3d plane
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	plane3df getAttributeAsPlane3d(string attributeName);

	/// Gets an attribute as 3d plane
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	plane3df getAttributeAsPlane3d(size_t index);

	/// Sets an attribute as 3d plane
	void setAttribute(size_t index, plane3df v);


	/*

		3d triangle

	*/

	/// Adds an attribute as 3d triangle
	void addTriangle3d(string attributeName, triangle3df v);

	/// Sets an attribute as 3d trianle
	void setAttribute(string attributeName, triangle3df v);

	/// Gets an attribute as a 3d triangle
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	triangle3df getAttributeAsTriangle3d(string attributeName);

	/// Gets an attribute as 3d triangle
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	triangle3df getAttributeAsTriangle3d(size_t index);

	/// Sets an attribute as 3d triangle
	void setAttribute(size_t index, triangle3df v);


	/*

		line 2d

	*/

	/// Adds an attribute as a 2d line
	void addLine2d(string attributeName, line2df v);

	/// Sets an attribute as a 2d line
	void setAttribute(string attributeName, line2df v);

	/// Gets an attribute as a 2d line
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	line2df getAttributeAsLine2d(string attributeName);

	/// Gets an attribute as a 2d line
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	line2df getAttributeAsLine2d(size_t index);

	/// Sets an attribute as a 2d line
	void setAttribute(size_t index, line2df v);


	/*

		line 3d

	*/

	/// Adds an attribute as a 3d line
	void addLine3d(string attributeName, line3df v);

	/// Sets an attribute as a 3d line
	void setAttribute(string attributeName, line3df v);

	/// Gets an attribute as a 3d line
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get.
	* Returns: Returns value of the attribute previously set by setAttribute() 
	*/
	line3df getAttributeAsLine3d(string attributeName);

	/// Gets an attribute as a 3d line
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	line3df getAttributeAsLine3d(size_t index);

	/// Sets an attribute as a 3d line
	void setAttribute(size_t index, line3df v);


	/*

		Texture Attribute

	*/

	/// Adds an attribute as texture reference
	void addTexture(string attributeName, ITexture texture, string filename = "");

	/// Sets an attribute as texture reference
	void setAttribute(string attributeName, ITexture texture, string filename = "");

	/// Gets an attribute as texture reference
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get. 
	*/
	ITexture getAttributeAsTexture(string attributeName);

	/// Gets an attribute as texture reference
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	ITexture getAttributeAsTexture(size_t index);

	/// Sets an attribute as texture reference
	void setAttribute(size_t index, ITexture texture, string filename = "");


	/*

		User Pointer Attribute

	*/

	/// Adds an attribute as user pointner
	void addUserPointer(string attributeName, void* userPointer);

	/// Sets an attribute as user pointer
	void setAttribute(string attributeName, void* userPointer);

	/// Gets an attribute as user pointer
	/**
	* Params:
	* 	attributeName=  Name of the attribute to get. 
	*/
	void* getAttributeAsUserPointer(string attributeName);

	/// Gets an attribute as user pointer
	/**
	* Params:
	* 	index=  Index value, must be between 0 and getAttributeCount()-1. 
	*/
	void* getAttributeAsUserPointer(size_t index);

	/// Sets an attribute as user pointer
	void setAttribute(size_t index, void* userPointer);

}
