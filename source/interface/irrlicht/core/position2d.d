// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
/**
* As of Irrlicht 1.6, position2d is a synonym for vector2d.
* ou should consider position2d to be deprecated, and use vector2d by preference.
*/
module irrlicht.core.position2d;

import irrlicht.core.vector2d;

/// Deprecated: position2d is now synonym for vector2d, but vector2d should be used directly.
deprecated alias vector2d!float position2df;

/// Deprecated: position2d is now synonym for vector2d, but vector2d should be used directly.
deprecated alias vector2d!int position2di;