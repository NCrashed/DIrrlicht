// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneNodeFactory;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ESceneNodeTypes;

/// Interface for dynamic creation of scene nodes
/**
* To be able to add custom scene nodes to Irrlicht and to make it possible for the
* scene manager to save and load those external scene nodes, simply implement this
* interface and register it in you scene manager via ISceneManager::registerSceneNodeFactory.
* Note: When implementing your own scene node factory, don't call ISceneNodeManager::grab() to
* increase the reference counter of the scene node manager. This is not necessary because the
* scene node manager will grab() the factory anyway, and otherwise cyclic references will
* be created and the scene manager and all its nodes won't get deallocated.
*/
interface ISceneNodeFactory
{
	/// adds a scene node to the scene graph based on its type id
	/**
	* Params:
	* 	type=  Type of the scene node to add.
	* 	parent=  Parent scene node of the new node, can be null to add the scene node to the root.
	* Returns: Returns pointer to the new scene node or null if not successful.
	* This pointer should not be dropped. See IReferenceCounted::drop() for more information. 
	*/
	ISceneNode addSceneNode(ESCENE_NODE_TYPE type, ISceneNode parent = null);

	/// adds a scene node to the scene graph based on its type name
	/**
	* Params:
	* 	typeName=  Type name of the scene node to add.
	* 	parent=  Parent scene node of the new node, can be null to add the scene node to the root.
	* Returns: Returns pointer to the new scene node or null if not successful.
	*/
	ISceneNode addSceneNode(string typeName, ISceneNode parent = null);

	/// returns amount of scene node types this factory is able to create
	size_t getCreatableSceneNodeTypeCount() const;

	/// returns type of a createable scene node type
	/**
	* Params:
	* 	idx=  Index of scene node type in this factory. Must be a value between 0 and
	* getCreatableSceneNodeTypeCount() 
	*/
	ESCENE_NODE_TYPE getCreateableSceneNodeType(size_t idx) const;

	/// returns type name of a createable scene node type by index
	/**
	* Params:
	* 	idx=  Index of scene node type in this factory. Must be a value between 0 and
	* getCreatableSceneNodeTypeCount() 
	*/
	string getCreateableSceneNodeTypeName(size_t idx) const;

	/// returns type name of a createable scene node type
	/**
	* Params:
	* 	type=  Type of scene node.
	* Returns: Returns name of scene node type if this factory can create the type, otherwise 0. 
	*/
	string getCreateableSceneNodeTypeName(ESCENE_NODE_TYPE type) const;
}