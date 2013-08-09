// Copyright (C) 2009-2012 Christian Stehno
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.driverChoice;

import irrlicht.IrrlichtDevice;
import irrlicht.video.EDriverTypes;
import std.stdio;

/// ask user for driver
static E_DRIVER_TYPE driverChoiceConsole(bool allDrivers = true)
{
	immutable(string[]) names = ["NullDriver", "Software Renderer", "Burning's Video", "Direct3D 8.1", "Direct3D 9.0c", "OpenGL 1.x/2.x/3.x"];
	writeln("Please select the driver you want:");

	for (uint i = E_DRIVER_TYPE.EDT_COUNT; i>0; --i)
	{
		if (allDrivers || (IrrlichtDevice.isDriverSupported(cast (E_DRIVER_TYPE)(i-1))))
			writef(" (%s) %s\n", 'a'+cast(char)(E_DRIVER_TYPE.EDT_COUNT-i), names[i-1]);
	}

	char c = readln()[0];
	c = cast(char)(cast(uint)E_DRIVER_TYPE.EDT_COUNT+'a'-c);

	for (uint i = E_DRIVER_TYPE.EDT_COUNT; i>0; --i)
	{
		if (!(allDrivers || (IrrlichtDevice.isDriverSupported(cast(E_DRIVER_TYPE)(i-1)))))
			--c;
		if (cast(char)i==c)
			return cast(E_DRIVER_TYPE)(i-1);
	}

	return E_DRIVER_TYPE.EDT_COUNT;
}