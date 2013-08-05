// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IMeshWriter;

import irrlicht.scene.IMesh;
import irrlicht.scene.EMeshWriterEnums;
import irrlicht.io.IWriteFile;

/// Interface for writing meshes
interface IMeshWriter
{
	/// Get the type of the mesh writer
	/**
	* For own implementations, use MAKE_IRR_ID as shown in the
	* EMESH_WRITER_TYPE enumeration to return your own unique mesh
	* type id.
	* Returns: Type of the mesh writer. 
	*/
	EMESH_WRITER_TYPE getType() const;

	/// Write a static mesh.
	/**
	* Params:
	* 	file=  File handle to write the mesh to.
	* 	mesh=  Pointer to mesh to be written.
	* 	flags=  Optional flags to set properties of the writer.
	* Returns: True if sucessful 
	*/
	bool writeMesh(IWriteFile file, IMesh mesh,
						E_MESH_WRITER_FLAGS flags = E_MESH_WRITER_FLAGS.EMWF_NONE);

	// Writes an animated mesh
	// for future use, no writer is able to write animated meshes currently
	/* \return Returns true if sucessful */
	//bool writeAnimatedMesh(IWriteFile* file,
	// IAnimatedMesh* mesh,
	// int flags=EMWF_NONE);
}