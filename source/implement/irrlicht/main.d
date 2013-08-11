// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.main;

immutable(string) copyright = "Irrlicht Engine (c) 2002-2013 Nikolaus Gebhardt";

enum IRRLICHT_SDK_VERSION = "1.8.0";

import irrlicht.IrrlichtDevice;
import irrlicht.IEventReceiver;
import irrlicht.SIrrlichtCreationParameters;
import irrlicht.EDeviceTypes;
import irrlicht.video.EDriverTypes;
import irrlicht.core.dimension2d;

version(IRR_COMPILE_WITH_WINDOWS_DEVICE)
	import irrlicht.CIrrDeviceWin32;

version(IRR_COMPILE_WITH_OSX_DEVICE)
	import irrlicht.CIrrDeviceMacOSX;

version(IRR_COMPILE_WITH_X11_DEVICE)
	import irrlicht.CIrrDeviceLinux;

version(IRR_COMPILE_WITH_SDL_DEVICE)
	import irrlicht.CIrrDeviceSDL;

version(IRR_COMPILE_WITH_FB_DEVICE)
	import irrlicht.CIrrDeviceFB;

version(IRR_COMPILE_WITH_CONSOLE_DEVICE)
	import irrlicht.CIrrDeviceConsole;

export IrrlichtDevice createDevice(
	E_DRIVER_TYPE deviceType = E_DRIVER_TYPE.EDT_SOFTWARE,
	// parantheses are necessary for some compilers
	const dimension2du windowSize = dimension2du(640,480),
	uint bits = 16,
	bool fullscreen = false,
	bool stencilbuffer = false,
	bool vsync = false,
	IEventReceiver receiver = null)
{
	SIrrlichtCreationParameters p;
	p.DriverType = deviceType;
	p.WindowSize = windowSize;
	p.Bits = cast(ubyte)bits;
	p.Fullscreen = fullscreen;
	p.Stencilbuffer = stencilbuffer;
	p.Vsync = vsync;
	p.EventReceiver = receiver;

	return createDeviceEx(p);
}

export IrrlichtDevice createDeviceEx(
	SIrrlichtCreationParameters params)
{
	IrrlichtDevice dev = null;

	version(IRR_COMPILE_WITH_WINDOWS_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_WIN32	 || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceWin32(params);
	}

	version(IRR_COMPILE_WITH_OSX_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_OSX	 || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceMacOSX(params);	
	}

	version(IRR_COMPILE_WITH_X11_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_X11	 || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceLinux(params);	
	}	

	version(IRR_COMPILE_WITH_SDL_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_SDL	 || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceSDL(params);	
	}

	version(IRR_COMPILE_WITH_FB_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_FRAMEBUFFER	 || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceFB(params);	
	}

	version(IRR_COMPILE_WITH_CONSOLE_DEVICE)
	{
		if(params.DeviceType == E_DEVICE_TYPE.EIDT_CONSOLE || (dev is null && params.DeviceType == E_DEVICE_TYPE.EIDT_BEST))
			dev = new CIrrDeviceConsole(params);	
	}

	if(dev !is null && dev.getVideoDriver() is null && params.DriverType != E_DRIVER_TYPE.EDT_NULL)
	{
		dev.closeDevice(); // destroy window
		dev.run(); // consume quit message
		dev = null;
	}

	return dev;
}