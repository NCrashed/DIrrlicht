// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IGPUProgrammingServices;

import irrlicht.video.EShaderTypes;
import irrlicht.video.EMaterialTypes;
import irrlicht.scene.EPrimitiveTypes;
import irrlicht.video.IVideoDriver;
import irrlicht.video.IShaderConstantSetCallBack;
import irrlicht.io.IReadFile;
import irrlicht.io.path;

/// Enumeration for different types of shading languages
enum E_GPU_SHADING_LANGUAGE
{
	/// The default language, so HLSL for Direct3D and GLSL for OpenGL.
	EGSL_DEFAULT = 0,

	/// Cg shading language.*/
	EGSL_CG
}

/// Interface making it possible to create and use programs running on the GPU.
interface IGPUProgrammingServices
{
	/// Adds a new high-level shading material renderer to the VideoDriver.
	/**
	* Currently only HLSL/D3D9 and GLSL/OpenGL are supported.
	* Params:
	* 	vertexShaderProgram=  String containing the source of the vertex
	* shader program. This can be 0 if no vertex program shall be used.
	* 	vertexShaderEntryPointName=  Name of the entry function of the
	* vertexShaderProgram (p.e. "main")
	* 	vsCompileTarget=  Vertex shader version the high level shader
	* shall be compiled to.
	* 	pixelShaderProgram=  String containing the source of the pixel
	* shader program. This can be 0 if no pixel shader shall be used.
	* 	pixelShaderEntryPointName=  Entry name of the function of the
	* pixelShaderProgram (p.e. "main")
	* 	psCompileTarget=  Pixel shader version the high level shader
	* shall be compiled to.
	* 	geometryShaderProgram=  String containing the source of the
	* geometry shader program. This can be 0 if no geometry shader shall be
	* used.
	* 	geometryShaderEntryPointName=  Entry name of the function of the
	* geometryShaderProgram (p.e. "main")
	* 	gsCompileTarget=  Geometry shader version the high level shader
	* shall be compiled to.
	* 	inType=  Type of vertices passed to geometry shader
	* 	outType=  Type of vertices created by geometry shader
	* 	verticesOut=  Maximal number of vertices created by geometry
	* shader. If 0, maximal number supported is assumed.
	* 	callback=  Pointer to an implementation of
	* IShaderConstantSetCallBack in which you can set the needed vertex,
	* pixel, and geometry shader program constants. Set this to 0 if you
	* don't need this.
	* 	baseMaterial=  Base material which renderstates will be used to
	* shade the material.
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* 	shaderLang=  a type of shading language used in current shader.
	* Returns: Number of the material type which can be set in
	* SMaterial::MaterialType to use the renderer. -1 is returned if an error
	* occured, e.g. if a shader program could not be compiled or a compile
	* target is not reachable. The error strings are then printed to the
	* error log and can be catched with a custom event receiver. 
	*/
	int addHighLevelShaderMaterial(
		string vertexShaderProgram,
		string vertexShaderEntryPointName,
		E_VERTEX_SHADER_TYPE vsCompileTarget,
		string pixelShaderProgram,
		string pixelShaderEntryPointName,
		E_PIXEL_SHADER_TYPE psCompileTarget,
		string geometryShaderProgram,
		string geometryShaderEntryPointName = "main",
		E_GEOMETRY_SHADER_TYPE gsCompileTarget = E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
		E_PRIMITIVE_TYPE inType = E_PRIMITIVE_TYPE.EPT_TRIANGLES,
		E_PRIMITIVE_TYPE outType = E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP,
		uint verticesOut = 0,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT);

	/// convenience function for use without geometry shaders
	final int addHighLevelShaderMaterial(
		string vertexShaderProgram,
		string vertexShaderEntryPointName = "main",
		E_VERTEX_SHADER_TYPE vsCompileTarget = E_VERTEX_SHADER_TYPE.EVST_VS_1_1,
		string pixelShaderProgram = "",
		string pixelShaderEntryPointName = "main",
		E_PIXEL_SHADER_TYPE psCompileTarget = E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT)
	{
		return addHighLevelShaderMaterial(
			vertexShaderProgram, vertexShaderEntryPointName,
			vsCompileTarget, pixelShaderProgram,
			pixelShaderEntryPointName, psCompileTarget,
			"", "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP, 0,
			callback, baseMaterial, userData, shadingLang);
	}

	/// convenience function for use with many defaults, without geometry shader
	/**
	* All shader names are set to "main" and compile targets are shader
	* type 1.1.
	*/
	final int addHighLevelShaderMaterial(
		string vertexShaderProgram,
		string pixelShaderProgram = "",
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0)
	{
		return addHighLevelShaderMaterial(
			vertexShaderProgram, "main",
			E_VERTEX_SHADER_TYPE.EVST_VS_1_1, pixelShaderProgram,
			"main", E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
			"", "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP, 0,
			callback, baseMaterial, userData);
	}

	/// convenience function for use with many defaults, with geometry shader
	/**
	* All shader names are set to "main" and compile targets are shader
	* type 1.1 and geometry shader 4.0.
	*/
	final int addHighLevelShaderMaterial(
		string vertexShaderProgram,
		string pixelShaderProgram = "",
		string geometryShaderProgram = "",
		E_PRIMITIVE_TYPE inType = E_PRIMITIVE_TYPE.EPT_TRIANGLES,
		E_PRIMITIVE_TYPE outType = E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP,
		uint verticesOut = 0,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0 )
	{
		return addHighLevelShaderMaterial(
			vertexShaderProgram, "main",
			E_VERTEX_SHADER_TYPE.EVST_VS_1_1, pixelShaderProgram,
			"main", E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
			geometryShaderProgram, "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			inType, outType, verticesOut,
			callback, baseMaterial, userData);
	}

	/// Like IGPUProgrammingServices.addShaderMaterial(), but loads from files.
	/**
	* Params:
	* 	vertexShaderProgramFileName=  Text file containing the source
	* of the vertex shader program. Set to empty string if no vertex shader
	* shall be created.
	* 	vertexShaderEntryPointName=  Name of the entry function of the
	* vertexShaderProgram  (p.e. "main")
	* 	vsCompileTarget=  Vertex shader version the high level shader
	* shall be compiled to.
	* 	pixelShaderProgramFileName=  Text file containing the source of
	* the pixel shader program. Set to empty string if no pixel shader shall
	* be created.
	* 	pixelShaderEntryPointName=  Entry name of the function of the
	* pixelShaderProgram (p.e. "main")
	* 	psCompileTarget=  Pixel shader version the high level shader
	* shall be compiled to.
	* 	geometryShaderProgramFileName=  Name of the source of
	* the geometry shader program. Set to empty string if no geometry shader
	* shall be created.
	* 	geometryShaderEntryPointName=  Entry name of the function of the
	* geometryShaderProgram (p.e. "main")
	* 	gsCompileTarget=  Geometry shader version the high level shader
	* shall be compiled to.
	* 	inType=  Type of vertices passed to geometry shader
	* 	outType=  Type of vertices created by geometry shader
	* 	verticesOut=  Maximal number of vertices created by geometry
	* shader. If 0, maximal number supported is assumed.
	* 	callback=  Pointer to an implementation of
	* IShaderConstantSetCallBack in which you can set the needed vertex,
	* pixel, and geometry shader program constants. Set this to 0 if you
	* don't need this.
	* 	baseMaterial=  Base material which renderstates will be used to
	* shade the material.
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* 	shaderLang=  a type of shading language used in current shader.
	* Returns: Number of the material type which can be set in
	* SMaterial::MaterialType to use the renderer. -1 is returned if an error
	* occured, e.g. if a shader program could not be compiled or a compile
	* target is not reachable. The error strings are then printed to the
	* error log and can be catched with a custom event receiver. 
	*/
	int addHighLevelShaderMaterialFromFiles(
		const Path vertexShaderProgramFileName,
		string vertexShaderEntryPointName,
		E_VERTEX_SHADER_TYPE vsCompileTarget,
		const Path pixelShaderProgramFileName,
		string pixelShaderEntryPointName,
		E_PIXEL_SHADER_TYPE psCompileTarget,
		const Path geometryShaderProgramFileName,
		string geometryShaderEntryPointName = "main",
		E_GEOMETRY_SHADER_TYPE gsCompileTarget = E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
		E_PRIMITIVE_TYPE inType = E_PRIMITIVE_TYPE.EPT_TRIANGLES,
		E_PRIMITIVE_TYPE outType = E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP,
		uint verticesOut = 0,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT);

	/// convenience function for use without geometry shaders
	final int addHighLevelShaderMaterialFromFiles(
		const Path vertexShaderProgramFileName,
		string vertexShaderEntryPointName = "main",
		E_VERTEX_SHADER_TYPE vsCompileTarget = E_VERTEX_SHADER_TYPE.EVST_VS_1_1,
		const Path pixelShaderProgramFileName = "",
		string pixelShaderEntryPointName = "main",
		E_PIXEL_SHADER_TYPE psCompileTarget = E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT)
	{
		return addHighLevelShaderMaterialFromFiles(
			vertexShaderProgramFileName, vertexShaderEntryPointName,
			vsCompileTarget, pixelShaderProgramFileName,
			pixelShaderEntryPointName, psCompileTarget,
			"", "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP, 0,
			callback, baseMaterial, userData, shadingLang);
	}

	/// convenience function for use with many defaults, without geometry shader
	/**
	* All shader names are set to "main" and compile targets are shader
	* type 1.1.
	*/
	final int addHighLevelShaderMaterialFromFiles(
		const Path vertexShaderProgramFileName,
		const Path pixelShaderProgramFileName = "",
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0 )
	{
		return addHighLevelShaderMaterialFromFiles(
			vertexShaderProgramFileName, "main",
			E_VERTEX_SHADER_TYPE.EVST_VS_1_1, pixelShaderProgramFileName,
			"main", E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
			"", "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP, 0,
			callback, baseMaterial, userData);
	}

	/// convenience function for use with many defaults, with geometry shader
	/**
	* All shader names are set to "main" and compile targets are shader
	* type 1.1 and geometry shader 4.0.
	*/
	final int addHighLevelShaderMaterialFromFiles(
		const Path vertexShaderProgramFileName,
		const Path pixelShaderProgramFileName = "",
		const Path geometryShaderProgramFileName = "",
		E_PRIMITIVE_TYPE inType = E_PRIMITIVE_TYPE.EPT_TRIANGLES,
		E_PRIMITIVE_TYPE outType = E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP,
		uint verticesOut = 0,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0 )
	{
		return addHighLevelShaderMaterialFromFiles(
			vertexShaderProgramFileName, "main",
			E_VERTEX_SHADER_TYPE.EVST_VS_1_1, pixelShaderProgramFileName,
			"main", E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
			geometryShaderProgramFileName, "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			inType, outType, verticesOut,
			callback, baseMaterial, userData);
	}

	/// Like IGPUProgrammingServices.addShaderMaterial(), but loads from files.
	/**
	* Params:
	* 	vertexShaderProgram=  Text file handle containing the source
	* of the vertex shader program. Set to 0 if no vertex shader shall be
	* created.
	* 	vertexShaderEntryPointName=  Name of the entry function of the
	* vertexShaderProgram
	* 	vsCompileTarget=  Vertex shader version the high level shader
	* shall be compiled to.
	* 	pixelShaderProgram=  Text file handle containing the source of
	* the pixel shader program. Set to 0 if no pixel shader shall be created.
	* 	pixelShaderEntryPointName=  Entry name of the function of the
	* pixelShaderProgram (p.e. "main")
	* 	psCompileTarget=  Pixel shader version the high level shader
	* shall be compiled to.
	* 	geometryShaderProgram=  Text file handle containing the source of
	* the geometry shader program. Set to 0 if no geometry shader shall be
	* created.
	* 	geometryShaderEntryPointName=  Entry name of the function of the
	* geometryShaderProgram (p.e. "main")
	* 	gsCompileTarget=  Geometry shader version the high level shader
	* shall be compiled to.
	* 	inType=  Type of vertices passed to geometry shader
	* 	outType=  Type of vertices created by geometry shader
	* 	verticesOut=  Maximal number of vertices created by geometry
	* shader. If 0, maximal number supported is assumed.
	* 	callback=  Pointer to an implementation of
	* IShaderConstantSetCallBack in which you can set the needed vertex and
	* pixel shader program constants. Set this to 0 if you don't need this.
	* 	baseMaterial=  Base material which renderstates will be used to
	* shade the material.
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* 	shaderLang=  a type of shading language used in current shader.
	* Returns: Number of the material type which can be set in
	* SMaterial::MaterialType to use the renderer. -1 is returned if an
	* error occured, e.g. if a shader program could not be compiled or a
	* compile target is not reachable. The error strings are then printed to
	* the error log and can be catched with a custom event receiver. 
	*/
	int addHighLevelShaderMaterialFromFiles(
		IReadFile vertexShaderProgram,
		string vertexShaderEntryPointName,
		E_VERTEX_SHADER_TYPE vsCompileTarget,
		IReadFile pixelShaderProgram,
		string pixelShaderEntryPointName,
		E_PIXEL_SHADER_TYPE psCompileTarget,
		IReadFile geometryShaderProgram,
		string geometryShaderEntryPointName = "main",
		E_GEOMETRY_SHADER_TYPE gsCompileTarget = E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
		E_PRIMITIVE_TYPE inType = E_PRIMITIVE_TYPE.EPT_TRIANGLES,
		E_PRIMITIVE_TYPE outType = E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP,
		uint verticesOut = 0,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT);

	/// convenience function for use without geometry shaders
	final int addHighLevelShaderMaterialFromFiles(
		IReadFile vertexShaderProgram,
		string vertexShaderEntryPointName = "main",
		E_VERTEX_SHADER_TYPE vsCompileTarget = E_VERTEX_SHADER_TYPE.EVST_VS_1_1,
		IReadFile pixelShaderProgram = null,
		string pixelShaderEntryPointName = "main",
		E_PIXEL_SHADER_TYPE psCompileTarget = E_PIXEL_SHADER_TYPE.EPST_PS_1_1,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0,
		E_GPU_SHADING_LANGUAGE shadingLang = E_GPU_SHADING_LANGUAGE.EGSL_DEFAULT)
	{
		return addHighLevelShaderMaterialFromFiles(
			vertexShaderProgram, vertexShaderEntryPointName,
			vsCompileTarget, pixelShaderProgram,
			pixelShaderEntryPointName, psCompileTarget,
			null, "main", E_GEOMETRY_SHADER_TYPE.EGST_GS_4_0,
			E_PRIMITIVE_TYPE.EPT_TRIANGLES, E_PRIMITIVE_TYPE.EPT_TRIANGLE_STRIP, 0,
			callback, baseMaterial, userData, shadingLang);
	}

	/// Adds a new ASM shader material renderer to the VideoDriver
	/**
	* Note that it is a good idea to call IVideoDriver.queryFeature() in
	* advance to check if the IVideoDriver supports the vertex and/or pixel
	* shader version your are using.
	* The material is added to the VideoDriver like with
	* IVideoDriver.addMaterialRenderer() and can be used like it had been
	* added with that method.
	* Params:
	* 	vertexShaderProgram=  String containing the source of the vertex
	* shader program. This can be 0 if no vertex program shall be used.
	* For DX8 programs, the will always input registers look like this: v0:
	* position, v1: normal, v2: color, v3: texture cooridnates, v4: texture
	* coordinates 2 if available.
	* For DX9 programs, you can manually set the registers using the dcl_
	* statements.
	* 	pixelShaderProgram=  String containing the source of the pixel
	* shader program. This can be 0 if you don't want to use a pixel shader.
	* 	callback=  Pointer to an implementation of
	* IShaderConstantSetCallBack in which you can set the needed vertex and
	* pixel shader program constants. Set this to 0 if you don't need this.
	* 	baseMaterial=  Base material which renderstates will be used to
	* shade the material.
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* Returns: Returns the number of the material type which can be set in
	* SMaterial.MaterialType to use the renderer. -1 is returned if an
	* error occured. -1 is returned for example if a vertex or pixel shader
	* program could not be compiled, the error strings are then printed out
	* into the error log, and can be catched with a custom event receiver. 
	*/
	int addShaderMaterial(string vertexShaderProgram = "",
		string pixelShaderProgram = "",
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0);

	/// Like IGPUProgrammingServices.addShaderMaterial(), but loads from files.
	/**
	* Params:
	* 	vertexShaderProgram=  Text file containing the source of the
	* vertex shader program. Set to 0 if no shader shall be created.
	* 	pixelShaderProgram=  Text file containing the source of the pixel
	* shader program. Set to 0 if no shader shall be created.
	* 	callback=  Pointer to an IShaderConstantSetCallback object to
	* which the OnSetConstants function is called.
	* 	baseMaterial=  baseMaterial
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* Returns: Returns the number of the material type which can be set in
	* SMaterial.MaterialType to use the renderer. -1 is returned if an
	* error occured. -1 is returned for example if a vertex or pixel shader
	* program could not be compiled, the error strings are then printed out
	* into the error log, and can be catched with a custom event receiver. 
	*/
	int addShaderMaterialFromFiles(IReadFile vertexShaderProgram,
		IReadFile pixelShaderProgram,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0);

	/// Like IGPUProgrammingServices.addShaderMaterial(), but loads from files.
	/**
	* Params:
	* 	vertexShaderProgramFileName=  Text file name containing the
	* source of the vertex shader program. Set to 0 if no shader shall be
	* created.
	* 	pixelShaderProgramFileName=  Text file name containing the source
	* of the pixel shader program. Set to 0 if no shader shall be created.
	* 	callback=  Pointer to an IShaderConstantSetCallback object on
	* which the OnSetConstants function is called.
	* 	baseMaterial=  baseMaterial
	* 	userData=  a user data int. This int can be set to any value and
	* will be set as parameter in the callback method when calling
	* OnSetConstants(). In this way it is easily possible to use the same
	* callback method for multiple materials and distinguish between them
	* during the call.
	* Returns: Returns the number of the material type which can be set in
	* SMaterial.MaterialType to use the renderer. -1 is returned if an
	* error occured. -1 is returned for example if a vertex or pixel shader
	* program could not be compiled, the error strings are then printed out
	* into the error log, and can be catched with a custom event receiver. 
	*/
	int addShaderMaterialFromFiles(const Path vertexShaderProgramFileName,
		const Path pixelShaderProgramFileName,
		IShaderConstantSetCallBack callback = null,
		E_MATERIAL_TYPE baseMaterial = E_MATERIAL_TYPE.EMT_SOLID,
		int userData = 0);
}
