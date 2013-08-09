// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.rect;

import irrlicht.core.vector2d;
import irrlicht.core.dimension2d;
//import irrlicht.core.position2d; deprecated
import std.algorithm : swap;

/// Rectangle template.
/** 
* Mostly used by 2D GUI elements and for 2D drawing methods.
* It has 2 positions instead of position and dimension and a fast
* method for collision detection with other rectangles and points.
* 
* Coordinates are (0,0) for top-left corner, and increasing to the right
* and to the bottom.
*/
struct rect(T)
{
	this()()
	{
		UpperLeftCorner = vector2d!T(0, 0);
		LowerRightCorner = vector2d!T(0, 0);
	}

	/// Constructor with two corners
	this()(T x, T y, T x2, T y2)
	{
		UpperLeftCorner = vector2d!T(x, y);
		LowerRightCorner = vector2d!T(x2, y2);
	}

	/// Constructor with upper left corner and dimension
	this(U)(auto ref const vector2d!T pos, auto ref const dimension2d!U size)
	{
		UpperLeftCorner = pos;
		LowerRightCorner = vector2d!T(pos.X + size.Width, pos.Y + size.Height);
	}

	/// Move right/left by given numbers
	rect!T opBinary(string op)(auto ref const vector2d!T pos)
		if(op == "+" || op == "-")
	{
		rect!T ret = this;
		mixin("return ret "~op~"= pos;");
	}

	/// Move right/left by given numbers
	auto ref rect!T opOpAssign(string op)(auto ref const vector2d!T pos)
		if(op == "+" || op == "-")
	{
		mixin("UpperLeftCorner "~op~"= pos;");
		mixin("LowerRightCorner "~op~"= pos;");
		return this;
	}

	/// equality operator
	bool opEqual()(auto ref const rect!T other)
	{
		return (UpperLeftCorner == other.UpperLeftCorner &&
			LowerRightCorner == other.LowerRightCorner);
	}

	/// Compares by areas
	bool opCmp()(auto ref const rect!T other)
	{
		if(getArea() < other.getArea())
		{
			return -1;
		} else if(getArea() > other.getArea())
		{
			return 1;
		}
		return 0;
	}

	/// Returns size of rectangle
	T getArea()
	{
		return getWidth() * getHeight();
	}

	/// Returns if a 2d point is within this rectangle.
	/**
	*	Params:
	*	pos Position to test if it lies within this rectangle.
	*
	*	Returns:
	*	True if the position is within the rectangle, false if not.
	*/
	bool isPointInside()(auto ref const vector2d!T pos)
	{
		return (UpperLeftCorner.X <= pos.X &&
			UpperLeftCorner.Y <= pos.Y &&
			LowerRightCorner.X >= pos.X &&
			LowerRightCorner.Y >= pos.Y);
	}

	/// Check if the rectangle collides with another rectangle.
	/**
	*	Params:
	*	other	Rectangle to test collision with
	*	
	*	Returns: True if the rectangles collide.
	*/
	bool isRectCollided()(auto ref const rect!T other)
	{
		return (LowerRightCorner.Y > other.UpperLeftCorner.Y &&
			UpperLeftCorner.Y < other.LowerRightCorner.Y &&
			LowerRightCorner.X > other.UpperLeftCorner.X &&
			UpperLeftCorner.X < other.LowerRightCorner.X);
	}

	/// Clips this rectangle with another one.
	/**
	*	Params:
	*	other	Rectangle to clip with
	*/
	void clipAgainst()(auto ref const rect!T other)
	{
		if (other.LowerRightCorner.X < LowerRightCorner.X)
			LowerRightCorner.X = other.LowerRightCorner.X;
		if (other.LowerRightCorner.Y < LowerRightCorner.Y)
			LowerRightCorner.Y = other.LowerRightCorner.Y;

		if (other.UpperLeftCorner.X > UpperLeftCorner.X)
			UpperLeftCorner.X = other.UpperLeftCorner.X;
		if (other.UpperLeftCorner.Y > UpperLeftCorner.Y)
			UpperLeftCorner.Y = other.UpperLeftCorner.Y;

		// correct possible invalid rect resulting from clipping
		if (UpperLeftCorner.Y > LowerRightCorner.Y)
			UpperLeftCorner.Y = LowerRightCorner.Y;
		if (UpperLeftCorner.X > LowerRightCorner.X)
			UpperLeftCorner.X = LowerRightCorner.X;
	}

	/// Moves this rectangle to fit inside another one.
	/**
	* Returns: True on success, false if not possible.
	*/
	bool constrainTo()(auto ref const rect!T other)
	{
		if (other.getWidth() < getWidth() || other.getHeight() < getHeight())
			return false;

		T diff = other.LowerRightCorner.X - LowerRightCorner.X;
		if (diff < 0)
		{
			LowerRightCorner.X += diff;
			UpperLeftCorner.X += diff;
		}

		diff = other.LowerRightCorner.Y - LowerRightCorner.Y;
		if (diff < 0)
		{
			LowerRightCorner.Y += diff;
			UpperLeftCorner.Y += diff;
		}

		diff = UpperLeftCorner.X - other.UpperLeftCorner.X;
		if (diff < 0)
		{
			UpperLeftCorner.X -= diff;
			LowerRightCorner.X -= diff;
		}

		diff = UpperLeftCorner.Y - other.UpperLeftCorner.Y;
		if (diff < 0)
		{
			UpperLeftCorner.Y -= diff;
			LowerRightCorner.Y -= diff;
		}

		return true;
	}

	/// Get width of rectangle
	T getWidth() const
	{
		return LowerRightCorner.X - UpperLeftCorner.X;
	}

	/// Get height of rectangle
	T getHeight() const
	{
		return LowerRightCorner.Y - UpperLeftCorner.Y;
	}

	/// If the lower right corner of the rect is smaller then upper left, the points are swapped.
	void repair()
	{
		if (LowerRightCorner.X < UpperLeftCorner.X)
		{
			std.algorithm.swap(LowerRightCorner.X, UpperLeftCorner.X);
		}

		if (LowerRightCorner.Y < UpperLeftCorner.Y)
		{
			std.algorithm.swap(LowerRightCorner.Y, UpperLeftCorner.Y);
		}
	}

	/// Returns if the rect is valid to draw
	/**
	* It would be invalid if the UpperLeftCorner is lower or more
	* right than the LowerRightCorner.
	*/
	bool isValid() const
	{
		return ((LowerRightCorner.X >= UpperLeftCorner.X) &&
			(LowerRightCorner.Y >= UpperLeftCorner.Y));
	}

	/// Get the center of the rectangle
	vector2d!T getCenter() const
	{
		return vector2d!T(
			(UpperLeftCorner.X + LowerRightCorner.X) / 2,
			(UpperLeftCorner.Y + LowerRightCorner.Y) / 2);
	}

	/// Get the dimensions of the rectangle
	vector2d!T getSize() const
	{
		return vector2d!T(getWidth(), getHeight());
	}

	/// Adds a point to the rectangle
	/**
	* Causes the rectangle to grow bigger if point is outside 
	* the box.
	*
	* Params:
	* p 	Point to add to the box.
	*/
	void addInternalPoint()(auto ref const vector2d!T p)
	{
		addInternalPoint(p.X, p.Y);
	}

	/// Adds a point to the bounding rectangle
	/**
	* Causes the rectangle to grow bigger if point is outside
	* ther box.
	*
	* Params:
	* x 	X-Coordinate of the point to add to this box.
	* y 	Y-Coordinate of the point ot add to this box.
	*/
	void addInternalPoint()(T x, T y)
	{
		if (x > LowerRightCorner.X)
			LowerRightCorner.X = x;
		if (y > LowerRightCorner.Y)
			LowerRightCorner.Y = y;

		if (x < UpperLeftCorner.X)
			UpperLeftCorner.X = x;
		if (y < UpperLeftCorner.Y)
			UpperLeftCorner.Y = y;
	}

	/// Upper left corner
	vector2d!T UpperLeftCorner;

	/// Lower right corner
	vector2d!T LowerRightCorner;
}

/// Rectangle with float values
alias rect!float rectf;

/// Rectangle with int values
alias rect!int recti;