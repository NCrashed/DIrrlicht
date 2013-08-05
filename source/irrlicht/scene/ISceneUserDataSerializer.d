// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneUserDataSerializer;

import irrlicht.scene.ISceneNode;
import irrlicht.io.IAttributes;

/// Interface to read and write user data to and from .irr files.
/**
* This interface is to be implemented by the user, to make it possible to read
* and write user data when reading or writing .irr files via ISceneManager.
* To be used with ISceneManager.loadScene() and ISceneManager.saveScene() 
*/
interface ISceneUserDataSerializer
{
	/// Called when the scene manager create a scene node while loading a file.
	void OnCreateNode(ISceneNode node);
	
	/// Called when the scene manager read a scene node while loading a file.
	/**
	* The userData pointer contains a list of attributes with userData which
	* were attached to the scene node in the read scene file.
	*/
	void OnReadUserData(ISceneNode forSceneNode, IAttributes userData);

	/// Called when the scene manager is writing a scene node to an xml file for example.
	/**
	* Implement this method and return a list of attributes containing the user data
	* you want to be saved together with the scene node. Return 0 if no user data should
	* be added. Please note that the scene manager will call drop() to the returned pointer
	* after it no longer needs it, so if you didn't create a new object for the return value
	* and returning a longer existing IAttributes object, simply call grab() before returning it. 
	*/
	IAttributes createUserData(ISceneNode forSceneNode);
}
