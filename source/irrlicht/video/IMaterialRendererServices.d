// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IMaterialRendererServices;

import irrlicht.video.SMaterial;
import irrlicht.video.S3DVertex;
import irrlicht.video.IVideoDriver;

/// Interface providing some methods for changing advanced, internal states of a IVideoDriver.
interface IMaterialRendererServices
{
	/// Can be called by an IMaterialRenderer to make its work easier.
	/**
	* Sets all basic renderstates if needed.
	* Basic render states are diffuse, ambient, specular, and emissive color,
	* specular power, bilinear and trilinear filtering, wireframe mode,
	* grouraudshading, lighting, zbuffer, zwriteenable, backfaceculling and
	* fog enabling.
	* Params:
	* 	material=  The new material to be used.
	* 	lastMaterial=  The material used until now.
	* 	resetAllRenderstates=  Set to true if all renderstates should be
	* set, regardless of their current state. 
	*/
	void setBasicRenderStates(const SMaterial material,
		const SMaterial lastMaterial,
		bool resetAllRenderstates);

	/// Sets a constant for the vertex shader based on a name.
	/**
	* This can be used if you used a high level shader language like GLSL
	* or HLSL to create a shader. Example: If you created a shader which has
	* variables named 'mWorldViewProj' (containing the WorldViewProjection
	* matrix) and another one named 'fTime' containing one float, you can set
	* them in your IShaderConstantSetCallBack derived class like this:
	* Examples:
	* ------
	* void OnSetConstants(IMaterialRendererServices services, int userData)
	* {
	*	 IVideoDriver driver = services.getVideoDriver();
	*	 float time = cast(float)getTime()/100000.0f;
	*	 services.setVertexShaderConstant("fTime", time, 1);
	*	 matrix4 worldViewProj(driver.getTransform(E_TRANSFORMATION_STATE.ETS_PROJECTION));
	*	 worldViewProj *= driver.getTransform(E_TRANSFORMATION_STATE.ETS_VIEW);
	*	 worldViewProj *= driver.getTransform(E_TRANSFORMATION_STATE.ETS_WORLD);
	*	 services.setVertexShaderConstant("mWorldViewProj", worldViewProj.M, 16);
	* }
	* ------
	* Params:
	* 	name=  Name of the variable
	* 	floats=  Pointer to array of floats
	* 	count=  Amount of floats in array.
	* Returns: True if successful.
	*/
	bool setVertexShaderConstant(string name, const float[] floats);

	/// Bool interface for the above.
	bool setVertexShaderConstant(string name, const bool[] bools);

	/// Int interface for the above.
	bool setVertexShaderConstant(string name, const int[] ints);

	/// Sets a vertex shader constant.
	/**
	* Can be used if you created a shader using pixel/vertex shader
	* assembler or ARB_fragment_program or ARB_vertex_program.
	* Params:
	* 	data=  Data to be set in the constants
	* 	startRegister=  First register to be set
	* 	constantAmount=  Amount of registers to be set. One register consists of 4 floats. 
	*/
	void setVertexShaderConstant(const float[] data, uint startRegister, uint constantAmount=1);

	/// Sets a constant for the pixel shader based on a name.
	/**
	* This can be used if you used a high level shader language like GLSL
	* or HLSL to create a shader. See setVertexShaderConstant() for an
	* example on how to use this.
	* Params:
	* 	name=  Name of the variable
	* 	floats=  Pointer to array of floats
	* 	count=  Amount of floats in array.
	* Returns: True if successful. 
	*/
	bool setPixelShaderConstant(string name, const float[] floats);

	/// Bool interface for the above.
	bool setPixelShaderConstant(string name, const bool[] bools);

	/// Int interface for the above.
	bool setPixelShaderConstant(string name, const int[] ints);

	/// Sets a pixel shader constant.
	/**
	* Can be used if you created a shader using pixel/vertex shader
	* assembler or ARB_fragment_program or ARB_vertex_program.
	* Params:
	* 	data=  Data to be set in the constants
	* 	startRegister=  First register to be set.
	* 	constantAmount=  Amount of registers to be set. One register consists of 4 floats. 
	*/
	void setPixelShaderConstant(const float[] data, uint startRegister, uint constantAmount=1);

	/// Get pointer to the IVideoDriver interface
	/**
	* Returns: Pointer to the IVideoDriver interface 
	*/
	IVideoDriver getVideoDriver();
}
