// Copyright (C) 2007-2012 Nikolaus Gebhardt / Thomas Alten
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.scene.IAnimatedMeshMD3;

import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.quake3.IQ3Shader;
import irrlicht.core.vector3d;
import irrlicht.core.quaternion;
import irrlicht.core.matrix4;
import irrlicht.irrMath;

enum eMD3Models
{
	EMD3_HEAD = 0,
	EMD3_UPPER,
	EMD3_LOWER,
	EMD3_WEAPON,
	EMD3_NUMMODELS
}

/// Animation list
enum EMD3_ANIMATION_TYPE
{
	// Animations for both lower and upper parts of the player
	EMD3_BOTH_DEATH_1 = 0,
	EMD3_BOTH_DEAD_1,
	EMD3_BOTH_DEATH_2,
	EMD3_BOTH_DEAD_2,
	EMD3_BOTH_DEATH_3,
	EMD3_BOTH_DEAD_3,

	// Animations for the upper part
	EMD3_TORSO_GESTURE,
	EMD3_TORSO_ATTACK_1,
	EMD3_TORSO_ATTACK_2,
	EMD3_TORSO_DROP,
	EMD3_TORSO_RAISE,
	EMD3_TORSO_STAND_1,
	EMD3_TORSO_STAND_2,

	// Animations for the lower part
	EMD3_LEGS_WALK_CROUCH,
	EMD3_LEGS_WALK,
	EMD3_LEGS_RUN,
	EMD3_LEGS_BACK,
	EMD3_LEGS_SWIM,
	EMD3_LEGS_JUMP_1,
	EMD3_LEGS_LAND_1,
	EMD3_LEGS_JUMP_2,
	EMD3_LEGS_LAND_2,
	EMD3_LEGS_IDLE,
	EMD3_LEGS_IDLE_CROUCH,
	EMD3_LEGS_TURN,

	/// Not an animation, but amount of animation types.
	EMD3_ANIMATION_COUNT
}

struct SMD3AnimationInfo
{
	/// First frame
	int first;
	/// Last frame
	int num;
	/// Looping frames
	int looping;
	/// Frames per second
	int fps;
}


// byte-align structures

/// this holds the header info of the MD3 file
align(1) struct SMD3Header
{
	char headerID[4];	//id of file, always "IDP3"
	int	Version;	//this is a version number, always 15
	char fileName[68];	//sometimes left Blank... 65 chars, 32bit aligned == 68 chars
	int	numFrames;	//number of KeyFrames
	int	numTags;	//number of 'tags' per frame
	int	numMeshes;	//number of meshes/skins
	int	numMaxSkins;	//maximum number of unique skins used in md3 file. artefact md2
	int	frameStart;	//starting position of frame-structur
	int	tagStart;	//starting position of tag-structures
	int	tagEnd;		//ending position of tag-structures/starting position of mesh-structures
	int	fileSize;
}

/// this holds the header info of an MD3 mesh section
align(1) struct SMD3MeshHeader
{
	char meshID[4];		//id, must be IDP3
	char meshName[68];	//name of mesh 65 chars, 32 bit aligned == 68 chars

	int numFrames;		//number of meshframes in mesh
	int numShader;		//number of skins in mesh
	int numVertices;	//number of vertices
	int numTriangles;	//number of Triangles

	int offset_triangles;	//starting position of Triangle data, relative to start of Mesh_Header
	int offset_shaders;	//size of header
	int offset_st;		//starting position of texvector data, relative to start of Mesh_Header
	int vertexStart;	//starting position of vertex data,relative to start of Mesh_Header
	int offset_end;
}


/// Compressed Vertex Data
align(1) struct SMD3Vertex
{
	short position[3];
	ubyte normal[2];
}

/// Texture Coordinate
align(1) struct SMD3TexCoord
{
	float u;
	float v;
}

/// Triangle Index
align(1) struct SMD3Face
{
	int Index[3];
}


// Default alignment


/// Holding Frame Data for a Mesh
struct SMD3MeshBuffer
{
	SMD3MeshHeader MeshHeader;

	string Shader;
	int[] Indices = [];
	SMD3Vertex[] Vertices = [];
	SMD3TexCoord[] Tex = [];
}

/// hold a tag info for connecting meshes
/**
* Basically its an alternate way to describe a transformation. 
*/
struct SMD3QuaternionTag
{
	// construct for searching
	this()(string name )
	{
		Name = name;
	}

	// construct from a position and euler angles in degrees
	this()(auto ref const vector3df pos, auto ref const vector3df angle )
	{
		position = pos;
		rotation = angle * DEGTORAD;
	}

	// set to matrix
	void setto()(auto ref matrix4 m)
	{
		rotation.getMatrix ( m, position );
	}

	bool opEqual()(auto ref const SMD3QuaternionTag other ) const
	{
		return Name == other.Name;
	}

	auto ref SMD3QuaternionTag opAssign()(auto ref const SMD3QuaternionTag copyMe )
	{
		Name = copyMe.Name;
		position = copyMe.position;
		rotation = copyMe.rotation;
		return this;
	}

	string Name;
	vector3df position;
	quaternion rotation;
}

/// holds a associative list of named quaternions
struct SMD3QuaternionTagList
{
	auto ref SMD3QuaternionTag get()(const string name)
	{
		auto search = SMD3QuaternionTag( name );
		int index = countUntil(Container, search);
		if ( index >= 0 )
			return Container[index];
		throw new Exception("Not found"); // Find better solution
	}

	size_t size () const
	{
		return Container.length;
	}

	void set_used(size_t new_size)
	{
		int diff = cast(int) new_size - cast(int) Container.length;
		if ( diff > 0 )
		{
			auto e = SMD3QuaternionTag("");
			for ( int i = 0; i < diff; ++i )
				Container ~= e;
		}
	}

	auto ref const SMD3QuaternionTag opIndex()(size_t index) const
	{
		return Container[index];
	}

	auto ref SMD3QuaternionTag opIndex()(size_t index)
	{
		return Container[index];
	}

	void opOpAssign(string op)(auto ref const SMD3QuaternionTag other)
		if(op == "~")
	{
		Container ~= (other);
	}

	auto ref SMD3QuaternionTagList opAssign()(auto ref const SMD3QuaternionTagList copyMe)
	{
		Container = copyMe.Container;
		return this;
	}

	private SMD3QuaternionTag[] Container = [];
}


/// Holding Frames Buffers and Tag Infos
struct SMD3Mesh
{
	string Name;
	SMD3MeshBuffer[] Buffer;
	SMD3QuaternionTagList TagList;
	SMD3Header MD3Header;
}


/// Interface for using some special functions of MD3 meshes
interface IAnimatedMeshMD3 : IAnimatedMesh
{
	/// tune how many frames you want to render inbetween.
	void setInterpolationShift(uint shift, uint loopMode);

	/// get the tag list of the mesh.
	ref SMD3QuaternionTagList getTagList(int frame, int detailLevel, int startFrameLoop, int endFrameLoop);

	/// get the original md3 mesh.
	ref SMD3Mesh getOriginalMesh();
}
