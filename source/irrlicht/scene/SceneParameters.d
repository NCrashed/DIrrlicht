// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
/**
* Header file containing all scene parameters for modifying mesh loading etc.
*	This file includes all parameter names which can be set using ISceneManager::getParameters()
*	to modify the behavior of plugins and mesh loaders.
*/
module irrlicht.scene.SceneParameters;

/// Name of the parameter for changing how Irrlicht handles the ZWrite flag for transparent (blending) materials
/**
* The default behavior in Irrlicht is to disable writing to the
* z-buffer for all really transparent, i.e. blending materials. This
* avoids problems with intersecting faces, but can also break renderings.
* If transparent materials should use the SMaterial flag for ZWriteEnable
* just as other material types use this attribute.
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(ALLOW_ZWRITE_ON_TRANSPARENT, true);
* ------
**/
enum ALLOW_ZWRITE_ON_TRANSPARENT = "Allow_ZWrite_On_Transparent";

/// Name of the parameter for changing the texture path of the built-in csm loader.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(CSM_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum CSM_TEXTURE_PATH = "CSM_TexturePath";

/// Name of the parameter for changing the texture path of the built-in lmts loader.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(LMTS_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum LMTS_TEXTURE_PATH = "LMTS_TexturePath";

/// Name of the parameter for changing the texture path of the built-in my3d loader.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(MY3D_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum MY3D_TEXTURE_PATH = "MY3D_TexturePath";

/// Name of the parameter specifying the COLLADA mesh loading mode
/**
* Specifies if the COLLADA loader should create instances of the models, lights and
* cameras when loading COLLADA meshes. By default, this is set to false. If this is
* set to true, the ISceneManager::getMesh() method will only return a pointer to a
* dummy mesh and create instances of all meshes and lights and cameras in the collada
* file by itself. Example:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(COLLADA_CREATE_SCENE_INSTANCES, true);
* ------
*/
enum COLLADA_CREATE_SCENE_INSTANCES = "COLLADA_CreateSceneInstances";

/// Name of the parameter for changing the texture path of the built-in DMF loader.
/**
* This path is prefixed to the file names defined in the Deled file when loading
* textures. This allows to alter the paths for a specific project setting.
* Use it like this:
* Examples:
* ------
* SceneManager.getStringParameters().setAttribute(DMF_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum DMF_TEXTURE_PATH = "DMF_TexturePath";

/// Name of the parameter for preserving DMF textures dir structure with built-in DMF loader.
/**
* If this parameter is set to true, the texture directory defined in the Deled file
* is ignored, and only the texture name is used to find the proper file. Otherwise, the
* texture path is also used, which allows to use a nicer media layout.
* Use it like this:
* Examples:
* ------
* //this way you won't use this setting (default)
* SceneManager.getParameters().setAttribute(DMF_IGNORE_MATERIALS_DIRS, false);
* ------
* Examples:
* ------
* //this way you'll use this setting
* SceneManager.getParameters().setAttribute(DMF_IGNORE_MATERIALS_DIRS, true);
* ------
**/
enum DMF_IGNORE_MATERIALS_DIRS = "DMF_IgnoreMaterialsDir";

/// Name of the parameter for setting reference value of alpha in transparent materials.
/**
* Use it like this:
* Examples:
* ------
* //this way you'll set alpha ref to 0.1
* SceneManager.getParameters().setAttribute(DMF_ALPHA_CHANNEL_REF, 0.1);
* ------
**/
enum DMF_ALPHA_CHANNEL_REF = "DMF_AlphaRef";

/// Name of the parameter for choose to flip or not tga files.
/**
* Use it like this:
* Examples:
* ------
* //this way you'll choose to flip alpha textures
* SceneManager.getParameters().setAttribute(DMF_FLIP_ALPHA_TEXTURES, true);
* ------
**/
enum DMF_FLIP_ALPHA_TEXTURES = "DMF_FlipAlpha";


/// Name of the parameter for changing the texture path of the built-in obj loader.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(OBJ_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum OBJ_TEXTURE_PATH = "OBJ_TexturePath";

/// Flag to avoid loading group structures in .obj files
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(OBJ_LOADER_IGNORE_GROUPS, true);
* ------
**/
enum OBJ_LOADER_IGNORE_GROUPS = "OBJ_IgnoreGroups";


/// Flag to avoid loading material .mtl file for .obj files
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(OBJ_LOADER_IGNORE_MATERIAL_FILES, true);
* ------
**/
enum OBJ_LOADER_IGNORE_MATERIAL_FILES = "OBJ_IgnoreMaterialFiles";


/// Flag to ignore the b3d file's mipmapping flag
/**
* Instead Irrlicht's texture creation flag is used. Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(B3D_LOADER_IGNORE_MIPMAP_FLAG, true);
* ------
**/
enum B3D_LOADER_IGNORE_MIPMAP_FLAG = "B3D_IgnoreMipmapFlag";

/// Name of the parameter for changing the texture path of the built-in b3d loader.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(B3D_TEXTURE_PATH, "path/to/your/textures");
* ------
**/
enum B3D_TEXTURE_PATH = "B3D_TexturePath";

/// Flag set as parameter when the scene manager is used as editor
/**
* In this way special animators like deletion animators can be stopped from
* deleting scene nodes for example 
*/
enum IRR_SCENE_MANAGER_IS_EDITOR = "IRR_Editor";

/// Name of the parameter for setting the length of debug normals.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttribute(DEBUG_NORMAL_LENGTH, 1.5f);
* ------
**/
enum DEBUG_NORMAL_LENGTH = "DEBUG_Normal_Length";

/// Name of the parameter for setting the color of debug normals.
/**
* Use it like this:
* Examples:
* ------
* SceneManager.getParameters().setAttributeAsColor(DEBUG_NORMAL_COLOR, video::SColor(255, 255, 255, 255));
* ------
**/
enum DEBUG_NORMAL_COLOR = "DEBUG_Normal_Color";

