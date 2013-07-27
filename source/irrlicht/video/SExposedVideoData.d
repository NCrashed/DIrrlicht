// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.video.SExposedVideoData;

// forward declarations for internal pointers
interface IDirect3D9 {}
interface IDirect3DDevice9 {}
interface IDirect3D8 {}
interface IDirect3DDevice8 {}

//! structure for holding data describing a driver and operating system specific data.
/** This data can be retrived by IVideoDriver::getExposedVideoData(). Use this with caution.
This only should be used to make it possible to extend the engine easily without
modification of its source. Note that this structure does not contain any valid data, if
you are using the software or the null device.
*/
struct SExposedVideoData
{
	this(void* Window) 
	{
		OpenGLWin32.HDc  = null; 
		OpenGLWin32.HRc  = null; 
		OpenGLWin32.HWnd = Window;
	}

	union
	{
		struct HolderD3D9
		{
			//! Pointer to the IDirect3D9 interface
			IDirect3D9 D3D9 = null;

			//! Pointer to the IDirect3DDevice9 interface
			IDirect3DDevice9 D3DDev9 = null;

			//! Window handle.
			/** Get with for example HWND h = reinterpret_cast<HWND>(exposedData.D3D9.HWnd) */
			void* HWnd = null;

		}
		HolderD3D9 D3D9;

		struct HolderD3D8
		{
			//! Pointer to the IDirect3D8 interface
			IDirect3D8 D3D8 = null;

			//! Pointer to the IDirect3DDevice8 interface
			IDirect3DDevice8 D3DDev8 = null;

			//! Window handle.
			/** Get with for example with: HWND h = reinterpret_cast<HWND>(exposedData.D3D8.HWnd) */
			void* HWnd = null;

		} 
		HolderD3D8 D3D8;

		struct HolderOpenGLWin32
		{
			//! Private GDI Device Context.
			/** Get if for example with: HDC h = reinterpret_cast<HDC>(exposedData.OpenGLWin32.HDc) */
			void* HDc = null;

			//! Permanent Rendering Context.
			/** Get if for example with: HGLRC h = reinterpret_cast<HGLRC>(exposedData.OpenGLWin32.HRc) */
			void* HRc = null;

			//! Window handle.
			/** Get with for example with: HWND h = reinterpret_cast<HWND>(exposedData.OpenGLWin32.HWnd) */
			void* HWnd = null;
		} 
		HolderOpenGLWin32 OpenGLWin32;

		struct HolderOpenGLLinux
		{
			// XWindow handles
			void* X11Display = null;
			void* X11Context = null;
			ulong X11Window;
		} 
		HolderOpenGLLinux OpenGLLinux;
	}
}