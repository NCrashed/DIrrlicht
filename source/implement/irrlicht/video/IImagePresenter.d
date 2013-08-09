// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IImagePresenter;

import irrlicht.video.IImage;
import irrlicht.core.rect;

/**
*	Interface for a class which is able to present an IImage 
*	an the Screen. Usually only implemented by an IrrDevice for
*	presenting Software Device Rendered images.
*
*	This class should be used only internally.
*/
interface IImagePresenter
{
	///presents a surface in the client area
	bool present(IImage surface, void* windowId = null, rect!(int)* src = null );
}