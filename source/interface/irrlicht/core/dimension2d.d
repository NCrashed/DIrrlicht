// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.core.dimension2d;

import irrlicht.core.vector2d;

/// Specifies a 2 dimensional size
struct dimension2d(T)
{
	public
	{
		/// Constructor with width and height
		this()(const T width, const T height)
		{
			Width = width;
			Height = height;
		}

		this()(auto ref const vector2d!T other)
		{
			Width = other.X;
			Height = other.Y;
		}

		/// Use this constructor only where you are sure that 
		/// conversion is valid.
		this(U)(auto ref const dimension2d!U other)
		{
			Width = cast(T)other.Width;
			Height = cast(T)other.Height;
		}

		auto ref dimension2d!T opAssign(U)(auto ref const dimension2d!U other)
		{
			Width = cast(T)other.Width;
			Height = cast(T)other.Height;
			return this;
		}

		/// Equality operator
		bool opEqual()(auto ref const dimension2d!T other)
		{
			return Width == other.Width &&
				Height == other.Height;
		}

		bool opEqual()(auto ref const vector2d!T other)
		{
			return other.X == Width && other.Y == Height;
		}

		/// Set to new values
		dimension2d!T set(const T width, const T height)
		{
			Width = width;
			Height = height;
			return this;
		}

		/// Divide width and height by scalar
		auto ref dimension2d!T opOpAssign(string op)(auto ref const T scale)
			if(op == "/")
		{
			Width /= scale;
			Height /= scale;
			return this;
		}

		/// Divide width and height by scalar
		dimension2d!T opBinary(string op)(const T scale)
			if(op == "/")
		{
			return dimension2d!T(Width/scale, Height/scale);
		}

		/// Multiply width and height by scalar
		auto ref dimension2d!T opOpAssign(string op)(auto ref const T scale)
			if(op == "*")
		{
			Width *= scale;
			Height *= scale;
			return this;
		}

		/// Multiply width and height by scalar
		dimension2d!T opBinary(string op)(const T scale)
			if(op == "*")
		{
			return dimension2d!T(Width*sacle, Height*scale);
		}

		/// Add another dimension to this one
		auto ref dimension2d!T opOpAssign(string op)(auto ref const dimension2d other)
			if(op == "+")
		{
			Width += other.Width;
			Height += other.Height;
			return this;
		}

		/// Add two dimensions
		dimension2d!T opBinary(string op)(const dimension2d!T other)
			if(op == "+")
		{
			return dimension2d!T(Width+other.Width, Height+other.Height);
		}

		/// Subtract a dimension from this one
		auto ref dimension2d!T opOpAssign(string op)(auto ref const dimension2d!T other)
			if(op == "-")
		{
			Width -=  other.Width;
			Height -= other.Height;
			return this;
		}

		/// Subtract a dimension from another
		dimension2d!T opBinary(string op)(const dimension2d!T other)
		{
			return dimension2d!T(Width-other.Width, Height-other.Height);
		}

		/// Get area
		T getArea()
		{
			return Width*Height;
		}

		/// Get the optimal size according to some properties
		/** 
		* This is a function often used for texture dimension
		* calculations. The function returns the next larger or
		* smaller dimension which is a power-of-two dimension
		* (2^n,2^m) and/or square (Width=Height).
		* Params:
		* requirePowerOfTwo 	Forces the result to use only
		* powers of two as values.
		* requireSquare 		Makes width==height in the result
		* larger 				Choose whether the result is larger or
		* smaller than the current dimension. If one dimension
		* need not be changed it is kept with any value of larger.
		* maxValue 				Maximum texturesize. if value > 0 size is
		* clamped to maxValue
		* 
		* Returns: The optimal dimension under the given
		* constraints. 
		*/
		dimension2d!T getOptimalSize(
			bool requirePowerOfTwo = true,
			bool requireSquare = false,
			bool larger = true,
			uint maxValue = 0)
		{
			uint i = 1;
			uint j = 1;

			if(requirePowerOfTwo)
			{
				while(i < cast(uint)Width)
				{
					i <<= 1;
				}
				if(!larger && i!=1 && i!=cast(uint)Width)
				{
					i >>= 1;
				}

				while(j < cast(uint)Height)
				{
					j <<= 1;
				}
				if(!larger && j!=1 && j!=cast(uint)Height)
				{
					j >>= 1;
				}
			} else
			{
				i = cast(uint)Width;
				j = cast(uint)Height;
			}

			if(requireSquare)
			{
				if((larger && (i>j)) || (!larger && (i<j)))
				{
					j = i;
				}
				else
				{
					i = j;
				}
			}

			if(maxValue > 0 && i > maxValue)
				i = maxValue;

			if(maxValue > 0 && j > maxValue)
				j = maxValue;

			return dimension2d!T(cast(T)i, cast(T)j);
		}

		/// Get the interpolated dimension
		/** 
		* Params:
		* other 	Other dimension to interpolate with.
		* d 		Value between 0.0f and 1.0f.
		*
		* Returns: Interpolated dimension. 
		*/
		dimension2d!T getInterpolated(const dimension2d!T other, float d)
		{
			float inv = (1.0f - d);
			return dimension2d!T( cast(T)(other.Width*inv + Width*d), cast(T)(other.Height*inv + Height*d));
		}

		/// Width of the dimension
		T Width;

		/// Height of the dimension
		T Height;
	}
}

/// Alias for an float dimension.
alias dimension2d!float dimension2df;

/// Alias for an unsigned integer dimension.
alias dimension2d!uint dimension2du;

/// Alias for an integer dimension.
/**
*	There are few cases where negative dimensions make sense.
*	Please consider using dimension2du instead.
*/
alias dimension2d!int dimension2di;