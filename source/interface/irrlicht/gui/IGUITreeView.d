// written by Reinhard Ostermeier, reinhard@nospam.r-ostermeier.de
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUITreeView;

import irrlicht.gui.IGUIEnvironment;
import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUIImageList;
import irrlicht.gui.IGUIFont;
import irrlicht.core.rect;

/// Node for gui tree view
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_TREEVIEW_NODE_EXPAND
* \li EGET_TREEVIEW_NODE_COLLAPS
* \li EGET_TREEVIEW_NODE_DESELECT
* \li EGET_TREEVIEW_NODE_SELECT
*/
interface IGUITreeViewNode 
{
	/// returns the owner (tree view) of this node
	IGUITreeView getOwner() const;

	/// Returns the parent node of this node.
	/**
	* For the root node this will return 0. 
	*/
	IGUITreeViewNode getParent() const;

	/// returns the text of the node
	wstring getText() const;

	/// sets the text of the node
	void setText( wstring text );

	/// returns the icon text of the node
	wstring getIcon() const;

	/// sets the icon text of the node
	void setIcon( wstring icon );

	/// returns the image index of the node
	size_t getImageIndex() const;

	/// sets the image index of the node
	void setImageIndex( size_t imageIndex );

	/// returns the image index of the node
	size_t getSelectedImageIndex() const;

	/// sets the image index of the node
	void setSelectedImageIndex( size_t imageIndex );

	/// returns the user data (void*) of this node
	void* getData() const;

	/// sets the user data (void*) of this node
	void setData(void* data);

	// TODO: design more elegant way to store user data
	/// sets the user data (void*) of this node
	void setData( void* data );

	/// returns the user data (void*) of this node
	void* getData2() const;

	/// returns the child item count
	size_t getChildCount() const;

	/// removes all children (recursive) from this node
	void clearChildren();

	/// removes all children (recursive) from this node
	/**
	* Deprecated:  Deprecated in 1.8, use clearChildren() instead.
	* This method may be removed by Irrlicht 1.9 
	*/
	deprecated final void clearChilds()
	{
		return clearChildren();
	}

	/// returns true if this node has child nodes
	bool hasChildren() const;

	/// returns true if this node has child nodes
	/**
	* Deprecated:  Deprecated in 1.8, use hasChildren() instead. 
	* This method may be removed by Irrlicht 1.9 
	*/
	deprecated final bool hasChilds() const
	{
		return hasChildren();
	}

	/// Adds a new node behind the last child node.
	/**
	* Params:
	* 	text=  text of the new node
	* 	icon=  icon text of the new node
	* 	imageIndex=  index of the image for the new node (-1 = none)
	* 	selectedImageIndex=  index of the selected image for the new node (-1 = same as imageIndex)
	* 	data=  user data (void*) of the new node
	* 	data2=  user data2 (IReferenceCounted*) of the new node
	* Returns: The new node
	*/
	IGUITreeViewNode addChildBack(
			wstring text, wstring icon = "",
			ptrdiff_t imageIndex=-1, ptrdiff_t selectedImageIndex=-1,
			void* data = null, void* data2 = null);

	/// Adds a new node before the first child node.
	/**
	* Params:
	* 	text=  text of the new node
	* 	icon=  icon text of the new node
	* 	imageIndex=  index of the image for the new node (-1 = none)
	* 	selectedImageIndex=  index of the selected image for the new node (-1 = same as imageIndex)
	* 	data=  user data (void*) of the new node
	* 	data2=  user data2 (IReferenceCounted*) of the new node
	* Returns: The new node
	*/
	IGUITreeViewNode addChildFront(
			wstring text, wstring icon = "",
			ptrdiff_t imageIndex=-1, ptrdiff_t selectedImageIndex=-1,
			void* data = null, void* data2 = null );

	/// Adds a new node behind the other node.
	/**
	* The other node has also te be a child node from this node.
	* Params:
	* 	other=  Node to insert after
	* 	text=  text of the new node
	* 	icon=  icon text of the new node
	* 	imageIndex=  index of the image for the new node (-1 = none)
	* 	selectedImageIndex=  index of the selected image for the new node (-1 = same as imageIndex)
	* 	data=  user data (void*) of the new node
	* 	data2=  user data2 (IReferenceCounted*) of the new node
	* Returns: The new node or 0 if other is no child node from this
	*/
	IGUITreeViewNode insertChildAfter(
			IGUITreeViewNode other,
			wstring text, wstring icon = "",
			ptrdiff_t imageIndex=-1, ptrdiff_t selectedImageIndex=-1,
			void* data = null, void* data2 = null);

	/// Adds a new node before the other node.
	/**
	* The other node has also te be a child node from this node.
	* Params:
	* 	other=  Node to insert before
	* 	text=  text of the new node
	* 	icon=  icon text of the new node
	* 	imageIndex=  index of the image for the new node (-1 = none)
	* 	selectedImageIndex=  index of the selected image for the new node (-1 = same as imageIndex)
	* 	data=  user data (void*) of the new node
	* 	data2=  user data2 (IReferenceCounted*) of the new node
	* Returns: The new node or 0 if other is no child node from this
	*/
	IGUITreeViewNode insertChildBefore(
			IGUITreeViewNode other,
			wstring text, wstring icon = "",
			ptrdiff_t imageIndex=-1, ptrdiff_t selectedImageIndex=-1,
			void* data = null, void* data2 = null);

	/// Return the first child node from this node.
	/**
	* Returns: The first child node or 0 if this node has no children. 
	*/
	IGUITreeViewNode getFirstChild() const;

	/// Return the last child node from this node.
	/**
	* Returns: The last child node or 0 if this node has no children. 
	*/
	IGUITreeViewNode getLastChild() const;

	/// Returns the previous sibling node from this node.
	/**
	* Returns: The previous sibling node from this node or 0 if this is
	* the first node from the parent node.
	*/
	IGUITreeViewNode getPrevSibling() const;

	/// Returns the next sibling node from this node.
	/**
	* Returns: The next sibling node from this node or 0 if this is
	* the last node from the parent node.
	*/
	IGUITreeViewNode getNextSibling() const;

	/// Returns the next visible (expanded, may be out of scrolling) node from this node.
	/**
	* Returns: The next visible node from this node or 0 if this is
	* the last visible node. 
	*/
	IGUITreeViewNode getNextVisible() const;

	/// Deletes a child node.
	/**
	* Returns: Returns true if the node was found as a child and is deleted. 
	*/
	bool deleteChild( IGUITreeViewNode child );

	/// Moves a child node one position up.
	/**
	* Returns: True if the node was found as achild node and was not already the first child. 
	*/
	bool moveChildUp( IGUITreeViewNode child );

	/// Moves a child node one position down.
	/**
	* Returns: True if the node was found as achild node and was not already the last child. 
	*/
	bool moveChildDown( IGUITreeViewNode child );

	/// Returns true if the node is expanded (children are visible).
	bool getExpanded() const;

	/// Sets if the node is expanded.
	void setExpanded( bool expanded );

	/// Returns true if the node is currently selected.
	bool getSelected() const;

	/// Sets this node as selected.
	void setSelected( bool selected );

	/// Returns true if this node is the root node.
	bool isRoot() const;

	/// Returns the level of this node.
	/**
	* The root node has level 0. Direct children of the root has level 1 ... 
	*/
	int getLevel() const;

	/// Returns true if this node is visible (all parents are expanded).
	bool isVisible() const;
}


/// Default tree view GUI element.
/**
* Displays a windows like tree buttons to expand/collaps the child
* nodes of an node and optional tree lines. Each node consits of an
* text, an icon text and a void pointer for user data. 
*/
abstract class IGUITreeView : IGUIElement
{

	/// constructor
	this(IGUIEnvironment environment, IGUIElement parent,
			int id, rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_TREE_VIEW, environment, parent, id, rectangle);
	}

	/// returns the root node (not visible) from the tree.
	IGUITreeViewNode getRoot() const;

	/// returns the selected node of the tree or 0 if none is selected
	IGUITreeViewNode getSelected() const;

	/// returns true if the tree lines are visible
	bool getLinesVisible() const;

	/// sets if the tree lines are visible
	/**
	* Params:
	* 	visible=  true for visible, false for invisible 
	*/
	void setLinesVisible( bool visible );

	/// Sets the font which should be used as icon font.
	/**
	* This font is set to the Irrlicht engine built-in-font by
	* default. Icons can be displayed in front of every list item.
	* An icon is a string, displayed with the icon font. When using
	* the build-in-font of the Irrlicht engine as icon font, the icon
	* strings defined in GUIIcons.h can be used.
	*/
	void setIconFont( IGUIFont font );

	/// Sets the image list which should be used for the image and selected image of every node.
	/**
	* The default is 0 (no images). 
	*/
	void setImageList( IGUIImageList imageList );

	/// Returns the image list which is used for the nodes.
	IGUIImageList getImageList() const;

	/// Sets if the image is left of the icon. Default is true.
	void setImageLeftOfIcon( bool bLeftOf );

	/// Returns if the Image is left of the icon. Default is true.
	bool getImageLeftOfIcon() const;

	/// Returns the node which is associated to the last event.
	/**
	* This pointer is only valid inside the OnEvent call! 
	*/
	IGUITreeViewNode getLastEventNode() const;
}
