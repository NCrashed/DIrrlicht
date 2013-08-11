// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.CIrrDeviceStub;

import irrlicht.main;
import irrlicht.IrrlichtDevice;
import irrlicht.ILogger;
import irrlicht.CLogger;
import irrlicht.ITimer;
import irrlicht.CTimer;
import irrlicht.IRandomizer;
import irrlicht.IEventReceiver;
import irrlicht.SIrrlichtCreationParameters;
import irrlicht.IOSOperator;
import irrlicht.os;
import irrlicht.irrMath;
import irrlicht.io.IFileSystem;
import irrlicht.scene.ISceneManager;
import irrlicht.video.IImagePresenter;
import irrlicht.video.IVideoModeList;
import irrlicht.video.CVideoModeList;
import irrlicht.video.IVideoDriver;
import irrlicht.video.SColor;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.ICursorControl;
import irrlicht.core.dimension2d;
import irrlicht.core.vector2d;
import std.array;
import std.math;
import std.conv;

///TODO: remove this when ported!
IGUIEnvironment createGUIEnvironment(IFileSystem fs,
	IVideoDriver driver, IOSOperator op)
{
	return null;
}

ISceneManager createSceneManager(IVideoDriver driver,
	IFileSystem fs, ICursorControl cc, IGUIEnvironment gui)
{
	return null;
}

IFileSystem createFileSystem()
{
	return null;
}

IVideoDriver createSoftwareDriver()(auto ref const dimension2du windowSize,
	bool fullscreen, IFileSystem io,
	IImagePresenter presenter)
{
	return null;
}

IVideoDriver createBurningVideoDriver()(auto ref const SIrrlichtCreationParameters params,
	IFileSystem io, IImagePresenter presenter)
{
	return null;
}

IVideoDriver createNullDriver()(IFileSystem fs, auto ref const dimension2du screenSize)
{
	return null;
}
// ended dummy functions

/// Stub for an Irrlicht Device implementation
abstract class CIrrDeviceStub : IrrlichtDevice
{
	/// constructor
	this(SIrrlichtCreationParameters params)
	{
		CreationParams = params;
		UserReceiver = params.EventReceiver;

		Timer = new CTimer(params.UsePerformanceTimer);
		if(Printer.Logger !is null)
		{
			Logger = cast(CLogger)Printer.Logger;
			Logger.setReceiver(UserReceiver);
		}
		else
		{
			Logger = new CLogger(UserReceiver);
			Printer.Logger = Logger;
		}

		Logger.setLogLevel(CreationParams.LoggingLevel);
		Randomizer = createDefaultRandomizer();

		FileSystem = createFileSystem();
		Printer.log("Irrlicht Engine version "~getVersion(), ELOG_LEVEL.ELL_INFORMATION);

		checkVersion(params.SDK_version_do_not_use);
	}

	/// returns the video driver
	IVideoDriver getVideoDriver()
	{
		return VideoDriver;
	}

	/// return file system
	IFileSystem getFileSystem()
	{
		return FileSystem;
	}

	/// returns the gui environment
	IGUIEnvironment getGUIEnvironment()
	{
		return GUIEnvironment;
	}

	/// returns the scene manager
	ISceneManager getSceneManager()
	{
		return SceneManager;
	}

	/// Returns: a pointer to the mouse cursor control interface.
	ICursorControl getCursorControl()
	{
		return CursorControl;
	}

	/// Returns a pointer to a list with all video modes supported by the gfx adapter.
	IVideoModeList getVideoModeList()
	{
		return VideoModeList;
	}

	/// Returns a pointer to the ITimer object. With it the current Time can be received.
	ITimer getTimer()
	{
		return Timer;
	}

	/// Returns the version of the engine.
	string getVersion() const
	{
		return IRRLICHT_SDK_VERSION;
	}

	/// send the event to the right receiver
	bool postEventFromUser()(auto ref const SEvent event)
	{
		bool absorbed = false;

		if (UserReceiver !is null)
			absorbed = UserReceiver.OnEvent(event);

		if (!absorbed && GUIEnvironment !is null)
			absorbed = GUIEnvironment.postEventFromUser(event);

		ISceneManager inputReceiver = InputReceivingSceneManager;
		if (inputReceiver is null) 
			inputReceiver = SceneManager;

		if (!absorbed && inputReceiver !is null)
			absorbed = inputReceiver.postEventFromUser(event);

		return absorbed;
	}

	/// Sets a new event receiver to receive events
	void setEventReceiver(IEventReceiver receiver)
	{
		UserReceiver = receiver;
		Logger.setReceiver(receiver);
		if(GUIEnvironment !is null)
			GUIEnvironment.setUserEventReceiver(receiver);
	}

	/// Returns pointer to the current event receiver. Returns 0 if there is none.
	IEventReceiver getEventReceiver()
	{
		return UserReceiver;
	}

	/// Sets the input receiving scene manager.
	/** If set to null, the main scene manager (returned by GetSceneManager()) will receive the input */
	void setInputReceivingSceneManager(ISceneManager sceneManager)
	{
		InputReceivingSceneManager = sceneManager;
	}

	/// Returns a pointer to the logger.
	ILogger getLogger()
	{
		return Logger;
	}

	/// Provides access to the engine's currently set randomizer.
	IRandomizer getRandomizer()
	{
		return Randomizer;
	}

	/// Sets a new randomizer.
	void setRandomizer(IRandomizer r)
	{
		if (r != Randomizer)
		{
			Randomizer = r;
		}
	}

	/// Creates a new default randomizer.
	IRandomizer createDefaultRandomizer() const
	{
		class CDefaultRandomizer : IRandomizer
		{
			void reset(uint value=0x0f0f0f0f)
			{
				Randomizer.reset(value);
			}

			uint rand() const
			{
				return Randomizer.rand();
			}

			float frand() const
			{
				return Randomizer.frand();
			}

			uint randMax() const
			{
				return Randomizer.randMax();
			}
		}

		IRandomizer r = new CDefaultRandomizer();
		r.reset();
		return r;
	}

	/// Returns the operation system opertator object.
	IOSOperator getOSOperator()
	{
		return Operator;
	}

	/// Checks if the window is running in fullscreen mode.
	bool isFullscreen() const
	{
		return CreationParams.Fullscreen;
	}

	/// get color format of the current window
	ECOLOR_FORMAT getColorFormat() const
	{
		return ECOLOR_FORMAT.ECF_R5G6B5;
	}

	/// Activate any joysticks, and generate events for them.
	bool activateJoysticks(out SJoystickInfo[] joystickInfo)
	{
		return false;
	}

	/// Set the current Gamma Value for the Display
	bool setGammaRamp( float red, float green, float blue, float brightness, float contrast )
	{
		return false;
	}

	/// Get the current Gamma Value for the Display
	bool getGammaRamp( out float red, out float green, out float blue, out float brightness, out float contrast )
	{
		return false;
	}

	/// Set the maximal elapsed time between 2 clicks to generate doubleclicks for the mouse. It also affects tripleclick behavior.
	/// When set to 0 no double- and tripleclicks will be generated.
	void setDoubleClickTime( uint timeMs )
	{
		MouseMultiClicks.DoubleClickTime = timeMs;
	}

	/// Get the maximal elapsed time between 2 clicks to generate double- and tripleclicks for the mouse.
	uint getDoubleClickTime() const
	{
		return MouseMultiClicks.DoubleClickTime;
	}

	/// Remove all messages pending in the system message loop
	void clearSystemMessages()
	{

	}


	protected
	{

		void createGUIAndScene()
		{
			version(IRR_COMPILE_WITH_GUI)
			{
				GUIEnvironment = createGUIEnvironment(FileSystem, VideoDriver, Operator);
			}

			SceneManager = createSceneManager(VideoDriver, FileSystem, CursorControl, GUIEnvironment);

			setEventReceiver(UserReceiver);
		}

		/// checks version of SDK and prints warning if there might be a problem
		bool checkVersion(string irrVersion)
		{
			if(irrVersion != getVersion())
			{
				auto build = appender!string();
				build.put("Warning: The library version of the Irrlicht Engine (");
				build.put(to!string(getVersion()));
				build.put(") does not match the version the application was compiled with (");
				build.put(to!string(irrVersion));
				build.put("). This may cause problems.");

				Printer.log(build.data, ELOG_LEVEL.ELL_WARNING);

				return false;
			}

			return true;
		}

		/// Compares to the last call of this function to return double and triple clicks.
		/// Returns: only 1,2 or 3. A 4th click will start with 1 again.
		uint checkSuccessiveClicks(int mouseX, int mouseY, EMOUSE_INPUT_EVENT inputEvent )
		{
			enum MAX_MOUSEMOVE = 3;

			uint clickTime = getTimer.getRealTime();

			if( (clickTime - MouseMultiClicks.LastClickTime) < MouseMultiClicks.DoubleClickTime
				&& abs(MouseMultiClicks.LastClick.X - mouseX) <= MAX_MOUSEMOVE
				&& abs(MouseMultiClicks.LastClick.Y - mouseY) <= MAX_MOUSEMOVE
				&& MouseMultiClicks.CountSuccessiveClicks < 3
				&& MouseMultiClicks.LastMouseInputEvent == inputEvent)
			{
				++MouseMultiClicks.CountSuccessiveClicks;
			}
			else 
			{
				MouseMultiClicks.CountSuccessiveClicks = 1;
			}

			MouseMultiClicks.LastMouseInputEvent = inputEvent;
			MouseMultiClicks.LastClickTime = clickTime;
			MouseMultiClicks.LastClick.X = mouseX;
			MouseMultiClicks.LastClick.Y = mouseY;

			return MouseMultiClicks.CountSuccessiveClicks;
		}

		void calculateGammaRamp ( out ushort[256] ramp, float gamma, float relativebrightness, float relativecontrast )
		{
			int i;
			int value;
			int rbright = cast(int) ( relativebrightness * (65535.0f / 4 ) );
			float rcontrast = 1.0f / (255.0f - ( relativecontrast * 127.5f ) );

			gamma = gamma > 0.0f ? 1.0f / gamma : 0.0f;

			for ( i = 0; i < 256; ++i )
			{
				value = cast(int)(pow( rcontrast * i, gamma)*65535.0f + 0.5f );
				ramp[i] = cast(ushort)clamp( value + rbright, 0u, 65535u );
			}
		}

		void calculateGammaFromRamp ( out float gamma, const ushort[256] ramp )
		{
			/* The following is adapted from a post by Garrett Bass on OpenGL
			Gamedev list, March 4, 2000.
			*/
			float sum = 0.0f;
			int i, count = 0;

			gamma = 1.0f;
			for ( i = 1; i < 256; ++i ) 
			{
				if ( (ramp[i] != 0) && (ramp[i] != 65535) ) 
				{
					float B = cast(float)i / 256.0f;
					float A = ramp[i] / 65535.0f;
					sum += cast(float) ( log(A) / log(B) );
					count++;
				}
			}
			if ( count != 0 && sum != 0.0f ) 
			{
				gamma = 1.0f / (sum / count);
			}
		}

		IVideoDriver VideoDriver = null;
		IGUIEnvironment GUIEnvironment = null;
		ISceneManager SceneManager = null;
		ITimer Timer = null;
		ICursorControl CursorControl = null;
		IEventReceiver UserReceiver = null;
		CLogger Logger = null;
		IOSOperator Operator = null;
		IRandomizer Randomizer = null;
		IFileSystem FileSystem = null;
		ISceneManager InputReceivingSceneManager = null;

		struct SMouseMultiClicks
		{
			uint DoubleClickTime = 500;
			uint CountSuccessiveClicks = 0;
			uint LastClickTime = 0;
			vector2di LastClick;
			EMOUSE_INPUT_EVENT LastMouseInputEvent = EMOUSE_INPUT_EVENT.EMIE_COUNT;
		}

		SMouseMultiClicks MouseMultiClicks;
		CVideoModeList VideoModeList = null;
		SIrrlichtCreationParameters CreationParams;
		bool Close = false;
	}
}