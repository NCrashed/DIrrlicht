// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.SMesh;

import irrlicht.scene.EHardwareBufferFlags;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.SMaterial;
import irrlicht.scene.IMesh;
import irrlicht.scene.IMeshBuffer;
import irrlicht.core.aabbox3d;

/// Simple implementation of the IMesh interface.
class SMesh : IMesh
{
	/// constructor
	this()
	{
		MeshBuffers = new IMeshBuffer[0];
	}

	~this()
	{
		clear();
	}

	/// clean mesh
	void clear()
	{
		foreach(ref buf; MeshBuffers)
			buf = null;

		MeshBuffers = [];
		BoundingBox.reset ( 0.0f, 0.0f, 0.0f );
	}


	/// returns amount of mesh buffers.
	size_t getMeshBufferCount() const
	{
		return MeshBuffers.length;
	}

	/// returns pointer to a mesh buffer
	IMeshBuffer getMeshBuffer(size_t nr)
	{
		return MeshBuffers[nr];
	}

	/// returns a meshbuffer which fits a material
	/** reverse search */
	IMeshBuffer getMeshBuffer(const SMaterial material)
	{
		foreach_reverse(buffer; MeshBuffers)
		{
			if ( material == buffer.getMaterial())
				return buffer;
		}

		return null;
	}

	/// returns an axis aligned bounding box
	aabbox3df getBoundingBox() const
	{
		return BoundingBox;
	}

	/// set user axis aligned bounding box
	void setBoundingBox(aabbox3df box)
	{
		BoundingBox = box;
	}

	/// recalculates the bounding box
	void recalculateBoundingBox()
	{
		BoundingBox.reset(0.0f, 0.0f, 0.0f);
		if (MeshBuffers.length > 0)
		{
			foreach(buffer; MeshBuffers)
				BoundingBox.addInternalBox(buffer.getBoundingBox());
		}
	}

	/// adds a MeshBuffer
	/** Warning: The bounding box is not updated automatically. */
	void addMeshBuffer(IMeshBuffer buf)
	{
		if (buf !is null)
		{
			MeshBuffers ~= buf;
		}
	}

	/// sets a flag of all contained materials to a new value
	void setMaterialFlag(E_MATERIAL_FLAG flag, bool newvalue)
	{
		foreach(meshBuffer; MeshBuffers)
			meshBuffer.getMaterial().setFlag(flag, newvalue);
	}

	/// set the hardware mapping hint, for driver
	void setHardwareMappingHint( E_HARDWARE_MAPPING newMappingHint, E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX )
	{
		foreach(meshBuffer; MeshBuffers)
			meshBuffer.setHardwareMappingHint(newMappingHint, buffer);
	}

	/// flags the meshbuffer as changed, reloads hardware buffers
	void setDirty(E_BUFFER_TYPE buffer = E_BUFFER_TYPE.EBT_VERTEX_AND_INDEX)
	{
		foreach(meshBuffer; MeshBuffers)
			meshBuffer.setDirty(buffer);
	}

	/// foreach implementation
	int opApply(int delegate(IMeshBuffer) dg)
	{
		int result = 0; 

		foreach(meshBuffer; MeshBuffers) 
		{ 
			result = dg(meshBuffer); 
			if (result) break; 
		} 

		return result;
	}

	/// foreach_reverse implementation
	int opApplyReverse(int delegate(IMeshBuffer) dg)
	{
		int result = 0; 

		foreach_reverse(meshBuffer; MeshBuffers)  
		{ 
			result = dg(meshBuffer); 
			if (result) break; 
		} 

		return result;
	}

	/// foreach implementation with indexing
	int opApply(int delegate(size_t, IMeshBuffer) dg)
	{
		int result = 0; 

		foreach(i, meshBuffer; MeshBuffers) 
		{ 
			result = dg(i, meshBuffer); 
			if (result) break; 
		}

		return result;
	}

	/// foreach_reverse implementation with indexing
	int opApplyReverse(int delegate(size_t, IMeshBuffer) dg)
	{
		int result = 0; 

		foreach_reverse(i, meshBuffer; MeshBuffers) 
		{ 
			result = dg(i, meshBuffer); 
			if (result) break; 
		}

		return result;
	}

	private
	{
		/// The meshbuffers of this mesh
		IMeshBuffer[] MeshBuffers;

		/// The bounding box of this mesh
		aabbox3df BoundingBox;
	}
};
