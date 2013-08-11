// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.COSOperator;

import irrlicht.IOSOperator;
import irrlicht.core.coreutil;
import std.string;

version(IRR_COMPILE_WITH_X11_DEVICE)
{
	import irrlicht.CIrrDeviceLinux;
}
version(Posix)
{
	import std.c.linux.linux;
}
version(Windows)
{
	import core.sys.windows.windows;
}
version(OSX)
{
	// should declare prototypes and link myself?
	static assert("Fix that, cannot find specific import for osx");
}

/// The Operating system operator provides operation system specific methods and informations.
class COSOperator : IOSOperator
{
	version(IRR_COMPILE_WITH_X11_DEVICE)
	{
		this(string osversion, CIrrDeviceLinux device)
		{
			OperatingSystem = osversion;
			IrrDeviceLinux = device;
		}
	} 
	else
	{
		this(string osversion)
		{
			OperatingSystem = osversion;
		}
	}

	/// Get the current operation system version as string.
	string getOperatingSystemVersion() const
	{
		return OperatingSystem;
	}

	/// Copies text to the clipboard
	void copyToClipboard(string text) const
	{
		if(text.length == 0)
			return;

		version(Windows)
		{
			if(!OpenClipboard(NULL))
				return;

			EmptyClipboard();

			HGLOBAL clipbuffer;
			char* buffer;

			clipbuffer = GlobalAlloc(GMEM_DDESHARE, text.length+1);
			buffer = cast(char*)GlobalLock(clipbuffer);

			for(size_t i = 0; i<text.length; i++)
			{
				buffer[i] = text[i];
			}
			buffer[text.length] = '\0';

			GlobalUnlock(clipbuffer);
			SetClipboardData(CF_TEXT, clipbuffer);
			CloseClipboard();
		}
		version(OSX)
		{
			OSXCopyToClipboard(text.toStringz());
		}
		version(IRR_COMPILE_WITH_X11_DEVICE)
		{
			if(IrrDeviceLinux !is null)
				IrrDeviceLinux.copyToClipboard(text);
		}
	}

	/// Get text from the clipboard
	/**
	* Returns: Returns empty string if no string is in there. 
	*/
	string getTextFromClipboard() const
	{
		version(Windows)
		{
			if(!OpenClipboard(NULL))
				return "";

			char* buffer;

			HANDLE hData = GetClipboardData(CF_TEXT);
			buffer = cast(char*)GlobalLock(hData);
			string ret = fromStringz(buffer);
			GlobalUnlock(hData);
			CloseClipboard();

			return ret;
		}
		else version(OSX)
		{
			return OSXCopyFromClipboard().fromStringz();
		}
		else version(IRR_COMPILE_WITH_X11_DEVICE)
		{
			if (IrrDeviceLinux !is null)
				return IrrDeviceLinux.getTextFromClipboard();
			return "";
		}
		else
			return "";
	}

	/// Get the processor speed in megahertz
	/**
	* Params:
	* 	MHz=  The integer variable to store the speed in.
	* Returns: True if successful, false if not 
	*/
	bool getProcessorSpeedMHz(out size_t MHz) const
	{
		version(Windows)
		{
			LONG Error;

			HKEY Key;
			Error = RegOpenKeyEx(HKEY_LOCAL_MACHINE,
					__TEXT("HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0".toStringz()),
					0, KEY_READ, &Key);

			if(Error != ERROR_SUCCESS)
				return false;

			DWORD Speed = 0;
			DWord Size = Speed.sizeof;
			Error = RegQueryValueEx(Key, __TEXT("~MHz".toStringz()), NULL, NULL, cast(LPBYTE)&Speed, &Size);

			RegCloseKey(Key);

			if (Error != ERROR_SUCCESS)
				return false;
			else
				MHz = Speed;

			return true;
		}
		else version(OSX)
		{
			struct clockinfo 
			{
				int	hz;			// clock frequency
				int	tick;		// micro-seconds per hz tick
				int	tickadj;	// clock skew rate for adjtime() 
				int	stathz;		// statistics clock frequency 
				int	profhz;		// profiling clock frequency 
			}

			clockinfo CpuClock;
			size_t Size = sizeof(clockinfo);

			if (!sysctlbyname("kern.clockrate", &CpuClock, &Size, 0, 0))
				return false;
			else 
				MHz = CpuClock.hz;

			return true;
		}
		else // could probably be read from "/proc/cpuinfo" or "/proc/cpufreq"
			return false;
	}

	/// Get the total and available system RAM
	/**
	* Params:
	* 	Total=  will contain the total system memory
	* 	Avail=  will contain the available memory
	* Returns: True if successful, false if not 
	*/
	bool getSystemMemory(out size_t Total, out size_t Avail) const
	{
		version(Windows)
		{
			MEMORYSTATUS MemoryStatus;
			MemoryStatus.dwLength = MEMORYSTATUS.sizeof;

			// cannot fail
			GlobalMemoryStatus(&MemoryStatus);

			Total = cast(size_t)(MemoryStatus.dwTotalPhys >> 10);
			Avail = cast(size_t)(MemoryStatus.dwAvailPhys >> 10);
			return true;
		}
		else version(Posix)
		{
			///TODO: implement for non-availablity of symbols/features
			auto ps = sysconf(_SC_PAGESIZE);
			auto pp = sysconf(_SC_PHYS_PAGES);
			auto ap = sysconf(_SC_AVPHYS_PAGES);

			if((ps == -1) || (pp == -1) || (ap == -1))
				return false;

			Total = cast(size_t)(ps * cast(long)pp >> 10);
			Avail = cast(size_t)(ps * cast(long)ap >> 10);
			return true;
		}
		else version(OSX)
		{
			///TODO: implement for OSX
			return false;
		}
		else
			return false;
	}

	private
	{
		string OperatingSystem;

		version(IRR_COMPILE_WITH_X11_DEVICE)
		{
			CIrrDeviceLinux IrrDeviceLinux;
		}
	}
}