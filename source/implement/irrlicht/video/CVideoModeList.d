// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.CVideoModeList;

import irrlicht.video.IVideoModeList;
import irrlicht.core.dimension2d;
import std.math;
import std.algorithm;

class CVideoModeList : IVideoModeList
{
	/// constructor
	this()
	{
		Desktop.depth = 0;
		Desktop.size = dimension2du(0,0);
	}

	/// Gets amount of video modes in the list.
	size_t getVideoModeCount() const
	{
		return VideoModes.length;
	}

	/// Returns the screen size of a video mode in pixels.
	dimension2du getVideoModeResolution()(size_t modeNumber) const
	{
		if (modeNumber >= VideoModes.length)
			return dimension2du(0,0);

		return VideoModes[modeNumber].size;
	}

	/// Returns the screen size of an optimal video mode in pixels.
	dimension2du getVideoModeResolution()(
		auto ref const dimension2du minSize, 
		auto ref const dimension2du maxSize) const
	{
		size_t best = VideoModes.length;
		// if only one or no mode
		if(bes < 2)
			return getVideoModeResolution(0);

		foreach(ref mode; VideoModes)
		{
			if (mode.size.Width  >= minSize.Width &&
				mode.size.Height >= minSize.Height &&
				mode.size.Width  <= maxSize.Width &&
				mode.size.Height <= maxSize.Height)
			{
				best = i;
			}
		}

		// we take the last one found, the largest one fitting
		if (best < VideoModes.length)
			return VideoModes[best].size;

		immutable minArea = minSize.getArea();
		immutable maxArea = maxSize.getArea();
		uint minDist = uint.max;
		best = 0;

		foreach(ref mode; VideoModes)
		{
			immutable area = mode.size.getArea();
			immutable dist = cast(uint)fmin(abs(cast(int)(minArea-area)), abs(cast(int)(maxArea-area)));
			if(dist < minDist)
			{
				minDist = dist;
				best = i;
			}
		}

		return VideoModes[best].size;
	}

	/// Returns the pixel depth of a video mode in bits.
	int getVideoModeDepth(size_t modeNumber) const
	{
		if(modeNumber >= VideoModes.length)
			return 0;

		return VideoModes[modeNumber].depth;
	}

	/// Returns current desktop screen resolution.
	auto ref const dimension2du getDesktopResolution()() const
	{
		return Desktop.size;
	}

	/// Returns the pixel depth of a video mode in bits.
	int getDesktopDepth() const
	{
		return Desktop.depth;
	}

	/// adds a new mode to the list
	void addMode()(auto ref const dimension2du size, int depth)
	{
		SVideoMode m;
		m.depth = depth;
		m.size = size;

		foreach(ref mode; VideoModes)
		{
			if(mode == m)
				return;
		}

		VideoModes ~= m;
		sort(VideoModes); // TODO: could be replaced by inserting into right place
	}

	void setDesktop()(int desktopDepth, auto ref const dimension2du desktopSize)
	{
		Desktop.depth = desktopDepth;
		Desktop.size = desktopSize;
	}

	private struct SVideoMode
	{
		dimension2du size;
		int depth;

		bool opEqual()(auto ref const SVideoMode other) const
		{
			return size == other.size && depth == other.depth;
		}

		int opCmp()(auto ref const SVideoMode other) const
		{
			if (size.Width < other.size.Width ||
				(size.Width == other.size.Width &&
				size.Height < other.size.Height) ||
				(size.Width == other.size.Width &&
				size.Height == other.size.Height &&
				depth < other.depth))
			{
				return -1;
			}
			else if (size.Width > other.size.Width ||
				(size.Width == other.size.Width &&
				size.Height > other.size.Height) ||
				(size.Width == other.size.Width &&
				size.Height == other.size.Height &&
				depth > other.depth))
			{
				return 1;
			}
			return 0;
		}
	}

	SVideoMode[] VideoModes = [];
	SVideoMode Desktop;
};