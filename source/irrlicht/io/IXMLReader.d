// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.io.IXMLReader;

import irrlicht.io.irrXML;

alias IIrrXMLReader!(wchar, Object) IXMLReaderUTF16;
alias IIrrXMLReader!(char, Object) IXMLReaderUTF8;

alias IXMLReaderUTF8 IXMLReader;