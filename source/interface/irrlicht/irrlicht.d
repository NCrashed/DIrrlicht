// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.irrlicht;

import irrlicht.IrrlichtDevice;
import irrlicht.IEventReceiver;
import irrlicht.SIrrlichtCreationParameters;
import irrlicht.video.EDriverTypes;
import irrlicht.core.dimension2d;

private 
{
    import derelict.util.loader;
    import derelict.util.system;
    import derelict.util.exception;
    
    static if( Derelict_OS_Windows )
        enum libNames = "Irrlicht.dll";
    else static if( Derelict_OS_Mac )
        enum libNames = "libIrrlicht.dylib";
    else static if( Derelict_OS_Posix )
        enum libNames = "libIrrlicht.so";
    else
        static assert(0, "Need to implement Irrlicht libNames for this poeration system" );
}

/// Creates an Irrlicht device. The Irrlicht device is the root object for using the engine.
/**
* If you need more parameters to be passed to the creation of the Irrlicht Engine device,
* use the createDeviceEx() function.
* Params:
* 	deviceType=  Type of the device. This can currently be EDT_NULL,
* EDT_SOFTWARE, EDT_BURNINGSVIDEO, EDT_DIRECT3D8, EDT_DIRECT3D9 and EDT_OPENGL.
* 	windowSize=  Size of the window or the video mode in fullscreen mode.
* 	bits=  Bits per pixel in fullscreen mode. Ignored if windowed mode.
* 	fullscreen=  Should be set to true if the device should run in fullscreen. Otherwise
	* the device runs in windowed mode.
* 	stencilbuffer=  Specifies if the stencil buffer should be enabled. Set this to true,
* if you want the engine be able to draw stencil buffer shadows. Note that not all
* devices are able to use the stencil buffer. If they don't no shadows will be drawn.
* 	vsync=  Specifies vertical syncronisation: If set to true, the driver will wait
* for the vertical retrace period, otherwise not.
* 	receiver=  A user created event receiver.
* Returns: Returns pointer to the created IrrlichtDevice or null if the
* device could not be created.
*/
//extern(C) IrrlichtDevice createDevice(
//	E_DRIVER_TYPE deviceType = E_DRIVER_TYPE.EDT_SOFTWARE,
//	// parantheses are necessary for some compilers
//	dimension2du windowSize = dimension2du(640,480),
//	uint bits = 16,
//	bool fullscreen = false,
//	bool stencilbuffer = false,
//	bool vsync = false,
//	IEventReceiver receiver = null);

/// Creates an Irrlicht device with the option to specify advanced parameters.
/**
* Usually you should used createDevice() for creating an Irrlicht Engine device.
* Use this function only if you wish to specify advanced parameters like a window
* handle in which the device should be created.
* Params:
*   parameters=  Structure containing advanced parameters for the creation of the device.
* See_Also:
*   irrlicht.SIrrlichtCreationParameters for details.
* Returns: Returns pointer to the created IrrlichtDevice or null if the
* device could not be created. 
*/
//extern(C) IrrlichtDevice createDeviceEx(SIrrlichtCreationParameters parameters);

extern(C) nothrow
{
    /// alias for Function Pointer
    alias IrrlichtDevice function(
            E_DRIVER_TYPE deviceType,
            const ref dimension2du windowSize,
            uint bits,
            bool fullscreen,
            bool stencilbuffer,
            bool vsync,
            IEventReceiver receiver) funcptr_createDevice;
    
    /// alias for Function Pointer
    alias IrrlichtDevice function( 
        SIrrlichtCreationParameters parameters ) funcptr_createDeviceEx;
}

__gshared
{
    funcptr_createDevice createDevice;
    funcptr_createDeviceEx createDeviceEx;
}

class DerelicthIrrlichtLoader : SharedLibLoader
{
    public this()
    {
        super(libNames);
    }
    
    protected override void loadSymbols()
    {
        bindFunc( cast( void** )&createDevice, "createDevice" );
        bindFunc( cast( void** )&createDeviceEx, "createDeviceEx" );
    }
}

__gshared DerelicthIrrlichtLoader DerelictIrrlicht;

shared static this()
{
    DerelictIrrlicht = new DerelicthIrrlichtLoader();
}