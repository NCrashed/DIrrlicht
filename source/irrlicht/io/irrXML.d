// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" and the "irrXML" project.
// For conditions of distribution and use, see copyright notice in irrlicht.h and/or irrXML.h
/** \mainpage irrXML 1.2 API documentation
 <div align="center"><img src="logobig.png" ></div>

 \section intro Introduction

  Welcome to the irrXML API documentation.
  Here you'll find any information you'll need to develop applications with
  irrXML. If you look for a tutorial on how to start, take a look at the \ref irrxmlexample,
  at the homepage of irrXML at <A HREF="http://www.ambiera.com/irrxml/">www.ambiera.com/irrxml/</A>
  or into the SDK in the directory example.

  irrXML is intended to be a high speed and easy-to-use XML Parser for C++, and
  this documentation is an important part of it. If you have any questions or
  suggestions, just send a email to the author of the engine, Nikolaus Gebhardt
  (niko (at) irrlicht3d.org). For more informations about this parser, see \ref history.

  \section features Features

  irrXML provides forward-only, read-only
     access to a stream of non validated XML data. It was fully implemented by
	Nikolaus Gebhardt. Its current features are:

	- It it fast as lighting and has very low memory usage. It was
	developed with the intention of being used in 3D games, as it already has been.
	- irrXML is very small: It only consists of 60 KB of code and can be added easily
	to your existing project.
	- Of course, it is platform independent and works with lots of compilers.
	- It is able to parse ASCII, UTF-8, UTF-16 and UTF-32 text files, both in
	little and big endian format.
	- Independent of the input file format, the parser can return all strings in ASCII, UTF-8,
	UTF-16 and UTF-32 format.
	- With its optional file access abstraction it has the advantage that it can read not
	only from files but from any type of data (memory, network, ...). For example when
	used with the Irrlicht Engine, it directly reads from compressed .zip files.
	- Just like the Irrlicht Engine for which it was originally created, it is extremely easy
	to use.
	- It has no external dependencies, it does not even need the STL.

	Although irrXML has some strenghts, it currently also has the following limitations:

	- The input xml file is not validated and assumed to be correct.

    \section irrxmlexample Example

    The following code demonstrates the basic usage of irrXML. A simple xml
	file like this is parsed:
    \code
	<?xml version="1.0"?>
	<config>
		<!-- This is a config file for the mesh viewer -->
		<model file="dwarf.dea" />
		<messageText caption="Irrlicht Engine Mesh Viewer">
		Welcome to the Mesh Viewer of the &quot;Irrlicht Engine&quot;.
		</messageText>
	</config>
	\endcode

	The code for parsing this file would look like this:
	\code
	#include <irrXML.h>
	using namespace irr; // irrXML is located in the namespace irr.io
	using namespace io;

	#include <string> // we use STL strings to store data in this example

	void main()
	{
		// create the reader using one of the factory functions

		IrrXMLReader* xml = createIrrXMLReader("config.xml");

		// strings for storing the data we want to get out of the file
		std.string modelFile;
		std.string messageText;
		std.string caption;

		// parse the file until end reached

		while(xml && xml->read())
		{
			switch(xml->getNodeType())
			{
			case EXN_TEXT:
				// in this xml file, the only text which occurs is the messageText
				messageText = xml->getNodeData();
				break;
			case EXN_ELEMENT:
				{
					if (!strcmp("model", xml->getNodeName()))
						modelFile = xml->getAttributeValue("file");
					else
					if (!strcmp("messageText", xml->getNodeName()))
						caption = xml->getAttributeValue("caption");
				}
				break;
			}
		}

		// drop the xml parser after usage
		drop xml;
	}
	\endcode

	\section howto How to use

	Simply add the source files in the /src directory of irrXML to your project. Done.

	\section license License

	The irrXML license is based on the zlib license. Basicly, this means you can do with
	irrXML whatever you want:

	Copyright (C) 2002-2012 Nikolaus Gebhardt

	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
		claim that you wrote the original software. If you use this software
		in a product, an acknowledgment in the product documentation would be
		appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and must not be
		misrepresented as being the original software.

	3. This notice may not be removed or altered from any source distribution.

	\section history History

	As lots of references in this documentation and the source show, this xml
	parser has originally been a part of the
	<A HREF="http://irrlicht.sourceforge.net" >Irrlicht Engine</A>. But because
	the parser has become very useful with the latest release, people asked for a
	separate version of it, to be able to use it in non Irrlicht projects. With
	irrXML 1.0, this has now been done.
*/
module irrlicht.irrXML;

import std.stream;
import std.utf;
import std.traits;
import std.stdio;
import std.typetuple;

/// Enumeration of all supported source text file formats
enum ETEXT_FORMAT
{
	/// ASCII, file without byte order mark, or not a text file
	ETF_ASCII,

	/// UTF-8 format
	ETF_UTF8,

	/// UTF-16 format, big endian
	ETF_UTF16_BE,

	/// UTF-16 format, little endian
	ETF_UTF16_LE,

	/// UTF-32 format, big endian
	ETF_UTF32_BE,

	/// UTF-32 format, little endian
	ETF_UTF32_LE
}

/// Enumeration for all xml nodes which are parsed by IrrXMLReader
enum EXML_NODE
{
	/// No xml node. This is usually the node if you did not read anything yet.
	EXN_NONE,

	/// An xml element such as &lt;foo&gt;
	EXN_ELEMENT,

	/// End of an xml element such as &lt;/foo&gt;
	EXN_ELEMENT_END,

	/**
	* Text within an xml element: &lt;foo&gt; this is the text. &lt;/foo&gt;
	* Also text between 2 xml elements: &lt;/foo&gt; this is the text. &lt;foo&gt;
	*/
	EXN_TEXT,

	/// An xml comment like &lt;!-- I am a comment --&gt; or a DTD definition.
	EXN_COMMENT,

	/// An xml cdata section like &lt;![CDATA[ this is some CDATA ]]&gt;
	EXN_CDATA,

	/// Unknown element.
	EXN_UNKNOWN
}

/// Callback class for file read abstraction.
/** 
* With this, it is possible to make the xml parser read in other
* things than just files. The Irrlicht engine is using this for example to
* read xml from compressed .zip files. To make the parser read in
* any other data, derive a class from this interface, implement the
* two methods to read your data and give a pointer to an instance of
* your implementation when calling createIrrXMLReader(),
* createIrrXMLReaderUTF16() or createIrrXMLReaderUTF32() 
*/
interface IFileReadCallBack
{
	/// Reads an amount of bytes from the file.
	/** 
	* Params:
	*	buffer = 		Pointer to buffer where to read bytes will be written to.
	* 	sizeToRead = 	Amount of bytes to read from the file.
	* Returns: Returns how much bytes were read. 
	*/
	int read(void* buffer, int sizeToRead);

	/// Returns size of file in bytes
	long getSize() const;
}

/// Empty class to be used as parent class for IrrXMLReader.
/** 
* If you need another class as base class for the xml reader, you can do this by creating
* the reader using for example new CXMLReaderImpl<char, YourBaseClass>(yourcallback);
* The Irrlicht Engine for example needs IReferenceCounted as base class for every object to
* let it automaticly reference countend, hence it replaces IXMLBase with IReferenceCounted.
* See irrXML.cpp on how this can be done in detail. 
*/
interface IXMLBase
{
}

/// Interface providing easy read access to a XML file.
/** 
* You can create an instance of this reader using one of the factory functions
* createIrrXMLReader(), createIrrXMLReaderUTF16() and createIrrXMLReaderUTF32().
* If using the parser from the Irrlicht Engine, please use IFileSystem.createXMLReader()
* instead.
* For a detailed intro how to use the parser, see \ref irrxmlexample and \ref features.
*
* The typical usage of this parser looks like this:
* Example:
* ---------
* import irrlicht.io.irrXML;
*
* void main()
* {
*	// create the reader using one of the factory functions
*	IrrXMLReader xml = createIrrXMLReader("config.xml");
*
*	if (xml is null)
*		return; // file could not be opened
*
*	// parse the file until end reached
*	while(xml.read())
*	{
*		// based on xml.getNodeType(), do something.
*	}
*
*	// drop the xml parser after usage
*	xml.drop();
* }
* ---------
* See_Also: $(B irrxmlexample) for a more detailed example.
*/
class IIrrXMLReader(char_type, super_class) : super_class
{
	alias immutable(char_type)[] string_type;

	/// Reads forward to the next xml node.
	/** 
	* Returns: false, if there was no further node. 
	*/
	bool read();

	/// Returns the type of the current XML node.
	EXML_NODE getNodeType() const;

	/// Returns attribute count of the current XML node.
	/** 
	* This is usually non null if the current 
	* node is EXN_ELEMENT, and the element has attributes.
	* Returns: amount of attributes of this xml node. 
	*/
	uint getAttributeCount() const;

	/// Returns name of an attribute.
	/** 
	* Params:
	* idx = 	Zero based index, should be something between 0 and getAttributeCount()-1.
	* Returns: Name of the attribute, 0 if an attribute with this index does not exist. 
	*/
	string_type getAttributeName(int idx) const;

	/// Returns the value of an attribute.
	/** 
	* Params:
	* idx = Zero based index, should be something between 0 and getAttributeCount()-1.
	* Returns: Value of the attribute, 0 if an attribute with this index does not exist. 
	*/
	string_type getAttributeValue(int idx) const;

	/// Returns the value of an attribute.
	/** 
	* Params:
	* name =	Name of the attribute.
	* Returns: Value of the attribute, 0 if an attribute with this name does not exist. 
	*/
	string_type getAttributeValue(string_type name) const;

	/// Returns the value of an attribute in a safe way.
	/** 
	* Like getAttributeValue(), but does not
	* return 0 if the attribute does not exist. An empty string ("") is returned then.
	* Params:
	* name = Name of the attribute.
	* Returns: Value of the attribute, and "" if an attribute with this name does not exist 
	*/
	string_type getAttributeValueSafe(string_type name) const;

	/// Returns the value of an attribute as integer.
	/** 
	* Params: 
	* name = 	Name of the attribute.
	* Returns: Value of the attribute as integer, and 0 if an attribute with this name does not exist or
	* the value could not be interpreted as integer. 
	*/
	int getAttributeValueAsInt(string_type name) const;

	/// Returns the value of an attribute as integer.
	/** 
	* Params: 
	* idx =	 Zero based index, should be something between 0 and getAttributeCount()-1.
	* Returns: Value of the attribute as integer, and 0 if an attribute with this index does not exist or
	* the value could not be interpreted as integer. 
	*/
	int getAttributeValueAsInt(int idx) const;

	/// Returns the value of an attribute as float.
	/** 
	* Params:
	* name = 	Name of the attribute.
	* Returns: Value of the attribute as float, and 0 if an attribute with this name does not exist or
	* the value could not be interpreted as float. 
	*/
	float getAttributeValueAsFloat(string_type name) const;

	/// Returns the value of an attribute as float.
	/** 
	* Params: 
	* idx =	 Zero based index, should be something between 0 and getAttributeCount()-1.
	* Returns: Value of the attribute as float, and 0 if an attribute with this index does not exist or
	* the value could not be interpreted as float. 
	*/
	float getAttributeValueAsFloat(int idx) const;

	/// Returns the name of the current node.
	/** 
	* Only valid, if the node type is EXN_ELEMENT.
	* Returns: Name of the current node or 0 if the node has no name. 
	*/
	string_type getNodeName() const;

	/// Returns data of the current node.
	/** 
	* Only valid if the node has some
	* data and it is of type EXN_TEXT, EXN_COMMENT, EXN_CDATA or EXN_UNKNOWN. 
	*/
	string_type getNodeData() const;

	/// Returns if an element is an empty element, like &lt;foo />
	bool isEmptyElement() const;

	/// Returns format of the source xml file.
	/** 
	* It is not necessary to use
	* this method because the parser will convert the input file format
	* to the format wanted by the user when creating the parser. This
	* method is useful to get/display additional informations. 
	*/
	ETEXT_FORMAT getSourceFormat() const;

	/// Returns format of the strings returned by the parser.
	/** 
	* This will be UTF8 for example when you created a parser with
	* IrrXMLReaderUTF8() and UTF32 when it has been created using
	* IrrXMLReaderUTF32. It should not be necessary to call this
	* method and only exists for informational purposes. 
	*/
	ETEXT_FORMAT getParserFormat() const;
}

struct xmlChar(T) 
	if(isSomeChar!T)
{
	T c;

	private static string gen()
	{
		string res;
		foreach(U; TypeTuple!(char, wchar, ushort, uint, ulong))
		{
			res ~= q{
			this(}~U.stringof~q{ val)
			{
				c = cast(T)val;
			}};
		}
		return res;
	}
	mixin(gen());

	T opCast(T)() const
	{
		return c;
	}

	void opAssign(int t)
	{
		c = cast(T)(t);
	}
}

/// defines the utf-16 type.
alias xmlChar!wchar char16;

/// defines the utf-32 type.
alias xmlChar!dchar char32;

/// A UTF-8 or ASCII character xml parser.
/** 
*	This means that all character data will be returned in 8 bit ASCII or UTF-8 by this parser.
*	The file to read can be in any format, it will be converted to UTF-8 if it is not
*	in this format.
*	Create an instance of this with createIrrXMLReader();
*	See IIrrXMLReader for description on how to use it. 
*/
alias IIrrXMLReader!(char, IXMLBase) IrrXMLReader;

/// A UTF-16 xml parser.
/** 
* This means that all character data will be returned in UTF-16 by this parser.
* The file to read can be in any format, it will be converted to UTF-16 if it is not
* in this format.
* Create an instance of this with createIrrXMLReaderUTF16();
* See IIrrXMLReader for description on how to use it. 
*/
alias IIrrXMLReader!(char16, IXMLBase) IrrXMLReaderUTF16;

/// A UTF-32 xml parser.
/** 
* This means that all character data will be returned in UTF-32 by this parser.
* The file to read can be in any format, it will be converted to UTF-32 if it is not
* in this format.
* Create an instance of this with createIrrXMLReaderUTF32();
* See IIrrXMLReader for description on how to use it. 
*/
alias IIrrXMLReader!(char32, IXMLBase) IrrXMLReaderUTF32;

export
{
	/// Creates an instance of an UFT-8 or ASCII character xml parser.
	/** 
	* This means that all character data will be returned in 8 bit ASCII or UTF-8.
	* The file to read can be in any format, it will be converted to UTF-8 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReaderUTF8() instead.
	* Params: 
	* filename = Name of file to be opened.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReader createIrrXMLReader(string filename);

	/// Creates an instance of an UFT-8 or ASCII character xml parser.
	/** 
	* This means that all character data will be returned in 8 bit ASCII or UTF-8. The file to read can
	* be in any format, it will be converted to UTF-8 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReaderUTF8() instead.
	* Params:
	* file = Pointer to opened file, must have been opened in binary mode, e.g.
	* using fopen("foo.bar", "wb"); The file will not be closed after it has been read.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReader createIrrXMLReader(FILE* file);

	/// Creates an instance of an UFT-8 or ASCII character xml parser.
	/** 
	* This means that all character data will be returned in 8 bit ASCII or UTF-8. The file to read can
	* be in any format, it will be converted to UTF-8 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReaderUTF8() instead.
	* Params:
 	* callback = Callback for file read abstraction. Implement your own
	* callback to make the xml parser read in other things than just files. See
	* IFileReadCallBack for more information about this.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReader createIrrXMLReader(IFileReadCallBack callback);

	/// Creates an instance of an UFT-16 xml parser.
	/** 
	* This means that
	* all character data will be returned in UTF-16. The file to read can
	* be in any format, it will be converted to UTF-16 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* filename = Name of file to be opened.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReaderUTF16 createIrrXMLReaderUTF16(string filename);

	/// Creates an instance of an UFT-16 xml parser.
	/** 
	* This means that all character data will be returned in UTF-16. The file to read can
	* be in any format, it will be converted to UTF-16 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* file = Pointer to opened file, must have been opened in binary mode, e.g.
	* using fopen("foo.bar", "wb"); The file will not be closed after it has been read.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReaderUTF16 createIrrXMLReaderUTF16(FILE* file);

	/// Creates an instance of an UFT-16 xml parser.
	/** 
	* This means that all character data will be returned in UTF-16. The file to read can
	* be in any format, it will be converted to UTF-16 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* callback = Callback for file read abstraction. Implement your own
	* callback to make the xml parser read in other things than just files. See
	* IFileReadCallBack for more information about this.
	*/
	IrrXMLReaderUTF16 createIrrXMLReaderUTF16(IFileReadCallBack callback);


	/// Creates an instance of an UFT-32 xml parser.
	/** 
	* This means that all character data will be returned in UTF-32. The file to read can
	* be in any format, it will be converted to UTF-32 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* filename: Name of file to be opened.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReaderUTF32 createIrrXMLReaderUTF32(string filename);

	/// Creates an instance of an UFT-32 xml parser.
	/** 
	* This means that all character data will be returned in UTF-32. The file to read can
	* be in any format, it will be converted to UTF-32 if it is not in this format.
	* if you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* file = Pointer to opened file, must have been opened in binary mode, e.g.
	* using fopen("foo.bar", "wb"); The file will not be closed after it has been read.
	* Returns: a pointer to the created xml parser. This pointer should be
	* deleted using 'drop' after no longer needed. Returns 0 if an error occured
	* and the file could not be opened. 
	*/
	IrrXMLReaderUTF32* createIrrXMLReaderUTF32(FILE* file);

	/// Creates an instance of an UFT-32 xml parser.
	/** 
	* This means that
	* all character data will be returned in UTF-32. The file to read can
	* be in any format, it will be converted to UTF-32 if it is not in this format.
	* If you are using the Irrlicht Engine, it is better not to use this function but
	* IFileSystem.createXMLReader() instead.
	* Params:
 	* callback = Callback for file read abstraction. Implement your own
	* callback to make the xml parser read in other things than just files. See
	* IFileReadCallBack for more information about this.
	*/
	IrrXMLReaderUTF32 createIrrXMLReaderUTF32(IFileReadCallBack callback);
}