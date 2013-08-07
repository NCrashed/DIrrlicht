// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.video.IShaderConstantSetCallBack;

import irrlicht.video.IMaterialRendererServices;
import irrlicht.video.SMaterial;

/// Interface making it possible to set constants for gpu programs every frame.
/**
* Implement this interface in an own class and pass a pointer to it to one of
* the methods in IGPUProgrammingServices when creating a shader. The
* OnSetConstants method will be called every frame now. 
*/
interface IShaderConstantSetCallBack
{
	/// Called to let the callBack know the used material (optional method)
	/**
	* Examples:
	* ------
	* class MyCallBack : IShaderConstantSetCallBack
	* {
	*	 const SMaterial UsedMaterial;
	*
	*	 OnSetMaterial(const SMaterial material)
	*	 {
	*		 UsedMaterial = material;
	*	 }
	*
	*	 OnSetConstants(IMaterialRendererServices services, int userData)
	*	 {
	*		 services.setVertexShaderConstant("myColor", cast(float*)(&UsedMaterial.color), 4);
	*	 }
	* }
	* ------
	*/
	void OnSetMaterial(const SMaterial material);

	/// Called by the engine when the vertex and/or pixel shader constants for an material renderer should be set.
	/**
	* Implement the IShaderConstantSetCallBack in an own class and implement your own
	* OnSetConstants method using the given IMaterialRendererServices interface.
	* Pass a pointer to this class to one of the methods in IGPUProgrammingServices
	* when creating a shader. The OnSetConstants method will now be called every time
	* before geometry is being drawn using your shader material. A sample implementation
	* would look like this:
	* Examples:
	* ------
	* void OnSetConstants(IMaterialRendererServices services, int userData)
	* {
	*	 IVideoDriver driver = services.getVideoDriver();
	*	 // set clip matrix at register 4
	*	 matrix4 worldViewProj(driver.getTransform(E_TRANSFORMATION_STATE.ETS_PROJECTION));
	*	 worldViewProj *= driver.getTransform(E_TRANSFORMATION_STATE.ETS_VIEW);
	*	 worldViewProj *= driver.getTransform(E_TRANSFORMATION_STATE.ETS_WORLD);
	*	 services.setVertexShaderConstant(&worldViewProj.M[0], 4, 4);
	*	 // for high level shading languages, this would be another solution:
	*	 //services.setVertexShaderConstant("mWorldViewProj", worldViewProj.M, 16);
	*	 // set some light color at register 9
	*	 SColorf col(0.0f,1.0f,1.0f,0.0f);
	*	 services.setVertexShaderConstant(cast(const float*)(&col), 9, 1);
	*	 // for high level shading languages, this would be another solution:
	*	 //services.setVertexShaderConstant("myColor", cast(float*)(&col), 4);
	* }
	* ------
	* Params:
	* 	services=  Pointer to an interface providing methods to set the constants for the shader.
	* 	userData=  Userdata int which can be specified when creating the shader.
	*/
	void OnSetConstants(IMaterialRendererServices services, int userData);
}