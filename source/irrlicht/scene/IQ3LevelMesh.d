// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.IQ3LevelMesh;

import irrlicht.scene.IMesh;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.quake3.IQ3Shader;

/// Interface for a Mesh which can be loaded directly from a Quake3 .bsp-file.
/**
* The Mesh tries to load all textures of the map.
*/
interface IQ3LevelMesh :IAnimatedMesh
{
	/// loads the shader definition from file
	/**
	* Params:
	* 	filename=  Name of the shaderfile, defaults to /scripts if fileNameIsValid is false.
	* 	fileNameIsValid=  Specifies whether the filename is valid in the current situation. 
	*/
	IQ3Shader getShader( string filename, bool fileNameIsValid=true );

	/// returns a already loaded Shader
	IQ3Shader getShader(size_t index) const;

	/// get's an interface to the entities
	IQ3Entity[] getEntityList();

	/// returns the requested brush entity
	/**
	* Params:
	* 	num=  The number from the model key of the entity.
	* Use this interface if you parse the entities yourself.
	*/
	IMesh getBrushEntityMesh(int num) const;

	/// returns the requested brush entity
	IMesh getBrushEntityMesh(IQ3Entity ent) const;
}
