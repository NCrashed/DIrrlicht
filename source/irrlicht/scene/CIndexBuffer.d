// Copyright (C) 2008-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.CIndexBuffer;

import irrlicht.scene.IIndexBuffer;
import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.video.SVertexIndex;
import std.traits;
import std.container;
import std.range;

class CIndexBuffer : IIndexBuffer
{
	protected class CIndexRange(InnerRange) : IndexRange
	{
		this()(auto ref InnerRange toWrap)
		{
			range = toWrap;
		}

		bool empty() @property 
		{
			return range.empty;
		}

		uint front() @property
		{
			return cast(uint)range.front();
		}

		void popFront()
		{
			range.popFront;
		}

		uint back() @property
		{
			return cast(uint)range.back();
		}

		void popBack()
		{
			range.popBack;
		}

		IndexRange save() @property
		{
			return new CIndexRange!InnerRange(range.save);
		}

		uint opIndex(size_t n)
		{
			return cast(uint)range[n];
		}

		size_t length() @property
		{
			return range.length;
		}

		private InnerRange range;
	}

	protected interface IIndexList
	{
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

		E_INDEX_TYPE getType() const;
	}

	protected class CSpecificIndexList(IndexType) : IIndexList
		if(isUnsigned!IndexType)
	{
		Array!IndexType Indices;

		size_t stride() const 
		{
			return IndexType.sizeof;
		}

		size_t size() const 
		{
			return Indices.length();
		}

		void insertBack(const uint element)
		{
			Indices.insertBack(cast(IndexType)element);
		}

		uint opIndex(size_t index) const
		{
			return cast(uint)((cast(Array!IndexType)(Indices))[index]);
		}

		uint getLast() 
		{
			return cast(IndexType)Indices.back();
		}

		void setValue(size_t index, uint value)
		{
			Indices[index] = cast(IndexType)value;
		}

		void setCapacity(size_t usedNow)
		{
			Indices.reserve(usedNow);
		}

		void reallocate(size_t new_size)
		{
			Indices.reserve(new_size);
		}

		size_t capacity() const
		{
			return (cast(Array!IndexType)(Indices)).capacity();
		}

		IndexRange opSlice(size_t a, size_t b) 
		{
			assert(a <= b && b <= Indices.length);
			return new CIndexRange!(typeof(Indices.opSlice(a,b)))(Indices.opSlice(a, b));
		}

		size_t opDollar() const
		{
			return Indices.length;
		}

		void clear()
		{
			Indices.clear();
		}

		E_INDEX_TYPE getType() const
		{
			static if(is(IndexType == ushort))
				return E_INDEX_TYPE.EIT_16BIT;
			else
				return E_INDEX_TYPE.EIT_32BIT;
		}
	}

	IIndexList Indices;

	this(E_INDEX_TYPE IndexType)
	{
		Indices = null;
		MappingHint = E_HARDWARE_MAPPING.EHM_NEVER;
		ChangedID = 1;
		setType(IndexType);
	}

	this(const IIndexBuffer IndexBufferCopy)
	{
		Indices = null;
		MappingHint = E_HARDWARE_MAPPING.EHM_NEVER;
		ChangedID = 1;
		setType(IndexBufferCopy.getType());
		reallocate(IndexBufferCopy.size());

		for (size_t n = 0; n<IndexBufferCopy.size(); ++n)
			insertBack(IndexBufferCopy[n]);
	}

	//void setType(E_INDEX_TYPE IndexType);
	void setType(E_INDEX_TYPE IndexType)
	{
		IIndexList NewIndices = null;

		final switch (IndexType)
		{
			case E_INDEX_TYPE.EIT_16BIT:
			{
				NewIndices = new CSpecificIndexList!ushort();
				break;
			}
			case E_INDEX_TYPE.EIT_32BIT:
			{
				NewIndices = new CSpecificIndexList!uint();
				break;
			}
		}

		if (Indices !is null)
		{
			NewIndices.reallocate( Indices.size() );

			for(size_t n=0;n < Indices.size(); ++n)
				NewIndices.insertBack(Indices[n]);
		}

		Indices.clear();
		Indices = NewIndices;
	}

	IndexRange getData() 
	{
		return Indices[0 .. $];
	}

	E_INDEX_TYPE getType() const 
	{
		return Indices.getType();
	}

	size_t stride() const 
	{
		return Indices.stride();
	}

	size_t size() const
	{
		return Indices.size();
	}

	void insertBack(const uint element)
	{
		Indices.insertBack(element);
	}

	uint opIndex(size_t index) const
	{
		return Indices[index];
	}

	uint getLast()
	{
		return Indices.getLast();
	}

	void setValue(size_t index, uint value)
	{
		Indices.setValue(index, value);
	}

	void setCapacity(size_t usedNow)
	{
		Indices.setCapacity(usedNow);
	}

	void reallocate(size_t new_size)
	{
		Indices.reallocate(new_size);
	}

	size_t capacity() const
	{
		return Indices.capacity();
	}

	IndexRange opSlice(size_t a, size_t b) 
	{
		return Indices.opSlice(a, b);
	}

	size_t opDollar() const
	{
		return Indices.size();
	}

	//! get the current hardware mapping hint
	E_HARDWARE_MAPPING getHardwareMappingHint() const
	{
		return MappingHint;
	}

	//! set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING NewMappingHint )
	{
		MappingHint=NewMappingHint;
	}

	//! flags the mesh as changed, reloads hardware buffers
	void setDirty()
	{
		++ChangedID;
	}

	//! Get the currently used ID for identification of changes.
	/** This shouldn't be used for anything outside the VideoDriver. */
	size_t getChangedID() const 
	{
		return ChangedID;
	}

	E_HARDWARE_MAPPING MappingHint;
	size_t ChangedID;
}