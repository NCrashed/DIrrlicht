// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.ISceneNode;

import irrlicht.scene.ISceneManager;
import irrlicht.scene.ESceneNodeTypes;
import irrlicht.scene.EDebugSceneTypes;
import irrlicht.scene.ECullingTypes;
import irrlicht.scene.ISceneNodeAnimator;
import irrlicht.scene.ITriangleSelector;
import irrlicht.video.SMaterial;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.EMaterialTypes;
import irrlicht.video.ITexture;
import irrlicht.io.IAttributes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.core.aabbox3d;
import irrlicht.core.matrix4;
import irrlicht.core.vector3d;
import std.container;
import std.algorithm;
import std.range;

/// Alias for list of scene nodes
alias DList!ISceneNode ISceneNodeList;

/// Alias for list of scene node animators
alias DList!ISceneNodeAnimator ISceneNodeAnimatorList;

/// Scene node interface.
/**
* A scene node is a node in the hierarchical scene graph. Every scene
* node may have children, which are also scene nodes. Children move
* relative to their parent's position. If the parent of a node is not
* visible, its children won't be visible either. In this way, it is for
* example easily possible to attach a light to a moving car, or to place
* a walking character on a moving platform on a moving ship.
*/
abstract class ISceneNode : IAttributeExchangingObject
{
	/// Constructor
	this(ISceneNode parent, ISceneManager mgr, int id=-1,
			const vector3df position = vector3df(0,0,0),
			const vector3df rotation = vector3df(0,0,0),
			const vector3df scale = vector3df(1.0f, 1.0f, 1.0f))
	{
		RelativeTranslation = position;
		RelativeTranslation = rotation;
		RelativeScale = scale;
		Parent = null;
		SceneManager = mgr;
		TriangleSelector = null;
		ID = id;
		AutomaticCullingState = E_CULLING_TYPE.EAC_BOX;
		DebugDataVisible = E_DEBUG_SCENE_TYPE.EDS_OFF;
		IsVisible = true;
		IsDebugObject = false;

		if(parent !is null)
			parent.addChild(this);

		updateAbsolutePosition();
	}

	/// Destructor
	~this()
	{
		// delete all children
		removeAll();
	}


	/// This method is called just before the rendering process of the whole 
	/**
	* Nodes may register themselves in the render pipeline during this call,
	* precalculate the geometry which should be renderered, and prevent their
	* children from being able to register themselves if they are clipped by simply
	* not calling their OnRegisterSceneNode method.
	* If you are implementing your own scene node, you should overwrite this method
	* with an implementation code looking like this:
	* Examples:
	* ------
	* if (IsVisible)
	*	 SceneManager.registerNodeForRendering(this);
	* ISceneNode.OnRegisterSceneNode();
	* ------
	*/
	void OnRegisterSceneNode()
	{
		if (IsVisible)
		{
			foreach(children; Children)
				children.OnRegisterSceneNode();
		}
	}


	/// OnAnimate() is called just before rendering the whole 
	/**
	* Nodes may calculate or store animations here, and may do other useful things,
	* depending on what they are. Also, OnAnimate() should be called for all
	* child scene nodes here. This method will be called once per frame, independent
	* of whether the scene node is visible or not.
	* Params:
	* 	timeMs=  Current time in milliseconds. 
	*/
	void OnAnimate(uint timeMs)
	{
		if (IsVisible)
		{
			// animate this node with all animators

			foreach(anim; Animators)
			{
				/// TODO: Check this!
				// continue to the next node before calling animateNode()
				// so that the animator may remove itself from the scene
				// node without the iterator becoming invalid
				anim.animateNode(this, timeMs);
			}

			// update absolute position
			updateAbsolutePosition();

			// perform the post render process on all children
			foreach(children; Children)
				children.OnAnimate(timeMs);
		}
	}


	/// Renders the node.
	void render();


	/// Returns the name of the node.
	/**
	* Returns: Name as character string. 
	*/
	string getName() const
	{
		return Name;
	}


	/// Sets the name of the node.
	/**
	* Params:
	* 	name=  New name of the scene node. 
	*/
	void setName(string name)
	{
		Name = name;
	}


	/// Get the axis aligned, not transformed bounding box of this node.
	/**
	* This means that if this node is an animated 3d character,
	* moving in a room, the bounding box will always be around the
	* origin. To get the box in real world coordinates, just
	* transform it with the matrix you receive with
	* getAbsoluteTransformation() or simply use
	* getTransformedBoundingBox(), which does the same.
	* Returns: The non-transformed bounding box. 
	*/
	auto ref const aabbox3d!float getBoundingBox()() const;


	/// Get the axis aligned, transformed and animated absolute bounding box of this node.
	/**
	* Returns: The transformed bounding box. 
	*/
	auto ref const aabbox3d!float getTransformedBoundingBox()() const
	{
		aabbox3d!float box = getBoundingBox();
		AbsoluteTransformation.transformBoxEx(box);
		return box;
	}


	/// Get the absolute transformation of the node. Is recalculated every OnAnimate()-call.
	/**
	* NOTE: For speed reasons the absolute transformation is not 
	* automatically recalculated on each change of the relative 
	* transformation or by a transformation change of an parent. Instead the
	* update usually happens once per frame in OnAnimate. You can enforce 
	* an update with updateAbsolutePosition().
	* Returns: The absolute transformation matrix. 
	*/
	auto ref const matrix4 getAbsoluteTransformation() const
	{
		return AbsoluteTransformation;
	}


	/// Returns the relative transformation of the scene node.
	/**
	* The relative transformation is stored internally as 3
	* vectors: translation, rotation and scale. To get the relative
	* transformation matrix, it is calculated from these values.
	* Returns: The relative transformation matrix. 
	*/
	matrix4 getRelativeTransformation() const
	{
		matrix4 mat;
		mat.setRotationDegrees(RelativeRotation);
		mat.setTranslation(RelativeTranslation);

		if (RelativeScale != vector3df(1.0f,1.0f,1.0f))
		{
			matrix4 smat;
			smat.setScale(RelativeScale);
			mat *= smat;
		}

		return mat;
	}


	/// Returns whether the node should be visible (if all of its parents are visible).
	/**
	* This is only an option set by the user, but has nothing to
	* do with geometry culling
	* Returns: The requested visibility of the node, true means
	* visible (if all parents are also visible). 
	*/
	bool isVisible() const
	{
		return IsVisible;
	}

	/// Check whether the node is truly visible, taking into accounts its parents' visibility
	/**
	* Returns: true if the node and all its parents are visible,
	* false if this or any parent node is invisible. 
	*/
	bool isTrulyVisible() const
	{
		if(!IsVisible)
			return false;

		if(Parent is null)
			return true;

		return Parent.isTrulyVisible();
	}

	/// Sets if the node should be visible or not.
	/**
	* All children of this node won't be visible either, when set
	* to false. Invisible nodes are not valid candidates for selection by
	* collision manager bounding box methods.
	* Params:
	* 	isVisible=  If the node shall be visible. 
	*/
	void setVisible(bool isVisible)
	{
		IsVisible = isVisible;
	}


	/// Get the id of the scene node.
	/**
	* This id can be used to identify the node.
	* Returns: The id. 
	*/
	int getID() const
	{
		return ID;
	}


	/// Sets the id of the scene node.
	/**
	* This id can be used to identify the node.
	* Params:
	* 	id=  The new id. 
	*/
	void setID(int id)
	{
		ID = id;
	}


	/// Adds a child to this scene node.
	/**
	* If the scene node already has a parent it is first removed
	* from the other parent.
	* Params:
	* 	child=  A pointer to the new child. 
	*/
	void addChild(ISceneNode child)
	{
		if (child !is null && (child != this))
		{
			// Change scene manager?
			if (SceneManager != child.SceneManager)
				child.setSceneManager(SceneManager);

			child.remove(); // remove from old parent
			Children.insertBack(child);
			child.Parent = this;
		}
	}


	/// Removes a child from this scene node.
	/**
	* If found in the children list, the child pointer is also
	* dropped and might be deleted if no other grab exists.
	* Params:
	* 	child=  A pointer to the child which shall be removed.
	* Returns: True if the child was removed, and false if not,
	* e.g. because it couldn't be found in the children list. 
	*/
	bool removeChild(ISceneNode child)
	{
		auto findResult = find(Children[], child);
		Children.linearRemove(findResult.take(1));
		return !findResult.empty;
	}


	/// Removes all children of this scene node
	/**
	* The scene nodes found in the children list are also dropped
	* and might be deleted if no other grab exists on them.
	*/
	void removeAll()
	{
		Children.clear();
	}


	/// Removes this scene node from the scene
	/**
	* If no other grab exists for this node, it will be deleted.
	*/
	void remove()
	{
		if (Parent !is null)
			Parent.removeChild(this);
	}


	/// Adds an animator which should animate this node.
	/**
	* Params:
	* 	animator=  A pointer to the new animator. 
	*/
	void addAnimator(ISceneNodeAnimator animator)
	{
		if (animator !is null)
		{
			Animators.insertBack(animator);
		}
	}


	/// Get a list of all scene node animators.
	/**
	* Returns: The list of animators attached to this node. 
	*/
	const(ISceneNodeAnimatorList) getAnimators() const
	{
		return Animators;
	}


	/// Removes an animator from this scene node.
	/**
	* If the animator is found, it is also dropped and might be
	* deleted if not other grab exists for it.
	* Params:
	* 	animator=  A pointer to the animator to be deleted. 
	*/
	void removeAnimator(ISceneNodeAnimator animator)
	{
		Animators.linearRemove(find(Animators[], animator).take(1));		
	}


	/// Removes all animators from this scene node.
	/**
	* The animators might also be deleted if no other grab exists
	* for them. 
	*/
	void removeAnimators()
	{
		Animators.clear();
	}


	/// Returns the material based on the zero based index i.
	/**
	* To get the amount of materials used by this scene node, use
	* getMaterialCount(). This function is needed for inserting the
	* node into the scene hierarchy at an optimal position for
	* minimizing renderstate changes, but can also be used to
	* directly modify the material of a scene node.
	* Params:
	* 	num=  Zero based index. The maximal value is getMaterialCount() - 1.
	* Returns: The material at that index. 
	*/
	SMaterial getMaterial(size_t num)
	{
		return new SMaterial(IdentityMaterial);
	}


	/// Get amount of materials used by this scene node.
	/**
	* Returns: Current amount of materials of this scene node. 
	*/
	size_t getMaterialCount() const
	{
		return 0;
	}


	/// Sets all material flags at once to a new value.
	/**
	* Useful, for example, if you want the whole mesh to be
	* affected by light.
	* Params:
	* 	flag=  Which flag of all materials to be set.
	* 	newvalue=  New value of that flag. 
	*/
	void setMaterialFlag(E_MATERIAL_FLAG flag, bool newvalue)
	{
		for (size_t i=0; i<getMaterialCount(); ++i)
			getMaterial(i).setFlag(flag, newvalue);
	}


	/// Sets the texture of the specified layer in all materials of this scene node to the new texture.
	/**
	* Params:
	* 	textureLayer=  Layer of texture to be set. Must be a
	* value smaller than MATERIAL_MAX_TEXTURES.
	* 	texture=  New texture to be used. 
	*/
	void setMaterialTexture(uint textureLayer, ITexture texture)
	{
		if (textureLayer >= MATERIAL_MAX_TEXTURES)
			return;

		for (size_t i=0; i<getMaterialCount(); ++i)
			getMaterial(i).setTexture(textureLayer, texture);
	}


	/// Sets the material type of all materials in this scene node to a new material type.
	/**
	* Params:
	* 	newType=  New type of material to be set. 
	*/
	void setMaterialType(E_MATERIAL_TYPE newType)
	{
		for (size_t i=0; i<getMaterialCount(); ++i)
			getMaterial(i).MaterialType = newType;
	}


	/// Gets the scale of the scene node relative to its parent.
	/**
	* This is the scale of this node relative to its parent.
	* If you want the absolute scale, use
	* getAbsoluteTransformation().getScale()
	* Returns: The scale of the scene node. 
	*/
	auto ref const vector3df getScale()() const
	{
		return RelativeScale;
	}


	/// Sets the relative scale of the scene node.
	/**
	* Params:
	* 	scale=  New scale of the node, relative to its parent. 
	*/
	void setScale()(auto ref const vector3df scale)
	{
		RelativeScale = scale;
	}


	/// Gets the rotation of the node relative to its parent.
	/**
	* Note that this is the relative rotation of the node.
	* If you want the absolute rotation, use
	* getAbsoluteTransformation().getRotation()
	* Returns: Current relative rotation of the scene node. 
	*/
	auto ref const vector3df getRotation()() const
	{
		return RelativeRotation;
	}


	/// Sets the rotation of the node relative to its parent.
	/**
	* This only modifies the relative rotation of the node.
	* Params:
	* 	rotation=  New rotation of the node in degrees. 
	*/
	void setRotation()(auto ref const vector3df rotation)
	{
		RelativeRotation = rotation;
	}


	/// Gets the position of the node relative to its parent.
	/**
	* Note that the position is relative to the parent. If you want
	* the position in world coordinates, use getAbsolutePosition() instead.
	* Returns: The current position of the node relative to the parent. 
	*/
	auto ref const vector3df getPosition()() const
	{
		return RelativeTranslation;
	}


	/// Sets the position of the node relative to its parent.
	/**
	* Note that the position is relative to the parent.
	* Params:
	* 	newpos=  New relative position of the scene node. 
	*/
	void setPosition()(auto ref const vector3df newpos)
	{
		RelativeTranslation = newpos;
	}


	/// Gets the absolute position of the node in world coordinates.
	/**
	* If you want the position of the node relative to its parent,
	* use getPosition() instead.
	* NOTE: For speed reasons the absolute position is not 
	* automatically recalculated on each change of the relative 
	* position or by a position change of an parent. Instead the 
	* update usually happens once per frame in OnAnimate. You can enforce 
	* an update with updateAbsolutePosition().
	* Returns: The current absolute position of the scene node (updated on last call of updateAbsolutePosition). 
	*/
	vector3df getAbsolutePosition() const
	{
		return AbsoluteTransformation.getTranslation();
	}


	/// Enables or disables automatic culling based on the bounding box.
	/**
	* Automatic culling is enabled by default. Note that not
	* all SceneNodes support culling and that some nodes always cull
	* their geometry because it is their only reason for existence,
	* for example the OctreeSceneNode.
	* Params:
	* 	state=  The culling state to be used. 
	*/
	void setAutomaticCulling(uint state)
	{
		AutomaticCullingState = state;
	}


	/// Gets the automatic culling state.
	/**
	* Returns: The automatic culling state. 
	*/
	uint getAutomaticCulling() const
	{
		return AutomaticCullingState;
	}


	/// Sets if debug data like bounding boxes should be drawn.
	/**
	* A bitwise OR of the types from @ref irr.E_DEBUG_SCENE_TYPE.
	* Please note that not all scene nodes support all debug data types.
	* Params:
	* 	state=  The debug data visibility state to be used. 
	*/
	void setDebugDataVisible(uint state)
	{
		DebugDataVisible = state;
	}

	/// Returns if debug data like bounding boxes are drawn.
	/**
	* Returns: A bitwise OR of the debug data values from
	* @ref irr.E_DEBUG_SCENE_TYPE that are currently visible. 
	*/
	uint isDebugDataVisible() const
	{
		return DebugDataVisible;
	}


	/// Sets if this scene node is a debug object.
	/**
	* Debug objects have some special properties, for example they can be easily
	* excluded from collision detection or from serialization, etc. 
	*/
	void setIsDebugObject(bool debugObject)
	{
		IsDebugObject = debugObject;
	}


	/// Returns if this scene node is a debug object.
	/**
	* Debug objects have some special properties, for example they can be easily
	* excluded from collision detection or from serialization, etc.
	* Returns: If this node is a debug object, true is returned. 
	*/
	bool isDebugObject() const
	{
		return IsDebugObject;
	}


	/// Returns a const reference to the list of all children.
	/**
	* Returns: The list of all children of this node. 
	*/
	const(ISceneNodeList) getChildren() const
	{
		return Children;
	}


	/// Changes the parent of the scene node.
	/**
	* Params:
	* 	newParent=  The new parent to be used. 
	*/
	void setParent(ISceneNode newParent)
	{
		remove();

		Parent = newParent;

		if (Parent !is null)
			Parent.addChild(this);
	}


	/// Returns the triangle selector attached to this scene node.
	/**
	* The Selector can be used by the engine for doing collision
	* detection. You can create a TriangleSelector with
	* ISceneManager.createTriangleSelector() or
	* ISceneManager.createOctreeTriangleSelector and set it with
	* ISceneNode.setTriangleSelector(). If a scene node got no triangle
	* selector, but collision tests should be done with it, a triangle
	* selector is created using the bounding box of the scene node.
	* Returns: A pointer to the TriangleSelector or 0, if there
	* is none. 
	*/
	const(ITriangleSelector) getTriangleSelector() const
	{
		return TriangleSelector;
	}


	/// Sets the triangle selector of the scene node.
	/**
	* The Selector can be used by the engine for doing collision
	* detection. You can create a TriangleSelector with
	* ISceneManager.createTriangleSelector() or
	* ISceneManager.createOctreeTriangleSelector(). Some nodes may
	* create their own selector by default, so it would be good to
	* check if there is already a selector in this node by calling
	* ISceneNode.getTriangleSelector().
	* Params:
	* 	selector=  New triangle selector for this scene node. 
	*/
	void setTriangleSelector(ITriangleSelector selector)
	{
		if (TriangleSelector != selector)
		{
			TriangleSelector = selector;
		}
	}


	/// Updates the absolute position based on the relative and the parents position
	/**
	* Note: This does not recursively update the parents absolute positions, so if you have a deeper
	* hierarchy you might want to update the parents first.
	*/
	void updateAbsolutePosition()
	{
		if (Parent !is null)
		{
			AbsoluteTransformation =
				Parent.getAbsoluteTransformation() * getRelativeTransformation();
		}
		else
			AbsoluteTransformation = getRelativeTransformation();
	}


	/// Returns the parent of this scene node
	/**
	* Returns: A pointer to the parent. 
	*/
	const(ISceneNode) getParent() const
	{
		return Parent;
	}


	/// Returns type of the scene node
	/**
	* Returns: The type of this node. 
	*/
	ESCENE_NODE_TYPE getType() const
	{
		return ESCENE_NODE_TYPE.ESNT_UNKNOWN;
	}


	/// Writes attributes of the scene node.
	/**
	* Implement this to expose the attributes of your scene node
	* for scripting languages, editors, debuggers or xml
	* serialization purposes.
	* Params:
	* 	out=  The attribute container to write into.
	* 	options=  Additional options which might influence the
	* serialization. 
	*/
	void serializeAttributes(out IAttributes outAttr, SAttributeReadWriteOptions options) const
	{
		if (outAttr is null)
			return;

		outAttr.addString("Name", Name);
		outAttr.addInt	("Id", ID );

		outAttr.addVector3d("Position", getPosition() );
		outAttr.addVector3d("Rotation", getRotation() );
		outAttr.addVector3d("Scale", getScale() );

		outAttr.addBool	("Visible", IsVisible );
		outAttr.addInt	("AutomaticCulling", AutomaticCullingState);
		outAttr.addInt	("DebugDataVisible", DebugDataVisible );
		outAttr.addBool	("IsDebugObject", IsDebugObject );
	}


	/// Reads attributes of the scene node.
	/**
	* Implement this to set the attributes of your scene node for
	* scripting languages, editors, debuggers or xml deserialization
	* purposes.
	* Params:
	* 	in=  The attribute container to read from.
	* 	options=  Additional options which might influence the
	* deserialization. 
	*/
	void deserializeAttributes(IAttributes inAttr, SAttributeReadWriteOptions options)
	{
		if (inAttr is null)
			return;

		Name = inAttr.getAttributeAsString("Name");
		ID = inAttr.getAttributeAsInt("Id");

		setPosition(inAttr.getAttributeAsVector3d("Position"));
		setRotation(inAttr.getAttributeAsVector3d("Rotation"));
		setScale(inAttr.getAttributeAsVector3d("Scale"));

		IsVisible = inAttr.getAttributeAsBool("Visible");
		int tmpState = inAttr.getAttributeAsEnumeration("AutomaticCulling",
				AutomaticCullingNames);
		if (tmpState != -1)
			AutomaticCullingState = cast(uint)tmpState;
		else
			AutomaticCullingState = inAttr.getAttributeAsInt("AutomaticCulling");

		DebugDataVisible = inAttr.getAttributeAsInt("DebugDataVisible");
		IsDebugObject = inAttr.getAttributeAsBool("IsDebugObject");

		updateAbsolutePosition();
	}

	/// Creates a clone of this scene node and its children.
	/**
	* Params:
	* 	newParent=  An optional new parent.
	* 	newManager=  An optional new scene manager.
	* Returns: The newly created clone of this node. 
	*/
	ISceneNode clone(ISceneNode newParent = null, ISceneManager newManager = null)
	{
		return null; // to be implemented by derived classes
	}

	/// Retrieve the scene manager for this node.
	/**
	* Returns: The node's scene manager. 
	*/
	const(ISceneManager) getSceneManager() const 
	{ 
		return SceneManager; 
	}

	protected	
	{
		/// A clone function for the ISceneNode members.
		/**
		* This method can be used by clone() implementations of
		* derived classes
		* Params:
		* 	toCopyFrom=  The node from which the values are copied
		* 	newManager=  The new scene manager. 
		*/
		void cloneMembers(ISceneNode toCopyFrom, ISceneManager newManager)
		{
			Name = toCopyFrom.Name;
			AbsoluteTransformation = toCopyFrom.AbsoluteTransformation;
			RelativeTranslation = toCopyFrom.RelativeTranslation;
			RelativeRotation = toCopyFrom.RelativeRotation;
			RelativeScale = toCopyFrom.RelativeScale;
			ID = toCopyFrom.ID;
			setTriangleSelector(toCopyFrom.TriangleSelector);
			AutomaticCullingState = toCopyFrom.AutomaticCullingState;
			DebugDataVisible = toCopyFrom.DebugDataVisible;
			IsVisible = toCopyFrom.IsVisible;
			IsDebugObject = toCopyFrom.IsDebugObject;

			if (newManager !is null)
				SceneManager = newManager;
			else
				SceneManager = toCopyFrom.SceneManager;

			// clone children

			foreach(child; toCopyFrom.Children)
				child.clone(this, newManager);

			// clone animators

			foreach(toCopyAnim; toCopyFrom.Animators)
			{
				ISceneNodeAnimator anim = toCopyAnim.createClone(this, SceneManager);
				if (anim !is null)
				{
					addAnimator(anim);
				}
			}
		}

		/// Sets the new scene manager for this node and all children.
		/// Called by addChild when moving nodes between scene managers
		void setSceneManager(ISceneManager newManager)
		{
			SceneManager = newManager;

			foreach(child; Children)
				child.setSceneManager(newManager);
		}

		/// Name of the scene node.
		string Name;

		/// Absolute transformation of the node.
		matrix4 AbsoluteTransformation;

		/// Relative translation of the scene node.
		vector3df RelativeTranslation;

		/// Relative rotation of the scene node.
		vector3df RelativeRotation;

		/// Relative scale of the scene node.
		vector3df RelativeScale;

		/// Pointer to the parent
		ISceneNode Parent;

		/// List of all children of this node
		ISceneNodeList Children;

		/// List of all animator nodes
		ISceneNodeAnimatorList Animators;

		/// Pointer to the scene manager
		ISceneManager SceneManager;

		/// Pointer to the triangle selector
		ITriangleSelector TriangleSelector;

		/// ID of the node.
		int ID;

		/// Automatic culling state
		uint AutomaticCullingState;

		/// Flag if debug data should be drawn, such as Bounding Boxes.
		uint DebugDataVisible;

		/// Is the node visible?
		bool IsVisible;

		/// Is debug object?
		bool IsDebugObject;
	}
}
