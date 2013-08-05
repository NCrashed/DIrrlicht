// Copyright (C) 2008-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IVertexBuffer;

import irrlicht.video.S3DVertex;
import irrlicht.scene.EHardwareBufferFlags;

interface IVertexBuffer
{
	void* getData();

	E_VERTEX_TYPE getType() const;

	void setType(E_VERTEX_TYPE vertexType);

	size_t stride() const;

	size_t size() const;

	void push_back()(auto ref const S3DVertex element);

	ref S3DVertex opIndex(const size_t index);

	ref S3DVertex getLast();

	void set_used(size_t usedNow);

	void reallocate(size_t new_size);

	size_t allocated_size() const;

	S3DVertex* pointer();

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