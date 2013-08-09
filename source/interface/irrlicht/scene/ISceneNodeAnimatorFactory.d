// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.ISceneNodeAnimatorFactory;

import irrlicht.scene.ISceneNode;
import irrlicht.scene.ISceneNodeAnimator;
import irrlicht.scene.ESceneNodeAnimatorTypes;

/// Interface for dynamic creation of scene node animators
/**
* To be able to add custom scene node animators to Irrlicht and to make it possible for the
* scene manager to save and load those external animators, simply implement this
* interface and register it in you scene manager via ISceneManager.registerSceneNodeAnimatorFactory.
*/
interface ISceneNodeAnimatorFactory
{
	/// creates a scene node animator based on its type id
	/**
	* Params:
	* 	type=  Type of the scene node animator to add.
	* 	target=  Target scene node of the new animator.
	* Returns: Returns pointer to the new scene node animator or null if not successful.
	*/
	ISceneNodeAnimator createSceneNodeAnimator(ESCENE_NODE_ANIMATOR_TYPE type, ISceneNode target);

	/// creates a scene node animator based on its type name
	/**
	* Params:
	* 	typeName=  Type of the scene node animator to add.
	* 	target=  Target scene node of the new animator.
	* Returns: Returns pointer to the new scene node animator or null if not successful. 
	*/
	ISceneNodeAnimator createSceneNodeAnimator(string typeName, ISceneNode target);

	/// returns amount of scene node animator types this factory is able to create
	size_t getCreatableSceneNodeAnimatorTypeCount() const;

	/// returns type of a createable scene node animator type
	/**
	* Params:
	* 	idx=  Index of scene node animator type in this factory. Must be a value between 0 and
	* getCreatableSceneNodeTypeCount() 
	*/
	ESCENE_NODE_ANIMATOR_TYPE getCreateableSceneNodeAnimatorType(size_t idx) const;

	/// returns type name of a createable scene node animator type
	/**
	* Params:
	* 	idx=  Index of scene node animator type in this factory. Must be a value between 0 and
	* getCreatableSceneNodeAnimatorTypeCount() 
	*/
	string getCreateableSceneNodeAnimatorTypeName(size_t idx) const;

	/// returns type name of a createable scene node animator type
	/**
	* Params:
	* 	type=  Type of scene node animator.
	* Returns: Returns name of scene node animator type if this factory can create the type, otherwise 0. 
	*/
	string getCreateableSceneNodeAnimatorTypeName(ESCENE_NODE_ANIMATOR_TYPE type) const;
}