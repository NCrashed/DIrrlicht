module irrlicht.IrrlichtDevice;

import irrlicht.video.IVideoDriver;
import irrlicht.video.IVideoModeList;
import irrlicht.video.SColor;
import irrlicht.video.EDriverTypes;

import irrlicht.io.IFileSystem;

import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.ICursorControl;

import irrlicht.scene.ISceneManager;

import irrlicht.core.array;

import irrlicht.IReferenceCounted;
import irrlicht.IRandomizer;
import irrlicht.IOSOperator;
import irrlicht.ILogger;
import irrlicht.ITimer;
import irrlicht.IEventReceiver;
import irrlicht.SEvent;
import irrlicht.SJoystickInfo;
import irrlicht.EDeviceTypes;

/// The Irrlicht device. You can create it with createDevice() or createDeviceEx().
/** 
*This is the most important class of the Irrlicht Engine. You can
*access everything in the engine if you have a pointer to an instance of
*this class.  There should be only one instance of this class at any
*time.
*/
interface IrrlichtDevice : IReferenceCounted
{
	/// Runs the device.
	/** 
	*Also increments the virtual timer by calling
	*ITimer.tick();. You can prevent this
	*by calling ITimer.stop(); before and ITimer.start() after
	*calling IrrlichtDevice.run(). Returns false if device wants
	*to be deleted. Use it in this way:
	*
	*Examples:
	*------
	*while(device.run())
	*{
	*	// draw everything here
	*}
	*------
	*
	*If you want the device to do nothing if the window is inactive
	*(recommended), use the slightly enhanced code shown at isWindowActive().
	*
	*Note if you are running Irrlicht inside an external, custom
	*created window: Calling Device.run() will cause Irrlicht to
	*dispatch windows messages internally.
	*If you are running Irrlicht in your own custom window, you can
	*also simply use your own message loop using GetMessage,
	*DispatchMessage and whatever and simply don't use this method.
	*But note that Irrlicht will not be able to fetch user input
	*then. 
	*
	*See_Also:
	*	irrlicht.SIrrlichtCreationParameters.WindowId for more informations and example code.
	*/
	bool run();

	/// Cause the device to temporarily pause execution and let other processes run.
	/** 
	*This should bring down processor usage without major
	*performance loss for Irrlicht 
	*/
	void yield();

	/// Pause execution and let other processes to run for a specified amount of time.	
	/** 
	*It may not wait the full given time, as sleep may be interrupted
	*
	*Params:
	*	timeMs= Time to sleep for in milisecs.
	*	pauseTimer= If true, pauses the device timer while sleeping
	*/
	void sleep(uint timeMs, bool pauseTimer=false);

	/// Provides access to the video driver for drawing 3d and 2d geometry.		
	/** 
	*Returns: Pointer the video driver. 
	*/	
	IVideoDriver getVideoDriver();

	/// Provides access to the virtual file system.		
	/** 
	*Retruns: Pointer to the file system. 
	*/	
	IFileSystem getFileSystem();

	/// Provides access to the 2d user interface environment.		
	/** 
	*Returns: Pointer to the gui environment. 
	*/
	IGUIEnvironment getGUIEnvironment();

	/// Provides access to the scene manager.		
	/** 
	*Returns: Pointer to the scene manager. 
	*/
	ISceneManager getSceneManager();

	/// Provides access to the cursor control.		
	/** 
	*Returns: Pointer to the mouse cursor control interface. 
	*/
	ICursorControl getCursorControl();
	
	/// Provides access to the message logger.
	/** 
	*Returns: Pointer to the logger. 
	*/
	ILogger getLogger();

	/// Gets a list with all video modes available.
	/** 
	*If you are confused now, because you think you have to
	*create an Irrlicht Device with a video mode before being able
	*to get the video mode list, let me tell you that there is no
	*need to start up an Irrlicht Device with EDT_DIRECT3D8,
	*EDT_OPENGL or EDT_SOFTWARE: For this (and for lots of other
	*reasons) the null driver, EDT_NULL exists.
	*Returns: Pointer to a list with all video modes supported
	*by the gfx adapter. 
	*/
	IVideoModeList getVideoModeList();			
	
	/// Provides access to the operation system operator object.
	/** 
	*The OS operator provides methods for
	*getting system specific informations and doing system
	*specific operations, such as exchanging data with the clipboard
	*or reading the operation system version.
	*Returns: Pointer to the OS operator. 
	*/
	IOSOperator getOSOperator();

	/// Provides access to the engine's timer.
	/** 
	*The system time can be retrieved by it as
	*well as the virtual time, which also can be manipulated.
	*Returns: Pointer to the ITimer object. 
	*/
	ITimer getTimer();

	/// Provides access to the engine's currently set randomizer.
	/** 
	*Returns: Pointer to the IRandomizer object. 
	*/
	IRandomizer getRandomizer();

	/// Sets a new randomizer.
	/**
	*Params:
	*	r=	Pointer to the new IRandomizer object. 
	*		This object is grab()'ed by the engine and will be released upon the next setRandomizer call or 
	*		upon device destruction. 
	*/
	void setRandomizer(IRandomizer r);

	/// Creates a new default randomizer.
	/** 
	*The default randomizer provides the random sequence known from previous
	*Irrlicht versions and is the initial randomizer set on device creation.
	*Returns: Pointer to the default IRandomizer object. 
	*/
	IRandomizer createDefaultRandomizer();

	/// Sets the caption of the window.
	/**
	*Params: 
	*	text= New text of the window caption. 
	*/
	void setWindowCaption(string text);

	/// Returns if the window is active.
	/** 
	*If the window is inactive,
	*nothing needs to be drawn. So if you don't want to draw anything
	*when the window is inactive, create your drawing loop this way:
	*Examples:
	*------
	*while(device.run())
	*{
	*	if (device.isWindowActive())
	*	{
	*		// draw everything here
	*	}
	*	else
	*		device.yield();
	*}
	*------
	*Returns: True if window is active. 
	*/
	bool isWindowActive();

	/// Checks if the Irrlicht window has focus
	/** 
	*Returns: True if window has focus. 
	*/
	bool isWindowFocused();

	/// Checks if the Irrlicht window is minimized
	/** 
	*Returns: True if window is minimized. 
	*/
	bool isWindowMinimized();

	/// Checks if the Irrlicht window is running in fullscreen mode
	/** 
	*Returns: True if window is fullscreen. */
	bool isFullscreen();

	/// Get the current color format of the window
	/**
	*Returns: Color format of the window. 
	*/
	ECOLOR_FORMAT getColorFormat();

	/// Notifies the device that it should close itself.
	/** 
	*IrrlichtDevice.run() will always return false after closeDevice() was called. 
	*/
	void closeDevice();

	/// Get the version of the engine.
	/** 
	*The returned string
	*will look like this: "1.2.3" or this: "1.2".
	*Returns: String which contains the version. */
	string getVersion();

	/// Sets a new user event receiver which will receive events from the engine.
	/** 
	*Return true in IEventReceiver.OnEvent to prevent the event from continuing along
	*the chain of event receivers. The path that an event takes through the system depends
	*on its type. See irrlicht.EEVENT_TYPE for details.
	*Params:
	*	receiver= New receiver to be used. 
	*/
	void setEventReceiver(IEventReceiver receiver) = 0;

	/// Provides access to the current event receiver.
	/** 
	*Returns: Pointer to the current event receiver. Returns 0 if there is none. 
	*/
	IEventReceiver getEventReceiver();

	/// Sends a user created event to the engine.
	/**
	*Is is usually not necessary to use this. However, if you
	*are using an own input library for example for doing joystick
	*input, you can use this to post key or mouse input events to
	*the engine. Internally, this method only delegates the events
	*further to the scene manager and the GUI environment. 
	*/
	bool postEventFromUser(ref const SEvent event);

	/// Sets the input receiving scene manager.
	/**
	*If set to null, the main scene manager (returned by
	*GetSceneManager()) will receive the input
	*Params:
	*	sceneManager= New scene manager to be used. 
	*/
	void setInputReceivingSceneManager(ISceneManager sceneManager);

	/// Sets if the window should be resizable in windowed mode.
	/** 
	*The default is false. This method only works in windowed
	*mode.
	*Params:
	*	resize= Flag whether the window should be resizable. 
	*/
	void setResizable(bool resize=false);

	/// Minimizes the window if possible.
	void minimizeWindow();

	//! Maximizes the window if possible.
	void maximizeWindow();

	/// Restore the window to normal size if possible.
	void restoreWindow();

	/// Activate any joysticks, and generate events for them.
	/** 
	*Irrlicht contains support for joysticks, but does not generate joystick events by default,
	*as this would consume joystick info that 3rd party libraries might rely on. Call this method to
	*activate joystick support in Irrlicht and to receive irr::SJoystickEvent events.
	*Params:
	*	joystickInfo= On return, this will contain an array of each joystick that was found and activated.
	*Returns: true if joysticks are supported on this device and _IRR_COMPILE_WITH_JOYSTICK_EVENTS_
	*		is defined, false if joysticks are not supported or support is compiled out.
	*/
	bool activateJoysticks(array!SJoystickInfo joystickInfo);

	/// Set the current Gamma Value for the Display
	bool setGammaRamp(float red, float green, float blue,
				float relativebrightness, float relativecontrast);

	/// Get the current Gamma Value for the Display
	bool getGammaRamp(out float red, out float green, out float blue,
				out float brightness, out float contrast);

	/// Remove messages pending in the system message loop
	/** 
	*This function is usually used after messages have been buffered for a longer time, for example
	*when loading a large scene. Clearing the message loop prevents that mouse- or buttonclicks which users
	*have pressed in the meantime will now trigger unexpected actions in the gui. <br>
	*So far the following messages are cleared:<br>
	*Win32: All keyboard and mouse messages<br>
	*Linux: All keyboard and mouse messages<br>
	*All other devices are not yet supported here.<br>
	*The function is still somewhat experimental, as the kind of messages we clear is based on just a few use-cases.
	*If you think further messages should be cleared, or some messages should not be cleared here, then please tell us. */
	void clearSystemMessages();

	/// Get the type of the device.
	/** 
	*This allows the user to check which windowing system is currently being
	*used. 
	*/
	E_DEVICE_TYPE getType();

	/// Check if a driver type is supported by the engine.
	/** 
	*Even if true is returned the driver may not be available
	*for a configuration requested when creating the device. 
	*/
	static final bool isDriverSupported(E_DRIVER_TYPE driver)
	{
		switch (driver)
		{
			case E_DRIVER_TYPE.EDT_NULL:
				return true;
			
			case E_DRIVER_TYPE.EDT_SOFTWARE:
				version(_IRR_COMPILE_WITH_SOFTWARE_)
				{
					return true;
				}
				else
				{
					return false;
				}
			
			case E_DRIVER_TYPE.EDT_BURNINGSVIDEO:
				version(_IRR_COMPILE_WITH_BURNINGSVIDEO_)
				{
					return true;
				}
				else
				{
					return false;
				}

			case E_DRIVER_TYPE.EDT_DIRECT3D8:
				version(_IRR_COMPILE_WITH_DIRECT3D_8_)
				{
					return true;
				}
				else
				{
					return false;
				}

			case E_DRIVER_TYPE.EDT_DIRECT3D9:
				version(_IRR_COMPILE_WITH_DIRECT3D_9_)
				{
					return true;
				}
				else
				{
					return false;
				}
				
			case E_DRIVER_TYPE.EDT_OPENGL:
				version(_IRR_COMPILE_WITH_OPENGL_)
				{
					return true;
				}
				else
				{
					return false;
				}
				
			default:
				return false;
		}
	}
}
