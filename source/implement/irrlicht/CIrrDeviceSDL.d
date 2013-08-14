// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
// This device code is based on the original SDL device implementation
// contributed by Shane Parker (sirshane).
module irrlicht.CIrrDeviceSDL;

import irrlicht.IrrlichtDevice;
import irrlicht.CIrrDeviceStub;
import irrlicht.EDeviceTypes;
import irrlicht.IEventReceiver;
import irrlicht.SIrrlichtCreationParameters;
import irrlicht.ILogger;
import irrlicht.CTimer;
import irrlicht.COSOperator;
import irrlicht.Keycodes;
import irrlicht.os;
import irrlicht.video.EDriverTypes;
import irrlicht.video.IImagePresenter;
import irrlicht.video.IVideoModeList;
import irrlicht.video.IImage;
import irrlicht.video.SColor;
import irrlicht.gui.ICursorControl;
import irrlicht.core.rect;
import irrlicht.core.coreutil;
import irrlicht.core.vector2d;
import irrlicht.core.dimension2d;
import derelict.sdl2.sdl;
import std.math;
import std.array;
import std.algorithm;
import std.conv;
import std.string;

import irrlicht.io.IFileSystem;
import irrlicht.video.IVideoDriver;
IVideoDriver createOpenGLDriver(SIrrlichtCreationParameters params,
		IFileSystem io, CIrrDeviceSDL device)
{
	assert(false); ///TODO:Remove stub function!
}

class CIrrDeviceSDL : CIrrDeviceStub, IImagePresenter
{
	/// constructor
	this(SIrrlichtCreationParameters param)
	{
		super(param);
		Window = cast(SDL_Window*)param.WindowId;
		//SDL_Flags = SDL_ANYFORMAT;
		MouseX = 0;
		MouseY = 0;
		MouseButtonStates = 0;
		Width = param.WindowSize.Width;
		Height = param.WindowSize.Height;
		Resizable = false;
		WindowHasFocus = false;
		WindowMinimized = false;

		DerelictSDL2.load();
		// Initialize SDL... Timer for sleep, video for the obvious, and
		// noparachute prevents SDL from catching fatal errors.
		version(IRR_COMPILE_WITH_JOYSTICK_EVENTS)
		{
			Joysticks = new SDL_Joystick*[0];
			if (SDL_Init( SDL_INIT_TIMER | SDL_INIT_VIDEO |
					SDL_INIT_JOYSTICK | SDL_INIT_NOPARACHUTE ) < 0)
			{
				Printer.log( "Unable to initialize SDL!", fromStringz(SDL_GetError()));
				Close = true;
			}
		}
		else
		{
			if (SDL_Init( SDL_INIT_TIMER | SDL_INIT_VIDEO |
					SDL_INIT_NOPARACHUTE ) < 0)
			{
				Printer.log( "Unable to initialize SDL!", fromStringz(SDL_GetError()));
				Close = true;
			}
		}

		//version(Windows)
		//	SDL_putenv("SDL_VIDEODRIVER=directx");
		//version(OSX)
		//	SDL_putenv("SDL_VIDEODRIVER=Quartz");
		//else
		//	SDL_putenv("SDL_VIDEODRIVER=x11");

		SDL_GetVersion(&Info);

		auto sdlversion = appender!string();
		sdlversion.put("SDL Version ");
		sdlversion.put(Info.major);
		sdlversion.put(".");
		sdlversion.put(Info.minor);
		sdlversion.put(".");
		sdlversion.put(Info.patch);

		Operator = new COSOperator(sdlversion.data);
		Printer.log(sdlversion.data, ELOG_LEVEL.ELL_INFORMATION);

		// create keymap
		createKeyMap();
		// enable key to character translation
		//SDL_EnableUNICODE(1);

		//SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);

		if ( CreationParams.Fullscreen )
			SDL_Flags |= SDL_WINDOW_FULLSCREEN;
		if (CreationParams.DriverType == E_DRIVER_TYPE.EDT_OPENGL)
			SDL_Flags |= SDL_WINDOW_OPENGL;
		//else if (CreationParams.Doublebuffer)
		//	SDL_Flags |= SDL_DOUBLEBUF;

		// create window
		if (CreationParams.DriverType != E_DRIVER_TYPE.EDT_NULL)
		{
			// create the window, only if we do not use the null device
			createWindow();
		}

		// create cursor control
		CursorControl = new CCursorControl(this);

		// create driver
		createDriver();

		if (VideoDriver !is null)
			createGUIAndScene();
	}

	/// destructor
	~this()
	{
		version(IRR_COMPILE_WITH_JOYSTICK_EVENTS)
		{
			foreach(ref joystick; Joysticks)
			{
				SDL_JoystickClose(joystick);
			}
		}

		SDL_Quit();
	}

	/// runs the device. Returns false if device wants to be deleted
	bool run()
	{
		Timer.tick();

		SEvent irrevent;
		SDL_Event SDL_event;

		while (!Close && SDL_PollEvent(&SDL_event))
		{
			switch(SDL_event.type)
			{
				case SDL_MOUSEMOTION:
					irrevent.EventType = EEVENT_TYPE.EET_MOUSE_INPUT_EVENT;
					irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_MOUSE_MOVED;
					MouseX = irrevent.MouseInput.X = SDL_event.motion.x;
					MouseY = irrevent.MouseInput.Y = SDL_event.motion.y;
					irrevent.MouseInput.ButtonStates = MouseButtonStates;

					postEventFromUser(irrevent);
					break;
				case SDL_MOUSEBUTTONDOWN:
					goto case SDL_MOUSEBUTTONUP;
				case SDL_MOUSEBUTTONUP:

					irrevent.EventType = EEVENT_TYPE.EET_MOUSE_INPUT_EVENT;
					irrevent.MouseInput.X = SDL_event.button.x;
					irrevent.MouseInput.Y = SDL_event.button.y;

					irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_MOUSE_MOVED;

					switch(SDL_event.button.button)
					{
						case SDL_BUTTON_LEFT:
							if(SDL_event.type == SDL_MOUSEBUTTONDOWN)
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_LMOUSE_PRESSED_DOWN;
								MouseButtonStates |= E_MOUSE_BUTTON_STATE_MASK.EMBSM_LEFT;
							}
							else
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_LMOUSE_LEFT_UP;
								MouseButtonStates &= E_MOUSE_BUTTON_STATE_MASK.EMBSM_LEFT;
							}
							break;
						case SDL_BUTTON_RIGHT:
							if(SDL_event.type == SDL_MOUSEBUTTONDOWN)
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_RMOUSE_PRESSED_DOWN;
								MouseButtonStates |= E_MOUSE_BUTTON_STATE_MASK.EMBSM_RIGHT;
							}
							else
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_RMOUSE_LEFT_UP;
								MouseButtonStates &= E_MOUSE_BUTTON_STATE_MASK.EMBSM_RIGHT;
							}
							break;
						case SDL_BUTTON_MIDDLE:
							if(SDL_event.type == SDL_MOUSEBUTTONDOWN)
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_MMOUSE_PRESSED_DOWN;
								MouseButtonStates |= E_MOUSE_BUTTON_STATE_MASK.EMBSM_MIDDLE;
							}
							else
							{
								irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_MMOUSE_LEFT_UP;
								MouseButtonStates &= E_MOUSE_BUTTON_STATE_MASK.EMBSM_MIDDLE;
							}
							break;
						case SDL_MOUSEWHEEL:
							irrevent.MouseInput.Event = EMOUSE_INPUT_EVENT.EMIE_MOUSE_WHEEL;
							irrevent.MouseInput.Wheel = SDL_event.wheel.y;
							break;
						default:
					}

					irrevent.MouseInput.ButtonStates = MouseButtonStates;

					if (irrevent.MouseInput.Event != EMOUSE_INPUT_EVENT.EMIE_MOUSE_MOVED)
					{
						postEventFromUser(irrevent);

						if ( irrevent.MouseInput.Event >= EMOUSE_INPUT_EVENT.EMIE_LMOUSE_PRESSED_DOWN && irrevent.MouseInput.Event <= EMOUSE_INPUT_EVENT.EMIE_MMOUSE_PRESSED_DOWN )
						{
							uint clicks = checkSuccessiveClicks(irrevent.MouseInput.X, irrevent.MouseInput.Y, irrevent.MouseInput.Event);
							if ( clicks == 2 )
							{
								irrevent.MouseInput.Event = cast(EMOUSE_INPUT_EVENT)(EMOUSE_INPUT_EVENT.EMIE_LMOUSE_DOUBLE_CLICK + irrevent.MouseInput.Event-EMOUSE_INPUT_EVENT.EMIE_LMOUSE_PRESSED_DOWN);
								postEventFromUser(irrevent);
							}
							else if ( clicks == 3 )
							{
								irrevent.MouseInput.Event = cast(EMOUSE_INPUT_EVENT)(EMOUSE_INPUT_EVENT.EMIE_LMOUSE_TRIPLE_CLICK + irrevent.MouseInput.Event-EMOUSE_INPUT_EVENT.EMIE_LMOUSE_PRESSED_DOWN);
								postEventFromUser(irrevent);
							}
						}
					}
					break;

				case SDL_KEYDOWN:
					goto case SDL_KEYUP;
				case SDL_KEYUP:
				{
					SKeyMap mp;
					mp.SDLKey = SDL_event.key.keysym.sym;
					ptrdiff_t idx = KeyMap.countUntil(mp);

					EKEY_CODE key;
					if(idx == -1)
						key = cast(EKEY_CODE)0;
					else
						key = cast(EKEY_CODE)KeyMap[idx].Win32Key;

					version(Windows)
					{
						// handle alt+f4 in Windows, because SDL seems not to
						if ( (SDL_event.key.keysym.mod & KMOD_LALT) && key == EKEY_CODE.KEY_F4)
						{
							Close = true;
							break;
						}
					}

					irrevent.EventType = EEVENT_TYPE.EET_KEY_INPUT_EVENT;
					irrevent.KeyInput.Char = to!char(SDL_event.key.keysym.unicode);
					irrevent.KeyInput.Key = key;
					irrevent.KeyInput.PressedDown = (SDL_event.type == SDL_KEYDOWN);
					irrevent.KeyInput.Shift = (SDL_event.key.keysym.mod & KMOD_SHIFT) != 0;
					irrevent.KeyInput.Control = (SDL_event.key.keysym.mod & KMOD_CTRL ) != 0;
					postEventFromUser(irrevent);
					break;
				}
				case SDL_QUIT:
				{
					Close = true;
					break;
				}
				case SDL_WINDOWEVENT:
				{
					switch (SDL_event.window.event) 
					{
						case SDL_WINDOWEVENT_FOCUS_GAINED:
							WindowHasFocus = true;
							break;
						case SDL_WINDOWEVENT_FOCUS_LOST:
							WindowHasFocus = false;
							break;
						case SDL_WINDOWEVENT_SIZE_CHANGED:
							if ((SDL_event.window.data1 != cast(int)Width) || (SDL_event.window.data2 != cast(int)Height))
							{
								Width = SDL_event.window.data1;
								Height = SDL_event.window.data2;
								
								if (VideoDriver !is null)
									VideoDriver.OnResize(dimension2du(Width, Height));
							}
							break;
						default:
							break;
					}
					break;
				}
				case SDL_USEREVENT:
				{
					irrevent.EventType = EEVENT_TYPE.EET_USER_EVENT;
					irrevent.UserEvent.UserData1 = *(cast(int*)(&SDL_event.user.data1));
					irrevent.UserEvent.UserData2 = *(cast(int*)(&SDL_event.user.data2));

					postEventFromUser(irrevent);
					break;
				}
				default:
					break;
			} // end switch

		} // end while

		version(IRR_COMPILE_WITH_JOYSTICK_EVENTS)
		{
			// TODO: Check if the multiple open/close calls are too expensive, then
			// open/close in the constructor/destructor instead

			// we'll always send joystick input events...
			SEvent joyevent;
			joyevent.EventType = EEVENT_TYPE.EET_JOYSTICK_INPUT_EVENT;
			foreach(i, ref joystick; Joysticks)
			{
				if (joystick !is null)
				{
					// update joystick states manually
					SDL_JoystickUpdate(joystick);

					size_t j;
					// query all buttons
					immutable numButtons = cast(size_t)fmin(SDL_JoystickNumButtons(joystick), 32);
					joyevent.JoystickEvent.ButtonStates = 0;
					for (j=0; j<numButtons; ++j)
						joyevent.JoystickEvent.ButtonStates |= (SDL_JoystickGetButton(joystick, cast(int)j)<<j);

					// query all axes, already in correct range
					immutable numAxes = cast(size_t)fmin(SDL_JoystickNumAxes(joystick), SEvent.SJoystickEvent.NUMBER_OF_AXES);
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_X]=0;
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_Y]=0;
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_Z]=0;
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_R]=0;
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_U]=0;
					joyevent.JoystickEvent.Axis[SEvent.SJoystickEvent.AXIS_V]=0;
					for (j=0; j<numAxes; ++j)
						joyevent.JoystickEvent.Axis[j] = SDL_JoystickGetAxis(joystick, cast(int)j);

					// we can only query one hat, SDL only supports 8 directions
					if (SDL_JoystickNumHats(joystick)>0)
					{
						switch (SDL_JoystickGetHat(joystick, 0))
						{
							case SDL_HAT_UP:
								joyevent.JoystickEvent.POV=0;
								break;
							case SDL_HAT_RIGHTUP:
								joyevent.JoystickEvent.POV=4500;
								break;
							case SDL_HAT_RIGHT:
								joyevent.JoystickEvent.POV=9000;
								break;
							case SDL_HAT_RIGHTDOWN:
								joyevent.JoystickEvent.POV=13500;
								break;
							case SDL_HAT_DOWN:
								joyevent.JoystickEvent.POV=18000;
								break;
							case SDL_HAT_LEFTDOWN:
								joyevent.JoystickEvent.POV=22500;
								break;
							case SDL_HAT_LEFT:
								joyevent.JoystickEvent.POV=27000;
								break;
							case SDL_HAT_LEFTUP:
								joyevent.JoystickEvent.POV=31500;
								break;
							case SDL_HAT_CENTERED:
							default:
								joyevent.JoystickEvent.POV=65535;
								break;
						}
					}
					else
					{
						joyevent.JoystickEvent.POV=65535;
					}

					// we map the number directly
					joyevent.JoystickEvent.Joystick = cast(ubyte)(i);
					// now post the event
					postEventFromUser(joyevent);
					// and close the joystick
				}
			}
		}

		return !Close;
	}

	/// pause execution temporarily
	void yield()
	{
		SDL_Delay(0);
	}

	/// pause execution for a specified time
	void sleep(uint timeMs, bool pauseTimer)
	{
		immutable wasStopped = Timer !is null ? Timer.isStopped() : true;
		if(pauseTimer && !wasStopped)
			Timer.stop();

		SDL_Delay(timeMs);

		if(pauseTimer && !wasStopped)
			Timer.start();
	}

	/// sets the caption of the window
	void setWindowCaption(wstring text)
	{
		SDL_SetWindowTitle(Window, to!string(text).toStringz());
	}

	/// returns if window is active. if not, nothing need to be drawn
	bool isWindowActive() const
	{
		return (WindowHasFocus && !WindowMinimized);
	}

	/// returns if window has focus.
	bool isWindowFocused() const
	{
		return WindowHasFocus;
	}

	/// returns if window is minimized.
	bool isWindowMinimized() const
	{
		return WindowMinimized;
	}

	/// returns color format of the window.
	override ECOLOR_FORMAT getColorFormat() const
	{
		if(Window !is null)
		{
			auto format = SDL_GetWindowPixelFormat(cast(SDL_Window*)Window);
			if(SDL_BITSPERPIXEL(format) ==  16)
			{
				if(SDL_ISPIXELFORMAT_ALPHA(format))
					return ECOLOR_FORMAT.ECF_A1R5G5B5;
				else 
					return ECOLOR_FORMAT.ECF_R5G6B5;
			}
			else 
			{
				if(SDL_ISPIXELFORMAT_ALPHA(format))
					return ECOLOR_FORMAT.ECF_A8R8G8B8;
				else 
					return ECOLOR_FORMAT.ECF_R8G8B8;
			}
		}
		else 
			return super.getColorFormat();
	}

	/// presents a surface in the client area
	bool present(IImage surface, void* windowId = null, rect!(int)* srcClip = null )
	{
		SDL_Surface* sdlSurface = SDL_CreateRGBSurfaceFrom(
				surface.lock(), surface.getDimension().Width, surface.getDimension().Height,
				surface.getBitsPerPixel(), surface.getPitch(),
				surface.getRedMask(), surface.getGreenMask(), surface.getBlueMask(), surface.getAlphaMask());
		
		if (sdlSurface is null)
			return false;
		
		SDL_SetSurfaceAlphaMod(sdlSurface, 0);
		SDL_SetColorKey(sdlSurface, 0, 0);
		sdlSurface.format.BitsPerPixel  = cast(ubyte)surface.getBitsPerPixel();
		sdlSurface.format.BytesPerPixel = cast(ubyte)surface.getBytesPerPixel();

		if ((surface.getColorFormat()== ECOLOR_FORMAT.ECF_R8G8B8) ||
				(surface.getColorFormat() == ECOLOR_FORMAT.ECF_A8R8G8B8))
		{
			sdlSurface.format.Rloss = 0;
			sdlSurface.format.Gloss = 0;
			sdlSurface.format.Bloss = 0;
			sdlSurface.format.Rshift = 16;
			sdlSurface.format.Gshift = 8;
			sdlSurface.format.Bshift = 0;
			if (surface.getColorFormat() == ECOLOR_FORMAT.ECF_R8G8B8)
			{
				sdlSurface.format.Aloss = 8;
				sdlSurface.format.Ashift = 32;
			}
			else
			{
				sdlSurface.format.Aloss = 0;
				sdlSurface.format.Ashift = 24;
			}
		}
		else if (surface.getColorFormat() == ECOLOR_FORMAT.ECF_R5G6B5)
		{
			sdlSurface.format.Rloss = 3;
			sdlSurface.format.Gloss = 2;
			sdlSurface.format.Bloss = 3;
			sdlSurface.format.Aloss = 8;
			sdlSurface.format.Rshift = 11;
			sdlSurface.format.Gshift = 5;
			sdlSurface.format.Bshift = 0;
			sdlSurface.format.Ashift = 16;
		}
		else if (surface.getColorFormat() == ECOLOR_FORMAT.ECF_A1R5G5B5)
		{
			sdlSurface.format.Rloss = 3;
			sdlSurface.format.Gloss = 3;
			sdlSurface.format.Bloss = 3;
			sdlSurface.format.Aloss = 7;
			sdlSurface.format.Rshift = 10;
			sdlSurface.format.Gshift = 5;
			sdlSurface.format.Bshift = 0;
			sdlSurface.format.Ashift = 15;
		}

		SDL_Surface* scr = cast(SDL_Surface* )windowId;
		if (scr is null)
			scr = SDL_GetWindowSurface(Window);

		if (scr !is null)
		{
			if (srcClip !is null)
			{
				SDL_Rect sdlsrcClip;
				sdlsrcClip.x = srcClip.UpperLeftCorner.X;
				sdlsrcClip.y = srcClip.UpperLeftCorner.Y;
				sdlsrcClip.w = srcClip.getWidth();
				sdlsrcClip.h = srcClip.getHeight();
				SDL_BlitSurface(sdlSurface, &sdlsrcClip, scr, null);
			}
			else
				SDL_BlitSurface(sdlSurface, null, scr, null);

			SDL_RenderPresent(Renderer);
		}

		SDL_FreeSurface(sdlSurface);
		surface.unlock();
		return (scr !is null);
	}

	/// notifies the device that it should close itself
	void closeDevice()
	{
		Close = true;
	}

	/// Returns: a list with all video modes supported
	override IVideoModeList getVideoModeList()
	{
		if(VideoModeList.getVideoModeCount() > 0)
		{
			int displayIndex = SDL_GetWindowDisplayIndex(Window);
			for(size_t i = 0; i < SDL_GetNumDisplayModes(displayIndex); i++)
			{
				SDL_DisplayMode mode;
				SDL_GetDisplayMode(displayIndex, cast(int)i, &mode);
				VideoModeList.addMode(dimension2d!uint(mode.w, mode.h), SDL_BITSPERPIXEL(mode.format));
			}
		}

		return VideoModeList;
	}

	/// Sets if the window should be resizable in windowed mode.
	void setResizable(bool resize=false)
	{
		if (resize != Resizable)
		{
			if (resize)
			{
				SDL_SetWindowMaximumSize(Window, int.max, int.max);
				SDL_SetWindowMinimumSize(Window, 0, 0);
				SDL_Flags |= SDL_WINDOW_RESIZABLE;
			}
			else
			{
				SDL_SetWindowMaximumSize(Window, Width, Height);
				SDL_SetWindowMinimumSize(Window, Width, Height);			
				SDL_Flags &= ~SDL_WINDOW_RESIZABLE;
			}

			Resizable = resize;
		}
	}

	/// Minimizes the window.
	void minimizeWindow()
	{
		SDL_MinimizeWindow(Window);
		WindowMinimized = true;
	}

	/// Maximizes the window.
	void maximizeWindow()
	{
		SDL_MaximizeWindow(Window);
		WindowMinimized = false;
	}

	/// Restores the window size.
	void restoreWindow()
	{
		SDL_RestoreWindow(Window);
	}

	/// Activate any joysticks, and generate events for them.
	override bool activateJoysticks(out SJoystickInfo[] joystickInfo)
	{
		version(IRR_COMPILE_WITH_JOYSTICK_EVENTS)
		{
			joystickInfo[] = [];
			Joysticks[] = [];

			// we can name up to 256 different joysticks
			immutable numJoysticks = cast(size_t)fmin(SDL_NumJoysticks(), 256);
			Joysticks.length = numJoysticks;
			joystickInfo.length = numJoysticks;

			foreach(joystick, ref info; joystickInfo)
			{
				Joysticks[joystick] = SDL_JoystickOpen(cast(int)joystick);

				info.Joystick = cast(ubyte)joystick;
				info.Axes = SDL_JoystickNumAxes(Joysticks[joystick]);
				info.Buttons = SDL_JoystickNumButtons(Joysticks[joystick]);
				info.Name = fromStringz(SDL_JoystickName(Joysticks[joystick]));
				info.PovHat = (SDL_JoystickNumHats(Joysticks[joystick]) > 0)
								? SJoystickInfo.PovHatEnum.POV_HAT_PRESENT : SJoystickInfo.PovHatEnum.POV_HAT_ABSENT;
			}

			foreach(joystick, ref info; joystickInfo)
			{
				Printer.log(text(
					"Found joystick ", joystick, 
					", ", info.Axes, " axes, ",
					info.Buttons, " buttons '", info.Name, "'"), 
					ELOG_LEVEL.ELL_INFORMATION);
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	/// Set the current Gamma Value for the Display
	override bool setGammaRamp( float red, float green, float blue, float brightness, float contrast )
	{
		return false;
	}

	/// Get the current Gamma Value for the Display
	override bool getGammaRamp( out float red, out float green, out float blue, out float brightness, out float contrast )
	{
		return false;
	}

	/// Get the device type
	E_DEVICE_TYPE getType() const
	{
		return E_DEVICE_TYPE.EIDT_SDL;
	}

	/// Implementation of the linux cursor control
	class CCursorControl : ICursorControl
	{
		this(CIrrDeviceSDL dev)
		{
			Device = dev;
			IsVisible = true;
		}

		/// Changes the visible state of the mouse cursor.
		void setVisible(bool visible)
		{
			IsVisible = visible;
			if ( visible )
				SDL_ShowCursor( SDL_ENABLE );
			else
				SDL_ShowCursor( SDL_DISABLE );
		}

		/// Returns if the cursor is currently visible.
		bool isVisible() const
		{
			return IsVisible;
		}

		/// Sets the new position of the cursor.
		void setPosition(ref const vector2df pos)
		{
			setPosition(pos.X, pos.Y);
		}

		/// Sets the new position of the cursor.
		void setPosition(float x, float y)
		{
			setPosition(cast(int)(x*Device.Width), cast(int)(y*Device.Height));
		}

		/// Sets the new position of the cursor.
		void setPosition(ref const vector2di pos)
		{
			setPosition(pos.X, pos.Y);
		}

		/// Sets the new position of the cursor.
		void setPosition(int x, int y)
		{
			SDL_WarpMouseInWindow(Device.Window, x, y );
		}

		/// Returns the current position of the mouse cursor.
		ref const(vector2di) getPosition()
		{
			updateCursorPos();
			return CursorPos;
		}

		/// Returns the current position of the mouse cursor.
		vector2df getRelativePosition()
		{
			updateCursorPos();
			return vector2df(CursorPos.X / cast(float)Device.Width,
				CursorPos.Y / cast(float)Device.Height);
		}

		void setReferenceRect(rect!(int)* rect = null)
		{

		}

		/// Sets the active cursor icon
		/**
		* Setting cursor icons is so far only supported on Win32 and Linux 
		*/
		void setActiveIcon(ECURSOR_ICON iconId)
		{

		}

		/// Gets the currently active icon
		ECURSOR_ICON getActiveIcon() const
		{
			return ECURSOR_ICON.ECI_NORMAL;
		}

		/// Add a custom sprite as cursor icon.
		/**
		* Returns: Identification for the icon 
		*/
		ECURSOR_ICON addIcon(ref const SCursorSprite icon)
		{
			return ECURSOR_ICON.ECI_NORMAL;
		}

		/// replace a cursor icon.
		/**
		* Changing cursor icons is so far only supported on Win32 and Linux
		*	 Note that this only changes the icons within your application, system cursors outside your
		*	 application will not be affected.
		*/
		void changeIcon(ECURSOR_ICON iconId, ref const SCursorSprite sprite)
		{

		}

		/// Return a system-specific size which is supported for cursors. Larger icons will fail, smaller icons might work.
		dimension2di getSupportedIconSize() const
		{
			return dimension2di(0, 0);
		}

		/// Set platform specific behavior flags.
		void setPlatformBehavior(ECURSOR_PLATFORM_BEHAVIOR behavior)
		{

		}

		/// Return platform specific behavior.
		/**
		* Returns: Behavior set by setPlatformBehavior or ECPB_NONE for platforms not implementing specific behaviors.
		*/
		ECURSOR_PLATFORM_BEHAVIOR getPlatformBehavior() const
		{
			return ECURSOR_PLATFORM_BEHAVIOR.ECPB_NONE;
		}


		private void updateCursorPos()
		{
			CursorPos.X = Device.MouseX;
			CursorPos.Y = Device.MouseY;
			clipCursorPos();
		}

		protected
		{
			void clipCursorPos()
			{
				if (CursorPos.X < 0)
					CursorPos.X = 0;
				if (CursorPos.X > cast(int)Device.Width)
					CursorPos.X = Device.Width;
				if (CursorPos.Y < 0)
					CursorPos.Y = 0;
				if (CursorPos.Y > cast(int)Device.Height)
					CursorPos.Y = Device.Height;
			}
		}

		private
		{
			CIrrDeviceSDL Device;
			vector2di CursorPos;
			bool IsVisible;
		}
	}

	private
	{
		/// create the driver
		void createDriver()
		{
			switch(CreationParams.DriverType)
			{
			case E_DRIVER_TYPE.EDT_DIRECT3D9:
				version(IRR_COMPILE_WITH_DIRECT3D_9)
				{
					VideoDriver = createDirectX9Driver(CreationParams, FileSystem, HWnd);
					if (!VideoDriver)
					{
						Printer.log("Could not create DIRECT3D9 Driver.", ELOG_LEVEL.ELL_ERROR);
					}
				}
				else
					Printer.log("DIRECT3D9 Driver was not compiled into this dll. Try another one.", ELOG_LEVEL.ELL_ERROR);

				break;

			case E_DRIVER_TYPE.EDT_SOFTWARE:
				version(IRR_COMPILE_WITH_SOFTWARE)
				{
					VideoDriver = createSoftwareDriver(CreationParams.WindowSize, CreationParams.Fullscreen, FileSystem, this);
				}
				else
					Printer.log("No Software driver support compiled in.",  ELOG_LEVEL.ELL_ERROR);
				
				break;

			case E_DRIVER_TYPE.EDT_BURNINGSVIDEO:
				version(IRR_COMPILE_WITH_BURNINGSVIDEO)
				{
					VideoDriver = createBurningVideoDriver(CreationParams, FileSystem, this);
				}
				else
					Printer.log("Burning's video driver was not compiled in.",  ELOG_LEVEL.ELL_ERROR);
				
				break;

			case E_DRIVER_TYPE.EDT_OPENGL:
				version(IRR_COMPILE_WITH_OPENGL)
				{
					VideoDriver = createOpenGLDriver(CreationParams, FileSystem, this);
				}
				else
					Printer.log("No OpenGL support compiled in.",  ELOG_LEVEL.ELL_ERROR);
				
				break;

			case E_DRIVER_TYPE.EDT_NULL:
				VideoDriver = createNullDriver(FileSystem, CreationParams.WindowSize);
				break;

			default:
				Printer.log("Unable to create video driver of unknown type.",  ELOG_LEVEL.ELL_ERROR);
				break;
			}
		}

		bool createWindow()
		{
			if ( Close )
				return false;

			if (CreationParams.DriverType == E_DRIVER_TYPE.EDT_OPENGL)
			{
				if (CreationParams.Bits == 16)
				{
					SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 4 );
					SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 4 );
					SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 4 );
					SDL_GL_SetAttribute( SDL_GL_ALPHA_SIZE, CreationParams.WithAlphaChannel?1:0 );
				}
				else
				{
					SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 8 );
					SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 8 );
					SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 8 );
					SDL_GL_SetAttribute( SDL_GL_ALPHA_SIZE, CreationParams.WithAlphaChannel?8:0 );
				}
				SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, CreationParams.ZBufferBits);

				if (CreationParams.Doublebuffer)
					SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
				if (CreationParams.Stereobuffer)
					SDL_GL_SetAttribute( SDL_GL_STEREO, 1 );
				if (CreationParams.AntiAlias>1)
				{
					SDL_GL_SetAttribute( SDL_GL_MULTISAMPLEBUFFERS, 1 );
					SDL_GL_SetAttribute( SDL_GL_MULTISAMPLESAMPLES, CreationParams.AntiAlias );
				}

				if(Window is null)
				{
					SDL_CreateWindowAndRenderer(Width, Height, SDL_Flags, &Window, &Renderer);
				}
				if(Window is null && CreationParams.AntiAlias > 1)
				{
					while (--CreationParams.AntiAlias > 1)
					{
						SDL_GL_SetAttribute( SDL_GL_MULTISAMPLESAMPLES, CreationParams.AntiAlias );
						SDL_CreateWindowAndRenderer(Width, Height, SDL_Flags, &Window, &Renderer);
						if (Window !is null)
							break;
					}
					if ( Window is null )
					{
						SDL_GL_SetAttribute( SDL_GL_MULTISAMPLEBUFFERS, 0 );
						SDL_GL_SetAttribute( SDL_GL_MULTISAMPLESAMPLES, 0 );
						SDL_CreateWindowAndRenderer(Width, Height, SDL_Flags, &Window, &Renderer);
						if (Window !is null)
							Printer.log("AntiAliasing disabled due to lack of support!" );
					}
				}

			}
			else if ( Window is null )
				SDL_CreateWindowAndRenderer(Width, Height, SDL_Flags, &Window, &Renderer);

			if ( Window is null && CreationParams.Doublebuffer)
			{
				// Try single buffer
				if (CreationParams.DriverType == E_DRIVER_TYPE.EDT_OPENGL)
					SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
				//SDL_Flags &= ~SDL_DOUBLEBUF;
				SDL_CreateWindowAndRenderer(Width, Height, SDL_Flags, &Window, &Renderer);
			}
			if ( Window is null )
			{
				Printer.log( "Could not initialize display!" );
				return false;
			}

			if(Renderer is null)
			{
				Renderer = SDL_CreateRenderer(Window, -1, 0);
			}

			return true;
		}

		void createKeyMap()
		{
			// I don't know if this is the best method  to create
			// the lookuptable, but I'll leave it like that until
			// I find a better version.

			auto b = appender(KeyMap);

			// buttons missing

			b.put(SKeyMap(SDLK_BACKSPACE, 	EKEY_CODE.KEY_BACK));
			b.put(SKeyMap(SDLK_TAB, 		EKEY_CODE.KEY_TAB));
			b.put(SKeyMap(SDLK_CLEAR, 		EKEY_CODE.KEY_CLEAR));
			b.put(SKeyMap(SDLK_RETURN, 		EKEY_CODE.KEY_RETURN));

			// combined modifiers missing

			b.put(SKeyMap(SDLK_PAUSE, 		EKEY_CODE.KEY_PAUSE));
			b.put(SKeyMap(SDLK_CAPSLOCK, 	EKEY_CODE.KEY_CAPITAL));

			// asian letter keys missing

			b.put(SKeyMap(SDLK_ESCAPE, 		EKEY_CODE.KEY_ESCAPE));

			// asian letter keys missing

			b.put(SKeyMap(SDLK_SPACE, 		EKEY_CODE.KEY_SPACE));
			b.put(SKeyMap(SDLK_PAGEUP, 		EKEY_CODE.KEY_PRIOR));
			b.put(SKeyMap(SDLK_PAGEDOWN, 	EKEY_CODE.KEY_NEXT));
			b.put(SKeyMap(SDLK_END, 		EKEY_CODE.KEY_END));
			b.put(SKeyMap(SDLK_HOME, 		EKEY_CODE.KEY_HOME));
			b.put(SKeyMap(SDLK_LEFT, 		EKEY_CODE.KEY_LEFT));
			b.put(SKeyMap(SDLK_UP, 			EKEY_CODE.KEY_UP));
			b.put(SKeyMap(SDLK_RIGHT, 		EKEY_CODE.KEY_RIGHT));
			b.put(SKeyMap(SDLK_DOWN, 		EKEY_CODE.KEY_DOWN));

			// select missing
			b.put(SKeyMap(SDLK_PRINTSCREEN, EKEY_CODE.KEY_PRINT));
			// execute missing
			b.put(SKeyMap(SDLK_PRINTSCREEN, EKEY_CODE.KEY_SNAPSHOT));

			b.put(SKeyMap(SDLK_INSERT, 		EKEY_CODE.KEY_INSERT));
			b.put(SKeyMap(SDLK_DELETE, 		EKEY_CODE.KEY_DELETE));
			b.put(SKeyMap(SDLK_HELP, 		EKEY_CODE.KEY_HELP));

			b.put(SKeyMap(SDLK_0, 			EKEY_CODE.KEY_KEY_0));
			b.put(SKeyMap(SDLK_1,			EKEY_CODE.KEY_KEY_1));
			b.put(SKeyMap(SDLK_2, 			EKEY_CODE.KEY_KEY_2));
			b.put(SKeyMap(SDLK_3, 			EKEY_CODE.KEY_KEY_3));
			b.put(SKeyMap(SDLK_4, 			EKEY_CODE.KEY_KEY_4));
			b.put(SKeyMap(SDLK_5, 			EKEY_CODE.KEY_KEY_5));
			b.put(SKeyMap(SDLK_6, 			EKEY_CODE.KEY_KEY_6));
			b.put(SKeyMap(SDLK_7, 			EKEY_CODE.KEY_KEY_7));
			b.put(SKeyMap(SDLK_8, 			EKEY_CODE.KEY_KEY_8));
			b.put(SKeyMap(SDLK_9, 			EKEY_CODE.KEY_KEY_9));

			b.put(SKeyMap(SDLK_a, 			EKEY_CODE.KEY_KEY_A));
			b.put(SKeyMap(SDLK_b, 			EKEY_CODE.KEY_KEY_B));
			b.put(SKeyMap(SDLK_c, 			EKEY_CODE.KEY_KEY_C));
			b.put(SKeyMap(SDLK_d, 			EKEY_CODE.KEY_KEY_D));
			b.put(SKeyMap(SDLK_e, 			EKEY_CODE.KEY_KEY_E));
			b.put(SKeyMap(SDLK_f, 			EKEY_CODE.KEY_KEY_F));
			b.put(SKeyMap(SDLK_g, 			EKEY_CODE.KEY_KEY_G));
			b.put(SKeyMap(SDLK_h, 			EKEY_CODE.KEY_KEY_H));
			b.put(SKeyMap(SDLK_i, 			EKEY_CODE.KEY_KEY_I));
			b.put(SKeyMap(SDLK_j, 			EKEY_CODE.KEY_KEY_J));
			b.put(SKeyMap(SDLK_k, 			EKEY_CODE.KEY_KEY_K));
			b.put(SKeyMap(SDLK_l, 			EKEY_CODE.KEY_KEY_L));
			b.put(SKeyMap(SDLK_m, 			EKEY_CODE.KEY_KEY_M));
			b.put(SKeyMap(SDLK_n, 			EKEY_CODE.KEY_KEY_N));
			b.put(SKeyMap(SDLK_o, 			EKEY_CODE.KEY_KEY_O));
			b.put(SKeyMap(SDLK_p, 			EKEY_CODE.KEY_KEY_P));
			b.put(SKeyMap(SDLK_q, 			EKEY_CODE.KEY_KEY_Q));
			b.put(SKeyMap(SDLK_r, 			EKEY_CODE.KEY_KEY_R));
			b.put(SKeyMap(SDLK_s, 			EKEY_CODE.KEY_KEY_S));
			b.put(SKeyMap(SDLK_t, 			EKEY_CODE.KEY_KEY_T));
			b.put(SKeyMap(SDLK_u, 			EKEY_CODE.KEY_KEY_U));
			b.put(SKeyMap(SDLK_v, 			EKEY_CODE.KEY_KEY_V));
			b.put(SKeyMap(SDLK_w, 			EKEY_CODE.KEY_KEY_W));
			b.put(SKeyMap(SDLK_x, 			EKEY_CODE.KEY_KEY_X));
			b.put(SKeyMap(SDLK_y, 			EKEY_CODE.KEY_KEY_Y));
			b.put(SKeyMap(SDLK_z, 			EKEY_CODE.KEY_KEY_Z));

			b.put(SKeyMap(SDLK_LGUI, 		EKEY_CODE.KEY_LWIN));
			b.put(SKeyMap(SDLK_RGUI, 		EKEY_CODE.KEY_RWIN));
			// apps missing
			b.put(SKeyMap(SDLK_POWER, 		EKEY_CODE.KEY_SLEEP)); //??

			b.put(SKeyMap(SDLK_KP_0, 		EKEY_CODE.KEY_NUMPAD0));
			b.put(SKeyMap(SDLK_KP_1, 		EKEY_CODE.KEY_NUMPAD1));
			b.put(SKeyMap(SDLK_KP_2, 		EKEY_CODE.KEY_NUMPAD2));
			b.put(SKeyMap(SDLK_KP_3, 		EKEY_CODE.KEY_NUMPAD3));
			b.put(SKeyMap(SDLK_KP_4, 		EKEY_CODE.KEY_NUMPAD4));
			b.put(SKeyMap(SDLK_KP_5, 		EKEY_CODE.KEY_NUMPAD5));
			b.put(SKeyMap(SDLK_KP_6, 		EKEY_CODE.KEY_NUMPAD6));
			b.put(SKeyMap(SDLK_KP_7, 		EKEY_CODE.KEY_NUMPAD7));
			b.put(SKeyMap(SDLK_KP_8, 		EKEY_CODE.KEY_NUMPAD8));
			b.put(SKeyMap(SDLK_KP_9, 		EKEY_CODE.KEY_NUMPAD9));
			b.put(SKeyMap(SDLK_KP_MULTIPLY, EKEY_CODE.KEY_MULTIPLY));
			b.put(SKeyMap(SDLK_KP_PLUS, 	EKEY_CODE.KEY_ADD));
		//	b.put(SKeyMap(SDLK_KP_, KEY_SEPARATOR));
			b.put(SKeyMap(SDLK_KP_MINUS, 	EKEY_CODE.KEY_SUBTRACT));
			b.put(SKeyMap(SDLK_KP_PERIOD, 	EKEY_CODE.KEY_DECIMAL));
			b.put(SKeyMap(SDLK_KP_DIVIDE, 	EKEY_CODE.KEY_DIVIDE));

			b.put(SKeyMap(SDLK_F1,  		EKEY_CODE.KEY_F1));
			b.put(SKeyMap(SDLK_F2,  		EKEY_CODE.KEY_F2));
			b.put(SKeyMap(SDLK_F3,  		EKEY_CODE.KEY_F3));
			b.put(SKeyMap(SDLK_F4,  		EKEY_CODE.KEY_F4));
			b.put(SKeyMap(SDLK_F5,  		EKEY_CODE.KEY_F5));
			b.put(SKeyMap(SDLK_F6,  		EKEY_CODE.KEY_F6));
			b.put(SKeyMap(SDLK_F7,  		EKEY_CODE.KEY_F7));
			b.put(SKeyMap(SDLK_F8,  		EKEY_CODE.KEY_F8));
			b.put(SKeyMap(SDLK_F9,  		EKEY_CODE.KEY_F9));
			b.put(SKeyMap(SDLK_F10, 		EKEY_CODE.KEY_F10));
			b.put(SKeyMap(SDLK_F11, 		EKEY_CODE.KEY_F11));
			b.put(SKeyMap(SDLK_F12, 		EKEY_CODE.KEY_F12));
			b.put(SKeyMap(SDLK_F13, 		EKEY_CODE.KEY_F13));
			b.put(SKeyMap(SDLK_F14, 		EKEY_CODE.KEY_F14));
			b.put(SKeyMap(SDLK_F15, 		EKEY_CODE.KEY_F15));
			// no higher F-keys

			b.put(SKeyMap(SDLK_NUMLOCKCLEAR,EKEY_CODE.KEY_NUMLOCK));
			b.put(SKeyMap(SDLK_SCROLLLOCK, 	EKEY_CODE.KEY_SCROLL));
			b.put(SKeyMap(SDLK_LSHIFT, 		EKEY_CODE.KEY_LSHIFT));
			b.put(SKeyMap(SDLK_RSHIFT, 		EKEY_CODE.KEY_RSHIFT));
			b.put(SKeyMap(SDLK_LCTRL,  		EKEY_CODE.KEY_LCONTROL));
			b.put(SKeyMap(SDLK_RCTRL,  		EKEY_CODE.KEY_RCONTROL));
			b.put(SKeyMap(SDLK_LALT,  		EKEY_CODE.KEY_LMENU));
			b.put(SKeyMap(SDLK_RALT,  		EKEY_CODE.KEY_RMENU));

			b.put(SKeyMap(SDLK_PLUS,   		EKEY_CODE.KEY_PLUS));
			b.put(SKeyMap(SDLK_COMMA,  		EKEY_CODE.KEY_COMMA));
			b.put(SKeyMap(SDLK_MINUS,  		EKEY_CODE.KEY_MINUS));
			b.put(SKeyMap(SDLK_PERIOD, 		EKEY_CODE.KEY_PERIOD));

			// some special keys missing
			KeyMap = b.data;
			KeyMap.sort();
		}

		SDL_Renderer* Renderer;
		SDL_Window* Window;
		int SDL_Flags;
		
		version(IRR_COMPILE_WITH_JOYSTICK_EVENTS)
		{
			SDL_Joystick*[] Joysticks;
		}

		int MouseX, MouseY;
		uint MouseButtonStates;

		uint Width, Height;

		bool Resizable;
		bool WindowHasFocus;
		bool WindowMinimized;

		struct SKeyMap
		{
			this(int x11, int win32)
			{
				SDLKey = x11;
				Win32Key = win32;
			}

			int SDLKey;
			int Win32Key;

			int opCmp()(auto ref const SKeyMap o) const
			{
				if(SDLKey < o.SDLKey)
					return -1;
				else if(SDLKey > o.SDLKey)
					return 1;
				return 0;
			}
		}

		SKeyMap[] KeyMap;
		SDL_version Info;
	}
}