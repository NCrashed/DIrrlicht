// Copyright (C) 2009-2012 Christian Stehno
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.SVertexManipulator;

import irrlicht.video.S3DVertex;
import irrlicht.video.SColor;
import irrlicht.video.IMesh;
import irrlicht.video.IMeshBuffer;
import irrlicht.scene.SMesh;
import irrlicht.core.vector3d;
import irrlicht.core.vector2d;
import irrlicht.core.matrix4;
import irrlicht.irrMath;
import std.math;

/// Interface for vertex manipulators.
/**
* You should derive your manipulator from this class if it shall 
* be called for every vertex, getting as parameter just the vertex.
*/
interface IVertexManipulator 
{
	/// Functional operator
	/**
	* You should override opCall to handle three possible vertex types:
	* S3DVertex, S3DVertex2TCoords and S3DVertexTangents.
	*/
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents));
}

/// Vertex manipulator to set color to a fixed color for all vertices
class SVertexColorSetManipulator : IVertexManipulator
{
	this(SColor color)
	{
		Color = color;
	} 

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = Color;
	}

	private SColor Color;
}

/// Vertex manipulator to set the alpha value of the vertex color to a fixed value
class SVertexColorSetAlphaManipulator : IVertexManipulator
{
	this(uint alpha) 
	{
		Alpha = alpha;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setAlpha(Alpha);
	}

	private uint Alpha;
}

/// Vertex manipulator which invertes the RGB values
class SVertexColorInvertManipulator : IVertexManipulator
{
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(255-vertex.Color.getRed());
		vertex.Color.setGreen(255-vertex.Color.getGreen());
		vertex.Color.setBlue(255-vertex.Color.getBlue());
	}
}

/// Vertex manipulator to set vertex color to one of two values depending on a given threshold
/**
* If average of the color value is >Threshold the High color is chosen, else Low. 
*/
class SVertexColorThresholdManipulator : IVertexManipulator
{
	this(ubyte threshold, SColor low,
		SColor high)
	{
		Threshold = threshold;
		Low = low;
		High = high;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = (cast(ubyte)vertex.Color.getAverage() > Threshold) ? High : Low;
	}

	private
	{
		ubyte Threshold;
		SColor Low;
		SColor High;
	}
}

/// Vertex manipulator which adjusts the brightness by the given amount
/**
* A positive value increases brightness, a negative value darkens the colors. 
*/
class SVertexColorBrightnessManipulator : IVertexManipulator
{
	this(int amount) 
	{
		Amount = amount;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(cast(ubyte)clamp(vertex.Color.getRed()+Amount, 0, 255));
		vertex.Color.setGreen(cast(ubyte)clamp(vertex.Color.getGreen()+Amount, 0, 255));
		vertex.Color.setBlue(cast(ubyte)clamp(vertex.Color.getBlue()+Amount, 0, 255));
	}

	private int Amount;
}

/// Vertex manipulator which adjusts the contrast by the given factor
/**
* Factors over 1 increase contrast, below 1 reduce it. 
*/
class SVertexColorContrastManipulator : IVertexManipulator
{
	this(float factor)
	{
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(cast(ubyte)clamp(cast(int)round((vertex.Color.getRed()-128)*Factor)+128, 0, 255));
		vertex.Color.setGreen(cast(ubyte)clamp(cast(int)round((vertex.Color.getGreen()-128)*Factor)+128, 0, 255));
		vertex.Color.setBlue(cast(ubyte)clamp(cast(int)round((vertex.Color.getBlue()-128)*Factor)+128, 0, 255));
	}

	private float Factor;
}

/// Vertex manipulator which adjusts the contrast by the given factor and brightness by a signed amount.
/**
* Factors over 1 increase contrast, below 1 reduce it.
* A positive amount increases brightness, a negative one darkens the colors. 
*/
class SVertexColorContrastBrightnessManipulator : IVertexManipulator
{
	this(float factor, int amount)
	{
		Factor = factor;
		Amount = amount+128;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(cast(ubyte)clamp(cast(int)round((vertex.Color.getRed()-128)*Factor)+Amount, 0, 255));
		vertex.Color.setGreen(cast(ubyte)clamp(cast(int)round((vertex.Color.getGreen()-128)*Factor)+Amount, 0, 255));
		vertex.Color.setBlue(cast(ubyte)clamp(cast(int)round((vertex.Color.getBlue()-128)*Factor)+Amount, 0, 255));
	}

	private float Factor;
	private int Amount;
}

/// Vertex manipulator which adjusts the brightness by a gamma operation
/**
* A value over one increases brightness, one below darkens the colors. 
*/
class SVertexColorGammaManipulator : IVertexManipulator
{
	this(float gamma)
	{
		if (gamma != 0.0f)
			Gamma = 1.0f/gamma;
		else
			Gamma = 1.0f;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(cast(ubyte)clamp(cast(int)round(pow(cast(float)(vertex.Color.getRed()),Gamma)), 0, 255));
		vertex.Color.setGreen(cast(ubyte)clamp(cast(int)round(pow(cast(float)(vertex.Color.getGreen()),Gamma)), 0, 255));
		vertex.Color.setBlue(cast(ubyte)clamp(cast(int)round(pow(cast(float)(vertex.Color.getBlue()),Gamma)), 0, 255));
	}

	private float Gamma;
}

/// Vertex manipulator which scales the color values
/**
* Can e.g be used for white balance, factor would be 255.f/brightest color. 
*/
class SVertexColorScaleManipulator : IVertexManipulator
{
	this(float factor)
	{
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color.setRed(cast(ubyte)clamp(cast(int)round(vertex.Color.getRed()*Factor), 0, 255));
		vertex.Color.setGreen(cast(ubyte)clamp(cast(int)round(vertex.Color.getGreen()*Factor), 0, 255));
		vertex.Color.setBlue(cast(ubyte)clamp(cast(int)round(vertex.Color.getBlue()*Factor), 0, 255));
	}

	private float Factor;
}

/// Vertex manipulator which desaturates the color values
/**
* Uses the lightness value of the color. 
*/
class SVertexColorDesaturateToLightnessManipulator : IVertexManipulator
{
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = SColor(cast(ubyte)round(vertex.Color.getLightness()));
	}
}

/// Vertex manipulator which desaturates the color values
/**
* Uses the average value of the color. 
*/
class SVertexColorDesaturateToAverageManipulator : IVertexManipulator
{
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = SColor(vertex.Color.getAverage());
	}
}

/// Vertex manipulator which desaturates the color values
/**
* Uses the luminance value of the color. 
*/
class SVertexColorDesaturateToLuminanceManipulator : IVertexManipulator
{
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = SColor(cast(ubyte)round(vertex.Color.getLuminance()));
	}
}

/// Vertex manipulator which interpolates the color values
/**
* Uses linear interpolation. 
*/
class SVertexColorInterpolateLinearManipulator : IVertexManipulator
{
	this(SColor color, float factor)
	{
		Color = color;
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = vertex.Color.getInterpolated(Color, Factor);
	}

	private SColor Color;
	private float Factor;
}

/// Vertex manipulator which interpolates the color values
/**
* Uses linear interpolation. 
*/
class SVertexColorInterpolateQuadraticManipulator : IVertexManipulator
{
	this(SColor color1, SColor color2, float factor)
	{
		Color1 = color1;
		Color2 = color2;
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Color = vertex.Color.getInterpolated_quadratic(Color1, Color2, Factor);
	}

	private SColor Color1;
	private SColor Color2;
	private float Factor;
}

/// Vertex manipulator which scales the position of the vertex
class SVertexPositionScaleManipulator : IVertexManipulator
{
	this()(auto ref const vector3df factor)
	{
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Pos *= Factor;
	}

	private vector3df Factor;
}

/// Vertex manipulator which scales the position of the vertex along the normals
/**
* This can look more pleasing than the usual Scale operator, but
* depends on the mesh geometry.
*/
class SVertexPositionScaleAlongNormalsManipulator : IVertexManipulator
{
	this()(auto ref const vector3df factor)
	{
		Factor = factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		vertex.Pos += vertex.Normal*Factor;
	}

	private vector3df Factor;
}

/// Vertex manipulator which transforms the position of the vertex
class SVertexPositionTransformManipulator : IVertexManipulator
{
	this()(auto ref const matrix4 m)
	{
		Transformation = m;
	}
	
	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertex2TCoords) ||
			is(VType == S3DVertexTangents))
	{
		Transformation.transformVect(vertex.Pos);
	}

	private matrix4 Transformation;
}

/// Vertex manipulator which scales the TCoords of the vertex
class SVertexTCoordsScaleManipulator : IVertexManipulator
{
	this()(auto ref const vector2df factor, uint uvSet = 1u)
	{
		Factor = factor;
		UVSet = uvSet;
	} 

	void opCall(VType)(ref VType vertex) const
		if(is(VType == S3DVertex2TCoords))
	{
		if (UVSet == 1)
			vertex.TCoords *= Factor;
		else if (UVSet == 2)
			vertex.TCoords2 *= Factor;
	}

	void opCall(VType)(ref VType vertex) const
		if( is(VType == S3DVertex) ||
			is(VType == S3DVertexTangents))
	{
		if (UVSet == 1)
			vertex.TCoords *= Factor;
	}

	private vector2df Factor;
	private uint UVSet;
}