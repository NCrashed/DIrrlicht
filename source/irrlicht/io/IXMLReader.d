// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IXMLReader;

import irrlicht.irrXML;

alias IIrrXMLReader!(wchar, Object) IXMLReaderUTF16;
alias IIrrXMLReader!(char, Object) IXMLReaderUTF8;

alias IXMLReaderUTF8 IXMLReader;