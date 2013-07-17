// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IXMLReader;

import irrlicht.IReferenceCounted;
import irrlicht.irrXML;

alias IIrrXMLReader!(wchar, IReferenceCounted) IXMLReaderUTF16;
alias IIrrXMLReader!(char, IReferenceCounted) IXMLReaderUTF8;

alias IXMLReaderUTF8 IXMLReader;