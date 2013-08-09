// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.gui.IGUIElement;

import irrlicht.IEventReceiver;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.io.IAttributes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.gui.EGUIAlignment;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.core.dimension2d;
import irrlicht.core.vector2d;
import irrlicht.core.rect;
import std.container;
import std.algorithm;
import std.range;
import std.math;

/// Base class of all GUI elements.
abstract class IGUIElement : IAttributeExchangingObject, IEventReceiver
{
	/// Constructor
	this()(EGUI_ELEMENT_TYPE type, IGUIEnvironment environment, IGUIElement parent,
		size_t id, auto ref const rect!int rectangle)
	{
		// Init
		Parent = null;
		
		RelativeRect = rectangle;
		
		AbsoluteRect = rectangle;
		
		AbsoluteClippingRect = rectangle;
		
		DesiredRect = rectangle;
		
		MaxSize = dimension2du(0,0);
		
		MinSize = dimension2du(1,1);
		
		IsVisible = true;
		
		IsEnabled = true;
		
		IsSubElement = false;
		
		NoClip = false;
		
		ID = id;
		
		IsTabStop = false;
		
		TabOrder = -1;
		
		IsTabGroup = false;
		
		AlignLeft = EGUI_ALIGNMENT.EGUIA_UPPERLEFT;
		
		AlignRight = EGUI_ALIGNMENT.EGUIA_UPPERLEFT;
		
		AlignTop = EGUI_ALIGNMENT.EGUIA_UPPERLEFT;
		
		AlignBottom = EGUI_ALIGNMENT.EGUIA_UPPERLEFT;
		
		Environment = environment;
		
		Type = type;
	
		// if we were given a parent to attach to
		if (parent !is null)
		{
			parent.addChildToEnd(this);
			recalculateAbsolutePosition(true);
		}
	}


	/// Destructor
	~this()
	{
		// delete all children
		foreach(child; Children)
		{
			child.Parent = null;
		}
	}


	/// Returns parent of this element.
	const(IGUIElement) getParent() const
	{
		return Parent;
	}

	/// Returns parent of this element.
	IGUIElement getParent()
	{
		return Parent;
	}

	/// Returns the relative rectangle of this element.
	rect!int getRelativePosition() const
	{
		return RelativeRect;
	}


	/// Sets the relative rectangle of this element.
	/**
	* Params:
	* 	r=  The absolute position to set 
	*/
	void setRelativePosition()(auto ref const rect!int r)
	{
		if (Parent !is null)
		{
			immutable rect!int r2 = Parent.getAbsolutePosition();

			auto d = dimension2df(cast(float) r2.getSize().X, cast(float) r2.getSize().Y);

			if (AlignLeft == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.UpperLeftCorner.X = cast(float) r.UpperLeftCorner.X / d.Width;
			
			if (AlignRight == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.LowerRightCorner.X = cast (float) r.LowerRightCorner.X / d.Width;
			
			if (AlignTop == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.UpperLeftCorner.Y = cast (float) r.UpperLeftCorner.Y / d.Height;
			
			if (AlignBottom == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.LowerRightCorner.Y = cast (float) r.LowerRightCorner.Y / d.Height;
		}

		DesiredRect = r;
		updateAbsolutePosition();
	}

	/// Sets the relative rectangle of this element, maintaining its current width and height
	/**
	* Params:
	* 	position=  The new relative position to set. Width and height will not be changed. 
	*/
	void setRelativePosition()(auto ref const vector2di position)
	{
		immutable mySize = RelativeRect.getSize();
		
		immutable rectangle = rect!int(position.X, position.Y,
						position.X + mySize.Width, position.Y + mySize.Height);
		
		setRelativePosition(rectangle);
	}


	/// Sets the relative rectangle of this element as a proportion of its parent's area.
	/**
	* Note:  This method used to be 'void setRelativePosition(const core::rect<f32>& r)'
	* Params:
	* 	r=   The rectangle to set, interpreted as a proportion of the parent's area.
	* Meaningful values are in the range [0...1], unless you intend this element to spill
	* outside its parent. 
	*/
	void setRelativePositionProportional()(auto ref const rect!int r)
	{
		if (Parent is null)
			return;

		immutable d = Parent.getAbsolutePosition().getSize();

		DesiredRect = rect!int(
					cast(int)floor(cast(float)d.Width * r.UpperLeftCorner.X),
					cast(int)floor(cast(float)d.Height * r.UpperLeftCorner.Y),
					cast(int)floor(cast(float)d.Width * r.LowerRightCorner.X),
					cast(int)floor(cast(float)d.Height * r.LowerRightCorner.Y));

		ScaleRect = r;

		updateAbsolutePosition();
	}


	/// Gets the absolute rectangle of this element
	rect!int getAbsolutePosition() const
	{
		return AbsoluteRect;
	}


	/// Returns the visible area of the element.
	rect!int getAbsoluteClippingRect() const
	{
		return AbsoluteClippingRect;
	}


	/// Sets whether the element will ignore its parent's clipping rectangle
	/**
	* Params:
	* 	noClip=  If true, the element will not be clipped by its parent's clipping rectangle. 
	*/
	void setNotClipped(bool noClip)
	{
		NoClip = noClip;
		updateAbsolutePosition();
	}


	/// Gets whether the element will ignore its parent's clipping rectangle
	/**
	* Returns: true if the element is not clipped by its parent's clipping rectangle. 
	*/
	bool isNotClipped() const
	{
		return NoClip;
	}


	/// Sets the maximum size allowed for this element
	/**
	* If set to 0,0, there is no maximum size 
	*/
	void setMaxSize()(auto ref const dimension2du size)
	{
		MaxSize = size;
		updateAbsolutePosition();
	}


	/// Sets the minimum size allowed for this element
	void setMinSize()(auto ref const dimension2du size)
	{
		MinSize = size;
		if (MinSize.Width < 1)
			MinSize.Width = 1;
		if (MinSize.Height < 1)
			MinSize.Height = 1;
		updateAbsolutePosition();
	}


	/// The alignment defines how the borders of this element will be positioned when the parent element is resized.
	void setAlignment(EGUI_ALIGNMENT left, EGUI_ALIGNMENT right, EGUI_ALIGNMENT top, EGUI_ALIGNMENT bottom)
	{
		AlignLeft = left;
		AlignRight = right;
		AlignTop = top;
		AlignBottom = bottom;

		if (Parent !is null)
		{
			auto r = Parent.getAbsolutePosition();

			auto d = dimension2df(cast(float)r.getSize().X, cast(float)r.getSize().Y);

			if (AlignLeft   == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.UpperLeftCorner.X = cast(float)DesiredRect.UpperLeftCorner.X / d.Width;
			if (AlignRight  == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.LowerRightCorner.X = cast(float)DesiredRect.LowerRightCorner.X / d.Width;
			if (AlignTop    == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.UpperLeftCorner.Y = cast(float)DesiredRect.UpperLeftCorner.Y / d.Height;
			if (AlignBottom == EGUI_ALIGNMENT.EGUIA_SCALE)
				ScaleRect.LowerRightCorner.Y = cast(float)DesiredRect.LowerRightCorner.Y / d.Height;
		}
	}


	/// Updates the absolute position.
	void updateAbsolutePosition()
	{
		recalculateAbsolutePosition(false);

		// update all children
		foreach(child; Children)
		{
			child.updateAbsolutePosition();
		}
	}


	/// Returns the topmost GUI element at the specific position.
	/**
	* This will check this GUI element and all of its descendants, so it
	* may return this GUI element.  To check all GUI elements, call this
	* function on device.getGUIEnvironment().getRootGUIElement(). Note
	* that the root element is the size of the screen, so doing so (with
	* an on-screen point) will always return the root element if no other
	* element is above it at that point.
	* Params:
	* 	point=  The point at which to find a GUI element.
	* Returns: The topmost GUI element at that point, or 0 if there are
	* no candidate elements at this point.
	*/
	IGUIElement getElementFromPoint()(auto ref const vector2d!int point)
	{
		IGUIElement target = null;

		// we have to search from back to front, because later children
		// might be drawn over the top of earlier ones.

		if (isVisible())
		{	
			foreach_reverse(child; Children)
			{
				target = child.getElementFromPoint(point);
				
				if (target !is null)
					return target;
			}
		}

		if (isVisible() && isPointInside(point))
			target = this;

		return target;
	}


	/// Returns true if a point is within this element.
	/**
	* Elements with a shape other than a rectangle should override this method 
	*/
	bool isPointInside()(auto ref const vector2d!int point) const
	{
		return AbsoluteClippingRect.isPointInside(point);
	}


	/// Adds a GUI element as new child of this element.
	void addChild(IGUIElement child)
	{
		addChildToEnd(child);
		if (child !is null)
		{
			child.updateAbsolutePosition();
		}
	}

	/// Removes a child.
	void removeChild(IGUIElement child)
	{		
		auto findResult = find(Children[], child);
		Children.linearRemove(findResult.take(1));
	}


	/// Removes this element from its parent.
	void remove()
	{
		if (Parent !is null)
			Parent.removeChild(this);
	}


	/// Draws the element and its children.
	void draw()
	{
		if ( isVisible() )
		{		
			foreach(child; Children)
			{
				child.draw();
			}
		}
	}


	/// animate the element and its children.
	void OnPostRender(uint timeMs)
	{
		if ( isVisible() )
		{
			foreach(child; Children)
			{
				child.OnPostRender( timeMs);
			}
		}
	}


	/// Moves this element.
	void move(vector2d!int absoluteMovement)
	{
		setRelativePosition(DesiredRect + absoluteMovement);
	}


	/// Returns true if element is visible.
	bool isVisible() const
	{
		return IsVisible;
	}


	/// Sets the visible state of this element.
	void setVisible(bool visible)
	{
		IsVisible = visible;
	}


	/// Returns true if this element was created as part of its parent control
	bool isSubElement() const
	{
		return IsSubElement;
	}


	/// Sets whether this control was created as part of its parent.
	/**
	* For example, it is true when a scrollbar is part of a listbox.
	* SubElements are not saved to disk when calling guiEnvironment.saveGUI() 
	*/
	void setSubElement(bool subElement)
	{
		IsSubElement = subElement;
	}


	/// If set to true, the focus will visit this element when using the tab key to cycle through elements.
	/**
	* If this element is a tab group (see isTabGroup/setTabGroup) then
	* ctrl+tab will be used instead. 
	*/
	void setTabStop(bool enable)
	{
		IsTabStop = enable;
	}


	/// Returns true if this element can be focused by navigating with the tab key
	bool isTabStop() const
	{
		return IsTabStop;
	}


	/// Sets the priority of focus when using the tab key to navigate between a group of elements.
	/**
	* See_Also:
	* 	setTabGroup, isTabGroup and getTabGroup for information on tab groups.
	* Elements with a lower number are focused first 
	*/
	void setTabOrder(int index)
	{
		// negative = autonumber
		if (index < 0)
		{
			TabOrder = 0;
			IGUIElement el = getTabGroup();
			while (IsTabGroup && (el !is null) && (el.Parent !is null))
				el = el.Parent;

			IGUIElement first = null;
			IGUIElement closest = null;
			if (el !is null)
			{
				// find the highest element number
				el.getNextElement(-1, true, IsTabGroup, first, closest, true);
				if (first !is null)
				{
					TabOrder = first.getTabOrder() + 1;
				}
			}

		}
		else
			TabOrder = index;
	}


	/// Returns the number in the tab order sequence
	int getTabOrder() const
	{
		return TabOrder;
	}


	/// Sets whether this element is a container for a group of elements which can be navigated using the tab key.
	/**
	* For example, windows are tab groups.
	* Groups can be navigated using ctrl+tab, providing isTabStop is true. 
	*/
	void setTabGroup(bool isGroup)
	{
		IsTabGroup = isGroup;
	}


	/// Returns true if this element is a tab group.
	bool isTabGroup() const
	{
		return IsTabGroup;
	}


	/// Returns the container element which holds all elements in this element's tab group.
	IGUIElement getTabGroup()
	{
		IGUIElement ret = this;

		while ((ret !is null) && !ret.isTabGroup())
			ret = ret.getParent();

		return ret;
	}


	/// Returns true if element is enabled
	/**
	* Currently elements do _not_ care about parent-states.
	* So if you want to affect childs you have to enable/disable them all.
	* The only exception to this are sub-elements which also check their parent.
	*/
	bool isEnabled() const
	{
		if ( isSubElement() && IsEnabled && (getParent()!is null) )
			return getParent().isEnabled();

		return IsEnabled;
	}


	/// Sets the enabled state of this element.
	void setEnabled(bool enabled)
	{
		IsEnabled = enabled;
	}


	/// Sets the new caption of this element.
	void setText(wstring text)
	{
		Text = text;
	}


	/// Returns caption of this element.
	const wstring getText() const
	{
		return Text;
	}


	/// Sets the new caption of this element.
	void setToolTipText(const wstring text)
	{
		ToolTipText = text;
	}


	/// Returns caption of this element.
	const wstring getToolTipText() const
	{
		return ToolTipText;
	}


	/// Returns id. Can be used to identify the element.
	size_t getID() const
	{
		return ID;
	}


	/// Sets the id of this element
	void setID(size_t id)
	{
		ID = id;
	}


	/// Called if an event happened.
	bool OnEvent()(auto ref const SEvent event)
	{
		return (Parent !is null) ? Parent.OnEvent(event) : false;
	}


	/// Brings a child to front
	/**
	* Returns: True if successful, false if not. 
	*/
	bool bringToFront(IGUIElement element)
	{
		auto findResult = find(Children[], element);
		if(!findResult.empty)
		{
			Children.linearRemove(findResult.take(1));
			Children.insertBack(element);
			return true;
		} else
		{
			return false;
		}
	}

	/// Moves a child to the back, so it's siblings are drawn on top of it
	/**
	* Returns: True if successful, false if not. 
	*/
	bool sendToBack(IGUIElement child)
	{
		if (child == Children.front()) //already there
		{
			return true;
		}
		
		auto findResult = find(Children[], child);
		if(!findResult.empty)
		{
			Children.linearRemove(findResult.take(1));
			Children.insertFront(child);
			return true;
		} else
		{
			return false;
		}
	}

	/// Returns list with children of this element
	const(DList!IGUIElement) getChildren() const
	{
		return Children;
	}


	/// Finds the first element with the given id.
	/**
	* Params:
	* 	id=  Id to search for.
	* 	searchchildren=  Set this to true, if also children of this
	* element may contain the element with the searched id and they
	* should be searched too.
	* Returns: Returns the first element with the given id. If no element
	* with this id was found, null is returned. 
	*/
	IGUIElement getElementFromId(size_t id, bool searchchildren = false) const
	{
		IGUIElement e = null;
		
		foreach(child; cast(DList!IGUIElement)Children)
		{
			if (child.getID() == id)
				return child;
				
			if (searchchildren)
				e = child.getElementFromId(id, true);
				
			if (e !is null)
				return e;
		}

		return e;
	}


	/// returns true if the given element is a child of this one.
	/**
	* Params:
	* 	child= The child element to check
	*/
	bool isMyChild(IGUIElement child) const
	{
		if (child is null)
			return false;
		do
		{
			if (child.Parent !is null)
				child = child.Parent;

		} while ((child.Parent !is null) && (child != this));

		return child == this;
	}


	/// searches elements to find the closest next element to tab to
	/**
	* Params:
	* 	startOrder=  The TabOrder of the current element, -1 if none
	* 	reverse=  true if searching for a lower number
	* 	group=  true if searching for a higher one
	* 	first=  element with the highest/lowest known tab order depending on search direction
	* 	closest=  the closest match, depending on tab order and direction
	* 	includeInvisible=  includes invisible elements in the search (default=false)
	* Returns: true if successfully found an element, false to continue searching/fail 
	*/
	bool getNextElement(int startOrder, bool reverse, bool group,
		out IGUIElement first, out IGUIElement closest, bool includeInvisible=false) const
	{
		// we'll stop searching if we find this number
		int wanted = startOrder + ( reverse ? -1 : 1 );
		if (wanted==-2)
			wanted = int.max; // maximum int

		int closestOrder;
		int currentOrder;

		foreach(child; cast(DList!IGUIElement)Children)
		{
			// ignore invisible elements and their children
			if ( ( child.isVisible() || includeInvisible ) &&
				(group == true || child.isTabGroup() == false) )
			{
				// only check tab stops and those with the same group status
				if (child.isTabStop() && (child.isTabGroup() == group))
				{
					currentOrder = child.getTabOrder();

					// is this what we're looking for?
					if (currentOrder == wanted)
					{
						closest = child;
						return true;
					}

					// is it closer than the current closest?
					if (closest !is null)
					{
						closestOrder = closest.getTabOrder();
						if ( ( reverse && currentOrder > closestOrder && currentOrder < startOrder)
							||(!reverse && currentOrder < closestOrder && currentOrder > startOrder))
						{
							closest = child;
						}
					}
					else if ( (reverse && currentOrder < startOrder) || (!reverse && currentOrder > startOrder) )
					{
						closest = child;
					}

					// is it before the current first?
					if (first !is null)
					{
						closestOrder = first.getTabOrder();

						if ( (reverse && closestOrder < currentOrder) || (!reverse && closestOrder > currentOrder) )
						{
							first = child;
						}
					}
					else
					{
						first = child;
					}
				}
				// search within children
				if (child.getNextElement(startOrder, reverse, group, first, closest))
				{
					return true;
				}
			}
		}
		
		return false;
	}


	/// Returns the type of the gui element.
	/**
	* This is needed for the .NET wrapper but will be used
	* later for serializing and deserializing.
	* If you wrote your own GUIElements, you need to set the type for your element as first parameter
	* in the constructor of IGUIElement. For own (=unknown) elements, simply use EGUIET_ELEMENT as type 
	*/
	EGUI_ELEMENT_TYPE getType() const
	{
		return Type;
	}

	/// Returns true if the gui element supports the given type.
	/**
	* This is mostly used to check if you can cast a gui element to the class that goes with the type.
	* Most gui elements will only support their own type, but if you derive your own classes from interfaces
	* you can overload this function and add a check for the type of the base-class additionally.
	* This allows for checks comparable to the dynamic_cast of c++ with enabled rtti.
	* Note that you can't do that by calling BaseClass::hasType(type), but you have to do an explicit
	* comparison check, because otherwise the base class usually just checks for the membervariable
	* Type which contains the type of your derived class.
	*/
	bool hasType(EGUI_ELEMENT_TYPE type) const
	{
		return type == Type;
	}


	/// Returns the type name of the gui element.
	/**
	* This is needed serializing elements. For serializing your own elements, override this function
	* and return your own type name which is created by your IGUIElementFactory 
	*/
	const string getTypeName() const
	{
		return GUIElementTypeNames[Type];
	}
	
	/// Returns the name of the element.
	/**
	* Returns: Name as character string. 
	*/
	const string getName() const
	{
		return Name;
	}


	/// Sets the name of the element.
	/**
	* Params:
	* 	name=  New name of the gui element. 
	*/
	void setName(const string name)
	{
		Name = name;
	}

	/// Writes attributes of the scene node.
	/**
	* Implement this to expose the attributes of your scene node for
	* scripting languages, editors, debuggers or xml serialization purposes. 
	*/
	void serializeAttributes(out IAttributes outAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions()) const
	{
		outAttr.add("Name", Name);		
		outAttr.add("Id", cast(ulong)ID ); // aware cross machine incompabilites
		outAttr.add("Caption", getText());
		outAttr.add("Rect", DesiredRect);
		outAttr.add("MinSize", vector2di(MinSize.Width, MinSize.Height));
		outAttr.add("MaxSize", vector2di(MaxSize.Width, MaxSize.Height));
		outAttr.addEnum("LeftAlign", AlignLeft, GUIAlignmentNames);
		outAttr.addEnum("RightAlign", AlignRight, GUIAlignmentNames);
		outAttr.addEnum("TopAlign", AlignTop, GUIAlignmentNames);
		outAttr.addEnum("BottomAlign", AlignBottom, GUIAlignmentNames);
		outAttr.add("Visible", IsVisible);
		outAttr.add("Enabled", IsEnabled);
		outAttr.add("TabStop", IsTabStop);
		outAttr.add("TabGroup", IsTabGroup);
		outAttr.add("TabOrder", TabOrder);
		outAttr.add("NoClip", NoClip);
	}


	/// Reads attributes of the scene node.
	/**
	* Implement this to set the attributes of your scene node for
	* scripting languages, editors, debuggers or xml deserialization purposes. 
	*/
	void deserializeAttributes(IAttributes inAttr, SAttributeReadWriteOptions options = SAttributeReadWriteOptions())
	{
		setName(inAttr.getAttribute!string("Name"));
		setID(cast(size_t)inAttr.getAttribute!ulong("Id"));
		setText(inAttr.getAttribute!wstring("Caption"));
		setVisible(inAttr.getAttribute!bool("Visible"));
		setEnabled(inAttr.getAttribute!bool("Enabled"));
		IsTabStop = inAttr.getAttribute!bool("TabStop");
		IsTabGroup = inAttr.getAttribute!bool("TabGroup");
		TabOrder = inAttr.getAttribute!int("TabOrder");

		vector2di p = inAttr.getAttribute!vector2di("MaxSize");
		setMaxSize(dimension2du(p.X,p.Y));

		p = inAttr.getAttribute!vector2di("MinSize");
		setMinSize(dimension2du(p.X,p.Y));

		setAlignment(cast(EGUI_ALIGNMENT) inAttr.getAttributeAsEnumeration("LeftAlign", GUIAlignmentNames),
			cast (EGUI_ALIGNMENT) inAttr.getAttributeAsEnumeration("RightAlign", GUIAlignmentNames),
			cast (EGUI_ALIGNMENT) inAttr.getAttributeAsEnumeration("TopAlign", GUIAlignmentNames),
			cast (EGUI_ALIGNMENT) inAttr.getAttributeAsEnumeration("BottomAlign", GUIAlignmentNames));

		setRelativePosition(inAttr.getAttribute!(rect!int)("Rect"));

		setNotClipped(inAttr.getAttribute!bool("NoClip"));
	}

	// not virtual because needed in constructor
	protected final void addChildToEnd(IGUIElement child)
	{
		if (child !is null)
		{
			child.remove(); // remove from old parent
			child.LastParentRect = getAbsolutePosition();
			child.Parent = this;
			Children.insertBack(child);
		}
	}

	// not virtual because needed in constructor
	protected final void recalculateAbsolutePosition(bool recursive)
	{
		auto parentAbsolute = rect!int(0,0,0,0);
		rect!int parentAbsoluteClip;
		
		float fw = 0.0f;
		float fh = 0.0f;

		if (Parent !is null)
		{
			parentAbsolute = Parent.AbsoluteRect;

			if (NoClip)
			{
				IGUIElement p = this;
				
				while ((p !is null) && (p.Parent !is null))
					p = p.Parent;
					
				parentAbsoluteClip = p.AbsoluteClippingRect;
			}
			else
				parentAbsoluteClip = Parent.AbsoluteClippingRect;
		}

		immutable int diffx = parentAbsolute.getWidth() - LastParentRect.getWidth();
		immutable int diffy = parentAbsolute.getHeight() - LastParentRect.getHeight();

		if (AlignLeft == EGUI_ALIGNMENT.EGUIA_SCALE || AlignRight == EGUI_ALIGNMENT.EGUIA_SCALE)
			fw = cast(float) parentAbsolute.getWidth();

		if (AlignTop == EGUI_ALIGNMENT.EGUIA_SCALE || AlignBottom == EGUI_ALIGNMENT.EGUIA_SCALE)
			fh = cast(float) parentAbsolute.getHeight();

		final switch (AlignLeft)
		{
			case EGUI_ALIGNMENT.EGUIA_UPPERLEFT:
				break;
			case EGUI_ALIGNMENT.EGUIA_LOWERRIGHT:
				DesiredRect.UpperLeftCorner.X += diffx;
				break;
			case EGUI_ALIGNMENT.EGUIA_CENTER:
				DesiredRect.UpperLeftCorner.X += diffx/2;
				break;
			case EGUI_ALIGNMENT.EGUIA_SCALE:
				DesiredRect.UpperLeftCorner.X = cast(int)round(ScaleRect.UpperLeftCorner.X * fw);
				break;
		}

		final switch (AlignRight)
		{
			case EGUI_ALIGNMENT.EGUIA_UPPERLEFT:
				break;
			case EGUI_ALIGNMENT.EGUIA_LOWERRIGHT:
				DesiredRect.LowerRightCorner.X += diffx;
				break;
			case EGUI_ALIGNMENT.EGUIA_CENTER:
				DesiredRect.LowerRightCorner.X += diffx/2;
				break;
			case EGUI_ALIGNMENT.EGUIA_SCALE:
				DesiredRect.LowerRightCorner.X = cast(int)round(ScaleRect.LowerRightCorner.X * fw);
				break;
		}

		final switch (AlignTop)
		{
			case EGUI_ALIGNMENT.EGUIA_UPPERLEFT:
				break;
			case EGUI_ALIGNMENT.EGUIA_LOWERRIGHT:
				DesiredRect.UpperLeftCorner.Y += diffy;
				break;
			case EGUI_ALIGNMENT.EGUIA_CENTER:
				DesiredRect.UpperLeftCorner.Y += diffy/2;
				break;
			case EGUI_ALIGNMENT.EGUIA_SCALE:
				DesiredRect.UpperLeftCorner.Y = cast(int)round(ScaleRect.UpperLeftCorner.Y * fh);
				break;
		}

		final switch (AlignBottom)
		{
			case EGUI_ALIGNMENT.EGUIA_UPPERLEFT:
				break;
			case EGUI_ALIGNMENT.EGUIA_LOWERRIGHT:
				DesiredRect.LowerRightCorner.Y += diffy;
				break;
			case EGUI_ALIGNMENT.EGUIA_CENTER:
				DesiredRect.LowerRightCorner.Y += diffy/2;
				break;
			case EGUI_ALIGNMENT.EGUIA_SCALE:
				DesiredRect.LowerRightCorner.Y = cast(int)round(ScaleRect.LowerRightCorner.Y * fh);
				break;
		}

		RelativeRect = DesiredRect;

		immutable int w = RelativeRect.getWidth();
		immutable int h = RelativeRect.getHeight();

		// make sure the desired rectangle is allowed
		if (w < cast(int)MinSize.Width)
			RelativeRect.LowerRightCorner.X = RelativeRect.UpperLeftCorner.X + MinSize.Width;
		if (h < cast(int)MinSize.Height)
			RelativeRect.LowerRightCorner.Y = RelativeRect.UpperLeftCorner.Y + MinSize.Height;
		if (MaxSize.Width && w > cast(int)MaxSize.Width)
			RelativeRect.LowerRightCorner.X = RelativeRect.UpperLeftCorner.X + MaxSize.Width;
		if (MaxSize.Height && h > cast(int)MaxSize.Height)
			RelativeRect.LowerRightCorner.Y = RelativeRect.UpperLeftCorner.Y + MaxSize.Height;

		RelativeRect.repair();

		AbsoluteRect = RelativeRect + parentAbsolute.UpperLeftCorner;

		if (Parent is null)
			parentAbsoluteClip = AbsoluteRect;

		AbsoluteClippingRect = AbsoluteRect;
		AbsoluteClippingRect.clipAgainst(parentAbsoluteClip);

		LastParentRect = parentAbsolute;

		if ( recursive )
		{
			// update all children
			foreach(child; Children)
			{
				child.recalculateAbsolutePosition(recursive);
			}
		}
	}

	protected
	{
		/// List of all children of this element
		DList!IGUIElement Children;

		/// Pointer to the parent
		IGUIElement Parent;

		/// relative rect of element
		rect!int RelativeRect;

		/// absolute rect of element
		rect!int AbsoluteRect;

		/// absolute clipping rect of element
		rect!int AbsoluteClippingRect;

		/// the rectangle the element would prefer to be,
		/// if it was not constrained by parent or max/min size
		rect!int DesiredRect;

		/// for calculating the difference when resizing parent
		rect!int LastParentRect;

		/// relative scale of the element inside its parent
		rect!float ScaleRect;

		/// maximum and minimum size of the element
		dimension2du MaxSize; 
		
		dimension2du MinSize;

		/// is visible?
		bool IsVisible;

		/// is enabled?
		bool IsEnabled;

		/// is a part of a larger whole and should not be serialized?
		bool IsSubElement;

		/// does this element ignore its parent's clipping rectangle?
		bool NoClip;

		/// caption
		wstring Text;

		/// tooltip
		wstring ToolTipText;
	
		/// users can set this for identificating the element by string
		string Name;

		/// users can set this for identificating the element by integer
		size_t ID;

		/// tab stop like in windows
		bool IsTabStop;

		/// tab order
		int TabOrder;

		/// tab groups are containers like windows, use ctrl+tab to navigate
		bool IsTabGroup;

		/// tells the element how to act when its parent is resized
		EGUI_ALIGNMENT AlignLeft, AlignRight, AlignTop, AlignBottom;

		/// GUI Environment
		IGUIEnvironment Environment;

		/// type of element
		EGUI_ELEMENT_TYPE Type;
	}
}
