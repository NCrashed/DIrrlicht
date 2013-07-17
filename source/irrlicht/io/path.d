// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" and the "irrXML" project.
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.path;

import std.regex;
import std.string;

//! Type used for all file system related strings.
/** This type will transparently handle different file system encodings. */
alias string Path;

//! Used in places where we identify objects by a filename, but don't actually work with the real filename
/** Irrlicht is internally not case-sensitive when it comes to names.
    Also this class is a first step towards support for correctly serializing renamed objects.
*/
class SNamedPath
{
	this() {}

	this(const Path p)
	{
		mPath = p;
		mInternalName = PathToName(p);
	}

	//! Is smaller comparator
	bool opBinary(string op)(const SNamedPath other)
		if(op == "<")
	{
		return mInternalName < other.mInternalName;
	}

	//! Set the path
	void path(const Path p) @property
	{
		mPath = p;
		mInternalName = PathToName(p);
	}

	//! Get the path
	const Path path() @property
	{
		return mPath;
	}

	/** 
	* Get the name which is used to identify the file.
	* This string is similar to the names and filenames used before Irrlicht 1.7
	*/
	const Path internalName() @property
	{
		return mInternalName;
	}

	/// Implicit cast to string
	T opCast(T)() if(is(T == string))
	{
		return cast(string)Path;
	}

	protected:

		// convert the given path string to a name string.
		static Path PathToName(const Path p)
		{
			return toLower(replace(p, regex(`\\`, "g"), "/"));
		}
		unittest
		{
			assert(PathToName("\\a\\") == "/a/");
		}

	private:
		Path mPath;
		Path mInternalName;	
}