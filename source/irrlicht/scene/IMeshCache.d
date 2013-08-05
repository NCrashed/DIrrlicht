// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IMeshCache;

import irrlicht.scene.IMesh;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.IAnimatedMeshSceneNode;
import irrlicht.scene.IMeshLoader;
import irrlicht.io.path;

/// The mesh cache stores already loaded meshes and provides an interface to them.
/**
* You can access it using ISceneManager.getMeshCache(). All existing
* scene managers will return a pointer to the same mesh cache, because it
* is shared between them. With this interface, it is possible to manually
* add new loaded meshes (if ISceneManager.getMesh() is not sufficient),
* to remove them and to iterate through already loaded meshes. 
*/
interface IMeshCache
{
	/// Adds a mesh to the internal list of loaded meshes.
	/**
	* Usually, ISceneManager.getMesh() is called to load a mesh
	* from a file. That method searches the list of loaded meshes if
	* a mesh has already been loaded and returns a pointer to if it
	* is in that list and already in memory. Otherwise it loads the
	* mesh. With IMeshCache.addMesh(), it is possible to pretend
	* that a mesh already has been loaded. This method can be used
	* for example by mesh loaders who need to load more than one mesh
	* with one call. They can add additional meshes with this method
	* to the scene manager. The COLLADA loader for example uses this
	* method.
	* Params:
	* 	name=  Name of the mesh. When calling
	* ISceneManager.getMesh() with this name it will return the mesh
	* set by this method.
	* 	mesh=  Pointer to a mesh which will now be referenced by
	* this name. 
	*/
	void addMesh(const Path name, IAnimatedMesh mesh);

	/// Removes the mesh from the cache.
	/**
	* After loading a mesh with getMesh(), the mesh can be
	* removed from the cache using this method, freeing a lot of
	* memory.
	* Params:
	* 	mesh = Pointer to the mesh which shall be removed. 
	*/
	void removeMesh(const IMesh mesh);

	/// Returns amount of loaded meshes in the cache.
	/**
	* You can load new meshes into the cache using getMesh() and
	* addMesh(). If you ever need to access the internal mesh cache,
	* you can do this using removeMesh(), getMeshNumber(),
	* getMeshByIndex() and getMeshName().
	* Returns: Number of meshes in cache. 
	*/
	size_t getMeshCount() const;

	/// Returns current index number of the mesh or -1 when not found.
	/**
	* Params:
	* 	mesh=  Pointer to the mesh to search for.
	* Returns: Index of the mesh in the cache, or -1 if not found. 
	*/
	ptrdiff_t getMeshIndex(const IMesh mesh) const;

	/// Returns a mesh based on its index number.
	/**
	* Params:
	* 	index=  Index of the mesh, number between 0 and
	* getMeshCount()-1.
	* Note that this number is only valid until a new mesh is loaded
	* or removed.
	* Returns: Pointer to the mesh or 0 if there is none with this
	* number. 
	*/
	IAnimatedMesh getMeshByIndex(size_t index);

	/// Returns a mesh based on its name (often a filename).
	/**
	* Deprecated:  Use getMeshByName() instead. This method may be removed by
	* Irrlicht 1.9 
	*/
	deprecated final IAnimatedMesh getMeshByFilename(const Path filename)
	{
		return getMeshByName(filename);
	}

	/// Get the name of a loaded mesh, based on its index. (Name is often identical to the filename).
	/**
	* Deprecated:  Use getMeshName() instead. This method may be removed by
	* Irrlicht 1.9 
	*/
	deprecated final const Path getMeshFilename(size_t index) const
	{
		return getMeshName(index).internalName;
	}

	/// Get the name of a loaded mesh, if there is any. (Name is often identical to the filename).
	/**
	* Deprecated:  Use getMeshName() instead. This method may be removed by
	* Irrlicht 1.9 
	*/
	deprecated final const Path getMeshFilename(const IMesh mesh) const
	{
		return getMeshName(mesh).internalName;
	}

	/// Renames a loaded mesh.
	/**
	* Deprecated:  Use renameMesh() instead. This method may be removed by
	* Irrlicht 1.9 
	*/
	deprecated final bool setMeshFilename(size_t index, const Path filename)
	{
		return renameMesh(index, filename);
	}

	/// Renames a loaded mesh.
	/**
	* Deprecated:  Use renameMesh() instead. This method may be removed by
	* Irrlicht 1.9 
	*/
	deprecated final bool setMeshFilename(const IMesh mesh, const Path filename)
	{
		return renameMesh(mesh, filename);
	}

	/// Returns a mesh based on its name.
	/**
	* Params:
	* 	name=  Name of the mesh. Usually a filename.
	* Returns: Pointer to the mesh or 0 if there is none with this number. 
	*/
	IAnimatedMesh getMeshByName(const Path name);

	/// Get the name of a loaded mesh, based on its index.
	/**
	* Params:
	* 	index=  Index of the mesh, number between 0 and getMeshCount()-1.
	* Returns: The name if mesh was found and has a name, else	the path is empty. 
	*/
	auto ref const SNamedPath getMeshName(size_t index) const;

	/// Get the name of the loaded mesh if there is any.
	/**
	* Params:
	* 	mesh=  Pointer to mesh to query.
	* Returns: The name if mesh was found and has a name, else	the path is empty. 
	*/
	auto ref const SNamedPath getMeshName(const IMesh mesh) const;

	/// Renames a loaded mesh.
	/**
	* Note that renaming meshes might change the ordering of the
	* meshes, and so the index of the meshes as returned by
	* getMeshIndex() or taken by some methods will change.
	* Params:
	* 	index=  The index of the mesh in the cache.
	* 	name=  New name for the mesh.
	* Returns: True if mesh was renamed. 
	*/
	bool renameMesh(size_t index, const Path name);

	/// Renames the loaded mesh
	/**
	* Note that renaming meshes might change the ordering of the
	* meshes, and so the index of the meshes as returned by
	* getMeshIndex() or taken by some methods will change.
	* Params:
	* 	mesh=  Mesh to be renamed.
	* 	name=  New name for the mesh.
	* Returns: True if mesh was renamed. 
	*/
	bool renameMesh(const IMesh mesh, const Path name);

	/// Check if a mesh was already loaded.
	/**
	* Params:
	* 	name=  Name of the mesh. Usually a filename.
	* Returns: True if the mesh has been loaded, else false. 
	*/
	bool isMeshLoaded(const Path name);

	/// Clears the whole mesh cache, removing all meshes.
	/**
	* All meshes will be reloaded completely when using ISceneManager.getMesh()
	* after calling this method.
	* Warning: If you have pointers to meshes that were loaded with ISceneManager.getMesh()
	* and you did not grab them, then they may become invalid. 
	*/
	void clear();

	/// Clears all meshes that are held in the mesh cache but not used anywhere else.
	/**
	* Warning: If you have pointers to meshes that were loaded with ISceneManager.getMesh()
	* and you did not grab them, then they may become invalid. 
	*/
	void clearUnusedMeshes();
}