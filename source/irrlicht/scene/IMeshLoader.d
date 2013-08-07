// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IMeshLoader;

import irrlicht.io.path;
import irrlicht.io.IReadFile;
import irrlicht.scene.IAnimatedMesh;

/// Class which is able to load an animated mesh from a file.
/** 
* If you want Irrlicht be able to load meshes of
* currently unsupported file formats (e.g. .cob), then implement
* this and add your new Meshloader with
* ISceneManager.addExternalMeshLoader() to the engine. 
*/
interface IMeshLoader
{
	/// Returns true if the file might be loaded by this class.
	/** 
	* This decision should be based on the file extension (e.g. ".cob")
	* only.
	* Params:
	* filename = Name of the file to test.
	*
	* Returns: True if the file might be loaded by this class. 
	*/
	bool isALoadableFileExtension(const Path filename) const;

	/// Creates/loads an animated mesh from the file.
	/** 
	* Params:
	* file = File handler to load the file from.
	*
	* Returns: Pointer to the created mesh. Returns 0 if loading failed. 
	*/
	IAnimatedMesh* createMesh(IReadFile file);
}
