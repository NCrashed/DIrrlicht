// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.meta;

import std.array;
import std.typecons;
import std.traits;
import std.typetuple;

template mangleUnqual(T)
{
	alias mangledName!(Unqual!T) mangleUnqual;
}

string genTemplatePrototypes(string marker, Tuple...)(string decl)
{
	string outString;
	foreach(Type; Tuple)
	{
		outString ~= 
			decl.replace('('~marker~')', mangledName!Type)
				.replace(marker, Type.stringof);
	}
	return outString;
}