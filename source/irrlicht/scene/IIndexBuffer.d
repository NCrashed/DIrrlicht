// Copyright (C) 2008-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IIndexBuffer;

import irrlicht.video.SVertexIndex;
import irrlicht.scene.EHardwareBufferFlags;
import std.range;

interface IIndexBuffer
{
	interface IndexRange
	{
		bool empty() @property;
		uint front() @property;
		void popFront();
		uint back() @property;
		void popBack();
		IndexRange save() @property;
		uint opIndex(size_t n);
		size_t length()  @property;
		
		final size_t opDollar()
		{
			return length();
		}
	}

	static assert(isRandomAccessRange!IndexRange);

	IndexRange getData();

	E_INDEX_TYPE getType() const;

	void setType(E_INDEX_TYPE IndexType);

	size_t stride() const;

	size_t size() const;

	void insertBack(const uint element);

	uint opIndex(size_t index) const;

	uint getLast();

	void setValue(size_t index, uint value);

	void setCapacity(size_t usedNow);

	void reallocate(size_t new_size);

	size_t capacity() const;

	IndexRange opSlice(size_t a, size_t b);
	size_t opDollar() const;

	/// get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint() const;

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING NewMappingHint );

	/// flags the meshbuffer as changed, reloads hardware buffers
	void setDirty();

	/// Get the currently used ID for identification of changes.
	/** 
	* Warning: This shouldn't be used for anything outside the VideoDriver. 
	*/
	size_t getChangedID() const;
}