// Copyright (C) 2006-2012 Nikolaus Gebhardt / Thomas Alten
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.quake3.IQ3Shader;

import irrlicht.io.IFileSystem;
import irrlicht.video.IVideoDriver;
import irrlicht.video.SMaterial;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.EMaterialTypes;
import irrlicht.video.ITexture;
import irrlicht.video.IImage;
import irrlicht.video.SColor;
import irrlicht.core.vector3d;
import irrlicht.core.dimension2d;
import irrlicht.irrMath;
import std.path;
import std.conv;
import std.algorithm;
import std.string;
import std.math;


/// Hold the different Mesh Types used for getMesh
enum eQ3MeshIndex
{
	E_Q3_MESH_GEOMETRY = 0,
	E_Q3_MESH_ITEMS,
	E_Q3_MESH_BILLBOARD,
	E_Q3_MESH_FOG,
	E_Q3_MESH_UNRESOLVED,
	E_Q3_MESH_SIZE
}

/// Used to customize Quake3 BSP Loader
struct Q3LevelLoadParameter
{
	E_MATERIAL_TYPE defaultLightMapMaterial = E_MATERIAL_TYPE.EMT_LIGHTMAP_M4;
	E_MODULATE_FUNC defaultModulate = E_MODULATE_FUNC.EMFN_MODULATE_4X;
	E_MATERIAL_FLAG defaultFilter = E_MATERIAL_FLAG.EMF_BILINEAR_FILTER;
	int patchTesselation = 8;
	int verbose = 0;
	uint startTime = 0;
	uint endTime = 0;
	int mergeShaderBuffer = 1;
	int cleanUnResolvedMeshes = 1;
	int loadAllShaders = 0;
	int loadSkyShader = 0;
	int alpharef = 1;
	int swapLump = 0;

	version(LittleEndian)
	{
		int swapHeader = 1;
	}
	else version(BigEndian)
	{
		int swapHeader = 0;
	}

	string scriptDir = "scripts";
}

/// get a quake3 vector translated to irrlicht position (x,-z,y )
vector3df getAsVector3df(ref string inputString)
{
	vector3df v;

	inputString = munch(inputString, " \t\n\r");
	v.X = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
	v.Z = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
	v.Y = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");

	return v;
}
unittest
{
	string input = "0.34f 0.1 10";
	assert(getAsVector3df(input) == vector3df(0.34f, 0.1f, 10.0f));
	assert(input == "");

	input = " 0 \t\n 5 \r 20 some text";
	assert(getAsVector3df(input) == vector3df(0.0f, 5.0f, 20.0f));
	assert(input == "some text");
}

/*
	extract substrings
*/
string[] getAsStringList(size_t max, ref string inputString)
{
	string[] list = [];

	do
	{
		auto tail = find(inputString, ' ');
		if(tail.length == 0) 
		{
			if(inputString == "")
				return list;
			else
				return list ~ inputString;
		}

		list ~= inputString[0..$-tail.length+1];
		inputString = tail[1..$];

		if ( list.length >= max )
		{
			return list;
		}
	} while ( inputString != "" );

	return list;
}
unittest
{
	string input = "val1 val2 val3";
	assert(getAsStringList(3, input) == ["val1", "val2", "val3"]);
	assert(input == "");

	input = "";
	assert(getAsStringList(3, input) == []);
	assert(input == "");

	input = "val1 val2 val3 val4 val5";
	assert(getAsStringList(3, input) == ["val1", "val2", "val3"]);
	assert(input == "val4 val5");
}

/// A blend function for a q3 shader.
struct SBlendFunc
{
	this( E_MODULATE_FUNC mod )
	{
		modulate = mod;
	}

	E_MATERIAL_TYPE type = E_MATERIAL_TYPE.EMT_SOLID;
	E_MODULATE_FUNC modulate;

	float param0 = 0.0f;
	bool isTransparent = false;
}

// parses the content of Variable cull
bool getCullingFunction(const string cull)
{
	if ( cull.length == 0 )
		return true;

	bool ret = true;
	immutable(string[]) funclist = [ "none", "disable", "twosided" ];

	switch ( countUntil(funclist, cull) )
	{
		case 0:
		case 1:
		case 2:
			ret = false;
			break;
		default:
	}
	return ret;
}
unittest
{
	assert(getCullingFunction(""));
	assert(!getCullingFunction("none"));
	assert(!getCullingFunction("disable"));
	assert(!getCullingFunction("twosided"));
	assert(getCullingFunction("some other string"));
}

// parses the content of Variable depthfunc
// return a z-test
ubyte getDepthFunction ( string inputString )
{
	ubyte ret = cast(ubyte)E_COMPARISON_FUNC.ECFN_LESSEQUAL;

	if ( inputString.length == 0 )
		return ret;

	immutable(string[]) funclist = [ "lequal","equal" ];

	switch ( countUntil!"startsWith(b, a)"(funclist, inputString) )
	{
		case 0:
			ret = cast(ubyte)E_COMPARISON_FUNC.ECFN_LESSEQUAL;
			break;
		case 1:
			ret = cast(ubyte)E_COMPARISON_FUNC.ECFN_EQUAL;
			break;
		default:
	}
	return ret;
}
unittest
{
	assert(getDepthFunction("") == cast(ubyte)E_COMPARISON_FUNC.ECFN_LESSEQUAL);
	assert(getDepthFunction("some string") == cast(ubyte)E_COMPARISON_FUNC.ECFN_LESSEQUAL);
	assert(getDepthFunction("lequal") == cast(ubyte)E_COMPARISON_FUNC.ECFN_LESSEQUAL);
	assert(getDepthFunction("equal") == cast(ubyte)E_COMPARISON_FUNC.ECFN_EQUAL);
	assert(getDepthFunction("equal some string") == cast(ubyte)E_COMPARISON_FUNC.ECFN_EQUAL);
}

/**
*	parses the content of Variable blendfunc,alphafunc
*	it also make a hint for rendering as transparent or solid node.
*
*	we assume a typical quake scene would look like this..
*	1) Big Static Mesh ( solid )
*	2) static scene item ( may use transparency ) but rendered in the solid pass
*	3) additional transparency item in the transparent pass
*
*	it's not 100% accurate! it just empirical..
*/
static void getBlendFunc ( string inputString, out SBlendFunc blendfunc )
{
	if ( inputString.length == 0 )
		return;

	// maps to E_BLEND_FACTOR
	immutable(string[]) funclist =
	[
		"gl_zero",
		"gl_one",
		"gl_dst_color",
		"gl_one_minus_dst_color",
		"gl_src_color",
		"gl_one_minus_src_color",
		"gl_src_alpha",
		"gl_one_minus_src_alpha",
		"gl_dst_alpha",
		"gl_one_minus_dst_alpha",
		"gl_src_alpha_sat",

		"add",
		"filter",
		"blend",

		"ge128",
		"gt0",
	];

	int srcFact = countUntil!"startsWith(b, a)"(funclist, inputString);
	if ( srcFact < 0 )
		return;

	
	bool resolved = false;
	string factString = funclist[cast(size_t)srcFact];
	int dstFact = -1;

	if(inputString.length > factString.length)
	{
		inputString = find(inputString, factString)[factString.length+1 .. $];
		dstFact = countUntil!"startsWith(b, a)"(funclist, inputString);
	}

	switch ( srcFact )
	{
		case cast(int)E_BLEND_FACTOR.EBF_ZERO:
			switch ( dstFact )
			{
				// gl_zero gl_src_color == gl_dst_color gl_zero
				case E_BLEND_FACTOR.EBF_SRC_COLOR:
					blendfunc.type = E_MATERIAL_TYPE.EMT_ONETEXTURE_BLEND;
					blendfunc.param0 = pack_textureBlendFunc ( E_BLEND_FACTOR.EBF_DST_COLOR, E_BLEND_FACTOR.EBF_ZERO, blendfunc.modulate );
					blendfunc.isTransparent = true;
					resolved = true;
					break;
				default:
			} break;

		case cast(int)E_BLEND_FACTOR.EBF_ONE:
			switch ( dstFact )
			{
				// gl_one gl_zero
				case E_BLEND_FACTOR.EBF_ZERO:
					blendfunc.type = E_MATERIAL_TYPE.EMT_SOLID;
					blendfunc.isTransparent = false;
					resolved = true;
					break;

				// gl_one gl_one
				case E_BLEND_FACTOR.EBF_ONE:
					blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ADD_COLOR;
					blendfunc.isTransparent = true;
					resolved = true;
					break;
				default:
			} break;

		case cast(int)E_BLEND_FACTOR.EBF_SRC_ALPHA:
			switch ( dstFact )
			{
				// gl_src_alpha gl_one_minus_src_alpha
				case E_BLEND_FACTOR.EBF_ONE_MINUS_SRC_ALPHA:
					blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ALPHA_CHANNEL;
					blendfunc.param0 = 1.0f/255.0f;
					blendfunc.isTransparent = true;
					resolved = true;
					break;
				default:
			} break;

		case 11:
			// add
			blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ADD_COLOR;
			blendfunc.isTransparent = true;
			resolved = true;
			break;
		case 12:
			// filter = gl_dst_color gl_zero or gl_zero gl_src_color
			blendfunc.type = E_MATERIAL_TYPE.EMT_ONETEXTURE_BLEND;
			blendfunc.param0 = pack_textureBlendFunc ( E_BLEND_FACTOR.EBF_DST_COLOR, E_BLEND_FACTOR.EBF_ZERO, blendfunc.modulate );
			blendfunc.isTransparent = true;
			resolved = true;
			break;
		case 13:
			// blend = gl_src_alpha gl_one_minus_src_alpha
			blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ALPHA_CHANNEL;
			blendfunc.param0 = 1.0f/255.0f;
			blendfunc.isTransparent = true;
			resolved = true;
			break;
		case 14:
			// alphafunc ge128
			blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ALPHA_CHANNEL;
			blendfunc.param0 = 0.5f;
			blendfunc.isTransparent = true;
			resolved = true;
			break;
		case 15:
			// alphafunc gt0
			blendfunc.type = E_MATERIAL_TYPE.EMT_TRANSPARENT_ALPHA_CHANNEL;
			blendfunc.param0 = 1.0f / 255.0f;
			blendfunc.isTransparent = true;
			resolved = true;
			break;
		default:	
	}

	// use the generic blender
	if ( !resolved )
	{
		blendfunc.type = E_MATERIAL_TYPE.EMT_ONETEXTURE_BLEND;
		blendfunc.param0 = pack_textureBlendFunc (
				cast(E_BLEND_FACTOR) srcFact,
				cast(E_BLEND_FACTOR) dstFact,
				blendfunc.modulate);

		blendfunc.isTransparent = true;
	}
}

// random noise [-1;1]
struct Noiser
{
	static float get ()
	{
		static uint RandomSeed = 0x69666966;
		RandomSeed = (RandomSeed * 3631 + 1);

		float value = ( cast(float) (RandomSeed & 0x7FFF ) * (1.0f / cast(float)(0x7FFF >> 1) ) ) - 1.0f;
		return value;
	}
}

enum eQ3ModifierFunction : int
{
	TCMOD				= 0,
	DEFORMVERTEXES		= 1,
	RGBGEN				= 2,
	TCGEN				= 3,
	MAP					= 4,
	ALPHAGEN			= 5,

	FUNCTION2			= 0x10,
	SCROLL				= FUNCTION2 + 1,
	SCALE				= FUNCTION2 + 2,
	ROTATE				= FUNCTION2 + 3,
	STRETCH				= FUNCTION2 + 4,
	TURBULENCE			= FUNCTION2 + 5,
	WAVE				= FUNCTION2 + 6,

	IDENTITY			= FUNCTION2 + 7,
	VERTEX				= FUNCTION2 + 8,
	TEXTURE				= FUNCTION2 + 9,
	LIGHTMAP			= FUNCTION2 + 10,
	ENVIRONMENT			= FUNCTION2 + 11,
	DOLLAR_LIGHTMAP		= FUNCTION2 + 12,
	BULGE				= FUNCTION2 + 13,
	AUTOSPRITE			= FUNCTION2 + 14,
	AUTOSPRITE2			= FUNCTION2 + 15,
	TRANSFORM			= FUNCTION2 + 16,
	EXACTVERTEX			= FUNCTION2 + 17,
	CONSTANT			= FUNCTION2 + 18,
	LIGHTINGSPECULAR	= FUNCTION2 + 19,
	MOVE				= FUNCTION2 + 20,
	NORMAL				= FUNCTION2 + 21,
	IDENTITYLIGHTING	= FUNCTION2 + 22,

	WAVE_MODIFIER_FUNCTION	= 0x30,
	SINUS				= WAVE_MODIFIER_FUNCTION + 1,
	COSINUS				= WAVE_MODIFIER_FUNCTION + 2,
	SQUARE				= WAVE_MODIFIER_FUNCTION + 3,
	TRIANGLE			= WAVE_MODIFIER_FUNCTION + 4,
	SAWTOOTH			= WAVE_MODIFIER_FUNCTION + 5,
	SAWTOOTH_INVERSE	= WAVE_MODIFIER_FUNCTION + 6,
	NOISE				= WAVE_MODIFIER_FUNCTION + 7,


	UNKNOWN				= -2

}

struct SModifierFunction
{
	// "tcmod","deformvertexes","rgbgen", "tcgen"
	eQ3ModifierFunction masterfunc0 = eQ3ModifierFunction.UNKNOWN;
	// depends
	eQ3ModifierFunction masterfunc1 = eQ3ModifierFunction.UNKNOWN;
	// depends
	eQ3ModifierFunction func = eQ3ModifierFunction.SINUS;

	eQ3ModifierFunction tcgen = eQ3ModifierFunction.TEXTURE;
	eQ3ModifierFunction rgbgen = eQ3ModifierFunction.IDENTITY;
	eQ3ModifierFunction alphagen = eQ3ModifierFunction.UNKNOWN;

	union
	{
		float base = 0.0f;
		float bulgewidth;
	}

	union
	{
		float amp = 1.0f;
		float bulgeheight;
	}

	float phase = 0.0f;

	union
	{
		float frequency = 1.0f;
		float bulgespeed;
	}

	union
	{
		float wave = 1.0f;
		float div;
	}

	float x = 0.0f;
	float y = 0.0f;
	float z = 0.0f;
	uint count = 0;

	float evaluate ( float dt ) const
	{
		// phase in 0 and 1..
		real tmp;
		real x = modf( (dt + phase ) * frequency, tmp);
		float y = 0.0f;

		switch ( func )
		{
			case eQ3ModifierFunction.SINUS:
				y = cast(float)sin( x * PI * 2.0f );
				break;
			case eQ3ModifierFunction.COSINUS:
				y = cast(float)cos( x * PI * 2.0f );
				break;
			case eQ3ModifierFunction.SQUARE:
				y = x < 0.5f ? 1.0f : -1.0f;
				break;
			case eQ3ModifierFunction.TRIANGLE:
				y = x < 0.5f ? cast(float)( 4.0f * x ) - 1.0f : cast(float)( -4.0f * x ) + 3.0f;
				break;
			case eQ3ModifierFunction.SAWTOOTH:
				y = x;
				break;
			case eQ3ModifierFunction.SAWTOOTH_INVERSE:
				y = 1.0f - cast(float)x;
				break;
			case eQ3ModifierFunction.NOISE:
				y = Noiser.get();
				break;
			default:
				break;
		}

		return cast(float)(base + ( y * amp ));
	}
}

vector3df getMD3Normal ( uint i, uint j )
{
	immutable float lng = i * 2.0f * PI / 255.0f;
	immutable float lat = j * 2.0f * PI / 255.0f;
	return vector3df(cast(float)(cos ( lat ) * sin ( lng )),
			cast(float)(sin ( lat ) * sin ( lng )),
			cast(float)(cos ( lng )));
}

//
void getModifierFunc ( out SModifierFunction fill, ref string inputString)
{
	if ( inputString.length == 0 )
		return;

	immutable(string[]) funclist =
	[
		"sin","cos","square",
		"triangle", "sawtooth","inversesawtooth", "noise"
	];

	fill.masterfunc0 = cast(eQ3ModifierFunction)(countUntil!"startsWith(b, a)"(funclist, inputString));
	fill.masterfunc0 = (fill.masterfunc0 == eQ3ModifierFunction.UNKNOWN) ? eQ3ModifierFunction.SINUS : cast(eQ3ModifierFunction) (cast(uint) fill.masterfunc0 + eQ3ModifierFunction.WAVE_MODIFIER_FUNCTION + 1);

	inputString = munch(inputString, " \t\n\r");
	fill.base = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
	fill.amp = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
	fill.phase = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
	fill.frequency = parse!float(inputString);
	inputString = munch(inputString, " \t\n\r");
}


// name = "a b c .."
struct SVariable
{
	string name;
	string content;

	this( string n, string c = "" ) 
	{
		name = n;
		content = c;
	}

	void clear ()
	{
		name = "";
		content = "";
	}

	int isValid () const
	{
		return name.length;
	}

	bool opEqual()(auto ref const SVariable other ) const
	{
		return name == other.name;
	}

	bool opCmp()(auto ref const SVariable other ) const
	{
		if(name > other.name)
			return 1;
		else if(name < other.name)
			return -1;
		else
			return 0;
	}
}


// string database. "a" = "Hello", "b" = "1234.6"
struct SVarGroup
{
	size_t isDefined ( string name, string content = "" ) const
	{
		for ( size_t i = 0; i != Variable.length; ++i )
		{
			if ( Variable[i].name == name &&
				(  content == "" || canFind( Variable[i].content, content ) )
				)
			{
				return i;
			}
		}
		return -1;
	}

	// searches for Variable name and returns is content
	// if Variable is not found a reference to an Empty String is returned
	string get( string name ) const
	{
		auto search = SVariable( name );
		int index = countUntil(Variable, search);
		if ( index < 0 )
			return "";

		return Variable[ index ].content;
	}

	// set the Variable name
	void set ( string name, string content = "" )
	{
		size_t index = isDefined(name);
		if ( index == -1 )
		{
			Variable ~= ( SVariable ( name, content ) );
		}
		else
		{
			Variable[ index ].content = content;
		}
	}


	SVariable[] Variable = [];
}

/// holding a group a variable
struct SVarGroupList
{
	SVarGroup[] VariableGroup = [];
}


/// A Parsed Shader Holding Variables ordered in Groups
struct IQ3Shader
{
	void opAssign()(auto ref const IQ3Shader other)
	{
		ID = other.ID;
		VarGroup = other.VarGroup;
		name = other.name;
	}

	bool opEqual()(auto ref const IQ3Shader other ) const
	{
		return name == other.name;
	}

	bool opCmp()(auto ref const IQ3Shader other ) const
	{
		if(name > other.name)
			return 1;
		else if (name < other.name)
			return -1;
		else
			return 0;
	}

	size_t getGroupSize () const
	{
		return VarGroup.VariableGroup.length;
	}

	auto ref const SVarGroup getGroup()( size_t stage ) const
	{
		if ( stage >= VarGroup.VariableGroup.length )
			return 0;

		return VarGroup.VariableGroup [ stage ];
	}

	// id
	int ID = 0;
	SVarGroupList VarGroup; 

	// Shader: shader name ( also first variable in first Vargroup )
	// Entity: classname ( variable in Group(1) )
	string name;
}

alias IQ3Shader IQ3Entity;

/*
	dump shader like original layout, regardless of internal data holding
	no recursive folding..
*/
void dumpVarGroup()( out string dest, auto ref const SVarGroup group, int stack )
{
	string buf;
	int i;


	if ( stack > 0 )
	{
		buf = "";
		for ( i = 0; i < stack - 1; ++i )
			buf ~= '\t';

		buf ~= "{\n";
		dest ~= ( buf );
	}

	for ( size_t g = 0; g != group.Variable.length; ++g )
	{
		buf = "";
		for ( i = 0; i < stack; ++i )
			buf += '\t';

		buf ~= group.Variable[g].name;
		buf ~= " ";
		buf ~= group.Variable[g].content;
		buf ~= "\n";
		dest ~= buf;
	}

	if ( stack > 1 )
	{
		buf = "";
		for ( i = 0; i < stack - 1; ++i )
			buf += '\t';

		buf += "}\n";
		dest ~= ( buf );
	}

}

/*!
	dump a Shader or an Entity
*/
string dumpShader()(out string dest, auto ref const IQ3Shader shader, bool entity = false )
{
	SVarGroup group;

	immutable size_t size = shader.VarGroup.VariableGroup.length;
	for ( size_t i = 0; i != size; ++i )
	{
		group = shader.VarGroup.VariableGroup[ i ];
		dumpVarGroup ( dest, group, clamp( cast(int)i, 0, 2 ) );
	}

	if ( !entity )
	{
		if ( size <= 1 )
		{
			dest ~= "{\n";
		}
		dest ~= "}\n" ;
	}
	return dest;
}


/*
	quake3 doesn't care much about tga & jpg
	load one or multiple files stored in name started at startPos to the texture array textures
	if texture is not loaded 0 will be added ( to find missing textures easier)
*/
void getTextures(ref ITexture[] textures,
			ref string name,
			IFileSystem fileSystem,
			IVideoDriver driver)
{
	immutable(string[]) extension =
	[
		".jpg",
		".jpeg",
		".png",
		".dds",
		".tga",
		".bmp",
		".pcx"
	];

	string[] stringList = getAsStringList(size_t.max, name);
	textures[] = [];

	string loadFile;
	for ( size_t i = 0; i!= stringList.length; ++i )
	{
		ITexture texture;
		for (size_t g = 0; g != 7 ; ++g)
		{
			loadFile = stripExtension( stringList[i] );

			if ( loadFile == "$whiteimage" )
			{
				texture = driver.getTexture( "$whiteimage" );
				if ( texture is null )
				{
					auto s = dimension2du( 2, 2 );
					uint image[4] = [ 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ];
					IImage w = driver.createImageFromData ( ECOLOR_FORMAT.ECF_A8R8G8B8, s, image.ptr );
					texture = driver.addTexture( "$whiteimage", w );
				}
			}
			else
			if ( loadFile == "$redimage" )
			{
				texture = driver.getTexture( "$redimage" );
				if ( texture is null )
				{
					auto s = dimension2du( 2, 2 );
					uint image[4] = [ 0xFFFF0000, 0xFFFF0000,0xFFFF0000,0xFFFF0000 ];
					IImage w = driver.createImageFromData ( ECOLOR_FORMAT.ECF_A8R8G8B8, s, image.ptr );
					texture = driver.addTexture( "$redimage", w );
				}
			}
			else
			if ( loadFile == "$blueimage" )
			{
				texture = driver.getTexture( "$blueimage" );
				if ( texture is null )
				{
					auto s = dimension2du( 2, 2 );
					uint image[4] = [ 0xFF0000FF, 0xFF0000FF,0xFF0000FF,0xFF0000FF ];
					IImage w = driver.createImageFromData ( ECOLOR_FORMAT.ECF_A8R8G8B8, s, image.ptr );
					texture = driver.addTexture( "$blueimage", w );
				}
			}
			else
			if ( loadFile == "$checkerimage" )
			{
				texture = driver.getTexture( "$checkerimage" );
				if ( texture is null )
				{
					auto s = dimension2du( 2, 2 );
					uint image[4] = [ 0xFFFFFFFF, 0xFF000000,0xFF000000,0xFFFFFFFF ];
					IImage w = driver.createImageFromData ( ECOLOR_FORMAT.ECF_A8R8G8B8, s, image.ptr );
					texture = driver.addTexture( "$checkerimage", w );
				}
			}
			else
			if ( loadFile == "$lightmap" )
			{
				texture = null;
			}
			else
			{
				loadFile ~= ( extension[g] );
			}

			if ( fileSystem.existFile( loadFile ) )
			{
				texture = driver.getTexture( loadFile );
				if ( texture !is null )
					break;
			}
		}
		// take 0 Texture
		textures ~= texture;
	}
}


/// Manages various Quake3 Shader Styles
class IShaderManager
{
}
